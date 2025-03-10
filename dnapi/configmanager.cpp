#include "configmanager.h"
#include <QFile>
#include <QDebug>
#include <QQmlEngine>


ConfigManager::ConfigManager(QObject *parent)
    : QObject{parent}
{
    QQmlEngine::setObjectOwnership(this, QQmlEngine::CppOwnership);

    QFile file(":/res/SensorType.xml");
    reader.setDevice(&file);
    if(file.open(QIODevice::ReadOnly | QIODevice::Text)){
        qDebug()<<"file opened";

        if (reader.readNextStartElement()) {
            if (reader.name().toString() == "marinelink"){
                while(reader.readNextStartElement()){
                    if(reader.name().toString() == "enum"){
                        if(reader.attributes().value("name").toString() == "SENSOR"){
                            readSensorTypes();

                        }else if(reader.attributes().value("name").toString() == "MESSAGE_TYPE"){
                            readMessageTypes();

                        }else if(reader.attributes().value("name").toString() == "VIDEO_FORMAT"){
                            readVideoFormatTypes();
                        }else if(reader.attributes().value("name").toString() == "CONTROL_TYPE"){
                            readControlTypes();

                        }else{
                            reader.skipCurrentElement();
                        }

                    }
                    else{
                        reader.skipCurrentElement();
                    }
                }
            }
            else
                reader.raiseError(QObject::tr("ConfigManager:: Incorrect xml config file"));
        }
    }
    file.close();
    qDebug()<<"ConfigManager:: xml file closed";
}


int ConfigManager::message(QString msg){
    if(_messageTypeMap.find(msg) == _messageTypeMap.end()){
        qDebug()<<"**Fatal::ConfigManager::message no msg:"<<msg;
        return -1;
    }else{
        return _messageTypeMap[msg];
    }
}

QString ConfigManager::messageChar(uint8_t index){
    QList<QString> result = _messageTypeMap.keys(index);


    if(result.size() == 0){
        return QString();
    }else{

        return _messageTypeMap.keys(index)[0];
    }
}

void ConfigManager::readSensorTypes()
{


    while(reader.readNextStartElement()){
        if(reader.name().toString() == "sensorgroup"){
            SensorGroup sg(nullptr, reader.attributes().value("name").toString());
            qDebug()<<reader.attributes().value("name");
            // readElementText at last to prevent breaking loop

            while(reader.readNextStartElement()){

                if(reader.name().toString() == "sensor"){
                    qDebug()<<reader.attributes().value("name");
                    int sensorType = reader.attributes().value("value").toInt();
                    QString name = reader.attributes().value("name").toString();
                    QString dataTypeName = reader.attributes().value("type").toString();
                    DNMetaData::ValueType_t dataType = DNMetaData::stringToType(dataTypeName);
                    DNValue value(0, dataType);
                    SensorItem* si = new SensorItem(this, name, sensorType, value);

                    qDebug()<<dataTypeName;
                    sg.append(si);
                    // readElementText at last to prevent breaking loop
                    reader.readElementText();
                }
            }
            _sensorGropList.append(sg);
        }else{
            reader.skipCurrentElement();
        }
    }




}

void ConfigManager::readMessageTypes()
{

    while(reader.readNextStartElement()){

        if(reader.name().toString() == "entry"){
            uint8_t messageType = reader.attributes().value("value").toInt();
            QString name = reader.attributes().value("name").toString();
            _messageTypeMap[name] = messageType;
            qDebug()<<messageType<<","<<name;
            // readElementText at last to prevent breaking loop
            reader.readElementText();
        }
    }

}

void ConfigManager::readVideoFormatTypes()
{
    qDebug()<<"ConfigManager::read videoformat types";
    while(reader.readNextStartElement()){

        if(reader.name().toString() == "entry"){
            uint8_t videoType = reader.attributes().value("value").toInt();
            QString name = reader.attributes().value("name").toString();
            _videoFormatTypeList.append(name);
            qDebug()<<"  -"<<videoType<<","<<name;
            // readElementText at last to prevent breaking loop
            reader.readElementText();

        }
    }

}


void ConfigManager::readControlTypes()
{
    qDebug()<<"ConfigManager::read control types";
    while(reader.readNextStartElement()){

        if(reader.name().toString() == "entry"){

            uint8_t controlType = reader.attributes().value("value").toInt();
            QString name = reader.attributes().value("name").toString();
            QVector<DNValue> fields;

            qDebug()<<"  -"<<controlType<<","<<name;
            // readElementText at last to prevent breaking loop
            //reader.readElementText();
            while(reader.readNextStartElement()){

                if(reader.name().toString() == "field"){
                    QString fieldName = reader.attributes().value("name").toString();
                    QString type = reader.attributes().value("type").toString();
                    DNValue value(0, DNMetaData::stringToType(type));
                    value.setName(fieldName);
                    fields.append(value);
                    qDebug()<<fieldName<<type;
                    // readElementText at last to prevent breaking loop

                    reader.readElementText();
                }else{
                    //reader.skipCurrentElement();
                }
            }
            ControlItem control(nullptr, name, controlType, fields);
            _controlTypeList.append(control);
        }
    }

}
