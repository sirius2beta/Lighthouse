import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Layouts 1.15
import DeNovoViewer 1.0
import DeNovoViewer.Boat 1.0

Item {
    ListModel {  //not used
        id: demoModel
        ListElement {
            name: "Temperature"
            number: "26.45"
            unit: "℃"
        }
        ListElement {
            name: "Pressure"
            number: "1.1"
            unit: "psi"
        }
        ListElement {
            name: "Density of water"
            number: "1.05"
            unit: "d"
        }
        ListElement {
            name: "Specific conductivity"
            number: "521.21"
            unit: "%"
        }
        ListElement {
            name: "Barometric pressure"
            number: "101.22"
            unit: "psi"
        }
        ListElement {
            name: "Dissolved oxgen saturation"
            number: "13.22"
            unit: "%"
        }
        ListElement {
            name: "Dissolved oxgen saturation"
            number: "13.22"
            unit: "%"
        }
        ListElement {
            name: "Resistivity"
            number: "45.23"
            unit: "%"
        }
    }

    Layout.preferredWidth: 300
    Layout.fillHeight: true
    Layout.alignment: Qt.AlignLeft
    Rectangle{
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.left: parent.left
        anchors.bottom: parent.bottom

        radius:5
        color: "#292b2d"
        Rectangle{
            id: _title
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            radius: 5
            height:30
            color: "#222222"


            Text{

                font.family: "Segoe UI"
                text: " Aqua"
                font.pixelSize: 20
                color:"white"
            }
        }
        Component {
            id: sensorDelegate
            Item {
                width: _sensorListView.width; height: 25
                RowLayout{

                    Text {
                        Layout.preferredWidth: 200
                        wrapMode: Text.WordWrap
                        font.family: "Segoe UI"
                        font.pixelSize: 16
                        lineHeight: 0.6
                        color:"#b8bbc0"
                        text: object.name.toLowerCase().split('_').join(' ')
                    }
                    Item {
                        Layout.fillWidth: true
                    }

                    Text {
                        Layout.preferredWidth: 30
                        font.family: "Segoe UI"
                        font.pixelSize: 16
                        color:"white"
                        text: object.displayValue
                    }

                }
            }
        }

        ListView{
            id: _sensorListView
            anchors.top:_title.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: 10
            clip: true
            model: DeNovoViewer.sensorManager.aquaModel
            delegate: sensorDelegate

        }

    }



}
