<?php

/** CLASS DEFINITIONS **/
require_once('BaseClass.php');
require_once('Collection.php');

/**
 * Scene information.
 */
class Scene extends BaseClass
{
	
	/**
	 * current scene information
	 */
	public $info = [ ];
	
	/**
	 * is there a loaded scene?
	 */
	public $loaded = false;
    
    /**
     * loaded scene unique id
     */
    public $uid = false;

	/**
	 * Constructor.
	 */
	public function __construct($id = null)
	{
		parent::__construct();
		if (!is_null($id)) {
			$this->loadScene($id);
		}
	}
	
	/**
	 * Creates a scene.
	 * @return string|bool the created scene ID or false on error
	 */
	public function createScene($id, $movie, $title, $user) {
		// checking id
		/*if ($id != '') {
			$id = substr($this->cleanString($id), 0, 32);
			$ck = $this->queryAll('SELECT sc_uid FROM scenes WHERE sc_id=:id AND sc_movie=:mv', [
				':id' => $id,
				':mv' => $movie, 
			]);
			if (count($ck) > 0) $id = '';
		}*/
		$id = '';
		
		// create id?
		if ($id == '') {
			$ckid = true;
			while ($ckid) {
				$id = md5(time() . rand(0, 9999));
				$ck = $this->queryAll('SELECT sc_uid FROM scenes WHERE sc_id=:id AND sc_movie=:mv', [
					':id' => $id, 
					':mv' => $movie, 
				]);
				if (count($ck) == 0) $ckid = false;
			}
		}
		
		// adding to database
		if ($this->execute('INSERT INTO scenes (sc_id, sc_movie, sc_title, sc_user, sc_published) VALUES (:id, :mv, :tt, :us, :pub)', [
			':id' => $id, 
			':mv' => $movie, 
			':tt' => $title, 
			':us' => $user, 
			':pub' => '1',
		])) {
			
			// creating an empty keyframe
			$uid = $this->insertID();
			$this->execute('INSERT INTO keyframes (kf_scene, kf_order) VALUES (:sc, :or)', [
				':sc' => $uid, 
				':or' => 0, 
			]);
			
			// publish original version
			if ($this->loadScene($movie, $id, -1)) {
				$this->publish();
				return ($id);	
			} else {
				// error publishing original version
				return (false);
			}
		} else {
			return (false);
		}
	}
	
	/**
	 * Loads a scene from its UID.
	 * @param	int	$id	the scene UID
	 * @param	string	$movie	the scene movie
	 * @return	bool	was the scene found and loaded?
	 */
	public function loadSceneUid($id, $movie) {
		$ck = $this->queryAll('SELECT sc_id FROM scenes WHERE sc_uid=:id AND sc_movie=:mv', [
			':id' => $id, 
			':mv' => $movie, 
		]);
		if (count($ck) == 0) {
			return (false);
		} else {
			return ($this->loadScene($movie, $ck[0]['sc_id'], $id));
		}
	}

