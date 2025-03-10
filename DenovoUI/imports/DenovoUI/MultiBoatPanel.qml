import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: root
    width: 200
    height: 300

    Rectangle{
        id: rectangle
        color: "#1a1a1c"
        anchors.fill: parent

        ListModel {
            id: boatList
                ListElement {
                    boatname: "Red9"
                    PIP: "192.168.0.10"
                    SIP: "100.105.122.84"
                    PIPConnected: false
                    SIPConnected: false
                    colorCode: "red"
                }

                ListElement {
                    boatname: "Green"
                    PIP: "192.168.0.10"

                    SIP: "100.105.122.84"
                    PIPConnected: false
                    SIPConnected: false
                    colorCode: "green"
                }
            }

        ListView {
            id: listView
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: addButton.top
            anchors.leftMargin: 10
            anchors.rightMargin: 10
            anchors.topMargin: 20
            anchors.bottomMargin: 10
            model: boatList
            delegate: Rectangle{
                width: parent.width
                height: 80
                color: "#303030"
                border.color: "#909090"

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 4
                    anchors.rightMargin: 4
                    anchors.topMargin: 0
                    Row{
                        id: row1
                        spacing:5
                        Column{
                            leftPadding: 5
                            spacing: 3
                            Text {
                                width: 100
                                color: "#ffffff"
                                font.family: Constants.font.family
                                text: boatname
                                font.pointSize: 14
                            }
                            Row{
                                id: row
                                spacing: 5
                                Rectangle{
                                    width: 5
                                    height: 5
                                    anchors.verticalCenter: parent.verticalCenter

                                }

                                Text {
                                    width: 100
                                    color: "#ffffff"
                                    font.family: Constants.font.family
                                    text: PIP
                                }
                            }

                            Row{
                                id: row2
                                spacing: 5
                                Rectangle{
                                    width: 5
                                    height: 5
                                    anchors.verticalCenter: parent.verticalCenter

                                }

                                Text {
                                    width: 100
                                    color: "#ffffff"
                                    font.family: Constants.font.family
                                    text: SIP
                                }
                            }


                        }
                    }
                    Column{
                        spacing: -9
                        DNButton {
                            text: "Del"
                            height: 35
                            width:30
                            fontSize: 9
                            bgColor: "#990000"
                        }
                        DNButton {
                            text: "A"
                            fontSize: 9
                            height: 35
                            width:30
                            bgColor: "#009900"
                        }
                        DNButton {
                            showIcon: true
                            text: ""
                            height: 35
                            width:30
                            iconSource: "images/settings.svg"
                        }
                    }


                }

            }
        }

        DNButton {
            id: addButton
            showIcon: true
            text: ""
            y: 286
            height: 30
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.leftMargin: 5
            anchors.rightMargin: 5
            anchors.bottomMargin: 5
            icon.cache: false
            iconSource: "images/add.svg"
        }
    }





}
