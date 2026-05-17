# Fabric Git Integration — canonical reference

Source: https://learn.microsoft.com/en-us/fabric/cicd/git-integration/intro-to-git-integration (updated 2026-04-28)

Fabric Git integration links a **workspace** (not a repo) to a Git branch. Workspace structure including subfolders is preserved in the repo.

## Supported Git providers

- Azure DevOps (cloud-based only)
- GitHub (cloud-based only)
- GitHub Enterprise (cloud-based only)

Local Git providers are not supported at the workspace ↔ repo sync layer — but for the purposes of *this* skill, that's irrelevant: we operate entirely on local files via `git`.

## Power BI item types in scope

| Item | Status |
| --- | --- |
| Semantic model | Preview — supported (except push datasets, AS live connections, model v1) |
| Report | Preview — supported (except reports connected to AAS/SSAS or MyWorkspace-hosted models) |
| Paginated report | Preview |
| Org app | Preview |
| Metrics Set | Preview |

If the workspace has unsupported items, they're ignored — not synced and not deleted. This means a PR's diff may not reflect every change in the workspace.

## Branching workflow Microsoft recommends

Trunk-based with short-lived feature branches:

1. Feature branch cloned from `main`.
2. Developer works in their **private workspace** linked to that branch.
3. Commits + pushes to the branch.
4. **Pull request** opens to merge feature → main.
5. **Technical owner reviews + merges.**
6. Successful merge syncs `main` to the **development workspace**.
7. Azure Pipelines (or manual deploy) promote to test → production.

The reviewer in this skill plays the role of step 5's technical owner.

## Conflict resolution

- Two-way: workspace ↔ repo. If both diverge, Fabric shows conflicts in the source-control panel.
- TMDL + PBIR text formats were chosen specifically to make these conflicts mergeable.
- A conflict the reviewer should specifically watch for: stale `lineageTag` values after a manual merge — these break downstream connections.

## What this means for the reviewer

- A diff that touches a semantic model but is missing the matching `model.tmdl` `ref` line is a **half-merge** symptom.
- A diff that includes `.platform` changes is a Fabric-managed sync — usually safe but worth confirming with the user.
- Cross-workspace references (a report's `definition.pbir` pointing `byConnection` to a model in another workspace) are valid; flag only if the connection string looks malformed.

## Network security note

Workspace-level security can block outbound connections; CI/CD tools that pull from Git need to be in the allowed network boundary. Not the reviewer's job to enforce, but a note for the user if they see CI failures unrelated to code quality.
