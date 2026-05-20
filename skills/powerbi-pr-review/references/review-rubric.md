# Review rubric

The reviewer follows this severity ladder and output format. The orchestrator skill renders the result verbatim.

## Severity ladder

| Symbol | Label | Meaning | Examples |
| --- | --- | --- | --- |
| 🔴 | **Blocker** | Would break the model/report, breaks MS Learn structural rules, contradicts an explicit team convention, or is a BPA Level 5. **Must be fixed before merge.** | Renamed `lineageTag`; duplicate measure name; mixed PBIR/PBIR-Legacy; calculated column doing full-table scan; `cache.abf` committed. |
| 🟡 | **Should-fix** | BPA Level 3–4; performance smell; inconsistent with team norms; risky-but-not-broken. | Calculated column where a measure would do; bi-directional relationship without justification; missing `$schema` in PBIR JSON. |
| 🔵 | **Nit / question** (on this diff) | BPA Level 1–2; style preference; cases where the reviewer wants the author's reasoning. **Must anchor to a line the diff actually changed.** | Missing measure description on the *newly added* measure; ambiguous *new* measure name; "is this intentional?" |
| 💡 | **Enhancement** (not part of this PR) | *Not a severity.* Optional suggestions about pre-existing state the diff did not touch. Never blocks merge. Caps at 5 per report by default. | "Not a change in this PR — measure `Foo` on `main` has no `formatString`; consider adding one." |

Findings with no clear severity should default to 🔵.

A would-be 🔵 question whose target line is **not in the diff hunks** must be demoted to 💡 and rephrased with the `Not a change in this PR — …` opener. The 🔴 / 🟡 / 🔵 categories never apply to unchanged content.

## Findings precedence

When a single change triggers multiple rules, **report it only once**, under the highest severity that applies. Cite all relevant rule sources in the "why" line.

## Writing style — topic-first, not inductive

Reviews are read by humans who triage in seconds. Lead with the conclusion. Support with evidence. Never make the reader synthesize the verdict from a sequence of facts.

**Three rules govern every artifact the reviewer produces.**

### Rule 1 — The report opens with a TL;DR

The first section of the report is `## TL;DR`. Its first sentence is the merge-or-don't-merge call, stated outright. A reader who reads only that sentence should know whether to block, request changes, or approve. Follow-up sentences (1–3) name the load-bearing reasons. The `## Summary` counts come **after** the TL;DR, not before.

### Rule 2 — Every finding heading is a verdict

The heading of each 🔴 / 🟡 finding names the action or the conclusion, not the location of the offending code. Imperative or declarative, ≤ 18 words, no trailing punctuation, first-letter-uppercase.

Concrete contrast (real example from the v1 run log):

| ❌ Inductive (location-first) | ✅ Topic-first (verdict-first) |
| --- | --- |
| `### B1. Three .pbi/localSettings.json files tracked-in-index, bypassing .gitignore` | `### B1. Drop three .pbi/localSettings.json files — they leak per-user DPAPI secrets and the .gitignore is already configured to ignore them` |
| `### S2. diagramLayout.json committed with a no-op scroll-position diff` | `### S2. Revert diagramLayout.json — the 3-pixel scroll delta is per-author noise, not a model change` |

Folder-ID-only and "files are X" headings fail this rule. If your heading describes *what was found* instead of *what to do or conclude*, rewrite it.

### Rule 3 — Body fields are `Why → Where → Fix`

The verdict heading already answers "what." Repeating it in a `What:` field is redundant. The body's job is to justify and locate. Order:

1. **Why** — one sentence, ending in `— Source: <…>`.
2. **Where** — `path:line` (plus the visual-identity label for PBIR paths).
3. **Fix** (or **Suggested fix**) — one to two lines.

🔵 questions keep `Where → Comment to author` (the question is the verdict). 💡 enhancements keep `Where → Note` (the note opens with `Not a change in this PR — …`).

## Output format

The reviewer returns this Markdown structure. The orchestrator renders it without modification.

