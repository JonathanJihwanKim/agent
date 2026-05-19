---
name: powerbi-pr-review
description: Critically review a Power BI pull request (local branch diff vs. main) against the team's own main-branch conventions, Microsoft Learn canonical guidance for PBIP / TMDL / PBIR, and Tabular Editor BPA rules. Triggers on requests like "review this PR", "review this branch", "review the Power BI changes", "what's wrong with this PR", or any review request in a directory containing a `*.pbip` pointer, a `*.SemanticModel/definition/` folder, or a `*.Report/definition/` folder. Produces a severity-grouped Markdown report with file:line citations and proposed review comments. No GitHub/ADO integration — output is rendered in chat for the user to paste.
---

# Power BI PR Review

You are the orchestrator for a critical review of a Power BI pull request. You delegate the heavy work to two subagents and stitch their output into the final report.

## Inputs (resolved from the conversation)

- **Repo root** — the working directory. Must contain a `*.pbip` file or a `*.SemanticModel/` or `*.Report/` folder.
- **Target branch** (`target_branch`) — the branch to diff against. Resolved in [Step 0](#0-detect--confirm-inputs); falls back to the repo's default branch (`origin/HEAD`) when the user didn't name one.
- **Sub-branch** (`sub_branch`) — the branch under review. Resolved in [Step 0](#0-detect--confirm-inputs) from current `HEAD` or a `git worktree list` pick.
- **Mode** — `full-review` (default), `questions-only` (only the 🔵 questions section), or `enhancements-only` (only the 💡 enhancements section).

## Workflow

### 0. Detect & confirm inputs

This skill needs three things — repo, target branch, sub-branch — and `git` already knows two. Resolve them once, up front; a wrong-branch review wastes minutes of agent work.

Read-only probes:

```powershell
git rev-parse --is-inside-work-tree
git rev-parse --show-toplevel
git symbolic-ref --short HEAD                                       # current branch (fails if detached)
git symbolic-ref --short refs/remotes/origin/HEAD                   # default branch
git for-each-ref --format='%(refname:short)' refs/heads/            # all local branches
git worktree list --porcelain                                       # worktrees + their HEADs (annotation only)
```

If `origin/HEAD` is unset, probe `main` → `master` → `develop` via `git rev-parse --verify`. If none exist, abort: "Can't determine the default branch — re-invoke with an explicit target (e.g. 'review against develop')."

The review only needs branch **names** — `git diff <target>...<sub>` and `git show <sub>:<path>` work whether or not `<sub>` is checked out in a worktree. So worktrees are an annotation, not a requirement.

Classify:

| Scenario | Pattern | Pre-filled values |
| --- | --- | --- |
| **A — on a feature branch** | `HEAD` is a branch and `HEAD ≠ default` | `target_branch = <default>`, `sub_branch = <HEAD>` |
| **B — on the default branch** | `HEAD = <default>` | `target_branch = <default>`, `sub_branch = pick one of the other local branches` (abort if none exist: "You're on `<default>` with no other local branches — create or check out the branch you want reviewed first.") |
| **C — detached or non-git** | `symbolic-ref --short HEAD` fails, or cwd is not in a git repo | Abort with the specific diagnostic. No half-guessing. |

Then ask **one** `AskUserQuestion` — always, even when Scenario A looks unambiguous. A pre-filled confirmation costs one click; running the reviewer against the wrong branch pair costs minutes.

- **Scenario A** — single question:
  > "I'll review **`<sub_branch>`** against **`<target_branch>`**. Continue?"
  > Options: `Yes, proceed` / `Pick a different target branch` (Other) / `Pick a different sub-branch` (Other).
- **Scenario B** — single question listing every local non-default branch:
  > "You're on `<default>`. Which branch should I review against `<default>`?"
  > One option per local branch from `git for-each-ref refs/heads/` (excluding `<default>`). If a branch is checked out in a worktree, annotate it: `<branch> — checked out at <path>`; otherwise just `<branch>`. Plus `Enter a branch name` (Other) — accepts any ref that resolves via `git rev-parse --verify`.

**Skip the confirmation entirely** if the user's invocation already named both branches (e.g. *"review feature/x against develop"*). Run `git rev-parse --verify <target_branch>` and `git rev-parse --verify <sub_branch>` and proceed if both resolve; abort with the failing ref otherwise.

Out of scope: remote-only branches with no local tracking branch. If `Other` resolves only as `origin/<name>` (remote-tracking, no local), abort with: "`<branch>` exists only on the remote. `git checkout <branch>` (or `git fetch && git branch <branch> origin/<branch>`) first, then re-run."

Carry `target_branch` and `sub_branch` forward; every `HEAD` in steps 2–4 is replaced with `<sub_branch>`.

### 1. Sanity-check the repo

Run these checks (read-only):

```powershell
# Confirm we are in a PBIP repo
Get-ChildItem -Filter *.pbip
Get-ChildItem -Directory -Filter *.SemanticModel
Get-ChildItem -Directory -Filter *.Report
```

If none of those exist, stop and tell the user: "This doesn't look like a PBIP repo — I see no `*.pbip`, `*.SemanticModel/`, or `*.Report/` folder. Open the skill in the root of your PBIP project."

### 2. Resolve the diff range

Using `target_branch` and `sub_branch` from [Step 0](#0-detect--confirm-inputs):

```bash
git fetch origin <target_branch>                              # read-only refresh
git merge-base <target_branch> <sub_branch>                   # the base
git diff --name-only <merge-base>...<sub_branch>              # changed files
```

If `sub_branch` is the current `HEAD` (Scenario A) and the working tree has uncommitted changes, tell the user once: "You have uncommitted changes — the review reflects only what's committed on this branch." Do not block. Skip this notice in Scenario B (the working tree belongs to a different worktree, so its state is irrelevant to the chosen `sub_branch`).

### 3. Check for a conventions profile

Look for two artifacts:

- File: `<repo-root>/.claude/powerbi-conventions.md`
- Memory: a `reference`-type entry in the current project's memory dir that points to that file and records the `<target_branch>` SHA at profile time.

Branch on what you find:

| State | Action |
| --- | --- |
| Both missing | Enumerate models/reports on the target branch first (see step 3a below), then dispatch the `powerbi-main-profiler` subagent with the resolved scope. Tell the user one sentence: "No team-conventions profile yet — running the profiler against `<target_branch>` first." |
| File exists, no memory pointer | Read the file, write a memory pointer with the current `<target_branch>` SHA, proceed. |
| Both exist, SHA matches `<target_branch>` tip | Proceed silently. |
| Both exist, SHA stale | Use `AskUserQuestion`: "The conventions profile is from commit `<old SHA>`; `<target_branch>` is now `<new SHA>`. Refresh before reviewing?" Default to "Refresh" if the user picks "yes"; otherwise proceed with the stale profile and note it in the final report. |

#### 3a. Resolve profiler scope (only when dispatching the profiler)

Never auto-skip the profiler because the repo is large. Always sample instead.

```bash
git ls-tree -d --name-only "<target_branch>" | grep -E '\.SemanticModel$|\.Report$'
```

Count semantic models (`M`) and reports (`R`):

| Condition | Action | Profiler input |
| --- | --- | --- |
| `M ≤ 3` AND `R ≤ 3` | Dispatch profiler in `full` scope. | `scope: full` |
| Otherwise | Use `AskUserQuestion` with **two** questions: (1) "Pick up to 3 semantic models to profile" with the enumerated `*.SemanticModel/` names (multi-select, max 3); (2) same for `*.Report/`. Include file counts per item so the user can pick representative ones. Pass the selections to the profiler. | `scope: sampled`, `selected_models: [...]`, `selected_reports: [...]` |
| User picks zero on both questions | Dispatch profiler in `project-hygiene-only` scope. The reviewer will lean on MS Learn + BPA only and emit a 🔵 caveat in the report. | `scope: project-hygiene-only` |

Never silently skip. The conventions file's `scope` field tells the reviewer how to caveat its findings.

### 4. Dispatch the reviewer

Spawn the `powerbi-pr-reviewer` subagent with:

- Diff range: `<merge-base>...<sub_branch>`
- Conventions file path: `<repo-root>/.claude/powerbi-conventions.md`
- References directory path: `<this-skill>/references/`
- Mode: `full-review`, `questions-only`, or `enhancements-only` (default `full-review`)

The reviewer returns Markdown — pass it through verbatim into the chat surface. Do not summarize or compress.

### 5. Offer a follow-up

After rendering the report, ask once via `AskUserQuestion` with two options (plus the always-available "Other"):

- "Draft inline review questions (the 🔵 section, phrased as PR comments you can paste)" → re-dispatch in `questions-only` mode.
- "Show all enhancement suggestions (the 💡 section, including any that were truncated)" → re-dispatch in `enhancements-only` mode.

## Tool priority

When you (the orchestrator) need to run something directly, prefer in this order:

1. **File reads** — `Read`, `Glob`, `Grep` on TMDL / PBIR plain-text files.
2. **Git** — `Bash` with `git diff`, `git log`, `git rev-parse`, `git merge-base`, `git show <branch>:<path>`.
3. **Live docs** — `WebFetch` *only* when the bundled `references/` excerpts don't answer a specific question. Never go to the web by default.

No MCP server is required for v1. Do not invoke `@microsoft/powerbi-modeling-mcp` or similar authoring MCPs — this skill only reads.

## What this skill does NOT do

- Does not push, post, or comment anywhere external (no `gh pr review`, no Slack, no Azure DevOps).
- Does not modify any TMDL / PBIR / .pbip file. Read-only against the working tree.
- Does not run Tabular Editor or any external BPA executor — BPA rules are evaluated by reading `references/bpa-rules-digest.md`.
- Does not fix the issues it finds. Authoring is a separate skill (next planning round).

## References on disk

| File | Purpose |
| --- | --- |
| `references/ms-learn-pbip.md` | PBIP folder structure, `.gitignore` patterns, `.pbip` pointer file. |
| `references/ms-learn-tmdl.md` | TMDL grammar, folder layout, indentation rules. |
| `references/ms-learn-pbir.md` | PBIR folder layout, `definition.pbir`, JSON schemas, PBIR-Legacy distinction. |
| `references/ms-learn-fabric-git.md` | Fabric Git integration, supported items, branching workflow. |
| `references/ms-learn-lifecycle.md` | Official MS guidance on PR review, BPA usage, environment separation. |
| `references/bpa-rules-digest.md` | Tabular Editor BPA rule corpus (Kovalsky) grouped by category + severity. |
| `references/review-rubric.md` | Severity ladder + output format the reviewer must follow. |
| `references/conventions-schema.md` | Schema the profiler fills in when writing `.claude/powerbi-conventions.md`. |
