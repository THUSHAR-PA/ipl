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

        for inning_no, inning in enumerate(data["innings"], start=1):

            for over in inning["overs"]:

                for delivery in over["deliveries"]:

                    if "wickets" not in delivery:
                        continue

                    for wicket in delivery["wickets"]:

                        conn.execute(
                            text("""
                            INSERT INTO dismissals (
                                match_id,
                                inning_no,
                                batter,
                                bowler,
                                dismissal_kind
                            )
                            VALUES (
                                :match_id,
                                :inning_no,
                                :batter,
                                :bowler,
                                :dismissal_kind
                            )
                            """),
                            {
                                "match_id": match_id,
                                "inning_no": inning_no,
                                "batter": wicket["player_out"],
                                "bowler": delivery["bowler"],
                                "dismissal_kind": wicket["kind"]
                            }
                        )

                        rows_inserted += 1

print(f"Inserted {rows_inserted} dismissals")