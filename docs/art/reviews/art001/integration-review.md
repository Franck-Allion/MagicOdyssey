# ART-001-T01 - Observatory artwork integration review

Date: 2026-11-11. Technical experiment: completed. Artistic status: WIP, NOT APPROVED.
Recommendation: **REQUEST_BACKGROUND_REVISION** (REVISE).

## Scope and reproduction

Isolated scene: `res://scenes/ui/art001_integration_test.tscn`.
Script: `res://scripts/presentation/art001_integration_test.gd`.
The experiment extends the existing premium shell only to reuse its native Theme, text, hero, card and crest helpers. It overrides layout and suppresses the inherited procedural background. No existing shell, Theme, main scene, project settings, domain, catalog, harness or normative specification was edited. All sample names, stats and card values are visual fixtures, not game definitions. No BoardSlot component or gameplay behavior was introduced.

Inspector preset values: 0 = A/background, 1 = B/typical (default), 2 = C/full. CLI `--preset=N` overrides the inspector. `board_darkening` is exported, default 0.30, and applies only to the combat-region scrim in B/C. The background-only preset has no scrim or UI.

Source: `assets/_source/lot1/battlefield/wip/mo_battlefield_sundered_observatory_bg_wip_v02.png`.
Source dimensions: 1376x768. SHA256 before and after: `508ff955d418998caf699b90d279a6916d1bdc284a9ca4bb46f5c2efc4eb11d3`.
Native TextureRect uses KEEP_ASPECT_COVERED and IGNORE_SIZE expansion in a 1920x1080 virtual reference. Scale is 1.40625; the resulting 1935x1080 image loses 7.5 output pixels from each side (about 5.33 source pixels per side). No vertical crop, perspective warp or source edit. No runtime derivative was needed. The source remains WIP and was already untracked at task start; Godot created its import metadata.

## A. Composition

The artwork establishes a convincing observatory, but its platform is not a natural support for this grid. In background_only_1080p.png, the visible floor ellipse begins around y=610, with its luminous center near y=750 and its front rim close to y=1000. The grid must occupy y=263..781 to retain readable crests and a hand beginning at y=816. Both opponent rows therefore sit over walls, arches and instruments; only the lower player row lies fully over the illustrated floor.

The 6x4 grid is strictly rectangular and screen-aligned: six 164x120 slots per row; x=478+185*column; row tops 263,389,535,661. All columns align, with 21px horizontal gaps, 6px gaps inside camps and a 26px central camp gap. No slot is curved, resized per row or projected toward the circle.

The grid reads as a functional floating tactical overlay, but it looks pasted over the room rather than resting naturally in the arena. Moving it down enough to put the opponent on the floor would collide with the hand; compressing four rows into the visible platform depth would reduce portrait/stat readability. The 30% local navy scrim calms the center without erasing the environment, but it cannot correct that geometry mismatch.

## B. Tactical readability

- Empty slots: visible at 1080p, with translucent interiors and existing camp-colored edges. Artwork remains visible; bright floor markings compete more with blue player outlines than with opaque crest faces.
- Occupied slots: all 24 shield studies remain distinct. Warm opponent/cool player colors are reinforced by explicit O/P and ATTACK/DEFENSE row labels.
- ATK/HP: visible at bottom-left/bottom-right on every crest, 28 reference pixels (about 18.7 physical pixels at 720p). No stat-to-stat collisions observed.
- Selected protection samples: AR 2 / SH 3 badges on eight crests, with dark backing. At 720p these are about 12px and tight; badges obscure the very top of some helmet studies. Final badge placement should move off the portrait before production acceptance.
- Stress test: all four rows and six columns remain distinguishable with 24 occupied slots; neither side panel crosses a slot. Static fixture inspection is not a test of selection, hover, animation or input ergonomics.

## C. Screen ergonomics

Top hero: opaque frame at x=650..1270, y=115..231; readable against the celestial opening. The brightest moon is mostly above/right of this panel, so it does not obscure HP/mana/deck values.

The final crest bottoms reach approximately y=779; slots end y=781. The hand starts y=816, leaving 35 reference pixels (about 23px at 720p) of clearance. All seven card faces are fully visible through y=1056. The hand is a separate 0.9-scale native Control group using existing card helpers, not new frames. It spans roughly x=290..1617, while the player hero stays x=42..240. The left inspector and right action panel remain outside the grid bounds x=478..1567. No clipped slots, hand faces or ATK/HP labels were observed.

At 1080p main values are comfortably readable. At 720p crest values and hero counters remain readable; small card fixture notes, deck labels and protection badges are denser and should receive later typography review. Seven cards obscure much of the front platform rim, even though hand clearance is technically sound.

## D. Artistic assessment

