#include "winchcontrol.h"
#include <QDataStream>

WinchControl::WinchControl(QObject *parent, QString name, int controlType, QVector<DNValue> fields)
: ControlItem(parent, name, 0, fields),
  _maxSpeed(2000),
  _acceleration(1000),
  _steps(0)
{

}

void WinchControl::run(int steps)
{
    QByteArray bt;
    uint8_t commandType = 6;

    bt.append(boatID());
    bt.append(controlType());
    bt.append(commandType);
    bt.append(DNValue(steps).bytesData());

    // message type use raw
    emit sendMsgbyID(boatID(), 5, bt);

}

void WinchControl::stop()
{
    QByteArray bt;
    uint8_t commandType = 7;

    bt.append(boatID());
    bt.append(controlType());
    bt.append(commandType);

    // message type use raw
    emit sendMsgbyID(boatID(), 5, bt);

}

void WinchControl::init(ControlItem* controlItem)
{
    *qobject_cast<ControlItem*> (this) = *controlItem;

}

void WinchControl::setMaxSpeed(int s)
{
    _maxSpeed = s;
    setField(0,QString::number(s));
    emit maxSpeedChanged(s);
}

void WinchControl::setAcceleration(int a)
{
    _acceleration = a;
    setField(1,QString::number(a));
    emit accelerationChanged(a);
}

void WinchControl::setSteps(int s)
{
    _steps = s;
    //setField(2,QString::number(s));
    //run(s);
    emit stepsChanged(s);
}

void WinchControl::setStatus(uint8_t s)
{
    _status = s;
    emit statusChanged(s);
}

void WinchControl::processMsg(QByteArray command)
{
    qDebug()<<"WinchControl::processMsg"<<command.size();
    uint8_t action;
    int32_t step;
    int32_t tension;
    uint8_t status;
    memcpy(&action, command.data(), sizeof(uint8_t));
    memcpy(&step, command.data()+1, sizeof(int32_t));
    memcpy(&tension, command.data()+5, sizeof(int32_t));
    memcpy(&status, command.data()+9, sizeof(uint8_t));
    setSteps(step);
    setStatus(status);
    qDebug()<<"step:"<<step<<"tension"<<tension<<"status"<<status;
}
