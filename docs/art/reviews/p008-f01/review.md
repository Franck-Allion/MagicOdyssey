# P008-F01 — Tactical CreatureToken layout benchmark

2026-11-19. **DIAGNOSTIC REVIEW COMPLETE / OWNER LAYOUT DECISION PENDING.** Recommend **Variant B** for the next owner-controlled art-layout decision. Nothing in this benchmark replaces production V03; no V04 artwork was generated and no artistic acceptance is granted.

## Executive result

Three independent review-only implementations preserve the four stat meanings and the order **Attack — Armor — Shield — current Health**. All use the exact same token area, official ART-002 textures, illustration, value fixtures and P006 slot positions. Real native Godot captures and 240 per-value/stat/resolution raster measurements show a meaningful improvement over V03.

B is the best overall compromise in this study: primary single/double ink is **14 physical pixels high at 720p**, and positive secondary ink **11 px**. Its raised defenses cost portrait space versus A but leave the Knight's face identifiable. C gives 15 px primaries, but less usable portrait area and no consistent secondary advantage. A keeps the most portrait and an economical band, but its primary doubles remain 11–12 px and the Armor highlight can compete with white ink.

These are measured render dimensions and a qualitative visual recommendation, not a timed recognition study or proof of accessibility for all players. Local texture-contour spill and contrast minima remain issues for future art treatment. The owner must choose a layout before any decorated V04 work or production implementation.

## Baseline and protected scope

Production V03 remains byte-for-byte identical to HEAD, including `CreatureToken`, its layout, models, `CombatScreen`, slot component, fixtures, fonts, card overlays, textures, test runner and existing assertions. [Preservation manifest](preservation.json) verifies **215 tracked production files**. Only review tooling/evidence and one progress-tracker row were added. No production PNG, gameplay API, rule, engine implementation or Windows executable was created or changed.

V03's P008-E measured baseline remains approximately 11 px primary single, 9 px primary double and 7 px secondary bright ink at native 720p. Those baseline glyph figures are reused from [P008-E measurements](../p008-e/glyph_measurements.json), with unchanged source verified; fresh baseline scene captures are included here as visual controls. Baseline `99` is shown in the fresh comparison, without pretending the earlier measurements include every stress value.

The fixed 162×112-reference slot hosts the same centered **154×102.667-reference token** in all three variants and V03. At 720p the continuous rectangle is **102.667×68.444 physical px**, approximately a 103×69 raster footprint depending on phase. At 1080p it is 154×102.667. All three prototypes fill exactly the same rectangle; none wins through a larger token, different grid, moved HUD or larger screenshot scale.

## Review architecture and exact geometry

`token.gd` is a review-only `CreatureToken` subclass, mounted only by diagnostic scenes. It reuses typed resolved view-models and the passive token anchor; no production API was added. Coordinates below are in the 154×102.667 reference rectangle; multiply by **1536/154** for source-space drawing. All use dark neutral housing, thin separators and the untouched shared ART-002 numeral renderer with zero custom optical offsets. No alternate stat colors, oversized metal bezels, decorative frame generation or gameplay rules were introduced.

| Variant | Attack rectangle | Armor rectangle | Shield rectangle | Health rectangle |
|---|---|---|---|---|
| A — compact band | (1,74), 38×27.667 | (40,76), 36×25.667 | (78,76), 36×25.667 | (116,74), 37×27.667 |
| B — corners/raised center | (1,63), 39×38.667 | (43,49), 32×33 | (79,49), 32×33 | (114,63), 39×38.667 |
| C — tactical console | (1,56), 42×45.667 | (45,64), 31×30 | (78,64), 31×30 | (111,56), 42×45.667 |

A allocates a 152×72 portrait above its compact band; primary/secondary font ceilings are 260/220 source points. B allocates a 152×81 portrait, partly covered by the raised plaques and primary corners; font ceilings are 300/240. C allocates a 152×54 portrait above a deeper dark console; font ceilings are 320/230. Width fitting remains active, with no horizontal glyph compression. Font point ceilings are **not** physical glyph height.

Original `mo_inlay_attack.png`, `mo_inlay_health.png`, `mo_plate_armor.png` and `mo_plate_shield.png` are drawn directly. Full texture images are fitted to the diagnostic rectangular surfaces, so some original motifs change aspect. This is an explicit prototyping tradeoff, not an approved remaster of the artwork. Their raw bytes, silver/azure/dark/red identity and stat association are preserved. Future premium housings must be designed around the measured content space, rather than shipping these stretched diagnostic surfaces as final art.

## Identical fixture and rendering conditions

