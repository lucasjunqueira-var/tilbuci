<?php

/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

/** CLASS DEFINITIONS **/
require_once('BaseClass.php');
require_once('Scene.php');
require_once('Collection.php');

/**
 * Movie information.
 */
class Movie extends BaseClass
{
	/**
     * TilBuci expected version
     */
    private $version = 13;
    
	/**
	 * current movie information
	 */
	public $info = [ ];
	
	/**
	 * is there a loaded movie?
	 */
	public $loaded = false;

	/**
	 * Constructor.
	 */
	public function __construct($id = null)
	{
		parent::__construct();
		if (!is_null($id)) {
			$this->loadMovie($id);
		}
	}
	
	/**
	 * Creates a movie.
	 * @return string|bool the created movie ID or false on error
	 */
	public function createMovie($id, $user, $title, $author, $copyright, $copyleft, $about, $sizebig, $sizesmall, $moviesizetype, $interval) {
		// checking id
		if ($id != '') {
			$id = substr($this->cleanString($id), 0, 32);
			$ck = $this->queryAll('SELECT mv_id FROM movies WHERE mv_id=:id', [':id' => $id]);
			if (count($ck) > 0) $id = '';
		}
		// create id?
		if ($id == '') {
			$ckid = true;
			while ($ckid) {
				$id = md5(time() . rand(0, 9999));
				$ck = $this->queryAll('SELECT mv_id FROM movies WHERE mv_id=:id', [':id' => $id]);
				if (count($ck) == 0) $ckid = false;
			}
		}
		
		// adding to database
		$ok = false;
		if ($this->execute('INSERT INTO movies (mv_id, mv_user, mv_title, mv_author, mv_copyright, mv_copyleft, mv_about, mv_screenbig, mv_screensmall, mv_screentype, mv_interval) VALUES (:id, :us, :tt, :au, :cr, :cl, :ab, :sb, :ss, :st, :in)', [
			':id' => $id, 
			':us' => $user, 
			':tt' => $title, 
			':au' => $author, 
			':cr' => $copyright, 
			':cl' => $copyleft, 
			':ab' => $about, 
			':sb' => $sizebig, 
			':ss' => $sizesmall, 
			':st' => $moviesizetype, 
			':in' => $interval, 
		])) {
		
			// creating folder
			$ok = true;
			if (!$this->createDir('../movie/'.$id.'.movie')) {
				// error creating movie folder
				$this->execute('DELETE FROM movies WHERE mv_id=:id', [':id'=>$id]);
				$ok = false;
			} else {
				// creating sub folders
				$this->createDir('../movie/'.$id.'.movie/media');
				$this->createDir('../movie/'.$id.'.movie/media/picture');
				$this->createDir('../movie/'.$id.'.movie/media/video');
				$this->createDir('../movie/'.$id.'.movie/media/audio');
				$this->createDir('../movie/'.$id.'.movie/media/html');
				$this->createDir('../movie/'.$id.'.movie/media/font');
				$this->createDir('../movie/'.$id.'.movie/media/spritemap');
				$this->createDir('../movie/'.$id.'.movie/scene');
				$this->createDir('../movie/'.$id.'.movie/collection');
			}
			
			// additional files
			file_put_contents('../movie/'.$id.'.movie/strings.json', '{"default":{"sample":"sample text"}}');
		}
		if ($ok) {
			return ($id);
		} else {
			return (false);
		}
	}

	/**
	 * Loads a movie informarion.
	 * @param string $id the movie id
	 * @return bool was the movie found and loaded?
	 */
	public function loadMovie($id) {
		$this->info = [ ];
		$this->loaded = false;
		$ck = $this->queryAll('SELECT * FROM movies WHERE mv_id=:id', [':id'=>$id]);
		if (count($ck) > 0) {
			// basic movie information
			$this->info = [
				'version' => $this->version, 
				'id' => $id, 
				'author' => $ck[0]['mv_author'], 
				'copyright' => $ck[0]['mv_copyright'], 
				'copyleft' => $ck[0]['mv_copyleft'], 
				'title' => $ck[0]['mv_title'], 
				'description' => $ck[0]['mv_about'], 
				'tags' => ($ck[0]['mv_tags'] == '' ? [ ] : explode(',', $ck[0]['mv_tags'])),
				'favicon' => $ck[0]['mv_favicon'], 
				'image' => $ck[0]['mv_image'], 
				'key' => $ck[0]['mv_key'], 
                'fallback' => $ck[0]['mv_fallback'], 
                'identify' => $ck[0]['mv_identify'] == '1' ? true : false, 
                'vsgroups' => ($ck[0]['mv_vsgroups'] == '' ? [ ] : explode(',', $ck[0]['mv_vsgroups'])),
				'start' => $ck[0]['mv_start'], 
				'acstart' => (is_null($ck[0]['mv_acstart']) || $ck[0]['mv_acstart'] == '') ? '' : gzdecode(base64_decode($ck[0]['mv_acstart'])), 
				'screen' => [
					'big'=> (int)$ck[0]['mv_screenbig'], 
					'small'=> (int)$ck[0]['mv_screensmall'], 
					'type' => $ck[0]['mv_screentype'], 
					'bgcolor' => $ck[0]['mv_screenbg'], 
				], 
				'time' => (float)$ck[0]['mv_interval'], 
				'origin' => $ck[0]['mv_origin'], 
				'animation' => $ck[0]['mv_animation'], 
                'highlight' => $ck[0]['mv_highlight'], 
                'loadingic' => $ck[0]['mv_loading'], 
                'encrypted' => $ck[0]['mv_encrypted'] == '1' ? true : false, 
				'fonts' => ((is_null($ck[0]['mv_fonts']) || $ck[0]['mv_fonts'] == '') ? [ ] : json_decode(gzdecode(base64_decode($ck[0]['mv_fonts'])), true)), 
				'style' => (is_null($ck[0]['mv_style']) || $ck[0]['mv_style'] == '') ? '' : gzdecode(base64_decode($ck[0]['mv_style'])), 
				'actions' => ((is_null($ck[0]['mv_actions']) || $ck[0]['mv_actions'] == '') ? [ ] : json_decode(gzdecode(base64_decode($ck[0]['mv_actions'])), true)), 
				'theme' => ((is_null($ck[0]['mv_theme']) || $ck[0]['mv_theme'] == '') ? '{}' : gzdecode(base64_decode($ck[0]['mv_theme']))), 
				'inputs' => ((is_null($ck[0]['mv_inputs']) || $ck[0]['mv_inputs'] == '') ? [ ] : json_decode(gzdecode(base64_decode($ck[0]['mv_inputs'])), true)), 
                'texts' => ((is_null($ck[0]['mv_texts']) || $ck[0]['mv_texts'] == '') ? [ ] : json_decode(gzdecode(base64_decode($ck[0]['mv_texts'])), true)), 
				'numbers' => ((is_null($ck[0]['mv_numbers']) || $ck[0]['mv_numbers'] == '') ? [ ] : json_decode(gzdecode(base64_decode($ck[0]['mv_numbers'])), true)), 
				'flags' => ((is_null($ck[0]['mv_flags']) || $ck[0]['mv_flags'] == '') ? [ ] : json_decode(gzdecode(base64_decode($ck[0]['mv_flags'])), true)), 
				'created' => $ck[0]['mv_created'], 
				'updated' => $ck[0]['mv_updated'], 
				'plugins' => [ ], 
			];
			// active plugins
			$pl = $ck[0]['mv_plugins'] == '' ? [ ] : explode(',', $ck[0]['mv_plugins']);
			foreach ($pl as $plid) {
				$this->info['plugins'][$plid] = [
					'active' => true, 
					'config' => [ ], 
				];
			}
			// plugin configuration
			$ckp = $this->queryAll('SELECT pl_name, pl_config FROM plugins WHERE pl_movie=:mv AND pl_scene=:sc', [
				':mv' => $id, 
				':sc' => '', 
			]);
			foreach($ckp as $v) {
				$conf = json_decode(gzdecode(base64_decode($v['pl_config'])), true);
				if (json_last_error() != JSON_ERROR_NONE) $conf = [ ];
				if (isset($this->info['plugins'][$v['pl_name']])) {
					$this->info['plugins'][$v['pl_name']]['config'] = $conf;
				} else {
					$this->info['plugins'][$v['pl_name']] = [
						'active' => false,
						'config' => $conf, 
					];
				}
			}
			// movie loaded
			$this->loaded = true;
		}
		return ($this->loaded);
	}
	
	/**
	 * Publish the current movie to file.
     * @param bool $decrypt force decrypted file?
	 * @return bool was the movie published?
	 */
	public function publish($decrypt = false) {
		if ($this->loaded) {
			// creating folders
			$ok = true;
			$id = $this->info['id'];
			if (!is_dir('../movie/'.$id.'.movie')) if (!$this->createDir('../movie/'.$id.'.movie')) $ok = false;
			if ($ok && !is_dir('../movie/'.$id.'.movie/media')) if (!$this->createDir('../movie/'.$id.'.movie/media')) $ok = false;
			if ($ok && !is_dir('../movie/'.$id.'.movie/media/picture')) if (!$this->createDir('../movie/'.$id.'.movie/media/picture')) $ok = false;
			if ($ok && !is_dir('../movie/'.$id.'.movie/media/video')) if (!$this->createDir('../movie/'.$id.'.movie/media/video')) $ok = false;
			if ($ok && !is_dir('../movie/'.$id.'.movie/media/audio')) if (!$this->createDir('../movie/'.$id.'.movie/media/audio')) $ok = false;
			if ($ok && !is_dir('../movie/'.$id.'.movie/media/html')) if (!$this->createDir('../movie/'.$id.'.movie/media/html')) $ok = false;
			if ($ok && !is_dir('../movie/'.$id.'.movie/media/font')) if (!$this->createDir('../movie/'.$id.'.movie/media/font')) $ok = false;
			if ($ok && !is_dir('../movie/'.$id.'.movie/media/spritemap')) if (!$this->createDir('../movie/'.$id.'.movie/media/spritemap')) $ok = false;
			if ($ok && !is_dir('../movie/'.$id.'.movie/scene')) if (!$this->createDir('../movie/'.$id.'.movie/scene')) $ok = false;
			if ($ok && !is_dir('../movie/'.$id.'.movie/collection')) if (!$this->createDir('../movie/'.$id.'.movie/collection')) $ok = false;
			if ($ok && !is_file('../movie/'.$id.'.movie/strings.json')) file_put_contents('../movie/'.$id.'.movie/strings.json', '{"default":{"sample":"sample text"}}');
			if (!$ok) {
				// no folders
				return (false);
			} else {
                // decrypted file?
                if ($decrypt) {
                    file_put_contents(('../movie/'.$id.'.movie/movie.json'), json_encode($this->info));
                } else {
                    // save movie file
                    if ($this->info['encrypted']) {
                        file_put_contents(('../movie/'.$id.'.movie/movie.json'), $this->encryptTBFile($this->info['id'], json_encode($this->info)));
                    } else {
                        file_put_contents(('../movie/'.$id.'.movie/movie.json'), json_encode($this->info));
                    }
                }
				return (true);
			}
		} else {
			// movie not loaded
			return (false);
		}
	}
	
	/**
	 * Lists movies that can be open by the current user.
	 * @return array movies list
	 */
	public function listMovies($user, $own = false) {
		$ret = [ ];
        if ($own) {
            $ck = $this->queryAll('SELECT mv_id, mv_title, mv_user FROM movies WHERE mv_user=:us ORDER BY mv_updated DESC', [
                ':us' => $user, 
            ]);
            foreach ($ck as $v) $ret[] = [
                'id' => $v['mv_id'], 
                'title' => $v['mv_title'], 
            ];
        } else {
            $ck = $this->queryAll('SELECT mv_id, mv_title, mv_user FROM movies WHERE mv_user=:us OR mv_collaborators LIKE :col ORDER BY mv_updated DESC', [
                ':us' => $user, 
                ':col' => '%' . $user . '%', 
            ]);
            foreach ($ck as $v) $ret[] = [
                'id' => $v['mv_id'], 
                'title' => $v['mv_title'] . ($v['mv_user'] == $user ? '*' : ''), 
            ];
        }
		return ($ret);
	}
    
    /**
	 * Removes a movie.
	 * @return array movies list
	 */
	public function remove($user, $id) {
        // can the current user remove the movie?
        $ck = $this->queryAll('SELECT mv_id FROM movies WHERE mv_user=:us AND mv_id=:id', [
            ':us' => $user, 
            ':id' => $id, 
        ]);
        if (count($ck) > 0) {
            $ckc = $this->queryAll('SELECT cl_uid FROM collections WHERE cl_movie=:mv', [':mv'=>$id]);
            foreach ($ckc as $v) $this->execute('DELETE FROM assets WHERE at_collection=:col', [':col'=>$v['cl_uid']]);
            $this->execute('DELETE FROM collections WHERE cl_movie=:mv', [':mv'=>$id]);
            $cks = $this->queryAll('SELECT sc_uid, sc_id FROM scenes WHERE sc_movie=:mv', [':mv'=>$id]);
            foreach ($cks as $v) {
                $ckk = $this->queryAll('SELECT kf_id FROM keyframes WHERE kf_scene=:sc', [':sc'=>$v['sc_uid']]);
                foreach ($ckk as $vk) {
                    $cki = $this->queryAll('SELECT in_id FROM instances WHERE in_keyframe=:kf', [':kf'=>$vk['kf_id']]);
                    foreach ($cki as $vi) {
                        $this->execute('DELETE FROM instancedesc WHERE id_instance=:in', [':in'=>$vi['in_id']]);
                    }
                    $this->execute('DELETE FROM instances WHERE in_keyframe=:kf', [':kf'=>$vk['kf_id']]);
                }
                $this->execute('DELETE FROM keyframes WHERE kf_scene=:sc', [':sc'=>$v['sc_uid']]);
            }
            $this->execute('DELETE FROM scenes WHERE sc_movie=:mv', [':mv'=>$id]);
            $this->execute('DELETE FROM movies WHERE mv_id=:id', [':id'=>$id]);
            $this->removeFileDir('../movie/'.$id.'.movie');
            @rmdir('../movie/'.$id.'.movie');
        }
        // loading movies
		$ret = [ ];
        $ck = $this->queryAll('SELECT mv_id, mv_title, mv_user FROM movies WHERE mv_user=:us ORDER BY mv_updated DESC', [
            ':us' => $user, 
        ]);
        foreach ($ck as $v) $ret[] = [
            'id' => $v['mv_id'], 
            'title' => $v['mv_title'], 
        ];
		return ($ret);
	}
	
	/**
	 * Updates a movie information.
	 * @param string $id movie id
	 * @param array $data data to update
	 * @param string $user current user
	 * @return return array withe error code "e" and "list" with updated info
	 * 0 => movie updated
	 * 1 => movie id not found for current user
	 * 2 => no information to update
	 * 3 => error publishing new information
	 */
	public function update($id, $data, $user) {
		$ck = $this->queryAll('SELECT mv_id FROM movies WHERE mv_id=:id AND mv_user=:us', [
			':id' => $id,
			':us' => $user, 
		]);
		if (count($ck) == 0) {
			return (['e' => 1, 'list' => [ ], 'reload' => false]);
		} else {
			$cols = [ ];
			$vals = [ ];
			$updt = [ ];
			$reld = false;
            $publish = null;
			foreach ($data as $k => $v) {
				switch ($k) {
					case 'author':
						$cols[] = 'mv_author=:au';
						$vals[':au'] = $v;
						$updt['author'] = $v;
						break;
					case 'title':
						$cols[] = 'mv_title=:tt';
						$vals[':tt'] = $v;
						$updt['title'] = $v;
						break;
					case 'copyright':
						$cols[] = 'mv_copyright=:cr';
						$vals[':cr'] = $v;
						$updt['copyright'] = $v;
						break;
					case 'copyleft':
						$cols[] = 'mv_copyleft=:cl';
						$vals[':cl'] = $v;
						$updt['copyleft'] = $v;
						break;
					case 'tags':
						$tgs = explode(',', $v);
						foreach ($tgs as $tk => $tv) $tgs[$tk] = trim($tv);
						$cols[] = 'mv_tags=:tg';
						$vals[':tg'] = implode(',', $tgs);
						$updt['tags'] = implode(',', $tgs);
						break;
					case 'about':
						$cols[] = 'mv_about=:ab';
						$vals[':ab'] = $v;
						$updt['about'] = $v;
						break;
					case 'start':
						$cols[] = 'mv_start=:sc';
						$vals[':sc'] = $v;
						$updt['start'] = $v;
						break;
					case 'favicon':
						$cols[] = 'mv_favicon=:fav';
						$vals[':fav'] = $v;
						$updt['favicon'] = $v;
						break;
					case 'image':
						$cols[] = 'mv_image=:img';
						$vals[':img'] = $v;
						$updt['image'] = $v;
						break;
					case 'key':
						$cols[] = 'mv_key=:key';
						$vals[':key'] = $v;
						$updt['key'] = $v;
						break;
                    case 'fallback':
						$cols[] = 'mv_fallback=:fallback';
						$vals[':fallback'] = $v;
						$updt['fallback'] = $v;
						break;
                    case 'identify':
						$cols[] = 'mv_identify=:identify';
						$vals[':identify'] = $v;
						$updt['identify'] = $v;
                        $publish = ($v == '0');
						break;
                    case 'vsgroups':
						$cols[] = 'mv_vsgroups=:vsgroups';
						$vals[':vsgroups'] = $v;
						$updt['vsgroups'] = $v;
						break;
					case 'time':
						$cols[] = 'mv_interval=:in';
						$vals[':in'] = $v;
						$updt['time'] = $v;
						break;
					case 'origin':
						$cols[] = 'mv_origin=:or';
						$vals[':or'] = $v;
						$updt['origin'] = $v;
						break;
					case 'animation':
						$cols[] = 'mv_animation=:an';
						$vals[':an'] = $v;
						$updt['animation'] = $v;
						break;
                    case 'highlight':
						$cols[] = 'mv_highlight=:high';
						$vals[':high'] = $v;
						$updt['highlight'] = $v;
						break;
                    case 'loadingic':
						$cols[] = 'mv_loading=:load';
						$vals[':load'] = $v;
						$updt['loadingic'] = $v;
						break;
                    case 'encrypt':
						$cols[] = 'mv_encrypted=:encr';
						$vals[':encr'] = $v;
						$updt['encrypt'] = $v;
						break;
					case 'bigsize':
						$cols[] = 'mv_screenbig=:bg';
						$vals[':bg'] = $v;
						$updt['bigsize'] = $v;
						$reld = true;
						break;
					case 'smallsize':
						$cols[] = 'mv_screensmall=:sm';
						$vals[':sm'] = $v;
						$updt['smallsize'] = $v;
						$reld = true;
						break;
					case 'typesize':
						$cols[] = 'mv_screentype=:st';
						$vals[':st'] = $v;
						$updt['typesize'] = $v;
						$reld = true;
						break;
					case 'bgcolor':
						$cols[] = 'mv_screenbg=:bc';
						$vals[':bc'] = $v;
						$updt['bgcolor'] = $v;
						$reld = true;
						break;
					case 'css':
						$cols[] = 'mv_style=:css';
						$vals[':css'] = base64_encode(gzencode($v));
						$updt['css'] = $v;
						break;
					case 'acstart':
						$cols[] = 'mv_acstart=:acs';
						$vals[':acs'] = base64_encode(gzencode($v));
						$updt['acstart'] = $v;
						break;
					case 'actions':
						$cols[] = 'mv_actions=:ac';
						$vals[':ac'] = base64_encode(gzencode($v));
						$updt['actions'] = $v;
						break;
					case 'texts':
						$cols[] = 'mv_texts=:txt';
						$vals[':txt'] = base64_encode(gzencode($v));
						$updt['texts'] = $v;
						break;
					case 'numbers':
						$cols[] = 'mv_numbers=:num';
						$vals[':num'] = base64_encode(gzencode($v));
						$updt['numbers'] = $v;
						break;
					case 'flags':
						$cols[] = 'mv_flags=:fl';
						$vals[':fl'] = base64_encode(gzencode($v));
						$updt['flags'] = $v;
						break;
					case 'theme':
						$cols[] = 'mv_theme=:th';
						$vals[':th'] = base64_encode(gzencode($v));
						$updt['theme'] = $v;
						break;
                    case 'inputs':
						$cols[] = 'mv_inputs=:inp';
						$vals[':inp'] = base64_encode(gzencode($v));
						$updt['inputs'] = $v;
						break;
					case 'plugins':
						$cols[] = 'mv_plugins=:pl';
						$vals[':pl'] = $v;
						$updt['plugins'] = $v;
						break;
				}
			}
			if (count($cols) == 0) {
				return (['e' => 2, 'list' => [ ], 'reload' => false]);
			} else {
				$vals[':id'] = $id;
				$this->execute('UPDATE movies SET ' . implode(', ', $cols) . ' WHERE mv_id=:id', $vals);
                // publish or remove scene files?
                if (!is_null($publish)) {
                    if ($publish) {
                        $this->publishScenes($id);
                    } else {
                        $this->removePublished($id);
                    }
                }
                // return
				if ($this->loadMovie($id) && $this->publish()) {
					return (['e' => 0, 'list' => $updt, 'reload' => $reld]);	
				} else {
					return (['e' => 3, 'list' => [ ], 'reload' => false]);
				}
			}
		}
	}
    
