# MagicOdyssey — Technical Specifications

This directory contains transversal technical architecture documents and verification matrices.

---

## Index

1. **[01-causal-budgets-and-replay.md](01-causal-budgets-and-replay.md):**
   - Causal tracking context (`root_command_id`, `chain_depth`).
   - Recursion limits (max depth 16) and targeted branch neutralization [Q115–Q118].
   - Deterministic PRNG stream and canonical state hashing [Q119–Q122].
   - Binary/Dictionary snapshot serialization [Q123–Q125].

2. **[02-full-acceptance-tests.md](02-full-acceptance-tests.md):**
   - Full regression suite of 274 acceptance test scenarios (`T-001` to `T-274`).
   - Direct traceability to Decisions Q01 through Q274.
   - Mapping to the 45 Lot 1 tests (`L1-B01..B32` and `L1-U01..U13`).
