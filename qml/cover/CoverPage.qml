import QtQuick 2.6
import Sailfish.Silica 1.0

CoverBackground {
    property var pred: store.predictions()

    Connections {
        target: store
        onDataChanged: pred = store.predictions()
        onSettingsChanged: pred = store.predictions()
    }

    Column {
        anchors { left: parent.left; right: parent.right; top: parent.top; margins: Theme.paddingLarge }
        spacing: Theme.paddingMedium

        Label {
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("ZenPeriod")
            color: Theme.primaryColor
            font.pixelSize: Theme.fontSizeMedium
        }
        Label {
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            color: Theme.highlightColor
            font.pixelSize: Theme.fontSizeLarge
            text: pred.daysToNext > 0
                  ? qsTr("%n day(s) to period", "", pred.daysToNext)
                  : pred.daysToNext === 0
                    ? qsTr("Due today")
                    : qsTr("Day %1 late").arg(-pred.daysToNext)
        }
        Label {
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            color: Theme.secondaryColor
            font.pixelSize: Theme.fontSizeSmall
            text: qsTr("Next: %1").arg(pred.nextPeriod)
        }
    }

    CoverActionList {
        CoverAction {
            iconSource: "image://theme/icon-cover-new"
            onTriggered: {
                var app = applicationWindow
                if (app) {
                    app.activate()
                    app.pageStack.push(Qt.resolvedUrl("../pages/LogPage.qml"))
                }
            }
        }
    }
}