	/**
	 * Loads a scene informarion.
	 * @param string $movie the movie id
	 * @param string $id the scene id
	 * @param int $version the scene version (null for latest, -1 for published, number for sc_uid)
	 * @return bool was the scene found and loaded?
	 */
	public function loadScene($movie, $id, $version = null) {
		$this->info = [ ];
		$this->loaded = false;
		if (is_null($version)) {
			$ck = $this->queryAll('SELECT * FROM scenes WHERE sc_id=:id AND sc_movie=:mv ORDER by sc_uid DESC LIMIT 1', [
				':id' => $id, 
				':mv' => $movie, 
			]);
		} else if ($version < 0) {
			$ck = $this->queryAll('SELECT * FROM scenes WHERE sc_id=:id AND sc_movie=:mv AND sc_published=:pub', [
				':id' => $id, 
				':mv' => $movie, 
				':pub' => '1', 
			]);
		} else {
			$ck = $this->queryAll('SELECT * FROM scenes WHERE sc_id=:id AND sc_movie=:mv AND sc_uid=:uid', [
				':id' => $id, 
				':mv' => $movie, 
				':uid' => $version, 
			]);
		}
		if (count($ck) > 0) {
			// basic scene information
			$ackeyframes = [ ];
			$ackftemp = explode(',', $ck[0]['sc_ackeyframes']);
			foreach ($ackftemp as $akf) {
				if ($akf == '') {
					$ackeyframes[] = '';
				} else {
					$ackeyframes[] = gzdecode(base64_decode($akf));
				}
			}
            $this->uid = $ck[0]['sc_uid'];
			$this->info = [
				'title' => $ck[0]['sc_title'], 
				'id' => $id, 
				'movie' => $movie, 
				'about' => $ck[0]['sc_about'], 
				'image' => $ck[0]['sc_image'], 
				'navigation' => [
					'up' => $ck[0]['sc_up'], 
					'down' => $ck[0]['sc_down'], 
					'left' => $ck[0]['sc_left'], 
					'right' => $ck[0]['sc_right'], 
					'nin' => $ck[0]['sc_nin'], 
					'nout' => $ck[0]['sc_nout'], 
				], 
				'collections' => explode(',', $ck[0]['sc_collections']), 
				'loop' => (int)$ck[0]['sc_loop'], 
				'acstart' => ($ck[0]['sc_acstart'] == '' ? '' : gzdecode(base64_decode($ck[0]['sc_acstart']))), 
				'ackeyframes' => $ackeyframes, 
				'keyframes' => [ ], 
			];
			
			// keyframes
			$ckk = $this->queryAll('SELECT * FROM keyframes WHERE kf_scene=:uid ORDER BY kf_order ASC', [
				':uid' => $ck[0]['sc_uid'], 
			]);
			foreach ($ckk as $vk) {
				$kf = [ ];
				$cki = $this->queryAll('SELECT * FROM instances WHERE in_keyframe=:kf ORDER BY in_name ASC', [
					':kf' => $vk['kf_id'], 
				]);
				foreach ($cki as $vi) {
					$kf[$vi['in_name']] = [
						'collection' => $vi['in_collection'], 
						'asset' => $vi['in_asset'], 
						'action' => ($vi['in_action'] == '' ? '' : gzdecode(base64_decode($vi['in_action']))), 
						'play' => $vi['in_play'] == '1', 
						'horizontal' => [
								'order' => 0, 
								'x' => 0, 
								'y' => 0, 
								'alpha' => 0, 
								'width' => 32, 
								'height' => 32, 
								'rotation' => 0, 
								'visible' => false, 
								'color' => '0xFFFFFF', 
								'colorAlpha' => 0, 
								'volume' => 0, 
								'pan' => 0, 
								'blur' => '', 
								'dropshadow' => '', 
								'textFont' => '', 
								'textSize' => 12, 
								'textColor' => '0xFFFFFF', 
								'textBold' => false, 
								'textItalic' => false, 
								'textLeading' => 0, 
								'textSpacing' => 0, 
								'textBackground' => '', 
								'textAlign' => 'left', 
							], 
						'vertical' => [
								'order' => 0, 
								'x' => 0, 
								'y' => 0, 
								'alpha' => 0, 
								'width' => 32, 
								'height' => 32, 
								'rotation' => 0, 
								'visible' => false, 
								'color' => '0xFFFFFF', 
								'colorAlpha' => 0, 
								'volume' => 0, 
								'pan' => 0, 
								'blur' => '', 
								'dropshadow' => '', 
								'textFont' => '', 
								'textSize' => 12, 
								'textColor' => '0xFFFFFF', 
								'textBold' => false, 
								'textItalic' => false, 
								'textLeading' => 0, 
								'textSpacing' => 0, 
								'textBackground' => '', 
								'textAlign' => 'left', 
							], 
					];
					$ckd = $this->queryAll('SELECT * FROM instancedesc WHERE id_instance=:inst ORDER BY id_order ASC', [
						':inst' => $vi['in_id'], 
					]);
					foreach ($ckd as $vd) {
						if ($vd['id_position'] == 'v') {
							$kf[$vi['in_name']]['vertical'] = [
								'order' => (int)$vd['id_order'], 
								'x' => (int)$vd['id_x'], 
								'y' => (int)$vd['id_y'], 
								'alpha' => (float)$vd['id_alpha'], 
								'width' => (int)$vd['id_width'], 
								'height' => (int)$vd['id_height'],
								'rotation' => (int)$vd['id_rotation'], 
								'visible' => $vd['id_visible'] == '1', 
								'color' => $vd['id_color'], 
								'colorAlpha' => (float)$vd['id_coloralpha'], 
								'volume' => (float)$vd['id_volume'], 
								'pan' => (float)$vd['id_pan'], 
								'blur' => $vd['id_blur'], 
								'dropshadow' => $vd['id_dropshadow'], 
								'textFont' => $vd['id_textfont'], 
								'textSize' => (int)$vd['id_textsize'], 
								'textColor' => $vd['id_textcolor'], 
								'textBold' => $vd['id_textbold'] == '1', 
								'textItalic' => $vd['id_textitalic'] == '1', 
								'textLeading' => (int)$vd['id_textleading'], 
								'textSpacing' => (int)$vd['id_textspacing'], 
								'textBackground' => $vd['id_textbackground'], 
								'textAlign' => $vd['id_textalign'], 
							];
						} else {
							$kf[$vi['in_name']]['horizontal'] = [
								'order' => (int)$vd['id_order'], 
								'x' => (int)$vd['id_x'], 
								'y' => (int)$vd['id_y'], 
								'alpha' => (float)$vd['id_alpha'], 
								'width' => (int)$vd['id_width'], 
								'height' => (int)$vd['id_height'],
								'rotation' => (int)$vd['id_rotation'], 
								'visible' => $vd['id_visible'] == '1', 
								'color' => $vd['id_color'], 
								'colorAlpha' => (float)$vd['id_coloralpha'], 
								'volume' => (float)$vd['id_volume'], 
								'pan' => (float)$vd['id_pan'], 
								'blur' => $vd['id_blur'], 
								'dropshadow' => $vd['id_dropshadow'], 
								'textFont' => $vd['id_textfont'], 
								'textSize' => (int)$vd['id_textsize'], 
								'textColor' => $vd['id_textcolor'], 
								'textBold' => $vd['id_textbold'] == '1', 
								'textItalic' => $vd['id_textitalic'] == '1', 
								'textLeading' => (int)$vd['id_textleading'], 
								'textSpacing' => (int)$vd['id_textspacing'], 
								'textBackground' => $vd['id_textbackground'], 
								'textAlign' => $vd['id_textalign'], 
							];
						}
					}
				}
				$this->info['keyframes'][] = $kf;
			}
			
			// scene loaded
			$this->loaded = true;
		}
		return ($this->loaded);
	}
	
