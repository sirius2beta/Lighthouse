

/*
This is a UI file (.ui.qml) that is intended to be edited in Qt Design Studio only.
It is supposed to be strictly declarative and only uses a subset of QML. If you edit
this file manually, you might introduce QML code that is not supported by Qt Design Studio.
Check out https://doc.qt.io/qtcreator/creator-quick-ui-forms.html for details on .ui.qml files.
*/
import QtQuick 2.15
import QtQuick.Controls 2.15

Button {
    id: control
    width: 100
    height: 100

    implicitWidth: Math.max(
                       buttonBackground ? buttonBackground.implicitWidth : 0,
                       textItem.implicitWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(
                        buttonBackground ? buttonBackground.implicitHeight : 0,
                        textItem.implicitHeight + topPadding + bottomPadding)
    leftPadding: 4
    rightPadding: 4

    text: "My Button"
    highlighted: false
    property string imgsrc: ""

    background: buttonBackground
    Rectangle {
        id: buttonBackground
        x: 0
        y: -2
        color: "#00000000"
        anchors.fill: parent
        opacity: enabled ? 1 : 0.3
        radius: 2
        border.color: "#ffffff"
    }

    contentItem: textItem
    Text {
        id: textItem
        x: 4
        y: 45
        width: 72
        height: 29
        font.family: Constants.font.family
        text: ""

        opacity: enabled ? 1.0 : 0.3
        color: "#00047eff"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
    Text {
        id: text2
        y: 57
        width: 72
        height: 23
        text: control.text
        anchors.bottom: parent.bottom
        font.pixelSize: 16
        anchors.bottomMargin: 10
        font.family: Constants.font.family
        opacity: enabled ? 1.0 : 0.3
        color: "#ffffff"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        anchors.horizontalCenter: parent.horizontalCenter
    }

    Image {
        id: winch
        width: 50
        height: 50
        anchors.top: parent.top
        anchors.topMargin: 10
        source: imgsrc
        anchors.horizontalCenter: parent.horizontalCenter
        fillMode: Image.PreserveAspectFit
    }

    states: [
        State {
            name: "normal"
            when: !control.down

            PropertyChanges {
                target: buttonBackground
                color: "#00000000"
                border.color: "#ffffff"
            }

            PropertyChanges {
                target: text2
                color: "#ffffff"
            }
        },
        State {
            name: "down"
            when: control.down
            PropertyChanges {
                target: text2
                color: "#ffffff"
            }

            PropertyChanges {
                target: buttonBackground
                color: "#888888"
                border.color: "#00000000"
            }
        }
    ]
}
