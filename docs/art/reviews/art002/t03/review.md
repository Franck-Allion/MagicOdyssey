# ART-002-T03 — Premium rarity gemstones

2026-11-12 · **PASS** · Recommendation: **APPROVED** as the basis for the final card presentation pipeline. This is an implementation and visual-review recommendation, not a substitute for the owner's final art approval.

The card face no longer contains the temporary rarity name or horizontal ribbon. All three existing stones now express Common (white), Uncommon (blue), Rare (red), Epic (violet), or Legendary (gold). The comparison captions remain outside the cards as review legends. The hand cycles through all five rarities, then repeats Common and Uncommon.

The shader uses the approved frame's painted facet values and narrow white speculars to reconstruct rich crystal colors. It adds a small, static internal-light contribution, slightly stronger for Epic and Legendary. There is no pulse, bloom, halo, or animation. Theme rarity hues are retained; saturation is increased for the small gemstone material, with Common rendered achromatically.

An editable, source-space SVG mask defines three crystal interiors at the crown, portrait/body bridge, and footer. It protects bronze settings, midnight-blue cloth, stat sockets, and transparency. The entire frame is rendered once with a ShaderMaterial; there is no duplicate alpha-blended frame overlay. Materials are shared per rarity within the fixture. A future CardView can call `RarityGemTreatment.create_material(rarity)` and assign the result to its full-frame TextureRect. The material expects full 0–1 frame UVs; atlas cropping needs UV adaptation. The mask belongs specifically to v03's geometry.

The master and illustration files were not modified. Master SHA-256 remains `937d2a3e3c099ec9830213c725025af250639032591ecc234f8e491068ced3e3`.

## Files

| File | Change |
|---|---|
| `scripts/presentation/art002_card_integration_test.gd` | Remove face label/ribbon; apply materials; update captions and mixed-rarity hand. |
| `scripts/presentation/rarity_gem_treatment.gd` | Reusable, typed material factory using existing design tokens. |
| `resources/shaders/card_rarity_gems.gdshader` | Masked faceted crystal treatment; preserve native alpha and CanvasItem modulation. |
| `assets/textures/cards/frame_v03_gem_mask.svg` | Three editable crystal contours in 1086 × 1448 source coordinates. |
| `docs/art/reviews/art002/t03/verify_gems.gd` | Graphical regression check against an untreated frame. |
| This directory | Review, validation transcript, and four actual Godot captures. |

Godot-generated UIDs/import metadata accompany the runtime resources and review artifacts. No gameplay, catalog, stat-icon, armor, shield, or production CardView work is included.

## Screenshots and visual assessment

All four images were opened and inspected. They are graphical Godot SubViewport captures after `RenderingServer.frame_post_draw`, not generated mockups or resized screenshots. Renderer: Godot 4.7.2 stable, OpenGL Compatibility, NVIDIA GeForce GTX 1660 Ti.

| Capture | Assessment |
|---|---|
| [Single card, 1080p](single_card_1080p.png) | Epic sample; faceted amethyst interiors, white reflected highlights and dark cuts; bronze bezels stay neutral. |
| [Seven-card hand, 1080p](hand_7_cards_1080p.png) | Five stone colors visible with identical framing and no rarity labels on the faces. |
| [Seven-card hand, 720p](hand_7_cards_720p.png) | Colors remain visible; the footer is the strongest cue. Fine facets and tiny crown/bridge stones naturally lose detail at this size. |
| [Five rarities, 1080p](rarity_samples_1080p.png) | White, blue, red, violet and gold distinguishable side by side, without recoloring metalwork. |

The full-size gemstone areas were additionally inspected enlarged during review: the painted facet structure and dark contact edges remain visible. The treatment is restrained and consistent with the existing fantasy frame; the cleaned card face gives the illustration and rules more space.

## Validation and reproduction

Executable: `D:\Temp\Godot_v4.7.2-stable_win64.exe`. Commands below list the actual engine arguments. Processes were launched with PowerShell `Start-Process -WindowStyle Hidden -Wait -PassThru`, with stdout/stderr redirected to logs and native process exit codes checked. Working directory: `D:\Dev\MagicOdyssey`.

| Arguments / command | Native exit | Result |
|---|---:|---|
| `--headless --editor --path D:\Dev\MagicOdyssey --import` | 0 | Assets and scripts imported. |
| `--headless --path D:\Dev\MagicOdyssey --script res://scripts/tests/test_runner.gd` | 0 | 14 assertions passed; 0 failed. Existing suite is harness verification, not all 45 Lot 1 acceptance scenarios. |
| `--headless --path D:\Dev\MagicOdyssey res://scenes/ui/art002_card_integration_test.tscn --quit-after 5` | 0 | Fixture launches without script errors. |
| `--path D:\Dev\MagicOdyssey --script res://docs/art/reviews/art002/t03/verify_gems.gd` | 0 | All five actual GPU-rendered frames pass alpha and mask-isolation checks. |
| Four capture runs below | 0 each | Exact requested viewport dimensions; PNG save result 0. |
| `git diff --check` | 0 | No whitespace errors. |

Capture argument prefix:

```text
--path D:\Dev\MagicOdyssey --script res://docs/art/reviews/art002/capture.gd --
```

Capture arguments following the prefix:

```text
D:/Dev/MagicOdyssey/docs/art/reviews/art002/t03/single_card_1080p.png 1920 1080 --mode=0
D:/Dev/MagicOdyssey/docs/art/reviews/art002/t03/hand_7_cards_1080p.png 1920 1080 --mode=1
D:/Dev/MagicOdyssey/docs/art/reviews/art002/t03/hand_7_cards_720p.png 1280 720 --mode=1
D:/Dev/MagicOdyssey/docs/art/reviews/art002/t03/rarity_samples_1080p.png 1920 1080 --mode=2
```

The graphical check compares each treated frame against an untreated GPU render at native source resolution. **Zero changed alpha pixels** for every rarity; **zero RGB changes greater than 1/255 outside the antialiased mask**. Each of the three stones changes in every rarity (approximately 1,225, 1,370 and 2,220 pixels respectively). This verifies shader isolation and transparency; alignment of the hand-authored mask with the art was assessed visually. See [validation.log](validation.log) for actual output.

During the first graphical iteration, multiplying fragment COLOR by the sampled texture darkened the frame. This was corrected by passing modulation from the vertex stage; the final captures and GPU regression check use that corrected shader.

## Limitations

- At 720p hand scale, the stones occupy only a few pixels in width. Color identity survives, but detailed material inspection requires the larger view. No enlargement or silhouette redesign was introduced.
- Gem hue alone is not a complete color-vision accessibility solution. The production inspector/tooltip should expose rarity semantically; this isolated task does not claim full L1-U13 compliance.
- Keyboard mode switching was not manually exercised; every mode was rendered via its command-line argument. Future production CardView integration is outside this fixture.
- Final AAA art acceptance remains a visual judgment for the owner. No remaining technical or observed visual defect blocks using this treatment as the production basis.
