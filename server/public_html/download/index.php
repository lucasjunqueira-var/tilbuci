<?php
/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 /** TIlBuci file downloader **/

/** CLASS DEFINITIONS **/
chdir(__DIR__);
require_once('../../app/Data.php');
$prefix = preg_replace('/[^a-zA-Z0-9_]/', '', $data->conf['databasePrefix']);
$movie = isset($_GET['movie']) ? preg_replace('/[^a-zA-Z0-9_-]/', '', $_GET['movie']) : '';
$media = isset($_GET['media']) ? preg_replace('/[^a-zA-Z0-9_-]/', '', $_GET['media']) : '';

// process request
if (isset($_GET['a'])) {
	if ((trim($_GET['a']) == 'download') && isset($_GET['file'])) {
		$path = '';
		$mime = '';
		$name = '';
		$image = '';
		switch (trim($_GET['file'])) {
            case 'snippets':
                if (isset($_GET['movie']) && isset($_GET['media'])) {
                    $data = new Data;
                    $media = str_replace(['.json', ' '], '', mb_strtolower($media));
                    $ck = $data->queryAll('SELECT `sn_content` FROM `' . $prefix . 'snippets` WHERE `sn_movie`=:mv AND `sn_file`=:fl', [':mv' => $movie, ':fl' => $media]);
                    if (count($ck) > 0) {
                        file_put_contents(('../../export/'.$movie.'-snippets.json'), gzdecode(base64_decode($ck[0]['sn_content'])));
                        $path = '../../export/'.$movie.'-snippets.json';
                        if (is_file($path)) {
                            $name = $media.'.json';
                            $mime = 'application/json';
                        }
                    }
                }
                break;
			case 'strings':
                if (isset($_GET['movie']) && isset($_GET['media'])) {
                    $data = new Data;
                    $media = str_replace(['.json', ' '], '', mb_strtolower($media));
                    $ck = $data->queryAll('SELECT `st_content` FROM `' . $prefix . 'strings` WHERE `st_movie`=:mv AND `st_file`=:fl', [':mv' => $movie, ':fl' => $media]);
                    if (count($ck) > 0) {
                        file_put_contents(('../../export/'.$movie.'-string.json'), gzdecode(base64_decode($ck[0]['st_content'])));
                        $path = '../../export/'.$movie.'-string.json';
                        if (is_file($path)) {
                            $name = $media.'.json';
                            $mime = 'application/json';
                        }
                    }
                }
                break;
			case 'strings.json':
				if (isset($_GET['movie'])) {
                    $data = new Data;
                    $ck = $data->queryAll('SELECT `mv_strings` FROM `' . $prefix . 'movies` WHERE `mv_id`=:mv', [':mv' => $movie]);
                    if (count($ck) > 0) {
                        file_put_contents(('../../export/'.$movie.'-string.json'), gzdecode(base64_decode($ck[0]['mv_strings'])));
                        $path = '../../export/'.$movie.'-string.json';
                        if (is_file($path)) {
                            $name = 'strings.json';
                            $mime = 'application/json';
                        }
                    }
				}
				break;
            case 'export':
				if (isset($_GET['movie'])) {
					$path = '../../export/'.$movie.'.zip';
					if (is_file($path)) {
						$name = $movie.'.zip';
						$mime = 'application/x-zip';
					}
				}
				break;
            case 'website':
				if (isset($_GET['movie'])) {
					$path = '../../export/site-'.$movie.'.zip';
					if (is_file($path)) {
						$name = 'site-'.$movie.'.zip';
						$mime = 'application/x-zip';
					}
				}
				break;
            case 'pwa':
				if (isset($_GET['movie'])) {
					$path = '../../export/pwa-'.$movie.'.zip';
					if (is_file($path)) {
						$name = 'pwa-'.$movie.'.zip';
						$mime = 'application/x-zip';
					}
				}
				break;
			case 'makers':
				if (isset($_GET['movie'])) {
					$path = '../../export/makers-'.$movie.'.zip';
					if (is_file($path)) {
						$name = 'makers-'.$movie.'.zip';
						$mime = 'application/x-zip';
					}
				}
				break;
            case 'pub':
				if (isset($_GET['movie'])) {
					$path = '../../export/publish-'.$movie.'.zip';
					if (is_file($path)) {
						$name = 'publish-'.$movie.'.zip';
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
			case 'qrcode':
                if (isset($_GET['link']) && isset($_GET['name'])) {
					$link = base64_decode($_GET['link']);
					if ($link !== false) {
						require_once('../../third/qrcode.php');
						$qr = new QRCode($link, [ 'w' => 2048, 'h' => 2048 ]);
						$image = $qr->render_image();
						$mime = 'qrcode';
						$name = 'qrcode-' . trim($_GET['name']) . '.png';
					}
                }
                break;
			default:
				http_response_code(404); 
				exit();
		}
		if ($mime == '') {
			exit();
		} else if ($mime == 'qrcode') {
			// download qrcode png
			header("Content-Type: image/png");
			header("Content-Transfer-Encoding: Binary");
			header("Content-disposition: attachment; filename=\"" . $name . "\"");
			header("Expires: 0"); 
            header("Cache-Control: must-revalidate"); 
            header("Pragma: public"); 
			imagepng($image);
			imagedestroy($image);
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