# Metric contract

Version 1 | 2026-10-09 | Explicit project decisions

- **Order grain:** one row per `order_id`; customer records join on `customer_id`. Use `customer_unique_id` only when following a buyer across orders.
- **Item grain:** one row per (`order_id`, `order_item_id`). Count distinct order IDs for category/seller incidence; group counts can overlap.
- **Eligibility:** status `delivered`, valid purchase/actual/estimated timestamps, actual >= purchase, estimated calendar date >= purchase calendar date. Other orders stay in the mart and status counts but are excluded from delivery rate/duration denominators.
- **Late:** actual calendar date > estimated calendar date. Time of day on the promised date does not make a delivery late.
- **Late rate:** sum of late flags / sum of eligible flags. Null on zero eligible orders. On-time rate is (eligible - late)/eligible, also null on zero eligible orders.
- **Delivery days:** (actual - purchase) total seconds / 86400, only for eligible rows.
- **Delay days:** max(actual calendar date - estimated calendar date, 0), only for eligible rows.
- **Money:** BRL. `item_value` sums prices, `freight_value` sums freight, `payment_value` sums payments separately. Do not add payments to item value. No profit measure.
- **Delivered item value:** item prices on delivered-status orders. These need not all be delivery-evaluable.
- **Delivered AOV:** delivered item value / delivered-status orders with nonmissing item totals.
- **Reviews:** choose latest answer timestamp, then creation date, then lexical review ID, with missing dates ordered first. Scores outside 1-5 become missing. Keep multiple-review counts and test alternate policies if conclusions depend on them.
- **Review coverage:** orders with selected valid reviews / orders in the current population. Mean score and low-review rate use only selected valid reviews. Low review = score 1 or 2.
- **Time charts:** grouped by purchase date; outcomes may be observed later. Boundary months and unresolved orders can bias delivery comparisons.
- **Action queue:** groups with minimum eligible volume, initially 50; rank max(0, late_count - eligible_count * overall_rate). Baseline and groups share filters. This is a descriptive investigation heuristic.
- **Scenario:** C treated orders * baseline late rate * assumed relative reduction = expected late orders avoided. Require 0<=C<=N, 0<=reduction<=1, N>0. Cost applies to every treated order. Results are hypothetical, not causal or monetary recovery claims.
- **Reconciliation:** counts exact; raw-to-mart money within BRL 0.01; investigate per-order payment/item/freight differences above approximately one cent without forcing them to zero.


## Manual KPI Validation — 20-Order Audit

The audit contains 20 unique orders, including 10 with
delivered status.

- Evaluable delivered orders: 8
- Late orders: 4
- On-time or early orders: 4
- Delivered orders missing actual dates: 2
- Sample late rate: 4 / 8 = 50%

Orders with missing dates or non-delivered status are
excluded from this KPI, but retained for data-quality
reporting.

The 50% rate is from a deliberately selected validation
sample, not the overall Olist dataset.
