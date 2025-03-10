import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: root
    width: 200
    height: 350
    signal homePage()

    Rectangle{
        id: rectangle
        anchors.fill: parent
        color: "#1a1a1c"
        border.color: "#565656"

        Text {
            id: title
            x: 8
            y: 8
            color: "#ffffff"
            text: qsTr("Video Control")
            font.pixelSize: 12
            font.family: Constants.font.family
        }

        ListView {
            id: listView
            anchors.top: title.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: 5
            spacing: 5

            model: ListModel {
                ListElement {
                    name: "video0"
                    port: "5201"
                    colorCode: "red"
                }

                ListElement {
                    name: "video1"
                    port: "5202"
                    colorCode: "green"
                }

                ListElement {
                    name: "video2"
                    port: "5203"
                    colorCode: "blue"
                }

                ListElement {
                    name: "video3"
                    port: "5204"
                    colorCode: "white"
                }
            }
            delegate: Rectangle {
                property int quality: 0
                width: 180
                height: 60
                color: "#00ffffff"
                anchors.horizontalCenter: parent.horizontalCenter
                Column{
                    Row{
                        id: row
                        Rectangle{
                            width: 10
                            height: 10
                            anchors.verticalCenter: parent.verticalCenter


                        }

                        Text {
                            width: 100
                            color: "#ffffff"
                            text: name
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        Text{
                            width: 100
                            color: "#ffffff"
                            text: port
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                    Row{
                        spacing: 2

                        Rectangle{
                            width: 40
                            height: 25
                            color: quality==2?"#209FBC":"#00ffffff"
                            border.color: "#999999"
                            Text{
                                anchors.fill: parent
                                color: quality==2?"#ffffff":"#999999"
                                text: "High"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                font.pixelSize: 12
                                font.family: Constants.font.family
                            }
                            MouseArea{
                                anchors.fill: parent
                                onClicked: {
                                    quality = 2;
                                }
                            }

                        }
                        Rectangle{
                            width: 40
                            height: 25
                            color: quality==1?"#209FBC":"#00ffffff"
                            border.color: "#999999"
                            Text{
                                anchors.fill: parent
                                color: quality==1?"#ffffff":"#999999"
                                text: "Mid"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                font.family: Constants.font.family
                                font.pointSize: 12
                            }
                            MouseArea{
                                anchors.fill: parent
                                onClicked: {
                                    quality = 1;
                                }
                            }
                        }
                        Rectangle{
                            width: 40
                            height: 25
                            color: quality==0?"#209FBC":"#00ffffff"
                            border.color: "#999999"
                            Text{
                                anchors.fill: parent
                                color: quality==0?"#ffffff":"#999999"
                                text: "Low"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                font.family: Constants.font.family
                                font.pointSize: 12
                            }
                            MouseArea{
                                anchors.fill: parent
                                onClicked: {
                                    quality = 0;
                                }
                            }
                        }
                    }


                }



            }


        }


    }
    DNButton{
        x: 111
        y: 307
        text:"home"
        onClicked: {
            root.homePage()
        }
    }

}
