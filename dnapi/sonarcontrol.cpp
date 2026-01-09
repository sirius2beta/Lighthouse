#include "sonarcontrol.h"



SonarControl::SonarControl(QObject *parent, QString name, int controlType, QVector<DNValue> fields)
    : ControlItem(parent, name, 2, fields),_powerOn(false)
{

    qDebug()<<"create sonar control: contorl type"<<this->controlType();
}

void SonarControl::setPower(bool p)
{
    QByteArray bt;
    uint8_t commandType = 6;

    bt.append(controlType());
    bt.append(commandType);
    bt.append(DNValue(p).bytesData());

    // message type use raw
    emit sendMsgbyID(boatID(), 5, bt);
}

void SonarControl::processMsg(QByteArray command)
{
    qDebug()<<"SonarControl::processMsg"<<command.size();
    uint8_t action;
    int32_t step;
    int32_t tension;
    uint8_t status;
    memcpy(&action, command.data(), sizeof(uint8_t));
    memcpy(&step, command.data()+1, sizeof(int32_t));
    memcpy(&tension, command.data()+5, sizeof(int32_t));
    memcpy(&status, command.data()+9, sizeof(uint8_t));

    qDebug()<<"step:"<<step<<"tension"<<tension<<"status"<<status;
}

bool SonarControl::power()
{
    qDebug()<<"get power";
    return _powerOn;
}
