#include "dnvalue.h"
#include <QQmlEngine>
DNValue::DNValue(QObject *parent)
    : QObject{parent},
    _rawValue(0),
    _type(DNMetaData::valueTypeUint32)
{
QQmlEngine::setObjectOwnership(this, QQmlEngine::CppOwnership);
}

DNValue::DNValue(uint8_t i)
    : _rawValue(i),
    _type(DNMetaData::valueTypeUint8)
{
QQmlEngine::setObjectOwnership(this, QQmlEngine::CppOwnership);
}

DNValue::DNValue(int8_t i)
    : _rawValue(i),
    _type(DNMetaData::valueTypeInt8)
{
QQmlEngine::setObjectOwnership(this, QQmlEngine::CppOwnership);
}

DNValue::DNValue(uint16_t i)
    : _rawValue(i),
    _type(DNMetaData::valueTypeUint16)
{
QQmlEngine::setObjectOwnership(this, QQmlEngine::CppOwnership);
}

DNValue::DNValue(int16_t i)
    : _rawValue(i),
    _type(DNMetaData::valueTypeInt16)
{
QQmlEngine::setObjectOwnership(this, QQmlEngine::CppOwnership);
}

DNValue::DNValue(uint32_t i)
    : _rawValue(i),
    _type(DNMetaData::valueTypeUint32)
{
QQmlEngine::setObjectOwnership(this, QQmlEngine::CppOwnership);
}

DNValue::DNValue(int32_t i)
    : _rawValue(i),
    _type(DNMetaData::valueTypeInt32)
{
QQmlEngine::setObjectOwnership(this, QQmlEngine::CppOwnership);
}

DNValue::DNValue(uint64_t i)
    : _rawValue(i),
    _type(DNMetaData::valueTypeUint64)
{
QQmlEngine::setObjectOwnership(this, QQmlEngine::CppOwnership);
}

DNValue::DNValue(int64_t i)
    : _rawValue(i),
    _type(DNMetaData::valueTypeInt64)
{
QQmlEngine::setObjectOwnership(this, QQmlEngine::CppOwnership);
}
DNValue::DNValue(double f)
    : _rawValue(f),
    _type(DNMetaData::valueTypeDouble)
{
QQmlEngine::setObjectOwnership(this, QQmlEngine::CppOwnership);
}

DNValue::DNValue(float f)
    : _rawValue(f),
    _type(DNMetaData::valueTypeFloat)
{
QQmlEngine::setObjectOwnership(this, QQmlEngine::CppOwnership);
}

DNValue::DNValue(QVariant _rawValue, DNMetaData::ValueType_t type, QObject *parent)
    : QObject{parent},
    _rawValue(0),
    _type(type)
{
    QQmlEngine::setObjectOwnership(this, QQmlEngine::CppOwnership);
    if(type == DNMetaData::valueTypeFloat){
        //_rawValue = QVariant(float(0));

    }
}

DNValue::DNValue(const DNValue& other, QObject *parent)
{
    *this = other;
}

DNValue::DNValue(const DNValue* other, QObject *parent)
{
    *this = *other;
}

const DNValue& DNValue::operator =(const DNValue& other)
{
    _rawValue = other._rawValue;
    _type = other._type;
    _name = other._name;
    return *this;
}

QByteArray DNValue::bytesData()
{
    if(_type == DNMetaData::valueTypeUint8){
        char str1[sizeof(uint8_t)];
        uint8_t str2 = _rawValue.toUInt();
        memcpy(str1, &str2, sizeof(uint8_t));
        return QByteArray(str1,sizeof(uint));
    }else if(_type == DNMetaData::valueTypeInt8){
        char str1[sizeof(int8_t)];
        int8_t str2 = _rawValue.toInt();
        memcpy(str1, &str2, sizeof(int8_t));
        return QByteArray(str1,sizeof(uint));
    }else if(_type == DNMetaData::valueTypeUint16){
        char str1[sizeof(uint16_t)];
        uint16_t str2 = _rawValue.toUInt();
        memcpy(str1, &str2, sizeof(uint16_t));
        return QByteArray(str1,sizeof(uint));
    }else if(_type == DNMetaData::valueTypeInt16){
        char str1[sizeof(int16_t)];
        int16_t str2 = _rawValue.toInt();
        memcpy(str1, &str2, sizeof(int16_t));
        return QByteArray(str1,sizeof(uint));
    }else if(_type == DNMetaData::valueTypeUint32){
        char str1[sizeof(uint)];
        uint str2 = _rawValue.toUInt();
        memcpy(str1, &str2, sizeof(uint));
        return QByteArray(str1,sizeof(uint));
    }else if(_type == DNMetaData::valueTypeInt32){
        char str1[sizeof(int)];
        int str2 = _rawValue.toInt();
        memcpy(str1, &str2, sizeof(int));
        return QByteArray(str1,sizeof(int));
    }else if(_type == DNMetaData::valueTypeFloat){
        char str1[sizeof(float)];
        float str2 = _rawValue.toFloat();
        memcpy(str1, &str2, sizeof(float));
        return QByteArray(str1,sizeof(float));
    }else if(_type == DNMetaData::valueTypeDouble){
        char str1[sizeof(double)];
        double str2 = _rawValue.toDouble();
        memcpy(str1, &str2, sizeof(double));
        return QByteArray(str1,sizeof(uint));
    }else if(_type == DNMetaData::valueTypeBool){
        char str1[sizeof(float)];
        bool str2 = _rawValue.toBool();
        memcpy(str1, &str2, sizeof(bool));
        return QByteArray(str1,sizeof(bool));
    }
    return QByteArray();
}

DNValue::~DNValue()
{

}

QVariant DNValue::parseString(QString s, DNMetaData::ValueType_t type)
{
    if(type == DNMetaData::valueTypeUint32){


        return QVariant(s.toInt());
    }else if(type == DNMetaData::valueTypeFloat){
        return QVariant(s.toFloat());

    }else if(type == DNMetaData::valueTypeBool){
        if(s.toLower() == "true"){
           return QVariant(true);
        }else{
           return QVariant(false);
        }
    }else{

        return QVariant(s.toInt());
    }

    return QVariant();
}
