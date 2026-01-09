#ifndef CONTROLITEM_H
#define CONTROLITEM_H

#include <QObject>
#include <QHostAddress>

#include "dnvalue.h"

class ControlItem : public QObject
{
    Q_OBJECT
public:
    Q_PROPERTY(QString name READ name CONSTANT)
    Q_PROPERTY(uint8_t boatID READ boatID CONSTANT)
    explicit ControlItem(QObject *parent, QString name, int controlType, QVector<DNValue> fields);
    ControlItem(const ControlItem& other, QObject *parent = nullptr);
    const ControlItem& operator = (const ControlItem& other);
    Q_INVOKABLE virtual void run();
    Q_INVOKABLE virtual void setField(int index, QString value);
    Q_INVOKABLE virtual DNValue* getField(int index);
    Q_INVOKABLE void setBoatID(uint8_t boatID) { _boatID = boatID;}
    //virtual void setFields(QVector<int>  fieldsMap, QVector<DNValue> fields);
    void sendCMD();
    QString name() { return _name; }
    int controlType() { return _controlType;}
    uint8_t boatID() {  return _boatID;}

    void setControlType(int type) {_controlType = type;}
    virtual void processMsg(QByteArray command){}


signals:
    void sendMsgbyID(uint8_t boatID, uint8_t topic, QByteArray command);
private:
    QString _name;

    QVector<DNValue*> _fields;
    uint8_t _boatID;
    int _controlType;

};

#endif // CONTROLITEM_H
