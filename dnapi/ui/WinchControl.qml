import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Layouts 1.15
import DeNovoViewer 1.0
import DeNovoViewer.Boat 1.0

Item {
    property ControlItem control: DeNovoViewer.controlManager.controls.get(0)
    property int length: 0


    Layout.fillWidth: true
    Layout.fillHeight: true
    Layout.alignment: Qt.AlignTop
    ColumnLayout{
        anchors.fill:parent
        Rectangle{
            border.color: "black"
            border.width: 1.5
            radius: 5
            color: "#222222"
            Layout.preferredHeight: 30
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignTop
            Text{
                anchors.fill:parent
                font.family: "Segoe UI"
                text:" Winch Control"
                color:"white"
                font.pixelSize: 20
                verticalAlignment: Text.AlignVCenter
                leftPadding: 5
            }
        }
        RowLayout{
            Layout.maximumHeight: 350
            Layout.preferredHeight: 350
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignTop
            Rectangle{
                border.color: "black"
                border.width: 1.5
                radius: 5
                color: "#222222"
                Layout.fillHeight: true
                Layout.preferredWidth: 100
                Layout.alignment: Qt.AlignLeft
                ColumnLayout{
                    anchors.fill: parent
                    Rectangle{
                        id: upButton
                        anchors.margins: 2
                        border.color: "black"
                        border.width: 1.5
                        radius: 5
                        color: "#555555"
                        Layout.preferredHeight: 40
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignTop
                        Layout.margins: 5
                        MouseArea{
                            anchors.fill: parent
                            onPressed: {
                                upButton.color = "#444444"
                            }
                            onReleased: {
                                upButton.color = "#555555"
                            }
                            onClicked: {
                                length = length -1

                                control.run("-"+steps.text)
                            }

                        }
                        Text{
                            anchors.fill:parent
                            font.family: "Segoe UI"
                            text:"-"
                            font.pixelSize: 20
                            color:"white"
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                        }

                    }


                    Row{

                        Layout.alignment: Qt.AlignHCenter
                        Column {
                            topPadding: 20
                            width:10
                            Repeater {
                                model: 5
                                Rectangle {
                                    width: 10; height: 40
                                    border.width: 1
                                    color: index<length?"white":"#666666"
                                }
                            }
                        }
                        Column {
                            width:30
                            leftPadding:5
                            Repeater {
                                model: 6
                                Item{
                                    width: 30; height: 40
                                    Text{
                                        anchors.fill: parent
                                        font.family: "Segoe UI"
                                        font.pixelSize: 20
                                        text:index + " m"
                                        color:"white"
                                        verticalAlignment: Text.AlignVCenter
                                        leftPadding: 10
                                    }


                                }


                            }
                        }
                    }
                    Rectangle{
                        id: downButton
                        anchors.margins: 2
                        border.color: "black"
                        border.width: 1.5
                        radius: 5
                        color: "#555555"
                        Layout.preferredHeight: 40
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignTop
                        Layout.margins: 5
                        MouseArea{
                            anchors.fill: parent
                            onPressed: {
                                downButton.color = "#444444"
                            }
                            onReleased: {
                                downButton.color = "#555555"
                            }
                            onClicked: {
                                length = length + 1
                                control.run(steps.text)
                            }

                        }
                        Text{
                            anchors.fill:parent
                            font.family: "Segoe UI"
                            text:"+"
                            font.pixelSize: 20
                            color:"white"
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                        }

                    }

                }
            }
            Rectangle{
                border.color: "black"
                border.width: 1.5
                radius: 5
                color: "#222222"
                Layout.fillHeight: true
                Layout.fillWidth: true

                ColumnLayout{
                    anchors.fill: parent

                    RowLayout{
                        Layout.leftMargin: 20
                        Layout.rightMargin: 20
                        Layout.topMargin: 20
                        Text{
                            Layout.rightMargin: 20
                            Layout.bottomMargin: 0
                            font.family: "Segoe UI"
                            text:"MaxSpeed"
                            font.pixelSize: 16
                            color:"white"
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                        }

                        TextField {
                            bottomPadding: 5
                            Layout.preferredHeight: 30
                            Layout.bottomMargin: 0
                            Layout.fillWidth: true
                            id: maxSpeed
                            selectByMouse: true
                            text: "2000"
                            font.family: "Segoe UI"
                            color: "white"
                            background: Item {
                                    implicitWidth: 50
                                    implicitHeight: 40
                                    Rectangle {
                                        color: "black"
                                        height: parent.height
                                        width: parent.width
                                        anchors.bottom: parent.bottom
                                    }
                            }
                        }
                    }
                    RowLayout{
                        Layout.leftMargin: 20
                        Layout.rightMargin: 20
                        Text{
                            Layout.rightMargin: 20
                            Layout.bottomMargin: 0
                            font.family: "Segoe UI"
                            text:"Acceleration"
                            font.pixelSize: 16
                            color:"white"
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                        }

                        TextField {
                            bottomPadding: 5
                            Layout.preferredHeight: 30
                            Layout.bottomMargin: 0
                            Layout.fillWidth: true
                            id: acceleraiton
                            selectByMouse: true
                            text: "1000"
                            font.family: "Segoe UI"
                            color: "white"
                            background: Item {
                                    implicitWidth: 50
                                    implicitHeight: 20
                                    Rectangle {
                                        color: "black"
                                        height: parent.height
                                        width: parent.width
                                        anchors.bottom: parent.bottom
                                    }
                            }
                        }
                    }
                    RowLayout{
                        Layout.leftMargin: 20
                        Layout.rightMargin: 20
                        Layout.bottomMargin: 20
                            Text{
                                Layout.rightMargin: 20
                                Layout.bottomMargin: 0
                                Layout.preferredHeight: 30
                                font.family: "Segoe UI"
                                text:"Steps"
                                font.pixelSize: 16
                                color:"white"
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignHCenter
                            }

                            TextField {
                                bottomPadding: 5
                                Layout.preferredHeight: 30
                                Layout.bottomMargin: 0
                                Layout.fillWidth: true
                                id: steps
                                selectByMouse: true
                                text: "1600"
                                font.family: "Segoe UI"
                                color: "white"
                                background: Item {
                                        implicitWidth: 50
                                        implicitHeight: 20
                                        Rectangle {
                                            color: "black"
                                            height: parent.height
                                            width: parent.width
                                            anchors.bottom: parent.bottom
                                        }
                                    }
                            }
                        }

                    RowLayout{
                        Layout.fillWidth: true
                        Layout.preferredHeight: 10
                        Layout.leftMargin: 10
                        Layout.rightMargin: 10
                        Layout.bottomMargin: 5
                        Rectangle{
                            id: stopButton
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            radius: 5
                            color:"#666666"
                            MouseArea{
                                id: stopButtonMouseArea
                                anchors.fill: parent
                                onPressed: {
                                    stopButton.color = "#444444"
                                }
                                onReleased: {
                                    stopButton.color = "#666666"
                                }
                                onClicked: {
                                    control.stop()
                                }

                            }
                            Text{
                                anchors.fill: parent
                                font.family: "Segoe UI"
                                text:"Stop"
                                font.pixelSize: 16
                                color:"white"
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignHCenter
                            }

                        }
                        Rectangle{
                            id: powerButton
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            radius: 5
                            color:"#151515"
                            border.width: 2
                            border.color: "#444444"
                            Text{
                                topPadding: 5
                                anchors.fill: parent
                                font.family: "Segoe UI"
                                text:"ON"
                                font.pixelSize: 16
                                color:"white"
                                verticalAlignment: Text.AlignTop
                                horizontalAlignment: Text.AlignHCenter
                            }
                            Rectangle{
                                height: 60
                                anchors.bottom: parent.bottom
                                anchors.right: parent.right
                                anchors.left: parent.left
                                color:"#454545"
                                border.width: 1
                                border.color: "black"
                                radius:5
                                Text{
                                    anchors.fill: parent
                                    font.family: "Segoe UI"
                                    text:"Power"
                                    font.pixelSize: 16
                                    color:"white"
                                    verticalAlignment: Text.AlignVCenter
                                    horizontalAlignment: Text.AlignHCenter
                                }
                            }


                        }
                        Rectangle{
                            id: statusButton
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            radius: 5
                            color:"#151515"
                            border.width: 2
                            border.color: "#444444"
                            Text{
                                topPadding: 5
                                anchors.fill: parent
                                font.family: "Segoe UI"
                                text:"Ready"
                                font.pixelSize:16
                                color:"white"
                                verticalAlignment: Text.AlignTop
                                horizontalAlignment: Text.AlignHCenter
                            }
                            Rectangle{
                                height: 60
                                anchors.bottom: parent.bottom
                                anchors.right: parent.right
                                anchors.left: parent.left
                                color:"#454545"
                                border.width: 1
                                border.color: "black"
                                radius:5
                                Text{
                                    anchors.fill: parent
                                    font.family: "Segoe UI"
                                    text:"Status"
                                    font.pixelSize: 16
                                    color:"white"
                                    verticalAlignment: Text.AlignVCenter
                                    horizontalAlignment: Text.AlignHCenter
                                }
                            }


                        }
                    }
                    RowLayout{
                        Layout.fillWidth: true
                        Layout.preferredHeight: 10
                        Layout.leftMargin: 10
                        Layout.rightMargin: 10
                        Layout.bottomMargin: 5
                        Rectangle{
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            radius: 10
                            color:"#666666"
                        }
                        Rectangle{
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            radius: 10
                            color:"#666666"
                        }
                        Rectangle{
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            radius: 10
                            color:"#666666"
                        }
                    }
                    Item{
                        Layout.fillHeight: true
                    }
                }
            }
        }
        Item{
            Layout.fillHeight: true
        }
    }
}
