#ifndef NETWORKMANAGER_H
#define NETWORKMANAGER_H

#include <QObject>
#include <QUdpSocket>
#include "boatmanager.h"
#include "MAVLinkLib.h"
#include "LinkManager.h"



class DNCore;

class NetworkManager : public QObject
{
    Q_OBJECT
public:
    explicit NetworkManager(QObject *parent = nullptr, DNCore* core = nullptr);
    void init();

signals:
    void AliveResponse(uint8_t boatID, const bool& isPrimary);
    void setFormat(uint8_t boatID, QByteArray data);
    void sensorMsg(uint8_t boatID, QByteArray data);
    void controlMsg(uint8_t boatID, QByteArray data);
    void detectMsg(uint8_t boatID, QByteArray data);
    void cameraMsg(uint8_t boatID, QByteArray data);
    void deviceStatusMsg(uint8_t boatID, QByteArray data);
public slots:
    void sendMsgSelect(QHostAddress addr, bool isPrimary, uint8_t topic, QByteArray command = "");
    void sendMsg(QHostAddress addr, LinkInterface* link, uint8_t topic, QByteArray command = "");
    void sendMsgbyID(uint8_t boatID, uint8_t topic, QByteArray command = "");
    void onIPChanged(const int &ID, bool isPrimary);
protected:
    void parseMsg(const bool &isPrimary, const mavlink_message_t &message);

protected slots:
    void _mavlinkMessageReceived(LinkInterface* link, mavlink_message_t message);

private:
    DNCore* _core;
};

#endif // NETWORKMANAGER_H
