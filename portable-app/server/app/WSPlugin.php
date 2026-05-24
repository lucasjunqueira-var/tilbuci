<?php

/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

/** CLASS DEFINITIONS **/
require_once('Webservice.php');
require_once('Plugin.php');

/**
 * Plugin operations.
 */
class WSPlugin extends Webservice
{	
	/**
	 * Class constructor.
	 */
	public function __construct($ac)
	{
		parent::__construct($ac, true);
	}
	
	/**
	 * Runs the current request.
	 */
	public function runRequest() {
		// getting the request
		$er = $this->getRequest($this->ac == 'Plugin/GetConfig');
		if ($er != 0) {
			$this->returnRequest([ 'e' => $er ]);
		} else {
			switch ($this->ac) {
				case 'Plugin/GetConfig':
					$this->getPluginConfig();
					break;
				case 'Plugin/SetConfig':
					$this->setPluginConfig();
					break;
				default:
					$this->returnRequest([ 'e' => -9 ]);
					break;
			}
		}
	}
	
	/** PRIVATE/PROTECTED METHODS **/
	
	/**
	 * Getting plugin configuration.
	 */
	private function getPluginConfig() {
		// required fields received?
		if ($this->requiredFields(['name', 'file', 'index', 'ws'])) {
			// load plugin config
			$pl = new Plugin($this->req['name'], $this->req['file'], $this->req['index'], $this->req['ws']);
			$this->returnRequest([ 'e' => 0, 'conf' => $pl->config ]);
		}
	}
	
	/**
	 * Setting plugin configuration.
	 */
	private function setPluginConfig() {
		// required fields received?
		if ($this->requiredFields(['name', 'conf', 'index', 'ws', 'file'])) {
			// load plugin config
			$pl = new Plugin($this->req['name'], $this->req['file'], $this->req['index'], $this->req['ws']);
			$conf = json_decode($this->req['conf'], true);
			if (json_last_error() == JSON_ERROR_NONE) {
				$pl->setPluginConfig(json_encode($conf), $this->req['file'], $this->req['index'], $this->req['ws']);
				$this->returnRequest([ 'e' => 0, 'conf' => $pl->config ]);
			} else {
				$this->returnRequest([ 'e' => 1, 'conf' => $pl->config ]);
			}
		}
	}
}