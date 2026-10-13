# Harbour submission dossier — harbour-zenperiod 0.1-2

## 1. Identity (copy into dashboard fields)
- Title (pretty name): **ZenPeriod**
- Package: `harbour-zenperiod` (Harbour `harbour-` prefix rule: satisfied)
- Version: 0.1, Release: 2
- License: `GPL-3.0-only` (`LICENSE` file in repo root)
- Category: pick Health / Lifestyle equivalent on the dashboard (TODO: confirm exact category name at submit time)
- URL: TODO — replace `http://example.org/` in `rpm/harbour-zenperiod.spec` with the GitHub repo URL before the 0.2 submission (cosmetic only, not a validator failure)

## 2. Upload artifacts (these exact files)
- `RPMS/SailfishOS-5.1.0.11-aarch64/harbour-zenperiod-0.1-2.aarch64.rpm`
- `RPMS/SailfishOS-5.1.0.11-armv7hl/harbour-zenperiod-0.1-2.armv7hl.rpm`
- The `i486` (emulator) RPM is NOT uploaded.
- No GPG signature needed: Harbour accepts unsigned uploads and Jolla signs on publish.

## 3. Store texts (paste-ready)
**Summary (one line):**
Privacy-focused period and PMS tracker, fully offline.

**Full description:**
Local-only period and PMS tracker. No account, no cloud, no tracking.
Log flow, pain, mood, PMS symptoms, temperature and notes in a native calendar;
predictions for next period, ovulation and PMS window are computed on-device
from your logged data. Cycle predictions are not medical advice.
Everything stays in the app sandbox SQLite file — the app declares zero
Sailjail permissions, not even network access.

## 4. Graphics (done 2026-10-13, in `~/Jolla/store-screenshots/harbour-zenperiod/`)
- `zenperiod-calendar-1080x2400.png`, `zenperiod-settings-1080x2400.png`,
  `zenperiod-log-1080x2400.png` — upscaled 1.5× LANCZOS from 1032×2272 phone
  shots; 1080×2378 clears the 1080×1920 minimum. Upload as screenshots.
- `zenperiod-banner-1080x540.png` — cover banner (icon rose-circle motif +
  tagline), exact 1080×540. Upload to the banner field, not screenshots.

## 5. Privacy (paste link + text)
- Link `PRIVACY.md` from the submission form (required for personal-data apps).
- Permissions statement for reviewers: **zero `[X-Sailjail]` permissions declared**
  (no Internet, Location, Contacts, Calendar, Reminders — not even Notifications,
  which needs none). Notification nudge is on-device only via `Nemo.Notifications`.
- Full policy text (repo `PRIVACY.md`):
  - Day entries (date, flow, pain, mood, symptoms, temperature, notes) plus three
    integers (usual cycle/period/luteal lengths) in a SQLite file under the
    Sailjail-private app data directory.
  - No network permission, so the sandbox blocks exfiltration even on a bug.
  - No third-party SDKs, no telemetry, no account.
  - In-app wipe deletes everything and replays onboarding. Note: uninstalling
    the RPM leaves the data dir behind (standard Sailfish behavior) — wipe is
    the full reset path.

## 6. Changelog 0.1-2 (as shipped in RPM)
- Local-only period tracker scaffold with SQLite store and Silica UI
- Onboarding, ovulation prediction, future-date guard, jump-to-today
- Calendar refresh on store changes; history opens day entries
- Bleeding days with <=2-day gaps merged into one period; spotting ring vs symptom dot
- Wipe is a full factory reset replaying onboarding
- Zero Sailjail permissions (validator-driven fix)

## 7. Validation evidence (all run 2026-10-13, SDK 3.13.5, target 5.1.0.11)
- `sfdk check -s harbour`: **Validation succeeded**, 18/18 sections PASSED,
  both architectures (only note: unstripped-binary WARNING, non-blocking).
- `desktop-file-validate`: clean, exit 0.
- RPM Requires limited to QtCore/Gui/Qml/Quick/Sql + sailfishapp/silica + libc
  on both arches; Provides `application()`; changelog well-formed.
- Binaries verified: ARM aarch64 / ARMv7 (plus i486 emulator build).
- On-device tested on Jolla phone (aarch64): scenarios S1–S10, S12 pass;
  S11 (onboarding replay via wipe) and permission-less notification retest
  (S6/S7) are the last open on-device items — see `META-INF/USER-ACTIONS.md`.

## 8. After acceptance
- Updates go through the same dashboard. Per Harbour FAQ: bumping `Release`
  is NOT enough for an update — increment `Version` in the spec (next: 0.2).
- Keep the per-target `RPMS/` discipline: full clean (`rm` of gitignored
  build artifacts) whenever switching `sfdk` targets, or the wrong-arch
  binary gets packaged silently.

## 9. GitHub repo notes
- Suggested name: `harbour-zenperiod`. Push the full tree as-is (branch `master`).
- `RPMS/`, binaries, `Makefile`, `*.o`, `*.qm` are gitignored build artifacts —
  attach the two release RPMs to a GitHub Release manually (`0.1-2` tag).
- `META-INF/*.png` + `run.txt` are raw test diagnostics; move keepers to
  `store-screenshots/` and consider dropping the rest before going public.
- Never commit signing keys, passphrases, or device IPs (none are in the tree).
