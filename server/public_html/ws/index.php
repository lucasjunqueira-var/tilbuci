<?php
/** CLASS DEFINITIONS **/
require_once('../../app/WSEmail.php');
require_once('../../app/WSFile.php');
require_once('../../app/WSMedia.php');
require_once('../../app/WSMovie.php');
require_once('../../app/WSScene.php');
require_once('../../app/WSSystem.php');
require_once('../../app/WSVisitor.php');
require_once('../../app/WSUser.php');
require_once('../../app/WSPlugin.php');
require_once('../../app/Data.php');
$data = new Data;

// check for cross domain access
$cors = $data->checkCORS();
if (count($cors) > 0) {
    if (isset($_SERVER['HTTP_ORIGIN'])) {
        if (in_array(mb_strtolower($data->slashUrl($_SERVER['HTTP_ORIGIN'])), $cors)) {
            header("Access-Control-Allow-Origin: {$_SERVER['HTTP_ORIGIN']}");
            header('Access-Control-Allow-Credentials: true');
            header('Access-Control-Max-Age: 86400');
        }
    } else if (isset($_SERVER['HTTP_REFERER'])) {
        if (in_array(mb_strtolower($data->slashUrl($_SERVER['HTTP_REFERER'])), $cors)) {
            header("Access-Control-Allow-Origin: {$_SERVER['HTTP_REFERER']}");
            header('Access-Control-Allow-Credentials: true');
            header('Access-Control-Max-Age: 86400');
        }
    }
    if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
        if (isset($_SERVER['HTTP_ACCESS_CONTROL_REQUEST_METHOD']))
            header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
        if (isset($_SERVER['HTTP_ACCESS_CONTROL_REQUEST_HEADERS']))
            header("Access-Control-Allow-Headers: {$_SERVER['HTTP_ACCESS_CONTROL_REQUEST_HEADERS']}");
    }
}

// plugin webservices
$list = $data->pluginWs();
$plugins = [ ];
foreach ($list as $v) {
	if (is_file('../../app/' . $v['fl'] . '.php')) {
		require_once('../../app/WS' . $v['fl'] . '.php');
		$plugins[$v['fl']] = 'WS' . $v['fl'];
	}	
}

// process request
if (!isset($_POST['a'])) {
	// return error
	header('Content-Type: application/json');
	exit(json_encode([
		'e' => -8, 
		'a' => '', 
		't' => date('c'), 
	]));
} else {
	// identify action
	$ac = explode('/', trim($_POST['a']));
	switch ($ac[0]) {
		case 'Email':
			$ws = new WSEmail(trim($_POST['a']));
			break;
		case 'File':
			$ws = new WSFile(trim($_POST['a']));
			break;
		case 'Media':
			$ws = new WSMedia(trim($_POST['a']));
			break;
		case 'Movie':
			$ws = new WSMovie(trim($_POST['a']));
			break;
		case 'Plugin':
			$ws = new WSPlugin(trim($_POST['a']));
			break;
		case 'Scene':
			$ws = new WSScene(trim($_POST['a']));
			break;
		case 'System':
			$ws = new WSSystem(trim($_POST['a']));
			break;
		case 'User':
			$ws = new WSUser(trim($_POST['a']));
			break;
		case 'Visitor':
			$ws = new WSVisitor(trim($_POST['a']));
			break;
		default:
			// plugin ws
			if (isset($plugins[$ac[0]])) {
				$ws = new $plugins[$ac[0]](trim($_POST['a']));
			} else {
				// no valid action
				$ws = false;
			}
			break;
	}
	// run action
	if ($ws === false) {
		header('Content-Type: application/json');
		exit(json_encode([
			'e' => -8, 
			'a' => trim($_POST['a']), 
			't' => date('c'), 
		]));
	} else {
		$ws->runRequest();
	}
}