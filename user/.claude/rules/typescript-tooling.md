---
paths:
  - "**/package.json"
  - "**/*.ts"
  - "**/*.tsx"
  - "**/*.js"
  - "**/*.jsx"
  - "**/*.mts"
  - "**/*.cts"
---

# TypeScript Tooling Rules

Read `package.json` devDependencies before any type-checking or package install action.

## Package conflict

`typescript` and `@typescript/native-preview` (tsgo) must NEVER coexist. Check `package.json` before installing either. For new projects without either, prefer `@typescript/native-preview` — it's the native Go port (beta, going stable mid-2026) and significantly faster.

## Type-checking tool selection

- `oxlint` + `oxlint-tsgolint` both present → `oxlint --type-aware --type-check` covers type-checking; separate `tsc`/`tsgo` is redundant
- All other setups (oxlint without tsgolint, eslint, biome, prettier, or no linter) → still need a separate type-check step

## Type-checker command

- `@typescript/native-preview` in deps → `tsgo --noEmit`
- `typescript` in deps → `tsc --noEmit`
- Never mix
