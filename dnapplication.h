#ifndef DNAPPLICATION_H
#define DNAPPLICATION_H

#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQuickWindow>
#include "dnapi/dncore.h"
#include "dnapi/dnqmlglobal.h"



class DNApplication:public QApplication
{
    Q_OBJECT
public:
    DNApplication(int &argc, char* argv[]);
    ~DNApplication();
    void _shutdown();
    void _init(int &argc, char *argv[]);
    QObject* _rootQmlObject();
    QQuickWindow* mainRootWindow();
    static DNApplication* _app;

    DNCore* core() { return _core; }
signals:
    void initiated();
private:
    DNCore* _core;
    QQmlApplicationEngine* _qmlEngine = nullptr;
    QQuickWindow* _mainRootWindow = nullptr;

};


DNApplication* dnApp(void);
#endif // DNAPPLICATION_H
