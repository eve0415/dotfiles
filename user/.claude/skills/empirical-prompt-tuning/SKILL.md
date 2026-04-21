---
name: empirical-prompt-tuning
description: A method for iteratively improving agent-facing text instructions (skills, slash commands, task prompts, CLAUDE.md sections, code-generation prompts) by having a bias-free executor run them and evaluating from both sides — the executor's self-report plus instruction-side metrics. Iterate until improvement plateaus. Use immediately after creating or significantly revising a prompt or skill, or when you suspect the cause of unexpected agent behavior is ambiguity on the instruction side rather than the executor.
---

# Empirical Prompt Tuning

Prompt quality is invisible to its author. The clearer it feels to the writer, the more likely a different agent will stall on it. The core of this skill: **have a bias-free executor actually run the prompt, evaluate from both sides, and iterate until improvement plateaus.** Don't stop early.

## When to use

- Right after creating or significantly revising a skill, slash command, or task prompt
- When an agent isn't behaving as expected and you want to attribute the cause to ambiguity on the instruction side
- When hardening a high-importance prompt (a frequently-used skill, a core automation prompt)

When NOT to use:
- One-off throwaway prompts (evaluation cost isn't worth it)
- When the goal is to satisfy your subjective preferences rather than improve success rate

## Workflow

0. **Iteration 0 — description vs body integrity check** (static, no dispatch needed)
   - Read the triggers / use cases the frontmatter `description` advertises
   - Read what the body actually covers
   - If they diverge, align description and body before iter 1
   - Example: `description` claims "navigation / form filling / data extraction" but the body is just `npx playwright test` CLI reference — flag the mismatch
   - Skip this and the subagent will reinterpret the body to match the `description`, hiding the gap (false positive)

1. **Baseline setup**: lock the target prompt and prepare two artifacts.
   - **Evaluation scenarios** — 2 to 3 (one median + 1-2 edge cases). Use realistic tasks that actually exercise the prompt's intended use.
   - **Requirements checklist** (for accuracy calculation). For each scenario, list 3-7 items the deliverable must satisfy. Accuracy % = items satisfied / total items. Lock these up front (don't move them later).

2. **Bias-free read**: have a "blank slate" executor read the prompt. **Dispatch a fresh subagent via the `Agent` tool**. Don't use self-rereading (you cannot structurally view your own freshly-written text objectively). For multiple scenarios in parallel, place several `Agent` calls in a single message. For environments where dispatch isn't possible, see "Environment constraints" below.

3. **Execute**: pass the subagent a prompt following the **subagent invocation contract** (defined below). The executor produces output and returns a self-report at the end.

4. **Dual-sided evaluation**: from the returned result, record:
   - **Executor self-report** (extracted from the subagent's report body): unclear points, judgment calls the executor had to fill in, places the template fell short
   - **Instruction-side measurements** (judgment rules defined here once; other sections refer back):
     - Success / failure: success (○) only when **all `[critical]`-tagged requirements** are ○. Even one × or partial → failure (×). Two-valued labels only.
     - Accuracy (% of requirements checklist met. ○ = full, × = 0, partial = 0.5; sum / total items)
     - Step count (`tool_uses` from the `Agent` tool's usage metadata, used as-is. Includes Read/Grep — don't exclude. *Field names depend on Claude Code version; treat as "tool-call count".*)
     - Duration (`duration_ms` from `Agent` usage metadata. *Same caveat — treat as "wall-clock duration".*)
     - Retry count (how many times the subagent reattempted the same decision. Extracted from self-report; instruction side cannot measure.)
     - **On failure, add a one-line entry "which `[critical]` item failed" to the "unclear points" section** for traceability.
   - The requirements checklist must include **at least one `[critical]` tag** (zero criticals → vacuous success). Don't add or remove `[critical]` tags after the fact.

5. **Patch**: apply the minimum modification that closes the unclear point. **One theme per iteration** (related multi-line edits OK; unrelated edits go to the next iteration).
   - **Before patching, state explicitly which checklist item or judgment-criteria text the patch is addressing.** Patches inferred from axis names alone often miss (see "Patch propagation patterns" below).

6. **Re-evaluate**: dispatch a *new* subagent and run 2 → 5 again. (Don't reuse the same agent — it has learned from the previous iteration.) Increase parallel scenario count if iterations stop yielding improvement.

7. **Convergence check**: stop when "two consecutive iterations with zero new unclear points AND metric improvements below threshold" (defined below). For high-importance prompts, require three consecutive.

## Evaluation axes

| Axis | Source | Meaning |
|---|---|---|
| Success / failure | Did the executor produce the intended deliverable (binary) | Floor |
| Accuracy | What % of requirements the deliverable meets | Degree of partial success |
| Step count | Number of tool calls / decision steps the executor used | Indicator of wasted instruction surface |
| Duration | Executor's `duration_ms` | Proxy for cognitive load |
| Retry count | How many times the same decision was redone | Signal of instruction ambiguity |
| Unclear points (self-report) | Executor's bullet list | Qualitative material for improvement |
| Judgment fills (self-report) | Decisions the instruction left open | Surfaces implicit spec |

**Weighting**: qualitative (unclear points, judgment fills) primary; quantitative (time, step count) secondary. Chasing time-savings alone produces anorexic prompts.

### Qualitative interpretation of `tool_uses`

Looking at accuracy alone hides skill-level structural problems. `tool_uses` used as **a relative value across scenarios** reveals structural defects:

- If one scenario's `tool_uses` is **3-5× higher** than the others, the skill is **decision-tree-index-shaped, not self-contained**. The executor is being forced into references descent.
- Typical example: every scenario at `tool_uses` 1-3 except one at 15+ → no recipe in the skill body covers that scenario; the executor is grepping references/.
- Fix: in iter 2, add an inline minimal complete example or a "when to read references" guideline at the top of SKILL.md. `tool_uses` drops dramatically.

Even at 100% accuracy, an outlier `tool_uses` justifies iter 2. "Stop early because accuracy is fine" misses structural defects.

### Patch propagation patterns (conservative / overshoot / zero)

Patch → effect is not linear. Three pre-estimate outcomes are possible:

- **Conservative** (estimate > measured): aimed at multiple axes with one patch but only one moved. "Multi-axis aim usually misses."
- **Overshoot** (estimate < measured): one structural piece (e.g., a command + config + expected-output combo) hit multiple judgment lines at once. "Information combos hit multiple axes structurally."
- **Zero** (estimate > 0, measured = 0): a patch inferred from the axis name didn't reach any of the judgment-criteria text. "Axis names and judgment text are different things."

To stabilize this, **before patching, have the subagent verbalize which judgment-criteria text the patch satisfies.** Without binding to threshold-text level, estimate accuracy doesn't materialize. When introducing a new evaluation axis, also concretize each scoring point's criteria to the threshold-text level (e.g., "all-explicit," "minimum runnable configuration in full" — at a granularity where the subagent can tell what gets a 2-point score).

## Subagent invocation contract

The prompt to the executor takes this structure. This is the input contract for "dual-sided evaluation."

```
You are an executor reading <target prompt name> with no prior context.

## Target prompt
<full body of the target prompt, or a Read path to feed it>

## Scenario
<one paragraph describing the scenario's situation>

## Requirements checklist (what the deliverable must satisfy)
1. [critical] <floor item>
2. <regular item>
3. <regular item>
...
(Judgment rules are defined once in "Workflow 4. Dual-sided evaluation / Instruction-side measurements." [critical] minimum 1 required.)

## Task
1. Follow the target prompt to execute the scenario and produce the deliverable.
2. On exit, return using the report structure below.

## Report structure
- Deliverable: <output or execution summary>
- Requirements met: ○ / × / partial (with reason) per item
- Unclear points: passages where you stalled or wording that left you uncertain (bullet list)
- Judgment fills: places not specified by the instruction that you decided yourself (bullet list)
- Retries: how many times you redid the same decision and why
```

The caller extracts the self-report sections, pulls `tool_uses` / `duration_ms` from the `Agent` tool's usage metadata, and fills in the evaluation table.

## Environment constraints

In environments where you can't dispatch a fresh subagent (you're already running as a subagent, the `Agent` tool is disabled, etc.), this skill **does not apply**.
- Alternative 1: ask the parent session's user to launch a separate Claude Code session and run the eval there.
- Alternative 2: skip the evaluation and report explicitly to the user: "empirical evaluation skipped: dispatch unavailable."
- **NOT acceptable**: fall back to self-rereading (bias-contaminated; the eval result cannot be trusted).

**Structural-review mode**: If you only want to check **textual consistency and clarity** of a skill or prompt (not run an empirical evaluation), explicitly invoke this as structural-review mode. In the subagent's prompt, write "this is structural-review mode: text consistency check, not execution." This lets the subagent skip the environment-constraint section's skip behavior and return a static review. Structural review is supplementary to empirical (cannot be used for consecutive-clear convergence judgment).

## Stopping criteria

- **Converged (stop)**: two consecutive iterations meet **all** of:
  - New unclear points: 0
  - Accuracy improvement vs. previous: ≤ +3 points (e.g., 5% → 8% saturation)
  - Step count change vs. previous: within ±10%
  - Duration change vs. previous: within ±15%
  - **Overfit check**: at convergence, add 1 hold-out scenario that hasn't been used yet and re-evaluate. If accuracy drops 15+ points from the recent average, you've overfit. Go back to baseline scenario design and add edge cases.
- **Diverged (suspect the design)**: 3+ iterations with no reduction in new unclear points → the prompt's design itself may be wrong. Stop patching, restructure.
- **Resource cutoff**: when importance no longer justifies the improvement cost, stop (the "ship at 80" call).

## Presentation format

Each iteration is recorded and presented to the user in this form:

```
## Iteration N

### Changes (diff from last iteration)
- <one-line patch description>

### Results (per scenario)
| Scenario | Success/Failure | Accuracy | steps | duration | retries |
|---|---|---|---|---|---|
| A | ○ | 90% | 4 | 20s | 0 |
| B | × | 60% | 9 | 41s | 2 |

### Unclear points (new this iteration)
- <Scenario B>: [critical] item N failed — <one-line cause>   # always add on failure
- <Scenario B>: <other observation, one line>
- <Scenario A>: (none new)

### Judgment fills (new this iteration)
- <Scenario B>: <what was filled in>

### Next patch
- <minimum patch, one line>

(Convergence: X consecutive clears so far / Y more to stopping criterion)
```

## Red flags (rationalizations to watch for)

| Surfacing rationalization | Reality |
|---|---|
| "I can re-read it myself for the same effect" | You cannot "objectively view" text you just wrote. Always dispatch a new subagent. |
| "One scenario is enough" | One scenario overfits. Minimum 2, ideally 3. |
| "Zero unclear points appeared once, so we're done" | Could be coincidence. Confirm with two consecutive clears. |
| "Let's fix all the unclear points at once" | You can't tell what worked. One theme per iteration. |
| "Even tightly-related micro-fixes go in separate iterations" | The opposite trap. "One theme" is meaning-level. 2-3 related micro-fixes can ship together. Splitting too finely explodes iteration count. |
| "Metrics are good, ignore qualitative feedback" | Time-savings can also signal an anorexic prompt. Qualitative primary. |
| "Faster to rewrite from scratch" | Correct answer iff 3+ iterations show no reduction in unclear points. Before that, it's avoidance. |
| "Reuse the same subagent" | It's learned the previous improvement. Dispatch fresh every time. |

## Common failures

- **Scenarios too easy / too hard**: either way, no signal. One median scenario from real use, one edge case.
- **Metrics-only attention**: chasing time-savings alone strips important explanations and makes the prompt brittle.
- **Too many changes per iteration**: you can't trace which change had which effect. One patch per iteration.
- **Tuning the scenario to the patch**: making the scenario easier to "make unclear points go away" — defeats the purpose.

## Related

- `superpowers:writing-skills` — TDD approach to skill creation. Same essence as this skill's "subagent baseline → patch → re-run" loop.
- `retrospective-codify` — fixing learnings post-task. This skill runs *during* prompt development; retrospective-codify runs after task completion.
- `superpowers:dispatching-parallel-agents` — etiquette for running multiple scenarios in parallel.
