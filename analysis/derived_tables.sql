CREATE TABLE batting_positions (
    match_id TEXT,
    inning_no INTEGER,
    batter TEXT,
    batting_position INTEGER
);


--INSERTING DATA INTO BATTING_POSITION TABLE

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



--Create batter position stats table    
CREATE TABLE batter_position_stats (
    batting_role TEXT,
    batter TEXT,
    batting_team TEXT,
    matches INTEGER,
    runs INTEGER,
    balls INTEGER,
    strike_rate NUMERIC(6,2),
    fours INTEGER,
    sixes INTEGER,
    boundary_percentage NUMERIC(6,2)
);

--Insert into batting position stats table

INSERT INTO batter_position_stats

SELECT

    CASE
        WHEN bp.batting_position IN (1, 2)
            THEN 'Opener'

        ELSE bp.batting_position::TEXT
    END AS batting_role,

    d.batter,

    d.batting_team,

    COUNT(DISTINCT d.match_id) AS matches,

    SUM(d.batter_runs) AS runs,

    COUNT(*) AS balls,

    ROUND(
        SUM(d.batter_runs) * 100.0 / COUNT(*),
        2
    ) AS strike_rate,

    COUNT(*) FILTER (
        WHERE d.batter_runs = 4
    ) AS fours,

    COUNT(*) FILTER (
        WHERE d.batter_runs = 6
    ) AS sixes,

    ROUND(
        COUNT(*) FILTER (
            WHERE d.batter_runs IN (4, 6)
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
    batting_role,
    d.batter,
    d.batting_team;

