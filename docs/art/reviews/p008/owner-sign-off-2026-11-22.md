# P008 final owner artistic sign-off

Decision date: **2026-11-22**. Reviewed checkout: **72de243** (`P008-F04`).

**P008 - OWNER ART-APPROVED / WINDOWS TECHNICAL FOLLOW-UP PASS (2026-11-22).**

The project owner explicitly confirmed final artistic acceptance after viewing the result in the actual MagicOdyssey Windows executable. This records the owner's decision supplied in the current task; it is not an approval inferred from automated tests.

## Accepted scope

- V05 CreatureToken frame, tactical geometry and current portrait aperture.
- Four-stat composition: effective Attack, Armor, Shield, current Health.
- P008-F04 Bahnschrift weight 700, natural-width white numerals with a thin black outline.
- Native 720p readability as a deliberate Lot 1 artistic and ergonomic compromise.
- No further CreatureToken artwork or redesign is required before progressing to P009.

This approval **supersedes the earlier recommendation to redesign V05's internal stat housings to reproduce exact P008-F01 Variant B geometry**. That proposal is no longer a prerequisite for P009. Historical measurements, defects and test outcomes remain unchanged.

## Approved assets and evidence

- [V05 source artwork](../../../../assets/_source/lot1/tokens/mo_creature_token_frame_v05_final.png).
- [Byte-identical production V05 frame](../../../../assets/textures/tokens/mo_creature_token_frame_v05_final.png).
- [Selected token numeral style](../../../../resources/themes/creature_token_numerals.tres).
- [Protected token geometry](../../../../scripts/presentation/creature_token_layout.gd).
- [P008-F03B corrected verification package](../p008-f03/verification/index.md), [measurements](../p008-f03/verification/measurements.json), [verification manifest](../p008-f03/verification/validation.json).
- [P008-F04 typography review](../p008-f04/review.md), [native 720p comparison](../p008-f04/comparison_720p.png), [installed production 720p full board](../p008-f04/production_full_board_720p.png).

## Accepted limitations and separate dependencies

The artistic decision does not retroactively change the raster evidence:

- Primary glyphs do not consistently reach the historical 14 px benchmark.
- Secondary glyphs do not consistently reach the historical 11 px benchmark.
- Some residual material-boundary interference remains.
- Extreme value `99` has reduced white-ink height.
- Final approved status/equipment icons remain a separate dependency.
- P008-F04 automated Windows desktop acceptance was blocked by foreground-window ownership. The executable was built and the owner confirmed actual visual inspection; the blocked automated OS-input tests are not a PASS.

## Technical follow-up

The unchanged production checkout was rebuilt and the standard full-board Windows OS-input test passed at 1080p, 720p and default window mode, exit 0 for the harness and each ESC termination. See [current follow-up evidence](final-windows-2026-11-22/review.md). This resolves the historical foreground-ownership verification block without changing its old results or reopening artistic approval. No second owner art review is required for the unchanged V05.

## Progression boundary

P008's artistic milestone is closed. This task authorizes **P009-R01A artistic specification and prompt preparation only**. Spell artwork generation, alpha validation and owner review remain pending. P009-R01B stays TODO until an actual Spell frame is generated, reviewed, alpha-validated and explicitly owner-approved. P009-R02A/R02B and P010 remain TODO. G1 remains NOT_VALIDATED; Lot 1 is not declared playable.
