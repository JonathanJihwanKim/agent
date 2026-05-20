# Conventions profile schema

This is the structure the profiler subagent writes into `<repo-root>/.claude/powerbi-conventions.md`. The reviewer reads it section by section.

## Required frontmatter

```yaml
---
generated_by: powerbi-main-profiler
generated_at: <ISO-8601 UTC>
main_sha: <full SHA of main HEAD at scan time>
repo_root: <relative path of PBIP root, usually ".">
scope: <full | sampled | project-hygiene-only>
user_chose_skip: <true | false>   # true only when scope == project-hygiene-only AND the user explicitly picked "Skip profile" at the SKILL.md §3a gate; otherwise false
semantic_models:
  - <name>.SemanticModel
reports:
  - <name>.Report
sampled_models:        # required when scope == sampled; omit otherwise
  - <name>.SemanticModel
sampled_reports:       # required when scope == sampled; omit otherwise
  - <name>.Report
notes: <free-form text the profiler can add — e.g. "scanned 47 tables, 312 measures">
---
```

### `scope` values

| Value | When | Reviewer behavior |
| --- | --- | --- |
| `full` | `≤3` semantic models AND `≤3` reports on `main` — profiled exhaustively. | Treat conventions as authoritative. |
| `sampled` | More than 3 of either; user picked "Profile a sample" at the §3a gate and selected up to 3 of each. `sampled_models` / `sampled_reports` list what was actually scanned. | Treat conventions as indicative. Emit a 🔵 caveat that findings against §2 / §3 may miss models/reports not in the sample. |
| `project-hygiene-only` | User picked "Skip profile" at the §3a gate (`user_chose_skip: true`). Only §1 (project hygiene) is populated with real observations; §2 and §3 contain the stub line `No observable convention (out of scope: scope=project-hygiene-only).` in every required subsection. §1 also includes a one-line note that the skip was explicit. | Skip §2 / §3 convention passes entirely; rely on MS Learn + BPA only. Emit a 🔵 caveat. The next review run re-offers the §3a gate rather than silently reusing this stub. |

### `user_chose_skip` field

A boolean that distinguishes a deliberate skip from any other `project-hygiene-only` state:

- `false` (default) — the field is present on every conventions file. Combined with `scope: full` or `scope: sampled`, this is a normal profiled state.
- `true` — only valid when `scope == project-hygiene-only`. Signals that the user saw the §3a gate question and explicitly picked "Skip profile." Without this flag, an orchestrator encountering a `project-hygiene-only` file on a subsequent run cannot tell whether the previous user had a chance to choose. The flag preserves the audit trail.

