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
 * Movie operations.
 */
class WSMovie extends Webservice
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
				case 'Movie/New':
					$this->newMovie();
					break;
				case 'Movie/List':
					$this->listMovies();
					break;
				case 'Movie/Update':
					$this->updateMovie();
					break;
				case 'Movie/Collaborators':
					$this->listCollaborators();
					break;
				case 'Movie/CollaboratorAdd':
					$this->addCollaborator();
					break;
				case 'Movie/CollaboratorRemove':
					$this->removeCollaborator();
					break;
				case 'Movie/OwnerChange':
					$this->changeOwner();
					break;
				case 'Movie/Info':
					$this->infoMovie();
					break;
				case 'Movie/Plugin':
					$this->setPlugin();
				case 'Movie/SetList':
					$this->getMovieSetList();
				case 'Movie/SetIndex':
					$this->setIndexMovie();
					break;
				case 'Movie/SetRender':
					$this->setRender();
					break;
				case 'Movie/SetShare':
					$this->setShare();
					break;
				case 'Movie/SetFPS':
					$this->setFPS();
					break;
                case 'Movie/Export':
					$this->export();
					break;
                case 'Movie/ImportID':
					$this->importId();
					break;
                case 'Movie/ImportZip':
					$this->importZip();
					break;
                case 'Movie/ExportSite':
					$this->exportSite();
					break;
                case 'Movie/ExportIframe':
					$this->exportIframe();
					break;
                case 'Movie/ExportPwa':
					$this->exportPwa();
					break;
                case 'Movie/ExportPub':
					$this->exportPub();
					break;
                case 'Movie/ExportDesk':
					$this->exportDesk();
					break;
                case 'Movie/ExportCordova':
					$this->exportCordova();
					break;
                case 'Movie/Remove':
					$this->remove();
					break;
                case 'Movie/AcInfo':
					$this->acInfo();
					break;
                case 'Movie/Navigation':
					$this->navigation();
					break;
                case 'Movie/Notes':
					$this->notes();
					break;
                case 'Movie/SaveNote':
					$this->saveNote();
					break;
                case 'Movie/UnlockScenes':
					$this->unlock();
					break;
                case 'Movie/SaveContraptions':
					$this->saveContraptions();
					break;
				default:
					$this->returnRequest([ 'e' => -9 ]);
					break;
			}
		}
	}
	
	/** PRIVATE/PROTECTED METHODS **/
	
	/**
	 * Creating a movie.
	 */
	private function newMovie() {
		// required fields received?
		if ($this->requiredFields(['title', 'id', 'author', 'copyright', 'copyleft', 'about', 'sizebig', 'sizesmall', 'moviesizetype', 'interval'])) {
			// preparing movie
			$mv = new Movie;
			$id = $mv->createMovie($this->req['id'], $this->user, $this->req['title'], $this->req['author'], $this->req['copyright'], $this->req['copyleft'], $this->req['about'], $this->req['sizebig'], $this->req['sizesmall'], $this->req['moviesizetype'], $this->req['interval']);
			if ($id === false) {
				// error while creating the movie
				$this->returnRequest([ 'e' => 2 ]);
			} else {
				// publishing the movie file
				if ($mv->loadMovie($id)) {
					if ($mv->publish()) {
						$this->returnRequest([ 'e' => 0, 'id' => $id ]);
					} else {
						// error while publishing the movie
						$this->returnRequest([ 'e' => 3 ]);
					}
				} else {
					// error while publishing the movie
					$this->returnRequest([ 'e' => 3 ]);
				}
				
			}
		}
	}
	
	/**
	 * Lists available movies for current user.
	 */
	private function listMovies() {
		$mv = new Movie;
		$list = $mv->listMovies($this->user, isset($this->req['owner']) && (trim($this->req['owner']) == 'true'));
		$this->returnRequest([ 'e' => 0, 'list' => $list ]);
	}
	
	/**
	 * Updates movie information.
	 */
	private function updateMovie() {
		// required fields received?
		if ($this->requiredFields(['id', 'data'])) {
			$mv = new Movie;
			$json = json_decode($this->req['data'], true);
			if (json_last_error() == JSON_ERROR_NONE) {
				// try to update
				$this->returnRequest($mv->update($this->req['id'], $json, $this->user));
			} else {
				// the update information is corrupted
				$this->returnRequest([ 'e' => 4, 'list' => [ ], 'reload' => false ]);
			}
		}
	}
	
	/**
	 * Lists the movie collaborators.
	 */
	private function listCollaborators() {
		// required fields received?
		if ($this->requiredFields(['id'])) {
			$mv = new Movie;
			$this->returnRequest($mv->listCollaborators($this->req['id'], $this->user));
		} else {
			$this->returnRequest([ 'e' => 2, 'list' => [ ] ]);
		}
	}
	
	/**
	 * Add a collaborator to a movie.
	 */
	private function addCollaborator() {
		// required fields received?
		if ($this->requiredFields(['id', 'email'])) {
			$mv = new Movie;
			$this->returnRequest($mv->addCollaborator($this->req['id'], $this->user, $this->req['email']));
		} else {
			$this->returnRequest([ 'e' => 2, 'list' => [ ] ]);
		}
	}
	
	/**
	 * Remove a collaborator from a movie.
	 */
	private function removeCollaborator() {
		// required fields received?
		if ($this->requiredFields(['id', 'email'])) {
			$mv = new Movie;
			$this->returnRequest($mv->removeCollaborator($this->req['id'], $this->user, $this->req['email']));
		} else {
			$this->returnRequest([ 'e' => 2, 'list' => [ ] ]);
		}
	}
	
	/**
	 * Changes a movie owner.
	 */
	private function changeOwner() {
		// required fields received?
		if ($this->requiredFields(['id', 'email'])) {
			$mv = new Movie;
			$this->returnRequest($mv->changeOwner($this->req['id'], $this->user, $this->req['email']));
		} else {
			$this->returnRequest([ 'e' => 3 ]);
		}
	}
	
	/**
	 * Getting information about the movie.
	 */
	private function infoMovie() {
		// required fields received?
		if ($this->requiredFields(['id'])) {
			$mv = new Movie;
			$this->returnRequest($mv->infoMovie($this->req['id'], $this->user));
		} else {
			$this->returnRequest([ 'e' => 2 ]);
		}
	}
	
	/**
	 * Sets plugin configuration for a movie.
	 */
	private function setPlugin() {
		// required fields received?
		if ($this->requiredFields(['id', 'plugin', 'active', 'conf'])) {
			$mv = new Movie;
			$this->returnRequest($mv->setPlugin($this->req['id'], $this->user, $this->req['plugin'], $this->req['active'], $this->req['conf']));
		} else {
			$this->returnRequest([ 'e' => 2 ]);
		}
	}
	
	/**
	 * Gets a movie list to set index.
	 */
	private function getMovieSetList() {
		$mv = new Movie;
		$this->returnRequest([
			'e' => 0,
			'list' => $mv->getMovieSetList($this->user), 
			'current' => $mv->getCurrentIndex(), 
		]);
	}
	
	/**
	 * Sets the index movie.
	 */
	private function setIndexMovie() {
		// required fields received?
		if ($this->requiredFields(['movie'])) {
			$mv = new Movie;
			$this->returnRequest([ 'e' => $mv->setIndexMovie($this->user, $this->req['movie']) ]);
		}
	}
	
	/**
	 * Sets the render mode.
	 */
	private function setRender() {
		// required fields received?
		if ($this->requiredFields(['rd'])) {
			$mv = new Movie;
			$this->returnRequest([ 'e' => $mv->setRender($this->user, $this->req['rd']) ]);
		}
	}
	
	/**
	 * Sets the share mode.
	 */
	private function setShare() {
		// required fields received?
		if ($this->requiredFields(['sh'])) {
			$mv = new Movie;
			$this->returnRequest([ 'e' => $mv->setShare($this->user, $this->req['sh']) ]);
		}
	}
	
	/**
	 * Sets the player FPS handling mode.
	 */
	private function setFPS() {
		// required fields received?
		if ($this->requiredFields(['fps'])) {
			$mv = new Movie;
			$this->returnRequest([ 'e' => $mv->setFPS($this->user, $this->req['fps']) ]);
		}
	}
    
    /**
	 * Exports a movie.
	 */
	private function export() {
		// required fields received?
		if ($this->requiredFields(['movie'])) {
			$mv = new Movie;
            $exp = $mv->export($this->user, $this->req['movie']);
            if ($exp === false) {
                $this->returnRequest([ 'e' => 1, 'exp' => '' ]);
            } else {
                $this->returnRequest([ 'e' => 0, 'exp' => $exp ]);
            }
		}
	}
    
    /**
	 * Checks a movie ID for importing.
	 */
	private function importId() {
		// required fields received?
		if ($this->requiredFields(['movie'])) {
            $movie = $this->cleanString($this->req['movie']);
			$mv = new Movie;
            if ($mv->importId($this->user, $movie)) {
                $this->returnRequest([ 'e' => 0, 'imp' => $movie ]);
            } else {
                $this->returnRequest([ 'e' => 1, 'imp' => '' ]);
            }
		}
	}
    
    /**
	 * Checks an uploaded zip file for movie import.
	 */
	private function importZip() {
		// required fields received?
		if ($this->requiredFields(['movie'])) {
			$mv = new Movie;
            $this->returnRequest([ 'e' => $mv->importZip($this->user, $this->req['movie']) ]);
		}
	}
    
    /**
	 * Exports a movie as a website.
	 */
	private function exportSite() {
		// required fields received?
		if ($this->requiredFields(['movie', 'mode', 'sitemap', 'location'])) {
			$mv = new Movie;
            $exp = $mv->exportSite($this->user, $this->req['movie'], $this->req['mode'], $this->req['sitemap'], $this->req['location']);
            if ($exp === false) {
                $this->returnRequest([ 'e' => 1, 'exp' => '' ]);
            } else {
                $this->returnRequest([ 'e' => 0, 'exp' => $exp ]);
            }
		}
	}
    
    /**
	 * Exports a movie for iframe embed.
	 */
	private function exportIframe() {
		// required fields received?
		if ($this->requiredFields(['movie', 'location'])) {
			$mv = new Movie;
            $exp = $mv->exportSite($this->user, $this->req['movie'], 'webgl', '', $this->req['location'], true);
            if ($exp === false) {
                $this->returnRequest([ 'e' => 1, 'exp' => '' ]);
            } else {
                $this->returnRequest([ 'e' => 0, 'exp' => $exp ]);
            }
		}
	}
    
    /**
	 * Exports a movie as a PWA application.
	 */
	private function exportPwa() {
		// required fields received?
		if ($this->requiredFields(['movie', 'name', 'shortname', 'lang', 'url', 'location'])) {
			$mv = new Movie;
            $exp = $mv->exportPwa($this->user, $this->req['movie'], $this->req['name'], $this->req['shortname'], $this->req['lang'], $this->req['url'], $this->req['location']);
            if ($exp === false) {
                $this->returnRequest([ 'e' => 1, 'exp' => '' ]);
            } else {
                $this->returnRequest([ 'e' => 0, 'exp' => $exp ]);
            }
		}
	}
    
    /**
	 * Exports a movie for publishing services.
	 */
	private function exportPub() {
		// required fields received?
		if ($this->requiredFields(['movie'])) {
			$mv = new Movie;
            $exp = $mv->exportPub($this->user, $this->req['movie']);
            if ($exp === false) {
                $this->returnRequest([ 'e' => 1, 'exp' => '' ]);
            } else {
                $this->returnRequest([ 'e' => 0, 'exp' => $exp ]);
            }
		}
	}
    
    /**
	 * Exports a movie as a desktop application.
	 */
	private function exportDesk() {
		// required fields received?
		if ($this->requiredFields(['movie', 'mode', 'window', 'width', 'height', 'favicon', 'author', 'description', 'title'])) {
			$mv = new Movie;
            $exp = $mv->exportDesk($this->user, $this->req['movie'], $this->req['mode'], $this->req['window'], $this->req['width'], $this->req['height'], $this->req['favicon'], $this->req['author'], $this->req['description'], $this->req['title']);
            if ($exp === false) {
                $this->returnRequest([ 'e' => 1, 'exp' => '' ]);
            } else {
                $this->returnRequest([ 'e' => 0, 'exp' => $exp ]);
            }
		}
	}
    
    /**
	 * Exports a movie as an Apache Cordova project.
	 */
	private function exportCordova() {
		// required fields received?
		if ($this->requiredFields(['movie', 'mode', 'appid', 'appsite', 'appauthor', 'appemail', 'applicense'])) {
			$mv = new Movie;
            $exp = $mv->exportCordova($this->user, $this->req['movie'], $this->req['mode'], $this->req['appid'], $this->req['appsite'], $this->req['appauthor'], $this->req['appemail'], $this->req['applicense']);
            if ($exp === false) {
                $this->returnRequest([ 'e' => 1, 'exp' => '' ]);
            } else {
                $this->returnRequest([ 'e' => 0, 'exp' => $exp ]);
            }
		}
	}
    
    /**
	 * Removes a movie.
	 */
	private function remove() {
		// required fields received?
		if ($this->requiredFields(['id'])) {
			$mv = new Movie;
            $list = $mv->remove($this->user, $this->req['id']);
            $this->returnRequest([ 'e' => 0, 'list' => $list ]);
		} else {
			$this->returnRequest([ 'e' => 2, 'list' => [ ] ]);
		}
	}
    
    /**
	 * Gets information for action blocks.
	 */
	private function acInfo() {
		// required fields received?
		if ($this->requiredFields(['id'])) {
			$mv = new Movie;
            $this->returnRequest([
                'e' => 0,
                'movies' => $mv->listAcMovies($this->user), 
                'scenes' => $mv->listAcScenes($this->req['id'])
            ]);
		} else {
			$this->returnRequest([ 'e' => 1 ]);
		}
	}
    
    /**
	 * Creates a navigation sequence.
	 */
	private function navigation() {
		// required fields received?
		if ($this->requiredFields(['movie', 'seq', 'con', 'axis'])) {
			$mv = new Movie;
            $mv->createNavigation($this->req['movie'], $this->req['seq'], $this->req['con'], $this->req['axis']);
            $this->returnRequest([ 'e' => 0 ]);
		} else {
			$this->returnRequest([ 'e' => 1 ]);
		}
	}
    
    /**
	 * Recovers the design notes.
	 */
	private function notes() {
		// required fields received?
		if ($this->requiredFields(['movie', 'scene'])) {
			$mv = new Movie;
            $notes = $mv->getNotes($this->user, $this->req['movie'], $this->req['scene']);
            if ($notes === false) {
                $this->returnRequest([ 'e' => 2 ]);
            } else {
                $this->returnRequest([ 'e' => 0, 'notes' => $notes ]);
            }
		} else {
			$this->returnRequest([ 'e' => 1 ]);
		}
	}
    
    /**
	 * Saves a design note.
	 */
	private function saveNote() {
		// required fields received?
		if ($this->requiredFields(['movie', 'scene', 'type', 'text'])) {
			$mv = new Movie;
            $notes = $mv->saveNote($this->user, $this->req['movie'], $this->req['scene'], $this->req['type'], $this->req['text']);
            if ($notes === false) {
                $this->returnRequest([ 'e' => 2 ]);
            } else {
                $this->returnRequest([ 'e' => 0, 'notes' => $notes ]);
            }
		} else {
			$this->returnRequest([ 'e' => 1 ]);
		}
	}
    
    /**
	 * Unlocks all scenes.
	 */
	private function unlock() {
		// required fields received?
		if ($this->requiredFields(['id'])) {
			$mv = new Movie;
            if ($mv->unlockScenes($this->user, $this->req['id'])) {
                $this->returnRequest([ 'e' => 0 ]);
            } else {
                $this->returnRequest([ 'e' => 2 ]);
            }
		} else {
			$this->returnRequest([ 'e' => 1 ]);
		}
	}
    
    /**
	 * Saves the movie contraption settings.
	 */
	private function saveContraptions() {
		// required fields received?
		if ($this->requiredFields(['movie', 'data'])) {
			$mv = new Movie;
            $this->returnRequest([ 'e' => $mv->saveContraptions($this->user, $this->req['movie'], $this->req['data']) ]);
		}
	}
}