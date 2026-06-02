# etl/load_matches.py

import json

file_path = r"C:\Projects\ipl_analytics\data\raw\1535465.json"   # replace with an actual file

with open(file_path, "r", encoding="utf-8") as f:
    data = json.load(f)

print(data["info"].keys())

with open(file_path, "r", encoding="utf-8") as f:
    data = json.load(f)

info = data["info"]

print(info.keys())

print("Season:", info["season"])
print("Event:", info["event"])
print("Teams:", info["teams"])
print("Outcome:", info["outcome"])
print("Toss:", info["toss"])