All variants and fresh V03 control use the same five repeating tuples `(Attack, current Health, Armor, Shield)`:

```text
(1,1,0,0), (6,8,2,3), (12,14,10,12), (0,0,1,1), (99,99,14,14)
```

This includes every mandatory pair and mixed state. Maximum Health is independently set to 99 in the benchmark model; it is never substituted for current Health. Positive defenses are always visible; secondary zeros remain neutral and hide their numeral/material. Status fixtures retain five entries, display three numbered placeholder cells plus `+2`, and include W/P attachment flags. These placeholders are labeled **NON-PRODUCTION** in the scene captions and [capture index](index.md); no permanent status artwork was invented.

Normal portraits use the same existing Arcane Knight illustration. Bright/dark scenarios use **that same artwork**, adjusted only in an in-memory diagnostic Image at brightness 2.5/0.18, then genuinely rendered by Godot. Source files are never edited. The dark case can itself hide facial detail; it is a contrast stress fixture, not proof that a layout preserves recognition for arbitrary dark artwork. This study does not test 24 different creature portraits.

All scenario frames are native 1920×1080 or 1280×720 Godot/OpenGL captures. They are not synthesized, resized, retouched or assembled from screenshots. [Side-by-side 720p](comparison_720p.png) / [1080p](comparison_1080p.png) are independently GPU-rendered comparison scenes at the same individual token size, not enlarged crops. P005/P006/P007 composition and production hand/utility HUD remain unchanged in the full-board scenes. Diagnostic captions occupy the free region above the board; empty controls omit captions for exact parity checks.

## Measurements: physical ink, clipping, spacing and contrast

[measurements.json](measurements.json) records **240 entries**: A/B/C × Attack/Armor/Shield/Health × ten values (`0,1,2,3,6,8,10,12,14,99`) × two resolutions. Secondary-zero glyph probes are explicitly marked hypothetical; actual zero-defense scenes suppress them. Every record includes bright-ink XYWH, full nonzero-alpha XYWH, cell margin, nearest-other-stat-cell distance, texture-alpha contour spill and local contrast minimum/median. [Raw probes](probes/) include 240 ink renders and 24 material-alpha renders.

Method: bright ink means alpha≥128 with R/G≥150 and B≥140, consistent with earlier P008 measurement thresholds. Separate full-alpha bounds include antialiasing, outline and shadow. Probes use each real renderer, production token scaling and first-slot fractional raster phase. Contrast uses those glyph probes composited in straight alpha over same-phase **actual GPU-rendered no-ink ART-002 backgrounds**, followed by sRGB relative luminance. This is a local pixel diagnostic, not a WCAG or user-readability certification. `backgrounds.gd` and `analyze.py` make the calculations reproducible.

| Physical bright-ink height | A at 720p /1080p | B at 720p /1080p | C at 720p /1080p |
|---|---|---|---|
| Primary single digits | **11–12 /18 px** | **14 /21 px** | **15 /22 px** |
| Primary two digits, including 99 | **11–12 /18 px** | **14 /21 px** | **15 /22 px** |
| Secondary single digits | **9–10 /14–15 px** | **11 /16–17 px** | **10–11 /16 px** |
| Secondary two digits | **10 /14–16 px** | **11 /17 px** | **10–11 /16 px** |

Examples at 720p: A Attack `12` 16×11 px and Armor `12` 13×10; B Attack `12` 19×14 and Armor `12` 15×11; C Attack `12` 20×15 and Armor `12` 15×10. Other digits/positions can vary by one raster pixel; full per-stat boxes are in the JSON. `12`, `14` and `99` were inspected natively, rather than inferred readable from point size.

**No ink or full-alpha glyph box leaves its stat cell, and no glyph overlaps a neighboring stat.** Minimum full-alpha cell margins over all tested cases/resolutions are A 2.56, B 2.67 and C 2.33 physical pixels. At 720p the minimum bright-ink-box distance to another stat's cell is A 5.33, B 4.67 and C 3.67 pixels. These are conservative box-to-cell distances, not an invented optical-separation score. No complete token leaves its original P006 slot.

Some glyph pixels cross the **material texture's alpha contour**, even though they remain well within their quiet rectangular housing. At 720p B primary `12` has three bright pixels outside the half-alpha material contour, and `14` two; A has one for Health `12`/`99` and Attack `99`; C has one or two on `12`/`14`. Full results include 1080p and all values. This is retained and documented, not falsely reported as clean material-edge integration. A future V04 material window should extend beneath the whole numeral instead of forcing text against an elliptical alpha edge.

