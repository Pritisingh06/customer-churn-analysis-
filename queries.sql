-- Telco Customer Churn: SQL analysis
-- Table: telco (one row per customer). Churn is stored as 1 = churned, 0 = stayed.

-- Q1: Overall churn rate
SELECT COUNT(*) AS total_customers,
       SUM(Churn) AS churned,
       ROUND(100.0 * SUM(Churn) / COUNT(*), 1) AS churn_rate_pct
FROM telco;

-- Q2: Churn rate by contract type
SELECT Contract,
       COUNT(*) AS customers,
       SUM(Churn) AS churned,
       ROUND(100.0 * SUM(Churn) / COUNT(*), 1) AS churn_rate_pct
FROM telco
GROUP BY Contract
ORDER BY churn_rate_pct DESC;

-- Q3: Churn rate by internet service
SELECT InternetService,
       COUNT(*) AS customers,
       ROUND(100.0 * SUM(Churn) / COUNT(*), 1) AS churn_rate_pct
FROM telco
GROUP BY InternetService
ORDER BY churn_rate_pct DESC;

-- Q4: Churn by tenure group (CASE WHEN)
SELECT CASE WHEN tenure <= 12 THEN '1. 0-12 months'
            WHEN tenure <= 24 THEN '2. 13-24 months'
            WHEN tenure <= 48 THEN '3. 25-48 months'
            ELSE '4. 49+ months' END AS tenure_group,
       COUNT(*) AS customers,
       ROUND(100.0 * SUM(Churn) / COUNT(*), 1) AS churn_rate_pct
FROM telco
GROUP BY tenure_group
ORDER BY tenure_group;

-- Q5: Average monthly charges, churned vs retained
SELECT CASE WHEN Churn = 1 THEN 'Churned' ELSE 'Stayed' END AS status,
       COUNT(*) AS customers,
       ROUND(AVG(MonthlyCharges), 2) AS avg_monthly_charges,
       ROUND(AVG(tenure), 1) AS avg_tenure_months
FROM telco
GROUP BY Churn;

-- Q6: Monthly revenue lost to churn
SELECT ROUND(SUM(CASE WHEN Churn = 1 THEN MonthlyCharges ELSE 0 END), 0) AS monthly_revenue_lost,
       ROUND(SUM(MonthlyCharges), 0) AS total_monthly_revenue,
       ROUND(100.0 * SUM(CASE WHEN Churn = 1 THEN MonthlyCharges ELSE 0 END) / SUM(MonthlyCharges), 1) AS pct_revenue_lost
FROM telco;

-- Q7: Rank payment methods by churn rate (window function)
SELECT PaymentMethod,
       ROUND(100.0 * SUM(Churn) / COUNT(*), 1) AS churn_rate_pct,
       RANK() OVER (ORDER BY 1.0 * SUM(Churn) / COUNT(*) DESC) AS churn_rank
FROM telco
GROUP BY PaymentMethod;

-- Q8: Do protective services reduce churn? (customers with vs without security and tech support)
SELECT CASE WHEN OnlineSecurity = 'Yes' AND TechSupport = 'Yes' THEN 'Both'
            WHEN OnlineSecurity = 'Yes' OR TechSupport = 'Yes' THEN 'One'
            WHEN InternetService = 'No' THEN 'No internet'
            ELSE 'Neither' END AS protection,
       COUNT(*) AS customers,
       ROUND(100.0 * SUM(Churn) / COUNT(*), 1) AS churn_rate_pct
FROM telco
GROUP BY protection
ORDER BY churn_rate_pct DESC;

-- Q9: High-risk segment (CTE): month-to-month, fiber optic, tenure up to 12 months
WITH segment AS (
    SELECT * FROM telco
    WHERE Contract = 'Month-to-month'
      AND InternetService = 'Fiber optic'
      AND tenure <= 12
)
SELECT COUNT(*) AS customers_in_segment,
       ROUND(100.0 * SUM(Churn) / COUNT(*), 1) AS segment_churn_rate_pct,
       ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM telco), 1) AS pct_of_all_customers
FROM segment;

-- Q10: Churn rate by monthly-charge quartile (NTILE)
WITH ranked AS (
    SELECT Churn, MonthlyCharges,
           NTILE(4) OVER (ORDER BY MonthlyCharges) AS charge_quartile
    FROM telco
)
SELECT charge_quartile,
       ROUND(MIN(MonthlyCharges), 2) AS min_charge,
       ROUND(MAX(MonthlyCharges), 2) AS max_charge,
       ROUND(100.0 * SUM(Churn) / COUNT(*), 1) AS churn_rate_pct
FROM ranked
GROUP BY charge_quartile
ORDER BY charge_quartile;

-- Q11: Cumulative share of churners by tenure month (running total)
WITH by_tenure AS (
    SELECT tenure, SUM(Churn) AS churners
    FROM telco
    GROUP BY tenure
)
SELECT tenure,
       churners,
       SUM(churners) OVER (ORDER BY tenure) AS cumulative_churners,
       ROUND(100.0 * SUM(churners) OVER (ORDER BY tenure) / (SELECT SUM(Churn) FROM telco), 1) AS cumulative_pct
FROM by_tenure
WHERE tenure IN (1, 3, 6, 12, 24, 36, 48, 60, 72)
ORDER BY tenure;

-- Q12: Churned customers paying above the average monthly charge (subquery)
SELECT COUNT(*) AS churned_above_avg_charge,
       ROUND(100.0 * COUNT(*) / (SELECT SUM(Churn) FROM telco), 1) AS pct_of_all_churners
FROM telco
WHERE Churn = 1
  AND MonthlyCharges > (SELECT AVG(MonthlyCharges) FROM telco);

-- Q13: Churn by number of add-on services
SELECT (OnlineSecurity = 'Yes') + (OnlineBackup = 'Yes') + (DeviceProtection = 'Yes')
       + (TechSupport = 'Yes') + (StreamingTV = 'Yes') + (StreamingMovies = 'Yes') AS num_addons,
       COUNT(*) AS customers,
       ROUND(100.0 * SUM(Churn) / COUNT(*), 1) AS churn_rate_pct
FROM telco
WHERE InternetService <> 'No'
GROUP BY num_addons
ORDER BY num_addons;

-- Q14: Churn by senior citizen, partner and dependents
SELECT SeniorCitizen, Partner, Dependents,
       COUNT(*) AS customers,
       ROUND(100.0 * SUM(Churn) / COUNT(*), 1) AS churn_rate_pct
FROM telco
GROUP BY SeniorCitizen, Partner, Dependents
HAVING COUNT(*) >= 100
ORDER BY churn_rate_pct DESC;
