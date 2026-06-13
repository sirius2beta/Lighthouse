#ifndef MARINEDATABASE_H
#define MARINEDATABASE_H

#include <QObject>
#include <QString>
#include <QSqlDatabase>

class MarineDatabase : public QObject {
    Q_OBJECT // 1. 必須加上這個巨集才能支援訊號槽與 QML

public:
    // 2. 標準的 QObject 建構子設計
    explicit MarineDatabase(QObject *parent = nullptr, const QString& dbName = "marine.db");
    ~MarineDatabase();

    // Q_INVOKABLE 允許這些函數直接在 QML 程式碼中被呼叫
    Q_INVOKABLE bool openConnection();
    Q_INVOKABLE void closeConnection();
    Q_INVOKABLE bool insertMarineData(const QString& location, double temperature, double salinity);

signals:
    // 3. 定義訊號：當資料庫狀態改變或有新資料時通知外部
    void connectionStatusChanged(bool connected);
    void dataInsertedSuccessfully();

private:
    QString m_dbName;
    QString m_connectionName;

    bool createTables();
};

#endif // MARINEDATABASE_H
