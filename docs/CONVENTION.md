# The origin convention contract

The origin's *structural conventions* are the contract the generic `skillrig`
binary depends on (architecture.md §2d.3, R5e). This template is the **reference
implementation** of that contract. Because the binary is generic and centrally
maintained, the contract must be versioned so it can evolve without silently
breaking deployed consumers — the way Terraform pins provider schema versions.

## What the contract covers

- **Skill layout** — `skills/<name>/{SKILL.md, skill.toml}`.
- **Index schema** — `index.json` shape + the `skillrigConvention` field.
- **Tag/version scheme** — per-binary / per-skill prefixed tags (`name-vSEMVER`).
- **Fingerprint boundary** — the git tree SHA of a skill subtree (architecture.md
  §4.2) is the label-honesty primitive; *which* subtree is hashed is part of the
  contract.

## Where the version lives

- Canonically in **`.skillrig-origin.toml`** → `convention_version`.
- Mirrored into **`index.json`** → `skillrigConvention`, so a binary that has
  only fetched the index already knows the convention and can fail fast.

The binary checks this value and **fails clearly** against an incompatible
origin rather than misbehaving. (Open question: exact compatibility policy —
does a binary support conventions N and N-1? — architecture.md §12 Q14.)

## When to bump it

Bump `convention_version` only for a **structural** change to the above. Do NOT
bump it for adding skills, adding backing CLIs, or editing policy — those are
content, not contract. Treat a bump as a deliberate, reviewed event:

1. Land the structural change + the version bump together.
2. Coordinate with the skillrig binary release that understands convention N+1.
3. Note the change in this file's changelog below.

## Changelog

- **v1** — initial contract: `skills/<name>/{SKILL.md,skill.toml}`, `index.json`
  with `skillrigConvention`, `name-vSEMVER` prefixed tags, git-tree-SHA
  fingerprint boundary.
