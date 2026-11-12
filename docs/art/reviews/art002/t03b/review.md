# ART-002-T03B — Improved Rarity Gemstone Color Separation

2026-11-12 · **PASS** · Recommendation: **APPROVED**.

This review verifies the visual and technical improvements made to the five rarity gemstone treatments for card frame master v03 under ART-002-T03B, resolving the color darkness and chromatic ambiguity identified in ART-002-T03 (specifically Uncommon sapphire blue versus Epic amethyst violet at small scales, and Legendary gold reading as dark amber).

The underlying three-gemstone shader architecture, source-space SVG mask, and master artwork remain intact and bit-exact outside the crystal interiors.

---

## 1. Summary of Deficiencies in T03 and Root Causes

In ART-002-T03:
1. **Epic vs Uncommon Ambiguity:** Epic's theme token had lower saturation (`s = 0.339`) because pastel text tokens prioritize text legibility on dark backgrounds. Scaling saturation by `minf(color.s * 1.65, 0.85)` produced only `0.56` saturation for Epic versus `0.77` for Uncommon. Under low gem body luminance, Epic collapsed into a muted slate-indigo that was nearly indistinguishable from Uncommon blue at 720p hand scale.
2. **Specular Washout:** T03 blended highlights directly toward neutral white (`vec3(0.98, 0.99, 1.0)`) across a wide range (`smoothstep(0.42, 0.88, facet)`). In small stones, the brightest 40% of facet pixels lost all chromatic saturation, desaturating the downsampled pixel cluster.
3. **Dark Amber Legendary:** Gold requires higher luminance to avoid dropping into the olive/amber/brown perceptual quadrant. Under T03's low body multiplier and 0.045 inner light, Legendary read as dark murky amber.
4. **Subdued Brilliance:** Inner light was capped at 0.02 (Common, Uncommon, Rare) and 0.045 (Epic, Legendary), leaving the facet bodies overly dark.

---

## 2. Exact Shader and Material Changes

### 2.1. Shader: `resources/shaders/card_rarity_gems.gdshader`

1. **Two-Stage Specular Model (Colored Specular Reflection + Peak Glint):**
   - Added uniform `uniform vec4 specular_color : source_color = vec4(1.0);`.
   - **Colored Specular Reflection:** Added `smoothstep(0.35, 0.75, facet)` mixing `crystal` with `specular_color.rgb` by `0.45`. This simulates internal reflection and facet brilliance that gleams with the gemstone's own saturated hue before reaching the peak glint.
   - **White Peak Glint:** Tightened the white specular threshold from `smoothstep(0.42, 0.88, facet)` to `smoothstep(0.66, 0.92, facet)`. This preserves crisp white sparkles at the sharpest painted tips without washing out the facet shoulders.
2. **Body Contrast Shaping:**
   - Adjusted body curve: `float body = pow(clamp(facet * 1.75, 0.0, 1.0), 0.75);` and `crystal = pigment * (body * 0.90);`.
   - Deep facet cuts (`facet < 0.08`) remain deep dark shadows, preserving realistic facet geometry and 3D cut depth.
3. **Expanded Inner Light:**
   - Inner light uniform range expanded from `hint_range(0.0, 0.1)` to `hint_range(0.0, 0.3)`.
   - Inner light formula `crystal += pigment * inner_light * smoothstep(0.06, 0.28, facet);` ensures light is contained inside the stone and does not spill onto bronze bezels or dark contact borders.

### 2.2. Material Factory: `scripts/presentation/rarity_gem_treatment.gd`

Replaced the blanket formula with a typed, per-rarity match block deriving high jewel saturation, tailored colored specular reflections, and graduated inner light from the canonical theme token hues (`TOKENS.color_token(rarity).h`):

| Rarity | Canonical Token | Pigment (HSV) | Specular Tint (HSV) | Inner Light | Visual Character |
|---|---|---|---|---:|---|
| **Common** | `Color(0.949, 0.941, 0.922)` | `Color(1.0, 1.0, 1.0)` (s=0.0) | `Color(1.0, 1.0, 1.0)` | 0.04 | Neutral white crystal / diamond; zero blue or warm cast. |
| **Uncommon** | `Color(0.525, 0.741, 0.980)` | `Color.from_hsv(color.h, 0.88, 1.0)` | `Color.from_hsv(color.h, 0.45, 1.0)` | 0.10 | Sapphire blue: pure azure hue (211.5°), electric blue facet brilliance. |
| **Rare** | `Color(0.949, 0.545, 0.533)` | `Color.from_hsv(color.h, 0.90, 1.0)` | `Color.from_hsv(color.h, 0.45, 1.0)` | 0.10 | Ruby red: vivid crimson hue (1.7°), ruby reflection. |
| **Epic** | `Color(0.773, 0.635, 0.961)` | `Color.from_hsv(color.h, 0.92, 1.0)` | `Color.from_hsv(color.h, 0.50, 1.0)` | 0.13 | Amethyst violet: saturated violet hue (265.4°), luminous lilac reflection. |
| **Legendary** | `Color(0.910, 0.776, 0.459)` | `Color.from_hsv(color.h, 0.82, 1.0)` | `Color.from_hsv(color.h, 0.35, 1.0)` | 0.16 | Luminous gold: warm golden hue (42.4°), radiant champagne highlight. |

### 2.3. Test Fixture: `scripts/presentation/art002_card_integration_test.gd`

Updated fixture header subtitle to `"ART–002–T03B · MASTER FRAME v03 · Three faceted rarity gemstones"`.

---

## 3. Before and After Visual Comparison

### 3.1. Color Metrics (Measured on GPU-rendered Footer Gem)

