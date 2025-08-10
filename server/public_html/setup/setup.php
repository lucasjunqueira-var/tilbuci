<?php
/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

/**
 TilBuci setup script
 Lucas Junqueira, August 2025
 **/

// version info
$version = [
    'num' => 14, 
];

// database access
function queryDb($db, $query, $values = [ ]) {
	$sth = $db->prepare($query, array(PDO::ATTR_CURSOR => PDO::CURSOR_FWDONLY));
	$sth->execute($values);
    $vals = [ ];
    try {
        $vals = $sth->fetchAll();
    } catch (\Exception $e) {
        $vals = [ ];
    }
	return($vals);
}
function executeDb($db, $query, $values = [ ]) {
	$sth = $db->prepare($query, array(PDO::ATTR_CURSOR => PDO::CURSOR_FWDONLY));
    $ret = false;
    try {
        $sth->execute($values);
        $ret = true;
    } catch (\Exception $e) {
        $ret = false;
    }
	return($ret);
}

// server information
$sinfo = [
	'host' => $_SERVER['HTTP_HOST'] . '/' . str_replace('/setup.php', '', $_SERVER['SCRIPT_NAME']), 
	'https' => false, 
];
if (isset($_SERVER['REQUEST_SCHEME'])) {
	$sinfo['https'] = strtolower($_SERVER['REQUEST_SCHEME']) == 'https';
} else if (isset($_SERVER['SCRIPT_URI'])) {
	$sinfo['https'] = substr(strtolower($_SERVER['SCRIPT_URI']), 0, 5) == 'https';
}
if ($sinfo['https']) $sinfo['host'] = 'https://' . $sinfo['host'];
	else $sinfo['host'] = 'http://' . $sinfo['host'];
if (substr($sinfo['host'], -1) != '/') $sinfo['host'] .= '/';

// install information
$iinfo = [
    'page' => 0, 
	'databaseServ' => '', 
	'databaseUser' => '', 
	'databasePass' => '',
	'databaseName' => '', 
	'databasePort' => '',
	'email' => '', 
	'mode' => 'multi', 
];

