import QtQuick 2.15
import QtQuick.Controls 2.15

import QtQuick.Layouts 1.3
import DeNovoViewer 1.0


Item {
    id: root
    width: 300
    height: 700

    property real targetStep: 0

    signal homePage()
    Rectangle{
        id: rectangle
        anchors.topMargin: 0
        color: "#1a1a1c"
        border.color: "#565656"
        anchors.fill:parent
    }
    Rectangle{
        id: titleBar
        height:40

        color: "#333333"
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        Text {
            id: text1
            color: "#ffffff"
            text: qsTr("Winch Control")
            anchors.fill: parent
            font.pixelSize: 18
            verticalAlignment: Text.AlignVCenter
            anchors.rightMargin: 10
            anchors.leftMargin: 10
            font.family: Constants.font.family
        }
        DNButton{

            text:"home"
            anchors.right: parent.right
            height:40
            onClicked: {
                root.parent.source = ""
            }
        }
    }

    ScrollView{
        id: flickable
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: titleBar.bottom
        anchors.bottom: parent.bottom

        clip: parent.width
        contentHeight: 700
        contentWidth: parent.width

            ColumnLayout{

                id: column
                anchors.fill: parent

                anchors.margins: 10

                spacing: 10
                Text {
                    color: "#ffffff"

                    text: qsTr("Current steps")
                    font.pixelSize: 18
                    font.family: Constants.font.family
                    Layout.alignment: Qt.AlignHCenter
                }
                Rectangle{
                    id: currentStepBox
                    Layout.fillWidth: true
                    height:60
                    radius:10
                    color: "#333333"
                    Text {
                        anchors.fill: parent
                        color: "#ffffff"
                        text: DeNovoViewer.controlManager.controls.get(0).steps.toString() + "\n(" + DeNovoViewer.sensorManager.aquaModel.get(0).displayValue+ " m)"
                        font.pixelSize: 18
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.family: Constants.font.family
                    }
                    RowLayout{
                        anchors.fill: parent
                        Rectangle{
                            height:30
                            color: "#009ddc"
                            Layout.fillHeight: true
                            width:60
                            radius: 15
                            Text {
                                anchors.fill: parent
                                color: "#ffffff"

                                text: qsTr("reset")
                                font.pixelSize: 18
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                font.family: Constants.font.family
                            }
                            MouseArea{
                                anchors.fill: parent
                                onPressed: {
                                    DeNovoViewer.controlManager.controls.get(0).reset()
                                    parent.color = '#999999'

                                }
                                onReleased:  {
                                    parent.color = "#009ddc"

                                }
                            }

                        }
                        Rectangle{
                            Layout.fillWidth: true

                        }

                        ColumnLayout{
                            Rectangle{
                                width:80
                                height:20
                                color: DeNovoViewer.controlManager.controls.get(0).status==1?"#009900":"#272727"
                                Text {
                                    color: DeNovoViewer.controlManager.controls.get(0).status==1?"#ffffff":"#797979"
                                    text: "running"
                                    font.pixelSize: 16
                                    anchors.fill: parent
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    font.family: Constants.font.family
                                }
                            }
                            Rectangle{
                                width:80
                                height:20
                                color: DeNovoViewer.controlManager.controls.get(0).status==0?"#990000":"#272727"
                                Text {
                                    color: DeNovoViewer.controlManager.controls.get(0).status==0?"#ffffff":"#797979"
                                    text: "Stopped"
                                    font.pixelSize: 16
                                    anchors.fill: parent
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    font.family: Constants.font.family
                                }
                            }
                        }


                    }
                }
                Text {
                    color: "#ffffff"

                    text: qsTr("Target step")
                    font.pixelSize: 18
                    font.family: Constants.font.family
                    Layout.alignment: Qt.AlignHCenter
                }

                DNValueEdit{
                    Layout.fillWidth: true
                    height:60
                    increment: 1000
                    value: targetStep
                    onValueChanged:{
                        targetStep = this.value
                    }
                }

                Rectangle{
                    height:60
                    color: "#009ddc"
                    Layout.fillWidth: true
                    radius: 30
                    Text {
                        anchors.fill: parent
                        color: "#ffffff"

                        text: qsTr("Go")
                        font.pixelSize: 18
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.family: Constants.font.family
                    }
                    MouseArea{
                        anchors.fill: parent
                        onPressed: {
                            DeNovoViewer.controlManager.controls.get(0).run(targetStep)
                            parent.color = '#999999'

                        }
                        onReleased:  {
                            parent.color = "#009ddc"

                        }
                    }

                }

                Rectangle{
                    height:60
                    color: "#636363"
                    Layout.fillWidth: true
                    radius: 30
                    Text {
                        anchors.fill: parent
                        color: "#ffffff"

                        text: qsTr("Stop")
                        font.pixelSize: 18
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.family: Constants.font.family
                    }
                    MouseArea{
                        anchors.fill: parent
                        onPressed: {
                            DeNovoViewer.controlManager.controls.get(0).stop()
                            parent.color = '#999999'

                        }
                        onReleased:  {
                            parent.color = "#636363"

                        }
                    }

                }

                Text {
                    color: "#ffffff"
                    text: qsTr("Free Control")
                    font.pixelSize: 18
                    font.family: Constants.font.family
                    Layout.alignment: Qt.AlignHCenter
                }

                Rectangle{
                    id: freeControl
                    Layout.fillWidth: true
                    height:60
                    color: "#00ffffff"

                    RowLayout{
                        anchors.fill:parent
                        Rectangle{
                            id: freedownbtn
                            property string colorn: "#555555"
                            width: 90
                            height:60
                            color: "#00ffffff"
                            Rectangle{
                                width:60
                                height:60
                                radius:30
                                color: parent.colorn
                            }
                            Rectangle{
                                x:30
                                width:60
                                height:60
                                color: parent.colorn
                            }
                            Text {
                                anchors.fill: parent
                                color: "#ffffff"
                                text: qsTr("-")
                                font.pixelSize: 18
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                font.family: Constants.font.family

                            }
                            MouseArea{
                                anchors.fill: parent
                                onPressed: {
                                    DeNovoViewer.controlManager.controls.get(0).run(-1000000)
                                    parent.colorn = "#999999"
                                }
                                onReleased:  {
                                    //parent.colorn = "#555555"

                                }
                            }
                        }
                        Rectangle{
                            id: stopbtn
                            width: 80
                            height:60
                            color: "#555555"
                            Text {
                                anchors.fill: parent
                                color: "#ffffff"
                                text: qsTr("STOP")
                                font.pixelSize: 18
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                font.family: Constants.font.family

                            }
                            MouseArea{
                                anchors.fill: parent
                                onPressed: {
                                    parent.color = "#999999"
                                }
                                onReleased:  {
                                    DeNovoViewer.controlManager.controls.get(0).stop()
                                    parent.color = "#555555"
                                    freedownbtn.colorn = "#555555"
                                    freeupbtn.colorn = "#555555"

                                }
                            }
                        }

                        Rectangle{
                            id: freeupbtn

                            property string colorn: "#555555"
                            width: 90
                            height:60
                            color: "#00ffffff"
                            Rectangle{
                                x:30
                                width:60
                                height:60
                                radius:30
                                color: parent.colorn
                            }
                            Rectangle{

                                width:60
                                height:60
                                color: parent.colorn
                            }
                            Text {
                                anchors.fill: parent
                                color: "#ffffff"
                                text: qsTr("+")
                                font.pixelSize: 18
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                font.family: Constants.font.family

                            }
                            MouseArea{
                                anchors.fill: parent
                                onPressed: {
                                    DeNovoViewer.controlManager.controls.get(0).run(1000000)
                                    freeupbtn.colorn = "#999999"
                                }
                                onReleased:  {
                                    //freeupbtn.colorn = "#555555"

                                }
                            }
                        }

                    }
                }

                Text {
                    color: "#ffffff"
                    text: qsTr("Max Speed")
                    font.pixelSize: 18
                    font.family: Constants.font.family
                    Layout.alignment: Qt.AlignHCenter
                }

                DNValueEdit{
                    Layout.fillWidth: true
                    height:60
                    value:DeNovoViewer.controlManager.controls.get(0).maxSpeed
                    onValueChanged:{
                        console.log(DeNovoViewer.controlManager.controls.get(0).maxSpeed)
                        DeNovoViewer.controlManager.controls.get(0).set = this.value
                    }
                }

                Rectangle{
                    Layout.fillHeight: true
                }


            }

    }





}
