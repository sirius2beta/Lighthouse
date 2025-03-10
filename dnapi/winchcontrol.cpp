#include "winchcontrol.h"
#include <QDataStream>

WinchControl::WinchControl(QObject *parent, QString name, int controlType, QVector<DNValue> fields)
: ControlItem(parent, name, 0, fields),
  _maxSpeed(2000),
  _acceleration(1000),
  _steps(0)
{

}

void WinchControl::run(QString steps)
{
    QByteArray bt;
    uint8_t commandType = 1;
    uint8_t m_controlType = controlType();
    int32_t m_steps = steps.toInt();
    bt.append(boatID());
    bt.append(m_controlType);
    bt.append(commandType);
    bt.append((const char*)&m_steps, sizeof(int32_t));

    // message type use raw
    emit sendMsgbyID(boatID(), 5, bt);

}

void WinchControl::stop()
{
    QByteArray bt;
    uint8_t commandType = 2;
    uint8_t m_controlType = controlType();
    bt.append(boatID());
    bt.append(m_controlType);
    bt.append(commandType);

    // message type use raw
    emit sendMsgbyID(boatID(), 5, bt);
    //qDebug()<<"ControlItem::stop winch";
    //qDebug()<<bt;

}

void WinchControl::init(ControlItem* controlItem)
{
    *qobject_cast<ControlItem*> (this) = *controlItem;

}

void WinchControl::setMaxSpeed(int s)
{
    _maxSpeed = s;
    emit maxSpeedChanged(s);
}

void WinchControl::setAcceleration(int a)
{
    _acceleration = a;
    emit accelerationChanged(a);
}

void WinchControl::setSteps(int s)
{
    _steps = s;
    emit stepsChanged(s);
}
