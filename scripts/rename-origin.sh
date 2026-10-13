#!/usr/bin/env bash
# Replace the template placeholders (my-org / my-skills) with your org + repo.
# Run once right after creating a repo from this template (README step 2).
#
#   ./scripts/rename-origin.sh <org> <repo>
#   e.g.  ./scripts/rename-origin.sh acme platform-skills
set -euo pipefail

if [[ $# -ne 2 ]]; then
  echo "usage: $0 <org> <repo>" >&2
  exit 2
fi

ORG="$1"
REPO="$2"

# Files that embed the origin identity. index.json regenerates on merge, but we
# stamp it here too so the repo is coherent before the first release.
FILES=(
  README.md
  .skillrig-origin.toml
  index.json
  policy.toml
  go.mod
  mise.toml
  CODEOWNERS
  .goreleaser.yaml
  skills/terraform-plan-review/skill.toml
)

# Order matters: replace the full slug first, then the bare org token.
for f in "${FILES[@]}"; do
  [[ -f "$f" ]] || continue
  perl -pi -e "s{my-org/my-skills}{${ORG}/${REPO}}g" "$f"
  perl -pi -e "s{my-org}{${ORG}}g" "$f"
  perl -pi -e "s{my-skills}{${REPO}}g" "$f"
done

echo "Renamed origin to ${ORG}/${REPO}."
echo "Next: review CODEOWNERS teams, set branch protection (docs/BRANCH-PROTECTION.md),"
echo "then dispatch the 'release' workflow to cut the first tags + index.json."
