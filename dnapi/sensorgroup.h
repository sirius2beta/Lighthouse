#ifndef SENSORGROUP_H
#define SENSORGROUP_H

#include <QObject>
#include <QList>

#include "sensoritem.h"
#include "dnqmlobjectlistmodel.h"

class SensorGroup : public QObject
{
    Q_OBJECT
public:
    explicit SensorGroup(QObject *parent = nullptr, QString name=QString());
    ~SensorGroup();
    SensorGroup(const SensorGroup& other, QObject *parent = nullptr);
    const SensorGroup& operator = (const SensorGroup& other);
    int count(){return _sensorList.count();}
    void append(SensorItem* si);
    SensorItem*    operator[]          (int i){ return _sensorList[i]; };
signals:

private:
    QString _name;
    int _boatID;
    QList<SensorItem*> _sensorList;


};

#endif // SENSORGROUP_H
