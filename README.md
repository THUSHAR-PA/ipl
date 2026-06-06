# IPL 2026 Analytics Engine

Advanced IPL analytics project using PostgreSQL, Python ETL pipelines, and ball-by-ball cricket data.

IPL 2026 Analytics Engine

A PostgreSQL-based cricket analytics project built using IPL 2026 ball-by-ball data.
This project focuses on advanced batting, bowling, and team analytics using structured SQL analysis and Python ETL pipelines.

Project Overview

This project processes raw IPL JSON match data and converts it into an analytics-ready PostgreSQL database.

The project includes:

Ball-by-ball delivery analysis
Batting position reconstruction
Phase-wise batting insights
Bowling analytics
Team performance analysis
Advanced positional impact metrics

The goal was to move beyond beginner cricket statistics and build reusable analytical datasets similar to real sports analytics systems.


Tech Stack
Python
PostgreSQL
SQLAlchemy
SQL
JSON ETL Pipeline
Dataset Source

Ball-by-ball IPL data sourced from:

Cricsheet:https://cricsheet.org/?utm_source=chatgpt.com

Project Structure


ipl_analytics/
│
├── analysis/
│   ├── batting_analysis.sql
│   ├── bowling_analysis.sql
│   ├── team_analysis.sql
│   ├── advanced_analysis.sql
│   ├── derived_tables.sql
│   └── validation_queries.sql
│
|__   api/
|
|__ dashboard/
|
├── data/
│   └── raw/
│
|
|__database/
|
├── etl/
│   └── load_deliveries.py
│
|__notebooks
|
|__scraper
|
|
├── README.md
├── requirements.txt
└── .env


Database Schema
Core Tables
matches

Stores match-level information.

deliveries

Stores ball-by-ball IPL data.

dismissals

Stores wicket and dismissal details.

Derived Analytical Tables
batting_positions

Reconstructs batting order using:

striker
non-striker
first ball logic
batter_position_stats

Stores aggregated batter statistics based on batting roles.

Example:

Opener
No.3
No.4
Finisher roles



Key Features

✔ Ball-by-ball IPL analytics
✔ Batting role reconstruction
✔ Powerplay, Middle, and Death over analysis
✔ Strike rate analysis
✔ Boundary percentage analysis
✔ Bowling economy analytics
✔ Dot ball percentage analysis
✔ Team win percentage analysis
✔ Advanced batting position analytics




Advanced Analytics Implemented
Best Openers Analysis

Compares all opening batters based on:

runs
strike rate
boundary percentage
Positional Batting Analysis

Tracks batter performance at:

No.3
No.4
Finisher positions
Phase-Based Batting Analysis

Analyzes:

Powerplay scoring
Death over strike rates
Aggressive batters
Bowling Analysis

Includes:

Purple Cap leaderboard
Economy rate
Death over economy
Dot ball percentage


Example Insights
V Suryavanshi emerged as the highest scoring opener.
Virat Kohli maintained strong consistency as an opener.
Rajat Patidar dominated the No.4 batting role.
Heinrich Klaasen showed elite middle-order impact.
Several finishers achieved strike rates above 180 in death overs.


Example Queries
Orange Cap
SELECT
    batter,
    SUM(batter_runs) AS runs
FROM deliveries
GROUP BY batter
ORDER BY runs DESC;

Best Death Over Batter

SELECT
    batter,
    ROUND(
        SUM(batter_runs)*100.0/COUNT(*),
        2
    ) AS strike_rate
FROM deliveries
WHERE phase = 'Death'
GROUP BY batter
HAVING COUNT(*) > 20
ORDER BY strike_rate DESC;

ETL Pipeline

The ETL pipeline:

Reads raw IPL JSON files
Extracts innings and delivery data
Generates:
ball number
delivery sequence
match phases
Loads cleaned data into PostgreSQL



Future Improvements
Data visualization dashboard
Partnership analysis
Match impact metrics
Win probability modeling
Player consistency metrics
Streamlit dashboard integration

How To Run
Clone Repository
git clone <https://github.com/THUSHAR-PA/ipl>

Install Requirements
pip install -r requirements.txt



Configure Environment Variables

Create .env

DB_USER=your_user
DB_PASSWORD=your_password
DB_HOST=localhost
DB_PORT=5432
DB_NAME=ipl


Run ETL
python etl/load_deliveries.py


Author

Thushar P A