import json
from pathlib import Path
from sqlalchemy import create_engine, text
from dotenv import load_dotenv
import os

load_dotenv()

DATABASE_URL = (
    f"postgresql://{os.getenv('DB_USER')}:"
    f"{os.getenv('DB_PASSWORD')}@"
    f"{os.getenv('DB_HOST')}:"
    f"{os.getenv('DB_PORT')}/"
    f"{os.getenv('DB_NAME')}"
)

engine = create_engine(DATABASE_URL)

raw_dir = Path("../data/raw")

rows_inserted = 0

with engine.begin() as conn:

    for file in raw_dir.glob("*.json"):

        with open(file, encoding="utf-8") as f:
            data = json.load(f)

        info = data["info"]

        if str(info.get("season")) != "2026":
            continue

        match_id = file.stem

        innings = data["innings"]

        for inning_no, inning in enumerate(innings, start=1):

            batting_team = inning["team"]

            for over in inning["overs"]:

                over_no = over["over"]

                for delivery in over["deliveries"]:

                    runs = delivery["runs"]

                    wicket = "wickets" in delivery

                    conn.execute(
                        text("""
                        INSERT INTO deliveries(
                            match_id,
                            inning_no,
                            batting_team,
                            over_no,
                            batter,
                            bowler,
                            non_striker,
                            batter_runs,
                            extras,
                            total_runs,
                            wicket
                        )
                        VALUES(
                            :match_id,
                            :inning_no,
                            :batting_team,
                            :over_no,
                            :batter,
                            :bowler,
                            :non_striker,
                            :batter_runs,
                            :extras,
                            :total_runs,
                            :wicket
                        )
                        """),
                        {
                            "match_id": match_id,
                            "inning_no": inning_no,
                            "batting_team": batting_team,
                            "over_no": over_no,
                            "batter": delivery["batter"],
                            "bowler": delivery["bowler"],
                            "non_striker": delivery["non_striker"],
                            "batter_runs": runs["batter"],
                            "extras": runs["extras"],
                            "total_runs": runs["total"],
                            "wicket": wicket
                        }
                    )

                    rows_inserted += 1

print(f"Inserted {rows_inserted} deliveries")