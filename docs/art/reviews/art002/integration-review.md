# ART-002-T01 — Premium card frame integration

Date: 2026-11-11. Engine verified: Godot 4.7.2.stable.official.ed1daf0bf.

**Recommendation: REQUEST_FRAME_REVISION.**

**Artwork status: BLOCKED_FOR_FINAL_APPROVAL.** The supplied frame is RGB with a painted checkerboard, not transparent artwork. These screenshots are explicitly labeled temporary previews. This technical experiment does not approve ART-002, implement P009, or change gameplay/catalog/specifications. Final artistic approval remains with the human reviewer.

## Sources and transparency evidence

The requested `res://assets/_source/lot1/cards/frames/wip/mo_card_frame_master_wip_v02.png` does not exist. The user explicitly authorized the existing `res://assets/_source/lot1/cards/frames/mo_card_frame_master_v02.png` instead.

| Source | Dimensions | Stored mode | SHA-256 before and after |
|---|---|---|---|
| `assets/_source/lot1/cards/frames/mo_card_frame_master_v02.png` | 1086 × 1448 | RGB | `ce802a9e85b6f60aa500720ba6ed07087ed4c429224c54479d51b31e13d074d9` |
| `assets/_source/lot1/cards/illustrations/mo_illustration_arcane_knight_test_v01.png` | 1086 × 1448 | RGB | `71f87eb6bc0fb8d10da7286d47aacb1cae07236088afc04f2e6209d6738d50dc` |

Pillow inspected actual pixels and PNG metadata. Frame bands are `('R', 'G', 'B')`; there is no `transparency` metadata. **No native alpha channel exists.** The values below are effective alpha after explicit RGBA conversion (which assigns 255 everywhere), not a claim that the PNG stores alpha. Coordinates are source pixels from the top left.

| Region | Coordinate | Stored RGB | Effective alpha / 255 |
|---|---|---|---|
| Outer top-left | 0, 0 | 253, 253, 253 | 255 |
| Outer top-right | 1085, 0 | 248, 250, 249 | 255 |
| Outer bottom-left | 0, 1447 | 254, 254, 254 | 255 |
| Outer bottom-right | 1085, 1447 | 248, 248, 248 | 255 |
| Aperture gray square | 543, 400 | 234, 234, 235 | 255 |
| Aperture white square | 550, 400 | 253, 253, 253 | 255 |
| Aperture lower sample | 543, 600 | 234, 234, 235 | 255 |
| Left frame border | 80, 600 | 110, 61, 91 | 255 |
| Nameplate | 543, 130 | 55, 60, 90 | 255 |
| Rules panel | 543, 1000 | 47, 45, 51 | 255 |

The exterior and aperture fail transparency requirements. Borders, nameplate and rules panel are opaque as required. The panel has enough contrast for light text at inspection scale. The illustration does not need alpha.

Reproduce the inspection from the repository root:

```powershell
@'
from PIL import Image
from pathlib import Path
import hashlib
paths = [Path('assets/_source/lot1/cards/frames/mo_card_frame_master_v02.png'),
         Path('assets/_source/lot1/cards/illustrations/mo_illustration_arcane_knight_test_v01.png')]
for path in paths:
    im = Image.open(path)
    print(path, im.size, im.mode, im.getbands(), im.info.get('transparency'))
    print(hashlib.sha256(path.read_bytes()).hexdigest())
im = Image.open(paths[0])
for point in [(0,0),(1085,0),(0,1447),(1085,1447),(543,400),(550,400),
              (543,600),(80,600),(543,130),(543,1000)]:
    print(point, im.getpixel(point), im.convert('RGBA').getpixel(point)[3])
'@ | python -
```

Inspection exited 0. Both source hashes remained unchanged after rendering.

## Assembly and temporary preview limits

Created only an isolated scene, presentation script, capture script, this review, screenshots and Godot-generated metadata. The scene uses native Control, TextureRect, Label and Panel nodes and the existing Theme/token accessors. No source artwork was overwritten, no replacement was generated, and no mask artwork was saved.

Composition uses source coordinates (1086 × 1448):

