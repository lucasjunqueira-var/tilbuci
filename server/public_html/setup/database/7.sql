ALTER TABLE `instancedesc` ADD `id_glow` VARCHAR(128) NOT NULL DEFAULT ''; 
ALTER TABLE `instancedesc` ADD `id_blend` VARCHAR(16) NOT NULL DEFAULT 'normal'; 
ALTER TABLE `movies` ADD `mv_contraptions` LONGTEXT NULL; 
ALTER TABLE `scenes` ADD `sc_static` TINYINT NOT NULL DEFAULT '0'; 
INSERT INTO config (cf_key, cf_value) VALUES ('dbVersion', '8') ON DUPLICATE KEY UPDATE cf_value=VALUES(cf_value);