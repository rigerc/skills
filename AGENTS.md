# Maintainer & agent guide for this origin

This repo is a **skillrig origin**: the source of truth for the org's agent
skills and the private CLIs they depend on, governed as one monorepo. Created
from the skillrig origin template (architecture.md §2d).

## Ground rules

- **Publishing = a PR.** There is no publish/login/sync command and no auth
  surface. To add or change a skill, open a PR; CODEOWNERS + branch protection
  approve it; `lint` gates format conformance.
- **Never hand-edit `index.json`.** It regenerates on merge via
  `.github/workflows/index.yml`. Edit `skill.toml`/`SKILL.md` and let CI rebuild.
- **One Go module, many binaries.** Backing CLIs live under `cmd/<tool>/` and
  release on their own prefixed tag streams (`oxid-v*`) via release-please. When
  you add a CLI, register it in `release-please-config.json`, `mise.toml`
  (with `tag_regex`), and `.goreleaser.yaml`.
- **Co-locate skill + tool.** If a skill needs a private CLI, build that CLI here
  and point the skill's `[[requires]].source` at this origin — they version and
  release together.
- **The convention contract is load-bearing.** Don't change skill layout, the
  index schema, the tag scheme, or the tree-SHA boundary without bumping
  `convention_version` in `.skillrig-origin.toml`. See `docs/CONVENTION.md`.

## Layout

| Path | Purpose |
|---|---|
| `skills/<name>/SKILL.md` | agent-facing instructions (vendors to consumers) |
| `skills/<name>/skill.toml` | machine-facing manifest; `[[requires]]`, tags |
| `cmd/<tool>/` | private backing CLI source |
| `index.json` | generated discovery artifact (committed) |
| `policy.toml` | external-source allowlist (governance) |
| `.skillrig-origin.toml` | the convention contract version |

## Adding a skill (checklist)

1. `skills/<name>/SKILL.md` — valid frontmatter, **specific** description.
2. `skills/<name>/skill.toml` — name/version/namespace/description/tags, plus any
   `[[requires]]`.
3. Add a `CODEOWNERS` line and a `release-please-config.json` package entry.
4. Open a PR. `lint` must pass; CODEOWNERS approves; merge regenerates the index.

See `docs/ADOPTING.md` for the consumer side and `README.md` for setup.