    /**
     * Re-publicsh all scene json files from a movie.
     * @param   string  $movie  the movie id
     */
    public function publishScenes($movie) {
        if (is_dir('../movie/'.$movie.'.movie/scene/')) {
            $sc = new Scene;
            $ck = $this->queryAll('SELECT sc_id FROM scenes WHERE sc_movie=:mv AND sc_published=:pub', [
                ':mv' => $movie, 
                ':pub' => '1', 
            ]);
            foreach ($ck as $v) {
                if ($sc->loadScene(null, $movie, $v['sc_id'])) {
                    $sc->publish();
                }
            }
        }
    }
    
    /**
     * Removes all scene json files from a movie folder.
     * @param   string  $movie  the movie id
     */
    public function removePublished($movie) {
        if (is_dir('../movie/'.$movie.'.movie/scene/')) {
            $files = scandir('../movie/'.$movie.'.movie/scene/');
            foreach($files as $fl) {
                if (($fl != '.') && ($fl != '..')) {
                    @unlink('../movie/'.$movie.'.movie/scene/' . $fl);
                }
            }
        }
    }
	
	/**
	 * Returns a list opf a movie collaborators.
	 * @param string $id the movie id
	 * @param string $user the movie user
	 * @return array information about collaborators
	 */
	public function listCollaborators($id, $user) {
		$ck = $this->queryAll('SELECT mv_collaborators FROM movies WHERE mv_id=:id AND mv_user=:us', [
			':id' => $id, 
			':us' => $user, 
		]);
		if (count($ck) == 0) {
			return (['e' => 1, 'list' => [ ]]);
		} else {
			$list = [ ];
			if ($ck[0]['mv_collaborators'] != '') $list = explode(',', $ck[0]['mv_collaborators']);
			return (['e' => 0, 'list' => $list]);
		}
	}
	
	/**
	 * Adds a collaborator to a movie.
	 * @param string $id the movie id
	 * @param string $user the movie user
	 * @param string $email new collaborator e-mail
	 * @return array information about collaborators
	 */
	public function addCollaborator($id, $user, $email) {
		$ck = $this->queryAll('SELECT mv_collaborators FROM movies WHERE mv_id=:id AND mv_user=:us', [
			':id' => $id, 
			':us' => $user, 
		]);
		if (count($ck) == 0) {
			return (['e' => 1, 'list' => [ ]]);
		} else {
			$list = [ ];
			if ($ck[0]['mv_collaborators'] != '') $list = explode(',', $ck[0]['mv_collaborators']);
			$list[] = trim($email);
			$this->execute('UPDATE movies SET mv_collaborators=:list WHERE mv_id=:id', [
				':list' => implode(',', $list), 
				':id' => $id, 
			]);
			return (['e' => 0, 'list' => $list]);
		}
	}
	
	/**
	 * Removes a collaborator from a movie.
	 * @param string $id the movie id
	 * @param string $user the movie user
	 * @param string $email new collaborator e-mail
	 * @return array information about collaborators
	 */
	public function removeCollaborator($id, $user, $email) {
		$ck = $this->queryAll('SELECT mv_collaborators FROM movies WHERE mv_id=:id AND mv_user=:us', [
			':id' => $id, 
			':us' => $user, 
		]);
		if (count($ck) == 0) {
			return (['e' => 1, 'list' => [ ]]);
		} else {
			$list = [ ];
			if ($ck[0]['mv_collaborators'] != '') $list = explode(',', $ck[0]['mv_collaborators']);
			$newlist = [ ];
			foreach ($list as $em) if ($em != trim($email)) $newlist[] = $em;
			$this->execute('UPDATE movies SET mv_collaborators=:list WHERE mv_id=:id', [
				':list' => implode(',', $newlist), 
				':id' => $id, 
			]);
			return (['e' => 0, 'list' => $newlist]);
		}
	}
	
	/**
	 * Changes a movie owner.
	 * @param string $id the movie id
	 * @param string $user the movie user
	 * @param string $email new owner e-mail
	 * @return array error code
	 */
	public function changeOwner($id, $user, $email) {
		$ck = $this->queryAll('SELECT mv_collaborators FROM movies WHERE mv_id=:id AND mv_user=:us', [
			':id' => $id, 
			':us' => $user, 
		]);
		if (count($ck) == 0) {
			return (['e' => 1]);
		} else {
			$cku = $this->queryAll('SELECT us_email FROM users WHERE us_email=:em', [':em'=>$email]);
			if (count($cku) == 0) {
				return (['e' => 2]);
			} else {
				$list = [ ];
				if ($ck[0]['mv_collaborators'] != '') $list = explode(',', $ck[0]['mv_collaborators']);
				$newlist = [ $user ];
				foreach ($list as $em) if ($em != $user) $newlist[] = $em;
				$this->execute('UPDATE movies SET mv_user=:us, mv_collaborators=:list WHERE mv_id=:id', [
					':us' => $email, 
					':list' => implode(',', $newlist), 
					':id' => $id, 
				]);
				return (['e' => 0]);
			}
		}
	}
	
	/**
	 * Returns information about the movie.
	 * @param string $id the movie id
	 * @param string $user the movie user
	 * @return array information about collaborators
	 */
	public function infoMovie($id, $user) {
		$ck = $this->queryAll('SELECT mv_user, mv_collaborators FROM movies WHERE mv_id=:id', [
			':id' => $id, 
		]);
		if (count($ck) == 0) {
			return (['e' => 1]);
		} else {
			$info = [
				'isOwner' => ($ck[0]['mv_user'] == $user), 
				'isCollaborator' => (($ck[0]['mv_user'] == $user) || (strpos($ck[0]['mv_collaborators'], $user) !== false)), 
			];
			return (['e' => 0, 'info' => $info]);
		}
	}
	
	/**
	 * Sets a plugin configuration.
	 * @param	string	$id	movie id
	 * @param	string	$user	user e-mail
	 * @param	string	$plugin	plugin name
	 * @param	bool	$active	plugin enabled on movie?
	 * @param	string	$conf	plugin configuration
	 */
	public function setPlugin($id, $user, $plugin, $active, $conf) {
		$ck = $this->queryAll('SELECT mv_plugins FROM movies WHERE mv_id=:id AND mv_user=:us', [
			':id' => $id, 
			':us' => $user, 
		]);
		if (count($ck) == 0) {
			return (['e' => 1]);
		} else {
			// plugin enabled?
			$current = $ck[0]['mv_plugins'] == '' ? [ ] : explode(',', $ck[0]['mv_plugins']);
			if ($active) {
				if (!in_array($plugin, $current)) {
					$current[] = $plugin;
				}
			} else {
				if (in_array($plugin, $current)) {
					$newarr = [ ];
					foreach ($current as $pls) if ($pls != $plugin) $newarr[] = $pls;
					$current = $newarr;
				}
			}
			$this->execute('UPDATE movies SET mv_plugins=:pl WHERE mv_id=:id', [
				':pl' => implode(',', $current), 
				':id' => $id, 
			]);
			// save configuration
			$plid = $plugin.'_'.$id;
			$json = json_decode($conf, true);
			if (json_last_error() != JSON_ERROR_NONE) $json = [ ];
			$this->execute('INSERT INTO plugins (pl_id, pl_name, pl_movie, pl_scene, pl_config) VALUES (:id, :nm, :mv, :sc, :conf) ON DUPLICATE KEY UPDATE pl_config=VALUES(pl_config)', [
				':id' => $plid, 
				':nm' => $plugin, 
				':mv' => $id, 
				':sc' => '', 
				':conf' => base64_encode(gzencode(json_encode($json))), 
			]);
			// finish and return
			$this->loadMovie($id);
			$this->publish();
			return (['e' => 0]);
		}
	}
	
	/**
	 * Gets the available movies list.
	 * @param	string	$user	the user requesting the list
	 * @return	array	available movies list
	 */
	public function getMovieSetList($user) {
		$list = [ ];
		// check user: admin?
		if (!is_null($this->db)) {
			$ck = $this->queryAll('SELECT us_email FROM users WHERE us_email=:em AND us_level=:adm', [
				':em' => $user, 
				':adm' => '0', 
			]);
			if (count($ck) > 0) {
				$ck = $this->queryAll('SELECT mv_id, mv_title FROM movies ORDER BY mv_title ASC');
				foreach ($ck as $v) $list[] = [
					'name' => $v['mv_title'], 
					'id' => $v['mv_id'], 
				];
			}
		}
		return ($list);
	}
	
	/**
	 * Gets the current index movie id.
	 * @return	string	index movie ID or empty string if none is selected.
	 */
	public function getCurrentIndex() {
		if (!is_null($this->db)) {
			$ck = $this->queryAll('SELECT cf_value FROM config WHERE cf_key=:key', [':key'=>'indexMovie']);
			if (count($ck) > 0) {
				return ($ck[0]['cf_value']);
			} else {
				return ('');
			}
		} else {
			return ('');
		}
	}
	
	/**
	 * Sets the index movie.
	 * @param	string	$user	the requesting user
	 * @param	string	$movie	the movie Id to use
	 * @return	int	error code
	 * 0 => index movie set
	 * 1 => no database set
	 * 2 => requesting user can't set the index movie
	 * 3 => movie id not found
	 */
	public function setIndexMovie($user, $movie) {
		// check user: admin?
		if (!is_null($this->db)) {
			$ck = $this->queryAll('SELECT us_email FROM users WHERE us_email=:em AND us_level=:adm', [
				':em' => $user, 
				':adm' => '0', 
			]);
			if (count($ck) > 0) {
				// movie id is valid?
				$ck = $this->queryAll('SELECT mv_id FROM movies where mv_id=:id', [':id'=>$movie]);
				if (count($ck) == 0) {
					return (3);
				} else {
					// set index movie
					$this->execute('INSERT INTO config (cf_key, cf_value) VALUES (:key, :val) ON DUPLICATE KEY UPDATE cf_value=VALUES(cf_value)', [
						':key' => 'indexMovie', 
						':val' => $movie, 
					]);
					// save configuration
					return ($this->savePlayerConfig($user));
				}
			} else {
				return (2);
			}
		} else {
			return (1);
		}
	}
	
	/**
	 * Sets the render mode.
	 * @param	string	$user	the requesting user
	 * @param	string	$rd	the render mode for the player
	 * @return	int	error code
	 * 0 => render set
	 * 1 => no database set
	 * 2 => requesting user can't set the render mode
	 */
	public function setRender($user, $rd) {
		// check user: admin?
		if (!is_null($this->db)) {
			$ck = $this->queryAll('SELECT us_email FROM users WHERE us_email=:em AND us_level=:adm', [
				':em' => $user, 
				':adm' => '0', 
			]);
			if (count($ck) > 0) {
				// get new config
				if (mb_strtolower($rd) == 'dom') {
					$rd = 'dom';
				} else {
					$rd = 'webgl';
				}
				// set render mode
				$this->execute('INSERT INTO config (cf_key, cf_value) VALUES (:key, :val) ON DUPLICATE KEY UPDATE cf_value=VALUES(cf_value)', [
					':key' => 'renderMode', 
					':val' => $rd, 
				]);
				// save configuration
				return ($this->savePlayerConfig($user));
			} else {
				return (2);
			}
		} else {
			return (1);
		}
	}
	
	/**
	 * Sets the share mode.
	 * @param	string	$user	the requesting user
	 * @param	string	$sh	the share mode for the player
	 * @return	int	error code
	 * 0 => share set
	 * 1 => no database set
	 * 2 => requesting user can't set the share mode
	 */
	public function setShare($user, $sh) {
		// check user: admin?
		if (!is_null($this->db)) {
			$ck = $this->queryAll('SELECT us_email FROM users WHERE us_email=:em AND us_level=:adm', [
				':em' => $user, 
				':adm' => '0', 
			]);
			if (count($ck) > 0) {
				// get new config
				if (mb_strtolower($sh) == 'never') {
					$sh = 'never';
				} else if (mb_strtolower($sh) == 'movie') {
					$sh = 'movie';
				} else {
					$sh = 'scene';
				}
				// set render mode
				$this->execute('INSERT INTO config (cf_key, cf_value) VALUES (:key, :val) ON DUPLICATE KEY UPDATE cf_value=VALUES(cf_value)', [
					':key' => 'shareMode', 
					':val' => $sh, 
				]);
				// save configuration
				return ($this->savePlayerConfig($user));
			} else {
				return (2);
			}
		} else {
			return (1);
		}
	}
	
	/**
	 * Sets the fps handling mode.
	 * @param	string	$user	the requesting user
	 * @param	string	$fps	the fps handling mode for the player
	 * @return	int	error code
	 * 0 => fps handling set
	 * 1 => no database set
	 * 2 => requesting user can't set the fps handling mode
	 */
	public function setFPS($user, $fps) {
		// check user: admin?
		if (!is_null($this->db)) {
			$ck = $this->queryAll('SELECT us_email FROM users WHERE us_email=:em AND us_level=:adm', [
				':em' => $user, 
				':adm' => '0', 
			]);
			if (count($ck) > 0) {
				// get new config
				switch ($fps) {
					// ok values
					case '60': break;
					case '50': break;
					case '40': break;
					case '30': break;
					case '20': break;
					case 'free': break;
					case 'calc': break;
					// all other values
					default: $fps = 'free'; break;
				}
				// set render mode
				$this->execute('INSERT INTO config (cf_key, cf_value) VALUES (:key, :val) ON DUPLICATE KEY UPDATE cf_value=VALUES(cf_value)', [
					':key' => 'fpsMode', 
					':val' => $fps, 
				]);
				// save configuration
				return ($this->savePlayerConfig($user));
			} else {
				return (2);
			}
		} else {
			return (1);
		}
	}
	
	/**
	 * Saves the player.json file configuration.
	 * @param	string	$user	the requesting user
	 * @return	int	error code
	 * 0 => file saved
	 * 1 => no database set
	 * 2 => requesting user can't save the file
	 */
	private function savePlayerConfig($user) {
		// check user: admin?
		if (!is_null($this->db)) {
			$ck = $this->queryAll('SELECT us_email FROM users WHERE us_email=:em AND us_level=:adm', [
				':em' => $user, 
				':adm' => '0', 
			]);
			if (count($ck) > 0) {
				// get custom values
				$index = '';
				$render = 'webgl';
				$share = 'scene';
				$fps = 'free';
				$ck = $this->queryAll('SELECT * FROM config');
				foreach ($ck as $v) {
					switch ($v['cf_key']) {
						case 'indexMovie':
							$index = $v['cf_value'];
							break;
						case 'renderMode':
							$render = $v['cf_value'];
							break;
						case 'shareMode':
							$share = $v['cf_value'];
							break;
						case 'fpsMode':
							$fps = $v['cf_value'];
							break;
					}
				}
				// system fonts
				$fonts = [ ];
				$ck = $this->queryAll('SELECT * FROM fonts');
				foreach ($ck as $v) $fonts[] = [ 'name' => $v['fn_name'], 'file' => $v['fn_file'] ];
				// save player.json
				file_put_contents('../app/player.json', json_encode([
					'server' => true, 
					'base' => $this->conf['path'], 
					'ws' => $this->conf['path'] . 'ws/', 
					'font' => $this->conf['path'] . 'font/', 
					'systemfonts' => $fonts, 
					'start' => $index, 
					'render' => $render, 
					'share' => $share, 
					'fps' => $fps, 
					'secret' => $this->conf['secret'], 
				]));
				return (0);
			} else {
				return (2);
			}
		} else {
			return (1);
		}
	}
    
    /**
	 * Exports a movie.
	 * @param	string	$user	the requesting user
	 * @param	string	$movie	the movie id
	 * @return	string|bool the path to the exported file or false on error
	 */
	public function export($user, $movie) {
		// check user: movie owner?
		if (!is_null($this->db)) {
			$ck = $this->queryAll('SELECT * FROM movies WHERE mv_id=:id AND mv_user=:user', [
				':id' => $movie, 
				':user' => $user, 
			]);
			if (count($ck) > 0) {
                if (is_dir('../movie/'.$movie.'.movie')) {
                    set_time_limit(0);
                    
                    // re-publish scenes?
                    $pub = false;
                    if (($ck[0]['mv_encrypted'] == '1') || ($ck[0]['mv_identify'] == '1') || (!is_null($ck[0]['mv_vsgroups']) && ($ck[0]['mv_vsgroups'] != ''))) {
                        $pub = true;
                        $this->republish($user, $movie, 'true', true);
                    }
                    
                    @unlink('../../export/'.$movie.'.zip');
                    $zip = new \ZipArchive;
                    $zip->open('../../export/'.$movie.'.zip', \ZipArchive::CREATE | \ZipArchive::OVERWRITE);
                    $files = new \RecursiveIteratorIterator(
                        new \RecursiveDirectoryIterator('../movie/'.$movie.'.movie'),
                        \RecursiveIteratorIterator::LEAVES_ONLY
                    );
                    $rootPath = realpath('../movie/'.$movie.'.movie');
                    foreach ($files as $file) {
                        if (!$file->isDir()) {
                            $filePath = $file->getRealPath();
                            $relativePath = substr($filePath, strlen($rootPath) + 1);
                            $relativePath = str_replace('\\', '/', $relativePath);
                            $zip->addFile($filePath, $relativePath);
                        }
                    }
                    $zip->close();
                    
                    // remove scenes?
                    if ($pub) {
                        if (($ck[0]['mv_identify'] == '1') || (!is_null($ck[0]['mv_vsgroups']) && ($ck[0]['mv_vsgroups'] != ''))) {
                            $this->removePublished($movie);
                        } else {
                            $this->republish($user, $movie, 'true');
                        }
                    }
                    
                    return ($movie.'.zip');
                } else {
                    return (false);
                }
			} else {
                // the current user isn't the movie owner
				return (false);
			}
		} else {
			return (false);
		}
	}
    
