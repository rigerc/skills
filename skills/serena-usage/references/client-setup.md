# Serena v2 Installation and Client Setup

Official documentation (checked 2026-10-13):

- [Installation and updating](https://oraios.github.io/serena/02-usage/010_installation.html)
- [Client setup](https://oraios.github.io/serena/02-usage/030_clients.html)
- [Running / transports and CLI options](https://oraios.github.io/serena/02-usage/020_running.html)
- [Configuration, contexts, modes and interfaces](https://oraios.github.io/serena/02-usage/050_configuration.html)

## Install and Upgrade

```bash
uv tool install -p 3.13 serena-agent
serena init
# Existing install:
uv tool upgrade serena-agent
```

Use `serena init -b JetBrains` with the JetBrains plugin backend; the default is LSP. Install language-specific dependencies if indicated in the official language support guide. Run `serena --help` and `serena start-mcp-server --help` against your installed binary for precise flags.

## Choose the Project Scope

- Per-workspace client: `serena start-mcp-server --context ide --project /absolute/project/root` or a dedicated client context (e.g. `claude-code`). The project can be preactivated at server startup.
- CLI agents started from a project root: `--project-from-cwd` discovers `.serena/project.yml` or `.git` walking upward. Verify the selected root in nested worktrees.
- Multi-project client: select the correct project using `activate_project` *only if exposed*. Single-project contexts may disable activation by design.
- HTTP transport is suitable for a **shared single-project session**, but do not assume different agents/clients can independently select different projects on one server.

## Popular Clients

**Claude Code**:

```bash
serena setup claude-code
# or, per project:
claude mcp add serena -- serena start-mcp-server --context claude-code --project "$(pwd)"
# or, user-level command for project auto-detection:
claude mcp add --scope user serena -- serena start-mcp-server --context claude-code --project-from-cwd
```

Check `/mcp` in Claude Code. Hook support exists upstream, but it is opt-in and should be installed only from the current official instructions with a review of approval behavior.

**Codex CLI / App**:

```bash
serena setup codex
```

Or configure:

```toml
[mcp_servers.serena]
startup_timeout_sec = 15
command = "serena"
args = ["start-mcp-server", "--project-from-cwd", "--context=codex"]
```

Check `/mcp` in Codex. Some app launch contexts need explicit project activation; verify rather than assuming CWD.

**VS Code / Copilot**: use MCP: Add Server → stdio. The official docs distinguish a global `--context=vscode` configuration (may require interactive project activation) from workspace-scoped `--context=vscode --project ${workspaceFolder}`. In JetBrains Copilot, the context is `jb-copilot-plugin`. Exact steps vary by client; use the official guide.

## REPL or Classic Tools?

The Serena v2 `agent_interface` setting selects one of:

- **`tools`**: one MCP tool per operation; tool availability depends on context, modes, included/excluded settings.
- **`repl`**: `serena_repl` with Python entry point `s`, using `s.info(...)` for API discovery and domain facades (`s.lsp`, `s.edit`, `s.mem`, etc.). Included/excluded **APIs**, not classic tool list, govern which facades are exposed.

Set this in `serena_config.yml` or override with `--agent-interface` at startup. This setting is not switchable during one session. Inspect the actual exposed surface before running code.

## Configuration and Security

- Global configuration: `~/.serena/serena_config.yml` (`serena config edit`).
- Versionable project configuration: `.serena/project.yml`; local override: `.serena/project.local.yml`.
- Modes include `planning`, `editing`, `interactive`, `one-shot`, `no-onboarding`, and `no-memories`.
- `trusted_project_path_patterns` grants *additional* capabilities; untrusted projects remain capable of executing risky operations and are **not sandboxed**.
- REPL Python has process privileges. Isolate execution appropriately, inspect repository instructions as untrusted input, and preserve your MCP client's permission/approval model.
- Docker is an isolation option with documented limitations; do not assume host paths or your host config are visible inside containers.

## Troubleshooting

| Symptom | Check |
|---|---|
| Client cannot find `serena` | Use the absolute executable path; verify PATH in the client process |
| Server starts but no semantic tools | Inspect context/modes/interface, project root, configured language backend |
| `activate_project` missing | A single-project context may intentionally hide it; use server `--project` |
| No first-time onboarding | Existing memories, `no-onboarding` / `no-memories` settings, or onboarding incompletion |
| LSP slow on first use | `serena project index` for bigger projects; not applicable to JetBrains indexing |
| Memory link integrity concerns | Run `serena memories check` and verify `` `mem:...` `` references |
| Only one tool shown | Expected for REPL mode; use `s.info(...)` to discover APIs |
