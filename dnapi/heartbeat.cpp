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
    run = false;
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
    //QString cmd;
    QByteArray cmd_bytes;
    QString ip;

    if(primary){
        cmd_bytes.resize(2);
        cmd_bytes[0] = boat->ID();
        cmd_bytes[1] = 'P';
        ip = boat->PIP();
    }else{
        cmd_bytes.resize(2);
        cmd_bytes[0] = boat->ID();
        cmd_bytes[1] = 'S';
        ip = boat->SIP();
    }
    emit sendMsg(QHostAddress(ip), _core->configManager()->message("HEARTBEAT"),cmd_bytes);
}

void HeartBeat::checkAlive()
{
    if(isAlive == false){
        checkAliveTimer->stop();
        HeartBeatLoop();
    }
    isAlive = false;
}

