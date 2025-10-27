<?php

/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

/** CLASS DEFINITIONS **/
require_once('Webservice.php');
require_once('Media.php');

/**
 * Media operations.
 */
class WSMedia extends Webservice
{	

	/**
	 * expected media file extensions
	 */
	private $mediaExt = [
		'picture' => [ 'jpg', 'png', 'jpeg' ], 
		'audio' => [ 'mp3', 'm4a' ], 
		'video' => [ 'mp4', 'webm' ], 
		'html' => [ 'html', 'htm' ], 
		'spritemap' => [ 'png' ], 
	];

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
				case 'Media/List':
					$this->listMedia();
					break;
				case 'Media/NewFolder':
					$this->newFolder();
					break;
				case 'Media/DeleteFolder':
					$this->deleteFolder();
					break;
				case 'Media/DeleteFile':
					$this->deleteFile();
					break;
				case 'Media/ExtUpload':
					$this->receiveFile();
					break;
				case 'Media/CreateCollection':
					$this->createCollection();
					break;
				case 'Media/ListCollections':
					$this->listCollections();
					break;
                case 'Media/ListRmCollections':
					$this->listRmCollections();
					break;
                case 'Media/ListCollectionsFull':
					$this->listCollectionsFull();
					break;
				case 'Media/ListColAssets':
					$this->listColAssets();
				case 'Media/StringsJSON':
					$this->getStringsJSON();
					break;
                case 'Media/Embed':
					$this->embed();
					break;
                case 'Media/EmbedImport':
					$this->embedImport();
					break;
                case 'Media/EmbedRemove':
					$this->embedRemove();
					break;
                case 'Media/RemoveCollection':
					$this->removeCollection();
					break;
				default:
					$this->returnRequest([ 'e' => -9 ]);
					break;
			}
		}
	}
	
	/** PRIVATE/PROTECTED METHODS **/
	
	/**
	 * Loading a list of media files.
	 */
	private function listMedia() {
		// required fields received?
		if ($this->requiredFields(['movie', 'type', 'path'])) {
			$md = new Media;
			$er = $md->listFiles($this->req['movie'], $this->req['type'], $this->req['path']);
			if ($er == 0) {
				$this->returnRequest([ 'e' => 0, 'list' => $md->flist ]);
			} else {
				$this->returnRequest([ 'e' => $er ]);
			}
		}
	}
	
	/**
	 * Creates a folder.
	 */
	private function newFolder() {
		// required fields received?
		if ($this->requiredFields(['movie', 'type', 'path', 'name'])) {
			$md = new Media;
			if ($md->newFolder($this->req['movie'], $this->req['type'], $this->req['path'], $this->req['name'])) {
				$this->returnRequest([ 'e' => 0, 'list' => $md->flist ]);
			} else {
				$this->returnRequest([ 'e' => 1 ]);
			}
		}
	}
	
	/**
	 * Deletes a folder.
	 */
	private function deleteFolder() {
		// required fields received?
		if ($this->requiredFields(['movie', 'type', 'path', 'name'])) {
			$md = new Media;
			if ($md->deleteFolder($this->req['movie'], $this->req['type'], $this->req['path'], $this->req['name'])) {
				$this->returnRequest([ 'e' => 0 ]);
			} else {
				$this->returnRequest([ 'e' => 1 ]);
			}
		}
	}
	
	/**
	 * Deletes a file.
	 */
	private function deleteFile() {
		// required fields received?
		if ($this->requiredFields(['movie', 'type', 'path', 'name'])) {
			$md = new Media;
			if ($md->deleteFile($this->req['movie'], $this->req['type'], $this->req['path'], $this->req['name'])) {
				$this->returnRequest([ 'e' => 0 ]);
			} else {
				$this->returnRequest([ 'e' => 1 ]);
			}
		}
	}
	
	/**
	 * Creates a collection.
	 */
	private function createCollection() {
		// required fields received?		
		if ($this->requiredFields(['movie', 'id', 'name'])) {
			$md = new Media;
			$id = $md->createCollection($this->req['movie'], $this->req['id'], $this->req['name']);
			$this->returnRequest([ 'e' => 0 , 'id' => $id, 'name' => $this->req['name'] ]);
		}
	}
	
	/**
	 * Lists a movie collections.
	 */
	private function listCollections() {
		// required fields received?		
		if ($this->requiredFields(['movie'])) {
			$md = new Media;
			$er = $md->listCollections($this->req['movie']);
			if ($er == 0) {
				$this->returnRequest([ 'e' => 0, 'list' => $md->dlist ]);
			} else {
				$this->returnRequest([ 'e' => $er ]);
			}
		}
	}
    
    /**
	 * Lists collections of a movie for removal.
	 */
	private function listRmCollections() {
		// required fields received?		
		if ($this->requiredFields(['movie'])) {
			$md = new Media;
			$er = $md->listRmCollections($this->req['movie']);
			if ($er == 0) {
				$this->returnRequest([ 'e' => 0, 'list' => $md->dlist ]);
			} else {
				$this->returnRequest([ 'e' => $er ]);
			}
		}
	}
    
    /**
	 * Lists a movie collections full information.
	 */
	private function listCollectionsFull() {
		// required fields received?		
		if ($this->requiredFields(['movie'])) {
			$md = new Media;
			$er = $md->listCollectionsFull($this->req['movie']);
			if ($er == 0) {
				$this->returnRequest([ 'e' => 0, 'list' => $md->dlist ]);
			} else {
				$this->returnRequest([ 'e' => $er ]);
			}
		}
	}
	
	/**
	 * Lists a collection assets.
	 */
	private function listColAssets() {
		// required fields received?		
		if ($this->requiredFields(['uid'])) {
			$md = new Media;
			$er = $md->listColAssets($this->req['uid']);
			if ($er == 0) {
				$this->returnRequest([ 'e' => 0, 'list' => $md->dlist ]);
			} else {
				$this->returnRequest([ 'e' => $er ]);
			}
		}
	}
	
	/**
	 * Receives a strings.json file.
	 */
	private function getStringsJSON() {
		// required fields received?		
		if ($this->requiredFields(['movie', 'strings'])) {
			$md = new Media;
			if ($md->getStringsJSON($this->req['movie'], $this->req['strings'])) {
				$this->returnRequest([ 'e' => 0 ]);
			} else {
				$this->returnRequest([ 'e' => 1 ]);
			}
		}
	}
	
	/**
	 * Receiving a file.
	 * @param bool $ext uploading using js externals?
	 */
	private function receiveFile() {
		// required fields received?
		if ($this->requiredFields(['movie', 'type', 'path', 'fname'])) {
			if ($this->saveExtern()) {
				if ($this->lastPiece()) {
					// warn about complete
					$this->returnRequest([
						'e' => 0, 
						'part' => $_POST['p'],
						'total' => $_POST['t'],
						'fname' => $this->req['fname'], 
						'movie' => $this->req['movie'], 
						'type' => $this->req['type'], 
						'path' => $this->req['path'], 
					]);
				} else {
					// ask for the next piece
					$this->returnRequest([
						'e' => 0, 
						'part' => $_POST['p'],
						'total' => $_POST['t'],
						'fname' => $this->req['fname'], 
						'movie' => $this->req['movie'], 
						'type' => $this->req['type'], 
						'path' => $this->req['path'], 
					]);
				}
			} else {
				// part download failure
				$this->returnRequest([
					'e' => 1, 
					'part' => $_POST['p'],
					'total' => $_POST['t'],
					'fname' => $this->req['fname'], 
					'movie' => $this->req['movie'], 
					'type' => $this->req['type'], 
					'path' => $this->req['path'], 
				]);
			}
		}
	}
	
	/**
	 * Saves a file part uploaded by js externals.
	 * @return bool was te part received?
	 */
	private function saveExtern() {
		// path to the file
        if ($this->req['type'] == 'movie') {
            $path = '../../export/' . $this->req['movie'] . '.zip';
		} else if ($this->req['type'] == 'update') {
            $path = '../../export/update.zip';
		} else if (substr($this->req['type'], 0, 4) == 'zip_') {
            $path = '../../export/' . $this->req['type'] . '.zip';
        } else if ($this->req['type'] == 'embed') {
            if (!is_dir('../../embed/')) {
                $this->data->createDir('../../embed/');
            }
            $path = '../../embed/' . $this->req['path'] . '.zip';
        } else {
            $path = str_replace('../', '', $this->req['path']);
            if (substr($path, 0, 1) == '/') $path = substr($path, 1);
            if (substr($path, -1) != '/') $path .= '/';
            $path = str_replace('//', '', $path);
            $path = '../movie/' . $this->req['movie'] . '.movie/media/' . $this->req['type'] . '/' . $path . $this->req['fname'];
        }
		// remove partial file?
		if ($_POST['remove'] == '1') {
			@unlink($path);
			return (true);
		} else {
			// first piece? remove previous file
			if ($_POST['p'] == 0) @unlink($path);
			// get current part
			$size = $_FILES['TBU_file']['size'];
			$in = fopen($_FILES['TBU_file']['tmp_name'], "rb");
			$out = fopen($path, "ab");
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
            if ($_POST['p'] >= ($_POST['t'] - 1)) {
                $r = json_decode($_POST['r'], true);
                if (json_last_error() == JSON_ERROR_NONE) {
                    if (isset($r['type']) && isset($r['movie']) && isset($r['fname'])) {
						if (substr($r['type'], 0, 4) == 'zip_') {
							// unpack media zip file
							$truetype = str_replace('zip_', '', $r['type']);
							if (is_file('../../export/' . $r['type'] . '.zip')) {
								$zip = new \ZipArchive;
                    			$res = $zip->open('../../export/' . $r['type'] . '.zip');
								if ($res === true) {
									$path = '../movie/' . $r['movie'] . '.movie/media/' . $truetype . '/';
									for ($i = 0; $i < $zip->numFiles; $i++) {
										$file = $zip->getNameIndex($i);
										$ext = explode('.', $file);
										if (in_array(strtolower($ext[count($ext)-1]), $this->mediaExt[$truetype])) {
											$zip->extractTo($path, $file);
										}
									}
									$zip->close();
									@unlink('../../export/' . $r['type'] . '.zip');
									return (true);
								} else {
									// error reading file
									@unlink('../../export/' . $r['type'] . '.zip');
									return (true);
								}
							} else {
								// no file received
								return (true);
							}
							

						} else if ($r['type'] == 'strings') {
                            $md = new Media;
                            $md->saveStrings($r['movie'], $r['fname']);
                            return (true);
                        } else {
                            return (true);
                        }
                    } else {
                        return (true);
                    }
                } else {
                    return (true);
                }
            } else {
                return (false);
            }
		} else {
			return (false);
		}
	}
	
    /**
	 * Lists available embed content.
	 */
	private function embed() {
		// required fields received?		
		if ($this->requiredFields(['movie'])) {
			$md = new Media;
			if ($md->listEmbed($this->req['movie'])) {
				$this->returnRequest([ 'e' => 0, 'list' => $md->flist ]);
			} else {
				$this->returnRequest([ 'e' => 1, 'list' => [ ] ]);
			}
		}
	}
    
    /**
	 * Imports a received embed zip file.
	 */
	private function embedImport() {
		// required fields received?		
		if ($this->requiredFields(['movie', 'name'])) {
			$md = new Media;
			if ($md->embedImport($this->req['movie'], $this->req['name'])) {
				$this->returnRequest([ 'e' => 0 ]);
			} else {
				$this->returnRequest([ 'e' => 1 ]);
			}
		}
	}
    
    /**
	 * Removes an embed content.
	 */
	private function embedRemove() {
		// required fields received?		
		if ($this->requiredFields(['movie', 'name'])) {
			$md = new Media;
			$md->embedRemove($this->req['movie'], $this->req['name']);
            $this->returnRequest([ 'e' => 0 ]);
		}
	}
    
    /**
	 * Removes a collection.
	 */
	private function removeCollection() {
		// required fields received?		
		if ($this->requiredFields(['movie', 'col'])) {
			$md = new Media;
			$md->removeCollection($this->req['movie'], $this->req['col']);
            $this->returnRequest([ 'e' => 0 ]);
		}
	}
}