# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

`d:\agent` is a **meta-workspace for authoring Claude Code skills and subagents that help Power BI developers**. There is no application to build, no test suite, and no runtime — every artifact is Markdown (`SKILL.md`, agent definitions, reference docs, templates) that Claude Code loads at invocation time.

The repo is the source-of-truth location during development. Packaging into a distributable form (Claude Code plugin marketplace, symlink into `~/.claude/skills/`, or direct copy) is deliberately deferred and decided per-skill. Treat `d:\agent` as authoritative; do not edit the same skill in two places.

Reference architecture: https://github.com/RuiRomano/powerbi-agentic-plugins (skills + MCP for Power BI authoring). This repo intentionally targets gaps in that reference — starting with PR review.

## Skill anatomy used here

Every skill follows this layout:

```
skills/<skill-name>/
  SKILL.md                  # YAML frontmatter (name, description, triggers) + orchestrator workflow
  README.md                 # human-facing notes
  VALIDATION.md             # dry-run log from first end-to-end exercise
  references/               # bundled excerpts the agents read at runtime
  templates/                # skeletons agents fill in
  agents/<subagent>.md      # YAML frontmatter (name, description, tools, model) + agent instructions
```

Conventions that matter when modifying or adding skills:

- **Subagents over inline logic.** When a skill has multiple distinct concerns (e.g. profile vs. review), split each into its own agent file under `agents/`. The skill's `SKILL.md` is an orchestrator that dispatches them. The reference repo's persona-based pattern is what we follow.
- **References are bundled excerpts, not URL lists alone.** Each `references/ms-learn-*.md` holds a distilled excerpt **plus** the canonical URL — primary for offline-deterministic reads, with `WebFetch` as fallback for questions the excerpts don't cover.
- **Read-only by default.** Subagents that scan a target repo (like `powerbi-main-profiler`) must use `git show <branch>:<path>` rather than `git checkout` so the user's working tree is never disturbed.
- **No MCP dependencies.** The reference repo uses `@microsoft/powerbi-modeling-mcp` for *authoring*. Skills here that only *read* (review, lint, analyze) do not declare MCP servers. If a future authoring skill needs one, declare it then.
- **Memory + repo-file pattern for per-team state.** When a skill needs to learn about a target repo's conventions (each team's main branch is different), write the profile to `<target-repo>/.claude/<file>.md` as the source of truth, and write a `reference`-type entry into Claude's per-cwd memory pointing to it (with a SHA so staleness is detectable). See `skills/powerbi-pr-review/agents/powerbi-main-profiler.md` for the exact pattern.

## The first skill: `powerbi-pr-review`

This skill reviews Power BI pull requests locally (no GitHub/ADO integration in v1). Architecture:

- **Orchestrator** ([SKILL.md](skills/powerbi-pr-review/SKILL.md)) — sanity-checks the PBIP repo, resolves the diff range, checks for a conventions profile, dispatches subagents, renders the result.
- **Profiler subagent** ([agents/powerbi-main-profiler.md](skills/powerbi-pr-review/agents/powerbi-main-profiler.md)) — scans `main`, writes `<repo>/.claude/powerbi-conventions.md` describing the team's de-facto conventions. Read-only against the working tree.
- **Reviewer subagent** ([agents/powerbi-pr-reviewer.md](skills/powerbi-pr-review/agents/powerbi-pr-reviewer.md)) — reads the diff, the conventions file, and the bundled MS Learn / BPA references, then produces a severity-grouped Markdown report (🔴 Blocker / 🟡 Should-fix / 🔵 Nit-or-question). Cites file:line and source rule for every finding.

Three independent rule passes inside the reviewer, in this order: **team conventions → MS Learn canonical → BPA**. Each finding reports at the highest applicable severity and is sourced (`Source: conventions §X.Y | MS Learn URL | BPA rule ID`). The rubric, severity ladder, and output skeleton are pinned in [references/review-rubric.md](skills/powerbi-pr-review/references/review-rubric.md) and [templates/review-report.template.md](skills/powerbi-pr-review/templates/review-report.template.md). When changing severity meanings or output shape, update both.

Out of scope for v1 (do not add without re-planning): GitHub/ADO comment posting, Azure DevOps PRs, running Tabular Editor or external BPA executors, authoring fixes, performance/VertiPaq analysis, packaging.

## Validating a new or modified skill

The validation pattern used for the first skill:

1. Pick one real PBIP repo from the user's project list (10+ tracked in `~/.claude/projects/`).
2. **Manually execute the profiler logic** against the target's `main` branch (read TMDL/PBIR via `git show`, fill in the template, write the conventions file to `<target>/.claude/`).
3. Capture findings already present in `main` (e.g. wrongly-committed `.pbi/*` files) and grandfather them in section §1 of the conventions file so the reviewer doesn't flag them on every future PR.
4. Document the run in `skills/<skill>/VALIDATION.md` with: target repo, main SHA, what worked, what wasn't end-to-end-tested, and "Known gaps for v1.1".

The skill itself is not yet installed in Claude Code, so end-to-end invocation (with subagent dispatch) cannot be exercised from inside Claude Code yet. The manual dry-run is the substitute.

For the validation log of the first skill, see [skills/powerbi-pr-review/VALIDATION.md](skills/powerbi-pr-review/VALIDATION.md) — it includes a worked example of what a real review report should look like, which is the de-facto contract for the reviewer's output shape.

## When extending

- Always plan before building. Plans live in `~/.claude/plans/`. Use the Plan / ExitPlanMode workflow.
- New skills go under `skills/<kebab-case-name>/`. Mirror the anatomy above.
- Bundle MS Learn excerpts under `references/ms-learn-*.md` with the source URL at the top and the `updated_at` date from the doc's frontmatter — drift matters for Power BI (PBIR is going GA in Q3 2026, semantics shift).
- The user (Jihwan Kim, Power BI MVP) is the primary audience. Skills should be terse, opinionated, and BPA-aware. Avoid hedging language in agent prompts — the reviewer is explicitly a "critic not a coach."
