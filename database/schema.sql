\\Teams
CREATE TABLE teams (
    team_id SERIAL PRIMARY KEY,
    team_name VARCHAR(100) UNIQUE NOT NULL
);

\\matches

CREATE TABLE matches (
    match_id VARCHAR(50) PRIMARY KEY,
    match_date DATE,
    venue VARCHAR(200),
    team1 VARCHAR(100),
    team2 VARCHAR(100),
    winner VARCHAR(100)
);

\\players

CREATE TABLE players (
    player_id SERIAL PRIMARY KEY,
    player_name VARCHAR(100) NOT NULL,
    team_id INTEGER REFERENCES teams(team_id)
);