// input
$warn = '';
if (isset($_POST['ac'])) {
    switch ($_POST['ac']) {
        case '4': // override files
            if (is_file('../app/Config.php')) {
                // trying to load database config
                $iinfo['page'] = 6;
                require_once('../app/Config.php');
                if (isset($gconf)) {
                    $db = null;
                    if ($gconf['databaseServ'] == 'sqlite') {
                        try {    
                            $db = new PDO('sqlite:./movie/tilbuci.sqlite');
                            $db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
                        } catch (Exception $e) {
                            $db = null;
                        }
                    } else {
                        try {
                            $db = new PDO('mysql:host=' . $gconf['databaseServ'] . (($gconf['databasePort'] != '') ? (':' . $gconf['databasePort']) : '') . ';dbname=' . $gconf['databaseName'] . ';charset=utf8', $gconf['databaseUser'], ($gconf['databasePass'] == '' ? '' : base64_decode($gconf['databasePass'])));
                        } catch(Exception $e) {
                            $db = null;
                        }
                    }
                    if (!is_null($db)) {
                        // required files found?
                        if (is_file('./setup/part1.zip') || !is_file('./setup/part2.zip')) {
                            // files
                            $zip = new \ZipArchive;
                            $res = $zip->open('./setup/part1.zip');
                            if ($res === true) {
                                $zip->extractTo('../');
                                $zip->close();
                                $zip = new \ZipArchive;
                                $res = $zip->open('./setup/part2.zip');
                                if ($res === true) {
                                    $zip->extractTo('./');
                                    $zip->close();
                                    // remove setup
                                    @unlink('./setup/part1.zip');
                                    @unlink('./setup/part2.zip');
                                    @unlink('./setup/part3.zip');
                                    @unlink('./setup/database/tilbuci.sql');
                                    for ($i=1; $i<$version['num']; $i++) @unlink('./setup/database/'.$i.'.sql');
                                    @rmdir('./setup/database/');
                                    @rmdir('./setup/');
                                    // update complete
                                    $iinfo['page'] = 7;
                                }
                            }
                        }
                    }
                }
            }
            break;
        case '3': // update
            if (is_file('../app/Config.php')) {
                // trying to load database config
                $iinfo['page'] = 6;
                require_once('../app/Config.php');
                if (isset($gconf)) {
                    $db = null;
                    $sqlfl = '';
                    if ($gconf['databaseServ'] == 'sqlite') {
                        try {    
                            $db = new PDO('sqlite:./movie/tilbuci.sqlite');
                            $db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
                            $sqlfl = '-sqlite';
                        } catch (Exception $e) {
                            $db = null;
                        }
                    } else {
                        try {
                            $db = new PDO('mysql:host=' . $gconf['databaseServ'] . (($gconf['databasePort'] != '') ? (':' . $gconf['databasePort']) : '') . ';dbname=' . $gconf['databaseName'] . ';charset=utf8', $gconf['databaseUser'], ($gconf['databasePass'] == '' ? '' : base64_decode($gconf['databasePass'])));
                        } catch(Exception $e) {
                            $db = null;
                        }
                    }
                    if (!is_null($db)) {
                        // required files found?
                        if (is_file('./setup/part1.zip') || !is_file('./setup/part2.zip')) {
                            // update the database
                            $erupdate = false;
                            for ($i=1; $i<$version['num']; $i++) {
                                if (!$erupdate && is_file('./setup/database/'.$i.$sqlfl.'.sql')) {
                                    $handle = fopen('./setup/database/'.$i.$sqlfl.'.sql', 'r');
                                    if (!$handle) {
                                        $erupdate = true;
                                    } else {
                                        while (($line = fgets($handle)) !== false) {
                                            executeDb($db, $line);
                                        }
                                        fclose($handle);
                                    }
                                } else {
                                    $erupdate = true;
                                }
                            }
                            if (!$erupdate) {
                                // files
                                $zip = new \ZipArchive;
                                $res = $zip->open('./setup/part1.zip');
                                if ($res === true) {
                                    $zip->extractTo('../');
                                    $zip->close();
                                    $zip = new \ZipArchive;
                                    $res = $zip->open('./setup/part2.zip');
                                    if ($res === true) {
                                        $zip->extractTo('./');
                                        $zip->close();
                                        // remove setup
                                        @unlink('./setup/part1.zip');
                                        @unlink('./setup/part2.zip');
                                        @unlink('./setup/part3.zip');
                                        @unlink('./setup/database/tilbuci.sql');
                                        for ($i=1; $i<$version['num']; $i++) @unlink('./setup/database/'.$i.'.sql');
                                        @rmdir('./setup/database/');
                                        @rmdir('./setup/');
                                        // update complete
                                        $iinfo['page'] = 7;
                                    }
                                }
                            }
                        }
                    }
                }
            }
            break;
        case '1': // new installation
			$iinfo['databaseServ'] = trim($_POST['databaseServ']);
			$iinfo['databaseUser'] = trim($_POST['databaseUser']);
			$iinfo['databasePass'] = trim($_POST['databasePass']);
			$iinfo['databaseName'] = trim($_POST['databaseName']);
			$iinfo['databasePort'] = trim($_POST['databasePort']);
			$iinfo['email'] = trim($_POST['email']);
			$iinfo['mode'] = trim($_POST['mode']);
			if ($iinfo['email'] == '') {
				$warn = 'You must provide your e-mail address.';
			} else if ($iinfo['email'] != trim($_POST['email2'])) {
				$warn = 'Please check out your e-mail address confirmation.';
			} else if (($iinfo['databaseServ'] == '') || ($iinfo['databaseName'] == '')) {
				$warn = 'Please provide the database server and name.';
			} else {
				// check database connection
				$db = null;
				if ($gconf['databaseServ'] == 'sqlite') {
                    try {    
                        $db = new PDO('sqlite:./movie/tilbuci.sqlite');
                        $db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
                    } catch (Exception $e) {
                        $db = null;
                    }
                } else {
                    try {
                        $db = new PDO('mysql:host=' . $gconf['databaseServ'] . (($gconf['databasePort'] != '') ? (':' . $gconf['databasePort']) : '') . ';dbname=' . $gconf['databaseName'] . ';charset=utf8', $gconf['databaseUser'], ($gconf['databasePass'] == '' ? '' : base64_decode($gconf['databasePass'])));
                    } catch(Exception $e) {
                        $db = null;
                    }
                }
				if (is_null($db)) {
					$warn = "Couldn't connect to your database. Please check out the connection information.";
				} else {
                    if ($gconf['databaseServ'] == 'sqlite') {
					    $ck = queryDb($db, "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'");
                    } else {
                        $ck = queryDb($db, 'SHOW TABLES');
                    }
					if (count($ck) > 0) {
						$warn = 'The installation database is not empty.';
					} else {
						if (!is_file('./setup/database/tilbuci.sql')) {
							$warn = 'The database initialize script was not found.';
						} else {
							$handle = fopen('./setup/database/tilbuci'.$sqlfl.'.sql', 'r');
							if (!$handle) {
								$warn = "Couldn't open the database initialize script.";
							} else {
                                if (!is_file('./setup/part1.zip') || !is_file('./setup/part2.zip')) {
                                    $warn = "Couldn't find the installation files.";
                                } else {
                                    $zip = new \ZipArchive;
                                    $res = $zip->open('./setup/part1.zip');
                                    if ($res === true) {
                                        $zip->extractTo('../');
                                        $zip->close();
                                        $zip = new \ZipArchive;
                                        $res = $zip->open('./setup/part2.zip');
                                        if ($res === true) {
                                            $zip->extractTo('./');
                                            $zip->close();
                                            $zip = new \ZipArchive;
                                            $res = $zip->open('./setup/part3.zip');
                                            if ($res === true) {
                                                $zip->extractTo('./');
                                                $zip->close();
                                                while (($line = fgets($handle)) !== false) {
                                                    executeDb($db, $line);
                                                }
                                                fclose($handle);
                                                executeDb($db, 'INSERT INTO users (us_email, us_pass, us_passtemp, us_key, us_level) VALUES (:em, :ps, :pt, :ke, :lv)', [
                                                    ':em' => 'single', 
                                                    ':ps' => '', 
                                                    ':pt' => '', 
                                                    ':ke' => md5(time().rand(1000, 9999)), 
                                                    ':lv' => '0', 
                                                ]);
                                                executeDb($db, 'INSERT INTO users (us_email, us_pass, us_passtemp, us_key, us_level) VALUES (:em, :ps, :pt, :ke, :lv)', [
                                                    ':em' => $iinfo['email'], 
                                                    ':ps' => md5('password'), 
                                                    ':pt' => '', 
                                                    ':ke' => md5(time().rand(1000, 9999)), 
                                                    ':lv' => '0', 
                                                ]);
                                                for ($i=1; $i<$version['num']; $i++) {
                                                    if (is_file('./setup/database/'.$i.'.sql')) {
                                                        $handle = fopen('./setup/database/'.$i.$sqlfl.'.sql', 'r');
                                                        if ($handle) {
                                                            while (($line = fgets($handle)) !== false) {
                                                                executeDb($db, $line);
                                                            }
                                                            fclose($handle);
                                                        }
                                                    }
                                                }
                                                $config = [
                                                    'databaseServ' => $iinfo['databaseServ'], 
                                                    'databaseUser' => $iinfo['databaseUser'], 
                                                    'databasePass' => $iinfo['databasePass'] == '' ? '' : base64_encode($iinfo['databasePass']), 
                                                    'databaseName' => $iinfo['databaseName'], 
                                                    'databasePort' => $iinfo['databasePort'], 
                                                    'path' => $sinfo['host'], 
                                                    'singleUser' => $iinfo['mode'] == 'single', 
                                                    'encVec' => '1234567890123456', 
                                                    'encKey' => md5(time().rand(1000, 9999)),
                                                    'secret' => md5(time().rand(1000, 9999)), 
                                                    'sceneVersions' => 10, 
                                                ];
                                                $conffile = "<?php \r\n";
                                                $conffile .= 'global $gconf;' . "\r\n";
                                                $conffile .= '$gconf = [' . "\r\n";
                                                foreach ($config as $k => $v) {
                                                    if ($k == 'singleUser') {
                                                        $conffile .= "'singleUser' => " . ($config['singleUser'] ? "true" : "false") . ", \r\n";
                                                    } else if ($k == 'sceneVersions') {
                                                        $conffile .= "'sceneVersions' => " . $config['sceneVersions'] . ", \r\n";
                                                    } else {
                                                        $conffile .= "'" . $k . "' => '" . $v . "', \r\n";	
                                                    }
                                                }
                                                $conffile .= "]; ";
                                                file_put_contents('../app/Config.php', $conffile);
                                                file_put_contents('./app/player.json', json_encode([
                                                    'server' => true, 
                                                    'base' => $sinfo['host'],
                                                    'ws' => $sinfo['host'] . 'ws/',
                                                    'font' => $sinfo['host'] . 'font/',
                                                    'systemfonts' => [
                                                        [ 'name' => 'Averia Serif GWF', 'file' => 'averiaserifgwf.woff2' ], 
                                                        [ 'name' => 'Liberation Serif', 'file' => 'liberationserif.woff2' ], 
                                                        [ 'name' => 'Libra Sans', 'file' => 'librasans.woff2' ], 
                                                        [ 'name' => 'Roboto Sans', 'file' => 'roboto.woff2' ], 
                                                    ], 
                                                    'start' => '', 
                                                    'render' => 'webgl', 
                                                    'share' => 'scene', 
                                                    'fps' => 'free', 
                                                    'secret' => $config['secret'], 
                                                ]));
                                                file_put_contents('./app/editor.json', json_encode([
                                                    'base' => $sinfo['host'] . 'editor/',
                                                    'player' => $sinfo['host'],
                                                    'ws' => $sinfo['host'] . 'ws/',
                                                    'font' => $sinfo['host'] . 'font/',
                                                    'secret' => $config['secret'], 
                                                    'language' => [
                                                        [ 'name' => 'English', 'file' => 'default' ], 
                                                    ], 
                                                ]));
                                                @unlink('./setup/part1.zip');
                                                @unlink('./setup/part2.zip');
                                                @unlink('./setup/part3.zip');
                                                @unlink('./setup/database/tilbuci.sql');
                                                for ($i=1; $i<$version['num']; $i++) @unlink('./setup/database/'.$i.'.sql');
                                                @rmdir('./setup/database/');
                                                @rmdir('./setup/');
                                                $iinfo['page'] = 1;
                                            } else {
                                                $warn = "One of the installation files (3) was corrupted.";
                                            }
                                        } else {
                                            $warn = "One of the installation files (2) was corrupted.";
                                        }
                                    } else {
                                        $warn = "One of the installation files (1) was corrupted.";
                                    }
                                }
							}
						}
					}
				}
			}
			break;
    }
}

