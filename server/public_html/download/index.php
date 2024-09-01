<?php
 /** TIlBuci file downloader **/

// process request
if (isset($_GET['a'])) {
	if ((trim($_GET['a']) == 'download') && isset($_GET['file'])) {
		$path = '';
		$mime = '';
		$name = '';
		switch (trim($_GET['file'])) {
			case 'strings.json':
				if (isset($_GET['movie'])) {
					$path = '../movie/'.trim($_GET['movie']).'.movie/strings.json';
					if (is_file($path)) {
						$name = 'strings.json';
						$mime = 'application/json';
					}
				}
				break;
            case 'export':
				if (isset($_GET['movie'])) {
					$path = '../../export/'.$_GET['movie'].'.zip';
					if (is_file($path)) {
						$name = $_GET['movie'].'.zip';
						$mime = 'application/x-zip';
					}
				}
				break;
            case 'website':
				if (isset($_GET['movie'])) {
					$path = '../../export/site-'.$_GET['movie'].'.zip';
					if (is_file($path)) {
						$name = 'site-'.$_GET['movie'].'.zip';
						$mime = 'application/x-zip';
					}
				}
				break;
            case 'pwa':
				if (isset($_GET['movie'])) {
					$path = '../../export/pwa-'.$_GET['movie'].'.zip';
					if (is_file($path)) {
						$name = 'pwa-'.$_GET['movie'].'.zip';
						$mime = 'application/x-zip';
					}
				}
				break;
            case 'pub':
				if (isset($_GET['movie'])) {
					$path = '../../export/publish-'.$_GET['movie'].'.zip';
					if (is_file($path)) {
						$name = 'publish-'.$_GET['movie'].'.zip';
						$mime = 'application/x-zip';
					}
				}
				break;
            case 'desk':
				if (isset($_GET['movie']) && isset($_GET['exp'])) {
					$path = '../../export/' . trim($_GET['exp']);
					if (is_file($path)) {
						$name = trim($_GET['exp']);
						$mime = 'application/x-zip';
					}
				}
				break;
            case 'events':
                if (isset($_GET['name'])) {
                    $path = '../../events/' . trim($_GET['name']);
                    if (is_file($path)) {
                        $name = trim($_GET['name']);
                        $mime = 'text/csv';
                    }
                }
                break;
			default:
				http_response_code(404); 
				exit();
		}
		if ($mime == '') {
			exit();
		} else {
			// download file
			header("Content-Type: $mime");
			header("Content-Transfer-Encoding: Binary");
			header("Content-disposition: attachment; filename=\"" . basename($name) . "\"");
			header("Expires: 0"); 
            header("Cache-Control: must-revalidate"); 
            header("Pragma: public"); 
            header("Content-Length: " . filesize($path));
			flush();
			readfile($path);
			exit();
		}
	} else {
		http_response_code(404); 
		exit();
	}
} else {
	http_response_code(404); 
	exit();
}