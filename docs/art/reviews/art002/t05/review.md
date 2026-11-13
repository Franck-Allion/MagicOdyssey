# ART-002-T05 — Premium Card Typography and Adaptive Content Layout

2026-11-13 · **Technical result: PASS**.

**Recommendation: KEEP_WITH_ADJUSTMENTS.** Keep the reusable component and the current catalog typography. Owner review is still needed for very long titles in the 720p hand and the appearance of dormant non-creature sockets. This is a presentation candidate, not an AAA artistic acceptance or completion of P009/P010. Work stops at T05.

## Files created and changed

- Created `scripts/presentation/card_content_overlay.gd` (+ Godot UID): typed declarative content, native typography, fit limits and explicit transactional overflow.
- Changed `scripts/presentation/art002_card_integration_test.gd`: extracts the hardcoded text into that component, accepts optional presentation content, and selects a cost-only stat overlay for non-creatures.
- Created `docs/art/reviews/art002/t05/fixture.gd`, `fixture.tscn` and `capture.gd` (+ Godot UIDs), six screenshots with import metadata, this report and `validation.txt`.
- The companion scene inherits the existing ART-002 scene and script. It reuses `_card()`, illustration cropping, frame material selection and stat composition; it does not implement another CardView/HandView.

The initial implementation was committed externally while this task was still running: current HEAD is `669e8ad` (`feat(ui): refine card typography and adaptive content layout`). No commit was created or amended by this agent. Subsequent typography refinements, captures and evidence remain in the working tree; see the git-status section below.

## Preservation

Against the pre-T05 baseline `bfe0d8e`, Git blob comparisons confirm unchanged:

- Master frame v03 PNG and original Arcane Knight illustration.
- `card_stat_overlay.gd`, including socket coordinates, glyph centering, automatic circular fitting, sword/heart, Armor and Shield rendering.
- Rarity material factory, gem shader, gem mask, and Theme/design tokens.
- Official card catalog and roadmap.

Frame aspect ratio, RGBA composition, portrait crop and full-frame material UVs are unchanged. Canonical Epic is violet; the pre-existing emerald experiment remains opt-in. No game rules, production UI, main combat scene or roadmap status was edited.

## Typography architecture

`CardContentOverlay.Content` supplies a title, a category enum (`Creature`, `Spell`, `Equipment`), optional tribe, literal rules text and ordered `KeywordSpan` character ranges. There are no card IDs or combat-engine dependencies.

The component uses Godot `Label` for title/type and synchronous `RichTextLabel` for rules. It takes fonts and colors from the existing Theme:

- Title and type: `CardTitle` fantasy serif SystemFont, using the Theme's Cinzel/Trajan/Palatino/Georgia fallback chain.
- Rules: normal body font and restrained bold body font, using the Theme's Segoe UI/Calibri/Arial chain.
- Ivory title/body, muted gold type line. Armor/Shield emphasis is bold in the same body color, without chips, color coding or inline debug tags.

Bold spans are measured and rendered by the same native RichTextLabel. They may affect word widths; fitting includes that effect. Literal input is added with `add_text()`, not interpreted as BBCode. No custom text renderer, letter-spacing compression or layout-driven game logic was introduced.

Source-space regions within the 1086 × 1448 card:

| Field | Rectangle | Strategy |
| --- | --- | --- |
| Title | `(292,90,610,94)` | One line, centered in the nameplate; 68 preferred, 40 minimum. |
| Type/tribe | `(180,916,726,66)` | 48 px serif; centered, fixed position. |
| Rules | `(260,990,566,210)` | Natural word wrapping; 48 preferred, 30 minimum; wrapped block vertically centered. |

The narrow rules column keeps text away from the upper shoulders of the two circular stat sockets. Rules line separation uses the font's native line metrics, with zero additional line separation; lines are not compressed with negative spacing. Typography stays subordinate to the original artwork and bronze frame.

## Title fitting, baseline and envelope

Native `Font.get_string_size()` estimates the largest single-line size within the 610 px width. The result is verified and stepped down only if necessary, with no size below 40 and no ellipsis. The same serif family, centered Label line box and nameplate position preserve consistent alignment as the size changes.

| Tested title | Characters | Font size, source px |
| --- | ---: | ---: |
| Fireball | 8 | 68 |
| Arcane Knight | 13 | 68 |
| Guardian of the Ancient Grove | 29 | 43 |
| Guardians of the Ancient Grove | 30 | 41 |