// update?
if ($iinfo['page'] == 0) {
    if (is_file('../app/Config.php')) {
        // trying to load database config
        $iinfo['page'] = 2;
        require_once('../app/Config.php');
        if (isset($gconf)) {
            $db = null;
            if ($gconf['databaseServ'] == 'sqlite') {
                try {    
                    $db = new PDO('sqlite:./movie/tilbuci.sqlite');
                    $db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
                } catch (Exception $e) {
                    $db = null;
                }
            } else {
                try {
                    $db = new PDO('mysql:host=' . $gconf['databaseServ'] . (($gconf['databasePort'] != '') ? (':' . $gconf['databasePort']) : '') . ';dbname=' . $gconf['databaseName'] . ';charset=utf8', $gconf['databaseUser'], ($gconf['databasePass'] == '' ? '' : base64_decode($gconf['databasePass'])));
                } catch(Exception $e) {
                    $db = null;
                }
            }
            if (!is_null($db)) {
                if ($gconf['databaseServ'] == 'sqlite') {
                    $tbmovies = queryDb($db, "SELECT name FROM sqlite_master WHERE type='table' AND name LIKE 'movies'");
                    $tbconfig = queryDb($db, "SELECT name FROM sqlite_master WHERE type='table' AND name LIKE 'config'");
                } else {
                    $tbmovies = queryDb($db, 'SHOW TABLES LIKE :mv', [ ':mv' => 'movies' ]);
                    $tbconfig = queryDb($db, 'SHOW TABLES LIKE :cf', [ ':cf' => 'config' ]);
                }
                if ((count($tbmovies) > 0) && (count($tbconfig) > 0)) {
                    $dbVersion = 1;
                    $ckversion = queryDb($db, 'SELECT cf_value FROM config WHERE cf_key=:ver', [':ver' => 'dbVersion' ]);
                    if (count($ckversion) > 0) $dbVersion = (int)$ckversion[0]['cf_value'];
                    // installation can be updated
                    $iinfo['page'] = 3;
                    // current version is the installer one?
                    if ($dbVersion == $version['num']) $iinfo['page'] = 4;
                    // current version is newer then the installer one?
                    if ($dbVersion > $version['num']) $iinfo['page'] = 5;
                }
            }
        }
    }
}

