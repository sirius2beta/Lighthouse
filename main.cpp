#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlEngine>
#include <gst/gst.h>
#include <QDebug>
#include <QSplashScreen>

#include "dnapplication.h"

int main(int argc, char *argv[])
{

    DNApplication* app = new DNApplication(argc, argv);
    QPixmap pixmap(":/res/splash.png");
    QSplashScreen splash(pixmap);
    QObject::connect(app, &DNApplication::initiated, &splash, &QSplashScreen::close);
    splash.show();
    app->_init(argc, argv);

    Q_CHECK_PTR(app);
    int exitcode = 0;
    exitcode = app->exec();
   // splash.finish();

    app->_shutdown();
    delete app;
    gst_deinit();
    return exitcode;
}
