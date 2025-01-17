<?php

/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

/** CLASS DEFINITIONS **/
require_once('Data.php');

/**
 * User information.
 */
class Visitor extends Data
{

    /**
     * information list
     */
    public $list = [ ];
    
    /**
     * groups list
     */
    public $groups = [ ];
    
    /**
     * movies list
     */
    public $movies = [ ];
    
    /**
     * cors allowed domains list
     */
    public $cors = [ ];
    
    /**
     * selected visitor
     */
    public $selected = [ ];
    
    public function __construct()
	{
		parent::__construct();
    }
    
    /**
     * Retrieves a visitor list.
     * @param   string  $user   request user
     * @param   string  $filter search filter
     * @return  bool    successful listing?
     */
    public function listVisitors($user, $filter) {
        // only admin users can list visitors
        $ck = $this->queryAll('SELECT * FROM users WHERE us_email=:em AND us_level=:zero', [
            ':em' => $user, 
            ':zero' => '0', 
        ]);
        if (count($ck) == 0) {
            return (false);
        } else {
            $this->list = [ ];
            if ($filter == '') {
                $ck = $this->queryAll('SELECT * FROM visitors ORDER BY vs_email ASC');
            } else {
                $ck = $this->queryAll('SELECT * FROM visitors WHERE vs_email LIKE :filt ORDER BY vs_email ASC', [
                    ':filt' => '%' . $filter . '%', 
                ]);
            }
            foreach ($ck as $v) {
                $ckb = $this->queryAll('SELECT vb_email FROM visitorsblocked WHERE vb_email=:em', [
                    ':em' => $v['vs_email'], 
                ]);
                $this->list[] = [
                    'email' => $v['vs_email'], 
                    'created' => $v['vs_created'], 
                    'last' => $v['vs_last'], 
                    'level' => (int)$v['vs_level'], 
                    'blocked' => (count($ckb) > 0), 
                ];
            }
            $this->groups = [ ];
            $ck = $this->queryAll('SELECT * FROM visitorgroups ORDER BY vg_name ASC');
            foreach ($ck as $v) {
                $ckt = $this->queryAll('SELECT COUNT(*) AS TOTAL FROM visitorassoc WHERE va_group=:id GROUP BY va_group', [':id'=>$v['vg_id']]);
                $this->groups[] = [
                    'id' => $v['vg_id'], 
                    'name' => $v['vg_name'], 
                    'visitors' => (!is_null($ckt) && isset($ckt[0])) ? (int)$ckt[0]['TOTAL'] : 0, 
                ];
            }
            $this->movies = [ ];
            $ck = $this->queryAll('SELECT mv_id, mv_title FROM movies ORDER BY mv_title ASC');
            foreach ($ck as $v) $this->movies[] = [
                'id' => $v['mv_id'], 
                'title' => $v['mv_title'], 
            ];
            $this->cors = [ ];
            $ck = $this->queryAll('SELECT cr_domain FROM cors');
            foreach ($ck as $v) $this->cors[] = $v['cr_domain'];
            return (true);
        }
    }

    /**
     * Selects a visitor.
     * @param   string  $user   request user
     * @param   string  $email  the visitor e-mail
     * @return  bool    visitor selected?
     */
    public function selectVisitor($user, $email) {
        // only admin users can list visitors
        $ck = $this->queryAll('SELECT * FROM users WHERE us_email=:em AND us_level=:zero', [
            ':em' => $user, 
            ':zero' => '0', 
        ]);
        if (count($ck) == 0) {
            return (false);
        } else {
            $this->list = [ ];
            $ck = $this->queryAll('SELECT * FROM visitors WHERE vs_email=:em', [
                ':em' => $email, 
            ]);
            if (count($ck) > 0) {
                $ckb = $this->queryAll('SELECT vb_email FROM visitorsblocked WHERE vb_email=:em', [
                    ':em' => $ck[0]['vs_email'], 
                ]);
                $this->selected = [
                    'email' => $ck[0]['vs_email'], 
                    'created' => $ck[0]['vs_created'], 
                    'last' => $ck[0]['vs_last'], 
                    'movies' => 0, 
                    'states' => 0, 
                    'data' => 0, 
                    'groups' => [ ], 
                    'blocked' => (count($ckb) > 0), 
                ];
                $movies = [ ];
                $ckst = $this->queryAll('SELECT vs_movie, COUNT(*) as TOTAL FROM visitorstate WHERE vs_user=:em GROUP BY vs_movie', [ ':em' => $email ]);
                foreach ($ckst as $st) {
                    $this->selected['states'] += $st['TOTAL'];
                    if (!in_array($st['vs_movie'], $movies)) $movies[] = $st['vs_movie'];
                }
                $ckdt = $this->queryAll('SELECT vd_movie, COUNT(*) as TOTAL FROM visitordata WHERE vd_user=:em GROUP BY vd_movie', [ ':em' => $email ]);
                foreach ($ckdt as $dt) {
                    $this->selected['data'] += $dt['TOTAL'];
                    if (!in_array($dt['vd_movie'], $movies)) $movies[] = $dt['vd_movie'];
                }
                $this->selected['movies'] = count($movies);
                return (true);
            } else {
                return (false);
            }
        }
    }
    
