INSERT INTO `tilbuci_config` (`cf_key`, `cf_value`) VALUES
	('dbVersion', '20'),
	('fpsMode', '30'),
	('renderMode', 'webgl'),
	('shareMode', 'scene');
INSERT INTO `tilbuci_fonts` (`fn_name`, `fn_file`) VALUES
	('Averia Serif GWF', 'averiaserifgwf.woff2'),
	('Liberation Serif', 'liberationserif.woff2'),
	('Libra Sans', 'librasans.woff2'),
	('Roboto Sans', 'roboto.woff2');
TRUNCATE TABLE `tilbuci_visitorgroups`;
INSERT INTO `tilbuci_visitorgroups` (`vg_id`, `vg_name`) VALUES ('1', 'WordPress');