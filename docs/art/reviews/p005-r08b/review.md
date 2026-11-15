# P005-R08B - Premium Utility HUD Integration

2026-11-15. Godot 4.7.2 stable, Windows, OpenGL Compatibility, NVIDIA GeForce GTX 1660 Ti.

## 1. Executive summary

**TECH PASS / ART REVIEW. Recommendation: APPROVE, subject to owner artistic sign-off.** The production CombatScreen and independent Windows executable now use the approved utility and turn/phase artwork, paired shared deck/graveyard views for both camps, and a real premium End Turn Button. All changes are presentation-only. P005 remains incomplete; stop after R08B. No R09 or P007 implementation.

## 2. Required local asset preflight

All five required local files existed and were inspected before production edits. The four utility inputs arrived untracked and are now committed unchanged in **101cc8f**. The official card back and ART-002 master/illustration were already committed. [asset_preflight.json](asset_preflight.json) records initial dimensions, alpha bounds and SHA-256; [analysis.json](analysis.json) independently verifies final source bytes, interior alpha and desktop evidence.

Paths below are under `assets/_source/lot1/`. Bounds are exclusive right/bottom, alpha >8/255.

| Source | PNG size | Canvas aspect | Painted bounds |
|---|---:|---:|---|
| `hud/utility/mo_hud_utility_panel_v01.png` | 791x1989 | 0.3977 | (72,21)..(719,1963) |
| `hud/utility/mo_hud_graveyard_empty_v01.png` | 1086x1448 | 0.7500 | (107,84)..(978,1353) |
| `hud/utility/mo_hud_end_turn_normal_v01.png` | 2090x522 | 4.0038 | (22,13)..(2074,507) |
| `hud/utility/mo_hud_turn_phase_panel_v01.png` | 1774x887 | 2.0000 | (12,101)..(1761,770) |
| `hud/opponent/mo_hud_opponent_card_back_v01.png` | 1086x1448 | 0.7500 | (45,31)..(1041,1417) |

All are genuine RGBA PNGs with fully transparent pixels. Visual inspection of source composites and actual GPU output found no baked checkerboard, major transparency holes, unusable silhouette or severe colored fringe. Quantitative saturated-red and green-fringe checks report zero visible pixels for these sources. Low-alpha RGB viewed without correct compositing is not treated as a painted colored fringe. ART-002 master v03 and existing Arcane Knight test illustration were inspected and reused; no new artwork was generated.

## 3. Final artwork and imports

Both panels use the supplied PNGs through AtlasTexture crops. Both decks and the hidden hand use the exact same `CombatPreviewCards.CARD_BACK` texture resource. Empty graveyards use the supplied transparent skull/rune image. Nonempty graveyards use existing ART-002 illustration crop, master v03, rarity treatment, content, stat or category overlays. End Turn uses the supplied normal image.

The four utility imports use lossless compression, no source resizing, no premultiplied alpha, alpha-border fix and mipmaps. All miniature artwork uses uniform aspect-preserving scaling and linear mipmap filtering. Actual Godot import, GPU rendering and export succeeded. Source PNG hashes are unchanged.

## 4. Accepted alpha exceptions

Utility and status interiors retain the approved near-opacity; no opaque background overlay is added. Sampled utility/status ranges and all sample regions are recorded in analysis.json. The button sample is **251-254/255**, status **252-254/255**, and the existing card-back interior **251-254/255**. These tiny differences do not constitute holes. The deck reuses the already approved card-back opacity shader, which promotes near-opaque interiors while retaining exterior transparency. The intentionally translucent graveyard ornament and central aperture are preserved without opacity promotion.

## 5. Shared card-back source organization

The physical source stays at `hud/opponent/mo_hud_opponent_card_back_v01.png` for this integration. Relocation to `cards/backs/mo_card_back_v01.png` is deferred to a dedicated resource migration: the hidden-hand renderer, tests and capture workflow already depend on the current path/UID. Keeping this reference limits regression scope while guaranteeing resource identity. There is one source PNG, no divergent copy, no rejected generated stack illustration, and no changed opponent-hand code or UID.

