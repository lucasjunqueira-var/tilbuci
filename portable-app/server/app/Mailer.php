<?php

/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

/** CLASS DEFINITIONS **/
require_once('Data.php');

/**
 * Mailer information.
 */
class Mailer extends Data
{

	/**
	 * server address
	 */
    private $server = null;
	
	/**
	 * connection port
	 */
	private $port = null;
	
	/**
	 * user login
	 */
	private $login = null;
	
	/**
	 * user password
	 */
	private $pass = null;
	
	/**
	 * request security
	 */
	private $security = null;
	
	/**
	 * use TLS crypto? (currently not supported)
	 */
	private $tls = false;
	
	/**
	 * connection socket
	 */
	private $socket = false;
	
	/**
	 * text charset
	 */
	private $charset = 'utf-8';
	
	/**
	 * line break string
	 */
	private $lb = "\r\n";
	
	/**
	 * the current e-mail settings
	 */
	public $currentSettings = [
		'valid' => false, 
		'server' => '',
		'sender' => 'Tilbuci', 
		'email' => '', 
		'user' => '', 
		'password' => '', 
		'port' => '465', 
		'security' => 'ssl', 
		'istls' => false, 
	];
	
	/**
	 * Sets the SMTP configuration.
	 * @param string $sr the server address
	 * @param string $login user login
	 * @param string $password user password
	 * @param int $pr connection port
	 * @param string $sec request security
	 * @param bool $istls TLS crypto (currently not supported)
	 */
	public function setSMTP($sr, $login, $password, $pr, $sec = null, $istls = false) {
		$this->server = $sr;
		$this->port = $pr;
		$this->login = $login;
		$this->pass = $password;
		$this->security = (is_null($sec) || ($sec == '')) ? '' : $sec . '://';
		$this->tls = $istls;
	}
	
	/**
	 * Sends an e-mail.
	 * @param string $frommail sender e-mail address
	 * @param string $fromname sender name
	 * @param string $tomail recipient e-mail address
	 * @param string $toname recipient name
	 * @param string $subject message subject
	 * @param string $txt plain text message
	 * @param string $html html-formatted message
	 * @return bool was the message sent?
	 */
	public function send($frommail, $fromname, $tomail, $toname, $subject, $txt, $html) {
		// open socket
		$this->socket = @fsockopen(
			($this->security . $this->server), 
			$this->port, 
			$errno, 
			$errstr, 
			30
		);
		// correclty opened?
		if ($this->socket === false) {
			return (false);
		} else {
			// contacting SMTP server
			$this->sendCommand('EHLO ' . gethostname());
			
			// TLS crypto (not currently supported)
			/*if ($this->tls) {
				$this->sendCommand('STARTTLS');
				stream_socket_enable_crypto($this->socket, true, STREAM_CRYPTO_METHOD_TLS_CLIENT);
				$this->sendCommand('EHLO ' . gethostname());
			}*/
			
			// prepare header
			$bd = md5(uniqid(microtime(true), true));
			if (($frommail == '') && $this->currentSettings['valid']) $frommail = $this->currentSettings['email'];
			if (($fromname == '') && $this->currentSettings['valid']) $fromname = $this->currentSettings['sender'];
			$headers = [
				'X-Mailer: PHP/' . phpversion(), 
				'MIME-Version: 1.0', 
				'Date: ' . date('r'), 
				'Subject: ' . $subject, 
				'From: ' . ($fromname . ' <' . $frommail . '>'), 
				'Return-Path: ' . ($fromname . ' <' . $frommail . '>'), 
				'To: ' . ($toname == '' ? $tomail : ($toname . ' <' . $tomail . '>')), 
				'Content-Type: multipart/alternative; boundary="alt-' . $bd . '"', 
			];
			$hd = implode($this->lb, $headers) . $this->lb;
			
			// prepare message
			$msg = '--alt-' . $bd . $this->lb;
            $msg .= 'Content-Type: text/plain; charset=' . $this->charset . $this->lb;
            $msg .= 'Content-Transfer-Encoding: base64' . $this->lb . $this->lb;
            $msg .= chunk_split(base64_encode($txt)) . $this->lb;
			$msg .= '--alt-' . $bd . $this->lb;
            $msg .= 'Content-Type: text/html; charset=' . $this->charset . $this->lb;
            $msg .= 'Content-Transfer-Encoding: base64' . $this->lb . $this->lb;
            $msg .= chunk_split(base64_encode($html)) . $this->lb;
			$msg .= '--alt-' . $bd . '--' . $this->lb . $this->lb;
			
			// send message
			$this->sendCommand('AUTH LOGIN');
			$this->sendCommand(base64_encode($this->login));
			$this->sendCommand(base64_encode($this->pass));
			$this->sendCommand('MAIL FROM: <' . $frommail . '>');
			$this->sendCommand('RCPT TO: <' . $tomail . '>');
			$this->sendCommand('DATA');
			$response = $this->sendCommand($hd . $this->lb . $msg . $this->lb . '.');
			$this->sendCommand('QUIT');
			fclose($this->socket);
			$this->socket = false;
			
			// returning
			return ((substr($response, 0, 3) == '250') || (substr($response, 0, 3) == '354'));
		}
	}
	
