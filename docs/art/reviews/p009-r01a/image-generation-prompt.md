# English image-generation prompt — MagicOdyssey Spell frame v01

Status: **prepared prompt; not executed**. Attach the three unmodified reference images listed in [references.md](references.md), in order. The first image is the geometry/material authority. The other images show family finish and native presentation context; their text, figures, portraits and Creature-only sockets must not be copied into the output.

---

Create ONE premium production-quality **SPELL CARD FRAME** for the original dark-fantasy game MagicOdyssey. This is a card-type sibling of the supplied approved ART-002 Creature master, not a new visual identity and not a battlefield creature token.

Deliver a standalone **1086 × 1448 pixel RGBA PNG**, exactly **3:4 portrait aspect ratio**, with genuine transparent pixels. Intended filename: `mo_card_frame_spell_v01.png`. Show only the single front-facing frame in orthographic view: no camera perspective, tilt, staging, border outside the canvas, cast shadow on a backdrop, collage, variants, captions, sample card content or presentation sheet. If the generation service cannot output those exact dimensions, explicitly report its native dimensions; do not silently stretch, crop or mislabel a different aspect ratio as the final deliverable. A true 3:4 oversampled candidate would require a separately documented uniform downsample and complete pixel validation before delivery at 1086×1448.

## Match the supplied MagicOdyssey family

Use the first reference as the primary authority for proportion, top structure, outer material thickness, upper-left mana housing, nameplate, illustration window, three small faceted rarity stones and engraved metal craftsmanship. Preserve the family language: antique bronze with convincing sculpted bevels, controlled worn gold highlights, deep midnight-blue enamel, dark blue-black recessed substrates, fine restrained engravings and precise material transitions. Rich and elegant, with physically credible metal and enamel, not flat generic UI, bright plastic, cheap glow, neon, wood, parchment, futuristic technology or an imitation of another game's frame.

Keep the familiar long upper nameplate and large single illustration opening. Give the lower half an uninterrupted, quiet effect-description surface with a compact continuous border. Use the space released by the removed Creature statistics for real text capacity and visual breathing room. Never fill it with bulky purposeless bronze ornaments, circular seals, vacant medallions or extra decorative panels.

## Spell-specific removals — mandatory

Remove every Creature-only feature present in the Creature reference: bottom-left Attack housing, bottom-right Health housing, central Armor/Shield plaques, stat captions, stat medallions, empty stat sockets, rosette replacements, equipment attachment sockets and Weapon/Protection indicators. Do not leave the silhouette of a removed socket as an empty recess. Rebuild those lower regions as part of the continuous Spell text panel and restrained lower border.

The single upper-left mana housing MUST remain. Do not confuse it with an Attack or Health socket. The three small family rarity crystals also remain; they are not combat-stat sockets.

## Exact layout reservations

All following coordinates are source pixels on the 1086×1448 canvas, origin at the upper-left. Rectangle notation is x, y, width, height. Respect these reservations before adding ornament:

