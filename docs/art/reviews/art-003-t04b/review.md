# ART-003-T04B — Opponent HUD composition and proportion study

2026-11-15. **Offline study complete; no production integration. Owner visual approval pending.**

**Result: none of A–F meets the complete brief.** The 272 px envelope with this backplate and two horizontal ornate housings is insufficient for comfortably readable internal values at 720p. Increasing height to 312 px reduces border interference but does not improve the numeric aperture or type size. Retain **272 × 296** as the preferred envelope for the illustrated alternative: small resource color cues with values beside them. This is a proposed arrangement, not an approved redesign.

## Evidence and viewing scale

- [Six variants, 1080p](opponent_hud_comparison_1080p.png), [720p](opponent_hud_comparison_720p.png): normal values above, worst cases below.
- [Worst cases](opponent_hud_worst_case_values.png): all six at 1080p above and actual 720p physical size below.
- [Recommended alternative, 1080p](opponent_hud_best_candidate_1080p.png), [720p](opponent_hud_best_candidate_720p.png).
- [Alternative at both physical scales](opponent_hud_fallback_proposal.png).
- [Screen context, 1080p](opponent_hud_screen_context.png), [720p](opponent_hud_screen_context_720p.png).
- [Exact text measurements and source SHA-256 hashes](measurements.json), [layout measurements](geometry.json), [reproduction script](compose.py).

Open originals at **100%**. The 1080p and 720p canvases are respectively 1920 × 1080 and 1280 × 720; HUDs are never enlarged for presentation. Every primary variant uses the same reference-to-physical scale. The 720p files are uniformly downsampled by 2/3. On the mixed-scale worst-case and fallback sheets, the two physical scales are explicitly identified. Embedded application/browser thumbnails can obscure this difference.

The required `best_candidate` files deliberately show the supported alternative: no primary candidate passed. Their annotations identify this as a proposal. All comparisons and context images are composited studies, **not newly rendered or integrated CombatScreen screenshots**.

## Source assets and transparency

| Existing file | Native dimensions | Use |
|---|---:|---|
| `assets/_source/lot1/hud/opponent/mo_hud_opponent_panel_v01.png` | 1202 × 1308 | Supplied opponent candidate; present at task start, untracked |
| `assets/_source/lot1/hud/player/mo_hud_player_portrait_frame_v01.png` | 1254 × 1254 | Approved portrait frame |
| `assets/_source/lot1/hud/player/mo_hud_player_health_orb_housing_v01.png` | 1254 × 1254 | Same approved housing for both resources |
| `assets/_source/lot1/cards/illustrations/mo_illustration_arcane_knight_test_v01.png` | 1086 × 1448 | Existing test illustration, temporary portrait only |
| `docs/art/reviews/p005-r06e/combat_screen_1080p.png` | 1920 × 1080 | Current bottom-left player HUD and battlefield context |
| `assets/_source/lot1/battlefield/wip/mo_battlefield_sundered_observatory_bg_wip_v03.png` | 1672 × 941 | Background patch behind the removed old opponent block |

All source PNGs are read only. The portrait uses the existing face crop `(260,40)..(760,540)`; no new opponent identity, official character or mechanic is introduced. System fonts are Windows Segoe UI and Segoe UI Bold (`segoeui.ttf`, `segoeuib.ttf`), available locally and consistent with the theme's body-font family. No font files are copied into the repository.

The panel has substantial native transparent padding. At alpha > 8/255 its visible source bounds are `(156,18)..(1045,1257)`, only **889 × 1239**; nonzero alpha also contains very faint outlying pixels. The PNG canvas ratio must not be mistaken for the painted silhouette ratio. At 296 reference pixels high the visible panel is approximately **202 × 281**, not 272 × 296. At 312 high it is approximately **213 × 296**.

The panel is scaled uniformly by height: approximately 272 × 296 for A–C and 287 × 312 for D–F. D–F are centered in the 272 px envelope, cropping eight left/seven right raster columns of near-transparent padding, with no visible bronze clipped. There is **no anisotropic stretch**, extension, separator relocation, or new taller painting. Integer rounding is at most one raster pixel. Thus this is a study of the actual supplied art; a future artist-authored taller panel might distribute its internal space differently.

Portrait and liquid masks come from the **center-connected transparent component** of the corresponding approved PNG. The original inverse alpha supplies the fringe; a one-source-pixel dilation includes the antialias boundary. Exterior transparency remains excluded. Portrait/liquid are composited underneath the unchanged metal. There are no opaque disks laid over the housings. Reservoirs are static red/blue preview gradients filling the aperture, not the animated Godot shader.

