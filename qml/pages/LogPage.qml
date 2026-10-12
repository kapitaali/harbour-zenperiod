import QtQuick 2.6
import Sailfish.Silica 1.0
import "../backend/cycle.js" as Cycle

Dialog {
    id: dialog
    objectName: "LogPage"
    property string date: Cycle.todayIso()
    property bool isFuture: date > Cycle.todayIso()
    property var existing: store.getDay(date)

    property int flow: existing.flow || 0
    property int pain: existing.pain || 0
    property string mood: existing.mood || ""
    property string tempText: (existing.logged && !isNaN(existing.temp)) ? String(existing.temp) : ""
    property string notes: existing.notes || ""
    // symptoms stored as comma-separated tokens
    property var checked: (existing.symptoms || "").split(",").filter(function(s) { return s !== "" })

    function hasSymptom(s) { return checked.indexOf(s) !== -1 }
    function toggleSymptom(s) {
        var i = checked.indexOf(s)
        if (i === -1) checked.push(s); else checked.splice(i, 1)
        checkedChanged()
    }

    canAccept: true
    onAccepted: {
        var t = parseFloat(tempText.replace(",", "."))
        if (isNaN(t)) t = NaN
        store.saveDay(date, flow, pain, mood, checked.join(","), t, notes)
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        DialogHeader { id: header; title: dialog.date; acceptText: qsTr("Save"); cancelText: qsTr("Cancel") }

        PullDownMenu {
            MenuItem {
                text: qsTr("Delete entry")
                enabled: dialog.existing.logged
                onClicked: {
                    store.removeDay(dialog.date)
                    pageStack.pop()
                }
            }
        }

        Column {
            id: column
            width: parent.width
            spacing: Theme.paddingMedium

            Label {
                visible: dialog.isFuture
                x: Theme.horizontalPageMargin; width: parent.width - 2 * Theme.horizontalPageMargin
                wrapMode: Text.Wrap
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeSmall
                text: qsTr("Future date: saved for symptoms, but never counted in predictions.")
            }

            ComboBox {
                width: parent.width
                label: qsTr("Flow")
                currentIndex: dialog.flow
                menu: ContextMenu {
                    MenuItem { text: qsTr("None") }
                    MenuItem { text: qsTr("Spotting") }
                    MenuItem { text: qsTr("Light") }
                    MenuItem { text: qsTr("Medium") }
                    MenuItem { text: qsTr("Heavy") }
                }
                onCurrentIndexChanged: dialog.flow = currentIndex
            }

            Slider {
                width: parent.width
                label: qsTr("Pain")
                minimumValue: 0; maximumValue: 10; stepSize: 1
                value: dialog.pain
                valueText: value
                onValueChanged: dialog.pain = Math.round(value)
            }

            ComboBox {
                width: parent.width
                label: qsTr("Mood")
                currentIndex: ["", "calm", "energetic", "irritable", "anxious", "sad"].indexOf(dialog.mood)
                menu: ContextMenu {
                    MenuItem { text: qsTr("—") }
                    MenuItem { text: qsTr("Calm") }
                    MenuItem { text: qsTr("Energetic") }
                    MenuItem { text: qsTr("Irritable") }
                    MenuItem { text: qsTr("Anxious") }
                    MenuItem { text: qsTr("Sad") }
                }
                onCurrentItemChanged: {
                    dialog.mood = ["", "calm", "energetic", "irritable", "anxious", "sad"][currentIndex] || ""
                }
            }

            SectionHeader { text: qsTr("Symptoms") }
            Repeater {
                model: [
                    ["cramps", qsTr("Cramps")], ["headache", qsTr("Headache")],
                    ["backache", qsTr("Backache")], ["bloating", qsTr("Bloating")],
                    ["tender", qsTr("Breast tenderness")], ["fatigue", qsTr("Fatigue")],
                    ["sleep", qsTr("Bad sleep")], ["cravings", qsTr("Cravings")],
                    ["nausea", qsTr("Nausea")]
                ]
                TextSwitch {
                    x: Theme.horizontalPageMargin; width: parent.width - 2 * Theme.horizontalPageMargin
                    text: modelData[1]
                    checked: dialog.hasSymptom(modelData[0])
                    onClicked: dialog.toggleSymptom(modelData[0])
                }
            }

            TextField {
                x: Theme.horizontalPageMargin; width: parent.width - 2 * Theme.horizontalPageMargin
                label: qsTr("Temperature °C (optional)")
                text: dialog.tempText
                inputMethodHints: Qt.ImhFormattedNumbersOnly
                validator: DoubleValidator { bottom: 30; top: 45; decimals: 1 }
                onTextChanged: dialog.tempText = text
            }

            TextArea {
                x: Theme.horizontalPageMargin; width: parent.width - 2 * Theme.horizontalPageMargin
                label: qsTr("Notes")
                text: dialog.notes
                onTextChanged: dialog.notes = text
            }
        }
    }
}
