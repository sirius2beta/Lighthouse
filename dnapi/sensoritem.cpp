#include "sensoritem.h"

SensorItem::SensorItem(QObject *parent, QString name, int sensorType, DNValue value)
    : QObject{parent},
    _name(name),
    _sensorType(sensorType),
    _value(value),
    _maxAlarmValue(QVariant()),
    _enableMaxAlarm(false),
    _boatID(-1)
{

}

SensorItem::SensorItem(const SensorItem& other, QObject *parent)
{
    *this = other;
}

QString SensorItem::displayValue()
{
    if(_value.dataType() == DNMetaData::valueTypeUint32){
        return QString::number(_value.data().toInt());
    }else if(_value.dataType() == DNMetaData::valueTypeInt32){
        return QString::number(_value.data().toInt());
    }else if(_value.dataType() == DNMetaData::valueTypeFloat){
        return QString::number(_value.data().toFloat());
    }else if(_value.dataType() == DNMetaData::valueTypeBool){
        return _value.data().toBool()?"On":"Off";
    }else{
        return QString::number(_value.data().toInt());
    }
}

const SensorItem& SensorItem::operator =(const SensorItem& other)
{
    _name = other._name;
    _sensorType = other._sensorType;
    _value = other._value;
    _maxAlarmValue = other._maxAlarmValue;
    _enableMaxAlarm = other._enableMaxAlarm;
    _boatID = other._boatID;
    return *this;
}

void SensorItem::setBoatID(int ID)
{
    _boatID = ID;
    emit BoatIDSet(ID);
}



void SensorItem::setValue(DNValue value)
{
    _value = value;
    if(value.dataType() == DNMetaData::valueTypeUint32){
        emit displayValueChanged(QString::number(value.data().toUInt()));
    }else if(value.dataType() == DNMetaData::valueTypeFloat){
        emit displayValueChanged(QString::number(value.data().toFloat()));
    }else if(value.dataType() == DNMetaData::valueTypeBool){
        emit displayValueChanged(value.data().toBool()?"On":"Off");
    }else{
        emit displayValueChanged(QString::number(value.data().toInt()));
    }
}
