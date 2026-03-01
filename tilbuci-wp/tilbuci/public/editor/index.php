<?php
chdir(__DIR__);
session_start();
$_SESSION['md'] = 'editor';
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
if (isset($_POST['rd'])) {
	if ($_POST['rd'] == 'dom') $_SESSION['rd'] = 'dom';
} else if (isset($_GET['rd'])) {
	if ($_GET['rd'] == 'dom') $_SESSION['rd'] = 'dom';
}
if (isset($_POST['cch']) || isset($_GET['cch'])) {
	$_SESSION['cch'] = time();
}
if (isset($_GET['us']) && isset($_GET['uk'])) {
	$_SESSION['us'] = trim($_GET['us']);
	$_SESSION['uk'] = trim($_GET['uk']);
	$_SESSION['cch'] = time();
}
header('Location: ../app/');
?>