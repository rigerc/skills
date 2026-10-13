# Serena Memories and Onboarding (v2)

Source: [Memories & Onboarding](https://oraios.github.io/serena/02-usage/045_memories.html). Serena memories are human-readable Markdown, not an automatic record of every task. The agent receives a list of memory names and reads selected content on demand.

## Locations and Scope

| Scope | Name | Default storage |
|---|---|---|
| Project | `core`, `modules/frontend`, `memory_maintenance` | `<project>/.serena/memories/` |
| Global | `global/coding-conventions` | `~/.serena/memories/global/` |

The project directory can be relocated by Serena configuration. **Never assume** the default storage location for projects that configured `project_serena_folder_location`. Do not indiscriminately copy global memories into project-specific files.

## Current Onboarding Behavior

Serena normally detects first-time onboarding when a project has no project memories. It seeds the `memory_maintenance` memory (unless a `global/memory_maintenance` memory already defines the conventions), gathers project structure/build/test knowledge, and writes project memories. On future activations it detects existing project memories and normally skips onboarding.

Use the exposed `list_memories` / `s.mem.list_memories()` to inspect memory names; read `memory_maintenance` *before new memory writes*. A legacy `check_onboarding_performed` tool is **not** in Serena's current published tool list. If a project has sparse memories, ask whether to refresh context rather than forcibly re-onboarding or overwriting conventions. `no-onboarding` and `no-memories` modes explicitly alter this behavior.

## Naming and Structure

Prefer short names that convey content: `core`, `architecture`, `suggested_commands`, `modules/backend`. Organize with `/` topics when useful. Serena recognizes references **only** when written as an inline-code `mem:` target, e.g. `` `mem:modules/backend` ``; bare memory names do not auto-update if renamed.

Read relevant memories deliberately; avoid dumping the whole collection into an agent's context. An existing `memory_maintenance` may specify a preferred `core` entry point and split/add thresholds—follow that memory rather than prescribing a new mandatory structure.

Example project memory (illustrative):

```markdown
# API routing

- User routes live in `src/routes/users.ts`.
- Integration tests are under `tests/integration/`.
- For auth-related architecture, see `mem:architecture/auth`.
```

Use `mem:` for existing targets only and audit after refactors.

## Memory Operations

| Intent | Classic tool | REPL API |
|---|---|---|
| Enumerate | `list_memories` | `s.mem.list_memories` |
| Read | `read_memory` | `s.mem.read_memory` |
| Create | `write_memory` | `s.mem.write_memory` |
| Update exact section/pattern | `edit_memory` | `s.mem.edit_memory` |
| Rename/move and update `mem:` refs | `rename_memory` | `s.mem.rename_memory` |
| Delete | `delete_memory` | `s.mem.delete_memory` |
| Onboarding | `onboarding` (where enabled) | `s.mem.onboarding` |

Read exact tool definitions in the active host. The **current** `edit_memory` does pattern-based substitution; older snippets with only `name` and `content` are not accurate for this version. For an update, read the old memory, choose a bounded pattern, avoid broad regex replacements and verify the result afterward. Prefer the rename tool to filesystem renames so linked `mem:` references stay consistent.

**Destructive actions:** Require appropriate user approval before deleting or destructively rewriting memories; do not use deletion as a routine archive workflow. Never store private credentials, API keys, or undocumented assumptions. Global memories can be made read-only via `read_only_memory_patterns`; archived topics may be hidden with `ignored_memory_patterns` (hidden memories become inaccessible via memory tools).

## Verification and CLI

```bash
serena memories check
serena memories --help
serena memories auto-prefix-references --dry-run
```

`serena memories check` reports stale `mem:` references. The CLI supports additional memory commands but confirm their current flags via `--help`. On projects using Git, review memory edits as ordinary versioned Markdown diffs; commit only relevant, non-sensitive content.

## Backup

Use [`../scripts/serena-memory-backup.ps1`](../scripts/serena-memory-backup.ps1) for default project memory folders:

```powershell
./scripts/serena-memory-backup.ps1 -ProjectDir "C:\Projects\MyApp"
```

The helper copies **only** `.serena/memories/**` and preserves topic subdirectories in a timestamped local backup. It does not back up global memories, custom central memory locations, caches or Serena configuration. Store backup output outside Git and protect it as project context data.

## Session Continuity Checklist

1. Verify current project and read only task-relevant memories.
2. Follow `memory_maintenance` naming and update conventions.
3. Work on the code; do not record speculative decisions as settled facts.
4. Update existing relevant memories with *verified* decisions, gotchas, working commands and outstanding tasks.
5. Confirm changed memories, references, and `serena memories check` if memory links were changed.
