#ifndef SEAGRASSHTTPCLIENT_H
#define SEAGRASSHTTPCLIENT_H

#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QJsonObject>
#include <QJsonArray>
#include <QStringList>
#include <QByteArray>

class LogHttpClient : public QObject
{
    Q_OBJECT
    // 讓 QML 可以設定或讀取 API 的基礎 URL (例如: "http://192.168.1.100:5000")
    Q_PROPERTY(QString baseUrl READ baseUrl WRITE setBaseUrl NOTIFY baseUrlChanged)

public:
    explicit LogHttpClient(QObject *parent = nullptr);

    QString baseUrl() const;
    void setBaseUrl(const QString &url);

public slots:
    // 對應你的 4 個 Flask API
    void fetchLatestLog();
    void fetchStructure();
    void fetchImagesInRecord(const QString &recordDir);

    // 注意：如果是 QML 要顯示圖片，建議直接在 QML 的 Image source 填入 URL。
    // 這個 C++ 方法主要用於如果你需要在 C++ 端做影像處理 (例如 OpenCV) 時下載用。
    void fetchImage(const QString &recordDir, const QString &filename);

signals:
    void baseUrlChanged();

    // 成功獲取資料的 Signals
    void latestLogReceived(const QJsonObject &logData);
    void structureReceived(const QStringList &records);
    void imagesListReceived(const QString &recordDir, int totalCount, const QStringList &images);
    void imageReceived(const QString &recordDir, const QString &filename, const QByteArray &imageData);

    // 統一的錯誤處理 Signal
    void errorOccurred(const QString &apiEndpoint, const QString &errorMsg);

private:
    QNetworkAccessManager *m_manager;
    QString m_baseUrl;
};

#endif // SEAGRASSHTTPCLIENT_H
