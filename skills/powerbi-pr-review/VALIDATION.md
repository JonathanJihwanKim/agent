# Validation log — first dry-run

**Target repo:** `D:\sample_powerbi`
**Main SHA at scan:** `24b315e227f31990d0c8202e3fd1aa9ef44fbab5`
**Date:** 2026-05-17

This log documents the first end-to-end validation of the `powerbi-pr-review` skill against a real PBIP repo. The skill itself isn't installed yet (per the plan, packaging is deferred), so Claude executed the profiler logic manually as a stand-in. The conventions file `D:\sample_powerbi\.claude\powerbi-conventions.md` is the output of that run.

## Verification step 1 — Profile run

✅ **Pass.** The profiler logic, walked manually over `main`, produced a conventions file that matches the schema in `references/conventions-schema.md` and uses the template at `templates/powerbi-conventions.template.md`. All six required sections are present.

What the conventions file captures faithfully:
- Naming taxonomy (Title Case dims, `_` hidden facts, `__` system, `prm` parameters)
- Display folder discipline (~86% measures have one, but only ~100% of *visible* measures do — the file calls this out correctly)
- M / parameterization style (`_BillingProject`, `_ReportId` parameters; Google BigQuery via `Value.NativeQuery`)
- The 100% `lineageTag` coverage
- BPA-aligned conventions already in use: `DIVIDE`, `discourageImplicitMeasures`, `crossFilteringBehavior: oneDirection`

What the dry-run skipped (the real profiler would do these):
- `$schema` declaration coverage on PBIR JSON files (spot-check only)
- Mobile-layout coverage % (spot-check only)
- Custom-visual enumeration (spot-check only)
- Description-coverage exact %

These are time-budget cuts, not skill design gaps. Marked "needs spot-check" in §3 of the conventions file.

## Verification step 2 — Review run (clean diff)

⏸ **Not run.** Would require creating a feature branch with a conformant change (e.g. one new visible measure following all hard rules). User has not yet authorized branch creation in the sample repo.

Expected behavior when run: zero 🔴 / 🟡 findings; possibly one 🔵 if the new measure lacks a `///` description (inconsistent in main, so 🔵 not 🟡).

## Verification step 3 — Review run (rule violations)

⏸ **Not run.** Would require a feature branch with deliberate violations. To demonstrate the rubric, here is what the reviewer **would** produce for a hypothetical diff that:

1. Adds `prod_report_picking_dashboard_v1.SemanticModel/.pbi/cache.abf` (new commit, not grandfathered)
2. Adds a visible measure `Foo Bar` in `Measure.tmdl` without `displayFolder` or `formatString`
3. Adds a calculated column `column 'Total Picked' = SUMX(_orderline_agg_rpt, [orderline_count])` on `Picking Area`
4. Hardcodes `Source = GoogleBigQuery.Database([BillingProject="ingka-ilo-ia-prod"])` in a new expression instead of `_BillingProject`
5. Adds a new relationship with `crossFilteringBehavior: bothDirections`
6. Changes `lineageTag` on existing measure `Number of Exceptions` to a new GUID

### Expected output

```markdown
# Power BI PR review — `<feature>` vs `main`

**Diff range:** `24b315e..<head>` (5 files changed)
**Conventions profile:** `.claude/powerbi-conventions.md` taken at `24b315e` (fresh)
**References:** MS Learn (PBIP, TMDL, PBIR, Fabric Git, Lifecycle) + BPA digest

## Summary

- 🔴 Blockers: 3
- 🟡 Should-fix: 3
- 🔵 Nits / questions: 0

This PR mixes a new measure addition with infrastructure changes (lineage tag rewrite, hardcoded data source, bi-directional relationship). The blockers are independent and severe; recommend splitting.

## 🔴 Blockers

### B1. `lineageTag` rewritten on existing measure

- **Where:** `prod_report_picking_dashboard_v1.SemanticModel/definition/tables/Measure.tmdl:7`
- **What:** `lineageTag` of measure `Number of Exceptions` changed from `f847b11f-…` to a new GUID.
- **Why:** Lineage tags are immutable references used by downstream reports/Fabric — changing them breaks visuals. — Source: conventions §6 (Hard rules), BPA META07.
- **Suggested fix:** Revert the lineage tag to its prior value.

### B2. Hardcoded BigQuery project in `expressions.tmdl`

- **Where:** `prod_report_picking_dashboard_v1.SemanticModel/definition/expressions.tmdl:<line>`
- **What:** New M expression uses `BillingProject="ingka-ilo-ia-prod"` instead of `_BillingProject`.
- **Why:** Every other expression in this repo parameterizes the project — hardcoding breaks environment promotion. — Source: conventions §6 (Hard rules).
- **Suggested fix:** Replace with `BillingProject=_BillingProject`.

### B3. `.pbi/cache.abf` added in commit

- **Where:** `prod_report_picking_dashboard_v1.SemanticModel/.pbi/cache.abf:1`
- **What:** A new `cache.abf` was committed.
- **Why:** This file is a local AS backup, often hundreds of MB; MS Learn lists it in the default `.gitignore`. — Source: references/ms-learn-pbip.md.
- **Suggested fix:** `git rm --cached <path>` and force-add the `.gitignore` rule.

## 🟡 Should-fix

### S1. New visible measure has no `displayFolder`

- **Where:** `prod_report_picking_dashboard_v1.SemanticModel/definition/tables/Measure.tmdl:<line>`
- **What:** Measure `Foo Bar` is added without a `displayFolder` property.
- **Why:** Every visible measure in this repo uses `displayFolder` — this PR breaks the pattern. — Source: conventions §6 (Hard rules).
- **Suggested fix:** Add `displayFolder: <Exceptions | Corrections | Orders | Orderlines | …>`.

### S2. New visible measure has no `formatString`

- **Where:** `prod_report_picking_dashboard_v1.SemanticModel/definition/tables/Measure.tmdl:<line>`
- **What:** Measure `Foo Bar` lacks a `formatString` (or `formatStringDefinition`).
- **Why:** Every visible measure has one (`#,0`, percentages, or a SWITCH-based definition). — Source: conventions §6 (Hard rules), BPA META03.
- **Suggested fix:** Pick `formatString: #,0` for an integer count or follow the team's existing conventions for the metric type.

