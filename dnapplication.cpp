#include <QRunnable>
#include <gst/gst.h>
#include <QQuickStyle>
#include <QtGui/QFontDatabase>

#include "dnapplication.h"
#include "dnapi/dnvideomanager.h"
#include "dnapi/boatmanager.h"
#include "dnapi/videoitem.h"
#include "dnapi/sensormanager.h"
#include "dnapi/controlmanager.h"
#include "dnapi/controlitem.h"
#include "dnapi/dnvalue.h"
G_BEGIN_DECLS
    GST_PLUGIN_STATIC_DECLARE(qml6);
    GST_PLUGIN_STATIC_DECLARE(androidmedia);
    GST_PLUGIN_STATIC_DECLARE(applemedia);
    GST_PLUGIN_STATIC_DECLARE(coreelements);
    GST_PLUGIN_STATIC_DECLARE(d3d);
    GST_PLUGIN_STATIC_DECLARE(d3d11);
    GST_PLUGIN_STATIC_DECLARE(d3d12);
    GST_PLUGIN_STATIC_DECLARE(dav1d);
    GST_PLUGIN_STATIC_DECLARE(dxva);
    GST_PLUGIN_STATIC_DECLARE(isomp4);
    GST_PLUGIN_STATIC_DECLARE(libav);
    GST_PLUGIN_STATIC_DECLARE(matroska);
    GST_PLUGIN_STATIC_DECLARE(mpegtsdemux);
    GST_PLUGIN_STATIC_DECLARE(msdk);
    GST_PLUGIN_STATIC_DECLARE(nvcodec);
    GST_PLUGIN_STATIC_DECLARE(opengl);
    GST_PLUGIN_STATIC_DECLARE(openh264);
    GST_PLUGIN_STATIC_DECLARE(playback);
    GST_PLUGIN_STATIC_DECLARE(qml6);
    GST_PLUGIN_STATIC_DECLARE(qsv);
    GST_PLUGIN_STATIC_DECLARE(rtp);
    GST_PLUGIN_STATIC_DECLARE(rtpmanager);
    GST_PLUGIN_STATIC_DECLARE(rtsp);
    GST_PLUGIN_STATIC_DECLARE(sdpelem);
    GST_PLUGIN_STATIC_DECLARE(tcp);
    GST_PLUGIN_STATIC_DECLARE(typefindfunctions);
    GST_PLUGIN_STATIC_DECLARE(udp);
    GST_PLUGIN_STATIC_DECLARE(va);
    GST_PLUGIN_STATIC_DECLARE(videoparsersbad);
    GST_PLUGIN_STATIC_DECLARE(vpx);
    GST_PLUGIN_STATIC_DECLARE(vulkan);

G_END_DECLS

static void _putenv(const QString &key, const QString &root, const QString &path = "")
{
    const QByteArray keyArray = key.toLocal8Bit();
    const QByteArray valueArray = (root + path).toLocal8Bit();
    (void) qputenv(keyArray, valueArray);
}