The broken dome, moon, stone arches and astronomical instruments remain recognizable in B and C. The scene feels like a fantasy game environment rather than the earlier procedural gallery. However, the strongest painted focal point is the blue floor circle under the player's lower row and hand, while the opponent floats above the horizon line. This gives the player rows a stronger environmental anchor than the opponent rows.

The star/rune network adds contrast behind the lower slots. The scrim helps; further darkening would hide more of the arena and still would not solve its vertical placement. At full occupancy, the circle center is partially obscured, while its curved rim stays visible beside/below the hand. The bright moon is atmospheric rather than a text readability failure because hero text has its own opaque panel.

A small pale four-point mark is visible in the source's bottom-right corner and remains visible in captures; determine its intended provenance/treatment during art approval. It was not edited out for this experiment.

## E. Recommendation

**REQUEST_BACKGROUND_REVISION**.

Specific issue: the platform ellipse is too low and vertically compressed by the low room-view camera to support the required four readable tactical rows above the hand. Request a more elevated view and a platform/floor area extending higher into the central composition, with a quieter center behind the grid. Preserve the observatory architecture and atmosphere. Use the current grid safe area (approximately x=478..1567, y=263..781) and hand safe area (y>=816) as composition guides for a new art proposal, without baking UI into the art.

This recommendation is based on the B/C overlays, not on a requirement that the rectangle fit inside a circle. The circle may remain decorative, but the current floor/horizon alignment makes the opponent rows read as wall-mounted HUD. A layout-only shift would trade this issue for hand overlap or smaller unreadable crests. No source revision has been made, and no background is approved by this report.

## Evidence - inspected real Godot renders

| File | Verified PNG dimensions | Preset | Capture exit |
|---|---|---|---|
| [background_only_1080p.png](background_only_1080p.png) | 1920x1080 | A / 0 | 0 |
| [typical_combat_1080p.png](typical_combat_1080p.png) | 1920x1080 | B / 1 | 0 |
| [full_board_1080p.png](full_board_1080p.png) | 1920x1080 | C / 2 | 0 |
| [full_board_720p.png](full_board_720p.png) | 1280x720 | C / 2 | 0 |

All four images were opened and visually inspected. Captures use a real graphical Godot SubViewport with explicit pixel dimensions, not headless screenshots, generated mockups or resized images. `capture.gd` is included here for reproducibility; it waits for frame_post_draw and saves the actual rendered viewport texture. Exact SubViewport sizing avoids this desktop's native-window title-bar size limit.

## Verification commands and actual results

Executable: `D:\Temp\Godot_v4.7.2-stable_win64.exe`. Working directory: `D:\Dev\MagicOdyssey`. Banner: `Godot Engine v4.7.2.stable.official.ed1daf0bf`.

Processes were invoked using PowerShell `Start-Process -Wait -PassThru`, inspecting `.ExitCode` and console output.

| Arguments / command | Actual output | Exit |
|---|---|---|
| `--headless --editor --path . --quit` | Filesystem scan/import and editor layout DONE; no errors | 0 |
| `--headless --path . --script res://scripts/tests/test_runner.gd` | Total Assertions: 14; Passed: 14; Failed: 0; RESULT: ALL TESTS PASSED | 0 |
| `--headless --path . res://scenes/ui/art001_integration_test.tscn --quit-after 2` | Engine banner only; no scene/parser/runtime errors | 0 |
| `--headless --path . res://scenes/ui/theme_showcase.tscn --quit-after 2` | Engine banner only; original Theme/showcase usable | 0 |
| `git diff --check` | No formatting errors | 0 |

Capture commands (graphical, no --headless):

```powershell
$exe = 'D:\Temp\Godot_v4.7.2-stable_win64.exe'
$cases = @(
    @('background_only_1080p',1920,1080,0),
    @('typical_combat_1080p',1920,1080,1),
    @('full_board_1080p',1920,1080,2),
    @('full_board_720p',1280,720,2)
)
foreach ($case in $cases) {
    $process = Start-Process $exe -WindowStyle Hidden -Wait -PassThru -ArgumentList @(
        '--path','D:\Dev\MagicOdyssey',
        '--script','res://docs/art/reviews/art001/capture.gd','--',
        "D:/Dev/MagicOdyssey/docs/art/reviews/art001/$($case[0]).png",
        $case[1],$case[2],"--preset=$($case[3])"
    )
    $process.ExitCode
}
```

Manual scene launch: use the supplied executable with `--path . --resolution 1280x720 res://scenes/ui/art001_integration_test.tscn -- --preset=2`; repeat with presets 0/1. Editor inspection can instead select the exported preset before running the scene.

Git status: only untracked experiment/evidence files and the pre-existing untracked artwork directory; no tracked project files modified. Generated `.gd.uid` and PNG import metadata may appear after editor import. Source SHA256 is unchanged. P005/P006 and ART-001 approval status are untouched.
