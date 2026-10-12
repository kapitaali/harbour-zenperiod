import QtQuick 2.6
import Sailfish.Silica 1.0
import "../backend/cycle.js" as Cycle

Page {
    id: page
    objectName: "OnboardingPage"

    property string startDate: Cycle.todayIso()
    property int cycle: 28
    property int period: 5
    property bool startValid: startDate !== "" && startDate <= Cycle.todayIso()

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        Column {
            id: column
            width: parent.width
            spacing: Theme.paddingMedium

            PageHeader { title: qsTr("Welcome") }

            Label {
                x: Theme.horizontalPageMargin; width: parent.width - 2 * Theme.horizontalPageMargin
                wrapMode: Text.Wrap
                color: Theme.primaryColor
                font.pixelSize: Theme.fontSizeMedium
                text: qsTr("ZenPeriod keeps everything on this phone: no account, no cloud, no tracking. Predictions are computed on-device and are not medical advice.")
            }

            SectionHeader { text: qsTr("When did your last period start?") }

            DatePickerButton {
                x: Theme.horizontalPageMargin; width: parent.width - 2 * Theme.horizontalPageMargin
                title: qsTr("Last period start")
                date: new Date()
                onDateChanged: page.startDate = Cycle.dateToIso(date)
            }

            Label {
                visible: !page.startValid
                x: Theme.horizontalPageMargin; width: parent.width - 2 * Theme.horizontalPageMargin
                wrapMode: Text.Wrap
                color: "red"
                font.pixelSize: Theme.fontSizeSmall
                text: qsTr("Pick today or a past date.")
            }

            SectionHeader { text: qsTr("Usual lengths") }

            Row {
                x: Theme.horizontalPageMargin; width: parent.width - 2 * Theme.horizontalPageMargin
                spacing: Theme.paddingLarge
                Button { text: "−"; onClicked: page.cycle = Math.max(15, page.cycle - 1) }
                Label {
                    anchors.verticalCenter: parent.verticalCenter
                    color: Theme.primaryColor
                    text: qsTr("Cycle: %n day(s)", "", page.cycle)
                }
                Button { text: "+"; onClicked: page.cycle = Math.min(60, page.cycle + 1) }
            }
            Row {
                x: Theme.horizontalPageMargin; width: parent.width - 2 * Theme.horizontalPageMargin
                spacing: Theme.paddingLarge
                Button { text: "−"; onClicked: page.period = Math.max(1, page.period - 1) }
                Label {
                    anchors.verticalCenter: parent.verticalCenter
                    color: Theme.primaryColor
                    text: qsTr("Period: %n day(s)", "", page.period)
                }
                Button { text: "+"; onClicked: page.period = Math.min(14, page.period + 1) }
            }

            Button {
                x: Theme.horizontalPageMargin
                text: qsTr("Start tracking")
                enabled: page.startValid
                onClicked: {
                    store.completeOnboarding(page.startDate, page.cycle, page.period)
                    pageStack.replace(Qt.resolvedUrl("MainPage.qml"))
                }
            }
            Label {
                x: Theme.horizontalPageMargin; width: parent.width - 2 * Theme.horizontalPageMargin
                wrapMode: Text.Wrap
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeExtraSmall
                text: qsTr("You can change these later in Settings. To skip, use the pulley menu.")
            }
        }

        PullDownMenu {
            MenuItem {
                text: qsTr("Skip for now")
                onClicked: {
                    store.completeOnboarding("", page.cycle, page.period)
                    pageStack.replace(Qt.resolvedUrl("MainPage.qml"))
                }
            }
        }

        VerticalScrollDecorator {}
    }
}
