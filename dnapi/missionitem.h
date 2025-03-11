#ifndef MISSIONITEM_H
#define MISSIONITEM_H

#include <QObject>

class MissionItem : public QObject
{
    Q_OBJECT
public:
    explicit MissionItem(QObject *parent = nullptr);

signals:

};

#endif // MISSIONITEM_H
