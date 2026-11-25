# Quality assurance

Verified 26 November 2026 against Power BI Desktop 2.160.1151.0.

- Refreshed the four-table imported model and rendered all five analytical pages in Desktop.
- Reconciled 329 numeric results from six actual native DAX result sets to the unchanged SQL order export.
- Tested chart cross-filtering on Commerce overview: SP selects 40,501 orders, merchandise sales 5,067,633.16 and average order value 125.12. Clicking the same bar restores 96,478 orders.
- Verified explicit opening selections: merchandise sales, 5% late-rate target and minimum 100 eligible orders. The default Olist benchmark gap is 1,710.5 order-equivalents before display rounding.
- Built the project in a clean directory using only this repository's scripts, authoring templates and SQL CSV export. The rebuilt normalized CSV matches byte-for-byte; native field bindings and saved-engine reconciliation pass.
- Saved a genuine self-contained `OlistOperationsStudio.pbix` in Desktop. ZIP CRC checks pass, the native report contains five pages and its imported DataModel exceeds 1 MB.
- Reviewed all five actual page captures and the updated resume render. Kept the original Excel file and SQL scripts intact.

The official Microsoft authoring CLI reports **zero errors**. Eight schema URLs were unavailable to that CLI's schema fetcher, and five title boxes trigger a conservative height-floor warning (40 px at the configured font). The actual rendered headings were inspected and are readable. This is not a claim of complete JSON schema validation. See `powerbi/validation-report.json`.

The raw Olist source tables are not included; this release reproduces from the previously exported delivered-order view. Original source-table SQL checks are documented in the existing SQL scripts. No new full raw-dataset reimport is claimed.