	/**
	 * Publish the current scene to file.
	 * @return bool was the scene published?
	 */
	public function publish() {
		if ($this->loaded) {
			// creating folders
			$ok = true;
			$movie = $this->info['movie'];
			$id = $this->info['id'];
			if (!is_dir('../movie/'.$movie.'.movie')) if (!$this->createDir('../movie/'.$movie.'.movie')) $ok = false;
			if ($ok && !is_dir('../movie/'.$movie.'.movie/scene')) if (!$this->createDir('../movie/'.$movie.'.movie/scene')) $ok = false;
			if (!$ok) {
				// no folders
				return (false);
			} else {
				// save scene file
				file_put_contents(('../movie/'.$movie.'.movie/scene/' . $id . '.json'), json_encode($this->info));
				return (true);
			}
		} else {
			// movie not loaded
			return (false);
		}
	}
	
	/**
	 * Lists current movie scenes.
	 * @return array scenes list
	 */
	public function listScenes($movie) {
		$ret = [ ];
		$ck = $this->queryAll('SELECT * FROM (SELECT t1.sc_id, (SELECT t2.sc_title FROM scenes t2 WHERE t2.sc_movie=:t2mv AND t2.sc_id=t1.sc_id ORDER BY t2.sc_uid DESC LIMIT 1) as sc_title FROM scenes t1 WHERE t1.sc_movie=:t1mv ORDER BY t1.sc_title ASC) tbs GROUP BY tbs.sc_id ORDER BY tbs.sc_title ASC', [
			':t2mv' => $movie, 
			':t1mv' => $movie, 
		]);
		foreach ($ck as $v) $ret[] = [
			'id' => $v['sc_id'], 
			'title' => $v['sc_title'], 
		];
		return ($ret);
	}
	
