CREATE DATABASE tata_steel_db;
USE tata_steel_db;

CREATE TABLE financials (
  id INT AUTO_INCREMENT PRIMARY KEY,
  fiscal_year VARCHAR(10) NOT NULL,
  revenue DECIMAL(15,2),
  ebitda DECIMAL(15,2),
  net_profit DECIMAL(15,2),
  total_expense DECIMAL(15,2),
  total_debt DECIMAL(15,2),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(fiscal_year)
);
INSERT INTO financials
  (fiscal_year, revenue, ebitda, net_profit, total_expense, total_debt)
VALUES
  ('FY2020', 146521.00, 14009.00,  -1135.00, 132512.00, 100842.00),
  ('FY2021', 140046.00, 20059.00,   6621.00, 119987.00,  86330.00),
  ('FY2022', 203250.00, 32698.00,  40154.00, 170552.00,  75820.00),
  ('FY2023', 243353.00, 32698.00,   8760.00, 210655.00,  72400.00),
  ('FY2024', 229171.00, 23402.00,   7673.00, 205769.00,  73600.00);
  SELECT
  SUM(revenue)       AS total_revenue,
  SUM(ebitda)        AS total_ebitda,
  SUM(net_profit)    AS total_net_profit,
  COUNT(*)           AS total_years,
  ROUND(AVG(revenue), 2) AS avg_revenue
FROM financials;
SELECT
  fiscal_year,
  revenue,
  ebitda,
  net_profit,
  total_expense,
  ROUND((ebitda / revenue) * 100, 2)      AS ebitda_margin_pct,
  ROUND((net_profit / revenue) * 100, 2)  AS net_margin_pct,
  ROUND(((revenue - total_expense) / revenue) * 100, 2) AS operating_margin_pct
FROM financials
ORDER BY fiscal_year DESC;
-- Best Year by Revenue
SELECT fiscal_year, revenue
FROM financials
ORDER BY revenue DESC LIMIT 1;

-- Best Year by Profitability
SELECT fiscal_year, net_profit
FROM financials
ORDER BY net_profit DESC LIMIT 1;

-- Worst Year by Net Profit
SELECT fiscal_year, net_profit
FROM financials
ORDER BY net_profit ASC LIMIT 1;
SELECT
  curr.fiscal_year,
  curr.revenue,
  prev.revenue AS prev_revenue,
  ROUND(((curr.revenue - prev.revenue) / prev.revenue) * 100, 2) AS yoy_revenue_growth_pct,
  curr.ebitda,
  prev.ebitda AS prev_ebitda,
  ROUND(((curr.ebitda - prev.ebitda) / prev.ebitda) * 100, 2) AS yoy_ebitda_growth_pct
FROM financials curr
JOIN financials prev ON curr.id = prev.id + 1
ORDER BY curr.fiscal_year;
SELECT
  fiscal_year,
  total_debt,
  LAG(total_debt) OVER (ORDER BY fiscal_year) AS prev_debt,
  ROUND(total_debt - LAG(total_debt) OVER (ORDER BY fiscal_year), 0) AS debt_change,
  ROUND(((total_debt - LAG(total_debt) OVER (ORDER BY fiscal_year))
    / LAG(total_debt) OVER (ORDER BY fiscal_year)) * 100, 2) AS debt_change_pct
FROM financials
ORDER BY fiscal_year;
SELECT
  fiscal_year,
  revenue,
  ebitda,
  net_profit,
  ROUND((ebitda / revenue) * 100, 2) AS ebitda_margin,
  ROUND((net_profit / revenue) * 100, 2) AS net_profit_margin,
  CASE
    WHEN (ebitda / revenue) * 100 >= 15 THEN 'Excellent'
    WHEN (ebitda / revenue) * 100 >= 12 THEN 'Good'
    WHEN (ebitda / revenue) * 100 >= 10 THEN 'Average'
    ELSE 'Below Average'
  END AS margin_rating
FROM financials
ORDER BY fiscal_year DESC;
SELECT
  fiscal_year,
  revenue,
  ebitda,
  net_profit,
  SUM(revenue) OVER (ORDER BY fiscal_year) AS cumulative_revenue,
  SUM(net_profit) OVER (ORDER BY fiscal_year) AS cumulative_profit,
  COUNT(*) OVER (ORDER BY fiscal_year) AS year_count
FROM financials
ORDER BY fiscal_year;
SELECT
  'Total Revenue' AS metric, SUM(revenue) AS value, 'Cr' AS unit FROM financials
UNION ALL
SELECT 'Total EBITDA', SUM(ebitda), 'Cr' FROM financials
UNION ALL
SELECT 'Total Net Profit', SUM(net_profit), 'Cr' FROM financials
UNION ALL
SELECT 'Avg EBITDA Margin %', ROUND(AVG((ebitda/revenue)*100), 2), '%' FROM financials
UNION ALL
SELECT 'Debt Reduction', 100842 - 73600, 'Cr' FROM financials LIMIT 1
UNION ALL
SELECT 'Peak Revenue Year', 243353, 'FY23' FROM financials LIMIT 1;