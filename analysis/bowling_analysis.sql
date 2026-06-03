//PURPLE CAP

SELECT
    bowler,
    COUNT(*) AS wickets
FROM dismissals
WHERE dismissal_kind NOT IN (
    'run out',
    'retired hurt',
    'retired out',
    'obstructing the field'
)
GROUP BY bowler
ORDER BY wickets DESC;

// Lowest economy rate 
SELECT
    bowler,
    ROUND(
        SUM(total_runs)*6.0/COUNT(*),
        2
    ) AS economy
FROM deliveries
GROUP BY bowler
HAVING COUNT(*) > 30
ORDER BY economy;

//Lowest economy rate in death overs

SELECT
    bowler,
    ROUND(
        SUM(total_runs)*6.0/COUNT(*),
        2
    ) AS economy
FROM deliveries
WHERE phase = 'Death'
GROUP BY bowler
HAVING COUNT(*) > 30
ORDER BY economy;

//Dot Ball percentages

SELECT
    bowler,
    ROUND(
        COUNT(*) FILTER (WHERE total_runs = 0) * 100.0
        / COUNT(*),
        2
    ) AS dot_ball_pct
FROM deliveries
GROUP BY bowler
ORDER BY dot_ball_pct DESC;