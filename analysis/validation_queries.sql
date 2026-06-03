SELECT COUNT(*) FROM matches;
SELECT COUNT(*) FROM deliveries;
SELECT COUNT(*) FROM dismissals;

//Distinc matches

SELECT DISTINCT team1
FROM matches;

//Distin dismissal kinds

SELECT DISTINCT dismissal_kind
FROM dismissals;

//Nulll check

SELECT *
FROM matches
WHERE winner IS NULL;

// Sanity check for wicket type

SELECT
    dismissal_kind,
    COUNT(*)
FROM dismissals
GROUP BY dismissal_kind;

