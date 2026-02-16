#include "aquagraph.h"

AquaGraph::AquaGraph(QObject *parent) : QObject(parent)
{
    // 1. 強制初始化為空列表，避免 QML 看到 undefined
    m_currentData = QVariantList();
}

void AquaGraph::refreshData() {
    QVariantList newData;
    // 2. 模擬一些數據 (記得 i++)
    for (int i = 0; i < 50; ++i) {
        QVariantMap point;
        point["time"] = i;
        point["value"] = (double)i;
        newData.append(point);
    }

    m_currentData = newData;
    // 3. 發出訊號通知 QML
    emit dataChanged();
}
