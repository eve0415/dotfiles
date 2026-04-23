---
name: interview
description: Use when requirements are unclear or incomplete for a new feature, project change, or implementation. Also use when the user says "interview me", "spec this out", "let's plan this", or when structured elicitation is needed before design work begins.
---

# Interview

Systematic requirements elicitation through codebase research, external research, and relentless one-question-at-a-time depth probing. Produces either an implementation plan (system plan file) or official documentation (git-tracked spec), or both.

## When to Use

- New feature with unclear or incomplete requirements
- User wants structured requirements gathering before implementation
- Complex change where assumptions need to be validated
- User explicitly requests an interview or spec session

**Skip when:** Requirements are already clear and complete, the task is a simple bug fix with obvious cause, or the change is trivial (rename, typo, config tweak).

## Process

### Phase 1: Plan Mode Gate

If not in plan mode, enter plan mode before proceeding. The interview process is read-only research and conversation — no code changes.

### Phase 2: Codebase Exploration

Before asking any questions:
- Read project files, docs, CLAUDE.md, recent commits
- Trace architecture and map existing patterns
- Identify what's already known vs what needs asking
- Use Explore subagents for broad codebase research

### Phase 3: External Research

Before asking any questions:
- WebSearch for industry standards and best practices for the relevant technology
- Check official docs, GitHub issues, RFCs, blog posts for current state of the art
- Look for modern/latest approaches — prefer cutting-edge over traditional
- Identify known pitfalls, deprecated patterns, emerging alternatives
- Present a brief summary of key findings to the user before starting questions

### Phase 4: Interview Loop

Build a question tree from unknowns identified in Phases 2 and 3.

**Rules:**
- One question at a time via AskUserQuestion (never batch multiple questions)
- Always provide a recommended answer with reasoning (cite research when relevant)
- Multiple choice preferred when options are clear, open-ended when not
- Never ask what the codebase or research already answered
- Walk every branch of the design tree — all of these are mandatory, not suggestions:
  - Technical implementation (architecture, data flow, APIs)
  - UX (output format, user interaction, error messages)
  - Tradeoffs (performance, complexity, maintainability)
  - Edge cases (failure modes, concurrent access, empty/missing state)
  - Dependencies (ordering, external systems, backward compatibility)
  - Error handling (degradation, recovery, user-facing diagnostics)
  - Testing strategy (unit tests, integration tests, test infrastructure)
  - **Verification strategy** (how to verify end-to-end after implementation — exact commands, expected output, manual checks)
  - **Review criteria** (which review dimensions matter — security, performance, accessibility, architecture — and what specifically to check)
  - **Acceptance criteria** (definition of done — must-haves vs follow-ups, what the user will check before approving)
- Resolve dependencies between decisions one-by-one
- A branch is **resolved** when the user has made a concrete decision for every sub-topic in it — no open questions, no "TBD," no deferred choices. If a branch has only one obvious answer confirmed by codebase/research, state the answer and move on (don't ask what's already known).
- Continue relentlessly until all branches are resolved — do not stop early

### Phase 5: Design Synthesis

- Propose 2-3 approaches with trade-offs, informed by research findings
- Lead with your recommendation and explain why
- Present design section by section, get user approval on each
- Revise sections the user pushes back on before moving forward
- The chosen approach feeds the plan's Context and Architecture sections — no separate "Design Alternatives" section in the plan

### Phase 6: Terminal Choice

Ask the user via AskUserQuestion:
- **Option A: "Proceed to implementation"** (Recommended) — write implementation plan
- **Option B: "Write official spec"** — produce git-tracked documentation
- **Option C: "Both"** — write spec first, then implementation plan

### Phase 7: Write Spec (if Option B or C)

- Ask: audience (developer / end-user / both) and output path (default: `docs/specs/<name>.md`)
- Format for the chosen audience
- Write the git-tracked spec file
- If Option C, continue to Phase 8

### Phase 8: Implementation Plan (if Option A or C)

Write a self-contained implementation plan to the system plan file using the template in `plan-template.md` in this skill's directory.

**Critical:** The user clears conversation context after plan mode. The plan file is the ONLY context the implementer will have. It must include full context, architecture, research findings, all tasks with actual code, and which skills to invoke during implementation and review.

**All template sections are mandatory** — Context, Research Findings, Architecture, Skills Reference, Tasks, Verification, Review Checklist. Do not skip or stub any section. Fill Verification and Review Checklist with project-specific content gathered during the interview (Phase 4 verification/review/acceptance branches), not generic boilerplate.

- Self-review before writing: spec coverage, placeholder scan, type/name consistency, **verify all template sections present with project-specific content**
- Write to system plan file (`.claude/plans/<name>.md`)
- ExitPlanMode for user review

## Question Design

| Do | Don't |
|---|---|
| Ask about tradeoffs and constraints | Ask what's already in the codebase |
| Provide recommended answer with reasoning | Ask without a suggested direction |
| One question per message | Batch 3 questions in one message |
| Ask about edge cases and error handling | Only ask about the happy path |
| Walk design tree branches sequentially | Jump between unrelated topics |
| Cite research findings in recommendations | Ignore external research |

## Red Flags

| Rationalization | Reality |
|---|---|
| "I already know what they want" | Your assumption is the spec's biggest blind spot |
| "This is too simple to need an interview" | Simple features have the most unexamined assumptions |
| "I can infer the answers from the codebase" | Codebase shows WHAT exists, not WHAT the user wants |
| "Let me just ask all questions at once" | Batched questions get shallow answers |
| "The user seems impatient, skip some questions" | Skipping costs more in rework than asking costs now |
| "I don't need to research first" | You'll ask questions whose answers are in the docs |
| "Skip research, just use what I know" | Your training data is stale. Research current state. |

## Common Mistakes

- Asking questions the codebase already answers (didn't do Phase 2)
- Skipping external research (missed modern approaches, known pitfalls)
- Batching multiple questions in one message (shallow answers)
- Writing plan without the plan template (implementer gets incomplete context)
- Not presenting research findings before questions (user can't make informed decisions)
- Exiting plan mode before writing spec (if "Both" was chosen)
