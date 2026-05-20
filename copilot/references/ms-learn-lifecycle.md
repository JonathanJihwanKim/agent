# Power BI content lifecycle & PR review — canonical reference

Source: https://learn.microsoft.com/en-us/power-bi/guidance/powerbi-implementation-planning-content-lifecycle-management-develop-manage (updated 2026-01-02)

This is Microsoft's official guidance on developing Power BI content with version control, including what a "good" PR review looks like. The reviewer should treat this as the highest-level rubric.

## Why this skill exists, in Microsoft's words

> *"You want to automate certain processes, such as scanning metadata for best practice violations before publishing content."*

That is exactly the job.

## Microsoft's PR review guidance

> *"Pull request reviews are important to ensure creators adhere to organizational standards and practices for development, quality, and compliance."*

When reviewing PRs to Power BI content, consider:

- **Standards and practices** — *"you can use rules from the Best Practice Analyzer for semantic models."* The reviewer's BPA pass implements this.
- **Merge conflict resolution** — see `ms-learn-fabric-git.md`.
- **Commit messages and batching** — *"Technical owners can more easily review pull requests from content creators if changes are batched appropriately and have clear commit messages."* The reviewer should flag PRs that bundle unrelated concerns (semantic-model rewrite + report cosmetic tweak in one branch).

## Recommended file-format choices (relevant to this skill)

Microsoft recommends:

- `.pbip` over `.pbix` whenever Git is involved.
- **TMDL** over `.bim` (TMSL) for semantic models.
- **PBIR** over PBIR-Legacy (`report.json`) for reports — already auto-on in the Service as of Jan 2026.

A PR that downgrades any of these (e.g., reverts TMDL to a single `.bim`) is a **🔴 Blocker** with no functional reason in 2026.

## Environment separation

> *"The content creator deploys their solution to an isolated workspace for their development... successful merge triggers deployment of the solution to a development workspace... Users test and validate content in the test workspace... view content that's published to the production workspace."*

The reviewer should not enforce environment separation directly (that's deployment-pipeline territory) but should flag changes that **only make sense in dev** appearing in a PR aimed at `main` — e.g.:

- Hardcoded test-data connection strings in `dataSources.tmdl`.
- Visible measures named `[temp]`, `[debug]`, `_test_`.
- Pages named `Sandbox`, `WIP`, etc., still visible (not hidden).

## What manual review still has to do

BPA + structural checks catch maybe 70% of issues. The reviewer should also surface as **🔵 questions** anything that touches:

- **DAX semantics** — a measure expression that compiles but may not mean what the author thinks. The reviewer cannot prove correctness; it should ask.
- **RLS filter logic changes** — security-sensitive, requires human sign-off.
- **Data source connection changes** — could silently retarget production data.
- **Relationship cardinality or direction changes** — fundamental model behavior.

## Source-control benefits the reviewer should preserve

Per MS Learn, version control gives:

- Merge from multiple creators with conflict handling.
- Identification of which content changed.
- Linking changes to work items.
- Grouping changes into releases.
- Roll back individual versions.

If a PR is too large to roll back atomically (e.g., 500 file changes touching unrelated tables), flag it as 🟡 Should-fix: "Consider splitting — this is hard to roll back."
