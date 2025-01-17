<?php

/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

/** CLASS DEFINITIONS **/
require_once('BaseClass.php');

/**
 * Data access.
 */
class Data extends BaseClass
{
	
	/**
	 * current user information
	 */
	public $user = null;

	/**
	 * Constructor.
	 */
	public function __construct()
	{
		parent::__construct();
	}

	/**
	 * Checks for user login.
	 * @param string $email the user e-mail address (or "single")
	 * @param string $pass the user password (empty for single)
	 * @return int error code
	 * 0 => successfull login
	 * 1 => user e-mail not found
	 * 2 => wrong password
	 * 3 => error recovering user key
	 */
	public function checkUser($email, $pass) {
        // connected?
        if (is_null($this->db)) {
			// no db connection
			return (-6);
		} else {
			$ck = $this->queryAll('SELECT * FROM users WHERE us_email=:email', [':email'=>$email]);
			if (count($ck) == 0) {
				// no user found
				$this->user = null;
				return (1);
			} else {
				// check password
				if (($ck[0]['us_pass'] == md5($pass)) || (($email == 'single') && $this->conf['singleUser'])) {
					// user checked, setting new key
					$this->user = [
						'email' => $ck[0]['us_email'], 
						'level' => $ck[0]['us_level'], 
						'key' => md5(time().$ck[0]['us_email'].rand(1000, 9999)), 
					];
					if ($this->execute('UPDATE users SET us_key=:key, us_passtemp=:pass WHERE us_email=:email', [
						':key' => $this->user['key'], 
						':pass' => '', 
						':email' => $this->user['email'], 
					])) {
						// login completed
						return (0);
					} else {
						// error assigning key
						$this->user = null;
						return (3);
					}
				} else if ($ck[0]['us_passtemp'] == md5($pass)) {
					// using temporary password
					$this->user = [
						'email' => $ck[0]['us_email'], 
						'level' => $ck[0]['us_level'], 
						'key' => md5(time().$ck[0]['us_email'].rand(1000, 9999)), 
					];
					if ($this->execute('UPDATE users SET us_key=:key, us_pass=:pass, us_passtemp=:tpass WHERE us_email=:email', [
						':key' => $this->user['key'], 
						':pass' => md5($pass), 
						':tpass' => '', 
						':email' => $this->user['email'], 
					])) {
						// login completed
						return (0);
					} else {
						// error assigning key
						$this->user = null;
						return (3);
					}
				} else {
					// wrong password
					$this->user = null;
					return (2);
				}
			}
		}
    }
	
	/**
	 * Recovers an user passord.
	 * @param string $email the user e-mail address
	 * @return bool user located an recover email sent?
	 */
	public function recoverUser($email) {
        // connected?
        if (is_null($this->db)) {
			// no db connection
			return (false);
		} else {
			$ck = $this->queryAll('SELECT * FROM users WHERE us_email=:email', [':email'=>$email]);
			if (count($ck) == 0) {
				// no user found
				$this->user = null;
				return (false);
			} else {
				// create a password
				$pass = $this->randSring(8);
				$mailer = new Mailer;
				$sender = $mailer->loadSender(true);
				if ($sender['valid']) {
					// send the new password email
					$txt = 'Hello, you recently asked for an account recover for your ' . $sender['sender'] . ' account. Please return to the system login and provide your e-mail and this new password:' . "\r\n" . $pass . "\r\nIf you didn't ask for this, just ignore this message.";
					$html = '<p>Hello, you recently asked for an account recover for your ' . $sender['sender'] . ' account. Please return to the system login and provide your e-mail and this new password:<br /><strong>' . $pass . '</strong><br />If you didn\'t ask for this, just ignore this message.</p>';
					if ($mailer->send('', '', $email, '', ($sender['sender'] . ': password recover'), $txt, $html)) {
						// save temporary password
						$this->execute('UPDATE users SET us_passtemp=:pass WHERE us_email=:email', [
							':pass' => md5($pass), 
							':email' => $email, 
						]);
						return (true);
					} else {
						// error while sending the email
						return (false);
					}
				} else {
					// can't send emails
					return (false);
				}
			}
		}
    }
	
	/**
	 * Sets an user passord.
	 * @param string $email the user e-mail address
	 * @param string $pass the new password
	 * @return bool user located and new password set?
	 */
	public function setPassword($email, $pass) {
        // connected?
        if (is_null($this->db)) {
			// no db connection
			return (false);
		} else {
			$ck = $this->queryAll('SELECT * FROM users WHERE us_email=:email', [':email'=>$email]);
			if (count($ck) == 0) {
				// no user found
				$this->user = null;
				return (false);
			} else {
				// save as temporary password
				$this->execute('UPDATE users SET us_passtemp=:pass WHERE us_email=:email', [
					':pass' => md5($pass), 
					':email' => $email, 
				]);
				return (true);
			}
		}
    }
	
