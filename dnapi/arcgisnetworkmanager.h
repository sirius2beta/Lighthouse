#ifndef ARCGISNETWORKMANAGER_H
#define ARCGISNETWORKMANAGER_H


#include <QNetworkAccessManager>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QNetworkDiskCache>
#include <QStandardPaths>
#include <QQmlNetworkAccessManagerFactory>
#include <QDebug>

class ArcGISInterceptor : public QNetworkAccessManager {
    Q_OBJECT
public:
    ArcGISInterceptor(QObject *parent = nullptr) : QNetworkAccessManager(parent) {
        // 設定硬碟快取，這能解決「卡」的問題
        QNetworkDiskCache *diskCache = new QNetworkDiskCache(this);
        QString cachePath = QStandardPaths::writableLocation(QStandardPaths::CacheLocation) + "/tile_cache";
        diskCache->setCacheDirectory(cachePath);
        diskCache->setMaximumCacheSize(500 * 1024 * 1024); // 500MB 快取
        this->setCache(diskCache);
    }

protected:
    QNetworkReply* createRequest(Operation op, const QNetworkRequest &req, QIODevice *outgoingData = nullptr) override {
            QUrl url = req.url();
            QString urlStr = url.toString();

            // 偵測是否為我們設定的虛擬路徑 (127.0.0.1)
            if (urlStr.contains("127.0.0.1/arcgis")) {
                QStringList parts = urlStr.split('?');
                if (parts.size() > 1) {
                    QString path = parts.last().replace(".png", "");
                    QStringList coords = path.split('/');

                    if (coords.size() >= 3) {
                        QString z = coords[0];
                        QString x = coords[1];
                        QString y = coords[2];

                        // 重組成 ArcGIS 格式 (Z/Y/X)
                        QString newUrl = QString("https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/%1/%2/%3")
                                         .arg(z).arg(y).arg(x);
                        qDebug() << "Redirect to:" << newUrl;
                        QNetworkRequest newRequest(newUrl);
                        // 這裡很重要：設定屬性，讓 Qt 知道這是一個轉發的請求
                        newRequest.setAttribute(QNetworkRequest::CacheLoadControlAttribute, QNetworkRequest::PreferCache);
                        newRequest.setRawHeader("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) Lighthouse/1.0");

                        // 直接回傳對真實網址的請求
                        return QNetworkAccessManager::createRequest(op, newRequest, outgoingData);
                    }
                }
            }
            // 如果不是地圖請求，就照常處理
            return QNetworkAccessManager::createRequest(op, req, outgoingData);
        }
};

// 工廠類別：讓 QML 引擎使用我們的攔截器
class ArcGISNetworkFactory : public QQmlNetworkAccessManagerFactory {
public:
    QNetworkAccessManager *create(QObject *parent) override {
        qDebug() << ">>> Factory 正在建立新的 NetworkManager！"; // 看這行有沒有出現
        return new ArcGISInterceptor(parent);
    }
};

#include <QTcpServer>
#include <QTcpSocket>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QNetworkRequest>
#include <QRegularExpression>

class LighthouseMapProxy : public QTcpServer {
    Q_OBJECT
public:
    LighthouseMapProxy(QObject *parent = nullptr) : QTcpServer(parent) {
        listen(QHostAddress::LocalHost, 8080); // 監聽 8080 埠口
        connect(&networkManager, &QNetworkAccessManager::finished, this, &LighthouseMapProxy::onReplyFinished);
    }

protected:
    void incomingConnection(qintptr socketDescriptor) override {
        QTcpSocket *socket = new QTcpSocket(this);
        socket->setSocketDescriptor(socketDescriptor);
        connect(socket, &QTcpSocket::readyRead, [this, socket]() {
            QString request = socket->readAll();
            // 抓取網址中的 Z/X/Y (例如 /tile/19/438799/224521.png)
            QRegularExpression re("/tile/(\\d+)/(\\d+)/(\\d+)");
            auto match = re.match(request);
            if (match.hasMatch()) {
                QString z = match.captured(1);
                QString x = match.captured(2);
                QString y = match.captured(3);

                // 【核心修正】將 X/Y 對調以符合 ArcGIS 的 Z/Y/X 規範
                QString arcgisUrl = QString("https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/%1/%2/%3")
                                    .arg(z).arg(y).arg(x);
                QNetworkRequest req(arcgisUrl);
                req.setRawHeader("User-Agent", "Lighthouse_USV");

                // 發送請求並把 socket 暫存起來
                QNetworkReply *reply = networkManager.get(req);
                pendingRequests[reply] = socket;
            }
        });
    }

private slots:
    void onReplyFinished(QNetworkReply *reply) {
        if (pendingRequests.contains(reply)) {
            QTcpSocket *socket = pendingRequests.take(reply);
            if (socket->state() == QTcpSocket::ConnectedState) {
                // 關鍵修正：將 Content-Type 改為 image/jpeg，因為 ArcGIS 衛星圖是 JPEG
                socket->write("HTTP/1.1 200 OK\r\n");
                socket->write("Content-Type: image/jpeg\r\n");
                socket->write("Access-Control-Allow-Origin: *\r\n"); // 允許跨網域讀取
                socket->write(QString("Content-Length: %1\r\n").arg(reply->size()).toUtf8());
                socket->write("\r\n");
                socket->write(reply->readAll());
                socket->flush();
                socket->disconnectFromHost();
            }
            socket->deleteLater();
        }
        reply->deleteLater();
    }

private:
    QNetworkAccessManager networkManager;
    QMap<QNetworkReply*, QTcpSocket*> pendingRequests;
};

#endif // ARCGISNETWORKMANAGER_H