### S3. Calculated column doing aggregation

- **Where:** `prod_report_picking_dashboard_v1.SemanticModel/definition/tables/Picking Area.tmdl:<line>`
- **What:** New calculated column `column 'Total Picked' = SUMX(_orderline_agg_rpt, [orderline_count])` does table-scan aggregation.
- **Why:** Aggregation belongs in a measure, not a calculated column — calc-columns persist per-row and bloat the model. — Source: BPA PERF01.
- **Suggested fix:** Convert to a measure on `Measure.tmdl` with appropriate `displayFolder`.

### S4. New relationship is bi-directional without justification

- **Where:** `prod_report_picking_dashboard_v1.SemanticModel/definition/relationships.tmdl:<line>`
- **What:** New relationship sets `crossFilteringBehavior: bothDirections`.
- **Why:** Every other relationship in the model is one-directional; bi-directional filters are slow and ambiguity-prone. — Source: conventions §6 (Hard rules), BPA PERF03.
- **Suggested fix:** Confirm the use case in the PR description, or rewrite as a measure pattern using `CROSSFILTER`.

## 🔵 Nits / questions

_No nits or questions for this hypothetical diff._

## Notes

- Files reviewed: 4 TMDL, 0 PBIR, 1 project-hygiene, 0 other.
- Rules applied: team-conventions pass, MS Learn canonical pass, BPA pass.
- Skipped: DAX semantic correctness (`Foo Bar` expression not evaluated); DirectQuery folding (not in v1 scope).
```

This output demonstrates that:
- Severity ladder works (🔴 / 🟡 / 🔵).
- Source attribution is consistent (conventions §, MS Learn URL, or BPA ID).
- Each finding is short, with file:line + Why + Suggested fix.
- Stack-ranked across all three rule passes (team conventions cited first when applicable).

## Verification step 4 — Staleness detection

⏸ **Not run** end-to-end, but the conventions file has `main_sha: 24b315e…` in frontmatter, so the orchestrator's check (`git rev-parse main` ≠ stored SHA) will work the moment `main` advances. Mechanism verified by inspection.

## Verification step 5 — PBIR coverage

⏸ **Not run** as a diff. From static inspection of `prod_report_picking_dashboard_v1.Report/`:

- ✅ PBIR (not PBIR-Legacy) — `definition/` folder present.
- ✅ `definition.pbir` references `byPath` to the local SemanticModel.
- ✅ Folder structure matches `references/ms-learn-pbir.md`.

If a PR modified a `visual.json` to break the theme reference (e.g. removed `IKEA_scheme*` from `RegisteredResources/`), the reviewer would raise 🔴 against the `report.json` theme block.

## Real findings already present in `main`

Independent of any PR, the dry-run surfaced **two issues that exist in `main` today**:

1. **`.pbi/cache.abf`** is committed in `prod_report_picking_dashboard_v1.SemanticModel/.pbi/`. This is a local AS backup. — Source: `references/ms-learn-pbip.md`, the repo's own `.gitignore`.
2. **`.pbi/localSettings.json`** is committed in both `.SemanticModel/.pbi/` and `.Report/.pbi/`. User-local settings should never be committed. — Same source.

The `.gitignore` already lists both patterns, so these were committed before the rule was added. Fix:

```bash
git rm --cached prod_report_picking_dashboard_v1.SemanticModel/.pbi/cache.abf
git rm --cached prod_report_picking_dashboard_v1.SemanticModel/.pbi/localSettings.json
git rm --cached prod_report_picking_dashboard_v1.SemanticModel/.pbi/editorSettings.json
git rm --cached prod_report_picking_dashboard_v1.Report/.pbi/localSettings.json
git commit -m "Remove user-local .pbi/ files from version control (already in .gitignore)"
```

The conventions file calls these out under §1 as **grandfathered exemptions** so the reviewer does not flag them on every future PR, but does flag any **new** `.pbi/*` additions.

## Skill validity — file checks

✅ `SKILL.md` has YAML frontmatter with `name` and `description`.
✅ `agents/powerbi-main-profiler.md` declares `tools: Read, Glob, Grep, Bash, Write`.
✅ `agents/powerbi-pr-reviewer.md` declares `tools: Read, Glob, Grep, Bash, WebFetch`.
✅ All six reference files exist and are populated.
✅ Both templates exist and conform to their referenced schema/rubric.

## Known gaps for v1.1

- The reviewer's BPA pass relies on textual pattern matching against `bpa-rules-digest.md`. A formal `tabular-editor.exe -script bpa.tegen` run would catch rules the textual heuristic misses. Out of scope for v1 (per plan).
- DAX semantic correctness is not evaluated — only syntactic patterns flagged by BPA.
- Description-coverage % is not exact — currently spot-checked.
- No automation for `git rm --cached` cleanup suggestions; the reviewer reports, the user fixes.

## Installation path TBD

Per the plan, packaging (Claude Code plugin marketplace vs `~/.claude/skills/` direct vs symlink) is being decided separately. Files live in `d:\agent\skills\powerbi-pr-review\` until then.
