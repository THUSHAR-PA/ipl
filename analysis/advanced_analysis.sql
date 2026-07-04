




-- Batter Ranking based on their imapct at each position they played




WITH batter_stats AS (

    SELECT
        bp.batting_position,
        d.batter,
        d.batting_team,

        SUM(d.batter_runs) AS runs,

        COUNT(*) AS balls,

        ROUND(
            SUM(d.batter_runs) * 100.0 / COUNT(*),
            2
        ) AS strike_rate,

        ROUND(
            SUM(
                CASE
                    WHEN d.batter_runs IN (4, 6)
                    THEN 1
                    ELSE 0
                END
            ) * 100.0 / COUNT(*),
            2
        ) AS boundary_percentage

    FROM deliveries d

    JOIN batting_positions bp
        ON d.match_id = bp.match_id
       AND d.inning_no = bp.inning_no
       AND d.batter = bp.batter

    WHERE d.inning_no IN (1, 2)

    GROUP BY
        bp.batting_position,
        d.batter,
        d.batting_team
)

SELECT *,
       RANK() OVER (
           PARTITION BY batting_position
           ORDER BY runs DESC
       ) AS position_rank

FROM batter_stats

WHERE balls >= 30

ORDER BY
    batting_position,
    position_rank;




-- Query to view the best opener by runs


    SELECT *
FROM batter_position_stats
WHERE batting_role = 'Opener'
ORDER BY runs DESC;






/*=========================================================
            ADVANCED INSIGHTS
=========================================================*/

----------------------------------------------------------
-- Insight 1 : Powerplay Advantage vs Match Outcome
----------------------------------------------------------

/*
Business Question:
Does dominating the Powerplay increase the probability
of winning the match?

Definition:
Powerplay Dominance is determined by:
1. Higher Powerplay runs.
2. If runs are tied, fewer wickets lost.

Finding:
Teams dominating the Powerplay won
70.83% of completed IPL 2026 matches
(51 out of 72 matches).
*/

WITH ranked_powerplays AS (

    SELECT

        match_id,
        batting_team,
        runs,
        wickets_lost,

        ROW_NUMBER() OVER(

            PARTITION BY match_id

            ORDER BY
                runs DESC,
                wickets_lost ASC

        ) AS powerplay_rank

    FROM team_phase_stats

    WHERE phase = 'Powerplay'

)

SELECT

    m.match_id,

    m.team1,

    m.team2,

    rp.batting_team AS powerplay_dominant_team,

    rp.runs,

    rp.wickets_lost,

    m.winner,

    CASE

        WHEN rp.batting_team = m.winner
        THEN 'Won Match'

        ELSE 'Lost Match'

    END AS outcome

FROM ranked_powerplays rp

JOIN matches m

ON rp.match_id = m.match_id

WHERE powerplay_rank = 1

ORDER BY m.match_id;

/*---------------------------------------------------------
Summary Statistics
---------------------------------------------------------*/

WITH ranked_powerplays AS (

    SELECT
        match_id,
        batting_team,
        runs,
        wickets_lost,

        ROW_NUMBER() OVER(

            PARTITION BY match_id

            ORDER BY
                runs DESC,
                wickets_lost ASC

        ) AS powerplay_rank

    FROM team_phase_stats

    WHERE phase = 'Powerplay'

),

results AS (

    SELECT

        m.match_id,

        CASE

            WHEN rp.batting_team = m.winner
            THEN 1

            ELSE 0

        END AS won_after_dominating

    FROM ranked_powerplays rp

    JOIN matches m

    ON rp.match_id = m.match_id

    WHERE powerplay_rank = 1

      AND m.winner IS NOT NULL

)

SELECT

    COUNT(*) AS matches,

    SUM(won_after_dominating) AS successful_predictions,

    COUNT(*) - SUM(won_after_dominating) AS unsuccessful_predictions,

    ROUND(
        AVG(won_after_dominating) * 100,
        2
    ) AS success_percentage

FROM results;


/*=========================================================
Insight 2 : Death Overs Scoring Multiplier
=========================================================*/

/*
Business Question:
Which IPL teams accelerate their scoring the most
during the death overs?

Definition:
Death Overs Scoring Multiplier =
Average Death Overs Run Rate
/
Average Middle Overs Run Rate

Finding:
Lucknow Super Giants recorded the highest
Death Overs Scoring Multiplier
with a multiplier of 1.33x.
*/

WITH phase_run_rates AS (

    SELECT

        batting_team,

        AVG(
            CASE
                WHEN phase = 'Middle'
                THEN run_rate
            END
        ) AS middle_run_rate,

        AVG(
            CASE
                WHEN phase = 'Death'
                THEN run_rate
            END
        ) AS death_run_rate

    FROM team_phase_stats

    GROUP BY batting_team

)

SELECT

    batting_team,

    ROUND(middle_run_rate,2) AS middle_run_rate,

    ROUND(death_run_rate,2) AS death_run_rate,

    ROUND(
        death_run_rate /
        NULLIF(middle_run_rate,0),
        2
    ) AS acceleration_multiplier

FROM phase_run_rates

ORDER BY acceleration_multiplier DESC;


/*=========================================================
Insight 3 : Team Batting Distribution
=========================================================*/

/*
Business Question:
How are a team's runs distributed across the batting order?

Batting groups:

Top Order    : Positions 1-3

Middle Order : Positions 4-5

Finishers    : Positions 6+

Finding:

• Gujarat Titans were the most top-order dependent team,
  with 66.20% of their runs coming from the top three batters.

• Punjab Kings received the highest middle-order contribution,
  with 31.40% of runs coming from positions 4-5.

• Chennai Super Kings received the highest finisher contribution,
  with 25.10% of runs coming from batters at position 6 or below.
*/

SELECT

    batting_team,

    top_order_pct,

    middle_order_pct,

    finisher_pct

FROM team_batting_distribution

ORDER BY top_order_pct DESC;