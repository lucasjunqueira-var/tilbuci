<?php
// launcher version
$version = 14;

// running from launcher?
require_once('../../app/Data.php');
if (!isset($gconf['databaseServ']) || ($gconf['databaseServ'] != 'sqlite')) {
	// not running from launcher app
	header('Location: ../app/');
} else {

	// interface presets
	function intHeader($pg) {
		$bg = 'bgbuci'.sprintf('%02d', rand(1, 5)).'.jpg';
		?>

<!DOCTYPE html>
<html>
	<head>
		<meta charset="UTF-8" />
		<title>TilBuci Launcher</title>
		<style>
			body, html {
				padding: 10px;
				margin: 0;
				box-sizing: border-box;
				background-color: #666666;
				color: #dadada;
				font-family: 'Lucida Sans', 'Lucida Sans Regular', 'Lucida Grande', 'Lucida Sans Unicode', Geneva, Verdana, sans-serif;
				font-size: 20px;
				background-image: url('launcher/<?= $bg ?>');
				overflow: hidden;
			}
			#holder {
				box-sizing: border-box;
				padding: 20px;
				border: 2px solid #dadada;
				background-color: rgba(102, 102, 102, 0.8);
				border-radius: 10px;
				width: 750px;
				height: 530px;
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
				font-size: 14px;
				border-radius: 10px;
				margin-bottom: 10px;
				margin-top: 20px;
				background-color: rgba(255, 255, 255, 0.1);
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
		</style>
	</head>
	<body>
		<div id="holder">

		<?php
	}

	function intFooter($pg) {
		?>

		</div>
	<body>
</html>

		<?php
	}

	// checking current page
	$page = isset($_GET['pg']) ? trim($_GET['pg']) : '';
	switch ($page) {
		
		case 'check': // checking if the php server is running
			// preparing local installation
			if (!is_dir('../movie')) @mkdir('../movie', 0777);
			if (!is_file('../movie/tilbuci.sqlite')) {
				@copy('../../database/tilbuci.sqlite', '../movie/tilbuci.sqlite');
			}
			// login
			$data = new Data;
			if(!$data->launcherLogin()) {
				// login error
				exit('error');
			} else {
				// start launcher interface
				exit('ok');
			}
			break;
			
		case 'home': // launcher home
			// getting launcher key
			$data = new Data;
			$key = $data->launcherKey();
			if ($key == '') {
				exit('no key');
			} else {
				intHeader($page);
				?>
				<div id="title">TilBuci Launcher <small>version <?= $version ?></small></div>
				<div class="button" onclick="api.openwindow('http://localhost:51804/editor/?us=single&uk=<?= $key ?>&cch=true')">
					<h1>Open TilBuci</h1>
					Start a new TilBuci workspace.
				</div>
				<div class="button" onclick="window.location='http://localhost:51804/ws/launcher.php?pg=learn'">
					<h1>Learn TilBuci</h1>
					Check out tutorials and tips about the software.
				</div>
				<div class="button" onclick="window.location='http://localhost:51804/ws/launcher.php?pg=backup'">
					<h1>Backup</h1>
					Manage content backups.
				</div>
				<div class="button" onclick="window.location='http://localhost:51804/ws/launcher.php?pg=update'">
					<h1>Update TilBuci</h1>
					Update your TilBuci version.
				</div>
				<div class="button" onclick="window.location='http://localhost:51804/ws/launcher.php?pg=about'">
					<h1>About</h1>
					Learn more about TilBuci and this launcher.
				</div>
				<div class="button" onclick="api.close()">
					<h1>Close</h1>
					Close this launcher.
				</div>
				<?php
				intFooter($page);
			}
			break;

		case 'backup': // backup folder
			file_put_contents(('../movie/version.txt'), ('TilBuci version '.$version));
			intHeader($page);
			?>
				<div id="title">Content backup</div>
				<p>To make a backup of your creations, just open your movies folder and copy all the contents of it. To restore the backup, just overwrite the contents of this folder, but be careful: always restore the contents to the same launcher version (currenlty <?= $version ?>).</p>
				<p>If you want to transfer a movie to another TilBuci installation, use the exchange functionality in the TilBuci workspace itself.</p>
				<div class="button" onclick="api.openfolder('movie/')">
					<h1>Open folder</h1>
					Open movies folder for backup.
				</div>
				<br />
				<div class="button" onclick="window.location='http://localhost:51804/ws/launcher.php?pg=home'">
					<h1>Back</h1>
				</div>
			<?php
			intFooter($page);
			break;

		case 'learn': // learn TilBuci
			intHeader($page);
			?>
				<div id="title">Learn TilBuci</div>
				<p>Check out online information about TilBuci and find out how to create your own content using the software.</p>
				<div class="button" onclick="api.openbrowser('https://tilbuci.com.br/site/getting-started-with-tilbuci/')">
					<h1>Getting started</h1>
					Basic information for beginners.
				</div>
				<div class="button" onclick="api.openbrowser('https://tilbuci.com.br/site/tutorials/')">
					<h1>Tutorials</h1>
					Step-by-step instructions for various types of content.
				</div>
				<div class="button" onclick="api.openbrowser('https://tilbuci.com.br/site/quick-tips/')">
					<h1>Quick tips</h1>
					Quick tips about the software.
				</div>
				<div class="button" onclick="api.openbrowser('https://tilbuci.com.br/files/TilBuci-ScriptingActions.pdf')">
					<h1>Scripting actions document</h1>
					Access the interaction creation manual.
				</div>
				<br />
				<div class="button" onclick="window.location='http://localhost:51804/ws/launcher.php?pg=home'">
					<h1>Back</h1>
				</div>
			<?php
			intFooter($page);
			break;

		case 'update': // update system
			intHeader($page);
			?>
				<div id="title">Updating TilBuci</div>
				<p>To update your TilBuci version, first download the latest release. Then, open a new workspace, access the "setup" menu on the left side, and select the "system update" tab. Upload the downloaded ZIP file and follow the instructions in the window that opens.</p>
				<div class="button" onclick="api.openbrowser('https://tilbuci.com.br/site/latest-version/')">
					<h1>Latest release</h1>
					Check out the TilBuci latest version.
				</div>
				<br />
				<div class="button" onclick="window.location='http://localhost:51804/ws/launcher.php?pg=home'">
					<h1>Back</h1>
				</div>
			<?php
			intFooter($page);
			break;

		case 'about': // about the launcher
			intHeader($page);
			?>
				<div id="title">About TilBuci</div>
				<p>TilBuci is a free, open-source tool licensed under the MPL-2.0. It runs as a web tool with features for collective creation. This launcher simplifies use for individual production. For this launcher, the Electron and the static-php-cli projects were used.</p>
				<div class="button" onclick="api.openbrowser('https://tilbuci.com.br/')">
					<h1>TilBuci website</h1>
				</div>
				<div class="button" onclick="api.openbrowser('https://github.com/lucasjunqueira-var/tilbuci')">
					<h1>Code repository</h1>
				</div>
				<div class="button" onclick="api.openbrowser('https://www.mozilla.org/en-US/MPL/2.0/')">
					<h1>License (MPL-2.0)</h1>
				</div>
				<div class="button" onclick="api.openbrowser('https://www.electronjs.org/')">
					<h1>Electron</h1>
				</div>
				<div class="button" onclick="api.openbrowser('https://github.com/crazywhalecc/static-php-cli')">
					<h1>static-php-cli project</h1>
				</div>
				<div class="button" onclick="window.location='http://localhost:51804/ws/launcher.php?pg=home'">
					<h1>Back</h1>
				</div>
			<?php
			intFooter($page);
			break;
		
		default: // no page set
			header('Location: ../app/');
			break;
	}
}