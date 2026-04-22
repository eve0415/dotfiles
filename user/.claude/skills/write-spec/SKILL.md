---
name: write-spec
description: Use when official project documentation is needed for future reference — feature specs, API docs, architecture decisions, user guides. Also use when the user says "document this", "write a spec", "write docs for", or after an interview session when the user chose official documentation as the output. For developer audience, end-user audience, or both.
---

# Write Spec

Produce official, git-tracked specification documents meant for future reference by developers or end-users. These are NOT ephemeral planning artifacts — they are project documentation.

## When to Use

- After an interview session when user chooses "Write official spec"
- Standalone: document an existing feature, API, or architecture decision
- Creating public-facing documentation (README sections, API docs, architecture guides)
- Recording design decisions for future contributors

**Skip when:** The information is ephemeral (session-only planning), already documented elsewhere, or belongs in code comments rather than a separate doc.

## Process

### Phase 1: Determine Scope

Ask via AskUserQuestion:
- What is being documented? (feature, API, architecture, user guide, decision record)
- Who is the audience? (developer / end-user / both)
- What format? (spec, RFC, guide, reference, decision record)

### Phase 2: Gather Content

**If called after an interview:** Use the design and research findings from the interview session. Supplement with additional codebase exploration if needed.

**If standalone:**
- Explore the codebase: read implementation, trace execution paths, map architecture
- Research external references: official docs, standards, best practices
- Ask clarifying questions via AskUserQuestion (one at a time, with recommended answers)

### Phase 3: Write Document

Structure for the audience:

**Developer audience:**
- Architecture overview and design rationale
- Data flow and component interactions
- API contracts (inputs, outputs, error cases)
- Configuration and environment requirements
- Extension points and integration patterns

**End-user audience:**
- Purpose and use cases (what problem does this solve?)
- Getting started / quick start
- Configuration with examples
- Common workflows with step-by-step instructions
- Troubleshooting and FAQ

**Both audiences:**
- Layered document: user-facing overview first, developer details in deeper sections
- Clear separation so each audience can find their section

### Phase 4: Output

- Ask user for output path via AskUserQuestion (default: `docs/specs/<name>.md`)
- Write the file
- Ask user to confirm before committing to git

## Common Mistakes

- Writing developer docs in developer jargon when audience is end-users
- Missing examples — every configuration option and API endpoint needs at least one
- Documenting implementation details that will rot (document WHAT and WHY, not internal HOW)
- Skipping the audience question — developer docs and user docs have completely different structures
- Not researching current state before documenting (documenting outdated behavior)
