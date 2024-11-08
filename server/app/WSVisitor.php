<?php

/** CLASS DEFINITIONS **/
require_once('Webservice.php');
require_once('Visitor.php');
require_once('Scene.php');

/**
 * Visitor operations.
 */
class WSVisitor extends Webservice
{	
    /**
     * system allowed actions
     */
    private $sysAllow = [
        'Visitor/DataLoad', 
        'Visitor/DataSave', 
        'Visitor/StateSave', 
        'Visitor/StateLoad', 
        'Visitor/StateList', 
        'Visitor/LoadScene', 
        'Visitor/Event', 
    ];
    
    /**
     * actions that don't require visitor login
     */
    private $noLogin = [
        'Visitor/Event', 
    ];
    
	/**
	 * Class constructor.
	 */
	public function __construct($ac)
	{
		parent::__construct($ac, in_array($ac, $this->noLogin));
	}
	
	/**
	 * Runs the current request.
	 */
	public function runRequest() {
		// getting the request
		$er = $this->getRequest(in_array($this->ac, $this->sysAllow));
		if ($er != 0) {
			$this->returnRequest([ 'e' => $er ]);
		} else {
			switch ($this->ac) {
				case 'Visitor/DataLoad':
					$this->dataLoad();
					break;
				case 'Visitor/DataSave':
					$this->dataSave();
					break;
				case 'Visitor/StateSave':
					$this->stateSave();
					break;
				case 'Visitor/StateLoad':
					$this->stateLoad();
					break;
				case 'Visitor/StateList':
					$this->stateList();
					break;
                case 'Visitor/List':
					$this->listVisitors();
					break;
                case 'Visitor/Select':
					$this->selectVisitor();
					break;
                 case 'Visitor/Block':
					$this->blockVisitor();
					break;
                case 'Visitor/Remove':
					$this->removeVisitor();
					break;
                case 'Visitor/CreateGroup':
					$this->createGroup();
					break;
                case 'Visitor/RemoveGroup':
					$this->removeGroup();
					break;
                case 'Visitor/ShowGroup':
					$this->showGroup();
					break;
                case 'Visitor/ChangeGroupName':
					$this->changeGroupName();
					break;
                case 'Visitor/AddGroupVisitor':
					$this->addGroupVisitor();
					break;
                case 'Visitor/RemoveGroupVisitor':
					$this->removeGroupVisitor();
					break;
                case 'Visitor/Access':
					$this->accessInfo();
					break;
                case 'Visitor/LoadScene':
					$this->loadScene();
					break;
                case 'Visitor/Event':
					$this->event();
					break;
                case 'Visitor/ExportEvents':
					$this->exportEvents();
					break;
                case 'Visitor/RemoveEvents':
					$this->removeEvents();
					break;
                case 'Visitor/RemoveCORS':
					$this->removeCors();
					break;
                case 'Visitor/AddCORS':
					$this->addCors();
					break;
				default:
					$this->returnRequest([ 'e' => -9 ]);
					break;
			}
		}
	}
	
	/** PRIVATE/PROTECTED METHODS **/
	
	/**
	 * Saving visitor data.
	 */
	private function dataSave() {
		// required fields received?
		if ($this->requiredFields(['name', 'values', 'movie'])) {
			// adding save
			$this->data->execute('INSERT INTO visitordata (vd_id, vd_movie, vd_user, vd_name, vd_value) VALUES (:id, :mv, :us, :nm, :vl) ON DUPLICATE KEY UPDATE vd_value=VALUES(vd_value)', [
				':id' => $this->user . '_' . $this->req['movie'] . '_' . $this->req['name'], 
				':mv' => $this->req['movie'], 
				':us' => $this->user, 
				':nm' => $this->req['name'], 
				':vl' => base64_encode(gzencode($this->req['values'])), 
			]);
			$this->returnRequest([ 'e' => 0 ]);
		}
	}
	
	/**
	 * Loading visitor data.
	 */
	private function dataLoad() {
		// required fields received?
		if ($this->requiredFields(['name', 'movie'])) {
			// loading data
			$ck = $this->data->queryAll('SELECT vd_value FROM visitordata WHERE vd_id=:id', [
				':id' => $this->user . '_' . $this->req['movie'] . '_' . $this->req['name'], 
			]);
			if (count($ck) == 0) {
				$this->returnRequest([ 'e' => 1 ]);	
			} else {
				$val = base64_decode($ck[0]['vd_value']);
				if ($val === false) {
					$this->returnRequest([ 'e' => 2 ]);	
				} else {
					$val = @gzdecode($val);
					if ($val === false) {
						$this->returnRequest([ 'e' => 2 ]);	
					} else {
						$this->returnRequest([ 'e' => 0, 'values' => $val ]);
					}
				}
			}
			
		}
	}
	