    /**
	 * Checks a movie ID for importing.
	 * @param	string	$user	the requesting user
	 * @param	string	$movie	the movie id
	 * @return	bool is the movie ID available?
	 */
	public function importId($user, $movie) {
		// check user: at least editor?
		if (!is_null($this->db)) {
			$ck = $this->queryAll('SELECT * FROM users WHERE us_email=:user AND us_level<=:level', [
				':user' => $user, 
                ':level' => '50', 
			]);
			if (count($ck) > 0) {
                $ck = $this->queryAll('SELECT * FROM movies WHERE mv_id=:movie', [
                    ':movie' => $movie
                ]);
                if (count($ck) > 0) {
                    return (false);
                } else {
                    return (true);
                }
			} else {
                // the current user can't import movies
				return (false);
			}
		} else {
			return (false);
		}
	}
    
    /**
	 * Checks a movie zip for importing.
	 * @param	string	$user	the requesting user
	 * @param	string	$movie	the movie id
	 * @return	int zip import error
     * 0 => movie imported
     * 1 => user can't import movies
     * 2 => zip file not found
     * 3 => movie ID already exists
     * 4 => error creating new movie folder
     * 5 => corrupted zip file
	 */
	public function importZip($user, $movie) {
		// check user: at least editor?
		if (!is_null($this->db)) {
			$ck = $this->queryAll('SELECT * FROM users WHERE us_email=:user AND us_level<=:level', [
				':user' => $user, 
                ':level' => '50', 
			]);
			if (count($ck) == 0) {
                // user can't import
                return (1);
			} else if (!is_file('../../export/' . $movie . '.zip')) {
                // movie zip not found
				return (2);
			} else {
                $ck = $this->queryAll('SELECT * FROM movies WHERE mv_id=:movie', [
                    ':movie' => $movie
                ]);
                if (count($ck) > 0) {
                    // movie ID already taken
                    @unlink('../../export/' . $movie . '.zip');
                    return (3);
                } else {
                    // create new movie folder
                    set_time_limit(0);
                    if (!$this->createDir('../movie/'.$movie.'.movie/')) {
                        // error creating folder
                        @unlink('../../export/' . $movie . '.zip');
                        return (4);
                    } else {
                        // load zip
                        $zip = new \ZipArchive;
                        $res = $zip->open('../../export/' . $movie . '.zip');
                        if ($res === true) {
                            $zip->extractTo('../movie/'.$movie.'.movie/');
                            $zip->close();
                            // check movie.json
                            if (!is_file('../movie/'.$movie.'.movie/movie.json')) {
                                // no movie.json file
                                $dir = '../movie/'.$movie.'.movie/';
                                $files = new \RecursiveIteratorIterator(
                                    new \RecursiveDirectoryIterator($dir, \RecursiveDirectoryIterator::SKIP_DOTS),
                                    \RecursiveIteratorIterator::CHILD_FIRST
                                );
                                foreach ($files as $fileinfo) {
                                    $todo = ($fileinfo->isDir() ? 'rmdir' : 'unlink');
                                    $todo($fileinfo->getRealPath());
                                }
                                @rmdir($dir);
                                @unlink('../../export/' . $movie . '.zip');
                                return (6);
                            } else {
                                $json = json_decode(file_get_contents('../movie/'.$movie.'.movie/movie.json'), true);
                                if (json_last_error() != JSON_ERROR_NONE) {
                                    // invalid movie.json file
                                    $dir = '../movie/'.$movie.'.movie/';
                                    $files = new \RecursiveIteratorIterator(
                                        new \RecursiveDirectoryIterator($dir, \RecursiveDirectoryIterator::SKIP_DOTS),
                                        \RecursiveIteratorIterator::CHILD_FIRST
                                    );
                                    foreach ($files as $fileinfo) {
                                        $todo = ($fileinfo->isDir() ? 'rmdir' : 'unlink');
                                        $todo($fileinfo->getRealPath());
                                    }
                                    @rmdir($dir);
                                    @unlink('../../export/' . $movie . '.zip');
                                    return (6);
                                } else {
                                    if (!isset($json['version']) || !isset($json['title']) || !isset($json['screen']) || !isset($json['screen']['big']) || !isset($json['screen']['small'])) {
                                        // invalid movie.json file
                                        $dir = '../movie/'.$movie.'.movie/';
                                        $files = new \RecursiveIteratorIterator(
                                            new \RecursiveDirectoryIterator($dir, \RecursiveDirectoryIterator::SKIP_DOTS),
                                            \RecursiveIteratorIterator::CHILD_FIRST
                                        );
                                        foreach ($files as $fileinfo) {
                                            $todo = ($fileinfo->isDir() ? 'rmdir' : 'unlink');
                                            $todo($fileinfo->getRealPath());
                                        }
                                        @rmdir($dir);
                                        @unlink('../../export/' . $movie . '.zip');
                                        return (6);
                                    } else {
                                        // extra files
                                        $strings = '';
                                        if (is_file('../movie/'.$movie.'.movie/strings.json')) $strings = file_get_contents('../movie/'.$movie.'.movie/strings.json');
                                        $contraptions = '';
                                        if (is_file('../movie/'.$movie.'.movie/contraptions.json')) $contraptions = file_get_contents('../movie/'.$movie.'.movie/contraptions.json');
                                        // adjust json values
                                        $json['id'] = $movie;
                                        if (!isset($json['author'])) $json['author'] = $user;
                                        if (!isset($json['copyright'])) $json['copyright'] = '';
                                        if (!isset($json['copyleft'])) $json['copyleft'] = '';
                                        if (!isset($json['description'])) $json['description'] = '';
                                        if (!isset($json['tags'])) $json['tags'] = [ ];
                                        if (!isset($json['favicon'])) $json['favicon'] = '';
                                        if (!isset($json['image'])) $json['image'] = '';
                                        $json['key'] = '';
                                        $json['fallback'] = '';
                                        $json['identify'] = false;
                                        $json['encrypted'] = false;
                                        $json['vsgroups'] = [ ];
                                        if (!isset($json['start'])) $json['start'] = '';
                                        if (!isset($json['acstart'])) $json['acstart'] = '';
                                        if (!isset($json['screen']['bgcolor'])) $json['screen']['bgcolor'] = '0x000000';
                                        if (!isset($json['screen']['type'])) $json['screen']['type'] = 'both';
                                        if (!isset($json['time'])) $json['time'] = 1;
                                        if (!isset($json['origin'])) $json['origin'] = 'center';
                                        if (!isset($json['animation'])) $json['animation'] = 'linear';
                                        if (!isset($json['fonts'])) $json['fonts'] = [ ];
                                        if (!isset($json['style'])) $json['style'] = '';
                                        if (!isset($json['actions'])) $json['actions'] = [ ];
                                        if (!isset($json['theme'])) $json['theme'] = '{}';
                                        if (!isset($json['texts'])) $json['texts'] = [ ];
                                        if (!isset($json['numbers'])) $json['numbers'] = [ ];
                                        if (!isset($json['flags'])) $json['flags'] = [ ];
                                        if (!isset($json['created'])) $json['created'] = date('Y-m-d H:i:s');
                                        if (!isset($json['loadingic'])) $json['loadingic'] = '';
                                        if (!isset($json['highlight'])) $json['highlight'] = '';
                                        $json['updated'] = date('Y-m-d H:i:s');
                                        if (!isset($json['plugins'])) {
                                            $json['plugins'] = [ ];
                                        } else {
                                            $plg = [ ];
                                            foreach ($json['plugins'] as $kp => $vp) $plg[] = $kp;
                                            $json['plugins'] = $plg;
                                        }
                                        file_put_contents('../movie/'.$movie.'.movie/movie.json', json_encode($json));
                                        if (!$this->execute('INSERT INTO movies (mv_id, mv_user, mv_collaborators, mv_author, mv_title, mv_about, mv_copyright, mv_copyleft, mv_tags, mv_favicon, mv_image, mv_key, mv_start, mv_acstart, mv_screenbig, mv_screensmall, mv_screentype, mv_screenbg, mv_interval, mv_origin, mv_animation, mv_fonts, mv_style, mv_actions, mv_theme, mv_texts, mv_numbers, mv_flags, mv_plugins, mv_created, mv_updated, mv_loading, mv_encrypted, mv_highlight, mv_contraptions, mv_strings) VALUES (:mv_id, :mv_user, :mv_collaborators, :mv_author, :mv_title, :mv_about, :mv_copyright, :mv_copyleft, :mv_tags, :mv_favicon, :mv_image, :mv_key, :mv_start, :mv_acstart, :mv_screenbig, :mv_screensmall, :mv_screentype, :mv_screenbg, :mv_interval, :mv_origin, :mv_animation, :mv_fonts, :mv_style, :mv_actions, :mv_theme, :mv_texts, :mv_numbers, :mv_flags, :mv_plugins, :mv_created, :mv_updated, :mv_loading, :mv_encrypted, :mv_highlight, :mv_contraptions, :mv_strings)', [
                                            ':mv_id' => $json['id'], 
                                            ':mv_user' => $user, 
                                            ':mv_collaborators' => '', 
                                            ':mv_author' => $json['author'], 
                                            ':mv_title' => $json['title'], 
                                            ':mv_about' => $json['description'], 
                                            ':mv_copyright' => $json['copyright'], 
                                            ':mv_copyleft' => $json['copyleft'], 
                                            ':mv_tags' => implode(',', $json['tags']), 
                                            ':mv_favicon' => $json['favicon'], 
                                            ':mv_image' => $json['image'], 
                                            ':mv_key' => $json['key'], 
                                            ':mv_start' => $json['start'], 
                                            ':mv_acstart' => $json['acstart'] == '' ? '' : base64_encode(gzencode($json['acstart'])), 
                                            ':mv_screenbig' => $json['screen']['big'], 
                                            ':mv_screensmall' => $json['screen']['small'], 
                                            ':mv_screentype' => $json['screen']['type'], 
                                            ':mv_screenbg' => $json['screen']['bgcolor'], 
                                            ':mv_interval' => $json['time'], 
                                            ':mv_origin' => $json['origin'], 
                                            ':mv_animation' => $json['animation'], 
                                            ':mv_fonts' => count($json['fonts']) == 0 ? '' : base64_encode(gzencode(json_encode($json['fonts']))), 
                                            ':mv_style' => $json['style'] == '' ? '' : base64_encode(gzencode($json['style'])), 
                                            ':mv_actions' => count($json['actions']) == 0 ? '' : base64_encode(gzencode(json_encode($json['actions']))), 
                                            ':mv_theme' => (($json['theme'] == '') || ($json['theme'] == '{}')) ? '' : base64_encode(gzencode($json['theme'])), 
                                            ':mv_texts' => count($json['texts']) == 0 ? '' : base64_encode(gzencode(json_encode($json['texts']))), 
                                            ':mv_numbers' => count($json['numbers']) == 0 ? '' : base64_encode(gzencode(json_encode($json['numbers']))), 
                                            ':mv_flags' => count($json['flags']) == 0 ? '' : base64_encode(gzencode(json_encode($json['flags']))), 
                                            ':mv_plugins' => implode(',', $json['plugins']), 
                                            ':mv_created' => $json['created'], 
                                            ':mv_updated' => $json['updated'], 
                                            ':mv_loading' => $json['loadingic'], 
                                            ':mv_encrypted' => (isset($json['encrypted']) ? ($json['encrypted'] ? '1' : '0') : '0'), 
                                            ':mv_highlight' => $json['highlight'], 
                                            ':mv_contraptions' => $contraptions == '' ? '' : base64_encode(gzencode($contraptions)), 
                                            ':mv_strings' => $strings == '' ? '' : base64_encode(gzencode($strings)), 
                                        ])) {
                                            // error saving movie
                                            $dir = '../movie/'.$movie.'.movie/';
                                            $files = new \RecursiveIteratorIterator(
                                                new \RecursiveDirectoryIterator($dir, \RecursiveDirectoryIterator::SKIP_DOTS),
                                                \RecursiveIteratorIterator::CHILD_FIRST
                                            );
                                            foreach ($files as $fileinfo) {
                                                $todo = ($fileinfo->isDir() ? 'rmdir' : 'unlink');
                                                $todo($fileinfo->getRealPath());
                                            }
                                            @rmdir($dir);
                                            @unlink('../../export/' . $movie . '.zip');
                                            return (6);
                                        } else {
                                            // strings.json
                                            if (!is_file('../movie/'.$movie.'.movie/strings.json')) {
                                               file_put_contents('../movie/'.$movie.'.movie/strings.json', '{"default":{"sample":"sample text"}}');
                                            }
                                            // collections
                                            if (!is_dir('../movie/'.$movie.'.movie/collection')) {
                                                $this->createDir('../movie/'.$movie.'.movie/collection');
                                            }
                                            $files = scandir('../movie/'.$movie.'.movie/collection');
                                            foreach ($files as $fl) {
                                                if (($fl != '.') && ($fl != '..')) {
                                                    $json = json_decode(file_get_contents('../movie/'.$movie.'.movie/collection/'.$fl), true);
                                                    if (json_last_error() == JSON_ERROR_NONE) {
                                                        $uid = $movie . $json['id'];
                                                        $this->execute('INSERT INTO collections (cl_uid, cl_id, cl_movie, cl_title, cl_transition, cl_time) VALUES (:cl_uid, :cl_id, :cl_movie, :cl_title, :cl_transition, :cl_time)', [
                                                            ':cl_uid' => $uid, 
                                                            ':cl_id' => $json['id'], 
                                                            ':cl_movie' => $movie, 
                                                            ':cl_title' => $json['name'], 
                                                            ':cl_transition' => $json['transition'], 
                                                            ':cl_time' => $json['time'], 
                                                        ]);
                                                        foreach ($json['assets'] as $kas => $vas) {
                                                            $this->execute('INSERT INTO assets (at_id, at_collection, at_order, at_name, at_type, at_time, at_action, at_frames, at_frtime, at_file1, at_file2, at_file3, at_file4, at_file5) VALUES (:at_id, :at_collection, :at_order, :at_name, :at_type, :at_time, :at_action, :at_frames, :at_frtime, :at_file1, :at_file2, :at_file3, :at_file4, :at_file5)', [
                                                                ':at_id' => $kas, 
                                                                ':at_collection' => $uid, 
                                                                ':at_order' => $json['assets'][$kas]['order'], 
                                                                ':at_name' => $json['assets'][$kas]['name'], 
                                                                ':at_type' => $json['assets'][$kas]['type'], 
                                                                ':at_time' => $json['assets'][$kas]['time'], 
                                                                ':at_action' => base64_encode(gzencode($json['assets'][$kas]['action'])), 
                                                                ':at_frames' => $json['assets'][$kas]['frames'], 
                                                                ':at_frtime' => $json['assets'][$kas]['frtime'], 
                                                                ':at_file1' => $json['assets'][$kas]['file']['@1'], 
                                                                ':at_file2' => $json['assets'][$kas]['file']['@2'], 
                                                                ':at_file3' => $json['assets'][$kas]['file']['@3'], 
                                                                ':at_file4' => $json['assets'][$kas]['file']['@4'], 
                                                                ':at_file5' => $json['assets'][$kas]['file']['@5'], 
                                                            ]);
                                                        }
                                                    }
                                                }
                                            }
                                            // scenes
                                            if (!is_dir('../movie/'.$movie.'.movie/scene')) {
                                                $this->createDir('../movie/'.$movie.'.movie/scene');
                                            }
                                            $files = scandir('../movie/'.$movie.'.movie/scene');
                                            foreach ($files as $fl) {
                                                if (($fl != '.') && ($fl != '..')) {
                                                    $json = json_decode(file_get_contents('../movie/'.$movie.'.movie/scene/'.$fl), true);
                                                    if (json_last_error() == JSON_ERROR_NONE) {
                                                        $ackeyframes = [ ];
                                                        foreach ($json['ackeyframes'] as $ack) $ackeyframes[] = $ack == '' ? '' : base64_encode(gzencode($ack));
                                                        $this->execute('INSERT INTO scenes (sc_id, sc_movie, sc_published, sc_title, sc_about, sc_image, sc_up, sc_down, sc_left, sc_right, sc_nin, sc_nout, sc_collections, sc_loop, sc_acstart, sc_ackeyframes, sc_user, sc_date, sc_static) VALUES (:sc_id, :sc_movie, :sc_published, :sc_title, :sc_about, :sc_image, :sc_up, :sc_down, :sc_left, :sc_right, :sc_nin, :sc_nout, :sc_collections, :sc_loop, :sc_acstart, :sc_ackeyframes, :sc_user, :sc_date, :sc_static)', [
                                                            ':sc_id' => $json['id'], 
                                                            ':sc_movie' => $movie, 
                                                            ':sc_published' => '1', 
                                                            ':sc_title' => $json['title'], 
                                                            ':sc_about' => $json['about'], 
                                                            ':sc_image' => $json['image'], 
                                                            ':sc_up' => $json['navigation']['up'], 
                                                            ':sc_down' => $json['navigation']['down'], 
                                                            ':sc_left' => $json['navigation']['left'], 
                                                            ':sc_right' => $json['navigation']['right'], 
                                                            ':sc_nin' => $json['navigation']['nin'], 
                                                            ':sc_nout' => $json['navigation']['nout'], 
                                                            ':sc_collections' => implode(',', $json['collections']), 
                                                            ':sc_loop' => $json['loop'], 
                                                            ':sc_acstart' => $json['acstart'] == '' ? '' : base64_encode(gzencode($json['acstart'])), 
                                                            ':sc_ackeyframes' => implode(',', $ackeyframes), 
                                                            ':sc_user' => $user, 
                                                            ':sc_date' => date('Y-m-d H:i:s'), 
                                                            ':sc_static' => (isset($json['staticsc']) ? ($json['staticsc'] === true ? '1' : '0') : '0'), 
                                                        ]);
                                                        $sceneid = $this->insertID();
                                                        $kforder = 0;
                                                        foreach ($json['keyframes'] as $kf) {
                                                            $this->execute('INSERT INTO keyframes (kf_scene, kf_order) VALUES (:kf_scene, :kf_order)', [
                                                               ':kf_scene' => $sceneid,
                                                                ':kf_order' => $kforder, 
                                                            ]);
                                                            $kfid = $this->insertID();
                                                            foreach ($kf as $kin => $vin) {
                                                                $this->execute('INSERT INTO instances (in_keyframe, in_name, in_collection, in_asset, in_action, in_play, in_actionover, in_timedac) VALUES (:in_keyframe, :in_name, :in_collection, :in_asset, :in_action, :in_play, :in_actionover, :in_timedac)', [
                                                                    ':in_keyframe' => $kfid, 
                                                                    ':in_name' => $kin, 
                                                                    ':in_collection' => $vin['collection'], 
                                                                    ':in_asset' => $vin['asset'], 
                                                                    ':in_action' => $vin['action'] == '' ? '' : base64_encode(gzencode($vin['action'])), 
                                                                    ':in_play' => $vin['play'] == true ? '1' : '0', 
                                                                    ':in_actionover' => (isset($vin['actionover']) ? ($vin['actionover'] == '' ? '' : base64_encode(gzencode($vin['actionover']))) : ''), 
                                                                    ':in_timedac' => (isset($vin['timedac']) ? ($vin['timedac'] == '' ? '' : base64_encode(gzencode($vin['timedac']))) : ''), 
                                                                ]);
                                                                $inid = $this->insertID();
                                                                $this->execute('INSERT INTO instancedesc (id_instance, id_position, id_order, id_x, id_y, id_alpha, id_width, id_height, id_rotation, id_visible, id_color, id_coloralpha, id_volume, id_pan, id_blur, id_dropshadow, id_textfont, id_textsize, id_textcolor, id_textbold, id_textitalic, id_textleading, id_textspacing, id_textbackground, id_textalign, id_glow, id_blend) VALUES (:instance, :position, :order, :x, :y, :alpha, :width, :height, :rotation, :visible, :color, :coloralpha, :volume, :pan, :blur, :dropshadow, :textfont, :textsize, :textcolor, :textbold, :textitalic, :textleading, :textspacing, :textbackground, :textalign, :glow, :blend)', [
                                                                    ':instance' => $inid, 
                                                                    ':position' => 'h', 
                                                                    ':order' => $vin['horizontal']['order'], 
                                                                    ':x' => $vin['horizontal']['x'], 
                                                                    ':y' => $vin['horizontal']['y'], 
                                                                    ':alpha' => $vin['horizontal']['alpha'], 
                                                                    ':width' => $vin['horizontal']['width'], 
                                                                    ':height' => $vin['horizontal']['height'], 
                                                                    ':rotation' => $vin['horizontal']['rotation'], 
                                                                    ':visible' => $vin['horizontal']['visible'] ? '1' : '0', 
                                                                    ':color' => $vin['horizontal']['color'], 
                                                                    ':coloralpha' => $vin['horizontal']['colorAlpha'], 
                                                                    ':volume' => $vin['horizontal']['volume'], 
                                                                    ':pan' => $vin['horizontal']['pan'], 
                                                                    ':blur' => $vin['horizontal']['blur'], 
                                                                    ':dropshadow' => $vin['horizontal']['dropshadow'], 
                                                                    ':textfont' => $vin['horizontal']['textFont'], 
                                                                    ':textsize' => $vin['horizontal']['textSize'], 
                                                                    ':textcolor' => $vin['horizontal']['textColor'], 
                                                                    ':textbold' => $vin['horizontal']['textBold'] ? '1' : '0', 
                                                                    ':textitalic' => $vin['horizontal']['textItalic'] ? '1' : '0', 
                                                                    ':textleading' => $vin['horizontal']['textLeading'], 
                                                                    ':textspacing' => $vin['horizontal']['textSpacing'], 
                                                                    ':textbackground' => $vin['horizontal']['textBackground'], 
                                                                    ':textalign' => $vin['horizontal']['textAlign'], 
                                                                    ':glow' => (isset($vin['horizontal']['glow']) ? $vin['horizontal']['glow'] : ''), 
                                                                    ':blend' => (isset($vin['horizontal']['blend']) ? $vin['horizontal']['blend'] : ''), 
                                                                ]);
                                                                $this->execute('INSERT INTO instancedesc (id_instance, id_position, id_order, id_x, id_y, id_alpha, id_width, id_height, id_rotation, id_visible, id_color, id_coloralpha, id_volume, id_pan, id_blur, id_dropshadow, id_textfont, id_textsize, id_textcolor, id_textbold, id_textitalic, id_textleading, id_textspacing, id_textbackground, id_textalign, id_glow, id_blend) VALUES (:instance, :position, :order, :x, :y, :alpha, :width, :height, :rotation, :visible, :color, :coloralpha, :volume, :pan, :blur, :dropshadow, :textfont, :textsize, :textcolor, :textbold, :textitalic, :textleading, :textspacing, :textbackground, :textalign, :glow, :blend)', [
                                                                    ':instance' => $inid, 
                                                                    ':position' => 'v', 
                                                                    ':order' => $vin['vertical']['order'], 
                                                                    ':x' => $vin['vertical']['x'], 
                                                                    ':y' => $vin['vertical']['y'], 
                                                                    ':alpha' => $vin['vertical']['alpha'], 
                                                                    ':width' => $vin['vertical']['width'], 
                                                                    ':height' => $vin['vertical']['height'], 
                                                                    ':rotation' => $vin['vertical']['rotation'], 
                                                                    ':visible' => $vin['vertical']['visible'] ? '1' : '0', 
                                                                    ':color' => $vin['vertical']['color'], 
                                                                    ':coloralpha' => $vin['vertical']['colorAlpha'], 
                                                                    ':volume' => $vin['vertical']['volume'], 
                                                                    ':pan' => $vin['vertical']['pan'], 
                                                                    ':blur' => $vin['vertical']['blur'], 
                                                                    ':dropshadow' => $vin['vertical']['dropshadow'], 
                                                                    ':textfont' => $vin['vertical']['textFont'], 
                                                                    ':textsize' => $vin['vertical']['textSize'], 
                                                                    ':textcolor' => $vin['vertical']['textColor'], 
                                                                    ':textbold' => $vin['vertical']['textBold'] ? '1' : '0', 
                                                                    ':textitalic' => $vin['vertical']['textItalic'] ? '1' : '0', 
                                                                    ':textleading' => $vin['vertical']['textLeading'], 
                                                                    ':textspacing' => $vin['vertical']['textSpacing'], 
                                                                    ':textbackground' => $vin['vertical']['textBackground'], 
                                                                    ':textalign' => $vin['vertical']['textAlign'], 
                                                                    ':glow' => (isset($vin['horizontal']['glow']) ? $vin['horizontal']['glow'] : ''), 
                                                                    ':blend' => (isset($vin['horizontal']['blend']) ? $vin['horizontal']['blend'] : ''), 
                                                                ]);
                                                            }
                                                            $kforder++;
                                                        }
                                                    }
                                                }
                                            }
                                            
                                            // media folder
                                            if (!is_dir('../movie/'.$movie.'.movie/media')) !$this->createDir('../movie/'.$movie.'.movie/media');
                                            if (!is_dir('../movie/'.$movie.'.movie/media/picture')) !$this->createDir('../movie/'.$movie.'.movie/media/picture');
                                            if (!is_dir('../movie/'.$movie.'.movie/media/video')) !$this->createDir('../movie/'.$movie.'.movie/media/video');
                                            if (!is_dir('../movie/'.$movie.'.movie/media/audio')) !$this->createDir('../movie/'.$movie.'.movie/media/audio');
                                            if (!is_dir('../movie/'.$movie.'.movie/media/html')) !$this->createDir('../movie/'.$movie.'.movie/media/html');
                                            if (!is_dir('../movie/'.$movie.'.movie/media/font')) !$this->createDir('../movie/'.$movie.'.movie/media/font');
                                            if (!is_dir('../movie/'.$movie.'.movie/media/spritemap')) !$this->createDir('../movie/'.$movie.'.movie/media/spritemap');
                                            
                                            // additional files
                                            $stringsjson = '';
                                            if (is_file('../movie/'.$movie.'.movie/strings.json')) $stringsjson = file_get_contents('../movie/'.$movie.'.movie/strings.json');
                                            $contraptions = '';
                                            if (is_file('../movie/'.$movie.'.movie/contraptions.json')) $contraptions = file_get_contents('../movie/'.$movie.'.movie/contraptions.json');
                                            if ($contraptions != '') $contraptions = base64_encode(gzencode($contraptions));
                                            if ($stringsjson != '') $stringsjson = base64_encode(gzencode($stringsjson));
                                            $this->execute('UPDATE movies SET mv_contraptions=:cont, mv_strings=:str WHERE mv_id=:id', [
                                                ':cont' => $contraptions, 
                                                ':str' => $stringsjson, 
                                                ':id' => $movie,
                                            ]);
                                            
                                            // movie imported
                                            @unlink('../../export/' . $movie . '.zip');
                                            return (0);
                                        }
                                    }
                                }
                            }
                        } else {
                            // error opening zip
                            @unlink('../../export/' . $movie . '.zip');
                            return (5);
                        }
                    }
                }
            }
		} else {
			return (-6);
		}
	}
    
