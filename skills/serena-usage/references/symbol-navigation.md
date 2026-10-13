# Symbol Navigation and Refactoring (Serena v2)

Source: [Serena Tools and APIs](https://oraios.github.io/serena/01-about/035_tools.html). Applies to the LSP backend; JetBrains/IDE backends expose equivalent operations with different names and behavior. Available functions vary by client, context and mode. Confirm the active project before any operation.

## Choose the Exposed Interface

| Goal | Classic tools | REPL facade, when enabled |
|---|---|---|
| Top-level symbol map | `get_symbols_overview` | `s.lsp.get_symbols_overview` |
| Find a symbol | `find_symbol` | `s.lsp.find_symbol` |
| Find callers/usages | `find_referencing_symbols` | `s.lsp.find_referencing_symbols` |
| Definition / implementations | `find_declaration`, `find_implementations` | `s.lsp.find_declaration`, `s.lsp.find_implementations` |
| Diagnostics | `get_diagnostics_for_file` | `s.lsp.get_diagnostics_for_file` |
| Rename symbol + usages | `rename_symbol` | `s.lsp.rename_symbol` |
| Delete if safe | `safe_delete_symbol` | `s.lsp.safe_delete_symbol` |
| Replace definition body | `replace_symbol_body` | `s.edit.replace_symbol_body` |
| Scoped text search | `search_for_pattern` | `s.fs.search_for_pattern` |
| Multi-file textual replacement | `replace_in_files` | `s.edit.replace_in_files` |

**Important:** `s.lsp` is only for the LSP backend. When an IDE backend is active, inspect `s.jb` or `s.ide`, and use the available functions. In REPL mode, call `s.info(...)` to obtain authoritative method signatures; do not assume classic-tool parameters transfer unchanged to Python calls.

## REPL Example

Submit this **inside Serena's `serena_repl` MCP tool**, not a normal Python shell:

```python
result = s.lsp.find_symbol("SerenaAgent", depth=1)
print([member.name for member in result.symbols[0].iter_children()])
```

For actual projects, first verify project config and examine results. You can compose several read-only operations in one REPL call and print a concise result; runtime return types differ from classic JSON/text tool output. Avoid printed multi-megabyte results.

## Classic Interface Patterns

Examples below illustrate the **intent and common LSP parameters**. Invoke only functions shown in the actual connected tool schema.

```text
get_symbols_overview(relative_path="src/services/RecipeService.ts", depth=1)
find_symbol(name_path_pattern="RecipeService", relative_path="src/services/RecipeService.ts", include_body=False)
find_referencing_symbols(name_path_pattern="RecipeService", relative_path="src/services/RecipeService.ts")
```

The `name_path_pattern` is a symbol name/path such as `RecipeService` or `RecipeService/getAll`, not a shell-glob language. If you do not know an exact symbol name, search by file, substring or regex first and inspect candidates. `get_symbols_overview` is file-oriented: supply a relevant source file, not an assumed directory-wide list.

## Read-Only Navigation

1. Locate likely files (path-scoped `find_file`, `list_dir` or a code-restricted `search_for_pattern`).
2. Get a symbol overview for each relevant **file**, only drilling into the required method(s).
3. Locate the precise symbol definition with `find_symbol`, read the body only when implementation details are necessary.
4. Trace direct references with `find_referencing_symbols`; trace implementations/declarations as warranted.
5. Search for indirect or dynamic usage: import strings, reflection, template names, generated bindings, tests and build config. Semantic references cannot always capture these.

## Safe Change Workflow

For semantic rename `RecipeService` → `RecipeRepository`:

1. Confirm the specific definition and the complete set of impact sites.
2. Inspect the signature of `rename_symbol` via the tool schema or `s.info(...)`; use semantic rename, not `replace_symbol_body` or unreviewed global regex replacement.
3. Preview/confirm the proposed change if offered; preserve unrelated similarly named symbols.
4. Rename the source file/import paths separately if the backend did not do so; inspect all affected imports.
5. Search for old names and check references to the new symbol, noting any intentionally retained names.
6. Run diagnostics, focused tests and `git diff --check`; review the patch for unintended changes.

For implementation-only changes use `replace_symbol_body` or precise text operations, retaining all other class members. `safe_delete_symbol` checks references but cannot prove no runtime reflection/string-based usages: verify independently.

## Common Errors

- Assuming wildcard glob patterns work in `name_path_pattern`.
- Asking for `get_symbols_overview` on an entire directory without checking the tool's file-level contract.
- Performing a class rename by replacing its whole body with placeholder methods.
- Forgetting renamed file paths, tests, type declarations or dynamically named usages.
- Treating a zero-reference result as proof the entire project builds.
- Calling `s.lsp` when Serena selected a JetBrains/IDE backend, or calling absent `serena_repl` methods without introspection.
