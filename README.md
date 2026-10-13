# my-org/my-skills — a skillrig origin

> This repository was created from the **skillrig origin template**. It is your
> organization's private **origin**: the source of truth for the agent skills
> your teams consume, *plus* the private backing CLIs those skills depend on,
> all governed as one monorepo. See `architecture.md` §1–§2d in the skillrig
> project for the full design rationale.

The generic `skillrig` binary (fetched separately via curl/mise) is pointed at
this repo and operates **on** it. Nothing about skillrig's own internals lives
here — only your skills, your CLIs, and the conventions the binary depends on.

---

## What this repo is

A single Go module that co-locates two kinds of artifact:

```
.
├── cmd/                      # your private backing CLIs (built + released here)
│   └── oxid/                 #   a skill's `requires.tool = "oxid"` resolves to THIS
├── skills/                   # your agent skills
│   └── terraform-plan-review/
│       ├── SKILL.md          #   agent-facing instructions (vendors to consumers)
│       └── skill.toml        #   machine-facing manifest; [[requires]] may name a cmd/ CLI
├── index.json                # GENERATED discovery artifact (committed) — see workflows
├── policy.toml               # external-source allowlist (governance; v1 enforcement)
├── .skillrig-origin.toml      # the CONVENTION CONTRACT version this origin speaks
├── mise.toml                 # per-CLI tag-filtered stanzas so mise can fetch each binary
├── .goreleaser.yaml          # builds every cmd/ binary
├── release-please-config.json + .release-please-manifest.json   # per-binary release streams
└── .github/workflows/        # index regen, PR lint, release
```

The co-location is the whole point: a skill and the CLI it needs version
together, release together, and are verified together as one unit.

---

## Standing up your origin (no CLI required — git host features only)

1. **Use this template** → create a *private* repo (e.g. `my-org/my-skills`).
2. **Rename the placeholders.** Replace `my-org` / `my-skills` everywhere:
   ```sh
   ./scripts/rename-origin.sh my-org my-skills
   ```
   (Edits `.skillrig-origin.toml`, `index.json`, `policy.toml`, `go.mod`,
   `mise.toml`, `release-please-config.json`, and the example skill manifest.)
3. **Set up branch protection + CODEOWNERS** — see `docs/BRANCH-PROTECTION.md`.
   This is what makes "publishing a skill = opening a PR" trustworthy.
4. **Enable immutable releases + tag protection** on the repo (Settings → see
   the same doc). The git tree SHA proves content matches its version label;
   immutable releases prove upstream can't swap it under a tag you trust.
5. **Dispatch the first release workflow** (`Actions → release → Run workflow`)
   to cut the initial `oxid-v…` / skill tags and generate `index.json`.

That's it. Consumers then run `skillrig init --origin my-org/my-skills` in their
repos (consumer-side; not this repo's job).

---

## Day-to-day

| You want to… | You do… |
|---|---|
| Publish / change a skill | open a PR to this repo — `lint` runs as a required check |
| Add a backing CLI | add `cmd/<tool>/`, register it in `release-please-config.json` + `mise.toml` |
| Release | merge the release-please PR; per-binary tags + `index.json` regen on merge |
| Approve who can merge what | `CODEOWNERS` paths + branch protection |

There is **no** publish/login/sync command and no auth surface — this repo *is*
the backend, and your git host already has the permission model.

---

## The convention contract

`.skillrig-origin.toml` declares `convention_version`. The generic `skillrig`
binary reads it (mirrored into `index.json`) and refuses to operate against an
origin whose convention it doesn't understand, rather than misbehaving silently.
Treat changes to the origin's *structure* (skill layout, index schema, tag/
version scheme, the tree-SHA boundary) as contract changes — bump the version
deliberately. See `docs/CONVENTION.md`.
