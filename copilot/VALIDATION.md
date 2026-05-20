# VALIDATION — Copilot port of `powerbi-pr-review`

This is the analog of [../skills/powerbi-pr-review/VALIDATION.md](../skills/powerbi-pr-review/VALIDATION.md) for the VS Code Copilot port. Fill it in after the first real end-to-end run.

## Status

**Not yet validated end-to-end.** Authored on 2026-05-20 against VS Code Copilot custom-agent docs ([code.visualstudio.com/docs/copilot/customization/custom-agents](https://code.visualstudio.com/docs/copilot/customization/custom-agents)) but never exercised in a live Copilot session.

## Target

- Target repo: *(fill in — one of the PBIP repos in `~/.claude/projects/`)*
- Target branch: *(fill in)*
- Target SHA at validation time: *(fill in)*
- VS Code version: *(fill in)*
- Copilot extension version: *(fill in)*

## Verification checklist

1. [ ] Copied `copilot/agents/*.agent.md` into `<target>/.github/agents/`.
2. [ ] Copied `copilot/references/` and `copilot/templates/` into `<target>/.github/powerbi-pr-review/`.
3. [ ] Opened the target repo in VS Code, opened Copilot Chat.
4. [ ] `powerbi-pr-orchestrator` is listed in the agent picker.
5. [ ] `powerbi-main-profiler` and `powerbi-pr-reviewer` are **not** in the user-facing agent picker (they have `user-invocable: false`) but the orchestrator can still hand off to them.
6. [ ] Selected `powerbi-pr-orchestrator`, typed *"review this PR"*.
7. [ ] Orchestrator ran `git rev-parse`, `git symbolic-ref`, `git for-each-ref` via `runCommands`.
8. [ ] Step 0 branch-confirm appeared as an inline plaintext prompt (no `AskUserQuestion` UI).
9. [ ] When no `.claude/powerbi-conventions.md` existed, the orchestrator handed off to `powerbi-main-profiler` and Copilot's handoff button appeared.
10. [ ] The profiler wrote `<repo>/.claude/powerbi-conventions.md` via `editFiles` without modifying any TMDL/PBIR file.
11. [ ] Orchestrator then handed off to `powerbi-pr-reviewer`.
12. [ ] The reviewer rendered a Markdown report with the TL;DR-first shape, file:line citations, and `Source:` lines on every finding.
13. [ ] Mode-restricted re-runs (`questions-only`, `enhancements-only`) worked when requested via the Step 5 follow-up prompt.

## What worked

*(fill in)*

## What diverged from the Claude Code version

*(fill in — e.g. handoff button UX, plaintext-prompt confusion, missing tool, etc.)*

## Known gaps for v1.1

- *(fill in — anything the port should fix in the next iteration.)*

## Anything that wasn't end-to-end-tested

- *(fill in — e.g. `enhancements-only` mode, sampled scope path, stale-profile refresh.)*
