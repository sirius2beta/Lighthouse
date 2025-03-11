import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Layouts 1.15
import DeNovoViewer 1.0
import DeNovoViewer.Boat 1.0

Item {
    Layout.preferredWidth: 300
    Layout.preferredHeight: 500
    Layout.alignment: Qt.AlignLeft

    ListModel {
        id: demoModel2
        ListElement {
            name: "Cabin Temperature"
            number: "26.45"
            unit: "℃"
        }
        ListElement {
            name: "Battery cell 1"
            number: "19.3"
            unit: "V"
        }
        ListElement {
            name: "Battery cell 2"
            number: "19.5"
            unit: "V"
        }
        ListElement {
            name: "Battery cell 3"
            number: "19.3"
            unit: "V"
        }
        ListElement {
            name: "CPU temperature"
            number: "40.5"
            unit: "C"
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
    Component {
        id: sensorDelegate
        Item {
            width: _sensorListView.width; height: 20
            RowLayout{

                Text {
                    Layout.preferredWidth: 150
                    Layout.fillHeight: true
                    wrapMode: Text.WordWrap
                    font.family: "Segoe UI"
                    font.pixelSize: 16
                    lineHeight: 0.8
                    color:"#b8bbc0"
                    text: object.name.toLowerCase()
                }
                Item {
                    Layout.fillWidth: true
                }
                Rectangle{
                    Layout.preferredWidth: 50
                    Layout.fillHeight: true
                    color: "#007700"
                    Text {
                        anchors.fill: parent
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        font.family: "Segoe UI"
                        font.pixelSize: 16
                        color:"white"

                        text: object.displayValue
                    }
                }



            }
        }
    }
    Component {
        id: sensorDelegate2
        Item {
            width: _sensorListView.width; height: 20
            RowLayout{

                Text {
                    Layout.preferredWidth: 150
                    Layout.fillHeight: true
                    wrapMode: Text.WordWrap
                    font.family: "Segoe UI"
                    font.pixelSize: 16
                    lineHeight: 0.8
                    color:"#b8bbc0"
                    text: object.name.toLowerCase()
                }
                Item {
                    Layout.fillWidth: true
                }

                Rectangle{
                    Layout.preferredWidth: 50
                    Layout.fillHeight: true
                    color: "#007700"
                    Text {
                        anchors.fill: parent
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        font.family: "Segoe UI"
                        font.pixelSize: 16
                        color:"white"

                        text: object.displayValue
                    }
                }

            }
        }
    }
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
            height:35
            color: "#222222"


            Text{

                font.family: "Segoe UI"
                font.pixelSize: 20
                text:" SensorValue"

                color:"white"
            }
        }


        Item {
            anchors.top: _title.bottom
            anchors.right: parent.right
            anchors.left: parent.left
            anchors.bottom: parent.bottom

            ColumnLayout{
                anchors.fill: parent
                Text {
                    text: "Cabin"
                    Layout.preferredHeight: 10
                    font.family: "Segoe UI"
                    font.pixelSize: 16
                    color:"#eeeeee"
                }
                ToolSeparator {
                    orientation: Qt.Horizontal
                    Layout.fillWidth: true
                    bottomPadding: 0
                }
                ListView{
                    topMargin: 0
                    bottomMargin: 0
                    Layout.preferredWidth: 250
                    Layout.preferredHeight: 50
                    id: _sensorListView
                    clip: true
                    model: DeNovoViewer.sensorManager.cabinModel
                    delegate: sensorDelegate

                }
                Text {
                    topPadding: 0
                    text: "Battery"

                    Layout.preferredHeight: 10
                    font.family: "Segoe UI"
                    font.pixelSize: 16
                    color:"#eeeeee"
                }
                ToolSeparator {
                    orientation: Qt.Horizontal
                    Layout.fillWidth: true
                    bottomPadding: 0
                }
                ListView{
                    spacing: 2
                    Layout.fillWidth: true
                    Layout.preferredHeight: 90
                    id: _battery0ListView
                    clip: true
                    model: DeNovoViewer.sensorManager.battery0Model
                    delegate: sensorDelegate2

                }
                Text {
                    topPadding: 0
                    text: "KBest"

                    Layout.preferredHeight: 10
                    font.family: "Segoe UI"
                    font.pixelSize: 16
                    color:"#eeeeee"
                }
                ToolSeparator {
                    orientation: Qt.Horizontal
                    Layout.fillWidth: true
                    bottomPadding: 0
                }
                ListView{
                    spacing: 2
                    Layout.fillWidth: true
                    Layout.preferredHeight: 90
                    id: _KbestView
                    clip: true
                    model: DeNovoViewer.sensorManager.kbestModel
                    delegate: sensorDelegate2

                }
                Text {
                    topPadding: 0
                    text: "ARDUSIMPLE"

                    Layout.preferredHeight: 10
                    font.family: "Segoe UI"
                    font.pixelSize: 16
                    color:"#eeeeee"
                }
                ToolSeparator {
                    orientation: Qt.Horizontal
                    Layout.fillWidth: true
                    bottomPadding: 0
                }
                ListView{
                    spacing: 2
                    Layout.fillWidth: true
                    Layout.preferredHeight: 110
                    id: _gpsModelView
                    clip: true
                    model: DeNovoViewer.sensorManager.ardusimpleModel
                    delegate: sensorDelegate2

                }
                Item{
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }
            }



        }







    }

}
