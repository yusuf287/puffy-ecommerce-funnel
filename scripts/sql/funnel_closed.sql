-- File: closed_funnel_session_anchored.sql
-- Purpose: Build session-anchored, closed e-commerce funnel
-- Funnel: visit → view_item → add_to_cart → begin_checkout → purchase
-- Grain: (user_pseudo_id, param.ga_session_number)
-- Notes:
--   • Anchors stages to session_date (first event of session)
--   • De-dupes purchases by transaction_id
--   • Reports strict purchase (after checkout) and purchase-after-view


-- Table: `project.dataset.events`
WITH base AS (
  SELECT
    user_pseudo_id,
    CAST(param.ga_session_number AS INT64) AS ga_session_number,
    event_name,
    TIMESTAMP_MICROS(event_timestamp) AS event_time,
    DATE(TIMESTAMP_MICROS(event_timestamp)) AS event_date,
    CAST(param.transaction_id AS STRING) AS transaction_id,
    SAFE_CAST(event_value_in_usd AS FLOAT64) AS event_value_in_usd
  FROM `project.dataset.events`
),

sessions AS (
  SELECT
    user_pseudo_id, ga_session_number,
    MIN(event_time) AS ts_first_event,
    DATE(MIN(event_time)) AS session_date
  FROM base
  GROUP BY 1,2
),

stage_ts AS (
  SELECT
    s.user_pseudo_id, s.ga_session_number, s.session_date,
    MIN(IF(b.event_name IN ('first_visit','session_start'), b.event_time, NULL)) AS ts_visit,
    MIN(IF(b.event_name = 'view_item',      b.event_time, NULL)) AS ts_view,
    MIN(IF(b.event_name = 'add_to_cart',    b.event_time, NULL)) AS ts_add,
    MIN(IF(b.event_name = 'begin_checkout', b.event_time, NULL)) AS ts_checkout
  FROM sessions s
  LEFT JOIN base b
    ON b.user_pseudo_id = s.user_pseudo_id
   AND b.ga_session_number = s.ga_session_number
  GROUP BY 1,2,3
),

dedup_purchase AS (
  SELECT *
  FROM base
  WHERE event_name = 'purchase' AND transaction_id IS NOT NULL
  QUALIFY ROW_NUMBER() OVER (PARTITION BY transaction_id ORDER BY event_time DESC) = 1
),

purchase_to_session AS (
  SELECT
    user_pseudo_id, ga_session_number,
    MIN(event_time) AS ts_purchase,
    SUM(event_value_in_usd) AS revenue_usd
  FROM dedup_purchase
  GROUP BY 1,2
),

chained AS (
  SELECT
    st.*,
    IF(ts_visit IS NOT NULL, 1, 0) AS hit_visit,
    IF(ts_view IS NOT NULL AND ts_view > ts_visit, 1, 0) AS hit_view,
    IF(ts_add  IS NOT NULL AND ts_add  > ts_view  AND ts_view  > ts_visit, 1, 0) AS hit_add,
    IF(ts_checkout IS NOT NULL AND ts_checkout > ts_add AND ts_add > ts_view AND ts_view > ts_visit, 1, 0) AS hit_checkout
  FROM stage_ts st
),

chained_with_purchase AS (
  SELECT
    c.*,
    p.ts_purchase,
    p.revenue_usd,
    IF(p.ts_purchase IS NOT NULL AND p.ts_purchase > c.ts_checkout AND c.hit_checkout=1, 1, 0) AS hit_purchase_strict,
    IF(p.ts_purchase IS NOT NULL AND p.ts_purchase > c.ts_view AND c.hit_view=1, 1, 0) AS hit_purchase_after_view
  FROM chained c
  LEFT JOIN purchase_to_session p
    ON p.user_pseudo_id = c.user_pseudo_id
   AND p.ga_session_number = c.ga_session_number
),

daily AS (
  SELECT
    session_date AS date,
    SUM(hit_visit)    AS sessions,
    SUM(hit_view)     AS product_views,
    SUM(hit_add)      AS add_to_carts,
    SUM(hit_checkout) AS checkouts,
    SUM(hit_purchase_strict) AS purchases_closed,
    SUM(hit_purchase_after_view) AS purchases_after_view,
    SUM(revenue_usd) AS revenue_usd
  FROM chained_with_purchase
  GROUP BY 1
)
SELECT
  date, sessions, product_views, add_to_carts, checkouts,
  purchases_closed, purchases_after_view, revenue_usd,
  SAFE_DIVIDE(product_views, sessions)            AS cr_visit_to_view,
  SAFE_DIVIDE(add_to_carts, NULLIF(product_views,0))      AS cr_view_to_add,
  SAFE_DIVIDE(checkouts, NULLIF(add_to_carts,0))          AS cr_add_to_checkout,
  SAFE_DIVIDE(purchases_closed, NULLIF(checkouts,0))      AS cr_checkout_to_purchase,
  SAFE_DIVIDE(purchases_closed, NULLIF(sessions,0))       AS cr_visit_to_purchase_closed,
  SAFE_DIVIDE(purchases_after_view, NULLIF(sessions,0))   AS cr_visit_to_purchase_after_view
FROM daily
ORDER BY date;
