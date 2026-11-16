# P005-R09A - Global CombatScreen Visual Audit

2026-11-16. Windows; Godot 4.7.2 stable; OpenGL Compatibility; NVIDIA GeForce GTX 1660 Ti.

## 1. Executive summary

**TARGETED_CORRECTIONS_REQUIRED.** Preserve the current composition and artwork. Materials, side-column alignment, utility hierarchy, hidden information and native input are technically sound. However, hover inspection is not comfortably readable at 720p: the full long card title renders at **8.51 physical px**, and sampled rules at **9.32-9.72 px**. This is a **MAJOR readability issue**, despite passing bounds and interaction tests. A focused correction is recommended before owner P005 sign-off; global redesign is not justified.

**Technical verification: PASS.** 2476/2476 native assertions, ART-002 3/3 bit-exact, real GPU scenarios at both resolutions and isolated Windows input/animation/ESC checks all succeeded with exit 0. **129 protected production files retain their SHA-256 bytes.** Default GPU frames remain bit-exact with R08C at both sizes.

No production scene, behavior, shader, PNG, rule or tactical position changed. P005 remains pending explicit owner artistic approval. Gate G1 is not complete. P006-P010 and Hero Artifact gameplay are not implemented or approved by this audit.

## 2. Scope and authority

Read the relevant AGENTS protocol, scope, roadmap, cards/inspection specification, glossary, PLAN-002 decisions, progress tracker and R07B/R08B/R08C reviews. Ten displayed cards are a **presentation stress capacity**, not a change to the normative seven-card hand limit in scope section 3.6 / Q39.

PLAN-002 Hero Artifacts are progression inventory objects, not cards or Creature Equipment. They consume no tactical Creature slots. Starting/max Artifact Capacity remains undecided. Dedicated Spell/Equipment visuals remain future P009-R01A/B and P009-R02A/B work.

Inspection used task-directed Tier 2 graph search, traces and snippets, with exact source fallback for metadata-changed/not-tracked coverage. This is a bounded visual audit, not an exhaustive architecture audit. Permitted changes consist of audit scripts, evidence and documentation only.

## 3. Baseline and preservation

Baseline **`9ae59b6`**, the PLAN-002 documentation commit following **`42a3761`** (R08C). [production_manifest.json](production_manifest.json) records the full revision and hashes of 129 tracked scene, presentation/domain, resource/shader, asset and project/export files. [analyze.py](analyze.py) verifies every protected byte after import, GPU rendering and Windows export. Git shows no production edits.

Audit scripts and artifacts are isolated in this directory; the only existing tracked document changed is `docs/progress/lot1-progress.md`. Source tests are unchanged. The rebuilt Windows EXE remains an ignored build product.

## 4. Method and actual commands

Commands ran from `D:/Dev/MagicOdyssey`; `$GodotExe = D:/Temp/Godot_v4.7.2-stable_win64_console.exe`.

| Command | Actual result | Exit |
|---|---|---:|
| `& $GodotExe --headless --path . --editor --import --quit` | Clean headless import | 0 |
| `& $GodotExe --headless --path . --script res://scripts/tests/test_runner.gd` | **2476/2476 PASS**, including CombatScreen, hover, hidden-hand, utility and reservoir suites | 0 |
| `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/tests/run_visual_regression.ps1` | ART-002 **3/3 bit-exact**, no golden changes | 0 |
| `& $GodotExe --path . --script res://docs/art/reviews/p005-r09a/capture.gd` | Both GPU sizes, scenarios, actual pointer/keyboard and six timed motion samples per size | 0 |
| `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/build_windows.ps1` | Embedded Windows EXE rebuilt | 0 |
| `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/tests/playtest_windows.ps1 -ReviewDir docs/art/reviews/p005-r09a -HandCount 10 -AnimateResources -UtilityHud` | Isolated desktop in three modes; input, animation, ESC | 0 |
| `python docs/art/reviews/p005-r09a/analyze.py --desktop` | Source preservation, geometry and motion/input evidence verified | 0 |
| `git diff --check` / `git diff --cached --check` | Clean whitespace | 0 |

