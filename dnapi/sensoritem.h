#ifndef SENSORITEM_H
#define SENSORITEM_H

#include <QObject>
#include "dnvalue.h"

class SensorItem : public QObject
{
    Q_OBJECT
public:
    Q_PROPERTY(QString name READ name CONSTANT)
    Q_PROPERTY(QString displayValue READ displayValue  NOTIFY displayValueChanged)

    explicit SensorItem(QObject *parent = nullptr, QString name = QString(), int sensorType=-1, DNValue value=DNValue());
    SensorItem(const SensorItem& other, QObject *parent = nullptr);
    const SensorItem& operator = (const SensorItem& other);
    int boatID() { return _boatID; }
    Q_INVOKABLE DNValue value() { return _value; }
    QString name() { return _name; }
    QString displayValue();
    QVariant maxAlarmValue() { return _maxAlarmValue; }
    bool isEnableMaxAlarm() { return _enableMaxAlarm; }

    void setBoatID(int ID);
    void setValue(DNValue value);
    void setMaxAlarmValue(QVariant value){ _maxAlarmValue = value; };
    void enableMaxAlarm(bool enable) { _enableMaxAlarm = enable; };

signals:
    void BoatIDSet(int ID);
    void textSet(QString text);
    void nameSet(QString name);
    void displayValueChanged(QString value);
private:
    QString _name;
    int _sensorType;
    DNValue _value;
    QVariant _maxAlarmValue;
    bool _enableMaxAlarm;
    int _boatID;

};

#endif // SENSORITEM_H
