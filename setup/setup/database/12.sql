ALTER TABLE `movies` ADD `mv_encrypted` TINYINT NOT NULL DEFAULT '0'; 
INSERT INTO config (cf_key, cf_value) VALUES ('dbVersion', '13') ON DUPLICATE KEY UPDATE cf_value=VALUES(cf_value);