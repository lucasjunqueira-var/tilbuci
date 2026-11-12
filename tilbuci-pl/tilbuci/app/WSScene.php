<?php

/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

/** CLASS DEFINITIONS **/
require_once('Webservice.php');
require_once('Scene.php');

/**
 * Scene operations.
 */
class WSScene extends Webservice
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
				case 'Scene/New':
					$this->newScene();
					break;
				case 'Scene/NewPdf':
					$this->newScenePdf();
					break;
				case 'Scene/Load':
					$this->loadScene();
					break;
				case 'Scene/LoadUid':
					$this->loadSceneUid();
					break;
				case 'Scene/List':
					$this->listScenes();
					break;
				case 'Scene/ListDflow':
					$this->listDflow();
					break;
				case 'Scene/Save':
					$this->saveScene();
					break;
				case 'Scene/SaveAs':
					$this->saveScene(true);
					break;
				case 'Scene/ListVersions':
					$this->listVersions();
					break;
				case 'Scene/Remove':
					$this->removeScene();
					break;
				default:
					$this->returnRequest([ 'e' => -9 ]);
					break;
			}
		}
	}
	
	/** PRIVATE/PROTECTED METHODS **/
	
	/**
	 * Creating a scene.
	 */
	private function newScene() {
		// required fields received?
		if ($this->requiredFields(['title', 'id', 'movie'])) {
			// preparing scene
			$sc = new Scene;
			$id = $sc->createScene($this->req['id'], $this->req['movie'], $this->req['title'], $this->user);
			if ($id === false) {
				// error while creating the scene
				$this->returnRequest([ 'e' => 1 ]);
			} else {
				// return scene id
				$this->returnRequest([ 'e' => 0, 'id' => $id ]);
			}
		}
	}

	/**
	 * Creating a scene from a pdf page.
	 */
	private function newScenePdf() {
		// required fields received?
		if ($this->requiredFields(['title', 'movie', 'page'])) {

			// uploaded PDF file?
			if (!is_file('../../export/pdfmovie.pdf')) {
				// pdf file not found
				$this->returnRequest([ 'e' => 1 ]);
			} else {
				// rename source file
				$sourcefl = '../../export/pdfmovie_'.time().'.pdf';
				rename('../../export/pdfmovie.pdf', $sourcefl);

				// create the scene
				$sc = new Scene;
				set_time_limit(0);
				$id = $sc->createScenePdf($this->req['movie'], $this->user, $this->req['title'], $sourcefl, $this->req['page'], '../../third/pdfbase', '../movie');
				if ($id === false) {
					// error while creating the scene
					@unlink($sourcefl);
					$this->returnRequest([ 'e' => 1 ]);
				} else {
					// import the scene
					if ($sc->importSceneFile($this->user, $this->req['movie'], $id)) {
						// return scene id
						@unlink($sourcefl);
						$this->returnRequest([ 'e' => 0, 'id' => $id ]);
					} else {
						// error importing the scene file
						@unlink($sourcefl);
						$this->returnRequest([ 'e' => 2 ]);
					}
					
				}

			}
		}
	}
	
	/**
	 * Loading the latest scene version.
	 */
	private function loadScene() {
		// required fields received?
		if ($this->requiredFields(['id', 'movie'])) {
			// preparing scene
			$sc = new Scene;
			if ($sc->loadScene($this->user, $this->req['movie'], $this->req['id'])) {
				// return scene information
				$this->returnRequest([ 'e' => 0, 'info' => $sc->info ]);
			} else {
				// error while loading
				$this->returnRequest([ 'e' => 1 ]);
			}
		}
	}
	
	/**
	 * Loading a scene from its UID.
	 */
	private function loadSceneUid() {
		// required fields received?
		if ($this->requiredFields(['uid', 'movie'])) {
			// preparing scene
			$sc = new Scene;
			if ($sc->loadSceneUid($this->user, $this->req['uid'], $this->req['movie'])) {
				// return scene information
				$this->returnRequest([ 'e' => 0, 'info' => $sc->info ]);
			} else {
				// error while loading
				$this->returnRequest([ 'e' => 1 ]);
			}
		}
	}
	
	/**
	 * Lists available scenes for current movie.
	 */
	private function listScenes() {
		if ($this->requiredFields(['movie'])) {
			$sc = new Scene;
			$list = $sc->listScenes($this->user, $this->req['movie']);
			$this->returnRequest([ 'e' => 0, 'list' => $list ]);
		} else {
			// error loading list
			$this->returnRequest([ 'e' => 1 ]);
		}
	}

	/**
	 * Lists scenes with decision flow enabled.
	 */
	private function listDflow() {
		if ($this->requiredFields(['movie'])) {
			$sc = new Scene;
			$list = $sc->listDflow($this->user, $this->req['movie']);
			$this->returnRequest([ 'e' => 0, 'list' => $list ]);
		} else {
			// error loading list
			$this->returnRequest([ 'e' => 1 ]);
		}
	}
	
	/**
	 * Saves a scene.
	 */
	private function saveScene($newid = false) {
		if ($newid) {
			// save as
			if ($this->requiredFields(['movie', 'id', 'scene', 'collections', 'title'])) {
				$sc = new Scene;
				$er = $sc->saveScene($this->req['movie'], $this->req['id'], $this->req['scene'], $this->req['collections'], true, $this->user, $this->req['title']);
				if ($er == 0) {
					$this->returnRequest([ 'e' => 0, 'id' => $sc->info['id'] ]);
				} else {
					$this->returnRequest([ 'e' => $er ]);
				}
			}
		} else {
			// save with same id
			if ($this->requiredFields(['movie', 'id', 'scene', 'collections', 'pub'])) {
				$sc = new Scene;
				$er = $sc->saveScene($this->req['movie'], $this->req['id'], $this->req['scene'], $this->req['collections'], $this->req['pub'], $this->user);
				if ($er == 0) {
					$this->returnRequest([ 'e' => 0, 'pub' => $this->req['pub'] ]);
				} else {
					$this->returnRequest([ 'e' => $er ]);
				}
			}
		}
	}
	
	/**
	 * Lists available scene versions.
	 */
	private function listVersions() {
		if ($this->requiredFields(['movie', 'id', 'format'])) {
			$sc = new Scene;
			$list = $sc->listVersions($this->req['movie'], $this->req['id'], $this->req['format']);
			$this->returnRequest([ 'e' => 0, 'list' => $list ]);
		} else {
			// error loading list
			$this->returnRequest([ 'e' => 1 ]);
		}
	}
	
	/**
	 * Removes a scene.
	 */
	private function removeScene() {
		if ($this->requiredFields(['movie', 'id'])) {
			$sc = new Scene;
			if ($sc->removeScene($this->req['movie'], $this->req['id'])) {
				$this->returnRequest([ 'e' => 0 ]);
			} else {
				$this->returnRequest([ 'e' => 1 ]);
			}
		}
	}
	
}