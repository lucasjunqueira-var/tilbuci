<?php

/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

/** GLOBAL CONFIGURATIONS **/
require_once('Config.php');

/**
 * Basic Tilbuci PHP calss.
 */
class BaseClass
{
	/**
	 * global configuration
	 */
	protected $conf;
	
	/**
	 * translated text
	 */
	private $lang = [ ];
	
	/**
	 * connected database
	 */
	public $db = null;

	/**
	 * last connection error
	 */
	public $error = 0;
	
	/**
	 * Class constructor.
	 */
	public function __construct() {
		global $gconf;
		$this->conf = $gconf;
		try {
			$this->db = new PDO('mysql:host=' . $this->conf['databaseServ'] . (($this->conf['databasePort'] != '') ? (':' . $this->conf['databasePort']) : '') . ';dbname=' . $this->conf['databaseName'] . ';charset=utf8', $this->conf['databaseUser'], ($this->conf['databasePass'] == '' ? '' : base64_decode($this->conf['databasePass'])));
			$this->error = 0;
		} catch(Exception $e) {
			$this->db = null;
			$this->error = -6;
		}
	}
	
	/**
	 * Encrypts a string.
	 * @param string $string the string to encrypt
	 * @return string the encrypted value
	 */
	public function encrypt($string) {
		return(openssl_encrypt($string, 'AES-128-CTR', $this->conf['encKey'], 0, $this->conf['encVec']));
	}
	
	/**
	 * Decrypts a string.
	 * @param string $string the encrypted value
	 * @return string the decrypted string
	 */
	public function decrypt($string) {
		return(openssl_decrypt($string, 'AES-128-CTR', $this->conf['encKey'], 0, $this->conf['encVec']));
	}
    
    /**
     * Encrypt a TilBuci json file.
     * @param string $movie the movie ID
     * @param string $content the json file content
     * @return string the encrypted content
     */
    public function encryptTBFile($movie, $content) {
        $iv = openssl_random_pseudo_bytes(16);
        $encrypted = openssl_encrypt($content, 'AES-256-CBC', mb_strtolower(md5($movie)), OPENSSL_RAW_DATA, $iv);
        $combined = $iv . $encrypted;
        $txt = 'TB' . base64_encode($combined);
        $txt = substr($txt, 0, (strlen($txt) - 9)) . 'b' . substr($txt, -9);
        return ($txt);
    }
	
	/**
	 * Loads a language file.
	 * @param string $id the language file id
	 */
	public function loadLang($id) {
		// no default loaed yet?
		if (empty($this->lang)) {
			if (is_file('../../language/langDefault.json')) {
				$json = json_decode(file_get_contents('../../language/langDefault.json'), true);
				if (json_last_error() == JSON_ERROR_NONE) {
					foreach ($json as $k => $v) $this->lang[$k] = $v;
				}
			}
		}
		// load requested language file
		if ($id != 'langDefault') {
			if (is_file('../../language/' . $id . '.json')) {
				$json = json_decode(file_get_contents('../../language/' . $id . '.json'), true);
				if (json_last_error() == JSON_ERROR_NONE) {
					foreach ($json as $k => $v) $this->lang[$k] = $v;
				}
			}
		}
	}
	
	/**
	 * Gets a text string in current language.
	 * @param string $id the text id
	 * @return string the requested text or empty string if not found
	 */
	public function getLang($id) {
		if (isset($this->lang[$id])) {
			return ($this->lang[$id]);
		} else {
			return ('');
		}
	}
	
	/**
	 * Generates a rando string with numbers and capital chars.
	 * @param int $size the rand string length
	 * @return string the random string
	 */
	public function randSring($size) {
		$chars = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
		$length = strlen($chars);
		$rand = '';
		for ($i=0; $i<$size; $i++) $rand .= $chars[random_int(0, $length - 1)];
		return ($rand);
	}
	
	/**
	 * Creates a clean, lower case string.
	 * @param string $string the original string
	 * @return string the "clean" string
	 */
	public function cleanString($string) {
		$string = mb_strtolower(preg_replace('/\s*/m', '', trim($string)));
		$string = str_replace([' ', '/', '\\', '^', '~', '´', '`', '"', "'", '?', '@', '!', '#', '$', '%', '&', '*', '(', ')', '[', ']', '<', '>', '|', 'ç', 'ñ', 'á', 'à', 'â', 'ã', 'é', 'è', 'ê', 'í', 'ó', 'ô', 'ú'], '', $string);
		return ($string);
	}
	
	/**
	 * Queries the database for results.
	 * @param string $query the sql query
	 * @param array $values the values to replace on query
	 * @return array the results as associative array
	 */
	public function queryAll($query, $values = [ ]) {
		// connected?
		if (is_null($this->db)) {
			return([]);
		} else {
			$sth = $this->db->prepare($query, array(PDO::ATTR_CURSOR => PDO::CURSOR_FWDONLY));
			$sth->execute($values);
			return($sth->fetchAll());
		}
	}
	
