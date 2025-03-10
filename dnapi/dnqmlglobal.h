#ifndef DNQMLGLOBAL_H
#define DNQMLGLOBAL_H

#include <QObject>

#include "boatmanager.h"
#include "networkmanager.h"
#include "dnvideomanager.h"
#include "sensormanager.h"
#include "controlmanager.h"
class DNCore;

class DNQmlGlobal : public QObject
{
    Q_OBJECT



public:
    explicit DNQmlGlobal(QObject *parent = nullptr, DNCore* core = nullptr);

    Q_INVOKABLE QString programName() const {return _programName;}

    Q_PROPERTY(QString programName READ programName CONSTANT);
    Q_PROPERTY(NetworkManager* networkManager READ networkManager CONSTANT);
    Q_PROPERTY(BoatManager* boatManager READ boatManager CONSTANT);
    Q_PROPERTY(DNVideoManager* videoManager READ videoManager CONSTANT);
    Q_PROPERTY(SensorManager* sensorManager READ sensorManager CONSTANT);
    Q_PROPERTY(ControlManager* controlManager READ controlManager CONSTANT);
    Q_PROPERTY(int boatListmodel READ boatListmodel CONSTANT)

    NetworkManager* networkManager() { return _networkManager; }
    BoatManager* boatManager() { return _boatManager; }
    DNVideoManager* videoManager() { return _videoManager; }
    SensorManager* sensorManager() {return _sensorManager;}
    ControlManager* controlManager() { return _controlManager;}
    int boatListmodel() const {return 0;}
signals:
private:
    DNCore* _core;
    NetworkManager* _networkManager = nullptr;
    BoatManager* _boatManager = nullptr;
    DNVideoManager* _videoManager = nullptr;
    SensorManager* _sensorManager = nullptr;
    ControlManager* _controlManager = nullptr;
    QString _programName ;
};

#endif // DNQMLGLOBAL_H
