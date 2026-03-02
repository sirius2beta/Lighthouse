import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Layouts 1.15
import QtQuick.Dialogs
import DeNovoViewer 1.0
import DeNovoViewer.Boat 1.0

Item {
    Component{
        id: editBoatDialog
        EditBoatDialog{

        }
    }
    id: _root
    height:300
    width:300
    Layout.preferredWidth: 300
    Layout.fillHeight: true
    Layout.alignment: Qt.AlignLeft
    property int boatNo: 0

    Rectangle{
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        radius:5
        color: "#222222"
        opacity: 100
        border.width: 0
        border.color: "#dddddd"

        Rectangle{
            id: _title
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 2

            height:35
            color: "#191919"

            Text{
                anchors.fill: parent
                verticalAlignment: Qt.AlignVCenter
                leftPadding: 2
                font.family: "Roboto"
                font.pixelSize: 16
                text:" Boat Settings"
                color:"white"
            }
            Button {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                id: close_button
                text: ""
                topInset: 0
                bottomInset: 0
                height:30
                width:30
                property bool activate: false
                background: Rectangle {
                    color: parent.down ? "#99333333" : "#00000000"
                    //border.color: "#26282a"
                    //border.width: 1
                    implicitWidth: 45
                    implicitHeight: 45
                    radius: 4
                    Rectangle{
                        anchors.fill: parent
                        radius:4
                        anchors.margins: 5
                        color:"#00999900"
                    }

                    Image{
                        id: img3
                        anchors.margins: 5
                        anchors.top: parent.top
                        anchors.right: parent.right
                        anchors.left: parent.left
                        fillMode: Image.PreserveAspectFit

                        source: "qrc:/res/close.png"
                    }
                }
                onClicked: {
                    _root.parent.source = ""
                }
            }
        }
        ColumnLayout{
            anchors.top: _title.bottom
            anchors.left: parent.left
            anchors.right:  parent.right
            anchors.bottom: parent.bottom
            anchors.margins: 10
            RowLayout{
                id: boat_name_layout
                Text{
                    text:"boat name"
                    Layout.preferredWidth: 100
                    color:"#ffffff"
                    font.pixelSize: 14
                }
                TextField {
                    id: boat_name_edit
                    Layout.fillWidth: true
                    selectByMouse: true
                    text: DeNovoViewer.boatManager.getBoatbyIndex(boatNo).name
                    font.family: "Segoe UI"
                }
            }
            RowLayout{
                id: pip_layout
                Text{
                    text:"priamary IP"
                    color:"#ffffff"
                    font.pixelSize: 14
                    Layout.preferredWidth: 100
                }
                TextField {
                    id: boat_PIP_edit
                    Layout.fillWidth: true
                    selectByMouse: true
                    text: DeNovoViewer.boatManager.getBoatbyIndex(boatNo).PIP
                    font.family: "Segoe UI"
                }
            }
            RowLayout{
                id: sip_layout
                Text{
                    text:"secondary IP"
                    color:"#ffffff"
                    font.pixelSize: 14
                    Layout.preferredWidth: 100
                }
                TextField {
                    id: boat_SIP_edit
                    Layout.fillWidth: true
                    selectByMouse: true
                    text: DeNovoViewer.boatManager.getBoatbyIndex(boatNo).SIP
                    font.family: "Segoe UI"
                }
            }
            RowLayout{
                Item{
                    Layout.fillWidth: true
                }

                Button{
                    text: "save"
                    onClicked: {
                        DeNovoViewer.boatManager.getBoatbyIndex(boatNo).name = boat_name_edit.text
                        DeNovoViewer.boatManager.getBoatbyIndex(boatNo).PIP = boat_PIP_edit.text
                        DeNovoViewer.boatManager.getBoatbyIndex(boatNo).SIP = boat_SIP_edit.text

                    }
                }
            }
            Item{
                Layout.fillHeight: true
            }
        }
    }

}


