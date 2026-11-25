# P009-R01C — Spell category alignment and rarity gem registration

**2026-11-25 · Technical correction verified on Godot 4.7.2 / Windows OpenGL Compatibility / GeForce GTX 1660 Ti. Owner artistic review pending.**

The corrected Spell card clears the bronze rail and bridge bezel. Its crown, bridge and footer gems all respond to the shared rarity material, with zero recoloring in the description panel. The three approved ART-002 golden renders match pixel for pixel.

[Original defect reference](../p009-r01b/creature_vs_spell_comparison_1080p.png) · [Matched before/after 1080p](spell_rare_before_after_1080p.png) · [Matched before/after 720p](spell_rare_before_after_720p.png)

## Category

The former layout borrowed the Creature reservation `Rect2(180, 916, 726, 66)` and its 48 px display font. That put the center at y949, on the lower bronze divider. The y898–946 straight dark-enamel strip extends across the measured x180–906 band, but the central bridge bezel descends to about y925. Centering a full-size label in a plain rectangle can still put the “p” or “e” over that taper.

The Spell variant uses `Rect2(180, 908, 726, 38)`, the existing CardTitle display font at 36 px, and 5 source px of glyph spacing. The added spacing places the bezel tip in the gap between “p” and “e.” The font resolves to Palatino Linotype on this Windows machine. At 36 px, ascent is 27 px and descent is 11 px. The shared label still uses horizontal and vertical center alignment and the existing −6 line separation, which has no effect on a one-line label.

| Source-space metric | Before | Corrected |
|---|---:|---:|
| Raster gold ink bounds, exclusive right and bottom | (488, 925)–(599, 973) | (492, 909)–(595, 944) |
| Optical ink center | (543.5, 949) | (543.5, 926.5) |
| Left/right margins to the measured strip | 308 / 307 px | 312 / 311 px |
| Top/bottom margins to the straight rails | 27 / −27 px | 11 / 2 px |
| Visible gold ink pixels on traced bridge bezel | 0 | 0 |

The 4.5 px vertical bias from the strip midpoint gives the text room beneath the bridge shoulders. The horizontal ink center is within half a source pixel of the plate center. The negative before margin records how far the text extends below the top of the lower rail. The corrected gold ink clears the rail and the central bronze tip.

| Actual pose | 1080p ink height | 720p ink height |
|---|---:|---:|
| Two-card mixed hand, exposed Fireball | 7 px | 4 px |
| Ten-card mixed hand, exposed Martial Blessing | 7 px | 5 px |
| Raised reference Spells | 13 px | 9 px |

All 16 hand and inspection measurements compare genuine GPU frames with the label visible and hidden. Four spells were raised through the normal hand controller by injected SubViewport pointer input in the ten-card layout. Fireball and Mending Light were also raised in the two-card layout. At resting 720p size, the lettering is very small and partly subject to normal hand overlap. Raised inspection is the reliable reading view.

[Source-size text before](spell_text_before.png) · [Source-size text corrected](spell_text_alignment_diagnostic.png) · [1080p text diagnostic](spell_text_alignment_diagnostic_1080p.png) · [720p text diagnostic](spell_text_alignment_diagnostic_720p.png)

## Rarity mask

CardView uses a full-frame `TextureRect` with `STRETCH_SCALE`. The CanvasItem shader samples frame RGB/alpha and mask coverage at the same 0–1 UVs, with linear filtering for mask edges. Each card receives its own ShaderMaterial. The previous Spell variant passed the Creature mask, whose lower diamond spans y1247–1337. The Spell footer crystal begins at y1339, after the enlarged description panel. This placed 2,248 nonzero mask pixels in the lower description panel, changing 2,236 pixels on the Rare GPU frame while the actual footer gemstone received zero treatment.

The new editable [Spell SVG](../../../../assets/textures/cards/frame_spell_v01_gem_mask.svg) imports as the 1086×1448 runtime Texture2D at `res://assets/textures/cards/frame_spell_v01_gem_mask.svg` and is selected by the Spell visual variant. Both art PNGs match their verified R01B SHA-256 hashes. The source and runtime PNG are `assets/_source/lot1/cards/frames/mo_card_frame_spell_v01.png` and `assets/textures/cards/mo_card_frame_spell_v01.png`.

