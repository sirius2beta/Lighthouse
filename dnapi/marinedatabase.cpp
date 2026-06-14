#include "marinedatabase.h"
#include <QSqlQuery>
#include <QSqlError>
#include <QDebug>
#include <QUuid>
#include <QTimer>
#include <QDateTime>
#include <QJsonDocument>
#include <QJsonObject>
#include <QDir>
#include <QFileInfo>
#include <QSettings>
#include <QStandardPaths>
#include <QtCore/qapplicationstatic.h>

Q_APPLICATION_STATIC(MarineDatabase, _marineDatabaseInstance);

MarineDatabase* MarineDatabase::instance()
{
    return _marineDatabaseInstance;
}

MarineDatabase::MarineDatabase(QObject *parent, const QString& dbName)
    : QObject(parent), m_dbName(dbName), _writeInterval(5) // 預設 5 秒
{
    m_connectionName = QUuid::createUuid().toString();
    QSettings settings;
    // Is the group even there?

    m_logTimer = new QTimer(this);
    connect(m_logTimer, &QTimer::timeout, this, &MarineDatabase::handleLogTimeout);
    if (settings.contains(settingsRoot() + "/lastRecord")) {
        QString path = settings.value(settingsRoot() + "/lastRecord").toString();
        openConnection(path);
    }
}

MarineDatabase::~MarineDatabase() {
    stopLogging(); // 確保析構時停止定時器
    closeConnection();
}

bool MarineDatabase::openConnection(const QString& path) {
    // 💡 2. 更新檔名並發射訊號給 QML
    if (m_dbName != path) {
        m_dbName = path;
        emit dbNameChanged(m_dbName);
    }

    // 💡 3. 自動建立目標資料夾，避免硬碟路徑不存在導致 open 失敗
    QFileInfo fileInfo(m_dbName);
    QDir().mkpath(fileInfo.absolutePath());

    // 預防機制：如果舊連線還開著，先把它清掉
    if (QSqlDatabase::contains(m_connectionName)) {
        closeConnection();
    }

    m_isClosed = false;
    emit dbConnected(m_isClosed);
    QSqlDatabase db = QSqlDatabase::addDatabase("QSQLITE", m_connectionName);
    db.setDatabaseName(m_dbName);

    if (!db.open()) {
        qDebug() << "無法開啟海洋資料庫:" << db.lastError().text();
        closeConnection();
        emit connectionStatusChanged(false);
        return false;
    }

    // 💡 為了即時作圖順暢，開啟 WAL 模式
    QSqlQuery query(db);
    if (!query.exec("PRAGMA journal_mode=WAL;")) {
        qDebug() << "無法啟動 WAL 模式:" << query.lastError().text();
    }

    if (!createTables()) {
        closeConnection(); // 如果建表失敗，記得把連線完整關閉
        emit connectionStatusChanged(false);
        return false;
    }
    m_sensorCache.clear();
    QSettings settings;
    settings.setValue(settingsRoot() + "/lastRecord", path);
    emit connectionStatusChanged(true);
    return true;
}

void MarineDatabase::closeConnection() {

    if (m_isClosed) {
        return;
    }


    m_isClosed = true;
    emit dbConnected(m_isClosed);

    if (!QSqlDatabase::contains(m_connectionName)) {
        return;
    }

    {
        QSqlDatabase db = QSqlDatabase::database(m_connectionName, false);
        if (db.isOpen()) {
            db.close();
        }
    }

    QSqlDatabase::removeDatabase(m_connectionName);
    emit connectionStatusChanged(false);
}


void MarineDatabase::setWriteInterval(int t) {
    if (_writeInterval != t) {
        _writeInterval = t;
        emit writeIntervalChanged(_writeInterval); // 通知 QML 介面更新

        // 如果目前正在紀錄中，更改頻率後要即時套用新頻率
        if (m_logTimer->isActive()) {
            m_logTimer->start(_writeInterval * 1000); // 假設 QML 傳入的是秒，轉成毫秒
        }
    }
}

void MarineDatabase::startLogging() {
    if (!m_logTimer->isActive()) {
        m_logTimer->start(_writeInterval * 1000); // 啟動定時器
        qDebug() << "開始紀錄資料，間隔:" << _writeInterval << "秒";
    }
}

void MarineDatabase::stopLogging() {
    if (m_logTimer->isActive()) {
        m_logTimer->stop();
        qDebug() << "停止紀錄資料";
    }
}

// ==========================================
// 📊 資料暫存與寫入機制 (JSON 擴充架構)
// ==========================================

// 💡 4. 動態建表：採用 JSON 單一欄位架構，永遠不怕感測器增減
bool MarineDatabase::createTables() {
    QSqlDatabase db = QSqlDatabase::database(m_connectionName);
    QSqlQuery query(db);

    QString sql = "CREATE TABLE IF NOT EXISTS sensor_logs ("
                  "id INTEGER PRIMARY KEY AUTOINCREMENT, "
                  "timestamp TEXT NOT NULL, "
                  "data_json TEXT NOT NULL)";

    if (!query.exec(sql)) {
        qDebug() << "建立資料表失敗:" << query.lastError().text();
        return false;
    }
    return true;
}

// 接收所有感測器的最新數值，更新暫存區
void MarineDatabase::handleDataUpdate(const QVariantMap& data) {
    for(auto it = data.begin(); it != data.end(); ++it) {
        m_sensorCache[it.key()] = it.value();
    }
}

