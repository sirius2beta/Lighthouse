#include "dncontrol.h"

DNControl::DNControl(QObject *parent, int controlType)
    : QObject{parent},
      _controlType(controlType)
{

}