Actual logs accompany this review. The initial GPU run also exited 0; the final run adds explicit fixture labels and full populated-hover evidence. No production fix occurred between runs. Technical PASS does not override the artistic finding.

Production frames use the real production scene in exact-size Godot SubViewports. Closeups copy actual rendered pixels at native physical scale. Stress states have on-screen AUDIT labels. Crowded geometry and reservation overlays are explicitly diagnostic, not approved designs. No screenshot is reconstructed or retouched to hide a defect.

## 5. Composition and painted-bound measurements

Reference coordinates are 1920x1080; 720p uses uniform factor 2/3. Painted bounds use source alpha >8/255, actual AtlasTexture crops and runtime texture rectangles. [analysis.json](analysis.json) retains measurements; [observations.json](observations.json) records runtime transforms, fonts and times.

| Element | Geometry | Actual paint / optical alignment |
|---|---|---|
| Player hero panel | (24,344), 272x700; nominal x=160 | x=38.96..278.32, y=352.64..1034.45; center x=158.64 |
| Opponent hero panel | (24,24), 272x296; nominal x=160 | x=55.20..265.04, y=25.42..317.88; center x=160.12 |
| Left panels | same geometric axis | painted centers differ **1.48 px**; visible vertical separation **34.76 px** |
| Utility panel | (1624,372), 272x684 | x=1647.16..1872.49, y=375.13..1051.47; center x=1759.83 |
| Turn/phase panel | (1624,220), 272x136 | x=1645.05..1874.82, y=265.36..353.25; center x=1759.93 |
| End Turn | 190x47.4545 Button | x=1666.38..1852.93, y=893.18..938.09; center x=1759.65 |
| Battlefield envelope | x=320..1600, y=220..780 | axis x=960 |
| Actual six-column guides | x=480..1542 | axis x=1011: **51 px right** of screen center, because of the left row-label gutter |
| Opponent hidden hand | axis x=960 | paint x=720.57..1199.43, y=33.10..185.15; centered at x=960 |
| Resting player fan, 7/10 | same outer spread; axis x=960 | paint x=343.36..1575.90, y approximately 775.91..1072.78; painted midpoint x=959.63 |

The top opponent margin is 25.42 px. Bottom margins are 45.55 px for player panel, 28.53 px for utility and 7.22 px for hand paint. Status/utility painted gap is 21.88 px, with only 0.10 px center difference and 4.44 px width difference.

The last guides end y=774, only **1.91 px minimum projected clearance** from the fan, despite a 24 px logical battlefield/hand gap. This is a future-token density reservation, not present clipping. R08C's unchanged source-alpha analysis still gives miniature side margins 11.52/12.43 px, inter-card gap 16.26 px and button side gaps approximately 8.42 px. Silhouette bounds supplement actual image inspection; they do not establish artistic acceptance alone.

## 6. Scenario A - default and global artistic assessment

[Default 1080p](combat_default_1080p.png) / [720p](combat_default_720p.png).

Bronze ridges and midnight-blue interiors form a consistent family. Player frames have brighter, more intricate highlights than utility panels, giving cards and hero identity greater weight while the right column remains secondary. This difference does not demonstrate a need to repaint approved assets. No baked checkerboard, severe fringe, stretched panel or default clipping is visible.

The hand attracts attention first, with player portrait/resources next. The empty battlefield is quieter; final hierarchy with real tokens remains deferred. The observatory's perspective survives the restrained overlay. Row labels balance the grid's rightward offset optically, but centering its parent alone would miss that offset. Compact opponent presentation is deliberately less prominent. The right column's quiet space is coherent with an empty log and avoids a separate framed text box. Preserve this composition rather than redesign it.

## 7. Scenarios B/F - full hand and inspection

[Full hand 1080p](combat_full_hand_1080p.png) / [720p](combat_full_hand_720p.png). Ten cards are a stress fixture; gameplay cap remains seven.

All mana circles remain exposed. Actual viewport motion reaches indices 0, 4 and 9, plus Spell index 1 and Equipment index 2. Each settles into INSPECTING and returns to IDLE after leaving. Rapid 0/2/4/6/8/9 scrubbing also settles. Existing native tests and Windows pointer checks corroborate this. At-rest names/rules are necessarily small or partly covered, making hover detail readability important.