Bounds below are source-space xyxy with exclusive right and bottom. Crystal contours were traced on the bare artwork at 4× for measurement. The SVG paths are inset slightly to keep the antialiased edges on the facets. Weighted overlap sums the actual imported mask coverage on the independent contours.

| Crystal | Painted interior bounds and center | Before mask bounds | Corrected mask bounds and center | Weighted coverage before → after |
|---|---|---|---|---:|
| Crown | (523,24)–(565,83), (544,53.5) | (525,24)–(564,83) | (524,25)–(564,82), (544,53.5) | 90.32% → 89.96% |
| Bridge | (519,833)–(567,896), (543,864.5) | (522,836)–(565,896) | (520,834)–(566,895), (543,864.5) | 83.27% → 90.80% |
| Footer | (519,1339)–(568,1408), (543.5,1373.5) | Old artifact at (520,1247)–(567,1337) | (520,1340)–(567,1407), (543.5,1373.5) | 0.00% → 91.11% |

The mask-wide comparison found 2,285 pixels of prior coverage outside the traced crystals and zero with the corrected mask. The new mask has zero support in the rules reservation and the lower description area. The five full-frame shader comparisons found zero RGB changes outside the three traced regions and zero alpha changes. The small inset preserves a clean facet-to-bezel edge.

Q181 specifies purple Epic. The shared runtime still renders Epic emerald, including on Spell. That existing palette discrepancy remains open. Common, Uncommon, Rare and Legendary render in their expected white/silver, blue, red and gold families.

[Source-size mask](spell_mask_diagnostic.png) · [1080p mask diagnostic](spell_mask_diagnostic_1080p.png) · [720p mask diagnostic](spell_mask_diagnostic_720p.png) · [Full measurements](mask_metrics.json)

## Native GPU captures

| Case | 1920×1080 | 1280×720 |
|---|---|---|
| Creature Rare | [1080p](creature_rare_baseline_1080p.png) | [720p](creature_rare_baseline_720p.png) |
| Creature / Spell | [1080p](creature_vs_spell_comparison_1080p.png) | [720p](creature_vs_spell_comparison_720p.png) |
| Spell Common | [1080p](spell_common_1080p.png) | [720p](spell_common_720p.png) |
| Spell Uncommon | [1080p](spell_uncommon_1080p.png) | [720p](spell_uncommon_720p.png) |
| Spell Rare | [1080p](spell_rare_1080p.png) | [720p](spell_rare_720p.png) |
| Spell Epic | [1080p](spell_epic_1080p.png) | [720p](spell_epic_720p.png) |
| Spell Legendary | [1080p](spell_legendary_1080p.png) | [720p](spell_legendary_720p.png) |
| Mixed hand, two cards | [1080p](combat_screen_mixed_small_1080p.png) | [720p](combat_screen_mixed_small_720p.png) |
| Mixed hand, ten cards | [1080p](combat_screen_mixed_large_1080p.png) | [720p](combat_screen_mixed_large_720p.png) |
| Raised Fireball | [1080p](inspect_fireball_10_1080p.png) | [720p](inspect_fireball_10_720p.png) |
| Raised Mending Light | [1080p](inspect_mending_light_10_1080p.png) | [720p](inspect_mending_light_10_720p.png) |
| Raised Arcane Barrier | [1080p](inspect_arcane_barrier_10_1080p.png) | [720p](inspect_arcane_barrier_10_720p.png) |
| Raised Martial Blessing | [1080p](inspect_martial_blessing_10_1080p.png) | [720p](inspect_martial_blessing_10_720p.png) |

## Regression runs

