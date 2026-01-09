#ifndef CONFIGMANAGER_H
#define CONFIGMANAGER_H

#include <QObject>
#include <QXmlStreamReader>

#include <QStandardItemModel>

#include "controlitem.h"
#include "sensorgroup.h"

#include "QDebug"


class ConfigManager : public QObject
{
    Q_OBJECT
public:
    explicit ConfigManager(QObject *parent = nullptr);
    int message(QString msg);
    QString messageChar(uint8_t index);
    QString videoFormatString(uint8_t index){ return _videoFormatTypeList[index]; }
    QVector<SensorGroup> sensorGropList() { return _sensorGropList;};
    QVector<ControlItem> controlList() { return _controlTypeList; }
    static const QString msg_heartbeat() {return "HEARTBEAT"; }
    static const QString msg_format() { return "FORMAT";}
    static const QString msg_command() { return "COMMAND";}
    static const QString msg_quit() { return "QUIT";}
    static const QString msg_sensor() { return "SENSOR"; }
    static const uint8_t msg_control;
    static const uint8_t msg_detect;
    static const uint8_t msg_devicestatus;


signals:
protected:
    void readSensorTypes();
    void readMessageTypes();
    void readVideoFormatTypes();
    void readControlTypes();
    void readArray();
private:
    QXmlStreamReader reader;
    QStandardItemModel* s;

    QVector<SensorGroup> _sensorGropList;


    QMap<QString, uint8_t> _messageTypeMap;
    QVector<QString> _videoFormatTypeList;
    QVector<ControlItem> _controlTypeList;
};

#endif // CONFIGMANAGER_H
