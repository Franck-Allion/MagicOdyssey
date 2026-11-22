# P009-R01A — Spell card frame art preparation

2026-11-22 · **SPECIFICATION / PROMPT PREPARED — ARTWORK AND OWNER REVIEW PENDING.**

P008's [owner artistic sign-off](../p008/owner-sign-off-2026-11-22.md) and [Windows follow-up](../p008/final-windows-2026-11-22/review.md) are recorded first. This package prepares one standalone Spell frame. It does not generate artwork, install a PNG, change card definitions, modify Godot presentation or implement P009-R01B. Expected eventual source: `assets/_source/lot1/cards/mo_card_frame_spell_v01.png` (**not created**).

## Artistic direction

Make the Spell frame a direct sibling of the approved ART-002 Creature master: sculpted antique bronze, midnight-blue enamel, fine restrained engraving, faceted neutral jewels, the same upper-left mana identity and illustrated-card proportions. Use the actual [master v03](../../../../assets/_source/lot1/cards/frames/mo_card_frame_master_v03.png), not an unrelated game's frame or a CreatureToken.

Keep the large illustration window and familiar nameplate. Remove **every** Attack/Health/Armor/Shield housing, empty stat socket, equipment attachment socket, Weapon/Protection marker and creature-only footer decoration. Replace the former lower stat intrusions with a wider, uninterrupted quiet text surface and a compact continuous lower border. Do not replace them with blank medallions, rosettes, seals, oversized bronze flourishes or unexplained vacant panels.

The proposed effect text rectangle grows from **566×210 to 806×240 source pixels**, a **62.7% increase in usable rectangular area**. This uses the space constrained by the Creature footer shoulders while retaining the three small family rarity gems. Preserve the existing large artwork allocation rather than adding a second illustration panel. All names, costs, category text, rarity labels and effects are dynamic; none is painted into the frame.

## Verified source geometry versus proposed Spell reservations

Coordinates below are **source pixels at 1086×1448**, origin upper-left, rectangles XYWH. This is exactly **3:4**, not 1024×1536. Verified Creature values come from `CardViewLayout` and the actual PNG/mask; Spell reservations are an art-generation proposal and have not been validated against a generated asset.

| Region | Verified ART-002 Creature source | Proposed Spell v01 |
|---|---|---|
| Canvas / runtime card bounds | 1086×1448, `(0,0,1086,1448)` | Identical canvas and aspect ratio |
| Visible outer envelope | Alpha≥128 bbox `(24,0,1034,1444)` | Match the family envelope/margins; rebuild lower corners without stat circles. This is not a pixel-identical silhouette requirement. |
| Renderer illustration coverage | `(124,207,838,642)` | Retain this coverage and large single aperture; sculpted edges overlap the drawing underneath |
| Actual legacy alpha0 opening | Connected bbox `(131,206,823,637)`; curved, not a rectangle | New clear opening approximately within `(132,216,822,620)`, fully covered by the renderer rectangle; no alpha0 spill outside the illustration coverage |
| Title safe rectangle | `(292,90,610,94)` | Retain; quiet backing and room for the current controlled title wrapping |
| Mana value center / safe disk | `(153,151)`, radius 70 | Retain; one upper-left bronze/blue-black mana housing, no number |
| Category safe rectangle | `(180,916,726,66)` | Retain; blank backing for dynamic `Spell` text and the existing optional category cue |
| Effect-description safe rectangle | `(260,990,566,210)` | **`(140,990,806,240)`**, ends at y1230; no ornament, socket shoulder or high-contrast texture inside |
| Rarity crystals | Three painted crystal regions; exact mask contours below | Preserve all three neutral crystal locations and proportions, clear of dynamic text |

Rarity mask contours from `assets/textures/cards/frame_v03_gem_mask.svg`:

- Crown: `(543,24) (564,48) (544,83) (525,49)`.
- Bridge: `(543,836) (565,861) (544,896) (522,862)`.
- Footer: `(543,1247) (567,1286) (543,1337) (520,1287)`.

**Important calibration distinction:** `CardViewLayout.BOTTOM_RARITY_GEM_CENTER` is `(543,1330)`, while the actual footer shader contour spans y1247–1337 and is centered nearer y1290. Do not mistake that nominal layout constant for the painted crystal's visual center. This task changes neither the constant nor the mask. The proposed effect rectangle stops at y1230 to clear the actual crystal region.

The shader mask covers crystal interiors, not their bronze bezels. Its 17 px gap above the footer stone is not proof that the legacy bronze setting clears the proposed text field. For the new Spell frame, compact/re-sculpt any projecting footer bezel outside the entire effect rectangle while keeping the crystal interior registered. Do not blindly copy an old bronze tip into the writing area; measure the actual generated material contours before acceptance.

The old master's alpha0 opening extends one pixel above its nominal renderer coverage. The new Spell brief requires a contained opening instead of copying that discrepancy. Likewise, the legacy reference contains **27,402 alpha-1 pixels**; this is not permission to reproduce alpha-1 contamination in the new asset. Existing approved artwork is not edited.

See [machine-readable reservations](layout-reservations.json), [reference inventory/upload order](references.md), [complete English prompt](image-generation-prompt.md) and [post-generation validation requirements](validation-protocol.md).

## Static and dynamic layering

