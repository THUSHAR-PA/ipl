--ORANGE CAP

SELECT
    batter,
    SUM(batter_runs) AS runs
FROM deliveries
GROUP BY batter
ORDER BY runs DESC;

--Most Sixes

SELECT
    batter,
    COUNT(*) AS sixes
FROM deliveries
WHERE batter_runs = 6
GROUP BY batter
ORDER BY sixes DESC;

--MOST FOURS

SELECT
    batter,
    COUNT(*) AS fours
FROM deliveries
WHERE batter_runs = 4
GROUP BY batter
ORDER BY fours DESC;


--Batter_with highest strike rate_in powerplay who faced atleast 100 balls
 
 SELECT
    batter,
    ROUND(
        SUM(batter_runs)*100.0/COUNT(*),
        2
    ) AS strike_rate
FROM deliveries
WHERE phase = 'Powerplay'
GROUP BY batter
HAVING COUNT(*) > 100
ORDER BY strike_rate DESC;

--Death over strike rate min 20 balls faced

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

