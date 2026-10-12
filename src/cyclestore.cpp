#include "cyclestore.h"

#include <QDate>
#include <QDir>
#include <QSqlDatabase>
#include <QSqlError>
#include <QSqlQuery>
#include <QStandardPaths>
#include <QVariant>
#include <QtMath>
#include <limits>

namespace {
const char *kConn = "zenperiod";
bool validIso(const QString &s) { return QDate::fromString(s, Qt::ISODate).isValid(); }
}

CycleStore::CycleStore(QObject *parent) : QObject(parent) {}

QString CycleStore::dbPath() const
{
    QString base = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    if (base.isEmpty())
        base = QDir::homePath() + "/.local/share/harbour-zenperiod";
    QDir().mkpath(base);
    return base + "/zenperiod.sqlite";
}

bool CycleStore::init()
{
    QSqlDatabase db = QSqlDatabase::addDatabase("QSQLITE", kConn);
    db.setDatabaseName(dbPath());
    if (!db.open())
        return false;
    if (!ensureSchema())
        return false;
    QSqlQuery q(QSqlDatabase::database(kConn));
    q.prepare("SELECT key, value FROM settings");
    if (q.exec()) {
        while (q.next()) {
            const QString k = q.value(0).toString();
            const int v = q.value(1).toInt();
            if (k == "usualCycle" && v >= 15 && v <= 60) m_usualCycle = v;
            if (k == "usualPeriod" && v >= 1 && v <= 14) m_usualPeriod = v;
        }
    }
    return true;
}

bool CycleStore::ensureSchema() const
{
    QSqlQuery q(QSqlDatabase::database(kConn));
    if (!q.exec("CREATE TABLE IF NOT EXISTS days("
                "date TEXT PRIMARY KEY, flow INTEGER NOT NULL DEFAULT 0,"
                "pain INTEGER NOT NULL DEFAULT 0, mood TEXT NOT NULL DEFAULT '',"
                "symptoms TEXT NOT NULL DEFAULT '', temp REAL NOT NULL DEFAULT -999,"
                "notes TEXT NOT NULL DEFAULT '')"))
        return false;
    if (!q.exec("CREATE TABLE IF NOT EXISTS settings(key TEXT PRIMARY KEY, value TEXT)"))
        return false;
    return true;
}

void CycleStore::setUsualCycle(int v)
{
    if (v < 15 || v > 60 || v == m_usualCycle) return;
    m_usualCycle = v;
    QSqlQuery q(QSqlDatabase::database(kConn));
    q.prepare("INSERT OR REPLACE INTO settings(key, value) VALUES('usualCycle', ?)");
    q.addBindValue(v);
    q.exec();
    emit settingsChanged();
    emit dataChanged();
}

void CycleStore::setUsualPeriod(int v)
{
    if (v < 1 || v > 14 || v == m_usualPeriod) return;
    m_usualPeriod = v;
    QSqlQuery q(QSqlDatabase::database(kConn));
    q.prepare("INSERT OR REPLACE INTO settings(key, value) VALUES('usualPeriod', ?)");
    q.addBindValue(v);
    q.exec();
    emit settingsChanged();
    emit dataChanged();
}

QVariantMap CycleStore::getDay(const QString &isoDate) const
{
    QVariantMap m;
    m["date"] = isoDate;
    m["flow"] = 0; m["pain"] = 0; m["mood"] = "";
    m["symptoms"] = ""; m["temp"] = std::numeric_limits<double>::quiet_NaN();
    m["notes"] = ""; m["logged"] = false;
    if (!validIso(isoDate)) return m;
    QSqlQuery q(QSqlDatabase::database(kConn));
    q.prepare("SELECT flow, pain, mood, symptoms, temp, notes FROM days WHERE date=?");
    q.addBindValue(isoDate);
    if (q.exec() && q.next()) {
        m["flow"] = q.value(0).toInt();
        m["pain"] = q.value(1).toInt();
        m["mood"] = q.value(2).toString();
        m["symptoms"] = q.value(3).toString();
        const double t = q.value(4).toDouble();
        if (t > -900) m["temp"] = t;
        m["notes"] = q.value(5).toString();
        m["logged"] = true;
    }
    return m;
}

