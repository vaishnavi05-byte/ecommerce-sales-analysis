# Dashboard guide

## A practical interview demonstration

Start on Commerce overview. Explain the delivered-order grain and why the SQL aggregates items before joining orders. Quote the eligible-delivery denominator separately from delivered orders. Select SP on the state chart: the cards change to **40,501 orders**, merchandise sales **5,067,633.16** and average order value **125.12**. Click the bar again to clear the selection.

Switch the chart metric from merchandise sales to delivered orders or late orders. The charts respond to the selected measure; the headline cards retain their own named metrics. This avoids silently relabelling a fixed KPI.

Open Delivery watch. Its default target is 5%. The full-snapshot rate is 6.77309%; its gap above the target is **1,710.5 order-equivalents**. Change the target to 10% and the full-snapshot gap becomes zero. This is an adjustable benchmark applied to observed data, not an intervention forecast. The gap is continuous and the card rounds its display to whole order-equivalents.

Open State explorer and increase the minimum eligible sample from 100 to 1,000. The qualified-rate chart suppresses states below that threshold. The evidence table deliberately keeps all selected states and their denominators visible. Filtering a chart also filters the supporting table.

Open Basket economics. Select a basket band to compare its volume, sales and delivery rate. Basket bands use the summed item counts from the source order export: one item, two items, three/four items, or five-plus items. They are not distinct-product counts.

Finish on Order explorer. Select `Missing actual date`; there should be **eight** delivered records. Order-level money in this evidence table is **integer cents** and elapsed time is **seconds**, explicitly labelled. This prevents confusing raw evidence with rounded display measures.

## English interview answer

“I expanded my Olist SQL and Excel analysis into a five-page Power BI operations suite. I used a delivered-order export with 96,478 unique orders, converted monetary data to integer cents and kept delivery eligibility explicit. The pages connect demand, geography, basket size and delivery exceptions through native filters and cross-filtering. I added a metric selector, a minimum-sample guard and an adjustable late-rate benchmark. I checked 329 native DAX results against the SQL export. The data supports descriptive operational analysis; it does not contain the cost data needed to claim product profitability or causal savings.”

## Data and calculation ownership

The original SQL owns delivery eligibility and calendar-date lateness. Python owns type normalization, cents conversion, basket bands and validation. DAX owns measures in the current filter context. Ratios are recomputed from totals, not averages of state or month percentages. The three control tables are disconnected deliberately. The data is historical and does not refresh from a live business system.
