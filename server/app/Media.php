<?php

/** CLASS DEFINITIONS **/
require_once('BaseClass.php');

/**
 * Media information.
 */
class Media extends BaseClass
{
	
	/**
	 * files list
	 */
	public $flist = [ ];
	
	/**
	 * data list
	 */
	public $dlist = [ ];

	/**
	 * Constructor.
	 */
	public function __construct()
	{
		parent::__construct();
	}
	
	/**
	 * Returns a list of folders/files.
	 * @param	string	$movie	the movie id
	 * @param	string	$type	the media type
	 * @param	string	$path	path inside the media type folder
	 * @return	int	error code
	 */
	public function listFiles($movie, $type, $path) {
		// open media type folder
		$dir = null;
		switch ($type) {
			case 'audio':
			case 'picture':
			case 'spritemap':
			case 'html':
			case 'video':
				$dir = '../movie/' . $movie . '.movie/media/' . $type . '/';
				break;
			default:
				$dir = null;
				break;
		}
		// no folder?
		if (is_null($dir)) {
			// no folder set
			return (1);
		} else {
			// create media folder?
			if (!is_dir($dir)) $this->createDir($dir, true);
			// media folder exists?
			if (!is_dir($dir)) {
				return (2);
			} else {
				// path
				$path = str_replace('../', '', $path);
				if (substr($path, 0, 1) == '/') $path = substr($path, 1);
				if (substr($path, -1) != '/') $path .= '/';
				$path = str_replace('//', '', $path);
				$dir = $dir . $path;
				if (!is_dir($dir)) $this->createDir($dir, true);
				// path exists?
				if (!is_dir($dir)) {
					return (3);
				} else {
					// list files
					$files = scandir($dir);
					if ($files === false) {
						return (4);
					} else {
						// read files list
						$dirs = [ ];
						$fls = [ ];
						$this->flist = [ ];
						foreach ($files as $fl) {
							if (($fl != '.') && ($fl != '..')) {
								if (is_dir($dir . $fl)) {
									$dirs[] = [ 'n' => $fl, 't' => 'd' ];
								} else {
									$fls[] = [ 'n' => $fl, 't' => 'f' ];
								}
							}
						}
						foreach ($dirs as $it) $this->flist[] = $it;
						foreach ($fls as $it) $this->flist[] = $it;
						return (0);
					}
				}
			}
		}
	}
	
	/**
	 * Creates a folder.
	 * @param	string	$movie	the movie id
	 * @param	string	$type	the media type
	 * @param	string	$path	path inside the media type folder
	 * @param	string	$name	new folder name
	 * @return	bool	was the folder created?
	 */
	public function newFolder($movie, $type, $path, $name) {
		// open media type folder
		$dir = null;
		switch ($type) {
			case 'audio':
			case 'picture':
			case 'spritemap':
			case 'html':
			case 'video':
				$dir = '../movie/' . $movie . '.movie/media/' . $type . '/';
				break;
			default:
				$dir = null;
				break;
		}
		// no folder?
		if (is_null($dir)) {
			// no folder set
			return (false);
		} else {
			// create media folder?
			if (!is_dir($dir)) $this->createDir($dir, true);
			// media folder exists?
			if (!is_dir($dir)) {
				return (false);
			} else {
				// path
				$path = str_replace('../', '', $path);
				if (substr($path, 0, 1) == '/') $path = substr($path, 1);
				if (substr($path, -1) != '/') $path .= '/';
				$path = str_replace('//', '', $path);
				$dir = $dir . $path;
				if (!is_dir($dir)) $this->createDir($dir, true);
				// path exists?
				if (!is_dir($dir)) {
					return (false);
				} else {
					// the folder already exists?
					$dir = $dir . $name . '/';
					if (is_dir($dir)) {
						return (false);
					} else {
						$this->createDir($dir, true);
						if (is_dir($dir)) {
							// getting file list
							return ($this->listFiles($movie, $type, $path) == 0);
						} else {
							// error creating dir
							return (false);
						}
					}
				}
			}
		}
	}
	
