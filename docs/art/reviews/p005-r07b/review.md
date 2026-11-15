# P005-R07B — Opponent hero HUD and premium card back

2026-11-15. Windows, Godot 4.7.2 stable, OpenGL Compatibility, NVIDIA GeForce GTX 1660 Ti.

**TECH PASS / ART REVIEW. Recommendation: APPROVE, subject to owner composition sign-off.** The production CombatScreen and exported Windows application now display the compact opponent HUD at top left and six premium face-down cards centered over the battlefield. P005 remains artistically incomplete. Stop after R07B; no R08 or gameplay integration.

## Assets and preflight

All four required local PNGs were inspected before production changes. Existing source bytes are preserved; SHA-256 hashes, exact bounds and transparency counts are recorded in [analysis.json](analysis.json). The supplied card back was committed unchanged in `c9984d2`; the opponent panel was already committed in `8af7bd5`. Reused player artwork was already tracked. These are available approved inputs for this integration, not a claim of final integrated composition approval.

| Path under `assets/_source/lot1/hud/` | Dimensions | Painted bounds, alpha >8 | Transparency / use |
|---|---:|---|---|
| `opponent/mo_hud_opponent_panel_v01.png` | 1202×1308 | (156,18)..(1045,1257) | Transparent exterior; dark interior alpha 252–254; retained unchanged |
| `opponent/mo_hud_opponent_card_back_v01.png` | 1086×1448 | (45,31)..(1041,1417) | Exact 3:4; true transparent exterior; almost opaque interior; presentation treatment below |
| `player/mo_hud_player_portrait_frame_v01.png` | 1254×1254 | (46,22)..(1208,1193) | Transparent exterior and central portrait aperture |
| `player/mo_hud_player_health_orb_housing_v01.png` | 1254×1254 | (13,0)..(1242,1253) | Transparent exterior and liquid aperture; same image for Health and Mana |

No checkerboard or gameplay text is visible on the card back. Its full card interior sample x=160..925, y=160..1287 has alpha **251–254**, rather than exactly 255. This small near-opacity issue has no large holes or painted checkerboard and does not require replacement artwork. A dedicated, non-destructive canvas shader promotes alpha >=0.98 to 1.0 while retaining genuine exterior transparency and soft edges. The approved PNG is not regenerated or edited. Actual GPU renders over solid red and green backgrounds prove bit-exact interior pixels and different exterior pixels: [red](card_back_over_red.png), [green](card_back_over_green.png).

Godot imports are lossless (`compress/mode=0`), RGBA, no premultiplied alpha, alpha-border fix enabled, no source resizing. **Only the two opponent imports** enable mipmaps; their TextureRects use linear filtering with mipmaps. This removes severe reduction aliasing in the panel and 144 px card backs. Approved player import settings are unchanged.

## Panel and portrait

The existing `OpponentHeroZone` Panel/API remains, now at **(24,24), 272×296**, ending at y=320. Its procedural style is replaced by `StyleBoxEmpty`; the supplied artwork is the only visible backplate. Old Name/DeckCount/GraveyardCount nodes remain hidden for path compatibility. No opponent counters are displayed or moved into the compact HUD.

An AtlasTexture crops source padding to **Rect2(150,12,900,1254)**. This contains the full visible metal silhouette with 5–9 native pixels of margin. Only negligible outlying alpha noise outside the painted silhouette is excluded. `KEEP_ASPECT_CENTERED` uniformly fits this crop into the envelope: approximately **212.44×296**, centered on local x=136. Painted bounds are approximately x=31.2..241.1, y=1.4..293.9. There is no stretch, added border, opaque generic overlay or clipped visible protrusion.

The approved 88×88 portrait frame is at local **(92,38)**. The existing test knight face uses the existing source crop `(260,40,500,500)` in an approximately **65×62** illustration window at `(104,50)`, underneath the frame and existing aperture shader. The measured source aperture center is `(626.5,615)` within the 1254 canvas; this is slightly above its rectangular center. Tests compare the illustration against that actual aperture. The portrait remains identifiable at 720p; fine facial detail is necessarily limited. It is a temporary test illustration, not a new official opponent identity.

The player's approved rectangle stays **(24,344), 272×700**. Logical vertical gap is 24 reference pixels / 16 physical pixels at 720p. With the new crop the painted opponent tip ends around screen y=318, versus the player's painted crest near y=351, leaving roughly 33 reference pixels. Neither panel collides, and both use the same left-column centerline. Player children and artwork are unchanged.

## Resource indicators, labels and synchronization

The existing LiquidResourceOrb scene/shader supplies both 44×44 indicators. Health is at local **(58,140)**; Mana at **(58,194)**. Both use the approved housing and the player's restrained housing modulation. The original reservoir geometry, independent ShaderMaterials, glass, fill transition, clock and API remain intact. No second liquid implementation or combat binding is added.