	/**
	 * Saving visitor state.
	 */
	private function stateSave() {
		// required fields received?
		if ($this->requiredFields(['values', 'movie', 'quick', 'scene', 'about'])) {
			// creating id
			$id = $this->user . '_' . $this->req['movie'] . '_' . ($this->req['quick'] ? '0' : time());
			// adding state
			$this->data->execute('INSERT INTO visitorstate (vs_id, vs_movie, vs_user, vs_quick, vs_scene, vs_about, vs_value) VALUES (:id, :mv, :us, :qc, :sc, :ab, :vl) ON DUPLICATE KEY UPDATE vs_scene=VALUES(vs_scene), vs_about=VALUES(vs_about), vs_value=VALUES(vs_value)', [
				':id' => $id, 
				':mv' => $this->req['movie'], 
				':us' => $this->user, 
				':qc' => ($this->req['quick'] ? '1' : '0'), 
				':sc' => $this->req['scene'], 
				':ab' => $this->req['about'], 
				':vl' => base64_encode(gzencode($this->req['values'])), 
			]);
			// remove old states?
			if (!$this->req['quick']) {
				$ck = $this->data->queryAll('SELECT vs_id FROM visitorstate WHERE vs_movie=:mv AND vs_user=:us AND vs_quick=:qc ORDER BY vs_created DESC LIMIT 10 OFFSET 10', [
					':mv' => $this->req['movie'], 
					':us' => $this->user, 
					':qc' => '0', 
				]);
				foreach ($ck as $v) $this->data->execute('DELETE FROM visitorstate WHERE vs_id=:id LIMIT 1', [ ':id' => $v['vs_id'] ]);
			}
			$this->returnRequest([ 'e' => 0 ]);
		}
	}
	
	/**
	 * Loading visitor state.
	 */
	private function stateLoad() {
		// required fields received?
		if ($this->requiredFields(['id', 'quick', 'movie'])) {
			// looking for state
			if ($this->req['quick']) {
				$ck = $this->data->queryAll('SELECT * FROM visitorstate WHERE vs_movie=:mv AND vs_user=:us AND vs_quick=:qc', [
					':mv' => $this->req['movie'], 
					':us' => $this->user, 
					':qc' => '1', 
				]);
			} else {
				$ck = $this->data->queryAll('SELECT * FROM visitorstate WHERE vs_id=:id', [':id'=>$this->req['id']]);
			}
			if (count($ck) > 0) {
				$val = base64_decode($ck[0]['vs_value']);
				if ($val === false) {
					$this->returnRequest([ 'e' => 2 ]);	
				} else {
					$val = @gzdecode($val);
					if ($val === false) {
						$this->returnRequest([ 'e' => 2 ]);	
					} else {
						$this->returnRequest([
							'e' => 0, 
							'values' => $val,
							'scene' => $ck[0]['vs_scene'], 
							'about' => $ck[0]['vs_about'], 
							'quick' => $ck[0]['vs_quick'] == '1', 
						]);
					}
				}
			} else {
				$this->returnRequest([ 'e' => 1 ]);
			}
		}
	}
	
	/**
	 * Loading visitor saved states.
	 */
	private function stateList() {
		// required fields received?
		if ($this->requiredFields(['movie', 'format'])) {
			// looking for saved states
			$ck = $this->data->queryAll('SELECT * FROM visitorstate WHERE vs_movie=:mv AND vs_user=:us AND vs_quick=:qc ORDER BY vs_updated DESC LIMIT 10', [
				':mv' => $this->req['movie'], 
				':us' => $this->user, 
				':qc' => '0', 
			]);
			$states = [ ];
			foreach ($ck as $v) {
				$date = strtotime($v['vs_updated']);
				$states[] = [
					'about' => $v['vs_about'], 
					'id' => $v['vs_id'], 
					'date' => date($this->req['format'], strtotime($v['vs_updated'])), 
				];
			}
			$this->returnRequest([ 'e' => 0, 'states' => $states ]);
		}
	}
    
