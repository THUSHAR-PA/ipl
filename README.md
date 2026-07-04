# IPL 2026 Analytics Engine

A PostgreSQL-based cricket analytics project built using IPL 2026 ball-by-ball data.
This project focuses on advanced batting, bowling, and team analytics using structured SQL analysis and Python ETL pipelines.

---

# Project Overview

This project processes raw IPL JSON match data and converts it into an analytics-ready PostgreSQL database.

The project includes:

* Ball-by-ball delivery analysis
* Batting position reconstruction
* Phase-wise batting insights
* Bowling analytics
* Team performance analysis
* Advanced positional impact metrics

The goal was to move beyond beginner cricket statistics and build reusable analytical datasets similar to real sports analytics systems.

---

# Tech Stack

* Python
* PostgreSQL
* SQLAlchemy
* SQL
* JSON ETL Pipeline

---

# Dataset Source

Ball-by-ball IPL data sourced from:

* [Cricsheet](https://cricsheet.org/?utm_source=chatgpt.com)

---
# Data Cleaning & Transformation

The raw IPL JSON files were transformed into analytics-ready PostgreSQL tables using a custom Python ETL pipeline.

Cleaning and transformation steps included:

- Filtering only IPL 2026 matches
- Generating ball numbers and delivery sequence
- Creating phase classifications:
  - Powerplay
  - Middle Overs
  - Death Overs
- Handling wicket information and dismissal types
- Reconstructing batting positions using striker/non-striker logic
- Excluding super over innings from analysis
- Creating derived analytical tables for reusable metrics
---

# Project Structure

```txt
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
├── data/
│   └── raw/
│
├── etl/
│   └── load_deliveries.py
│
├── README.md
├── requirements.txt
└── .env
```

---

# Database Schema

## Core Tables

### `matches`

Stores match-level information.

### `deliveries`

Stores ball-by-ball IPL data.

### `dismissals`

Stores wicket and dismissal details.

---

## Derived Analytical Tables

### `batting_positions`

Reconstructs batting order using:

* striker
* non-striker
* first ball logic

### `batter_position_stats`

Stores aggregated batter statistics based on batting roles.

Example:

* Opener
* No.3
* No.4
* Finisher roles

---

# Key Features

* Ball-by-ball IPL analytics
* Batting role reconstruction
* Powerplay, Middle, and Death over analysis
* Strike rate analysis
* Boundary percentage analysis
* Bowling economy analytics
* Dot ball percentage analysis
* Team win percentage analysis
* Advanced batting position analytics

---

# Advanced Analytics Implemented
## Dot Ball Battle vs Match Outcome

Evaluated whether teams that handled dot-ball pressure better were more likely to win.

**Method**

- Calculated the dot-ball percentage for each team in every match.
- Compared both teams in the same match.
- The team with the lower dot-ball percentage was considered the winner of the dot-ball battle.

### Finding

Teams winning the dot-ball battle won

**58 of 72 completed matches (80.56%)**.

This suggests that minimizing dot balls while batting is one of the strongest indicators of match success in IPL 2026.

## Team Batting Distribution

Analyzed how each team's total runs were distributed across different batting roles.

Batting roles:

- **Top Order:** Positions 1–3
- **Middle Order:** Positions 4–5
- **Finishers:** Positions 6+

### Key Findings

- **Gujarat Titans** recorded the highest Top Order dependency (**66.20%**).
- **Punjab Kings** recorded the highest Middle Order contribution (**31.40%**).
- **Chennai Super Kings** recorded the highest Finisher contribution (**25.10%**).

The analysis is powered by a reusable analytical table (`team_batting_distribution`) that summarizes batting contributions by role.

## Death Overs Scoring Multiplier

Measures how effectively teams increase their scoring rate during the death overs compared to the middle overs.

**Metric**

Death Overs Scoring Multiplier =
Average Death Overs Run Rate ÷ Average Middle Overs Run Rate

### Finding

- Lucknow Super Giants recorded the highest acceleration.
- Their scoring rate increased by **1.33×** during the death overs.


## Powerplay Advantage vs Match Outcome

A custom team-level analysis measuring whether winning the Powerplay
translates into winning the match.

Powerplay dominance is determined using:

- Higher Powerplay runs
- Fewer wickets lost (tie-breaker)

### Finding

Teams dominating the Powerplay won:

**51 of 72 completed matches (70.83%)**

This insight is derived using the reusable `team_phase_stats`
analytical table.
## Best Openers Analysis

Compares all opening batters based on:

* runs
* strike rate
* boundary percentage

## Positional Batting Analysis

Tracks batter performance at:

* No.3
* No.4
* Finisher positions

## Phase-Based Batting Analysis

Analyzes:

* Powerplay scoring
* Death over strike rates
* Aggressive batters

## Bowling Analysis

Includes:

* Purple Cap leaderboard
* Economy rate
* Death over economy
* Dot ball percentage

---

# Example Insights

* V Suryavanshi emerged as the highest scoring opener.
* Virat Kohli maintained strong consistency as an opener.
* Rajat Patidar dominated the No.4 batting role.
* Heinrich Klaasen showed elite middle-order impact.
* Several finishers achieved strike rates above 180 in death overs.

---

# Example Queries

## Orange Cap

```sql
SELECT
    batter,
    SUM(batter_runs) AS runs
FROM deliveries
GROUP BY batter
ORDER BY runs DESC;
```

---

## Best Death Over Batter

```sql
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
```

---

# ETL Pipeline

The ETL pipeline:

1. Reads raw IPL JSON files
2. Extracts innings and delivery data
3. Generates:

   * ball number
   * delivery sequence
   * match phases
4. Loads cleaned data into PostgreSQL

---

# Future Improvements

* Data visualization dashboard
* Partnership analysis
* Match impact metrics
* Win probability modeling
* Player consistency metrics
* Streamlit dashboard integration

---

# How To Run

## Clone Repository

```bash
git clone <https://github.com/THUSHAR-PA/ipl>
```

---

## Install Requirements

```bash
pip install -r requirements.txt
```

---

## Configure Environment Variables

Create `.env`

```env
DB_USER=your_user
DB_PASSWORD=your_password
DB_HOST=localhost
DB_PORT=5432
DB_NAME=ipl
```

---

## Run ETL

```bash
python etl/load_deliveries.py
```

---

# Author

Thushar P A

---
