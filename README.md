# Olist Operations Studio

**Five interactive native Power BI pages, 18 DAX measures and the original Excel dashboard, built from the project's audited MySQL order export.**

[Download the native PBIX](powerbi/OlistOperationsStudio.pbix) · [Editable Power BI project](powerbi/OlistOperations.pbip) · [Dashboard guide](docs/dashboard-guide.md) · [Validation](docs/native-validation.json)

![Commerce overview](docs/images/Commerce%20overview.png)

**Verified on Windows and Linux:** [GitHub Actions passed](https://github.com/vaishnavi05-byte/ecommerce-sales-analysis/actions/runs/45723282094) for the functional release `9f1e51d`. The workflow rebuilds the source and checks saved native evidence; it does not launch Power BI Desktop.

## Explore the dashboards

The original single Excel dashboard has been complemented by an original, five-page Power BI suite. Plum, lilac and mint colours, rounded chart panels, a persistent navigation rail and compact KPI cards keep the pages consistent.

| Page | Business question and interaction |
|---|---|
| Commerce overview | How do merchandise sales and demand vary? Switch sales/orders/late orders; select a month or destination state. |
| Delivery watch | Where does historical lateness exceed a chosen benchmark? Change the late-rate target and inspect the eligible denominator and missing dates. |
| State explorer | Which destinations deserve investigation? Adjust the minimum eligible-order sample and compare rates alongside sales and elapsed delivery days. |
| Basket economics | How do basket sizes differ in volume, order value and delivery outcomes? Filter basket bands and inspect the underlying counts. |
| Order explorer | Which orders support the selected result? Filter by state, date and delivery outcome, then inspect the actual order IDs. |

These are analytical report pages in Power BI Desktop. The repository does not claim a hosted Power BI Service deployment.

Open **[OlistOperationsStudio.pbix](powerbi/OlistOperationsStudio.pbix)** in current Power BI Desktop; imported snapshot data is included. For the editable PBIP, run `python scripts/configure_data_path.py`, open the project and select **Home → Refresh**.

In Desktop, Ctrl-click navigation/reset buttons; click chart bars normally. Selecting a chart filters its page; click the same item again to clear it. Reset clears current-page slicers, not chart selections or every page. Filters are intentionally page-specific. Tables scroll and retain full order evidence.

## Source and validated scope

Source: [Brazilian E-commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce), historical 2016–2018 data. The original MySQL scripts validate **99,441 orders and 112,650 item rows**. Items are aggregated before order joins to avoid multiplying order counts and sales.

The committed `data/processed/dashboard_orders.csv` is the authoritative SQL export for this dashboard. It contains one row per **delivered** order. The original raw Kaggle files are not bundled here. This suite does not report cancellation, customer retention, product profit, reviews or payment attribution from fields absent from that export.

| Full dashboard snapshot | Value |
|---|---:|
| Delivered orders | 96,478 |
| Merchandise sales, excluding freight | 13,221,498.11 source monetary units |
| Delivered items | 110,197 |
| Average order value | 137.04 |
| Eligible delivery orders | 96,470 |
| Late orders | 6,534 |
| Late-delivery rate | 6.77% |
| Average elapsed delivery time | 12.56 days |
| Missing actual delivery dates | 8 |

Late means the actual delivery **calendar date** was after the estimated calendar date. Delivery eligibility was calculated in SQL using required dates and valid sequences. Rates use eligible orders; the eight missing actual delivery dates remain visible and are excluded from delivery denominators. Elapsed days include fractional days. Boundary months are retained and may be incomplete; they are not presented as comparable growth periods.

Merchandise sales exclude freight and are not profit. No cost or margin is invented. A target is an adjustable descriptive benchmark: `max(0, late orders − eligible orders × target rate)` is the order-equivalent gap, potentially fractional, not a predicted number of prevented delays or achieved savings.

## Reproduce and verify

Python 3.11+; standard library only:

```powershell
python scripts/build_dashboards.py
python scripts/validate_native_source.py
python scripts/verify_native_results.py
```

The builder preserves the unchanged SQL export, converts money to integer cents and derives explicit basket bands and delivery outcomes. It generates the editable model and report source, not a fabricated PBIX. The PBIX is saved by Power BI Desktop after refresh.

**329 numeric comparisons** reconcile actual local Power BI engine results with the SQL CSV export: totals, 27 states, purchase months, basket sizes, a filtered SP/10% target example and the minimum-sample guard. See [the executed DAX queries](tests/native_checks.dax), [saved engine results](docs/native-dax-results.json), [build fingerprint](docs/build-validation.json) and [native reconciliation](docs/native-validation.json). CI rechecks saved evidence and source bindings; it does not launch Desktop. The official authoring CLI report separately records any unavailable-schema warnings.

The original **[Excel workbook](dashboard/Ecommerce_Analysis_Dashboard.xlsx)** and [23 MySQL scripts](sql) remain available. The workbook retains its PivotTables, PivotCharts and slicers.

## Gallery

![Delivery watch](docs/images/Delivery%20watch.png)
![State explorer](docs/images/State%20explorer.png)
![Basket economics](docs/images/Basket%20economics.png)
![Order explorer](docs/images/Order%20explorer.png)

Screenshots are captures of the actual Power BI Desktop reports. A Desktop recovery notification may appear above the report canvas; it is not part of the dashboard.
