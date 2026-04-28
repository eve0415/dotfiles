---
description: Enforce block-style YAML formatting over flow-style
paths:
  - "**/*.yaml"
  - "**/*.yml"
---

# YAML Style

Always block style. Never flow style.

- Sequences: `- item` on separate lines, never `["item1", "item2"]`
- Maps: `key: value` on separate lines, never `{key: value}`
