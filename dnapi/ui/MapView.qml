import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtPositioning
import QtLocation
import QtQuick.Layouts

import DeNovoViewer 1.0
import DeNovoViewer.Boat 1.0


Item {
    id: _root
    property Item pipView
    property Item pipState: videoPipState
    property bool isFull: videoPipState.state === videoPipState.fullState
    property string videoObjectName //required, bind to C++ gstreamer g_object_set
    property int display_no: 0
    property int h_resolution: 480
    property int w_resolution: 640
    property real ratio: w_resolution/h_resolution
    property int lastRenderedId: -1

    clip: true

    PipState {
        id:         videoPipState
        pipView:    _root.pipView
        isDark:     true
    }

    Material.theme: Material.Dark
    Material.accent: Material.Purple
    property bool controlHide: true
    property int _index: 0
    property VideoItem videoItem

    Plugin {
            id: archPlugin
            name: "osm"

            PluginParameter {
                name: "osm.mapping.custom.host"
                value: "http://127.0.0.1:8081/tile/"
            }
            // 2. 偽裝成 QGC 或瀏覽器以確保穩定連線
            PluginParameter { name: "osm.useragent"; value: "Lighthouse_Proxy" }
            PluginParameter { name: "osm.mapping.providersrepository.disabled"; value: "true" }
            PluginParameter { name: "osm.mapping.providers.visible"; value: "false" }
            PluginParameter { name: "osm.mapping.cache.directory"; value: "" }
            PluginParameter { name: "osm.mapping.cache.disk.size"; value: "0" }
            PluginParameter { name: "osm.mapping.offline.allow"; value: "false" }
    }
    ListModel {
        id: trajectoryModel
    }
    Map {
        id: mmap
        anchors.fill: parent
        plugin: archPlugin
        //activeMapType: supportedMapTypes[3] // Cycle map provided by Thunderforest

        // 💡 這是用來繪製軌跡點的工廠
        MapItemView {
                    id: trajectoryRenderer
                    model: trajectoryModel // 綁定到上面的 ListModel

                    delegate: MapQuickItem {
                        coordinate: QtPositioning.coordinate(lat, lon)

                        anchorPoint.x: 4
                        anchorPoint.y: 4

                        sourceItem: Rectangle {
                            width: 8
                            height: 8
                            radius: 4
                            color: colorRampEngine.getColor(
                                       value, // 直接寫 value
                                       parseFloat(minField.text),
                                       parseFloat(maxField.text),
                                       colorRampCombo.currentIndex)
                        }
                    }





                }
            // --- 關鍵除錯區 ---
            onActiveMapTypeChanged: {
                console.log("當前使用的地圖名稱: " + activeMapType.name)
                console.log("當前使用的樣式編號: " + activeMapType.style)
            }

            Component.onCompleted: {
                // 強制搜尋並切換到自定義類型
                for (var i = 0; i < supportedMapTypes.length; i++) {
                    if (supportedMapTypes[i].name.indexOf("Custom") !== -1) {
                        activeMapType = supportedMapTypes[i]
                        console.log(">>> 已強制切換至 Custom URL Map (Index: " + i + ")")
                        return
                    }
                }
                console.log("找不到 Custom URL Map，請檢查 Plugin 參數！")
            }
        center: h_point
        zoomLevel: 10

        // 建議同時設定限制，防止縮放到不見或報錯
        minimumZoomLevel: 3
        maximumZoomLevel: 20
        copyrightsVisible: false
        MapQuickItem{
            id: h_point
            zoomLevel: parent.zoomLevel
            coordinate: QtPositioning.coordinate(25, 121.3)
            anchorPoint: Qt.point(sourceItem.width/2, sourceItem.height/2)
            sourceItem: Image{
                width:50
                height:50
                source: "qrc:/res/home_pin.png"
                fillMode: Image.Stretch
            }
        }
        MapQuickItem{
            id: b_point
            zoomLevel: parent.zoomLevel
            //coordinate: lat?QtPositioning.coordinate(lat,lon): QtPositioning.coordinate(25, 121.3)
            coordinate: QtPositioning.coordinate(0, 0)
            anchorPoint: Qt.point(sourceItem.width/2, sourceItem.height/2)
            opacity: 0.2
            sourceItem: Image{
                width:30
                height:30
                source: "qrc:/res/navigation.png"
                fillMode: Image.Stretch
                transform: Rotation{origin.x:25; origin.y:25; angle:parseInt(DeNovoViewer.sensorManager.mav1Model.get(4).displayValue)/100}
            }
            onCoordinateChanged: {
                    mmap.center = coordinate
            }

        }
        PinchHandler {
            id:     pinchHandler
            target: null

            property var pinchStartCentroid

            onActiveChanged: {
                if (active) {
                    pinchStartCentroid = _map.toCoordinate(pinchHandler.centroid.position, false)
                }
            }
            onScaleChanged: (delta) => {
                let newZoomLevel = Math.max(_map.zoomLevel + Math.log2(delta), 0)
                mmap.zoomLevel = newZoomLevel
                mmap.alignCoordinateToPoint(pinchStartCentroid, pinchHandler.centroid.position)
            }
        }
        WheelHandler {
            // workaround for QTBUG-87646 / QTBUG-112394 / QTBUG-112432:
            // Magic Mouse pretends to be a trackpad but doesn't work with PinchHandler
            // and we don't yet distinguish mice and trackpads on Wayland either
            acceptedDevices:    Qt.platform.pluginName === "cocoa" || Qt.platform.pluginName === "wayland" ?
                                    PointerDevice.Mouse | PointerDevice.TouchPad : PointerDevice.Mouse
            rotationScale:      1 / 120
            property:           "zoomLevel"


        }
        signal mapPanStart()
        signal mapPanStop()
        signal mapClicked(var position)
        MultiPointTouchArea {
                anchors.fill: parent
                maximumTouchPoints: 1
                mouseEnabled: true

                property bool dragActive: false
                property real lastMouseX
                property real lastMouseY

                onPressed: (touchPoints) => {
                    lastMouseX = touchPoints[0].x
                    lastMouseY = touchPoints[0].y
                }

                onGestureStarted: (gesture) => {
                    dragActive = true
                    gesture.grab()
                    mmap.mapPanStart()
                }

                onUpdated: (touchPoints) => {
                    if (dragActive) {
                        let deltaX = touchPoints[0].x - lastMouseX
                        let deltaY = touchPoints[0].y - lastMouseY
                        if (Math.abs(deltaX) >= 1.0 || Math.abs(deltaY) >= 1.0) {
                            mmap.pan(lastMouseX - touchPoints[0].x, lastMouseY - touchPoints[0].y)
                            lastMouseX = touchPoints[0].x
                            lastMouseY = touchPoints[0].y
                        }
                    }
                }

                onReleased: (touchPoints) => {
                    if (dragActive) {
                        mmap.pan(lastMouseX - touchPoints[0].x, lastMouseY - touchPoints[0].y)
                        dragActive = false
                        mmap.mapPanStop()
                    } else {
                        mmap.mapClicked(Qt.point(touchPoints[0].x, touchPoints[0].y))
                    }
                }
            }
        onZoomLevelChanged: {
            if (mmap.zoomLevel > 21) mmap.zoomLevel = 21
            if (mmap.zoomLevel < 3) mmap.zoomLevel = 3
        }
    }
    Rectangle{
        id: controlBar
        width:50*3+10+2*2
        height:60
        anchors.margins: 5
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        color:"#191919"
        radius:5
        visible: isFull
        RowLayout{
            anchors.fill:parent
            spacing: 2
            Button {
                Layout.alignment: Qt.AlignVCenter
                id: menu_button
                text: ""
                property bool activate: false
                background: Rectangle {
                    implicitWidth: 50
                    implicitHeight: 50
                    color: parent.down ? "#99555555" : "#00000000"
                    radius: 4
                    Rectangle{
                        anchors.fill: parent
                        radius:4
                        anchors.margins: 5
                        color:"#00999900"
                    }

                    Image{
                        id: img
                        anchors.margins: 5
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                        fillMode: Image.PreserveAspectFit
                        source: "qrc:/res/menu.svg"
                    }

                }
                onClicked: {
                    activate = !activate // 切換按鈕的活躍狀態
                }
            }
            Button {
                Layout.alignment: Qt.AlignVCenter
                id: follow_boat_button
                text: ""
                property bool activate: false
                background: Rectangle {
                    implicitWidth: 50
                    implicitHeight: 50
                    color: parent.down ? "#99555555" : "#00000000"
                    radius: 4
                    Rectangle{
                        anchors.fill: parent
                        radius:4
                        anchors.margins: 5
                        color:"#00999900"
                    }

                    Image{
                        anchors.margins: 5
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                        fillMode: Image.PreserveAspectFit
                        source: "qrc:/res/boat.svg"
                    }

                }
                onClicked: {
                    //openControlView()
                }
            }
            Button {
                Layout.alignment: Qt.AlignVCenter
                id: focus_home_button
                text: ""
                property bool activate: false
                background: Rectangle {
                    implicitWidth: 50
                    implicitHeight: 50
                    color: parent.down ? "#99555555" : "#00000000"
                    radius: 4
                    Rectangle{
                        anchors.fill: parent
                        radius:4
                        anchors.margins: 5
                        color:"#00999900"
                    }

                    Image{
                        anchors.margins: 5
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                        fillMode: Image.PreserveAspectFit
                        source: "qrc:/res/home.svg"
                    }

                }
                onClicked: {
                    //openControlView()
                }
            }

        }
    }
    // 🎨 色彩漸層計算機
        QtObject {
            id: colorRampEngine

            function getColor(value, min, max, rampType) {
                // 1. 防呆與範圍限制，計算比例 (0.0 ~ 1.0)
                if (min >= max) return "#808080" // 避免除以零
                var ratio = (value - min) / (max - min)
                if (ratio < 0) ratio = 0
                if (ratio > 1) ratio = 1

                // 2. 根據選擇的 Color Ramp 回傳顏色
                // 0: Rainbow (彩虹：藍 -> 青 -> 綠 -> 黃 -> 紅)
                if (rampType === 0) {
                    // Hue 從 240(藍色) 到 0(紅色)
                    var h = (1.0 - ratio) * 240.0 / 360.0
                    return Qt.hsla(h, 1.0, 0.5, 0.8) // 0.8 是透明度
                }
                // 1: Heatmap (熱力：黑 -> 深紅 -> 橘 -> 黃 -> 白)
                else if (rampType === 1) {
                    // 利用 HSL 亮度控制
                    var l = ratio * 0.8 + 0.1
                    var h2 = (1.0 - ratio) * 60.0 / 360.0
                    return Qt.hsla(h2, 1.0, l, 0.8)
                }
                // 2: Monochrome (單色：透明深紫 -> 不透明亮紫)
                else {
                    return Qt.rgba(0.6, 0.2, 0.8, ratio * 0.8 + 0.2)
                }
            }
        }
    // --- 地圖資料可視化設定面板 ---

        Rectangle {
            id: map_setting
            width: 260
            height: 350
            // 停靠在控制列的上方
            anchors.bottom: controlBar.top
            anchors.bottomMargin: 10
            anchors.horizontalCenter: parent.horizontalCenter

            color: "#252528"
            radius: 8
            border.color: "#3a3a3c"
            border.width: 1

            // 💡 綁定到選單按鈕的狀態
            visible: menu_button.activate && isFull

            // 防止滑鼠點擊穿透到下方的地圖
            MouseArea { anchors.fill: parent }

            // 判斷資料庫是否已經有開啟檔案 (假設利用 dbName 判斷，可依據你的 C++ 邏輯微調)
            property bool isDbReady: DeNovoViewer.marineDatabase &&
                                     DeNovoViewer.marineDatabase.dbName !== "" &&
                                     DeNovoViewer.marineDatabase.dbName !== "marine.db"
            function refreshMapData() {
                        // 清空舊點
                        trajectoryModel.clear()
                        _root.lastRenderedId = -1

                        if (!isDbReady) return

                        var rawData = DeNovoViewer.marineDatabase.fetchTrajectoryData(dataFieldCombo.currentIndex)
                        console.log(">>> QML 準備畫圖，接收到點數: " + rawData.length)
                        // 💡 將 C++ 傳來的大量陣列，一筆一筆快速塞進動態模型中
                        for (var i = 0; i < rawData.length; i++) {
                            trajectoryModel.append(rawData[i])
                        }


                        // 記錄最後一筆的 ID，方便接續即時繪圖
                        if (rawData.length > 0) {
                            _root.lastRenderedId = rawData[rawData.length - 1].id
                        }
                    }
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 10

                // ==========================================
                // 1. 開啟/關閉軌跡繪圖 (搭配未連線警告)
                // ==========================================
                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: "啟用歷史數值渲染"
                        color: "#FFFFFF"
                        font.bold: true
                        font.pointSize: 10
                        Layout.fillWidth: true
                    }
                    Switch {
                        id: renderSwitch
                        checked: false
                        enabled: map_setting.isDbReady // 💡 DB 沒開就不准打開開關
                        onCheckedChanged: {
                            if (checked) {
                                map_setting.refreshMapData() // 開啟時抓資料
                            } else {
                                trajectoryRenderer.model = [] // 關閉時清空地圖上的點
                            }
                        }
                    }
                }

                // ⚠️ 警告提示：當資料庫未準備好時顯示
                Text {
                    text: "⚠️ 請先至日誌系統開啟或選取 DB 檔案"
                    color: "#E74C3C"
                    font.pointSize: 8
                    visible: !map_setting.isDbReady
                    Layout.topMargin: -10
                }

                // 分隔線
                Rectangle { Layout.fillWidth: true; height: 1; color: "#3a3a3c" }

                // 以下設定，只有在 Switch 打開時才允許操作 (防呆)
                ColumnLayout {
                    Layout.fillWidth: true
                    enabled: renderSwitch.checked
                    opacity: renderSwitch.checked ? 1.0 : 0.4 // 視覺上的 Disable 效果
                    spacing: 8

                    // ==========================================
                    // 2. 代表點顏色的欄位 (Data Source)
                    // ==========================================
                    Text { text: "數值來源 (Data Field):"; color: "#B3B3B3"; font.pointSize: 9 }
                    ComboBox {
                        id: dataFieldCombo
                        Layout.fillWidth: true
                        model: ["None (無)", "Temperature (溫度)", "Depth (水深)", "pH (酸鹼度)"]

                        // 💡 當更改來源時，重新抓資料
                        onCurrentIndexChanged: {
                            if (renderSwitch.checked) refreshMapData()
                        }
                    }

                    // ==========================================
                    // 3. Color Ramp 漸層配色
                    // ==========================================
                    Text { text: "漸層配色 (Color Ramp):"; color: "#B3B3B3"; font.pointSize: 9 }
                    ComboBox {
                        id: colorRampCombo
                        Layout.fillWidth: true
                        model: ["Rainbow (彩虹漸層)", "Heatmap (熱力紅黃)", "Monochrome (單色深淺)"]
                    }

                    // ==========================================
                    // 4. 數值範圍 (Min ~ Max)
                    // ==========================================
                    Text { text: "色彩對應範圍 (Min ~ Max):"; color: "#B3B3B3"; font.pointSize: 9 }
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        TextField {
                            id: minField
                            Layout.fillWidth: true
                            placeholderText: "Min"
                            text: "0.0"
                            // 限制只能輸入小數或整數
                            validator: DoubleValidator { bottom: -10000; top: 10000; decimals: 2 }
                            color: "#FFFFFF"
                        }
                        Text { text: "~"; color: "#8A8A8F"; font.bold: true }
                        TextField {
                            id: maxField
                            Layout.fillWidth: true
                            placeholderText: "Max"
                            text: "100.0"
                            validator: DoubleValidator { bottom: -10000; top: 10000; decimals: 2 }
                            color: "#FFFFFF"
                        }
                    }

                }

                // 彈性留白撐開佈局
                Item { Layout.fillHeight: true }

            }
        }

        Connections {
                target: DeNovoViewer.marineDatabase
                // ...

                // 🌟 當 C++ 成功寫入一筆資料到 SQLite 時觸發！
                function onDataInsertedSuccessfully() {

                    // 如果軌跡渲染開關有打開，且有選擇要畫的數值
                    if (renderSwitch.checked && dataFieldCombo.currentIndex !== 0) {

                        // 向 C++ 請求最新寫入的那一筆點
                        var newPt = DeNovoViewer.marineDatabase.fetchLatestPoint(dataFieldCombo.currentIndex)

                        // 💡 降頻與防呆邏輯：
                        // 1. 確保這筆資料的 id 是 5 的倍數 (對應你的 1/5 抽樣率)
                        // 2. 確保沒有重複畫 (newPt.id !== lastRenderedId)
                        if (newPt.id !== -1 && newPt.id % 5 === 0 && newPt.id !== _root.lastRenderedId) {

                            _root.lastRenderedId = newPt.id

                            // 🚀 核心：直接把新點 Append 到地圖上，完全不影響舊的點！
                            trajectoryModel.append(newPt)
                        }
                    }
                }
}
}
