<?php

/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

/** CLASS DEFINITIONS **/
require_once('Plugin.php');

/**
 * Plugin base.
 */
class Overlay extends Plugin
{

	/**
	 * Constructor.
	 */
	public function __construct()
	{
		parent::__construct('overlay', 'Overlay', '1', '1');
		$this->execute("CREATE TABLE IF NOT EXISTS overlay_plugin (op_key VARCHAR(32) NOT NULL, op_url VARCHAR(2048) NOT NULL, op_request LONGTEXT NOT NULL, op_return LONGTEXT NOT NULL, op_closed TINYINT NOT NULL DEFAULT '0', op_created DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, op_updated DATETIME on update CURRENT_TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, PRIMARY KEY (op_key), INDEX (op_created), INDEX (op_updated)) ENGINE = InnoDB");
		$this->execute('DELETE FROM overlay_plugin WHERE op_created<:limit', [
			':limit' => date('Y-m-d H:i:s', strtotime('-2days')), 
		]);
	}
	
	/**
	 * Content to be add to the head part of the page index.
	 * @return	string	the content to be placed at head
	 */
	public function indexHead() {
		$text = parent::indexHead();
		if (isset($this->config['overlay'])) {
			$text .= '<style>#overlay_area { position: absolute; left: 0; top: 0; display: none; background-color: #000000; padding: 0 30px 30px 30px; width: 100%; height: 100%; box-sizing: content-box; } #overlay_header { width: 100%; box-sizing: content-box; height: 30px; margin: 5px 0; } #overlay_title { color: #FFFFFF; font-family: Segoe, "Segoe UI", "DejaVu Sans", "Trebuchet MS", Verdana, "sans-serif"; font-size: 20px; font-weight: bold; } #overlay_close { color: #FFFFFF; font-family: Segoe, "Segoe UI", "DejaVu Sans", "Trebuchet MS", Verdana, "sans-serif"; font-size: 20px; font-weight: bold; cursor: pointer; text-align: right; position: absolute; top: 5px; right: 100px; min-width: 100px; } #overlay_frame { display: none; } </style>';
		}
		return ($text);
	}
	
	/**
	 * Content to be add to the end of body part of the page index.
	 * @return	string	the content to be placed at body end
	 */
	public function indexEndBody() {
		$text = parent::indexEndBody();
		if (isset($this->config['overlay'])) {
			$text .= '<div id="overlay_area"><div id="overlay_header"><div id="overlay_title"></div><div id="overlay_close" onClick="overlay_close();"><img id="btclose" src="btclose.png" /></div></div><iframe id="overlay_frame" width="0" height="0" src=""></iframe></div>';
		}
		return ($text);
	}

	/**
	 * Prepares a key to show an overlay.
	 * @param	string	$url	the url to display at the overlay
	 * @param	string	$data	json-encoded request data
	 * @return	string	the key to current overlay
	 */
	public function getOverlayKey($url, $data) {
		$run = true;
		while($run) {
			$key = md5(time().rand(10000, 99999));
			$ck = $this->queryAll('SELECT op_key FROM overlay_plugin WHERE op_key=:key', [ ':key' => $key ]);
			if (count($ck) == 0) $run = false;
		}
		$this->execute('INSERT IGNORE INTO overlay_plugin (op_key, op_url, op_request, op_return) VALUES (:key, :url, :req, :ret)', [
			':key' => $key, 
			':url' => $url, 
			':req' => $data, 
			':ret' => '', 
		]);
		return ($key);
	}
	
	/**
	 * Loads return information from an overlay key.
	 * @param	string	$key	the overlay key
	 * @return	string|bool	the json-encoded information or false
	 */
	public function loadOverlayKey($key) {
		$ck = $this->queryAll('SELECT op_return FROM overlay_plugin WHERE op_key=:key', [':key' => $key]);
		if (count($ck) == 0) {
			return (false);
		} else {
			return ($ck[0]['op_return']);
		}
	}
	
	/**
	 * Loads request information from an overlay key.
	 * @param	string	$key	the overlay key
	 * @return	string|bool	the json-encoded information or false
	 */
	public function getKeyData($key) {
		$ck = $this->queryAll('SELECT op_request FROM overlay_plugin WHERE op_key=:key', [':key' => $key]);
		if (count($ck) == 0) {
			return (false);
		} else {
			return ($ck[0]['op_request']);
		}
	}
	
	/**
	 * Sets return information to an overlay key.
	 * @param	string	$key	the overlay key
	 * @return	bool	was the information set?
	 */
	public function setKeyData($key, $data) {
		$json = json_decode($data, true);
		if (json_last_error() != JSON_ERROR_NONE) {
			return (false);
		} else {
			$valid = true;
			foreach ($json as $k => $v) {
				if (!isset($v['t']) || !isset($v['v'])) $valid = false;
			}
			if (!$valid) {
				return (false);
			} else {
				$ck = $this->queryAll('SELECT op_key FROM overlay_plugin WHERE op_key=:key', [':key' => $key]);
				if (count($ck) == 0) {
					return (false);
				} else {
					$this->execute('UPDATE overlay_plugin SET op_return=:ret WHERE op_key=:key', [
						':ret' => json_encode($json), 
						':key' => $key
					]);
					return (true);
				}
			}
		}
	}
}