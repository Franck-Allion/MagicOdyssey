# P008-B - Premium rectangular CreatureToken integration

Date: 2026-11-17. Godot 4.7.2 stable ed1daf0bf; Windows; OpenGL Compatibility; NVIDIA GeForce GTX 1660 Ti, driver 551.86.

## 1. Executive summary

Presentation implementation complete; native and GPU checks PASS. **ART CORRECTIONS REQUIRED / OWNER ACCEPTANCE PENDING.** The supplied rectangular candidate is used under this task's explicit authorization, superseding the older shield-shaped description for this integration only. No normative rule/specification was rewritten.

Reusable typed tokens display resolved Attack, current Health, Armor, Shield, three ordered statuses plus overflow, and independent Weapon/Protection markers. Existing P006 anchors host all 24 copies. No CombatEngine, targeting, costs, effects, movement, turn advancement or inventory was implemented. Default CombatScreen stays empty.

Final native suite: **3620/3620 PASS**, including all 3098 prior assertions and 522 P008 assertions. GPU suite: **263/263 PASS**. These are technical checks, not artistic approval. Four statistics are **not reliably readable at native 720p**, especially Armor/Shield. The painted blue zero-state plaque and layered metal motif remain art review items.

Files added: `creature_token.gd`, `creature_token_layout.gd`, `creature_token_view_model.gd`, `creature_status_view_model.gd`, `creature_token_demo.gd` (under `scripts/presentation/`, with UIDs); `scenes/combat/creature_token.tscn`; six `.tres` fixtures under `resources/fixtures/p008/`; the runtime PNG and import configuration; native `test_creature_token.gd`; and this GPU/review evidence directory. The supplied source PNG remains intact.

Existing files changed: `combat_screen.gd` (visual APIs), `combat_preview.gd` (explicit fixture flag), `test_runner.gd` (suite registration), `playtest_windows.ps1` (scenario parameter/confirmation) and `docs/progress/lot1-progress.md` (P008 status). No commit was created.

## 2. Frame source verification

Source: `assets/_source/lot1/tokens/mo_creature_token_frame_v01.png`. It existed before implementation and was initially untracked. Runtime: `assets/textures/tokens/mo_creature_token_frame_v01.png`, byte-identical copy. No repainting, source resizing, alpha correction, substitute artwork or new illustration.

1536x1024 RGBA; 961458 fully transparent pixels. Alpha range **0-254**, with no alpha-255 pixels: the near-opaque metal/plaque values are part of the supplied source and were preserved. This is an observation, not a new project-wide alpha exception. Center aperture and both cabochon centers have alpha 0; Armor sample alpha 253, Shield sample alpha 252. Black RGB values in alpha-zero areas are not painted backgrounds.

SHA-256: `bb131857a192724c3bbf336272b55b7aba2dbc6106d712663f0c1d15c64e038c`.

Machine-readable evidence: [source-verification.json](source-verification.json). Runtime lossless import generates mipmaps, and the component uses linear mipmap filtering to reduce metal-edge aliasing at board size. Import settings do not change PNG source bytes.

## 3. Actual asset layout

One measured source-space calibration: `scripts/presentation/creature_token_layout.gd`.

| Element | Source coordinates / dimensions |
|---|---|
| Canvas | 1536x1024 |
| Attack center | (220, 802) |
| Current Health center | (1317, 802) |
| Inlay rectangles | 296x296, centered on cavities |
| Armor inset | (408, 809), 300x104 |
| Shield inset | (826, 803), 300x115 |
| Portrait fill target | (108, 84), 1320x690, clipped by measured inner polygon |
| Status strip | (410, 610), three 138x124 cells, step 146, fourth cell +N |
| Weapon / Protection | (114, 300) / (1284, 300), diagnostic cells |

A 4-reference-pixel minimum slot margin yields a **154x102.667** token in each 162x112 guide. At 720p this is approximately **102.667x68.444 physical pixels**. The entire source silhouette remains within the original guide, with no stretching or replacement of the grid.

## 4. ART-002 compatibility assessment

Unmodified authoritative `mo_inlay_attack.png`, `mo_inlay_health.png`, `mo_plate_armor.png` and `mo_plate_shield.png` are referenced directly through `CardStatOverlay` constants. Attack retains its official dark steel material; Health retains the official red material. No sword/heart badge replacements or approximated stat colors.

