CREATE TABLE servers (
    id          SERIAL PRIMARY KEY,
    name        VARCHAR(100) NOT NULL,
    ip          VARCHAR(45)  NOT NULL,
    created_at  TIMESTAMP    NOT NULL DEFAULT now()
);

CREATE TABLE metrics (
    id          BIGSERIAL PRIMARY KEY,
    server_id   INTEGER NOT NULL REFERENCES servers(id) ON DELETE CASCADE,
    cpu         REAL NOT NULL,
    ram         REAL NOT NULL,
    disk        REAL NOT NULL,
    recorded_at TIMESTAMP NOT NULL DEFAULT now()
);

CREATE INDEX idx_metrics_server_time ON metrics (server_id, recorded_at DESC);

INSERT INTO servers (name, ip) VALUES
    ('srv-web-01', '192.168.1.10'),
    ('srv-db-01',  '192.168.1.11');