Contrast also remains uneven around metallic highlights. Across the tested 720p probes, Armor's local minima reach roughly **1.10:1 in A, 1.63:1 in B, 1.31:1 in C**; median glyph contrast is much higher (around 7:1). For B Attack `12`, minimum local contrast is about 4.58:1; B Health `12` about 1.97:1. Minima refer to individual ink samples over textured art, not the whole numeral. Outline and neighboring dark pixels help visually, but a good median does not erase a weak edge. No material recoloring or fabricated contrast pass was used.

## Portrait usability and crowded boards

[portrait_metrics.json](portrait_metrics.json) distinguishes gross target size from actual remaining geometric portrait space. A rectangular portrait can still be partly obscured by its stat cells; B's 81-reference-pixel portrait height is not all unobstructed.

| Layout | Visible geometric portrait area without indicators | With all six placeholder cells | Width/height at 720p before stat overlap |
|---|---:|---:|---|
| V03 | about **47.6%**, polygon/open-alpha intersection | not remeasured here | about 87×41 px fill target |
| A | **69.2%** | **63.0%** | about 101×48 px |
| B | **55.1%** | **48.9%** | about 101×54 px; central upper clear height about 32 px |
| C | **51.9%** | **45.7%** | about 101×36 px |

Prototype areas subtract opaque stat-cell overlap analytically. Maximum placeholders subtract six 15×11-reference cells. Baseline uses a pixel mask of its existing portrait polygon intersected with the V03 opening. These are declared geometric measurements, not subject segmentation or a recognition percentage.

In normal native screenshots the Knight's head remains identifiable in all three. A preserves most chest/pose context. B's raised plaques cover lower portrait/chest and can approach the chin, but preserve the face in this fixture. C retains the face with the least vertical portrait space and a visually dominant console. Other creatures with large heads, horns or wings require later portrait fixtures before committing final art. Status placeholders still have tiny text; none of the layouts solves approved-icon recognition merely by retaining those cells.

Native full-board evidence: [A 720p](variant_a_full_board_720p.png), [B 720p](variant_b_full_board_720p.png), [C 720p](variant_c_full_board_720p.png), and corresponding 1080p pairs in the index. The full board is deliberately dense and identical in data order. A has the most regular single-line scan; B makes a useful primary/secondary hierarchy; C gives the largest primaries but its dark console can dominate the board. These are visual judgments, not measured response times.

## Comparison matrix

Numbers marked **M** are measured; **J** marks visual judgment. V03 ink figures are the preserved P008-E baseline, not a claim of new baseline probe coverage for every stress value.

| Criterion | Current V03 | A compact band | B raised defenses | C console |
|---|---|---|---|---|
| Primary single height at 720p — M | ~11 px | 11–12 px | **14 px** | **15 px** |
| Primary double height at 720p — M | ~9 px | 11–12 px | **14 px** | **15 px** |
| Secondary single height — M | ~7 px | 9–10 px | **11 px** | 10–11 px |
| Secondary double height — M | ~7 px | 10 px | **11 px** | 10–11 px |
| Stat contrast — M/J | white over textured materials; not re-quantified | weakest sampled Armor edge; dark stroke helps | stronger primary separation; Armor highlights remain | strong dark console; local metal highlights remain |
| Usable portrait — M | ~47.6% | **69.2%** | **55.1%** | **51.9%** |
| Four-stat density — J | small numbers amid frame detail | regular and compact, weaker hierarchy | **clear primary corners with distinct raised defenses** | largest primary values, heavy console |
| Status/equipment compatibility — J | existing capability; tiny diagnostics | same three +N and W/P; more portrait room | retained; top and raised plaques need careful art spacing | retained; least vertical portrait slack |
| Neighbor separation — M/J | original P006 feedback | same footprint; no spill into slots | same footprint; no spill into slots | same footprint; no spill into slots |
| Native 720p judgment — J | four-stat comfort inadequate | meaningful gain, best portrait compromise | **recommended overall compromise** | meaningful gain, console dominates more |
| ART-002 compatibility | production rendering | exact source textures; prototype reshaping | exact source textures; contour spill remains | exact source textures; prototype reshaping |
| Complexity — J | existing production component | lowest: one band | medium: raised center and overlap budget | low/medium: integrated console sizing |

## Recommendation and future V04 geometry proposal

