import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: root
    property real value: 0
    property real increment: 100
    signal valueChange()

    Rectangle{
        id:leftbtn
        color: "#555555"
        width:60
        height:60
        radius:30
        Image {
            anchors.fill:parent
            anchors.margins: 10
            source: "images/down.png"
            fillMode: Image.PreserveAspectFit
        }
        MouseArea{
            anchors.fill: parent
            onPressed: {
                leftbtn.color = '#999999'
                root.value-=increment
            }
            onReleased:  {
                parent.color = "#555555"

            }
        }
    }
    Rectangle{
        id: display
        x: 30
        z:-1
        width: parent.width - leftbtn.width/2 - rightbtn.width/2
        height:60
        color: "#333333"
        Text{
            color: "#ffffff"
            text: root.value
            font.pixelSize: 18
            font.family: "Roboto"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            anchors.fill: parent
        }
    }

    Rectangle{
        id:rightbtn
        x: leftbtn.width+display.width-width
        color:leftbtn.color
        width:60
        height:60
        radius:30
        Image {
            anchors.fill:parent
            anchors.margins: 10
            source: "images/up.png"
            fillMode: Image.PreserveAspectFit
        }
        MouseArea{
            anchors.fill: parent
            onPressed: {

                rightbtn.color = '#999999'
                root.value+=increment
            }
            onReleased:  {
                rightbtn.color = "#555555"

            }
        }
    }


}
