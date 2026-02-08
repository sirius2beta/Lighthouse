#include <QRunnable>
#include <QQuickStyle>
#include <QtGui/QFontDatabase>
#include <QtCore/QCoreApplication>
#include <QtCore/QSettings>
#include <QDir>

#include "dnapplication.h"
#include "dnapi/dnvideomanager.h"
#include "dnapi/boatmanager.h"
#include "dnapi/videoitem.h"
#include "dnapi/sensormanager.h"
#include "dnapi/controlmanager.h"
#include "dnapi/controlitem.h"
#include "dnapi/dnvalue.h"








class FinishVideoInitialization : public QRunnable
{
public:
  FinishVideoInitialization(DNVideoManager* manager)
      : _dnvideomanager(manager)
  {
  }

  void run () {
     _dnvideomanager->initVideo();
  }

private:
  DNVideoManager* _dnvideomanager;
};

//register a singleton type provider
static QObject* DNQmlGlobalSingletonFactory(QQmlEngine*, QJSEngine*)
{
    DNQmlGlobal* qmlGlobal = new DNQmlGlobal(dnApp(), dnApp()->core());
    return qmlGlobal;
}

DNApplication* DNApplication::_app = nullptr;

DNApplication::DNApplication(int &argc, char *argv[])
    :QApplication (argc, argv)
{
    QQuickWindow::setGraphicsApi(QSGRendererInterface::OpenGL);
    setApplicationName("LightHouse");
    setOrganizationName("Denovo");
    setOrganizationDomain("Denovo.org");
    setApplicationVersion("1.0");
    QSettings::setDefaultFormat(QSettings::IniFormat);

}

DNApplication::~DNApplication()
{
}

void DNApplication::_shutdown()
{
    delete _qmlEngine;
}

void DNApplication::_init(int &argc, char *argv[])
{



    _app = this;
    _qmlEngine = new QQmlApplicationEngine(this);

    _core = new DNCore(this, QString("config1"));
    // Register our Qml objects
    qmlRegisterUncreatableType<BoatItem>("DeNovoViewer.Boat", 1, 0, "BoatItem",  "reference only");
    qmlRegisterUncreatableType<BoatManager>("DeNovoViewer.Boat", 1, 0, "BoatManager",  "reference only");
    qmlRegisterUncreatableType<DNVideoManager>("DeNovoViewer.Boat", 1, 0, "DNVideoManager",  "reference only");
    qmlRegisterUncreatableType<VideoItem>("DeNovoViewer.Boat", 1, 0, "VideoItem",  "reference only");
    qmlRegisterUncreatableType<SensorManager>("DeNovoViewer.Boat", 1, 0, "SensorManager",  "reference only");
    qmlRegisterUncreatableType<ControlManager>("DeNovoViewer.Boat", 1, 0, "ControlManager", "reference only");
    qmlRegisterUncreatableType<ControlItem>("DeNovoViewer.Boat", 1, 0, "ControlItem", "reference only");
    qmlRegisterType<DNValue>("DeNovoViewer.Boat", 1, 0, "DNValue");

    // Register Qml Singletons
    qmlRegisterSingletonType<DNQmlGlobal>("DeNovoViewer", 1, 0, "DeNovoViewer", DNQmlGlobalSingletonFactory);
    qDebug()<<"global init()";

    QFontDatabase::addApplicationFont(":/fonts/Roboto-Regular.ttf");
    QFontDatabase::addApplicationFont(":/fonts/Roboto-Bold.ttf");
    QFontDatabase::addApplicationFont(":/fonts/Roboto-Black.ttf");

    _core->videoManager()->initGstreamer();

    _qmlEngine->addImportPath("qrc:/imports");
    _qmlEngine->addImportPath("qrc:/qml");
    _qmlEngine->load("qrc:/main.qml");

    QQuickWindow* rootWindow = dnApp()->mainRootWindow();
    if (rootWindow) {
        rootWindow->scheduleRenderJob (new FinishVideoInitialization (_core->videoManager()),
                                      QQuickWindow::BeforeSynchronizingStage);
    }



    emit initiated();


}


QObject* DNApplication::_rootQmlObject()
{
    if(_qmlEngine && _qmlEngine->rootObjects().size())
        return _qmlEngine->rootObjects()[0];
    return nullptr;
}

QQuickWindow* DNApplication::mainRootWindow()
{
    if(!_mainRootWindow) {
        _mainRootWindow = reinterpret_cast<QQuickWindow*>(_rootQmlObject());
    }
    return _mainRootWindow;
}

DNApplication* dnApp(void)
{
    return DNApplication::_app;
}
