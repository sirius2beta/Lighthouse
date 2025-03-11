import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: root
    implicitWidth: 1280
    height: 90
    FontLoader { source: "font/Roboto-Black.ttf" }
    FontLoader { source: "font/Roboto-Regular.ttf" }
    Rectangle{
        anchors.fill: parent
        color: "#000000"
        border.width: 0

    }
    Rectangle{
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        color: "#333333"
        border.width: 0
        height:11

    }

    Row{
        anchors.fill: parent
        spacing: 15
        anchors.leftMargin: 10
        Rectangle{

            width:220
            height:90
            color: "#333333"
            radius:8
            Column{
                anchors.fill: parent
                spacing: 4
                anchors.leftMargin: 15
                anchors.topMargin: 10
                Row{
                    spacing: 20
                    Text {
                        color: "#ffffff"
                        text: qsTr("BOAT")
                        font.family: "roboto"
                        font.pixelSize: 18
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                    }
                    Text {
                        color: "#ffffff"
                        text: qsTr("text")
                        font.family: "roboto"
                        font.pixelSize: 18
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                    }
                }


                Row{
                    spacing: 15

                    Rectangle{
                        width:44
                        height:44
                        color: "#000000"
                        radius:22
                        Image {
                            id: winch
                            anchors.margins: 5
                            anchors.fill:parent
                            source: "images/link.png"
                            anchors.horizontalCenter: parent.horizontalCenter
                            fillMode: Image.PreserveAspectFit
                        }
                    }
                    Column{
                        spacing: 3
                        Row{
                            spacing: 10
                            Text {
                                color: "#00ffff"
                                text: "P"
                                font.family: "roboto black"
                                font.pixelSize: 16
                                horizontalAlignment: Text.AlignHCenter
                                wrapMode: Text.WordWrap
                            }
                            Text {
                                color: "#ffffff"
                                text: "192.168.0.10"
                                font.family: "roboto"
                                font.pixelSize: 16
                                horizontalAlignment: Text.AlignHCenter
                                wrapMode: Text.WordWrap
                            }
                        }
                        Row{
                            spacing: 10
                            Text {
                                color: "#ffffff"
                                text: "S"
                                font.family: "roboto black"
                                font.pixelSize: 16
                                horizontalAlignment: Text.AlignHCenter
                                wrapMode: Text.WordWrap
                            }
                            Text {
                                color: "#ffffff"
                                text: "100.152.0.10"
                                font.family: "roboto"
                                font.pixelSize: 16
                                horizontalAlignment: Text.AlignHCenter
                                wrapMode: Text.WordWrap
                            }
                        }
                    }
                }
            }

        }

        Rectangle{

            width:220
            height:90
            color: "#333333"
            radius:8
            Column{
                anchors.fill: parent
                spacing: 4
                anchors.leftMargin: 15
                anchors.topMargin: 10
                Row{
                    spacing: 20
                    Text {
                        color: "#ffffff"
                        text: qsTr("Video")
                        font.family: "roboto"
                        font.pixelSize: 18
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                    }
                    Text {
                        color: "#ffffff"
                        text: qsTr("text")
                        font.family: "roboto"
                        font.pixelSize: 18
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                    }
                }


                Row{
                    spacing: 15

                    Rectangle{
                        width:44
                        height:44
                        color: "#000000"
                        radius:22
                        Image {
                            anchors.margins: 5
                            anchors.fill:parent
                            source: "images/play_arrow.png"
                            anchors.horizontalCenter: parent.horizontalCenter
                            fillMode: Image.PreserveAspectFit
                        }
                    }
                    Column{
                        spacing: 3

                            Text {
                                color: "#00ffff"
                                text: "640 x 480"
                                font.family: "roboto"
                                font.pixelSize: 16
                                horizontalAlignment: Text.AlignHCenter
                                wrapMode: Text.WordWrap
                            }

                            Text {
                                color: "#ffffff"
                                text: "5701"
                                font.family: "roboto"
                                font.pixelSize: 16
                                horizontalAlignment: Text.AlignHCenter
                                wrapMode: Text.WordWrap
                            }


                    }
                }
            }

        }
    }
}
