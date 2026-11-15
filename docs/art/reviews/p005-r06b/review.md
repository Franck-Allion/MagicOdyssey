# P005-R06B - Premium player hero HUD integration

Date: 2026-11-15. Godot 4.7.2 stable, OpenGL Compatibility, NVIDIA GeForce GTX 1660 Ti, Windows.

**TECH PASS / ART REVIEW. Recommendation: KEEP_WITH_ADJUSTMENTS pending owner composition review.** The three source assets are owner-approved, including the asset-specific panel alpha exception. The integrated composition has not received owner artistic approval. P005 remains incomplete. Stop after R06B.

## 1. Executive summary

The approved panel now supplies the only shared player HUD backing. The existing knight portrait sits under its approved frame. Health and Mana reuse exactly the same approved housing texture over their independent animated liquid/glass materials. The old player HeroFrame style is replaced with StyleBoxEmpty, and the optional external-housing shader setting removes the procedural metal rim only on the player instances.

All 1532 native assertions pass, including CombatScreen integration, hand picking/hover and LiquidResourceOrb regressions. Three ART-002 golden comparisons are bit-exact. Real GPU captures and an isolated Windows executable were verified at 1080p/720p; all three desktop launch modes exit with ESC code 0.

## 2. Exact approved assets

All three PNGs live under `res://assets/_source/lot1/hud/player/`. They were supplied in the workspace and are included with this integration. No PNG was repainted, regenerated, substituted or altered. SHA-256 values match the read-only measurements taken before integration; full hashes are in [verification.json](verification.json).

| PNG | Source dimensions | Actual mode / alpha | SHA-256 prefix |
| --- | --- | --- | --- |
| `mo_hud_player_portrait_frame_v01.png` | 1254 x 1254 | RGBA, 0-255 | `ba4e8a35cd786cfb` |
| `mo_hud_player_health_orb_housing_v01.png` | 1254 x 1254 | RGBA, 0 or 255 | `ce58a60fd27e9098` |
| `mo_hud_player_panel_v01.png` | 1024 x 1536 | RGBA, 0-254 | `11e45aa68ea60d24` |

One housing source is intentionally shared by Health and Mana. No separate Mana artwork is required.

## 3. Alpha preflight and owner exception

The earlier preflight stopped because the panel had no alpha=255 pixels. The owner explicitly accepted interior alpha **252-254/255 for this exact panel asset**, and instructed integration to resume without changing the artwork. This exception is documented and tested only for this file; it does not weaken requirements for other assets.

The center `(512,768)` is RGBA `(26,33,42,253)`. The interior rectangle `[320,180,700,1350)` has alpha 252-254 throughout. There are 855742 exactly transparent source pixels. Far exterior columns contain alpha 0 with a few alpha=1 residual pixels; the source contains RGB colors under transparent pixels. Thresholded silhouette inspection finds no enclosed holes at half alpha. This threshold is used to inspect the silhouette, not to redefine the accepted interior range.

The portrait aperture is genuinely transparent; its central connected opening bounds are `[162,177,1091,1053)` in source pixels. The housing aperture bounds are `[203,209,1036,1046)`. Opaque ornament is present on both frames. All three files imported with Godot successfully. Visual inspection of the actual combined GPU captures at both resolutions found no baked checkerboard, visible colored fringe, unexpected holes or observable background leakage through the dark panel. Slightly translucent interior values do not create a visible defect in these captures. Default Godot alpha-border fixing is enabled on the imported textures; source pixels remain untouched.

## 4. Scene composition and layering

Existing PlayerHeroZone, Portrait, PlayerHealthOrb, PlayerManaOrb and all public accessors keep their paths and types. The player zone remains reference-space x=24-296, y=220-920. Added nodes are Backplate, PortraitFrame and the optional Housing child inside LiquidResourceOrb.

Layering is backplate -> portrait/animated reservoir -> approved portrait frame/orb housing -> resource captions and numeric values. Artwork controls ignore mouse input. The placeholder YOUR HERO label retains its node but is hidden because it collided with the panel's upper crest. No new decorative separators or procedural ornaments were added.

The panel is an AtlasTexture region `Rect2(212,0,600,1536)` that crops only wide exterior margins. Its visible metal silhouette is retained. KEEP_ASPECT_CENTERED fits this region uniformly into 272 x 700, yielding about 272 x 696.3 displayed pixels. No nine-patch, tiling or nonuniform border scaling is used. The dark backing remains secondary to the portrait and resource values.

## 5. Portrait implementation

The original 500 x 500 face-and-shoulders atlas crop `Rect2(260,40,500,500)` is retained. Portrait occupies local `(62,74)` to `(210,218)` with uniform aspect-covered sampling. A small canvas shader clips only the illustration's rounded corners under the measured opening; it does not draw a replacement frame. The approved square frame occupies `(36,46)` to `(236,246)` and preserves its aspect ratio.

