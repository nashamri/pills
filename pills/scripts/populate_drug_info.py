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
    drug_type            TEXT,
    legal_status         TEXT,
    manufacture_name     TEXT,
    manufacture_country  TEXT,
    authorization_status TEXT,
    last_update          TEXT
)
""")

with open(CSV, newline="", encoding="utf-8-sig") as f:
    reader = csv.DictReader(f)
    rows = [
        (
            row["TradeName"], row["ScientificName"], row["Size"],
            row["SizeUnit"], row["DrugType"], row["LegalStatus"],
            row["Manufacture_Name"], row["Manufacture_Country"],
            row["AuthorizationStatus"], row["LastUpdate"],
        )
        for row in reader
    ]

cur.executemany(
    """INSERT INTO drug_info
       (trade_name, scientific_name, size, size_unit, drug_type, legal_status,
        manufacture_name, manufacture_country, authorization_status, last_update)
       VALUES (?,?,?,?,?,?,?,?,?,?)""",
    rows,
)

con.commit()
con.close()
print(f"Inserted {len(rows)} rows into drug_info.")