    /**
	 * Loads a visitor list.
	 */
	private function listVisitors() {
		// required fields received?
		if ($this->requiredFields(['filter'])) {
			$vs = new Visitor;
            if ($vs->listVisitors($this->user, $this->req['filter'])) {
                $this->returnRequest([ 'e' => 0, 'list' => $vs->list, 'groups' => $vs->groups, 'movies' => $vs->movies, 'cors' => $vs->cors ]);
            } else {
                $this->returnRequest([ 'e' => 1, 'list' => [ ], 'groups' => [ ], 'movies' => [ ], 'cors' => [ ] ]);
            }
		}
	}
    
    /**
	 * Selects a visitor.
	 */
	private function selectVisitor() {
		// required fields received?
		if ($this->requiredFields(['email'])) {
			$vs = new Visitor;
            if ($vs->selectVisitor($this->user, $this->req['email'])) {
                $this->returnRequest([ 'e' => 0, 'data' => $vs->selected ]);
            } else {
                $this->returnRequest([ 'e' => 1, 'data' => [ ] ]);
            }
		}
	}
    
    /**
	 * Blocks/releases a visitor.
	 */
	private function blockVisitor() {
		// required fields received?
		if ($this->requiredFields(['email'])) {
			$vs = new Visitor;
            if ($vs->blockVisitor($this->user, $this->req['email'])) {
                $this->returnRequest([ 'e' => 0 ]);
            } else {
                $this->returnRequest([ 'e' => 1 ]);
            }
		}
	}
    
    /**
	 * Removes a visitor.
	 */
	private function removeVisitor() {
		// required fields received?
		if ($this->requiredFields(['email'])) {
			$vs = new Visitor;
            if ($vs->removeVisitor($this->user, $this->req['email'])) {
                $this->returnRequest([ 'e' => 0 ]);
            } else {
                $this->returnRequest([ 'e' => 1 ]);
            }
		}
	}
    
    /**
	 * Creates a group.
	 */
	private function createGroup() {
		// required fields received?
		if ($this->requiredFields(['name'])) {
			$vs = new Visitor;
            if ($vs->createGroup($this->user, $this->req['name'])) {
                $this->returnRequest([ 'e' => 0 ]);
            } else {
                $this->returnRequest([ 'e' => 1 ]);
            }
		}
	}
    
    /**
	 * Removes a group.
	 */
	private function removeGroup() {
		// required fields received?
		if ($this->requiredFields(['name', 'id'])) {
			$vs = new Visitor;
            if ($vs->removeGroup($this->user, $this->req['id'], $this->req['name'])) {
                $this->returnRequest([ 'e' => 0 ]);
            } else {
                $this->returnRequest([ 'e' => 1 ]);
            }
		}
	}
    
    /**
	 * Shows a group information.
	 */
	private function showGroup() {
		// required fields received?
		if ($this->requiredFields(['name', 'id'])) {
			$vs = new Visitor;
            if ($vs->showGroup($this->user, $this->req['id'], $this->req['name'])) {
                $this->returnRequest([ 'e' => 0, 'group' => $vs->groups ]);
            } else {
                $this->returnRequest([ 'e' => 1, 'group' => [ ] ]);
            }
		}
	}
    
    /**
	 * Changes a group name.
	 */
	private function changeGroupName() {
		// required fields received?
		if ($this->requiredFields(['name', 'id', 'new'])) {
			$vs = new Visitor;
            if ($vs->changeGroupName($this->user, $this->req['id'], $this->req['name'], $this->req['new'])) {
                $this->returnRequest([ 'e' => 0, ]);
            } else {
                $this->returnRequest([ 'e' => 1, ]);
            }
		}
	}
    
    /**
	 * Adds a group visitor.
	 */
	private function addGroupVisitor() {
		// required fields received?
		if ($this->requiredFields(['name', 'id', 'visitor'])) {
			$vs = new Visitor;
            if ($vs->addGroupVisitor($this->user, $this->req['id'], $this->req['name'], $this->req['visitor'])) {
                $this->returnRequest([ 'e' => 0, 'group' => $vs->groups ]);
            } else {
                $this->returnRequest([ 'e' => 1, 'group' => [ ] ]);
            }
		}
	}
    
    /**
	 * Removes a group visitor.
	 */
	private function removeGroupVisitor() {
		// required fields received?
		if ($this->requiredFields(['name', 'id', 'visitor'])) {
			$vs = new Visitor;
            if ($vs->removeGroupVisitor($this->user, $this->req['id'], $this->req['name'], $this->req['visitor'])) {
                $this->returnRequest([ 'e' => 0, 'group' => $vs->groups ]);
            } else {
                $this->returnRequest([ 'e' => 1, 'group' => [ ] ]);
            }
		}
	}
    
