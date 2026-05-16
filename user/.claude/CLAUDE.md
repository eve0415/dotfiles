# Global Directives

## Interaction

Be brutally honest. Challenge my thinking, question assumptions, expose blind spots. Don't validate, soften, or flatter. If I'm fooling myself or making excuses — call it out with the opportunity cost, then give a precise plan to fix it.

Keep responses concise. Don't summarize what you just did — I can read diffs. Present options with tradeoffs when exploring; implement when asked.

Act like a human for all outward-facing artifacts — commit messages, PR descriptions, branch names, comments, documentation. Short, natural, conversational. No multi-paragraph essays or systematic reports unless explicitly asked.

## Design Philosophy

**Extensibility by default.** Every implementation must be designed for future expansion — APIs, interfaces, types, data structures, all of it. This is non-negotiable and applies to all work, regardless of stated scope or finality.

Today's best practice is tomorrow's anti-pattern. Industrial standards evolve, technology advances, requirements change. Code that can't accommodate growth gets rewritten from scratch. Design as if everything will change, because it will.

This is about structural choices at boundaries, not speculative features:
- **Do:** Use an enum where a boolean would suffice today — a third state is one requirement change away
- **Do:** Define a trait/interface at a module boundary, even with one implementation now
- **Do:** Structure data for additive changes — adding a field shouldn't break existing consumers
- **Don't:** Build features no one requested. Create abstractions for hypothetical use cases. Over-engineer.

This principle is silent — don't surface it, don't discuss it. Just apply it to every design decision.

## Knowledge Currency

Your training data goes stale. Outdated guidance is worse than no guidance.

**WebSearch is mandatory when:**
- Recommending a specific version, flag, or configuration
- Answering "how does X work" for tools with versions
- A user names a specific external tool or action and you're about to describe its behavior
- Suggesting a dependency or approach the user hasn't already chosen

**Not needed when:**
- Tools already in the project's dependency files — read the project instead
- Well-known CLI tools in standard usage (`git commit`, `cargo test`)
- Internal project patterns — read the codebase
- General programming concepts without versioned APIs

This applies everywhere — formal skill execution, casual conversation, follow-up questions, subagent prompts. No exceptions for "I'm pretty sure." If you're about to state a specific version number, flag name, or behavioral detail from memory — stop and search.

## Code Practices

**Dead code first / phased execution:** Before structural refactors on files >300 LOC, remove dead code first (separate commit). Break multi-file refactors into phases of ≤5 files — complete, verify, get approval before each next phase.

**Senior dev standard:** Don't settle for "simplest approach" when architecture is flawed, state is duplicated, or patterns are inconsistent. Ask: "What would a perfectionist senior dev reject in code review?" Fix it.

**Verification before completion:** Never report done without running the project's type-checker and linter, fixing ALL errors. If none configured, state that explicitly.

### Context Safety

- Re-read files before editing after 10+ messages or every 3 edits to the same file — auto-compaction and Edit mismatches lose changes silently
- Files over 500 LOC: read in chunks. Suspiciously few search results: re-run narrower and state the suspicion

## Workflow

### Planning & Execution

- **Explore → Plan → Implement → Verify.** Separate research from coding. Use plan mode for non-trivial changes.
- Use `/goal` for substantial tasks with a verifiable end state — migrations, design doc implementations, multi-file refactors. Write conditions with: one measurable outcome, a stated check command, constraints that must hold.
- Specify tasks upfront with intent, constraints, acceptance criteria, and relevant file locations. One well-specified prompt outperforms five rounds of back-and-forth.
- Spawn subagents explicitly for investigation, parallel file processing, and independent review. Don't expect automatic parallelization — request it.
- Delegate codebase research to subagents to keep the main context clean for implementation.

### Git

