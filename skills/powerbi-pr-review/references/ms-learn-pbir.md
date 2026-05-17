# PBIR — canonical reference

Source: https://learn.microsoft.com/en-us/power-bi/developer/projects/projects-report (updated 2026-01-12)

PBIR (Power BI Enhanced Report format) replaces PBIR-Legacy (`report.json`). Currently in **preview**; will be the only supported format at GA. As of January 2026, new Service-created reports default to PBIR. Auto-conversion in the Service is on by default.

## Canonical folder structure

```
<name>.Report/
├── .pbi/
│   └── localSettings.json                       # user-local, gitignored
├── CustomVisuals/                               # private custom visuals (.pbiviz)
├── StaticResources/
│   └── RegisteredResources/                     # themes, images
├── definition.pbir                              # REQUIRED — references the semantic model
├── definition/                                  # REQUIRED for PBIR (replaces report.json)
│   ├── bookmarks/
│   │   ├── <bookmark>.bookmark.json
│   │   └── bookmarks.json
│   ├── pages/
│   │   ├── <pageName>/
│   │   │   ├── visuals/
│   │   │   │   └── <visualName>/
│   │   │   │       ├── visual.json              # REQUIRED
│   │   │   │       └── mobile.json
│   │   │   └── page.json                        # REQUIRED
│   │   └── pages.json
│   ├── version.json                             # REQUIRED
│   ├── reportExtensions.json                    # report-level measures
│   └── report.json                              # REQUIRED — report-level filters, theme
├── semanticModelDiagramLayout.json              # undocumented, do not edit
├── mobileState.json                             # undocumented, do not edit
└── .platform                                    # Fabric platform metadata
```

Note: in **PBIR-Legacy**, `definition/` is absent and the entire report is in a single top-level `report.json`. Flag PRs that mix the two.

## `definition.pbir` — semantic model reference

Must contain `datasetReference` with one of:

- `byPath`: `{ "path": "../<name>.SemanticModel" }` — opens model in full edit mode.
- `byConnection`: `{ "connectionString": "..." }` — live-connect, semantic model is read-only locally.

When deploying via Fabric REST API, `byConnection` is required.

## Naming conventions

- Folder/file names use **alphanumerics, underscores, and hyphens only**.
- Default folder names are 20-char unique IDs (e.g. `90c2e07d8e84e7d5c026`). Renaming is supported but you **must restart Power BI Desktop** afterward.
- Renaming the `name` property inside `*.json` files may break drillthrough or bookmark refs — handle with care.

## JSON schemas (every PBIR JSON file must declare `$schema`)

- `definition.pbir` → `https://developer.microsoft.com/json-schemas/fabric/item/report/definitionProperties/2.0.0/schema.json`
- `page.json` → `.../page/<version>/schema.json`
- `visual.json` → `.../visualContainer/<version>/schema.json`
- `report.json` → `.../report/<version>/schema.json`
- Full list: https://github.com/microsoft/json-schemas/tree/main/fabric/item/report/definition

A missing or stale `$schema` URL is a **🟡 Should-fix** (loses VS Code validation).

## Size limits (enforced by Service)

- ≤ 1,000 pages per report
- ≤ 1,000 visuals per page
- ≤ 1,000 resource package files
- ≤ 300 MB total resource package
- ≤ 300 MB total report files

## Common PBIR violations to flag

| Pattern | Severity | Why |
| --- | --- | --- |
| `report.json` (PBIR-Legacy) added alongside `definition/` folder | 🔴 Blocker | Mixed formats — only one is loaded. |
| `visual.json` missing required `$schema` declaration | 🟡 Should-fix | Loses inline schema validation. |
| `page.json` missing | 🔴 Blocker | Page won't load. |
| `version.json` missing or version downgrade | 🔴 Blocker | Reader uses version.json to decide what to load. |
| Hand-renamed page/visual folder without matching `name` in JSON | 🔴 Blocker | Power BI Desktop ignores the folder, treats as user file. |
| New visual with filter value persisted (e.g. `Company = "Contoso"`) | 🔵 Nit | Filter selection state leaks into metadata; ask if intentional. |
| Direct edit to `mobileState.json` or `semanticModelDiagramLayout.json` | 🟡 Should-fix | Undocumented schema, unsupported. |
| Bookmark file copy-pasted from another report | 🟡 Should-fix | Bookmark captures visual state that may no longer exist → silent data loss. |
| `pageBinding.name` duplicated across pages | 🔴 Blocker | Drillthrough/tooltip refs break. |
| Theme referenced in `report.json` but file missing from `RegisteredResources/` | 🔴 Blocker | Report fails to load. |
| > 500 visual files in a single report | 🟡 Should-fix | Authoring performance degrades. |

## Things the reviewer should know

- PBIR visuals can ship a `mobile.json` for mobile-layout overrides. Absence is fine; presence indicates mobile authoring.
- `reportExtensions.json` holds report-level measures (a feature reports can use without writing to the semantic model). Treat changes here with the same rigor as TMDL measure changes.
