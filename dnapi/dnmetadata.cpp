#include "dnmetadata.h"



DNMetaData::DNMetaData(QObject *parent)
    : QObject{parent}
{

}

DNMetaData::ValueType_t DNMetaData::intToType(int i)
{
    DNMetaData::ValueType_t dataType = DNMetaData::valueTypeUint32;
    if(i == 0){
        dataType = DNMetaData::valueTypeUint8;
    }else if(i == 1){
        dataType = DNMetaData::valueTypeInt8;
    }else if(i == 2){
        dataType = DNMetaData::valueTypeUint16;
    }else if(i == 3){
        dataType = DNMetaData::valueTypeInt16;
    }else if(i == 4){
        dataType = DNMetaData::valueTypeUint32;
    }else if(i == 5){
        dataType = DNMetaData::valueTypeInt32;
    }else if(i == 6){
        dataType = DNMetaData::valueTypeUint64;
    }else if(i == 7){
        dataType = DNMetaData::valueTypeInt64;
    }else if(i == 8){
        dataType = DNMetaData::valueTypeDouble;
    }else if(i == 9){
        dataType = DNMetaData::valueTypeFloat;
    }else if(i == 10){
        dataType = DNMetaData::valueTypeBool;
    }
    return dataType;
}

DNMetaData::ValueType_t DNMetaData::stringToType(QString s)
{
    DNMetaData::ValueType_t dataType = DNMetaData::valueTypeUint32;
    if(s == "uint_8"){
        dataType = DNMetaData::valueTypeUint8;
    }else if(s == "int_8"){
        dataType = DNMetaData::valueTypeInt8;
    }else if(s == "uint_16"){
        dataType = DNMetaData::valueTypeUint16;
    }else if(s == "int_16"){
        dataType = DNMetaData::valueTypeInt16;
    }else if(s == "uint_32"){
        dataType = DNMetaData::valueTypeUint32;
    }else if(s == "int_32"){
        dataType = DNMetaData::valueTypeInt32;
    }else if(s == "uint_64"){
        dataType = DNMetaData::valueTypeUint64;
    }else if(s == "int_64"){
        dataType = DNMetaData::valueTypeInt64;
    }else if(s == "double"){
        dataType = DNMetaData::valueTypeDouble;
    }else if(s == "float"){
        dataType = DNMetaData::valueTypeFloat;
    }else if(s == "bool"){
        dataType = DNMetaData::valueTypeBool;
    }
    return dataType;
}