`CreatureToken` extends `CardSocketOverlay` and reuses its font, measured glyph bounds, outline, shadow and bright-ink token. It does not call the card's printed-stat drawing method or mutate card data. Token numerals use zero custom optical offset: card-specific per-value offsets are not transplanted into a differently shaped housing.

[ART-002 vs token GPU comparison](art002_token_stat_comparison.png) shows the actual official card overlay beside the actual token. It is an enlarged, labeled diagnostic composition rendered directly by Godot; it is not native-size readability evidence.

## 5. Stat inlay compositing architecture

Order: clipped portrait; official Attack/Health material disks; unchanged token frame; shared primary glyph rendering; positive Armor/Shield official inserts; all secondary numerals; status/equipment fixtures.

The inlays sit **behind** the existing transparent circular apertures. The new frame supplies the bronze rings, cardinal decorations and outer silhouette. The original card bezel textures were inspected through the authoritative implementation but are deliberately **not overlaid**: their different geometry would duplicate bronze contours. No recoloring or source texture manipulation. Native-size captures show no obvious gap or colored spill; final seam/material judgment remains with the owner.

## 6. Armor/Shield plaque integration and zero state

The base artwork already paints silver Armor and blue Shield surfaces. The official card inserts are overlaid only for positive values and fitted inside their respective source housings. Their distinctive materials and left/right order are retained. Numerals use 140 source-point type, rather than increasing type until it overlaps the metal edges.

At zero, no extra material insert is drawn; an explicit **0** is drawn over the existing decorative surface. This avoids a positive numeral and makes absence numerically explicit. However, the source's blue surface still looks active. Its decorative plate motif can also remain visible around the official insert and suggest duplicated metal detailing. This cannot be certified as artistically faithful merely because its bounds fit.

Required correction: supply an owner-approved frame variant with neutral recessed Armor/Shield cavities (or separate inactive plaque layers), matched to the official inserts; provide taller, simpler usable plaque interiors if all four values must remain comfortably readable at 720p. Preserve outer silhouette and primary stat geometry. No opaque cover rectangle or unrelated texture was used. **The source PNG has not been edited.**

## 7. View-model and public API

`CreatureTokenViewModel` is a typed Resource containing `instance_id: StringName`, portrait, resolved effective Attack, current/maximum Health, Armor, Shield, ordered `Array[CreatureStatusViewModel]`, and independent attachment booleans. Status resources carry identity, optional icon and a diagnostic fallback character. Textures are shared; mutable model/status containers are copied on injection and retrieval.

Validation rejects missing identity/portrait, negative display statistics, current Health above maximum, and invalid/null status entries. Zero is supported. No formula derives effective stats, status priorities or duration. Invalid injection preserves the previous accepted display.

`CreatureToken.apply_view_model(model) -> bool` and `get_view_model()` support independent reuse. `scenes/combat/creature_token.tscn` is the reusable scene.

CombatScreen visual operations use `Vector3i(camp, column, row)` identifiers, matching P006:

- `add_creature_token(identity, model) -> bool`
- `update_creature_token(identity, model) -> bool`
- `remove_creature_token(identity) -> bool`
- `get_creature_token(identity) -> CreatureToken` (null when absent/invalid)
- `clear_creature_tokens() -> void`

Adding rejects occupied anchors, invalid models/coordinates and duplicate instance identities elsewhere. Updates preserve the displayed instance identity and node. Removal detaches immediately, allowing same-frame slot reuse; destruction is deferred. Failed operations return false/null without partial board changes. These are visual operations, not legal gameplay actions.

## 8. Portrait rendering and cropping

The existing Arcane Knight illustration is the only creature illustration fixture found in the inspected production presentation. It is reused for all six data fixtures; no claim of 24 distinct creature portraits. A deterministic **top-center aspect-fill** crop preserves the head in this full-body source. A measured inner polygon clips the portrait behind the frame, excludes both stat cavities and avoids the lower stat band. Wide, tall and square sources are exercised. Bright and dark solid-image GPU diagnostics are explicitly synthetic test textures, not substitute production artwork.

No portrait image is resized on disk, distorted or painted over metal. Shared border filtering is independent of the portrait's stored pixels.

## 9. Status display

The caller supplies presentation order. Three entries are shown; five entries display diagnostic markers `1`, `2`, `3`, **+2**. Approved injected textures render in the same cells. No approved standalone status icons were available in the inspected assets; neutral theme-colored diagnostic cells are explicitly temporary. No permanent effect symbols or mechanics were invented. Tiny marker text at 720p remains a readability limitation.

