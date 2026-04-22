# Plan Output Template

Use this template when writing implementation plans in Phase 8. The plan is the ONLY context the implementer will have — conversation history is cleared. Every section is mandatory.

Skills referenced below are invoked via the `Skill` tool with the skill name (e.g., `Skill: verify`). Superpowers skills use the full name (e.g., `Skill: superpowers:test-driven-development`). Subagent types are dispatched via the `Agent` tool with `subagent_type`.

---

```markdown
# [Feature Name] Implementation Plan

## Context
[Full description of what's being built and why. Include all architecture
decisions made during the interview. Write for someone with zero prior
knowledge of this conversation.]

## Research Findings
[Key findings from external research. Modern approaches chosen,
standards being followed, known pitfalls to avoid. Include links
to references where relevant.]

## Architecture
[Approach, key design decisions, technology choices. 2-5 sentences.]

## Skills Reference

### During Implementation (invoke per task)

> - **TDD**: `Skill: superpowers:test-driven-development` — Test first, watch it fail, implement, watch it pass. Every task.
> - **Debugging**: `Skill: superpowers:systematic-debugging` — Invoke when ANY test fails or unexpected behavior occurs. Root cause first, no guess-and-fix.
> - **Verification**: `Skill: superpowers:verification-before-completion` — MANDATORY before claiming any task is done. Run the verification command, read the full output, THEN claim success. No "should work now."

### After All Tasks — Multi-Perspective Review

> Run ALL of these before declaring implementation complete. Each reviewer is independent — dispatch as separate subagents where applicable.
>
> 1. **Code quality** — `Skill: superpowers:requesting-code-review` — Dispatch `superpowers:code-reviewer` subagent. Check: correctness, naming, structure, test quality.
> 2. **Security** — `Skill: security-review` — Check: injection, auth bypass, secrets exposure, input validation, OWASP top 10.
> 3. **Simplification** — `Skill: simplify` — Check: dead code, unnecessary complexity, reuse opportunities, efficiency.
> 4. **CI verification** — `Skill: verify` — Run full CI suite locally (format, lint, test, snapshots). All must pass.
> 5. **Architecture** (if applicable) — Dispatch `feature-dev:code-reviewer` subagent. Check: pattern consistency, dependency direction, separation of concerns.
>
> Fix issues found by each reviewer. Re-run the reviewer after fixes to confirm resolution.

### Completion

> - `Skill: superpowers:finishing-a-development-branch` — After all reviews pass. Presents options: merge locally, create PR, keep branch, or discard.

## Tasks

### Task 1: [Name]

**Files:**
- Create: `exact/path/to/new-file`
- Modify: `exact/path/to/existing-file:line-range`
- Test: `exact/path/to/test-file`

- [ ] **Step 1: Write failing test**
  ```lang
  // actual test code here
  ```

- [ ] **Step 2: Run test, verify it fails**
  Run: `exact test command`
  Expected: FAIL with "specific error message"

- [ ] **Step 3: Write minimal implementation**
  ```lang
  // actual implementation code here
  ```

- [ ] **Step 4: Run test, verify it passes**
  Run: `exact test command`
  Expected: PASS

- [ ] **Step 5: Commit**
  ```bash
  git add specific-files
  git commit -m "feat: descriptive message"
  ```

### Task N: [Name]
[Same structure — every task has actual code, not placeholders.
No "TBD", "TODO", "add appropriate error handling", "similar to Task N".]

## Verification

[How to verify the complete implementation end-to-end.
Exact commands. Expected output. Edge cases to test manually.]

## Review Checklist

- [ ] Code quality review passed (`superpowers:requesting-code-review`)
- [ ] Security review passed (`security-review`)
- [ ] Simplification review passed (`simplify`)
- [ ] CI verification passed (`verify`)
- [ ] Architecture review passed (if applicable)
- [ ] All issues from reviews fixed and re-verified
```