	/**
	 * Deletes a folder.
	 * @param	string	$movie	the movie id
	 * @param	string	$type	the media type
	 * @param	string	$path	path inside the media type folder
	 * @param	string	$name	the folder to delete
	 * @return	bool	was the folder created?
	 */
	public function deleteFolder($movie, $type, $path, $name) {
		// open media type folder
		$dir = null;
		switch ($type) {
			case 'audio':
			case 'picture':
			case 'spritemap':
			case 'html':
			case 'video':
				$dir = '../movie/' . $movie . '.movie/media/' . $type . '/';
				break;
			default:
				$dir = null;
				break;
		}
		// no folder?
		if (is_null($dir)) {
			// no folder set
			return (false);
		} else {
			// create media folder?
			if (!is_dir($dir)) $this->createDir($dir, true);
			// media folder exists?
			if (!is_dir($dir)) {
				return (false);
			} else {
				// path
				$path = str_replace('../', '', $path);
				if (substr($path, 0, 1) == '/') $path = substr($path, 1);
				if (substr($path, -1) != '/') $path .= '/';
				$path = str_replace('//', '', $path);
				$dir = $dir . $path;
				if (!is_dir($dir)) $this->createDir($dir, true);
				// path exists?
				if (!is_dir($dir)) {
					return (false);
				} else {
					// the folder exists?
					if (!is_dir($dir . $name . '/')) {
						return (false);
					} else {
						// are there files inside the folder?
						$files = scandir($dir . $name . '/');
						if (count($files) > 2) {
							return (false);
						} else {
							// delete the dir
							@rmdir($dir . $name . '/');
							if (is_dir($dir . $name . '/')) {
								return (false);
							} else {
								return (true);
							}
						}
					}
				}
			}
		}
	}
	
	/**
	 * Deletes a file.
	 * @param	string	$movie	the movie id
	 * @param	string	$type	the media type
	 * @param	string	$path	path inside the media type folder
	 * @param	string	$name	the file to delete
	 * @return	bool	was the file deleted?
	 */
	public function deleteFile($movie, $type, $path, $name) {
		// open media type folder
		$dir = null;
		switch ($type) {
			case 'audio':
			case 'picture':
			case 'spritemap':
			case 'html':
			case 'video':
				$dir = '../movie/' . $movie . '.movie/media/' . $type . '/';
				break;
			default:
				$dir = null;
				break;
		}
		// no folder?
		if (is_null($dir)) {
			// no folder set
			return (false);
		} else {
			// create media folder?
			if (!is_dir($dir)) $this->createDir($dir, true);
			// media folder exists?
			if (!is_dir($dir)) {
				return (false);
			} else {
				// path
				$path = str_replace('../', '', $path);
				if (substr($path, 0, 1) == '/') $path = substr($path, 1);
				if (substr($path, -1) != '/') $path .= '/';
				$path = str_replace('//', '', $path);
				$dir = $dir . $path;
				if (!is_dir($dir)) $this->createDir($dir, true);
				// path exists?
				if (!is_dir($dir)) {
					return (false);
				} else {
					// the folder exists?
					if (!is_file($dir . $name)) {
						return (false);
					} else {
						// delete the file
						@unlink($dir . $name);
						if (is_file($dir . $name)) {
							return (false);
						} else {
							return (true);
						}
					}
				}
			}
		}
	}
	
	/**
	 * Creates a collection.
	 * @param	string	$movie	movie id
	 * @param	string	$id	collecttion id
	 * @param	string	$name	collection name
	 * @return	new collection id
	 */
	public function createCollection($movie, $id, $name) {
		// check id
		/*$id = substr($this->cleanString($id), 0, 32);
		if ($id == '') {
			$id = md5(time().rand(10000, 99999));
		}*/
		$id = md5(time().rand(10000, 99999));
		$check = true;
		while ($check) {
			$id = substr($id, 0, 32);
			$ck = $this->queryAll('SELECT * FROM collections WHERE cl_id=:id AND cl_movie=:mv', [
				':id' => $id, 
				':mv' => $movie, 
			]);
			if (count($ck) > 0) {
				$id = md5(time().rand(10000, 99999));
			} else {
				$check = false;
			}
		}
		// create the collection
		$this->execute('INSERT INTO collections (cl_uid, cl_id, cl_movie, cl_title) VALUES (:uid, :id, :mv, :tt)', [
			':uid' => substr(($movie.$id), 0, 64), 
			':id' => $id, 
			':mv' => $movie, 
			':tt' => $name, 
		]);
		// returning
		return ($id);
	}
	
	/**
	 * Returns a list of available collections.
	 * @param	string	$movie	the movie id
	 * @return	int	error code
	 */
	public function listCollections($movie) {
		// checks available collections
		$this->dlist = [ ];
		$ck = $this->queryAll('SELECT c.*, (SELECT COUNT(*) FROM assets a WHERE a.at_collection=c.cl_uid) AS NUMASSETS FROM collections c WHERE c.cl_movie=:mv ORDER BY c.cl_title ASC', [ ':mv' => $movie ]);
		foreach ($ck as $v) {
			if ($v['NUMASSETS'] > 0) {
				$this->dlist[] = [
					'uid' => $v['cl_uid'], 
					'id' => $v['cl_id'], 
					'title' => $v['cl_title'], 
					'transition' => $v['cl_transition'], 
					'time' => (float)$v['cl_time'], 
					'num' => (int)$v['NUMASSETS'], 
				];
			}
		}
		return (0);
	}
    
