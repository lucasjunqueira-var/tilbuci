CREATE TABLE IF NOT EXISTS notes (nt_id INT NOT NULL AUTO_INCREMENT , nt_movie VARCHAR(32) NOT NULL , nt_scene VARCHAR(32) NOT NULL , nt_type VARCHAR(8) NOT NULL , nt_text LONGTEXT NOT NULL , nt_author VARCHAR(256) NOT NULL , nt_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP , PRIMARY KEY (nt_id), INDEX (nt_movie), INDEX (nt_scene)) ENGINE = InnoDB; 
CREATE TABLE IF NOT EXISTS scenelock (sl_id VARCHAR(128) NOT NULL, sl_movie VARCHAR(32) NOT NULL, sl_scene VARCHAR(32) NOT NULL, sl_user VARCHAR(512) NOT NULL DEFAULT '', sl_when DATETIME NOT NULL, PRIMARY KEY (sl_id), INDEX (sl_movie), INDEX (sl_scene)) ENGINE = InnoDB;
INSERT INTO config (cf_key, cf_value) VALUES ('dbVersion', '6') ON DUPLICATE KEY UPDATE cf_value=VALUES(cf_value);