bool CycleStore::saveDay(const QString &isoDate, int flow, int pain,
                         const QString &mood, const QString &symptoms,
                         double temp, const QString &notes)
{
    if (!validIso(isoDate)) return false;
    flow = qBound(0, flow, 4);
    pain = qBound(0, pain, 10);
    if (qIsNaN(temp)) temp = -999;
    if (flow == 0 && pain == 0 && mood.isEmpty() && symptoms.isEmpty()
        && temp < -900 && notes.trimmed().isEmpty())
        return removeDay(isoDate);
    QSqlQuery q(QSqlDatabase::database(kConn));
    q.prepare("INSERT OR REPLACE INTO days(date, flow, pain, mood, symptoms, temp, notes)"
              " VALUES(?, ?, ?, ?, ?, ?, ?)");
    q.addBindValue(isoDate);
    q.addBindValue(flow);
    q.addBindValue(pain);
    q.addBindValue(mood);
    q.addBindValue(symptoms);
    q.addBindValue(temp);
    q.addBindValue(notes);
    const bool ok = q.exec();
    if (ok) emit dataChanged();
    return ok;
}

bool CycleStore::removeDay(const QString &isoDate)
{
    if (!validIso(isoDate)) return false;
    QSqlQuery q(QSqlDatabase::database(kConn));
    q.prepare("DELETE FROM days WHERE date=?");
    q.addBindValue(isoDate);
    const bool ok = q.exec();
    if (ok) emit dataChanged();
    return ok;
}

// All logged days with flow>=2, collapsed to starts.
QVariantList CycleStore::loggedPeriodStarts() const
{
    QSqlQuery q(QSqlDatabase::database(kConn));
    q.exec("SELECT date FROM days WHERE flow>=2 ORDER BY date ASC");
    QStringList periodDays;
    while (q.next()) periodDays << q.value(0).toString();
    QSet<QString> daySet = QSet<QString>::fromList(periodDays);
    QVariantList starts;
    for (const QString &d : periodDays) {
        const QDate date = QDate::fromString(d, Qt::ISODate);
        if (!date.isValid()) continue;
        const QString prev = date.addDays(-1).toString(Qt::ISODate);
        if (!daySet.contains(prev))
            starts << d;
    }
    return starts;
}

QVariantList CycleStore::periodStarts() const { return loggedPeriodStarts(); }

QVariantMap CycleStore::predictions() const
{
    QVariantMap p;
    const QVariantList starts = loggedPeriodStarts();
    QList<QDate> dates;
    for (const QVariant &v : starts) {
        const QDate d = QDate::fromString(v.toString(), Qt::ISODate);
        if (d.isValid()) dates << d;
    }
    double avgCycle = m_usualCycle;
    if (dates.size() >= 2) {
        const int n = qMin(dates.size() - 1, 6);
        double sum = 0;
        for (int i = dates.size() - n; i < dates.size(); ++i)
            sum += dates[i - 1].daysTo(dates[i]);
        avgCycle = sum / n;
    }
    const QDate today = QDate::currentDate();
    const QDate lastStart = dates.isEmpty() ? QDate() : dates.last();
    const QDate next = lastStart.isValid()
        ? lastStart.addDays(qRound(avgCycle))
        : today.addDays(m_usualCycle);
    const int cycleDay = lastStart.isValid() ? lastStart.daysTo(today) + 1 : -1;
    const int daysToNext = today.daysTo(next);
    const QDate pmsStart = next.addDays(-7);
    const QDate pmsEnd = next.addDays(-1);

    p["avgCycle"] = avgCycle;
    p["avgPeriod"] = m_usualPeriod;
    p["lastStart"] = lastStart.isValid() ? lastStart.toString(Qt::ISODate) : "";
    p["nextPeriod"] = next.toString(Qt::ISODate);
    // Second and third predictions for the history page.
    p["next2"] = next.addDays(qRound(avgCycle)).toString(Qt::ISODate);
    p["next3"] = next.addDays(2 * qRound(avgCycle)).toString(Qt::ISODate);
    p["pmsStart"] = pmsStart.toString(Qt::ISODate);
    p["pmsEnd"] = pmsEnd.toString(Qt::ISODate);
    p["cycleDay"] = cycleDay;
    p["daysToNext"] = daysToNext;
    p["hasHistory"] = dates.size() >= 2;
    return p;
}