## 6. Utility panel crop and placement

`ActionBarZone` retains **(1624,372), 272x684** and its public API. Its procedural panel style becomes empty; old divider and text-only counter nodes remain hidden for path compatibility. The only visible backplate is the approved art, with source crop **(64,12,664,1964)** in a local **(20,0), 232x684** envelope. Uniform scale is approximately 0.3483; painted width is approximately 225 px. All alpha >8 decorative bounds fit in the crop. Only negligible outlying transparency is excluded. No stretched artwork, doubled metal border, extra ornate compartments or background overlays.

## 7. Turn/phase hierarchy

`MatchStatus` retains **(1624,220), 272x136**. Source crop **(4,92,1766,690)** occupies local **(20,44), 232x91** with uniform scaling. Both panels share center x=1760; painted widths differ by approximately 4-5 reference px because the original silhouettes differ. The logical art envelopes have a 17 px gap, approximately 22 px between the alpha >8 silhouettes, retaining the source margins and crest.

Turn uses the existing font family at 28 reference px, phase at 17; text is centered separately from source padding. Existing `TURN 01 / PLAYER / ACTION` state is retained. Native and real GPU tests exercise TURN 1, TURN 10, PLAYER / ACTION, OPPONENT / ACTION and **END-OF-TURN ATTACK**, supported by scope section 3.4, without inventing a phase. Width and height fit at 1080p and 720p. No text is baked into artwork.

## 8. DeckStackView

One shared implementation is instantiated for both camps. `visual_count` clamps negative input to zero and rebuilds immediately; art layers and count labels remain separate. Layer counts are **0 / 1 / 2 / 3 / 5** for **0 / 1 / 2-5 / 6-15 / 16+** cards. Layers use identical approved backs, with restrained 1.5 px horizontal and -1 px vertical offsets. The component accepts no card identity and creates no front overlays. No draw-pile binding or gameplay exists.

[Deck 0](deck_count_0.png), [1](deck_count_1.png), [9](deck_count_9.png), [10](deck_count_10.png), [34](deck_count_34.png), [100](deck_count_100.png). Exact boundary tests also cover 2, 5, 6, 15 and 16.

## 9. GraveyardView

`set_preview(count, entering_card)` accepts an explicit presentation snapshot of the **last card entering** the graveyard, independently of the last played card. At zero it clears identity and restores the transparent placeholder; no extra decorative frame is added. Positive counts replace the placeholder with a 3:4 face-up ART-002 miniature. Missing nonempty card data is rejected and preserves the previous accepted view. Creature, Spell and Equipment presentations reuse existing overlays; noncreatures receive no invented attack/health stats.

Fixtures use the existing Arcane Knight illustration for both Arcane Knight and Astral Weaver samples, matching current preview limitations. Count 1 uses the rare Arcane Knight snapshot, 12/100 the epic Astral Weaver snapshot. These names, rarities and counts are **controlled visual fixtures, not real combat data**. The default screen remains deck 34 / graveyard 0 for both camps. No automatic engine mutation or real card movement.

[Empty](empty_graveyard.png), [nonempty](nonempty_graveyard.png), [one card at 720p](graveyard_720p_1.png), [several at 720p](graveyard_720p_12.png).

## 10. Recent actions and pile layout

Recent actions retain `Awaiting first action...` as the obvious empty state, a 16 px section title and quiet 17 px body, without a separate log frame. The presentation API takes at most three visible entries; no history subscription or scrolling. Player views occupy paired 104x200 envelopes at local (30,296)/(138,296), leaving 62 px before the button. Opponent views use paired 104x166 envelopes in **(1624,24)..(1896,190)**, with no added backplate. Captions are 15 px, counts 25 px (10 / 16.7 physical px at 720p). Counts 0,1,9,10,34,100 and graveyards 0,1,12,100 fit without clipping.

