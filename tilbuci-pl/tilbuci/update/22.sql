ALTER TABLE `{PR}tilbuci_instances` ADD `in_focus` TINYINT NOT NULL DEFAULT '1';
INSERT INTO `{PR}tilbuci_config` (`cf_key`, `cf_value`) VALUES ('dbVersion', '22') ON DUPLICATE KEY UPDATE `cf_value`=VALUES(`cf_value`);
INSERT INTO `{PR}tilbuci_config` (`cf_key`, `cf_value`) VALUES ('shareMode', 'never') ON DUPLICATE KEY UPDATE `cf_value`=VALUES(`cf_value`);