| Check | Result |
|---|---|
| Godot headless import | Exit 0 |
| Complete native test runner | 3,881/3,881 assertions, exit 0. Included P005 CombatScreen, P006 battlefield slots, P007 HUD, P008 CreatureToken and P009 card presentation. The existing anchor-size warning in `test_combat_hud.gd:341` remains visible. |
| ART-002 / AUDIT-002 | Exit 0. Three golden comparisons passed with zero differing pixels and zero channel difference. [Card](../../../audits/AUDIT-002/card_production_baseline_1080p.png), [hand](../../../audits/AUDIT-002/seven_card_hand_baseline_1080p.png), [stats](../../../audits/AUDIT-002/four_stats_closeup_baseline_1080p.png). |
| ART-002 Creature rarity mask | Exit 0, 6/6 material cases. All three gems changed. Alpha and pixels outside the mask stayed identical within the existing regression threshold. Both legacy Epic call forms use emerald in the current runtime. |
| P009 GPU capture | 35 PNGs, 160 checks passed, zero failed, exit 0. [Observations](observations.json) |
| Raster, mask and rarity regression | Exit 0. Imported SVG coverage, actual raster ink, all five Spell rarity treatments, alpha and outside-contour RGB compared. [Measurements](mask_metrics.json) |
| Existing Windows export | Exit 0. `build/windows/MagicOdyssey.exe` built from the Windows Desktop preset. |
| Git whitespace check | Exit 0 on both the working diff and staged changes. |

Reproduction commands from the repository root:

```powershell
$Godot = 'D:/Temp/Godot_v4.7.2-stable_win64_console.exe'
& $Godot --headless --path . --editor --import
& $Godot --headless --path . --script res://scripts/tests/test_runner.gd
powershell -ExecutionPolicy Bypass -File scripts/tests/run_visual_regression.ps1
& $Godot --path . --script res://docs/art/reviews/art002/t03c/verify_gems.gd
$env:MO_R01C_ANALYSIS_DIR = 'D:/Temp/mo-r01c-analysis'
& $Godot --path . --script res://docs/art/reviews/p009-r01c/capture_review_evidence.gd
python docs/art/reviews/p009-r01c/mask_metrics.py $env:MO_R01C_ANALYSIS_DIR
powershell -ExecutionPolicy Bypass -File scripts/build_windows.ps1
powershell -ExecutionPolicy Bypass -File scripts/tests/playtest_windows.ps1 -ReviewDir build/windows/p009-r01c-playtest -CardScenario mixed -HandCount 10 -BattlefieldSlots -UtilityHud
git diff --check
```

## Windows desktop verification

See [desktop results](windows-results.md) for the separately recorded client sizes, OS input, End Turn and ESC results.

## Scope and changed files

- The local checkout began at `fba971a` with R01B and a draft R01C in the working tree. This commit carries the local R01B prerequisites and historical review so the corrected variant can be built from a clean checkout.
- The R01B runtime prerequisite comprises `card_view.gd`, `card_visual_variant.gd`, `card_presentation_model.gd`, `card_mana_overlay.gd`, their UIDs, the two Spell PNGs and import metadata, and the existing preview integration in `combat_preview.gd` and `combat_preview_cards.gd`.
- R01C changes the Spell reservation and spacing in `card_view_layout.gd` and `card_visual_variant.gd`. `card_view.gd` forwards typed variant values to the shared `card_content_overlay.gd`. `rarity_gem_treatment.gd` supports an injected Texture2D and retains the existing palette and shared shader.
- The source-aligned SVG and its Godot import metadata live in `assets/textures/cards/`. The Creature mask, shader, rules layout, mana, stats, card back and frame assets match their protected versions.
- Test changes are in `scripts/tests/test_card_presentation.gd`, `scripts/tests/playtest_windows.ps1` and this review directory. The review includes the capture script, raster analysis, JSON results, and native PNG evidence. `docs/progress/lot1-progress.md` records the correction and pending owner decision.
- The hand picker, hover transition, CombatScreen composition, P008 CreatureToken and gameplay code remain outside the correction. P005 and P008 retain their recorded owner sign-offs. P009 remains open, Equipment and P010 remain TODO, and G1 remains `NOT_VALIDATED`.
