# Branch protection & supply-chain hardening

In the GitHub-authority model (architecture.md §2b), this repo's git permissions
*are* the publish/approval system. There is no registry service to configure —
you configure GitHub. Do this right after creating from the template.

## Required: branch protection on the default branch

Settings → Branches → add a rule for `main`:

- ✅ **Require a pull request before merging** — publishing a skill = a PR.
- ✅ **Require approvals** (≥1) and **Require review from Code Owners** — this is
  what makes `CODEOWNERS` paths enforce per-skill / per-CLI ownership.
- ✅ **Require status checks to pass** → select the **`lint`** check (the
  author-side format gate, architecture.md §2b). Add `verify`-style checks as
  you add them.
- ✅ **Do not allow bypassing the above** (include administrators).

## Required: tag protection

Settings → Tags (or rulesets) → protect `*-v*` tag patterns so only the release
workflow creates release tags. Prevents hand-cut tags bypassing release-please.

## Strongly recommended: immutable releases

Settings → General (or Releases) → enable **immutable releases**. Once published,
release content can't be altered even by repo admins (architecture.md §9b). This
complements skillrig's tree-SHA check:

- the **git tree SHA** proves *the content matches the version it claims to be*;
- **immutable releases** prove *upstream can't swap it under a tag you trust*.

## Recommended: secret scanning + code scanning

Enable secret scanning and code scanning on this repo (gh skill's publish-time
posture, architecture.md §9b). Skill PRs are where new content enters; scan there.

## Where scanning belongs

Any security/risk scan runs as a **required check on the skill PR** here
(publish-time, admin-controlled CI) and travels into `index.json` only as
*advisory* metadata. The consumer's `skillrig verify` never runs or depends on a
scan — it reads only the deterministic allowlist + git tree SHA (architecture.md
§2c, §9b). Keep the consumer gate offline and deterministic.
