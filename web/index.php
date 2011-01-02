<?php 
session_start();
header("Content-Type: text/html; charset=UTF-8");
$noPass = false;

if($_SERVER["REQUEST_METHOD"] == "POST"){
	if((isset($_POST['auth'])) || $_SESSION["loggedIn"]){
		$sha1Pass = sha1($_POST['pass']);
		$sql = mysql_connect("localhost","werring","TWWT") or die("could not connect: " . mysql_error() . PHP_EOL);
		$qry =
		<<<SQL
SELECT COUNT(*) FROM `rubyTest`.`team` WHERE `auth`='$_POST[auth]' AND `passwd`='$sha1Pass'
SQL;
		$res = mysql_query($qry,$sql) or die("could not exec query: " . mysql_error() . PHP_EOL);
		$returnVal = mysql_fetch_assoc($res);
		$_SESSION["loggedIn"] = ($returnVal["COUNT(*)"] > 0);
		if (!$_SESSION["loggedIn"]) {
			
			$qry = <<<SQL
SELECT COUNT(*) FROM `rubyTest`.`team` WHERE `auth`='$_POST[auth]' AND `passwd` IS NULL
SQL;
			$res = mysql_query($qry,$sql) or die("could not exec query: " . mysql_error() . PHP_EOL);
			$returnVal = mysql_fetch_assoc($res);
			$noPass = ($returnVal["COUNT(*)"]>0);
		}
	}
}





$_SESSION['lineCount'] = 9;
$JS = "<script src='jquery.js'></script>".PHP_EOL;
$JS.= "<script src='ajax.php?js'></script>".PHP_EOL;

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



if($_SESSION['loggedIn']){
	echo "
<html>
	<head>
		<title>wLeaf - Log</title>
		".$JS."
		".$CSS."
	</head>
	<body>
		wLeaf Logs:<br/>
		<div id='log'>
			<pre>".$log."</pre>
		</div>
		<div>
			<div id='updated'></div>
			<div id='scrollDown'>Scroll Lock: true</div>
		</div>
	</body>
</html>";
} elseif(!$noPass) {
	echo <<<HTML
<html>
	<head>
		<title>wLeaf - Log</title>
		$JS
		$CSS
	</head>
	<body>
		<fieldset>
			<legend>Login</legend>
			<form name='login' method="POST" action="/">
				<dl>
					<dt>Authnaam
					<dd><input type="text" name="auth" />
					<dt>Password
					<dd><input type="password" name="pass" />
					<dt>Verzend
					<dd><input type="submit" value="Log in" />
				</dl>	
			</form>
		</fieldset>
	</body>
</html>
HTML;

} else {
	echo <<<HTML
	<html>
	<head>
		<title>wLeaf - Log</title>
		$JS
		$CSS
	</head>
	<body>
		<fieldset>
			<legend>Login</legend>
			Sorry you haven't setted your web password,<br /> 
			please set your password on IRC by using the createwebpass command.
		</fieldset>
	</body>
</html>
HTML;
}

?>