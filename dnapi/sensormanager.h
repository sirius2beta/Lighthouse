#ifndef SENSORMANAGER_H
#define SENSORMANAGER_H

#include <QObject>
#include <QSettings>
#include <QStandardItemModel>
#include "sensoritem.h"
#include "sensorgroup.h"
#include "dnvalue.h"
#include "dnqmlobjectlistmodel.h"


class DNCore;

class SensorManager : public QObject
{
    Q_OBJECT
public:

    Q_PROPERTY(DNQmlObjectListModel* aquaModel READ aquaModel CONSTANT)
    Q_PROPERTY(DNQmlObjectListModel* cabinModel READ cabinModel CONSTANT)
    Q_PROPERTY(DNQmlObjectListModel* battery0Model READ battery0Model CONSTANT)
    Q_PROPERTY(DNQmlObjectListModel* mav0Model READ mav0Model CONSTANT)
    Q_PROPERTY(DNQmlObjectListModel* mav1Model READ mav1Model CONSTANT)
    Q_PROPERTY(DNQmlObjectListModel* detection READ detection CONSTANT)
    explicit SensorManager(QObject *parent = nullptr, DNCore *core = nullptr);
    void init();
    int count() { return _sensorGroupListModel.size(); }
    DNQmlObjectListModel* cabinModel(void){return _sensorGroupListModel[0]; }
    DNQmlObjectListModel* aquaModel(void){return _sensorGroupListModel[1]; }
    DNQmlObjectListModel* battery0Model(void){return _sensorGroupListModel[2]; }
    DNQmlObjectListModel* mav0Model(void){return _sensorGroupListModel[3]; }
    DNQmlObjectListModel* mav1Model(void){return _sensorGroupListModel[4];}
    DNQmlObjectListModel* detection(void){return _sensorGroupListModel[5];}

    Q_INVOKABLE DNQmlObjectListModel* getSensorModel(int index);

    enum dataType{ int_type = 0, float_type = 1};


signals:
    void sensorDataChanged(int ID, DNValue& value);

public slots:
    void onSensorMsg(int ID, QByteArray data); //處理來自networkmanager的訊息

private:
    QSettings* settings;
    DNCore* _core;

    QList<DNQmlObjectListModel*> _sensorGroupListModel;
};

#endif // SENSORMANAGER_H
