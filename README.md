**SQL Analysis of Telecom Customer Churn**

Business questions about customer churn answered entirely with SQL: where churn is concentrated, how much revenue it costs, and which customer segments a retention team should target first.

**Tech stack:** SQL (SQLite, portable to MySQL / PostgreSQL) · Python · Pandas

This project complements my Customer Churn Prediction (ML) project, which predicts who will churn. This one explains where and why churn happens.

📁 **Dataset**

IBM Telco Customer Churn (Kaggle): 7,043 customers, 21 columns (demographics, services, contract, billing, churn status).

🧰 **SQL concepts used**

GROUP BY / HAVING · CASE WHEN · aggregate functions · subqueries · CTEs (WITH) · window functions (RANK, NTILE, running SUM() OVER)

🔍** Key findings**
**Insight	Result**
Overall churn rate	26.5% (1,869 of 7,043 customers)
Churn by contract	Month-to-month 42.7%, one-year 11.3%, two-year 2.8%
Churn by tenure	47.4% in the first 12 months, down to 9.5% after 4 years
When customers leave	About 20% of all churners leave in month 1; about 30% within the first year
Revenue impact	Churned customers account for 30.5% of monthly charges (about 139K of 456K)
Internet service	Fiber optic 41.9%, DSL 19.0%, no internet 7.4%
Support services	49.0% churn with neither online security nor tech support, vs 9.0% with both
Payment method	Electronic check 45.3%, vs 15–19% for all other methods
Add-on services (internet customers)	Churn falls from 52.2% with no add-ons to 5.3% with all six
High-risk segment	Month-to-month + fiber + tenure ≤ 12 months: 916 customers (13% of base) with 70.2% churn
Price	Churned customers pay more on average (74.44 vs 61.27 per month)

These are associations found in the data, not proof of cause.

💡 **Business recommendations**
Focus retention offers on the first 12 months, especially month-to-month fiber customers (70% churn).
Offer discounts or perks to move month-to-month customers onto annual contracts.
Bundle online security and tech support with fiber plans.
Encourage customers to switch from electronic check to automatic payment.

📋 **Questions answered (see queries.sql)**
#	**Question**
Q1	What is the overall churn rate?
Q2–Q4	How does churn vary by contract, internet service and tenure?
Q5	How do charges and tenure differ between churned and retained customers?
Q6	How much monthly revenue is lost to churn?
Q7	Which payment methods have the highest churn? (window function)
Q8	Do security and tech-support services go with lower churn?
Q9	How large and risky is the month-to-month / fiber / new-customer segment? (CTE)
Q10	Does churn rise with price? (quartiles with NTILE)
Q11	When do customers leave? (running total)
Q12	How many churners pay above the average charge? (subquery)
Q13	How does churn change with the number of add-on services?
Q14	Churn by senior citizen, partner and dependents

**Full output: outputs/sql_results.txt**

🚀 **How to run**
bash
pip install pandas
# download the dataset from Kaggle and save it as data/telco.csv
python run_sql.py

Results print to the screen and are saved to outputs/sql_results.txt. To use MySQL instead, load the CSV into a table named telco (convert Churn to 1/0) and run queries.sql.


📁 Project structure
sql-churn-analysis/
├── data/              # place telco.csv here (not included)
├── outputs/
│   └── sql_results.txt
├── queries.sql        # all 14 queries, documented
├── run_sql.py         # loads the CSV into SQLite and runs the queries
sql-churn-analysis/
├── data/              # place telco.csv here (not included)
├── outputs/
│   └── sql_results.txt
├── queries.sql        # all 14 queries, documented
├── run_sql.py         # loads the CSV into SQLite and runs the queries