1. Clipped illustration Control at `(124,207)` with size `(838,642)`. An AtlasTexture references the illustration's top `(0,0,1086,900)` region; KEEP_ASPECT_COVERED fills the opening without stretching the character. The head and armored torso remain clear. The lower body and sword are intentionally cropped; the raised spell hand is mostly outside the crop. A later illustration-specific crop should preserve more of this gesture if it is important to card identity.
2. Original frame TextureRect over the illustration, with an explicitly temporary shader. The shader removes bright near-neutral pixels only within bounded aperture/exterior regions (`min RGB > 0.70`, channel spread `< 0.045`). Opaque curved trim covers the illustration's rectangular clip edges. The preview does not spill over the nameplate, rules panel, mana or stat sockets.
3. Native title, type/tribe, rule, mana, ATK/HP, rarity name and thin rarity line above the frame. All labels are presentation fixtures. Nothing is submitted to an engine or catalog.

**The display key is not reliable production alpha.** It can leave pale edge fringes or remove small neutral highlights within its bounds. Fine checkerboard contamination remains at some decorative edges; do not approve edge quality from this preview. Its purpose is composition review while the artwork defect remains prominently disclosed. Replace the source with a properly authored RGBA export and remove the shader before any production integration.

Fixture: Arcane Knight / Creature / Human / mana 4 / ATK 4 / HP 5 / Epic; “Whenever this creature attacks, gain 1 Shield.” These values and words have no normative gameplay meaning.

Keys 1/2/3 switch modes. The standalone scene also accepts `--mode=0`, `--mode=1`, or `--mode=2` after `--`. The main scene and existing experiments remain untouched.

## Rendering observations

All four final screenshots were opened and visually inspected. They are actual graphical Godot OpenGL renders on the GTX 1660 Ti, captured using an explicitly sized SubViewport after `RenderingServer.frame_post_draw`. They are not mockups or image resizes.

| Mode | Layout and observed result |
|---|---|
| Full-size, 1080p | Card is 570 × 760 px. Title approximately 35.7 px, rule 28.3 px, mana 57.7 px. Text and values fit their intended panels. Bronze/gold trim, dark metal and cloth have convincing detail; the cool illustration complements the frame. The dense footer and repeated gems compete with the otherwise clear hierarchy. |
| Seven cards, 1080p | Each card is 237 × 316 px; 16 px Control gaps, centered with 82.5 px outer margins. Entire silhouettes fit. No overlap or clipped card. Titles are approximately 14.8 px; main numbers about 24 px and remain clear. Rule text is approximately 11.8 px and needs inspection for comfortable reading. Small ATK/HP captions are secondary and weak at this size. |
| Seven cards, 720p | Same composition scales to 158 × 210.7 px cards, 10.7 px gaps and 55 px margins. All seven fit fully. Mana and stats remain recognizable at about 16 px. Titles are approximately 9.9 px and marginal; rules approximately 7.9 px and not comfortably readable. **Full text readability at minimum viewport is not validated.** A production inspection/hover view and/or revised proportions are required, outside this experiment's scope. |
| Five rarities, 1080p | Five 319.5 × 426 px cards fit with consistent spacing. Native common white, uncommon blue, rare red, epic violet, legendary gold are applied to explicit on-card names and a thin line, with larger comparison labels below. No duplicate frame textures or gameplay rarity implementation. |

The fixed violet gems, side cloth and footer magic make every card feel Epic, even when its textual rarity differs. They compromise the candidate as a rarity-neutral master. A neutral base plus separately tintable ornaments or an authored mask would give the five rarities a stronger identity. A purple gemstone alone is not used as a rarity signal here. The small rarity line/name is feasible as a supplementary cue but insufficient as a production border identity at hand scale.

## Screenshot evidence

- [single_card_1080p.png](single_card_1080p.png) — 1920 × 1080
- [hand_7_cards_1080p.png](hand_7_cards_1080p.png) — 1920 × 1080
- [hand_7_cards_720p.png](hand_7_cards_720p.png) — 1280 × 720
- [rarity_samples_1080p.png](rarity_samples_1080p.png) — 1920 × 1080

## Verification commands and actual results

Run in `D:\Dev\MagicOdyssey`. Start-Process with `-Wait -PassThru` was used because invoking this Windows GUI executable directly from PowerShell did not provide a reliable process exit code. An initial direct import invocation produced an empty `$LASTEXITCODE`; it is not counted as a verified result. The import was repeated with a waited process.

