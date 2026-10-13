# ZenPeriod (`harbour-zenperiod`)

Privacy-focused period and PMS tracker for SailfishOS (Jolla phones).
Local-only: no account, no cloud, no tracking, no analytics — and not even
a network permission to track *with*.

(Screenshots: see the GitHub Releases page and `META-INF/` test shots.)

## Features

- **Month calendar** with per-day states: logged period (solid), predicted
  period (tint), PMS window (shade), predicted ovulation (bar), spotting
  (hollow ring), other symptoms (dot). Tap any day to log it.
- **Day log**: flow (None / Spotting / Light / Medium / Heavy), pain 0–10,
  mood, 9 PMS symptoms, temperature, free notes. Retroactive logging supported;
  future dates are stored but never feed predictions.
- **Predictions** (on-device, not medical advice): current cycle day,
  days-to-next / days-late, next 3 periods, ovulation date, PMS window.
- **History**: past periods with length and cycle interval, averages and range.
- **Onboarding**: first-run setup (last period start, usual lengths, skip path).
- **Local nudge**: due-tomorrow / due-today / overdue notification on app open
  (no background daemon; full reminders are a later milestone).
- **Cover**: days-to-period at a glance + quick "log today" action.
- **Settings**: usual cycle (15–60d), period (1–14d) and luteal phase (10–18d)
  lengths, full wipe. A build stamp at the bottom identifies the running build.

### The counting rules (read this before testing)

- Only **Light and stronger** (flow ≥ 2) make a period. **Spotting never
  starts one** — it is drawn as a ring and ignored by history/predictions.
- Bleeding days separated by **≤ 2 unlogged days count as one period**, so a
  skipped logging day never seeds a bogus 2-day "cycle".
- Future-dated entries are stored for symptoms but excluded from predictions.
- With fewer than 2 logged starts, predictions fall back to your usual lengths.

### Privacy model

- One SQLite file in the Sailjail-private app data directory. That's the whole
  backend — see `PRIVACY.md`.
- **Zero `[X-Sailjail]` permissions declared** (verified by the Harbour RPM
  validator: 18/18 sections green). No `Internet`, so exfiltration is
  technically impossible, not just promised.
- Uninstalling the RPM leaves the data dir behind (standard Sailfish
  behavior). In-app **Wipe** is the true factory reset: entries, settings,
  and onboarding all cleared, Welcome replays.

## Build

Requirements: Sailfish SDK 3.x with `sfdk` on PATH and Docker access
(`sg docker -c '…'` if your shell predates the `docker` group).

```sh
cd harbour-zenperiod

# Phone (64-bit, e.g. Jolla C2) — the default target
sfdk build   # → RPMS/SailfishOS-*-aarch64/harbour-zenperiod-*.aarch64.rpm

# Older 32-bit devices
sfdk build-shell make distclean   # or: rm -f harbour-zenperiod *.o moc_*.cpp Makefile .qmake.stash documentation.list
sfdk -c target=SailfishOS-5.1.0.11-armv7hl build

# Emulator
sfdk -c target=SailfishOS-5.1.0.11-i486 build
```

**Target-switching rule:** `sfdk build` compiles in place. Always fully clean
when changing targets (host-side `rm` of the gitignored artifacts is more
reliable than `make distclean` inside the engine) and verify with
`file harbour-zenperiod` before packaging — otherwise the previous
architecture's binary ships silently. `output-prefix = ./RPMS` keeps each
target's RPMs in their own directory.

Validate before submitting:

```sh
sfdk -c device= check -s harbour RPMS/<target>/harbour-zenperiod-*.rpm
```

## Install

On the phone (Developer mode on, SSH key deployed), copy the matching RPM
(`aarch64` for Jolla C2 and other 64-bit devices, `armv7hl` for 32-bit) and:

```sh
pkill -x harbour-zenperiod                       # close a running copy first
sudo pkcon install-local -y harbour-zenperiod-*.rpm
```

Emulator fallback (when engine→emulator routing fails):

```sh
KEY=~/SailfishOS/vmshare/ssh/private_keys/sdk
scp -P 2223 -i $KEY RPMS/<target>/*.i486.rpm defaultuser@127.0.0.1:~/
ssh -p 2223 -i $KEY defaultuser@127.0.0.1 \
  'sudo pkcon install-local -y ~/harbour-zenperiod-*.i486.rpm'
```

## Use

1. First launch shows **Welcome**: pick last period start, set usual lengths
   (or Skip from the pulley menu). reinstalling alone never replays it —
   use Wipe.
2. Tap a calendar day → log flow/symptoms → Save. Dots, rings and fills
   update immediately; History entries open their day on tap.
3. Pull-down menu: Log today, jump to Today, History, Settings.
4. Tester walkthroughs live in `META-INF/USER-ACTIONS.md`
   (anchored scenarios S1–S12); the Harbour dossier in
   `META-INF/SUBMISSION.md` doubles as the release checklist.

## Project layout

```
harbour-zenperiod/
├── harbour-zenperiod.pro / .desktop   # qmake (CONFIG += sailfishapp), zero-permission sandbox entry
├── src/cyclestore.{h,cpp}             # SQLite store + prediction engine, exposed to QML as "store"
├── src/harbour-zenperiod.cpp          # entry point
├── qml/harbour-zenperiod.qml          # ApplicationWindow, onboarding-vs-main routing, cover wiring
├── qml/pages/                         # Main, Onboarding, Log, History, Settings
├── qml/cover/CoverPage.qml            # multitasking cover + guarded log action
├── qml/backend/cycle.js               # date helpers (month grid, ISO-today)
├── rpm/                               # Harbour spec + changelog generator
├── icons/                             # app icon (86–172px) + SVG source
├── translations/                      # .ts sources (English in code; lrelease runs at build)
├── META-INF/                          # plan, test checklist, run logs, submission dossier
└── RPMS/ (gitignored)                 # per-target build output
```

Only Harbour-allowed libraries (`Qt5Sql` et al.), QML imports
(`Sailfish.Silica`, `QtQuick`, `Nemo.Notifications`) and RPM dependencies
are used — the validator confirms this on every release build.

## License

GPL-3.0-only — see `LICENSE`.