	/**
	 * Does the system has a valid e-mail configuration?
	 * @return bool configuraiton found?
	 */
	public function hasValidSender() {
		$sender = $this->getConfig('validEmail');
		if ($sender === false) {
			// no valid email
			return (false);
		} else {
			// valid email found
			return (true);
		}
	}
	
	/**
	 * Loads the current e-mail sending configuration.
	 * @param bool $setSmtp automatically sets smtp if valid configuration found?
	 * @return array the current settings
	 */
	public function loadSender($setSmtp = false) {
		// is there a valid e-mail?
		$sender = $this->getConfig('validEmail');
		if ($sender === false) {
			// is there a configuration to validate?
			$sender = $this->getConfig('attemptEmail');
			if ($sender === false) { 
				// no setting at all
				$this->currentSettings = [
					'valid' => false, 
					'server' => '',
					'sender' => 'TilBuci', 
					'email' => '', 
					'user' => '', 
					'password' => '', 
					'port' => '465', 
					'security' => 'ssl', 
					'istls' => false, 
					'attempt' => false, 
				];
			} else {
				// load the configuration
				$json = json_decode($sender, true);
				if (json_last_error() != JSON_ERROR_NONE) {
					// configuration error
					$this->currentSettings = [
						'valid' => false, 
						'server' => '',
						'sender' => 'TilBuci', 
						'email' => '', 
						'user' => '', 
						'password' => '', 
						'port' => '465', 
						'security' => 'ssl', 
						'istls' => false, 
						'attempt' => false, 
					];
				} else {
					$this->currentSettings = $json;
					$this->currentSettings['valid'] = false;
					$this->currentSettings['attempt'] = true;
					$this->currentSettings['password'] = $this->decrypt($this->currentSettings['password']);
				}
			}
		} else {
			// load the configuration
			$json = json_decode($sender, true);
			if (json_last_error() != JSON_ERROR_NONE) {
				// configuration error
				$this->currentSettings = [
					'valid' => false, 
					'server' => '',
					'sender' => 'TilBuci', 
					'email' => '', 
					'user' => '', 
					'password' => '', 
					'port' => '465', 
					'security' => 'ssl', 
					'istls' => false, 
					'attempt' => false, 
				];
			} else {
				$this->currentSettings = $json;
				$this->currentSettings['valid'] = true;
				$this->currentSettings['attempt'] = false;
			}
		}
		if ($setSmtp && $this->currentSettings['valid']) {
			$this->setSMTP(
				$this->currentSettings['server'],
				$this->currentSettings['user'],
				$this->decrypt($this->currentSettings['password']),
				$this->currentSettings['port'],
				$this->currentSettings['security'],
				$this->currentSettings['istls']);
		}
		return ($this->currentSettings);
	}
	
	/**
	 * Checks an e-mail setting validation code.
	 * @param string $code the code to check
	 * @return int error code:
	 * 0 => code validated
	 * 1 => no e-mail setting to validate
	 * 2 => corrupted validation settings found
	 * 3 => wrong code
	 */
	public function checkCode($code) {
		$check = $this->getConfig('attemptEmail');
		if ($check === false) {
			// no email settings to be validated
			return (1);
		} else {
			$json = json_decode($check, true);
			if (json_last_error() != JSON_ERROR_NONE) {
				// corrupted information
				return (2);
			} else {
				if (!isset($json['code'])) {
					// corrupted information
					return (2);
				} else if (strtoupper($json['code']) != strtoupper($code)) {
					// wrong code
					return (3);
				} else {
					// validate e-mail
					$json['valid'] = true;
					unset($json['code']);
					$this->clearConfig('attemptEmail');
					$this->setConfig('validEmail', json_encode($json));
					return (0);
				}
			}
		}
	}
	
	/**
	 * Sends a command to the SMTP server.
	 * @param string $command the command to send
	 * @return string the server response
	 */
	private function sendCommand($command) {
        fputs($this->socket, $command . $this->lb);
		$resp = $this->getResponse();
		return ($resp);
    }
	
	/**
	 * Retrieves a response from the SMTP server.
	 * @return string the server response
	 */
	private function getResponse()
    {
        $response = '';
        stream_set_timeout($this->socket, 10);
        while (($line = fgets($this->socket, 515)) !== false) {
            $response .= trim($line) . "\n";
            if (substr($line, 3, 1) == ' ') {
                break;
            }
        }
        return trim($response);
    }

}