    /**
	 * Returns a list of collections available for removal.
	 * @param	string	$movie	the movie id
	 * @return	int	error code
	 */
	public function listRmCollections($movie) {
		// checks available collections
		$this->dlist = [ ];
        // get all used collections
        $used = [ ];
        $ck = $this->queryAll('SELECT sc_id, sc_collections FROM scenes WHERE sc_movie=:mv AND sc_published=:pub', [ ':mv' => $movie, ':pub' => '1' ]);
        foreach ($ck as $v) {
            $exp = explode(',', $v['sc_collections']);
            foreach ($exp as $col) {
                if (trim($col) != '') {
                    if (!in_array(trim($col), $used)) $used[] = trim($col);
                }
            }
            $ckult = $this->queryAll('SELECT sc_collections FROM scenes WHERE sc_movie=:mv AND sc_id=:id ORDER BY sc_uid DESC LIMIT 1', [ ':mv' => $movie, ':id' => $v['sc_id'] ]);
            if (count($ckult) > 0) {
                $exp = explode(',', $ckult[0]['sc_collections']);
                foreach ($exp as $col) {
                    if (trim($col) != '') {
                        if (!in_array(trim($col), $used)) $used[] = trim($col);
                    }
                }
            }
        }
		$ck = $this->queryAll('SELECT c.*, (SELECT COUNT(*) FROM assets a WHERE a.at_collection=c.cl_uid) AS NUMASSETS FROM collections c WHERE c.cl_movie=:mv ORDER BY c.cl_title ASC', [ ':mv' => $movie ]);
		foreach ($ck as $v) {
			if (!in_array($v['cl_id'], $used)) {
				$this->dlist[] = [
					'uid' => $v['cl_uid'], 
					'id' => $v['cl_id'], 
					'title' => $v['cl_title'], 
					'transition' => $v['cl_transition'], 
					'time' => (float)$v['cl_time'], 
					'num' => (int)$v['NUMASSETS'], 
				];
			}
		}
		return (0);
	}
    
    /**
	 * Returns a list of available collections with full information.
	 * @param	string	$movie	the movie id
	 * @return	int	error code
	 */
	public function listCollectionsFull($movie) {
		// checks available collections
		$this->dlist = [ ];
		$ck = $this->queryAll('SELECT c.*, (SELECT COUNT(*) FROM assets a WHERE a.at_collection=c.cl_uid) AS NUMASSETS FROM collections c WHERE c.cl_movie=:mv ORDER BY c.cl_title ASC', [ ':mv' => $movie ]);
		foreach ($ck as $v) {
			if ($v['NUMASSETS'] > 0) {
                $item = [
                    'uid' => $v['cl_uid'], 
                    'title' => $v['cl_title'],
                    'assets' => [ ], 
                ];
                $cka = $this->queryAll('SELECT at_id, at_name, at_type, at_file1, at_file2, at_file3, at_file4, at_file5 FROM assets WHERE at_collection=:col AND FIND_IN_SET(at_type, :types) ORDER BY at_order ASC', [
                   ':col' => $v['cl_uid'], 
                    ':types' => 'audio,html,picture,spritemap,video', 
                ]);
                $astok = false;
                foreach($cka as $va) {
                    $item['assets'][$va['at_id']] = [
                        'id' => $va['at_id'], 
                        'name' => $va['at_name'], 
                        'type' => $va['at_type'], 
                        'file1' => $va['at_file1'], 
                        'file2' => $va['at_file2'], 
                        'file3' => $va['at_file3'], 
                        'file4' => $va['at_file4'], 
                        'file5' => $va['at_file5'], 
                    ];
                    $astok = true;
                }
                if ($astok) $this->dlist[$v['cl_uid']] = $item;
			}
		}
		return (0);
	}
	
