---
paths:
  - "**/Cargo.toml"
  - "**/Cargo.lock"
  - "**/package.json"
  - "**/package-lock.json"
  - "**/pnpm-lock.yaml"
  - "**/yarn.lock"
  - "**/bun.lock"
  - "**/pyproject.toml"
  - "**/uv.lock"
  - "**/poetry.lock"
  - "**/go.mod"
  - "**/go.sum"
  - "**/Gemfile"
  - "**/Gemfile.lock"
---

# Dependency Management

Never write a version number from memory.

**Adding/updating:**
- Prefer package manager CLI (`cargo add`, `pnpm add`, etc.) over manual manifest edits
- Match the project's version format with appropriate flags (e.g., `cargo add --exact` for pinned projects). Check after adding and fix if the flag wasn't available
- If manual edit is necessary, verify via registry CLI or WebSearch first
- Always target latest unless constraints require otherwise

**Version pinning:**
- Own projects: pin exact versions (no caret/tilde ranges) — supply chain attacks exploit loose ranges
- OSS contributions: follow the project's convention (if they use `^`, use `^`; if they pin, pin)
- When ambiguous, ask — but recommend pinned
- GitHub Actions: pin to full SHA, not tags

**Using library APIs:**
- Verify current API before writing import/use statements — breaking changes between major versions are common
- Check docs, changelog, or source rather than trusting training data
- If already in project deps, read the lock file for installed version and verify against that version's API

**Supply chain:**
- Verify package names exist in expected registry before adding (typosquatting is real)
- Check download counts and maintenance status for unfamiliar packages
- Never add unverified dependencies
