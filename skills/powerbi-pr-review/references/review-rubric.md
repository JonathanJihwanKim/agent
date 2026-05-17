# Review rubric

The reviewer follows this severity ladder and output format. The orchestrator skill renders the result verbatim.

## Severity ladder

| Symbol | Label | Meaning | Examples |
| --- | --- | --- | --- |
| 🔴 | **Blocker** | Would break the model/report, breaks MS Learn structural rules, contradicts an explicit team convention, or is a BPA Level 5. **Must be fixed before merge.** | Renamed `lineageTag`; duplicate measure name; mixed PBIR/PBIR-Legacy; calculated column doing full-table scan; `cache.abf` committed. |
| 🟡 | **Should-fix** | BPA Level 3–4; performance smell; inconsistent with team norms; risky-but-not-broken. | Calculated column where a measure would do; bi-directional relationship without justification; missing `$schema` in PBIR JSON. |
| 🔵 | **Nit / question** | BPA Level 1–2; style preference; cases where the reviewer wants the author's reasoning. | Missing measure description; ambiguous measure name; single-line measure where multi-line is the team norm; "is this intentional?" |

Findings with no clear severity should default to 🔵.

## Findings precedence

When a single change triggers multiple rules, **report it only once**, under the highest severity that applies. Cite all relevant rule sources in the "why" line.

## Output format

The reviewer returns this Markdown structure. The orchestrator renders it without modification.

```markdown
# Power BI PR review — `<branch>` vs `<target>`

**Diff range:** `<merge-base-sha>..<head-sha>` (`<N>` files changed)
**Conventions profile:** `.claude/powerbi-conventions.md` taken at `<sha>` (`<status: fresh | stale>`)
**References:** MS Learn (PBIP, TMDL, PBIR, Fabric Git, Lifecycle) + BPA digest

## Summary

- 🔴 Blockers: `<count>`
- 🟡 Should-fix: `<count>`
- 🔵 Nits / questions: `<count>`

One-paragraph overall take. What's the spirit of this PR, and is it well-executed?

## 🔴 Blockers

### B1. <one-line title>

- **Where:** `path/to/file.tmdl:42`
- **What:** <one-sentence description of the finding>
- **Why:** <one-sentence rationale> — Source: <conventions §X.Y | MS Learn URL | BPA rule ID>
- **Suggested fix:** <one or two lines>

(repeat for each blocker)

## 🟡 Should-fix

### S1. <one-line title>

- **Where:** `path/to/file.tmdl:42`
- **What:** ...
- **Why:** ... — Source: ...
- **Suggested fix:** ...

(repeat)

## 🔵 Nits / questions

### Q1. <one-line title>

- **Where:** `path/to/file.tmdl:42`
- **Comment to author:** <a single sentence the user can paste as a PR comment, phrased as a question>

(repeat)

## Notes

- Files reviewed: `<N>` TMDL, `<N>` PBIR, `<N>` project-hygiene, `<N>` other (ignored).
- Rules applied: team-conventions pass, MS Learn canonical pass, BPA pass.
- Anything skipped or out of scope: `<list>`
```

## Rules for writing findings

- **Cite line numbers.** A finding without `file:line` is rejected by the orchestrator. If the rule is structural (whole-file), cite line 1.
- **One sentence per "Why".** No paragraphs. If you need more, you're describing a different issue — split it.
- **Source attribution required.** Every finding's "Why" ends with `Source: <conventions §… | <URL> | BPA <ID>>`.
- **Quote, don't paraphrase, the offending code.** Use a fenced code block if the snippet > 20 chars.
- **No moralizing.** "This is wrong because X" — not "This is bad practice and the author should have known better."
- **`questions-only` mode** outputs only the 🔵 section. Each question is phrased so the user can copy it directly into a PR review comment.

## Anti-patterns the reviewer must avoid

- ❌ Inventing BPA rule IDs not in `bpa-rules-digest.md`.
- ❌ Inventing team conventions not in `.claude/powerbi-conventions.md`.
- ❌ Citing a Microsoft Learn URL the bundled refs don't already contain (use `WebFetch` first, cite only after confirming).
- ❌ Reporting on files the diff didn't actually change.
- ❌ Praising changes ("nice work here"). Reviews are for concerns, not compliments.
- ❌ Auto-fixing. The reviewer reports — the user (or a future authoring skill) fixes.