?>
<!doctype html>
<html>
<head>
<meta charset="utf-8">
<title>TilBuci setup script</title>
<style>
			body, html {
				padding: 10px;
				margin: 0;
				box-sizing: border-box;
				background-color: #333333;
				color: #dadada;
				font-family: 'Lucida Sans', 'Lucida Sans Regular', 'Lucida Grande', 'Lucida Sans Unicode', Geneva, Verdana, sans-serif;
				font-size: 20px;
			}
			#holder {
				box-sizing: border-box;
				padding: 20px;
				border: 2px solid #dadada;
				background-color: rgba(102, 102, 102, 0.8);
				border-radius: 10px;
				width: 100%;
			}
			#title {
				color: #ffffff;
				font-weight: bold;
				font-size: 30px;
				margin-bottom: 15px;
			}
			#title small {
				font-size: 15px;
			}
			.button {
				box-sizing: border-box;
				padding: 5px 10px;
				border: 2px solid #dadada;
				width: 100%;
				cursor: pointer;
				color: #dadada;
				font-size: 20px;
				border-radius: 10px;
				margin-bottom: 10px;
				margin-top: 20px;
				background-color: rgba(255, 255, 255, 0.1);
                font-weight: bold;
			}
			.button h1 {
				font-weight: bold;
				font-size: 18px;
				margin: 0;
			}
			.button:hover {
				border: 2px solid #ff9900;
				background-color: rgba(255, 153, 0, 0.25);
				color: #ffffff;
			}
            a {
                color: #ff9900;
            }
            .warn {
                color: #ff8a8a;
            }
            input[type="text"] {
                width: 100%;
                font-size: 16px;
                background-color: #ffffff;
                color: #000000;
                padding: 5px;
                border-radius: 5px;
            }
            select {
                width: 100%;
                font-size: 16px;
                background-color: #ffffff;
                color: #000000;
                padding: 5px;
                border-radius: 5px;
            }
		</style>
