#ifndef AQUAGRAPH_H
#define AQUAGRAPH_H

#include <QObject>
#include <qvariant.h>

class AquaGraph : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QVariantList currentData READ currentData NOTIFY dataChanged)
public:
    explicit AquaGraph(QObject *parent = nullptr);
    Q_INVOKABLE void refreshData();
    QVariantList currentData() const { return m_currentData; }

signals:
    void dataChanged();

private:
    QVariantList m_currentData;
};

#endif // AQUAGRAPH_H
