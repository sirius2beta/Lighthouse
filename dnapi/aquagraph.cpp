#include "aquagraph.h"
#include <QRandomGenerator>
#include "sensormanager.h"
#include "dncore.h"

AquaGraph::AquaGraph(QObject *parent, DNCore* core)
    : QObject{parent},
    _core(core),
    _refreshTimer(new QTimer(this))
{
    // 1. 強制初始化為空列表，避免 QML 看到 undefined
    m_currentData = QVariantList();
    connect(_refreshTimer, &QTimer::timeout, this, &AquaGraph::refreshData);
    _refreshTimer->setSingleShot(false);
    _refreshTimer->start(1000);
}

void AquaGraph::refreshData() {
    // 1. 不要建立 newData，直接對成員變數 m_currentData 操作
    QVariantMap point;

    // 2. 這裡用 m_currentData.length() 來當 X 軸，它才會往右長
    point["time"] = m_tickCount++;;
    point["value"] = QRandomGenerator::global()->bounded(100,300);
    if(_core->sensorManager()->aquaModel()){
        SensorItem* sensor = qobject_cast<SensorItem*>(_core->sensorManager()->aquaModel()->get(3));
        point["depth"] = sensor->value().toFloat();
    }


    m_currentData.append(point);

    // 3. (選配) 為了不讓記憶體爆炸，只保留最近的 50 筆資料
    if (m_currentData.length() > 100) {
        m_currentData.removeFirst();
    }

    emit dataChanged();
}