Inspection is **330x440 reference px**, or **220x293.33 physical px at 720p**. Left bounds (336,604)..(666,1044) and right bounds (1254,604)..(1584,1044) stay in the viewport and clear both side-column envelopes by 40 reference px. Inspection temporarily obscures lower battlefield slots; this is a hover tradeoff, not a new P010 inspector.

| Inspected text | 1080p physical font | 720p physical font |
|---|---:|---:|
| Short titles | 20.66 px | 13.78 px |
| Archon of the Sundered Sphere, full name | **12.76 px** | **8.51 px** |
| Sampled rule text | 13.98-14.59 px | **9.32-9.72 px** |

Full names are preserved and source-space text fits. At native 720p, however, the long title and rules demand squinting or image zoom. **R09A-001 / MAJOR** prevents a sign-off recommendation.

[Left 1080p](combat_hover_left_1080p.png), [center](combat_hover_center_1080p.png), [right](combat_hover_right_1080p.png), [right 720p](combat_hover_right_720p.png), [Spell 720p](combat_hover_spell_720p.png), [Equipment 720p](combat_hover_equipment_720p.png), [return to rest](combat_hover_return_720p.png).

## 8. Scenario C - crowded 24-slot envelope

[Crowded diagnostic 1080p](combat_crowded_board_1080p.png) / [720p](combat_crowded_board_720p.png).

Twenty-four explicitly labeled **geometry placeholders** occupy existing guides without moving them. Each is 146x100 inside a 162x112 guide. W/P marks probe Creature Weapon/Protection envelopes; A/H and S1/S2/S3/+N are synthetic density labels, not working stats/statuses or Hero Artifacts.

Six columns and four rows remain distinct. Horizontal gaps are 18 reference / 12 physical px. Guide row tops are 226/362/526/662; normal vertical gaps are 24 px and opposing attack-row gap is 52 px. Inset rectangles fit; their 720p content area is only 97.33x66.67 physical px, with cramped smallest diagnostic labels.

**Crowded-board scalability: DEFERRED.** Flat rectangles cannot approve a sculpted crest, portrait, stat values, statuses, attachment badges, selection and VFX. The lower guide/fan proximity needs real P008 artwork. This neither fabricates P008 completion nor requires an unrequested slot redesign.

## 9. Scenarios D/E - utility and extreme values

[Populated 1080p](combat_populated_utility_1080p.png) / [720p](combat_populated_utility_720p.png), [hover in context](combat_populated_utility_hover_720p.png), [worst values 720p](combat_worst_case_values_720p.png).

Controlled snapshots show three recent actions, player deck 100, opponent deck 34, player face-up graveyard 12 and opponent face-up graveyard 1. These are **last-entering snapshots**, independent of last-played cards and real combat state. Defaults show empty graveyards. Both decks reuse the hidden hand's official back.

Extremes use Health 100/100, Mana 10/10, all pile counts 100, TURN 10, END-OF-TURN ATTACK and a long action plus two short entries. At 720p: player Health is 16.67 physical px, Mana 20.67 px, opponent values 15.33 px. Counts and phase fit. The 10.67 px recent-action body fills five visible lines without truncating this fixture; unsupported longer input retains existing ellipsis containment.

The centered 19 px heading remains stronger than the 16 px body. Miniature illustrations/counts remain identifiable; their rules are intentionally not readable at this size. End Turn remains separate from panel metal, with distinct native states and no automatic turn advancement. Utility receives PASS_WITH_RESERVATIONS for limited fine detail at 720p, not for clipping or missing counts.

## 10. Scenario G - timed resource motion

Six actual samples per resolution are `resource_animation_1080p_00..05.png` and `resource_animation_720p_00..05.png`. Individual `orb_<resolution>p_<0..3>_<frame>.png` crops preserve physical scale. Order: player Health, player Mana, opponent Health, opponent Mana. Actual times are in observations.json; analysis.json records changes.

Adjacent 1080p samples change **433-465 / 471-514 / 51-62 / 56-68 pixels** respectively; 720p ranges are **223-252 / 233-258 / 25-35 / 27-36**. All four move at stable 3/5 fill with unchanged text. Eight timed desktop frames per mode independently confirm motion.

