# etl/explore_over.py

import json

with open(
    r"C:\Projects\ipl_analytics\data\raw\1535465.json",
    encoding="utf-8"
) as f:
    data = json.load(f)

first_innings = data["innings"][0]

print(first_innings["overs"][0])

for inning in data["innings"]:
    for over in inning["overs"]:
        for delivery in over["deliveries"]:
            if "wickets" in delivery:
                print(delivery["wickets"])
                raise SystemExit