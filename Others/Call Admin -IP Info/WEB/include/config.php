<?php
	if(!defined("key")) 
	{
		header("Location: ./index.php");
	}


	// Данни за връзката
	$host	= "localhost"; // host (ip/domain)
	$user	= "root"; // потребител
	$pass	= "gffg@7"; // парола
	$db		= "test"; // име на базата данни
	$table	= "call_admin"; // име на таблицата


	// Свързване
	$conn = mysqli_connect($host, $user, $pass);
	mysqli_select_db($conn, $db);


	//Настройки
	$last_calls_count = "10"; //колко последни викания на админ да показва
	$last_calls_refresh_count = "20"; //на колко секунди да рефрешва страницата
	$servername_color = "blue"; //цвят за сървър име
	$serverip_color = "orange"; // цвят за сървър ип
	$date_color = "grey"; //цвят за датата
	$time_color = "blue"; //цвят на часа
	$nick_color = "red"; //цвят на ника + ип-то на хакера
	$reason_color = "red"; //цвят на причината
	$reporter_color = "green"; //цвят на името на докладващият
	$border_color = "blue"; //цвят на ограждението
	$font_size = "20"; //големина на шрифта на самият текст
	$counter_font_size = "15"; //големина на шрифта за брояча
?>
