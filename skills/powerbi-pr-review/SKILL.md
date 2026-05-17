---
name: powerbi-pr-review
description: Critically review a Power BI pull request (local branch diff vs. main) against the team's own main-branch conventions, Microsoft Learn canonical guidance for PBIP / TMDL / PBIR, and Tabular Editor BPA rules. Triggers on requests like "review this PR", "review this branch", "review the Power BI changes", "what's wrong with this PR", or any review request in a directory containing a `*.pbip` pointer, a `*.SemanticModel/definition/` folder, or a `*.Report/definition/` folder. Produces a severity-grouped Markdown report with file:line citations and proposed review comments. No GitHub/ADO integration — output is rendered in chat for the user to paste.
---

# Power BI PR Review

You are the orchestrator for a critical review of a Power BI pull request. You delegate the heavy work to two subagents and stitch their output into the final report.

## Inputs (resolved from the conversation)

- **Repo root** — the working directory. Must contain a `*.pbip` file or a `*.SemanticModel/` or `*.Report/` folder.
- **Diff target branch** — default `main`. Override via the user's request (e.g. "review against develop").
- **Mode** — `full-review` (default) or `questions-only` (only the 🔵 question section).

## Workflow

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

```bash
git fetch origin <target-branch>            # read-only refresh
git merge-base <target-branch> HEAD         # the base
git diff --name-only <merge-base>...HEAD    # changed files
```

If the working tree has uncommitted changes, tell the user once: "You have uncommitted changes — the review reflects only what's committed on this branch." Do not block.

### 3. Check for a conventions profile

Look for two artifacts:

- File: `<repo-root>/.claude/powerbi-conventions.md`
- Memory: a `reference`-type entry in the current project's memory dir that points to that file and records the `main`-branch SHA at profile time.

Branch on what you find:

| State | Action |
| --- | --- |
| Both missing | Dispatch the `powerbi-main-profiler` subagent (see below), then proceed. Tell the user one sentence: "No team-conventions profile yet — running the profiler against `<target-branch>` first." |
| File exists, no memory pointer | Read the file, write a memory pointer with the current `main` SHA, proceed. |
| Both exist, SHA matches `main` tip | Proceed silently. |
| Both exist, SHA stale | Use `AskUserQuestion`: "The conventions profile is from commit `<old SHA>`; `main` is now `<new SHA>`. Refresh before reviewing?" Default to "Refresh" if the user picks "yes"; otherwise proceed with the stale profile and note it in the final report. |

### 4. Dispatch the reviewer

Spawn the `powerbi-pr-reviewer` subagent with:

- Diff range: `<merge-base>...HEAD`
- Conventions file path: `<repo-root>/.claude/powerbi-conventions.md`
- References directory path: `<this-skill>/references/`
- Mode: `full-review` or `questions-only` (default `full-review`)

The reviewer returns Markdown — pass it through verbatim into the chat surface. Do not summarize or compress.

### 5. Offer a follow-up

After rendering the report, ask once via `AskUserQuestion`:

> Want me to draft inline review questions (the 🔵 section, phrased as PR comments you can paste)?

If yes, re-dispatch the reviewer in `questions-only` mode.

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
