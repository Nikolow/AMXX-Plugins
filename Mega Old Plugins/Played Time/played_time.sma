#include <amxmodx>
#include <colorchat>
#include <nvault>
#include <time>

#define MAX_PLAYERS 32

new g_iVault

new g_szName[MAX_PLAYERS+1][32]
new g_iLastPlayedTime[MAX_PLAYERS+1]

public plugin_init()
{
	register_plugin("Time", "0.1", "ConnorMcLeod")
	register_dictionary("time.txt")

	g_iVault = nvault_open("played_time")

	register_clcmd("say /time", "ClientCommand_PlayedTime")
}

public plugin_end() nvault_close( g_iVault )
 

public client_authorized( id )
{
	new szTime[32]
	get_user_name(id, g_szName[id], charsmax(g_szName[]))
	nvault_get(g_iVault, g_szName[id], szTime, charsmax(szTime))
	g_iLastPlayedTime[id] = str_to_num(szTime)
}

get_user_total_playtime( id )
{
	return g_iLastPlayedTime[id] + get_user_time(id)
}

public ClientCommand_PlayedTime( id )
{
	new szTime[128]
	new szName[32]
	get_time_length(id, get_user_total_playtime( id ), timeunit_seconds, szTime, charsmax(szTime))
	get_user_name(id, szName, charsmax(szName)) 
	ColorChat( id, GREY, "^x03Player^x04 %s^x03 Information^x01 [^x03 Time:^x04 %s^x01 |^x03 Connects:^x04 disabled^x01 |^x03 Rounds:^x04 disabled^x01 ]", szName, szTime)
}

public client_disconnect( id )
{
	new szTime[32]
	formatex(szTime, charsmax(szTime), "%d", get_user_total_playtime( id ))
	nvault_set(g_iVault, g_szName[id], szTime)
}