static void _setGstEnvVars()
{
const QString currentDir = QCoreApplication::applicationDirPath();


#if defined(Q_OS_MACOS) && defined(QGC_GST_MACOS_FRAMEWORK)
        _putenv("GST_REGISTRY_REUSE_PLUGIN_SCANNER", "no");
        _putenv("GST_PLUGIN_SCANNER", currentDir, "/../Frameworks/GStreamer.framework/Versions/1.0/libexec/gstreamer-1.0/gst-plugin-scanner");
        _putenv("GST_PTP_HELPER_1_0", currentDir, "/../Frameworks/GStreamer.framework/Versions/1.0/libexec/gstreamer-1.0/gst-ptp-helper");
        _putenv("GIO_EXTRA_MODULES", currentDir, "/../Frameworks/GStreamer.framework/Versions/1.0/lib/gio/modules");
        _putenv("GST_PLUGIN_SYSTEM_PATH_1_0", currentDir, "/../Frameworks/GStreamer.framework/Versions/1.0/lib/gstreamer-1.0"); // PlugIns/gstreamer
        _putenv("GST_PLUGIN_SYSTEM_PATH", currentDir, "/../Frameworks/GStreamer.framework/Versions/1.0/lib/gstreamer-1.0");
        _putenv("GST_PLUGIN_PATH_1_0", currentDir, "/../Frameworks/GStreamer.framework/Versions/1.0/lib/gstreamer-1.0");
        _putenv("GST_PLUGIN_PATH", currentDir, "/../Frameworks/GStreamer.framework/Versions/1.0/lib/gstreamer-1.0");
        _putenv("GTK_PATH", currentDir, "/../Frameworks/GStreamer.framework/Versions/1.0");
#elif defined(Q_OS_WIN)
        _putenv("GST_REGISTRY_REUSE_PLUGIN_SCANNER", "no");
        _putenv("GST_PLUGIN_SCANNER", currentDir, "/../libexec/gstreamer-1.0/gst-plugin-scanner");
        _putenv("GST_PTP_HELPER_1_0", currentDir, "/../libexec/gstreamer-1.0/gst-ptp-helper");
        _putenv("GIO_EXTRA_MODULES", currentDir, "/../lib/gio/modules");
        _putenv("GST_PLUGIN_SYSTEM_PATH_1_0", currentDir, "/../lib/gstreamer-1.0");
        _putenv("GST_PLUGIN_SYSTEM_PATH", currentDir, "/../lib/gstreamer-1.0");
        _putenv("GST_PLUGIN_PATH_1_0", currentDir, "/../lib/gstreamer-1.0");
        _putenv("GST_PLUGIN_PATH", currentDir, "/../lib/gstreamer-1.0");
#endif
    }



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
    _setGstEnvVars();
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
    gst_init (&argc, &argv);
    #ifdef QGC_GST_STATIC_BUILD
        #ifdef GST_PLUGIN_androidmedia_FOUND
            GST_PLUGIN_STATIC_REGISTER(androidmedia);
        #endif
        #ifdef GST_PLUGIN_applemedia_FOUND
            GST_PLUGIN_STATIC_REGISTER(applemedia);
        #endif
            GST_PLUGIN_STATIC_REGISTER(coreelements);
        #ifdef GST_PLUGIN_d3d_FOUND
            GST_PLUGIN_STATIC_REGISTER(d3d);
        #endif
        #ifdef GST_PLUGIN_d3d11_FOUND
            GST_PLUGIN_STATIC_REGISTER(d3d11);
        #endif
        #ifdef GST_PLUGIN_d3d12_FOUND
            GST_PLUGIN_STATIC_REGISTER(d3d12);
        #endif
        #ifdef GST_PLUGIN_dav1d_FOUND
            GST_PLUGIN_STATIC_REGISTER(dav1d);
        #endif
        #ifdef GST_PLUGIN_dxva_FOUND
            GST_PLUGIN_STATIC_REGISTER(dxva);
        #endif
            GST_PLUGIN_STATIC_REGISTER(isomp4);
            GST_PLUGIN_STATIC_REGISTER(libav);
            GST_PLUGIN_STATIC_REGISTER(matroska);
            GST_PLUGIN_STATIC_REGISTER(mpegtsdemux);
        #ifdef GST_PLUGIN_msdk_FOUND
            GST_PLUGIN_STATIC_REGISTER(msdk);
        #endif
        #ifdef GST_PLUGIN_nvcodec_FOUND
            GST_PLUGIN_STATIC_REGISTER(nvcodec);
        #endif
            GST_PLUGIN_STATIC_REGISTER(opengl);
            GST_PLUGIN_STATIC_REGISTER(openh264);
            GST_PLUGIN_STATIC_REGISTER(playback);
        #ifdef GST_PLUGIN_qsv_FOUND
            GST_PLUGIN_STATIC_REGISTER(qsv);
        #endif
            GST_PLUGIN_STATIC_REGISTER(rtp);
            GST_PLUGIN_STATIC_REGISTER(rtpmanager);
            GST_PLUGIN_STATIC_REGISTER(rtsp);
            GST_PLUGIN_STATIC_REGISTER(sdpelem);
            GST_PLUGIN_STATIC_REGISTER(tcp);
            GST_PLUGIN_STATIC_REGISTER(typefindfunctions);
            GST_PLUGIN_STATIC_REGISTER(udp);
        #ifdef GST_PLUGIN_va_FOUND
            GST_PLUGIN_STATIC_REGISTER(va);
        #endif
            GST_PLUGIN_STATIC_REGISTER(videoparsersbad);
            GST_PLUGIN_STATIC_REGISTER(vpx);
        #ifdef GST_PLUGIN_vulkan_FOUND
            GST_PLUGIN_STATIC_REGISTER(vulkan);
        #endif
    #endif
    GST_PLUGIN_STATIC_REGISTER(qml6);

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