The meniscus, darker depth, curved reflections and secondary wave read as liquid, not gaseous-only movement. Red/blue and text remain distinguishable. Bubbles are intentionally tiny. The shader's 0.003 amplitude corresponds to approximately **0.49 px player / 0.12 px opponent** at 1080p and **0.32 / 0.08 px** at 720p. Opponent motion is therefore subdued (**R09A-002 / MINOR**), while external values remain clear. More expressive motion would be optional owner-directed work.

Actual GPU sample spans are approximately 7.14 s / 4.14 s. PNG I/O affects sampling: these are **not frame-rate benchmarks**. No rendering/process error was observed. CPU/GPU utilization, frame-time percentiles, long-session stability and other renderers are **NOT_VERIFIED**.

## 11. Hero Artifact reservation study

[artifact_space_study.png](artifact_space_study.png) is a real GPU frame plus an explicit **AUDIT OVERLAY ONLY**. It is not approved UI, an Artifact card, inventory object, effect or capacity implementation.

| Candidate | Reference area | 720p area | Finding |
|---|---|---|---|
| A: adjacent to player HUD | (296,344), 24x436 | 16x290.67 | Reject: gutter too narrow for useful icon/hit target; outer left margin is similarly 24 px. |
| B: lower battlefield/hand corridor | (320,780), 1280x24 | 853.33x16 | Reject: too shallow and crossed by resting/inspected hand paint. |
| C: upper-right transparent gap | (1640,198), 240x48 | **160x32** | Spatially viable with affiliation/input reservations. |

C ends at y=246, about 19.36 px before status paint, and starts 8 px below the opponent pile envelope. It clears the hand/battlefield envelopes horizontally by at least 40 px. No tactical slot or approved visible element must move. It overlaps logical transparent MatchStatus padding, so future input ownership must be explicit.

Prefer a compact, explicitly **Hero/Player-labeled summary**, with icons or visible subset plus **+N** and future hover/keyboard inspection of the active list. Its aggregate hit area is usable at 720p; arbitrarily many individually labeled icons will not fit. The display budget is not a starting/max Artifact Capacity. Remote placement near opponent utilities requires clear affiliation (**R09A-005**). Actual artwork, interaction and progression remain Phase 2 / PLAN-002-OP12 decisions, separate from Creature Equipment and card inspection.

## 12. Future Spell/Equipment compatibility

**Geometry: PASS_WITH_RESERVATIONS. Final variant art: DEFERRED.** Preview cards share 1086x1448 (3:4), mana anchor (153,151), hover scale and bounds-based picking/clamping. The same actual pointer test visits all three categories. Fan transform math does not assume Creature attack/health; noncreature rendering omits numeric Creature stats.

The current preview still shares a master frame/illustration; it is not the future dedicated variants. PLAN-002 requires different interiors without Creature stat sockets and Weapon/Protection distinction. Their actual alpha bounds, category typography and rules readability need approved P009-R01A/R02A art and R01B/R02B integration checks. CardViewLayout supplies geometry; this is not final P009 CardView/data completion. Hero Artifacts do not become a fourth card type.

## 13. Evidence index and viewing

Review originals at **100%**; image zoom conceals the 720p readability issue. All mandatory files exist.

- Default: [1080p](combat_default_1080p.png), [720p](combat_default_720p.png).
- Full hand: [1080p](combat_full_hand_1080p.png), [720p](combat_full_hand_720p.png).
- Crowded audit fixture: [1080p](combat_crowded_board_1080p.png), [720p](combat_crowded_board_720p.png).
- Populated utility: [1080p](combat_populated_utility_1080p.png), [720p](combat_populated_utility_720p.png).
- [Worst-case values 720p](combat_worst_case_values_720p.png).
- Hover 1080p: [left](combat_hover_left_1080p.png), [center](combat_hover_center_1080p.png), [right](combat_hover_right_1080p.png).
- Closeups: [utility](utility_hud_closeup.png), [player](player_hud_closeup.png), [opponent](opponent_hud_closeup.png).
- [Artifact diagnostic](artifact_space_study.png).
- Timed samples: [Health first](orb_1080p_0_00.png), [Health last](orb_1080p_0_05.png), [Mana first](orb_1080p_1_00.png), [Mana last](orb_1080p_1_05.png); full sequences/timestamps accompany them.