    /**
	 * Gets access iformation for movie properties.
	 */
	private function accessInfo() {
		// required fields received?
		if ($this->requiredFields(['movie'])) {
			$vs = new Visitor;
            if ($vs->accessInfo($this->req['movie'])) {
                $this->returnRequest([ 'e' => 0, 'group' => $vs->groups, 'list' => $vs->list ]);
            } else {
                $this->returnRequest([ 'e' => 1, 'group' => [ ], 'list' => [ ] ]);
            }
		}
	}
    
    /**
	 * Loads a scene information.
	 */
	private function loadScene() {
		// required fields received?
		if ($this->requiredFields(['movie', 'id', 'visitor'])) {
            $vs = new Visitor;
            if ($vs->allowMovie($this->req['movie'], $this->req['visitor'])) {
                // get scene info
                $sc = new Scene;
                if ($sc->loadScene(null, $this->req['movie'], $this->req['id'])) {
                    // return scene information
                    $sc->info['e'] = 0;
                    $this->returnRequest($sc->info);
                } else {
                    // error while loading
                    $this->returnRequest([ 'e' => 2 ]);
                }
            } else {
                // current visitor can't load the scene
				$this->returnRequest([ 'e' => 1 ]);
            }
		}
	}
    
    /**
	 * Receiving an event.
	 */
	private function event() {
		// required fields received?
		if ($this->requiredFields(['name', 'data', 'movieid', 'sceneid', 'movietitle', 'scenetitle', 'visitor'])) {
            if (!isset($this->req['when'])) $this->req['when'] = date('Y-m-d H:i:s');
			$this->data->execute('INSERT INTO events (ev_when, ev_name, ev_movie, ev_moviename, ev_scene, ev_scenename, ev_visitor, ev_extra) VALUES (:wh, :nm, :mv, :mvname, :sc, :scname, :vis, :ex)', [
                ':wh' => $this->req['when'], 
                ':nm' => $this->req['name'], 
                ':mv' => $this->req['movieid'], 
                ':mvname' => $this->req['movietitle'], 
                ':sc' => $this->req['sceneid'], 
                ':scname' => $this->req['scenetitle'], 
                ':vis' => $this->req['visitor'], 
                ':ex' => $this->req['data'], 
            ]);
            $this->returnRequest([ 'e' => 0 ]);
		}
	}
    
    /**
	 * Exporting events.
	 */
	private function exportEvents() {
		// required fields received?
		if ($this->requiredFields(['name', 'movie'])) {
			$vs = new Visitor;
            $fname = $vs->exportEvents($this->user, $this->req['movie'], $this->req['name']);
            if ($fname === false) {
                $this->returnRequest([ 'e' => 1, 'file' => '' ]);
            } else {
                $this->returnRequest([ 'e' => 0, 'file' => $fname ]);
            }
		}
	}
    
    /**
	 * Removing events.
	 */
	private function removeEvents() {
		// required fields received?
		if ($this->requiredFields(['name', 'movie', 'date'])) {
			$vs = new Visitor;
            if ($vs->removeEvents($this->user, $this->req['movie'], $this->req['name'], $this->req['date'])) {
                $this->returnRequest([ 'e' => 0 ]);
            } else {
                $this->returnRequest([ 'e' => 1 ]);
            }
		}
	}
    
    /**
	 * Removing allowed domains.
	 */
	private function removeCors() {
		// required fields received?
		if ($this->requiredFields(['domain'])) {
			$this->data->execute('DELETE FROM cors WHERE cr_domain=:dom LIMIT 1', [
                ':dom' => $this->req['domain'], 
            ]);
            $this->returnRequest([ 'e' => 0 ]);
		}
	}
    
    /**
	 * Adding an allowed domain.
	 */
	private function addCors() {
		// required fields received?
		if ($this->requiredFields(['domain'])) {
            $this->req['domain'] = mb_strtolower($this->req['domain']);
            if (substr($this->req['domain'], 0, 4) == 'http') {
                $domain = '';
                $cors = explode('/', $this->req['domain']);
                for ($i=1; $i<count($cors); $i++) {
                    if ($domain == '') {
                        if ($cors[$i] != '') {
                            $domain = $cors[0] . '//' . $cors[$i] . '/';
                        }
                    }
                }
                $this->data->execute('INSERT IGNORE INTO cors (cr_domain) VALUES (:dom)', [
                    ':dom' => $domain, 
                ]);
                $this->returnRequest([ 'e' => 0 ]);
            } else {
                $this->returnRequest([ 'e' => 1 ]);
            }
		}
	}
}