ALTER TABLE `instancedesc` CHANGE `id_textsize` `id_textsize` SMALLINT NOT NULL DEFAULT '12'; 
ALTER TABLE `instancedesc` CHANGE `id_textleading` `id_textleading` SMALLINT NOT NULL DEFAULT '0'; 
ALTER TABLE `movies` ADD `mv_loading` VARCHAR(2048) NOT NULL DEFAULT ''; 
ALTER TABLE `instances` ADD `in_actionover` TEXT NULL; 
INSERT INTO config (cf_key, cf_value) VALUES ('dbVersion', '9') ON DUPLICATE KEY UPDATE cf_value=VALUES(cf_value);