## 14. Windows standalone

Rebuilt `build/windows/MagicOdyssey.exe` with embedded PCK/all_resources. Only the EXE was copied to a fresh temporary directory and launched through Windows shell independently of editor/repository files. Readiness follows rendering. This remains a presentation prototype, not a complete playable match.

| Mode | Actual client | Hover/button/focus/Space | Four reservoirs | ESC exit |
|---|---:|---|---|---:|
| Default | 1888x956 | PASS | motion verified | 0 |
| 1080p | 1920x1080 | PASS | motion verified | 0 |
| 720p | 1280x720 | PASS | motion verified | 0 |

Actual pointer movement tests left/center/right cards, scrubbing and return. End Turn records exactly one mouse and one Space activation plus native focus. Six opponent backs remain hidden. The existing explicit animation flag changes presentation values only. All three processes exit via ESC; none remains; desktop logs have no Godot errors/warnings.

[720p desktop](desktop-1280x720.png), [720p center hover](desktop-1280x720-hover-center.png), [1080p desktop](desktop-1920x1080.png), [pressed button](desktop-1280x720-button-pressed.png). Some frames include Windows Reduce/Close tooltips at upper right; these are retained desktop artifacts, with separate clean GPU evidence. Clean-PC/VM, other platforms and DPI/renderer combinations are NOT_VERIFIED.

## 15. Detailed issue register

**Zero BLOCKERs, one MAJOR, one MINOR, three OPTIONAL reservations.** Deferred risks do not create additional P005 blockers.

### R09A-001 - MAJOR - inspection typography

- Area/scenario: player hover, B/F, index 9 and Spell index 1 via real pointer input.
- Evidence: `combat_hover_right_720p.png`, `combat_hover_spell_720p.png`, `combat_hover_center_720p.png`, `observations.json`.
- Impact 1080p: long title 12.76 px; rules 13.98-14.59 px. Impact 720p: **8.51 px title, 9.32-9.72 px rules**, uncomfortable without zoom despite full retained text.
- Proposed correction: a separate **P005-R09B proposal** for a physical reading target and larger, vertically clamped inspection, preserving full names, ART-002 and side HUD clearance. Do not implement P010 here.
- New artwork: **not demonstrated necessary**; investigate scale/placement first. Roadmap: proposed R09B, then owner R09 sign-off. **This is the acceptance correction.**

### R09A-002 - MINOR - opponent fluid expressiveness

- Area/scenario: small opponent reservoirs, G, stable 3/5 fill.
- Evidence: `orb_720p_2_00.png` / `_05.png`, `orb_1080p_0_00.png` / `_05.png`, `analysis.json`.
- Impact 1080p: 44 px housing and approximately 0.12 px waves; 720p: 29.33 px housing and approximately 0.08 px waves, bubbles mostly subpixel. Motion is provable but quiet; numbers/colors remain usable.
- Proposed correction: retain unless the owner requests a separate opponent-only motion-profile study. New artwork: **none demonstrated**. Roadmap: optional P005-R09 refinement, not P007. Not a sign-off blocker alone.

### R09A-003 - OPTIONAL - actual grid offset

- Area/scenario: A/C, slot guides versus BattlefieldZone center.
- Evidence: both `combat_crowded_board` images and `analysis.json`.
- Impact 1080p: +51 px grid-center offset; 720p: +34 px. Opposite-side labels provide visual balance; no collision is demonstrated.
- Proposed correction: owner accepts label-plus-grid balance or separately requests a study before P006; do not move approved slots automatically. New artwork: **no**. Roadmap: owner P005 composition decision / P006 verification.

### R09A-004 - OPTIONAL / DEFERRED - lower-board density

- Area/scenario: C/B, all guides and ten resting cards.
- Evidence: both crowded-board images and source/runtime bounds in `analysis.json`.
- Impact 1080p: last guide ends y=774, fan reaches y=775.91; 720p: only 1.27 px minimum projected clearance. Inset rectangles fit; future ornate protrusions are unknown.
- Proposed correction: P008 validates actual crests, stats/statuses, Creature Weapon/Protection marks and VFX within safe envelopes. Placeholders cannot grant PASS.
- New artwork: **real approved P008 artwork is needed to conclude**, not generated by this audit. Roadmap: P008 density/art validation with P006 dependency. Deferred, not an automatic P005 failure.

