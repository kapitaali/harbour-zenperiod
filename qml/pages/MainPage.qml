import QtQuick 2.6
import Sailfish.Silica 1.0
import Nemo.Notifications 1.0
import "../backend/cycle.js" as Cycle

Page {
    id: page

    property int shownYear: new Date().getFullYear()
    property int shownMonth: new Date().getMonth() + 1
    property var pred: store.predictions()
    property string notifiedKey: ""

    function refresh() {
        pred = store.predictions()
        // Local-only due/overdue nudge, posted at most once per
        // prediction state. Full background reminders (KeepAlive) are v2.
        if (pred.daysToNext !== undefined && pred.daysToNext <= 1 && pred.cycleDay > 0) {
            var key = pred.nextPeriod + "|" + pred.daysToNext
            if (key !== notifiedKey) {
                notifiedKey = key
                dueNotification.publish()
            }
        }
    }

    Component.onCompleted: refresh()
    onStatusChanged: if (status === PageStatus.Active) refresh()

    Connections {
        target: store
        onDataChanged: page.refresh()
        onSettingsChanged: page.refresh()
    }

    Notification {
        id: dueNotification
        category: "x-harbour-zenperiod-period"
        summary: qsTr("ZenPeriod")
        body: page.pred.daysToNext === 1
              ? qsTr("Period due tomorrow")
              : page.pred.daysToNext === 0
                ? qsTr("Period due today")
                : qsTr("Period %1 day(s) overdue — predictions are not medical advice").arg(-page.pred.daysToNext)
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        PullDownMenu {
            MenuItem { text: qsTr("Log today"); onClicked: pageStack.push(Qt.resolvedUrl("LogPage.qml", { date: Cycle.todayIso() })) }
            MenuItem { text: qsTr("History"); onClicked: pageStack.push(Qt.resolvedUrl("HistoryPage.qml")) }
            MenuItem { text: qsTr("Settings"); onClicked: pageStack.push(Qt.resolvedUrl("SettingsPage.qml")) }
        }

        Column {
            id: column
            width: parent.width
            spacing: Theme.paddingMedium

            PageHeader { title: qsTr("ZenPeriod") }

            Label {
                x: Theme.horizontalPageMargin; width: parent.width - 2 * Theme.horizontalPageMargin
                wrapMode: Text.Wrap
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeLarge
                text: pred.cycleDay > 0
                      ? qsTr("Day %1 · %2").arg(pred.cycleDay).arg(
                            pred.daysToNext > 0 ? qsTr("%n day(s) to period", "", pred.daysToNext)
                            : pred.daysToNext === 0 ? qsTr("due today")
                            : qsTr("%n day(s) late", "", -pred.daysToNext))
                      : qsTr("Log your first period to start predictions")
            }
            Label {
                x: Theme.horizontalPageMargin; width: parent.width - 2 * Theme.horizontalPageMargin
                wrapMode: Text.Wrap
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeSmall
                text: qsTr("Next: %1 · PMS %2–%3 · predictions are not medical advice")
                      .arg(pred.nextPeriod).arg(pred.pmsStart).arg(pred.pmsEnd)
            }

            Row {
                x: Theme.horizontalPageMargin; width: parent.width - 2 * Theme.horizontalPageMargin
                spacing: Theme.paddingMedium
                IconButton {
                    icon.source: "image://theme/icon-m-left"
                    onClicked: {
                        if (page.shownMonth === 1) { page.shownMonth = 12; page.shownYear-- }
                        else page.shownMonth--
                    }
                }
                Label {
                    width: parent.width - 2 * parent.children[0].width - 2 * parent.spacing
                    horizontalAlignment: Text.AlignHCenter
                    anchors.verticalCenter: parent.verticalCenter
                    color: Theme.primaryColor
                    text: Qt.locale().monthName(page.shownMonth - 1, Locale.LongFormat) + " " + page.shownYear
                }
                IconButton {
                    icon.source: "image://theme/icon-m-right"
                    onClicked: {
                        if (page.shownMonth === 12) { page.shownMonth = 1; page.shownYear++ }
                        else page.shownMonth++
                    }
                }
            }

            Grid {
                x: Theme.horizontalPageMargin; width: parent.width - 2 * Theme.horizontalPageMargin
                columns: 7
                spacing: 2
                Repeater {
                    model: ["M","T","W","T","F","S","S"]
                    Label {
                        width: (parent.width - 6 * parent.spacing) / 7
                        horizontalAlignment: Text.AlignHCenter
                        color: Theme.secondaryColor
                        font.pixelSize: Theme.fontSizeExtraSmall
                        text: modelData
                    }
                }
                Repeater {
                    model: Cycle.monthCells(page.shownYear, page.shownMonth)
                    delegate: BackgroundItem {
                        id: cell
                        width: (parent.width - 6 * parent.spacing) / 7
                        height: width * 1.15
                        enabled: modelData !== ""
                        property var info: modelData !== "" ? store.getDay(modelData) : null
                        property bool logged: info && info.logged
                        property bool isPeriod: logged && info.flow >= 2
                        property bool predP: modelData !== "" && store.isPredictedPeriod(modelData)
                        property bool predS: modelData !== "" && store.isPredictedPms(modelData)
                        Rectangle {
                            anchors.fill: parent
                            radius: 6
                            color: cell.isPeriod ? Theme.highlightBackgroundColor
                                 : cell.predP ? Theme.rgba(Theme.highlightBackgroundColor, 0.35)
                                 : cell.predS ? Theme.rgba(Theme.secondaryColor, 0.18)
                                 : "transparent"
                            border.color: modelData === Cycle.todayIso() ? Theme.highlightColor : "transparent"
                            border.width: 2
                        }
                        Label {
                            anchors.centerIn: parent
                            color: cell.isPeriod ? Theme.highlightColor : Theme.primaryColor
                            font.pixelSize: Theme.fontSizeSmall
                            text: modelData !== "" ? Number(modelData.split("-")[2]) : ""
                        }
                        // symptom dot
                        Rectangle {
                            visible: cell.logged && !cell.isPeriod
                            anchors { bottom: parent.bottom; horizontalCenter: parent.horizontalCenter; bottomMargin: 4 }
                            width: 6; height: 6; radius: 3
                            color: Theme.secondaryColor
                        }
                        onClicked: pageStack.push(Qt.resolvedUrl("LogPage.qml"), { date: modelData })
                    }
                }
            }

            SectionHeader { text: qsTr("Legend") }
            Label {
                x: Theme.horizontalPageMargin; width: parent.width - 2 * Theme.horizontalPageMargin
                wrapMode: Text.Wrap; color: Theme.secondaryColor; font.pixelSize: Theme.fontSizeExtraSmall
                text: qsTr("Solid = logged period · tinted = predicted period · shaded = PMS window · dot = other symptoms")
            }
            VerticalScrollDecorator {}
        }
    }
}
