---
description: Rust clippy discipline — run clippy on changed code, never suppress warnings with allow attributes
paths:
  - "**/*.rs"
---

# Rust — Clippy Discipline

After editing Rust code, run clippy on the affected crate(s) before declaring the change complete:

```sh
cargo clippy -p <crate> -- -D warnings
```

- Never use `#[allow(clippy::...)]` to suppress warnings — fix the code or restructure
- Only use `#[allow(...)]` when there is a genuine false positive AND you've verified clippy's suggestion is wrong for the specific case
- No `_`-prefixed unused variables — delete dead code entirely
- When clippy and the code conflict, restructure the code to satisfy clippy, don't suppress the lint