- Overall card envelope: match the first reference's approximately x24–1058, y0–1444 structural envelope and edge margins. Maintain the 3:4 card footprint; removing the Creature footer circles may change the local lower-corner contour, but must not make the Spell look wider, taller or unrelated.
- **Upper-left mana:** retain center **(153,151)** and a clean value-writing safe disk of radius **70** inside its bronze rim. Its dark blue-black/enamel backing is static and opaque. Leave it completely blank, without a number or symbol replacing the future cost.
- **Card-name safe area:** retain **(292,90,610,94)**. A quiet opaque dark backing, no engraved text, no ornament intruding into the usable rectangle. Leave space for dynamically rendered one- or controlled two-line names.
- **Large illustration aperture:** renderer coverage is **(124,207,838,642)**. Shape a genuine transparent, softly rounded/sculpted opening approximately within **(132,216,822,620)**, with a large unobstructed central field. Every fully transparent aperture pixel must be covered by that renderer rectangle. The sculpted frame should overlap the illustration coverage underneath, preventing gaps at curved corners. Do not paint a creature, person, spell effect, landscape or placeholder image into this opening.
- **Spell category safe area:** **(180,916,726,66)**, centered beneath the illustration bridge. Give it a quiet opaque backing for the word “Spell” to be rendered later by the game. Do not paint that word, a tribe, a category caption or runic pseudo-text into the PNG.
- **Effect-description safe area:** **(140,990,806,240)**, ending at y1230. This entire rectangle must be a low-noise opaque midnight-blue/dark enamel writing surface. No socket shoulders, ornaments, high-contrast scratches, glowing symbols or raised dividers inside it. This is wider and slightly taller than the Creature description area; do not preserve the old narrow text column or the bottom stat cutouts.
- Preserve the three small rarity crystal interiors at the supplied reference locations, using compact bronze settings clear of all writing areas. Their intended interior contours are: crown **(543,24)–(564,48)–(544,83)–(525,49)**; illustration bridge **(543,836)–(565,861)–(544,896)–(522,862)**; footer **(543,1247)–(567,1286)–(543,1337)–(520,1287)**. Keep the footer crystal beneath the effect text region, not embedded in a text line. These contours cover stone interiors, not bronze: re-sculpt any legacy projecting bezel tip so it stays outside the full effect-writing rectangle. Do not relocate the stone using y1330 as the visual center; its actual existing contour spans y1247–1337.

## Dynamic content versus static art

This PNG contains only the physical frame, quiet writing backings and neutral painted material substrates. The game later adds the illustration, full name, mana value, category, rarity labeling and effect description. Paint **no letters, digits, words, stat abbreviations, costs, rules, rarity names, lorem ipsum, fake glyph paragraphs, logos, signatures or watermarks** anywhere.

Rarity crystals should be neutral blue-black/clear smoky faceted stones matching the master substrate, with sharp painted cuts and restrained specular highlights that can be recolored by a shader. They remain opaque painted material. Do not bake a permanent Common/Uncommon/Rare/Epic/Legendary palette into this single frame, and do not tint the whole frame a rank color. Runtime rarity supports white/silver, sapphire blue, ruby red, amethyst purple and solar gold; the source artwork must stay neutral rather than choose one. Some runtime references use emerald Epic; do not bake that existing implementation variation into this source PNG either.

The mana backing and rarity stones are intentionally opaque, because their dynamic text/recoloring is drawn above them. No additional under-frame material insert is specified. Do not cut transparent holes through the title/category/effect writing backings or through these painted stone substrates.

## Genuine alpha requirements — non-negotiable

- **Alpha 0 outside the intended outer card silhouette.** No full-canvas haze, matte, shadow rectangle, fake black background or opaque surround.
- **Alpha 0 throughout the intended illustration opening.** It is a hole for future artwork, not black paint, a checkerboard or a placeholder image.
- Bronze, enamel, title/category/effect backings, mana backing and painted neutral stone interiors are **alpha 255 in their solid interior regions**.
- Use smooth partial alpha only in a narrow, genuine antialiased transition at physical material edges. No semitransparent full-canvas layer or broadly translucent metal/panels.
- No alpha-1 contamination, isolated translucent specks, colored fringe residue, holes in solid metal, baked checkerboard, or hidden opaque plugs in transparent regions.
- The legacy reference is a visual/material reference, not an alpha-quality template: do not reproduce its historical near-opaque surfaces or tiny alpha-1 residues.

Use actual transparent output, not a picture depicting transparency. Keep exterior and illustration aperture visually clean on both near-black and near-white backgrounds. Do not use a global destructive alpha threshold to conceal bad edge construction.

## Final visual check before delivery

At normal card scale the illustration, mana and title should dominate recognition. The effect-description region must remain comfortably usable after the game draws its text. The blank frame should look authored for Spells, with no suggestion of missing Creature stats. Compare its material and proportions directly against the first reference. There must be one card, one illustration opening and one mana housing, with no footer stat sockets or equipment marks.

Return the single standalone RGBA frame candidate only. Do not provide a finished illustrated/text-filled card, a render in a hand, a battlefield screenshot or an Equipment variant. Pixel dimensions, alpha histogram, material integrity and native-scale suitability will be verified independently after generation; delivering an image does not itself mean those checks or owner approval have passed.
