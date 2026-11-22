# P008 Windows technical follow-up - 2026-11-22

**PASS - the previously blocked automated desktop follow-up is resolved.** Owner artistic approval was already final; see [sign-off](../owner-sign-off-2026-11-22.md). No second artistic review was requested or inferred from these tests.

Current checkout: `72de243`. Production code, artwork and card definitions are unchanged. The standard Windows exporter ran successfully, exit **0**, producing an embedded `build/windows/MagicOdyssey.exe`. The test harness copied only that executable to an isolated temporary directory and shell-launched it.

| Actual client | 24 occupied slots, hover/click and selection switching/toggle | Raised hand-card interaction/isolation | End Turn mouse + Space | ESC |
|---|---|---|---|---|
| Default 1888x956 | PASS | PASS | PASS | exit 0 |
| 1920x1080 | PASS | PASS | PASS | exit 0 |
| 1280x720 | PASS | PASS | PASS | exit 0 |

These are actual Windows pointer/keyboard events, not injected Godot signals. Foreground guards did not block this run. Harness process exit **0**; all three runs terminated cleanly with no remaining MagicOdyssey process. No engine warning or script error appears in the three desktop logs. The owner's previous visual acceptance remains an independent explicit decision.

Evidence: [export log](export.log), [desktop summary](windows.log), [machine-readable results](results.json), [1080p board](desktop/desktop-1920x1080.png), [720p board](desktop/desktop-1280x720.png), [720p selected slot](desktop/desktop-1280x720-selected-player-attack.png), [720p raised-hand isolation](desktop/desktop-1280x720-raised-hand-no-slot-leak.png), [1080p End Turn](desktop/desktop-1920x1080-button-pressed.png). Native-size captures were inspected; they show the actual V05/Bahnschrift production preview.

Commands executed:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File scripts/build_windows.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File scripts/tests/playtest_windows.ps1 -TokenScenario full_board -BattlefieldSlots -UtilityHud -ReviewDir docs/art/reviews/p008/final-windows-2026-11-22/desktop
```

The F04 blocked attempts remain unchanged historical evidence; they are not relabeled PASS. This new follow-up supplies the missing current OS-input evidence. Existing numerical limitations, reduced 99 height and the separate approved status/equipment icon dependency remain documented. No fresh full native/gameplay suite was run for this documentation-only task; the recorded F04 native suite remains historical evidence. G1 remains NOT_VALIDATED.
