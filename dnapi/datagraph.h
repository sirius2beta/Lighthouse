#ifndef DATAGRAPH_H
#define DATAGRAPH_H

#include <QObject>
#include <QQuickItem>

class DataGraph : public QObject
{
    Q_OBJECT
public:
    explicit DataGraph(QObject *parent = nullptr);

signals:
};

#endif // DATAGRAPH_H
