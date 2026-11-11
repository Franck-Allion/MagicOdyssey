# Tooltips, Durations, and Decoupled Visual Feedback (Juicy VFX)

**Normative References:** Decisions Q135, Q136, Q137, Q138, Q139, Q140, Q141, Q142, Q143, Q144, Q277, Q302.

---

## 1. Tactical Tooltips and Natural Language Durations

### 1.1 Hover Tooltip Design [Q135–Q137]
- Hovering a card in hand, creature token on board, or status icon displays an immediate, compact **Tactical Tooltip**.
- Shows: unit name, effective attack, current/max HP, armor, shield value, and concise summaries of active status effects.

### 1.2 Natural Language Durations [Q138, Q140]
- The game avoids obscure tick counts. Durations are explicitly rendered in localized, clear plain language:
  - *"Expires at the end of the current turn."*
  - *"Expires at the start of your next personal turn."*
  - *"Lasts until unequipped."*
  - *"Permanent."*
- When an effect alters a duration or adds turns, the tooltip recalculates its text immediately and triggers a subtle clock animation pulse [Q140].

---

## 2. Decoupled Visual Event Scheduler [Q277, Q302]

```
+--------------------------+
|      CombatEngine        | ---> Emits CombatEvent sequence immediately (0ms)
+--------------------------+
             |
             v
+--------------------------+
|  VisualEventSequencer    | ---> Plays animations: Impact (150ms), Shake (100ms)
+--------------------------+
             |
             +---> Critical board numbers match state: UNLOCK USER INPUT (250ms)
             |
             +---> Residual smoke/spark particles fade out in background (600ms)
```

### 2.1 Principles of Decoupled Feedback
1. **Engine Independence [Q277]:** The rules engine never yields or waits for animations. It produces the complete list of ordered gameplay events instantly.
2. **Snappy Pacing ("Juice") [Q141–Q144]:** Core gameplay animations are fast and punchy:
   - Card summon impact: 150–250ms.
   - Attack lunge / projectile flight: 150–300ms.
   - Damage shake & floating number: 200–350ms.
3. **Responsive Input Unlocking:** User interaction is re-enabled the moment essential token numbers (HP, armor, shields) match the authoritative state revision. Lingering decorative particles or audio tails must never block player input.
4. **State Revision Protection [Q302]:** A delayed visual effect from an older event is **strictly forbidden from overwriting a newer state revision**.

---

## 3. Visual Feedback Signatures [Q141]

| Event | Primary Visual Feedback | Audio Cue |
|---|---|---|
| **HP Damage** | Red floating number, screen/token impulse shake, target flash | Heavy flesh impact |
| **Armor Deflected** | Metallic ricochet sparks, grey floating number with shield icon | Metallic clang |
| **Shield Absorbed** | Blue crystalline crack / energy shimmer, decreasing shield pip | Resonant chime |
| **Healing** | Ascending emerald/golden halo, green floating `+N` number | Warm celestial hum |
| **Summoning** | Card flight from hand, ground impact dust, morph into crest | Magical thud |
| **Death** | Unit dissolves into ashes/light, slot clears cleanly | Low dissipation fade |
| **Victory / Defeat** | Dramatic modal banner, victory fanfare / defeat chord | Orchestral cue |
