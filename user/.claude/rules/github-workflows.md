---
description: Enforce GitHub Actions workflow conventions — permissions, formatting, SHA pinning
paths:
  - ".github/workflows/*.yaml"
  - ".github/workflows/*.yml"
---

# GitHub Workflows

## Permissions

Every job must have an explicit `permissions:` block. Never rely on top-level or default permissions.

## Formatting

- Blank line between each top-level key (`name:`, `on:`, `env:`, `concurrency:`, `jobs:`, etc.)
- Blank line between each job
- Blank line between each step
- Every step must have a `name:` field

## Action Pinning

Reference actions by full commit SHA with the version tag in a trailing comment:

```yaml
uses: actions/checkout@de0fac2e4500dabe0009e67214ff5f5447ce83dd # v6.0.2
```

Never use tag-only references like `@v4` or `@main`.

## SHA Lookup

Before writing any `uses:` line, look up the latest version and SHA. Never use memorized versions — they go stale.

1. Find the latest release tag:
   ```sh
   gh release list --repo {owner}/{repo} --limit 1 --json tagName -q '.[0].tagName'
   ```

2. Resolve the tag to a commit SHA:
   ```sh
   gh api repos/{owner}/{repo}/commits/{tag} --jq '.sha'
   ```

Do this for every `uses:` line, even if you just looked up the same action moments ago.
