import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Layouts 1.15
import DeNovoViewer 1.0
import DeNovoViewer.Boat 1.0

DNPopup {
    id:root
    padding: 10
    ColumnLayout{
        anchors.fill: parent
        Rectangle{

            height: 30
            color: '#0c0c0c'
            Text{
                text: ' Edit boat'
                font.family: "Segoe UI"
                font.pointSize: 10
                color: "white"
            }
        }

        RowLayout{
            Text{
                leftPadding: 10
                text: 'Primary IP'
                font.family: "Segoe UI"
                font.pointSize: 10
                color: "white"
            }

            TextField {
                id: pipEdit
                selectByMouse: true
                text: DeNovoViewer.boatManager.getBoatbyIndex(boatListView.currentIndex).PIP
                font.family: "Segoe UI"
            }
        }

        RowLayout{
            Text{
                leftPadding: 10
                text: 'Secondary IP'
                font.family: "Segoe UI"
                font.pointSize: 10
                color: "white"
            }
            TextField {
                id: sipEdit
                selectByMouse: true
                text: DeNovoViewer.boatManager.getBoatbyIndex(boatListView.currentIndex).SIP
                font.family: "Segoe UI"
            }
        }
        RowLayout{
            Item{
                Layout.fillWidth: true
            }

            Button{
                text: 'cancel'
                font.family: "Segoe UI"
                onClicked: {
                    root.close()
                }
            }
            Button{
                text: 'accept'
                font.family: "Segoe UI"
                onClicked: {
                    root.close()
                }
            }
        }
    }
}
