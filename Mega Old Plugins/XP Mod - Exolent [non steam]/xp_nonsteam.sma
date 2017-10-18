// =================================================
// BEGIN EDITING HERE
// =================================================

// Should the plugin save player data in SQL database?
// To save player data in a vault, change "#define USING_SQL" to "//#define USING_SQL"
// To save player data in SQL, change "//#define USING_SQL" to "#define USING_SQL"

//#define USING_SQL

// The prefix in all of the plugin's messages

new const MESSAGE_TAG[] =		"[HNS XP]";

// If the player hasn't ever been to your server, they will get this much xp to start with

#define ENTRY_XP			100

// These determine if these abilities should be enabled or disabled
// 1 = enabled
// 0 = disabled

#define ENABLE_GRENADE			1
#define ENABLE_FLASHBANG_1		1
#define ENABLE_FLASHBANG_2		1
#define ENABLE_SMOKEGRENADE		1
#define ENABLE_TERR_HEALTH		1
#define ENABLE_CT_HEALTH		1
#define ENABLE_TERR_ARMOR		1
#define ENABLE_CT_ARMOR			1
#define ENABLE_TERR_RESPAWN		1
#define ENABLE_CT_RESPAWN		1
#define ENABLE_TERR_NOFALL		1
#define ENABLE_CT_NOFALL		1

// The maximum level for each ability

#define MAXLEVEL_GRENADE		8
#define MAXLEVEL_FLASHBANG_1		4
#define MAXLEVEL_FLASHBANG_2		4
#define MAXLEVEL_SMOKEGRENADE		4
#define MAXLEVEL_TERR_HEALTH		10
#define MAXLEVEL_CT_HEALTH		5
#define MAXLEVEL_TERR_ARMOR		8
#define MAXLEVEL_CT_ARMOR		6
#define MAXLEVEL_TERR_RESPAWN		2
#define MAXLEVEL_CT_RESPAWN		2
#define MAXLEVEL_TERR_NOFALL		8
#define MAXLEVEL_CT_NOFALL		8

// The xp amount required to buy the first level

#define FIRST_XP_GRENADE		100
#define FIRST_XP_FLASHBANG_1		100
#define FIRST_XP_FLASHBANG_2		100
#define FIRST_XP_SMOKEGRENADE		100
#define FIRST_XP_TERR_HEALTH		100
#define FIRST_XP_CT_HEALTH		100
#define FIRST_XP_TERR_ARMOR		100
#define FIRST_XP_CT_ARMOR		100
#define FIRST_XP_TERR_RESPAWN		1000
#define FIRST_XP_CT_RESPAWN		2000
#define FIRST_XP_TERR_NOFALL		100
#define FIRST_XP_CT_NOFALL		100

// The maximum chance possible for this ability (happens when player has maximum level)

#define CHANCE_MAX_GRENADE		100
#define CHANCE_MAX_FLASHBANG_1		100
#define CHANCE_MAX_FLASHBANG_2		100
#define CHANCE_MAX_SMOKEGRENADE		100
#define CHANCE_MAX_TERR_RESPAWN		50
#define CHANCE_MAX_CT_RESPAWN		50
#define CHANCE_MAX_TERR_NOFALL		80
#define CHANCE_MAX_CT_NOFALL		80

// =================================================
// STOP EDITING HERE
// =================================================


#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <hamsandwich>
#include <fun>
#include <regex>
#include <hlsdk_const>
#include <colorchat>

#if defined USING_SQL
#include <sqlx>

new Handle:g_sql_tuple;
#else
#include <nvault>

new g_vault;
#endif


new const VERSION[] =	"0.0.1";


#pragma semicolon 1

enum _:Grenades
{
	NADE_HE,
	NADE_FL1,
	NADE_FL2,
	NADE_SM
};

new const g_nade_enabled[Grenades] =
{
	ENABLE_GRENADE,
	ENABLE_FLASHBANG_1,
	ENABLE_FLASHBANG_2,
	ENABLE_SMOKEGRENADE
};

new const g_any_nade_enabled = ENABLE_GRENADE + ENABLE_FLASHBANG_1 + ENABLE_FLASHBANG_2 + ENABLE_SMOKEGRENADE;

new const g_nade_names[Grenades][] =
{
	"HE Grenade",
	"Flashbang #1",
	"Flashbang #2",
	"Frost Nade"
};

new const g_nade_classnames[Grenades][] =
{
	"weapon_hegrenade",
	"weapon_flashbang",
	"weapon_flashbang",
	"weapon_smokegrenade"
};

new const g_nade_maxlevels[Grenades] =
{
	MAXLEVEL_GRENADE,
	MAXLEVEL_FLASHBANG_1,
	MAXLEVEL_FLASHBANG_2,
	MAXLEVEL_SMOKEGRENADE
};

new const g_nade_first_xp[Grenades] =
{
	FIRST_XP_GRENADE,
	FIRST_XP_FLASHBANG_1,
	FIRST_XP_FLASHBANG_2,
	FIRST_XP_SMOKEGRENADE
};

new const g_nade_max_chance[Grenades] =
{
	CHANCE_MAX_GRENADE,
	CHANCE_MAX_FLASHBANG_1,
	CHANCE_MAX_FLASHBANG_2,
	CHANCE_MAX_SMOKEGRENADE
};

new const g_team_names[CsTeams][] =
{
	"Spectator",
	"Terrorist",
	"Counter-Terrorist",
	"Spectator"
};

new const g_health_enabled[CsTeams] =
{
	0,
	ENABLE_TERR_HEALTH,
	ENABLE_CT_HEALTH,
	0
};

new const g_any_health_enabled = ENABLE_TERR_HEALTH + ENABLE_CT_HEALTH;

new const g_health_names[CsTeams][] =
{
	"",
	"T Extra Health",
	"CT Extra Health",
	""
};

new const g_health_maxamount[CsTeams] =
{
	0,
	100,
	50,
	0
};

new const g_health_maxlevels[CsTeams] =
{
	0,
	MAXLEVEL_TERR_HEALTH,
	MAXLEVEL_CT_HEALTH,
	0
};

new const g_health_first_xp[CsTeams] =
{
	0,
	FIRST_XP_TERR_HEALTH,
	FIRST_XP_CT_HEALTH,
	0
};

new const g_armor_enabled[CsTeams] =
{
	0,
	ENABLE_TERR_ARMOR,
	ENABLE_CT_ARMOR,
	0
};

new const g_any_armor_enabled = ENABLE_TERR_ARMOR + ENABLE_CT_ARMOR;

new const g_armor_names[CsTeams][] =
{
	"",
	"T Armor",
	"CT Armor",
	""
};

new const g_armor_maxamount[CsTeams] =
{
	0,
	200,
	150,
	0
};

new const g_armor_maxlevels[CsTeams] =
{
	0,
	MAXLEVEL_TERR_ARMOR,
	MAXLEVEL_CT_ARMOR,
	0
};

new const g_armor_first_xp[CsTeams] =
{
	0,
	FIRST_XP_TERR_ARMOR,
	FIRST_XP_CT_ARMOR,
	0
};

new const g_respawn_enabled[CsTeams] =
{
	0,
	ENABLE_TERR_RESPAWN,
	ENABLE_CT_RESPAWN,
	0
};

new const g_any_respawn_enabled = ENABLE_TERR_RESPAWN + ENABLE_CT_RESPAWN;

new const g_respawn_names[CsTeams][] =
{
	"",
	"T Respawn Chance",
	"CT Respawn Chance",
	""
};

new const g_respawn_maxlevels[CsTeams] =
{
	0,
	MAXLEVEL_TERR_RESPAWN,
	MAXLEVEL_CT_RESPAWN,
	0
};

new const g_respawn_first_xp[CsTeams] =
{
	0,
	FIRST_XP_TERR_RESPAWN,
	FIRST_XP_CT_RESPAWN,
	0
};

new const g_respawn_max_chance[CsTeams] =
{
	0,
	CHANCE_MAX_TERR_RESPAWN,
	CHANCE_MAX_CT_RESPAWN,
	0
};

new const g_nofall_enabled[CsTeams] =
{
	0,
	ENABLE_TERR_NOFALL,
	ENABLE_CT_NOFALL,
	0
};

new const g_any_nofall_enabled = ENABLE_TERR_NOFALL + ENABLE_CT_NOFALL;

new const g_nofall_names[CsTeams][] =
{
	"",
	"T Fall Damage Reducer",
	"CT Fall Damage Reducer",
	""
};

new const g_nofall_maxlevels[CsTeams] =
{
	0,
	MAXLEVEL_TERR_NOFALL,
	MAXLEVEL_CT_NOFALL,
	0
};

new const g_nofall_first_xp[CsTeams] =
{
	0,
	FIRST_XP_TERR_NOFALL,
	FIRST_XP_CT_NOFALL,
	0
};

new const g_nofall_max_chance[CsTeams] =
{
	0,
	CHANCE_MAX_TERR_NOFALL,
	CHANCE_MAX_CT_NOFALL,
	0
};

#define ANY_ABILITY_ENABLED (g_any_nade_enabled || g_any_health_enabled || g_any_armor_enabled || g_any_respawn_enabled || g_any_nofall_enabled)

