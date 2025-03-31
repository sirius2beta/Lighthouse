#include <QQmlEngine>
#include "controlmanager.h"
#include "dncore.h"
#include "sonarcontrol.h"
#include "winchcontrol.h"
#include "qdebug.h"
#include "dncore.h"
ControlManager::ControlManager(QObject *parent, DNCore *core)
    : QObject{parent},
      _boatID(0)
{
    _core = core;
}

void ControlManager::init()
{
    QQmlEngine::setObjectOwnership(this, QQmlEngine::CppOwnership);
    qDebug()<<"initializing ControlManager...";
    QVector<ControlItem> controls = _core->configManager()->controlList();
    qDebug()<<controls[0].name();
    for(int i = 0; i < controls.size(); i++){
        if(controls[i].controlType() == 0){
            qDebug()<<"controlManager create"<<controls[i].name();
            WinchControl* winchControl = new WinchControl(this);
            winchControl->init(&controls[i]);
            //ControlItem* newControl = new ControlItem(controls[i],this);
            winchControl->setBoatID(0);
            connect(winchControl, &ControlItem::sendMsgbyID, _core->networkManager(), &NetworkManager::sendMsgbyID);
            _controls.append(winchControl);
        }else if(controls[i].controlType() == 2){
            SonarControl* sonarControl = new SonarControl(this);
            _controls.append(sonarControl);
        }
    }
    qDebug()<<" ... done";
}

void ControlManager::sendControlMsg(QByteArray msg)
{
    emit sendMsg(_boatID, ConfigManager::msg_control, msg);
}

void ControlManager::setBoatID(int boatID)
{
    _boatID = boatID;
}

void ControlManager::onControlMsg(uint8_t boatID, QByteArray command)
{
    if(boatID != _boatID){
        qDebug()<<"id"<<boatID<<","<<_boatID;
        return;
    }
    int8_t index;
    memcpy(&index, command.data(), sizeof(int8_t));
    command.remove(0,1);
    qDebug()<<"ControlManager::onMsg, index:"<<index;
    for(int i = 0; i < _controls.count(); i++){
        ControlItem* control = qobject_cast<ControlItem*>(_controls[i]);
        if(control->controlType() == index){
            control->processMsg(command);
        }
    }
}

ControlItem* ControlManager::getDevice(int index)
{
    if(index >= _controls.count()){
        qDebug()<<"\u001b[38;5;203m"<<"**Fatal error:ControlManager::getDevice: index out of range"<<"\033[0m";
        return 0;
    }
    return qobject_cast<ControlItem*>(_controls.get(index));
}
