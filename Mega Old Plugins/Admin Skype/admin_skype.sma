#include <amxmodx>

#define VERSION "2.1"
#define TAG "CAAOS"

new pcv_skype_toggle, pcv_skype_type, pcv_skype_num, pcv_motd_message, pcv_motd_message2, pcv_announce_time, pcv_announce_message, pcv_message_color, pcv_motd_sec, pcv_skype, pcv_skype2, pcv_skype3
new g_SayText

public plugin_init() {
	register_plugin("Contact an Admin on Skype", VERSION, "rapara13");
	register_cvar("CAAOS", VERSION, FCVAR_SERVER|FCVAR_SPONLY)
	
	register_clcmd("say !admin", "cmdShowAdmin");
	register_clcmd("say /admin", "cmdShowAdmin");
	register_clcmd("say !skype", "cmdShowAdmin");
	register_clcmd("say /skype", "cmdShowAdmin");
	register_clcmd("say !hacker", "cmdShowAdmin");
	register_clcmd("say /hacker", "cmdShowAdmin");
	register_clcmd("say /calladmin", "cmdShowAdmin");
	register_clcmd("say /call-admin", "cmdShowAdmin");
	register_clcmd("say calladmin", "cmdShowAdmin");
	register_clcmd("say call-admin", "cmdShowAdmin");
	register_clcmd("say !calladmin", "cmdShowAdmin");
	register_clcmd("say !call-admin", "cmdShowAdmin");

	pcv_skype_toggle = register_cvar("as_toggle", "1")
	pcv_skype_type = register_cvar("as_type", "1")
	pcv_skype_num = register_cvar("as_num_skypes", "1")
	
	pcv_skype = register_cvar("as_admin_skype", "xd-gaming2.info_support")
	pcv_skype2 = register_cvar("as_admin_skype2", "YourSkypeHere2") // Only if as_num_skype is 2 or 3 in as_type 1
	pcv_skype3 = register_cvar("as_admin_skype3", "YourSkypeHere3") // Only if as_num_skype is 3 in as_type 1
	
	pcv_motd_sec = register_cvar("as_motd_sec", "2")
	pcv_motd_message = register_cvar("as_motd_message","For contact with admin press on image!")
	pcv_motd_message2 = register_cvar("as_motd_message2","Please wait a sec!")
	pcv_message_color = register_cvar("as_motd_message_color", "white")
	
	pcv_announce_time = register_cvar("as_announce_time", "60")
	pcv_announce_message = register_cvar("as_announce_message", "For contact with admin write say /calladmin or !admin")
	
	g_SayText = get_user_msgid("SayText")
	
	set_task(get_pcvar_float(pcv_announce_time),"announce",0,"",0,"b") 
}

public cmdShowAdmin(id) {
	if(!get_pcvar_num(pcv_skype_toggle))
		return;
	
	static motd[1501], len;
	new skype[200], skype2[200], skype3[200], message[200], message2[200], sec[200], color[200]
	get_pcvar_string(pcv_skype, skype, charsmax(skype))
	get_pcvar_string(pcv_skype2, skype2, charsmax(skype2))
	get_pcvar_string(pcv_skype3, skype3, charsmax(skype3))
	get_pcvar_string(pcv_motd_message, message, charsmax(message))
	get_pcvar_string(pcv_motd_message2, message2, charsmax(message2))
	get_pcvar_string(pcv_message_color, color, charsmax(color))
	get_pcvar_string(pcv_motd_sec, sec, charsmax(sec))
		
	switch(get_pcvar_num(pcv_skype_type)) {
		case 1: {
			len = format(motd, 1500,"<script type=^"text/javascript^" src=^"http://download.skype.com/share/skypebuttons/js/skypeCheck.js^"></script><body bgcolor=^"#202020^"><pre>");
			len += format(motd[len], 1500-len,"<center><img src=^"http://img693.imageshack.us/img693/2153/headerrb.png^"></center>");
			len += format(motd[len], 1500-len,"<table align=^"center^">");
			len += format(motd[len], 1500-len,"<tr><td align=^"center^" style=^"border: 1px #000 solid; background: #151515; color: %s^">%s</td></tr>", color, message);
			len += format(motd[len], 1500-len,"<tr><td align=^"center^" style=^"border: 1px #000 solid; background: #151515^"><a href=^"skype:%s?chat^"><img src=^"http://mystatus.skype.com/smallclassic/%s^" style=^"border: none;^" width=^"114^" height=^"20^" /></a></td></tr>^n", skype, skype);
			if(get_pcvar_num(pcv_skype_num) == 2 || get_pcvar_num(pcv_skype_num) == 3) len += format(motd[len], 1500-len,"<tr><td align=^"center^" style=^"border: 1px #000 solid; background: #151515^"><a href=^"skype:%s?chat^"><img src=^"http://mystatus.skype.com/smallclassic/%s^" style=^"border: none;^" width=^"114^" height=^"20^" /></a></td></tr>^n", skype2, skype2);
			if(get_pcvar_num(pcv_skype_num) == 3) len += format(motd[len], 1500-len,"<tr><td align=^"center^" style=^"border: 1px #000 solid; background: #151515^"><a href=^"skype:%s?chat^"><img src=^"http://mystatus.skype.com/smallclassic/%s^" style=^"border: none;^" width=^"114^" height=^"20^" /></a></td></tr>^n", skype3, skype3);
			len += format(motd[len], 1500-len,"<tr><td align=^"center^" style=^"border: 1px #000 solid; background: #151515; color: green^">Contact an Admin on Skype</td></tr>", VERSION);
			len += format(motd[len], 1500-len,"</table>");
	
			show_motd(id, motd, "Contact an Admin on Skype");
		} 
		case 2: {
			len = format(motd, 1500,"<body bgcolor=^"#202020^"><META HTTP-EQUIV=^"Refresh^" CONTENT=^"%s; URL=skype:%s?chat^"><pre>", sec, skype);
			len += format(motd[len], 1500-len,"<center><img src=^"http://img693.imageshack.us/img693/2153/headerrb.png^"></center>");
			len += format(motd[len], 1500-len,"<table align=^"center^">");
			len += format(motd[len], 1500-len,"<tr><td align=^"center^" style=^"border: 1px #000 solid; background: #151515; color: %s^">%s</td></tr>", color, message2);
			len += format(motd[len], 1500-len,"<tr><td align=^"center^" style=^"border: 1px #000 solid; background: #151515; color: green^">Contact an Admin on Skype</td></tr>", VERSION);
			len += format(motd[len], 1500-len,"</table>");
	
			show_motd(id, motd, "Contact an Admin on Skype");
		}
	}	
}

public announce(id) {
	if(get_pcvar_num(pcv_skype_toggle))
		return;

	new announce_msg[200]
	get_pcvar_string(pcv_announce_message, announce_msg, charsmax(announce_msg))
	colormsg(id, "\g[%s] \t%s", TAG, announce_msg)
}

stock colormsg(const id, const string[], {Float, Sql, Resul,_}:...) {
	new msg[191], players[32], count = 1;
	vformat(msg, sizeof msg - 1, string, 3);
	
	replace_all(msg,190,"\g","^4");
	replace_all(msg,190,"\y","^1");
	replace_all(msg,190,"\t","^3");
	
	if(id)
		players[0] = id;
	else
		get_players(players,count,"ch");
	
	for (new i = 0 ; i < count ; i++)
	{
		if (is_user_connected(players[i]))
		{
			message_begin(MSG_ONE_UNRELIABLE, g_SayText,_, players[i]);
			write_byte(players[i]);
			write_string(msg);
			message_end();
		}		
	}
}