    /**
     * Blocks/releases a visitor.
     * @param   string  $user   request user
     * @param   string  $email  the visitor e-mail
     * @return  bool    visitor blocked/released?
     */
    public function blockVisitor($user, $email) {
        // only admin users can list visitors
        $ck = $this->queryAll('SELECT * FROM users WHERE us_email=:em AND us_level=:zero', [
            ':em' => $user, 
            ':zero' => '0', 
        ]);
        if (count($ck) == 0) {
            return (false);
        } else {
            $this->list = [ ];
            $ck = $this->queryAll('SELECT * FROM visitors WHERE vs_email=:em', [
                ':em' => $email, 
            ]);
            if (count($ck) > 0) {
                $ckb = $this->queryAll('SELECT vb_email FROM visitorsblocked WHERE vb_email=:em', [
                    ':em' => $ck[0]['vs_email'], 
                ]);
                if (count($ckb) > 0) {
                    // release
                    $this->execute('DELETE FROM visitorsblocked WHERE vb_email=:em LIMIT 1', [
                        ':em' => $ck[0]['vs_email'], 
                    ]);
                } else {
                    // block
                    $this->execute('INSERT IGNORE INTO visitorsblocked (vb_email, vb_admin) VALUES (:em, :adm)', [
                        ':em' => $ck[0]['vs_email'], 
                        ':adm' => $user,
                    ]);
                }
                return (true);
            } else {
                return (false);
            }
        }
    }
    
    /**
     * Removes a visitor.
     * @param   string  $user   request user
     * @param   string  $email  the visitor e-mail
     * @return  bool    visitor removed?
     */
    public function removeVisitor($user, $email) {
        // only admin users can list visitors
        $ck = $this->queryAll('SELECT * FROM users WHERE us_email=:em AND us_level=:zero', [
            ':em' => $user, 
            ':zero' => '0', 
        ]);
        if (count($ck) == 0) {
            return (false);
        } else {
            $this->execute('DELETE FROM visitors WHERE vs_email=:em', [
                ':em' => $email, 
            ]);
            $this->execute('DELETE FROM visitorsblocked WHERE vb_email=:em', [
                ':em' => $email, 
            ]);
            $this->execute('DELETE FROM visitorstate WHERE vs_user=:em', [
                ':em' => $email, 
            ]);
            $this->execute('DELETE FROM visitordata WHERE vd_user=:em', [
                ':em' => $email, 
            ]);
            $this->execute('DELETE FROM visitorassoc WHERE va_visitor=:em', [
                ':em' => $email, 
            ]);
            return (true);
        }
    }
    
    /**
     * Creates a group.
     * @param   string  $user   request user
     * @param   string  $name  the group name
     * @return  bool    group created?
     */
    public function createGroup($user, $name) {
        // only admin users can create groups
        $ck = $this->queryAll('SELECT * FROM users WHERE us_email=:em AND us_level=:zero', [
            ':em' => $user, 
            ':zero' => '0', 
        ]);
        if (count($ck) == 0) {
            return (false);
        } else {
            $ck = $this->queryAll('SELECT * FROM visitorgroups WHERE vg_name=:nm', [
               ':nm' => $name, 
            ]);
            if (count($ck) > 0) {
                return (false);
            } else {
                $this->execute('INSERT INTO visitorgroups (vg_name) VALUES (:nm)', [
                   ':nm' => $name, 
                ]);
                return (true);
            }
        }
    }
    
