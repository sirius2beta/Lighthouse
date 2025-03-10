import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: root
    width: 32
    height: 100

    property int percentage: 20
    property int yellowWarning: 40
    property int redWarning:20
    property bool noBattery: true

    Rectangle{
        anchors.fill: parent
        color: "#1a1a1c"

    }

    Text {
        id: text1
        color: "#ffffff"
        text: noBattery?"NB":percentage+" %"
        anchors.top: parent.top
        anchors.topMargin: 8
        font.pixelSize: 12
        font.family: Constants.font.family
        anchors.horizontalCenter: parent.horizontalCenter
    }



    Rectangle {
        visible: !noBattery
        id: rectangle2
        width: 15
        height: 54
        color: "#00ffffff"
        border.color: "#ffffff"
        anchors.top: parent.top
        anchors.topMargin: 33
        anchors.horizontalCenter: parent.horizontalCenter
        Rectangle {
            id: rectangle
            x: 2
            y: 2 + (parent.height-4)*(100-percentage)/100
            width: 11
            height: (parent.height-4)* percentage/100
            color: {
                if(percentage>yellowWarning)
                    return "#ffffff"
                else if(percentage>redWarning)
                    return "#ffd900"
                else
                    return "#ff0000"
            }

            clip: false
        }
    }

    Image {
        id: nobattery
        width: 17
        height: 54
        anchors.top: parent.top
        anchors.topMargin: 33
        source: "images/nobattery.png"
        anchors.horizontalCenter: parent.horizontalCenter
        fillMode: Image.Stretch
        visible: noBattery
    }
}
