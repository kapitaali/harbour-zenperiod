# harbour-zenperiod — User Actions / Test Checklist
Domain primer: Cycle Day 1 = first bleeding day. Cycle length = Day 1 to next Day 1. PMS window = ~5-7 days before next period.

## 1. First run / onboarding
- Open app, read local-only privacy statement (no account, no network).
- Set last period start, usual period length (e.g. 5d), usual cycle length (e.g. 28d).
- Land on main calendar.

## 2. Log period day
- Tap today / any date, log flow: none, spotting, light, medium, heavy, clots.
- Mark period start/end if auto-detect fails.
- Save, re-open, edit same day, delete log.
- Log retroactively (10 / 30 / 90 days ago).
- Attempt future date: expect block or warning.

## 3. Log PMS / symptoms
- Pain: cramps 0-10, backache, headache.
- Physical: bloating, breast tenderness, fatigue, bad sleep, temp.
- Mood: irritable, anxious, sad, calm, energetic.
- Other: cravings, nausea, discharge, exercise, medication, spotting between periods.
- Free-text note.
- Verify persistence after restart + calendar marker.

## 4. Calendar
- Swipe months back/forward, jump to today.
- Verify states: period day, predicted period, ovulation, PMS window, symptom dot, today ring.
- Tap any day for detail view.

## 5. Predictions / home status
- View current cycle day (e.g. Day 14/28), days to next period, late flag if overdue.
- View next 3 predicted periods + ovulation + PMS window.
- Test with regular (28,28,28), irregular (24,32,27), single-cycle, and empty history.

## 6. History / stats
- List past periods (start, end, length).
- Check avg/min/max cycle and period length, variability.
- Delete a cycle, verify predictions recalculate.

## 7. Reminders (local only)
- Toggle period-due, PMS-starting, log nudge, overdue notices.
- Set due date to tomorrow, close app, verify notification fires.
- Check Cover shows status + quick log action.

## 8. Sailfish UX
- Pulley menu, back swipe, cover actions.
- Rotation, ambience (dark/light).

## 9. Settings
- Change cycle/period defaults, luteal length, reminder lead time.
- PIN lock on/off, change PIN, wrong PIN rejected, lock persists after relaunch.
- Language switch if shipped.

## 10. Data / privacy
- Export JSON/CSV to Documents on demand, inspect content.
- Import on fresh install, verify restore.
- Wipe all data, verify empty calendar + reset predictions.
- Airplane mode: all features work.
- Verify `.desktop` has no `Internet` permission.
- Reinstall: data gone, no cloud restore.

## Minimal script (no domain knowledge needed)
1. Set last period 2026-09-14, length 5, cycle 28.
2. Log Sep 14-18 flow, Sep 25 headache + irritable, Oct 12 new start.
3. Expect Cycle Day 1 today, next ~Nov 9, PMS ~Nov 2-8.
4. Edit Oct 12 to spotting only, check prediction shifts/clears.
5. Test export, lock, reminder, wipe.
