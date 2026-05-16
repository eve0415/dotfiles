---
name: interview
description: Use when requirements are unclear or incomplete for a new feature, project change, or implementation. Also use when the user says "interview me", "spec this out", "let's plan this", or when structured elicitation is needed before design work begins.
---

# Interview

Goal-driven requirements elicitation through codebase research, external research, and relentless depth probing. Defines a verifiable end state first, then works backward to requirements. Produces an implementation plan with phased tasks and a ready-to-paste `/goal` condition, or official documentation, or both.

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

### Phase 4: Goal Definition

Collaboratively define the verifiable end state with the user. Research findings from Phases 2-3 inform what's achievable.

- Ask the user: "What does done look like?" Frame it as a measurable outcome.
- Draft an initial `/goal` condition (≤4000 chars) with:
  - One measurable end state (a test result, build exit code, file state)
  - A stated check (how to prove completion — e.g., "`cargo test` exits 0")
  - Constraints (what must NOT change — e.g., "no existing tests broken")
- Present the draft `/goal` condition to the user for refinement
- The goal shapes which interview branches get priority and depth

**Output:** A prose goal description AND a draft `/goal` condition. Both will be refined as technical decisions resolve in Phase 5.

### Phase 5: Interview Loop

Build a question tree working backward from the goal. Walk branches in order of relevance to the goal — branches that directly impact goal achievement come first.

**Rules:**
- One question at a time via AskUserQuestion (never batch multiple questions)
- Always provide a recommended answer with reasoning (cite research when relevant)
- Multiple choice preferred when options are clear, open-ended when not
- Never ask what the codebase or research already answered
- Walk every branch of the design tree — all mandatory, ordered by goal relevance:
  - Technical implementation (architecture, data flow, APIs)
  - UX (output format, user interaction, error messages)
  - Tradeoffs (performance, complexity, maintainability)
  - Edge cases (failure modes, concurrent access, empty/missing state)
  - Dependencies (ordering, external systems, backward compatibility)
  - Error handling (degradation, recovery, user-facing diagnostics)
  - Testing strategy (unit tests, integration tests, test infrastructure)
  - **Goal condition** (refine the /goal condition as decisions resolve — update the check command, constraints, and end state to reflect technical choices made)
  - **Verification strategy** (how to verify end-to-end after implementation — exact commands, expected output, manual checks)
  - **Review criteria** (which review dimensions matter — security, performance, accessibility, architecture — and what specifically to check)
  - **Acceptance criteria** (definition of done — must-haves vs follow-ups, what the user will check before approving)
- Resolve dependencies between decisions one-by-one
- A branch is **resolved** when the user has made a concrete decision for every sub-topic in it — no open questions, no "TBD," no deferred choices. If a branch has only one obvious answer confirmed by codebase/research, state the answer and move on (don't ask what's already known).
- Continue relentlessly until all branches are resolved — do not stop early

### Phase 6: Design Synthesis

- Propose 2-3 approaches with trade-offs, informed by research findings
- Lead with your recommendation and explain why
- For each alternative: 1-2 sentences on why it was rejected (this feeds the plan's Design Rationale section)
- Present design section by section, get user approval on each
- Revise sections the user pushes back on before moving forward

### Phase 7: Terminal Choice

Ask the user via AskUserQuestion:
- **Option A: "Implement with /goal"** (Recommended) — Write implementation plan, then ExitPlanMode with the `/goal` condition so the implementer can run autonomously. The exit message includes: the plan file path, the finalized `/goal` condition ready to paste, and a note that the user can run `/goal <condition>` to start.
- **Option B: "Implement manually"** — Write implementation plan, ExitPlanMode normally. The implementer works through phases step by step.
- **Option C: "Write official spec"** — Produce git-tracked documentation.
- **Option D: "Both spec and implementation"** — Write spec first, then implementation plan.

### Phase 8: Write Spec (if Option C or D)

- Ask: audience (developer / end-user / both) and output path (default: `docs/specs/<name>.md`)
- Format for the chosen audience
- Write the git-tracked spec file
- If Option D, continue to Phase 9

### Phase 9: Implementation Plan (if Option A, B, or D)

Write a self-contained implementation plan to the system plan file using the template in `plan-template.md` in this skill's directory.

**Critical:** The user clears conversation context after plan mode. The plan file is the ONLY context the implementer will have. It must include full context, architecture, research findings, the /goal condition, design rationale, all tasks organized into phases with actual code, and which skills to invoke during implementation and review.

**All template sections are mandatory** — Goal, Context, Research Findings, Architecture, Design Rationale, Skills Reference, Implementation Phases, Verification, Review Checklist. Do not skip or stub any section. Fill Verification and Review Checklist with project-specific content gathered during the interview, not generic boilerplate.

- Self-review before writing: spec coverage, placeholder scan, type/name consistency, **verify all template sections present with project-specific content**
- Write to system plan file (`.claude/plans/<name>.md`)
- ExitPlanMode for user review. If Option A was chosen, include the `/goal` condition in the exit message.

## Question Design

| Do | Don't |
|---|---|
| Ask about tradeoffs and constraints | Ask what's already in the codebase |
| Provide recommended answer with reasoning | Ask without a suggested direction |
| One question per message | Batch 3 questions in one message |
| Ask about edge cases and error handling | Only ask about the happy path |
| Walk branches in goal-relevance order | Jump between unrelated topics |
| Cite research findings in recommendations | Ignore external research |
| Refine /goal condition as decisions resolve | Leave the goal vague or unmeasurable |

## Red Flags & Common Mistakes

| Rationalization | Consequence |
|---|---|
| "I already know what they want" | Your assumption is the spec's biggest blind spot |
| "This is too simple to need an interview" | Simple features have the most unexamined assumptions |
| "I can infer the answers from the codebase" | Codebase shows WHAT exists, not WHAT the user wants |
| "Let me just ask all questions at once" | Batched questions get shallow answers — one at a time |
| "The user seems impatient, skip some questions" | Skipping costs more in rework than asking costs now |
| "Skip research, just use what I know" | Training data is stale. Research current state first. |
| "The goal is obvious, skip definition" | Vague goals produce vague plans. Define it explicitly. |

**Process mistakes:**
- Writing plan without the plan template (implementer gets incomplete context)
- Not presenting research findings before questions (user can't make informed decisions)
- Exiting plan mode before writing spec (if "Both" was chosen)
- Not refining /goal condition as technical decisions resolve (stale goal)
- Writing flat tasks instead of phased implementation (no parallelization or gates)