The source portrait aperture bounds are `(160,175)..(1093,1055)` and housing aperture bounds `(203,209)..(1036,1046)`. The latter is about **0.664 of the external diameter**, before conservative text clearance. Downsampled mask support includes a faint antialias fringe; it is not all usable liquid area.

## Layout held constant

Panel-local coordinates, in 1080p reference pixels:

- Portrait frame: **88 × 88**, x=92, y=38 for A–C and y=40 for D–F. Visible metal is about 82 × 82; portrait opening about 65 × 62, or 43 × 41 physical pixels at 720p. The existing face remains identifiable, with limited fine detail. This small portrait prevents dominance and clears the crest and separator. Bronze-mask diagnostic finds zero portrait-to-panel metal overlap in all six.
- Nominal orb centers: x=81 and 191, shared y=205 for A–C or 217 for D–F. Both housings have identical dimensions and remain horizontally aligned. Integer placement moves odd-diameter C/F centers by -0.5 px on both axes; tables below use the actual rounded raster boxes.
- Normal values: `30 / 30`, `5 / 5`. Worst values: `100 / 100`, `10 / 10`. These are separate text draws on the compositions, never changes to source artwork.

## All six primary variants

Gaps below are reference pixels. Lower-ornament gap is a **conservative vertical projection** against the central lower metal, not a Euclidean collision distance; a negative projected gap alone does not prove an intersection because the center ornament lies between the orbs. Side intersections are supported by visible image inspection and the diagnostic described below.

| Variant | Panel / orb | Box gap between orbs | Orb top to separator bottom | Orb bottom to lower ornament projection | Diagnostic side intersections, HP / Mana pixels | Result |
|---|---|---:|---:|---:|---:|---|
| A | 272 × 296 / 90 | 20 | 26 | 6 | 303 / 268 | Best preferred-height baseline; still intersects side metal and fails worst-case readability |
| B | 272 × 296 / 100 | 10 | 21 | 1 | 471 / 475 | Larger liquid, crowded sides and lower edge; fails |
| C | 272 × 296 / 105 | 5 | 18 | -1 | 486 / 509 | Lowest breathing room and distracting rim competition; fails |
| D | 272 × 312 / 90 | 20 | 31 | 8 | 60 / 80 | Closest primary geometrically; small side intersections remain, identical type to A; fails |
| E | 272 × 312 / 100 | 10 | 26 | 3 | 332 / 352 | Height helps separation, not width or worst-case type; fails |
| F | 272 × 312 / 105 | 5 | 23 | 1 | 460 / 431 | Larger image but still cramped and ornament-heavy; fails |

The bronze diagnostic uses actual rendered RGB (`R > 1.12G`, `G > 1.12B`, alpha > 128), intersected with housing alpha > 128; side bands are x<70 and x>=202. Counts are approximate evidence of interference, **not an artist-authored material mask or exact optical judgment**. Zero projected whitespace is not used as approval. Measurements and the real-size images must be considered together.

The source housing's central glass is only approximately **60 / 66 / 70 px** across for external diameters 90 / 100 / 105; at 720p this becomes **40 / 44 / 47 px**. The ornament consumes too much of the available space for long internal values. The horizontal gaps also shrink to 13.3 / 6.7 / 3.3 physical pixels.

The portrait's visible bottom is approximately y=122/124, leaving about 4/9 px before the separator begins. Its decorative silhouette clears even the largest orb's upper bound by about 30/40 px; portrait-to-orb overlap is not the limiting factor.

## Exact typography and bezel clearance

Values use bold Segoe UI, captions regular, with a 1 reference pixel dark outline. Each value starts at diameter × 0.19 and shrinks to fit an ink width <= diameter × 0.56. Sizes are chosen independently for the actual string. Captions are centered at cy − 0.16d, values at cy + 0.065d. The same rules apply in all six variants.

| Variants | Caption font, HP and MANA | HP normal / worst font | Mana normal / worst font | Worst HP font at 720p | Minimum worst HP ink-to-aperture edge |
|---|---:|---:|---:|---:|---:|
| A, D | 9 | 14 / 11 | 17 / 14 | 7.33 | 2.83 px (1.89 at 720p) |
| B, E | 10 | 16 / 12 | 19 / 16 | 8.00 | 2.00 px (1.33 at 720p) |
| C, F | 10 | 16 / 12 | 20 / 16 | 8.00 | 3.00 px (2.00 at 720p) |

Exact ink boxes for every string, including outlines, are recorded in measurements.json. Minimum clearance is computed from nontrivial text-ink pixels to the boundary of the resized aperture's alpha >= 240 safe region. It is a conservative pixel diagnostic, not a guarantee against perceptual crowding after downsampling. Normal HP clearances are 2.83 / 3.61 / 5 px; normal Mana 6.32 / 8.60 / 7.21 px for the three diameters.

