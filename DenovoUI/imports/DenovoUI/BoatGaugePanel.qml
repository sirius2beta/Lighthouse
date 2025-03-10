import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    property int _totalBatteryPercentage: 0
    property int _totalBatteryVoltage: 0
    property int _totalBatteryCurrent: 0
    property int _cabinTemp: 25

    id: root
    width: 300
    height: 400
    Rectangle{
        color: "#222224"
        anchors.fill: parent
        border.color: "#565656"

    }

    ScrollView{
        anchors.fill: parent
        anchors.topMargin: 10
        anchors.rightMargin: 10
        anchors.leftMargin: 10
        anchors.bottomMargin: 10
        clip: true


        ColumnLayout {
            width:280
            id: columnLayout


            spacing: 2

            Rectangle{
                height:25
                color: "#53555f"
                Layout.preferredHeight: 20
                Layout.fillWidth: true
                radius: 2
                Text {
                    anchors.fill: parent
                    color: "#ffffff"

                    text: qsTr("CABIN")
                    font.pixelSize: 12
                    font.family: Constants.font.family
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

                }
                Rectangle{
                    anchors.bottom: parent.bottom
                    height: 1
                    width: parent.width
                    color: "#9d9d9d"

                }

            }


            ValueBar{
                title: "temperature"
                value: _cabinTemp
                Layout.fillWidth: true


            }
            Rectangle{
                height: 1
                color: "#7c7c7c"
                Layout.fillWidth: true

            }

            ValueBar{
                title: "humidity"
                value: 75
                lowerLimit: 0
                upperLimit: 0
                greenStart: 20
                yellowEnd: 0
                yellowStart: 0
                Layout.fillWidth: true


            }

            Rectangle{
                height:20
                color: "#5b5b62"
                Layout.preferredHeight: 20
                Layout.fillWidth: true
                Text {
                    anchors.fill: parent
                    id: text1
                    color: "#ffffff"

                    text: qsTr("BAT")
                    font.pixelSize: 12
                    font.family: Constants.font.family
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

                }
                Rectangle{
                    anchors.bottom: parent.bottom
                    height: 1
                    width: parent.width
                    color: "#9d9d9d"

                }

            }

            Rectangle{
                id: rectangle
                Layout.fillWidth: true
                height: 220
                color: "#1a1a1c"
                Layout.preferredHeight: 250
                Layout.margins: 4
                Column{
                    id: column
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10

                    RowLayout{
                        height:120
                        width:parent.width
                        Rectangle{
                            id: rectangle1
                            Layout.fillWidth: true
                            height:120
                            color: "#3d3d3d"
                            ColumnLayout{
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.margins: 4

                                Text {
                                    color: "#ffffff"
                                    font.family: Constants.font.family
                                    text: "Total "
                                    font.pixelSize: 16
                                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter

                                }
                                Text {
                                    id: text2
                                    color: "#ffffff"
                                    font.family: Constants.font.family
                                    text: _totalBatteryVoltage/1000 + " V"
                                    font.pixelSize: 16
                                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter

                                }
                                Text {
                                    id: text3
                                    color: "#ffffff"

                                    text: _totalBatteryCurrent/100 + " A"
                                    font.pixelSize: 16
                                    font.family: Constants.font.family
                                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter

                                }
                                Text {
                                    id: text4
                                    color: "#ffffff"
                                    font.family: Constants.font.family
                                    text: _totalBatteryPercentage+" %"
                                    font.pixelSize: 16
                                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter

                                }

                            }
                        }



                        BatteryBar{
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                            percentage: _totalBatteryPercentage
                            noBattery: false
                        }
                        BatteryBar{
                            percentage: 40
                        }
                        BatteryBar{

                        }
                        BatteryBar{

                        }
                    }

                }


            }
            Rectangle{
                color: "#00ffffff"
                Layout.fillHeight: true
                Layout.fillWidth: true

            }


        }



    }





}