| Rarity | T03 Average RGB | T03 Avg Saturation | T03B Average RGB | T03B Avg Saturation | Observed Separation |
|---|---|---:|---|---:|---|
| **Common** | (0.42, 0.42, 0.42) | 0.00 | (0.48, 0.48, 0.48) | 0.00 | Neutral crystal, brighter facets, no color cast. |
| **Uncommon** | (0.09, 0.24, 0.42) | 0.71 | (0.11, 0.30, 0.51) | 0.79 | Rich sapphire blue; Green (0.30) >> Red (0.11). |
| **Rare** | (0.43, 0.10, 0.09) | 0.73 | (0.51, 0.11, 0.10) | 0.80 | Distinct ruby crimson; high contrast cuts. |
| **Epic** | (0.24, 0.16, 0.38) | 0.48 | (0.27, 0.09, 0.52) | 0.83 | Vivid amethyst violet; Red (0.27) >> Green (0.09). |
| **Legendary** | (0.42, 0.32, 0.11) | 0.68 | (0.54, 0.42, 0.14) | 0.73 | Luminous warm gold; no dark amber/brown cast. |

### 3.2. Visual Assessment

- **Uncommon vs Epic at 720p:** In `hand_7_cards_720p.png`, Card 2 (Uncommon), Card 4 (Epic), and Card 7 (Uncommon) are immediately distinguishable. Uncommon reflects cold cyan-blue/sapphire, while Epic reflects warm magenta-violet/amethyst. The chromatic separation is unmistakable even on the 10-pixel footer gem and tiny bridge/crown stones.
- **Legendary Reading:** Rather than a muddy brown/amber spot, Legendary reflects warm, radiant gold with champagne highlights.
- **Facet Integrity:** Realistic dark facet cuts, internal occlusion lines, and sharp white highlight glints remain crisp. The treatment does not produce flat color fills.
- **Frame Artwork Preservation:** The bronze bezels, midnight-blue inlays, text sockets, and transparent card boundaries remain 100% bit-exact with the untreated master frame.

---

## 4. Screenshots

The captures below were rendered directly by Godot 4.7.2 stable using OpenGL Compatibility on an NVIDIA GeForce GTX 1660 Ti via `SubViewport` and `RenderingServer.frame_post_draw`.

| File | Resolution | Description |
|---|---|---|
| [rarity_samples_1080p.png](rarity_samples_1080p.png) | 1920 × 1080 | All five rarities side by side: Common (white), Uncommon (blue), Rare (red), Epic (violet), Legendary (gold). |
| [hand_7_cards_720p.png](hand_7_cards_720p.png) | 1280 × 720 | Seven-card hand at 720p scale cycling through rarities; demonstrates clear Uncommon vs Epic distinction at hand scale. |
| [single_card_1080p.png](single_card_1080p.png) | 1920 × 1080 | Full-size inspection view of Epic Arcane Knight; shows facet depth, colored speculars, and neutral bronze settings. |
| [hand_7_cards_1080p.png](hand_7_cards_1080p.png) | 1920 × 1080 | Seven-card hand at 1080p scale. |

---

## 5. Verification Transcript and Exit Codes

Working directory: `D:\Dev\MagicOdyssey`
Engine: `D:\Temp\Godot_v4.7.2-stable_win64.exe` (v4.7.2.stable.official.ed1daf0bf)

| Command / Invocation | Exit Code | Result | Notes |
|---|---:|---|---|
| `Godot --headless --editor --path D:\Dev\MagicOdyssey --import --quit` | 0 | PASS | Assets and shaders imported cleanly. |
| `powershell -File scripts\tests\run_tests.ps1` | 0 | PASS | 14 of 14 assertions passed. |
| `Godot --path D:\Dev\MagicOdyssey --script res://docs/art/reviews/art002/t03b/verify_gems.gd` | 0 | PASS | GPU regression check: 0 alpha changes, 0 outside-mask changes, all 3 gem regions > 200 pixels changed for all 5 rarities. |
| `Godot --headless --path D:\Dev\MagicOdyssey res://scenes/ui/art002_card_integration_test.tscn --quit-after 5` | 0 | PASS | Fixture scene executes without script errors. |
| `capture.gd -- t03b/rarity_samples_1080p.png 1920 1080 --mode=2` | 0 | PASS | 1920 × 1080 PNG saved successfully. |
| `capture.gd -- t03b/hand_7_cards_720p.png 1280 720 --mode=1` | 0 | PASS | 1280 × 720 PNG saved successfully. |
| `capture.gd -- t03b/single_card_1080p.png 1920 1080 --mode=0` | 0 | PASS | 1920 × 1080 PNG saved successfully. |
| `capture.gd -- t03b/hand_7_cards_1080p.png 1920 1080 --mode=1` | 0 | PASS | 1920 × 1080 PNG saved successfully. |
| `git diff --check` | 0 | PASS | Clean diff, no trailing whitespace or format errors. |

---

## 6. Remaining Limitations

- At 720p hand scale, the crown and bridge stones occupy approximately 4 to 6 screen pixels. While their color hue is preserved and distinguishable, fine facet lines can only be resolved on the larger footer stone or under inspection zoom.
- Gemstone color remains a visual presentation treatment and should be accompanied in production by semantic inspection tooltips for full accessibility compliance.
- No gameplay logic, catalog definitions, CardView, stat icons, or normative specifications were modified.

---

## 7. Recommendation

**APPROVED**.

ART-002-T03B successfully delivers vivid color separation, clear distinction between Uncommon (sapphire blue) and Epic (amethyst violet) even at 720p hand scale, warm radiant gold for Legendary, ruby red for Rare, and neutral crystal white for Common, while strictly preserving master frame artwork, bronze bezels, and 3D facet geometry.