```markdown
# Power BI PR review — `<branch>` vs `<target>`

**Diff range:** `<merge-base-sha>..<head-sha>` (`<N>` files changed)
**Conventions profile:** `.claude/powerbi-conventions.md` taken at `<sha>` (`<status: fresh | stale>`, scope=`<full | sampled | project-hygiene-only>`)
**References:** MS Learn (PBIP, TMDL, PBIR, Fabric Git, Lifecycle) + BPA digest

## TL;DR

<First sentence: the merge call. Either "Do not merge — <load-bearing reason>." or "Merge after the <N> blockers are fixed." or "Merge clean." 1–3 follow-up sentences name the reasons. A reader who reads only the first sentence should know the call.>

## Summary

- 🔴 Blockers: `<count>`
- 🟡 Should-fix: `<count>`
- 🔵 Nits / questions (on this diff): `<count>`
- 💡 Enhancement suggestions (existing state): `<count>`

## 🔴 Blockers

### B1. <verdict heading — names the action or the conclusion, not the location>

- **Why:** <one-sentence rationale> — Source: <conventions §X.Y | MS Learn URL | BPA rule ID>
- **Where:** `path/to/file.tmdl:42`
- **Fix:** <one or two lines>

(repeat for each blocker; if none, write `_No blockers._`)

## 🟡 Should-fix

### S1. <verdict heading>

- **Why:** <one-sentence rationale> — Source: <…>
- **Where:** `path/to/file.tmdl:42`
- **Fix:** <one or two lines>

(repeat; if none, write `_No should-fix findings._`)

## 🔵 Nits / questions (on this diff)

### Q1. <the question itself, phrased as a question — this is the verdict>

- **Where:** `path/to/file.tmdl:42`
- **Comment to author:** <a single sentence the user can paste as a PR comment>

(repeat; if none, write `_No nits or questions._`)

## 💡 Enhancement suggestions (existing state, not part of this PR)

### E1. <verdict heading — the proposed enhancement, stated as the conclusion>

- **Where:** `path/to/file.tmdl:42` (existing on `main` — not changed by this PR)
- **Note:** Not a change in this PR — <one sentence: what enhancement, and why it's worth considering>.

(repeat; cap 5 by default; if none, write `_No enhancement suggestions._`)

## Notes

- Files reviewed: `<N>` TMDL, `<N>` PBIR, `<N>` project-hygiene, `<N>` other (ignored).
- Rules applied: team-conventions pass, MS Learn canonical pass, BPA pass.
- Anything skipped or out of scope: `<list>`
```

## Rules for writing findings

- **Heading is the verdict.** Each 🔴 / 🟡 / 💡 heading names the action or the conclusion (e.g. `Drop three localSettings.json files — they leak DPAPI secrets`), not the location (e.g. `Three localSettings.json files exist`) and not a label (e.g. `Project hygiene issue`). First-letter-uppercase, imperative or declarative, ≤ 18 words, no trailing punctuation. For 🔵 the heading is the question itself.
- **Body order is `Why → Where → Fix`.** The verdict heading carries the "what"; do not repeat it as a `What:` field. The body justifies (`Why`), locates (`Where`), and prescribes (`Fix`). 🔵 questions keep `Where → Comment to author`; 💡 enhancements keep `Where → Note`.
- **Cite line numbers.** A finding without `file:line` is rejected by the orchestrator. If the rule is structural (whole-file), cite line 1.
- **One sentence per "Why".** No paragraphs. If you need more, you're describing a different issue — split it.
- **Source attribution required.** Every finding's "Why" ends with `Source: <conventions §… | <URL> | BPA <ID>>`. In `project-hygiene-only` scope, the conventions citation is unavailable; cite only MS Learn URLs or BPA IDs, and let the report header note that conventions were not consulted.
- **Quote, don't paraphrase, the offending code.** Use a fenced code block if the snippet > 20 chars.
- **No moralizing.** "This is wrong because X" — not "This is bad practice and the author should have known better."
- **Visual identity in `Where`.** When the file path contains `/visuals/<id>/` (or `/pages/<id>/`), the `Where` line **must** include the resolved visual type, title, and page name (e.g. `visual card "Total Picked" on page "Picking Capacity"`). Folder-ID-only citations are rejected — the visual identity index built in the reviewer's Step 2b resolves these.
- **`questions-only` mode** outputs only the 🔵 section. Each question is phrased so the user can copy it directly into a PR review comment.
- **`enhancements-only` mode** outputs only the 💡 section. Each item opens with `Not a change in this PR — …`.

## Anti-patterns the reviewer must avoid

- ❌ Inductive write-ups. Leading with evidence and ending with the conclusion ("File X has Y; Y violates Z; therefore fix Y") is rejected. State the call, then justify.
- ❌ Location-as-heading. `### B1. Three localSettings.json files in .pbi/` is a label, not a verdict. Rewrite to name the action: `### B1. Drop three localSettings.json files — they leak DPAPI secrets …`.
- ❌ Summary counts before the TL;DR. The TL;DR is the first section. The Summary counts come after.
- ❌ Inventing BPA rule IDs not in `bpa-rules-digest.md`.
- ❌ Inventing team conventions not in `.claude/powerbi-conventions.md`.
- ❌ Citing a Microsoft Learn URL the bundled refs don't already contain (use `WebFetch` first, cite only after confirming).
- ❌ Reporting on files the diff didn't actually change.
- ❌ Asking 🔵 questions about properties or values the diff didn't change. If you want to surface it, demote to 💡 and open with `Not a change in this PR — …`.
- ❌ Citing visuals by folder-ID alone (e.g. `…/visuals/90c2e07d8e84e7d5c026/visual.json:42`). Always resolve to `visual <type> "<title>" on page "<page>"` via the Step 2b visual identity index.
- ❌ Praising changes ("nice work here"). Reviews are for concerns, not compliments.
- ❌ Auto-fixing. The reviewer reports — the user (or a future authoring skill) fixes.
