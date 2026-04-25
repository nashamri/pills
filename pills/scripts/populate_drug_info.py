#!/usr/bin/env python
import csv
import sqlite3

DB = "../test.db"
CSV = "../assets/Human Drugs Products Local.csv"

con = sqlite3.connect(DB)
cur = con.cursor()

cur.execute("DROP TABLE IF EXISTS drug_info")
cur.execute("""
CREATE TABLE drug_info (
    id                   INTEGER PRIMARY KEY AUTOINCREMENT,
    trade_name           TEXT,
    scientific_name      TEXT,
    size                 TEXT,
    size_unit            TEXT,
    legal_status         TEXT,
    manufacture_name     TEXT,
    authorization_status TEXT
)
""")

with open(CSV, newline="", encoding="utf-8-sig") as f:
    reader = csv.DictReader(f)
    seen = set()
    rows = []
    for row in reader:
        key = (
            row["TradeName"], row["ScientificName"], row["Size"],
            row["SizeUnit"], row["LegalStatus"], row["Manufacture_Name"],
            row["AuthorizationStatus"],
        )
        if key not in seen:
            seen.add(key)
            rows.append(key)

cur.executemany(
    """INSERT INTO drug_info
       (trade_name, scientific_name, size, size_unit, legal_status,
        manufacture_name, authorization_status)
       VALUES (?,?,?,?,?,?,?)""",
    rows,
)

con.commit()
con.close()
print(f"Inserted {len(rows)} rows into drug_info.")
