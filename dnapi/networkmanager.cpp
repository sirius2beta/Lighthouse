#include "networkmanager.h"
#include "dncore.h"
#include <QQmlEngine>
#include "configmanager.h"



NetworkManager::NetworkManager(QObject *parent, DNCore *core)
    : QObject{parent}
{
    _core = core;
    serverSocket = new QUdpSocket(this);
    clientSocket = new QUdpSocket(this);
    clientSocket->bind(50008,QUdpSocket::ShareAddress);

}

void NetworkManager::init()
{
    QQmlEngine::setObjectOwnership(this, QQmlEngine::CppOwnership);
    connect(clientSocket,&QUdpSocket::readyRead,this, &NetworkManager::onUDPMsg);
}

void NetworkManager::sendMsg(QHostAddress addr, uint8_t topic, QByteArray command)
{
    QByteArray cmd;
    cmd.resize(1);
    cmd[0] = topic;
    cmd.append(command);
    serverSocket->writeDatagram(cmd,cmd.size(), addr, 50006);
}

void NetworkManager::sendMsgbyID(int boatID, uint8_t topic, QByteArray command)
{
    BoatItem* boat = _core->boatManager()->getBoatbyID(boatID);
    if(boat != 0){
        qDebug()<<"sd";
        sendMsg(QHostAddress(boat->currentIP()), topic, command);
    }else{
        qDebug()<<"\u001b[38;5;203m"<<"**Fatal error: NetworkManager::sendMsgbyID boatID outof range"<<"\033[0m";
    }
}

void NetworkManager::onUDPMsg()
{


    while(clientSocket->hasPendingDatagrams()){
        QByteArray data;
        QHostAddress addr;
        QString ip;
        data.resize(clientSocket->pendingDatagramSize());
        clientSocket->readDatagram(data.data(),data.size(),&addr);

        uint8_t topic = data[0];
        data.remove(0,1);

        ip = QHostAddress(addr.toIPv4Address()).toString();

        QStringList dataList = QString(data).split(' ');
        QString message;
        if(data.split(' ').size() >1){
            message = data.split(' ')[1];
        }

        QString msgType = _core->configManager()->messageChar(topic);
        //qDebug() << topic<<","<<msgType;
        if(msgType == ConfigManager::msg_heartbeat()){
            int ID = int(data[0]);
            //qDebug() << ID;
            BoatItem* boat = _core->boatManager()->getBoatbyID(ID);

            if( boat != 0){

                emit AliveResponse(ip, ID);
            }


        }else if(msgType == ConfigManager::msg_format()){
            int ID = int(data[0]);
            data.remove(0,1);
            emit setFormat(ID, data);
        }else if(msgType == ConfigManager::msg_sensor()){
            //qDebug()<<"NetworkManager:: on sensor msg";
            int ID = int(data[0]);
            data.remove(0,1);
            emit sensorMsg(ID, data);
        }else if(topic == 5){
            int ID = int(data[0]);
            data.remove(0,1);
            emit controlMsg(ID,data);
        }
        const QString content = QLatin1String(" Received Topic: ")
                    + QChar(topic)
                                + QLatin1String(" Message: ") + QString::number(data.size());
        //qDebug() << content;
    }
}
