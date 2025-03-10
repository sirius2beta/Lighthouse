import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Layouts 1.15
import QtPositioning 5.15
import QtLocation 5.15

import DeNovoViewer 1.0
import DeNovoViewer.Boat 1.0
import DeNovoViewer.Display 1.0

Window {
    id: dnMainWindow
    width: 1280
    height: 720
    visible: true
    title: DeNovoViewer.programName
    //visibility: Window.FullScreen

    Material.theme: Material.Dark
    Material.accent: Material.Purple


    Rectangle{
        color: "#020202"
        anchors.fill:parent
    }

    DNFlyView{
        id: _centerVideoView
        anchors.bottom: statusBar.top
        anchors.top: parent.top
        anchors.left: _leftTool.right
        anchors.right: _subVideoView.left
        anchors.margins: 15

    }

    Rectangle{
        id: _leftTool

        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: statusBar.top
        color: "#090910"
        width:70
        ColumnLayout{
            anchors.fill:parent
            anchors.margins: 5
            Button {
                Layout.fillWidth: true
                Layout.preferredHeight: 70
                contentItem: Image{
                    fillMode: Image.PreserveAspectFit
                    id: _boatManagerIcon
                    source: "res/boatManager.png"
                }


            }
            Image {
                Layout.fillWidth: true
                Layout.preferredHeight: 80
                fillMode: Image.PreserveAspectFit
                id: _sensorManagerIcon
                source: "res/sensorManager.png"
            }
            Item {
                Layout.fillHeight: true
            }
        }
    }

    Rectangle{
        id: statusBar
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height:30
        border.color: "#333333"
        border.width: 1
        color: "#090910"
    }

    SubVideoView{
        id: _subVideoView
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: statusBar.top
        anchors.margins: 15
        width: 400

    }

}
