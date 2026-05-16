---
paths:
  - "**/*.rs"
  - "**/*.ts"
  - "**/*.tsx"
  - "**/*.js"
  - "**/*.jsx"
  - "**/*.py"
  - "**/*.go"
  - "**/*.java"
  - "**/*.kt"
  - "**/*.swift"
  - "**/*.rb"
  - "**/*.cs"
---

# Rename & Refactor Safety

You have grep, not an AST. When renaming any identifier, search separately for:
- Direct calls, references, and type-level uses
- String literals and template strings
- Re-exports, barrel files, module entry points
- Test files, mocks, fixtures
- Language-specific dynamic references (macros, reflection, codegen)

Don't assume a single grep caught everything.