// 💡 5. 定時器觸發：將暫存區的資料打包成 JSON 寫入資料庫
void MarineDatabase::handleLogTimeout() {
    if (!QSqlDatabase::contains(m_connectionName)) return;

    QSqlDatabase db = QSqlDatabase::database(m_connectionName);
    if (!db.isOpen()) return;

    // 如果暫存區沒有任何資料，就不寫入，避免產生空紀錄
    if (m_sensorCache.isEmpty()) return;

    // 將 QMap 轉換為 QJsonObject，再轉成 JSON 字串
    QJsonObject jsonObj = QJsonObject::fromVariantMap(m_sensorCache);
    QJsonDocument doc(jsonObj);
    QString jsonString = doc.toJson(QJsonDocument::Compact);

    // 執行寫入
    QSqlQuery query(db);
    query.prepare("INSERT INTO sensor_logs (timestamp, data_json) VALUES (:time, :json)");
    // 紀錄到毫秒 (ISODateWithMs) 更有利於工業作圖對齊
    query.bindValue(":time", QDateTime::currentDateTime().toString(Qt::ISODateWithMs));
    query.bindValue(":json", jsonString);

    if (!query.exec()) {
        qDebug() << "定時對齊寫入失敗:" << query.lastError().text();
    } else {
        emit dataInsertedSuccessfully(); // 寫入成功，可讓 UI 閃爍狀態燈
    }
}


// 💡 讓 QML 可以讀取目前設定的日誌根目錄（如果沒設定過，就預設在 C:/boat_logs 或文件資料夾）
QString MarineDatabase::defaultLogDirectory() const {
    QSettings settings; // 👈 因為你在 main 設定了 AppName，這裡會自動對應到正確的 INI 檔

    // 預設路徑：優先使用 C:/boat_logs，若沒有則用系統的「文件」資料夾
    QString fallbackPath = "C:/boat_logs";
    if (!QDir(fallbackPath).exists()) {
        fallbackPath = QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation) + "/Lighthouse_Logs";
    }

    // 讀取設定，如果 INI 檔內沒有，就回傳 fallbackPath
    return settings.value("storage/log_root_dir", fallbackPath).toString();
}

// 💡 如果未來使用者想在 UI 更改根目錄，可以呼叫這個儲存
void MarineDatabase::setDefaultLogDirectory(const QString& path) {
    QSettings settings;
    settings.setValue("storage/log_root_dir", path);
}



QVariantList MarineDatabase::fetchTrajectoryData(int fieldIndex) {
    QVariantList trajectory;
    QSqlDatabase db = QSqlDatabase::database(m_connectionName);
    if ( !db.isOpen()) {
        return trajectory;
    }

    // 💡 效能關鍵：每 5 筆抽樣 1 筆 (id % 5 = 0)。記得把 id 也撈出來給 QML 防呆用！
    QSqlQuery query(db);
    query.prepare("SELECT id, data_json FROM sensor_logs WHERE id % 50 = 0");

    if (!query.exec()) {
        qDebug() << "讀取軌跡資料失敗:" << query.lastError().text();
        return trajectory;
    }

    while (query.next()) {
        int id = query.value(0).toInt();

        QString jsonStr = query.value(1).toString();
        QJsonDocument doc = QJsonDocument::fromJson(jsonStr.toUtf8());
        QJsonObject jsonObj = doc.object();

        double val = 0.0;
        double lat = jsonObj.value("lat").toDouble();
        double lon = jsonObj.value("lon").toDouble();

        if (fieldIndex == 1) {
            val = jsonObj.value("temperature").toDouble();
        } else if (fieldIndex == 2) {
            val = jsonObj.value("depth").toDouble();
        } else if (fieldIndex == 3) {
            val = jsonObj.value("dissolved_oxygen_concentration").toDouble();
        }

        // 將這一個點包裝成 QVariantMap (QML 中會變成 JavaScript Object)
        QVariantMap point;
        point["id"] = id;
        point["lat"] = lat;
        point["lon"] = lon;
        point["value"] = val;

        trajectory.append(point);
    }

    return trajectory;
}

QVariantMap MarineDatabase::fetchLatestPoint(int fieldIndex) {
    QVariantMap point;
    point["id"] = -1; // 預設無效值，給 QML 判斷用
    QSqlDatabase db = QSqlDatabase::database(m_connectionName);

    if (fieldIndex == 0 || !db.isOpen()) {
        return point;
    }

    // 💡 利用 ORDER BY id DESC LIMIT 1，瞬間抓出最新的一筆紀錄
    QSqlQuery query(db);
    query.prepare("SELECT id, data_json FROM sensor_logs ORDER BY id DESC LIMIT 1");

    if (!query.exec()) {
        qDebug() << "讀取最新點位失敗:" << query.lastError().text();
        return point;
    }

    if (query.next()) {
        int id = query.value(0).toInt();

        QString jsonStr = query.value(1).toString();
        QJsonDocument doc = QJsonDocument::fromJson(jsonStr.toUtf8());
        QJsonObject jsonObj = doc.object();

        double val = 0.0;
        double lat = jsonObj.value("lat").toDouble();
        double lon = jsonObj.value("lon").toDouble();

        if (fieldIndex == 1) {
            val = jsonObj.value("Temperature").toDouble();
        } else if (fieldIndex == 2) {
            val = jsonObj.value("Depth").toDouble();
        } else if (fieldIndex == 3) {
            val = jsonObj.value("pH").toDouble();
        }
        point["lat"] = lat;
        point["lon"] = lon;
        point["id"] = id;
        point["value"] = val;
    }

    return point;
}
