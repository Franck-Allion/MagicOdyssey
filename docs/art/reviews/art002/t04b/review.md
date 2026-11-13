# ART-002-T04B — Optical Stat Centering and Multi-Digit Validation

2026-11-12 · **PASS — socket registration, circular fit and technical validation**.
Recommendation: approve T04B for the current Lot 1 printed-stat presentation. Three-digit values at 720p remain an inspection-only stress case, not an approved quick-reading size. Artistic approval remains with the owner. Work stops at T04B.

## Finding: the Health 5 was centered on the wrong registration point

The original glyph-bounds algorithm was mathematically sound. Across the baseline matrix, its visible ink bounding-box centers were within **0.780 screen pixels per axis of the old scripted points**. Specifically, the inspected Health `5` was within approximately `(-0.221, -0.423)` screen pixels of `(934,1284)` projected into the card.

However, `(934,1284)` was not the painted Health aperture's center. The independent frame measurement places that center near `(919,1279)`. At 760 px inspection-card height, this error put the old Health 5 approximately **7.65 px right and 2.20 px down** from the measured aperture center. The visible imbalance was therefore real; the bounding-box test in T04 used the same incorrect registration point and could not detect it.

The same investigation found smaller registration errors for Mana and Attack. The correction applies to every numeral in a socket, rather than special-casing `5`.

## Measurement and exact corrections

`measure_geometry.py` reads the original v03 PNG without modifying it. For each socket it samples 360 radial directions, locates the first warm bronze pixel between radii 55 and 115, and fits a circle by least squares. It repeats this at red-channel brightness thresholds 65, 70 and 80, with fixed warm-color constraints. The median fitted center is rounded to source pixels. [socket_geometry.json](socket_geometry.json) preserves the fits and registration deltas.

| Socket | T04 point | Measured median | T04B point | Change in source pixels |
| --- | --- | --- | --- | --- |
| Mana | `(154,157)` | `(153.092,150.829)` | `(153,151)` | `(-1,-6)` |
| Attack | `(157,1284)` | `(162.221,1279.488)` | `(162,1279)` | `(+5,-5)` |
| Health | `(934,1284)` | `(919.326,1278.942)` | `(919,1279)` | `(-15,-5)` |

These are **source-art registration corrections**, not arbitrary optical nudges. The rings are painted, with bevels and directional illumination; the fitted centers are estimates, not claims of perfect analytic circles. Changing the three thresholds shifts fitted centers by up to about 2.3 source pixels vertically, substantially less than the Health horizontal error.

**Additional optical offsets: `(0,0)` for all sockets and all glyphs.** The side-by-side `1`, `5`, and `7` comparison supports the corrected registration without a numeral-specific adjustment. Their ink mass is naturally asymmetric: at inspection scale, the corrected Health 5's coverage centroid is about `(1.62,-3.07)` source pixels from center, while 7's is approximately `(-2.11,-13.02)`. These are diagnostic measurements, not optical alignment targets. Forcing their mass centroids to zero would make their bounding boxes drift and would introduce inconsistent baselines.

Sword `(157,1187)` and heart `(934,1187)` emblem positions are **unchanged**. Their existing placement on the decorated rim does not justify moving them in this bounded review. The comparison includes them, and all numeral masks clear their conservative occupied area.

## Circular fit and automatic resizing

The T04 width-only limit did not constrain diagonal corners to the circular aperture. In the baseline replay, **81/144 cases** exceeded the new conservative safe disk and **94/144** exceeded the centering tolerance relative to the measured artwork center. Exceeding this conservative disk is not itself a claim that every such case hit metal.

T04B retains the exact glyph-bounds union and baseline-centering calculation. It extends automatic fitting with an optional circular constraint: half the glyph bounding rectangle's diagonal, plus **3 source px outline and 1 source px rounding allowance**, must fit a **70 source px radius** disk. Font size is reduced until it fits. The nearest warm-metal pixels found with a lower detection threshold are 75.54, 72.03 and 72.00 source px away for Mana, Attack and Health. The common disk therefore sits inside each measured inner rim.

The optional radius is supplied only for primary circular stats. Armor/Shield badge layout and its existing width fitting remain unchanged. There is no gameplay cap or change to official stats.

## Numeric matrix and measured results

Values: `0, 1, 4, 5, 7, 8, 9, 10, 11, 12, 15, 20, 25, 99, 100, 999`.

Every value is rendered using the actual theme's **TacticalNumber** font in **each of the three sockets**, at:

- 760 px card height in a 1920 × 1080 inspection presentation: scale `760/1448`.
- 316 px card height in a 1920 × 1080 seven-card hand: scale `316/1448`.
- The same seven-card hand in 1280 × 720: scale `(316/1448) × (2/3)`.

That is **144 final cases**, plus 144 baseline replay cases. [numeral_measurements.csv](numeral_measurements.csv) records every result. The graphical test uses the same renderer and source-space socket positions, preserving each socket's fractional screen-pixel phase for the inspection or first hand-card origin. Full integrated fixture cards are used for the screenshots, including the other six horizontal card positions. The three review rows show successive seven-card batches, not a new 16-card hand layout.

The GPU mask checks cover visible ink centering, all pixels with alpha >0.1 including the dark outline, and clearance from the sword/heart occupied circles. They account for a pixel's half diagonal when checking radial containment. Centroid measurements are coverage-weighted diagnostics. They do not claim human legibility or replace the visual review.

