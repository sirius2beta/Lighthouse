#ifndef MARINEDATABASE_H
#define MARINEDATABASE_H

#include <QObject>
#include <QString>
#include <QSqlDatabase>
#include <QJsonDocument>
#include <QJsonObject>
#include <QMap>
#include <QVariant>
#include "dnvalue.h"

#include <QTimer>

class MarineDatabase : public QObject {
    Q_OBJECT

    // 💡 1. 修正 Q_PROPERTY：拔除 CONSTANT，加入 WRITE 和 NOTIFY，讓 QML 可以雙向綁定與監聽
    Q_PROPERTY(QString dbName READ dbName NOTIFY dbNameChanged)
    Q_PROPERTY(int writeInterval READ writeInterval WRITE setWriteInterval NOTIFY writeIntervalChanged)
    Q_PROPERTY(bool isConnected READ isConnected NOTIFY dbConnected)
public:
    static MarineDatabase *instance();
    explicit MarineDatabase(QObject *parent = nullptr, const QString& dbName = "marine.db");
    ~MarineDatabase();

    // Getter 加上 const 比較嚴謹
    QString dbName() const { return m_dbName; }
    int writeInterval() const { return _writeInterval; }
    bool isConnected() const { return !m_isClosed;}

    Q_INVOKABLE bool openConnection(const QString& path);
    Q_INVOKABLE void closeConnection();

    // 💡 把 setWriteInterval 的實作移到 .cpp，因為裡面需要 emit signal 還有重啟 Timer
    Q_INVOKABLE void setWriteInterval(int t);
    Q_INVOKABLE void startLogging();
    Q_INVOKABLE void stopLogging();

    Q_INVOKABLE QString defaultLogDirectory() const;
    Q_INVOKABLE void setDefaultLogDirectory(const QString& path);
    Q_INVOKABLE QVariantList fetchTrajectoryData(int fieldIndex);
    Q_INVOKABLE QVariantMap fetchLatestPoint(int fieldIndex);
signals:
    void connectionStatusChanged(bool connected);
    void dataInsertedSuccessfully();

    // 💡 2. 新增與 Q_PROPERTY 搭配的 Signal
    void dbNameChanged(QString newName);
    void writeIntervalChanged(int newInterval);
    void dbConnected(bool isConnected);

public slots:
    // 接收各個感測器打包來的最新資料 (存入 m_sensorCache)
    void handleDataUpdate(const QVariantMap& aquaData);

private slots:
    // 💡 3. 新增一個給 QTimer 時間到時，負責將 m_sensorCache 寫入 SQLite 的專用 Slot
    void handleLogTimeout();

private:
    static QString settingsRoot() { return QStringLiteral("MarineDatabaseConfig"); }
    QString m_dbName;
    QString m_connectionName;
    QMap<QString, QVariant> m_sensorCache;
    bool createTables();
    bool m_isClosed = true;

    int _writeInterval;
    QTimer* m_logTimer; // 💡 4. 新增定時器物件
};

#endif // MARINEDATABASE_H
