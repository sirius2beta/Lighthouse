#include "boatitem.h"
#include "dncore.h"

Q_LOGGING_CATEGORY(BoatItemLog, "hypex.comms.bridge")


BoatItem::BoatItem(QObject *parent, DNCore* core)
    : QObject{parent},
      _core(core),
      _name(QString("")),
      _primaryConnected(false),
      _secondaryConnected(false),
      _connectionPriority(0),
      _linkType(0),
     _commLostCheckTimer(new QTimer(this))
{
    QObject::connect(_core->networkManager(), &NetworkManager::deviceStatusMsg, this, &BoatItem::onDeviceStatusMsg);
    _deviceStatusCode = { "0", "0", "0", "0"};
    (void) QObject::connect(_commLostCheckTimer, &QTimer::timeout, this, &BoatItem::_commLostCheck);

    _commLostCheckTimer->setSingleShot(false);
    _commLostCheckTimer->setInterval(_commLostCheckTimeoutMSecs);

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

void BoatItem::_commLostCheck()
{

    const int heartbeatTimeout = _heartbeatMaxElpasedMSecs;
    bool linkStatusChange = false;

    if (!_primaryUdpLinkInfo.commLost &&  (_primaryUdpLinkInfo.heartbeatElapsedTimer.elapsed() > heartbeatTimeout)) {
        _primaryUdpLinkInfo.commLost = true;
        linkStatusChange = true;

    }
    if (!_secondaryUdpLinkInfo.commLost &&  (_secondaryUdpLinkInfo.heartbeatElapsedTimer.elapsed() > heartbeatTimeout)) {
        _secondaryUdpLinkInfo.commLost = true;
        linkStatusChange = true;

    }


    if (_updatePrimaryLink()) {
        emit connectionStatusChanged();
        emit connectionChanged(_ID);
        qCDebug(BoatItemLog, "update link");
    }

}

bool BoatItem::_updatePrimaryLink()
{

    if(_currentIP == _PIP){
        if(!_primaryUdpLinkInfo.commLost){
            return false;
        }else{
            if(!_secondaryUdpLinkInfo.commLost){ // secondary up!!
                _currentIP = _SIP;
                qCDebug(BoatItemLog,"secondary link up");
                return true;
            }else{
                return false;
            }
        }
        return false;
    }else{
        if(!_secondaryUdpLinkInfo.commLost){
            if(!_primaryUdpLinkInfo.commLost){ //primary up !!
                _currentIP = _PIP;
                qCDebug(BoatItemLog,"primary link up");
                return true;
            }else{
                return false;
            }
        }else{
            if(!_primaryUdpLinkInfo.commLost){
                _currentIP = _PIP;
                qCDebug(BoatItemLog,"primary link up");
                return true;
            }else{
                //need backup
                _currentIP = _PIP;
                qCDebug(BoatItemLog,"primary link up");
                return true;

            }

        }
    }
}

void BoatItem::receivedMsg(bool isPrimary)
{
    if(isPrimary){
        _primaryUdpLinkInfo.heartbeatElapsedTimer.restart();
        if(_primaryUdpLinkInfo.commLost){
            _primaryUdpLinkInfo.commLost = false;
            _updatePrimaryLink();
        }

    }else{
        _secondaryUdpLinkInfo.heartbeatElapsedTimer.restart();
        if(_secondaryUdpLinkInfo.commLost){
            _secondaryUdpLinkInfo.commLost = false;
            _updatePrimaryLink();
        }
    }
}