### R09A-005 - OPTIONAL / DEFERRED - Artifact affiliation/input

- Area/scenario: reservation candidate C only; no Artifact item instantiated.
- Evidence: `artifact_space_study.png`, `analysis.json`.
- Impact 1080p: 240x48 clears paint but sits near opponent utilities and over logical transparent MatchStatus padding; 720p: 160x32 aggregate area, limited individual-icon room.
- Proposed correction: future explicitly Hero/Player-labeled summary, visible subset/+N as appropriate, separate overlay input owner and hover/keyboard affordance. Infer no capacity values.
- New artwork: future icon/style choices **DEFERRED**; none generated. Roadmap: PLAN-002-OP12 / Phase 2, not Creature Equipment. Not a current P005 implementation blocker.

## 16. Prioritized correction plan

1. **Required for recommended owner sign-off:** request only the targeted R09A-001 correction. An audit proposal is roughly 12-14 physical px for essential inspection text at 720p, including the longest supported name; this is not a new validated rule. A larger card must also move/clamp vertically to avoid bottom clipping. Re-run existing native/ART-002/input/GPU/standalone checks. Do not regenerate approved Creature artwork first.
2. **Optional owner decisions:** retain quiet opponent indicators or separately assess expressiveness; accept grid/label balance or request a narrow study. Neither warrants global rework.
3. **Existing deferred dependencies:** evaluate actual P008 tokens, integrate approved P009 Spell/Equipment variants and design Hero Artifact interaction in Phase 2. Do not silently add these future features to P005 completion requirements.
4. **After targeted evidence:** owner performs P005-R09 artistic sign-off. No correction or next prompt is started by this audit.

## 17. Acceptance matrix

These are audit assessments, not owner approval.

| Area | Status | Evidence / boundary |
|---|---|---|
| Battlefield composition | PASS_WITH_RESERVATIONS | Observatory visible; grid offset disclosed; real-token density deferred. |
| Hero HUD alignment | PASS | Shared axis, 1.48px painted-center difference, 34.76px visible gap. |
| Player hand | FAIL | Geometry/input pass; 720p inspection typography fails comfortable readability, R09A-001. |
| Opponent hidden hand | PASS | Six centered official backs; no front identity/picking leakage. |
| Utility HUD | PASS_WITH_RESERVATIONS | Populated/long fixtures fit; 10.67px body is tertiary, fine detail limited. |
| Deck/Graveyard | PASS | Shared back, empty/last-entering face-up states, readable three-digit counts. |
| End Turn | PASS | Separate silhouette; actual hover/down/focus/mouse/Space/disabled checks. |
| Turn/Phase typography | PASS | Long supported phase and TURN 10 fit both sizes. |
| Resource rendering | PASS_WITH_RESERVATIONS | All four move; small opponent fluid cues subdued. |
| 720p readability | FAIL | Scoped to hover title/rules; hero values, counts and status remain usable. |
| Crowded-board scalability | DEFERRED | Geometry fits, but actual P008 crest/status/VFX/attachment art untested. |
| Card-type extension readiness | PASS_WITH_RESERVATIONS | Shared silhouette/mana/hover math; final variants and CardView integration DEFERRED. |
| Hero Artifact reservation | PASS_WITH_RESERVATIONS | C spatially viable; affiliation/input/art/behavior DEFERRED; no capacity assumed. |
| Windows standalone | PASS | Isolated exact sizes/default, input, four animations, ESC 0. |

## 18. Recommendation and stop boundary

**TARGETED_CORRECTIONS_REQUIRED**, specifically R09A-001 before recommending owner sign-off. This is not MAJOR_REWORK_REQUIRED: retain production structure, source art and working interactions. Requested evidence and technical checks are complete; no production fix is included.

**P005 and P005-R09 remain artistically open. Gate G1 stays NOT_VALIDATED. Stop after this audit. Do not start R09B, P006, P009, Artifact implementation or any recommended work without a new request.**