	/**
	 * Returns a list of acollection assets.
	 * @param	string	$uid	the collection uid
	 * @return	int	error code
	 */
	public function listColAssets($uid) {
		// checks available collections
		$this->dlist = [ ];
		$ck = $this->queryAll('SELECT * FROM assets WHERE at_collection=:cl ORDER BY at_order ASC', [ ':cl' => $uid ]);
		foreach ($ck as $v) $this->dlist[] = [
			'uid' => $v['at_uid'], 
			'id' => $v['at_id'], 
			'order' => $v['at_order'], 
			'name' => $v['at_name'], 
			'type' => $v['at_type'], 
			'time' => (int)$v['at_time'], 
			'frames' => (int)$v['at_frames'], 
			'frtime' => (int)$v['at_frtime'], 
			'file1' => $v['at_file1'], 
			'file2' => $v['at_file2'], 
			'file3' => $v['at_file3'], 
			'file4' => $v['at_file4'], 
			'file5' => $v['at_file5'], 
			'action' => gzdecode(base64_decode($v['at_action'])),
		];
		return (0);
	}
	
	/**
	 * Receives a strings.json file.
	 * @param	string	$movie	the movie id
	 * @param	string	strings	the file contents
	 * @return	bool	was the file received?
	 */
	public function getStringsJSON($movie, $strings) {
		$json = json_decode($strings, true);
		if (json_last_error() == JSON_ERROR_NONE) {
			$dir = '../movie/' . $movie . '.movie/';
			if (!is_dir($dir)) {
				return (false);
			} else {
				file_put_contents($dir.'strings.json', $strings);
				return (true);
			}
		} else {
			return (false);
		}
	}
    
    /**
	 * Gets a list of available embed contents.
	 * @param	string	$movie	the movie id
	 * @return	bool	embed content found?
	 */
	public function listEmbed($movie) {
        $dir = '../movie/' . $movie . '.movie/media/';
        if (is_dir($dir)) {
            if (!is_dir($dir.'embed/')) $this->createDir($dir.'embed/');
            if (is_dir($dir.'embed/')) {
                $this->flist = [ ];
                $list = scandir($dir.'embed/');
                foreach ($list as $l) {
                    if (($l != '.') && ($l != '..')) {
                        if (is_dir($dir.'embed/'.$l.'/')) {
                            if (is_file($dir.'embed/'.$l.'/index.html')) {
                                $this->flist[] = $l;
                            }
                        }
                    }
                }
                return (true);
            } else {
                return (false);
            }
        } else {
            return (false);
        }
	}
    
    /**
	 * Imports an embed zip file.
	 * @param	string	$movie	the movie id
     * @param   string  $name   the embed content name
	 * @return	bool	embed content imported?
	 */
	public function embedImport($movie, $name) {
        $dir = '../movie/' . $movie . '.movie/media/';
        if (is_dir($dir)) {
            if (!is_dir($dir.'embed/')) $this->createDir($dir.'embed/');
            if (is_dir($dir.'embed/')) {
                if (is_file('../../embed/' . $name . '.zip')) {
                    $zip = new \ZipArchive;
                    $res = $zip->open('../../embed/' . $name . '.zip');
                    if ($res === true) {
                        $finalname = $name;
                        while (is_dir($dir.'embed/'. $finalname . '/')) {
                            $finalname .= rand(0, 9);
                        }
                        $this->createDir($dir.'embed/'. $finalname . '/');
                        if (is_dir($dir.'embed/'. $finalname . '/')) {
                            $zip->extractTo($dir.'embed/'. $finalname . '/');
                            $zip->close();
                            @unlink('../../embed/' . $name . '.zip');
                            if (is_file($dir.'embed/'. $finalname . '/index.html')) {
                                return (true);
                            } else {
                                $this->removeFileDir($dir.'embed/'. $finalname . '/');
                                return (false);
                            }
                        } else {
                            $zip->close();
                            @unlink('../../embed/' . $name . '.zip');
                            return (false);
                        }
                    } else {
                        @unlink('../../embed/' . $name . '.zip');
                        return (false);
                    }
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
	 * Removes embed content.
	 * @param	string	$movie	the movie id
     * @param   string  $name   the embed content name
	 */
	public function embedRemove($movie, $name) {
        $dir = '../movie/' . $movie . '.movie/media/embed/' . $name . '/';
        if (is_dir($dir)) {
            $this->removeFileDir($dir);
        }
	}
    
    /**
	 * Removes a collection.
	 * @param	string	$movie	the movie id
     * @param   string  $col    the collection id
	 */
	public function removeCollection($movie, $col) {
        $this->execute('DELETE FROM assets WHERE at_collection=:id', [
            ':id' => $movie . $col, 
        ]);
        $this->execute('DELETE FROM collections WHERE cl_uid=:id', [
            ':id' => $movie . $col, 
        ]);
        if (is_file('../movie/' . $movie . '.movie/collection/' . $col . '.json')) {
            @unlink('../movie/' . $movie . '.movie/collection/' . $col . '.json');
        }
	}
	
}