At **1080p**, the normal values can be deciphered in all six, and the temporary face is recognizable. Multi-digit HP is noticeably subordinate to the ornament: only an 11–12 px font. B/C/E/F gain little numeric benefit because the longer string still forces shrinking. Red and blue distinguish resources, while the delicate panel and brighter, busier housing have unequal material weight. Housing filigree attracts more attention than the information.

At **720p**, normal HP has an effective 9.3–10.7 px font, worst HP 7.3–8 px, and captions 6–6.7 px. The worst HP ink itself is only about 7–8 physical pixels high. HP and especially MANA captions lose optical clarity; outlines and metal detail compete with the digits. The strings technically fit and remain off the rim in the measured masks, but **they are not comfortably readable without zoom**. This rejects every primary configuration. Portrait detail also reduces at 720p, although the head/armor silhouette remains identifiable.

## 296 versus 312 and player clearance

Nominal player placement remains x=24..296, y=344..1044. A–C end at y=320 and leave **24 reference / 16 physical px** at 720p. D–F end at y=336 and leave **8 reference / 5.33 physical px**.

Painted silhouettes tell a less severe story: opponent visible lower edges are approximately y=309 and y=324. The current player panel's crest begins near y=351 (source crop and alpha > 8), giving approximately **42 versus 27 reference px**, or **28 versus 18 physical px**. These are approximate vertical silhouette projections; tiny alpha noise is excluded. The 312 version is therefore **not rejected merely because its logical gutter is 8 px**. It has more visible separation than that rectangle suggests. It is rejected because the extra height does not fix numeric readability or fully resolve side collisions, while consuming 16 px of the reserved vertical budget.

The annotated context uses the current R06E screenshot. Only the obsolete opponent block is patched with a crop of the existing background, the proposed top-left composition is overlaid, and a study banner is added. The current player rectangle is checked **bit-exact** against the source capture. This shows the relationship to the battlefield and bottom-left HUD without changing production geometry.

## Supported alternative and reuse recommendation

**Recommended envelope: 272 × 296.** Keep the 88 px portrait. Place two **44 × 44** copies of the existing housing as resource color cues at `(58,140)` and `(58,194)`, with captions and values beside them at x=110. Caption font **16 px**, main value **23 px bold**, values 17 px below caption origins. At 720p these become **10.67 and 15.33 px**, materially larger than the primary worst-case figures. The accompanying image tests the worst strings. The normal strings require less space.

This arrangement deliberately changes the resource layout: it is an explicit alternative, not a seventh approved horizontal-orb variant. It preserves the supplied panel and assets and puts the information ahead of filigree. The 720p proposal is visibly easier to read. Tiny housings now communicate color/material rather than containing text; their filigree is no longer expected to be individually resolved. Owner acceptance is still required.

For the alternative, actual combined caption/value ink boxes are `(111,147)..(210,185)` and `(111,201)..(184,239)`. Both text layers and both housing layers have zero intersections with the diagnostic panel-metal mask. Housing-to-text box separation is at least 9 px horizontally; actual liquid/metal edge is further inside. These checks supplement the inspected full-screen context rather than approving the art.

The portrait frame is reusable, with a tightly cropped face and restrained size. The housing is **not suitable for comfortable internal worst-case values at 90–105 px** under this brief. It is reusable as a color cue in the illustrated alternative, subject to owner review. If the owner requires numbers inside two horizontally aligned orbs, **new artistic refinement is necessary**: less ornate metal, a larger glass-to-frame ratio, and a panel whose painted interior uses more of the 272 px width. No new artwork is generated here. For the external-value alternative, no new source artwork is technically needed.

## Reproduction, verification and boundaries

Run from the repository root:

```powershell
python docs/art/reviews/art-003-t04b/compose.py
```

Python/Pillow/numpy only. Generated files stay beside the script. Input SHA-256 hashes are checked before/after composition; the script asserts preservation of the current player region in the context. Six variants × two value sets are rendered. Final successful composition reports exit **0** and `PASS: 6 variants x 2 value sets; 1080p/720p; source hashes unchanged; player context bit-exact.` Visual inspection covers both comparison resolutions, worst cases, proposed alternative and screen context.

Only this new review directory is added. The pre-existing untracked opponent source remains untouched and uncommitted. No production scenes, scripts, shaders, approved PNGs, player HUD, hand, battlefield geometry or combat rules are edited. No roadmap advancement or executable export.

**NOT_RUN by scope:** Godot headless suite, native GPU capture, actual in-engine font rasterization, animation and Windows executable testing. This is an offline bitmap proportion study. The 720p reduction evaluates this composition's optical limits; any future approved integration still requires native-size Godot validation. Automated diagnostics do not constitute artistic approval. Stop after ART-003-T04B; P005-R07B is not implemented.