</head>
<body>
    <div id="holder">
    <?php if ($iinfo['page'] == 0) { ?>
        <h1>Welcome to the TilBuci setup script!</h1>
        <hr />
        <?= $warn == '' ? '' : '<p class="warn">' . $warn . '</p>' ?>
        <p>You are installing TilBuci at <em><?= $sinfo['host'] ?></em>. Please create a MySQL/MariaDB database and provide the information below.<?= !$sinfo['https'] ? '<br /><span class="warn">Attention: it is recommended to install TilBuci on a secure "https" server.</span>': '' ?></p>
        <form method="post">
            <p>Database server address</p>
            <input type="text" name="databaseServ" value="<?= $iinfo['databaseServ'] ?>" required />
            <p>Database server port (leave blank for default)</p>
            <input type="text" name="databasePort" value="<?= $iinfo['databasePort'] ?>" />
            <p>Database user</p>
            <input type="text" name="databaseUser" value="<?= $iinfo['databaseUser'] ?>" />
            <p>Database password</p>
            <input type="text" name="databasePass" value="<?= $iinfo['databasePass'] ?>" />
            <p>Database name</p>
            <input type="text" name="databaseName" value="<?= $iinfo['databaseName'] ?>" required />
            <p>Your e-mail address</p>
            <input type="text" name="email" value="<?= $iinfo['email'] ?>" required />
            <p>Confirm your e-mail address</p>
            <input type="text" name="email2" value="" required />
            <p>Access mode</p>
            <select name="mode">
                <option value="multi" <?= $iinfo['mode'] != 'single' ? 'selected' : '' ?>>multi user</option>
                <option value="single" <?= $iinfo['mode'] == 'single' ? 'selected' : '' ?>>single user</option>
            </select>
            <input type="hidden" name="ac" value="1" />
            <input type="submit" class="button" value="Check information and install" />
        </form>
    <?php } else if ($iinfo['page'] == 1) { ?>
        <h1>TilBuci setup script</h1>
        <hr />
        <p>Your TilBuci system was configured. For multiple user installation mode, acess the editor with the provided e-mail address and use <em>password</em> as your password. Please, remember to change this password on your first access.</p>
        <?php /*@unlink('setup.php');*/ ?>
    <?php } else if ($iinfo['page'] == 2) { ?>
        <h1>TilBuci setup script</h1>
        <hr />
        <p>An old TilBuci installation was found but it can't be updated with this script. Please check out your files. If needed, backup your data, export your movies and start a new TilBuci installation. After that you can import your movves and resume the work on them.</p>
    <?php } else if ($iinfo['page'] == 3) { ?>
        <h1>TilBuci setup script</h1>
        <hr />
        <p>A TilBuci version <strong><?= $dbVersion ?></strong> was found. This script can update it to the <strong><?= $version['num'] ?></strong> version - just click the button below. Plase backup your data before updating.</p>
        <form method="post">
            <input type="hidden" name="ac" value="3" />
            <input type="hidden" name="current" value="<?= $dbVersion ?>" />
            <input type="submit" class="button" value="Update the current TilBuci installation" />
        </form>
    <?php } else if ($iinfo['page'] == 4) { ?>
        <h1>TilBuci setup script</h1>
        <hr />
        <p>The installed TilBuci version, <strong><?= $dbVersion ?></strong>, is the same one provided by this install script. You may look for a newer installer version at <a href="https://tilbuci.com.br/">tilbuci.com.br</a>. You may also override your current files if needed by clicking the button below.</p>
        <form method="post">
            <input type="hidden" name="ac" value="4" />
            <input type="submit" class="button" value="Override current TilBuci files with version <?= $dbVersion ?>" />
        </form>
    <?php } else if ($iinfo['page'] == 5) { ?>
        <h1>TilBuci setup script</h1>
        <hr />
        <p>The currently installed TilBuci version is newer then the one provided by this setup script. Please download a newer installer version at <a href="https://tilbuci.com.br/">tilbuci.com.br</a> .</p>
    <?php } else if ($iinfo['page'] == 6) { ?>
        <h1>TilBuci setup script</h1>
        <hr />
        <p>An error was found while updating your TilBuci installation. Please run this <em>setup.php</em> script again.</p>
    <?php } else if ($iinfo['page'] == 7) { ?>
        <h1>TilBuci setup script</h1>
        <hr />
        <p>Your TilBuci installation update completed successfully.</p>
        <?php /*@unlink('setup.php');*/ ?>
    <?php } ?>
    </div>
</body>
</html>