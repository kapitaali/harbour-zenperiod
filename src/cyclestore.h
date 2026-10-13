#ifndef CYCLESTORE_H
#define CYCLESTORE_H

#include <QObject>
#include <QSet>
#include <QVariantList>
#include <QVariantMap>

// Flow levels: 0 none, 1 spotting, 2 light, 3 medium, 4 heavy.
// A "period day" is flow >= 2. A period starts on a period day whose two
// previous days were both period-free: isolated unlogged gap days do not
// split one period into two (and so never seed bogus 2-day "cycles").
class CycleStore : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int usualCycle READ usualCycle WRITE setUsualCycle NOTIFY settingsChanged)
    Q_PROPERTY(int usualPeriod READ usualPeriod WRITE setUsualPeriod NOTIFY settingsChanged)
    Q_PROPERTY(int usualLuteal READ usualLuteal WRITE setUsualLuteal NOTIFY settingsChanged)

public:
    explicit CycleStore(QObject *parent = nullptr);
    bool init();

    int usualCycle() const { return m_usualCycle; }
    int usualPeriod() const { return m_usualPeriod; }
    int usualLuteal() const { return m_usualLuteal; }
    void setUsualCycle(int v);
    void setUsualPeriod(int v);
    void setUsualLuteal(int v);

    Q_INVOKABLE QVariantMap getDay(const QString &isoDate) const;
    Q_INVOKABLE bool saveDay(const QString &isoDate, int flow, int pain,
                             const QString &mood, const QString &symptoms,
                             double temp, const QString &notes);
    Q_INVOKABLE bool removeDay(const QString &isoDate);
    Q_INVOKABLE QVariantList periodStarts() const;
    Q_INVOKABLE QVariantMap predictions() const;
    Q_INVOKABLE QVariantList history(int limit = 12) const;
    Q_INVOKABLE QVariantMap stats() const;
    Q_INVOKABLE bool isPredictedPeriod(const QString &isoDate) const;
    Q_INVOKABLE bool isPredictedPms(const QString &isoDate) const;
    Q_INVOKABLE bool isPredictedOvulation(const QString &isoDate) const;
    Q_INVOKABLE bool isOnboarded() const;
    Q_INVOKABLE void completeOnboarding(const QString &lastStart, int cycle, int period);
    Q_INVOKABLE QString buildStamp() const;
    Q_INVOKABLE void clearAll();

Q_SIGNALS:
    void dataChanged();
    void settingsChanged();

private:
    QString dbPath() const;
    bool ensureSchema() const;
    QVariantList loggedPeriodStarts() const;
    int m_usualCycle = 28;
    int m_usualPeriod = 5;
    int m_usualLuteal = 14;
};

#endif
