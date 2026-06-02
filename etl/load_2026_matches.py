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

count = 0

with engine.begin() as conn:

    for file in raw_dir.glob("*.json"):

        with open(file, "r", encoding="utf-8") as f:
            data = json.load(f)

        info = data["info"]

        season = info.get("season")

        if str(season) != "2026":
            continue

        teams = info.get("teams", [])

        if len(teams) != 2:
            continue

        outcome = info.get("outcome", {})
        toss = info.get("toss", {})
        event = info.get("event", {})

        conn.execute(
            text("""
                INSERT INTO matches (
                    match_id,
                    season,
                    stage,
                    match_date,
                    venue,
                    city,
                    team1,
                    team2,
                    winner,
                    toss_winner,
                    toss_decision
                )
                VALUES (
                    :match_id,
                    :season,
                    :stage,
                    :match_date,
                    :venue,
                    :city,
                    :team1,
                    :team2,
                    :winner,
                    :toss_winner,
                    :toss_decision
                )
                ON CONFLICT (match_id) DO NOTHING
            """),
            {
                "match_id": file.stem,
                "season": season,
                "stage": event.get("stage"),
                "match_date": info["dates"][0],
                "venue": info.get("venue"),
                "city": info.get("city"),
                "team1": teams[0],
                "team2": teams[1],
                "winner": outcome.get("winner"),
                "toss_winner": toss.get("winner"),
                "toss_decision": toss.get("decision"),
            }
        )

        count += 1

print(f"Loaded {count} matches")