#include "controlitem.h"

ControlItem::ControlItem(QObject *parent, QString name, int controlType, QVector<DNValue> fields)
: QObject{parent},
_name(name),
_controlType(controlType),
_boatID(-1)
{
    for(int i = 0; i< fields.size(); i++){
        DNValue* v = new DNValue(fields[i]);
        _fields.append(v);
    }
}

ControlItem::ControlItem(const ControlItem& other, QObject *parent)
{
    *this = other;
}


const ControlItem& ControlItem::operator =(const ControlItem& other)
{
    _name = other._name;
    _controlType = other._controlType;
    for(int i = 0; i< other._fields.size(); i++){
        DNValue* v = new DNValue(this);
        *v = other._fields[i];
        _fields.append(v);
    }
    _boatID = other._boatID;
    return *this;
}

void ControlItem::run()
{
}

// 請求networkmanager傳送訊息
void ControlItem::setField(int index, QString value)
{
    if(index >= _fields.size()){
        qDebug()<<"\u001b[38;5;203m"<<"**Fatal error: ControlItem::setField index outof range"<<"\033[0m";
    }else{
        _fields[index]->setValue(value);
        qDebug()<<"ControlItem::setField "<<_fields[index]->data();
    }
    uint8_t boatID = _boatID;
    uint8_t controlType = _controlType;
    uint8_t action = 0;
    uint8_t m_index = index;
    QByteArray bt;
    bt.append(boatID);
    bt.append(controlType);
    bt.append(action);
    bt.append(m_index);
    bt.append(_fields[index]->bytesData());
    // message type use raw
    emit sendMsgbyID(_boatID, 5, bt);
}

DNValue* ControlItem::getField(int index)
{
    if(index >= _fields.size()){
        qDebug()<<"\u001b[38;5;203m"<<"**Fatal error: ControlItem::setField index outof range"<<"\033[0m";
        return 0;
    }else{
        return _fields[index];
    }
}

void ControlItem::sendCMD()
{
    QByteArray data;
    for(int i = 0; i < _fields.size(); i++){
        data += _fields[i]->bytesData();
    }
    //emit sendMsg(data);
}
