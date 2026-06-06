import json
from pathlib import Path
from sqlalchemy import create_engine, text
from dotenv import load_dotenv
import os

# Load environment variables
load_dotenv()

DATABASE_URL = (
    f"postgresql://{os.getenv('DB_USER')}:"
    f"{os.getenv('DB_PASSWORD')}@"
    f"{os.getenv('DB_HOST')}:"
    f"{os.getenv('DB_PORT')}/"
    f"{os.getenv('DB_NAME')}"
)

# Create database engine
engine = create_engine(DATABASE_URL)

# Path to raw JSON files
raw_dir = Path("../data/raw")

rows_inserted = 0

with engine.begin() as conn:

    # Optional: Clear old data before re-importing
    conn.execute(text("TRUNCATE TABLE deliveries RESTART IDENTITY;"))

    for file in raw_dir.glob("*.json"):

        print(f"Processing {file.name}")

        with open(file, encoding="utf-8") as f:
            data = json.load(f)

        info = data["info"]

        # Only import 2026 season
        if str(info.get("season")) != "2026":
            continue

        match_id = file.stem

        innings = data["innings"]

        for inning_no, inning in enumerate(innings, start=1):

            batting_team = inning["team"]

            for over in inning["overs"]:

                over_no = over["over"]

                # Ball numbering starts here
                for ball_no, delivery in enumerate(over["deliveries"], start=1):

                    runs = delivery["runs"]

                    batter_runs = runs["batter"]
                    extras = runs["extras"]
                    total_runs = runs["total"]

                    # Delivery sequence example:
                    # 0.1, 0.2, 1.1, 1.2
                    delivery_sequence = float(f"{over_no}.{ball_no}")

                    # Wicket handling
                    wicket = "wickets" in delivery

                    player_out = None
                    dismissal_type = None

                    if wicket:
                        wicket_info = delivery["wickets"][0]

                        player_out = wicket_info.get("player_out")
                        dismissal_type = wicket_info.get("kind")

                    # Boundary checks
                    is_boundary = batter_runs == 4
                    is_six = batter_runs == 6

                    # Phase classification
                    if over_no <= 5:
                        phase = "Powerplay"
                    elif over_no <= 14:
                        phase = "Middle"
                    else:
                        phase = "Death"

                    # Insert into database
                    conn.execute(
                        text("""
                        INSERT INTO deliveries(
                            match_id,
                            inning_no,
                            batting_team,
                            over_no,
                            ball_no,
                            delivery_sequence,
                            batter,
                            bowler,
                            non_striker,
                            batter_runs,
                            extras,
                            total_runs,
                            wicket,
                            player_out,
                            dismissal_type,
                            is_boundary,
                            is_six,
                            phase
                        )
                        VALUES(
                            :match_id,
                            :inning_no,
                            :batting_team,
                            :over_no,
                            :ball_no,
                            :delivery_sequence,
                            :batter,
                            :bowler,
                            :non_striker,
                            :batter_runs,
                            :extras,
                            :total_runs,
                            :wicket,
                            :player_out,
                            :dismissal_type,
                            :is_boundary,
                            :is_six,
                            :phase
                        )
                        """),
                        {
                            "match_id": match_id,
                            "inning_no": inning_no,
                            "batting_team": batting_team,
                            "over_no": over_no,
                            "ball_no": ball_no,
                            "delivery_sequence": delivery_sequence,
                            "batter": delivery["batter"],
                            "bowler": delivery["bowler"],
                            "non_striker": delivery["non_striker"],
                            "batter_runs": batter_runs,
                            "extras": extras,
                            "total_runs": total_runs,
                            "wicket": wicket,
                            "player_out": player_out,
                            "dismissal_type": dismissal_type,
                            "is_boundary": is_boundary,
                            "is_six": is_six,
                            "phase": phase
                        }
                    )

                    rows_inserted += 1

print(f"\nInserted {rows_inserted} deliveries successfully.")