```powershell
$GodotExe = 'D:\Temp\Godot_v4.7.2-stable_win64.exe'
function Invoke-Art002Godot([string]$Name, [string[]]$Arguments) {
    $process = Start-Process -FilePath $GodotExe -ArgumentList $Arguments `
        -WindowStyle Hidden -PassThru -Wait `
        -RedirectStandardOutput ("D:\Temp\art002-$Name-stdout.log") `
        -RedirectStandardError ("D:\Temp\art002-$Name-stderr.log")
    Get-Content ("D:\Temp\art002-$Name-stdout.log")
    Get-Content ("D:\Temp\art002-$Name-stderr.log")
    Write-Output "$Name EXIT=$($process.ExitCode)"
}
Invoke-Art002Godot 'import' @('--headless','--editor','--path','D:\Dev\MagicOdyssey','--import')
Invoke-Art002Godot 'tests' @('--headless','--path','D:\Dev\MagicOdyssey',
    '--script','res://scripts/tests/test_runner.gd')
Invoke-Art002Godot 'launch' @('--headless','--path','D:\Dev\MagicOdyssey',
    'res://scenes/ui/art002_card_integration_test.tscn','--quit-after','5')
$runs = @(
    @('single_card_1080p.png','1920','1080','0'),
    @('hand_7_cards_1080p.png','1920','1080','1'),
    @('hand_7_cards_720p.png','1280','720','1'),
    @('rarity_samples_1080p.png','1920','1080','2')
)
foreach ($run in $runs) {
    Invoke-Art002Godot $run[0] @('--path','D:\Dev\MagicOdyssey',
        '--script','res://docs/art/reviews/art002/capture.gd','--',
        ('D:/Dev/MagicOdyssey/docs/art/reviews/art002/' + $run[0]),
        $run[1],$run[2],('--mode=' + $run[3]))
}
git diff --check
```

The helper above consolidates the executed Start-Process commands without changing their engine arguments. Logs were written under `D:\Temp`; the final capture loop used `art002-<filename>.stdout.log` and `.stderr.log` names.

| Check | Actual process exit | Evidence |
|---|---|---|
| Headless editor import | 0 | Editor import completed, no script error |
| Existing native runner | 0 | 14 total assertions, 14 passed, 0 failed; `RESULT: ALL TESTS PASSED` |
| New scene headless launch, five frames | 0 | No errors on stderr |
| Single 1080p graphical capture | 0 | `ART002_CAPTURE size=(1920, 1080) ... result=0` |
| Seven-card 1080p graphical capture | 0 | `ART002_CAPTURE size=(1920, 1080) ... result=0` |
| Seven-card 720p graphical capture | 0 | `ART002_CAPTURE size=(1280, 720) ... result=0` |
| Rarity 1080p graphical capture | 0 | `ART002_CAPTURE size=(1920, 1080) ... result=0` |
| Pixel inspection and source hash recheck | 0 | Dimensions above, source hashes identical |
| `git diff --check` | 0 | No output; untracked text additionally checked for whitespace |

The first single-card capture emitted an anchor/size warning. Capture setup was corrected to set top-left anchors and the explicit size before adding the scene. All four final captures ran without that warning. Native tests were not modified and test only the existing harness; they do not establish visual success. Keyboard switching was not manually exercised (NOT_RUN); capture arguments rendered every mode. No gameplay, drag/drop or production inspector was implemented or tested.

## Remaining work and Git status

1. Re-export true RGBA artwork: transparent exterior and illustration aperture, opaque trim/nameplate/rules panel, clean antialiased edges. Remove the preview shader after replacement.
2. Supply a rarity-neutral base or independently tintable ornaments; the violet accents currently dominate every rarity.
3. Improve hand-scale title/rules readability and consider preserving the character's spell-hand gesture through an alternate crop. Production hover/inspection belongs to its assigned roadmap work.
4. Human review of the linked screenshots remains required. This is a technical REQUEST_FRAME_REVISION, not automatic artistic rejection or approval.

At completion, no tracked existing file was modified, nothing was staged and no commit was created. `git status --short --untracked-files=all` lists `??` for:

- The two pre-existing source PNGs and their Godot `.png.import` metadata under `assets/_source/lot1/cards/` (the source directory was already untracked before this task).
- `scenes/ui/art002_card_integration_test.tscn`.
- `scripts/presentation/art002_card_integration_test.gd` and its generated `.uid`.
- This review, `capture.gd`, its generated `.uid`, and the four screenshots under `docs/art/reviews/art002/`.

No unrelated generated imports were retained. Suggested future commit message: `test(ui): validate premium card frame with illustration`.
