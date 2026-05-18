# Power BI PR review — `<branch>` vs `<target>`

**Diff range:** `<merge-base-sha>..<head-sha>` (`<N>` files changed)
**Conventions profile:** `.claude/powerbi-conventions.md` taken at `<sha>` (`<fresh | stale>`, scope=`<full | sampled | project-hygiene-only>`)
**References:** MS Learn (PBIP, TMDL, PBIR, Fabric Git, Lifecycle) + BPA digest

## Summary

- 🔴 Blockers: `<count>`
- 🟡 Should-fix: `<count>`
- 🔵 Nits / questions (on this diff): `<count>`
- 💡 Enhancement suggestions (existing state): `<count>`

<One paragraph: what's the spirit of this PR, and is it well-executed? Mention scope (TMDL only, PBIR only, both), size, and whether it bundles unrelated concerns.>

## 🔴 Blockers

### B1. <one-line title>

- **Where:** `<path>:<line>` — for PBIR visuals also write: `visual <type> "<title or 'untitled'>" on page "<pageName>"` (resolved by the Step 2b visual identity index).
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

## 🔵 Nits / questions (on this diff)

### Q1. <one-line title>

- **Where:** `<path>:<line>` — for PBIR visuals also write `visual <type> "<title>" on page "<pageName>"`.
- **Comment to author:** <single sentence, phrased as a question, paste-ready, about a line that the diff actually changes>

<!-- repeat; if none, write "_No nits or questions._" -->

## 💡 Enhancement suggestions (existing state, not part of this PR)

### E1. <one-line title>

- **Where:** `<path>:<line>` (existing on `main` — not changed by this PR) — for PBIR visuals also write `visual <type> "<title>" on page "<pageName>"`.
- **Note:** Not a change in this PR — <one sentence: what enhancement, and why it's worth considering>.

<!-- repeat; cap 5 per report by default; if more were dropped, end with: "_N additional suggestions omitted; rerun in `enhancements-only` mode to see all._" -->
<!-- if none, write "_No enhancement suggestions._" -->

## Notes

- Files reviewed: `<N>` TMDL, `<N>` PBIR, `<N>` project-hygiene, `<N>` other (ignored).
- Rules applied: team-conventions pass, MS Learn canonical pass, BPA pass.
- Anything skipped or out of scope: `<list or "nothing">`
