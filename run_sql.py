"""
Loads data/telco.csv into an in-memory SQLite database and runs every query in queries.sql.
Run:  python run_sql.py     (in Jupyter:  %run run_sql.py)
Results are printed and saved to outputs/sql_results.txt
"""
import re
import sqlite3
from pathlib import Path

import pandas as pd

df = pd.read_csv("data/telco.csv")
df["TotalCharges"] = pd.to_numeric(df["TotalCharges"], errors="coerce")
df["TotalCharges"] = df["TotalCharges"].fillna(df["MonthlyCharges"] * df["tenure"])
df["Churn"] = (df["Churn"] == "Yes").astype(int)

con = sqlite3.connect(":memory:")
df.to_sql("telco", con, index=False)

sql_text = Path("queries.sql").read_text()
blocks = re.split(r"^-- (Q\d+: .*)$", sql_text, flags=re.M)[1:]  # [title, sql, title, sql, ...]

Path("outputs").mkdir(exist_ok=True)
report = []
for title, sql in zip(blocks[0::2], blocks[1::2]):
    result = pd.read_sql_query(sql.strip().rstrip(";"), con)
    section = f"\n=== {title} ===\n{result.to_string(index=False)}\n"
    print(section)
    report.append(section)

Path("outputs/sql_results.txt").write_text("".join(report))
print("Saved to outputs/sql_results.txt")