	/**
	 * Executes a query on database.
	 * @param string $query the sql query
	 * @param array $values the values to replace on query
	 * @return bool was the query executed?
	 */
	public function execute($query, $values = [ ])
	{
		// connected?
		if (is_null($this->db)) {
			return(false);
		} else {
			$sth = $this->db->prepare($query, array(PDO::ATTR_CURSOR => PDO::CURSOR_FWDONLY));
			return($sth->execute($values));
		}
	}
	
	/**
	 * Gets the prepared statement for debug.
	 * @param string $query the sql query
	 * @param array $values the values to replace on query
	 * @return	string	the prepared query
	 */
	public function debugSql($query, $values = [ ]) {
		foreach ($values as $k => $v) {
			$query = str_replace($k.' ', "'" . $v . "' ", $query);
			$query = str_replace($k.',', "'" . $v . "',", $query);
		}
		return ($query);
	}
	
	/**
	 * Recovers the last inserted ID on database.
	 * @return * the inserted ID (or null on error)
	 */
	public function insertID()
	{
		// connected?
		if (!is_null($this->db)) {
			return($this->db->lastInsertId());
		} else {
			return (null);
		}
	}
	
	/**
	 * Sets a configuration value.
	 * @param string $key the configuration key
	 * @param string $value	the configuraiton value
	 * @return bool was the configuration saved?
	 */
	public function setConfig($key, $value) {
		if (!is_null($this->db)) {
			$this->execute('DELETE FROM config WHERE cf_key=:key', [':key' => $key]);
			return($this->execute('INSERT INTO config (cf_key, cf_value) VALUES (:key, :value)', [
				':key' => $key, 
				':value' => $value, 
			]));
		} else {
			return (false);
		}
	}
	
	/**
	 * Retrieves a configuration value.
	 * @param string $key the configuration key
	 * @return string|bool the recovered value or false if it was not found
	 */
	public function getConfig($key) {
		if (!is_null($this->db)) {
			$ck = $this->queryAll('SELECT cf_value FROM config WHERE cf_key=:key', [':key' => $key]);
			if (count($ck) == 0) {
				return (false);
			} else {
				return ($ck[0]['cf_value']);
			}
		} else {
			return (false);
		}
	}
	
	/**
	 * Clears a configuration value.
	 * @param string $key the configuration key
	 * @return bool was the configuration cleared?
	 */
	public function clearConfig($key) {
		if (!is_null($this->db)) {
			return($this->execute('DELETE FROM config WHERE cf_key=:key', [':key' => $key]));
		} else {
			return (false);
		}
	}
	
	/**
	 * Creates a directory.
	 * @param	string	$path	new dir path
	 * @param	bool	$recursive	recursive creation?
	 * @param	int	$perm	new dir permissions
	 * @return	was the dir created?
	 */
	public function createDir($path, $recursive = false, $perm = 0777) {
		$oldmask = umask(0);
		$ok = @mkdir($path, $perm, $recursive);
		umask($oldmask);
		return ($ok);
	}
    
    /**
	 * Copies a directory.
	 * @param	string	$from original dir
     * @param   string  $to copy path
	 */
	public function copyDir($from, $to) {
		$dir = opendir($from);
        $this->createDir($to);
        while(($file = readdir($dir))) {
            if (($file != '.') && ($file != '..')) {
                if (is_dir($from.'/'.$file)) {
                    $this->copyDir(($from.'/'.$file), ($to.'/'.$file));
                } else {
                    copy(($from.'/'.$file), ($to.'/'.$file));
                }
            }
        }
	}
    
    /**
	 * Removes a file or directory.
	 * @param	string	$path	dir path
	 * @return	was the dir removed?
	 */
	public function removeFileDir($path) {
        if (is_file($path)) {
            return(@unlink($path));
        } else if (is_dir($path)) {
            $dir = opendir($path);
            while(($file = readdir($dir))) {
                if (($file != '.') && ($file != '..')) {
                    if (is_file($path.'/'.$file)) {
                        @unlink($path.'/'.$file);
                    } else {
                        $this->removeFileDir($path.'/'.$file);
                    }
                }
            }
            return (@rmdir($path));
        } else {
            return (true);
        }
	}
    
    /**
	 * Lists all files in a directory.
	 * @param	string	$path	dir path
	 * @return	array   the file list
	 */
	public function listDirFiles($path, $flist = [ ]) {
        if (is_file($path)) {
            $flist[] = $path;
            return ($flist);
        } else if (is_dir($path)) {
            $dir = opendir($path);
            while(($file = readdir($dir))) {
                if (($file != '.') && ($file != '..')) {
                    if (is_file($path.'/'.$file)) {
                        $flist[] = $path.'/'.$file;
                    } else {
                        $flist = $this->listDirFiles(($path.'/'.$file), $flist);
                    }
                }
            }
            return ($flist);
        } else {
            return ($flist);
        }
	}
    
    /**
     * Checks if a string ends with / and adds it if not.
     * @param   string  $url    the string to check
     * @return'string   the prepared string
     */
    public function slashUrl($url) {
        if (substr($url, -1) != '/') $url .= '/';
        return ($url);
    }
	
}