The 29/30-character neighbors change by only 2 source pixels. All **16 official catalog names fit at the preferred 68** on this Windows installation. The 30-character name is the longest supported title in this review's tested set, not a universal character maximum. An 89-character title is explicitly rejected at the minimum size.

The actual envelope is measured width at 40, not a character count: wide capitals and narrow lowercase letters differ. For future naming, prefer the current catalog's concise style. **Proposal:** require art review for names that need below 60 source px, especially if recognition at 720p hand scale matters. This is a recommendation, not a modification to official names or catalog policy. The component's 40 px floor protects inspected-card readability; passing it does not certify hand readability.

## Rules wrapping, fitting and overflow

The component first tries 48 px with natural word wrapping, then reduces the normal and bold sizes together by one source pixel until the complete native text block fits the 566 × 210 region. It stops at 30. It never truncates a paragraph, adds ellipses, scrolls a card's rules, removes words or replaces text with decorative marks.

Measured examples:

| Content | Characters | Native lines | Font size | Content height |
| --- | ---: | ---: | ---: | ---: |
| No rules | 0 | 1 empty native line | 48 | 65, no visible glyphs |
| `Armor 1.` | 8 | 1 | 48 | 65 |
| Fireball operation wording | 35 | 2 | 48 | 130 |
| Arcane Knight visual rule | 46 | 2 | 48 | 130 |
| Five explicit explanatory lines | 120 | 5 | 31 | 210 |
| Multi-sentence protection explanation | 163 | 5 | 31 | 210 |

Thus five lines are supported for the tested texts, but not at arbitrary length or size. The envelope depends on word widths, punctuation, bold spans and explicit line breaks. The repeated 445-character stress paragraph is rejected rather than shrunk beyond the floor.

`configure()` returns `ERR_PARAMETER_RANGE_ERROR` (5) and exposes `title_overflow`, `rules_overflow` and `overflow_reason` when the readable envelope is exceeded. Invalid title/spans return `ERR_INVALID_DATA`. A rejected update leaves the last accepted title/type/rules nodes intact. The caller retains the full rejected Content input. The stress screenshot shows that full rejected input outside the card alongside an accepted long-title/five-line card; this is a review diagnostic, not a new production inspector. No rejected card is represented as having a complete printed paragraph.

## Category behavior and fixture provenance

- **Creature:** `Creature · Tribe` when a tribe exists; `Creature` alone otherwise. Printed base Attack/Max HP and the existing protection overlay remain available.
- **Spell:** `Spell`, without a tribe separator. Mana uses the existing renderer; the original footer sockets remain dormant midnight enamel. No Attack/Health numerals, sword/heart emblems or fake zero values are drawn.
- **Equipment:** same deliberate dormant socket treatment, with `Equipment` as category. No invented combat stats are displayed.

The cost-only adapter subclasses CardStatOverlay only to select what is drawn; it calls the approved mana rendering method and changes none of its algorithms or coordinates. Creature stat composition is preserved.

Official sample names/costs/base values are taken from the Lot 1 catalog where applicable: Fireball, Rampart Guard, Bastion Armor, Arcane Barrier and Ancestral Drake. Operation text is presentational prose derived from the catalog, not a newly ratified printed-text specification. Arcane Knight and both Grove titles are clearly labeled typography fixtures; their reused 4/5 numbers are visual samples, not new official definitions. Protection explanations and the five-line paragraph explain existing terminology, not new card abilities.

Only one committed card illustration is available. It is reused unchanged and identified on every review page as shared test artwork. Distinct final illustrations, especially for Spell/Equipment, remain unavailable; no substitute art was generated.

## Screenshots generated and visually reviewed

All are real Godot GPU SubViewport captures, not resized composites or synthetic mockups.

| Screenshot | Dimensions | Review |
| --- | --- | --- |
| [title_length_samples_1080p.png](title_length_samples_1080p.png) | 1920 × 1080 | Fireball, Arcane Knight and the 29-character Grove title side by side at 740 px card height. |
| [rules_text_samples_1080p.png](rules_text_samples_1080p.png) | 1920 × 1080 | No text, one line, wrapped text and five explicit lines; 580 px comparison cards. |
| [card_categories_1080p.png](card_categories_1080p.png) | 1920 × 1080 | Creature/Spell/Equipment at 740 px, including dormant non-creature sockets. |
| [mixed_hand_1080p.png](mixed_hand_1080p.png) | 1920 × 1080 | Seven varied fixtures at 316 px hand-card height. |
| [mixed_hand_720p.png](mixed_hand_720p.png) | 1280 × 720 | Same hand at about 158 × 211 px per card. |
| [typography_stress_test_1080p.png](typography_stress_test_1080p.png) | 1920 × 1080 | Accepted 30-character title + five-line paragraph at 760 px inspection height, plus complete rejected stress input. |