**Recommend B, without integrating it.** It improves the most important two-digit primary recognition from 9 to 14 px, keeps positive defenses consistently around 11 px, retains more useful portrait area than C and preserves Attack/Health corner anchors. C's extra primary pixel does not outweigh its lower portrait area and console dominance in this fixture. A remains attractive when portrait context is weighted more heavily, but has smaller primary values and a weaker sampled Armor edge. This recommendation follows native full boards and side-by-side renders as well as glyph dimensions; it is not a font-height-only winner.

For a future **owner-approved** V04 art brief, reserve B's existing content rectangles before adding ornament. At 1536×1024 source scale the proposed primary centers are approximately **(204,821)** and **(1332,821)**; defensive centers **(588,653)** and **(948,653)**. Primary windows are approximately **389×386 source px** and defensive windows **319×329**. Keep the 154×102.667 reference footprint, thin separators, and a clear head region above reference y49. Do not add bronze ornaments inside these measured glyph spaces. Material alpha contours should cover numeral edges and quiet highlights should avoid the bright glyph footprint. The exact ART-002 identity must survive any later approved material adaptation.

These are proposed content reservations, not new canon, not a fourth prototype, and not permission to generate V04. They deliberately preserve the existing 0/positive defense policy, three-icons-plus-overflow capability and attachment flags. Approved icon content and broader creature-art cropping tests remain necessary.

## Evidence index and reproducibility

- [Complete GPU evidence index](index.md): every scene screenshot, plus probe/measurement links.
- [Side-by-side 720p](comparison_720p.png) / [1080p](comparison_1080p.png).
- Required per-variant `single`, `full_board` and `mixed_stats` captures exist at the named paths; all three also include four positives, two digits, zero defenses, overflow, equipment, bright/dark portraits and 99 stress at both resolutions.
- [Hover checks](hover_results.json), [B hover 720p](b_hover_720p.png), [B selected 720p](b_selected_first_720p.png). Main full-board checks route clicks over all 24 identities for baseline and A/B/C at both sizes. Hover/selection are actual SubViewport GUI events, **not OS mouse tests**.
- `capture.gd`, `comparison.gd`, `backgrounds.gd`, `portrait_scenarios.gd`, `hover.gd`, `token.gd` and `analyze.py` are review-only tools. Rendering requires a GPU; run the `.gd` scripts with Godot `--path . --script res://docs/art/reviews/p008-f01/<script>.gd`.

## Automated verification and preservation

Godot 4.7.2 stable ed1daf0bf; Windows OpenGL Compatibility; NVIDIA GTX 1660 Ti / driver 551.86.

| Verification | Actual result | Exit |
|---|---|---:|
| Final Godot headless editor import | PASS | 0 |
| Existing complete native suite | **3681 passed, 0 failed; no assertion changes** | 0 |
| Main diagnostic GPU pipeline | **1136 checks, 0 failures** | 0 |
| Hover/selection GPU supplement | **32 checks, 0 failures** | 0 |
| Actual no-ink backgrounds / side-by-side / portrait supplements | PASS | 0 |
| Raster/contrast/cell/preservation audit | 240 records; no cell clipping or adjacent-stat overlap | 0 |
| ART-002 regression | **3/3 bit-exact, zero differing pixels** | 0 |
| P005/P006/P007/P008 preservation | 215 tracked production files match HEAD; all empty controls match P006 at both sizes | 0 |
| `git diff --check` | PASS | 0 |
| New Windows export / OS desktop tests | **NOT_RUN / NOT_NEEDED** for this review-only benchmark | — |

[Native log](tests.log), [main GPU log](gpu.log), [hover log](hover.log), [ART-002 log](art002.log), [machine-readable GPU checks](gpu_results.json), [preservation](preservation.json). The native suite retains its pre-existing P007 off-tree anchor warning. An initial review-script texture-region argument-order error was corrected; that attempt is preserved in `gpu-first-attempt.log` and is excluded from passing evidence. Final verification checks script-error logs and complete image/probe counts as well as return codes, avoiding the initial engine exit-0 false positive. Graph coverage metadata is unavailable/truncated; bounded source reads and exact HEAD comparisons were used rather than exhaustive graph claims.

No production Windows executable was built or launched. Earlier P008-E Windows evidence is historical and is not claimed as a new F01 test. The interactive prototype is not a playable Lot 1 combat implementation.

## Owner decision required

Choose whether B's stronger combat hierarchy and 14/11-pixel type justify its raised plaques, or whether A's portrait area or C's console better serves the intended product. Review material-contour spill, highlight contrast and status/icon space before approving a V04 art brief. **No layout or artwork is owner-approved by this report.** Production V03 remains unchanged. P009/P010 TODO, G1 NOT_VALIDATED. Stop after P008-F01; do not implement the recommendation or generate V04 automatically.
