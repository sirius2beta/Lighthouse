import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

// 【關鍵】：把 Button 換成 AbstractButton，徹底擺脫系統樣式的糾纏！
AbstractButton {
    id: control

    property string iconSource: ""
    property int iconSize: 24

    // 直接鎖死元件本身的物理長寬
    width: 45
    height: 45
    implicitWidth: 45
    implicitHeight: 45

    // 鎖死 Layout 的長寬
    Layout.preferredWidth: 45
    Layout.maximumWidth: 45
    Layout.minimumWidth: 10
    Layout.preferredHeight: 45
    Layout.maximumHeight: 45
    Layout.minimumHeight: 10
    Layout.alignment: Qt.AlignVCenter

    background: Rectangle {
        // 【關鍵】：讓背景絕對貼齊元件邊緣，不留一絲縫隙
        anchors.fill: parent
        radius: 0
        border.color: control.palette.dark
        border.width: 1

        color: {
            let baseColor = control.palette.button
            if (control.down) return Qt.darker(baseColor, 1.2)
            if (control.hovered) return Qt.lighter(baseColor, 1.1)
            return baseColor
        }
        opacity: control.enabled ? 1.0 : 0.5
    }

    contentItem: Item {
        // 【關鍵】：讓內容容器也絕對貼齊
        anchors.fill: parent

        Image {
            anchors.centerIn: parent
            width: control.iconSize
            height: control.iconSize
            source: control.iconSource
            fillMode: Image.PreserveAspectFit
            opacity: control.enabled ? 1.0 : 0.5
            mipmap: true
        }
    }
}
