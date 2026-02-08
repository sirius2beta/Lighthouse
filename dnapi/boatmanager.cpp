#include "boatmanager.h"
#include "dncore.h"
#include <QQmlEngine>

BoatManager::BoatManager(QObject* parent, DNCore *core): QObject(parent),
    _connectionType(0), _activeBoat(0)
{
    _core = core;

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

    QSettings settings;
    // Is the group even there?
    if (settings.contains(settingsRoot() + "/count")) {
        // Find out how many configurations we have
        const int count = settings.value(settingsRoot() + "/count").toInt();
        for (int i = 0; i < count; i++) {
            const QString root = settingsRoot() + QStringLiteral("/Link%1").arg(i);

            const QString boatname = settings.value(root + "/name").toString();
            int ID = settings.value(root+"/id").toInt();
            QString boatPIP = settings.value(root+"/PIP").toString();
            QString boatSIP = settings.value(root+"/SIP").toString();

            BoatItem* boat = new BoatItem(this, _core);
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
            connect(boat, &BoatItem::restartServiceSignal, this, &BoatManager::onRestartService);
            connect(boat, &BoatItem::rebootSignal, this, &BoatManager::onReboot);
            connect(boat, &BoatItem::stopServiceSignal, this, &BoatManager::onStopService);
            connect(boat, &BoatItem::updateSignal, this, &BoatManager::onUpdate);
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
    }else{
        addBoat();
        qDebug()<<"add boat";
    }

    if(_boatList.size() > 0){
        _activeBoat = _boatList[0];
    }
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



    BoatItem* boat = new BoatItem(this, _core);
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
    connect(boat, &BoatItem::restartServiceSignal, this, &BoatManager::onRestartService);
    connect(boat, &BoatItem::rebootSignal, this, &BoatManager::onReboot);
    connect(boat, &BoatItem::stopServiceSignal, this, &BoatManager::onStopService);
    connect(boat, &BoatItem::updateSignal, this, &BoatManager::onUpdate);
    //connect(boat, &BoatItem::disconnected, this, &BoatManager::onDisonnected);

    HeartBeat* primaryHeartBeat = new HeartBeat(boat, 50006, true, boat, _core);
    primaryHeartBeat->HeartBeatLoop();
    HeartBeat* secondaryHeartBeat = new HeartBeat(boat, 50006, false, boat, _core);
    secondaryHeartBeat->HeartBeatLoop();

    connect(boat, &BoatItem::connectionChanged, this, &BoatManager::connectionChanged);
    connect(boat, &BoatItem::IPChanged, primaryHeartBeat, &HeartBeat::onChangeIP);
    connect(boat, &BoatItem::IPChanged, secondaryHeartBeat, &HeartBeat::onChangeIP);

    QSettings settings;
    settings.remove(settingsRoot());

    int trueCount = 0;
    for (int i = 0; i < _boatList.count(); i++) {
        BoatItem* boat = _boatList[i];
        if (!boat) {
            qDebug() << "Internal error for link configuration in LinkManager";
            continue;
        }

        const QString root = settingsRoot() + QStringLiteral("/Link%1").arg(trueCount++);
        settings.setValue(root + "/name", boat->name());
        settings.setValue(root + "/id", boat->ID());
        settings.setValue(root + "/PIP", boat->PIP());
        settings.setValue(root + "/SIP", boat->SIP());

    }

    const QString root = QString(settingsRoot());
    settings.setValue(root + "/count", trueCount);


}

void BoatManager::deleteBoat(int index)
{
    int ID = getIndexbyID(index);
    _boatListModel.removeAt(index);
    delete _boatList[index];
    _boatList.removeAt(index);

    saveSettings();


    for(int i = 0; i < _core->videoManager()->count(); i++){
        if(_core->videoManager()->getVideoItem(i)->boatID() == ID){
            _core->videoManager()->getVideoItem(i)->stop();
        }
    }

    boatItemModel->removeRows(index,1);
    if(_boatList.size() > 0){
        _activeBoat = _boatList[0];
    }
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

void BoatManager::setActiveBoatbyIndex(int index)
{
    _activeBoat = getBoatbyIndex(index);
    emit activeBoatChanged();
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

void BoatManager::onBoatNameChange(int ID, QString newname)
{
    saveSettings();
    qDebug()<<"changename";
}

void BoatManager::onIPChanged(int ID, bool primary)
{
    saveSettings();

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

void BoatManager::onRestartService(uint8_t boatID)
{
    QByteArray bt;
    uint8_t commandType = 0;

    bt.append(boatID);
    bt.append(commandType);

    // message type use raw
    emit sendMsgbyID(boatID, 9, bt);
}

void BoatManager::onReboot(uint8_t boatID)
{
    QByteArray bt;
    uint8_t commandType = 1;

    bt.append(boatID);
    bt.append(commandType);

    // message type use raw
    emit sendMsgbyID(boatID, 9, bt);
}

void BoatManager::onStopService(uint8_t boatID)
{
    QByteArray bt;
    uint8_t commandType = 2;

    bt.append(boatID);
    bt.append(commandType);

    // message type use raw
    emit sendMsgbyID(boatID, 9, bt);
}

void BoatManager::onUpdate(uint8_t boatID)
{
    QByteArray bt;
    uint8_t commandType = 3;

    bt.append(boatID);
    bt.append(commandType);

    // message type use raw
    emit sendMsgbyID(boatID, 9, bt);
}

void BoatManager::saveSettings()
{
    QSettings settings;
    settings.remove(settingsRoot());

    int trueCount = 0;
    for (int i = 0; i < _boatList.count(); i++) {
        BoatItem* boat = _boatList[i];
        if (!boat) continue;

        const QString root = settingsRoot() + QStringLiteral("/Link%1").arg(trueCount++);
        settings.setValue(root + "/name", boat->name());
        settings.setValue(root + "/id", boat->ID());
        settings.setValue(root + "/PIP", boat->PIP());
        settings.setValue(root + "/SIP", boat->SIP());
    }
    settings.setValue(settingsRoot() + "/count", trueCount);

    qDebug() << "Settings saved, boat count:" << trueCount;
}
