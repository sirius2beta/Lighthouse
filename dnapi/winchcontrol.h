#ifndef WINCHCONTROL_H
#define WINCHCONTROL_H

#include <QObject>

#include "controlitem.h"

class WinchControl : public ControlItem
{
    Q_OBJECT
public:
    Q_PROPERTY(int maxSpeed READ maxSpeed WRITE setMaxSpeed NOTIFY maxSpeedChanged )
    Q_PROPERTY(int acceleration READ acceleration WRITE setAcceleration  NOTIFY accelerationChanged )
    Q_PROPERTY(int steps READ steps WRITE setSteps NOTIFY stepsChanged )
    explicit WinchControl(QObject *parent = nullptr, QString name =QString(), int controlType = 0, QVector<DNValue> fields = QVector<DNValue>());
    void init(ControlItem* controlItem);
    Q_INVOKABLE void run(QString steps);
    Q_INVOKABLE void stop();
    int maxSpeed() { return _maxSpeed;}
    int acceleration() { return _acceleration;}
    int steps() { return _steps;}

    void setMaxSpeed(int s);
    void setAcceleration(int a);
    void setSteps(int s);

signals:
    void maxSpeedChanged(int s);
    void accelerationChanged(int a);
    void stepsChanged(int s);
    void sendCMD(QByteArray cmd);
private:
    int _maxSpeed;
    int _acceleration;
    int _steps;

};

#endif // WINCHCONTROL_H
