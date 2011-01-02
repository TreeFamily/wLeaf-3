<?php
session_start();
if(isset($_GET['js'])) {
	header("content-type: text/javascript");
	echo <<<JAVASCRIPT
var elem;

var scrollToBottom = true;

$(document).ready(function(){
	setInterval("updateLog()",1000);
	elem = $('#log pre');
	if ((elem[0].scrollHeight - elem.scrollTop() == elem.outerHeight()) || (elem[0].scrollHeight - elem.scrollTop() + 17 == elem.outerHeight())) {
		scrollLock = true;
	}
	$("#scrollDown").click(function(){
		if(scrollToBottom){
			scrollToBottom = false
		} else {
			scrollToBottom = true
		}
		$(this).text("Scroll Lock: " +scrollToBottom.toString())
	});
});



function updateLog(){
	$.ajax({
		url: 'ajax.php?file',
		success: function(data) {
			if(data.length > 0) {
				$('#log pre').append(data);
			}
			$('#updated').text(new Date().toString());
			if(scrollToBottom){
				if (elem[0].scrollHeight - elem.scrollTop() != elem.outerHeight()) {
					$('#log pre').animate({scrollTop: $('#log pre')[0].scrollHeight});
				}
			}
		
		}
	});
}
JAVASCRIPT;

} elseif(isset($_GET['file'])) {
	$oldCount = $_SESSION['lineCount'];
	$file = file("log.html");
	$_SESSION["lineCount"] = count($file);
	for($i=$oldCount;$i<=$_SESSION['lineCount'];$i++){
		echo $file[$i];
	}
} else {
	header("Content-Type: text/html; charset=UTF-8");
	echo `head -n 200 /dev/urandom`;
}


?>