Inspection findings: the title/type/rules hierarchy is coherent, short paragraphs retain comfortable space, long content stays inside the dark panel and the five-line stress block clears the footer. The 30-character title remains readable at inspection size. Unused sockets are neutral and consistent, but still visibly look like vacant stat settings; their final visual acceptability needs owner review.

Hand findings: current short/medium catalog titles, costs and creature numerals remain scan targets at both resolutions. The 29-character title is marginal at 1080p and **not comfortably readable at 720p**: 43 source px becomes about 6.26 nominal screen px. The 30-character stress title is about 5.96 nominal screen px at that scale. Dense rules and fine keyword emphasis require inspection, as permitted by this task. The 48 px type line is only about 6.98 nominal screen px at 720p and remains a secondary cue; separating Spell from Equipment by that small line alone is weak. The repeated portrait also prevents illustration-based category recognition. These are limitations, not claims of full AAA readability.

## Automated verification and actual exit codes

Engine: `D:\Temp\Godot_v4.7.2-stable_win64.exe` (`4.7.2.stable.official.ed1daf0bf`). GPU captures: OpenGL Compatibility / NVIDIA GeForce GTX 1660 Ti.

Use `$GodotExe = 'D:\Temp\Godot_v4.7.2-stable_win64.exe'` from the repository root:

| Command | Actual exit | Result |
| --- | ---: | --- |
| `& $GodotExe --headless --editor --path . --import --quit` | 0 | Sources and review assets import; empty final stderr. |
| `& $GodotExe --headless --path . --script res://scripts/tests/test_runner.gd` | 0 | 14/14 existing harness assertions pass. These are harness self-tests, not comprehensive gameplay coverage. |
| `& $GodotExe --headless --path . res://scenes/ui/art002_card_integration_test.tscn --quit-after 5` | 0 | Existing ART-002 scene launches with the extracted content component; empty stderr. |
| `& $GodotExe --headless --path . --script res://docs/art/reviews/art002/t05/capture.gd -- --verify-only` | 0 | 125 checks pass: fit, full text retention, bounds, type formatting, font floors, glyph coverage, all catalog titles, smooth neighboring-title sizing, literal BBCode input and transactional overflow. |
| `& $GodotExe --path . --script res://docs/art/reviews/art002/t05/capture.gd` | 0 | 138 checks pass: those 125, seven GPU text masks, six captures at exact dimensions; empty final stderr. |
| `& $GodotExe --path . --script res://docs/art/reviews/art002/t03c/verify_gems.gd` | 0 | All six existing gem regression cases pass, including canonical violet and opt-in emerald. Zero alpha changes and zero outside-mask changes. No historical evidence files are rewritten. |
| `git diff --check` | 0 | No whitespace errors; normal LF-to-CRLF advisory. |

Native geometry checks validate title/type/rules Controls against their designated rectangles, the complete parsed rules string, line height, size floors and font glyph support. GPU text masks render the actual component at source resolution, allowing a 1 px antialiasing margin around regions; seven cases show **zero pixels outside the regions** and **zero overlaps with detected warm bronze pixels** in the source frame. Detection uses alpha >16/255 for text and the same conservative warm-metal color thresholds documented by the test. This is useful geometric evidence, not proof of human readability or a replacement for owner review.

Stat preservation is verified by exact Git blob equality of the complete approved stat renderer against `bfe0d8e`, plus inspection of the integrated screenshots. The T04B numeric matrix was **not rerun**, so its earlier 144-case result is not presented as a new T05 test. Earlier evidence is preserved. An initial text-test run exited 1 for a five-line block that exceeded its then-current region; that layout was revised and both final runs pass.

## Git status and remaining work

The session began from the completed T04B baseline. HEAD advanced externally to `669e8ad` during implementation; the initial extraction and new review files are therefore already tracked there. Final refinements modify `card_content_overlay.gd`, `t05/fixture.gd`, `t05/capture.gd` and the six T05 PNGs. New report/evidence and Godot-generated UID/import metadata are also present. No agent commit or amend was made.

Remaining review points: decide whether long names should be constrained for hand readability; confirm the dormant-socket treatment; supply distinct category/card art later. Other Windows font installations/platforms require another visual pass. No low-vision user study, live combat session, hover/drag input, production inspector or manual keyboard-mode test was run. No T06 or roadmap work was started.
