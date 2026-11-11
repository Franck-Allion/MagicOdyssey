# P004 UI baseline

Reference viewport: **1920Ãƒâ€”1080**. Minimum supported viewport: **1280Ãƒâ€”720**.
Theme: `res://resources/themes/fantasy_theme.tres`.
Showcase: `res://scenes/ui/theme_showcase.tscn` (run this scene directly).
Tokens: `res://scripts/presentation/ui_design_tokens.gd`.

## Premium combat presentation revision

The showcase is now **The Sundered Observatory**, an original static combat shell. Midnight architecture, concentric celestial engravings, warm metal trim, deep panel shadows and restrained blue/orange camp accents establish an arena rather than a component gallery. No downloaded art, fonts, plugins or external services are needed.

`premium_combat_shell.gd` constructs native Control/Panel/Label/Button elements and deterministic CanvasItem decorations. Its helpers separate heroes, cards, shield-shaped token studies and ornament drawing. A fixed 1920?1080 composition scales uniformly and centers within other aspect ratios. Coordinates are presentation fixtures, never board state or rule inputs. No per-frame processing or randomness is used.

Structure: header; opponent hero; six columns with four labelled rows (O defense/attack, P attack/defense); four sample shield tokens; contextual inspection study; player hero; action area; five hand card studies and rarity legend. The inspection panel is visible only as a static study, not a permanent gameplay architecture decision. Text names and values are invented presentation fixtures, not catalog definitions. The relic motif is decorative, not a new card type.

Native Theme variants added: BattleBoard, HeroFrame, CardFrame, TokenFrame and InspectorFrame. They reuse the existing font/button system and add differentiated surfaces, bronze borders and drop shadows. Removed invalid built-in OptionButton type-variation declaration. Theme resources are UTF-8 without BOM for Godot's resource parser.

The Theme owns all semantic palette values. Rarity identity drift in the prior working tree was corrected to the validated white/blue/red/violet/gold mapping. Scripts retrieve colors through UIDesignTokens, without copied rarity literals.

| Rarity | Hex |
|---|---|
| Common | #F2F0EB |
| Uncommon | #86BDFA |
| Rare | #F28B88 |
| Epic | #C5A2F5 |
| Legendary | #E8C675 |

Camp colors reuse the existing Theme: player #5BB4F0; opponent #EE6A4A. P/O and explicit row labels provide non-color cues. Other semantic states reuse existing selected/valid/invalid tokens. Spacing scale remains 8/16/24/32/48 reference pixels.

Production gaps: procedural crests and helmet silhouettes are original studies, not finished character portraits. Flat native materials still need illustrated surface texture, lighting and final art direction. Detailed production card rules, interaction, animation, audio and gameplay binding belong to later prompts.

## Typography and readability

Use Godot's default font. ScreenTitle 58, SectionHeading 28, CardTitle 26, BodyText 24, SecondaryText 22, TacticalNumber 32, TooltipText 22 reference pixels. At 720p these scale to approximately 39, 19, 17, 16, 15, 21 and 15 physical pixels with the project's existing canvas stretch. Use at least 4.5:1 contrast for body/tactical text against dark panels; never put rarity text on an equally bright surface. Labels and explicit stat names accompany colors. Preserve words and values rather than shrinking below readable size.

Button variants: default primary and SecondaryButton. Normal bronze border, brighter filled hover, dark inset pressed state, muted disabled surface, and a separate three-pixel gold keyboard focus outline. Shared native TooltipPanel/TooltipLabel styles support actual tooltips on the action button. All values in the scene are presentation fixtures.

## Manual inspection procedure

Run from repository root (repeat for each resolution):

```powershell
& 'D:\Temp\Godot_v4.7.2-stable_win64.exe' --path . --resolution 1920x1080 res://scenes/ui/theme_showcase.tscn
& 'D:\Temp\Godot_v4.7.2-stable_win64.exe' --path . --resolution 1280x720 res://scenes/ui/theme_showcase.tscn
```

- Check title, panel, rarity labels, tooltip and footer for clipping or overlaps.
- Check tactical values and explanatory text at actual display size.
- Hover and press End turn; verify its native hover/pressed styles without gameplay changes.
- Tab to End turn and check its gold focus ring. Disabled component styles remain available in the Theme.
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

Actual graphical Godot viewport captures saved as `baseline-1080p.png` (1920Ãƒâ€”1080) and `baseline-720p.png` (1280Ãƒâ€”720). Both graphical processes exited 0. A temporary capture script outside the repository instanced the real showcase, waited for rendering, and saved `root.get_texture().get_image()`; these are not generated mockups.

Capture invocation used the supplied executable with `--path D:\Dev\MagicOdyssey --resolution <size> --script D:\Temp\magicodyssey_p004_capture.gd -- <absolute PNG path>`.

- Resolution layout inspection: PASS at both sizes; header, 24-slot scaffold, hero counters, inspector, action button and all five card faces fit. Card bottoms were raised after the first capture exposed clipping at 720p; final captures were inspected at both sizes.
- Hover/pressed/native tooltip interaction review: NOT_RUN (static capture does not exercise mouse interactions).
- Keyboard focus navigation review: NOT_RUN (static capture does not exercise Tab navigation).
- Human artistic sign-off: pending; the native baseline precedes commissioned production artwork.

## Revision verification (2026-11-11)

All commands below use `D:\Temp\Godot_v4.7.2-stable_win64.exe` through `Start-Process -Wait -PassThru`; actual process ExitCode is inspected, along with console errors.

- `--headless --editor --path . --quit`: exit 0, initialization DONE, no final errors.
- `--headless --path . --script res://scripts/tests/test_runner.gd`: exit 0; Total Assertions 14, Passed 14, Failed 0, RESULT: ALL TESTS PASSED.
- `--headless --path . res://scenes/ui/theme_showcase.tscn --quit-after 2`: exit 0; engine banner only, no final resource/parser/runtime errors.
- Graphical viewport capture at both resolutions: exit 0, actual rendered images replace `baseline-1080p.png` and `baseline-720p.png`.
- `git diff --check`: final exit 0.

An intermediate resource encoding error and the prior OptionButton declaration were corrected; final import/launch were repeated cleanly. Static visual inspection covers layout/readability, not hover, keyboard navigation or gameplay. G0 remains NOT_VALIDATED; P005?P065 remain TODO.

The decorated desktop constrained the native 1080p window to 1920x1055, including when borderless was requested. The final 1080p image therefore uses an exact 1920x1080 Godot SubViewport in a running graphical Godot process: instance the same real showcase scene, set its size to 1920x1080, wait for RenderingServer.frame_post_draw, and save the viewport texture. The PNG dimensions were verified as 1920x1080. This is an actual Godot render, not a resized or generated mockup. 720p uses the native root viewport capture. Temporary capture scripts live outside the repository.