new g_authid[33][35];

new g_xp[33];

new g_first_time[33];
#if defined USING_SQL
new g_loaded_data[33];
#endif

new g_used_revive[33];

new g_nade_level[33][Grenades];
new g_armor_level[33][CsTeams];
new g_respawn_level[33][CsTeams];
new g_health_level[33][CsTeams];
new g_nofall_level[33][CsTeams];

new cvar_xp_suicide;
new cvar_xp_kill;
new cvar_xp_headshot;
new cvar_xp_grenade;
new cvar_xp_survive;
new cvar_xp_win;
new cvar_spawn_nade_delay;

new Float:g_nade_give_time;

new g_first_client;
new g_max_clients;

new g_msgid_SayText;

#if defined USING_SQL
public plugin_precache()
{
	g_sql_tuple = SQL_MakeStdTuple();
	
	SQL_ThreadQuery(g_sql_tuple, "QueryCreateTable", "CREATE TABLE IF NOT EXISTS `hns_xp` ( `name` VARCHAR(32) NOT NULL, `authid` VARCHAR(35) NOT NULL, `data` VARCHAR(256) NOT NULL );" );
}

public QueryCreateTable(failstate, Handle:query, error[], errnum, data[], size, Float:queuetime)
{
	if( failstate == TQUERY_CONNECT_FAILED
	|| failstate == TQUERY_QUERY_FAILED )
	{
		set_fail_state(error);
	}
}
#endif

public plugin_init()
{
	register_plugin("HideNSeek XP Mod", VERSION, "Exolent");
	register_cvar("hnsxp_author", "Exolent", FCVAR_SPONLY);
	register_cvar("hnsxp_version", VERSION, FCVAR_SPONLY);
	
	register_clcmd("say /xp", "CmdMainMenu");
	register_clcmd("say /exp", "CmdMainMenu");
	
	register_concmd("hnsxp_give_xp", "CmdGiveXP", ADMIN_RCON, "<nick, #userid, authid> <xp>");
	register_concmd("hnsxp_remove_xp", "CmdRemoveXP", ADMIN_RCON, "<nick, #userid, authid> <xp>");
	
	register_event("HLTV", "EventNewRound", "a", "1=0", "2=0");
	register_event("DeathMsg", "EventDeathMsg", "a");
	register_logevent("EventRoundStart", 2, "1=Round_Start");
	register_logevent("EventRoundEnd", 2, "1=Round_End");
	register_event("TextMsg", "EventRoundRestart", "a", "2&#Game_C", "2&#Game_w");
	
	RegisterHam(Ham_Spawn, "player", "FwdPlayerSpawn", 1);
	RegisterHam(Ham_Killed, "player", "FwdPlayerDeath", 1);
	RegisterHam(Ham_TakeDamage, "player", "FwdPlayerDamage");
	
	cvar_xp_suicide = register_cvar("hnsxp_xp_suicide", "5");
	cvar_xp_kill = register_cvar("hnsxp_xp_kill", "10");
	cvar_xp_headshot = register_cvar("hnsxp_xp_headshot", "15");
	cvar_xp_grenade = register_cvar("hnsxp_xp_grenade", "25");
	cvar_xp_survive = register_cvar("hnsxp_xp_survive", "10");
	cvar_xp_win = register_cvar("hnsxp_xp_win", "5");
	cvar_spawn_nade_delay = register_cvar("hnsxp_spawn_nade_delay", "10");
	
	#if !defined USING_SQL
	g_vault = nvault_open("hnsxp");
	#endif
		
	g_first_client = 1;
	g_max_clients = get_maxplayers();
	
	g_msgid_SayText = get_user_msgid("SayText");
}

#if !defined USING_SQL
public plugin_end()
{
	nvault_close(g_vault);
}
#endif

public plugin_natives()
{
	register_library("hns_xp");
	register_native("hnsxp_get_user_xp", "_get_xp");
	register_native("hnsxp_set_user_xp", "_set_xp");
}

public _get_xp(plugin, params)
{
	return g_xp[get_param(1)];
}

public _set_xp(plugin, params)
{
	new client = get_param(1);
	g_xp[client] = max(0, get_param(2));
	Save(client);
	return g_xp[client];
}

public client_authorized(client)
{
	if( !is_user_bot(client) && !is_user_hltv(client) )
	{
		get_user_name(client, g_authid[client], sizeof(g_authid[]) - 1);
		
		Load(client);
	}
}

public client_disconnect(client)
{
	Save(client);
	
	g_authid[client][0] = 0;
	g_first_time[client] = 0;
	#if defined USING_SQL
	g_loaded_data[client] = 0;
	#endif
	g_used_revive[client] = 0;
}

public CmdMainMenu(client)
{
	ShowMainMenu(client);
}

public CmdGiveXP(client, level, cid)
{
	if( !cmd_access(client, level, cid, 3) ) return PLUGIN_HANDLED;
	
	static arg[35];
	read_argv(1, arg, sizeof(arg) - 1);
	
	new target = cmd_target(client, arg, CMDTARGET_OBEY_IMMUNITY|CMDTARGET_NO_BOTS);
	if( !target ) return PLUGIN_HANDLED;
	
	if( !IsUserAuthorized(target) )
	{
		//console_print(client, "Target has not authorized with the server.");
		return PLUGIN_HANDLED;
	}
	
	read_argv(2, arg, sizeof(arg) - 1);
	new xp = str_to_num(arg);
	
	if( xp <= 0 )
	{
		//console_print(client, "XP must be a value greater than 0!");
		if( xp < 0 )
		{
			console_print(client, "Use hnsxp_remove_xp instead.");
		}
		return PLUGIN_HANDLED;
	}
	
	g_xp[target] += xp;
	
	Save(target);
	
	static name[2][32];
	get_user_name(client, name[0], sizeof(name[]) - 1);
	get_user_name(target, name[1], sizeof(name[]) - 1);
	
	Print(0, "%s gave %i XP to %s.", name[0], xp, name[1]);
	
	static steamid[2][35];
	get_user_authid(client, steamid[0], sizeof(steamid[]) - 1);
	get_user_authid(target, steamid[1], sizeof(steamid[]) - 1);
	
	log_amx("%s (%s) gave %i XP to %s (%s)", name[0], steamid[0], xp, name[1], steamid[1]);
	
	return PLUGIN_HANDLED;
}

public CmdRemoveXP(client, level, cid)
{
	if( !cmd_access(client, level, cid, 3) ) return PLUGIN_HANDLED;
	
	static arg[35];
	read_argv(1, arg, sizeof(arg) - 1);
	
	new target = cmd_target(client, arg, CMDTARGET_OBEY_IMMUNITY|CMDTARGET_NO_BOTS);
	if( !target ) return PLUGIN_HANDLED;
	
	if( !IsUserAuthorized(target) )
	{
		//console_print(client, "Target has not authorized with the server.");
		return PLUGIN_HANDLED;
	}
	
	read_argv(2, arg, sizeof(arg) - 1);
	new xp = str_to_num(arg);
	
	if( xp <= 0 )
	{
		//console_print(client, "XP must be a value greater than 0!");
		if( xp < 0 )
		{
			console_print(client, "Use hnsxp_give_xp instead.");
		}
		return PLUGIN_HANDLED;
	}
	
	g_xp[target] -= xp;
	
	Save(target);
	
	static name[2][32];
	get_user_name(client, name[0], sizeof(name[]) - 1);
	get_user_name(target, name[1], sizeof(name[]) - 1);
	
	Print(0, "%s removed %i XP from %s.", name[0], xp, name[1]);
	
	static steamid[2][35];
	get_user_authid(client, steamid[0], sizeof(steamid[]) - 1);
	get_user_authid(target, steamid[1], sizeof(steamid[]) - 1);
	
	log_amx("%s (%s) removed %i XP from %s (%s)", name[0], steamid[0], xp, name[1], steamid[1]);
	
	return PLUGIN_HANDLED;
}

public EventNewRound()
{
	arrayset(g_used_revive, 0, sizeof(g_used_revive));
	
	g_nade_give_time = 9999999.9;
}

public EventDeathMsg()
{
	new killer = read_data(1);
	new victim = read_data(2);
	
	if( (g_first_client <= killer <= g_max_clients) && victim != killer )
	{
		if( IsUserAuthorized(killer) )
		{
			// regular kill
			new xp = get_pcvar_num(cvar_xp_kill);
			
			if( read_data(3) )
			{
				// headshot kill
				xp += get_pcvar_num(cvar_xp_headshot);
			}
			else
			{
				static weapon[20];
				read_data(4, weapon, sizeof(weapon) - 1);
				
				if( contain(weapon, "grenade") >= 0 )
				{
					// grenade kill (or frostnade)
					xp += get_pcvar_num(cvar_xp_grenade);
				}
			}
			
			g_xp[killer] += xp;
			
			//Print(killer, "You gained %i XP!", xp);
			ColorChat(killer, RED, "You^x04 gained^x01 %i^x03 XP!", xp);
			
			Save(killer);
		}
	}
	else if( IsUserAuthorized(victim) )
	{
		// victim died of map causes or killed self
		new xp = get_pcvar_num(cvar_xp_suicide);
		
		g_xp[victim] -= xp;
		
		//Print(victim, "You lost %i XP!", xp);
		ColorChat(victim, RED, "You lost^x01 %i^x04 XP!", xp);
		
		Save(victim);
	}
}

