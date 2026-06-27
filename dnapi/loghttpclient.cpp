#include "loghttpclient.h"
#include <QNetworkRequest>
#include <QUrl>
#include <QJsonDocument>

LogHttpClient::LogHttpClient(QObject *parent)
    : QObject(parent), m_manager(new QNetworkAccessManager(this)), m_baseUrl("http://10.10.10.65:5000")
{
}

QString LogHttpClient::baseUrl() const
{
    return m_baseUrl;
}

void LogHttpClient::setBaseUrl(const QString &url)
{
    if (m_baseUrl != url) {
        m_baseUrl = url;
        emit baseUrlChanged();
    }
}

void LogHttpClient::fetchLatestLog()
{
    QUrl url(m_baseUrl + "/api/log/latest");
    QNetworkRequest request(url);

    QNetworkReply *reply = m_manager->get(request);
    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        reply->deleteLater();
        if (reply->error() != QNetworkReply::NoError) {
            emit errorOccurred("/api/log/latest", reply->errorString());
            return;
        }

        QJsonDocument jsonDoc = QJsonDocument::fromJson(reply->readAll());
        if (!jsonDoc.isNull() && jsonDoc.isObject()) {
            emit latestLogReceived(jsonDoc.object());
        } else {
            emit errorOccurred("/api/log/latest", "Invalid JSON format");
        }
    });
}

void LogHttpClient::fetchStructure()
{
    QUrl url(m_baseUrl + "/api/structure");
    QNetworkRequest request(url);

    QNetworkReply *reply = m_manager->get(request);
    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        reply->deleteLater();
        if (reply->error() != QNetworkReply::NoError) {
            emit errorOccurred("/api/structure", reply->errorString());
            return;
        }

        QJsonDocument jsonDoc = QJsonDocument::fromJson(reply->readAll());
        if (!jsonDoc.isNull() && jsonDoc.isObject() && jsonDoc.object().contains("records")) {
            QJsonArray recordsArray = jsonDoc.object()["records"].toArray();
            QStringList recordsList;
            for (const QJsonValue &value : recordsArray) {
                recordsList.append(value.toString());
            }
            emit structureReceived(recordsList);
        } else {
            emit errorOccurred("/api/structure", "Invalid JSON format");
        }
    });
}

void LogHttpClient::fetchImagesInRecord(const QString &recordDir)
{
    QUrl url(m_baseUrl + QString("/api/structure/%1").arg(recordDir));
    QNetworkRequest request(url);

    QNetworkReply *reply = m_manager->get(request);
    connect(reply, &QNetworkReply::finished, this, [this, recordDir, reply]() {
        reply->deleteLater();
        if (reply->error() != QNetworkReply::NoError) {
            emit errorOccurred(QString("/api/structure/%1").arg(recordDir), reply->errorString());
            return;
        }

        QJsonDocument jsonDoc = QJsonDocument::fromJson(reply->readAll());
        if (!jsonDoc.isNull() && jsonDoc.isObject()) {
            QJsonObject obj = jsonDoc.object();
            int totalCount = obj["total_count"].toInt();
            QJsonArray imagesArray = obj["images"].toArray();
            QStringList imagesList;
            for (const QJsonValue &value : imagesArray) {
                imagesList.append(value.toString());
            }
            emit imagesListReceived(recordDir, totalCount, imagesList);
        } else {
            emit errorOccurred(QString("/api/structure/%1").arg(recordDir), "Invalid JSON format");
        }
    });
}

void LogHttpClient::fetchImage(const QString &recordDir, const QString &filename)
{
    QUrl url(m_baseUrl + QString("/api/image/%1/%2").arg(recordDir, filename));
    QNetworkRequest request(url);

    QNetworkReply *reply = m_manager->get(request);
    connect(reply, &QNetworkReply::finished, this, [this, recordDir, filename, reply]() {
        reply->deleteLater();
        if (reply->error() != QNetworkReply::NoError) {
            emit errorOccurred(QString("/api/image/%1/%2").arg(recordDir, filename), reply->errorString());
            return;
        }

        QByteArray imageData = reply->readAll();
        emit imageReceived(recordDir, filename, imageData);
    });
}
