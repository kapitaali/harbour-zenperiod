import QtQuick 2.6
import Sailfish.Silica 1.0

Page {
    id: page

    RemorsePopup { id: remorse }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        Column {
            id: column
            width: parent.width
            spacing: Theme.paddingMedium
            PageHeader { title: qsTr("Settings") }

            SectionHeader { text: qsTr("Cycle defaults") }
            Label {
                x: Theme.horizontalPageMargin; width: parent.width - 2 * Theme.horizontalPageMargin
                color: Theme.primaryColor
                text: qsTr("Usual cycle: %n day(s)", "", store.usualCycle)
            }
            Row {
                x: Theme.horizontalPageMargin; width: parent.width - 2 * Theme.horizontalPageMargin
                spacing: Theme.paddingMedium
                IconButton {
                    width: Theme.itemSizeSmall; height: Theme.itemSizeSmall
                    icon.source: "image://theme/icon-m-remove"
                    onClicked: store.usualCycle = store.usualCycle - 1
                }
                Label {
                    width: parent.width - 2 * Theme.itemSizeSmall - 2 * parent.spacing
                    wrapMode: Text.Wrap
                    anchors.verticalCenter: parent.verticalCenter
                    color: Theme.secondaryColor; font.pixelSize: Theme.fontSizeSmall
                    text: qsTr("15–60 days, used until you log 2+ periods")
                }
                IconButton {
                    width: Theme.itemSizeSmall; height: Theme.itemSizeSmall
                    icon.source: "image://theme/icon-m-add"
                    onClicked: store.usualCycle = store.usualCycle + 1
                }
            }
            Label {
                x: Theme.horizontalPageMargin; width: parent.width - 2 * Theme.horizontalPageMargin
                color: Theme.primaryColor
                text: qsTr("Period: %n day(s)", "", store.usualPeriod)
            }
            Row {
                x: Theme.horizontalPageMargin; width: parent.width - 2 * Theme.horizontalPageMargin
                spacing: Theme.paddingMedium
                IconButton {
                    width: Theme.itemSizeSmall; height: Theme.itemSizeSmall
                    icon.source: "image://theme/icon-m-remove"
                    onClicked: store.usualPeriod = store.usualPeriod - 1
                }
                Label {
                    width: parent.width - 2 * Theme.itemSizeSmall - 2 * parent.spacing
                    wrapMode: Text.Wrap
                    anchors.verticalCenter: parent.verticalCenter
                    color: Theme.secondaryColor; font.pixelSize: Theme.fontSizeSmall
                    text: qsTr("Bleeding days, 1–14")
                }
                IconButton {
                    width: Theme.itemSizeSmall; height: Theme.itemSizeSmall
                    icon.source: "image://theme/icon-m-add"
                    onClicked: store.usualPeriod = store.usualPeriod + 1
                }
            }
            Label {
                x: Theme.horizontalPageMargin; width: parent.width - 2 * Theme.horizontalPageMargin
                color: Theme.primaryColor
                text: qsTr("Luteal phase: %n day(s)", "", store.usualLuteal)
            }
            Row {
                x: Theme.horizontalPageMargin; width: parent.width - 2 * Theme.horizontalPageMargin
                spacing: Theme.paddingMedium
                IconButton {
                    width: Theme.itemSizeSmall; height: Theme.itemSizeSmall
                    icon.source: "image://theme/icon-m-remove"
                    onClicked: store.usualLuteal = store.usualLuteal - 1
                }
                Label {
                    width: parent.width - 2 * Theme.itemSizeSmall - 2 * parent.spacing
                    wrapMode: Text.Wrap
                    anchors.verticalCenter: parent.verticalCenter
                    color: Theme.secondaryColor; font.pixelSize: Theme.fontSizeSmall
                    text: qsTr("Ovulation ≈ next period minus this, 10–18")
                }
                IconButton {
                    width: Theme.itemSizeSmall; height: Theme.itemSizeSmall
                    icon.source: "image://theme/icon-m-add"
                    onClicked: store.usualLuteal = store.usualLuteal + 1
                }
            }

            SectionHeader { text: qsTr("Privacy") }
            Label {
                x: Theme.horizontalPageMargin; width: parent.width - 2 * Theme.horizontalPageMargin
                wrapMode: Text.Wrap; color: Theme.secondaryColor; font.pixelSize: Theme.fontSizeSmall
                text: qsTr("Local-only: data stays in the app sandbox SQLite file. No account, no network permission, no analytics. Predictions are on-device and not medical advice.")
            }
            Button {
                x: Theme.horizontalPageMargin
                text: qsTr("Wipe all data")
                color: Theme.secondaryColor
                onClicked: remorse.execute(qsTr("Deleting all entries"), function() { store.clearAll() })
            }
        }
        VerticalScrollDecorator {}
    }
}
