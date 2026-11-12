ALTER TABLE instances ADD COLUMN in_alt TEXT NOT NULL DEFAULT '';
CREATE TABLE showtime (st_id INTEGER PRIMARY KEY AUTOINCREMENT, st_name TEXT NOT NULL, st_type TEXT NOT NULL, st_when DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, st_config TEXT NOT NULL, st_movies TEXT NOT NULL);
CREATE INDEX idx_showtime_name ON showtime(st_name);
CREATE INDEX idx_showtime_when ON showtime(st_when);
CREATE TABLE showtimeevt (se_id INTEGER PRIMARY KEY AUTOINCREMENT, se_name TEXT NOT NULL, se_type TEXT NOT NULL, se_data TEXT NOT NULL, se_when DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP);
CREATE INDEX idx_showtimeevt_name ON showtimeevt(se_name);
INSERT OR REPLACE INTO config (cf_key, cf_value) VALUES ('dbVersion', '24');