# Instructions for AI Implementation Agents

This document defines the mandatory engineering practices, architecture rules, and validation protocols for AI coding assistants (Codex, Gemini Flash, Claude, Cursor) working on **MagicOdyssey**.

The comprehensive protocol is maintained in [specs/06-reference/03-agents-protocol.md](specs/06-reference/03-agents-protocol.md).

---

## 1. Hierarchy of Truth and Sources

1. **Hierarchy:**
   - [specs/01-lot1-vertical-slice/01-scope.md](specs/01-lot1-vertical-slice/01-scope.md) and [specs/01-lot1-vertical-slice/02-catalog.md](specs/01-lot1-vertical-slice/02-catalog.md) take **absolute precedence** for current development.
   - [specs/01-lot1-vertical-slice/05-roadmap.md](specs/01-lot1-vertical-slice/05-roadmap.md) defines the exact prompt sequence (`P001` to `P065`).
   - [specs/02-combat-rules/](specs/02-combat-rules/) defines comprehensive game rules (Decisions Q01–Q274 + Q275–Q302).
   - [specs/06-reference/01-glossary.md](specs/06-reference/01-glossary.md) establishes normative English terminology.
   - [specs/06-reference/02-decisions.md](specs/06-reference/02-decisions.md) logs design decisions and rationale.
   - If a conflict arises between an older draft and a newer validated decision, the **latest validated decision wins**.
2. **Status Tags:**
   - **[VALIDATED]**: Non-negotiable design decision. Implement strictly.
   - **[LOT1]**: Implementation contract for the current vertical slice.
   - **[CONFIG]**: Fixture or balancing parameter. Place in `.tres` fixtures; do not hardcode into game engine scripts.
   - **[PROPOSAL]**: Recommendation. Do not treat as historical canon.
   - **[OUT OF SCOPE]**: Post-Lot 1 feature. Do not implement in Lot 1 prompts.
3. **Never Invent Rules:** If a scenario is underspecified, consult `specs/06-reference/02-decisions.md` or ask the user for confirmation. Never invent alternative game rules.

---

## 2. Godot 4 Architecture Invariants

1. **Strict Hexagonal Domain / Presentation Decoupling:**
   - The game rules engine lives in `res://scripts/domain/`.
   - Domain classes (`CombatState`, `CombatEngine`, `CombatCommand`, `CombatResult`, `CombatEvent`) inherit from `RefCounted`, **never from `Node` or `Control`**.
   - The engine must run headlessly without scenes or windows.
2. **Fully Typed GDScript:**
   - Every variable, parameter, and return value must have an explicit type annotation.
   - Enums must be typed; avoid untyped dictionaries where typed resources or classes fit.
3. **Declarative Card Catalog:**
   - Cards are defined as Godot `.tres` Resources (`CardDefinition`).
   - Never write card-specific branching logic (`if card_id == "spell_fireball": ...`) inside `CombatEngine`.
   - Behavior is composed of generic atomic `EffectOperation` primitives dispatched via `EffectRegistry`.
4. **Deterministic Execution:**
   - All randomness must consume a controlled seeded pseudo-random number generator (`RandomNumberGenerator`).
   - Engine logic must never call unseeded random functions or system time.
5. **Decoupled Visual Scheduling:**
   - The engine produces ordered events immediately upon command commit.
   - The presentation layer (`CombatPresenter`, `VisualEventSequencer`) animates events asynchronously.
   - Animations and Tweens must **never** trigger game logic or deal damage.

---

## 3. Atomic Prompt Execution Protocol

When implementing an assigned prompt (`PNNN`):
1. **Scope Constraint:** Modify only the files explicitly relevant to the prompt (typically 1–4 files). Never perform sweeping unprompted refactoring.
2. **Headless Test Verification:**
   Before claiming a prompt is complete, execute the test suite via PowerShell:
   ```powershell
   & $GodotExe --headless --path . --script res://scripts/tests/test_runner.gd
   ```
3. **Honest Reporting:**
   - Never claim a test was executed if it was not.
   - Report: (a) modified files, (b) implemented behavior, (c) test output with real exit codes, (d) known limitations or visual review needs.
4. **No Placeholder Hacks:**
   - Do not leave temporary colored debug boxes intended to survive until release.
   - Follow the established design system tokens in `fantasy_theme.tres`.