| Socket | Cases | Center tolerance | Maximum outlined pixel radius, including pixel extent | Emblem collisions |
| --- | ---: | --- | ---: | ---: |
| Mana | 48/48 pass | ≤1.5 screen px per axis | 68.904 source px | 0 |
| Attack | 48/48 pass | ≤1.5 screen px per axis | 67.511 source px | 0 |
| Health | 48/48 pass | ≤1.5 screen px per axis | 68.231 source px | 0 |

Maximum final ink-center error across the matrix: **1.056 screen pixels per axis**. All final cases fit entirely within the 70 px safe disk under the stated raster threshold, clear the measured metal rim and avoid the emblems. No debug markers are present in final screenshots.

## Screenshots generated and examined

| Screenshot | Dimensions | Contents |
| --- | --- | --- |
| [single_digit_comparison_1080p.png](single_digit_comparison_1080p.png) | 1920 × 1080 | All seven one-digit values, independently in Mana / Attack / Health, at actual inspection-card scale. |
| [double_digit_comparison_1080p.png](double_digit_comparison_1080p.png) | 1920 × 1080 | All seven two-digit values plus 100 and 999, in all three sockets at inspection scale. |
| [multi_digit_hand_720p.png](multi_digit_hand_720p.png) | 1280 × 720 | Entire 16-value matrix on complete fixture cards at seven-card hand scale. |
| [socket_optical_alignment_1080p.png](socket_optical_alignment_1080p.png) | 1920 × 1080 | Enlarged T04/T04B pairs for 1, 5 and 7 in every socket; same artwork and emblems. |
| [multi_digit_hand_1080p.png](multi_digit_hand_1080p.png) | 1920 × 1080 | Additional full matrix at 1080p hand scale. |

Visual findings:

- **One digit:** unchanged character size, cleaner alignment to the painted rings. The largest improvement is Health. The three sockets are consistent without suppressing the natural asymmetry of 1, 5 or 7.
- **Two digits:** circular fitting retains separation from the bronze rim and emblems. Values are readable in inspection and both hand sizes. At 720p the measured bright-ink height is **10–12 pixels**, so inspection remains useful for low-vision users and prolonged reading.
- **Three digits:** 100 and 999 remain centered and clear the metal. They are readable at inspection scale and small at 1080p hand scale. At 720p both have only **8 pixels of bright-ink height**: they can be identified in a stationary close review, but reliable quick reading is **not approved**. No claim of adequate three-digit combat readability at 720p is made.

The current official Lot 1 creature catalog has printed mana values 1–6 and printed Attack/Max HP values 1–7. Those expected printed values retain their single-digit size. The larger matrix is a presentation stress test, not an expansion or cap on game values.

## Files and preservation

- Modified: `scripts/presentation/card_stat_overlay.gd` only among existing files.
- Added under `docs/art/reviews/art002/t04b/`: `capture.gd` (+ UID), `measure_geometry.py`, `socket_geometry.json`, `numeral_measurements.csv`, this report, `validation.txt`, five PNGs and their Godot import metadata.
- Master v03 PNG, rarity material factory, gem shader/mask, theme and integration fixture match HEAD blobs exactly. Sword/heart drawing and positions are unchanged. No gameplay, catalog or rarity specification changed. Existing T04 evidence is preserved.

## Validation and actual exit codes

Engine: `D:\Temp\Godot_v4.7.2-stable_win64.exe`, `4.7.2.stable.official.ed1daf0bf`.
Graphical renderer: OpenGL Compatibility / NVIDIA GeForce GTX 1660 Ti.

| Check | Actual exit | Result |
| --- | ---: | --- |
| `python docs/art/reviews/art002/t04b/measure_geometry.py` | 0 | 360 rays × 3 thresholds per socket; JSON measurements produced. Requires Pillow and NumPy. |
| Godot `--headless --editor --path . --import --quit` | 0 | Final source/image import passed; empty stderr. |
| Godot `--headless --path . --script res://scripts/tests/test_runner.gd` | 0 | Existing harness self-tests: 14 assertions passed, 0 failed. This is not comprehensive gameplay coverage. |
| Godot graphical T04B capture script below | 0 | 144 final fit/centering/emblem cases passed; five images saved at expected dimensions; empty final stderr. |
| `git diff --check` | 0 | No whitespace errors; normal LF-to-CRLF advisory for the edited script. |
| Additional untracked capture-script check, `git diff --no-index --check -- NUL docs/art/reviews/art002/t04b/capture.gd` | 1 | Expected new-file difference status from `--no-index`; no whitespace-error diagnostics. |

Reproduce the graphical pass:

```powershell
& 'D:\Temp\Godot_v4.7.2-stable_win64.exe' --path . --script res://docs/art/reviews/art002/t04b/capture.gd
```

The capture script replays the old point/width behavior in a review-only subclass for the before/after comparison. That replay uses the preserved glyph-centering calculation, not a separately authored font rendering. An initial run emitted a Control anchor warning; the capture fixture was corrected to use top-left anchors and the final rerun has empty stderr. No warning was suppressed.

Remaining limits: the measured circles approximate painted artwork; other system-font installations and platforms need their own visual pass. Very long values still shrink and need inspection; no new interaction or gameplay behavior is introduced to solve that future UX question. Automated masks use explicit raster thresholds rather than treating infinitesimal antialiasing fringes as solid ink. No player study, low-vision test, live combat session or manual keyboard-mode test was run.
