<?php

/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

/** CLASS DEFINITIONS **/
require_once('Webservice.php');

/**
 * Showtime operations.
 */
class WSShowtime extends Webservice
{	

	/**
	 * Showtime key.
	 */
	private $stKey = '';

    /**
     * system allowed actions
     */
    private $sysAllow = [
    ];
    
    /**
     * actions that don't require visitor login
     */
    private $noLogin = [
        'Showtime/Ping', 
		'Showtime/ClearConf', 
		'Showtime/ClearRemove', 
		'Showtime/ClearUpload', 
    ];
    
	/**
	 * Class constructor.
	 */
	public function __construct($ac)
	{
		parent::__construct($ac, in_array($ac, $this->noLogin));
	}
	
	/**
	 * Runs the current request.
	 */
	public function runRequest() {
		// getting showtime access key
		$this->stKey = $this->getConfig('stAKey');
		// getting the request
		$er = $this->getRequest(in_array($this->ac, $this->sysAllow));
		if ($er != 0) {
			$this->returnRequest([ 'e' => $er ]);
		} else {
			switch ($this->ac) {
				case 'Showtime/Ping':
					$this->ping();
					break;
				case 'Showtime/ClearConf':
					$this->clearConf();
					break;
				case 'Showtime/ClearRemove':
					$this->clearRemove();
					break;
				case 'Showtime/ClearUpload':
					$this->clearUpload();
					break;
				default:
					$this->returnRequest([ 'e' => -9 ]);
					break;
			}
		}
	}
	
	/** PRIVATE/PROTECTED METHODS **/
	
	/**
	 * Receiving a Showtime instance information.
	 */
	private function ping() {
		// required fields received?
		if ($this->requiredFields(['name', 'config', 'movies', 'type'])) {
			if ($this->checkKey()) {
				// remove old records
				$this->data->execute('DELETE FROM `' . $this->data->conf['databasePrefix'] . 'showtime` WHERE `st_when`<:limit', [
					':limit' => date('Y-m-d H:i:s', strtotime('-1month')), 
				]);
				// adding record
				$this->data->execute('INSERT INTO `' . $this->data->conf['databasePrefix'] . 'showtime` (`st_name`, `st_config`, `st_movies`, `st_type`) VALUES (:nm, :cf, :mv, :tp)', [
					':nm' => $this->req['name'], 
					':cf' => $this->req['config'], 
					':mv' => $this->req['movies'], 
					':tp' => $this->req['type'], 
				]);
				// looking for configuration change
				$ck = $this->data->queryAll('SELECT `se_data` FROM `' . $this->data->conf['databasePrefix'] . 'showtimeevt` WHERE `se_name`=:nm AND `se_type`=:cf', [
					':nm' => $this->req['name'], 
					':cf' => 'config', 
				]);
				$conf = '';
				if (count($ck) > 0) {
					$conf = json_decode($ck[0]['se_data'], true);
					if (json_last_error() != JSON_ERROR_NONE) $conf = '';
				}
				// looking for movie removal
				$remove = '';
				$ck = $this->data->queryAll('SELECT `se_data` FROM `' . $this->data->conf['databasePrefix'] . 'showtimeevt` WHERE `se_name`=:nm AND `se_type`=:rm ORDER BY `se_when` ASC LIMIT 1', [
					':nm' => $this->req['name'], 
					':rm' => 'remove', 
				]);
				if (count($ck) > 0) $remove = $ck[0]['se_data'];
				// looking for movie upload
				$upload = '';
				$ck = $this->data->queryAll('SELECT `se_data` FROM `' . $this->data->conf['databasePrefix'] . 'showtimeevt` WHERE `se_name`=:nm AND `se_type`=:up ORDER BY `se_when` ASC LIMIT 1', [
					':nm' => $this->req['name'], 
					':up' => 'upload', 
				]);
				if (count($ck) > 0) $upload = $ck[0]['se_data'];
				$this->returnRequest([
					'e' => 0, 
					'conf' => $conf, 
					'remove' => $remove, 
					'upload' => $upload, 
				]);
			} else {
				$this->returnRequest([ 'e' => 1 ]);
			}
		}
	}

	/**
	 * Clearing a remote configuration setting.
	 */
	private function clearConf() {
		// required fields received?
		if ($this->requiredFields(['name', 'time'])) {
			if ($this->checkKey()) {
				// remove the remote setting
				$this->data->execute('DELETE FROM `' . $this->data->conf['databasePrefix'] . 'showtimeevt` WHERE `se_name`=:nm AND `se_type`=:cf', [
					':nm' => $this->req['name'], 
					':cf' => 'config', 
				]);
				$this->returnRequest([ 'e' => 0 ]);
			} else {
				$this->returnRequest([ 'e' => 1 ]);
			}
		}
	}

	/**
	 * Clearing a movie remove setting.
	 */
	private function clearRemove() {
		// required fields received?
		if ($this->requiredFields(['name', 'movie', 'time'])) {
			if ($this->checkKey()) {
				// remove the remote setting
				$this->data->execute('DELETE FROM `' . $this->data->conf['databasePrefix'] . 'showtimeevt` WHERE `se_name`=:nm AND `se_type`=:rm AND `se_data`=:mv', [
					':nm' => $this->req['name'], 
					':rm' => 'remove', 
					':mv' => $this->req['movie'], 
				]);
				$this->returnRequest([ 'e' => 0 ]);
			} else {
				$this->returnRequest([ 'e' => 1 ]);
			}
		}
	}

	/**
	 * Clearing a movie upload setting.
	 */
	private function clearUpload() {
		// required fields received?
		if ($this->requiredFields(['name', 'movie', 'time'])) {
			if ($this->checkKey()) {
				// remove the upload setting
				$this->data->execute('DELETE FROM `' . $this->data->conf['databasePrefix'] . 'showtimeevt` WHERE `se_name`=:nm AND `se_type`=:up AND `se_data`=:mv', [
					':nm' => $this->req['name'], 
					':up' => 'upload', 
					':mv' => $this->req['movie'], 
				]);
				$this->returnRequest([ 'e' => 0 ]);
			} else {
				$this->returnRequest([ 'e' => 1 ]);
			}
		}
	}

	/**
	 * Check the showtime key.
	 */
	private function checkKey() {
		if (($this->stKey === false) || ($this->stKey == '')) {
			return (false);
		} else if (!isset($_POST['s']) || !isset($_POST['k'])) {
			return (false);
		} else {
			if ($_POST['k'] == md5($this->stKey . $_POST['s'])) {
				return (true);
			} else {
				return (false);
			}
		}
	}
}