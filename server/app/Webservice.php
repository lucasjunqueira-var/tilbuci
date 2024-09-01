<?php

/** CLASS DEFINITIONS **/
require_once('BaseClass.php');
require_once('Data.php');

/**
 * Initial webservice process.
 */
class Webservice extends BaseClass
{	
	/**
	 * action called
	 */
	protected $ac = '';
	
	/**
	 * allow system user? (no signature)
	 */
	protected $allowSystem = false;
	
	/**
	 * data connection
	 */
	protected $data = null;
	
	/**
	 * received request
	 */
	protected $req = null;
	
	/**
	 * validated user
	 */
	protected $user = null;
	
	/**
	 * webservice actions open to external calls
	 */
	protected $openActions = [ ];
	
	/**
	 * Class constructor.
	 */
	public function __construct($ac = '', $allowSys = false, $open = [ ])
	{
		parent::__construct();
		$this->ac = $ac;
		$this->allowSystem = $allowSys;
		$this->openActions = $open;
		$this->data = new Data;
	}
	
	/**
	 * Runs the current request (meant to override).
	 */
	public function runRequest() {
		$this->returnRequest([ 'e' => -8 ]);
	}
	
	/**
	 * Checks open webservice action secret (meant to override).
	 */
	public function checkOpenSecret() {
		return (false);
	}
	
	/** PRIVATE/PROTECTED METHODS **/
	
	/**
	 * Gets the current request.
	 * @param bool $visitor check signature from registered visitors instead of users?
	 * @return int operation error
	 * 0 => request received
	 * -1 => no valid request received
	 * -2 => system user not allowed for request
	 * -3 => no access key found
	 * -4 => error on request signature
	 * -5 => database file not found
	 * -6 => error while connecting to the database
	 * -7 => corrupted request JSON
	 */
	protected function getRequest($visitor = false) {
		// really receiving a request?
		$this->req = null;
		$this->user = null;
		// open request?
		if (in_array($this->ac, $this->openActions)) {
			if ($this->checkOpenSecret()) {
				
			} else {
				// no valid request received
				return (-100);
			}
		} else if (isset($_POST['r']) && isset($_POST['u']) && isset($_POST['s'])) {
			// get data
			$request = trim($_POST['r']);
			$user = trim($_POST['u']);
			$sign = trim($_POST['s']);
			// system user?
			if (($user == 'system') && !$this->allowSystem) {
				// no system user allowed
				return (-2);
			} else {
				// prepare connection
				$this->data = new Data;
				if ($this->data->error != 0) {
					// error while connecting to the database
					return ($this->data->error);
				} else {
					// recover key
					$key = null;
					if ($user == 'system') {
						$key = '';
					} else {
						$key = $this->data->getKey($user, $visitor);
					}
					if (is_null($key)) {
						// no access key found
						return (-3);
					} else {
						// validate key
						if (strtolower(md5($key . $request)) != strtolower($sign)) {
							// invalid signature
							return (-4);
						} else {
							// parse request
							$json = json_decode($request, true);
							if (json_last_error() != JSON_ERROR_NONE) {
								// corrupted json
								return (-7);
							} else {
								// getting request
								$this->req = $json;
								$this->user = $user;
								$this->data->loadUser($user, $visitor);
								return (0);
							}
						}
					}
				}
			}
		} else {
			// no request received
			return (-1);
		}
	}
	
	/**
	 * Checks for admin user (level 0) and quits processing of not.
	 * @return bool admin user verifyed?
	 */
	protected function checkAdmin() {
		if ($this->data->user['level'] != 0) {
			$this->returnRequest([ 'e' => -10 ]);
			return (false);
		} else {
			return (true);
		}
	}
	
	/**
	 * Returns the webservice processing to the requester.
	 * @param array $val the values to return
	 */
	protected function returnRequest($val) {
		$val['t'] = date('c');
		$val['a'] = $this->ac;
		header('Content-Type: application/json');
		exit(json_encode($val));
	}
	
	/**
	 * Check if all required fields were sent.
	 * @param	array	$list	a list of required fields
	 * @param	bool	$exit	exit script executiion and return on error?
	 * @return	bool	were all required field sent?
	 */
	protected function requiredFields($list, $exit = true) {
		// all fields found on request?
		$ok = true;
		foreach ($list as $reqf) if (!isset($this->req[$reqf])) $ok = false;
		// all found?
		if ($ok) {
			return (true);
		} else {
			// at least one was not found. exit right now or return?
			if ($exit) {
				$this->returnRequest([ 'e' => -11 ]);
			} else {
				return (false);
			}
		}
	}
}