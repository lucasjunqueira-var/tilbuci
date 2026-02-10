ALTER TABLE `events` ADD `ev_session` VARCHAR(32) NOT NULL DEFAULT ''; 
INSERT INTO config (cf_key, cf_value) VALUES ('dbVersion', '11') ON DUPLICATE KEY UPDATE cf_value=VALUES(cf_value);