public EventRoundStart()
{
	g_nade_give_time = get_pcvar_float(cvar_spawn_nade_delay);
	
	set_task(g_nade_give_time, "TaskGiveNades", 1234);
	
	g_nade_give_time += get_gametime();
}

public EventRoundEnd()
{
	EventRoundRestart();
	
	new hider, seeker, hider_alive;
	
	for( new i = g_first_client; i <= g_max_clients; i++ )
	{
		if( is_user_connected(i) )
		{
			switch( cs_get_user_team(i) )
			{
				case CS_TEAM_CT:
				{
					if( !seeker )
					{
						seeker = i;
					}
				}
				case CS_TEAM_T:
				{
					if( !hider )
					{
						hider = i;
						
						if( !hider_alive && is_user_alive(i) )
						{
							hider_alive = i;
						}
					}
				}
			}
			
			if( seeker && hider && hider_alive )
			{
				break;
			}
		}
	}
	
	if( !hider || !seeker )
	{
		return;
	}
	
	new CsTeams:winner = CS_TEAM_CT;
	
	if( hider_alive )
	{
		winner = CS_TEAM_T;
		
		new survive = get_pcvar_num(cvar_xp_survive);
		for( new client = g_first_client; client <= g_max_clients; client++ )
		{
			if( IsUserAuthorized(client) && is_user_alive(client) && cs_get_user_team(client) == CS_TEAM_T )
			{
				g_xp[client] += survive;
				Save(client);
				
				//Print(client, "You gained %i XP for surviving!", survive);
				ColorChat(client, RED, "You^x04 gained^x01 %i^x03 XP^x01 for^x04 surviving!", survive);
			}
		}
	}
	
	new win = get_pcvar_num(cvar_xp_win);
	for( new client = g_first_client; client <= g_max_clients; client++ )
	{
		if( IsUserAuthorized(client) && is_user_alive(client) && cs_get_user_team(client) == winner )
		{
			g_xp[client] += win;
			Save(client);
			
			//Print(client, "You gained %i XP for winning the round!", win);
			ColorChat(client, RED, "You^x04 gained^x01 %i^x03 XP^x01 for^x04 winning^x03 the round!", win);
		}
	}
}

public EventRoundRestart()
{
	remove_task(1234);
	
	g_nade_give_time = 9999999.9;
}

public FwdPlayerSpawn(client)
{
	if( is_user_alive(client) )
	{
		new CsTeams:team = cs_get_user_team(client);
		if( team == CS_TEAM_T || team == CS_TEAM_CT )
		{
			if( g_first_time[client] )
			{
				//Print(client, "It is your first time playing this HideNSeek XP mod, so you are rewarded with %i XP!", ENTRY_XP);
				ColorChat(client, TEAM_COLOR, "It is your first time playing this^x04 HideNSeek XP mod,^x03 so you are rewarded with^x01 %i^x04 XP!", ENTRY_XP);
				//Print(client, "You earn XP based upon your gameplay, and you can buy more levels in the menu.");
				ColorChat(client, TEAM_COLOR, "You earn^x04 XP^x03 based upon your^x01 gameplay,^x03 and you can buy more levels in^x04 the menu.");
				//Print(client, "Type /xp to view what you can get!");
				ColorChat(client, TEAM_COLOR, "Type^x01 /xp^x03 to view what you^x04 can get!");
				
				g_first_time[client] = 0;
			}
			else
			{
				if( g_health_enabled[team] )
				{
					new health = g_health_maxamount[team] * g_health_level[client][team] / g_health_maxlevels[team];
					if( health > 0 )
					{
						set_user_health(client, get_user_health(client) + health);
					}
				}
				
				if( g_armor_enabled[team] )
				{
					new armorvalue = g_armor_maxamount[team] * g_armor_level[client][team] / g_armor_maxlevels[team];
					if( armorvalue == 0 )
					{
						cs_set_user_armor(client, armorvalue, CS_ARMOR_NONE);
					}
					else if( armorvalue < 100 )
					{
						cs_set_user_armor(client, armorvalue, CS_ARMOR_KEVLAR);
					}
					else
					{
						cs_set_user_armor(client, armorvalue, CS_ARMOR_VESTHELM);
					}
				}
			}
			
			if( get_gametime() >= g_nade_give_time )
			{
				GiveNades(client);
			}
		}
	}
}

public FwdPlayerDeath(client, killer, shouldgib)
{
	if( !g_used_revive[client] )
	{
		new CsTeams:team = cs_get_user_team(client);
		if( team == CS_TEAM_T || team == CS_TEAM_CT )
		{
			if( g_respawn_enabled[team] )
			{
				new percent = g_respawn_max_chance[team] * g_respawn_level[client][team] / g_respawn_maxlevels[team];
				if( random_num(1, 100) <= percent )
				{
					if( HasTeammateAlive(client, team) )
					{
						set_task(0.5, "TaskRespawn", client);
						
						//Print(client, "You have been respawned! (%i%% chance)", percent);
						ColorChat(client, GREY, "You^x04 have been^x03 respawned!^x01 (^x03%i%%^x04 chance^x01)", percent);
						
						g_used_revive[client] = 1;
					}
				}
			}
		}
	}
}

public FwdPlayerDamage(client, inflictor, attacker, Float:damage, damagebits)
{
	if( is_user_alive(client) && (damagebits & DMG_FALL) )
	{
		new CsTeams:team = cs_get_user_team(client);
		if( team == CS_TEAM_T || team == CS_TEAM_CT )
		{
			if( g_nofall_enabled[team] )
			{
				new percent = g_nofall_max_chance[team] * g_nofall_level[client][team] / g_nofall_maxlevels[team];
				SetHamParamFloat(4, damage * (1.0 - (float(percent) / 100.0)));
			}
		}
	}
}

public TaskRespawn(client)
{
	ExecuteHamB(Ham_CS_RoundRespawn, client);
}

public TaskGiveNades()
{
	for( new client = g_first_client; client <= g_max_clients; client++ )
	{
		if( is_user_alive(client) )
		{
			GiveNades(client);
		}
	}
}

HasTeammateAlive(client, CsTeams:team)
{
	for( new i = g_first_client; i <= g_max_clients; i++ )
	{
		if( i == client ) continue;
		
		if( is_user_alive(i) && cs_get_user_team(i) == team )
		{
			return 1;
		}
	}
	
	return 0;
}

GiveNades(client)
{
	new CsTeams:team = cs_get_user_team(client);
	
	if( team == CS_TEAM_T )
	{
		static percent;
		for( new i = 0; i < Grenades; i++ )
		{
			if( g_nade_enabled[i] )
			{
				percent = g_nade_max_chance[i] * g_nade_level[client][i] / g_nade_maxlevels[i];
				if( percent > 0 && (percent == 100 || random_num(1, 100) <= percent) )
				{
					give_item(client, g_nade_classnames[i]);
					
					if( percent < 100 )
					{
						//Print(client, "You received your %s! (%i%% chance)", g_nade_names[i], percent);
						ColorChat(client, GREY, "You^x04 received^x03 your^x04 %s!^x01 (^x03%i%%^x04 chance^x01)", g_nade_names[i], percent);
					}
				}
			}
		}
	}
}

ShowMainMenu(client)
{
	static title[128];
	formatex(title, sizeof(title) - 1, "[HNS XP by Exolent]^nMain Menu^n^nYour XP: \w%i", g_xp[client]);
	new menu = menu_create(title, "MenuMain");
	
	menu_additem(menu, "\yHelp", "*");
	if( g_any_nade_enabled )
	{
		menu_additem(menu, "Grenades Menu", "1");
	}
	if( g_any_health_enabled )
	{
		menu_additem(menu, "Health Menu", "2");
	}
	if( g_any_armor_enabled )
	{
		menu_additem(menu, "Armor Menu", "3");
	}
	if( g_any_respawn_enabled )
	{
		menu_additem(menu, "Respawn Menu", "4");
	}
	if( g_any_nofall_enabled )
	{
		menu_additem(menu, "Fall Damage Menu^n", "5");
	}
	if( ANY_ABILITY_ENABLED )
	{
		menu_additem(menu, "Player Info", "6");
	}
	
	menu_display(client, menu);
}

