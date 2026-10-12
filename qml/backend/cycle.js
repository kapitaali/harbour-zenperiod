.pragma library

function pad(n) { return (n < 10 ? "0" : "") + n }
function iso(y, m, d) { return y + "-" + pad(m) + "-" + pad(d) }
function todayIso() {
    var t = new Date()
    return iso(t.getFullYear(), t.getMonth() + 1, t.getDate())
}
function dateToIso(d) {
    return iso(d.getFullYear(), d.getMonth() + 1, d.getDate())
}
function addDays(isoDate, n) {
    var p = isoDate.split("-")
    var d = new Date(p[0], p[1] - 1, p[2])
    d.setDate(d.getDate() + n)
    return iso(d.getFullYear(), d.getMonth() + 1, d.getDate())
}
// 42 cells (6x7) for a month grid, Monday-first. Empty cells are "".
function monthCells(year, month) {
    var first = new Date(year, month - 1, 1)
    var offset = (first.getDay() + 6) % 7
    var daysInMonth = new Date(year, month, 0).getDate()
    var cells = []
    for (var i = 0; i < offset; ++i) cells.push("")
    for (var d = 1; d <= daysInMonth; ++d) cells.push(iso(year, month, d))
    while (cells.length % 7 !== 0) cells.push("")
    while (cells.length < 42) cells.push("")
    return cells
}
function flowLabel(flow) {
    return ["", qsTr("Spotting"), qsTr("Light"), qsTr("Medium"), qsTr("Heavy")][flow] || ""
}
