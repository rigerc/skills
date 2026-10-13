<!--
In this origin, "publishing a skill" = opening this PR (architecture.md §2b).
The `lint` check below is REQUIRED and gates objective format conformance.
-->

## What changed

<!-- New skill? Skill edit? Backing-CLI change? Policy change? -->

## Checklist

- [ ] If adding/changing a skill: `SKILL.md` frontmatter is valid and the
      `description` is specific (vague descriptions cause agent *undertriggering*
      — the lint scores this; see architecture.md §2b).
- [ ] `skill.toml` is valid; `version` bumped if behavior changed; `tags` set.
- [ ] Any new `[[requires]]` names a real source (this origin for private CLIs,
      or an entry permitted by `policy.toml` for external ones).
- [ ] If adding a backing CLI: registered in `release-please-config.json`,
      `mise.toml` (with `tag_regex`), and `.goreleaser.yaml`.
- [ ] I did **not** hand-edit `index.json` (it regenerates on merge).

## Reviewer notes

<!-- CODEOWNERS routes this to the right approvers. Security review applies if
     policy.toml or external sources changed. -->
