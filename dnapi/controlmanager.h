#ifndef CONTROLMANAGER_H
#define CONTROLMANAGER_H
#include <QObject>
#include <QHostAddress>

#include "dnqmlobjectlistmodel.h"
#include "controlitem.h"
#include "winchcontrol.h"

class DNCore;
class ControlManager : public QObject
{
    Q_OBJECT
public:
    Q_PROPERTY(DNQmlObjectListModel* controls READ controls CONSTANT)


    explicit ControlManager(QObject *parent = nullptr, DNCore *core = nullptr);

    void init();
    void sendControlMsg(QByteArray msg); //call by control
    void setBoatID(int boatID);
    DNQmlObjectListModel* controls() { return &_controls;}

    Q_INVOKABLE ControlItem* getDevice(int index);
    void onControlMsg(int boatID, QByteArray command);
signals:
    void sendMsg(int boatID, char topic, QByteArray command);


private:
    DNCore* _core;
    int _boatID;
    DNQmlObjectListModel _controls;
};

#endif // CONTROLMANAGER_H
