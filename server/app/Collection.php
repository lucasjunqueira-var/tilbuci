<?php

/** CLASS DEFINITIONS **/
require_once('BaseClass.php');

/**
 * Collection information.
 */
class Collection extends BaseClass
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
	 * Constructor.
	 */
	public function __construct($id = null, $movie = null)
	{
		parent::__construct();
		if (!is_null($id)) {
			if (is_null($movie)) {
				$this->loadCollection($id);
			} else {
				$this->loadCollection($id, $movie);
			}
		}
	}

	/**
	 * Loads a collection information.
	 * @param	string	$id	the collection uid (if movie is null) or id
	 * @param	string	$movie	the movie id
	 * @return	bool	was the collection found and loaded?
	 */
	public function loadCollection($id, $movie = null) {
		$this->info = [ ];
		$this->loaded = false;
		if (is_null($movie)) {
			$ck = $this->queryAll('SELECT * FROM collections WHERE cl_uid=:id', [':id' => $id]);
		} else {
			$ck = $this->queryAll('SELECT * FROM collections WHERE cl_id=:id AND cl_movie=:mv', [':id' => $id, ':mv' => $movie]);
		}
		if (count($ck) == 0) {
			return (false);
		} else {
			$this->info = [
				'id' => $ck[0]['cl_id'], 
				'movie' => $ck[0]['cl_movie'], 
				'name' => $ck[0]['cl_title'], 
				'transition' => $ck[0]['cl_transition'], 
				'time' => (float)$ck[0]['cl_time'], 
				'assets' => [ ], 
			];
			$cka = $this->queryAll('SELECT * FROM assets WHERE at_collection=:col ORDER BY at_order ASC', [':col' => $ck[0]['cl_uid']]);
			foreach ($cka as $a) {
				$this->info['assets'][$a['at_id']] = [
					'order' => (int)$a['at_order'], 
					'name' => $a['at_name'], 
					'type' => $a['at_type'], 
					'time' => (float)$a['at_time'], 
					'action' => gzdecode(base64_decode($a['at_action'])), 
					'frames' => (int)$a['at_frames'], 
					'frtime' => (int)$a['at_frtime'], 
					'file' => [
						'@1' => $a['at_file1'], 
						'@2' => $a['at_file2'], 
						'@3' => $a['at_file3'], 
						'@4' => $a['at_file4'], 
						'@5' => $a['at_file5'], 
					], 
				];
			}
			$this->loaded = true;
			return (true);
		}
	}
	
	/**
	 * Publish the current collection to file.
	 * @return bool was the collection published?
	 */
	public function publish() {
		if ($this->loaded) {
			// creating folders
			$ok = true;
			$movie = $this->info['movie'];
			$id = $this->info['id'];
			if (!is_dir('../movie/'.$movie.'.movie')) if (!$this->createDir('../movie/'.$movie.'.movie')) $ok = false;
			if ($ok && !is_dir('../movie/'.$movie.'.movie/collection')) if (!$this->createDir('../movie/'.$movie.'.movie/collection')) $ok = false;
			if (!$ok) {
				// no folders
				return (false);
			} else {
				// save collection file
				file_put_contents(('../movie/'.$movie.'.movie/collection/' . $id . '.json'), json_encode($this->info));
				return (true);
			}
		} else {
			// collection not loaded
			return (false);
		}
	}
	
}