    /**
     * Removes a group.
     * @param   string  $user   request user
     * @param   int  $id  the group id
     * @param   string  $name  the group name
     * @return  bool    group created?
     */
    public function removeGroup($user, $id, $name) {
        // only admin users can remove groups
        $ck = $this->queryAll('SELECT * FROM users WHERE us_email=:em AND us_level=:zero', [
            ':em' => $user, 
            ':zero' => '0', 
        ]);
        if (count($ck) == 0) {
            return (false);
        } else {
            $ck = $this->queryAll('SELECT * FROM visitorgroups WHERE vg_name=:nm and vg_id=:id', [
                ':nm' => $name, 
                ':id' => $id, 
            ]);
            if (count($ck) == 0) {
                return (false);
            } else {
                $this->execute('DELETE FROM visitorgroups WHERE vg_name=:nm and vg_id=:id', [
                    ':nm' => $name, 
                    ':id' => $id, 
                ]);
                return (true);
            }
        }
    }
    
    /**
     * Shows a group information.
     * @param   string  $user   request user
     * @param   int  $id  the group id
     * @param   string  $name  the group name
     * @return  bool    group found?
     */
    public function showGroup($user, $id, $name) {
        // only admin users can list groups
        $ck = $this->queryAll('SELECT * FROM users WHERE us_email=:em AND us_level=:zero', [
            ':em' => $user, 
            ':zero' => '0', 
        ]);
        if (count($ck) == 0) {
            return (false);
        } else {
            $ck = $this->queryAll('SELECT * FROM visitorgroups WHERE vg_name=:nm and vg_id=:id', [
                ':nm' => $name, 
                ':id' => $id, 
            ]);
            if (count($ck) == 0) {
                return (false);
            } else {
                $this->groups = [
                    'id' => $ck[0]['vg_id'], 
                    'name' => $ck[0]['vg_name'], 
                    'visitors' => [ ], 
                ];
                $ck = $this->queryAll('SELECT va_visitor FROM visitorassoc WHERE va_group=:id ORDER BY va_visitor ASC', [ ':id' => $id ]);
                foreach ($ck as $v) $this->groups['visitors'][] = $v['va_visitor'];
                return (true);
            }
        }
    }
    
    /**
     * Adds a group visitor.
     * @param   string  $user   request user
     * @param   int  $id  the group id
     * @param   string  $name  the group name
     * @param   string  $visitor  the new group visitor
     * @return  bool    visitor added?
     */
    public function addGroupVisitor($user, $id, $name, $visitor) {
        // only admin users can list groups
        $ck = $this->queryAll('SELECT * FROM users WHERE us_email=:em AND us_level=:zero', [
            ':em' => $user, 
            ':zero' => '0', 
        ]);
        if (count($ck) == 0) {
            return (false);
        } else {
            $ck = $this->queryAll('SELECT * FROM visitorgroups WHERE vg_name=:nm and vg_id=:id', [
                ':nm' => $name, 
                ':id' => $id, 
            ]);
            if (count($ck) == 0) {
                return (false);
            } else {
                $ck = $this->queryAll('SELECT * FROM visitorassoc WHERE va_visitor=:vs AND va_group=:id', [
                    ':vs' => $visitor, 
                    ':id' => $id, 
                ]);
                if (count($ck) == 0) {
                    $this->execute('INSERT INTO visitorassoc (va_visitor, va_group) VALUES (:vs, :id)', [
                        ':vs' => $visitor, 
                        ':id' => $id, 
                    ]);
                }
                $this->groups = [
                    'id' => $id, 
                    'name' => $name, 
                    'visitors' => [ ], 
                ];
                $ck = $this->queryAll('SELECT va_visitor FROM visitorassoc WHERE va_group=:id ORDER BY va_visitor ASC', [ ':id' => $id ]);
                foreach ($ck as $v) $this->groups['visitors'][] = $v['va_visitor'];
                return (true);
            }
        }
    }
    
