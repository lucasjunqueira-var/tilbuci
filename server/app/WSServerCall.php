<?php

/** CLASS DEFINITIONS **/
require_once('Webservice.php');
require_once('ServerCall.php');

/**
 * Server Call operations.
 */
class WSServerCall extends Webservice
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
		$er = $this->getRequest(true);
		if ($er != 0) {
			$this->returnRequest([ 'e' => $er ]);
		} else {
			switch ($this->ac) {
				case 'ServerCall/Url':
					$this->callUrl();
					break;
				case 'ServerCall/Process':
					$this->callProcess();
					break;
				default:
					$this->returnRequest([ 'e' => -9 ]);
					break;
			}
		}
	}
	
	/** PRIVATE/PROTECTED METHODS **/
	
	/**
	 * Acessing an URL.
	 */
	private function callUrl() {
		// required fields received?
		if ($this->requiredFields(['url', 'var'])) {
			$call = new ServerCall;
			$resp = $call->callUrl($this->req['url']);
			if ($resp === false) {
				$this->returnRequest([ 'e' => 1, 'resp' => '', 'var' => $this->req['var'] ]);	
			} else {
				$this->returnRequest([ 'e' => 0, 'resp' => $resp, 'var' => $this->req['var'] ]);	
			}
		}
	}
	
	/**
	 * Acessing an URL for data processing.
	 */
	private function callProcess() {
		// required fields received?
		if ($this->requiredFields(['url', 'data', 'movieid', 'sceneid', 'movietitle', 'scenetitle', 'visitor'])) {
			$call = new ServerCall;
			$resp = $call->callProcess($this->req['url'], $this->req['data'], $this->req['movieid'], $this->req['sceneid'], $this->req['movietitle'], $this->req['scenetitle'], $this->req['visitor']);
			if ($resp === false) {
				$this->returnRequest([ 'e' => 1, 'resp' => '' ]);	
			} else {
				$this->returnRequest([ 'e' => 0, 'resp' => $resp ]);	
			}
		}
	}
}