	/**
	 * Saves a scene.
	 * @param	string	$movie	movie id
	 * @param	string	$id	scene id
	 * @param	string	$scene	json-encoded scene description
	 * @param	array	$collections	array of json-encoded collection descriptios
	 * @param	bool	$pub	also publishes the scene?
	 * @param	string	$user	current user
	 * @param	string	$asTitle	new title (for save as, null to save with same id)
	 * @return	int	error code
	 */
	public function saveScene($movie, $id, $scene, $collections, $pub, $user, $asTitle = null) {
		// getting scene description
		$scene = json_decode($scene, true);
		if (json_last_error() != JSON_ERROR_NONE) {
			return (1);
		} else {
			// getting collections descriptions
			$cols = [ ];
			$ok = true;
			foreach ($collections as $k => $v) {
				$cols[$k] = json_decode($v, true);
				if (json_last_error() != JSON_ERROR_NONE) $ok = false;
			}
			if (!$ok) {
				return (2);
			} else {
				// save as?
				$ok = false;
				$saveas = false;
				if (!is_null($asTitle) && ($asTitle != '')) {
					$saveas = true;
					$pub = true;
					if (is_null($id) || ($id == '')) $id = md5(time().rand(1000, 9999));
					$check = true;
					while ($check) {
						$ck = $this->queryAll('SELECT COUNT(*) AS TOTAL FROM scenes WHERE sc_id=:id AND sc_movie=:mv', [
							':id' => $id, 
							':mv' => $movie, 
						]);
						if ($ck[0]['TOTAL'] == 0) {
							$check = false;
						} else {
							$id = md5(time().rand(1000, 9999));
						}
					}
					$ok = true;
					$scene['id'] = $id;
					$scene['title'] = $asTitle;
				} else {
					$ck = $this->queryAll('SELECT COUNT(*) AS TOTAL FROM scenes WHERE sc_id=:id AND sc_movie=:mv', [
						':id' => $id, 
						':mv' => $movie, 
					]);
					if ($ck[0]['TOTAL'] > 0) $ok = true;
				}
				if (!$ok) {
					return (3);
				} else {
					// checking used collections
					$sccols = [ ];
					foreach ($scene['keyframes'] as $kf) {
						foreach ($kf as $inst) {
							if (!in_array($inst['collection'], $sccols)) $sccols[] = $inst['collection'];
						}
					}
					$scene['collections'] = $sccols;
					foreach ($cols as $k => $v) if (!in_array($k, $scene['collections'])) unset($cols[$k]);
					
					// saving collection updates
					foreach ($cols as $k => $v) {
						// add/update collection description
						$this->execute('INSERT INTO collections (cl_uid, cl_id, cl_movie, cl_title, cl_transition, cl_time) VALUES (:uid, :id, :movie, :title, :transition, :time) ON DUPLICATE KEY UPDATE cl_title=VALUES(cl_title), cl_transition=VALUES(cl_transition), cl_time=VALUES(cl_time)', [
							':uid' => ($movie . $k), 
							':id' => $k, 
							':movie' => $movie, 
							':title' => $v['name'], 
							':transition' => $v['transition'], 
							':time' => $v['time'], 
						]);
						// remove previous assets
						$this->execute('DELETE FROM assets WHERE at_collection=:col', [
							':col' => ($movie . $k), 
						]);
						// add current assets
						foreach ($v['assets'] as $ka => $a) {
							$this->execute('INSERT INTO assets (at_id, at_collection, at_order, at_name, at_type, at_time, at_action, at_frames, at_frtime, at_file1, at_file2, at_file3, at_file4, at_file5) VALUES (:id, :collection, :order, :name, :type, :time, :action, :frames, :frtime, :file1, :file2, :file3, :file4, :file5)', [
								':id' => $ka, 
								':collection' => ($movie . $k), 
								':order' => $a['order'], 
								':name' => substr($a['name'], 0, 256), 
								':type' => $a['type'], 
								':time' => $a['time'], 
								':action' => base64_encode(gzencode($a['action'])), 
								':frames' => $a['frames'], 
								':frtime' => $a['frtime'], 
								':file1' => $a['file']['@1'],  
								':file2' => $a['file']['@2'],  
								':file3' => $a['file']['@3'],  
								':file4' => $a['file']['@4'],  
								':file5' => $a['file']['@5'],  
							]);
						}
						// loading collection and publishing the new version
						$col = new Collection($k, $movie);
						$col->publish();
					}
					
					// removing old scene versions
					if (!$saveas) {
						$ck = $this->queryAll('SELECT sc_uid FROM scenes WHERE sc_id=:id AND sc_movie=:mv AND sc_published=:pub ORDER BY sc_date DESC LIMIT ' . $this->conf['sceneVersions'] . ' OFFSET ' . $this->conf['sceneVersions'], [
							':id' => $id, 
							':mv' => $movie, 
							':pub' => 0, 
						]);
						foreach ($ck as $v) {
							// getting old keyframes
							$ckok = $this->queryAll('SELECT kf_id FROM keyframes WHERE kf_scene=:sc', [':sc'=>$v['sc_uid']]);
							foreach ($ckok as $kfo) {
								// getting ond instances
								$ckoi = $this->queryAll('SELECT in_id FROM instances WHERE in_keyframe=:kf', [':kf'=>$kfo['kf_id']]);
								foreach ($ckoi as $inso) {
									// remove instance descriptions
									$this->execute('DELETE FROM instancedesc WHERE id_instance=:id LIMIT 2', [':id'=>$inso['in_id']]);
									// remove the instance
									$this->execute('DELETE FROM instances WHERE in_id=:id LIMIT 1', [':id'=>$inso['in_id']]);
								}
								// remove the keyframe
								$this->execute('DELETE FROM keyframes WHERE kf_id=:id LIMIT 1', [':id'=>$kfo['kf_id']]);
							}
							// remove the scene
							$this->execute('DELETE FROM scenes WHERE sc_uid=:id LIMIT 1', [':id'=>$v['sc_uid']]);
						}
					}
					
					// saving scene version
					$ackeyframes = [ ];
					foreach ($scene['ackeyframes'] as $ack) $ackeyframes[] = $ack == '' ? '' : base64_encode(gzencode($ack));
					$this->execute('INSERT INTO scenes (sc_id, sc_movie, sc_title, sc_about, sc_image, sc_up, sc_down, sc_left, sc_right, sc_nin, sc_nout, sc_collections, sc_loop, sc_acstart, sc_ackeyframes, sc_user) VALUES (:id, :movie, :title, :about, :image, :up, :down, :left, :right, :nin, :nout, :collections, :loop, :acstart, :ackeyframes, :user)', [
						':id' => $id, 
						':movie' => $movie, 
						':title' => $scene['title'], 
						':about' => $scene['about'], 
						':image' => $scene['image'], 
						':up' => $scene['navigation']['up'], 
						':down' => $scene['navigation']['down'], 
						':left' => $scene['navigation']['left'], 
						':right' => $scene['navigation']['right'],  
						':nin' => $scene['navigation']['nin'], 
						':nout' => $scene['navigation']['nout'], 
						':collections' => implode(',', $scene['collections']), 
						':loop' => $scene['loop'], 
						':acstart' => base64_encode(gzencode($scene['acstart'])), 
						':ackeyframes' => implode(',', $ackeyframes), 
						':user' => $user, 
					]);
					$uid = $this->insertID();
					
					// saving keyframes
					$order = 0;
					foreach ($scene['keyframes'] as $kf) {
						$this->execute('INSERT INTO keyframes (kf_scene, kf_order) VALUES (:scene, :order)', [
							':scene' => $uid, 
							':order' => $order, 
						]);
						$kid = $this->insertID();
						foreach ($kf as $kins => $ins) {
							$this->execute('INSERT INTO instances (in_keyframe, in_name, in_collection, in_asset, in_action, in_play) VALUES (:keyframe, :name, :collection, :asset, :action, :play)', [
								':keyframe' => $kid, 
								':name' => $kins, 
								':collection' => $ins['collection'], 
								':asset' => $ins['asset'], 
								':action' => $ins['action'] == '' ? '' : base64_encode(gzencode($ins['action'])), 
								':play' => $ins['play'] ? '1' : '0', 
							]);
							$iid = $this->insertID();
							$this->execute('INSERT INTO instancedesc (id_instance, id_position, id_order, id_x, id_y, id_alpha, id_width, id_height, id_rotation, id_visible, id_color, id_coloralpha, id_volume, id_pan, id_blur, id_dropshadow, id_textfont, id_textsize, id_textcolor, id_textbold, id_textitalic, id_textleading, id_textspacing, id_textbackground, id_textalign) VALUES (:instance, :position, :order, :x, :y, :alpha, :width, :height, :rotation, :visible, :color, :coloralpha, :volume, :pan, :blur, :dropshadow, :textfont, :textsize, :textcolor, :textbold, :textitalic, :textleading, :textspacing, :textbackground, :textalign)', [
								':instance' => $iid, 
								':position' => 'h', 
								':order' => $ins['horizontal']['order'], 
								':x' => $ins['horizontal']['x'], 
								':y' => $ins['horizontal']['y'], 
								':alpha' => $ins['horizontal']['alpha'], 
								':width' => $ins['horizontal']['width'], 
								':height' => $ins['horizontal']['height'], 
								':rotation' => $ins['horizontal']['rotation'], 
								':visible' => $ins['horizontal']['visible'] ? '1' : '0', 
								':color' => $ins['horizontal']['color'], 
								':coloralpha' => $ins['horizontal']['colorAlpha'], 
								':volume' => $ins['horizontal']['volume'], 
								':pan' => $ins['horizontal']['pan'], 
								':blur' => $ins['horizontal']['blur'], 
								':dropshadow' => $ins['horizontal']['dropshadow'], 
								':textfont' => $ins['horizontal']['textFont'], 
								':textsize' => $ins['horizontal']['textSize'], 
								':textcolor' => $ins['horizontal']['textColor'], 
								':textbold' => $ins['horizontal']['textBold'] ? '1' : '0', 
								':textitalic' => $ins['horizontal']['textItalic'] ? '1' : '0', 
								':textleading' => $ins['horizontal']['textLeading'], 
								':textspacing' => $ins['horizontal']['textSpacing'], 
								':textbackground' => $ins['horizontal']['textBackground'], 
								':textalign' => $ins['horizontal']['textAlign'], 
							]);
							$this->execute('INSERT INTO instancedesc (id_instance, id_position, id_order, id_x, id_y, id_alpha, id_width, id_height, id_rotation, id_visible, id_color, id_coloralpha, id_volume, id_pan, id_blur, id_dropshadow, id_textfont, id_textsize, id_textcolor, id_textbold, id_textitalic, id_textleading, id_textspacing, id_textbackground, id_textalign) VALUES (:instance, :position, :order, :x, :y, :alpha, :width, :height, :rotation, :visible, :color, :coloralpha, :volume, :pan, :blur, :dropshadow, :textfont, :textsize, :textcolor, :textbold, :textitalic, :textleading, :textspacing, :textbackground, :textalign)', [
								':instance' => $iid, 
								':position' => 'v', 
								':order' => $ins['vertical']['order'], 
								':x' => $ins['vertical']['x'], 
								':y' => $ins['vertical']['y'], 
								':alpha' => $ins['vertical']['alpha'], 
								':width' => $ins['vertical']['width'], 
								':height' => $ins['vertical']['height'], 
								':rotation' => $ins['vertical']['rotation'], 
								':visible' => $ins['vertical']['visible'] ? '1' : '0', 
								':color' => $ins['vertical']['color'], 
								':coloralpha' => $ins['vertical']['colorAlpha'], 
								':volume' => $ins['vertical']['volume'], 
								':pan' => $ins['vertical']['pan'], 
								':blur' => $ins['vertical']['blur'], 
								':dropshadow' => $ins['vertical']['dropshadow'], 
								':textfont' => $ins['vertical']['textFont'], 
								':textsize' => $ins['vertical']['textSize'], 
								':textcolor' => $ins['vertical']['textColor'], 
								':textbold' => $ins['vertical']['textBold'] ? '1' : '0', 
								':textitalic' => $ins['vertical']['textItalic'] ? '1' : '0', 
								':textleading' => $ins['vertical']['textLeading'], 
								':textspacing' => $ins['vertical']['textSpacing'], 
								':textbackground' => $ins['vertical']['textBackground'], 
								':textalign' => $ins['vertical']['textAlign'], 
							]);
						}
						// adjusting order values
						$ckord = $this->queryAll('SELECT id_id, id_position, id_order FROM instancedesc d INNER JOIN instances i ON d.id_instance=i.in_id WHERE i.in_keyframe=:kf ORDER BY id_position, id_order', [ ':kf' => $kid ]);
						$ordv = $ordh = 0;
						foreach ($ckord as $vord) {
							if ($vord['id_position'] == 'v') {
								$this->execute('UPDATE instancedesc SET id_order=:ord WHERE id_id=:id', [
									':ord' => $ordv, 
									':id' => $vord['id_id'], 
								]);
								$ordv++;
							} else {
								$this->execute('UPDATE instancedesc SET id_order=:ord WHERE id_id=:id', [
									':ord' => $ordh, 
									':id' => $vord['id_id'], 
								]);
								$ordh++;
							}
						}
						$order++;
					}
					
					// publish?
					if ($pub) {
						if (!$saveas) {
							$this->execute('UPDATE scenes SET sc_published=:pub WHERE sc_id=:id AND sc_movie=:mv', [
								':pub' => '0', 
								':id' => $id, 
								':mv' => $movie, 
							]);
						}
						$this->execute('UPDATE scenes SET sc_published=:pub WHERE sc_uid=:id', [
							':pub' => '1', 
							':id' => $uid, 
						]);
						$this->loadSceneUid($uid, $movie);
                        // restricted movie?
                        $ckm = $this->queryAll('SELECT mv_identify, mv_vsgroups FROM movies WHERE mv_id=:mv', [ ':mv' => $movie ]);
                        if (count($ckm) > 0) {
                            if (($ckm[0]['mv_identify'] == '1') || (!is_null($ckm[0]['mv_vsgroups']) && ($ckm[0]['mv_vsgroups'] != ''))) {
                                // nothing to do
                            } else {
                                $this->publish();
                            }
                        }
					}
					
					// finish
					return (0);
				}
			}
		}
	}
	