    /**
     * Changes a group name.
     * @param   string  $user   request user
     * @param   int  $id  the group id
     * @param   string  $name  the group name
     * @param   string  $new  the new group name
     * @return  bool    group changed?
     */
    public function changeGroupName($user, $id, $name, $new) {
        // only admin users can list groups
        $ck = $this->queryAll('SELECT * FROM users WHERE us_email=:em AND us_level=:zero', [
            ':em' => $user, 
            ':zero' => '0', 
        ]);
        if (count($ck) == 0) {
            return (false);
        } else {
            $ck = $this->queryAll('SELECT * FROM visitorgroups WHERE vg_name=:nm and vg_id=:id', [
                ':nm' => $name, 
                ':id' => $id, 
            ]);
            if (count($ck) == 0) {
                return (false);
            } else {
                $this->execute('UPDATE visitorgroups SET vg_name=:new WHERE vg_name=:nm and vg_id=:id', [
                    ':new' => $new, 
                    ':nm' => $name, 
                    ':id' => $id, 
                ]);
                return (true);
            }
        }
    }
    
    /**
     * Removes a group visitor.
     * @param   string  $user   request user
     * @param   int  $id  the group id
     * @param   string  $name  the group name
     * @param   string  $visitor  the visitor to remove
     * @return  bool    visitor removed?
     */
    public function removeGroupVisitor($user, $id, $name, $visitor) {
        // only admin users can list groups
        $ck = $this->queryAll('SELECT * FROM users WHERE us_email=:em AND us_level=:zero', [
            ':em' => $user, 
            ':zero' => '0', 
        ]);
        if (count($ck) == 0) {
            return (false);
        } else {
            $ck = $this->queryAll('SELECT * FROM visitorgroups WHERE vg_name=:nm and vg_id=:id', [
                ':nm' => $name, 
                ':id' => $id, 
            ]);
            if (count($ck) == 0) {
                return (false);
            } else {
                $ck = $this->execute('DELETE FROM visitorassoc WHERE va_visitor=:vs AND va_group=:id', [
                    ':vs' => $visitor, 
                    ':id' => $id, 
                ]);
                $this->groups = [
                    'id' => $id, 
                    'name' => $name, 
                    'visitors' => [ ], 
                ];
                $ck = $this->queryAll('SELECT va_visitor FROM visitorassoc WHERE va_group=:id ORDER BY va_visitor ASC', [ ':id' => $id ]);
                foreach ($ck as $v) $this->groups['visitors'][] = $v['va_visitor'];
                return (true);
            }
        }
    }
    
    /**
     * Gets information for movie access setup.
     * @param   string  $movie   current movie
     * @return  bool    information found?
     */
    public function accessInfo($movie) {
        // movie exists?
        $ck = $this->queryAll('SELECT * FROM movies WHERE mv_id=:id', [
            ':id' => $movie,  
        ]);
        if (count($ck) == 0) {
            return (false);
        } else {
            $this->list = [ ];
            $this->groups = [ ];
            $ck = $this->queryAll('SELECT mv_id, mv_title FROM movies WHERE mv_id!=:id ORDER BY mv_title ASC', [
                ':id' => $movie,  
            ]);
            foreach ($ck as $v) $this->list[] = [
                'id' => $v['mv_id'], 
                'title' => $v['mv_title'], 
            ];
            $ck = $this->queryAll('SELECT vg_id, vg_name FROM visitorgroups ORDER BY vg_name ASC');
            foreach ($ck as $v) $this->groups[] = [
                'id' => $v['vg_id'], 
                'name' => $v['vg_name'], 
            ];
            return (true);
        }
    }
    
    /**
     * Ckecks if a visitor has access to a movie.
     * @param   string  $movie  the movie id
     * @param   string  $visitor    the visitor e-mail
     * @return  bool    can the visitor access the movie?
     */
    public function allowMovie($movie, $visitor) {
        // does the visitor account exist?
        $ck = $this->queryAll('SELECT vs_email FROM visitors WHERE vs_email=:em', [ ':em' => $visitor ]);
        if (count($ck) == 0) {
            // no visitor account
            return (false);
        } else {
            // does the movie exist?
            $ck = $this->queryAll('SELECT mv_vsgroups FROM movies WHERE mv_id=:mv', [ ':mv' => $movie ]);
            if (count($ck) == 0) {
                // no movie
                return (false);
            } else {
                // groups?
                if (!is_null($ck[0]['mv_vsgroups']) && ($ck[0]['mv_vsgroups'] != '')) {
                    $groups = explode(',', $ck[0]['mv_vsgroups']);
                    $found = false;
                    foreach ($groups as $gr) {
                        if (!$found) {
                            $ckg = $this->queryAll('SELECT va_id FROM visitorassoc WHERE va_visitor=:em AND va_group=:gr', [
                                ':em' => $visitor, 
                                ':gr' => $gr, 
                            ]);
                            if (count($ckg) > 0) $found = TRUE;
                        }
                    }
                    return ($found);
                } else {
                    // not limited by groups
                    return (true);
                }
            }
        }
    }
    