QVariantList CycleStore::history(int limit) const
{
    const QVariantList starts = loggedPeriodStarts();
    QList<QDate> dates;
    for (const QVariant &v : starts) {
        const QDate d = QDate::fromString(v.toString(), Qt::ISODate);
        if (d.isValid()) dates << d;
    }
    QVariantList out;
    const int from = qMax(0, dates.size() - qMax(1, limit));
    for (int i = dates.size() - 1; i >= from; --i) {
        QVariantMap m;
        m["start"] = dates[i].toString(Qt::ISODate);
        if (i + 1 < dates.size())
            m["cycleLength"] = dates[i].daysTo(dates[i + 1]);
        else
            m["cycleLength"] = 0;
        out << m;
    }
    return out;
}

QVariantMap CycleStore::stats() const
{
    QVariantMap s;
    const QVariantList starts = loggedPeriodStarts();
    QList<int> lens;
    QList<QDate> dates;
    for (const QVariant &v : starts) {
        const QDate d = QDate::fromString(v.toString(), Qt::ISODate);
        if (d.isValid()) dates << d;
    }
    for (int i = 1; i < dates.size(); ++i)
        lens << dates[i - 1].daysTo(dates[i]);
    if (lens.isEmpty()) {
        s["count"] = dates.size();
        s["avg"] = 0; s["min"] = 0; s["max"] = 0;
        return s;
    }
    double sum = 0;
    int mn = lens.first(), mx = lens.first();
    for (int l : lens) { sum += l; mn = qMin(mn, l); mx = qMax(mx, l); }
    s["count"] = dates.size();
    s["avg"] = sum / lens.size();
    s["min"] = mn;
    s["max"] = mx;
    return s;
}

bool CycleStore::isPredictedPeriod(const QString &isoDate) const
{
    const QDate d = QDate::fromString(isoDate, Qt::ISODate);
    if (!d.isValid()) return false;
    const QVariantMap p = predictions();
    const QDate next = QDate::fromString(p["nextPeriod"].toString(), Qt::ISODate);
    if (!next.isValid()) return false;
    const int cyc = qMax(1, qRound(p["avgCycle"].toDouble()));
    for (int k = 0; k < 3; ++k) {
        const QDate s = next.addDays(k * cyc);
        if (d >= s && d < s.addDays(m_usualPeriod))
            return true;
    }
    return false;
}

bool CycleStore::isPredictedPms(const QString &isoDate) const
{
    const QDate d = QDate::fromString(isoDate, Qt::ISODate);
    if (!d.isValid()) return false;
    const QVariantMap p = predictions();
    const QDate next = QDate::fromString(p["nextPeriod"].toString(), Qt::ISODate);
    if (!next.isValid()) return false;
    const int cyc = qMax(1, qRound(p["avgCycle"].toDouble()));
    for (int k = 0; k < 3; ++k) {
        const QDate s = next.addDays(k * cyc - 7);
        if (d >= s && d < s.addDays(7))
            return true;
    }
    return false;
}

void CycleStore::clearAll()
{
    QSqlQuery q(QSqlDatabase::database(kConn));
    q.exec("DELETE FROM days");
    emit dataChanged();
}
