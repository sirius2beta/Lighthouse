import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Dialogs 6.3
import DeNovoViewer 1.0
import DeNovoViewer.Boat 1.0

Item {
    id: root
    width: 200
    height: 350

    // 狀態追蹤
    property bool isDbConnected: false
    property bool isRecording: false

    property string currentDbName: "未選擇檔案"
    property string logRootDir: DeNovoViewer.marineDatabase ? DeNovoViewer.marineDatabase.defaultLogDirectory() : ""

    Connections {
        target: DeNovoViewer.marineDatabase

        function onConnectionStatusChanged(connected) {
            root.isDbConnected = connected
            if (connected) {
                var path = DeNovoViewer.marineDatabase.dbName
                root.currentDbName = path.substring(path.lastIndexOf("/") + 1)
            } else {
                root.currentDbName = "未選擇檔案"
                root.isRecording = false // 斷線時，強制停止錄製狀態
            }
        }

        function onDataInsertedSuccessfully() {
            blinkAnimation.start()
        }
    }

    // 檔案選取器
    FileDialog {
        id: fileDialog
        title: "請選擇舊日誌檔案 (.db)"
        currentFolder: urlFactory.fromLocalFile(root.logRootDir)
        nameFilters: ["SQLite 資料庫 (*.db)", "所有檔案 (*.*)"]

        onAccepted: {
            var rawPath = fileDialog.selectedFile.toString()
            var cleanPath = rawPath.replace("file:///", "")
            DeNovoViewer.marineDatabase.openConnection(cleanPath)
        }
    }

    QtObject {
        id: urlFactory
        function fromLocalFile(path) {
            if (!path) return ""
            var clean = path.replace(/\\/g, "/")
            if (!clean.startsWith("file:///")) {
                clean = "file:///" + clean
            }
            return clean
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "#1a1a1c"
        border.color: "#565656"
        border.width: 1

        ScrollView {
            anchors.fill: parent
            anchors.margins: 1
            clip: true
            contentWidth: availableWidth
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

            ColumnLayout {
                width: parent.width - 24
                x: 12
                y: 12
                spacing: 10

                Text {
                    text: "Lighthouse Database"
                    color: "#FFFFFF"
                    font.bold: true
                    font.pointSize: 11
                    Layout.alignment: Qt.AlignHCenter
                }

                // 狀態面板
                Rectangle {
                    Layout.fillWidth: true
                    height: 50
                    color: "#252528"
                    radius: 4
                    border.color: "#3a3a3c"

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 2
                        RowLayout {
                            spacing: 6
                            Layout.alignment: Qt.AlignHCenter
                            Rectangle {
                                width: 8; height: 8; radius: 4
                                color: root.isRecording ? "#2ECC71" : (root.isDbConnected ? "#F39C12" : "#E74C3C")
                            }
                            Text {
                                text: root.isRecording ? "錄製中 (WAL)" : (root.isDbConnected ? "檔案待機中" : "未連線")
                                color: "#DCDCDC"; font.pointSize: 9
                            }
                        }
                        Text {
                            text: root.currentDbName
                            color: "#8A8A8F"; font.pointSize: 8
                            Layout.maximumWidth: 170; elide: Text.ElideMiddle; Layout.alignment: Qt.AlignHCenter
                        }
                    }
                }

                // 寫入間隔
                ColumnLayout {
                    Layout.fillWidth: true; spacing: 2
                    Text { text: "寫入間隔 (秒):"; color: "#B3B3B3"; font.pointSize: 8 }
                    SpinBox {
                        id: intervalSpin; Layout.fillWidth: true; from: 1; to: 60
                        value: DeNovoViewer.marineDatabase ? DeNovoViewer.marineDatabase.writeInterval : 1
                        onValueModified: { if (DeNovoViewer.marineDatabase) DeNovoViewer.marineDatabase.writeInterval = value }
                    }
                }

                // ==========================================
                // 📂 區塊一：檔案管理
                // ==========================================
                ColumnLayout {
                    Layout.fillWidth: true; spacing: 4

                    Text { text: "1. 檔案管理"; color: "#B3B3B3"; font.pointSize: 8 }

                    // 尚未連線時顯示：新建與選取
                    Button {
                        text: "建立新紀錄檔"
                        Layout.fillWidth: true
                        visible: !root.isDbConnected // 💡 有連線就隱藏

                        onClicked: {
                            var currentTime = Qt.formatDateTime(new Date(), "yyyyMMdd_hhmmss")
                            var targetPath = root.logRootDir + "/trip_" + currentTime + ".db"
                            DeNovoViewer.marineDatabase.openConnection(targetPath)
                        }
                    }

                    Button {
                        text: "選取舊紀錄檔"
                        Layout.fillWidth: true
                        visible: !root.isDbConnected // 💡 有連線就隱藏

                        onClicked: {
                            root.logRootDir = DeNovoViewer.marineDatabase.defaultLogDirectory()
                            fileDialog.open()
                        }
                    }

                    // 已連線時顯示：關閉檔案
                    Button {
                        text: "關閉目前檔案"
                        Layout.fillWidth: true
                        visible: root.isDbConnected // 💡 只有連線時才顯示
                        enabled: !root.isRecording  // 💡 錄製中禁止關閉檔案

                        onClicked: {
                            if (DeNovoViewer.marineDatabase) {
                                DeNovoViewer.marineDatabase.closeConnection()
                            }
                        }
                    }
                }

                // ==========================================
                // ▶️ 區塊二：紀錄控制
                // ==========================================
                ColumnLayout {
                    Layout.fillWidth: true; spacing: 4
                    Layout.topMargin: 4

                    Text { text: "2. 紀錄控制"; color: "#B3B3B3"; font.pointSize: 8 }

                    Button {
                        text: "開始記錄"
                        Layout.fillWidth: true
                        enabled: root.isDbConnected && !root.isRecording // 💡 有檔案且未錄製時才能按

                        onClicked: {
                            if (DeNovoViewer.marineDatabase) {
                                DeNovoViewer.marineDatabase.startLogging()
                                root.isRecording = true
                            }
                        }
                    }

                    Button {
                        text: "停止紀錄"
                        Layout.fillWidth: true
                        enabled: root.isRecording // 💡 只有正在錄製時才能按停止

                        onClicked: {
                            if (DeNovoViewer.marineDatabase) {
                                DeNovoViewer.marineDatabase.stopLogging() // 💡 這裡移除了 closeConnection
                                root.isRecording = false
                            }
                        }
                    }
                }

                Item { Layout.minimumHeight: 10 }

                // 底部寫入指示燈
                RowLayout {
                    Layout.alignment: Qt.AlignHCenter; spacing: 6
                    Rectangle { id: blinkDot; width: 8; height: 8; radius: 4; color: "#3498DB"; opacity: 0.0 }
                    Text { text: "資料庫 I/O 寫入訊號"; color: "#565656"; font.pointSize: 8 }
                }

                Item { Layout.minimumHeight: 12 }
            }
        }
    }

    SequentialAnimation {
        id: blinkAnimation
        PropertyAnimation { target: blinkDot; property: "opacity"; from: 0.0; to: 1.0; duration: 80 }
        PropertyAnimation { target: blinkDot; property: "opacity"; from: 1.0; to: 0.0; duration: 250 }
    }

    Component.onCompleted: {
        if (DeNovoViewer.marineDatabase) {
            var path = DeNovoViewer.marineDatabase.dbName
            if (DeNovoViewer.marineDatabase.isConnected) {
                root.isDbConnected = true
                root.currentDbName = path.substring(path.lastIndexOf("/") + 1)
                root.isRecording = false
            }
        }
    }
}
