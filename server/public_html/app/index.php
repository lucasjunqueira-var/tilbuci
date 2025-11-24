<?php
/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

// addicional scripts
chdir(__DIR__);
require_once('../../app/Data.php');
$data = new Data;

// plugins
$list = $data->pluginIndex();
$plugins = [ ];
foreach ($list as $v) {
	if (is_file('../../app/' . $v['fl'] . '.php')) {
		require_once('../../app/' . $v['fl'] . '.php');
		$plugins[$v['id']] = new $v['fl'];
	}	
}

// TilBuci version
$version = $data->version();

// checking what to display
session_start();
$mode = 'player';
$movie = '';
$scene = '';
$nocache = '';
$cssmovie = '';
$render = '';
$userlogin = '';
if (isset($_SESSION['md']) && (trim($_SESSION['md']) == 'editor')) {
	$mode = 'editor';
	unset($_SESSION['md']);
} elseif (isset($_POST['md']) && (trim($_POST['md']) == 'editor')) {
	$mode = 'editor';
} else if (isset($_GET['md']) && (trim($_GET['md']) == 'editor')) {
	$mode = 'editor';
}
if (isset($_SESSION['mv'])) {
	$movie = trim($_SESSION['mv']);
	unset($_SESSION['mv']);
} else if (isset($_POST['mv'])) {
	$movie = trim($_POST['mv']);
} else if (isset($_GET['mv'])) {
	$movie = trim($_GET['mv']);
}
if (isset($_SESSION['sc'])) {
	$scene = trim($_SESSION['sc']);
	unset($_SESSION['sc']);
} else if (isset($_POST['sc'])) {
	$scene = trim($_POST['sc']);
} else if (isset($_GET['sc'])) {
	$scene = trim($_GET['sc']);
}
if (isset($_SESSION['cch'])) {
	$nocache = '?rand=' . time().rand(1000, 9999);
	unset($_SESSION['cch']);
} else if (isset($_POST['cch'])) {
	$nocache = '?rand=' . time().rand(1000, 9999);
} else if (isset($_GET['cch'])) {
	$nocache = '?rand=' . time().rand(1000, 9999);
}
if (isset($_SESSION['rd'])) {
    if ($_SESSION['rd'] == 'dom') $render = '-dom';
	unset($_SESSION['rd']);
} else if (isset($_POST['rd'])) {
	if ($_POST['rd'] == 'dom') $render = '-dom';
} else if (isset($_GET['rd'])) {
	if ($_GET['rd'] == 'dom') $render = '-dom';
}
if (isset($_SESSION['us']) && isset($_SESSION['uk'])) {
    $userlogin = ', "us": "'.trim($_SESSION['us']).'", "uk": "'.trim($_SESSION['uk']).'"';
	unset($_SESSION['us']);
	unset($_SESSION['uk']);
} else if (isset($_POST['us']) && isset($_POST['uk'])) {
	$userlogin = ', "us": "'.trim($_POST['us']).'", "uk": "'.trim($_POST['uk']).'"';
} else if (isset($_GET['us']) && isset($_GET['uk'])) {
	$userlogin = ', "us": "'.trim($_GET['us']).'", "uk": "'.trim($_GET['uk']).'"';
}


