﻿#ifndef HEARTBEAT_H
#define HEARTBEAT_H

#include <QObject>
#include <QHostAddress>

#include "boatitem.h"
#include "boatmanager.h"

class DNCore;
class HeartBeat : public QObject
{
    Q_OBJECT
public:
    explicit HeartBeat(QObject *parent = nullptr, DNCore *core= nullptr);
    HeartBeat(BoatItem* boat, int port, bool isPrimary, QObject *parent = nullptr, DNCore *core = nullptr);
    void HeartBeatLoop(); //工作函数
    ~HeartBeat();

signals:
    void sendMsg(QHostAddress addr, char topic, QByteArray command);

public slots:
    void beat();
    void checkAlive();
    void alive(QString ip, uint8_t ID);
    void onChangeIP(uint8_t ID, bool isPrimary);
    void onDeleteBoat(QString boatname);

private:
    QString boatIP;
    bool run;
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