- Conventional commits: `feat:`, `fix:`, `refactor:`, `chore:`, `docs:`, `test:`
- Tiny atomic commits — one concern per commit
- Independent branches per feature, rebase before PR, no merge commits on main
- Breaking changes are acceptable when they improve the codebase
- After any install/update or manifest edit, always stage and commit the lock file (`Cargo.lock`, `pnpm-lock.yaml`, `package-lock.json`, `yarn.lock`, `bun.lock`, `uv.lock`, `poetry.lock`, `go.sum`, `Gemfile.lock`) in the same commit
- Never leave lock file changes unstaged — if a dependency changed, the lock file is part of that change
- Sign all commits. Never change git author or signing options. Retry on failure — permission prompt may appear on the user's side. Only stop after repeated failures
- Use `gh` CLI for all GitHub interactions

### Testing

- Follow the language's test location convention (colocated in Rust/Go, `tests/` in Python, `__tests__/` in JS)
- Add unit tests when implementing new code, regression tests when fixing bugs
- Use project-specific test utilities — don't reinvent what exists
- Prefer real system integration tests over mocks that diverge from production

### General

- Prefer `.yaml` over `.yml`

## Skills & Planning

- Skill descriptions MUST start with "Use when..." — state explicit precedence when layering authority sources, never hardcode dynamic tool output, carve out diagnostic/reading from prohibition sections
- Write all plan and spec output to `.claude/plans/` — plans must be fully self-contained (the implementer has no conversation history)
- After implementation: review using `code-review:code-review` (code quality), `security-review` (security), `simplify` (simplification), `verify` (CI verification)

### Mandatory Plan Structure

All plans must include:

- **Goal** — verifiable end state with a ready-to-paste `/goal` condition
- **Context** — what's being built and why
- **Research Findings** — external research, modern approaches, known pitfalls
- **Architecture** — approach, key decisions
- **Design Rationale** — alternatives considered, why each was rejected, why chosen approach wins
- **Skills Reference** — exact skill names from the catalog below. List which to invoke during implementation AND which after all tasks for review
- **Implementation Phases** — grouped tasks with dependency graphs, per-phase verification gates, actual code and exact file paths
- **Verification** — project-specific end-to-end verification commands and expected output
- **Review Checklist** — specific review dimensions with concrete checks per dimension

The interview skill's `plan-template.md` (`~/.claude/skills/interview/plan-template.md`) is the authoritative template. Reference it when writing any plan.

### Skill Catalog

Use exact names when referencing skills in plans. Never use generic descriptions like "code quality review" — use the skill name.

**Pre-implementation:**
- `interview` — requirements elicitation when specs are unclear
- `spec-research` — research devcontainer spec / official CLI behavior
- `write-spec` — create official project documentation
**During implementation:**
- `superpowers:test-driven-development` — TDD workflow (test first, fail, implement, pass)
- `superpowers:systematic-debugging` — root cause debugging when tests fail
- `superpowers:verification-before-completion` — verify before claiming done
- `feature-dev:feature-dev` — guided feature development with architecture focus
- `verify` — run full CI verification suite locally

**Post-implementation review (invoke after every non-trivial task):**
- `code-review:code-review` — code quality review (dispatches `feature-dev:code-reviewer` subagent)
- `security-review` — security review of pending changes
- `simplify` — review changed code for reuse, quality, efficiency
- `verify` — CI verification (format, lint, test, snapshots)
- `empirical-prompt-tuning` — validate prompt/skill changes with bias-free executor

**Completion:**
- `superpowers:finishing-a-development-branch` — branch completion (merge, PR, keep, or discard)

**Maintenance:**
- `claude-md-management:claude-md-improver` — audit and improve CLAUDE.md files
- `claude-md-management:revise-claude-md` — update CLAUDE.md with session learnings
- `retrospective-codify` — codify trial-and-error learnings into rules or skills
- `update-config` — configure hooks, permissions, env vars in settings.json
- `fewer-permission-prompts` — optimize permission allowlists
