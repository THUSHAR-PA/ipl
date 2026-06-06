




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