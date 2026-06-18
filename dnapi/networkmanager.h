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
    Q_PROPERTY(QStringList forwardConnections READ forwardConnections NOTIFY forwardConnectionsChanged)
public:
    explicit NetworkManager(QObject *parent = nullptr, DNCore* core = nullptr);
    void init();
    QStringList forwardConnections() const { return _forwardConnections; }
    Q_INVOKABLE void addForwardConnection(const QString &address);
    Q_INVOKABLE void removeForwardConnection(const QString &address);
    Q_INVOKABLE void editForwardConnection(int index, const QString &address);
signals:
    void AliveResponse(uint8_t boatID, const bool& isPrimary);
    void setFormat(uint8_t boatID, QByteArray data);
    void sensorMsg(uint8_t boatID, QByteArray data);
    void controlMsg(uint8_t boatID, QByteArray data);
    void detectMsg(uint8_t boatID, QByteArray data);
    void cameraMsg(uint8_t boatID, QByteArray data);
    void deviceStatusMsg(uint8_t boatID, QByteArray data);
    void forwardConnectionsChanged();
public slots:
    void sendMsg(QHostAddress addr, LinkInterface* link, mavlink_message_t message);
    void sendMsgbyID(uint8_t boatID, uint8_t topic, QByteArray command = "");
    void onIPChanged(const int &ID, bool isPrimary);
protected:
    void parseMsg(const bool &isPrimary, const mavlink_message_t &message);

protected slots:
    void _mavlinkMessageReceived(LinkInterface* link, mavlink_message_t message);

private:
    void _forwardMessageToBoat(mavlink_message_t message);
    void _updateSettings();
    DNCore* _core;
    QStringList _forwardConnections;
    static QString settingsRoot() { return QStringLiteral("NetworkConfigurations"); }
};

#endif // NETWORKMANAGER_H
