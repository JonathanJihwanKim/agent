---
generated_by: powerbi-main-profiler
generated_at: <ISO-8601 UTC>
main_sha: <full SHA of main at scan time>
repo_root: .
semantic_models:
  - <name>.SemanticModel
reports:
  - <name>.Report
notes: <free-form summary — e.g. "scanned 47 tables, 312 measures, 12 pages, 84 visuals">
---

# Power BI conventions — `<repo-name>` `main` branch

Scanned by the `powerbi-main-profiler` subagent. This file is the source of truth for "how this team does Power BI." The reviewer reads it first. Edit it by hand if the profiler got something wrong, then re-commit.

## 1. Project hygiene

- `.gitignore` patterns present: <list> [consistent | inconsistent]
- Files under `.pbi/` committed (should be none): <list or "none">
- `.pbip` pointer file: <present at root | not present>
- File encoding: <UTF-8 no BOM | other> [consistent | inconsistent]
- Top-level folder naming: <pattern observed>

## 2. Semantic model — TMDL conventions

### 2.1 Naming

- Table naming: <style> [consistent | inconsistent]
- Measure naming: <style> [consistent | inconsistent]
- Column naming: <style> [consistent | inconsistent]
- Hidden technical column prefix: <pattern or "none">
- Role naming: <pattern or "none">

### 2.2 Display + organization

- Measures with `displayFolder`: <N> of <M> (<%>) — convention is <always | usually | inconsistent>
- Measure folder taxonomy: <list of folder names observed>
- Perspectives: <yes/no, details>
- Calculation groups: <yes/no, details>
- Hidden objects: <pattern>

### 2.3 DAX style

- VAR usage: <prevalent | rare>
- Comment style: <///, --, both, none>
- DIVIDE vs `/`: <DIVIDE always | mixed | / always>
- Format strings: <observed conventions>
- Time intelligence: <pattern>

### 2.4 Relationships

- Default `crossFilteringBehavior`: <oneDirection | bothDirections | mixed>
- Inactive relationships: <prevalent | rare | none>
- Cardinality patterns: <observation>

### 2.5 RLS

- Roles: <count>
- Filter expression style: <description>
- OLS in use: <yes/no>

### 2.6 Data sources + M

- Source types: <list>
- Connection parameterization: <parameterized | hardcoded | mixed>
- M pattern observations: <list>

### 2.7 Annotations + lineage

- Team-specific annotations: <list or "none">
- `lineageTag` coverage: <%>

## 3. Report — PBIR conventions

### 3.1 Format

- Format: <PBIR | PBIR-Legacy | mixed>
- `definition.pbir` reference: <byPath | byConnection | both>
- Multiple `*.pbir` files: <yes/no>

### 3.2 Pages + visuals

- Page folder naming: <default 20-char IDs | human-readable | mixed>
- Visual folder naming: <same>
- `$schema` declarations present on: <%> of JSON files
- Mobile layouts coverage: <%>

### 3.3 Theme + resources

- Theme files: <list>
- Custom visuals: <list>
- Static resources organization: <observation>

### 3.4 Bookmarks

- Count: <N>
- Grouping pattern: <observation>
- `bookmarks.json` usage: <yes/no>

## 4. Cross-cutting

- Description coverage on visible objects: <%>
- Test/debug artifacts in main: <list or "none">
- Accepted known-bad patterns: <list or "none">

## 5. Inconsistencies — flag in PR reviews

The profiler observed these patterns to be **inconsistent** across main. The reviewer should ask PR authors to pick a side, but should not call inconsistency itself a violation.

- <bullet>

## 6. Hard rules — never break

These are enforced 100% in main. Deviations in PRs are at least 🟡 Should-fix; structural deviations are 🔴 Blocker.

- <bullet>
