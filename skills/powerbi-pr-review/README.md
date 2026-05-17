# powerbi-pr-review

A Claude Code skill (plus two subagents) that critically reviews a Power BI pull request — locally, against the team's own main-branch conventions first, then against canonical Microsoft Learn guidance and the Tabular Editor BPA rule corpus.

## What it covers

- **TMDL** semantic-model definitions (`*.SemanticModel/definition/**/*.tmdl`)
- **PBIR** report definitions (`*.Report/definition/pages/`, `visuals/`, `bookmarks/`, `definition.pbir`)
- **PBIP project hygiene** (`.pbip` pointer file, `.gitignore`, `.pbi/` cache files)

## How it works

1. The skill checks whether a team-conventions profile exists at `.claude/powerbi-conventions.md`. If not, it dispatches the **`powerbi-main-profiler`** subagent to scan `main` and write one.
2. It then dispatches the **`powerbi-pr-reviewer`** subagent with the local diff (`git diff <merge-base>...HEAD`) plus the conventions file.
3. The reviewer applies three rule passes (team conventions → MS Learn canonical → BPA) and returns a severity-grouped Markdown report.
4. Nothing is posted anywhere — the user copies/pastes the report.

## v1 scope

- Local branch diffs only (no `gh pr` or `az repos pr` integration).
- TMDL + PBIR + project hygiene.
- Bundled MS Learn excerpts (in `references/`) with `WebFetch` as a fallback.
- No MCP server dependency.

## Installation

Files currently live in `d:\agent\skills\powerbi-pr-review\`. Install method (plugin marketplace, symlink, or direct copy under `~/.claude/skills/`) is being decided separately. Once decided, the canonical location will be added here.

## Known gaps

To be filled in after the first validation run.
