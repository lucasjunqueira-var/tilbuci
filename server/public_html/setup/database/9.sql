ALTER TABLE `instances` ADD `in_timedac` MEDIUMTEXT NULL; 
INSERT INTO config (cf_key, cf_value) VALUES ('dbVersion', '10') ON DUPLICATE KEY UPDATE cf_value=VALUES(cf_value);