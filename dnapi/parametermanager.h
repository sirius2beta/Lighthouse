#ifndef PARAMETERMANAGER_H
#define PARAMETERMANAGER_H

#include <QObject>

class ParameterManager : public QObject
{
    Q_OBJECT
public:
    explicit ParameterManager(QObject *parent = nullptr);

signals:

};

#endif // PARAMETERMANAGER_H
