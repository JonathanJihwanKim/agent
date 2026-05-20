# Power BI PR Review — VS Code Copilot port

This folder is a **VS Code Copilot custom-agent package** that mirrors the Claude Code skill at [../skills/powerbi-pr-review/](../skills/powerbi-pr-review/). Recipients drop it into a PBIP workspace and review Power BI pull requests from Copilot Chat — no GitHub or Azure DevOps integration, output stays in chat.

The Claude Code version is the source of truth. Reference excerpts and templates here are byte-identical copies, kept in sync via [`sync-from-skill.ps1`](sync-from-skill.ps1).

## What's in this folder

```
copilot/
  agents/
    powerbi-pr-orchestrator.agent.md     # entry agent — detects branches, dispatches subagents
    powerbi-main-profiler.agent.md       # scans main and writes <repo>/.claude/powerbi-conventions.md
    powerbi-pr-reviewer.agent.md         # reads the diff and produces a severity-grouped Markdown report
  references/                            # bundled MS Learn / BPA excerpts the reviewer reads at runtime
  templates/                             # skeletons the profiler and reviewer fill in
  sync-from-skill.ps1                    # refresh references/templates from the Claude Code source
  VALIDATION.md                          # first-real-run notes (filled in after manual verification)
```

## Install in a PBIP workspace (recipient instructions)

1. Clone or download this repo.
2. In the target PBIP repo (the one whose PRs you want to review), copy files into `.github/`:

   ```powershell
   # from your PBIP repo root:
   $src = 'D:\path\to\agent\copilot'
   New-Item -ItemType Directory -Force -Path '.github\agents','.github\powerbi-pr-review\references','.github\powerbi-pr-review\templates' | Out-Null
   Copy-Item "$src\agents\*"     '.github\agents\'                              -Force
   Copy-Item "$src\references\*" '.github\powerbi-pr-review\references\'        -Force
   Copy-Item "$src\templates\*"  '.github\powerbi-pr-review\templates\'         -Force
   ```

   Result:

   ```
   <your-pbip-repo>/
     .github/
       agents/
         powerbi-pr-orchestrator.agent.md
         powerbi-main-profiler.agent.md
         powerbi-pr-reviewer.agent.md
       powerbi-pr-review/
         references/*.md
         templates/*.md
   ```

3. Open the workspace in VS Code. Open Copilot Chat (`Ctrl+Alt+I`). Click the agent picker — you should see `powerbi-pr-orchestrator` listed. The profiler and reviewer are hidden from the picker (`user-invocable: false`) because the orchestrator dispatches them.

4. Select `powerbi-pr-orchestrator` and type *"review this PR"* (or *"review feature/foo against develop"* to skip the branch-confirm prompt).

## Run

- Switch to `powerbi-pr-orchestrator` in Copilot Chat.
- Type a review request. The orchestrator:
  1. Probes git for branches, asks you to confirm `target` vs `sub_branch` inline.
  2. Sanity-checks that the workspace is a PBIP repo.
  3. Resolves the diff range.
  4. If `<repo>/.claude/powerbi-conventions.md` is missing, hands off to `powerbi-main-profiler` to write it (read-only against the working tree).
  5. Hands off to `powerbi-pr-reviewer` to produce the Markdown report.
  6. Asks if you want a `questions-only` or `enhancements-only` re-run.

## What's different vs the Claude Code original

These are intentional adaptations to the Copilot platform — not bugs:

| Claude Code feature | Copilot replacement |
| --- | --- |
| `AskUserQuestion` (clickable single/multi-select prompts) | Inline plaintext prompts — orchestrator writes the question, you reply with `yes` / `sample` / `skip` / `cancel` / branch names / etc. |
| Per-cwd memory pointer with `target_branch` SHA | Dropped. The `main_sha:` field in `<repo>/.claude/powerbi-conventions.md`'s own frontmatter is the only staleness signal; the orchestrator re-reads it each run and compares to `git rev-parse <target_branch>`. |
| Natural-language skill auto-trigger | Copilot doesn't match on `description:` text for invocation. You must select `powerbi-pr-orchestrator` from the agent picker before typing the review request. |
| Subagent dispatch via `Task` tool | Copilot `handoffs:` frontmatter. The orchestrator declares `agents: [powerbi-main-profiler, powerbi-pr-reviewer]` and routes via the handoff mechanism. |
| Tool names `Read`, `Glob`, `Grep`, `Bash`, `Write`, `WebFetch` | `codebase` (read/search), `runCommands` (terminal), `editFiles` (write), `fetch` (web). |

Everything else — the severity ladder (🔴 / 🟡 / 🔵), the three rule passes (team-conventions → MS Learn → BPA), the read-only `git show` discipline in the profiler, the topic-first review headings, the TL;DR-first report shape — ports verbatim.

## Keep references in sync with the Claude Code source

When the upstream files at [../skills/powerbi-pr-review/references/](../skills/powerbi-pr-review/references/) or [../skills/powerbi-pr-review/templates/](../skills/powerbi-pr-review/templates/) change, refresh the Copilot copies:

```powershell
.\sync-from-skill.ps1
```

The script copies `references/*` and `templates/*` from the Claude Code skill into this folder, overwriting in place. The three `.agent.md` files in `agents/` are **not** touched — they're adapted bodies, not pure copies, and have to be edited manually when the upstream SKILL.md or subagent files change in ways that affect the workflow.

## Validation

This port has not been end-to-end tested inside VS Code Copilot yet. The first real run should be captured in [VALIDATION.md](VALIDATION.md) — what worked, what diverged, what's a known gap. The Claude Code analog is at [../skills/powerbi-pr-review/VALIDATION.md](../skills/powerbi-pr-review/VALIDATION.md).

## License & attribution

Authored by Jihwan Kim (Power BI MVP). See the parent repo for license terms.
