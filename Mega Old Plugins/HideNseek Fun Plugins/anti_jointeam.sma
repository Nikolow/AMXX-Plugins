#include <amxmodx>
#include <colorchat>

public plugin_init() {
	
	register_plugin("Anti WTJ", "0.2", "Nicky")
	
	register_clcmd("jointeam 1", "jointeam")
	register_clcmd("jointeam 2", "jointeam")
	register_clcmd("jointeam 5", "jointeam")
	register_clcmd("jointeam 6", "jointeam")
}

public jointeam(id)
{
	server_cmd("amx_kick #%d  Anti Win Team Join [WTJ]", get_user_userid( id ));
	ColorChat(0, GREY, "^x04 **^x03 Anti Win Team Join:^x01 #%d^x03 has been kicked !", get_user_userid( id ));
}