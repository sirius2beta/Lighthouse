#ifndef MISSIONMANAGER_H
#define MISSIONMANAGER_H

#include <QObject>

class MissionManager : public QObject
{
    Q_OBJECT
public:
    explicit MissionManager(QObject *parent = nullptr);

signals:

};

#endif // MISSIONMANAGER_H
