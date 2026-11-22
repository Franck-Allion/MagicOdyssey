# References to attach alongside the English prompt

These are **unmodified copies of existing project references**, not generated Spell artwork. Use [image-generation-prompt.md](image-generation-prompt.md) with the three images below in order. Exact hashes, modes and dimensions are recorded in [reference-manifest.json](reference-manifest.json).

| Upload order and copied image | Exact existing source path | Use and approval context |
|---|---|---|
| [01_art002_master_v03.png](references/01_art002_master_v03.png) | `assets/_source/lot1/cards/frames/mo_card_frame_master_v03.png` | Primary ART-002 Creature master, 1086×1448 RGBA. Family geometry, bronze/enamel, mana and neutral stones. This is the authoritative visual source; remove all Creature stat features for Spell. |
| [02_art002_rarity_palette_t03b.png](references/02_art002_rarity_palette_t03b.png) | `docs/art/reviews/art002/t03b/rarity_samples_1080p.png` | Existing ART-002 five-rarity demonstration supporting normative Q181 colors. Use for jewel treatment/material continuity only, not baked color, dynamic text, stats or portraits. It is historical reference evidence, not a newly granted Spell approval. |
| [03_owner_approved_card_hover_720p.png](references/03_owner_approved_card_hover_720p.png) | `docs/art/reviews/p005-r09c/final_hover_left_720p.png` | P005 owner-approved native composition/card-hover reference, 1280×720. Shows card-family finish and dynamic typography in context; do not copy the Creature sockets or illustration. P005 approval is recorded in the progress tracker on 2026-11-16. |

The master source and the current preview share the approved ART-002 family. These references **do not** mean the still-uncreated Spell frame has been generated or accepted. The actual master has legacy alpha residues; its visual authority is not an alpha-quality exemption for the new Spell source.

The current theme/rarity implementation renders Epic emerald while normative English Q181 specifies purple. The T03B panel displays the normative purple palette. Keep the new source rarity-neutral; see [the brief's discrepancy record](brief.md#rarity-continuity-and-a-verified-specification-mismatch). No runtime palette or existing artwork is changed here.

Technical source references, for the production team rather than image-model uploads:

- [Current source geometry](../../../../scripts/presentation/card_view_layout.gd).
- [Three crystal mask contours](../../../../assets/textures/cards/frame_v03_gem_mask.svg).
- [Rarity material factory](../../../../scripts/presentation/rarity_gem_treatment.gd), [shader](../../../../resources/shaders/card_rarity_gems.gdshader), [theme](../../../../resources/themes/fantasy_theme.tres).
- [Existing dynamic content contract](../../../../scripts/presentation/card_content_overlay.gd), [noncreature fallback](../../../../scripts/presentation/card_category_overlay.gd), [current hand/hover implementation](../../../../scripts/presentation/combat_preview_cards.gd).
- [ART-002 v03 review](../art002/v03/integration-review.md), [T03B rarity review](../art002/t03b/review.md), [P005 owner approval evidence](../p005-r09c/review.md).
- [Normative card variants](../../../../specs/03-presentation-ui/02-cards-and-inspection.md), [catalog and planned data schemas](../../../../specs/01-lot1-vertical-slice/02-catalog.md), [Q181 and PLAN-002 decisions](../../../../specs/06-reference/02-decisions.md).

No third-party game frame, online reference image or new font is introduced. The package reuses supplied project artwork; it makes no new provenance claim for historical sources beyond their recorded project role. Use `upload-package.zip` as a transport archive: extract it, then attach the three PNGs and paste the English prompt. Do not treat the archive itself as a rendered Spell asset.
