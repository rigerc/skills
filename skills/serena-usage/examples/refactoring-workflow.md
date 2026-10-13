# Serena Refactoring Workflow: Rename Class and Method

This example illustrates Serena v2's **classic** and **REPL** styles without assuming any operation was actually executed. Use the tool/API signatures exposed by your live server. All paths and class names are illustrative.

## Goal

In a TypeScript application, rename `RecipeService` → `RecipeRepository` and `RecipeService/getAll` → `RecipeRepository/findAll`, leaving unrelated declarations untouched. Preserve tests, imports, public API compatibility where needed, and write a memory note only if requested or useful for future context.

## 1. Verify Environment and Scope

- Confirm Serena MCP is connected: classic tools or `serena_repl`.
- Verify the current project with `get_current_config` or `s.cfg.get_current_config()` (when present).
- If no active project, use an enabled activation tool or restart/configure the server with `--project /path/to/repo`.
- Check `git status --short`; avoid overwriting existing user edits.
- Read only relevant memories (e.g., architecture notes) if available, following `memory_maintenance` conventions.

**Do not call** the removed `check_onboarding_performed` tool: v2 normally detects onboarding based on existing project memories.

## 2. Locate the Symbol and Its Call Sites

### Classic tools (conceptual syntax)

```text
get_symbols_overview(relative_path="src/services/RecipeService.ts", depth=1)
find_symbol(name_path_pattern="RecipeService", relative_path="src/services/RecipeService.ts", include_body=False)
find_symbol(name_path_pattern="RecipeService/getAll", relative_path="src/services/RecipeService.ts", include_body=True)
find_referencing_symbols(name_path_pattern="RecipeService", relative_path="src/services/RecipeService.ts")
find_referencing_symbols(name_path_pattern="RecipeService/getAll", relative_path="src/services/RecipeService.ts")
```

Review actual references and the code/exports. The symbol path may differ by language-server backend. Check file names, import paths, string-based references, test fixtures and generated API bindings separately.

### REPL (`serena_repl` MCP tool)

```python
config = s.cfg.get_current_config()
result = s.lsp.find_symbol("RecipeService", depth=1)
print([symbol.name for symbol in result.symbols])
```

This is a read-only LSP example. Obtain **the exact calling conventions** for `s.lsp.find_referencing_symbols` and `s.lsp.rename_symbol` using `s.info(...)`, then inspect references before editing. Use `s.jb` / `s.ide` when configured for those backends, rather than trying to call `s.lsp` unconditionally.

## 3. Rename Semantically, Not Textually

In classic-tool mode call the live `rename_symbol` tool on the **specific** class definition using its actual required parameters. Then locate the method under the renamed class and rename it semantically. In REPL use the enabled `s.lsp.rename_symbol` (or IDE equivalent) after inspecting its signature.

**Why:** semantic rename attempts to update declarations and statically resolvable usages. `replace_symbol_body` only replaces the definition/body and is the wrong operation for renaming callers. A broad `rg` + find-and-replace can corrupt unrelated names.

If the file is named after the class, rename that file separately when the backend does not do so and repair/check import specifiers. Check external references, serialized names, documentation, reflection and runtime dependency injection manually.

If the target is a public API, make the compatibility/major-version policy explicit before renaming; consider a temporary backward-compatibility alias if required.

## 4. Confirm the Intended Diff

```bash
git diff --check
git diff -- src/services src/controllers src/routes tests
rg -n 'RecipeService|getAll|RecipeRepository|findAll' src tests
```

Adapt the paths to folders that exist. Re-query old/new symbols with Serena and verify the unrelated similarly named symbol has not changed. A *missing* reference in a semantic query is not proof that no dynamic/string usage remains.

## 5. Validate Behavior

Run the repository's actual supported test/build scripts after inspecting `package.json` (examples only):

```bash
npm run typecheck    # if available
npm test             # if available
npm run lint         # if available
```

Check Serena diagnostics for affected files, when enabled. Report which commands ran, failures and outstanding verification gaps. Do not claim success based only on a Serena tool's result message.

## 6. Write Durable Memory (Optional)

After tests/diff review and subject to user permissions, inspect existing memories and add one concise, factual note to a relevant architecture memory. Example content:

```markdown
## Repository abstraction

- The recipe data-access class is now `RecipeRepository`.
- The list method is `findAll`; previous callers were updated.
- Verified with [actual test/typecheck command and outcome].
```

Use the active `edit_memory`/`s.mem.edit_memory` **pattern-based** API, not outdated `name`/`content` parameters. For new memories, first follow the active project's `memory_maintenance`. Add `` `mem:...` `` links only to actual memory targets.

## Acceptance Criteria

- Active project and exact symbol/path verified.
- Reference-impact analysis done before edits.
- Class/method imports and call sites updated or intentionally retained for compatibility.
- Diff contains no unrelated changes; tests/diagnostics executed or exceptions documented.
- No destructive memory changes without authorization; links checked if they changed.
