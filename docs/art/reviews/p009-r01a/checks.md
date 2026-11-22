# Preparation checks — 2026-11-22

Scope: documentary P008 closure followed by P009-R01A art preparation. No production source, artwork, card definitions, theme, shader or engine code is changed.

| Check actually executed | Result |
|---|---|
| Current HEAD and clean-start inspection | `72de243`, working tree initially clean |
| Standard Windows export | PASS, exit 0; [log](../p008/final-windows-2026-11-22/export.log) |
| Isolated Windows OS-input follow-up | PASS, harness exit 0; default/1920×1080/1280×720, 24 occupied identities, selection, raised hand, End Turn mouse/Space, ESC 0 in all three runs; [results](../p008/final-windows-2026-11-22/results.json) |
| Existing source image inspection | Master PNG 1086×1448 RGBA, exact 3:4; SHA-256 matches historical ART-002 v03 record; alpha0 opening and visible envelope measured independently |
| Reference package integrity | Three existing image copies, byte-identical to their sources; [manifest](reference-manifest.json) |
| Production non-regression | All tracked `scripts`, `scenes`, `assets`, `resources`, `project.godot` and `export_presets.cfg` files match HEAD; [per-file hashes](preservation.json) |
| Historical review preservation | Original F03/F04 review bodies remain verbatim beneath dated current sign-off addenda; old measurement/test JSONs are unchanged |
| Documentation consistency | Local links, JSON schemas-as-data, rectangle bounds, status boundaries and archive contents checked; [final check manifest](validation-results.json) |
| `git diff --check` | PASS, exit 0 |

**NOT RUN / NOT CLAIMED:** fresh full native/gameplay suite or fresh ART-002 GPU regression (documentation-only task; source preservation checked instead); image generation; Spell PNG delivery; pixel/alpha validation of nonexistent Spell artwork; native-scale/GPU review of generated Spell art; owner Spell acceptance; R01B integration.

Mandatory source inspection included AGENTS/protocol, roadmap/progress, F03/F04 evidence, ART-002 master/reviews/mask, current content/category/stat/layout/hand presentation, theme/rarity shader, and normative card catalog. Graph project `D-Dev-MagicOdyssey` was checked at session start. Targeted search and both-direction `CardContentOverlay.configure` trace plus exact snippet were consulted. Coverage metadata generation `2026-11-22T10:37:38Z` was unavailable/changed for bounded candidate paths; direct source and bounded file/class inventories were used. No exhaustive graph claim is made. The currently absent standalone CardView/HandView/CardDefinition files were not invented or implemented.

The source reference master has historical alpha residues; no cleanup was applied. The Q181 purple/current-implementation emerald Epic mismatch is recorded without changing production colors. Preparation is complete; generation, alpha validation and owner Spell review remain pending. P009-R01B/R02A/R02B and P010 remain TODO, G1 NOT_VALIDATED.

See [the exact changed-document inventory](changed-documents.md). Binary screenshots and reference copies are separate evidence artifacts, not new production artwork.
