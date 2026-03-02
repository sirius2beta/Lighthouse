#include "dnqmlglobal.h"
#include "dncore.h"
#include "QDebug"

DNQmlGlobal::DNQmlGlobal(QObject *parent, DNCore* core)
    : QObject{parent},
      _core(core),
      _programName(QString("DeNovo Viewer"))
{

    _networkManager = core->networkManager();
    _boatManager = core->boatManager();
    _videoManager = core->videoManager();
    _sensorManager = core->sensorManager();
    _controlManager = core->controlManager();
    _aquaGraph = core->aquaGraph();

}
