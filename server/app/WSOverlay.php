<?php

/** CLASS DEFINITIONS **/
require_once('Webservice.php');
require_once('Overlay.php');

/**
 * Server Call operations.
 */
class WSOverlay extends Webservice
{	
	
	/**
	 * Class constructor.
	 */
	public function __construct($ac)
	{
		parent::__construct($ac, true, [ 'Overlay/GetKeyData', 'Overlay/SetKeyData' ]);
	}
	
	/**
	 * Checks open webservice action key.
	 */
	public function checkOpenSecret() {
		$ov = new Overlay;
		if (isset($ov->config['overlay']) && ($ov->config['overlay'] != '')) {
			if (isset($_POST['s']) && isset($_POST['k'])) {
				if (trim($_POST['s']) == md5($ov->config['overlay'] . trim($_POST['k']))) {
					return (true);
				} else {
					return (false);
				}
			} else {
				return (false);
			}
		} else {
			return (false);
		}
	}
	
	/**
	 * Runs the current request.
	 */
	public function runRequest() {
		// getting the request
		$er = $this->getRequest(true);
		if ($er != 0) {
			$this->returnRequest([ 'e' => $er ]);
		} else {
			switch ($this->ac) {
				case 'Overlay/GetKey':
					$this->show();
					break;
				case 'Overlay/LoadKey':
					$this->loadKey();
					break;
				case 'Overlay/GetKeyData':
					$this->getKeyData();
					break;
				case 'Overlay/SetKeyData':
					$this->setKeyData();
					break;
				default:
					$this->returnRequest([ 'e' => -9 ]);
					break;
			}
		}
	}
	
	/** PRIVATE/PROTECTED METHODS **/
	
	/**
	 * Prepare a key for an overlay display.
	 */
	private function show() {
		// required fields received?
		if ($this->requiredFields(['url', 'title', 'addget', 'data'])) {
			$ov = new Overlay;
			$key = $ov->getOverlayKey($this->req['url'], $this->req['data']);
			if ($key == '') {
				$this->returnRequest([ 'e' => 1, 'key' => '', 'url' => '', 'title' => '', 'addget' => '0', 'data' => '' ]);	
			} else {
				$this->returnRequest([
					'e' => 0,
					'key' => $key,
					'url' => $this->req['url'], 
					'title' => $this->req['title'],
					'addget' => $this->req['addget'], 
					'data' => $this->req['data'], 
				]);	
			}
		}
	}
	
	/**
	 * Loads information about an overylay key.
	 */
	private function loadKey() {
		// required fields received?
		if ($this->requiredFields(['key'])) {
			$ov = new Overlay;
			$ret = $ov->loadOverlayKey($this->req['key']);
			if ($ret === false) {
				$this->returnRequest([ 'e' => 1, 'key' => '', 'ret' => '' ]);	
			} else {
				$this->returnRequest([
					'e' => 0,
					'key' => $this->req['key'],
					'ret' => $ret, 
				]);	
			}
		}
	}
	
	/**
	 * Gets data from and overlay key.
	 */
	private function getKeyData() {
		$ov = new Overlay;
		$data = $ov->getKeyData(trim($_POST['k']));
		if ($data === false) {
			$this->returnRequest([ 'e' => 1, 'key' => '', 'data' => '' ]);	
		} else {
			$this->returnRequest([
				'e' => 0,
				'key' => trim($_POST['k']),
				'data' => $data, 
			]);	
		}
	}
	
	/**
	 * Sets data for and overlay key.
	 */
	private function setKeyData() {
		if (isset($_POST['d'])) {
			$ov = new Overlay;
			$data = $ov->setKeyData(trim($_POST['k']), trim($_POST['d']));
			if ($data === false) {
				$this->returnRequest([ 'e' => 1, 'key' => '' ]);	
			} else {
				$this->returnRequest([
					'e' => 0,
					'key' => trim($_POST['k']),
				]);	
			}
		} else {
			$this->returnRequest([ 'e' => -11 ]);
		}
	}
}