# harbour-zenperiod — Plan
Privacy-focused PMS / period tracker for SailfishOS (Jolla). Local-only, no cloud, no tracking.

## 1. Goal
Native Silica app for logging periods, PMS symptoms, and viewing predictions. Must work fully offline and prove privacy by requesting no network access.

## 2. Stack
- Qt 5 Quick + Sailfish Silica QML for UI
- Small C++ backend (`CycleStore`) for storage + prediction logic
- SQLite via `QSqlDatabase`, file in Sailjail-private `~/.local/share/<org>/harbour-zenperiod/`
- Notifications via `Nemo.Notifications`
- Build with `sfdk`, qmake `CONFIG += sailfishapp`
- Layout (mirror `harbour-zensors`):
  ```
  harbour-zenperiod/
  ├── harbour-zenperiod.pro
  ├── harbour-zenperiod.desktop
  ├── src/harbour-zenperiod.cpp
  ├── src/cyclestore.{cpp,h}
  ├── qml/harbour-zenperiod.qml
  ├── qml/cover/CoverPage.qml
  ├── qml/pages/MainPage.qml
  ├── qml/pages/CalendarPage.qml
  ├── qml/pages/LogPage.qml
  ├── qml/pages/StatsPage.qml
  ├── qml/pages/SettingsPage.qml
  ├── rpm/harbour-zenperiod.spec
  ├── translations/*.ts
  └── META-INF/
  ```

## 3. Privacy architecture
- `[X-Sailjail]` permissions: `Notifications;Reminders` only. No `Internet`, `Location`, `Contacts`, `Calendar`, `Pictures`.
- No analytics SDKs, no third-party QML imports. Only `Sailfish.Silica`, `QtQuick`, `QtSql`, `Nemo.Notifications` (all Harbour-allowed).
- No account, no network syscalls. Works in airplane mode.
- Secrets/PIN via `Sailfish.Secrets` or salted hash, never plaintext. Note: Jolla C2 has no fingerprint sensor, do not promise biometrics.
- Export/import (JSON/CSV) only on explicit user action to `Documents`. No auto-sync.
- `PRIVACY.md` documents what is stored and why. Test under `sailjail /usr/bin/harbour-zenperiod`, not just unsandboxed IDE run.

## 4. MVP features
- Onboarding: privacy statement, last period start, usual period/cycle length.
- Calendar month view with states: period day, predicted period, ovulation, PMS window, symptom dot, today.
- Day log: flow (none/spotting/light/medium/heavy/clots), pain 0-10, mood, PMS flags, temp, notes. Retroactive edit/delete. Future dates blocked/warned.
- Predictions: current cycle day, days to next period / late flag, next 3 periods, ovulation, PMS window. Moving average of last 3-6 cycles. Disclaimer: not medical advice.
- Stats/history: past periods list, avg/min/max cycle and period length, variability.
- Reminders: period due, PMS starting, log nudge, overdue. All on-device.
- Cover: status + "Log today" action. Pulley menu: log today, go to today, settings.
- Settings: defaults, luteal length, reminder lead time, PIN lock, wipe data.

## 5. Phases
1. Scaffold via Sailfish IDE / `sfdk`, Harbour-prefixed name.
2. Data layer: `days(date PK, flow, pain, mood, symptoms, temp, notes)` + derived cycles. QtTest unit tests.
3. UI pages + cover.
4. Prediction engine + notifications.
5. Privacy hardening + `sailjail` test + airplane-mode test.
6. RPM for `i486` (emulator) + `aarch64` (C2), clean between targets (`sfdk build -- --clean` or equivalent). Harbour submission, consider Chum/OpenRepos second.

## 6. Open questions
- Symptom set size for v1 (minimal vs extended).
- PIN lock in v1 or v2.
- Export/import in v1 or v2.
- Harbour-only vs Chum/OpenRepos.
