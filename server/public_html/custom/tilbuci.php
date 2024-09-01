<?php
// prepare return
$ret = [
	'queryok' => [ 't' => 'B', 'v' => false ], 
	'queryname' => [ 't' => 'B', 'v' => false ], 
	'queryresults' => [ 't' => 'S', 'v' => 0 ], 
];
// data sent?
if (isset($_POST['data'])) {
	$json = json_decode($_POST['data'], true);
	// valid data?
	if (json_last_error() == JSON_ERROR_NONE) {
		// enough data?
		if (count($json) > 0) {
			// query bing
			$tryyahoo = false;
			$query = urlencode($json[0]);
			$ch = curl_init();
			curl_setopt($ch, \CURLOPT_URL, 'https://www.bing.com/search?q=' . $query);
			curl_setopt($ch, \CURLOPT_RETURNTRANSFER, true);
			curl_setopt($ch, \CURLOPT_HTTPGET, 1);
			$res = curl_exec($ch);
			curl_close($ch);
			// checking out bing response
			if (($res !== false) && ($res != '')) {
				$ini = strpos($res, 'sb_count');
				if ($ini !== false) {
					$text = substr($res, $ini);
					$end = strpos($text, '<');
					if ($end !== false) {
						$text = substr($text, 0, $end);
						$arr = explode(' ', trim($text));
						foreach ($arr as $v) {
							if (is_numeric(str_replace(['.', ','], '', $v))) {
								// number of results found!
								$ret['queryok']['v'] = true;
								$ret['queryname']['v'] = true;
								$ret['queryresults']['v'] = $v;
							}
						}
					}
				} else {
					$tryyahoo = true;
				}
			} else {
				$tryyahoo = true;
			}
			// try yahoo?
			if ($tryyahoo) {
				$ch = curl_init();
				curl_setopt($ch, \CURLOPT_URL, 'https://br.search.yahoo.com/search?p=' . $query);
				curl_setopt($ch, \CURLOPT_RETURNTRANSFER, true);
				curl_setopt($ch, \CURLOPT_HTTPGET, 1);
				$res = curl_exec($ch);
				curl_close($ch);
				if (($res !== false) && ($res != '')) {
					$ini = strpos($res, 'Cerca de');
					if ($ini !== false) {
						$text = substr($res, $ini);
						$end = strpos($text, 'de busca');
						if ($end !== false) {
							$text = substr($text, 0, $end);
							$arr = explode(' ', trim($text));
							foreach ($arr as $v) {
								if (is_numeric(str_replace(['.', ','], '', $v))) {
									// number of results found!
									$ret['queryok']['v'] = true;
									$ret['queryname']['v'] = true;
									$ret['queryresults']['v'] = $v;
								}
							}
						}
					} else {
						// nothing found
						$ret['queryok']['v'] = true;
						$ret['queryname']['v'] = false;
						$ret['queryresults']['v'] = '';
					}
				}
			}
		}
	}
}
// returning
exit(json_encode($ret));