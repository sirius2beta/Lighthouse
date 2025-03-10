#include "boatmanager.h"
#include "dncore.h"
#include <QQmlEngine>

BoatManager::BoatManager(QObject* parent, DNCore *core): QObject(parent),
    _connectionType(0)
{
    _core = core;
    settings = new QSettings("Ezosirius", "GPlayer_v1", this);
    boatItemModel = new QStandardItemModel();
    QStringList label = {"name", "Primary", "Secondary"};
    boatItemModel->setHorizontalHeaderLabels(label);
    init();

}

BoatManager::~BoatManager()
{
    delete boatItemModel;

}

void BoatManager::init()
{

    QQmlEngine::setObjectOwnership(this, QQmlEngine::CppOwnership);

    qDebug()<<"BoatManager::init(): Initiating...";
    settings->beginGroup(QString("%1").arg(_core->config()));
    int size = settings->beginReadArray("boat");

    for(int i = 0; i < size; i++){
        settings->setArrayIndex(i);
        QString boatname = settings->value("boatname").toString();
        int ID = settings->value("ID").toInt();
        QString boatPIP = settings->value("/PIP").toString();
        QString boatSIP = settings->value("/SIP").toString();

        BoatItem* boat = new BoatItem(this);
        boat->setID(ID);
        boat->setName(boatname);
        boat->setPIP(boatPIP);
        boat->setSIP(boatSIP);
        _boatList.append(boat);

        _boatListModel.append(boat);

        int current = boatItemModel->rowCount();
        QStandardItem* item1 = new QStandardItem(boatname);
        QStandardItem* item2 = new QStandardItem(QString("SB"));
        item2->setData(boatPIP);
        item2->setBackground(QBrush(QColor(120,0,0)));
        QStandardItem* item3 = new QStandardItem(QString("SB"));
        item3->setData(boatSIP);
        item3->setBackground(QBrush(QColor(120,0,0)));
        boatItemModel->setItem(current,0,item1);
        boatItemModel->setItem(current,1,item2);
        boatItemModel->setItem(current,2,item3);

        connect(boat, &BoatItem::nameChanged, this, &BoatManager::onBoatNameChange);
        connect(boat, &BoatItem::IPChanged, this, &BoatManager::onIPChanged);
        connect(boat, &BoatItem::connectStatusChanged, this, &BoatManager::onConnectStatusChanged);
        //connect(boat, &BoatItem::disconnected, this, &BoatManager::onDisonnected);

        HeartBeat* _primaryHeartBeat = new HeartBeat(boat, 50006, true, boat, _core);
        _primaryHeartBeat->HeartBeatLoop();
        HeartBeat* _secondaryHeartBeat = new HeartBeat(boat, 50006, false, boat, _core);
        _secondaryHeartBeat->HeartBeatLoop();

        connect(boat, &BoatItem::connectionChanged, this, &BoatManager::connectionChanged);
        connect(boat, &BoatItem::IPChanged, _primaryHeartBeat, &HeartBeat::onChangeIP);
        connect(boat, &BoatItem::IPChanged, _secondaryHeartBeat, &HeartBeat::onChangeIP);

        qDebug()<<"  - Add boat: ID:"<<ID<<", name:"<<boatname ;

    }

    settings->endArray();
    settings->endGroup();
    qDebug()<<"BoatManager::init(): Initiate complete";
}

void BoatManager::addBoat()
{

    QVector<bool> indexfree(256, true);
        int index = 0;
        for(int i = 0; i< size(); i++){
            indexfree[getBoatbyIndex(i)->ID()] = false;

        }
        for(int i =0; i<256; i++){
            if(indexfree[i] == true){
                index = i;

                break;
            }
        }



    BoatItem* boat = new BoatItem(this);
    QQmlEngine::setObjectOwnership(boat, QQmlEngine::CppOwnership);
    boat->setID(index);
    boat->setName("unknown");
    boat->setPIP("");
    boat->setSIP("");
    _boatList.append(boat);

    _boatListModel.append(boat);
    emit onboatListModelChanged(&_boatListModel);
    emit boatAdded();

    int current = boatItemModel->rowCount();
    QStandardItem* item1 = new QStandardItem("unknown");
    QStandardItem* item2 = new QStandardItem(QString("SB"));
    item2->setData("");
    item2->setBackground(QBrush(QColor(120,0,0)));
    QStandardItem* item3 = new QStandardItem(QString("SB"));
    item3->setData("");
    item3->setBackground(QBrush(QColor(120,0,0)));
    boatItemModel->setItem(current,0,item1);
    boatItemModel->setItem(current,1,item2);
    boatItemModel->setItem(current,2,item3);

    connect(boat, &BoatItem::nameChanged, this, &BoatManager::onBoatNameChange);
    connect(boat, &BoatItem::IPChanged, this, &BoatManager::onIPChanged);
    connect(boat, &BoatItem::connectStatusChanged, this, &BoatManager::onConnectStatusChanged);
    //connect(boat, &BoatItem::disconnected, this, &BoatManager::onDisonnected);

    HeartBeat* primaryHeartBeat = new HeartBeat(boat, 50006, true, boat, _core);
    primaryHeartBeat->HeartBeatLoop();
    HeartBeat* secondaryHeartBeat = new HeartBeat(boat, 50006, false, boat, _core);
    secondaryHeartBeat->HeartBeatLoop();

    connect(boat, &BoatItem::connectionChanged, this, &BoatManager::connectionChanged);
    connect(boat, &BoatItem::IPChanged, primaryHeartBeat, &HeartBeat::onChangeIP);
    connect(boat, &BoatItem::IPChanged, secondaryHeartBeat, &HeartBeat::onChangeIP);

    settings->beginGroup(QString("%1").arg(_core->config()));
    int size = settings->beginReadArray("boat");
    settings->endArray();
    settings->beginWriteArray("boat");
    settings->setArrayIndex(size);
    settings->setValue(QString("boatname"), "unknown");
    settings->setValue(QString("ID"), index);
    settings->setValue(QString("PIP"), "");
    settings->setValue(QString("SIP"), "");
    settings->endArray();
    settings->endGroup();

}

