# PBIP — canonical reference

Source: https://learn.microsoft.com/en-us/power-bi/developer/projects/projects-overview (updated 2025-12-15)
Source: https://learn.microsoft.com/en-us/power-bi/developer/projects/projects-git

PBIP (Power BI Project) is the **plain-text folder format** for Power BI reports + semantic models. It is currently in **preview**.

## Canonical folder structure

```
Project/
├── <name>.SemanticModel/        # see ms-learn-tmdl.md
├── <name>.Report/               # see ms-learn-pbir.md
├── .gitignore
└── <name>.pbip                  # pointer file (optional but conventional)
```

Multiple reports and semantic models can live in the same root. Each `.Report/` can be opened independently via its own `definition.pbir`. The top-level `.pbip` is just a shortcut.

## `.pbip` pointer file

- Optional. Opens the targeted report + model for authoring in Power BI Desktop.
- Schema: https://github.com/microsoft/json-schemas/tree/main/fabric/pbip/pbipProperties
- A repo can omit it entirely if Fabric Git Integration is connected — Fabric never creates it.

## `.gitignore` (Microsoft's default)

When Power BI Desktop saves a PBIP, it creates `.gitignore` with exactly two patterns:

```
**/.pbi/localSettings.json
**/.pbi/cache.abf
```

Both are user-local. **Neither should ever appear in a commit.** Flag any PR that adds them.

## What lives under `.pbi/`

- `localSettings.json` — per-user UI settings (e.g., diagram layout zoom). User-local, do not commit.
- `cache.abf` — local Analysis Services backup of the model's data. Can be **hundreds of MB**. Do not commit.
- `unappliedChanges.json` — present when there are pending edits not yet applied. Read about how this can cause expression edits to be lost.

## File encoding

- PBIP files **must** be saved as UTF-8 without BOM when edited outside Power BI Desktop.
- Power BI Desktop writes **CRLF** line endings. Configure Git `autocrlf` to avoid noisy diffs.

## Path-length gotcha

- Windows default max path is 260 chars. PBIR splits each visual into its own folder, so long table/page names can exceed the limit. **Keep the repo root path short.**

## Things the reviewer should know

- Schemas for `report.json`, `mobileState.json`, `semanticModelDiagramLayout.json`, `diagramLayout.json` are **not documented** — they're not supposed to be edited outside Power BI Desktop. Flag direct edits as risky.
- Sensitivity labels and Report Linguistic Schema are **not supported** in PBIP.
- Cannot save a PBIP directly to OneDrive/SharePoint reliably.

## Common PBIP repo violations to flag

| Pattern | Severity | Why |
| --- | --- | --- |
| `**/.pbi/cache.abf` committed | 🔴 Blocker | Large binary, leaks data, MS Learn says never commit. |
| `**/.pbi/localSettings.json` committed | 🟡 Should-fix | User-specific, conflicts when teammates pull. |
| `.gitignore` missing the two default patterns | 🟡 Should-fix | Future commits will leak local files. |
| Direct edit to `report.json` (PBIR-Legacy) or `mobileState.json` | 🟡 Should-fix | Undocumented schema, unsupported. |
| Repo root path > 200 chars before PBIP folder | 🔵 Nit | Pre-empts the 260-char Windows limit. |
| File encoding != UTF-8 without BOM | 🟡 Should-fix | Breaks Power BI Desktop reopen. |
