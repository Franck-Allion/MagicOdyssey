# ART-002-T04 — Premium Stat Sockets and Combat Readability

2026-11-12 · **PASS — implementation and technical validation**.
Recommendation: **approve this presentation candidate for T04**, subject to owner art review.
This is an integration study using the accepted master v03, not a gameplay or roadmap completion claim.

## Files changed

- `scripts/presentation/art002_card_integration_test.gd`: replaces ATK/HP captions and old number placement with the reusable overlay; adds socket close-ups and four protection combinations; exercises zero and two-digit values in the seven-card hand.
- `scripts/presentation/card_stat_overlay.gd` (+ Godot UID): typed, presentation-only renderer for printed numbers, symbolic socket accents, native Armor and optional Shield status.
- `docs/art/reviews/art002/t04/capture.gd` (+ Godot UID): reproducible graphical capture and pixel regression checks.
- This report, `validation.txt`, five PNGs below, and their Godot import metadata.

No scene/material changes were needed. The master PNG, rarity material factory, shader, gem mask and theme match their HEAD blobs exactly. Rarity continues to use the three gemstones only; canonical violet Epic remains the default, and the existing emerald experiment remains opt-in. No rarity text or stripe was added to a card.

## Display decisions

| Element | Treatment |
| --- | --- |
| Mana | Ivory numeral centered in the original top-left socket; no extra icon competing with the title. |
| Attack | Ivory numeral centered in the bottom-left socket; small bronze-collet sword on its upper rim. |
| Health | Ivory numeral centered in the bottom-right socket; warm heart symbol on its upper rim. This remains printed base max HP. |
| Armor | Solid steel crest with a numeric counter in a dark, bronze-edged auxiliary badge to the left of the footer gem. Represents printed native Armor. |
| Shield | Azure pointed energy ward with detached arcs and a counter to the right of the footer gem. A separate optional transient status overlay. |

Numbers use the design system's TacticalNumber font. Glyph bounds and bearings determine the baseline, rather than centering a Label line box with unused descender space. Values shrink to their available width. The socket centers are source-space `(154,157)`, `(157,1284)`, and `(934,1284)`; the same overlay scales with the card.

The symbols use antialiased procedural silhouettes, facet lines, bronze rims and restrained palette tokens. They are replaceable in `_symbol()` without changing the number layout or data API. Shapes distinguish metal Armor from the energy Shield independently of color. Zero protection values hide their badges; neither badges nor symbols cover a rarity gem or rules text.

`set_printed_values(cost, attack, max_health, native_armor)` takes presentation data, with no catalog or domain dependency. `set_shield_overlay(value)` changes only the separate status badge. The previewed 2 Armor / 3 Shield values are illustrative samples, not a change to Arcane Knight's rules or a promise that Shield is present in a real hand. No live modifier overwrites the printed primary values. Future effective Armor modifiers belong in the live modifier audit/status layer rather than overwriting native Armor.

## Screenshots generated and visually inspected

| Screenshot | Size | Review purpose |
| --- | --- | --- |
| [single_card_1080p.png](single_card_1080p.png) | 1920 × 1080 | Inspected card, both protections visible. |
| [hand_7_cards_1080p.png](hand_7_cards_1080p.png) | 1920 × 1080 | Seven complete cards, mixed protections, mana 0 and two-digit primary stats. |
| [hand_7_cards_720p.png](hand_7_cards_720p.png) | 1280 × 720 | Same seven-card layout at reduced scale. |
| [stats_closeup_1080p.png](stats_closeup_1080p.png) | 1920 × 1080 | Crops of actual integrated cards: mana 10, attack 12, health 10, Armor 2, Shield 3. |
| [armor_shield_samples_1080p.png](armor_shield_samples_1080p.png) | 1920 × 1080 | Neither protection, Armor only, Shield only, both. |

At inspection scale the primary numbers sit inside their circular sockets, with the icons outside the central number area. The auxiliary badges use the existing footer space without competing with the title or rules. The seven-card hand retains readable primary numbers at both resolutions, including 12 attack and 10 health. The 720p protection counters are readable but small, and the sword/heart details are supporting cues at that scale. The positions of the primary stats remain the strongest scan cue.

## Validation and actual exit codes

Engine: `D:\Temp\Godot_v4.7.2-stable_win64.exe`, `4.7.2.stable.official.ed1daf0bf`.
Graphical captures: OpenGL Compatibility, NVIDIA GeForce GTX 1660 Ti.

| Check | Exit | Actual result |
| --- | ---: | --- |
| Godot import, `--headless --editor --path . --import --quit` | 0 | Passed, including a final import of all generated images and the new capture script; empty stderr. |
| Automated suite, `--headless --path . --script res://scripts/tests/test_runner.gd` | 0 | 14/14 existing assertions passed. This existing suite is the harness self-test, not comprehensive gameplay coverage. |
| T04 graphical capture and pixel verification, command below | 0 | Five captures saved at exact dimensions; 24 numeric ink-centering checks and two protection checks passed; empty stderr. |
| `git diff --check` | 0 | No whitespace errors. Git emits the repository's LF-to-CRLF advisory for the modified fixture. |

Pixel checks exercise `0, 1, 4, 5, 10, 12, 99, 999` at native source scale and the 1080p/720p hand scales. The maximum measured deviation of the visible numeral bounding-box center is **1 pixel per axis**, within the 1.5-pixel antialiasing tolerance. Toggling Shield `0 → 3 → 0` changes 22,780 pixels inside its badge region, **zero outside**, and restores the original image exactly. A separate pixel check confirms native Armor zero hides the badge.

Reproduce the entire graphical pass from the repository root:

```powershell
& 'D:\Temp\Godot_v4.7.2-stable_win64.exe' --path . --script res://docs/art/reviews/art002/t04/capture.gd
```

Inspect interactively:

```powershell
& 'D:\Temp\Godot_v4.7.2-stable_win64.exe' --path . res://scenes/ui/art002_card_integration_test.tscn
```

Keys 1–6 select inspection, hand, rarities, existing Epic comparison, socket close-up and protection samples. Keyboard switching was **NOT_RUN manually**; the automated pass selects the same modes directly.

## Remaining limitations

- The procedural symbols are a styled interim art candidate, not final commissioned icon artwork. Owner approval is pending; no AAA-quality or UX sign-off is implied by technical PASS.
- Small rules text still requires inspection at hand scale. At 720p the miniature sword/heart are not detailed standalone teaching icons; the stable socket locations and readable numbers carry quick scanning. Armor/Shield recognition should receive a player review before final UI approval.
- Three-digit centering/fit is exercised by pixel tests; readability of very large values is not approved. Automatic fitting imposes no gameplay cap, but increasingly long numbers inevitably become small.
- Font selection follows the existing SystemFont theme. Captures validate this Windows installation; other installed fonts/platforms need a rendering pass.
- No domain engine connection, live combat scheduling, hover tooltips, animation, interactive selection or production CardView/HandView implementation was added or tested. The reusable overlay is integrated into the current ART-002 presentation fixture.
