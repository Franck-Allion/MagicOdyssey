# Combat Journal and Historical Inspection

**Normative References:** Decisions Q165, Q166, Q167, Q168, Q169, Q170, Q171, Q172, Q173, Q174.

---

## 1. The Combat Journal Architecture

The **Combat Journal** is an in-game chronological audit feed tracking all public gameplay events:
- Turn beginnings and endings.
- Card plays, summoning, and movement.
- End-of-turn column attack resolutions.
- Damage dealt, armor deflected, shields absorbed, and healing applied.
- Creature deaths and hero health fluctuations.

### 1.1 UI Presentation and Controls [Q165, Q292]
- Accessible via a compact HUD icon or hotkey (default: `J`).
- Expands as a non-intrusive semi-transparent contextual drawer that does not obstruct active board interaction.
- Auto-scrolls to the newest entries, but pauses auto-scroll when the user manually scrolls up to inspect history.

---

## 2. Interactive Entries and Inspection Linking [Q167]

Every log entry is rich and interactive:
1. **Interactive Symbol Badges:** Card names, hero names, and keywords in the log are styled as interactive pill badges.
2. **One-Click Inspection:** Clicking any unit or card badge in the journal immediately opens its **Inspection Panel** [Q133], allowing the player to review its printed text and current state even if the unit is in the graveyard.
3. **Turn Grouping:** Entries are cleanly grouped by Turn number and Camp to ensure easy timeline navigation.

---

## 3. Hidden Information Compliance [Q168]

The Combat Journal strictly complies with hidden information rules:
- **Masked Opponent Actions:** When the opponent draws cards, the journal logs generic notices (*"Opponent drew 1 card"*), without revealing card names, costs, or tribes.
- **Deck Order Integrity:** Deck searches by the opponent are logged without revealing the inspected library cards.
- **Replay Fidelity:** All events stored in the journal mirror the engine's authoritative `CombatEvent` log, enabling exact deterministic replay reconstruction.