`internal_labels_visible` defaults to **true**, preserving player and legacy behavior. Only the two compact opponent instances set it false. This hides the existing Kind/Values children without removing their API/data. `resource_values_changed(current, maximum)` emits immediately after clamping in `set_resource_values()`, before any equal-ratio early return. CombatScreen connects once, initializes the external Labels on ready and updates them from these clamped values. No polling or animation callback drives game state.

| Text | Local rectangle | Font | Effective font at 720p |
|---|---|---:|---:|
| HP caption | (110,140)..(224,160) | Segoe UI 16, muted secondary | 10.67 px |
| Health values | (110,157)..(224,190) | Segoe UI Bold 23, 1 px dark outline | 15.33 px |
| MANA caption | (110,194)..(224,214) | Segoe UI 16, muted secondary | 10.67 px |
| Mana values | (110,211)..(224,244) | Segoe UI Bold 23, 1 px dark outline | 15.33 px |

Values have a 114 px label width, at least 8 px horizontal clearance from the housing rectangle, and room before the painted side border. Native font metric assertions include outline clearance and height for every requested string. Real GPU captures cover Health 30/30, 18/30, 0/30, 100/100 and Mana 0/0, 1/1, 5/5, 10/10. The worst strings stay readable at 720p without overlapping metal. Captions remain subordinate. Numeric text is rendered by real Godot Labels.

Default opponent values remain **Health 30/30, Mana 0/0**. Empty Mana is deliberately empty. The existing explicit `--preview-animate` review fixture now also cycles opponent resource values so standalone fill/label synchronization can be observed. Synthetic review values are only enabled by that flag; they are not a claim about turn rules or production gameplay state.

## Premium hidden hand

Only the `face_down` visual branch changes: one TextureRect with the approved card-back PNG replaces the old procedural Panel and M O emblem. No front artwork, card labels, costs, rarity or stat overlays are instantiated under these cards. All six use the same texture and native **1086×1448** coordinates, scaled uniformly to 144 reference pixels high. Six-card count, 72 px center spacing and curved rotations (-8.75°..8.75°) are retained. Explicit z indices preserve left-to-right stacking.

The OpponentHand parent expands leftward from x=704 to **x=320**, keeping right edge 1600 and y=30..190. This centers the fan at **x=960**, the battlefield centerline, instead of x=1152. Actual transformed card rectangles span approximately **x=715.68..1204.32, y=29.86..188.88**. They remain inside the viewport and clear the tactical area beginning at y=220 by over 31 px. Distinct outlines and repeated center ornaments make the six cards countable without dominating the battlefield.

The face-down branch ignores pointer events, picking returns -1, and programmatic inspection now also refuses face-down cards. Native tests verify a back-only tree, exact imported texture, 3:4 uniform scale, stable stacking, six-card count, viewport containment and battlefield clearance. The face-up player branch, fan geometry, hover logic and rarity rendering are preserved.

## Actual GPU review

- [Production CombatScreen 1080p](combat_screen_1080p.png) / [720p](combat_screen_720p.png).
- [Opponent HUD 1080p](opponent_hud_closeup_1080p.png) / [720p](opponent_hud_closeup_720p.png).
- [Opponent hand 1080p](opponent_hand_1080p.png) / [720p](opponent_hand_720p.png).
- [Worst-case HUD 1080p](worst_case_closeup_1080p.png) / [720p](worst_case_closeup_720p.png).
- [Before/after 1080p](before_after_1080p.png): original scene on the left, integrated scene on the right.
- Timed GPU captures: `animation_1080p_0/1.png`, `animation_720p_0/1.png`.

All production screenshots come from actual Godot rendering of the production scene in exact-size SubViewports. The before images were captured before production edits. No offline T04B image is used as evidence of this integration, and no screenshot retouching is used. Closeups are pixel crops at their original physical scale.

Inspected both full-screen resolutions, closeups, worst cases and standalone hover captures. The whole opponent silhouette is visible, portrait contained, labels aligned and readable, resource metal unobstructed, and both panels remain separate. Mipmapped card backs are smooth, distinct and fully hidden. The gold/blue material family relates to the player HUD with less top-left visual weight. The removed horizontal opponent panel frees the upper battlefield header, while the recentered fan establishes a balanced top center.

The player HUD, player hand/hover region and right utility column are **bit-exact** before/after at both sizes. The battlefield region is bit-exact at 1080p. At 720p, **six existing label-edge pixels** near x=227, y=185..191 differ by only **1/255** in a channel; all other battlefield pixels match. Added font/atlas sampling is a plausible explanation, not proven. Battlefield scene geometry and slots are unchanged. These tiny deltas are explicitly recorded in analysis.json, rather than described as full-screen parity.

## Verification and commands

Commands run from `D:/Dev/MagicOdyssey`; `$GodotExe` is `D:/Temp/Godot_v4.7.2-stable_win64_console.exe`.

