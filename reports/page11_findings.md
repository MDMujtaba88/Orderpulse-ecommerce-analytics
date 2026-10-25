# OrderPulse — Python Analysis Findings

## Data
- Historical Brazilian Olist e-commerce dataset.
- 99,441 orders; 96,470 eligible delivered orders.
- All monetary figures are BRL.

## Chart 1 — Monthly Orders
Question: When was order volume highest?
Finding: November 2017 had 7,544 orders, the highest monthly count.
Limit: Order volume is not revenue or profit.

## Chart 2 — Monthly Late Deliveries
Question: When were late deliveries most common?
Finding: 6,534 of 96,470 eligible deliveries were late (6.77%).
March 2018 had the highest observed monthly rate, 18.96%,
among months with at least 50 eligible orders.
Limit: September and October 2018 had zero eligible deliveries;
they must not be presented as months with perfect delivery performance.

## Chart 3 — Delivery Performance by State
Question: Which states warrant investigation?
Finding: SP had 1,820 late orders (4.49%).
RJ had 1,495 late orders (12.11%).
AL had the highest qualifying state late rate (21.41%).
Interpretation: RJ is a notable candidate combining
substantial late-order volume and an above-average late rate.
Limit: Regional differences do not establish their underlying causes.

## Chart 4 — Delivery Duration
Question: How long do deliveries take?
Finding: Mean 13.19 days; median 10.83 days;
90th percentile 23.77 days; maximum 210.61 days.
Limit: Extreme values need investigation, not automatic deletion.

## Chart 5 — Customer Satisfaction
Question: Are delays associated with lower reviews?
Finding: On-time reviewed orders averaged 4.29/5;
late reviewed orders averaged 2.27/5.
Low-review rates: 9.27% on time versus 62.42% late.
Review coverage: 99.45% on time versus 97.66% late.
Limit: Association does not prove causation.

## Chart 6 — Product Categories
Question: Which categories have the highest delivered item value?
Finding: Health & Beauty leads with R$1,233,131.72.
Total delivered item value: R$13,221,498.11.
Limit: Item value excludes freight and is not profit.
Distinct order counts across categories are non-additive.

## Deeper Analysis — Repeat Buyers
Unique customers: 96,096.
Repeat customers: 2,997 (3.12%).
Orders from repeat customers: 6,342.
Limit: Historical repeat purchasing is not a formal retention rate.

## Next Research Questions
- Does the late-review association hold within major states?
- Does changing the minimum state sample size alter priorities?
- Are recent purchase months affected by incomplete follow-up?
- How does selecting a different review per order affect results?
