#include "sensormanager.h"
#include "dncore.h"
#include <QByteArray>
#include <QVariant>
#include <QQmlEngine>

SensorManager::SensorManager(QObject *parent, DNCore* core)
    : QObject{parent},
    _core(core)
{
    QQmlEngine::setObjectOwnership(this, QQmlEngine::CppOwnership);
    settings = new QSettings("Ezosirius", "GPlayer_v1", this);
}

void SensorManager::init()
{
    qDebug()<<"sensorManager:: Initiating...";

    QVector<SensorGroup> _sensorGroupList = _core->configManager()->sensorGropList(); //從configmanager取得sensorgrouplist
    //將_sensorGroupList轉存為_sensorGroupListModel

    for(int i = 0; i< _sensorGroupList.count(); i++){
        DNQmlObjectListModel* model = new DNQmlObjectListModel(this); // model為sensorgrouplist其中一個sensorGroup

        for(int j = 0; j < _sensorGroupList[i].count(); j++){
            model->append(_sensorGroupList[i][j]);

        }
        _sensorGroupListModel.append(model);
    }
    SensorItem* sensor = qobject_cast<SensorItem*> (_sensorGroupListModel[4]->get(1));
    qDebug()<<"type:"<<sensor->value().dataType();
    qDebug()<<"sensorManager:: Initiate complete";
}

DNQmlObjectListModel* SensorManager::getSensorModel(int index)
{

    if(index<_sensorGroupListModel.size()){
        return _sensorGroupListModel[index];
    }else{
        qDebug()<<"**Fatal: sensorManager:: getSensorModel: index out of range";
        return nullptr;
    }
}


void SensorManager::onSensorMsg(int ID, QByteArray data)
{

    //DNMetaData::ValueType_t datatype;
    //qDebug()<<data;
    int pos = 0; //byte readed

    uint8_t sensorGroup;
    DNQmlObjectListModel* sensorGroupModel;
    char* cdata = data.data();
    memcpy(&sensorGroup, cdata+pos, sizeof(uint8_t));
    pos+=sizeof(uint8_t);
    if(_sensorGroupListModel.size() < sensorGroup){
        qDebug()<<"**Fatal: sensorManager:: onSensorMsg: incoming sensorGroup index out of range";
        return;
    }else{
         sensorGroupModel = _sensorGroupListModel[sensorGroup];
    }

    while(data.size()>pos){
        //get sensor type
        int8_t sensortype_i;
        memcpy(&sensortype_i, cdata+pos, sizeof(int8_t));
        //qDebug()<<sensortype_i;
        pos+=sizeof(uint8_t);
        if(sensortype_i >= sensorGroupModel->count()){
            qDebug()<<"**Fatal: sensorManager:: onSensorMsg: incoming sensorType index out of range";
            return;
        }
        SensorItem* sensor = qobject_cast<SensorItem*> (sensorGroupModel->get(sensortype_i));

        //get sensor value

        if(sensor->value().dataType() == DNMetaData::valueTypeUint8){
            uint8_t value;
            memcpy(&value, cdata+pos, sizeof(uint8_t));
            pos+=sizeof(uint8_t);
            //qDebug()<<"["<<sensortype_i<<"]"<<":"<<value<<"(uint8)";
            sensor->setValue(DNValue(value));
        }else if(sensor->value().dataType() == DNMetaData::valueTypeInt8){
            int8_t value;
            memcpy(&value, cdata+pos, sizeof(int8_t));
            pos+=sizeof(int8_t);
            //qDebug()<<"["<<sensortype_i<<"]"<<":"<<value<<"(int8)";
            sensor->setValue(DNValue(value));
        }else if(sensor->value().dataType() == DNMetaData::valueTypeUint16){
            uint16_t value;
            memcpy(&value, cdata+pos, sizeof(uint16_t));
            pos+=sizeof(uint16_t);
            //qDebug()<<"["<<sensortype_i<<"]"<<":"<<value<<"(uint16)";
            sensor->setValue(DNValue(value));
        }else if(sensor->value().dataType() == DNMetaData::valueTypeInt16){
            int16_t value;
            memcpy(&value, cdata+pos, sizeof(int16_t));
            pos+=sizeof(int16_t);
            //qDebug()<<"["<<sensortype_i<<"]"<<":"<<value<<"(int16)";
            sensor->setValue(DNValue(value));
        }else if(sensor->value().dataType() == DNMetaData::valueTypeUint32){
            uint32_t value;
            memcpy(&value, cdata+pos, sizeof(uint32_t));
            pos+=sizeof(uint32_t);
            //qDebug()<<"["<<sensortype_i<<"]"<<":"<<value<<"(uint32)";
            sensor->setValue(DNValue(value));
        }else if(sensor->value().dataType() == DNMetaData::valueTypeInt32){
            int32_t value;
            memcpy(&value, cdata+pos, sizeof(int32_t));
            pos+=sizeof(int32_t);
            //qDebug()<<"["<<sensortype_i<<"]"<<":"<<value<<"(int32)";
            sensor->setValue(DNValue(value));
        }else if(sensor->value().dataType() == DNMetaData::valueTypeUint64){
            uint64_t value;
            memcpy(&value, cdata+pos, sizeof(uint64_t));
            pos+=sizeof(uint64_t);
            //qDebug()<<"["<<sensortype_i<<"]"<<":"<<value<<"(uint64)";
            sensor->setValue(DNValue(value));
        }else if(sensor->value().dataType() == DNMetaData::valueTypeInt64){
            int64_t value;
            memcpy(&value, cdata+pos, sizeof(int64_t));
            pos+=sizeof(int64_t);
            //qDebug()<<"["<<sensortype_i<<"]"<<":"<<value<<"(int64)";
            sensor->setValue(DNValue(value));
        }else if(sensor->value().dataType() == DNMetaData::valueTypeDouble){
            double value;
            memcpy(&value, cdata+pos, sizeof(double));
            pos+=sizeof(double);
            //qDebug()<<"["<<sensortype_i<<"]"<<":"<<value<<"(double)";
            sensor->setValue(DNValue(value));
        }else if(sensor->value().dataType() == DNMetaData::valueTypeFloat){
            float value;
            memcpy(&value, cdata+pos, sizeof(float));
            pos+=sizeof(float);
            //qDebug()<<"["<<sensortype_i<<"]"<<":"<<value<<"(float)";
            sensor->setValue(DNValue(value));
        }else{
            int value;
            memcpy(&value, cdata+pos, sizeof(uint32_t));
            pos+=sizeof(uint32_t);
            //qDebug()<<"["<<sensortype_i<<"]"<<":"<<value<<"(uint32xx)";
            sensor->setValue(DNValue(value));
        }


    }
}
