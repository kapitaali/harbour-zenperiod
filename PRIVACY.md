# Privacy

- Data stored: day entries (date, flow, pain, mood, symptoms, temperature, notes) plus two integers (usual cycle/period length). SQLite file under the Sailjail-private app data directory.
- No network permission declared, so the sandbox blocks exfiltration even on a bug.
- No Sailjail permissions declared at all — not even for notifications, which need none. The sandbox still isolates the app's data dir.
- No third-party SDKs, no telemetry.
- Export only if a future version adds explicit file export; v1 has none.
- Wipe via Settings deletes all day rows, resets usual lengths to defaults, and replays onboarding. Note: uninstalling the RPM does not delete the data dir (standard Sailfish behavior) — in-app wipe is the full reset path.
