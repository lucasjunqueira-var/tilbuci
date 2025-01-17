<?php

/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

/** CLASS DEFINITIONS **/
require_once('Webservice.php');
require_once('Mailer.php');

/**
 * E-mail related webservices.
 */
class WSEmail extends Webservice
{	
	/**
	 * Class constructor.
	 */
	public function __construct($ac)
	{
		parent::__construct($ac);
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
				case 'Email/CheckCode':
					$this->checkCode();
					break;
				case 'Email/GetConfig':
					$this->getEmailConfig();
					break;
				case 'Email/Save':
					$this->saveEmailConfig();
					break;
				default:
					$this->returnRequest([ 'e' => -9 ]);
					break;
			}
		}
	}
	
	/** PRIVATE/PROTECTED METHODS **/
	
	/**
	 * Gets the email configuration.
	 */
	private function getEmailConfig() {
		// admin only
		if ($this->checkAdmin()) {
			// sending the current setting
			$mailer = new Mailer;
			$response = $mailer->loadSender();
			$response['e'] = 0;
			$this->returnRequest($response);
		}
	}
	
	/**
	 * Saves an email configuration.
	 */
	private function saveEmailConfig() {
		// admin only
		if ($this->checkAdmin()) {
			// required fields received?
			if (isset($this->req['sender']) && isset($this->req['email']) && isset($this->req['server']) && isset($this->req['user']) && isset($this->req['password']) && isset($this->req['port']) && isset($this->req['security']) && isset($this->req['lang'])) {
				// setting language
				$this->loadLang($this->req['lang']);
				// creating confimation code and messages
				$code = $this->randSring(6);
				$text = str_replace('[CODE]', $code, $this->getLang('setting-email-msgtext'));
				$html = str_replace('[CODE]', $code, $this->getLang('setting-email-msghtml'));
				// validating settings
				$mailer = new Mailer;
				$mailer->setSMTP($this->req['server'], $this->req['user'], $this->req['password'], $this->req['port'], $this->req['security']);
				if ($mailer->send($this->req['email'], $this->req['sender'], $this->req['email'], $this->req['sender'], $this->getLang('setting-email-subject'), $text, $html)) {
					// clearing previous settings
					$this->data->clearConfig('validEmail');
					$this->data->setConfig('attemptEmail', json_encode([
						'vallid' => false, 
						'server' => $this->req['server'],
						'sender' => $this->req['sender'], 
						'email' => $this->req['email'], 
						'user' => $this->req['user'], 
						'password' => $this->encrypt($this->req['password']), 
						'port' => $this->req['port'], 
						'security' => $this->req['security'], 
						'istls' => false, 
						'code' => $code, 
					]));
					// e-mail sent
					$this->returnRequest([ 'e' => 0 ]);
				} else {
					// send failure
					$this->returnRequest([ 'e' => 2 ]);
				}
			} else {
				// not all fields received
				$this->returnRequest([ 'e' => 1 ]);
			}
		}
	}
	
	/**
	 * Checks the e-mail setting validation code.
	 */
	private function checkCode() {
		// admin only
		if ($this->checkAdmin()) {
			$mailer = new Mailer;
			$this->returnRequest([ 'e' => $mailer->checkCode($this->req['code']) ]);
		}
	}
}