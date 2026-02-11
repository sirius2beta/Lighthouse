#ifndef HEARTBEAT_H
#define HEARTBEAT_H

#include <QObject>
#include <QHostAddress>

#include "boatitem.h"
#include "boatmanager.h"
#include "LinkInterface.h"

class DNCore;
class HeartBeat : public QObject
{
    Q_OBJECT
public:
    explicit HeartBeat(QObject *parent = nullptr, DNCore *core= nullptr);
    HeartBeat(BoatItem* boat, int port, bool isPrimary, QObject *parent = nullptr, DNCore *core = nullptr);
    void HeartBeatLoop();
    ~HeartBeat();

signals:
    void sendMsg(QHostAddress addr, LinkInterface* link, char topic, QByteArray command);
    void sendMsgbyID(const int &ID, char topic, QByteArray command);

public slots:
    void beat();
    void checkAlive();
    void alive(uint8_t ID, const bool& isPrimary);
    void onDeleteBoat(QString boatname);

private:
    QTimer *heartBeatTimer;
    QTimer *checkAliveTimer;
    int boatPort;
    bool isAlive;
    bool isHearBeatLoop;
    bool primary;
    BoatItem* boat;
    BoatManager* boatList;
    DNCore* _core;

};

#endif // HEARTBEAT_H