| Layer | Responsibility |
|---|---|
| Below the frame | Dynamic spell illustration, aspect-filled without distortion and clipped to the proposed aperture coverage |
| Static frame PNG | Bronze/enamel structure; opaque quiet title/category/effect backings; opaque neutral faceted crystal substrates; opaque mana backing with no value |
| Frame material | Existing masked rarity recoloring over the neutral crystal pixels, preserving source alpha and bronze/enamel identity |
| Above the frame | Dynamic full card name, mana cost, `Spell` category, effect text, and any data-driven rarity/accessibility label supplied by the common CardView pipeline |

This proposal has **no additional under-frame material insert**: mana and rarity substrates remain painted opaque, as in the existing master. Rarity is a shader treatment over the painted crystals, not a transparent jewel hole. If a later approved design introduces an underlaid insert, its exact cavity must be alpha0 and its layer/API must be specified before acceptance; do not improvise such holes now.

## Rarity continuity and a verified specification mismatch

The normative English Q181 palette is **Common white/silver, Uncommon blue, Rare red, Epic purple, Legendary gold**. `specs/06-reference/02-decisions.md` and `specs/04-progression-rpg/03-rewards-and-rarities.md` state this explicitly. However, the current theme and `RarityGemTreatment` implement **emerald Epic**. This is an existing implementation/specification mismatch, not a new Spell design decision.

For this preparation, keep the PNG **rarity-neutral** and preserve compatibility with all five shader-applied colors. The T03B upload illustrates the normative five-color palette. Do not bake purple, emerald, rarity names or rarity-specific rank ornament into this single frame, and do not recolor the existing Creature assets or change code. R01B must account for this mismatch against then-current validated decisions before claiming full rarity conformance. This discrepancy does not block preparing a neutral frame.

## Verified current code and future compatibility

The current checkout has `CombatPreviewCards`, `CardViewLayout`, `CardContentOverlay` and `CardCategoryOverlay`. There are **no standalone `card_view.gd`, `hand_view.gd` or `scripts/catalog/card_definition.gd` files** at the checked paths. `CardDefinition` and its `.tres` catalog schema are specified for later roadmap work, not a currently implemented runtime contract. The bounded `scripts`, `scenes` and `resources` inventories were inspected; graph coverage was unavailable for these paths, so direct source was used.

Current presentation contract: `CardContentOverlay.Content` carries `title`, `category`, `tribe`, `rules` and typed keyword spans; categories are `CREATURE`, `SPELL`, `EQUIPMENT`. `configure()` returns an error on overflow and preserves the previously accepted display. Only Creature content gets its tribe appended. Preview fixtures supply cost/stats separately; the current noncreature overlay engraves the old stat sockets. That fallback is **not** the final Spell design and must not be copied into the new artwork. Preview names/effects are presentation samples, not authoritative Lot 1 card definitions.

The normative catalog declares Creature base stats/equipment slots, Spell target/effect operations, Equipment slot category/modifiers, and shared identity/name/mana/rarity/illustration metadata. Spell data has no displayable Creature Attack, Health, Armor or Shield values. The four Lot 1 reference spells are Fireball, Mending Light, Arcane Barrier and Martial Blessing; do not use this art task to change their costs or operations.

Future R01B must use one shared CardView pipeline with a Spell layout variant, not a separate Spell renderer. It must apply Spell-specific reservations without modifying the Creature constants; omit `CardStatOverlay` and legacy empty-socket engravings for Spell faces; preserve mana, card back, rarity shader, content overflow behavior, hand fan/picking/hover and printed-versus-effective stat semantics. Full-frame UVs are required by the current rarity mask. If generation fails to align its crystals, measure and provide a Spell-specific mask during the authorized integration phase rather than recoloring bronze or changing the protected Creature mask. No such integration or mask change happens here.

The existing content overlay currently uses fixed bounds; it does not already accept the proposed wider Spell rectangle. R01B will need a type-specific layout input in the common pipeline while retaining the present Creature defaults. This package specifies that requirement without implementing it. The Creature frame is currently preloaded directly from its `_source` path; no separate Spell runtime-copy filename is assumed or created here.

## Native-scale review contract after generation

Use actual existing production scales: hand height **270 reference px** (180 at 720p), hovered inspection height **540 reference px** (360 at 720p). Historical standalone ART-002 galleries may use other display heights; they are material references, not replacements for these current sizes.

Review at native 1920×1080 and 1280×720: Creature/Spell side by side; single Spell; full/overlapping hand; short and long names; costs 0/2/3/10; the four official spell descriptions plus an explicitly labeled longer typography stress sample; all five dynamic rarities; dark/bright illustration fixtures. Verify that mana/title/type are recognizable in hand and the full effect is comfortably readable in raised inspection, without abbreviating names or silently shrinking below accepted readability. Do not promise full rules-text reading from tiny resting hand cards. Source font point size is not raster ink height.

Before R01B, assess the actual static art at these scales with clearly labeled composition studies if needed; do not claim Godot integration or GPU validation of a nonexistent frame. After authorized R01B integration, use genuine GPU/native desktop captures, retain the 26 px inspection bottom clearance and current card pose dimensions, rerun the relevant regressions and obtain owner review of the generated asset.

## Completion boundary

Prepared now: brief, exact existing reference paths/copies, proposed reservations, layering, alpha/native review protocol and English generation prompt. **NOT_DONE:** Spell generation, PNG delivery, alpha validation of Spell art, owner Spell approval, runtime integration, Equipment variants or P010. The eventual source filename is reserved only; no empty/placeholder production PNG is created. Generate and validate the real Spell frame next, then obtain explicit owner acceptance before R01B.
