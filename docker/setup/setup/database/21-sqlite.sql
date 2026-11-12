ALTER TABLE instances ADD COLUMN in_focus INTEGER NOT NULL DEFAULT 1;
INSERT OR REPLACE INTO config (cf_key, cf_value) VALUES ('dbVersion', '22');