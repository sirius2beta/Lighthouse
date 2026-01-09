import QtQuick 2.15
import QtQuick.Layouts
import QtQuick.Controls

import DeNovoViewer 1.0
import DeNovoViewer.Boat 1.0



Item {
    width:150
    height:180
    property int boatIndex: 0
    Rectangle{
        anchors.fill: parent
        color: "#555555"
        radius: 2
        opacity: 0.5
    }

    ColumnLayout{
        anchors.fill:parent
        anchors.margins: 5
        spacing: 0
        Rectangle{
            width:80
            height:14
            color: "#00000000"
            Rectangle{
                y:3
                width:5
                height:5
                color: DeNovoViewer.boatManager.boatListModel.get(0).deviceStatusCode[0]=="0"?"#aaaaaa":"#00ff00"

            }

           Text{
                topPadding: 0
                leftPadding: 10
                font.family: "roboto"
                font.pixelSize: 12
                text:" Flight Control"
                color:"white"
            }

        }
        Rectangle{
            width:80
            height:14
            color: "#00000000"
            Rectangle{
                y:3
                width:5
                height:5
                color: DeNovoViewer.boatManager.boatListModel.get(0).deviceStatusCode[1]=="0"?"#aaaaaa":"#00ff00"

            }
            Text{
                 topPadding: 0
                 leftPadding: 10
                 font.family: "roboto"
                 font.pixelSize: 12
                 text:" GPS"
                 color:"white"
             }

        }
        Rectangle{
            width:80
            height:14
            color: "#00000000"
            Rectangle{
                y:3
                width:5
                height:5
                color: DeNovoViewer.boatManager.boatListModel.get(0).deviceStatusCode[2]=="0"?"#aaaaaa":"#00ff00"

            }
            Text{
                 topPadding: 0
                 leftPadding: 10
                 font.family: "roboto"
                 font.pixelSize: 12
                 text:" winch"
                 color:"white"
             }

        }
        Rectangle{
            width:80
            height:14
            color: "#00000000"
            Rectangle{
                y:3
                width:5
                height:5
                color: {
                    if(DeNovoViewer.boatManager.boatListModel.get(0).deviceStatusCode[3]=="0"){
                        return "#aaaaaa"
                    }else if(DeNovoViewer.boatManager.boatListModel.get(0).deviceStatusCode[3]=="1"){
                        return "#ffff00"
                    }else{
                        return "#00ff00"
                    }
                }
            }
            Text{
                 topPadding: 0
                 leftPadding: 10
                 font.family: "roboto"
                 font.pixelSize: 12
                 text:"Aqua"
                 color:"white"
             }

        }
        RowLayout{
            Rectangle{
                width: 60
                height: 40
                color: "#555555"
                Text{
                     topPadding: 2
                     leftPadding: 2
                     font.family: "roboto"
                     font.pixelSize: 12
                     text:"Restart"
                     color:"white"
                }
                MouseArea{
                    anchors.fill: parent
                    onPressed: {
                        parent.color = "#333333"

                    }
                    onReleased: {
                        parent.color = "#555555"
                        DeNovoViewer.boatManager.activeBoat.restartService()
                    }
                }
            }
            Rectangle{
                width: 60
                height: 40
                color: "#aa5555"
                Text{
                     topPadding: 2
                     leftPadding: 2
                     font.family: "roboto"
                     font.pixelSize: 12
                     text:"Reboot"
                     color:"white"
                }
                MouseArea{
                    anchors.fill: parent
                    onPressed: {
                        parent.color = "#882222"

                    }
                    onReleased: {
                        parent.color = "#aa5555"
                        DeNovoViewer.boatManager.activeBoat.reboot()
                    }
                }
            }
        }
        RowLayout{
            Rectangle{
                width: 60
                height: 40
                color: "#555555"
                Text{
                     topPadding: 2
                     leftPadding: 2
                     font.family: "roboto"
                     font.pixelSize: 12
                     text:"update"
                     color:"white"
                }
                MouseArea{
                    anchors.fill: parent
                    onPressed: {
                        parent.color = "#333333"

                    }
                    onReleased: {
                        parent.color = "#555555"
                        DeNovoViewer.boatManager.activeBoat.update()
                    }
                }
            }
            Rectangle{
                width: 60
                height: 40
                color: "#555555"
                Text{
                     topPadding: 2
                     leftPadding: 2
                     font.family: "roboto"
                     font.pixelSize: 12
                     text:"..."
                     color:"white"
                }
                MouseArea{
                    anchors.fill: parent
                    onPressed: {
                        parent.color = "#333333"

                    }
                    onReleased: {
                        parent.color = "#555555"
                    }
                }
            }
        }

    }

/*
    Connections{
        target: DeNovoViewer.boatManager.boatListModel.get(0)
        function onDeviceStatusCodeChanged() {
            //console.log("deviceStatusCode changed:", DeNovoViewer.boatManager.boatListModel.get(0).deviceStatusCode)
        }
    }
*/


}
