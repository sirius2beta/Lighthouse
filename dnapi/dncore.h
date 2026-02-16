#ifndef DNCORE_H
#define DNCORE_H

#include <QObject>
#include "boatmanager.h"
#include "networkmanager.h"
#include "heartbeat.h"
#include "dnvideomanager.h"
#include "sensormanager.h"
#include "configmanager.h"
#include "dnqmlglobal.h"
#include "controlmanager.h"
#include "aquagraph.h"

class DNCore : public QObject
{
    Q_OBJECT
public:
    explicit DNCore(QObject *parent = nullptr, QString config = 0);
    ~DNCore();

    void init();

    BoatManager* boatManager() { return _boatManager; }
    NetworkManager* networkManager() { return _networkManager; }
    DNVideoManager* videoManager() { return _videoManager; }
    SensorManager* sensorManager() { return _sensorManager; }
    ConfigManager* configManager() { return _configManager; }
    ControlManager* controlManager() { return _controlManager; }
    AquaGraph* aquaGraph(){ return _aquaGraph; }
    QString config() {return _config;}


private:
    QSettings* settings;
    QString _config;
    BoatManager* _boatManager;
    NetworkManager* _networkManager;
    DNVideoManager* _videoManager;
    SensorManager* _sensorManager;
    ConfigManager* _configManager;
    ControlManager* _controlManager;
    AquaGraph* _aquaGraph;

};

#endif // DNCORE_H