## 10. Equipment indicators

Independent optional `W` and `P` cells represent Creature Weapon and Protection. All four combinations are covered natively; fixtures show both, weapon-only and neither. These are temporary diagnostic letters, not Hero Artifacts or production icon artwork. Indicators sit at opposite portrait edges, above the primary statistics; no equip/unequip logic.

## 11. 24-slot integration

The original 24 `BattlefieldSlot` nodes, immutable identities, slot registry, positions and style resources remain unchanged. Tokens mount only in `get_token_anchor()`. Each token draws its layers in one Control with `MOUSE_FILTER_IGNORE`, so its portrait, stats and markers cannot consume input. Selection, passive highlights and hover remain visible in the reserved outer margin. GPU pointer tests check each populated position through the real picker, not by emitting signals.

Graph discovery/trace/snippet and coverage were used at Tier 2. Generations included `2026-11-17T20:29:57Z` and watcher refresh `2026-11-17T20:38:52Z`. Coverage reported changed filesystem metadata, so current source was read directly. A clean coverage signal was not treated as proof of complete indexing. No subagents were used.

## 12. 1080p review

All 24 frames are fully visible, separated and clear of the HUD, lower hand and neighboring guides. The portrait fixture remains identifiable after top-center cropping. Attack/Health are readable for demonstrated 0-14 values; secondary values are markedly smaller. Selected-slot feedback is visible around the complete token. Status/equipment fixtures do not cover the primary numerals. There is no claim that a compact token can provide the full future inspection UI.

## 13. 720p readability assessment

**READABILITY LIMITATION: all four statistics are not comfortably readable at native 1280x720.** Attack and Health remain recognizable for the demonstrated one/two-digit values, with reduced comfort for two digits. Armor/Shield materials are distinguishable, but their small numbers require close attention and are unsuitable for unconditional artistic acceptance. The source plaque usable heights scale to roughly 7 and 8 pixels; numeral ink is smaller. Status/+N and equipment letters are also marginal. Bounds tests establish geometry, not legibility.

This assessment uses actual 1280x720 GPU images and Windows client captures, not only enlarged development images. Keep final owner sign-off pending the plaque/readability corrections above.

## 14. GPU captures

All PNGs are actual Godot renders, with no synthesis or screenshot retouching. Required pairs:

| Scenario | 1080p | 720p |
|---|---|---|
| Single | [token_single_1080p.png](token_single_1080p.png) | [token_single_720p.png](token_single_720p.png) |
| Multi-digit stats | [token_stats_1080p.png](token_stats_1080p.png) | [token_stats_720p.png](token_stats_720p.png) |
| Armor / Shield | [token_armor_shield_1080p.png](token_armor_shield_1080p.png) | [token_armor_shield_720p.png](token_armor_shield_720p.png) |
| Zero | [token_zero_stats_1080p.png](token_zero_stats_1080p.png) | [token_zero_stats_720p.png](token_zero_stats_720p.png) |
| Status overflow | [token_status_overflow_1080p.png](token_status_overflow_1080p.png) | [token_status_overflow_720p.png](token_status_overflow_720p.png) |
| Equipment | [token_equipment_1080p.png](token_equipment_1080p.png) | [token_equipment_720p.png](token_equipment_720p.png) |
| Full board | [token_full_board_1080p.png](token_full_board_1080p.png) | [token_full_board_720p.png](token_full_board_720p.png) |
| Selected | [token_selected_1080p.png](token_selected_1080p.png) | [token_selected_720p.png](token_selected_720p.png) |

Also: empty board pairs, bright/dark diagnostics and `art002_token_stat_comparison.png`. [observations.json](observations.json) records renderer and **263 passing GPU checks**. `capture.gd` injects pointer events into a real SubViewport; OS pointer checks are separate.

## 15. Native test results

Executed with `D:\Temp\Godot_v4.7.2-stable_win64_console.exe`:

```powershell
& $GodotExe --headless --path . --script res://scripts/tests/test_runner.gd
```

