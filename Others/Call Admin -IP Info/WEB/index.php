<?php
define("key", TRUE);
include "./includes/config.php";
?>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title></title>
    </head>
    <body>
        <script language="JavaScript">
        var countDownInterval=<?php echo "$last_calls_refresh_count"; ?>;
        var c_reloadwidth=200
        </script>
        <ilayer id="c_reload" width=&{c_reloadwidth}; ><layer id="c_reload2" width=&{c_reloadwidth}; left=0 top=0></layer></ilayer>
        <script>
        var countDownTime=countDownInterval+1;
        function countDown(){
        countDownTime--;
        if (countDownTime <=0){
        countDownTime=countDownInterval;
        clearTimeout(counter)
        window.location.reload()
        return
        }
        if (document.all)
        document.all.countDownText.innerText = countDownTime+" ";
        else if (document.getElementById)
        document.getElementById("countDownText").innerHTML=countDownTime+" "
        else if (document.layers){
        document.c_reload.document.c_reload2.document.write('<div style="font-size: <?php echo "$counter_font_size"; ?>px;">Страницата ще се <a href="javascript:window.location.reload()">рефрешне</a> след <b id="countDownText">'+countDownTime+' </b> секунди!</div>')
        document.c_reload.document.c_reload2.document.close()
        }
        counter=setTimeout("countDown()", 1000);
        }
        function startit(){
        if (document.all||document.getElementById)
        document.write('<div style="font-size: <?php echo "$counter_font_size"; ?>px;">Страницата ще се <a href="javascript:window.location.reload()">рефрешне</a> след <b id="countDownText">'+countDownTime+' </b> секунди!</div>')
        countDown()
        }
        if (document.all||document.getElementById)
        startit()
        else
        window.onload=startit
        </script>
        <table>
            <?php
            $query = "SELECT * FROM `$table` ORDER by `id` DESC LIMIT 0,$last_calls_count";
			$data = mysqli_query($conn, "SELECT * FROM $table ORDER BY id DESC LIMIT 0,$last_calls_count") or die(mysqli_error($conn));
            
			if( mysqli_num_rows($data) > 0) 
			{
				
				while($row = mysqli_fetch_assoc($data)) {
					
					$secure_nick		= mysqli_real_escape_string($conn, $row['nick']);
					$secure_reporter	= mysqli_real_escape_string($conn, $row['reporter_name']);
					$secure_reason		= mysqli_real_escape_string($conn, $row['report']);
					$ip2				= mysqli_real_escape_string($conn, $row['ip2']);
					echo 
					"
					
						<div style='border-top: 1px solid $border_color; font-size: $font_size;'>
						
							<b>Сървър: <font color='$servername_color'>$row[server]</font> <font color='$serverip_color'>($row[ip])</font></b> | 
							<b><font color='$date_color'>$row[date]</font></b> в 
							<b><font color='$time_color'>$row[time]</font></b> | 
							<b>Нарушител: <font color='$nick_color'>$secure_nick ($ip2)</font></b> | |
							<b>Докладван от: <font color='$reporter_color'>$secure_reporter</font></b> :
							<b>Причина: <font color='$reason_color'>$secure_reason</font></b>
							
						</div>
						
					";
				}
				
			}
            ?>
        </table>
    </body>
</html>
