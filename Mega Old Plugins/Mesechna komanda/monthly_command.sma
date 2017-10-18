#include <amxmodx>

public plugin_init(){
	register_plugin("Month command", "1.0", "AnHiMiLaToR aka benz")
	register_logevent("round_end", 2, "1=Round_End");
}

new year, month, day, done, sbor;

public round_end(){
	date(year,month,day)
	sbor=year+month+day;
	if(day==1 && done!=sbor){ //day== 1 (the number only) is the day to execute the command every month
		done = sbor;
server_cmd("csstat_reset 1"); //Command to execute every month
}
return PLUGIN_CONTINUE 
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1026\\ f0\\ fs16 \n\\ par }
*/
