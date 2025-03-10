import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id:root
    width: 200
    height: 280

    property bool enableUpper: true
    property bool enableLower: true
    property real upperValue: 0
    property real lowerValue: 0
    property bool alarmOn: true

    signal save()


    Column {
        id: column
        anchors.fill: parent
        anchors.margins: 20
        spacing: 5
        Text{
            height:30
            color: "#ffffff"
            width:parent.width
            text:"Alarm settings"
            font.family: Constants.font
            font.pixelSize: 18
        }

        Row {
            id: row
            width:parent.width
            height: 50
            spacing: 5

            Text{
                color: "#ffffff"
                text: "Lower Limit"
                font.family: Constants.font
                font.pixelSize: 18
            }
            Rectangle{
                width: 60
                height: 30
                color: enableLower?"#000000":"#666666"
                TextInput {
                    id: vLLTextInput
                    anchors.fill: parent
                    color: "#ffffff"
                    text: lowerValue
                    font.family: Constants.font
                    font.pixelSize: 16
                    horizontalAlignment: Text.AlignRight
                    selectByMouse: true
                    enabled: enableLower

                }
            }


        }

        Row {
            id: row2
            width:parent.width
            height: 50
            spacing: 5
            Text{
                color: "#ffffff"
                text: "Upper Limit"
                font.family: Constants.font
                font.pixelSize: 18
            }
            Rectangle{
                width: 60
                height: 30
                color: enableUpper?"#000000":"#666666"
                TextInput {
                    id: textInput2
                    anchors.fill: parent
                    color: "#ffffff"
                    text: upperValue
                    font.family: Constants.font
                    font.pixelSize: 16
                    horizontalAlignment: Text.AlignRight
                    selectByMouse: true
                    enabled: enableUpper

                }
            }


        }
        Switch {
            id: switch1
            font.family: Constants.font
            text: qsTr("Sound")
            anchors.right: parent.right
            checked: alarmOn
            onCheckedChanged: {
                alarmOn = checked
            }

        }
        Button {
            id: button

            text: qsTr("Save")
            anchors.right: parent.right
            font.family: Constants.font
            onClicked: {
                upperValue = parseFloat(textInput2.text)
                lowerValue = parseFloat(vLLTextInput.text)
                root.save()
            }
        }

    }





}
