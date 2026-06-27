import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtPositioning
import QtLocation
import QtQuick.Layouts
import QtQuick.Effects
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
    property bool follow_boat: true

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
                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: -10 // 魔法：把點擊判定範圍往外擴張 10px，讓點擊更容易命中

                        onClicked: {
                            // 呼叫浮動視窗，並把這個點的 Model 資料傳過去
                            // 使用 typeof 防呆，避免某些點缺少特定感測器資料導致 QML 報錯
                            pointInfoPanel.showInfo(
                                typeof lat !== 'undefined' ? lat : 0,
                                typeof lon !== 'undefined' ? lon : 0,
                                typeof temperature !== 'undefined' ? temperature : "N/A",
                                typeof depth !== 'undefined' ? depth : "N/A",
                                typeof dissolved_oxygen_concentration !== 'undefined' ? dissolved_oxygen_concentration : "N/A",
                                typeof seagrass_coverage_ratio !== 'undefined' ? seagrass_coverage_ratio : "N/A"
                            )
                        }
                    }
                }
            }
        }

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
        zoomLevel: 15

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
            coordinate: lat?QtPositioning.coordinate(lat,lon): QtPositioning.coordinate(23.642, 119.601)
            anchorPoint: Qt.point(sourceItem.width/2, sourceItem.height/2)
            opacity: 0.8
            sourceItem: Image{
                width:15
                height:15
                source: "qrc:/res/navigation.png"
                fillMode: Image.Stretch
                transform: Rotation{origin.x:25; origin.y:25; angle:parseInt(DeNovoViewer.sensorManager.mav1Model.get(4).displayValue)/100}
            }
            onCoordinateChanged: {
                if(follow_boat){
                    mmap.center = coordinate
                }
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
        // 接收 MultiPointTouchArea 傳來的點擊訊號
                onMapClicked: (position) => {
                    var closestIndex = -1;
                    var minPixelDist = 20; // 💡 魔法數字：點擊容錯半徑 (像素)。20px 代表就算沒有點得很準，只要在附近也能選中！

                    // 遍歷模型中所有的點
                    for (var i = 0; i < trajectoryModel.count; i++) {
                        var pt = trajectoryModel.get(i);
                        if (pt.lat !== undefined && pt.lon !== undefined) {
                            var coord = QtPositioning.coordinate(pt.lat, pt.lon);

                            // 將經緯度轉換為當前螢幕上的 X,Y 像素座標 (false 代表不要過濾畫面外的點)
                            var screenPos = mmap.fromCoordinate(coord, false);

                            // 畢氏定理：計算滑鼠點擊位置與資料點的直線像素距離
                            var dx = screenPos.x - position.x;
                            var dy = screenPos.y - position.y;
                            var dist = Math.sqrt(dx * dx + dy * dy);

                            // 找出距離最近，且在容錯範圍內的點
                            if (dist < minPixelDist) {
                                minPixelDist = dist;
                                closestIndex = i;
                            }
                        }
                    }

                    // 如果有找到點，就呼叫小視窗
                    if (closestIndex !== -1) {
                        var hitPt = trajectoryModel.get(closestIndex);
                        pointInfoPanel.showInfo(
                            hitPt.lat !== undefined ? hitPt.lat : 0,
                            hitPt.lon !== undefined ? hitPt.lon : 0,
                            hitPt.temperature !== undefined ? hitPt.temperature : "N/A",
                            hitPt.depth !== undefined ? hitPt.depth : "N/A",
                            hitPt.dissolved_oxygen_concentration !== undefined ? hitPt.dissolved_oxygen_concentration : "N/A",
                            hitPt.seagrass_coverage_ratio !== undefined ? hitPt.seagrass_coverage_ratio : "N/A",
                            hitPt.seagrass_image_name !== undefined ? hitPt.seagrass_image_name : ""
                        );
                    } else {
                        // 💡 體驗升級：如果點擊了地圖的空白處，自動隱藏小視窗
                        pointInfoPanel.visible = false;
                    }
                }
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
        width:50*4+10+2*3
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
                    follow_boat = follow_boat?false:true
                    if(follow_boat){
                        mmap.center = b_point.coordinate
                    }
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

            Button {
                Layout.alignment: Qt.AlignVCenter
                id: database_setting_button
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
                        source: "qrc:/res/database_sm.svg"
                    }

                }
                onClicked: {
                    activate = !activate // 切換按鈕的活躍狀態
                }
            }

        }
    }

    // 色彩漸層計算機
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

    // 地圖資料可視化設定面板
    Rectangle {
            id: map_setting
            width: 260
            height: 350
            // 停靠在控制列的上方
            anchors.bottom: controlBar.top
            anchors.right: controlBar.left
            anchors.bottomMargin: 10

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
                                     DeNovoViewer.marineDatabase.isConnected
            function refreshMapData() {
                // 清空舊點
                trajectoryModel.clear()
                _root.lastRenderedId = -1

                if (!isDbReady) return

                var rawData = DeNovoViewer.marineDatabase.fetchTrajectoryData(dataFieldCombo.currentIndex)

                // 初始化最大最小變數 (以第一筆資料為基準)
                if (rawData.length > 0) {
                    // 🌟 1. 萃取所有數值到一個純 JS 陣列中
                    var values = [];
                    for (var i = 0; i < rawData.length; i++) {
                        values.push(rawData[i].value);
                    }

                    // 🌟 2. 將數值從小到大排序
                    // (JS 預設 sort 是轉字串排，所以務必加入 a-b 的比較函式)
                    values.sort(function(a, b) { return a - b; });

                    // 🌟 3. 採用「百分位數過濾法」，捨棄頭尾各 2% 的極端雜訊
                    var minIndex = Math.floor(values.length * 0.02);
                    var maxIndex = Math.floor(values.length * 0.98);

                    // 防呆：避免資料筆數太少時超出陣列範圍
                    if (minIndex < 0) minIndex = 0;
                    if (maxIndex >= values.length) maxIndex = values.length - 1;

                    var autoMin = values[minIndex];
                    var autoMax = values[maxIndex];

                    // 🌟 4. 防呆機制：如果整趟航程數值完全沒變
                    if (autoMin === autoMax) {
                        autoMax += 1.0;
                    }

                    // 🌟 5. 自動把過濾後的合理最大最小值填入 TextField
                    minField.text = autoMin.toFixed(2);
                    maxField.text = autoMax.toFixed(2);

                    // 🌟 6. 將資料正式塞入地圖渲染引擎
                    for (var j = 0; j < rawData.length; j++) {
                        trajectoryModel.append(rawData[j])
                    }

                    // 記錄最後一筆的 ID，方便接續即時繪圖
                    _root.lastRenderedId = rawData[rawData.length - 1].id
                }
            }
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 10

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
                                trajectoryModel.clear() // 關閉時清空地圖上的點
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
                        model: ["None", "Temperature (°C)", "Depth (cm)", "DO (%)", "coverage (%)"]

                        // 💡 當更改來源時，重新抓資料
                        onCurrentIndexChanged: {
                            if (renderSwitch.checked) map_setting.refreshMapData()
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

    // database setting
    Rectangle {
                id: database_setting
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

                // 💡 修正：綁定到剛建好的 database_setting_button
                visible: database_setting_button.activate && isFull

                // 防止滑鼠點擊穿透到下方的地圖
                MouseArea { anchors.fill: parent }

                // 🚀 核心魔法：動態載入器
                Loader {
                    id: databaseControlLoader
                    anchors.fill: parent
                    anchors.margins: 1 // 避開邊框

                    // 指定要載入的外部 QML 檔案
                    source: "DatabaseControl.qml"

                    // 💡 效能優化：只有當這個 Rectangle 顯示時，才真正在記憶體中實體化它
                    active: parent.visible
                }
            }

    // Color Legend
    Rectangle {
                id: colorLegend
                width: 85  // 💡 加寬一點，為了塞下右側的數字
                height: 280 // 💡 加高一點，讓 10 個刻度不會太擁擠

                // 停靠在左下角，位於 controlBar 的上方
                anchors.left: parent.left
                anchors.bottom: controlBar.top
                anchors.margins: 20

                color: "#E6252528" // 稍微帶一點透明度的高階黑背景 (Alpha 90%)
                radius: 8
                border.color: "#3a3a3c"
                border.width: 1

                // 💡 智慧顯示邏輯
                visible: renderSwitch.checked && dataFieldCombo.currentIndex !== 0 && isFull

                // --- 預先宣告三種漸層 ---
                Gradient {
                    id: rainbowGradient
                    GradientStop { position: 0.00; color: Qt.hsla(0.0, 1.0, 0.5, 0.8) }   // 紅色 (Max)
                    GradientStop { position: 0.25; color: Qt.hsla(60/360, 1.0, 0.5, 0.8) } // 黃色
                    GradientStop { position: 0.50; color: Qt.hsla(120/360, 1.0, 0.5, 0.8)} // 綠色
                    GradientStop { position: 0.75; color: Qt.hsla(180/360, 1.0, 0.5, 0.8)} // 青色
                    GradientStop { position: 1.00; color: Qt.hsla(240/360, 1.0, 0.5, 0.8)} // 藍色 (Min)
                }

                Gradient {
                    id: heatmapGradient
                    GradientStop { position: 0.00; color: Qt.hsla(0.0, 1.0, 0.9, 0.8) } // 亮白紅 (Max)
                    GradientStop { position: 0.50; color: Qt.hsla(30/360, 1.0, 0.5, 0.8) } // 橘紅
                    GradientStop { position: 1.00; color: Qt.hsla(60/360, 1.0, 0.1, 0.8) } // 偏黑黃 (Min)
                }

                Gradient {
                    id: monochromeGradient
                    GradientStop { position: 0.0; color: Qt.rgba(0.6, 0.2, 0.8, 1.0) } // 不透明紫 (Max)
                    GradientStop { position: 1.0; color: Qt.rgba(0.6, 0.2, 0.8, 0.2) } // 透明深紫 (Min)
                }

                // --- 圖例排版設計 ---
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 12 // 邊距加大，防止最上下的文字被切到
                    spacing: 8

                    // 1. 標題
                    Text {
                        text: dataFieldCombo.currentText.split(" ")[0]
                        color: "#B3B3B3"
                        font.pointSize: 9
                        font.bold: true
                        Layout.alignment: Qt.AlignHCenter
                    }

                    // 分隔線
                    Rectangle { Layout.fillWidth: true; height: 1; color: "#3a3a3c" }

                    // 2. 左右並排區塊 (左邊色條，右邊刻度)
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: 6

                        // 🌟 左側：漸層色條本體
                        Rectangle {
                            Layout.preferredWidth: 16
                            Layout.fillHeight: true
                            radius: 3
                            border.color: "#111111" // 加個深色邊框更有質感
                            border.width: 1

                            gradient: {
                                if (colorRampCombo.currentIndex === 0) return rainbowGradient;
                                if (colorRampCombo.currentIndex === 1) return heatmapGradient;
                                return monochromeGradient;
                            }
                        }

                        // 🌟 右側：11個刻度與數值 (切成完美的 10 等分)
                        Item {
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            Repeater {
                                model: 11 // 產生 11 個點位 (0~10)

                                Item {
                                    width: parent.width
                                    height: 1

                                    // 🚀 精準計算 Y 座標：確保點位完美平均分佈在色條的高度上
                                    // index 0 是最頂端 (0%)，index 10 是最底端 (100%)
                                    y: index * (parent.height / 10.0)

                                    // 刻度小橫線
                                    Rectangle {
                                        width: 5
                                        height: 1
                                        color: "#8A8A8F"
                                        anchors.left: parent.left
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                    // 數值文字
                                    Text {
                                        anchors.left: parent.left
                                        anchors.leftMargin: 8
                                        anchors.verticalCenter: parent.verticalCenter
                                        color: "#FFFFFF"
                                        font.pointSize: 8
                                        font.family: "Consolas" // 建議使用等寬字體，數字對齊會更好看

                                        // 🚀 神奇綁定：根據 Min/Max 自動內插算出這格的數字
                                        text: {
                                            let minVal = parseFloat(minField.text);
                                            if (isNaN(minVal)) minVal = 0.0;

                                            let maxVal = parseFloat(maxField.text);
                                            if (isNaN(maxVal)) maxVal = 100.0;

                                            // 計算當前刻度對應的數值 (index 0 必須是 Max，index 10 是 Min)
                                            let ratio = 1.0 - (index / 10.0);
                                            let val = minVal + (maxVal - minVal) * ratio;

                                            // 格式化為小數點後 1 位
                                            return val.toFixed(1);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
    // 💡 新增：資料點詳細資訊浮動視窗
        Rectangle {
            id: pointInfoPanel
            width: 300
            height: infoColumn.height + 20

            // 停靠在右上角 (你可以依據喜好改到左上或跟隨滑鼠)
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.bottomMargin: 20
            anchors.leftMargin: 20

            color: "#E6252528" // 與你其他面板相同的半透明深色風格
            radius: 8
            border.color: "#3a3a3c"
            border.width: 1
            visible: false // 預設隱藏

            ColumnLayout {
                id: infoColumn
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 12
                spacing: 6

                // 標題與關閉按鈕
                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: "📍 資料點詳細資訊"
                        color: "#FFFFFF"
                        font.bold: true
                        font.pointSize: 10
                        Layout.fillWidth: true
                    }

                    // 關閉按鈕 (X)
                    Rectangle {
                        width: 24
                        height: 24
                        radius: 12
                        color: closeArea.pressed ? "#555555" : "transparent"
                        Text {
                            text: "✕"
                            color: "#B3B3B3"
                            anchors.centerIn: parent
                            font.bold: true
                        }
                        MouseArea {
                            id: closeArea
                            anchors.fill: parent
                            onClicked: pointInfoPanel.visible = false
                        }
                    }
                }

                Rectangle { Layout.fillWidth: true; height: 1; color: "#3a3a3c" } // 分隔線

                // 數值顯示區塊
                Text { id: infoLatLon; color: "#B3B3B3"; font.pointSize: 9 }
                Text { id: infoTemp; color: "#FFFFFF"; font.pointSize: 9 }
                Text { id: infoDepth; color: "#FFFFFF"; font.pointSize: 9 }
                Text { id: infoDO; color: "#FFFFFF"; font.pointSize: 9 }
                Text { id: infoCoverage; color: "#FFFFFF"; font.pointSize: 9 }
                // ==========================================
                // 💡 海草照片與 Mask 疊加顯示區
                // ==========================================
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 5
                    // 如果沒有圖片名稱，就隱藏整個照片區塊
                    visible: seagrassPhotoBase.source != ""

                    // 1. 圖片容器 (負責將兩張圖片精準疊在一起)
                    Item {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 150

                        // 邊框與背景
                        Rectangle {
                            anchors.fill: parent
                            color: "transparent"
                            border.color: "#3a3a3c"
                            border.width: 1
                            radius: 4
                        }

                        // 底圖：原圖照
                        Image {
                            id: seagrassPhotoBase
                            anchors.fill: parent
                            anchors.margins: 1 // 避開邊框
                            fillMode: Image.PreserveAspectFit
                            source: ""
                        }

                        Item {
                            width: seagrassPhotoBase.paintedWidth
                            height: seagrassPhotoBase.paintedHeight
                            anchors.centerIn: seagrassPhotoBase // 對齊底圖中心
                            visible: maskSwitch.checked

                            Image {
                                id: seagrassPhotoMask
                                source: ""
                                anchors.fill: parent
                                fillMode: Image.Stretch
                                visible: false // 依然作為來源，不直接顯示
                            }

                            // 💡 Qt 6 使用 MultiEffect 實現染色
                            MultiEffect {
                                anchors.fill: parent
                                source: seagrassPhotoMask

                                // 將圖片「著色」為紅色
                                colorization: 1.0       // 啟用著色
                                colorizationColor: "#FF0000" // 設定為紅色

                                // 調整透明度
                                opacity: 0.5
                                maskEnabled: true
                                maskSource: seagrassPhotoMask

                            }
                        }

                        // 載入中文字提示 (綁定底圖狀態)
                        Text {
                            anchors.centerIn: parent
                            text: {
                                if (seagrassPhotoBase.status === Image.Loading) return "圖片載入中..."
                                if (seagrassPhotoBase.status === Image.Error) return "圖片載入失敗"
                                return ""
                            }
                            color: "#888888"
                            font.pointSize: 9
                        }
                    }

                    // 2. 切換開關 (Toggle)
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 8

                        Text {
                            text: "疊加 AI 辨識結果"
                            color: "#B3B3B3"
                            font.pointSize: 9
                        }

                        Switch {
                            id: maskSwitch
                            checked: true // 預設開啟疊加
                            // 縮小一下 Switch 的視覺比例讓它更精緻
                            scale: 0.8
                        }
                    }
                }
            }

            // 接收點擊傳來的資料並更新 UI
                    function showInfo(lat, lon, temp, depth, do_val, coverage, imageName) {
                        infoLatLon.text = "座標: " + Number(lat).toFixed(6) + ", " + Number(lon).toFixed(6)
                        infoTemp.text = "溫度: " + (typeof temp === 'number' ? temp.toFixed(2) : temp) + " °C"
                        infoDepth.text = "深度: " + (typeof depth === 'number' ? depth.toFixed(2) : depth) + " cm"
                        infoDO.text = "溶氧: " + (typeof do_val === 'number' ? do_val.toFixed(2) : do_val) + " %"
                        infoCoverage.text = "覆蓋率: " + (typeof coverage === 'number' ? coverage.toFixed(2) : coverage) + " %"

                        // 💡 處理圖片與 Mask 邏輯
                        if (imageName && imageName !== "") {
                            // --- 1. 設定原圖 URL ---
                            // ⚠️ 請記得把 IP 換成你實際 Flask API 的位置
                            var boatIP = "100.127.136.93"
                            if(DeNovoViewer.boatManager.activeBoat.primaryConnected){
                                boatIP = DeNovoViewer.boatManager.activeBoat.PIP
                            }else{
                                boatIP = DeNovoViewer.boatManager.activeBoat.SIP
                            }

                            var apiBaseUrl = "http://"+boatIP+":5000/api/image/";
                            seagrassPhotoBase.source = apiBaseUrl + imageName;

                            console.log(apiBaseUrl)

                            // --- 2. 智慧解析並生成 Mask 的 URL ---
                            // 尋找最後一個點 "." 的位置，用來分開檔名與副檔名 (例如 .jpg 或 .png)
                            var dotIndex = imageName.lastIndexOf(".");
                            if (dotIndex !== -1) {
                                var namePart = imageName.substring(0, dotIndex); // 拿到 "001"
                                var extPart = imageName.substring(dotIndex);     // 拿到 ".jpg"
                                var maskName = namePart + "_mask" + extPart;     // 組合成 "001_mask.jpg"

                                seagrassPhotoMask.source = apiBaseUrl + maskName;
                            } else {
                                // 防呆：萬一只傳了沒有副檔名的檔名
                                seagrassPhotoMask.source = apiBaseUrl + imageName + "_mask";
                            }
                        } else {
                            // 如果該點沒有照片，清空來源
                            seagrassPhotoBase.source = "";
                            seagrassPhotoMask.source = "";
                        }

                        visible = true
                    }
        }
    Connections {
        target: DeNovoViewer.marineDatabase

        function onDataInsertedSuccessfully(newPt) {
            if (renderSwitch.checked) {

                // 1. 根據下拉選單，動態抓取需要的數值
                var val = 0.0;
                if (dataFieldCombo.currentIndex === 1) val = Number(newPt["temperature"] || 0);
                else if (dataFieldCombo.currentIndex === 2) val = Number(newPt["depth"] || 0);
                else if (dataFieldCombo.currentIndex === 3) val = Number(newPt["dissolved_oxygen_concentration"] || 0);
                else if (dataFieldCombo.currentIndex === 4) val = Number(newPt["seagrass_coverage_ratio"] || 0);

                // 2. 防呆：確認有拿到 ID 且不是重複畫
                if (newPt.id !== undefined && newPt.id !== _root.lastRenderedId) {
                    _root.lastRenderedId = newPt.id
                    newPt.value = val
                    // 3. 直接 Append 進地圖 Model
                    trajectoryModel.append(newPt)
                    // 4. 輕量 Nudge 強迫 QML 重繪
                    var lastIndex = trajectoryModel.count - 1;
                    trajectoryModel.set(lastIndex, { "value": val });

                }
            }
        }

    }
}
