---
name: terraform-plan-review
description: Review a terraform plan for risk and drift before apply, flagging destructive changes, IAM/security-policy edits, and resources that will be replaced rather than updated.
license: Proprietary
metadata:
  x-skillrig.namespace: my-org
  x-skillrig.version: "1.4.0"
  x-skillrig.convention-version: "1"
  x-skillrig.topics: [platform-team, terraform, aws]
  x-skillrig.requires:
    - tool: oxid
      version: ">=0.4.0"
      source: my-org/my-skills
      manager: mise
    - tool: terraform
      version: ">=1.6"
      source: hashicorp/terraform
      manager: mise
---

# Terraform Plan Review

Use this skill when a user asks you to review, sanity-check, or assess the risk
of a `terraform plan` (or `terraform show -json <planfile>`) before they apply.

## When to use

- The user pastes plan output, points you at a saved plan file, or asks
  "is this plan safe to apply?"
- A CI job wants a structured risk summary of a plan diff.

## Prerequisites

This skill depends on the following backing CLIs (declared in the SKILL.md frontmatter):

- `terraform >= 1.6` — to produce machine-readable plan JSON.
- `oxid >= 0.4.0` — the org's plan-risk analyzer (built in this origin's `cmd/`).

Run `skillrig verify` (or `skillrig doctor`) in the consuming repo to confirm
both are present, version-satisfied, and authenticable before relying on this
skill.

## Procedure

1. Obtain machine-readable plan JSON:
   ```sh
   terraform show -json plan.tfplan > plan.json
   ```
2. Run the analyzer:
   ```sh
   oxid review --plan plan.json
   ```
3. Summarize for the user, grouped by severity:
   - **Destroy / replace** — resources being deleted or recreated (data loss risk).
   - **Security-sensitive** — IAM, security groups, public-access, KMS, secrets.
   - **Drift** — attributes changing that the user did not intend.
   - **Benign** — tag-only / no-op / in-place safe changes.
4. State an explicit recommendation: apply, apply-with-caution, or do-not-apply,
   with the specific resources driving that call.

## Output contract

Always end with a one-line verdict the user (or CI) can act on, e.g.
`VERDICT: do-not-apply — 2 destructive changes to production data stores`.
