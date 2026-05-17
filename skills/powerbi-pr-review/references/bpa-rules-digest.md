# Best Practice Analyzer (BPA) rules — digest

Source: https://github.com/TabularEditor/BestPracticeRules (Michael Kovalsky, et al.)
Reference doc: https://docs.tabulareditor.com/te2/Best-Practice-Analyzer.html

This is the community-standard rule corpus used in Tabular Editor's BPA. The reviewer evaluates these rules **by reading TMDL**, not by running Tabular Editor. We treat each rule as a pattern to grep/inspect.

## Severity levels (BPA convention)

| Level | Meaning |
| --- | --- |
| 1 | Cosmetic — not important |
| 2 | Minor — may cause user confusion |
| 3 | Important — functional issues, perf degradation, confusion |
| 4 | Very important — elevated risk |
| 5 | Critical — guaranteed problems (deployment/processing/logical errors) |

The reviewer maps BPA levels to its own rubric (see `review-rubric.md`):

- Level 5 → 🔴 Blocker
- Level 3–4 → 🟡 Should-fix
- Level 1–2 → 🔵 Nit / question

## Rule categories (rule-name prefix)

### DAX — DAX Expressions

Representative rules:

- **DAX01** — Use DIVIDE() instead of `/`. *Why: `/` returns infinity/NaN on zero; DIVIDE returns BLANK.* **Level 3.**
- **DAX02** — Avoid `IFERROR` (use `DIVIDE` or `COALESCE`). **Level 3.**
- **DAX03** — Filter context: prefer `KEEPFILTERS` for explicit semantics in measure filters. **Level 2.**
- **DAX04** — Avoid `FIND` / `SEARCH` in row context when a fixed pattern would do. **Level 2.**
- **DAX05** — Use `SELECTEDVALUE` instead of `IF(HASONEVALUE(...), VALUES(...), ...)`. **Level 1.**
- **DAX06** — Use `TREATAS` instead of complex `INTERSECT` patterns. **Level 3.**
- **DAX07** — Avoid `EARLIER` outside calculated columns; prefer `VAR`. **Level 2.**
- **DAX08** — Avoid `VAR ... RETURN` capturing context that's then re-filtered (subtle perf trap). **Level 3.**
- **DAX09** — Hardcoded date filters (`DATE(2024, 1, 1)`) — should be parameter-driven. **Level 2.**

### PERF — Performance

- **PERF01** — Avoid calculated columns when a measure would do. *In TMDL: a `column 'X' = SUMX(...)` inside a table file.* **Level 4.**
- **PERF02** — Calculated columns should not use full-table scans. **Level 3.**
- **PERF03** — Avoid bi-directional relationships unless required (set `crossFilteringBehavior: bothDirections` in `relationships.tmdl`). **Level 4.**
- **PERF04** — Avoid many-to-many relationships when a junction dim would do. **Level 3.**
- **PERF05** — Disable Auto Date/Time (`autoDateTimeEnabled: false` in `model.tmdl`). **Level 4.**
- **PERF06** — Set `IsAvailableInMDX: false` on hidden columns used only in measures (saves memory). **Level 2.**
- **PERF07** — `summarizeBy: none` for dimension keys (don't auto-sum). **Level 3.**
- **PERF08** — Large text columns should have `dataCategory: Address/WebUrl/...` only if they truly are. **Level 2.**
- **PERF09** — Avoid `DataType: string` for numeric values stored as text. **Level 4.**
- **PERF10** — Avoid floating point (`double`) when `decimal` is correct (currency). **Level 3.**

### NAME — Naming Conventions

- **NAME01** — Object names should not start/end with whitespace. **Level 5.**
- **NAME02** — Object names should not contain leading/trailing `_`. **Level 2.**
- **NAME03** — Calculation group columns should be named `Name` and `Ordinal`. **Level 3.**
- **NAME04** — Avoid prefixing measures with the table name. **Level 1.**
- **NAME05** — Measures and columns should not share a name (causes confusion). **Level 3.**
- **NAME06** — Avoid generic names: `Column1`, `Measure 1`, `New Table`. **Level 4.**

### META — Metadata

- **META01** — Visible columns should have a `description: "..."`. **Level 1.**
- **META02** — Visible measures should have a `description: "..."`. **Level 1.**
- **META03** — Provide `formatString` on every measure. **Level 2.**
- **META04** — Provide `displayFolder` on measures. **Level 1–2** (team-dependent — see conventions file).
- **META05** — Foreign key columns should be hidden (`isHidden`). **Level 3.**
- **META06** — Primary key columns should be marked `isKey`. **Level 3.**
- **META07** — `lineageTag` must be a GUID, must not change once set. **Level 5.**
- **META08** — Annotations starting with `PBI_` are managed by Power BI — do not edit by hand. **Level 4.**

### LAYOUT — Model Layout

- **LAYOUT01** — Use perspectives to organize large models. **Level 1.**
- **LAYOUT02** — Hidden tables should have `isHidden` on the table itself, not just on every column. **Level 2.**
- **LAYOUT03** — Sort-by-column should not reference a column in a different table. **Level 4.**
- **LAYOUT04** — Calculation groups should have exactly one column. **Level 5.**

## How the reviewer evaluates a rule (pattern)

For each changed `*.tmdl` file, the reviewer:

1. Loads the file content + the relevant diff hunks.
2. Walks the BPA rules above. For each rule, identifies the TMDL token/pattern that would match.
3. Cites the rule ID (`DAX01`, `PERF03`, etc.) in the review output so the author can look up the canonical rule.

The reviewer should **not** invent BPA rule IDs. If a concern doesn't map to one of the rules above, frame it as a team-conventions deviation or a 🔵 question instead.

## Out of scope for v1

- DirectQuery / Direct Lake–specific rules (a future skill).
- Roleplay/USERELATIONSHIP rules.
- Translations / culture rules.
