#include <amxmodx>
#include <amxmisc>

#define VERSION	"0.1"

#define FLAG_VIP ADMIN_LEVEL_B
#define TAG_VIP "VIP"

new VIP; 
new SzMaxPlayers, SzSayText;

new SzGTeam[3][] = {
	"Spectator",
	"Terrorist",
	"Counter-Terrorist"
}

public plugin_init()
{
	register_plugin("VIP Tag", VERSION, "Advanced");
	
	VIP = register_cvar("vip_tag", "1");
	
	register_cvar("vip_tag_version",	VERSION, FCVAR_SERVER|FCVAR_SPONLY);
	set_cvar_string("vip_tag_version",	VERSION);
	register_clcmd("say", "hook_say");
	register_clcmd("say_team", "hook_say_team");
	
	SzSayText = get_user_msgid ("SayText");
	SzMaxPlayers = get_maxplayers();
	
	register_message(SzSayText, "MsgDuplicate");
}

public MsgDuplicate(id){ return PLUGIN_HANDLED; }

public hook_say(id)
{
	new SzMessages[192], SzName[32];
	new SzAlive = is_user_alive(id);
	new SzGetFlag = get_user_flags(id);
	
	read_args(SzMessages, 191);
	remove_quotes(SzMessages);
	get_user_name(id, SzName, 31);
	
	if(!is_valid_msg(SzMessages))
		return PLUGIN_CONTINUE;
	
	if(get_pcvar_num(VIP) && SzGetFlag & FLAG_VIP)(SzAlive ? format(SzMessages, 191, "^4[%s] ^3%s^1 : %s", TAG_VIP, SzName, SzMessages) : format(SzMessages, 191, "^1*DEAD* ^4[%s] ^3%s^1 : %s", TAG_VIP, SzName, SzMessages));
	else if(get_pcvar_num(VIP) && !(SzGetFlag & FLAG_VIP))(SzAlive ? format(SzMessages, 191, "^3%s^1 : %s", SzName, SzMessages) : format(SzMessages, 191, "^1*DEAD* ^3%s^1 : %s", SzName, SzMessages));
	for(new i = 1; i <= SzMaxPlayers; i++)
		{
			if(!is_user_connected(i))
				continue;
		
			if(SzAlive && is_user_alive(i) || !SzAlive && !is_user_alive(i))
				{
					message_begin(MSG_ONE, get_user_msgid("SayText"), {0, 0, 0}, i);
					write_byte(id);
					write_string(SzMessages);
					message_end();
				}
		}

	return PLUGIN_CONTINUE;
}

public hook_say_team(id){
	new SzMessages[192], SzName[32];
	new SzAlive = is_user_alive(id);
	new SzGetFlag = get_user_flags(id);
	new SzGetTeam = get_user_team(id);

	read_args(SzMessages, 191);
	remove_quotes(SzMessages);
	get_user_name(id, SzName, 31);
	
	if(!is_valid_msg(SzMessages))
		return PLUGIN_CONTINUE;
	
	if(get_pcvar_num(VIP) && SzGetFlag & FLAG_VIP)(SzAlive ? format(SzMessages, 191, "^1(%s) ^4[%s] ^3%s^1 : %s", SzGTeam[SzGetTeam], TAG_VIP, SzName, SzMessages) : format(SzMessages, 191, "^1*DEAD* ^1(%s) ^4[%s] ^3%s^1 : %s", SzGTeam[SzGetTeam], TAG_VIP, SzName, SzMessages));
         else if(get_pcvar_num(VIP) && !(SzGetFlag & FLAG_VIP))(SzAlive ? format(SzMessages, 191, "^1(%s) ^3%s^1 : %s", SzGTeam[SzGetTeam], SzName, SzMessages) : format(SzMessages, 191, "^1*DEAD* ^1(%s) ^3%s^1 : %s", SzGTeam[SzGetTeam], SzName, SzMessages));
	for(new i = 1; i <= SzMaxPlayers; i++)
		{
			if(!is_user_connected(i))
				continue;
			
			if(get_user_team(i) != SzGetTeam)
				continue;
			
			if(SzAlive && is_user_alive(i) || !SzAlive && !is_user_alive(i))
				{
					message_begin(MSG_ONE, get_user_msgid("SayText"), {0, 0, 0}, i);
					write_byte(id);
					write_string(SzMessages);
					message_end();
				}
		}

	return PLUGIN_CONTINUE;
}


bool:is_valid_msg(const SzMessages[]){
	if( SzMessages[0] == '@'
	|| !strlen(SzMessages)){ return false; }
	return true;
}
