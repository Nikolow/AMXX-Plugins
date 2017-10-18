#include <amxmodx>
#include <amxmisc>
#include <geoip>
/*
*** amx_joinmsg 1/2/3 //1=connected only,2=connecting + connected,3=connecting connected disconnected

*** Update geoipcity monthly - download http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz, then rename into GeoIPCity.dat

This is code snippets I find useful.
^x01 is Yellow
^x03 is Team Color. Ie. Red (Terrorist) or blue (Counter-Terrorist) or grey (SPECTATOR or UNASSIGNED).
^x04 is Green
The colors red, grey, and blue can't be used on the same line. This is not possible at all to do.
Also there are limitation to using Red or Grey while on the TEAM CT.
You would have to do for example if they were on CT.
ColorChat(0, RED, "%s, ^x01This color is yellow. ^x03This color is red. ^x04This color is green.);
You have to set the Type to RED because of certain messages that need to be sent out so a person on the
team CT can be sent red colors.
*/
#define MAXPLAYER 32
enum Color
{
YELLOW = 1, // Yellow
GREEN, // Green Color
TEAM_COLOR, // Red, grey, blue
GREY, // grey
RED, // Red
BLUE, // Blue
}
new TeamInfo;
new SayText;
new MaxSlots;
new TERRORIST[] = "TERRORIST";
new CT[] = "CT";
new NOTHING[] = "";
new SPEC[] = "SPECTATOR";
new bool:IsConnected[MAXPLAYER + 1];
public plugin_init()
{
register_plugin("ConnectInfo Ultimate", "3.0b2", "Diggz");
register_cvar("amx_joinmsg", "3") //1=connected only, 2=connecting + connected, 3=connecting connected disconnected
TeamInfo = get_user_msgid("TeamInfo");
SayText = get_user_msgid("SayText");
MaxSlots = get_maxplayers();
}
public client_putinserver(player)
{
IsConnected[player] = true;
if(get_cvar_num("amx_joinmsg") >= 1) {
new authid[35],user[32],ip[32],Country[33],City[33]
get_user_name(player,user,31)
get_user_ip(player,ip,31,1)
get_user_authid(player,authid,34)
geoip_country(ip,Country)
geoip_city(ip,City)
ColorChat(0, RED, "^x03%s^x01 joined from ^x04[^x03%s^x04] [^x03%s^x04]^x01 with ^x03%s^x04 IP",user,Country,City,ip);
client_cmd(0,"hud_saytext_time 8")
client_cmd(0,"hud_deathnotice_time 8") //remove if needed
}
}
public client_disconnect(player)
{
if(get_cvar_num("amx_joinmsg") >= 3) {
IsConnected[player] = false;
new authid[35],user[32],ip[32],Country[33],City[33]
get_user_name(player,user,31)
get_user_ip(player,ip,31,1)
get_user_authid(player,authid,34)
geoip_country(ip,Country)
geoip_city(ip,City)
ColorChat(0, BLUE, "^x03%s^x01 dropped. ^x04Info: ^x04[^x03%s^x04] [^x03%s^x04] [^x03%s^x04]",user,Country,City,ip);
}

}

public client_authorized(player)

{

IsConnected[player] = false;

if(get_cvar_num("amx_joinmsg") >= 2) {

new authid[35],user[32],ip[32],Country[33],City[33]

get_user_name(player,user,31)

get_user_ip(player,ip,31,1)

get_user_authid(player,authid,34)

geoip_country(ip,Country)

geoip_city(ip,City)



ColorChat(0, GREY, "^x03%s ^x04[^x03%s^x04] [^x03%s^x04]^x01 with ^x03%s^x04 IP^x01 connecting...",user,Country,City,ip);

}

}





public ColorChat(id, Color:type, const msg[], {Float,Sql,Result,_}:...)

{

static message[256];



switch(type)

{

case YELLOW: // Yellow

{

message[0] = 0x01;

}

case GREEN: // Green

{

message[0] = 0x04;

}

default: // White, Red, Blue

{

message[0] = 0x03;

}

}



vformat(message[1], 251, msg, 4);



// Make sure message is not longer than 192 character. Will crash the server.

message[192] = '^0';



new team, did;



if(id && IsConnected[id])

{

team = get_user_team(id);



did = color_selection(id, type);

show_message(id, id, MSG_ONE, message);



if(did)

{

TeamSelection(id, team);

}

} else {

new index = FindPlayer();



if(index != -1)

{

team = get_user_team(index);



did = color_selection(index, type);

show_message(index, 0, MSG_ALL, message);



if(did)

{

TeamSelection(index, team);

}

}

}

}



show_message(id, index, type, message[])

{

message_begin(type, SayText, {0, 0, 0}, index);

write_byte(id);

write_string(message);

message_end();

}



Team_Info(id, team[])

{

message_begin(MSG_ALL, TeamInfo);

write_byte(id);

write_string(team);

message_end();



return 1;

}



color_selection(index, Color:Type)

{

switch(Type)

{

case RED:

{

return Team_Info(index, TERRORIST);

}

case BLUE:

{

return Team_Info(index, CT);

}

case GREY:

{

return Team_Info(index, NOTHING);

}

}



return 0;

}



TeamSelection(index, team)

{

switch(team)

{

case 0:

{

Team_Info(index, NOTHING);

}

case 1:

{

Team_Info(index, TERRORIST);

}

case 2:

{

Team_Info(index, CT);

}

case 3:

{

Team_Info(index, SPEC);

}

}

}



FindPlayer()

{

new i = -1;



while(i <= MaxSlots)

{

if(IsConnected[++i])

{

return i;

}

}



return -1;

}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
/
