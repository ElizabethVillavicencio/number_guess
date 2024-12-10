CREATE TABLE users (
    username VARCHAR(22) PRIMARY KEY,
    games_played INTEGER DEFAULT 0,
    best_game INTEGER
);

CREATE TABLE games (
    game_id SERIAL PRIMARY KEY,
    username VARCHAR(22),
    attempts INTEGER,
    secret_number INTEGER,
    FOREIGN KEY (username) REFERENCES users(username)
);