	/**
	 * Checks for visitor login.
	 * @param string $email the user e-mail address
	 * @return login code (false for visitor error)
	 */
	public function checkVisitor($email) {
        // connected?
        if (is_null($this->db)) {
			// no db connection
			return (false);
		} else {
            // visitor blocked?
            $ck = $this->queryAll('SELECT vb_email FROM visitorsblocked WHERE vb_email=:em', [
                ':em' => $email, 
            ]);
            if (count($ck) > 0) {
                // blocked visitor
                return (false);
            } else {
                // creating access code
                $code = $this->randSring(6);
                $this->execute('INSERT IGNORE INTO visitors (vs_email, vs_code) VALUES (:email, :code) ON DUPLICATE KEY UPDATE vs_code=VALUES(vs_code)', [
                    ':email' => $email, 
                    ':code' => $code, 
                ]);
                return ($code);
            }
		}
    }
	
	/**
	 * Checks for visitor login code.
	 * @param string $email the user e-mail address
	 * @param string $code the code to check
	 * @return user sign key or false if code is not valid
	 */
	public function checkVisitorCode($email, $code) {
        // connected?
        if (is_null($this->db)) {
			// no db connection
			return (false);
		} else {
            // visitor blocked?
            $ck = $this->queryAll('SELECT vb_email FROM visitorsblocked WHERE vb_email=:em', [
                ':em' => $email, 
            ]);
            if (count($ck) > 0) {
                // blocked visitor
                return (false);
            } else {
                // check code
                $ck = $this->queryAll('SELECT * FROM visitors WHERE vs_email=:email AND vs_code=:code AND vs_last>:limit', [
                    ':email' => $email, 
                    ':code' => $code, 
                    ':limit' => date('Y-m-d H:i:s', strtotime('-5hours')), 
                ]);
                if (count($ck) == 0) {
                    // code not found
                    return (false);
                } else {
                    $key = md5($this->randSring(16));
                    $this->execute('UPDATE visitors SET vs_key=:key WHERE vs_email=:email', [
                        ':key' => $key, 
                        ':email' => $email, 
                    ]);
                    return ($key);
                }
            }
		}
    }
    
    /**
	 * Gets a list of a visitor groups.
	 * @param string $email the visitor e-mail address
	 * @return array   the visitor groups lisy
	 */
	public function getVisitorGroups($email) {
        // connected?
        if (is_null($this->db)) {
			// no db connection
			return ([ ]);
		} else {
            // visitor blocked?
            $ck = $this->queryAll('SELECT vb_email FROM visitorsblocked WHERE vb_email=:em', [
                ':em' => $email, 
            ]);
            if (count($ck) > 0) {
                // blocked visitor
                return ([ ]);
            } else {
                // check groups
                $ck = $this->queryAll('SELECT va_group FROM visitorassoc WHERE va_visitor=:email GROUP BY va_group', [
                    ':email' => $email, 
                ]);
                $groups = [ ];
                foreach ($ck as $v) $groups[] = $v['va_group'];
                return ($groups);
            }
		}
    }
	
	/**
	 * Loads an user information.
	 * @param string $email the user e-mail
	 * @param bool $visitor look at the visitor's table instead of the user one?
	 * @return array the user information or null on error
	 */
	public function loadUser($email, $visitor = false) {
		$this->user = null;
		if (is_null($this->db)) {
			return(null);
		} else {
			if ($visitor) {
				$ck = $this->queryAll('SELECT * FROM visitors WHERE vs_email=:email', [
					':email' => $email, 
				]);
				if (count($ck) == 0) {
					// no user found
					return (null);
				} else {
					// reconvering current key
					$this->user = [
						'email' => $ck[0]['vs_email'], 
						'level' => $ck[0]['vs_level'], 
						'key' => $ck[0]['vs_key'], 
					];
					return ($this->user);
				}
			} else {
				$ck = $this->queryAll('SELECT * FROM users WHERE us_email=:email', [
					':email' => $email, 
				]);
				if (count($ck) == 0) {
					// no user found
					return (null);
				} else {
					// reconvering current key
					$this->user = [
						'email' => $ck[0]['us_email'], 
						'level' => $ck[0]['us_level'], 
						'key' => $ck[0]['us_key'], 
					];
					return ($this->user);
				}
			}
		}
	}
	
