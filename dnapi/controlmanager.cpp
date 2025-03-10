#include <QQmlEngine>
#include "controlmanager.h"
#include "dncore.h"
#include "dncontrol.h"
#include "winchcontrol.h"
#include "qdebug.h"
#include "dncore.h"
ControlManager::ControlManager(QObject *parent, DNCore *core)
    : QObject{parent},
      _boatID(-1)
{
    _core = core;
}

void ControlManager::init()
{
    QQmlEngine::setObjectOwnership(this, QQmlEngine::CppOwnership);
    qDebug()<<"initializing ControlManager...";
    QVector<ControlItem> controls = _core->configManager()->controlList();
    for(int i = 0; i < controls.size(); i++){
        WinchControl* winchControl = new WinchControl(this);
        winchControl->init(&controls[i]);
        //ControlItem* newControl = new ControlItem(controls[i],this);
        winchControl->setBoatID(0);
        connect(winchControl, &ControlItem::sendMsgbyID, _core->networkManager(), &NetworkManager::sendMsgbyID);

        _controls.append(winchControl);
    }
    qDebug()<<"    ... done";
}

void ControlManager::sendControlMsg(QByteArray msg)
{
    emit sendMsg(_boatID, _core->configManager()->message(ConfigManager::msg_control()), msg);
}

void ControlManager::setBoatID(int boatID)
{
    _boatID = boatID;
}

void ControlManager::onMsg(QByteArray command)
{

}

ControlItem* ControlManager::getDevice(int index)
{
    if(index >= _controls.count()){
        qDebug()<<"\u001b[38;5;203m"<<"**Fatal error:ControlManager::getDevice: index out of range"<<"\033[0m";
        return 0;
    }
    return qobject_cast<ControlItem*>(_controls.get(index));
}
