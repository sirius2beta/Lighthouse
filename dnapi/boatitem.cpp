#include "boatitem.h"
#include "dncore.h"

BoatItem::BoatItem(QObject *parent, DNCore* core)
    : QObject{parent},
      _core(core),
      _name(QString("")),
      _primaryConnected(false),
      _secondaryConnected(false),
      _connectionPriority(0),
      _linkType(0)
{
    QObject::connect(_core->networkManager(), &NetworkManager::deviceStatusMsg, this, &BoatItem::onDeviceStatusMsg);
    _deviceStatusCode = { "0", "0", "0", "0"};

}

BoatItem::BoatItem(const BoatItem& other, QObject* parent)
    :QObject{parent}
{
    *this = other;
}

const BoatItem& BoatItem::operator=(const BoatItem& other)
{
    _core = other._core;
    _name = other._name;
    _ID = other._ID;
    _PIP = other._PIP;
    _SIP = other._SIP;
    _currentIP = other._currentIP;
    _OS = other._OS;
    _primaryConnected = other._primaryConnected;
    _secondaryConnected = other._secondaryConnected;
    _connectionPriority = other._connectionPriority;
    _linkType = other._linkType;


    _primaryHeartBeat = other._primaryHeartBeat;
    _secondaryHeartBeat = other._secondaryHeartBeat;
    return *this;

}

BoatItem::~BoatItem()
{
    QObject::disconnect(_core->networkManager(), &NetworkManager::deviceStatusMsg, this, &BoatItem::onDeviceStatusMsg);
}

void BoatItem::setName(QString name)
{
    _name = name;
    emit nameChanged(_ID, name);
}

void BoatItem::setID(int ID)
{
    _ID = ID;
    emit IDChanged(ID);
}

void BoatItem::setPIP(QString PIP)
{
    if(PIP != _PIP){
        _PIP = PIP;
        emit IPChanged(_ID, true);
    }
}

void BoatItem::setSIP(QString SIP)
{
    if(SIP != _SIP){
        _SIP = SIP;
        emit IPChanged(_ID, false);
    }
}

void BoatItem::setOS(int OS)
{
    _OS = OS;
}

void BoatItem::setConnectionPriority(int connectionType)
{
    _connectionPriority = connectionType;
}

Peripheral BoatItem::getPeriperalbyID(int ID)
{

    for(int i = 0; i<peripherals.size(); i++){
        if(peripherals[i].ID == ID){
            return peripherals[i];
        }
    }

    return Peripheral();
}

void BoatItem::connect(bool isPrimary)
{

    if(_connectionPriority == 0){
        if(_primaryConnected){
                //keep connected
        }else{
            if(_secondaryConnected){
                if(isPrimary){
                    emit connectionChanged(_ID);
                    _currentIP = _PIP;
                }else{
                    //keep connected
                }
            }else{
                if(isPrimary){
                    emit connectionChanged(_ID);
                    _currentIP = _PIP;
                }else{
                    emit connectionChanged(_ID);
                    _currentIP = _SIP;
                    //keep connected
                }
            }
        }
    }else{
        if(_secondaryConnected){
                //keep connected
        }else{
            if(_primaryConnected){
                if(isPrimary){
                    //keep connected
                }else{
                    emit connectionChanged(_ID);
                    _currentIP = _SIP;
                }

            }else{
                if(isPrimary){
                    emit connectionChanged(_ID);
                    _currentIP = _PIP;
                }else{
                    emit connectionChanged(_ID);
                    _currentIP = _SIP;
                }
            }
        }
    }

    if(isPrimary){
        _primaryConnected = true;
        emit primaryConnectedChanged(true);
    }else{
        _secondaryConnected = true;
        emit secondaryConnectedChanged(true);
    }
    emit connectStatusChanged(_ID, isPrimary, true);
    qDebug()<<"BoatItem::connect "<<(isPrimary?"Primary":"Secondary")<<" "<<QString::number(_ID);



}

void BoatItem::disconnect(bool isPrimary)
{
    if(isPrimary){
        _primaryConnected = false;
    }else{
        _secondaryConnected = false;
    }

    if(_connectionPriority == 0){
        if(_primaryConnected){
            //keep connected
        }else{
            if(_secondaryConnected){
                qDebug()<<"BoatItem:: switch connection";
                emit connectionChanged(_ID);
                _currentIP = _SIP;
            }
        }
    }else{
        if(_secondaryConnected){
            //keep connected
        }else{
            if(_primaryConnected){
                qDebug()<<"BoatItem:: switch connection";
                emit connectionChanged(_ID);
                _currentIP = _PIP;
            }
        }
    }

    qDebug()<<"BoatItem::disconnect "<<(isPrimary?"Primary":"Secondary")<<" "<<QString::number(_ID);
    if(isPrimary){
        emit primaryConnectedChanged(false);
    }else{
        emit secondaryConnectedChanged(false);
    }
    emit connectStatusChanged(_ID, isPrimary, false);
}

Device* BoatItem::getDevbyID(int ID)
{

    for(int i = 0; i<devices.size(); i++){
        if(devices[i].ID == ID){
            return &devices[i];
        }
    }
    return 0;
}

void BoatItem::setDeviceStatusCode(QStringList list)
{
    _deviceStatusCode = list;
    emit deviceStatusCodeChanged(list);
}

void BoatItem::restartService()
{
    emit restartServiceSignal(_ID);
}

void BoatItem::reboot()
{
    emit rebootSignal(_ID);
}

void BoatItem::stopService()
{
    emit stopServiceSignal(_ID);
}
void BoatItem::update()
{
    emit updateSignal(_ID);
}

void BoatItem::onDeviceStatusMsg(uint8_t boatID, QByteArray detectMsg)
{
    if(boatID == _ID){
        uint8_t flightControl;
        uint8_t GPS;
        uint8_t winch;
        uint8_t aqua;
        memcpy(&flightControl, detectMsg.data(), sizeof(uint8_t));
        memcpy(&GPS, detectMsg.data()+1, sizeof(uint8_t));
        memcpy(&winch, detectMsg.data()+2, sizeof(uint8_t));
        memcpy(&aqua, detectMsg.data()+3, sizeof(uint8_t));
        QStringList list = {QString::number(flightControl), QString::number(GPS), QString::number(winch), QString::number(aqua)};
        setDeviceStatusCode(list);

    }

}