    /**
	 * Exports a movie as a website.
	 * @param	string	$user	the requesting user
	 * @param	string	$movie	the movie id
     * @param	string	$mode	the render mode
     * @param   string    $sitemap    website base for sitemap (don't create if blank)
     * @param   string    $location    export as zip or to the sites folder?
     * @param   bool    $iframe add and iframe.html file embed example?
	 * @return	string|bool the path to the exported file or false on error
	 */
	public function exportSite($user, $movie, $mode, $sitemap, $location, $iframe = false) {
		// check user: movie owner?
		if (!is_null($this->db)) {
			$ck = $this->queryAll('SELECT * FROM movies WHERE mv_id=:id AND mv_user=:user', [
				':id' => $movie, 
				':user' => $user, 
			]);
			if (count($ck) > 0) {
                if (is_dir('../movie/'.$movie.'.movie')) {
                    set_time_limit(0);
                    $this->removeFileDir('../../export/site-'.$movie.'.zip');
                    $this->removeFileDir('../../export/site-'.$movie);
                    $this->copyDir('../../export/site', ('../../export/site-'.$movie));
                    if (is_dir('../../export/site-'.$movie)) {
                        if ($this->loadMovie($movie)) {
                            set_time_limit(0);
                            
                            // re-publish scenes?
                            $pub = false;
                            if (($ck[0]['mv_identify'] == '1') || (!is_null($ck[0]['mv_vsgroups']) && ($ck[0]['mv_vsgroups'] != ''))) {
                                $pub = true;
                                $this->publishScenes($movie);
                            }
                            
                            // fonts
                            $fonts = [ ];
                            $ck = $this->queryAll('SELECT * FROM fonts');
                            foreach ($ck as $v) {
                                $fonts[] = '@font-face { font-family: "' . $v['fn_name'] . '"; src: url("./assets/' . $v['fn_file'] . '"); }';
                                @copy(('../font/' . $v['fn_file']), ('../../export/site-'.$movie.'/assets/' . $v['fn_file']));
                            }
                            $ck = $this->queryAll('SELECT mv_fonts FROM movies WHERE mv_id=:id', [':id' => $movie]);
                            if (count($ck) > 0) {
                                if ($ck[0]['mv_fonts'] != '') {
                                    $json = json_decode(gzdecode(base64_decode($ck[0]['mv_fonts'])), true);
                                    if (json_last_error() == JSON_ERROR_NONE) {
                                        foreach ($json as $k => $v) {
                                            if (isset($v['name']) && isset($v['file'])) {
                                                $fonts[] = '@font-face { font-family: "' . $v['name'] . '"; src: url("./assets/' . $v['file'] . '"); }';
                                                @copy(('../movie/'.$movie.'.movie/media/font/' . $v['file']), ('../../export/site-'.$movie.'/assets/' . $v['file']));
                                            }
                                        }
                                    }
                                }
                            }
                            // plugins
                            $plhead = [ ];
                            $plend = [ ];
                            $ck = $this->queryAll('SELECT pc_id, pc_file FROM pluginconfig WHERE pc_active=:ac AND pc_index=:in', [
                                ':ac' => '1', 
                                ':in' => '1', 
                            ]);
                            foreach ($ck as $v) {
                                if (is_file('../../app/' . $v['pc_file'] . '.php')) {
                                    require_once('../../app/' . $v['pc_file'] . '.php');
                                    $pl = new $v['pc_file'];
                                    $plhead[] = $pl->indexHead();
                                    $plend[] = $pl->indexEndBody();
                                }
                            }
                            // index text
                            $index = file_get_contents('../../export/site-'.$movie.'/index.html');
                            // prepare values
                            $fonts = implode("\r\n", $fonts);
                            $plhead = implode("\r\n", $plhead); 
                            $plend = implode("\r\n", $plend); 
                            $image = $this->info['image'] == '' ? '' : '<meta property="og:image" content="./movie/'.$movie.'.movie/media/picture/'.$this->info['image'].'" />';
                            $mode = $mode == 'dom' ? 'dom' : 'webgl';
                            $color = str_replace('0x', '#', $this->info['screen']['bgcolor']);
                            $ws = '';
                            if ((strpos($this->conf['path'], 'localhost') === false) && (strpos($this->conf['path'], '127.0.0.1') === false)) {
                                $ws = $this->slashUrl($this->conf['path']) . 'ws/';
                            }
                            // sitemap?
                            if ($sitemap != '') {
                                $sitemap = $this->slashUrl($sitemap);
                                $mapcontent = [ ['loc' => $sitemap . 'index.html', 'lastmod' => date('Y-m-d'), 'priority' => '1.0' ] ];
                                $sitemap = $this->slashUrl($sitemap);
                                $cks = $this->queryAll('SELECT sc_id, sc_title, sc_about, sc_image, sc_date FROM scenes WHERE sc_movie=:mv AND sc_published=:pub', [
                                    ':mv' => $movie, 
                                    ':pub' => '1', 
                                ]);
                                foreach ($cks as $vs) {
                                    $txt = $vs['sc_about'] == '' ? $this->info['description'] : $vs['sc_about'];
                                    $img = $vs['sc_image'] == '' ? $image : ('<meta property="og:image" content="./movie/'.$movie.'.movie/media/picture/'.$vs['sc_image'].'" />');
                                    $scenepage = str_replace([
                                        '[SITEMOVIE]', 
                                        '[SITESCENE]', 
                                        '[SITETITLE]', 
                                        '[SITECOLOR]', 
                                        '[SITEABOUT]', 
                                        '[SITESHAREIMG]',
                                        '[SITEFONTS]', 
                                        '[SITEPLUGINHEAD]', 
                                        '[SITEPLUGINEND]', 
                                        '[SITEWS]', 
                                        '[RAND]'
                                    ], [
                                        $movie, 
                                        $vs['sc_id'], 
                                        $vs['sc_title'], 
                                        $color,
                                        $txt, 
                                        $img, 
                                        $fonts, 
                                        $plhead, 
                                        $plend, 
                                        $ws, 
                                        time()
                                    ], $index);
                                    file_put_contents('../../export/site-'.$movie.'/'.$vs['sc_id'].'.html', $scenepage);
                                    $mapcontent[] = [
                                        'loc' => $sitemap . $vs['sc_id'] . '.html', 
                                        'lastmod' => substr($vs['sc_date'], 0, 10), 
                                        'priority' => '0.5', 
                                    ];
                                }
                                $sitemapfile = '<?xml version="1.0" encoding="UTF-8"?><urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">';
                                foreach ($mapcontent as $mc) {
                                    $sitemapfile .= '<url><loc>' . $mc['loc'] . '</loc><lastmod>' . $mc['lastmod'] . '</lastmod><priority>' . $mc['priority'] . '</priority></url>';
                                }
                                $sitemapfile .= '</urlset>';
                                file_put_contents('../../export/site-'.$movie.'/sitemap.xml', $sitemapfile);
                                // add CORS
                                $cors = explode('/', $sitemap);
                                $cdomain = '';
                                for ($i=1; $i<count($cors); $i++) {
                                    if ($cdomain == '') {
                                        if ($cors[$i] != '') {
                                            $cdomain = $cors[0] . '//' . $cors[$i] . '/';
                                        }
                                    }
                                }
                                if ($cdomain != '') {
                                    $this->execute('INSERT IGNORE INTO cors (cr_domain) VALUE (:dom)', [
                                       ':dom' => $cdomain, 
                                    ]);
                                }
                            }
                            // index.html
                            $index = str_replace([
                                '[SITEMOVIE]', 
                                '[SITESCENE]', 
                                '[SITETITLE]', 
                                '[SITECOLOR]', 
                                '[SITEABOUT]', 
                                '[SITESHAREIMG]',
                                '[SITEFONTS]', 
                                '[SITEPLUGINHEAD]', 
                                '[SITEPLUGINEND]', 
                                '[SITEWS]', 
                                '[RAND]'
                            ], [
                                $movie, 
                                '', 
                                $this->info['title'], 
                                $color, 
                                $this->info['description'], 
                                $image, 
                                $fonts, 
                                $plhead, 
                                $plend, 
                                $ws, 
                                time()
                            ], $index);
                            file_put_contents('../../export/site-'.$movie.'/index.html', $index);
                            // runtime
                            if ($mode == 'dom') {
                                @copy('../../export/runtimes/website-dom.js', ('../../export/site-'.$movie.'/TilBuci.js'));
                            } else {
                                @copy('../../export/runtimes/website-webgl.js', ('../../export/site-'.$movie.'/TilBuci.js'));
                            }
                            // iframe?
                            if ($iframe) {
                                $ifcontent = file_get_contents('../../export/iframe/iframe.html');
                                $ifheight = round(((int)$this->info['screen']['small'] * 640) / (int)$this->info['screen']['big']);
                                $ifcontent = str_replace([
                                    '[TITLE]', 
                                    '[HEIGHT]'
                                ], [
                                    $this->info['title'], 
                                    $ifheight
                                ], $ifcontent);
                                file_put_contents('../../export/site-'.$movie.'/iframe.html', $ifcontent);
                            }
                            // favicon
                            if ($this->info['favicon'] != '') {
                                @unlink('../../export/site-'.$movie.'/favicon.png');
                                @copy(('../movie/'.$movie.'.movie/media/picture/'.$this->info['favicon']), ('../../export/site-'.$movie.'/favicon.png'));
                            }
                            // movie folder
                            $this->copyDir(('../movie/'.$movie.'.movie'), ('../../export/site-'.$movie.'/movie/'.$movie.'.movie'));
                            $this->info['key'] = '';
                            $this->info['fallback'] = '';
                            $this->info['identify'] = false;
                            $this->info['vsgroups'] = '';
                            file_put_contents(('../../export/site-'.$movie.'/movie/'.$movie.'.movie/movie.json'), json_encode($this->info));
                            // save zip?
                            if ($location == 'zip') {
                                $zip = new \ZipArchive;
                                $zip->open('../../export/site-'.$movie.'.zip', \ZipArchive::CREATE | \ZipArchive::OVERWRITE);
                                $files = new \RecursiveIteratorIterator(
                                    new \RecursiveDirectoryIterator('../../export/site-'.$movie),
                                    \RecursiveIteratorIterator::LEAVES_ONLY
                                );
                                $rootPath = realpath('../../export/site-'.$movie);
                                foreach ($files as $file) {
                                    if (!$file->isDir()) {
                                        $filePath = $file->getRealPath();
                                        $relativePath = substr($filePath, strlen($rootPath) + 1);
                                        $relativePath = str_replace('\\', '/', $relativePath);
                                        $zip->addFile($filePath, $relativePath);
                                    }
                                }
                                $zip->close();
                                $this->removeFileDir('../../export/site-'.$movie);
                                // remove scenes?
                                if ($pub) {
                                    $this->removePublished($movie);
                                }
                                return ('site-'.$movie.'.zip');
                            } else {
                                // save at the sites folder
                                if (!is_dir('../sites')) $this->createDir('../sites');
                                if (is_dir('../sites/'.$movie)) $this->removeFileDir('../sites/'.$movie);
                                $redirect = file_get_contents('../../export/pwa/redirect.php');
                                file_put_contents('../sites/index.php', $redirect);
                                $this->copyDir(('../../export/site-'.$movie), ('../sites/'.$movie));
                                $this->removeFileDir('../../export/site-'.$movie);
                                if ($pub) {
                                    $this->removePublished($movie);
                                }
                                return ($this->conf['path'].'sites/'.$movie.'/');
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
			} else {
                // the current user isn't the movie owner
				return (false);
			}
		} else {
			return (false);
		}
	}
    
    /**
	 * Exports a movie as a PWA application.
	 * @param	string	$user	the requesting user
	 * @param	string	$movie	the movie id
     * @param	string	$name	the app name
     * @param	string	$shortname	the app short name
     * @param   string  $lang   the app language
     * @param   string  $url   the the url to load the app from
	 * @return	string|bool the path to the exported file or false on error
	 */
	public function exportPwa($user, $movie, $name, $shortname, $lang, $url, $location) {
		// check user: movie owner?
		if (!is_null($this->db)) {
			$ck = $this->queryAll('SELECT * FROM movies WHERE mv_id=:id AND mv_user=:user', [
				':id' => $movie, 
				':user' => $user, 
			]);
			if (count($ck) > 0) {
                if (is_dir('../movie/'.$movie.'.movie')) {
                    set_time_limit(0);
                    $this->removeFileDir('../../export/pwa-'.$movie.'.zip');
                    $this->removeFileDir('../../export/pwa-'.$movie);
                    $this->copyDir('../../export/site', ('../../export/pwa-'.$movie));
                    if (is_dir('../../export/pwa-'.$movie)) {
                        if ($this->loadMovie($movie)) {
                            // exporting may take some time
                            set_time_limit(0);
                            
                            // re-publish scenes?
                            $pub = false;
                            if (($ck[0]['mv_identify'] == '1') || (!is_null($ck[0]['mv_vsgroups']) && ($ck[0]['mv_vsgroups'] != ''))) {
                                $pub = true;
                                $this->publishScenes($movie);
                            }
                            
                            // add CORS
                            $cors = explode('/', $url);
                            $cdomain = '';
                            for ($i=1; $i<count($cors); $i++) {
                                if ($cdomain == '') {
                                    if ($cors[$i] != '') {
                                        $cdomain = $cors[0] . '//' . $cors[$i] . '/';
                                    }
                                }
                            }
                            if ($cdomain != '') {
                                $this->execute('INSERT IGNORE INTO cors (cr_domain) VALUE (:dom)', [
                                   ':dom' => $cdomain, 
                                ]);
                            }
                            
                            // check url
                            $url = str_replace('https://', '', $this->slashUrl(mb_strtolower($url)));
                            $url = explode('/', substr($url, 0, (strlen($url)-1)));
                            array_shift($url);
                            $url = implode('/', $url) . '/';
                            if ($url == '/') $url = '';
                                else $url = '/' . $url;
                            // offline files
                            $offline = [
                                $url, 
                                $url . 'index.html', 
                                $url . 'favicon.png', 
                                $url . 'TilBuci.js', 
                                $url . 'manifest.json', 
                                $url . 'assets/tilbuci/btClose.png', 
                                $url . 'assets/tilbuci/btOk.png', 
                                $url . 'manifest/default.json', 
                                $url . 'movie/' . $movie . '.movie/movie.json'
                            ];
                            // fonts
                            $fonts = [ ];
                            $ck = $this->queryAll('SELECT * FROM fonts');
                            foreach ($ck as $v) {
                                $fonts[] = '@font-face { font-family: "' . $v['fn_name'] . '"; src: url("./assets/' . $v['fn_file'] . '"); }';
                                @copy(('../font/' . $v['fn_file']), ('../../export/pwa-'.$movie.'/assets/' . $v['fn_file']));
                                $offline[] = $url . 'assets/' . $v['fn_file'];
                            }
                            $ck = $this->queryAll('SELECT mv_fonts FROM movies WHERE mv_id=:id', [':id' => $movie]);
                            if (count($ck) > 0) {
                                if ($ck[0]['mv_fonts'] != '') {
                                    $json = json_decode(gzdecode(base64_decode($ck[0]['mv_fonts'])), true);
                                    if (json_last_error() == JSON_ERROR_NONE) {
                                        foreach ($json as $k => $v) {
                                            if (isset($v['name']) && isset($v['file'])) {
                                                $fonts[] = '@font-face { font-family: "' . $v['name'] . '"; src: url("./assets/' . $v['file'] . '"); }';
                                                @copy(('../movie/'.$movie.'.movie/media/font/' . $v['file']), ('../../export/pwa-'.$movie.'/assets/' . $v['file']));
                                                $offline[] = $url . 'assets/' . $v['file'];
                                            }
                                        }
                                    }
                                }
                            }
                            // plugins
                            $plhead = [ ];
                            $plend = [ ];
                            $ck = $this->queryAll('SELECT pc_id, pc_file FROM pluginconfig WHERE pc_active=:ac AND pc_index=:in', [
                                ':ac' => '1', 
                                ':in' => '1', 
                            ]);
                            foreach ($ck as $v) {
                                if (is_file('../../app/' . $v['pc_file'] . '.php')) {
                                    require_once('../../app/' . $v['pc_file'] . '.php');
                                    $pl = new $v['pc_file'];
                                    $plhead[] = $pl->indexHead();
                                    $plend[] = $pl->indexEndBody();
                                }
                            }
                            // index text
                            $index = file_get_contents('../../export/pwa/index.html');
                            // prepare values
                            $fonts = implode("\r\n", $fonts);
                            $plhead = implode("\r\n", $plhead); 
                            $plend = implode("\r\n", $plend); 
                            $image = $this->info['image'] == '' ? '' : '<meta property="og:image" content="./movie/'.$movie.'.movie/media/picture/'.$this->info['image'].'" />';
                            $color = str_replace('0x', '#', $this->info['screen']['bgcolor']);
                            $ws = '';
                            if ((strpos($this->conf['path'], 'localhost') === false) && (strpos($this->conf['path'], '127.0.0.1') === false)) {
                                $ws = $this->slashUrl($this->conf['path']) . 'ws/';
                            }
                            // index.html
                            $index = str_replace([
                                '[SITEMOVIE]', 
                                '[SITESCENE]', 
                                '[SITETITLE]', 
                                '[SITECOLOR]', 
                                '[SITEABOUT]', 
                                '[SITESHAREIMG]',
                                '[SITEFONTS]', 
                                '[SITEPLUGINHEAD]', 
                                '[SITEPLUGINEND]', 
                                '[SITEWS]'
                            ], [
                                $movie, 
                                '', 
                                $this->info['title'], 
                                $color, 
                                $this->info['description'], 
                                $image, 
                                $fonts, 
                                $plhead, 
                                $plend, 
                                $ws
                            ], $index);
                            file_put_contents('../../export/pwa-'.$movie.'/index.html', $index);
                            // runtime
                            @copy('../../export/runtimes/pwa.js', ('../../export/pwa-'.$movie.'/TilBuci.js'));
                            // favicon
                            if ($this->info['favicon'] != '') {
                                @unlink('../../export/pwa-'.$movie.'/favicon.png');
                                @copy(('../movie/'.$movie.'.movie/media/picture/'.$this->info['favicon']), ('../../export/pwa-'.$movie.'/favicon.png'));
                            }
                            // movie folder
                            $this->copyDir(('../movie/'.$movie.'.movie'), ('../../export/pwa-'.$movie.'/movie/'.$movie.'.movie'));
                            $this->info['key'] = '';
                            $this->info['fallback'] = '';
                            $this->info['identify'] = false;
                            $this->info['vsgroups'] = '';
                            file_put_contents(('../../export/pwa-'.$movie.'/movie/'.$movie.'.movie/movie.json'), json_encode($this->info));
                            // offline movie files
                            if (is_file('../../export/pwa-'.$movie.'/movie/'.$movie.'.movie/strings.json')) $offline[] = $url . 'movie/'.$movie.'.movie/strings.json';
                            if (is_file('../../export/pwa-'.$movie.'/movie/'.$movie.'.movie/contraptions.json')) $offline[] = $url . 'movie/'.$movie.'.movie/contraptions.json';
                            // check offline scenes
                            $collections = [ ];
                            $cks = $this->queryAll('SELECT sc_id, sc_collections FROM scenes WHERE sc_movie=:mv AND sc_published=:pub', [ ':mv' => $movie, ':pub' => '1' ]);
                            foreach ($cks as $vs) {
                                $offline[] = $url . 'movie/'.$movie.'.movie/scene/' . $vs['sc_id'] . '.json';
                                $cols = explode(',', $vs['sc_collections']);
                                foreach ($cols as $vc) {
                                    if (($vc != '') && !in_array($vc, $collections)) {
                                        $collections[] = $vc;
                                    }
                                }
                            }
                            // check offline collections
                            foreach ($collections as $vc) {
                                if (is_file('../../export/pwa-'.$movie.'/movie/'.$movie.'.movie/collection/' . $vc . '.json')) $offline[] = $url . 'movie/'.$movie.'.movie/collection/' . $vc . '.json';
                                // offline collection assets
                                $cka = $this->queryAll('SELECT at_type, at_file1, at_file2, at_file3, at_file4, at_file5 FROM assets WHERE at_collection=:col AND FIND_IN_SET(at_type, :types)', [
                                    ':col' => $movie . $vc, 
                                    ':types' => 'audio,html,picture,spritemap,video', 
                                ]);
                                foreach ($cka as $va) {
                                    for ($ia=1; $ia<=5; $ia++) {
                                        $path = $url . 'movie/'.$movie.'.movie/media/' . $va['at_type'] . '/' . $va['at_file'.$ia];
                                        if (!in_array($path, $offline)) {
                                            if (is_file('../../export/pwa-'.$movie.'/movie/'.$movie.'.movie/media/' . $va['at_type'] . '/' . $va['at_file'.$ia])) {
                                                $offline[] = $path; 
                                            }
                                        }
                                    }
                                }
                            }
                            // check offline embed files
                            if (is_dir('../../export/pwa-'.$movie.'/movie/'.$movie.'.movie/media/embed/')) {
                                $embedlist = $this->listDirFiles('../../export/pwa-'.$movie.'/movie/'.$movie.'.movie/media/embed');
                                foreach ($embedlist as $el) {
                                    $offline[] = str_replace('../../export/pwa-'.$movie.'/', $url, $el);
                                }
                            }
                            // service worker
                            $worker = file_get_contents('../../export/pwa/serviceWorker.js');
                            $worker = str_replace([
                                    '[TIME]', 
                                    '[PRECACHE]'
                                ], [
                                    time(), 
                                    '"' . implode('", "', $offline) . '"', 
                                ], $worker);
                            file_put_contents('../../export/pwa-'.$movie.'/serviceWorker.js', $worker);
                            // manifest
                            $orientation = 'any';
                            if ($this->info['screen']['type'] == 'portrait') $orientation = 'portrait-primary';
                                else if ($this->info['screen']['type'] == 'landscape') $orientation = 'landscape-primary';
                            $manifest = file_get_contents('../../export/pwa/manifest.json');
                            $manifest = str_replace([
                                    '[APPNAME]', 
                                    '[APPSHORTNAME]', 
                                    '[APPSTART]', 
                                    '[APPID]', 
                                    '[APPCOLOR]', 
                                    '[APPORIENTATION]', 
                                    '[APPLANG]', 
                                    '[APPSCOPE]'
                                ], [
                                    $name, 
                                    $shortname, 
                                    ($url . 'index.html'), 
                                    ($url . 'index.html'), 
                                    $color, 
                                    $orientation, 
                                    $lang, 
                                    $url
                                ], $manifest);
                            file_put_contents('../../export/pwa-'.$movie.'/manifest.json', $manifest);
                            if ($location == 'zip') {
                                // save zip
                                $zip = new \ZipArchive;
                                $zip->open('../../export/pwa-'.$movie.'.zip', \ZipArchive::CREATE | \ZipArchive::OVERWRITE);
                                $files = new \RecursiveIteratorIterator(
                                    new \RecursiveDirectoryIterator('../../export/pwa-'.$movie),
                                    \RecursiveIteratorIterator::LEAVES_ONLY
                                );
                                $rootPath = realpath('../../export/pwa-'.$movie);
                                foreach ($files as $file) {
                                    if (!$file->isDir()) {
                                        $filePath = $file->getRealPath();
                                        $relativePath = substr($filePath, strlen($rootPath) + 1);
                                        $relativePath = str_replace('\\', '/', $relativePath);
                                        $zip->addFile($filePath, $relativePath);
                                    }
                                }
                                $zip->close();
                                $this->removeFileDir('../../export/pwa-'.$movie);
                                // remove scenes?
                                if ($pub) {
                                    $this->removePublished($movie);
                                }
                                return ('pwa-'.$movie.'.zip');
                            } else {
                                // save at the pwa folder
                                if (!is_dir('../pwa')) $this->createDir('../pwa');
                                if (is_dir('../pwa/'.$movie)) $this->removeFileDir('../pwa/'.$movie);
                                $redirect = file_get_contents('../../export/pwa/redirect.php');
                                file_put_contents('../pwa/index.php', $redirect);
                                $this->copyDir(('../../export/pwa-'.$movie), ('../pwa/'.$movie));
                                $this->removeFileDir('../../export/pwa-'.$movie);
                                if ($pub) {
                                    $this->removePublished($movie);
                                }
                                return ($this->conf['path'].'pwa/'.$movie.'/');
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
			} else {
                // the current user isn't the movie owner
				return (false);
			}
		} else {
			return (false);
		}
	}
    
    /**
	 * Exports a movie for publishing services.
	 * @param	string	$user	the requesting user
	 * @param	string	$movie	the movie id
	 * @return	string|bool the path to the exported file or false on error
	 */
	public function exportPub($user, $movie) {
		// check user: movie owner?
		if (!is_null($this->db)) {
			$ck = $this->queryAll('SELECT * FROM movies WHERE mv_id=:id AND mv_user=:user', [
				':id' => $movie, 
				':user' => $user, 
			]);
			if (count($ck) > 0) {
                if (is_dir('../movie/'.$movie.'.movie')) {
                    set_time_limit(0);
                    $this->removeFileDir('../../export/publish-'.$movie.'.zip');
                    $this->removeFileDir('../../export/publish-'.$movie);
                    $this->copyDir('../../export/site', ('../../export/publish-'.$movie));
                    if (is_dir('../../export/publish-'.$movie)) {
                        if ($this->loadMovie($movie)) {
                            set_time_limit(0);
                            
                            // re-publish scenes?
                            $pub = false;
                            if (($ck[0]['mv_identify'] == '1') || (!is_null($ck[0]['mv_vsgroups']) && ($ck[0]['mv_vsgroups'] != ''))) {
                                $pub = true;
                                $this->publishScenes($movie);
                            }
                            
                            // fonts
                            $fonts = [ ];
                            $ck = $this->queryAll('SELECT * FROM fonts');
                            foreach ($ck as $v) {
                                $fonts[] = '@font-face { font-family: "' . $v['fn_name'] . '"; src: url("./assets/' . $v['fn_file'] . '"); }';
                                @copy(('../font/' . $v['fn_file']), ('../../export/publish-'.$movie.'/assets/' . $v['fn_file']));
                            }
                            $ck = $this->queryAll('SELECT mv_fonts FROM movies WHERE mv_id=:id', [':id' => $movie]);
                            if (count($ck) > 0) {
                                if ($ck[0]['mv_fonts'] != '') {
                                    $json = json_decode(gzdecode(base64_decode($ck[0]['mv_fonts'])), true);
                                    if (json_last_error() == JSON_ERROR_NONE) {
                                        foreach ($json as $k => $v) {
                                            if (isset($v['name']) && isset($v['file'])) {
                                                $fonts[] = '@font-face { font-family: "' . $v['name'] . '"; src: url("./assets/' . $v['file'] . '"); }';
                                                @copy(('../movie/'.$movie.'.movie/media/font/' . $v['file']), ('../../export/publish-'.$movie.'/assets/' . $v['file']));
                                            }
                                        }
                                    }
                                }
                            }
                            // plugins
                            $plhead = [ ];
                            $plend = [ ];
                            $ck = $this->queryAll('SELECT pc_id, pc_file FROM pluginconfig WHERE pc_active=:ac AND pc_index=:in', [
                                ':ac' => '1', 
                                ':in' => '1', 
                            ]);
                            foreach ($ck as $v) {
                                if (is_file('../../app/' . $v['pc_file'] . '.php')) {
                                    require_once('../../app/' . $v['pc_file'] . '.php');
                                    $pl = new $v['pc_file'];
                                    $plhead[] = $pl->indexHead();
                                    $plend[] = $pl->indexEndBody();
                                }
                            }
                            // index text
                            $index = file_get_contents('../../export/publish/index.html');
                            // prepare values
                            $fonts = implode("\r\n", $fonts);
                            $plhead = implode("\r\n", $plhead); 
                            $plend = implode("\r\n", $plend); 
                            $image = $this->info['image'] == '' ? '' : '<meta property="og:image" content="./movie/'.$movie.'.movie/media/picture/'.$this->info['image'].'" />';
                            $color = str_replace('0x', '#', $this->info['screen']['bgcolor']);
                            // add CORS
                            $this->execute('INSERT IGNORE INTO cors (cr_domain) VALUE (:dom)', [
                               ':dom' => 'https://itch.io/', 
                            ]);
                            $this->execute('INSERT IGNORE INTO cors (cr_domain) VALUE (:dom)', [
                               ':dom' => 'https://gamejolt.com/', 
                            ]);
                            $ws = '';
                            if ((strpos($this->conf['path'], 'localhost') === false) && (strpos($this->conf['path'], '127.0.0.1') === false)) {
                                $ws = $this->slashUrl($this->conf['path']) . 'ws/';
                            }
                            // index.html
                            $index = str_replace([
                                '[SITEMOVIE]', 
                                '[SITESCENE]', 
                                '[SITETITLE]', 
                                '[SITECOLOR]', 
                                '[SITEABOUT]', 
                                '[SITESHAREIMG]',
                                '[SITEFONTS]', 
                                '[SITEPLUGINHEAD]', 
                                '[SITEPLUGINEND]', 
                                '[SITEWS]'
                            ], [
                                $movie, 
                                '', 
                                $this->info['title'], 
                                $color, 
                                $this->info['description'], 
                                $image, 
                                $fonts, 
                                $plhead, 
                                $plend, 
                                $ws
                            ], $index);
                            file_put_contents('../../export/publish-'.$movie.'/index.html', $index);
                            // runtime
                            @copy('../../export/runtimes/publish.js', ('../../export/publish-'.$movie.'/TilBuci.js'));
                            // favicon
                            if ($this->info['favicon'] != '') {
                                @unlink('../../export/publish-'.$movie.'/favicon.png');
                                @copy(('../movie/'.$movie.'.movie/media/picture/'.$this->info['favicon']), ('../../export/publish-'.$movie.'/favicon.png'));
                            }
                            // movie folder
                            $this->copyDir(('../movie/'.$movie.'.movie'), ('../../export/publish-'.$movie.'/movie/'.$movie.'.movie'));
                            $this->info['key'] = '';
                            $this->info['fallback'] = '';
                            $this->info['identify'] = false;
                            $this->info['vsgroups'] = '';
                            file_put_contents(('../../export/publish-'.$movie.'/movie/'.$movie.'.movie/movie.json'), json_encode($this->info));
                            // save zip
                            $zip = new \ZipArchive;
                            $zip->open('../../export/publish-'.$movie.'.zip', \ZipArchive::CREATE | \ZipArchive::OVERWRITE);
                            $files = new \RecursiveIteratorIterator(
                                new \RecursiveDirectoryIterator('../../export/publish-'.$movie),
                                \RecursiveIteratorIterator::LEAVES_ONLY
                            );
                            $rootPath = realpath('../../export/publish-'.$movie);
                            foreach ($files as $file) {
                                if (!$file->isDir()) {
                                    $filePath = $file->getRealPath();
                                    $relativePath = substr($filePath, strlen($rootPath) + 1);
                                    $relativePath = str_replace('\\', '/', $relativePath);
                                    $zip->addFile($filePath, $relativePath);
                                }
                            }
                            $zip->close();
                            $this->removeFileDir('../../export/publish-'.$movie);
                            
                            // remove scenes?
                            if ($pub) {
                                $this->removePublished($movie);
                            }
                            
                            return ('publish-'.$movie.'.zip');
                        } else {
                            return (false);
                        }
                    } else {
                        return (false);
                    }                    
                } else {
                    return (false);
                }
			} else {
                // the current user isn't the movie owner
				return (false);
			}
		} else {
			return (false);
		}
	}
    
    /**
	 * Exports a movie as a desktop application (Linux systems).
	 * @param	string	$user	the requesting user
	 * @param	string	$movie	the movie id
     * @param	string	$os    the desktop system
     * @param	string	$window    the window mode
     * @param	int   $width  window original width
     * @param	int   $height window original height
	 * @return	string|bool the path to the exported file or false on error
	 *
	public function exportDeskLinux($user, $movie, $os, $window, $width, $height) {
		// check user: movie owner?
		if (!is_null($this->db)) {
			$ck = $this->queryAll('SELECT * FROM movies WHERE mv_id=:id AND mv_user=:user', [
				':id' => $movie, 
				':user' => $user, 
			]);
			if (count($ck) > 0) {
                if (is_dir('../movie/'.$movie.'.movie') && is_file('../../export/desktop/'.$os.'.zip')) {
                    set_time_limit(0);
                    $appfolder = $movie;
                    $this->removeFileDir('../../export/'.$os.'-'.$movie.'.zip');
                    $this->removeFileDir('../../export/'.$os.'-'.$movie);
                    $this->createDir('../../export/'.$os.'-'.$movie);
                    $this->createDir('../../export/'.$os.'-'.$movie);
                    @copy(('../../export/desktop/'.$os.'.zip'), ('../../export/'.$os.'-'.$movie.'.zip'));
                    $this->copyDir('../../export/site', ('../../export/'.$os.'-'.$movie));
                    if (is_dir('../../export/'.$os.'-'.$movie)) {
                        if ($this->loadMovie($movie)) {
                            set_time_limit(0);
                            
                            // re-publish scenes?
                            $pub = false;
                            if (($ck[0]['mv_identify'] == '1') || (!is_null($ck[0]['mv_vsgroups']) && ($ck[0]['mv_vsgroups'] != ''))) {
                                $pub = true;
                                $this->publishScenes($movie);
                            }
                            
                            // fonts
                            $fonts = [ ];
                            $ck = $this->queryAll('SELECT * FROM fonts');
                            foreach ($ck as $v) {
                                $fonts[] = '@font-face { font-family: "' . $v['fn_name'] . '"; src: url("./assets/' . $v['fn_file'] . '"); }';
                                @copy(('../font/' . $v['fn_file']), ('../../export/'.$os.'-'.$movie.'/assets/' . $v['fn_file']));
                            }
                            $ck = $this->queryAll('SELECT mv_fonts FROM movies WHERE mv_id=:id', [':id' => $movie]);
                            if (count($ck) > 0) {
                                if ($ck[0]['mv_fonts'] != '') {
                                    $json = json_decode(gzdecode(base64_decode($ck[0]['mv_fonts'])), true);
                                    if (json_last_error() == JSON_ERROR_NONE) {
                                        foreach ($json as $k => $v) {
                                            if (isset($v['name']) && isset($v['file'])) {
                                                $fonts[] = '@font-face { font-family: "' . $v['name'] . '"; src: url("./assets/' . $v['file'] . '"); }';
                                                @copy(('../movie/'.$movie.'.movie/media/font/' . $v['file']), ('../../export/'.$os.'-'.$movie.'/assets/' . $v['file']));
                                            }
                                        }
                                    }
                                }
                            }
                            // plugins
                            $plhead = [ ];
                            $plend = [ ];
                            $ck = $this->queryAll('SELECT pc_id, pc_file FROM pluginconfig WHERE pc_active=:ac AND pc_index=:in', [
                                ':ac' => '1', 
                                ':in' => '1', 
                            ]);
                            foreach ($ck as $v) {
                                if (is_file('../../app/' . $v['pc_file'] . '.php')) {
                                    require_once('../../app/' . $v['pc_file'] . '.php');
                                    $pl = new $v['pc_file'];
                                    $plhead[] = $pl->indexHead();
                                    $plend[] = $pl->indexEndBody();
                                }
                            }
                            // index text
                            $index = file_get_contents('../../export/desktop/index.html');
                            // prepare values
                            $fonts = implode("\r\n", $fonts);
                            $plhead = implode("\r\n", $plhead); 
                            $plend = implode("\r\n", $plend); 
                            $image = $this->info['image'] == '' ? '' : '<meta property="og:image" content="./movie/'.$movie.'.movie/media/picture/'.$this->info['image'].'" />';
                            $color = str_replace('0x', '#', $this->info['screen']['bgcolor']);
                            $ws = '';
                            if ((strpos($this->conf['path'], 'localhost') === false) && (strpos($this->conf['path'], '127.0.0.1') === false)) {
                                $ws = $this->slashUrl($this->conf['path']) . 'ws/';
                            }
                            // index.html
                            $index = str_replace([
                                '[SITEMOVIE]', 
                                '[SITESCENE]', 
                                '[SITETITLE]', 
                                '[SITECOLOR]', 
                                '[SITEABOUT]', 
                                '[SITESHAREIMG]',
                                '[SITEFONTS]', 
                                '[SITEPLUGINHEAD]', 
                                '[SITEPLUGINEND]', 
                                '[SITEWS]'
                            ], [
                                $movie, 
                                '', 
                                $this->info['title'], 
                                $color, 
                                $this->info['description'], 
                                $image, 
                                $fonts, 
                                $plhead, 
                                $plend, 
                                $ws
                            ], $index);
                            file_put_contents('../../export/'.$os.'-'.$movie.'/index.html', $index);
                            // runtime
                            @copy('../../export/runtimes/desktop.js', ('../../export/'.$os.'-'.$movie.'/TilBuci.js'));
                            // favicon
                            if ($this->info['favicon'] != '') {
                                @unlink('../../export/'.$os.'-'.$movie.'/favicon.png');
                                @copy(('../movie/'.$movie.'.movie/media/picture/'.$this->info['favicon']), ('../../export/'.$os.'-'.$movie.'/favicon.png'));
                            }
                            // movie folder
                            $this->copyDir(('../movie/'.$movie.'.movie'), ('../../export/'.$os.'-'.$movie.'/movie/'.$movie.'.movie'));
                            $this->info['key'] = '';
                            $this->info['fallback'] = '';
                            $this->info['identify'] = false;
                            $this->info['vsgroups'] = '';
                            file_put_contents(('../../export/'.$os.'-'.$movie.'/movie/'.$movie.'.movie/movie.json'), json_encode($this->info));
                            // howler
                            @copy('../../export/desktop/howler.min.js', ('../../export/'.$os.'-'.$movie.'/howler.min.js'));
                            // package text
                            file_put_contents(('../../export/'.$os.'-'.$movie.'/package.json'), json_encode([
                                'name' => $this->info['title'], 
                                'version' => time(), 
                                'main' => 'index.html', 
                                'window' => [
                                    'id' => $movie, 
                                    'title' => $this->info['title'], 
                                    'icon' => 'favicon.png', 
                                    'width' => $width, 
                                    'height' => $height, 
                                    'position' => 'center', 
                                    'kiosk' => ($window == 'kiosk'), 
                                    'resizable' => ($window != 'resize'), 
                                    'fullscreen' => ($window == 'full'), 
                                ], 
                                'icons' => [
                                    '256' => 'favicon.png'
                                ]
                            ]));
                            // executable and readme
                            file_put_contents(('../../export/'.$os.'-'.$movie.'/readme'), "This is your Linux application folder. Just run execute './nw' file to open it (if fail, you may need to set run permissions to the file). You must distribute this entire folder.");

                            // save zip
                            $zip = new \ZipArchive;
                            $zip->open('../../export/'.$os.'-'.$movie.'.zip');
                            $files = new \RecursiveIteratorIterator(
                                new \RecursiveDirectoryIterator('../../export/'.$os.'-'.$movie),
                                \RecursiveIteratorIterator::LEAVES_ONLY
                            );
                            $rootPath = realpath('../../export/'.$os.'-'.$movie);
                            foreach ($files as $file) {
                                if (!$file->isDir()) {
                                    $filePath = $file->getRealPath();
                                    $relativePath = substr($filePath, strlen($rootPath) + 1);
                                    $relativePath = str_replace('\\', '/', $relativePath);
                                    $zip->addFile($filePath, $relativePath);
                                }
                            }
                            $zip->close();
                            $this->removeFileDir('../../export/'.$os.'-'.$movie);
                            
                            // remove scenes?
                            if ($pub) {
                                $this->removePublished($movie);
                            }
                            
                            return ($os.'-'.$movie.'.zip');
                        } else {
                            return (false);
                        }
                    } else {
                        return (false);
                    }                    
                } else {
                    return (false);
                }
			} else {
                // the current user isn't the movie owner
				return (false);
			}
		} else {
			return (false);
		}
	}
    
    /**
	 * Exports a movie as a desktop application.
	 * @param	string	$user	the requesting user
	 * @param	string	$movie	the movie id
     * @param	string	$os    the desktop system
     * @param	string	$window    the window mode
     * @param	int   $width  window original width
     * @param	int   $height window original height
	 * @return	string|bool the path to the exported file or false on error
	 *
	public function exportDesk($user, $movie, $os, $window, $width, $height) {
		// check user: movie owner?
		if (!is_null($this->db)) {
			$ck = $this->queryAll('SELECT * FROM movies WHERE mv_id=:id AND mv_user=:user', [
				':id' => $movie, 
				':user' => $user, 
			]);
			if (count($ck) > 0) {
                if (is_dir('../movie/'.$movie.'.movie') && is_file('../../export/desktop/'.$os.'.zip')) {
                    set_time_limit(0);
                    if ($os == 'windows') {
                        $appfolder = '/' . $movie;
                        $moviefolder = '';
                    } else {
                        $appfolder = '';
                        $moviefolder = '/nwjs.app/Contents/Resources/app.nw';
                    }
                    $this->removeFileDir('../../export/'.$os.'-'.$movie.'.zip');
                    $this->removeFileDir('../../export/'.$os.'-'.$movie);
                    $this->createDir('../../export/'.$os.'-'.$movie);
                    $this->createDir('../../export/'.$os.'-'.$movie.$appfolder);
                    $zipos = new \ZipArchive;
                    $res = $zipos->open('../../export/desktop/'.$os.'.zip');
                    if ($res === true) {
                        $zipos->extractTo('../../export/'.$os.'-'.$movie.$appfolder);
                        $zipos->close();
                    }
                    if ($moviefolder != '') $this->createDir('../../export/'.$os.'-'.$movie.$appfolder.$moviefolder);
                    $this->copyDir('../../export/site', ('../../export/'.$os.'-'.$movie.$appfolder.$moviefolder));
                    if (is_dir('../../export/'.$os.'-'.$movie.$appfolder.$moviefolder)) {
                        if ($this->loadMovie($movie)) {
                            set_time_limit(0);
                            
                            // re-publish scenes?
                            $pub = false;
                            if (($ck[0]['mv_identify'] == '1') || (!is_null($ck[0]['mv_vsgroups']) && ($ck[0]['mv_vsgroups'] != ''))) {
                                $pub = true;
                                $this->publishScenes($movie);
                            }
                            
                            // fonts
                            $fonts = [ ];
                            $ck = $this->queryAll('SELECT * FROM fonts');
                            foreach ($ck as $v) {
                                $fonts[] = '@font-face { font-family: "' . $v['fn_name'] . '"; src: url("./assets/' . $v['fn_file'] . '"); }';
                                @copy(('../font/' . $v['fn_file']), ('../../export/'.$os.'-'.$movie.$appfolder.$moviefolder.'/assets/' . $v['fn_file']));
                            }
                            $ck = $this->queryAll('SELECT mv_fonts FROM movies WHERE mv_id=:id', [':id' => $movie]);
                            if (count($ck) > 0) {
                                if ($ck[0]['mv_fonts'] != '') {
                                    $json = json_decode(gzdecode(base64_decode($ck[0]['mv_fonts'])), true);
                                    if (json_last_error() == JSON_ERROR_NONE) {
                                        foreach ($json as $k => $v) {
                                            if (isset($v['name']) && isset($v['file'])) {
                                                $fonts[] = '@font-face { font-family: "' . $v['name'] . '"; src: url("./assets/' . $v['file'] . '"); }';
                                                @copy(('../movie/'.$movie.'.movie/media/font/' . $v['file']), ('../../export/'.$os.'-'.$movie.$appfolder.$moviefolder.'/assets/' . $v['file']));
                                            }
                                        }
                                    }
                                }
                            }
                            // plugins
                            $plhead = [ ];
                            $plend = [ ];
                            $ck = $this->queryAll('SELECT pc_id, pc_file FROM pluginconfig WHERE pc_active=:ac AND pc_index=:in', [
                                ':ac' => '1', 
                                ':in' => '1', 
                            ]);
                            foreach ($ck as $v) {
                                if (is_file('../../app/' . $v['pc_file'] . '.php')) {
                                    require_once('../../app/' . $v['pc_file'] . '.php');
                                    $pl = new $v['pc_file'];
                                    $plhead[] = $pl->indexHead();
                                    $plend[] = $pl->indexEndBody();
                                }
                            }
                            // index text
                            $index = file_get_contents('../../export/desktop/index.html');
                            // prepare values
                            $fonts = implode("\r\n", $fonts);
                            $plhead = implode("\r\n", $plhead); 
                            $plend = implode("\r\n", $plend); 
                            $image = $this->info['image'] == '' ? '' : '<meta property="og:image" content="./movie/'.$movie.'.movie/media/picture/'.$this->info['image'].'" />';
                            $color = str_replace('0x', '#', $this->info['screen']['bgcolor']);
                            $ws = '';
                            if ((strpos($this->conf['path'], 'localhost') === false) && (strpos($this->conf['path'], '127.0.0.1') === false)) {
                                $ws = $this->slashUrl($this->conf['path']) . 'ws/';
                            }
                            // index.html
                            $index = str_replace([
                                '[SITEMOVIE]', 
                                '[SITESCENE]', 
                                '[SITETITLE]', 
                                '[SITECOLOR]', 
                                '[SITEABOUT]', 
                                '[SITESHAREIMG]',
                                '[SITEFONTS]', 
                                '[SITEPLUGINHEAD]', 
                                '[SITEPLUGINEND]', 
                                '[SITEWS]'
                            ], [
                                $movie, 
                                '', 
                                $this->info['title'], 
                                $color, 
                                $this->info['description'], 
                                $image, 
                                $fonts, 
                                $plhead, 
                                $plend, 
                                $ws
                            ], $index);
                            file_put_contents('../../export/'.$os.'-'.$movie.$appfolder.$moviefolder.'/index.html', $index);
                            // runtime
                            @copy('../../export/runtimes/desktop.js', ('../../export/'.$os.'-'.$movie.$appfolder.$moviefolder.'/TilBuci.js'));
                            // favicon
                            if ($this->info['favicon'] != '') {
                                @unlink('../../export/'.$os.'-'.$movie.$appfolder.$moviefolder.'/favicon.png');
                                @copy(('../movie/'.$movie.'.movie/media/picture/'.$this->info['favicon']), ('../../export/'.$os.'-'.$movie.$appfolder.$moviefolder.'/favicon.png'));
                            }
                            // movie folder
                            $this->copyDir(('../movie/'.$movie.'.movie'), ('../../export/'.$os.'-'.$movie.$appfolder.$moviefolder.'/movie/'.$movie.'.movie'));
                            $this->info['key'] = '';
                            $this->info['fallback'] = '';
                            $this->info['identify'] = false;
                            $this->info['vsgroups'] = '';
                            file_put_contents(('../../export/'.$os.'-'.$movie.$appfolder.$moviefolder.'/movie/'.$movie.'.movie/movie.json'), json_encode($this->info));
                            // howler
                            @copy('../../export/desktop/howler.min.js', ('../../export/'.$os.'-'.$movie.$appfolder.$moviefolder.'/howler.min.js'));
                            // package text
                            file_put_contents(('../../export/'.$os.'-'.$movie.$appfolder.$moviefolder.'/package.json'), json_encode([
                                'name' => $this->info['title'], 
                                'version' => time(), 
                                'main' => 'index.html', 
                                'window' => [
                                    'id' => $movie, 
                                    'title' => $this->info['title'], 
                                    'icon' => 'favicon.png', 
                                    'width' => $width, 
                                    'height' => $height, 
                                    'position' => 'center', 
                                    'kiosk' => ($window == 'kiosk'), 
                                    'resizable' => ($window != 'resize'), 
                                    'fullscreen' => ($window == 'full'), 
                                ], 
                                'icons' => [
                                    '256' => 'favicon.png'
                                ]
                            ]));
                            // executable and readme
                            if ($os == 'windows') {
                                @rename(('../../export/'.$os.'-'.$movie.$appfolder.$moviefolder.'/nw.exe'), ('../../export/'.$os.'-'.$movie.$appfolder.$moviefolder.'/'.$movie.'.exe'));
                                file_put_contents(('../../export/'.$os.'-'.$movie.'/readme.txt'), "The '$movie' folder contains your Windows application. Just run the '$movie.exe' file to open it. You must distribute the entire '$movie' folder.");
                            } else {
                                // mac
                                if (is_file(('../../export/'.$os.'-'.$movie.$appfolder.$moviefolder.'/favicon.png'))) {
                                    @copy(('../../export/'.$os.'-'.$movie.$appfolder.$moviefolder.'/favicon.png'), ('../../export/'.$os.'-'.$movie.$appfolder.'/nwjs.app/Contents/Resources/app.icns'));
                                    @copy(('../../export/'.$os.'-'.$movie.$appfolder.$moviefolder.'/favicon.png'), ('../../export/'.$os.'-'.$movie.$appfolder.'/nwjs.app/Contents/Resources/document.icns'));
                                }
                                file_put_contents(('../../export/'.$os.'-'.$movie.'/readme.txt'), "This is your macOS application. Just run 'nwjs' to open it. Some systems may require you to allow the execution of downloaded apps. Before distributing, you may change the app name from 'nwjs' to any other you want.");
                            }

                            // save zip
                            $zip = new \ZipArchive;
                            $zip->open('../../export/'.$os.'-'.$movie.'.zip', \ZipArchive::CREATE | \ZipArchive::OVERWRITE);
                            $files = new \RecursiveIteratorIterator(
                                new \RecursiveDirectoryIterator('../../export/'.$os.'-'.$movie),
                                \RecursiveIteratorIterator::LEAVES_ONLY
                            );
                            $rootPath = realpath('../../export/'.$os.'-'.$movie);
                            foreach ($files as $file) {
                                if (!$file->isDir()) {
                                    $filePath = $file->getRealPath();
                                    $relativePath = substr($filePath, strlen($rootPath) + 1);
                                    $relativePath = str_replace('\\', '/', $relativePath);
                                    $zip->addFile($filePath, $relativePath);
                                }
                            }
                            $zip->close();
                            $this->removeFileDir('../../export/'.$os.'-'.$movie);
                            
                            // remove scenes?
                            if ($pub) {
                                $this->removePublished($movie);
                            }
                            
                            return ($os.'-'.$movie.'.zip');
                        } else {
                            return (false);
                        }
                    } else {
                        return (false);
                    }                    
                } else {
                    return (false);
                }
			} else {
                // the current user isn't the movie owner
				return (false);
			}
		} else {
			return (false);
		}
	}
    /**/
    
    /**
	 * Exports a movie as a desktop application.
	 * @param	string	$user	the requesting user
	 * @param	string	$movie	the movie id
     * @param	string	$mode  export mode
     * @param	string	$window    the window mode
     * @param	int   $width  window original width
     * @param	int   $height window original height
     * @param	string	$favicon the app icon
     * @param	string	$author the app author
     * @param	string	$description the app description
     * @param	string	$title the app title
	 * @return	string|bool the path to the exported file or false on error
	 */
	public function exportDesk($user, $movie, $mode, $window, $width, $height, $favicon, $author, $description, $title) {
		// check user: movie owner?
		if (!is_null($this->db)) {
			$ck = $this->queryAll('SELECT * FROM movies WHERE mv_id=:id AND mv_user=:user', [
				':id' => $movie, 
				':user' => $user, 
			]);
			if (count($ck) > 0) {
                // prepare folders
                $this->removeFileDir('../../export/desktop-'.$movie.'.zip');
                $this->removeFileDir('../../export/desktop-'.$movie);
                $this->createDir('../../export/desktop-'.$movie);
                $this->createDir('../../export/desktop-'.$movie.'/'.$movie);
                $this->createDir('../../export/desktop-'.$movie.'/'.$movie.'/movie');
                
                // check movie
                if ($this->loadMovie($movie)) {
                    set_time_limit(0);
                    
                    // full app or update?
                    if ($mode == 'update') {
                        // readme
                        @copy('../../export/desktop/readmeupdate.txt', '../../export/desktop-'.$movie.'/readme.txt');
                    } else {
                        // readme
                        @copy('../../export/desktop/readmefull.txt', '../../export/desktop-'.$movie.'/readme.txt');

                        // package
                        $package = file_get_contents('../../export/desktop/package.json');
                        $package = str_replace([
                            '[TITLE]', 
                            '[AUTHOR]', 
                            '[DESCRIPTION]'
                        ], [
                            $title, 
                            $author, 
                            $description
                        ], $package);
                        file_put_contents('../../export/desktop-'.$movie.'/'.$movie.'/package.json', $package);
                    }

                    // howler audio fix
                    @copy('../../export/desktop/howler.min.js', '../../export/desktop-'.$movie.'/'.$movie.'/howler.min.js');
                    
                    // other assets
                    @copy('../../export/desktop/btclose.png', '../../export/desktop-'.$movie.'/'.$movie.'/btclose.png');
                    @copy('../../export/desktop/preload.js', '../../export/desktop-'.$movie.'/'.$movie.'/preload.js');
                    $this->copyDir(('../../export/desktop/assets'), ('../../export/desktop-'.$movie.'/'.$movie.'/assets'));
                    $this->copyDir(('../../export/desktop/lib'), ('../../export/desktop-'.$movie.'/'.$movie.'/lib'));
                    $this->copyDir(('../../export/desktop/manifest'), ('../../export/desktop-'.$movie.'/'.$movie.'/manifest'));

                    // main.js
                    $main = file_get_contents('../../export/desktop/main.js');
                    $main = str_replace([
                        '[WIDTH]', 
                        '[HEIGHT]', 
                        '[FULLSCREEN]', 
                        '[KIOSK]', 
                        '[RESIZE]'
                    ], [
                        $width, 
                        $height, 
                        ((($window == 'full') || ($window == 'kiosk')) ? 'fullscreen: true, ' : ''), 
                        (($window == 'kiosk') ? 'kiosk: true, ' : ''),
                        (($window == 'resize') ? 'win.resizable = false ' : ''),
                    ], $main);
                    file_put_contents('../../export/desktop-'.$movie.'/'.$movie.'/main.js', $main);
                            
                    // re-publish scenes?
                    $pub = false;
                    if (($ck[0]['mv_identify'] == '1') || (!is_null($ck[0]['mv_vsgroups']) && ($ck[0]['mv_vsgroups'] != ''))) {
                        $pub = true;
                        $this->publishScenes($movie);
                    }
                            
                    // fonts
                    $fonts = [ ];
                    $ckf = $this->queryAll('SELECT * FROM fonts');
                    foreach ($ckf as $v) {
                        $fonts[] = '@font-face { font-family: "' . $v['fn_name'] . '"; src: url("./assets/' . $v['fn_file'] . '"); }';
                        @copy(('../font/' . $v['fn_file']), ('../../export/desktop-'.$movie.'/'.$movie.'/assets/' . $v['fn_file']));
                    }
                    $ckf = $this->queryAll('SELECT mv_fonts FROM movies WHERE mv_id=:id', [':id' => $movie]);
                    if (count($ckf) > 0) {
                        if ($ckf[0]['mv_fonts'] != '') {
                            $json = json_decode(gzdecode(base64_decode($ckf[0]['mv_fonts'])), true);
                            if (json_last_error() == JSON_ERROR_NONE) {
                                foreach ($json as $k => $v) {
                                    if (isset($v['name']) && isset($v['file'])) {
                                        $fonts[] = '@font-face { font-family: "' . $v['name'] . '"; src: url("./assets/' . $v['file'] . '"); }';
                                        @copy(('../movie/'.$movie.'.movie/media/font/' . $v['file']), ('../../export/desktop-'.$movie.'/'.$movie.'/assets/' . $v['file']));
                                    }
                                }
                            }
                        }
                    }
                    
                    // plugins
                    $plhead = [ ];
                    $plend = [ ];
                    $ckp = $this->queryAll('SELECT pc_id, pc_file FROM pluginconfig WHERE pc_active=:ac AND pc_index=:in', [
                        ':ac' => '1', 
                        ':in' => '1', 
                    ]);
                    foreach ($ckp as $v) {
                        if (is_file('../../app/' . $v['pc_file'] . '.php')) {
                            require_once('../../app/' . $v['pc_file'] . '.php');
                            $pl = new $v['pc_file'];
                            $plhead[] = $pl->indexHead();
                            $plend[] = $pl->indexEndBody();
                        }
                    }
                    
                    // index text
                    $index = file_get_contents('../../export/desktop/index.html');
                    // prepare values
                    $fonts = implode("\r\n", $fonts);
                    $plhead = implode("\r\n", $plhead); 
                    $plend = implode("\r\n", $plend); 
                    $image = $this->info['image'] == '' ? '' : '<meta property="og:image" content="./movie/'.$movie.'.movie/media/picture/'.$this->info['image'].'" />';
                    $color = str_replace('0x', '#', $this->info['screen']['bgcolor']);
                    $ws = '';
                    if ((strpos($this->conf['path'], 'localhost') === false) && (strpos($this->conf['path'], '127.0.0.1') === false)) {
                        $ws = $this->slashUrl($this->conf['path']) . 'ws/';
                    }
                    
                    // index.html
                    $index = str_replace([
                        '[SITEMOVIE]', 
                        '[SITESCENE]', 
                        '[SITETITLE]', 
                        '[SITECOLOR]', 
                        '[SITEABOUT]', 
                        '[SITESHAREIMG]',
                        '[SITEFONTS]', 
                        '[SITEPLUGINHEAD]', 
                        '[SITEPLUGINEND]', 
                        '[SITEWS]'
                    ], [
                        $movie, 
                        '', 
                        $this->info['title'], 
                        $color, 
                        $this->info['description'], 
                        $image, 
                        $fonts, 
                        $plhead, 
                        $plend, 
                        $ws
                    ], $index);
                    file_put_contents('../../export/desktop-'.$movie.'/'.$movie.'/index.html', $index);
                    
                    // runtime
                    @copy('../../export/runtimes/desktop.js', ('../../export/desktop-'.$movie.'/'.$movie.'/TilBuci.js'));
                            
                    // favicon
                    if ($this->info['favicon'] != '') {
                        @unlink('../../export/desktop-'.$movie.'/'.$movie.'/favicon.png');
                        @copy(('../movie/'.$movie.'.movie/media/picture/'.$this->info['favicon']), ('../../export/desktop-'.$movie.'/'.$movie.'/favicon.png'));
                    }
                    
                    // movie folder
                    $this->copyDir(('../movie/'.$movie.'.movie'), ('../../export/desktop-'.$movie.'/'.$movie.'/movie/'.$movie.'.movie'));
                    $this->info['key'] = '';
                    $this->info['fallback'] = '';
                    $this->info['identify'] = false;
                    $this->info['vsgroups'] = '';
                    file_put_contents(('../../export/desktop-'.$movie.'/'.$movie.'/movie/'.$movie.'.movie/movie.json'), json_encode($this->info));
                            
                    // save zip
                    $zip = new \ZipArchive;
                    $zip->open('../../export/desktop-'.$movie.'.zip', \ZipArchive::CREATE | \ZipArchive::OVERWRITE);
                    $files = new \RecursiveIteratorIterator(
                        new \RecursiveDirectoryIterator('../../export/desktop-'.$movie),
                        \RecursiveIteratorIterator::LEAVES_ONLY
                    );
                    $rootPath = realpath('../../export/desktop-'.$movie);
                    foreach ($files as $file) {
                        if (!$file->isDir()) {
                            $filePath = $file->getRealPath();
                            $relativePath = substr($filePath, strlen($rootPath) + 1);
                            $relativePath = str_replace('\\', '/', $relativePath);
                            $zip->addFile($filePath, $relativePath);
                        }
                    }
                    $zip->close();
                    $this->removeFileDir('../../export/desktop-'.$movie);
                            
                    // remove scenes?
                    if ($pub) {
                        $this->removePublished($movie);
                    }
                            
                    return ('desktop-'.$movie.'.zip');
                } else {
                    return (false);
                }
			} else {
                // the current user isn't the movie owner
				return (false);
			}
		} else {
			return (false);
		}
	}
    
    /**
	 * Exports a movie as an Apache Cordova project.
	 * @param	string	$user	the requesting user
	 * @param	string	$movie	the movie id
     * @param	string	$mode  exporte mode (complete or update)
     * @param	string	$appid application id
     * @param	string	$appsite   app reference site
     * @param	string	$appauthor content author name
     * @param	string	$appemail  author e-mail
     * @param	string	$applicense    app distribution license name
     * @param	string	$fullscr    run app in fullcrssen? "true" or "false"
     * @param	string	$icon    app icon file
	 * @return	string|bool the path to the exported file or false on error
	 */
	public function exportCordova($user, $movie, $mode, $appid, $appsite, $appauthor, $appemail, $applicense, $fullscr, $icon) {
		// check user: movie owner?
		if (!is_null($this->db)) {
			$ck = $this->queryAll('SELECT * FROM movies WHERE mv_id=:id AND mv_user=:user', [
				':id' => $movie, 
				':user' => $user, 
			]);
			if (count($ck) > 0) {
                if (is_dir('../movie/'.$movie.'.movie')) {
                    set_time_limit(0);
                    $this->removeFileDir('../../export/mobile-'.$movie.'.zip');
                    $this->removeFileDir('../../export/mobile-'.$movie);
                    $this->createDir('../../export/mobile-'.$movie.'/'.$movie);
                    if ($mode == 'update') {
                        $this->createDir('../../export/mobile-'.$movie.'/'.$movie.'/www', true);
                    } else {
                        $zipor = new \ZipArchive;
                        $res = $zipor->open('../../export/cordova/cordova.zip');
                        if ($res === true) {
                            $zipor->extractTo('../../export/mobile-'.$movie.'/'.$movie);
                            $zipor->close();
                        }
                    }
                    $this->copyDir('../../export/site', ('../../export/mobile-'.$movie.'/'.$movie.'/www'));
                    if (is_dir('../../export/mobile-'.$movie.'/'.$movie.'/www')) {
                        if ($this->loadMovie($movie)) {
                            set_time_limit(0);
                            
                            // re-publish scenes?
                            $pub = false;
                            if (($ck[0]['mv_identify'] == '1') || (!is_null($ck[0]['mv_vsgroups']) && ($ck[0]['mv_vsgroups'] != ''))) {
                                $pub = true;
                                $this->publishScenes($movie);
                            }
                            
                            // fonts
                            $fonts = [ ];
                            $ck = $this->queryAll('SELECT * FROM fonts');
                            foreach ($ck as $v) {
                                $fonts[] = '@font-face { font-family: "' . $v['fn_name'] . '"; src: url("./assets/' . $v['fn_file'] . '"); }';
                                @copy(('../font/' . $v['fn_file']), ('../../export/mobile-'.$movie.'/'.$movie.'/www/assets/' . $v['fn_file']));
                            }
                            $ck = $this->queryAll('SELECT mv_fonts FROM movies WHERE mv_id=:id', [':id' => $movie]);
                            if (count($ck) > 0) {
                                if ($ck[0]['mv_fonts'] != '') {
                                    $json = json_decode(gzdecode(base64_decode($ck[0]['mv_fonts'])), true);
                                    if (json_last_error() == JSON_ERROR_NONE) {
                                        foreach ($json as $k => $v) {
                                            if (isset($v['name']) && isset($v['file'])) {
                                                $fonts[] = '@font-face { font-family: "' . $v['name'] . '"; src: url("./assets/' . $v['file'] . '"); }';
                                                @copy(('../movie/'.$movie.'.movie/media/font/' . $v['file']), ('../../export/mobile-'.$movie.'/'.$movie.'/www/assets/' . $v['file']));
                                            }
                                        }
                                    }
                                }
                            }
                            // plugins
                            $plhead = [ ];
                            $plend = [ ];
                            $ck = $this->queryAll('SELECT pc_id, pc_file FROM pluginconfig WHERE pc_active=:ac AND pc_index=:in', [
                                ':ac' => '1', 
                                ':in' => '1', 
                            ]);
                            foreach ($ck as $v) {
                                if (is_file('../../app/' . $v['pc_file'] . '.php')) {
                                    require_once('../../app/' . $v['pc_file'] . '.php');
                                    $pl = new $v['pc_file'];
                                    $plhead[] = $pl->indexHead();
                                    $plend[] = $pl->indexEndBody();
                                }
                            }
                            // index text
                            $index = file_get_contents('../../export/cordova/index.html');
                            // prepare values
                            $fonts = implode("\r\n", $fonts);
                            $plhead = implode("\r\n", $plhead); 
                            $plend = implode("\r\n", $plend); 
                            $image = $this->info['image'] == '' ? '' : '<meta property="og:image" content="./movie/'.$movie.'.movie/media/picture/'.$this->info['image'].'" />';
                            $color = str_replace('0x', '#', $this->info['screen']['bgcolor']);
                            $ws = '';
                            if ((strpos($this->conf['path'], 'localhost') === false) && (strpos($this->conf['path'], '127.0.0.1') === false)) {
                                $ws = $this->slashUrl($this->conf['path']) . 'ws/';
                            }
                            // index.html
                            $index = str_replace([
                                '[SITEMOVIE]', 
                                '[SITESCENE]', 
                                '[SITETITLE]', 
                                '[SITECOLOR]', 
                                '[SITEABOUT]', 
                                '[SITESHAREIMG]',
                                '[SITEFONTS]', 
                                '[SITEPLUGINHEAD]', 
                                '[SITEPLUGINEND]', 
                                '[SITEWS]'
                            ], [
                                $movie, 
                                '', 
                                $this->info['title'], 
                                $color, 
                                $this->info['description'], 
                                $image, 
                                $fonts, 
                                $plhead, 
                                $plend, 
                                $ws
                            ], $index);
                            file_put_contents('../../export/mobile-'.$movie.'/'.$movie.'/www/index.html', $index);
                            // runtime
                            @copy('../../export/runtimes/mobile.js', ('../../export/mobile-'.$movie.'/'.$movie.'/www/TilBuci.js'));
                            // favicon
                            if ($this->info['favicon'] != '') {
                                @unlink('../../export/mobile-'.$movie.'/'.$movie.'/www/favicon.png');
                                @copy(('../movie/'.$movie.'.movie/media/picture/'.$this->info['favicon']), ('../../export/mobile-'.$movie.'/'.$movie.'/www/favicon.png'));
                            }
                            // movie folder
                            $this->copyDir(('../movie/'.$movie.'.movie'), ('../../export/mobile-'.$movie.'/'.$movie.'/www/movie/'.$movie.'.movie'));
                            $this->info['key'] = '';
                            $this->info['fallback'] = '';
                            $this->info['identify'] = false;
                            $this->info['vsgroups'] = '';
                            file_put_contents(('../../export/mobile-'.$movie.'/'.$movie.'/www/movie/'.$movie.'.movie/movie.json'), json_encode($this->info));
                            // icon
                            if ($icon != '') {
                                if (is_file('../../export/mobile-'.$movie.'/'.$movie.'/www/movie/'.$movie.'.movie/media/picture/'.$icon)) {
                                    $this->createDir('../../export/mobile-'.$movie.'/'.$movie.'/res/');
                                    if (!copy(('../../export/mobile-'.$movie.'/'.$movie.'/www/movie/'.$movie.'.movie/media/picture/'.$icon), ('../../export/mobile-'.$movie.'/'.$movie.'/res/icon.png'))) {
                                        $icon = '';
                                    }
                                } else {
                                    $icon = '';
                                }
                            }
                            // readme and config files
                            if ($mode == 'update') {
                                @copy('../../export/cordova/readme-update.txt', ('../../export/mobile-'.$movie.'/readme.txt'));
                            } else {
                                $txt = file_get_contents('../../export/cordova/readme.html');
                                $txt = str_replace('[APPID]', $movie, $txt);
                                file_put_contents(('../../export/mobile-'.$movie.'/readme.html'), $txt);
                                $txt = file_get_contents('../../export/mobile-'.$movie.'/'.$movie.'/config.xml');
                                $txt = str_replace([
                                    '[APPDOMAIN]', 
                                    '[APPVERSION]', 
                                    '[APPTITLE]', 
                                    '[APPABOUT]', 
                                    '[APPEMAIL]', 
                                    '[APPSITE]', 
                                    '[APPAUTHOR]', 
                                    '[APPFULLSCR]', 
                                    '[APPICON]'
                                ], [
                                    $appid, 
                                    '1.0.0', 
                                    $this->info['title'], 
                                    $this->info['description'], 
                                    $appemail, 
                                    $appsite, 
                                    $appauthor, 
                                    (($fullscr == 'true') ? '<preference name="Fullscreen" value="true" />' : ''), 
                                    (($icon == '') ? '' : '<icon src="res/icon.png" />'), 
                                ], $txt);
                                file_put_contents(('../../export/mobile-'.$movie.'/'.$movie.'/config.xml'), $txt);
                                $txt = file_get_contents('../../export/mobile-'.$movie.'/'.$movie.'/package.json');
                                $txt = str_replace([
                                    '[APPDOMAIN]', 
                                    '[APPVERSION]', 
                                    '[APPTITLE]', 
                                    '[APPABOUT]', 
                                    '[APPEMAIL]', 
                                    '[APPSITE]', 
                                    '[APPAUTHOR]', 
                                    '[APPLICENSE]'
                                ], [
                                    $appid, 
                                    '1.0.0', 
                                    $this->info['title'], 
                                    $this->info['description'], 
                                    $appemail, 
                                    $appsite, 
                                    $appauthor, 
                                    $applicense
                                ], $txt);
                                file_put_contents(('../../export/mobile-'.$movie.'/'.$movie.'/package.json'), $txt);
                                $txt = file_get_contents('../../export/mobile-'.$movie.'/'.$movie.'/package-lock.json');
                                $txt = str_replace([
                                    '[APPDOMAIN]', 
                                    '[APPVERSION]', 
                                    '[APPTITLE]', 
                                    '[APPABOUT]', 
                                    '[APPEMAIL]', 
                                    '[APPSITE]', 
                                    '[APPAUTHOR]', 
                                    '[APPLICENSE]'
                                ], [
                                    $appid, 
                                    '1.0.0', 
                                    $this->info['title'], 
                                    $this->info['description'], 
                                    $appemail, 
                                    $appsite, 
                                    $appauthor, 
                                    $applicense
                                ], $txt);
                                file_put_contents(('../../export/mobile-'.$movie.'/'.$movie.'/package-lock.json'), $txt);
                            }
                        
                            // save zip
                            $zip = new \ZipArchive;
                            $zip->open('../../export/mobile-'.$movie.'.zip', \ZipArchive::CREATE | \ZipArchive::OVERWRITE);
                            $files = new \RecursiveIteratorIterator(
                                new \RecursiveDirectoryIterator('../../export/mobile-'.$movie),
                                \RecursiveIteratorIterator::LEAVES_ONLY
                            );
                            $rootPath = realpath('../../export/mobile-'.$movie);
                            foreach ($files as $file) {
                                if (!$file->isDir()) {
                                    $filePath = $file->getRealPath();
                                    $relativePath = substr($filePath, strlen($rootPath) + 1);
                                    $relativePath = str_replace('\\', '/', $relativePath);
                                    $zip->addFile($filePath, $relativePath);
                                }
                            }
                            $zip->close();
                            $this->removeFileDir('../../export/mobile-'.$movie);
                            
                            // remove scenes?
                            if ($pub) {
                                $this->removePublished($movie);
                            }
                            
                            return ('mobile-'.$movie.'.zip');
                        } else {
                            return (false);
                        }
                    } else {
                        return (false);
                    }                    
                } else {
                    return (false);
                }
			} else {
                // the current user isn't the movie owner
				return (false);
			}
		} else {
			return (false);
		}
	}
    
    /**
     * Gets a list of available movies for action blocks.
     * @param   string  $user   current user
     * @return  array   the available movies list
     */
    public function listAcMovies($user) {
        $list = [ ];
        $ck = $this->queryAll('SELECT mv_id, mv_title FROM movies WHERE mv_user=:us OR mv_collaborators LIKE :col ORDER BY mv_title ASC', [
            ':us' => $user, 
            ':col' => '%' . $user . '%', 
        ]);
        foreach ($ck as $v) $list[] = [
            'id' => $v['mv_id'], 
            'title' => $v['mv_title'], 
        ];
        return ($list);
    }
    
    /**
     * Gets a list of available movies for action blocks.
     * @param   string  $user   current user
     * @return  array   the available movies list
     */
    public function listAcScenes($movie) {
        $list = [ ];
        $ck = $this->queryAll('SELECT sc_id, sc_title FROM scenes WHERE sc_movie=:mv AND sc_published=:pub ORDER BY sc_title ASC', [
            ':mv' => $movie, 
            ':pub' => '1', 
        ]);
        foreach ($ck as $v) $list[] = [
            'id' => $v['sc_id'], 
            'title' => $v['sc_title'], 
        ];
        return ($list);
    }
    
    /**
     * Creates a navigation sequence on a movie.
     * @param   string  $id the movie ID
     * @param   string  $seq    a sequence of scene ids separated by ;
     * @param   string  $con    connecte first and last scenes? "true" or "false"
     * @param   string  $axis   the sequence direction: x, y or z
     */
    public function createNavigation($id, $seq, $con, $axis) {
        $seq = explode(';', $seq);
        if (count($seq) > 1) {
            $con = $con == 'true';
            switch (mb_strtolower($axis)) {
                case 'y': $axis = 'y'; break;
                case 'z': $axis = 'z'; break;
                default: $axis = 'x'; break;
            }
            $sc = new Scene;
            for ($i=0; $i<count($seq); $i++) {
                if ($sc->loadScene(null, $id, $seq[$i])) {
                    // first scene
                    if ($i == 0) {
                        if ($con) {
                            switch ($axis) {
                                case 'x':
                                    $sc->info['navigation']['left'] = $seq[count($seq)-1]; 
                                    break;
                                case 'y':
                                    $sc->info['navigation']['up'] = $seq[count($seq)-1]; 
                                    break;
                                case 'z':
                                    $sc->info['navigation']['nout'] = $seq[count($seq)-1]; 
                                    break;
                            }
                        } else {
                            switch ($axis) {
                                case 'x':
                                    $sc->info['navigation']['left'] = ''; 
                                    break;
                                case 'y':
                                    $sc->info['navigation']['up'] = ''; 
                                    break;
                                case 'z':
                                    $sc->info['navigation']['nout'] = ''; 
                                    break;
                            }
                        }
                        switch ($axis) {
                            case 'x': 
                                $sc->info['navigation']['right'] = $seq[$i+1]; 
                                break;
                            case 'y': 
                                $sc->info['navigation']['down'] = $seq[$i+1]; 
                                break;
                            case 'z': 
                                $sc->info['navigation']['nin'] = $seq[$i+1]; 
                                break;
                        }
                    } else if ($i == (count($seq)-1)) {
                        switch ($axis) {
                            case 'x': 
                                $sc->info['navigation']['left'] = $seq[$i-1];
                                break;
                            case 'y': 
                                $sc->info['navigation']['up'] = $seq[$i-1];
                                break;
                            case 'z': 
                                $sc->info['navigation']['nout'] = $seq[$i-1];
                                break;
                        }
                        if ($con) {
                            switch ($axis) {
                                case 'x': 
                                    $sc->info['navigation']['right'] = $seq[0]; 
                                    break;
                                case 'y': 
                                    $sc->info['navigation']['down'] = $seq[0]; 
                                    break;
                                case 'z': 
                                    $sc->info['navigation']['nin'] = $seq[0]; 
                                    break;
                            }
                        } else {
                            switch ($axis) {
                                case 'x': 
                                    $sc->info['navigation']['right'] = ''; 
                                    break;
                                case 'y': 
                                    $sc->info['navigation']['down'] = ''; 
                                    break;
                                case 'z': 
                                    $sc->info['navigation']['nin'] = ''; 
                                    break;
                            }
                        }
                    } else {
                        switch ($axis) {
                            case 'x': 
                                $sc->info['navigation']['left'] = $seq[$i-1];
                                $sc->info['navigation']['right'] = $seq[$i+1]; 
                                break;
                            case 'y': 
                                $sc->info['navigation']['up'] = $seq[$i-1];
                                $sc->info['navigation']['down'] = $seq[$i+1]; 
                                break;
                            case 'z': 
                                $sc->info['navigation']['nout'] = $seq[$i-1];
                                $sc->info['navigation']['nin'] = $seq[$i+1]; 
                                break;
                        }
                    }
                    $sc->saveSequence();
                }
            }
        }
    }
    
    /**
     * Gets the design notes.
     * @param   string  $user   the request user
     * @param   string  $mv the movie ID
     * @param   string  $sc the scene ID
     * @return  array|bool  the notes found or false on error
     */
    public function getNotes($user, $mv, $sc) {
        // does the movie exist?
        $ck = $this->queryAll('SELECT mv_id FROM movies WHERE mv_id=:id', [':id'=>$mv]);
        if (count($ck) > 0) {
            $ret = [
                'guidelines' => [ ], 
                'movie' => [ ], 
                'scene' => [ ], 
                'own' => [ ], 
            ];
            $ck = $this->queryAll('SELECT * FROM notes WHERE nt_movie=:mv AND nt_scene=:sc ORDER BY nt_time DESC', [':mv'=>$mv, ':sc'=>'']);
            foreach ($ck as $v) {
                if ($v['nt_type'] == 'guide') {
                    $ret['guidelines'][] = [
                        'id' => $v['nt_id'], 
                        'text' => gzdecode(base64_decode($v['nt_text'])),
                        'author' => $v['nt_author'], 
                        'time' => $v['nt_time'], 
                    ];
                } else {
                    $ret['movie'][] = [
                        'id' => $v['nt_id'], 
                        'text' => gzdecode(base64_decode($v['nt_text'])),
                        'author' => $v['nt_author'], 
                        'time' => $v['nt_time'], 
                    ];
                }
            }
            $ck = $this->queryAll('SELECT * FROM notes WHERE nt_movie=:mv AND nt_scene=:sc AND nt_type=:tp ORDER BY nt_time DESC', [':mv'=>$mv, ':sc'=>$sc, ':tp' => 'scene']);
            foreach ($ck as $v) {
                $ret['scene'][] = [
                    'id' => $v['nt_id'], 
                    'text' => gzdecode(base64_decode($v['nt_text'])),
                    'author' => $v['nt_author'], 
                    'time' => $v['nt_time'], 
                ];
            }
            $ck = $this->queryAll('SELECT * FROM notes WHERE nt_type=:tp AND nt_author=:user ORDER BY nt_time DESC', [':tp'=>'own', ':user' => $user]);
            foreach ($ck as $v) {
                $ret['own'][] = [
                    'id' => $v['nt_id'], 
                    'text' => gzdecode(base64_decode($v['nt_text'])),
                    'author' => $v['nt_author'], 
                    'time' => $v['nt_time'], 
                ];
            }
            return ($ret);
        } else {
            // movie not found
            return (false);
        }
    }
    
    /**
     * Saves a design note.
     * @param   string  $user   the request user
     * @param   string  $movie  the movie ID
     * @param   string  $type   the note type
     * @param   string  $text   the note text
     * @return  array|bool  the updated notes list or false on error
     */
    public function saveNote($user, $movie, $scene, $type, $text) {
        // getting movie information
        $ck = $this->queryAll('SELECT mv_user, mv_collaborators FROM movies WHERE mv_id=:mv', [':mv'=>$movie]);
        if (count($ck) == 0) {
            // no movie found
            return (false);
        } else {
            // check authorization
            $authorized = $ck[0]['mv_collaborators'] == '' ? [ ] : explode(',', $ck[0]['mv_collaborators']);
            $authorized[] = $ck[0]['mv_user'];
            if (($type == 'guide') && ($ck[0]['mv_user'] != $user)) {
                return (false);
            } else if (($type != 'own') && !in_array($user, $authorized)) {
                return (false);
            } else {
                $mv = ($type == 'own') ? '' : $movie;
                $sc = ($type == 'scene') ? $scene : '';
                $this->execute('INSERT INTO notes (nt_movie, nt_scene, nt_type, nt_text, nt_author) VALUES (:mv, :sc, :tp, :tx, :au)', [
                    ':mv' => $mv, 
                    ':sc' => $sc, 
                    ':tp' => $type, 
                    ':tx' => base64_encode(gzencode($text)), 
                    ':au' => $user, 
                ]);
                if ($type == 'own') {
                    $ck = $this->queryAll('SELECT nt_id FROM notes WHERE nt_author=:user AND nt_type=:own ORDER BY nt_time DESC LIMIT 5 OFFSET 5', [
						':user' => $user, 
                        ':own' => 'own', 
					]);
                } else {
                    $ck = $this->queryAll('SELECT nt_id FROM notes WHERE nt_movie=:mv AND nt_scene=:sc AND nt_type=:tp ORDER BY nt_time DESC LIMIT 5 OFFSET 5', [
						':mv' => $mv, 
						':sc' => $sc, 
                        ':tp' => $type, 
					]);
                }
                if (count($ck) > 0) {
                    foreach ($ck as $vn) $this->execute('DELETE FROM notes WHERE nt_id=:id LIMIT 1', [':id'=>$vn['nt_id']]);
                }
                return ($this->getNotes($user, $movie, $scene));
            }
        }
    }
    
    /**
     * Unlocks all movie scenes.
     * @param   string  $user   request user
     * @param   string  $movie  the movie id
     * @return  bool    were the scenes unlocked?
     */
    public function unlockScenes($user, $movie) {
        $ck = $this->queryAll('SELECT mv_id FROM movies WHERE mv_id=:id AND mv_user=:user', [
            ':id' => $movie, 
            ':user' => $user, 
        ]);
        if (count($ck) > 0) {
            $this->execute('DELETE FROM scenelock WHERE sl_movie=:id', [':id'=>$movie]);
            return (true);
        } else {
            return (false);
        }
    }
    
    /**
     * Saves the movie contraption settings
     * @param   string  $user   request user
     * @param   string  $movie  the movie id
     * @param   string  $data   the json contraptions data
     * @return  int error code
     * 0 => contraptions saved
     * 1 => not enough permissions
     * 2 => corrupted contraption data
     */
    public function saveContraptions($user, $movie, $data) {
        $ck = $this->queryAll('SELECT mv_id FROM movies WHERE mv_id=:id AND (mv_user=:user OR mv_collaborators LIKE :col)', [
            ':id' => $movie, 
            ':user' => $user, 
            ':col' => '%' . trim($user) . '%', 
        ]);
        if (count($ck) > 0) {
            $json = json_decode($data);
            if (json_last_error() != JSON_ERROR_NONE) {
                return (2);
            } else {
                $this->execute('UPDATE movies SET mv_contraptions=:cont WHERE mv_id=:id', [
                    ':cont' => base64_encode(gzencode($data)), 
                    ':id' => $movie, 
                ]);
                file_put_contents('../movie/'.$movie.'.movie/contraptions.json', $data);
                return (0);
            }
        } else {
            return (1);
        }
    }
    
    /**
     * Re-published all movie files.
     * @param   string  $user   request user
     * @param   string  $movie  the movie id
     * @param   string  $newest   use the newest scene versions?
     * @return  int error code
     * 0 => movie re-published
     * 1 => not enough permissions
     * 2 => movie not found
     */
    public function republish($user, $movie, $newest, $decrypt = false) {
        $ck = $this->queryAll('SELECT mv_id FROM movies WHERE mv_id=:id AND (mv_user=:user OR mv_collaborators LIKE :col)', [
            ':id' => $movie, 
            ':user' => $user, 
            ':col' => '%' . trim($user) . '%', 
        ]);
        if (count($ck) > 0) {
            // load movie
            if ($this->loadMovie($movie)) {
                // movie descriptor
                $this->publish($decrypt);
                
                // scenes
                $sc = new Scene;
                $ck = $this->queryAll('SELECT sc_id FROM scenes WHERE sc_movie=:mv AND sc_published=:pub', [
                    ':mv' => $movie, 
                    ':pub' => '1', 
                ]);
                if (($newest === true) || ($newest == 'true') || ($newest == '1')) {
                    $version = null;
                } else {
                    $version = -1;
                }
                foreach ($ck as $v) {
                    if ($sc->loadScene(null, $movie, $v['sc_id'], $version)) {
                        $sc->publish($decrypt);
                    }
                }
                
                // collections
                $cl = new Collection;
                $ck = $this->queryAll('SELECT cl_uid FROM collections WHERE cl_movie=:mv', [
                    ':mv' => $movie, 
                ]);
                foreach ($ck as $v) {
                    if ($cl->loadCollection($v['cl_uid'])) {
                        $cl->publish($decrypt);
                    }
                }
                
                // other files
                $ck = $this->queryAll('SELECT mv_contraptions, mv_strings FROM movies WHERE mv_id=:mv', [':mv' => $movie]);
                $writeback = false;
                if (is_null($ck[0]['mv_strings']) || ($ck[0]['mv_strings'] == '')) {
                    $writeback = true;
                    if (is_file('../movie/'.$movie.'.movie/strings.json')) {
                        $txt = file_get_contents('../movie/'.$movie.'.movie/strings.json');
                    } else {
                        $txt = '{"default":{"sample":"sample text"}}';
                    }
                } else {
                    $txt = gzdecode(base64_decode($ck[0]['mv_strings']));
                }
                if ($this->info['encrypted'] && !$decrypt) {
                    file_put_contents(('../movie/'.$movie.'.movie/strings.json'), $this->encryptTBFile($this->info['id'], $txt));
                } else {
                    file_put_contents(('../movie/'.$movie.'.movie/strings.json'), $txt);
                }
                if ($writeback) $this->execute('UPDATE movies SET mv_strings=:st WHERE mv_id=:mv', [
                    ':st' => base64_encode(gzencode($txt)), 
                    ':mv' => $movie, 
                ]);
                $writeback = false;
                if (is_null($ck[0]['mv_contraptions']) || ($ck[0]['mv_contraptions'] == '')) {
                    $writeback = true;
                    if (is_file('../movie/'.$movie.'.movie/contraptions.json')) {
                        $txt = file_get_contents('../movie/'.$movie.'.movie/contraptions.json');
                    } else {
                        $txt = json_encode([]);
                    }
                } else {
                    $txt = gzdecode(base64_decode($ck[0]['mv_contraptions']));
                }
                if ($this->info['encrypted'] && !$decrypt) {
                    file_put_contents(('../movie/'.$movie.'.movie/contraptions.json'), $this->encryptTBFile($this->info['id'], $txt));
                } else {
                    file_put_contents(('../movie/'.$movie.'.movie/contraptions.json'), $txt);
                }
                if ($writeback) $this->execute('UPDATE movies SET mv_contraptions=:ct WHERE mv_id=:mv', [
                    ':ct' => base64_encode(gzencode($txt)), 
                    ':mv' => $movie, 
                ]);
                
                return (0);
            } else {
                return (2);
            }
        } else {
            return (1);
        }
    }
}