The face and shoulders remain recognizable at both sizes. The portrait illustration no longer extends as an exposed square outside its frame. The integrated crop is slightly smaller than R05, leaving space for the approved frame within the column.

## 6. Orb housing integration

Both player orbs retain 190 x 190 external bounds at local x=41, y=256/474, with the same vertical axis and a 28 px gap between their external rectangles. Both use the exact same Texture2D and identical geometry. Opponent instances keep null housing textures and their previous renderer.

The measured opening requires the shader rectangle to be 0.9 times the external diameter, positioned at normalized `(0.044,0.0504)` within the housing bounds. The existing 0.375-radius glass therefore has a 128.25 px displayed diameter, slightly overlapping the inner metal lip to avoid seams. The opening's small source asymmetry is accounted for by a common reservoir origin, not by per-number offsets.

Captions and values remain Godot Labels above the artwork. The existing font-fitting algorithm handles all requested samples: HP 30/30, 18/30, 0/30, 100/100 and Mana 1/1, 5/5, 0/5, 10/10. Tests check outline clearance and at least 16 physical pixels for numeric fonts at 720p. [1080p large values](values_1080p_3.png), [720p large values](values_720p_3.png).

## 7. Redundant decorations removed

The player's former HeroFrame panel style is neutralized. The liquid shader has one optional `external_housing` boolean, default false. With artwork present it outputs only the original animated glass/reservoir disk; turned bronze bevels, enamel mounting and studs are not rendered. Null artwork restores the original procedural appearance and geometry. All existing resource methods, transitions, palette selection and per-instance ShaderMaterials remain functional. The shader is shared, mutable materials are independent.

No generic portrait border or additional metal ring was added. The shared panel border and the approved foreground frames are the only decorative structures. The existing glass reflection arcs are intentionally retained and are distinct from a bronze mounting.

## 8. Before/after comparison

R05 was rendered from the unchanged scene before integration using the same capture script, static clocks and exact resolutions. These are genuine GPU images, not reconstructed mockups.

| Resolution | Before | After | Matched HUD comparison |
| --- | --- | --- | --- |
| 1080p | [R05](before_r05_1080p.png) | [R06B](combat_screen_1080p.png) | [Side by side](before_after_1080p.png) |
| 720p | [R05](before_r05_720p.png) | [R06B](combat_screen_720p.png) | [Side by side](before_after_720p.png) |

For every pixel from reference x=320 to the right edge, before/after differences are **zero at both resolutions**. This covers battlefield, opponent HUD/hand, utility column, turn controls and player hand. The replaced region includes the old player panel shadow, which extended beyond x=296 to approximately x=312.

## 9. 1080p composition review

[Full CombatScreen](combat_screen_1080p.png), [native HUD closeup](player_hud_closeup_1080p.png).

The three vertical sections are aligned and separated. The quieter dark panel ties them together without another enclosing Godot border. The face, numeric values and liquids remain visible; no clipping or artwork distortion is apparent. The hand remains the larger, brighter foreground presentation. The approved orb housing is brighter gold than the portrait frame/backplate; owner review should decide whether that material contrast is acceptable. The source art was preserved rather than recolored.

## 10. 720p composition review

[Full CombatScreen](combat_screen_720p.png), [native HUD closeup](player_hud_closeup_720p.png), [resource states](states_720p.png).

The same uniform composition scales to 720p. Captions and one-/multi-digit values remain readable. No rim obscures a value. Fine metal details naturally soften at this size, but the silhouettes remain clear. No panel background/checkerboard contamination or liquid edge leak was seen. Opponent numerals retain their existing smaller appearance; they were outside this task's scope.

## 11. Animation verification

[Full / intermediate / empty 1080p](states_1080p.png), [720p](states_720p.png), [damage/refill 1080p](damage_refill_1080p.gif), [720p](damage_refill_720p.gif). GIFs and montage sheets are assembled solely from real GPU captures; original transition PNGs are retained.

The capture script starts Health at 30/30 and Mana at 0/5, then requests damage to 15/30 and refill to 5/5. Actual process timing and visible ratios are recorded in [gpu.log](gpu.log). The first 1080p sample records intermediate ratios HP 0.67700 and Mana 0.64601; both subsequently reach their independent targets. Numeric labels update immediately, as before.

Across eight transition frames, **7408 opaque housing sample pixels at 1080p and 2492 at 720p remain unchanged**, with zero sampled metal changes. After settling, captures separated by 0.45 seconds still show liquid motion (499 changed HUD pixels at 1080p, 256 at 720p). No flicker, desynchronization or background leakage was observed. The stability check samples opaque metal neighborhoods outside text, not antialiased silhouette pixels. It does not claim an exhaustive temporal rendering proof.

## 12. Native and visual regression results

Commands were run from `D:/Dev/MagicOdyssey`. `$GodotExe` below denotes `D:/Temp/Godot_v4.7.2-stable_win64_console.exe`.

