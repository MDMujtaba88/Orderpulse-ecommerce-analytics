-- MySQL 8+, after scripts/load_mysql.py. One statement at a time while learning.
USE orderpulse_portfolio;

-- 1. Grain: these counts must match.
SELECT COUNT(*) AS rows_n, COUNT(DISTINCT order_id) AS unique_orders
FROM fact_orders;

-- 2. Executive metrics. Monetary totals are delivered-order item value, not profit.
SELECT COUNT(*) AS total_orders,
 SUM(is_delivered) AS delivered_orders,
 SUM(eligible_delivery) AS eligible_orders,
 SUM(is_late) AS late_orders,
 SUM(is_late)/NULLIF(SUM(eligible_delivery),0) AS late_rate,
 SUM(CASE WHEN is_delivered=1 THEN item_value END) AS delivered_item_value_brl,
 SUM(CASE WHEN is_delivered=1 THEN item_value END)/
 NULLIF(SUM(CASE WHEN is_delivered=1 AND item_value IS NOT NULL THEN 1 ELSE 0 END),0) AS delivered_aov_brl,
 AVG(review_score) AS selected_review_score
FROM fact_orders;

-- 3. Monthly purchase cohorts. Edge months may be incomplete; outcomes observed later.
SELECT purchase_month,COUNT(*) AS orders_n,
 SUM(eligible_delivery) AS eligible_n,SUM(is_late) AS late_n,
 SUM(is_late)/NULLIF(SUM(eligible_delivery),0) AS late_rate
FROM fact_orders WHERE purchase_month IS NOT NULL
GROUP BY purchase_month ORDER BY purchase_month;

-- 4. States: minimum-volume rule is a configurable heuristic.
SELECT customer_state,SUM(eligible_delivery) AS eligible_n,SUM(is_late) AS late_n,
 SUM(is_late)/NULLIF(SUM(eligible_delivery),0) AS late_rate,
 AVG(delivery_days) AS avg_delivery_days
FROM fact_orders
GROUP BY customer_state HAVING SUM(eligible_delivery)>=50
ORDER BY late_n DESC;

-- 5. Reviews by delivery outcome. Association only; report denominators and coverage.
SELECT delivery_result,COUNT(*) AS orders_n,COUNT(review_score) AS reviewed_n,
 COUNT(review_score)/COUNT(*) AS review_coverage,AVG(review_score) AS avg_review,
 SUM(is_low_review)/NULLIF(COUNT(review_score),0) AS low_review_rate
FROM fact_orders WHERE eligible_delivery=1 GROUP BY delivery_result;

-- 6. Rank an investigation queue by volume above the overall observed rate.
WITH baseline AS (
 SELECT SUM(is_late)/NULLIF(SUM(eligible_delivery),0) AS overall_rate FROM fact_orders
), states AS (
 SELECT customer_state,SUM(eligible_delivery) AS eligible_n,SUM(is_late) AS late_n
 FROM fact_orders GROUP BY customer_state HAVING SUM(eligible_delivery)>=50
)
SELECT s.*,s.late_n/NULLIF(s.eligible_n,0) AS late_rate,
 GREATEST(0,s.late_n-s.eligible_n*b.overall_rate) AS above_baseline_late_orders,
 DENSE_RANK() OVER (ORDER BY GREATEST(0,s.late_n-s.eligible_n*b.overall_rate) DESC) AS investigation_rank
FROM states s CROSS JOIN baseline b ORDER BY investigation_rank,customer_state;

-- 7. Category order incidence is non-additive: one order can be in multiple categories.
SELECT product_category_name_english,
 COUNT(DISTINCT CASE WHEN eligible_delivery=1 THEN order_id END) AS eligible_orders,
 COUNT(DISTINCT CASE WHEN is_late=1 THEN order_id END) AS late_orders,
 COUNT(DISTINCT CASE WHEN is_late=1 THEN order_id END)/
 NULLIF(COUNT(DISTINCT CASE WHEN eligible_delivery=1 THEN order_id END),0) AS late_rate,
 SUM(CASE WHEN is_delivered=1 THEN price END) AS delivered_item_value_brl
FROM fact_order_items GROUP BY product_category_name_english
HAVING eligible_orders>=50 ORDER BY late_orders DESC;

-- 8. Single-seller orders reduce ambiguity; this still does NOT establish seller fault.
SELECT seller_id,COUNT(DISTINCT order_id) AS eligible_orders,
 COUNT(DISTINCT CASE WHEN is_late=1 THEN order_id END) AS late_orders
FROM fact_order_items WHERE eligible_delivery=1 AND seller_count=1
GROUP BY seller_id HAVING eligible_orders>=50 ORDER BY late_orders DESC LIMIT 20;

-- 9. Financial reconciliation: inspect differences rather than forcing equality.
SELECT order_id,item_value,freight_value,payment_value,payment_item_gap
FROM fact_orders WHERE ABS(payment_item_gap)>0.011
ORDER BY ABS(payment_item_gap) DESC LIMIT 50;

-- 10. Historical status mix, not a live operational backlog.
SELECT order_status,COUNT(*) AS orders_n FROM fact_orders GROUP BY order_status;

-- 11. Repeated buyers: customer_unique_id represents the buyer across orders.
WITH buyers AS (
 SELECT customer_unique_id,COUNT(*) AS delivered_orders
 FROM fact_orders WHERE is_delivered=1 AND customer_unique_id IS NOT NULL
 GROUP BY customer_unique_id
)
SELECT COUNT(*) AS observed_buyers,
 SUM(CASE WHEN delivered_orders>=2 THEN 1 ELSE 0 END) AS observed_repeat_buyers
FROM buyers;

-- 12. Review trend by purchase month; no assumption that reviewers represent all buyers.
SELECT purchase_month,COUNT(*) AS orders_n,COUNT(review_score) AS reviewed_n,
 AVG(review_score) AS mean_review,
 SUM(is_low_review)/NULLIF(COUNT(review_score),0) AS low_review_rate
FROM fact_orders GROUP BY purchase_month ORDER BY purchase_month;
