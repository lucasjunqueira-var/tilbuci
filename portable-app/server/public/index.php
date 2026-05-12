<?php
if (isset($_GET['mv']) || isset($_GET['md'])) {
	session_start();
	if (isset($_GET['md'])) {
		$_SESSION['md'] = trim($_GET['md']) == 'editor' ? 'editor' : 'player';
	} else {
		$_SESSION['md'] = 'player';	
	}
	if (isset($_GET['mv'])) {
		$_SESSION['mv'] = trim($_GET['mv']);
	}
	if (isset($_GET['sc'])) {
		$_SESSION['sc'] = trim($_GET['sc']);
	}
	if (isset($_GET['cch'])) {
		$_SESSION['cch'] = time();
	}
	header('Location: ./app/');
} else {
    header('Location: ./site/');
    /*
	?>

<!doctype html>
<html>
<head>
	<meta charset="utf-8">
	<title>TulBuci</title>
	<!--<meta id="viewport" name="viewport" content="width=device-width, maximum-scale=1.0, user-scalable=no" />-->
	<meta name="apple-mobile-web-app-capable" content="yes">
	<link rel="shortcut icon" type="image/png" href="./app/favicon.png">
	<meta property="og:title" content="TilBuci" />
	<meta property="og:url" content="https://tilbuci.com.br/" />
	<meta property="og:image" content="./app/shareimage.jpg" />
	<meta property="og:type" content="website" />
	<meta property="og:description" content="TilBuci is a free interactive animation software." />
	<style>
		* {
			margin: 0;
			padding: 0;
		}
		html, body {
			background-color: #000000;
			color: #FFFFFF;
			font-family: Segoe, "Segoe UI", "DejaVu Sans", "Trebuchet MS", Verdana, "sans-serif";
			text-align: center;
		}
		p {
			margin: 0 0 20px 0;
			font-size: 20px;
		}
		a:link, a:visited {
			color: #FFEF00;
			text-decoration: none;
		}
		a:hover, a:active {
			text-decoration: underline;
		}
		iframe {
			margin: 10px 0;
			border: solid 1px #FFEF00;
		}
		#logo {
			border: none;
			margin: 10px 0;
		}
		@media (max-width: 1024px) {
			#logo {
				margin: 50px 0;
			}
			iframe {
				width: 90%;
				min-height: 500px;
				border: solid 2px #FFEF00;
				margin: 30px 0 50px 0;
			}
			p {
				margin: 0 0 30px 0;
			}
			a {
				margin-bottom: 5px;
				display: block;
			}
		}
	</style>
</head>
<body>
	<img id="logo" src="./files/tilbucilogo.png" alt="TilBuci" />
	<p>
		TilBuci is a free interactive animation software.
		<br />
		<small>(I promise we'll have a proper site here soon.)</small>
	</p>
	<iframe width="560" height="315" src="https://www.youtube.com/embed/P1MxAHrJMMM?si=XbTWvaDkZG-uk3Js" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>
	<p>
		<a href="https://tilbuci.com.br/app/">Check out TilBuci in action!</a>
		<br />
		<a href="https://www.youtube.com/playlist?list=PLjJLo5ynGY5xRoMj6Ku_GGkwVJJ-GYspm" target="_blank">View the "Getting started with TIlBuci" video playlist.</a>
		<br />
		<a href="https://github.com/lucasjunqueira-var/tilbuci" target="_blank">Visit the source code repository.</a>
		<br />
		<a href="https://tilbuci.com.br/files/TilBuci-ScriptingActions.pdf" target="_blank">Download the scripting actions manual.</a>
		<br />
		<a href="https://github.com/lucasjunqueira-var/tilbuci/releases">Download the TilBuci installer.</a>
	</p>
</body>
</html>

	<?php
    */
}
?>