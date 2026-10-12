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
                spacing: Theme.paddingLarge
                Button {
                    text: "−"
                    onClicked: store.usualCycle = store.usualCycle - 1
                }
                Button {
                    text: "+"
                    onClicked: store.usualCycle = store.usualCycle + 1
                }
                Label {
                    anchors.verticalCenter: parent.verticalCenter
                    color: Theme.secondaryColor; font.pixelSize: Theme.fontSizeSmall
                    text: qsTr("15–60 days, used until you log 2+ periods")
                }
            }
            Row {
                x: Theme.horizontalPageMargin; width: parent.width - 2 * Theme.horizontalPageMargin
                spacing: Theme.paddingLarge
                Button {
                    text: "−"
                    onClicked: store.usualPeriod = store.usualPeriod - 1
                }
                Button {
                    text: "+"
                    onClicked: store.usualPeriod = store.usualPeriod + 1
                }
                Label {
                    anchors.verticalCenter: parent.verticalCenter
                    color: Theme.secondaryColor; font.pixelSize: Theme.fontSizeSmall
                    text: qsTr("Period: %n day(s), 1–14", "", store.usualPeriod)
                }
            }
            Row {
                x: Theme.horizontalPageMargin; width: parent.width - 2 * Theme.horizontalPageMargin
                spacing: Theme.paddingLarge
                Button {
                    text: "−"
                    onClicked: store.usualLuteal = store.usualLuteal - 1
                }
                Button {
                    text: "+"
                    onClicked: store.usualLuteal = store.usualLuteal + 1
                }
                Label {
                    anchors.verticalCenter: parent.verticalCenter
                    color: Theme.secondaryColor; font.pixelSize: Theme.fontSizeSmall
                    text: qsTr("Luteal phase: %n day(s), 10–18", "", store.usualLuteal)
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
