#!/usr/bin/env bash
# index.json generator (architecture.md §9).
#
# The canonical path is `skillrig index --out index.json` (the binary walks
# SKILL.md frontmatter with the same skillcore parser used by add/verify/search,
# so values can never diverge — AP-04).
#
# This script is the FALLBACK for environments where the binary is not yet
# available. It uses `yq` (YAML processor) to read SKILL.md frontmatter.
# Requires: yq v4+ on PATH. Emits to stdout.
set -euo pipefail

CONV=$(grep -E '^convention_version' .skillrig-origin.toml | sed -E 's/[^0-9]//g')
ORIGIN=$(grep -E '^origin\s*=' .skillrig-origin.toml | sed -E 's/.*=\s*"(.*)".*/\1/')

printf '{\n  "skillrigConvention": %s,\n  "origin": "%s",\n  "skills": [\n' "$CONV" "$ORIGIN"

first=1
for skill_md in skills/*/SKILL.md; do
  dir=$(dirname "$skill_md")

  name=$(yq eval '.name'                           "$skill_md" 2>/dev/null || echo "")
  ver=$(yq eval '.metadata["x-skillrig.version"]' "$skill_md" 2>/dev/null || echo "")
  ns=$(yq eval '.metadata["x-skillrig.namespace"]' "$skill_md" 2>/dev/null || echo "")
  desc=$(yq eval '.description'                    "$skill_md" 2>/dev/null || echo "")

  # topics: emit as a JSON array
  topics_json=$(yq eval -o=json '.metadata["x-skillrig.topics"]' "$skill_md" 2>/dev/null || echo "[]")
  [[ "$topics_json" == "null" ]] && topics_json="[]"

  [[ $first -eq 1 ]] || printf ',\n'
  first=0
  printf '    { "name": "%s", "version": "%s", "namespace": "%s", "description": "%s", "topics": %s, "path": "%s" }' \
    "$name" "$ver" "$ns" "$desc" "$topics_json" "$dir"
done

printf '\n  ]\n}\n'