	/**
	 * Get the user's current access key.
	 * @param string $email the user email
	 * @param bool $visitor look at the visitor's table instead of the user one?
	 * @return string the current key or null if user not found
	 */
	public function getKey($email, $visitor = false) {
		if (is_null($this->db)) {
			return(null);
		} else {
			if ($visitor) {
				$ck = $this->queryAll('SELECT vs_key AS "key" FROM visitors WHERE vs_email=:email', [
					':email' => $email, 
				]);	
			} else {
				$ck = $this->queryAll('SELECT us_key AS "key" FROM users WHERE us_email=:email', [
					':email' => $email, 
				]);	
			}
			if (count($ck) == 0) {
				// no user found
				return (null);
			} else {
				// reconvering current key
				return ($ck[0]['key']);
			}
		}
	}
	
	/**
	 * Gets the available manageable user list for an admin.
	 * @param string $user admin user to check
	 * @return array user list
	 */
	public function userList($user) {
		$list = [ ];
		if (!is_null($this->db)) {
			$ck = $this->queryAll('SELECT us_level FROM users WHERE us_email=:em', [':em'=>$user]);
			if (count($ck) > 0) {
				if ($ck[0]['us_level'] == 0) {
					// system admin
					$ck = $this->queryAll('SELECT us_email, us_level FROM users where us_email!=:own AND us_email!=:single', [ ':own' => $user, ':single' => 'single' ]);
				} else if ($ck[0]['us_level'] <= 50) {
					// editors
					$ck = $this->queryAll('SELECT us_email, us_level FROM users where us_email!=:own AND us_email!=:single AND us_level>=:lv', [ ':own' => $user, ':single' => 'single', ':lv' => $ck[0]['us_level'] ]);
				} else {
					// authors (can't manage users)
					$ck = [ ];
				}
				foreach ($ck as $v) $list[] = [
					'user' => $v['us_email'], 
					'level' => (int)$v['us_level'], 
				];
			}
		}
		return ($list);
	}
	
	/**
	 * Creates an user account.
	 * @param	string	$current	current user e-mail
	 * @param	string	$email	new user e-mail address
	 * @param	string	$pass	new user password
	 * @param	int	$level	new user access level
	 * @return	int	error code
	 * 0 => user created
	 * 1 => new account email address already in use
	 * 2 => no database selected
	 * 3 => current user not found
	 * 4 => blank information sent
	 */
	public function createUser($current, $email, $pass, $level) {
		// check current user
		if (!is_null($this->db)) {
			$ck = $this->queryAll('SELECT us_level FROM users WHERE us_email=:em', [':em' => $current]);
			if (count($ck) == 0) {
				// user not found
				return (3);
			} else {
				// current level
				$curlevel = (int)$ck[0]['us_level'];
				// new user already exists?
				$ck = $this->queryAll('SELECT us_level FROM users WHERE us_email=:em', [':em' => $email]);
				if (count($ck) > 0) {
					return (1);
				} else {
					// blank information?
					if (($email == '') || ($pass == '') || ($level == '')) {
						return (4);
					} else {
						// adjust level?
						if ($level < $curlevel) $level = $curlevel;
						// create user
						$this->execute('INSERT INTO users (us_email, us_pass, us_passtemp, us_key, us_level) VALUES (:em, :pass, :tpass, :key, :lvl)', [
							':em' => $email, 
							':pass' => md5($pass), 
							':tpass' => '', 
							':key' => '', 
							':lvl' => $level, 
						]);
						return (0);
					}
				}
			}
		} else {
			// no database
			return (2);
		}
	}
	
	/**
	 * Removes an user account.
	 * @param	string	$current	current user e-mail
	 * @param	string	$email	remove user e-mail address
	 * @return	int	error code
	 * 0 => user removed
	 * 1 => no database selected
	 * 2 => user removing itself
	 * 3 => current user not found
	 * 4 => account to remove not found
	 * 5 => account to remove on lower access level
	 */
	public function removeUser($current, $email) {
		// check current user
		if (!is_null($this->db)) {
			if ($current == $email) {
				// same user: can't remove
				return (2);
			} else {
				$ck = $this->queryAll('SELECT us_level FROM users WHERE us_email=:em', [':em' => $current]);
				if (count($ck) == 0) {
					// user not found
					return (3);
				} else {
					// check removed user level
					$curlvl = (int)$ck[0]['us_level'];
					$ck = $this->queryAll('SELECT us_level FROM users WHERE us_email=:em', [':em' => $email]);
					if (count($ck) == 0) {
						// account not found
						return (4);
					} else if ((int)$ck[0]['us_level'] < $curlvl) {
						// can't remove user of this level
						return (5);
					} else {
						// remove user
						$this->execute('DELETE FROM users WHERE us_email=:em LIMIT 1', [':em' => $email]);
						return (0);
					}
				}
			}
		} else {
			// no database
			return (1);
		}
	}
	
