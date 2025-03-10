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
    Q_PROPERTY(int boatID READ boatID CONSTANT)
    explicit ControlItem(QObject *parent, QString name, int controlType, QVector<DNValue> fields);
    ControlItem(const ControlItem& other, QObject *parent = nullptr);
    const ControlItem& operator = (const ControlItem& other);
    Q_INVOKABLE virtual void run();
    Q_INVOKABLE virtual void setField(int index, QString value);
    Q_INVOKABLE virtual DNValue* getField(int index);
    //virtual void setFields(QVector<int>  fieldsMap, QVector<DNValue> fields);
    void sendCMD();
    QString name() { return _name; }
    int controlType() { return _controlType;}
    int boatID() {  return _boatID;}
    void setBoatID(int boatID) { _boatID = boatID;}


signals:
    void sendMsgbyID(int boatID, uint8_t topic, QByteArray command);

private:
    QString _name;
    int _controlType;
    QVector<DNValue*> _fields;
    int _boatID;

};

#endif // CONTROLITEM_H
