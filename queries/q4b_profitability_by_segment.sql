-- Q4b: Profitability by segment — VBR vs Fixed (Mar-Aug 2026), PER CUSTOMER & PER AGREEMENT
WITH customer_segments AS (
  SELECT DISTINCT
    cje.customer_account,
    apc.segment,
    apc.contract_type
  FROM be_datascience_prd.test.fact_customer_journey_events cje
  JOIN fact_agreement_monthly_profitability_charges apc
    ON cje.agreement_id = apc.agreement_id
  WHERE apc.period_start >= '2026-03-01'
    AND apc.period_start < '2026-09-01'
),
customer_base AS (
  SELECT
    segment,
    contract_type,
    COUNT(DISTINCT customer_account) AS distinct_customers
  FROM customer_segments
  GROUP BY segment, contract_type
),
profitability_by_segment AS (
  SELECT
    segment,
    contract_type,
    COUNT(DISTINCT agreement_id) AS agreements,
    ROUND(SUM(revenue), 0) AS total_revenue,
    ROUND(SUM(profitability), 0) AS total_profitability
  FROM fact_agreement_monthly_profitability_charges
  WHERE contract_type IN ('Fixed', 'VBR')
    AND period_start >= '2026-03-01'
    AND period_start < '2026-09-01'
  GROUP BY segment, contract_type
)
SELECT
  p.segment,
  p.contract_type,
  p.agreements,
  cb.distinct_customers,
  p.total_revenue,
  p.total_profitability,
  ROUND(CASE WHEN p.total_revenue != 0 THEN p.total_profitability / p.total_revenue * 100 END, 2) AS profitability_pct,
  ROUND(p.total_profitability / p.agreements, 2) AS profitability_per_agreement,
  ROUND(p.total_profitability / cb.distinct_customers, 2) AS profitability_per_customer
FROM profitability_by_segment p
JOIN customer_base cb ON p.segment = cb.segment AND p.contract_type = cb.contract_type
ORDER BY p.segment, p.contract_type;