public MenuMain(client, menu, item)
{
	if( item == MENU_EXIT )
	{
		menu_destroy(menu);
		return;
	}
	
	static _access, info[4], callback;
	menu_item_getinfo(menu, item, _access, info, sizeof(info) - 1, _, _, callback);
	menu_destroy(menu);
	
	switch( info[0] )
	{
		case '*':
		{
			static motd[2500];
			new len = formatex(motd, sizeof(motd) - 1,	"<body style=^"background-color:#030303; color:#FF8F00^">");
			len += format(motd[len], sizeof(motd) - len - 1,	"<p align=^"center^">");
			len += format(motd[len], sizeof(motd) - len - 1,	"HideNSeek XP Mod is an experienced based addon for HideNSeek.<br>");
			len += format(motd[len], sizeof(motd) - len - 1,	"Players earn experience points by how well they play the game.<br>");
			len += format(motd[len], sizeof(motd) - len - 1,	"<br>");
			len += format(motd[len], sizeof(motd) - len - 1,	"<table border=0>");
			len += format(motd[len], sizeof(motd) - len - 1,	"<tr><th>Action</th><th>XP</th></tr>");
			len += format(motd[len], sizeof(motd) - len - 1,	"<tr><td>Kill</td><td>+%i</td></tr>", get_pcvar_num(cvar_xp_kill));
			len += format(motd[len], sizeof(motd) - len - 1,	"<tr><td>Grenade</td><td>+%i</td></tr>", get_pcvar_num(cvar_xp_grenade));
			len += format(motd[len], sizeof(motd) - len - 1,	"<tr><td>Headshot</td><td>+%i</td></tr>", get_pcvar_num(cvar_xp_headshot));
			len += format(motd[len], sizeof(motd) - len - 1,	"<tr><td>Suicide</td><td>-%i</td></tr>", get_pcvar_num(cvar_xp_suicide));
			len += format(motd[len], sizeof(motd) - len - 1,	"<tr><td>Survive as a T</td><td>+%i</td></tr>", get_pcvar_num(cvar_xp_survive));
			len += format(motd[len], sizeof(motd) - len - 1,	"<tr><td>Win Round</td><td>+%i</td></tr>", get_pcvar_num(cvar_xp_win));
			len += format(motd[len], sizeof(motd) - len - 1,	"</table>");
			len += format(motd[len], sizeof(motd) - len - 1,	"With these XP points, you can buy upgrades.<br>");
			len += format(motd[len], sizeof(motd) - len - 1,	"For a list of these upgrades, type /xp again and view the other menus inside.");
			len += format(motd[len], sizeof(motd) - len - 1,	"</p>");
			len += format(motd[len], sizeof(motd) - len - 1,	"</body>");
			
			show_motd(client, motd, "HideNSeek XP Mod Info");
		}
		case '1':
		{
			ShowGrenadesMenu(client);
		}
		case '2':
		{
			ShowHealthMenu(client);
		}
		case '3':
		{
			ShowArmorMenu(client);
		}
		case '4':
		{
			ShowRespawnMenu(client);
		}
		case '5':
		{
			ShowNoFallMenu(client);
		}
		case '6':
		{
			ShowPlayerMenu(client);
		}
	}
}

ShowGrenadesMenu(client)
{
	static title[128];
	formatex(title, sizeof(title) - 1, "[HNS XP by Exolent]^nGrenades Menu^n^nNote: \wGrenade abilities are for \rT's Only!\y^n^nYour XP: \w%i", g_xp[client]);
	new menu = menu_create(title, "MenuGrenades");
	new callback = menu_makecallback("CallbackGrenades");
	
	menu_additem(menu, "\yHelp", "*", _, callback);
	
	static level, xp, percent, item[128], info[4];
	for( new i = 0; i < Grenades; i++ )
	{
		if( g_nade_enabled[i] )
		{
			level = g_nade_level[client][i] + 1;
			percent = g_nade_max_chance[i] * level / g_nade_maxlevels[i];
			
			if( g_nade_level[client][i] < g_nade_maxlevels[i] )
			{
				xp = g_nade_first_xp[i] * (1 << (level - 1));
				formatex(item, sizeof(item) - 1, "%s: \yLevel %i (%i%%) \r[\w%i XP\r]", g_nade_names[i], level, percent, xp);
			}
			else
			{
				formatex(item, sizeof(item) - 1, "%s: \yLevel %i (%i%%) \r[\wMaxed Out!\r]", g_nade_names[i], level, percent);
			}
			
			num_to_str(i, info, sizeof(info) - 1);
			
			menu_additem(menu, item, info, _, callback);
		}
	}
	
	menu_display(client, menu);
}

public MenuGrenades(client, menu, item)
{
	if( item == MENU_EXIT )
	{
		menu_destroy(menu);
		ShowMainMenu(client);
		return;
	}
	
	static _access, info[4], callback;
	menu_item_getinfo(menu, item, _access, info, sizeof(info) - 1, _, _, callback);
	menu_destroy(menu);
	
	if( info[0] == '*' )
	{
		static motd[2500];
		new len = formatex(motd, sizeof(motd) - 1,	"<body style=^"background-color:#030303; color:#FF8F00^">");
		len += format(motd[len], sizeof(motd) - len - 1,	"<p align=^"center^">");
		len += format(motd[len], sizeof(motd) - len - 1,	"The Grenades ability for the XP Mod is for Terrorists only.<br>");
		len += format(motd[len], sizeof(motd) - len - 1,	"The Grenades ability contains the HE Grenade, 2 Flashbangs, and Frost Nade.<br>");
		len += format(motd[len], sizeof(motd) - len - 1,	"These are the grenades you are given when you receive the your items after the hide timer ends.<br>");
		len += format(motd[len], sizeof(motd) - len - 1,	"<br>");
		len += format(motd[len], sizeof(motd) - len - 1,	"<table>");
		len += format(motd[len], sizeof(motd) - len - 1,	"<tr>");
		len += format(motd[len], sizeof(motd) - len - 1,	"<th></th>");
		for( new i = 0; i < Grenades; i++ )
		{
			if( g_nade_enabled[i] )
			{
				len += format(motd[len], sizeof(motd) - len - 1,	"<th>%s</th>", g_nade_names[i]);
			}
		}
		len += format(motd[len], sizeof(motd) - len - 1,	"</tr>");
		len += format(motd[len], sizeof(motd) - len - 1,	"<tr>");
		len += format(motd[len], sizeof(motd) - len - 1,	"<th>Chance Intervals</th>");
		for( new i = 0; i < Grenades; i++ )
		{
			if( g_nade_enabled[i] )
			{
				len += format(motd[len], sizeof(motd) - len - 1,	"<td>%i%%</td>", (g_nade_max_chance[i] / g_nade_maxlevels[i]));
			}
		}
		len += format(motd[len], sizeof(motd) - len - 1,	"</tr>");
		len += format(motd[len], sizeof(motd) - len - 1,	"<tr>");
		len += format(motd[len], sizeof(motd) - len - 1,	"<th>Max Level</th>");
		for( new i = 0; i < Grenades; i++ )
		{
			if( g_nade_enabled[i] )
			{
				len += format(motd[len], sizeof(motd) - len - 1,	"<td>%i</td>", g_nade_maxlevels[i]);
			}
		}
		len += format(motd[len], sizeof(motd) - len - 1,	"</tr>");
		len += format(motd[len], sizeof(motd) - len - 1,	"<th>Max Chance</th>");
		for( new i = 0; i < Grenades; i++ )
		{
			if( g_nade_enabled[i] )
			{
				len += format(motd[len], sizeof(motd) - len - 1,	"<td>%i%%</td>", g_nade_max_chance[i]);
			}
		}
		len += format(motd[len], sizeof(motd) - len - 1,	"</tr>");
		len += format(motd[len], sizeof(motd) - len - 1,	"</table>");
		len += format(motd[len], sizeof(motd) - len - 1,	"</p>");
		len += format(motd[len], sizeof(motd) - len - 1,	"</body>");
		
		show_motd(client, motd, "XP Grenades Info");
	}
	else
	{
		new upgrade = str_to_num(info);
		
		new level = g_nade_level[client][upgrade] + 1;
		new xp = g_nade_first_xp[upgrade] * (1 << (level - 1));
		new percent = g_nade_max_chance[upgrade] * level / g_nade_maxlevels[upgrade];
		
		g_xp[client] -= xp;
		g_nade_level[client][upgrade] = level;
		
		Save(client);
		
		ColorChat(client, RED, "You^x04 bought^x03 %s^x01 Level^x04 %i^x01 (%i%%)^x03 for^x01 %i^x04 XP!", g_nade_names[upgrade], level, percent, xp);
		//Print(client, "You bought %s Level %i (%i%%) for %i XP!", g_nade_names[upgrade], level, percent, xp);
	}
	
	ShowGrenadesMenu(client);
}

public CallbackGrenades(client, menu, item)
{
	static _access, info[4], callback;
	menu_item_getinfo(menu, item, _access, info, sizeof(info) - 1, _, _, callback);
	
	if( info[0] == '*' ) return ITEM_ENABLED;
	
	new upgrade = str_to_num(info);
	if( g_nade_level[client][upgrade] == g_nade_maxlevels[upgrade] )
	{
		return ITEM_DISABLED;
	}
	
	new xp = g_nade_first_xp[upgrade] * (1 << g_nade_level[client][upgrade]);
	if( g_xp[client] < xp )
	{
		return ITEM_DISABLED;
	}
	
	return ITEM_ENABLED;
}

ShowHealthMenu(client)
{
	static title[128];
	formatex(title, sizeof(title) - 1, "[HNS XP by Exolent]^nHealth Menu^n^nYour XP: \w%i", g_xp[client]);
	new menu = menu_create(title, "MenuHealth");
	new callback = menu_makecallback("CallbackHealth");
	
	menu_additem(menu, "\yHelp", "*", _, callback);
	
	static level, xp, amount, item[128], info[4];
	for( new CsTeams:i = CS_TEAM_T; i <= CS_TEAM_CT; i++ )
	{
		if( g_health_enabled[i] )
		{
			level = g_health_level[client][i] + 1;
			amount = g_health_maxamount[i] * level / g_health_maxlevels[i];
			
			if( g_health_level[client][i] < g_health_maxlevels[i] )
			{
				xp = g_health_first_xp[i] * (1 << (level - 1));
				formatex(item, sizeof(item) - 1, "%s: \yLevel %i (%i HP) \r[\w%i XP\r]", g_health_names[i], level, amount, xp);
			}
			else
			{
				formatex(item, sizeof(item) - 1, "\w%s: \yLevel %i (%i HP) \r[\wMaxed Out!\r]", g_health_names[i], level, amount);
			}
			
			num_to_str(_:i, info, sizeof(info) - 1);
			
			menu_additem(menu, item, info, _, callback);
		}
	}
	
	menu_display(client, menu);
}

public MenuHealth(client, menu, item)
{
	if( item == MENU_EXIT )
	{
		menu_destroy(menu);
		ShowMainMenu(client);
		return;
	}
	
	static _access, info[4], callback;
	menu_item_getinfo(menu, item, _access, info, sizeof(info) - 1, _, _, callback);
	menu_destroy(menu);
	
	if( info[0] == '*' )
	{
		static motd[2500];
		new len = formatex(motd, sizeof(motd) - 1,	"<body style=^"background-color:#030303; color:#FF8F00^">");
		len += format(motd[len], sizeof(motd) - len - 1,	"<p align=^"center^">");
		len += format(motd[len], sizeof(motd) - len - 1,	"The Health ability is the amount of HP that is added to your spawn health.<br>");
		len += format(motd[len], sizeof(motd) - len - 1,	"<br>");
		len += format(motd[len], sizeof(motd) - len - 1,	"<table>");
		len += format(motd[len], sizeof(motd) - len - 1,	"<tr>");
		len += format(motd[len], sizeof(motd) - len - 1,	"<th></th>");
		for( new CsTeams:i = CS_TEAM_T; i <= CS_TEAM_CT; i++ )
		{
			if( g_health_enabled[i] )
			{
				len += format(motd[len], sizeof(motd) - len - 1,	"<th>%s</th>",g_team_names[i]);
			}
		}
		len += format(motd[len], sizeof(motd) - len - 1,	"</tr>");
		len += format(motd[len], sizeof(motd) - len - 1,	"<tr>");
		len += format(motd[len], sizeof(motd) - len - 1,	"<th>Health Intervals</th>");
		for( new CsTeams:i = CS_TEAM_T; i <= CS_TEAM_CT; i++ )
		{
			if( g_health_enabled[i] )
			{
				len += format(motd[len], sizeof(motd) - len - 1,	"<td>%i</td>", (g_health_maxamount[i] / g_health_maxlevels[i]));
			}
		}
		len += format(motd[len], sizeof(motd) - len - 1,	"</tr>");
		len += format(motd[len], sizeof(motd) - len - 1,	"<tr>");
		len += format(motd[len], sizeof(motd) - len - 1,	"<th>Max Level</th>");
		for( new CsTeams:i = CS_TEAM_T; i <= CS_TEAM_CT; i++ )
		{
			if( g_health_enabled[i] )
			{
				len += format(motd[len], sizeof(motd) - len - 1,	"<td>%i</td>", g_health_maxlevels[i]);
			}
		}
		len += format(motd[len], sizeof(motd) - len - 1,	"</tr>");
		len += format(motd[len], sizeof(motd) - len - 1,	"<th>Max Health</th>");
		for( new CsTeams:i = CS_TEAM_T; i <= CS_TEAM_CT; i++ )
		{
			if( g_health_enabled[i] )
			{
				len += format(motd[len], sizeof(motd) - len - 1,	"<td>%i</td>", g_health_maxamount[i]);
			}
		}
		len += format(motd[len], sizeof(motd) - len - 1,	"</tr>");
		len += format(motd[len], sizeof(motd) - len - 1,	"</table>");
		len += format(motd[len], sizeof(motd) - len - 1,	"</p>");
		len += format(motd[len], sizeof(motd) - len - 1,	"</body>");
		
		show_motd(client, motd, "XP Health Info");
	}
	else
	{
		new CsTeams:upgrade = CsTeams:str_to_num(info);
		
		new level = g_health_level[client][upgrade] + 1;
		new xp = g_health_first_xp[upgrade] * (1 << (level - 1));
		new amount = g_health_maxamount[upgrade] * level / g_health_maxlevels[upgrade];
		
		g_xp[client] -= xp;
		g_health_level[client][upgrade] = level;
		
		Save(client);
		
		ColorChat(client, RED, "You^x04 bought^x03 %s^x04 Level^x01 %i^x03 (%i HP)^x01 for^x03 %i^x04 XP!", g_health_names[upgrade], level, amount, xp);
		//Print(client, "You bought %s Level %i (%i HP) for %i XP!", g_health_names[upgrade], level, amount, xp);
	}
	
	ShowHealthMenu(client);
}

public CallbackHealth(client, menu, item)
{
	static _access, info[4], callback;
	menu_item_getinfo(menu, item, _access, info, sizeof(info) - 1, _, _, callback);
	
	if( info[0] == '*' ) return ITEM_ENABLED;
	
	new CsTeams:upgrade = CsTeams:str_to_num(info);
	if( g_health_level[client][upgrade] == g_health_maxlevels[upgrade] )
	{
		return ITEM_DISABLED;
	}
	
	new xp = g_health_first_xp[upgrade] * (1 << g_health_level[client][upgrade]);
	if( g_xp[client] < xp )
	{
		return ITEM_DISABLED;
	}
	
	return ITEM_ENABLED;
}

ShowArmorMenu(client)
{
	static title[128];
	formatex(title, sizeof(title) - 1, "[HNS XP by Exolent]^nArmor Menu^n^nYour XP: \w%i", g_xp[client]);
	new menu = menu_create(title, "MenuArmor");
	new callback = menu_makecallback("CallbackArmor");
	
	menu_additem(menu, "\yHelp", "*", _, callback);
	
	static level, xp, amount, item[128], info[4];
	for( new CsTeams:i = CS_TEAM_T; i <= CS_TEAM_CT; i++ )
	{
		if( g_armor_enabled[i] )
		{
			level = g_armor_level[client][i] + 1;
			amount = g_armor_maxamount[i] * level / g_armor_maxlevels[i];
			
			if( g_armor_level[client][i] < g_armor_maxlevels[i] )
			{
				xp = g_armor_first_xp[i] * (1 << (level - 1));
				formatex(item, sizeof(item) - 1, "%s: \yLevel %i (%i AP) \r[\w%i XP\r]", g_armor_names[i], level, amount, xp);
			}
			else
			{
				formatex(item, sizeof(item) - 1, "\w%s: \yLevel %i (%i AP) \r[\wMaxed Out!\r]", g_armor_names[i], level, amount);
			}
			
			num_to_str(_:i, info, sizeof(info) - 1);
			
			menu_additem(menu, item, info, _, callback);
		}
	}
	
	menu_display(client, menu);
}

public MenuArmor(client, menu, item)
{
	if( item == MENU_EXIT )
	{
		menu_destroy(menu);
		ShowMainMenu(client);
		return;
	}
	
	static _access, info[4], callback;
	menu_item_getinfo(menu, item, _access, info, sizeof(info) - 1, _, _, callback);
	menu_destroy(menu);
	
	if( info[0] == '*' )
	{
		static motd[2500];
		new len = formatex(motd, sizeof(motd) - 1,	"<body style=^"background-color:#030303; color:#FF8F00^">");
		len += format(motd[len], sizeof(motd) - len - 1,	"<p align=^"center^">");
		len += format(motd[len], sizeof(motd) - len - 1,	"The Armor ability is the amount of AP that given to you at spawn.<br>");
		len += format(motd[len], sizeof(motd) - len - 1,	"<br>");
		len += format(motd[len], sizeof(motd) - len - 1,	"<table>");
		len += format(motd[len], sizeof(motd) - len - 1,	"<tr>");
		len += format(motd[len], sizeof(motd) - len - 1,	"<th></th>");
		for( new CsTeams:i = CS_TEAM_T; i <= CS_TEAM_CT; i++ )
		{
			if( g_armor_enabled[i] )
			{
				len += format(motd[len], sizeof(motd) - len - 1,	"<th>%s</th>",g_team_names[i]);
			}
		}
		len += format(motd[len], sizeof(motd) - len - 1,	"</tr>");
		len += format(motd[len], sizeof(motd) - len - 1,	"<tr>");
		len += format(motd[len], sizeof(motd) - len - 1,	"<th>Armor Intervals</th>");
		for( new CsTeams:i = CS_TEAM_T; i <= CS_TEAM_CT; i++ )
		{
			if( g_armor_enabled[i] )
			{
				len += format(motd[len], sizeof(motd) - len - 1,	"<td>%i</td>", (g_armor_maxamount[i] / g_armor_maxlevels[i]));
			}
		}
		len += format(motd[len], sizeof(motd) - len - 1,	"</tr>");
		len += format(motd[len], sizeof(motd) - len - 1,	"<tr>");
		len += format(motd[len], sizeof(motd) - len - 1,	"<th>Max Level</th>");
		for( new CsTeams:i = CS_TEAM_T; i <= CS_TEAM_CT; i++ )
		{
			if( g_armor_enabled[i] )
			{
				len += format(motd[len], sizeof(motd) - len - 1,	"<td>%i</td>", g_armor_maxlevels[i]);
			}
		}
		len += format(motd[len], sizeof(motd) - len - 1,	"</tr>");
		len += format(motd[len], sizeof(motd) - len - 1,	"<th>Max Armor</th>");
		for( new CsTeams:i = CS_TEAM_T; i <= CS_TEAM_CT; i++ )
		{
			if( g_armor_enabled[i] )
			{
				len += format(motd[len], sizeof(motd) - len - 1,	"<td>%i</td>", g_armor_maxamount[i]);
			}
		}
		len += format(motd[len], sizeof(motd) - len - 1,	"</tr>");
		len += format(motd[len], sizeof(motd) - len - 1,	"</table>");
		len += format(motd[len], sizeof(motd) - len - 1,	"</p>");
		len += format(motd[len], sizeof(motd) - len - 1,	"</body>");
		
		show_motd(client, motd, "XP Armor Info");
	}
	else
	{
		new CsTeams:upgrade = CsTeams:str_to_num(info);
		
		new level = g_armor_level[client][upgrade] + 1;
		new xp = g_armor_first_xp[upgrade] * (1 << (level - 1));
		new amount = g_armor_maxamount[upgrade] * level / g_armor_maxlevels[upgrade];
		
		g_xp[client] -= xp;
		g_armor_level[client][upgrade] = level;
		
		Save(client);
		
		//Print(client, "You bought %s Level %i (%i AP) for %i XP!", g_armor_names[upgrade], level, amount, xp);
		ColorChat(client, RED, "You^x04 bought^x03 %s^x04 Level^x01 %i^x03 (%i AP)^x01 for^x03 %i^x04 XP!", g_armor_names[upgrade], level, amount, xp);
	}
	
	ShowArmorMenu(client);
}

public CallbackArmor(client, menu, item)
{
	static _access, info[4], callback;
	menu_item_getinfo(menu, item, _access, info, sizeof(info) - 1, _, _, callback);
	
	if( info[0] == '*' ) return ITEM_ENABLED;
	
	new CsTeams:upgrade = CsTeams:str_to_num(info);
	if( g_armor_level[client][upgrade] == g_armor_maxlevels[upgrade] )
	{
		return ITEM_DISABLED;
	}
	
	new xp = g_armor_first_xp[upgrade] * (1 << g_armor_level[client][upgrade]);
	if( g_xp[client] < xp )
	{
		return ITEM_DISABLED;
	}
	
	return ITEM_ENABLED;
}

ShowRespawnMenu(client)
{
	static title[128];
	formatex(title, sizeof(title) - 1, "[HNS XP by Exolent]^nRespawn Menu^n^nYour XP: \w%i", g_xp[client]);
	new menu = menu_create(title, "MenuRespawn");
	new callback = menu_makecallback("CallbackRespawn");
	
	menu_additem(menu, "\yHelp", "*", _, callback);
	
	static level, xp, percent, item[128], info[4];
	for( new CsTeams:i = CS_TEAM_T; i <= CS_TEAM_CT; i++ )
	{
		if( g_respawn_enabled[i] )
		{
			level = g_respawn_level[client][i] + 1;
			percent = g_respawn_max_chance[i] * level / g_respawn_maxlevels[i];
			
			if( g_respawn_level[client][i] < g_respawn_maxlevels[i] )
			{
				xp = g_respawn_first_xp[i] * (1 << (level - 1));
				formatex(item, sizeof(item) - 1, "%s: \yLevel %i (%i%%) \r[\w%i XP\r]", g_respawn_names[i], level, percent, xp);
			}
			else
			{
				formatex(item, sizeof(item) - 1, "%s: \yLevel %i (%i%%) \r[\wMaxed Out!\r]", g_respawn_names[i], level, percent);
			}
			
			num_to_str(_:i, info, sizeof(info) - 1);
			
			menu_additem(menu, item, info, _, callback);
		}
	}
	
	menu_display(client, menu);
}

public MenuRespawn(client, menu, item)
{
	if( item == MENU_EXIT )
	{
		menu_destroy(menu);
		ShowMainMenu(client);
		return;
	}
	
	static _access, info[4], callback;
	menu_item_getinfo(menu, item, _access, info, sizeof(info) - 1, _, _, callback);
	menu_destroy(menu);
	
	if( info[0] == '*' )
	{
		static motd[2500];
		new len = formatex(motd, sizeof(motd) - 1,	"<body style=^"background-color:#030303; color:#FF8F00^">");
		len += format(motd[len], sizeof(motd) - len - 1,	"<p align=^"center^">");
		len += format(motd[len], sizeof(motd) - len - 1,	"The Respawn ability is chance to be respawned when you die.<br>");
		len += format(motd[len], sizeof(motd) - len - 1,	"<br>");
		len += format(motd[len], sizeof(motd) - len - 1,	"<table>");
		len += format(motd[len], sizeof(motd) - len - 1,	"<tr>");
		len += format(motd[len], sizeof(motd) - len - 1,	"<th></th>");
		for( new CsTeams:i = CS_TEAM_T; i <= CS_TEAM_CT; i++ )
		{
			if( g_respawn_enabled[i] )
			{
				len += format(motd[len], sizeof(motd) - len - 1,	"<th>%s</th>",g_team_names[i]);
			}
		}
		len += format(motd[len], sizeof(motd) - len - 1,	"</tr>");
		len += format(motd[len], sizeof(motd) - len - 1,	"<tr>");
		len += format(motd[len], sizeof(motd) - len - 1,	"<th>Chance Intervals</th>");
		for( new CsTeams:i = CS_TEAM_T; i <= CS_TEAM_CT; i++ )
		{
			if( g_respawn_enabled[i] )
			{
				len += format(motd[len], sizeof(motd) - len - 1,	"<td>%i%%</td>", (g_respawn_max_chance[i] / g_respawn_maxlevels[i]));
			}
		}
		len += format(motd[len], sizeof(motd) - len - 1,	"</tr>");
		len += format(motd[len], sizeof(motd) - len - 1,	"<tr>");
		len += format(motd[len], sizeof(motd) - len - 1,	"<th>Max Level</th>");
		for( new CsTeams:i = CS_TEAM_T; i <= CS_TEAM_CT; i++ )
		{
			if( g_respawn_enabled[i] )
			{
				len += format(motd[len], sizeof(motd) - len - 1,	"<td>%i</td>", g_respawn_maxlevels[i]);
			}
		}
		len += format(motd[len], sizeof(motd) - len - 1,	"</tr>");
		len += format(motd[len], sizeof(motd) - len - 1,	"<th>Max Chance</th>");
		for( new CsTeams:i = CS_TEAM_T; i <= CS_TEAM_CT; i++ )
		{
			if( g_respawn_enabled[i] )
			{
				len += format(motd[len], sizeof(motd) - len - 1,	"<td>%i%%</td>", g_respawn_max_chance[i]);
			}
		}
		len += format(motd[len], sizeof(motd) - len - 1,	"</tr>");
		len += format(motd[len], sizeof(motd) - len - 1,	"</table>");
		len += format(motd[len], sizeof(motd) - len - 1,	"</p>");
		len += format(motd[len], sizeof(motd) - len - 1,	"</body>");
		
		show_motd(client, motd, "XP Respawn Info");
	}
	else
	{
		new CsTeams:upgrade = CsTeams:str_to_num(info);
		
		new level = g_respawn_level[client][upgrade] + 1;
		new xp = g_respawn_first_xp[upgrade] * (1 << (level - 1));
		new percent = g_respawn_max_chance[upgrade] * level / g_respawn_maxlevels[upgrade];
		
		g_xp[client] -= xp;
		g_respawn_level[client][upgrade] = level;
		
		Save(client);
		
		//Print(client, "You bought %s Level %i (%i%%) for %i XP!", g_respawn_names[upgrade], level, percent, xp);
		ColorChat(client, RED, "You^x04 bought^x03 %s^x04 Level^x01 %i^x03 (%i%%)^x01 for^x03 %i^x04 XP!", g_respawn_names[upgrade], level, percent, xp);
	}
	
	ShowRespawnMenu(client);
}

public CallbackRespawn(client, menu, item)
{
	static _access, info[4], callback;
	menu_item_getinfo(menu, item, _access, info, sizeof(info) - 1, _, _, callback);
	
	if( info[0] == '*' ) return ITEM_ENABLED;
	
	new CsTeams:upgrade = CsTeams:str_to_num(info);
	if( g_respawn_level[client][upgrade] == g_respawn_maxlevels[upgrade] )
	{
		return ITEM_DISABLED;
	}
	
	new xp = g_respawn_first_xp[upgrade] * (1 << g_respawn_level[client][upgrade]);
	if( g_xp[client] < xp || g_respawn_level[client][upgrade] == g_respawn_maxlevels[upgrade] )
	{
		return ITEM_DISABLED;
	}
	
	return ITEM_ENABLED;
}

ShowNoFallMenu(client)
{
	static title[128];
	formatex(title, sizeof(title) - 1, "[HNS XP by Exolent]^nFall Damage Menu^n^nYour XP: \w%i", g_xp[client]);
	new menu = menu_create(title, "MenuNoFall");
	new callback = menu_makecallback("CallbackNoFall");
	
	menu_additem(menu, "\yHelp", "*", _, callback);
	
	static level, xp, percent, item[128], info[4];
	for( new CsTeams:i = CS_TEAM_T; i <= CS_TEAM_CT; i++ )
	{
		if( g_nofall_enabled[i] )
		{
			level = g_nofall_level[client][i] + 1;
			percent = g_nofall_max_chance[i] * level / g_nofall_maxlevels[i];
			
			if( g_nofall_level[client][i] < g_nofall_maxlevels[i] )
			{
				xp = g_nofall_first_xp[i] * (1 << (level - 1));
				formatex(item, sizeof(item) - 1, "%s: \yLevel %i (%i%%) \r[\w%i XP\r]", g_nofall_names[i], level, percent, xp);
			}
			else
			{
				formatex(item, sizeof(item) - 1, "%s: \yLevel %i (%i%%) \r[\wMaxed Out!\r]", g_nofall_names[i], level, percent);
			}
			
			num_to_str(_:i, info, sizeof(info) - 1);
			
			menu_additem(menu, item, info, _, callback);
		}
	}
	
	menu_display(client, menu);
}

public MenuNoFall(client, menu, item)
{
	if( item == MENU_EXIT )
	{
		menu_destroy(menu);
		ShowMainMenu(client);
		return;
	}
	
	static _access, info[4], callback;
	menu_item_getinfo(menu, item, _access, info, sizeof(info) - 1, _, _, callback);
	menu_destroy(menu);
	
	if( info[0] == '*' )
	{
		static motd[2500];
		new len = formatex(motd, sizeof(motd) - 1,	"<body style=^"background-color:#030303; color:#FF8F00^">");
		len += format(motd[len], sizeof(motd) - len - 1,	"<p align=^"center^">");
		len += format(motd[len], sizeof(motd) - len - 1,	"The Fall Damage ability reduces the amount of damage inflicted from falling.<br>");
		len += format(motd[len], sizeof(motd) - len - 1,	"<br>");
		len += format(motd[len], sizeof(motd) - len - 1,	"<table>");
		len += format(motd[len], sizeof(motd) - len - 1,	"<tr>");
		len += format(motd[len], sizeof(motd) - len - 1,	"<th></th>");
		for( new CsTeams:i = CS_TEAM_T; i <= CS_TEAM_CT; i++ )
		{
			if( g_nofall_enabled[i] )
			{
				len += format(motd[len], sizeof(motd) - len - 1,	"<th>%s</th>",g_team_names[i]);
			}
		}
		len += format(motd[len], sizeof(motd) - len - 1,	"</tr>");
		len += format(motd[len], sizeof(motd) - len - 1,	"<tr>");
		len += format(motd[len], sizeof(motd) - len - 1,	"<th>Reduction Intervals</th>");
		for( new CsTeams:i = CS_TEAM_T; i <= CS_TEAM_CT; i++ )
		{
			if( g_nofall_enabled[i] )
			{
				len += format(motd[len], sizeof(motd) - len - 1,	"<td>%i%%</td>", (g_nofall_max_chance[i] / g_nofall_maxlevels[i]));
			}
		}
		len += format(motd[len], sizeof(motd) - len - 1,	"</tr>");
		len += format(motd[len], sizeof(motd) - len - 1,	"<tr>");
		len += format(motd[len], sizeof(motd) - len - 1,	"<th>Max Level</th>");
		for( new CsTeams:i = CS_TEAM_T; i <= CS_TEAM_CT; i++ )
		{
			if( g_nofall_enabled[i] )
			{
				len += format(motd[len], sizeof(motd) - len - 1,	"<td>%i</td>", g_nofall_maxlevels[i]);
			}
		}
		len += format(motd[len], sizeof(motd) - len - 1,	"</tr>");
		len += format(motd[len], sizeof(motd) - len - 1,	"<th>Max Chance</th>");
		for( new CsTeams:i = CS_TEAM_T; i <= CS_TEAM_CT; i++ )
		{
			if( g_nofall_enabled[i] )
			{
				len += format(motd[len], sizeof(motd) - len - 1,	"<td>%i%%</td>", g_nofall_max_chance[i]);
			}
		}
		len += format(motd[len], sizeof(motd) - len - 1,	"</tr>");
		len += format(motd[len], sizeof(motd) - len - 1,	"</table>");
		len += format(motd[len], sizeof(motd) - len - 1,	"</p>");
		len += format(motd[len], sizeof(motd) - len - 1,	"</body>");
		
		show_motd(client, motd, "XP Fall Damage Info");
	}
	else
	{
		new CsTeams:upgrade = CsTeams:str_to_num(info);
		
		new level = g_nofall_level[client][upgrade] + 1;
		new xp = g_nofall_first_xp[upgrade] * (1 << (level - 1));
		new percent = g_nofall_max_chance[upgrade] * level / g_nofall_maxlevels[upgrade];
		
		g_xp[client] -= xp;
		g_nofall_level[client][upgrade] = level;
		
		Save(client);
		
		//Print(client, "You bought %s Level %i (%i%%) for %i XP!", g_nofall_names[upgrade], level, percent, xp);
		ColorChat(client, RED, "You^x04 bought^x03 %s^x04 Level^x01 %i^x03 (%i%%)^x01 for^x03 %i^x04 XP!", g_nofall_names[upgrade], level, percent, xp);
	}
	
	ShowNoFallMenu(client);
}

public CallbackNoFall(client, menu, item)
{
	static _access, info[4], callback;
	menu_item_getinfo(menu, item, _access, info, sizeof(info) - 1, _, _, callback);
	
	if( info[0] == '*' ) return ITEM_ENABLED;
	
	new CsTeams:upgrade = CsTeams:str_to_num(info);
	if( g_nofall_level[client][upgrade] == g_nofall_maxlevels[upgrade] )
	{
		return ITEM_DISABLED;
	}
	
	new xp = g_nofall_first_xp[upgrade] * (1 << g_nofall_level[client][upgrade]);
	if( g_xp[client] < xp || g_nofall_level[client][upgrade] == g_nofall_maxlevels[upgrade] )
	{
		return ITEM_DISABLED;
	}
	
	return ITEM_ENABLED;
}

ShowPlayerMenu(client)
{
	new menu = menu_create("Player Info Menu", "MenuPlayer");
	
	new name[32], authid[35];
	for( new i = 1; i <= g_max_clients; i++ )
	{
		if( !is_user_connected(i) ) continue;
		
		get_user_name(i, name, sizeof(name) - 1);
		get_user_authid(i, authid, sizeof(authid) - 1);
		
		menu_additem(menu, name, authid);
	}
	
	menu_display(client, menu);
}

public MenuPlayer(client, menu, item)
{
	if( item == MENU_EXIT )
	{
		menu_destroy(menu);
		ShowMainMenu(client);
		return;
	}
	
	static _access, authid[35], callback;
	menu_item_getinfo(menu, item, _access, authid, sizeof(authid) - 1, _, _, callback);
	menu_destroy(menu);
	
	new player = find_player("c", authid);
	if( !is_user_connected(player) )
	{
		ShowMainMenu(client);
		return;
	}
	
	new name[32];
	get_user_name(player, name, sizeof(name) - 1);
	
	static motd[2500];
	new len = copy(motd, sizeof(motd) - 1, "<html>");
	len += format(motd[len], sizeof(motd) - len - 1, "<b><font size=^"4^">Name:</font></b> %s<br><br>", name);
	len += format(motd[len], sizeof(motd) - len - 1, "<b><font size=^"4^">XP:</font></b> %i<br><br>", g_xp[player]);
	if( g_any_nade_enabled )
	{
		len += format(motd[len], sizeof(motd) - len - 1, "<b><font size=^"4^">Grenades Levels:</font></b><br>");
		for( new i = 0; i < Grenades; i++ )
		{
			if( g_nade_enabled[i] )
			{
				len += format(motd[len], sizeof(motd) - len - 1, "<b>%s:</b> %i/%i<br>", g_nade_names[i], g_nade_level[player][i], g_nade_maxlevels[i]);
			}
		}
	}
	if( g_any_health_enabled )
	{
		len += format(motd[len], sizeof(motd) - len - 1, "<br><b><font size=^"4^">Health Levels:</font></b><br>");
		for( new CsTeams:i = CS_TEAM_T; i <= CS_TEAM_CT; i++ )
		{
			if( g_health_enabled[i] )
			{
				len += format(motd[len], sizeof(motd) - len - 1, "<b>%s:</b> %i/%i (%i/%i HP)<br>",\
					g_health_names[i], g_health_level[player][i], g_health_maxlevels[i],\
					(g_health_maxamount[i] * g_health_level[player][i] / g_health_maxlevels[i]), g_health_maxamount[i]);
			}
		}
	}
	if( g_any_armor_enabled )
	{
		len += format(motd[len], sizeof(motd) - len - 1, "<br><b><font size=^"4^">Armor Levels:</font></b><br>");
		for( new CsTeams:i = CS_TEAM_T; i <= CS_TEAM_CT; i++ )
		{
			if( g_armor_enabled[i] )
			{
				len += format(motd[len], sizeof(motd) - len - 1, "<b>%s:</b> %i/%i (%i/%i AP)<br>",\
					g_armor_names[i], g_armor_level[player][i], g_armor_maxlevels[i],\
					(g_armor_maxamount[i] * g_armor_level[player][i] / g_armor_maxlevels[i]), g_armor_maxamount[i]);
			}
		}
	}
	if( g_any_respawn_enabled )
	{
		len += format(motd[len], sizeof(motd) - len - 1, "<br><b><font size=^"4^">Respawn Levels:</font></b><br>");
		for( new CsTeams:i = CS_TEAM_T; i <= CS_TEAM_CT; i++ )
		{
			if( g_respawn_enabled[i] )
			{
				len += format(motd[len], sizeof(motd) - len - 1, "<b>%s:</b> %i/%i (%i/%i %%)<br>",\
					g_respawn_names[i], g_respawn_level[player][i], g_respawn_maxlevels[i],\
					(g_respawn_max_chance[i] * g_respawn_level[player][i] / g_respawn_maxlevels[i]), g_respawn_max_chance[i]);
			}
		}
	}
	if( g_any_nofall_enabled )
	{
		len += format(motd[len], sizeof(motd) - len - 1, "<br><b><font size=^"4^">Fall Damage Levels:</font></b><br>");
		for( new CsTeams:i = CS_TEAM_T; i <= CS_TEAM_CT; i++ )
		{
			if( g_nofall_enabled[i] )
			{
				len += format(motd[len], sizeof(motd) - len - 1, "<b>%s:</b> %i/%i (%i/%i %%)<br>",\
					g_nofall_names[i], g_nofall_level[player][i], g_nofall_maxlevels[i],\
					(g_nofall_max_chance[i] * g_nofall_level[player][i] / g_nofall_maxlevels[i]), g_nofall_max_chance[i]);
			}
		}
	}
	len += format(motd[len], sizeof(motd) - len - 1, "</html>");
	
	show_motd(client, motd, "HNS XP Mod Info");
	
	ShowPlayerMenu(client);
}


IsUserAuthorized(client)
{
	return g_authid[client][0] != 0;
}

Print(client, const msg_fmt[], any:...)
{
	static message[192];
	new len = formatex(message, sizeof(message) - 1, "%s^x03 ", MESSAGE_TAG);
	vformat(message[len], sizeof(message) - len - 1, msg_fmt, 3);
	
	if( client )
	{
		message_begin(MSG_ONE_UNRELIABLE, g_msgid_SayText, _, client);
		write_byte(client);
		write_string(message);
		message_end();
	}
	else
	{
		for( new i = g_first_client; i <= g_max_clients; i++ )
		{
			if( is_user_connected(i) )
			{
				message_begin(MSG_ONE_UNRELIABLE, g_msgid_SayText, _, i);
				write_byte(i);
				write_string(message);
				message_end();
			}
		}
	}
}

Load(client)
{
	#if defined USING_SQL
	static query[128];
	formatex(query, sizeof(query) - 1, "SELECT `data` FROM `hns_xp` WHERE `authid` = '%s';", g_authid[client]);
	
	static data[2];
	data[0] = client;
	
	SQL_ThreadQuery(g_sql_tuple, "QueryLoadData", query, data, sizeof(data));
	#else
	static data[256], timestamp;
	if( nvault_lookup(g_vault, g_authid[client], data, sizeof(data) - 1, timestamp) )
	{
		ParseLoadData(client, data);
		return;
	}
	else
	{
		NewUser(client);
	}
	#endif
}

#if defined USING_SQL
public QueryLoadData(failstate, Handle:query, error[], errnum, data[], size, Float:queuetime)
{
	if( failstate == TQUERY_CONNECT_FAILED
	|| failstate == TQUERY_QUERY_FAILED )
	{
		set_fail_state(error);
	}
	else
	{
		if( SQL_NumResults(query) )
		{
			static sqldata[256];
			SQL_ReadResult(query, 0, sqldata, sizeof(sqldata) - 1);
			ParseLoadData(data[0], sqldata);
		}
		else
		{
			NewUser(data[0]);
		}
	}
}
#endif

ParseLoadData(client, data[256])
{
	static num[6];
	strbreak(data, num, sizeof(num) - 1, data, sizeof(data) - 1);
	
	g_xp[client] = str_to_num(num);
	
	for( new i = 0; i < Grenades; i++ )
	{
		strbreak(data, num, sizeof(num) - 1, data, sizeof(data) - 1);
		g_nade_level[client][i] = clamp(str_to_num(num), 0, g_nade_maxlevels[i]);
	}
	
	for( new CsTeams:i = CS_TEAM_T; i <= CS_TEAM_CT; i++ )
	{
		strbreak(data, num, sizeof(num) - 1, data, sizeof(data) - 1);
		g_armor_level[client][i] = clamp(str_to_num(num), 0, g_armor_maxlevels[i]);
	}
	
	for( new CsTeams:i = CS_TEAM_T; i <= CS_TEAM_CT; i++ )
	{
		strbreak(data, num, sizeof(num) - 1, data, sizeof(data) - 1);
		g_respawn_level[client][i] = clamp(str_to_num(num), 0, g_respawn_maxlevels[i]);
	}
	
	for( new CsTeams:i = CS_TEAM_T; i <= CS_TEAM_CT; i++ )
	{
		strbreak(data, num, sizeof(num) - 1, data, sizeof(data) - 1);
		g_health_level[client][i] = clamp(str_to_num(num), 0, g_health_maxlevels[i]);
	}
	
	for( new CsTeams:i = CS_TEAM_T; i <= CS_TEAM_CT; i++ )
	{
		strbreak(data, num, sizeof(num) - 1, data, sizeof(data) - 1);
		g_nofall_level[client][i] = clamp(str_to_num(num), 0, g_nofall_maxlevels[i]);
	}
	
	#if defined USING_SQL
	g_loaded_data[client] = 1;
	#endif
}

NewUser(client)
{
	g_first_time[client] = 1;
	
	g_xp[client] = ENTRY_XP;
	arrayset(g_nade_level[client], 0, sizeof(g_nade_level[]));
	for( new CsTeams:i = CS_TEAM_T; i <= CS_TEAM_CT; i++ )
	{
		g_armor_level[client][i] = 0;
		g_respawn_level[client][i] = 0;
		g_health_level[client][i] = 0;
		g_nofall_level[client][i] = 0;
	}
}

Save(client)
{
	if( !IsUserAuthorized(client) ) return;
	
	static data[256];
	new len = formatex(data, sizeof(data) - 1, "%i", g_xp[client]);
	
	for( new i = 0; i < Grenades; i++ )
	{
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_nade_level[client][i]);
	}
	
	for( new CsTeams:i = CS_TEAM_T; i <= CS_TEAM_CT; i++ )
	{
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_armor_level[client][i]);
	}
	
	for( new CsTeams:i = CS_TEAM_T; i <= CS_TEAM_CT; i++ )
	{
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_respawn_level[client][i]);
	}
	
	for( new CsTeams:i = CS_TEAM_T; i <= CS_TEAM_CT; i++ )
	{
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_health_level[client][i]);
	}
	
	for( new CsTeams:i = CS_TEAM_T; i <= CS_TEAM_CT; i++ )
	{
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_nofall_level[client][i]);
	}
	
	#if defined USING_SQL
	static name[32];
	get_user_name(client, name, sizeof(name) - 1);
	
	static query[512];
	if( g_loaded_data[client] )
	{
		formatex(query, sizeof(query) - 1, "UPDATE `hns_xp` SET `name` = '%s', `data` = '%s' WHERE `authid` = '%s';", name, data, g_authid[client]);
	}
	else
	{
		formatex(query, sizeof(query) - 1, "INSERT INTO `hns_xp` ( `name`, `authid`, `data` ) VALUES ( '%s', '%s', '%s' );", name, g_authid[client], data);
	}
	
	SQL_ThreadQuery(g_sql_tuple, "QuerySaveData", query);
	#else
	nvault_set(g_vault, g_authid[client], data);
	#endif
}

#if defined USING_SQL
public QuerySaveData(failstate, Handle:query, error[], errnum, data[], size, Float:queuetime)
{
	if( failstate == TQUERY_CONNECT_FAILED
	|| failstate == TQUERY_QUERY_FAILED )
	{
		set_fail_state(error);
	}
}
#endif
