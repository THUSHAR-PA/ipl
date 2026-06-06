//INSERTING DATA INTO BATTING_POSITION TABLE

WITH first_ball AS (

    SELECT
        match_id,
        inning_no,
        batter AS opener_1,
        non_striker AS opener_2
    FROM deliveries
    WHERE over_no = 0
      AND ball_no = 1
),

other_batters AS (

    SELECT
        match_id,
        inning_no,
        batter,
        MIN(delivery_sequence) AS first_delivery
    FROM deliveries
    WHERE inning_no IN (1, 2)

    GROUP BY
        match_id,
        inning_no,
        batter
),

ranked_batters AS (

    SELECT
        ob.match_id,
        ob.inning_no,
        ob.batter,

        ROW_NUMBER() OVER (
            PARTITION BY ob.match_id, ob.inning_no
            ORDER BY ob.first_delivery
        ) + 2 AS batting_position

    FROM other_batters ob

    JOIN first_ball fb
        ON ob.match_id = fb.match_id
       AND ob.inning_no = fb.inning_no

    WHERE ob.batter NOT IN (
        fb.opener_1,
        fb.opener_2
    )
)

INSERT INTO batting_positions

SELECT
    match_id,
    inning_no,
    opener_1,
    1
FROM first_ball

UNION ALL

SELECT
    match_id,
    inning_no,
    opener_2,
    2
FROM first_ball

UNION ALL

SELECT
    match_id,
    inning_no,
    batter,
    batting_position
FROM ranked_batters;







// Batter Ranking based on their imapct at each position they played




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