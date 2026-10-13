# How consumers adopt skills from this origin

This is reference for the *consumer* side. None of it runs in this repo — it
documents what teams do once your origin exists, so authors understand the
end-to-end (architecture.md §2d, §3, §5).

## 1. Bind a repo to this origin

In a consuming repo, the developer/agent runs (consumer-side only):

```sh
skillrig init --origin my-org/my-skills      # writes .skillrig/config.toml
skillrig init --global --origin my-org/my-skills   # sets their personal default
```

Origin discovery precedence (git-style, architecture.md §2d):
`SKILLRIG_ORIGIN` env > project `.skillrig/config.toml` > global default.

## 2. Vendor a skill (project scope)

```sh
skillrig search --tag platform-team      # reads this origin's index.json
skillrig add terraform-plan-review       # vendors the tree + writes the lock
```

This checks the skill into `.agents/skills/terraform-plan-review/` (canonical),
creates per-client symlink views (e.g. `.claude/skills/...`), and records a pin
in `.skillrig/skills-lock.json`: `version` + `commit` (provenance) + `treeSha`
(label honesty) + mirrored `requires` (architecture.md §3, §4.2, §6).

## 3. Verify

```sh
skillrig verify     # offline: label honesty + prereqs + no orphans → exit code
skillrig doctor     # superset: also checks prerequisite AUTH + global hints
```

`verify` recomputes each vendored subtree's git tree SHA and compares it to the
pinned `treeSha` — catching content mislabeled as a known version. It also
checks every `[[requires]]` resolves (present + version-satisfied), and refuses
to pass if the on-disk skill set ≠ the locked set (orphan protection, §9b).

## 4. Stay current

A scheduled CI job in the consumer repo runs `skillrig bump --pr`: it compares
each pinned `commit` against the latest here, re-vendors advanced skills, and
opens a reviewable PR with the tree diff + lock diff together (architecture.md
§5). Locally-modified skills are reconciled via three-way merge; conflicts fail
with standard git conflict markers to resolve (§5b). The tool proposes; the
team's branch-protection / auto-merge policy disposes.

## Global scope

`skillrig global add <skill>` fetches/materializes skills into the user's
per-environment location (not committed). A repo may *recommend* global skills
via AGENTS.md/CLAUDE.md text, never require them (architecture.md §3, §7).