Exit **0**, **3620 total / 3620 passed / 0 failed**. Existing assertions unchanged. P008 adds 522 assertions for creation, typed snapshots, isolation, null/invalid handling, 0/1/asymmetric/two/three-digit values, independent stats, current vs maximum HP, portrait replacement/aspects, overflow, equipment combinations, 24 tokens, occupancy, identity, lifecycle, preserved selection, all P007 snapshot fields and printed overlay values. The existing P007 off-tree anchor-size warning remains; no new script errors or leaked-object warnings appear in the final native run.

During development, checks caught an unsupported constant PackedVector constructor and an exact floating-point ratio comparison. Both were corrected; no prior assertion was weakened.

## 16. Windows standalone results

All **nine real desktop runs PASS**: empty, single and full-board scenarios, each at default 1888x956, exact 1920x1080 and exact 1280x720 client sizes. Each scenario harness exited **0**; each executable exited **0** through OS ESC, with no remaining game process. Final full-board native-720p selection capture was opened and inspected.

For every run: all 24 slot identities hovered/clicked through OS pointer events; switching/toggle and populated-slot selection; actual hand hover and raised-inspection click isolation; mouse and Space End Turn activation; no slot-event leakage; no Godot warning/error in the standalone logs. In the single scenario only the first slot is populated; in the empty scenario all slots stay empty.

The harness uses Windows `SetCursorPos`, `mouse_event` and `keybd_event`; it checks the explicit scenario-ready log marker. These are not synthetic emitted slot signals. Structured actual results, executable SHA-256 and accepted click counts: [verification-results.json](verification-results.json). Local raw summaries: `standalone-full-summary.log`, `standalone-single-summary.log`, `standalone-empty-summary.log`; desktop screenshots and engine logs are under their corresponding `standalone-*` directories. Raw `.log` files follow the repository's existing git-ignore policy; structured results are tracked as review evidence.

Executable: `D:\Dev\MagicOdyssey\build\windows\MagicOdyssey.exe`. Built with the existing Windows Desktop preset, embedded PCK, standard build script; export exit **0**. Each run copies only the executable into a fresh temporary directory to verify independence from the editor/source checkout.

Reproduce a crowded preview:

```powershell
& .\build\windows\MagicOdyssey.exe -- --preview-tokens=full_board --preview-hand=7 --preview-slots --preview-utility --preview-size=1280x720
```

Use `single` or `empty` instead of `full_board` for the other fixtures. ESC quits. No gameplay shortcuts or global token input interceptors were introduced.

## 17. P005/P006/P007 regression results

ART-002 GPU regression: exit **0**, **3/3 scenes bit-exact, zero differing pixels**. Empty P008 versus P006 `board_idle` images: **0 differing pixels at both 1080p and 720p**. The native baseline retains all 3098 assertions. All P007 top-level and hero snapshot fields remain equal after add/update/remove/clear operations. P005 composition, hand fan, printed card overlay implementation/artwork, 540-reference-pixel inspection geometry and P006 geometry were not edited.

[preservation.json](preservation.json) records working SHA-256 and equality to HEAD for the six authoritative card stat textures (raw bytes), card overlays/layout, hand, P007 model classes, P006 slot component and combat scene (source with CRLF normalized to LF); no domain implementation was added. This is not a playable combat engine.

## 18. Known limitations

- Only one existing creature illustration; all 24 copies reuse it. Distinct production portrait content belongs to later asset work.
- Diagnostic status and W/P markers need approved artwork; status priority and expiry belong to the future presenter/domain adapter.
- Four-stat 720p readability fails the comfort criterion; primary values and secondary materials remain technically functional.
- Painted active-looking zero plaque and remaining metal motif overlap require owner art correction.
- No clean Windows VM, alternate GPU/renderer, live CombatEngine adapter, gameplay, animations, movement or token inspector was tested/implemented.
- Source alpha never reaches 255; preserved as supplied, with no normalization.

## 19. Outstanding art corrections

Owner-approved neutral/inactive plaque interiors or separated layers; clean official insert alignment without duplicated motif; taller or simplified stat interiors compatible with fixed 162x112 guide bounds; approved status/equipment icons. Review current zeros and native 720p captures before acceptance. No source repaint is authorized or performed in this task.

## 20. Final recommendation

Accept the presentation API and integration for technical review. **Do not mark artistic approval complete**: resolve plaque zero-state/compositing and native 720p readability first. P005 remains owner-approved; P006/P007 truthful statuses are preserved. P009 and P010 remain TODO, G1 remains NOT_VALIDATED. Work stops at P008-B.
