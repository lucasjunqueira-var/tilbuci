<?php

/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

/** CLASS DEFINITIONS **/
require_once('Webservice.php');
require_once('Movie.php');

/**
 * File upload webservices.
 */
class WSFile extends Webservice
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
				case 'File/Font':
					$this->font();
					break;
				case 'File/ExtFont':
					$this->font(true);
					break;
				case 'File/RemoveFont':
					$this->removeFont();
					break;
				default:
					$this->returnRequest([ 'e' => -9 ]);
					break;
			}
		}
	}
	
	/** PRIVATE/PROTECTED METHODS **/
	
	/**
	 * Required upload fields received?
	 * @param bool $ext uploading using js externals?
	 */
	protected function requiredFields($list = [ ], $ext = false) {	
		if ($ext && isset($this->req['fname']) && isset($_POST['remove']) && ($_POST['remove'] == '1')) {
			$this->req['fname'] = $this->cleanString($this->req['fname']);
			return (true);
		} else if ($ext && isset($this->req['fname']) && isset($this->req['path']) && isset($_FILES['TBU_file']) && isset($_POST['p']) && isset($_POST['b']) && isset($_POST['t'])) {
			$this->req['fname'] = $this->cleanString($this->req['fname']);
			return (true);
		} else if (isset($this->req['fname']) && isset($this->req['fcontent']) && isset($this->req['path'])) {
			$this->req['fname'] = $this->cleanString($this->req['fname']);
			return (true);
		} else {
			// file not received
			$this->returnRequest([ 'e' => 1, 'req' => $this->req, 'ext' => $etx ]);
			return (false);
		}
	}
	
	/**
	 * Saves the received data to a file.
	 * @param string $path the local file path
	 */
	private function saveB64($path) {
		$handle = fopen($path, 'w');
		stream_filter_append($handle, 'convert.base64-decode', STREAM_FILTER_WRITE);
		fwrite($handle, $this->req['fcontent']);
		fclose($handle);
	}
	
	/**
	 * Saves a file part uploaded by js externals.
	 * @return bool was te part received?
	 */
	private function saveExtern() {
		// remove partial file?
		if ($_POST['remove'] == '1') {
			@unlink($this->req['path'] . $this->req['fname']);
			return (true);
		} else {
			// first piece? remove previous file
			if ($_POST['p'] == 0) @unlink($this->req['path'] . $this->req['fname']);
			// get current part
			$size = $_FILES['TBU_file']['size'];
			$in = fopen($_FILES['TBU_file']['tmp_name'], "rb");
			$out = fopen(($this->req['path'] . $this->req['fname']), "ab");
			$ok = true;
			if ($out) {
				if ($in) {
					while ($buff = fread($in, $_POST['b'])) {
						fwrite($out, $buff);
					}   
				} else {
					$ok = false;
				}
				fclose($out);
			} else {
				// error opening the destination file
				$ok = false;
			}
			return ($ok);
		}
	}
	
	/**
	 * Received the last piece of a js extern upload?
	 */
	private function lastPiece() {
		if (isset($_POST['p']) && isset($_POST['t'])) {
			return ($_POST['p'] >= ($_POST['t'] - 1));
		} else {
			return (false);
		}
	}
	
	/**
	 * Receiving a font file.
	 * @param bool $ext uploading using js externals?
	 */
	private function font($ext = false) {
		// required fields received?
		if ($this->requiredFields([], $ext)) {
			// js externals?
			if ($ext) {
				if ($this->saveExtern()) {
					// part download ok
					if ($this->lastPiece()) {
						// movie font?
						if (isset($this->req['movie'])) {
							// register font
							$ck = $this->data->queryAll('SELECT mv_fonts FROM movies WHERE mv_id=:mv AND mv_user=:us', [
								':mv' => $this->req['movie'], 
								':us' => $this->user, 
							]);
							if (count($ck) == 0) {
								// movie not found
								$this->returnRequest([
									'e' => 2, 
									'part' => $_POST['p'],
									'total' => $_POST['t'],
									'name' => $this->req['name'], 
									'fname' => $this->req['fname'], 
								]);
							} else {
								if ($ck[0]['mv_fonts'] == '') {
									$fonts = [ ];
								} else {
									$fonts = json_decode(gzdecode(base64_decode($ck[0]['mv_fonts'])), true);
									if (json_last_error() != JSON_ERROR_NONE) $fonts = [ ];
								}
								$fonts[] = [
									'name' => $this->req['name'], 
									'file' => $this->req['fname'], 
								];
								$this->data->execute('UPDATE movies SET mv_fonts=:ft WHERE mv_id=:mv', [
									':ft' => base64_encode(gzencode(json_encode($fonts))), 
									':mv' => $this->req['movie'], 
								], 'UPDATE movies SET mv_fonts=:ft, mv_updated=:time WHERE mv_id=:mv', [
									':ft' => base64_encode(gzencode(json_encode($fonts))), 
									':time' => date('Y-m-d H:i:s'), 
									':mv' => $this->req['movie'], 
								]);
								$mv = new Movie($this->req['movie']);
								$mv->publish();
								$this->returnRequest([
									'e' => 0, 
									'part' => $_POST['p'],
									'total' => $_POST['t'],
									'name' => $this->req['name'], 
									'fname' => $this->req['fname'], 
									'mfonts' => $fonts, 
								]);
							}
						} else {
							// register font
							$this->data->execute('DELETE FROM fonts WHERE fn_name=:name', [':name' => $this->req['name']]);
							$this->data->execute('INSERT INTO fonts (fn_name, fn_file) VALUES (:name, :file)', [
								':name' => $this->req['name'], 
								':file' => $this->req['fname'], 
							]);
							// warn about complete
							$this->returnRequest([
								'e' => 0, 
								'part' => $_POST['p'],
								'total' => $_POST['t'],
								'name' => $this->req['name'], 
								'fname' => $this->req['fname'], 
							]);
						}
					} else {
						// ask for the next piece
						$this->returnRequest([
							'e' => 0, 
							'part' => $_POST['p'],
							'total' => $_POST['t'],
							'name' => $this->req['name'], 
							'fname' => $this->req['fname'], 
						]);
					}
				} else {
					// part download failure
					$this->returnRequest([
						'e' => 2, 
						'part' => $_POST['p'],
						'total' => $_POST['t'],
						'name' => $this->req['name'], 
						'fname' => $this->req['fname'], 
					]);
				}
			} else {
				// save font
				$this->saveB64($this->req['path'] . $this->req['fname']);
				// register font
				$this->data->execute('DELETE FROM fonts WHERE fn_name=:name', [':name' => $this->req['name']]);
				$this->data->execute('INSERT INTO fonts (fn_name, fn_file) VALUES (:name, :file)', [
					':name' => $this->req['name'], 
					':file' => $this->req['fname'], 
				]);
				// returning
				$this->returnRequest([
					'e' => 0, 
					'name' => $this->req['name'], 
					'fname' => $this->req['fname'], 
				]);
			}
		}
	}
	
	/**
	 * Removes a system font.
	 */
	private function removeFont() {
		if (isset($this->req['name'])) {
			// remove font
			$this->data->execute('DELETE FROM fonts WHERE fn_name=:name', [':name' => $this->req['name']]);
			$this->returnRequest([
				'e' => 0, 
				'name' => $this->req['name'], 
			]);
		} else {
			// no font to remove
			$this->returnRequest([
				'e' => 1, 
			]);
		}
	}
}