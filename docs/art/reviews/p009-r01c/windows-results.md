# P009-R01C Windows standalone results

**2026-11-25 · 1920×1080 physical Windows desktop**

The Windows Desktop preset export completed with exit 0. The playtest copied only `MagicOdyssey.exe` to an isolated temporary directory, launched it through the Windows shell, and confirmed the existing mixed preview scenario in the application's log. The test used the foreground Windows window, real OS pointer positioning and mouse/keyboard input. Desktop PNGs are unscaled captures of the game client.

| Mode | Client | Mixed hand | Raised Spell over player attack slot 3 | End Turn | ESC |
|---|---:|---|---|---|---:|
| Default desktop | 1888×956 | PASS | PASS | Mouse and Space PASS | 0 |
| Exact 1080p | 1920×1080 | PASS | PASS | Mouse and Space PASS | 0 |
| Exact 720p | 1280×720 | PASS | PASS | Mouse and Space PASS | 0 |

The control click on player attack slot 3 selected it. With mixed hand card 4 (Mending Light) raised, moving to the same slot area held card 4, produced no additional slot hover event, and generated no slot click. The captures show the Spell nameplate and all three Common jewels, with Creature cards also in the hand. The end-turn preview logged focus and exactly two activations. Each final playtest exited 0 and left no game process running.

| Evidence | Default | 1080p | 720p |
|---|---|---|---|
| Mixed hand | [Capture](windows/desktop-default.png) | [Capture](windows/desktop-1920x1080.png) | [Capture](windows/desktop-1280x720.png) |
| Raised Spell over slot | [Capture](windows/desktop-default-raised-hand-no-slot-leak.png) | [Capture](windows/desktop-1920x1080-raised-hand-no-slot-leak.png) | [Capture](windows/desktop-1280x720-raised-hand-no-slot-leak.png) |
| Left-hand hover | [Capture](windows/desktop-default-hover-left.png) | [Capture](windows/desktop-1920x1080-hover-left.png) | [Capture](windows/desktop-1280x720-hover-left.png) |
| End Turn pressed | [Capture](windows/desktop-default-button-pressed.png) | [Capture](windows/desktop-1920x1080-button-pressed.png) | [Capture](windows/desktop-1280x720-button-pressed.png) |
| Playtest and Godot logs | [Transcript](windows/desktop-default.txt) | [Transcript](windows/desktop-1920x1080.txt) | [Transcript](windows/desktop-1280x720.txt) |

Earlier attempts exited 1 after unexpected pointer movement affected target selection. One 720p attempt lost foreground ownership to the PDF viewer and the harness stopped before sending further input. The default-mode retest stayed in the same pointer column between the resting card and the raised area of slot 3. The successful runs above repeated the positive slot control, tested hover and click isolation, and completed End Turn and ESC. These results cover this Windows computer and renderer. The five-rarity coverage and color checks use the separately captured GPU fixtures.