	/**
	 * Sets an user account.
	 * @param	string	$current	current user e-mail
	 * @param	string	$email	user e-mail address
	 * @param	string	$pass	the new password
	 * @return	int	error code
	 * 0 => new password set
	 * 1 => no database selected
	 * 2 => user changing own password
	 * 3 => current user not found
	 * 4 => account to change not found
	 * 5 => account to change on lower access level
	 */
	public function setUserPassword($current, $email, $pass) {
		// check current user
		if (!is_null($this->db)) {
			if ($current == $email) {
				// same user: can't change
				return (2);
			} else {
				$ck = $this->queryAll('SELECT us_level FROM users WHERE us_email=:em', [':em' => $current]);
				if (count($ck) == 0) {
					// user not found
					return (3);
				} else {
					// check user level
					$curlvl = (int)$ck[0]['us_level'];
					$ck = $this->queryAll('SELECT us_level FROM users WHERE us_email=:em', [':em' => $email]);
					if (count($ck) == 0) {
						// account not found
						return (4);
					} else if ((int)$ck[0]['us_level'] < $curlvl) {
						// can't change password for user of this level
						return (5);
					} else {
						// set user password
						$this->execute('UPDATE users SET us_passtemp=:pass WHERE us_email=:em', [
							':em' => $email, 
							':pass' => md5($pass), 
						]);
						return (0);
					}
				}
			}
		} else {
			// no database
			return (1);
		}
	}
    
    /**
     * Gets the current system version.
     * @return  int the version number
     */
    public function version() {
        $version = 1;
        $ck = $this->queryAll('SELECT cf_value FROM config WHERE cf_key=:ver', [':ver' => 'dbVersion']);
        if (count($ck) > 0) $version = $ck[0]['cf_value'];
        return ($version);
    }
	
	/**
	 * Gets a CSS declare for used fonts.
	 * @param	string	$movie	initial movie
	 * @return	string	css-formatted text fopr font face loading
	 */
	public function indexFonts($movie) {
		$fonts = [ ];
		$ck = $this->queryAll('SELECT * FROM fonts');
		foreach ($ck as $v) {
			$fonts[$v['fn_name']] = '@font-face { font-family: "' . $v['fn_name'] . '"; src: url("' . $this->conf['path'] . 'font/' . $v['fn_file'] . '"); }';
		}
		if ($movie != '') {
			$ck = $this->queryAll('SELECT mv_fonts FROM movies WHERE mv_id=:id', [':id' => $movie]);
			if (count($ck) > 0) {
				if ($ck[0]['mv_fonts'] != '') {
					$json = json_decode(gzdecode(base64_decode($ck[0]['mv_fonts'])), true);
					if (json_last_error() == JSON_ERROR_NONE) {
						foreach ($json as $k => $v) {
							if (isset($v['name']) && isset($v['file'])) {
								$fonts[$v['name']] = '@font-face { font-family: "' . $v['name'] . '"; src: url("' . $this->conf['path'] . 'movie/' . $movie . '.movie/media/font/' . $v['file'] . '"); }';
							}
						}
					}
				}
			}
		}
		$return = '';
		foreach ($fonts as $f) $return .= $f . ' ';
		return ($return);
	}
	
	/**
	 * Recovers a list of active plugins that require index page adjustements.
	 * @return	array	plugin list
	 */
	public function pluginIndex() {
		$pl = [ ];
		$ck = $this->queryAll('SELECT pc_id, pc_file FROM pluginconfig WHERE pc_active=:ac AND pc_index=:in', [
			':ac' => '1', 
			':in' => '1', 
		]);
		foreach ($ck as $v) $pl[] = [ 'id' => $v['pc_id'], 'fl' => $v['pc_file'] ];
		return ($pl);
	}
	
	/**
	 * Recovers a list of active plugins that require custom webservices.
	 * @return	array	plugin list
	 */
	public function pluginWs() {
		$pl = [ ];
		$ck = $this->queryAll('SELECT pc_id, pc_file FROM pluginconfig WHERE pc_active=:ac AND pc_ws=:ws', [
			':ac' => '1', 
			':ws' => '1', 
		]);
		foreach ($ck as $v) $pl[] = [ 'id' => $v['pc_id'], 'fl' => $v['pc_file'] ];
		return ($pl);
	}
    
    /**
     * Checks domains allowed to request actions on this server webservices.
     * @return  array   the allowed domains list
     */
    public function checkCORS() {
        $list = [ ];
        $ck = $this->queryAll('SELECT * FROM cors');
        foreach ($ck as $v) $list[] = mb_strtolower($this->slashUrl($v['cr_domain']));
        return ($list);
    }
}