	/**
	 * Lists current scene versions.
	 * @param	string	$movie	movie id
	 * @param	string	$id	scene id
	 * @param	string	$format	date/time format
	 * @return array versions list
	 */
	public function listVersions($movie, $id, $format) {
		$ret = [ ];
		$ck = $this->queryAll('SELECT sc_uid, sc_user, sc_date, sc_published FROM scenes WHERE sc_movie=:mv AND sc_id=:id ORDER BY sc_uid DESC', [
			':mv' => $movie, 
			':id' => $id, 
		]);		
		foreach ($ck as $v) $ret[] = [
			'uid' => $v['sc_uid'], 
			'date' => date($format, strtotime($v['sc_date'])), 
			'user' => $v['sc_user'], 
			'pub' => $v['sc_published'], 
		];
		return ($ret);
	}
	
	/**
	 * Removes a scene.
	 * @param	string	$movie	movie id
	 * @param	string	$id	scene id
	 * @return	bool	was the scene found and removed?
	 */
	public function removeScene($movie, $id) {
		$ck = $this->queryAll('SELECT COUNT(*) AS TOTAL FROM scenes WHERE sc_movie=:mv AND sc_id=:id', [
			':mv' => $movie, 
			':id' => $id, 
		]);	
		if ($ck[0]['TOTAL'] > 0) {
			$ck = $this->queryAll('SELECT sc_uid FROM scenes WHERE sc_id=:id AND sc_movie=:mv', [
				':id' => $id, 
				':mv' => $movie, 
			]);
			foreach ($ck as $v) {
				$ckok = $this->queryAll('SELECT kf_id FROM keyframes WHERE kf_scene=:sc', [':sc'=>$v['sc_uid']]);
				foreach ($ckok as $kfo) {
					$ckoi = $this->queryAll('SELECT in_id FROM instances WHERE in_keyframe=:kf', [':kf'=>$kfo['kf_id']]);
					foreach ($ckoi as $inso) {
						$this->execute('DELETE FROM instancedesc WHERE id_instance=:id LIMIT 2', [':id'=>$inso['in_id']]);
						$this->execute('DELETE FROM instances WHERE in_id=:id LIMIT 1', [':id'=>$inso['in_id']]);
					}
					$this->execute('DELETE FROM keyframes WHERE kf_id=:id LIMIT 1', [':id'=>$kfo['kf_id']]);
				}
				$this->execute('DELETE FROM scenes WHERE sc_uid=:id LIMIT 1', [':id'=>$v['sc_uid']]);
			}
			@unlink('../movie/'.$movie.'.movie/scene/' . $id . '.json');
			return (true);
		} else {
			return (false);
		}
	}
    
    /**
     * Saves the currently loded scene navigation sequence changes (using current UID).
     */
    public function saveSequence() {
        if ($this->loaded) {
            $this->execute('UPDATE scenes SET sc_published=:pub WHERE sc_movie=:mv AND sc_id=:id', [
                ':pub' => '0', 
                ':mv' => $this->info['movie'], 
                ':id' => $this->info['id'], 
            ]);
            $this->execute('UPDATE scenes SET sc_published=:pub, sc_up=:up, sc_down=:down, sc_left=:left, sc_right=:right, sc_nin=:nin, sc_nout=:nout WHERE sc_uid=:uid', [
                ':pub' => '1', 
                ':up' => $this->info['navigation']['up'], 
                ':down' => $this->info['navigation']['down'], 
                ':left' => $this->info['navigation']['left'], 
                ':right' => $this->info['navigation']['right'], 
                ':nin' => $this->info['navigation']['nin'], 
                ':nout' => $this->info['navigation']['nout'], 
                ':uid' => $this->uid, 
            ]);
            $this->publish();
        }
    }
}