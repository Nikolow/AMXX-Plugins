/*

	При реклама / спамене, играчът ще бъде кикнат. 
	Думите за реклама са в .ini файла.
	Има и LANG файл.

*/

#include <amxmodx>
#include <amxmisc>
#include <colorchat>

new const SK_SPAM_FILE[] = "spam.ini"

new g_spam_count[33]

new g_array_created

new cvar_spam_option, cvar_spam_max, cvar_spam_ban, cvar_spam_log

new Array:g_spam

public plugin_precache()
{
	g_spam = ArrayCreate(32, 1)
	
	g_array_created = true
}

public plugin_init()
{
	register_plugin("Spam Kick", "0.1", "Advanced??")

	register_dictionary("spam.txt")
	
	register_clcmd("say", "SpamKick")
	register_clcmd("say_team", "SpamKick")	
	
	cvar_spam_option = register_cvar("amx_spam_option", "1")
	cvar_spam_max = register_cvar("amx_spam_max", "3")
	cvar_spam_ban = register_cvar("amx_spam_ban_time", "3")
	cvar_spam_log = register_cvar("amx_spam_log", "0")
}

public plugin_cfg()
{
	load_spam()
}

public client_putinserver(id)
{
	g_spam_count[id] = 0;
}

public SpamKick(id)
{
	if(!is_user_admin(id))
	{
		new Args[200]
		read_args(Args, 199)
		
		new BanTimes = get_cvar_num("amx_spam_ban_time")
		if(BanTimes > 1440) set_cvar_num("amx_spam_ban_time", 1440)
		if(BanTimes < 1) set_cvar_num("amx_spam_ban_time", 1)
		
		// Get Spam Option
		new option = get_pcvar_num(cvar_spam_option)
		
		// to compare
		new buffer[32]
		
		for(new i = 0; i < ArraySize(g_spam); i++)
		{
			ArrayGetString(g_spam, i, buffer, 31)
			if(containi(Args, buffer) != -1)
			{
				if(!option)
				{
					set_hudmessage(random(255), random(255), random(255), -1.0, 0.20, 0, 0.0, 15.0, 0.1, 0.15, -1)
					show_hudmessage(id, "%L^n^n%L", LANG_PLAYER, "SK_NOT_ALLOWED", LANG_PLAYER, "SK_NOT_ALLOWED")
					ColorChat(id, RED, "^x03%L", LANG_PLAYER, "SK_NOT_ALLOWED")
					break;
				}
				
				// Set Spam Count
				g_spam_count[id]++
				
				// Get Name and Steam ID
				new name[32], authid[32], intpro[46]
				get_user_name(id, name, 31)
				get_user_authid(id, authid, 31)
				get_user_ip(id, intpro, 45, 0)
				
				// Spam the Spamer
				set_hudmessage(random(255), random(255), random(255), -1.0, 0.20, 0, 0.0, 15.0, 0.1, 0.15, -1)
				show_hudmessage(id, "%L^n%i/%i^n%L", LANG_PLAYER, "SK_NOT_ALLOWED", g_spam_count[id], get_pcvar_num(cvar_spam_max), LANG_PLAYER, "SK_NOT_ALLOWED")
				ColorChat(id, RED, "^x04%L ^x01Spam: ^x03%i/%i", LANG_PLAYER, "SK_NOT_ALLOWED", g_spam_count[id], get_pcvar_num(cvar_spam_max))
				
				if (g_spam_count[id] >= get_pcvar_num(cvar_spam_max))
				{
					new mes_log[100], mes_action[100]
					
					switch(option)
					{
						case 1: // Kick Player
						{
							if(get_pcvar_num(cvar_spam_log))
							{
								format(mes_log, charsmax(mes_log), "%L", LANG_SERVER, "SK_LOG_KICK", name, authid, g_spam_count[id], get_pcvar_num(cvar_spam_max))
								log_amx("[Spam Kick] %s", mes_log)
							}
							format(mes_action, charsmax(mes_action), "%L", LANG_PLAYER, "SK_SERVER_KICK", g_spam_count[id], get_pcvar_num(cvar_spam_max))
							server_cmd("kick #%d %s", get_user_userid(id), mes_action)
							break;						
						}
						case 2: // Ban ID Player
						{
							if(get_pcvar_num(cvar_spam_log))
							{
								format(mes_log, charsmax(mes_log), "%L", LANG_SERVER, "SK_LOG_BAN", name, authid, get_pcvar_num(cvar_spam_ban), g_spam_count[id], get_pcvar_num(cvar_spam_max))
								log_amx("[Spam Kick] %s", mes_log)
							}
							server_cmd("banid ^"%i.0^" ^"%s^";wait;writeid", get_pcvar_num(cvar_spam_ban), authid)
							format(mes_action, charsmax(mes_action), "%L", LANG_PLAYER, "SK_SERVER_BAN", get_pcvar_num(cvar_spam_ban), g_spam_count[id], get_pcvar_num(cvar_spam_max))
							server_cmd("kick #%d %s", get_user_userid(id), mes_action)
							break;
						}
						case 3: // Ban IP Player
						{
							if(get_pcvar_num(cvar_spam_log))
							{
								format(mes_log, charsmax(mes_log), "%L", LANG_SERVER, "SK_LOG_BAN", name, intpro, get_pcvar_num(cvar_spam_ban), g_spam_count[id], get_pcvar_num(cvar_spam_max))
								log_amx("[Spam Kick] %s", mes_log)
							}
							server_cmd("addip ^"%i.0^" ^"%s^";wait;writeip", get_pcvar_num(cvar_spam_ban), intpro)
							format(mes_action, charsmax(mes_action), "%L", LANG_PLAYER, "SK_SERVER_BAN", get_pcvar_num(cvar_spam_ban), g_spam_count[id], get_pcvar_num(cvar_spam_max))
							server_cmd("kick #%d %s", get_user_userid(id), mes_action)
							break;
						}
					}
				}
				return PLUGIN_HANDLED
			}
		}
	}
	return PLUGIN_CONTINUE
}

load_spam()
{
	// Get Config Dir
	new archive[32], file_spam[64]
	get_configsdir(archive, 31)
	formatex(file_spam, 63, "%s/%s", archive, SK_SPAM_FILE)
	
	// File not found or array not created, stop plugin
	if(!file_exists(file_spam) || !g_array_created)
	{
		log_amx("[Spam Kick] %s %s", file_exists(file_spam) ? "Spam file found -" : "Spam file not found -", g_array_created ? " Array created." : " Array not created.")
		pause("ad")
		return;
	}
	
	new linea[128], file = fopen(file_spam, "rt")
	
	if(file)
	{
		while(file && !feof(file)) 
		{
			fgets(file, linea, 127)
			replace(linea, 127, "^n", "")
			
			if(linea[0] == '/' && linea[1] == '/' || linea[0] == ';' || strlen(linea) < 1)
				continue;
			
			ArrayPushString(g_spam, linea)
		}
	}
	fclose(file)
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1026\\ f0\\ fs16 \n\\ par }
*/
