# Global Directives

## Interaction Style

Be brutally honest. Challenge my thinking, question assumptions, expose blind spots. Don't validate, soften, or flatter.
If I'm fooling myself, avoiding something uncomfortable, or making excuses — call it out with the opportunity cost. Show me where I'm underestimating effort or playing small. Then give a precise, prioritized plan to fix it.

Keep responses concise. Don't summarize what you just did — I can read diffs. Present options with tradeoffs when exploring; implement when asked.

## Human Output

Act like a human for all outward-facing artifacts — commit messages, PR descriptions, branch names, comments, and documentation. Write short, natural commit messages, not multi-paragraph essays. PR descriptions should be conversational, not systematic reports. Unless I explicitly ask for detailed or formal output, default to what a human developer would naturally write.

## Knowledge Currency

Your training data goes stale. Outdated guidance is worse than no guidance.

**When to WebSearch (mandatory, not optional):**
- When recommending a specific version, flag, or configuration of a tool/API/action
- When answering "how does X work" or "what's the current way to do Y" for tools that have versions
- When a user names a specific external tool or action (e.g., `actions/attest-build-provenance`) and you're about to describe its behavior
- When suggesting a dependency or approach the user hasn't already chosen

**When WebSearch is not needed:**
- Tools already in the project's dependency files — read the project files instead
- Well-known CLI tools used in their standard way (`git commit`, `cargo test`, `docker build`)
- Internal project patterns — read the codebase instead
- General programming concepts that don't have versioned APIs

This applies everywhere: formal skill execution, casual conversation, follow-up questions, subagent prompts. No exceptions for "I'm pretty sure." If you're about to state a specific version number, flag name, or behavioral detail from memory — stop and search.

## General Preferences

- Use `gh` CLI for all GitHub interactions (PRs, issues, reviews, merges)
- Prefer `.yaml` over `.yml` for file extensions
- Sign all commits. Never change git author or signing options. If signing fails, retry — the permission prompt may appear on the user's side. Only stop after repeated failures.

## Pre-Work

- **Dead code first**: Before structural refactors on files >300 LOC, remove dead code (unused imports, exports, variables, debug logs). Commit cleanup separately before the real work.
- **Phased execution**: Break multi-file refactors into phases of ≤5 files. Complete, verify, and get approval before each next phase.

## Code Quality

- **Senior dev standard**: Don't settle for "simplest approach" when architecture is flawed, state is duplicated, or patterns are inconsistent. Ask: "What would a perfectionist senior dev reject in code review?" Fix it.
- **Verification before completion**: Never report done without running the project's type-checker and linter, and fixing ALL resulting errors. If none configured, state that explicitly instead of claiming success.

## Context Safety

- **Re-read before editing**: After 10+ messages, re-read files before editing. Auto-compaction silently destroys context — editing against stale state causes silent Edit failures.
- **Large file chunking**: Files over 500 LOC must be read in chunks with offset/limit. A single read may not capture the whole file.
- **Truncation awareness**: If a search returns suspiciously few results, re-run with narrower scope. State when you suspect truncation.
- **Edit verification**: Re-read after every 3 edits to the same file. The Edit tool fails silently when old_string doesn't match.

## Rename & Refactor Safety

You have grep, not an AST. When renaming or changing any identifier, search separately for:
- Direct calls, references, and type-level uses
- String literals and template strings containing the name
- Re-exports, barrel files, and module entry points
- Test files, mocks, and fixtures
- Language-specific dynamic references (macros, reflection, codegen)

Don't assume a single grep caught everything.

## Git Workflow

- Conventional commits: `feat:`, `fix:`, `refactor:`, `chore:`, `docs:`, `test:`
- Tiny atomic commits — one concern per commit
- Independent branches per feature, rebase before PR
- No merge commits on main
- Breaking changes are acceptable when they improve the codebase

## Testing Philosophy

- Follow the language's test location convention (colocated in Rust/Go, `tests/` in Python, `__tests__/` in JS — don't impose one style across languages)
- Add unit tests when implementing new code
- Add regression tests when fixing bugs
- Use project-specific test utilities — don't reinvent what exists
- Prefer real system integration tests over mocks that diverge from production

## Skills & Planning

- Skill descriptions MUST start with "Use when..." — no workflow verbs in descriptions
- Write ALL plan and spec output to `.claude/plans/`, not custom directories
- Plans must be fully self-contained — the implementer has no conversation history
- After implementation: review from multiple perspectives before declaring done (code quality, security, simplification, CI verification, architecture if applicable)

### Mandatory Plan Structure

All implementation plans — whether via `/interview`, plan mode, or `/writing-plans` — must include these sections:

- **Context** — what's being built and why
- **Architecture** — approach, key decisions
- **Skills Reference** — which skills to invoke during implementation (TDD, debugging, verification) AND after all tasks (code quality review, security review, simplification, CI verification, architecture review)
- **Tasks** — with actual code, exact file paths, TDD steps
- **Verification** — project-specific end-to-end verification commands and expected output, not just "run tests"
- **Review Checklist** — specific review dimensions with concrete checks per dimension, not generic boilerplate

The interview skill's `plan-template.md` (`~/.claude/skills/interview/plan-template.md`) is the authoritative template. Reference it when writing any plan.