// sharing and render information
$favicon = './favicon.png';
$title = 'TilBuci';
$about = 'TilBuci is a free interactive animation software.';
$tags = 'tilbuci,interactive,animation,digital,content';
$image = 'shareimage.jpg';
$link = '';
$baselink = '';
if (is_file('player.json')) {
	$json = json_decode(file_get_contents('player.json'), true);
	if (json_last_error() == JSON_ERROR_NONE) {
		$baselink = $json['base'];
		$link = $json['base'] . 'app/';
		if (isset($json['render'])) {
			if ($json['render'] == 'dom') $render = '-dom';
		}
	}
}
if ($mode != 'editor') {
	if ($movie != '') {
		$link .= '?mv='.urlencode($movie);
        $ck = $data->queryAll('SELECT mv_title, mv_about, mv_tags, mv_favicon, mv_image FROM movies WHERE mv_id=:mv', [':mv'=>$movie]);
        if (count($ck) > 0) {
            $title = $ck[0]['mv_title'];
            $about = $ck[0]['mv_about'];
            $tags = $ck[0]['mv_tags'];
            if (($ck[0]['mv_favicon'] != '') && ($baselink != '')) $favicon = $baselink . 'movie/' . $movie . '.movie/media/picture/' . $ck[0]['mv_favicon'];
            if (($ck[0]['mv_image'] != '') && ($baselink != '')) $image = $baselink . 'movie/' . $movie . '.movie/media/picture/' . $ck[0]['mv_image'];
        }
		if ($scene != '') {
			$link .= '&sc='.urlencode($scene);
            $ck = $data->queryAll('SELECT sc_title, sc_about, sc_image FROM scenes WHERE sc_movie=:mv AND sc_id=:id', [':mv'=>$movie, ':id'=>$scene]);
            if (count($ck) > 0) {
                $title = $ck[0]['sc_title'];
                if ($ck[0]['sc_about'] != '') $about = $ck[0]['sc_about'];
                if (($ck[0]['sc_image'] != '') && ($baselink != '')) $image = $baselink . 'movie/' . $movie . '.movie/media/picture/' . $ck[0]['sc_image'];
            }
		}
		$cssmovie = $movie;
	} else {
		$movie = $json['start'];
		$ck = $data->queryAll('SELECT mv_title, mv_about, mv_tags, mv_favicon, mv_image FROM movies WHERE mv_id=:mv', [':mv'=>$movie]);
        if (count($ck) > 0) {
            $title = $ck[0]['mv_title'];
            $about = $ck[0]['mv_about'];
            $tags = $ck[0]['mv_tags'];
            if (($ck[0]['mv_favicon'] != '') && ($baselink != '')) $favicon = $baselink . 'movie/' . $movie . '.movie/media/picture/' . $ck[0]['mv_favicon'];
            if (($ck[0]['mv_image'] != '') && ($baselink != '')) $image = $baselink . 'movie/' . $movie . '.movie/media/picture/' . $ck[0]['mv_image'];
        }
		$cssmovie = $movie;
		$movie = '';
	}
} else {
	$link .= '?md=editor';
}
if ($render == '') {
    if ($mode != 'player') $render = '';
    if (isset($_GET['rd'])) {
        if (trim($_GET['rd']) == 'dom') {
            $render = '-dom';
        }
    }
}
?>
<!DOCTYPE html>
<html lang="en">
<head>	
	<meta charset="utf-8">
	<title><?= $title ?></title>
	<meta id="viewport" name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no" />
	<meta name="apple-mobile-web-app-capable" content="yes">
	<link rel="shortcut icon" type="image/png" href="<?= $favicon ?>">
	<meta property="og:title" content="<?= $title ?>" />
	<meta property="og:url" content="<?= $link ?>" />
	<meta property="og:image" content="<?= $image ?>" />
	<meta property="og:type" content="website" />
	<meta property="og:description" content="<?= $about ?>" />
	<?php
		// head plugin area
		foreach($plugins as $pl) {
			echo("\r\n" . $pl->indexHead($mode) . "\r\n\r\n");
		}
	?>
    <?php if ($nocache == '') { ?>
        <script type="text/javascript" src="./TilBuci<?= $render ?>-min.js?rd=<?= $version ?>"></script>
    <?php } else { ?>
        <script type="text/javascript" src="./TilBuci<?= $render ?>.js<?= $nocache ?>"></script>
    <?php } ?>
	<script>
		window.addEventListener ("touchmove", function (event) { event.preventDefault (); }, { capture: false, passive: false });
		if (typeof window.devicePixelRatio != 'undefined' && window.devicePixelRatio > 2) {
			var meta = document.getElementById ("viewport");
			meta.setAttribute ('content', 'width=device-width, initial-scale=' + (2 / window.devicePixelRatio) + ', user-scalable=no');
		}
	</script>
	<style>
		<?= $data->indexFonts($cssmovie) ?>
		html,body { margin: 0; padding: 0; height: 100%; overflow: hidden; background-color: #666666; }
		#TilBuciArea { margin: 0; padding: 0; height: 100%; width: 100%; overflow: hidden; background: #000000; }
		#openfl-content { background: #000000; width: 100%; height: 100%; }
        #embed_area { position: absolute; left: 0; top: 0; display: none; padding: 0; width: 100%; height: 100%; box-sizing: content-box; margin: 0; border: none; overflow: hidden; background-color: transparent; }
        #embed_frame { display: none; padding: 0; box-sizing: content-box; margin: 0; border: none; width: 100%; height: 100%; background-color: transparent; }
	</style>
</head>
<body>
	<div id="TilBuciArea">
		<noscript>This webpage makes extensive use of JavaScript. Please enable JavaScript in your web browser to view this page.</noscript>
		<div id="openfl-content"></div>
		<script type="text/javascript">
			lime.embed ("TilBuci", "openfl-content", 0, 0, { parameters: { "mode" : "<?= $mode ?>", "movie": "<?= $movie ?>", "scene": "<?= $scene ?>" <?= $userlogin ?>} });
		</script>
		<?php
			// end body plugin area
			foreach($plugins as $pl) {
				echo("\r\n" . $pl->indexEndBody() . "\r\n\r\n");
			}
		?>
		<div id="embed_area"><iframe id="embed_frame" width="0" height="0" src="" frameborder="0"></iframe></div>
	</div>
</body>
</html>