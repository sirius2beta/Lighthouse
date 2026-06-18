import QtQuick 2.15
import QtQuick.Controls 2.15

Button {
    id: control

    // 預設的寬高，如果在外面使用時沒有特別指定寬高，就會用這個大小
    implicitWidth: 75
    implicitHeight: 45 // 稍微加高一點點，20 對於滑鼠點擊來說有時會太扁

    background: Rectangle {
        implicitWidth: control.implicitWidth
        implicitHeight: control.implicitHeight
        radius: 0 // 完全直角

        // 加上邊框讓質感更好 (可選)
        border.color: control.palette.dark
        border.width: 1

        color: {
            let baseColor = control.palette.button
            if (control.down) {
                return Qt.darker(baseColor, 1.2)
            } else if (control.hovered) {
                return Qt.lighter(baseColor, 1.1)
            } else {
                return baseColor
            }
        }

        // 如果按鈕被禁用 (enabled: false)，讓背景變透明/變淡，視覺提示更明顯
        opacity: control.enabled ? 1.0 : 0.5
    }

    // 確保文字也能跟隨主題，且置中對齊
    contentItem: Text {
        text: control.text
        color: control.palette.buttonText
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        // 字體如果被禁用也變淡
        opacity: control.enabled ? 1.0 : 0.5
    }
}
