import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtPositioning 5.15
import QtLocation 5.15
import DeNovoViewer 1.0
import DeNovoViewer.Display 1.0
import QtGraphs


Item {
    Rectangle{
        color: "#111111"
        anchors.fill:parent
        anchors.margins: 0

        GraphsView {
                id: chartView
                anchors.fill: parent
                anchors.margins: 0
                anchors.leftMargin: -15
                anchors.bottomMargin: -15


                axisX: ValueAxis { id: axisX; min: 0; max: 100; titleVisible: false }
                axisY: ValueAxis { id: axisY; min: 0; max: 100; titleVisible: false }

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
                        let minY = data[0].value;
                        let maxY = data[0].value;

                        // 2. 遍歷數據
                        for (let i = 0; i < data.length; i++) {
                            let val = data[i].value;
                            points.push(Qt.point(data[i].time, val));
                            if (val < minY) minY = val;
                            if (val > maxY) maxY = val;
                        }
                        waterSeries.replace(points);

                        // 3. 更新 X 軸
                        axisX.max = data[data.length - 1].time;
                        axisX.min = axisX.max - 50;

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
