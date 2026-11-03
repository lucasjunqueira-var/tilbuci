ALTER TABLE instances CHANGE in_name in_name VARCHAR(64);
INSERT INTO config (cf_key, cf_value) VALUES ('dbVersion', '26') ON DUPLICATE KEY UPDATE cf_value=VALUES(cf_value);