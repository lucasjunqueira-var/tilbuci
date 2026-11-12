ALTER TABLE `movies` ADD `mv_highlight` VARCHAR(16) NOT NULL DEFAULT '' AFTER `mv_style`;
ALTER TABLE `events` ADD `ev_when` DATETIME NOT NULL AFTER `ev_date`, ADD INDEX (`ev_when`); 
ALTER TABLE `movies` ADD `mv_inputs` TEXT NULL AFTER `mv_theme`; 
INSERT INTO config (cf_key, cf_value) VALUES ('dbVersion', '3') ON DUPLICATE KEY UPDATE cf_value=VALUES(cf_value);