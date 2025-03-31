#ifndef DNVALUE_H
#define DNVALUE_H

#include <QObject>
#include <QVariant>
#include <QDebug>
#include "dnmetadata.h"

class DNValue : public QObject
{
    Q_OBJECT
public:
    Q_PROPERTY(QString name READ name CONSTANT)
    DNValue(QObject *parent = nullptr);
    DNValue(uint8_t i);
    DNValue(int8_t i);
    DNValue(uint16_t i);
    DNValue(int16_t i);
    DNValue(uint32_t i);
    DNValue(int32_t i);
    DNValue(uint64_t i);
    DNValue(int64_t i);
    DNValue(double f);
    DNValue(float f);

    DNValue(QVariant _rawValue, DNMetaData::ValueType_t type, QObject *parent = nullptr);
    DNValue(const DNValue& other, QObject *parent = nullptr);
    DNValue(const DNValue* other, QObject *parent = nullptr);

    Q_INVOKABLE bool toBool() { return _rawValue.toBool(); }
    Q_INVOKABLE int toInt() { return _rawValue.toInt(); }
    Q_INVOKABLE float toFloat() { return _rawValue.toFloat(); }
    const DNValue& operator = (const DNValue& other);
    QVariant data() { return _rawValue; }
    QByteArray bytesData();
    DNMetaData::ValueType_t dataType() { return _type; }
    QString name(){ return _name; }
    ~DNValue();
    static QVariant parseString(QString s, DNMetaData::ValueType_t type);
    void setValue(QVariant value) { _rawValue = value; }
    void setValue(QString s) {  _rawValue = parseString(s, _type);}
    void setName(QString s) { _name=s; }

private:

    QVariant _rawValue;
    DNMetaData::ValueType_t _type;
    QString _name;
};

#endif // DNVALUE_H
