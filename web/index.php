<?php 
session_start();
header("Content-Type: text/html; charset=UTF-8");

$_SESSION['lineCount'] = 9;
$scripts = "<script src='jquery.js' ></script>".PHP_EOL;
$scripts.= "<script src='ajax.php?js' ></script>".PHP_EOL;

$CSS = <<<STYLE
<style>
#log pre {
  width:  100%;
  height: 80%;
  overflow: auto;
  border: 1px solid black;
}
#updated {
	float: left;
}
#scrollDown {
	float: right;
	cursor: pointer;
	width: 115px;
}
#scrollDown:hover {
	text-decoration: underline;
}
</style>
STYLE;

$oldCount = $_SESSION['lineCount'];
$file = file("log.html");
$_SESSION["lineCount"] = count($file);
$log = str_replace('<pre style="font-family:Courier New;font-size:10pt;">',"",$file[8]);
for($i=$oldCount;$i<=$_SESSION['lineCount'];$i++){
	$log .= $file[$i];
}




echo "<html>
<head>
<title>wLeaf - Log</title>
".$scripts."
".$CSS."
</head>
<body>
wLeaf Logs:<br/>
<div id='log'><pre>".$log."</pre></div>
<div><div id='updated'></div><div id='scrollDown'>Scroll Lock: true</div></div>
</body>
</html>";

 ?>
