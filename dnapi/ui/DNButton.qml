

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

    property bool showIcon: false
    property int fontSize: 12
    property string iconSource: ""
    property string bgColor: "#444444"

    width: 70
    height: 35

    implicitWidth: Math.max(
                       buttonBackground ? buttonBackground.implicitWidth : 0,
                       textItem.implicitWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(
                        buttonBackground ? buttonBackground.implicitHeight : 0,
                        textItem.implicitHeight + topPadding + bottomPadding)
    leftPadding: 4
    rightPadding: 4

    text: "My Button"
    icon.source: iconSource

    background: buttonBackground
    Rectangle {
        id: buttonBackground
        color: bgColor
        implicitWidth: 100
        implicitHeight: 40
        opacity: enabled ? 1 : 0.3
        radius: 2
        border.color: "#aaaaaa"
    }
    Image {
        visible: showIcon
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.topMargin:10
        anchors.bottomMargin:10
        source: icon.source
        anchors.horizontalCenter: parent.horizontalCenter
        fillMode: Image.PreserveAspectFit
    }

    contentItem: textItem
    Text {
        anchors.fill: parent
        id: textItem
        text: control.text
        font.family: Constants.font.family
        font.pointSize: fontSize
        opacity: enabled ? 1.0 : 0.3
        color: "#ffffff"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    states: [
        State {
            name: "normal"
            when: !control.down

            PropertyChanges {
                target: buttonBackground
                color: bgColor
                border.color: "#aaaaaa"
            }

            PropertyChanges {
                target: textItem
                color: "#ffffff"
            }
        },
        State {
            name: "down"
            when: control.down
            PropertyChanges {
                target: textItem
                color: "#ffffff"
            }

            PropertyChanges {
                target: buttonBackground
                color: "#444444"
                border.color: "#999999"
            }
        }
    ]
}
