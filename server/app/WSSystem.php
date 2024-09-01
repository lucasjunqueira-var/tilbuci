<?php

/** CLASS DEFINITIONS **/
require_once('Webservice.php');
require_once('Mailer.php');

/**
 * Sytem webservices.
 */
class WSSystem extends Webservice
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
		$er = $this->getRequest();
		if ($er != 0) {
			$this->returnRequest([ 'e' => $er ]);
		} else {
			switch ($this->ac) {
				case 'System/GetConfig':
					$this->getSystemConfig();
					break;
				case 'System/Login':
					$this->checkLogin();
					break;
				case 'System/LoginRecover':
					$this->loginRecover();
					break;
				case 'System/Visitor':
					$this->checkVisitor();
					break;
				case 'System/VisitorCode':
					$this->checkVisitorCode();
					break;
				default:
					$this->returnRequest([ 'e' => -9 ]);
					break;
			}
		}
	}
	
	/** PRIVATE/PROTECTED METHODS **/
	
	/**
	 * Gets the system configuration.
	 */
	private function getSystemConfig() {
		// single user? get the access key
		$er = 0;
		if ($this->conf['singleUser']) {
			$er = $this->data->checkUser('single', '');
			if ($er == 0) {
				$key = $this->data->user['key'];
			}
		} else {
			$key = '';
		}
		// email configuration
		$mailer = new Mailer;
		// available fonts
		$fonts = [ ];
		$ck = $this->data->queryAll('SELECT * FROM fonts');
		foreach ($ck as $val) $fonts[] = [ 'n' => $val['fn_name'], 'v' => $val['fn_file'] ];
		// return the configuration
		$this->returnRequest([
			'e' => $er, 
			'singleUser' => $this->conf['singleUser'], 
			'userKey' => $key, 
			'validEmail' => $mailer->hasValidSender(), 
			'fonts' => $fonts, 
		]);
	}
	
	/**
	 * Checks a login attempt.
	 */
	private function checkLogin() {
		if ($this->requiredFields(['user', 'pass'])) {
			$er = $this->data->checkUser($this->req['user'], $this->req['pass']);
			if ($er == 0) {
				$this->returnRequest([
				'e' => $er,
				'userMail' => $this->data->user['email'], 
				'userKey' => $this->data->user['key'], 
				'userLevel' => $this->data->user['level'], 
			]);
			} else {
				$this->returnRequest([ 'e' => $er ]);
			}
		}
	}
	
	/**
	 * Recovers a password.
	 */
	private function loginRecover() {
		if ($this->requiredFields(['user'])) {
			if ($this->data->recoverUser($this->req['user'])) {
				$this->returnRequest([ 'e' => 0 ]);
			} else {
				$this->returnRequest([ 'e' => 1 ]);
			}
		}
	}
	
	/**
	 * Checks a visitor login attempt.
	 */
	private function checkVisitor() {
		if ($this->requiredFields(['email'])) {
			$code = $this->data->checkVisitor($this->req['email']);
			if ($code === false) {
				// database error or visitor blocked
				$this->returnRequest([ 'e' => 1 ]);
			} else {
				$mailer = new Mailer;
				if ($mailer->hasValidSender()) {
					$mailer->loadSender(true);
					// prepare message
					if (strpos($this->req['text'], '[CODE]') === false) {
						// no [CODE] mark
						$html = nl2br($this->req['text']) . '<p><strong>'.$code.'</strong></p>';
						$mesage = $this->req['text'] . "\r\n\r\n" . $code;
					} else {
						$html = nl2br(str_replace('[CODE]', ('<strong>'.$code.'</strong>'), $this->req['text']));
						$message = nl2br(str_replace('[CODE]', $code, $this->req['text']));
					}
					if ($mailer->send('', $this->req['sender'], $this->req['email'], '', $this->req['title'], $message, $html)) {
						// email sent
						$this->returnRequest([ 'e' => 0 ]);
					} else {
						// no mail sent
						$this->returnRequest([ 'e' => 3 ]);
					}
				} else {
					// no way to send code
					$this->returnRequest([ 'e' => 2 ]);
				}
			}
		}
	}
	
	/**
	 * Checks a visitor login code.
	 */
	private function checkVisitorCode() {
		if ($this->requiredFields(['email', 'code'])) {
			$key = $this->data->checkVisitorCode($this->req['email'], $this->req['code']);
			if ($key === false) {
				// no code found
				$this->returnRequest([ 'e' => 1 ]);
			} else {
				// code ok
				$this->returnRequest([
					'e' => 0, 
					'key' => $key, 
                    'groups' => $this->data->getVisitorGroups($this->req['email']), 
				]);
			}
		}
	}
}