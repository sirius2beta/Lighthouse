#include "marinedatabase.h"
#include <QSqlQuery>
#include <QSqlError>
#include <QDebug>
#include <QUuid>

MarineDatabase::MarineDatabase(QObject *parent, const QString& dbName)
    : QObject(parent), m_dbName(dbName) // 初始化父類別
{
    m_connectionName = QUuid::createUuid().toString();
}

MarineDatabase::~MarineDatabase() {
    closeConnection();
}

bool MarineDatabase::openConnection() {
    QSqlDatabase db = QSqlDatabase::addDatabase("QSQLITE", m_connectionName);
    db.setDatabaseName(m_dbName);

    if (!db.open()) {
        qDebug() << "無法開啟海洋資料庫:" << db.lastError().text();
        emit connectionStatusChanged(false); // 發射失敗訊號
        return false;
    }

    if (!createTables()) {
        emit connectionStatusChanged(false);
        return false;
    }

    emit connectionStatusChanged(true); // 發射成功訊號
    return true;
}

void MarineDatabase::closeConnection() {
    {
        QSqlDatabase db = QSqlDatabase::database(m_connectionName, false);
        if (db.isOpen()) {
            db.close();
        }
    }
    QSqlDatabase::removeDatabase(m_connectionName);
    emit connectionStatusChanged(false);
}

bool MarineDatabase::createTables() {
    QSqlDatabase db = QSqlDatabase::database(m_connectionName);
    QSqlQuery query(db);

    QString createTableQuery =
        "CREATE TABLE IF NOT EXISTS marine_records ("
        "id INTEGER PRIMARY KEY AUTOINCREMENT, "
        "location TEXT, "
        "temperature REAL, "
        "salinity REAL, "
        "timestamp DATETIME DEFAULT CURRENT_TIMESTAMP)";

    return query.exec(createTableQuery);
}

bool MarineDatabase::insertMarineData(const QString& location, double temperature, double salinity) {
    QSqlDatabase db = QSqlDatabase::database(m_connectionName);
    QSqlQuery query(db);

    query.prepare("INSERT INTO marine_records (location, temperature, salinity) "
                  "VALUES (:location, :temp, :sal)");
    query.bindValue(":location", location);
    query.bindValue(":temp", temperature);
    query.bindValue(":sal", salinity);

    if (!query.exec()) {
        return false;
    }

    emit dataInsertedSuccessfully(); // 發射資料寫入成功訊號
    return true;
}
