#ifndef SONARCONTROL_H
#define SONARCONTROL_H

#include <QObject>

#include "controlitem.h"

class SonarControl : public ControlItem
{
    Q_OBJECT
public:
    Q_PROPERTY(bool power READ power NOTIFY powerChanged)
    explicit SonarControl(QObject *parent = nullptr, QString name =QString(), int controlType = 0, QVector<DNValue> fields = QVector<DNValue>());
    Q_INVOKABLE void setPower(bool p);
    void processMsg(QByteArray command);
    bool power();

signals:
    void powerChanged(bool power);
protected:
    bool _powerOn;

};

#endif // SONARCONTROL_H