| Actual command | Result | Exit |
| --- | --- | --- |
| `& $GodotExe --headless --path . --editor --import --quit` | All three PNGs import; no errors/warnings in [import.log](import.log) | 0 |
| `& $GodotExe --headless --path . --script res://scripts/tests/test_runner.gd` | **1532/1532**, 0 failures; includes CombatScreen, picking/hover, LiquidResourceOrb and 59 added mounting assertions. [tests.log](tests.log) | 0 |
| `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/tests/run_visual_regression.ps1` | **3/3 ART-002 scenes bit-exact**, 0 differing pixels. [art002.log](art002.log) | 0 |
| `& $GodotExe --path . --script res://scripts/tests/capture_p005_r06b.gd -- --before` | Two R05 GPU references captured before edits | 0 |
| `& $GodotExe --path . --script res://scripts/tests/capture_p005_r06b.gd` | Both resolutions, values/states, transitions, continued waves, unchanged other regions. [gpu.log](gpu.log) | 0 |
| `python scripts/tests/verify_p005_r06b.py` | Alpha, source hashes, fixed metal, moving fluid and comparison/state sheets. [verification.json](verification.json) | 0 |
| `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/build_windows.ps1` | Release executable regenerated. [export.log](export.log) | 0 |
| `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/tests/playtest_windows.ps1 -ReviewDir docs/art/reviews/p005-r06b -HandCount 10 -AnimateResources` | Three actual desktop launches, pointer hover, animation captures, ESC 0. [standalone.log](standalone.log) | 0 |
| `git diff --check` and staged equivalent | No whitespace errors | 0 |

The added native checks cover exact approved texture paths/loading, shared matching housing geometry, ordering, mouse pass-through, aspect preservation, player panel style removal, placeholder-name visibility, text widths/readability, null-mount restoration and opponent defaults. Missing required files fail normal Godot resource import/preload; no replacement or placeholder fallback is introduced. Destructive missing-file injection was not performed.

## 13. Windows executable playtest

Executable: `D:/Dev/MagicOdyssey/build/windows/MagicOdyssey.exe`. Double-click it to open the actual CombatScreen preview; hover cards to inspect them; press ESC to quit. Resource changes can be demonstrated with `MagicOdyssey.exe -- --preview-animate`.

The embedded release executable was copied alone to a new temporary directory and launched via the Windows shell without project resources or the editor. Actual clients were 1888 x 956 by default, 1920 x 1080, and 1280 x 720 on a 1920 x 1080 physical desktop. All three rendered, handled real OS pointer movement across the ten-card hand, animated resources and exited on ESC with code 0. No remaining game processes or Godot errors/warnings were reported.

Desktop evidence: [1080p rest](desktop-1920x1080.png), [hover left](desktop-1920x1080-hover-left.png), [center](desktop-1920x1080-hover-center.png), [right](desktop-1920x1080-hover-right.png); [720p rest](desktop-1280x720.png), [hover left](desktop-1280x720-hover-left.png), [center](desktop-1280x720-hover-center.png), [right](desktop-1280x720-hover-right.png). Eight timed motion PNGs per mode are retained. [Standalone pixel measurements](standalone-verification.json) supplement the visually inspected hover evidence; raw pixel changes alone are not used to infer correct picking.

## 14. Changed files and limitations

Runtime changes are confined to `scenes/combat/combat_screen.tscn`, `scenes/hud/liquid_resource_orb.tscn`, `scripts/presentation/liquid_resource_orb.gd`, `resources/shaders/liquid_resource_orb.gdshader` and the new `resources/shaders/hero_portrait_aperture.gdshader`. Source PNGs/import descriptors, the extended orb tests, capture/verification scripts and this review evidence are included. `docs/progress/lot1-progress.md` records the actual result.

CombatScreen script/accessors, domain/CombatEngine, gameplay data binding, opponent artwork, hand geometry/hover code, tactical geometry, ART-002 assets/components, theme resources and roadmap specifications are unchanged. No P006-P010 or R07 work is included. Resource values remain presentation fixtures, not P007 bindings. The exported executable is rebuilt under the existing ignored build path.

Known visual review points: the gold housing is brighter than the other approved metal, the visible liquid disk is smaller than R05 to fit the approved aperture, and portrait visibility is reduced slightly by its new frame. These are documented composition tradeoffs, not source asset modifications. Final owner artistic sign-off is outstanding. There are no outstanding required technical checks; destructive missing-file injection and testing on other GPUs/operating systems were not performed.

## 15. Recommendation

**KEEP_WITH_ADJUSTMENTS pending owner review** of the integrated 1080p/720p captures, chiefly metal brightness and portrait/orb proportions. Technical integration is complete, but approval of the standalone source artwork and the alpha exception does not constitute approval of this new composition. Do not mark P005 globally complete or advance to P005-R07A.