## 11. End Turn

The existing `EndTurnButton` path, PrimaryButton variation, native focus, mouse/keyboard input and `pressed` signal remain. It occupies local **(20,558), 232x58**, or reference (1644,930)..(1876,988), with 68 px below. Dynamic 21 px text is centered on the painted face; source silhouette center differs from the canvas center by less than one display pixel. Body-font colors override the former dark text intended for a gold procedural button.

NORMAL uses the supplied art; HOVER increases brightness to 1.12 over 0.10 s; PRESSED darkens to 0.86 and scales art to 0.98 around its center; DISABLED uses 0.52 brightness and 0.1 saturation. A small canvas shader changes saturation without modifying the PNG or adding glow. Keyboard focus retains a subtle outline. Native input drives the state; review APIs do not invoke gameplay.

[Four states](end_turn_states.png): top to bottom **normal, hover, pressed, disabled**. [720p states](end_turn_states_720p.png). GPU tests send actual viewport pointer motion, mouse down/up and Space key events; activation signals occur once, disabled input is rejected. The explicit standalone flag `--preview-utility` logs activation only; it never advances TURN 01.

## 12. 1080p GPU evidence

- [Full production screen](combat_screen_1080p.png).
- [Utility column](utility_hud_1080p.png).
- [Opponent piles](opponent_deck_graveyard_1080p.png).
- [Before/after](before_after_1080p.png), original on left, integration on right.
- [Worst supported labels and three-digit counts](worst_case_1080p.png).

## 13. 720p GPU evidence and visual assessment

- [Full production screen](combat_screen_720p.png).
- [Utility column](utility_hud_720p.png).
- [Opponent piles](opponent_deck_graveyard_720p.png).
- [Worst supported labels and counts](worst_case_720p.png).

All production screenshots come from real Godot GPU rendering of the production scene in exact-size SubViewports. Closeups are direct pixel-region captures. The comparison uses the genuine pre-edit baseline. No offline reconstruction or retouching is presented as production evidence.

Inspected actual full screens at both sizes, utility/opponent closeups, empty/nonempty miniature, worst labels, button states and standalone images. Bronze and midnight-blue materials are coherent; panels share a visual column, labels clear the borders, the button fits, and cards, portraits and reservoirs remain dominant. Empty skull detail is necessarily small and restrained at 720p. Nonempty face-up card identity, illustration and rarity remain visible; rules text is intentionally not readable at this miniature size. Opponent piles are distinguished by top placement, player piles by the lower utility panel. There are no added ornate pile frames.

GPU comparisons prove **bit-exact parity** before/after at both resolutions for the full left hero column, opponent hand, battlefield and player hand. All original geometry and hidden-information protections remain. Full parity results are in gpu.log.

## 14. Verification

Commands run from `D:/Dev/MagicOdyssey`; `$GodotExe = D:/Temp/Godot_v4.7.2-stable_win64_console.exe`.

| Check / command | Actual result | Exit |
|---|---|---:|
| Baseline GPU capture before production edits | 1080p and 720p saved | 0 |
| `& $GodotExe --headless --path . --editor --import --quit` | Clean imports | 0 |
| `& $GodotExe --headless --path . --script res://scripts/tests/test_runner.gd` | **2452/2452 PASS, 0 failed**, including CombatScreen, DeckStackView, GraveyardView, original player hover/hidden-hand and reservoir tests | 0 |
| `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/tests/run_visual_regression.ps1` | ART-002 **3/3 bit-exact**, no golden changes | 0 |
| `& $GodotExe --path . --script res://scripts/tests/capture_p005_r08b.gd` | Both exact sizes, text/count stress cases, parity and real Button input PASS; no script errors | 0 |
| `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/build_windows.ps1` | Embedded executable exported | 0 |
| `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/tests/playtest_windows.ps1 -ReviewDir docs/art/reviews/p005-r08b -HandCount 10 -AnimateResources -UtilityHud` | Three isolated desktop modes, button/hand/animation/ESC PASS | 0 |
| `python docs/art/reviews/p005-r08b/analyze.py` | Source byte equality, near-opaque interiors, native button changes, hand hover and all four desktop reservoir motions PASS | 0 |
| `git diff --check` and `git diff --cached --check` | Clean whitespace | 0 |

