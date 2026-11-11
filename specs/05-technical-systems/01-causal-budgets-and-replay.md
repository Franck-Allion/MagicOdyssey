# Causal Budgets, Snapshot Serialization, and Replay Determinism

**Normative References:** Decisions Q115, Q116, Q117, Q118, Q119, Q120, Q121, Q122, Q123, Q124, Q125.

---

## 1. Causal Budgets and Infinite Loop Prevention [Q115–Q118]

To guarantee that complex card combinations and reactive triggers never hang the game engine or cause a crash:

### 1.1 Causal Context Tracking [Q115]
Every event, trigger, and operation generated in the engine is tagged with a `CausalContext`:
- `root_command_id`: The originating player command or turn phase trigger.
- `chain_depth`: The nested trigger depth ($0$ for the root command, $+1$ for each subsequent trigger fired by a reaction).
- `source_signature`: Tuple of `(source_card_id, event_type, target_id)` detecting repetitive cycles.

### 1.2 Budget Thresholds [Q116]
- **Maximum Chain Depth:** Fixed at **16 nested trigger levels** per root command.
- **Maximum Event Count:** Fixed at **64 operations** per root transaction.

### 1.3 Targeted Branch Neutralization [Q117, Q118]
- When a causal chain exceeds the maximum depth, the engine **suppresses only the repeating recursive branch**.
- It does **not** roll back already committed events in the transaction.
- Legitimate, non-repeating events remaining in the FIFO queue continue to resolve.
- The engine emits a `CAUSAL_BUDGET_EXCEEDED` diagnostic event containing the loop signature for debugging.

---

## 2. Deterministic Replay and State Hashing [Q119–Q122]

1. **Deterministic Function Contract:**
   $$\text{CombatEngine}(\text{State}_t, \text{Command}_t, \text{RNG}_t) \longrightarrow (\text{State}_{t+1}, \text{Events}_t, \text{Result}_t)$$
2. **Controlled PRNG Stream:** Random choices (e.g. initial deck shuffle, random targeted spells) consume a seeded pseudo-random number generator. No unseeded system calls (`rand()`, `Time.get_ticks_msec()`) may influence game logic.
3. **Canonical State Hashing [Q121]:**
   - At each turn boundary, the engine computes a 64-bit canonical state hash (`state_hash`) covering: hero stats, board instances (positions, current HP, buffs), and zone contents.
   - Replaying an identical seed and command stream must produce identical state hashes at every step.
4. **Minimal Replay Artifact [Q122]:** A full combat match can be perfectly archived and shared using merely:
   - Rules engine version string.
   - Initial RNG seed.
   - Ordered list of input `CombatCommand` objects with timestamps.

---

## 3. Snapshot Serialization [Q123–Q125]

- The full `CombatState` is serializable to a compact typed dictionary / binary format.
- State serialization enables:
  - Mid-combat resume.
  - Headless AI rollouts and tree searches.
  - Snapshot diffing during automated regression testing.
