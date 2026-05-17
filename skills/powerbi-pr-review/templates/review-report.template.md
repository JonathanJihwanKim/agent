# Power BI PR review — `<branch>` vs `<target>`

**Diff range:** `<merge-base-sha>..<head-sha>` (`<N>` files changed)
**Conventions profile:** `.claude/powerbi-conventions.md` taken at `<sha>` (`<fresh | stale>`)
**References:** MS Learn (PBIP, TMDL, PBIR, Fabric Git, Lifecycle) + BPA digest

## Summary

- 🔴 Blockers: `<count>`
- 🟡 Should-fix: `<count>`
- 🔵 Nits / questions: `<count>`

<One paragraph: what's the spirit of this PR, and is it well-executed? Mention scope (TMDL only, PBIR only, both), size, and whether it bundles unrelated concerns.>

## 🔴 Blockers

### B1. <one-line title>

- **Where:** `<path>:<line>`
- **What:** <one-sentence description>
- **Why:** <one-sentence rationale> — Source: <conventions §X.Y | MS Learn URL | BPA rule ID>
- **Suggested fix:** <one or two lines>

```tmdl
<offending snippet if > 20 chars>
```

<!-- repeat for each blocker; if none, write "_No blockers._" -->

## 🟡 Should-fix

### S1. <one-line title>

- **Where:** `<path>:<line>`
- **What:** <one-sentence description>
- **Why:** <one-sentence rationale> — Source: <…>
- **Suggested fix:** <one or two lines>

<!-- repeat; if none, write "_No should-fix findings._" -->

## 🔵 Nits / questions

### Q1. <one-line title>

- **Where:** `<path>:<line>`
- **Comment to author:** <single sentence, phrased as a question, paste-ready>

<!-- repeat; if none, write "_No nits or questions._" -->

## Notes

- Files reviewed: `<N>` TMDL, `<N>` PBIR, `<N>` project-hygiene, `<N>` other (ignored).
- Rules applied: team-conventions pass, MS Learn canonical pass, BPA pass.
- Anything skipped or out of scope: `<list or "nothing">`
