import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtPositioning 5.15
import QtLocation 5.15
import DeNovoViewer 1.0
import DeNovoViewer.Display 1.0
import QtGraphs


Item {
    id: root
    property string sensorName: "數據"
    property string dataKey: "value" // 預設抓 "value" 欄位
    property color lineColor: "#00FFCC"
    Rectangle{
        color: "#111111"
        anchors.fill:parent
        anchors.margins: 0

        Text {
                    text: sensorName
                    color: "white"
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    anchors.topMargin: 5
                    z: 10
                }

        GraphsView {
                id: chartView
                anchors.fill: parent
                anchors.margins: 0
                marginLeft: 5
                marginBottom: 5


                axisX: ValueAxis { id: axisX; min: 0; max: 1000; titleVisible: false; tickInterval: (max - min) / 4 }
                axisY: ValueAxis { id: axisY; min: 0; max: 100; titleVisible: false; tickInterval: (max - min) / 5 }

                LineSeries {
                    id: waterSeries
                    name: "即時水質趨勢"

                    // 使用屬性綁定來監控資料
                    property var rawData: DeNovoViewer.aquaGraph.currentData

                    onRawDataChanged: {
                        if (DeNovoViewer.aquaGraph === null) return;

                        let data = rawData;
                        // 1. 防禦：如果沒資料，直接跳出
                        if (!data || data.length === 0) return;

                        let points = [];
                        let minY = data[0][root.dataKey];
                        let maxY = data[0][root.dataKey];

                        // 2. 遍歷數據
                        for (let i = 0; i < data.length; i++) {
                            let val = data[i][root.dataKey];
                            points.push(Qt.point(data[i].time, val));
                            if (val < minY) minY = val;
                            if (val > maxY) maxY = val;
                        }
                        waterSeries.replace(points);

                        // 3. 更新 X 軸
                        axisX.max = data[data.length - 1].time;
                        axisX.min = axisX.max - 300;

                        // 4. 更新 Y 軸（核心修正處）
                        if (minY === maxY) {
                            // 如果所有數值都一樣，手動給予一個上下範圍，避免 ASSERT 錯誤
                            axisY.min = minY - 1.0;
                            axisY.max = maxY + 1.0;
                        } else {
                            // 增加 10% 的緩衝空間
                            let margin = (maxY - minY) * 0.1;
                            axisY.min = minY - margin;
                            axisY.max = maxY + margin;
                        }
                    }
                }
            }


    }
}
