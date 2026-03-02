import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: root
    width: 640
    height: 480
    property real rollAngle: 10
    property real pitch:-10
    Rectangle{
        color: "#001a1a1c"
        border.color: "#00000000"
        anchors.fill: parent
    }
    Rectangle{
        id: rectangle
        width: 200
        height: 200
        color: "#00ffffff"
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter

        Image {
            id: indicator1
            anchors.top: parent.top
            anchors.topMargin: 0
            source: "qrc:/res/indicator1.png"
            anchors.horizontalCenter: parent.horizontalCenter
            fillMode: Image.PreserveAspectFit
            Image {
                id: indicator3
                anchors.top: parent.top
                anchors.topMargin: 19
                source: "qrc:/res/indicator2.png"
                anchors.horizontalCenter: parent.horizontalCenter
                fillMode: Image.PreserveAspectFit
                transform: Rotation{origin.x:7.5; origin.y:6; angle:180}
            }


            Rectangle{
                x: 221/2-50
                y:128-75
                width: 100
                height: 150
                color: "#00ffffff"
                clip:true
                Column {
                    id: column
                    y:75-150+pitch%10*5
                    width: 100
                    height: 300
                    Repeater{
                        model:5
                        Row{
                            Text{
                                y:15
                                width:15
                                color: "#ffffff"
                                font.family: Constants.font.family
                                style: Text.Outline
                                text: -index*10+20+Math.sign(pitch) * Math.floor(Math.abs(pitch/10))*10
                                font.pixelSize: 14
                                font.bold: true
                            }

                            Rectangle{
                                width:60
                                height:50
                                color: "#00000000"
                                Rectangle{
                                    x:33
                                    width:14
                                    height:4
                                    color: "#ffffff"
                                    border.width: 1
                                }
                                Rectangle{
                                    y:25
                                    x:20
                                    width:40
                                    height:4
                                    color: "#ffffff"
                                    border.width: 1
                                }
                            }
                        }


                    }
                }
            }



            transform: Rotation { origin.x: 221/2; origin.y: 128; angle: rollAngle}
        }
        Image {
            id: indicator2
            anchors.top: parent.top
            anchors.topMargin: 4
            source: "qrc:/res/indicator2.png"
            anchors.horizontalCenter: parent.horizontalCenter
            fillMode: Image.PreserveAspectFit
        }
    }









}
