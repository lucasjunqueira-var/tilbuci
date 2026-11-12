ALTER TABLE `movies` ADD `mv_strings` LONGTEXT NULL; 
INSERT INTO config (cf_key, cf_value) VALUES ('dbVersion', '12') ON DUPLICATE KEY UPDATE cf_value=VALUES(cf_value);