New native assertions cover actual layer thresholds, resource identity, count labels, empty/nonempty reversibility, last-entering identity and supplied illustration, invalid-snapshot preservation, noncreature stat absence, containment, font fitting, focusability and preserved envelopes. The 1818 existing assertions were not changed or weakened; **634 assertions were added**.

An initial capture used nonexistent `Label.get_line_width`; Godot reported script errors despite process exit 0, so that run was rejected. Font checks now use actual Font metrics and line height. New tests initially exposed off-tree font fallback, insufficient count/card bounds and turn-label height. Production envelopes/initialization and the off-tree measurement setup were corrected. The empty placeholder initially retained its native TextureRect minimum size; setting EXPAND_IGNORE_SIZE before assigning the texture/size fixed it, and containment is now asserted. An initial button shader multiplied texture color twice; corrected vertex tint preservation restores the normal source lighting. Final logs, captures and executable reflect all fixes.

## 15. Windows standalone playtest

Rebuilt **`D:/Dev/MagicOdyssey/build/windows/MagicOdyssey.exe`**, with all_resources and embedded PCK. Only the executable was copied to a fresh temporary directory and launched through Windows shell, independently of the editor/repository. The readiness marker was emitted after scene rendering.

| Mode | Actual client | Native End Turn | ESC exit |
|---|---:|---|---:|
| Default window | 1888x956 | hover/down/up/activation PASS | 0 |
| 1080p | 1920x1080 | hover/down/up/activation PASS | 0 |
| 720p | 1280x720 | hover/down/up/activation PASS | 0 |

Actual pointer tests exercise left/center/right player cards, rapid scrubbing, return to rest and the premium button. Eight timed desktop frames per mode show pixel changes within **each** player/opponent Health/Mana reservoir; analysis.json records adjacent-frame differences. The opponent hand remains six hidden backs. Each process exits with real ESC; no MagicOdyssey process remains. No Godot warnings or errors occur in the desktop logs.

[720p desktop](desktop-1280x720.png), [720p pressed button](desktop-1280x720-button-pressed.png), [1080p desktop](desktop-1920x1080.png), [1080p card hover](desktop-1920x1080-hover-center.png). Some 1080p desktop captures include Windows Reduce/Close tooltips in the upper right; these are desktop artifacts, not game UI, and clean GPU evidence is supplied separately. No tooltip pixels were retouched.

## 16. Changed files and known limitations

Production: combat_screen.tscn, combat_screen.gd, new deck_stack_view.gd, graveyard_view.gd, premium_end_turn_button.gd, utility_button_state.gdshader and UID files. The preview entry point adds only explicit input-proof logging. Validation: test_utility_hud.gd, suite registration, capture_p005_r08b.gd, optional UtilityHud desktop test switch, analysis script, source manifest, logs and screenshots. Documentation: this review and the R08A/R08B progress rows. Source art is committed without changes. Existing player/opponent HUD scripts, hand renderer, reservoir shader, battlefield geometry, domain and catalogue are untouched.

No real domain state, draw/discard, turn transition, graveyard interaction, card inspector, AI or event-history binding is implemented. All snapshots/counts remain preview data. Existing test illustration is reused for different visual fixture names; this is not new official card art. Card-back relocation is deferred as described above. Other renderers/platforms, clean-PC/VM, different DPI settings and performance benchmarks are **NOT_VERIFIED**. Final owner artistic approval is pending and cannot be inferred from tests.

## 17. Recommendation

**APPROVE for owner visual review; TECH PASS.** P005 remains artistically incomplete. Stop after **P005-R08B**; no automatic R09 work.
