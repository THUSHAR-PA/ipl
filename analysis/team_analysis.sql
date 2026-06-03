//Team Wins

SELECT
    winner,
    COUNT(*) AS wins
FROM matches
GROUP BY winner
ORDER BY wins DESC;

//RCB win percentages

SELECT
    ROUND(
        100.0 *
        COUNT(*) FILTER (
            WHERE winner = 'Royal Challengers Bengaluru'
        )
        /
        COUNT(*),
        2
    ) AS win_pct
FROM matches
WHERE team1 = 'Royal Challengers Bengaluru'
   OR team2 = 'Royal Challengers Bengaluru';

//Veneue usage

SELECT
    venue,
    COUNT(*) AS matches
FROM matches
GROUP BY venue
ORDER BY matches DESC;