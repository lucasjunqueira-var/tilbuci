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
 * User webservices.
 */
class WSUser extends Webservice
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
				case 'User/SetPassword':
					$this->setPassword();
					break;
				case 'User/List':
					$this->getUserList();
					break;
				case 'User/Create':
					$this->createUser();
					break;
				case 'User/Remove':
					$this->removeUser();
					break;
				case 'User/SetUserPassword':
					$this->setUserPassword();
					break;
			}
		}
	}
	
	/** PRIVATE/PROTECTED METHODS **/
	
	/**
	 * Sets the current user new password.
	 */
	private function setPassword() {
		if ($this->requiredFields(['user', 'pass'])) {
			// own password?
			if ($this->req['user'] == $this->user) {
				if ($this->data->setPassword($this->req['user'], $this->req['pass'])) {
					// new password set
					$this->returnRequest([ 'e' => 0 ]);
				} else {
					// error while setting the password
					$this->returnRequest([ 'e' => 2 ]);
				}
			} else {
				// not the same user as request
				$this->returnRequest([ 'e' => 1 ]);
			}
		}
	}
	
	/**
	 * Gets the users list.
	 */
	private function getUserList() {
		$this->returnRequest([
			'e' => 0, 
			'list' => $this->data->userList($this->user), 
		]);
	}
	
	/**
	 * Creates an user account.
	 */
	private function createUser() {
		if ($this->requiredFields(['email', 'pass', 'level'])) {
			$this->returnRequest([ 'e' => $this->data->createUser($this->user, $this->req['email'], $this->req['pass'], $this->req['level']) ]);
		}
	}
	
	/**
	 * Removes an user account.
	 */
	private function removeUser() {
		if ($this->requiredFields(['email'])) {
			$this->returnRequest([ 'e' => $this->data->removeUser($this->user, $this->req['email']) ]);
		}
	}
	
	/**
	 * Sets an user password.
	 */
	private function setUserPassword() {
		if ($this->requiredFields(['email', 'pass'])) {
			$this->returnRequest([ 'e' => $this->data->setUserPassword($this->user, $this->req['email'], $this->req['pass']) ]);
		}
	}
}