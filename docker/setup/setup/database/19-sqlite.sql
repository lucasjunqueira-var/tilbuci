CREATE TABLE snippets ( sn_id INTEGER PRIMARY KEY AUTOINCREMENT, sn_movie TEXT NOT NULL, sn_file TEXT NOT NULL, sn_content TEXT NOT NULL );
CREATE INDEX idx_sn_movie ON snippets(sn_movie);
CREATE INDEX idx_sn_file ON snippets(sn_file);
INSERT OR REPLACE INTO config (cf_key, cf_value) VALUES ('dbVersion', '20');