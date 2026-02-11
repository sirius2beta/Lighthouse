#include <QTimer>
#include <QDebug>

#include "heartbeat.h"
#include "networkmanager.h"
#include "dncore.h"



HeartBeat::HeartBeat(QObject *parent, DNCore *core): QObject(parent)
{
    _core = core;
}

HeartBeat::HeartBeat(BoatItem* boat, int port, bool isPrimary, QObject *parent, DNCore *core): QObject(parent)
{

    _core = core;
    boatPort = port;
    isAlive = false;
    isHearBeatLoop = false;
    primary = isPrimary;
    this->boat = boat;

    heartBeatTimer = new QTimer(this);
    checkAliveTimer = new QTimer(this);
    connect(heartBeatTimer, &QTimer::timeout, this, &HeartBeat::beat);
    connect(checkAliveTimer,&QTimer::timeout, this, &HeartBeat::checkAlive);
    connect(_core->networkManager(), &NetworkManager::AliveResponse, this, &HeartBeat::alive);
    connect(this, &HeartBeat::sendMsg, _core->networkManager(), &NetworkManager::sendMsg);
    connect(this, &HeartBeat::sendMsgbyID, _core->networkManager(), &NetworkManager::sendMsgbyID);


    qDebug()<<"HeartBeat: initiated (ID: "<< boat->ID()<<")";

}

HeartBeat::~HeartBeat()
{
}


void HeartBeat::onDeleteBoat(QString boatname)
{

    if(boatname == boat->name()){
        this->deleteLater();
    }

}

void HeartBeat::HeartBeatLoop()
{
    heartBeatTimer->start(1000);
    isHearBeatLoop = true;
    isAlive = false;

    boat->disconnect(primary);



}


void HeartBeat::alive(uint8_t ID, const bool &isPrimary)
{
    if(ID == boat->ID() && isPrimary == this->primary){
        //qDebug()<<"get HeartBeat boatname:"<<boat->name();
        if(isHearBeatLoop == false){

            isAlive = true;
        }else{
            // Enter alive loop
            //qDebug()<<"HeartBeat::AliveLoop started ("<<boat->name()<<", "<<ip<<")";
            //heartBeatTimer->stop();
            checkAliveTimer->start(2000);
            isHearBeatLoop = false;
            boat->connect(primary);
            beat(); //boat heart beat may come first, we have to send a heartbeat first to let it know
            //if we are primary
            emit sendMsgbyID(ID, _core->configManager()->message("FORMAT"), QString("q").toLocal8Bit());
            qDebug()<<"HeartBeat boatname:"<<boat->name();

        }
    }else{
        //Deposit other boat's message;
    }
}

void HeartBeat::beat()
{
    QByteArray cmd_bytes;
    QString ip;
    SharedLinkInterfacePtr sharedLink;

    if(primary){
        ip = boat->PIP();
        sharedLink = LinkManager::instance()->mavlinkPrimaryUDPLink();
    }else{
        ip = boat->SIP();
        sharedLink = LinkManager::instance()->mavlinkSecondaryUDPLink();
    }



    uint8_t payload[251];
    memset(payload, 0, sizeof(payload));

    mavlink_message_t message{};
    mavlink_msg_custom_legacy_wrapper_pack_chan(
        1,                          // System ID
        2,                          // Component ID
        sharedLink->mavlinkChannel(),
        &message,
        1,                          // Target System
        1,                          // Target Component
        0,    // 原始資料長度
        0, // heartbeat topic: 0
        payload                     // 使用處理過的填充陣列，而非直接用 command.data()
        );

    emit sendMsg(QHostAddress(ip), sharedLink.get(), message);
}

void HeartBeat::checkAlive()
{
    if(isAlive == false){
        checkAliveTimer->stop();
        HeartBeatLoop();
    }
    isAlive = false;
}

