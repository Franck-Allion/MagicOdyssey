# P004 UI baseline

Reference viewport: **1920×1080**. Minimum supported viewport: **1280×720**.
Theme: `res://resources/themes/fantasy_theme.tres`.
Showcase: `res://scenes/ui/theme_showcase.tscn` (run this scene directly).
Tokens: `res://scripts/presentation/ui_design_tokens.gd`.

## Design contract

Charcoal atmospheric background, iron panels, restrained bronze edges, warm parchment text and gold headings. Native StyleBoxFlat surfaces are the reusable foundation; illustrated atmosphere and metal texture integration follow in P054. No external fonts or artwork.

The Theme is the single source of palette literals, including custom `DesignTokens` colors and spacing. GDScript consumers use `UIDesignTokens.color_token(&"rare")` and `UIDesignTokens.spacing(&"md")`; never copy rarity literals into scripts. Theme label variations reference the same selected palette values. Spacing scale: xs 8, sm 16, md 24, lg 32, xl 48 reference pixels.

| Rarity token | Identity | Hex |
|---|---|---|
| common | White | #F2F0EB |
| uncommon | Blue | #86BDFA |
| rare | Red | #F28B88 |
| epic | Violet | #C5A2F5 |
| legendary | Gold | #E8C675 |

| Semantic token | Hex | Additional cue |
|---|---|---|
| player | #85C9E8 | [P] PLAYER |
| opponent | #EF9B91 | [O] OPPONENT |
| neutral | #BBB6AC | [-] INACTIVE |
| selected | #F3D28D | [+] SELECTED; gold focus outline |
| valid | #A8D6AE | [OK] VALID |
| invalid | #ECA79D | [X] INVALID; disabled button state |

## Typography and readability

Use Godot's default font. ScreenTitle 58, SectionHeading 28, CardTitle 26, BodyText 24, SecondaryText 22, TacticalNumber 32, TooltipText 22 reference pixels. At 720p these scale to approximately 39, 19, 17, 16, 15, 21 and 15 physical pixels with the project's existing canvas stretch. Use at least 4.5:1 contrast for body/tactical text against dark panels; never put rarity text on an equally bright surface. Labels and explicit stat names accompany colors. Preserve words and values rather than shrinking below readable size.

Button variants: default primary and SecondaryButton. Normal bronze border, brighter filled hover, dark inset pressed state, muted disabled surface, and a separate three-pixel gold keyboard focus outline. Shared native TooltipPanel/TooltipLabel styles support actual tooltips; the permanent sample keeps the content visible for inspection. All values in the scene are presentation fixtures.

## Manual inspection procedure

Run from repository root (repeat for each resolution):

```powershell
& 'D:\Temp\Godot_v4.7.2-stable_win64.exe' --path . --resolution 1920x1080 res://scenes/ui/theme_showcase.tscn
& 'D:\Temp\Godot_v4.7.2-stable_win64.exe' --path . --resolution 1280x720 res://scenes/ui/theme_showcase.tscn
```

- Check title, panel, rarity labels, tooltip and footer for clipping or overlaps.
- Check tactical values and explanatory text at actual display size.
- Hover and press both enabled buttons; verify distinct states.
- Tab through enabled controls and check the gold focus ring; disabled button must be skipped.
- Verify camp and action states remain understandable in grayscale through text markers.
- Hover a button to inspect the native tooltip.

## Technical evidence

Engine executable: `D:\Temp\Godot_v4.7.2-stable_win64.exe`; output banner `Godot Engine v4.7.2.stable.official.ed1daf0bf`.
Processes were launched with PowerShell `Start-Process -NoNewWindow -Wait -PassThru` to obtain real process ExitCode values.

| Arguments | Output | Exit |
|---|---|---|
| `--headless --editor --path . --quit` | Filesystem/editor initialization DONE; no errors | 0 |
| `--headless --path . --script res://scripts/tests/test_runner.gd` | Total Assertions: 14; Passed: 14; Failed: 0; RESULT: ALL TESTS PASSED | 0 |
| `--headless --path . res://scenes/ui/theme_showcase.tscn --quit-after 2` | Engine banner; no parser, missing resource or runtime errors | 0 |

The registered suite currently covers the harness itself, not combat or UI acceptance criteria.

## Graphical baseline evidence

Actual graphical Godot viewport captures saved as `baseline-1080p.png` (1920×1080) and `baseline-720p.png` (1280×720). Both graphical processes exited 0. A temporary capture script outside the repository instanced the real showcase, waited for rendering, and saved `root.get_texture().get_image()`; these are not generated mockups.

Capture invocation used the supplied executable with `--path D:\Dev\MagicOdyssey --resolution <size> --script D:\Temp\magicodyssey_p004_capture.gd -- <absolute PNG path>`.

- Resolution layout inspection: PASS at both sizes; title, panel, buttons, labels, tooltip sample and footer fit without overlap or clipping.
- Hover/pressed/native tooltip interaction review: NOT_RUN (static capture does not exercise mouse interactions).
- Keyboard focus navigation review: NOT_RUN (static capture does not exercise Tab navigation).
- Human artistic sign-off: pending; the native baseline precedes commissioned production artwork.
