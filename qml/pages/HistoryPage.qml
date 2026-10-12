import QtQuick 2.6
import Sailfish.Silica 1.0

Page {
    id: page
    property var items: store.history(12)
    property var st: store.stats()
    property var pred: store.predictions()

    function refresh() {
        items = store.history(12)
        st = store.stats()
        pred = store.predictions()
    }
    onStatusChanged: if (status === PageStatus.Active) refresh()
    Connections { target: store; onDataChanged: page.refresh() }

    SilicaListView {
        anchors.fill: parent
        header: Column {
            width: parent.width
            PageHeader { title: qsTr("History") }
            Label {
                x: Theme.horizontalPageMargin; width: parent.width - 2 * Theme.horizontalPageMargin
                wrapMode: Text.Wrap; color: Theme.secondaryColor; font.pixelSize: Theme.fontSizeSmall
                text: st.count > 1
                      ? qsTr("%1 periods · avg %2d · range %3–%4d").arg(st.count).arg(Math.round(st.avg)).arg(st.min).arg(st.max)
                      : st.count === 1 ? qsTr("1 period logged — log one more for averages")
                      : qsTr("Nothing logged yet")
            }
            Label {
                x: Theme.horizontalPageMargin; width: parent.width - 2 * Theme.horizontalPageMargin
                wrapMode: Text.Wrap; color: Theme.secondaryColor; font.pixelSize: Theme.fontSizeSmall
                text: qsTr("Predicted periods: %1, %2, %3 · ovulation ~%4").arg(pred.nextPeriod).arg(pred.next2).arg(pred.next3).arg(pred.ovulation)
            }
            SectionHeader { text: qsTr("Past periods") }
        }
        model: items
        delegate: ListItem {
            width: parent.width
            Label {
                x: Theme.horizontalPageMargin; anchors.verticalCenter: parent.verticalCenter
                color: Theme.primaryColor
                text: modelData.start + (modelData.cycleLength > 0 ? " · " + qsTr("%n day cycle", "", modelData.cycleLength) : "")
            }
        }
        VerticalScrollDecorator {}
    }
}