void BoatManager::deleteBoat(int index)
{
    int ID = getIndexbyID(index);
    _boatListModel.removeAt(index);
    delete _boatList[index];
    _boatList.removeAt(index);


    settings->beginGroup(QString("%1").arg(_core->config()));
    settings->remove("");
    settings->beginWriteArray("boat");


    for(int i = 0; i<_boatList.size(); i++){
        BoatItem* boat = _boatList[i];
        settings->setArrayIndex(i);
        settings->setValue("boatname",boat->name());
        settings->setValue("PIP", boat->PIP());
        settings->setValue("SIP", boat->SIP());
        settings->setValue("ID", boat->ID());
    }

    settings->endArray();
    settings->endGroup();

    for(int i = 0; i < _core->videoManager()->count(); i++){
        if(_core->videoManager()->getVideoItem(i)->boatID() == ID){
            _core->videoManager()->getVideoItem(i)->stop();
        }
    }

    boatItemModel->removeRows(index,1);
}

BoatItem* BoatManager::getBoatbyIndex(int index)
{
    if(index >= _boatList.size()){
        return 0;
    }
    return _boatList[index];
}

BoatItem* BoatManager::getBoatbyID(int ID)
{

    for(int i = 0; i<_boatList.size(); i++){

        if(_boatList[i]->ID() == ID){

            return _boatList[i];
        }
    }
    return 0;
}

int BoatManager::getIDbyInex(int index)
{
    if(_boatList.size() == 0){
        return -1;
    }
    return _boatList[index]->ID();
}

int BoatManager::getIndexbyID(int ID)
{
    for(int i = 0; i < _boatList.size(); i++){
        if(_boatList[i]->ID() == ID){
            return i;
        }
    }
    return -1;
}



QString BoatManager::CurrentIP(QString boatname)
{
    for(int i = 0; i<_boatList.size(); i++){
        if(_boatList[i]->name() == boatname){
            return _boatList[i]->currentIP();
        }
    }
    return QString();
}

int BoatManager::size()
{
    return _boatList.size();
}
/*
void BoatManager::setConnectionType(int connectiontype)
{
    _connectionType = connectiontype;
    emit connectionTypeChanged(connectiontype);
}
*/
void BoatManager::onBoatNameChange(int ID, QString newname)
{
    int index = getIndexbyID(ID);
    qDebug()<<"++id:"<<ID;
    boatItemModel->item(index, 0)->setText(newname);
    settings->beginGroup(QString("%1").arg(_core->config()));
    //int size = settings->beginReadArray("boat");
    settings->setArrayIndex(index);
    settings->setValue("boatname",newname);

    settings->endArray();
    settings->endGroup();
    qDebug()<<"changename";
}

void BoatManager::onIPChanged(int ID, bool primary)
{
    int index = getIndexbyID(ID);
    qDebug()<<"++:"<<index;
    BoatItem* boat = _boatList[index];
    if(primary){
        boatItemModel->item(index,1)->setData(boat->PIP());
    }else{
        boatItemModel->item(index,2)->setData(boat->SIP());
    }

    settings->beginGroup(QString("%1").arg(_core->config()));
    settings->beginReadArray("boat");

    settings->setArrayIndex(index);
    settings->setValue("PIP", boat->PIP());
    settings->setValue("SIP", boat->SIP());

    settings->endArray();
    settings->endGroup();
}

void BoatManager::onConnectStatusChanged(int ID, bool isprimary, bool isConnected)
{
    if(isConnected){
        if(isprimary){
            getBoatbyID(ID)->setPrimaryConnected(true);
            boatItemModel->item(getIndexbyID(ID),1)->setText("Active");
            boatItemModel->item(getIndexbyID(ID),1)->setBackground(QBrush(QColor(0,120,0)));
        }else{
            getBoatbyID(ID)->setSecondaryConnected(false);
            boatItemModel->item(getIndexbyID(ID),2)->setText("Active");
            boatItemModel->item(getIndexbyID(ID),2)->setBackground(QBrush(QColor(0,120,0)));
        }
    }else{
        if(isprimary){
            getBoatbyID(ID)->setPrimaryConnected(false);
            boatItemModel->item(getIndexbyID(ID),1)->setText("SB");
            boatItemModel->item(getIndexbyID(ID),1)->setBackground(QBrush(QColor(120,0,0)));
        }else{
            getBoatbyID(ID)->setSecondaryConnected(false);
            boatItemModel->item(getIndexbyID(ID),2)->setText("SB");
            boatItemModel->item(getIndexbyID(ID),2)->setBackground(QBrush(QColor(120,0,0)));
        }
    }

}

void BoatManager::onConnectionTypeChanged(int connectiontype)
{
    _connectionType = connectiontype;
    for(int i = 0; i< _boatList.size(); i++){
        _boatList[i]->setConnectionPriority(connectiontype);
    }
    emit connectionTypeChanged(connectiontype);
}
