<?php
session_start();
$_SESSION['md'] = 'player';
if (isset($_POST['mv'])) {
	$_SESSION['mv'] = trim($_POST['mv']);
} else if (isset($_GET['mv'])) {
	$_SESSION['mv'] = trim($_GET['mv']);
}
if (isset($_POST['sc'])) {
	$_SESSION['sc'] = trim($_POST['sc']);
} else if (isset($_GET['sc'])) {
	$_SESSION['sc'] = trim($_GET['sc']);
}
if (isset($_POST['cch']) || isset($_GET['cch'])) {
	$_SESSION['cch'] = time();
}
header('Location: ./app/');
?>