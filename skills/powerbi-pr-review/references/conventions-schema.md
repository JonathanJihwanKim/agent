# Conventions profile schema

This is the structure the profiler subagent writes into `<repo-root>/.claude/powerbi-conventions.md`. The reviewer reads it section by section.

## Required frontmatter

```yaml
---
generated_by: powerbi-main-profiler
generated_at: <ISO-8601 UTC>
main_sha: <full SHA of main HEAD at scan time>
repo_root: <relative path of PBIP root, usually ".">
semantic_models:
  - <name>.SemanticModel
reports:
  - <name>.Report
notes: <free-form text the profiler can add — e.g. "scanned 47 tables, 312 measures">
---
```

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
- Is missing any required section
- Has an empty section without "No observable convention."
- Has a `main_sha` that doesn't match `git rev-parse <target-branch>` (mark stale, not invalid).
