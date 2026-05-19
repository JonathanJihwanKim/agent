# powerbi-pr-review

A Claude Code skill (plus two subagents) that critically reviews a Power BI pull request — locally, against the team's own main-branch conventions first, then against canonical Microsoft Learn guidance and the Tabular Editor BPA rule corpus.

## What it covers

- **TMDL** semantic-model definitions (`*.SemanticModel/definition/**/*.tmdl`)
- **PBIR** report definitions (`*.Report/definition/pages/`, `visuals/`, `bookmarks/`, `definition.pbir`)
- **PBIP project hygiene** (`.pbip` pointer file, `.gitignore`, `.pbi/` cache files)

## How it works

1. **Step 0 — detect & confirm.** The skill runs `git symbolic-ref refs/remotes/origin/HEAD` (target branch), `git symbolic-ref HEAD` (current branch), and `git for-each-ref refs/heads/` (local branches; `git worktree list` is consulted only for annotation) to figure out the **target branch** (usually `main`) and the **sub-branch** under review. It then asks one pre-filled confirmation before doing any heavy work. See [Invoking](#invoking) below.
2. The skill checks whether a team-conventions profile exists at `.claude/powerbi-conventions.md`. If not, it dispatches the **`powerbi-main-profiler`** subagent to scan the target branch and write one.
3. It then dispatches the **`powerbi-pr-reviewer`** subagent with the local diff (`git diff <merge-base>...<sub_branch>`) plus the conventions file.
4. The reviewer applies three rule passes (team conventions → MS Learn canonical → BPA) and returns a severity-grouped Markdown report.
5. Nothing is posted anywhere — the user copies/pastes the report.

## Invoking

The skill only needs branch **names** — `git diff` and `git show` work without checking out the sub-branch — so both single-clone and worktree workflows are supported:

| Where you are when you invoke | What the skill does |
| --- | --- |
| **On a feature branch** (single clone with `git checkout -b feature/x`, or inside a feature worktree) | Detects `target = default branch`, `sub = current HEAD`. Asks one confirmation, then proceeds. |
| **On the default branch** (`HEAD = main`/`master`) with other local branches present | Lists every local non-default branch (annotating any that are checked out in a worktree) and asks which one to review against the default. |

You can also name both branches explicitly in the trigger — e.g. *"review feature/x against develop"* — and the skill skips the confirmation entirely. Out of scope for v1: remote-only branches with no local tracking branch — `git checkout` (or `git branch <name> origin/<name>`) first.

## v1 scope

- Local branch diffs only (no `gh pr` or `az repos pr` integration).
- TMDL + PBIR + project hygiene.
- Bundled MS Learn excerpts (in `references/`) with `WebFetch` as a fallback.
- No MCP server dependency.

## Installation

Files currently live in `d:\agent\skills\powerbi-pr-review\`. Install method (plugin marketplace, symlink, or direct copy under `~/.claude/skills/`) is being decided separately. Once decided, the canonical location will be added here.

## Known gaps

To be filled in after the first validation run.