    /**
     * Exports events records.
     * @param   string  $user   request user
     * @param   string  movie  the movie id (blank for all)
     * @param   string  name    the event name (blank for all)
     * @return  string|bool    the file name or false on error
     */
    public function exportEvents($user, $movie, $name) {
        // only admin users can export events
        $ck = $this->queryAll('SELECT * FROM users WHERE us_email=:em AND us_level=:zero', [
            ':em' => $user, 
            ':zero' => '0', 
        ]);
        if (count($ck) == 0) {
            return (false);
        } else {
            // remove old event files
            if (!is_dir('../../events/')) $this->createDir('../../events/');
            $limit = strtotime('-2days');
            $flcheck = glob('../../events/*.csv');
            foreach($flcheck as $fl) {
                if (is_file($fl)) {
                    if (filemtime($fl) < $limit) {
                        @unlink ($fl);
                    }
                }
            }
            // prepare the new file
            $fname = 'events_'.date('Y-m-d_h-m-s').'.csv';
            $content = [ 'Recorded date;Event date;Event name;Movie ID;Movie title;Scene ID;Scene title;Visitor;Additional information' ];
            $cols = [ ];
            $vals = [ ];
            if ($movie != '') {
                $cols[] = 'ev_movie=:mv';
                $vals[':mv'] = $movie;
            }
            if ($name != '') {
                $cols[] = 'ev_name=:nm';
                $vals[':nm'] = $name;
            }
            $ck = $this->queryAll('SELECT * FROM events ' . ((count($cols) > 0) ? 'WHERE ' . implode(' AND ', $cols) . ' ' : ' ') . 'ORDER BY ev_id ASC', $vals);
            foreach ($ck as $v) {
                $content[] = implode(';', [
                    $v['ev_date'], 
                    $v['ev_when'], 
                    str_replace(';', ',', trim($v['ev_name'])), 
                    str_replace(';', ',', trim($v['ev_movie'])), 
                    str_replace(';', ',', trim($v['ev_moviename'])), 
                    str_replace(';', ',', trim($v['ev_scene'])), 
                    str_replace(';', ',', trim($v['ev_scenename'])), 
                    ($v['ev_visitor'] == 'system' ? '' : str_replace(';', ',', trim($v['ev_visitor']))), 
                    str_replace(';', ',', trim($v['ev_extra'])), 
                ]);
            }
            file_put_contents(('../../events/'.$fname), implode("\r\n", $content));
            return ($fname);
        }
    }
    
    /**
     * Remove events records.
     * @param   string  $user   request user
     * @param   string  $movie  the movie id (blank for all)
     * @param   string  $name    the event name (blank for all)
     * @param   string  $date    date limit for removal
     * @return  string|bool    the file name or false on error
     */
    public function removeEvents($user, $movie, $name, $date) {
        // only admin users can export events
        $ck = $this->queryAll('SELECT * FROM users WHERE us_email=:em AND us_level=:zero', [
            ':em' => $user, 
            ':zero' => '0', 
        ]);
        if (count($ck) == 0) {
            return (false);
        } else {
            $cols = [ 'ev_date<:limit' ];
            $vals = [ ':limit' => date('Y-m-d H:i:s', strtotime($date))];
            if ($movie != '') {
                $cols[] = 'ev_movie=:mv';
                $vals[':mv'] = $movie;
            }
            if ($name != '') {
                $cols[] = 'ev_name=:nm';
                $vals[':nm'] = $name;
            }
            $this->execute('DELETE FROM events WHERE ' . implode(' AND ', $cols), $vals);
            return (true);
        }
    }

}