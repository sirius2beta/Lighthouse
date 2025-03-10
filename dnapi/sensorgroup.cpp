#include "sensorgroup.h"

SensorGroup::SensorGroup(QObject *parent, QString name)
    : QObject{parent}
{

}

SensorGroup::~SensorGroup()
{

}

SensorGroup::SensorGroup(const SensorGroup& other, QObject *parent)
{
    *this = other;
}

const SensorGroup& SensorGroup::operator =(const SensorGroup& other)
{
    _name = other._name;
    _sensorList = other._sensorList;
    _boatID = other._boatID;
    return *this;
}

void SensorGroup::append(SensorItem* si){
    _sensorList.append(si);
}
