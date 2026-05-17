# TMDL — canonical reference

Source: https://learn.microsoft.com/en-us/analysis-services/tmdl/tmdl-overview (updated 2026-02-02)
Source: https://learn.microsoft.com/en-us/power-bi/developer/projects/projects-dataset

TMDL (Tabular Model Definition Language) is the **YAML-like text format** for semantic models at compatibility level 1200+. Files have `.tmdl` extension. Full bidirectional parity with the Tabular Object Model (TOM).

## Canonical folder structure

```
<name>.SemanticModel/
└── definition/
    ├── cultures/
    │   └── <culture>.tmdl              # one per culture
    ├── perspectives/
    │   └── <perspective>.tmdl          # one per perspective
    ├── roles/
    │   └── <role>.tmdl                 # one per role
    ├── tables/
    │   └── <table>.tmdl                # one per table
    ├── relationships.tmdl              # ALL relationships in one file
    ├── functions.tmdl                  # ALL DAX UDFs in one file
    ├── expressions.tmdl                # ALL shared expressions in one file
    ├── dataSources.tmdl                # ALL data sources in one file
    ├── model.tmdl                      # model-level metadata + ref ordering
    └── database.tmdl                   # database-level metadata
```

Plus a `.pbi/` subfolder for user-local settings (gitignored).

**All inner table metadata** (columns, hierarchies, partitions, measures) lives in the parent table's `.tmdl` file. Tables are not split into multiple files unless using TMDL "partial declaration" (rare).

## Grammar essentials

- **Single tab** indentation is the default. Indentation is significant (parser will error on inconsistency).
- Three levels: object declaration → object properties → multi-line expressions.
- Property values use `:` delimiter. Default-property expressions use `=` delimiter.
- Boolean shortcut: `isHidden` (alone on a line) = `isHidden: true`.
- Names with `.`, `=`, `:`, `'`, or whitespace must be enclosed in single quotes. Double single quotes to escape.
- Object refs use the same quoting rules. Fully-qualified refs use dot notation: `'Table 1'.'Column 1'`.
- Descriptions use triple-slash `///` on the line(s) immediately above the object — first-class language feature.

## `model.tmdl` — `ref` ordering

`model.tmdl` declares object ordering with `ref` keyword to avoid noisy diffs:

```tmdl
model Model
    culture: en-US

ref table Calendar
ref table Sales
ref table Product

ref role 'Stores Cluster 1'
ref culture en-US
```

- Objects with a TMDL file but missing from `model.tmdl` get appended to the end of their collection.
- Objects referenced but with no TMDL file are silently ignored.
- Re-serialization always emits `ref` for every collection — flag PRs that delete `ref` lines.

## Properties treated as expressions (parsed verbatim)

| Object | Property | Language |
| --- | --- | --- |
| Measure | Expression | DAX |
| Function | Expression | DAX |
| CalculatedColumn | Expression | DAX |
| CalculationItem | Expression | DAX |
| MPartitionSource | Expression | M |
| TablePermission | FilterExpression | DAX (RLS) |
| FormatStringDefinition | Expression | DAX |
| KPI (Status / Target / Trend) | Expression | DAX |
| BasicRefreshPolicy (Source / Polling) | Expression | M |

Multi-line expressions must be indented one level deeper than parent properties; use ` ``` ` triple-backtick fences only when whitespace must be preserved verbatim.

## Common TMDL violations to flag

| Pattern | Severity | Why |
| --- | --- | --- |
| New table in `tables/` but no `ref table` in `model.tmdl` | 🟡 Should-fix | Table appears at end of collection — breaks intended ordering. |
| Inconsistent indentation (tabs ↔ spaces) inside one file | 🔴 Blocker | TMDL parser errors. |
| Property name in PascalCase instead of camelCase (e.g. `IsHidden:`) | 🟡 Should-fix | TMDL serializer writes camelCase; mixed case causes roundtrip churn. |
| Single-line measure when adding a new measure | 🔵 Nit | Multi-line + 4-space-indented DAX is the readable convention. |
| Missing `///` description on visible measure or column | 🔵 Nit | MS Learn calls description-coverage a best practice. |
| Calculated column doing aggregation (`SUMX`, `COUNTROWS`, etc.) | 🟡 Should-fix | Should be a measure (BPA rule PERF). |
| Hardcoded data source paths in `dataSources.tmdl` | 🟡 Should-fix | Should parameterize via `expressions.tmdl`. |
| `lineageTag` changed or removed on existing object | 🔴 Blocker | Breaks downstream report/Fabric references. |
| Two measures with the same name across files | 🔴 Blocker | TMDL deserializer errors. |

## Hidden / system tables to ignore in review

- `DateTableTemplate_*`, `LocalDateTable_*` — auto-generated when Auto-date-time is on. Should not be edited by hand. Flag manual edits.