The reviewer (and the orchestrator's Step 3 staleness check) reads this flag to decide whether to surface a 🔵 caveat with the stronger framing *"no team-norm cross-check was done"* (when `true`) versus the milder *"profile is hygiene-only"* (when `false`).

### `project-hygiene-only` stub-file expectations

When `scope == project-hygiene-only`, the file is a stub, but every required body section must still be present (see "Required sections" below). Concretely:

- **§1 Project hygiene** is populated with real observations from the target branch (`.gitignore` patterns, `.pbi/` files committed, `.pbip` pointer locations, file encoding, top-level folder naming). When `user_chose_skip: true`, the section opens with a one-line note: *"Skipped per user choice at the SKILL.md §3a gate — no §2 / §3 conventions profiled. Reviewer should cite only MS Learn + BPA and add a 🔵 caveat in the report."*
- **Every required §2 subsection (2.1–2.7)** contains the literal string `No observable convention (out of scope: scope=project-hygiene-only).` and nothing else.
- **Every required §3 subsection (3.1–3.4)** contains the same stub line.
- **§4, §5, §6** are present with `No observable convention.` if nothing applies.

This shape lets the reviewer's validation pass (every required section is present) while making the absence of profiled content explicit.

## Required sections

The body must have exactly these top-level sections, in this order. Empty sections are allowed (write "No observable convention.") but missing sections fail validation.

### 1. Project hygiene

For each finding, state the observed pattern in one sentence and tag it `[consistent]` or `[inconsistent]`.

- `.gitignore` patterns present
- Files under `.pbi/` committed (should be none)
- `.pbip` pointer file location (root, none, etc.)
- File encoding observed (BOM / no BOM, CRLF / LF)
- Top-level folder naming (e.g. `MyProject.SemanticModel/` vs `Model/`)

### 2. Semantic model — TMDL conventions

#### 2.1 Naming

- Table naming style: `<PascalCase | camelCase | snake_case | mixed>` `[consistent | inconsistent]`
- Measure naming style + casing
- Column naming style + casing
- Hidden technical column prefix (e.g. `_ID`, `Key_`)
- Role naming style

#### 2.2 Display + organization

- Measures with `displayFolder`: `<N of M>` (`<%>`) — convention is `<always | usually | inconsistent>`
- Measure folder taxonomy (the actual folder names observed)
- Perspectives in use: yes/no, and how
- Calculation groups: yes/no
- Hidden objects: pattern (e.g. "FK columns hidden, dim PKs visible")

#### 2.3 DAX style

- VAR usage: prevalent / rare
- Comment style: `///` descriptions, inline `--`, both, none
- DIVIDE vs `/` for division: which is used
- Format-string conventions (e.g. all currency = `$#,##0`)
- Time intelligence: explicit `Calendar[Date]` or `[Date]` shortcut

#### 2.4 Relationships

- Default `crossFilteringBehavior`: `<oneDirection | bothDirections | mixed>`
- Inactive relationships: prevalent / rare / none
- Cardinality patterns

#### 2.5 RLS

- Number of roles
- Filter expression style (single condition, USERPRINCIPALNAME pattern, etc.)
- Whether OLS (object-level security) is in use

#### 2.6 Data sources + M

- Source types in use (SQL, Lakehouse, Web, etc.)
- Connection parameterization: `[parameterized via expressions.tmdl | hardcoded | mixed]`
- Whether `Source = Sql.Database(Server, Database)` style is universal

#### 2.7 Annotations + lineage

- Annotation conventions (e.g. team tags like `Owner = "DataTeam"`)
- `lineageTag` presence on all objects (should be 100%)

### 3. Report — PBIR conventions

#### 3.1 Format

- PBIR or PBIR-Legacy: `<PBIR | PBIR-Legacy | mixed>`
- `definition.pbir` reference style: `byPath` / `byConnection` / both
- Multiple `*.pbir` files: yes/no (intentional pattern or accident)

#### 3.2 Pages + visuals

- Page folder naming: `<default 20-char IDs | human-readable | mixed>`
- Visual folder naming: same options
- `$schema` declarations: present on `<%>` of JSON files
- Mobile layouts: page-level coverage

#### 3.3 Theme + resources

- Theme file location and naming
- Custom-visual usage: list of `*.pbiviz` in `CustomVisuals/`
- Static resources organization

#### 3.4 Bookmarks

- Number of bookmarks
- Grouping pattern
- Use of bookmark groups in `bookmarks.json`

### 4. Cross-cutting

- Description coverage: `<%>` of visible objects have `///` descriptions
- Test/debug artifacts present in `main`: list any (these become exemptions for the reviewer)
- Known-bad patterns the team has accepted: list any (the reviewer skips these)

### 5. Inconsistencies — flag in PR reviews

A bullet list of patterns the profiler found in `main` that are **inconsistent**. The reviewer should not flag these as violations in PRs (the team itself is inconsistent) — but should ask the author to pick a side.

### 6. Hard rules — never break

A bullet list the profiler can confidently say `main` enforces 100%. Any PR deviating from these is at least 🟡, often 🔴.

## Validation

The reviewer must reject a conventions file that:

- Lacks the YAML frontmatter
- Is missing the `scope` field
- Is missing the `user_chose_skip` field
- Has `user_chose_skip: true` but `scope != project-hygiene-only`
- Has `scope: sampled` without a non-empty `sampled_models` / `sampled_reports` list
- Has `scope: project-hygiene-only` without the stub line in every required §2 / §3 subsection
- Is missing any required section
- Has an empty section without "No observable convention."
- Has a `main_sha` that doesn't match `git rev-parse <target-branch>` (mark stale, not invalid).
