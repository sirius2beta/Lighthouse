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

    m_logTimer = new QTimer(this);
    connect(m_logTimer, &QTimer::timeout, this, &MarineDatabase::handleLogTimeout);
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

    emit connectionStatusChanged(true);
    return true;
}

void MarineDatabase::closeConnection() {

    if (m_isClosed) {
        return;
    }


    m_isClosed = true;

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

    // 假設 fieldIndex: 1=Temperature, 2=Depth, 3=pH
    // 如果 fieldIndex == 0 (None)，直接回傳空陣列
    QSqlDatabase db = QSqlDatabase::database(m_connectionName);

    if (fieldIndex == 0 || db.isOpen()) return trajectory;

    // 💡 效能關鍵：利用 id % 5 = 0 進行降頻抽樣，5小時的資料只抓 3600 筆！
    QSqlQuery query("SELECT lat, lon, data_json FROM sensor_logs WHERE id % 5 = 0");

    while (query.next()) {
        double lat = query.value(0).toDouble();
        double lon = query.value(1).toDouble();
        QString jsonStr = query.value(2).toString();

        // 這裡你需要根據你的 JSON 格式把數值解析出來
        // 假設你解析出來的值存入 val 變數
        double val = 0.0;
        /* 解析 jsonStr 取得對應 fieldIndex 的數值 ... */

        // 將這一個點包裝成 QVariantMap (QML 的 Object)
        QVariantMap point;
        point["lat"] = lat;
        point["lon"] = lon;
        point["value"] = val;

        trajectory.append(point);
    }

    return trajectory;
}
