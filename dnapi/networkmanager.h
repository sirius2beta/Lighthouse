#ifndef NETWORKMANAGER_H
#define NETWORKMANAGER_H

#include <QObject>
#include <QUdpSocket>
#include "boatmanager.h"

class DNCore;

class NetworkManager : public QObject
{
    Q_OBJECT
public:
    explicit NetworkManager(QObject *parent = nullptr, DNCore* core = nullptr);
    void init();

signals:
    void AliveResponse(QString ip, uint8_t boatID);
    void setFormat(uint8_t boatID, QByteArray data);
    void sensorMsg(uint8_t boatID, QByteArray data);
    void controlMsg(uint8_t boatID, QByteArray data);
    void detectMsg(uint8_t boatID, QByteArray data);
    void cameraMsg(uint8_t boatID, QByteArray data);
    void deviceStatusMsg(uint8_t boatID, QByteArray data);
public slots:
    void sendMsg(QHostAddress addr, uint8_t topic, QByteArray command = "");
    void sendMsgbyID(uint8_t boatID, uint8_t topic, QByteArray command = "");

protected slots:
    void onUDPMsg();
private:
    QUdpSocket *serverSocket;
    QUdpSocket *clientSocket;
    DNCore* _core;
};

#endif // NETWORKMANAGER_H