| Command | Actual result | Exit |
|---|---|---:|
| `& $GodotExe --path . --script res://scripts/tests/capture_p005_r07b.gd -- --before` | Actual pre-integration 1080p/720p GPU captures | 0 |
| `& $GodotExe --headless --path . --editor --import --quit` | Clean import; opponent textures include mipmaps | 0 |
| `& $GodotExe --headless --path . --script res://scripts/tests/test_runner.gd` | **1818/1818 PASS, 0 failed**; includes CombatScreen, LiquidResourceOrb, opponent hidden-hand and player hover tests | 0 |
| `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/tests/run_visual_regression.ps1` | ART-002 **3/3 bit-exact**, no golden updates | 0 |
| `& $GodotExe --path . --script res://scripts/tests/capture_p005_r07b.gd` | Both sizes; containment, worst cases, both miniature animations, opaque interior and transparent exterior PASS | 0 |
| `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/build_windows.ps1` | Embedded Windows executable built | 0 |
| `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/tests/playtest_windows.ps1 -ReviewDir docs/art/reviews/p005-r07b -HandCount 10 -AnimateResources` | Isolated shell launch, real pointer hover, animated resources, three window modes, ESC 0 | 0 |
| `python docs/art/reviews/p005-r07b/analyze.py` | Source hashes, quantified preserved-region parity and all four desktop resource motions PASS | 0 |
| `git diff --check` / `git diff --cached --check` | Clean | 0 |

Baseline was 1598 assertions. The former fixed opponent position/procedural-housing assertions are explicitly superseded by R07B; equivalent stronger tests now cover the approved new placement and compact mounting. Player and legacy procedural API coverage remains. New assertions test actual font metrics, clamping, unchanged fill ratios with changed maxima, reversible internal-label visibility, real aperture alignment and hidden-information protection.

Two diagnostic attempts are retained: `analysis-initial.log` exited 1 because the first comparison required total battlefield bit parity and discovered the six 1/255 label pixels; final analysis reports the exact deltas and bounds them without relaxing strict player/utility parity. `tests-alignment-initial.log` exited 1 because a new portrait assertion compared against the padded frame center instead of the measured aperture center. The assertion was corrected to use the actual painted aperture; production placement was already correct. Final suite passes 1818 assertions. No passing player/hover regression was removed to resolve either finding.

## Windows standalone

Built **`D:/Dev/MagicOdyssey/build/windows/MagicOdyssey.exe`**, with `all_resources`, embedded PCK, docs/build excluded. The playtest copies only that EXE to an isolated temporary directory and launches it through Windows shell execution, without repository resources or the editor.

| Mode | Actual client pixels | ESC exit | Result |
|---|---:|---:|---|
| Default window | 1888×956 | 0 | PASS |
| 1080p | 1920×1080 | 0 | PASS |
| 720p | 1280×720 | 0 | PASS |

The readiness marker is emitted only after scene render. Real Windows pointer movement tests left, center, right, rapid scrubbing and return to rest with ten player cards. Eight timed desktop frames per mode prove changes inside each opponent and player reservoir region; some full/empty stationary intervals correctly have zero differences. See `desktop_animation` in analysis.json. GPU tests separately prove small-orb waves at a stable intermediate fill, so desktop changes are not the only animation evidence.

- [720p standalone](desktop-1280x720.png), [720p center hover](desktop-1280x720-hover-center.png).
- [1080p standalone](desktop-1920x1080.png), [1080p left hover](desktop-1920x1080-hover-left.png).

All three processes exit cleanly via real ESC; no MagicOdyssey process remains. A Windows “Fermer” close-button tooltip appears at the upper-right of one 1080p desktop hover capture; it is outside the game UI and absent in clean GPU screenshots. Logs contain no Godot errors/warnings. Tests ran sequentially with GPU capture finished before desktop automation to preserve focus.

## Changed files and remaining limits

Production: `combat_screen.tscn`, `combat_screen.gd`, `liquid_resource_orb.gd`, `combat_preview_cards.gd`, explicit review fixture in `combat_preview.gd`, and `card_back_opacity.gdshader` plus its UID. Two opponent import configurations enable mipmaps. Validation: focused additions in existing CombatScreen/LiquidResourceOrb tests, isolated GPU capture script/UID, read-only analysis script, captures and logs. Documentation: this review and the two R07 tracker rows. Approved PNG hashes are unchanged. No player/battlefield geometry, domain rules, interactions or R08 controls are changed.

Owner artistic sign-off remains pending. Tests do not approve art. Other renderers, non-Windows systems, clean-PC/VM deployment, DPI configurations beyond this desktop and performance benchmarks are **NOT_VERIFIED**. The small portrait and simplified resource cues intentionally trade filigree detail for legible values. The 0/0 default Mana state and explicit animation fixture remain presentation-only until P007.

**Final recommendation: APPROVE. P005 remains TECH PASS / ART IN PROGRESS. Stop after P005-R07B.**
