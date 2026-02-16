#ifndef AQUAGRAPH_H
#define AQUAGRAPH_H


#include <QObject>
#include <qvariant.h>
#include <Qtimer>

class DNCore;


class AquaGraph : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QVariantList currentData READ currentData NOTIFY dataChanged)
public:
    explicit AquaGraph(QObject *parent = nullptr, DNCore *core = nullptr);
    QVariantList currentData() const { return m_currentData; }

signals:
    void dataChanged();
protected slots:
    void refreshData();

private:
    QVariantList m_currentData;
    QTimer* _refreshTimer;
    DNCore* _core;
    int m_tickCount = 0; // 新增這個計數器，記錄總共跑了幾秒
};

#endif // AQUAGRAPH_H
