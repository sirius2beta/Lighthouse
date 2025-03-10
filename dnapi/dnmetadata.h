#ifndef DNMETADATA_H
#define DNMETADATA_H

#include <QObject>

class DNMetaData : public QObject
{
    Q_OBJECT
public:
    typedef enum {
        valueTypeUint8,
        valueTypeInt8,
        valueTypeUint16,
        valueTypeInt16,
        valueTypeInt32,
        valueTypeUint32,
        valueTypeInt64,
        valueTypeUint64,
        valueTypeFloat,
        valueTypeDouble,
        valueTypeBool,
        valueTypeArray
    } ValueType_t;
    explicit DNMetaData(QObject *parent = nullptr);
    static ValueType_t intToType(int i);
    static ValueType_t stringToType(QString s);
signals:

};

#endif // DNMETADATA_H
