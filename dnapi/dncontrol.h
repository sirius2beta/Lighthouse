#ifndef DNCONTROL_H
#define DNCONTROL_H

#include <QObject>

class DNControl : public QObject
{
    Q_OBJECT
public:
    explicit DNControl(QObject *parent = nullptr, int controType = -1);


signals:
    void sendMsg(QByteArray msg);
private:
    int _controlType;

};

#endif // DNCONTROL_H
