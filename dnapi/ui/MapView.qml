import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtPositioning
import QtLocation

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
            id: esriPlugin
            name: "esri"
        }

    Plugin {
        id: googlePlugin
        name: "osm"

        // 1. 使用 Google 衛星圖 (它完全符合 Qt 的 Z/X/Y 順序)
        // 我們利用問號 '?' 來吃掉 Qt 自動補上的 ".png"
        PluginParameter {
            name: "osm.mapping.custom.host"
            value: "http://mt1.google.com/vt/lyrs=s&x={x}&y={y}&z={z}&scale=1&"
        }

        // 2. 偽裝 User-Agent (必填，否則 Google 會封鎖請求)
        PluginParameter {
            name: "osm.useragent"
            value: "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
        }

        // 3. 停用其他干擾
        PluginParameter { name: "osm.mapping.providersrepository.disabled"; value: "true" }
        PluginParameter { name: "osm.mapping.cache.disk.size"; value: 0 }
        PluginParameter { name: "osm.mapping.cache.directory"; value: "" }
    }
    Plugin {
            id: google2Plugin
            name: "osm"

            // 1. 填入 Google 衛星圖 + 你的 API Key
            PluginParameter {
                name: "osm.mapping.custom.host"
                value: "http://mt1.google.com/vt/lyrs=y&x={x}&y={y}&z={z}&key=AIzaSyDmmZdDsB36uPDeQPBw8jCm8RFKat7tnDA"
            }

            // 2. 核心關鍵：禁用 OSM 從網路獲取預設提供者清單，防止它連到死掉的 qt.io
            PluginParameter {
                name: "osm.mapping.providersrepository.disabled"
                value: "true"
            }
            PluginParameter {
                    name: "osm.useragent"
                    value: "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
                }

            // 3. 核心關鍵：禁用預設的地圖選項，逼它只剩下基礎圖與自定義圖
            PluginParameter {
                name: "osm.mapping.providers.visible"
                value: "false"
            }
            PluginParameter {
                name: "osm.mapping.custom.format"
                value: "png" // 如果用 lyrs=y，請用 png；如果用 lyrs=s，請試試 jpeg
            }

            // 4. 強制清空損壞的快取
            PluginParameter { name: "osm.mapping.cache.directory"; value: "" }
            PluginParameter { name: "osm.mapping.cache.disk.size"; value: 0 }
        }
    Plugin {
            id: archPlugin
            name: "osm" // "mapboxgl", "esri", ...
            // specify plugin parameters if necessary



            // 1. 核心網址：ArcGIS 衛星圖 (ZYX 格式)
            PluginParameter {
                name: "osm.mapping.custom.host"
                // 關鍵：刪掉所有的 {z}/{y}/{x}，只留到 tile/
                // Qt 會自動在後面補上 "19/438799/224521.png"
                value: "http://127.0.0.1:8080/tile/"
            }
            // 2. 偽裝成 QGC 或瀏覽器以確保穩定連線
            PluginParameter { name: "osm.useragent"; value: "Lighthouse_Proxy" }
            // 3. 停用那些會報錯的預設 OSM 轉向伺服器
            PluginParameter { name: "osm.mapping.providersrepository.disabled"; value: "true" }
            PluginParameter { name: "osm.mapping.providers.visible"; value: "false" }
            PluginParameter { name: "osm.mapping.cache.directory"; value: "" }
            PluginParameter { name: "osm.mapping.cache.disk.size"; value: "0" }

            // 3. 提高連線逾時，確保不會因為網路慢而跳錯誤圖
            PluginParameter { name: "osm.mapping.offline.allow"; value: "false" }
    }
    Map {
        id: mmap
        anchors.fill: parent
        plugin: archPlugin
        //activeMapType: supportedMapTypes[3] // Cycle map provided by Thunderforest


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
        zoomLevel: 19

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
            coordinate: lat? QtPositioning.coordinate(lat,lon): QtPositioning.coordinate(25, 121.3)
            anchorPoint: Qt.point(sourceItem.width/2, sourceItem.height/2)
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



}
