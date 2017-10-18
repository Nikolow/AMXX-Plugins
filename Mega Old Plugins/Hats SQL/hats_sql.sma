/*

You will need two tables: hats_hats and hats_users.
hats_hats has columns 'id', 'name' and 'model'; 
all hat models should be in there, 'id' should start at 1.
hats_users has columns 'authid' and 'access'. 
The 'access' column decides which hats a user can use, it works like this: 
if a user is allowed hat id 1, 3 and 5, the access should be: 2^1 + 2^3 + 2^5 = 42.

*/


#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <sqlx>

new Handle:g_loginData;

new cvar_hats;
new cvar_obeyHatPermissions;

new g_userHatEntity[33];
new g_userHatName[33][32];

new g_uniqueNumber = 0;
new g_userTicket[33];

new g_queryHolder[256];

/*
   Init
        */

public plugin_init()
{
	register_plugin("playerHats", "0.1", "MaximusBrood");
	register_cvar("playerhats_version", "0.1", FCVAR_SERVER);
	
	register_forward(FM_PlayerPreThink, "event_clientPrethink");
	
	//register_clcmd("amx_givehat", "cmd_giveHat", ADMIN_LEVEL_A, "- <player> <(part of) name of hat>");
	//register_clcmd("amx_removehat", "cmd_removeHat", ADMIN_LEVEL_A, "- <player>");
	register_clcmd("amx_removeallhats", "cmd_removeAllHats", ADMIN_LEVEL_A, "- Removes everyone's hat");
	register_clcmd("say", "cmd_say");
	register_clcmd("say_team", "cmd_say");
		
	cvar_hats = register_cvar("sv_hats", "1");	
	cvar_obeyHatPermissions = register_cvar("sv_obeyhatpermissions", "1");
}

public plugin_precache()
{
	g_loginData = SQL_MakeStdTuple();
	
	//Precache all the models in the database, make a connection for our convience
	new errorNumber, errorMessage[128];
	new Handle:connection = SQL_Connect( g_loginData, errorNumber, errorMessage, (sizeof errorMessage - 1) );
	
	//Set failstate on connection error
	if(connection == Empty_Handle)
		set_fail_state2("Failure while attempting to connect to database: %s (%d)", errorNumber, errorMessage);
	
	new Handle:queryHandle = SQL_PrepareQuery(connection, "SELECT `model` FROM `hats_hats`;");
	
	//Set failstate on query error
	if( !SQL_Execute(queryHandle) )
	{
		errorNumber = SQL_QueryError( queryHandle, errorMessage, (sizeof errorMessage - 1) );
		set_fail_state2("Failure while executing model query: %s (%d)", errorNumber, errorMessage);
	}
	
	//Start precaching
	new modelPath[64];
	while( SQL_MoreResults(queryHandle) )
	{
		SQL_ReadResult(queryHandle, 0, modelPath, 63);
			
		if( file_exists(modelPath) )
			precache_model(modelPath);
		else
			log_amx("Found unknown hat model: %s", modelPath);
			
		SQL_NextRow(queryHandle);
	}
	
	SQL_FreeHandle(queryHandle);
	SQL_FreeHandle(connection);
}

public client_connect(id)
{
	g_userTicket[id] = ++g_uniqueNumber;
	
	//Remove the player's hat if he has one on
	removeHat(id);
}

public client_disconnect(id)
{
	g_userTicket[id] = ++g_uniqueNumber;
	
	//Remove the player's hat if he has one on
	removeHat(id);
}

/*
   Commands
            */
/*public cmd_giveHat(id, level, cid)
{
	if (!cmd_access(id, level, cid, 3))
		return PLUGIN_HANDLED;
}

public cmd_removeHat(id, level, cid)
{
	if (!cmd_access(id, level, cid, 2))
		return PLUGIN_HANDLED;
}*/

public cmd_removeAllHats(id, level, cid)
{
	if (!cmd_access(id, level, cid, 1))
		return PLUGIN_HANDLED;
	
	static players[32], playerAmount;
	get_players(players, playerAmount);
	
	for(new a = 0; a < playerAmount; ++a)
		removeHat(players[a]);
		
	return PLUGIN_CONTINUE;
}

public cmd_say(id)
{
	new talk[16];
	read_args(talk, 15);
	remove_quotes(talk);
	
	if(equali(talk, "/hats"))
		return cmd_sayHat(id);
	else if(equali(talk, "/hatinfo"))
		return cmd_sayHatInfo(id);
	else if(equali(talk, "/hatstatus"))
		return cmd_sayHatStatus(id);
	else if(equali(talk, "/hatoff"))
		return cmd_sayHatOff(id);
		
	return PLUGIN_CONTINUE;
}

public cmd_sayHat(id)
{
	if(!isPlayerHatsEnabled(id))
		return PLUGIN_HANDLED;
	
	if(get_pcvar_num(cvar_obeyHatPermissions) == 1)
	{
		static authid[32];
		get_user_authid(id, authid, 31);
		
		format(g_queryHolder, (sizeof g_queryHolder - 1), "SELECT `id`, `name` FROM hats_hats WHERE POW(2, `id`) & (SELECT `access` FROM hats_users WHERE `authid` = '%s');", authid);
	}
	else
		format(g_queryHolder, (sizeof g_queryHolder - 1), "SELECT `id`, `name` FROM hats_hats;");
		
	new data[2];
	data[0] = id;
	data[1] = g_userTicket[id];
	
	SQL_ThreadQuery(g_loginData, "SQLCallback_sayMenu", g_queryHolder, data, 2);
	
	return PLUGIN_HANDLED;
}

public cmd_sayHatInfo(id)
{
	show_motd(id, "http://gotjuice.nl/hats.php");
	return PLUGIN_CONTINUE;
}

public cmd_sayHatStatus(id)
{
	if(!isPlayerHatsEnabled(id))
		return PLUGIN_HANDLED;
	
	if(g_userHatEntity[id] < 1)
		client_print(id, print_chat, "You currently have no hat on.");
	else
		client_print(id, print_chat, "You currently have a '%s' hat on.", g_userHatName[id]);
		
	return PLUGIN_HANDLED;
}

public cmd_sayHatOff(id)
{
	if(g_userHatEntity[id] < 1)
		client_print(id, print_chat, "I can't remove your hat because you don't have one on.");
	else
	{
		removeHat(id);
		client_print(id, print_chat, "Your hat was removed.");
	}
	
	return PLUGIN_HANDLED;
}

/*
   Main
        */
public SQLCallback_sayMenu(failstate, Handle:query, errorMessage[], errorNumber, data[], size)
{
	if( !threadedQueryErrorHandler("SQLCallback_sayMenu", failstate, errorNumber, errorMessage) )
		return;
	
	new id = data[0];
	
	//Check if we are still talking to the same user and if he is actually connected
	if( !is_user_connected(id) || g_userTicket[id] != data[1] )
		return;
		
	new hatAmount = SQL_NumResults(query);
	if(hatAmount == 0)
	{
		client_print(id, print_chat, "You have no access to any hat. For more information, say /hatinfo");
		return;
	}
	
	//We now make a menu with all possible hats to which our user has access to.
	//The model won't be sent with it, we will query the database for it again later.
	new menu = menu_create("Pick a hat", "menuHandler_hatMenu", 0);
	
	static hatId, hatIdString[6], hatName[32];
	while( SQL_MoreResults(query) )
	{
		hatId = SQL_ReadResult(query, 0);
		SQL_ReadResult(query, 1, hatName, 31);
		
		format(hatIdString, 5, "%d", hatId);
		menu_additem(menu, hatName, hatIdString);
		
		SQL_NextRow(query);
	}
	
	//Add an exit button and display the menu
	menu_addblank(menu);
	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
	menu_display(id, menu, 0);
}

public menuHandler_hatMenu(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return;
	}
	
	//Get the data out of the chosen hat to see which one it is
	new hatIdString[6], hatId, dummyString[2], dummy;
	menu_item_getinfo(menu, item, dummy, hatIdString, 5, dummyString, 1, dummy);
	
	hatId = str_to_num(hatIdString);

	//Do yet another query to check if the user has access to this hat
	//Get the name and model
	if(get_pcvar_num(cvar_obeyHatPermissions) == 1)
	{
		static authid[32];
		get_user_authid(id, authid, 31);
	
		format(g_queryHolder, (sizeof g_queryHolder - 1), "SELECT `name`, `model` FROM hats_hats WHERE `id` = %d && POW(2, `id`) & (SELECT `access` FROM hats_users WHERE `authid` = '%s');", hatId, authid);
	} else
		format(g_queryHolder, (sizeof g_queryHolder - 1), "SELECT `name`, `model` FROM hats_hats WHERE `id` = %d;", hatId);
	
	new data[2];
	data[0] = id;
	data[1] = g_userTicket[id];
	
	SQL_ThreadQuery(g_loginData, "SQLCallback_giveHat", g_queryHolder, data, 2);
	
	//Prevent the world from imploding
	menu_destroy(menu);
}

public SQLCallback_giveHat(failstate, Handle:query, errorMessage[], errorNumber, data[], size)
{
	if( !threadedQueryErrorHandler("SQLCallback_sayMenu", failstate, errorNumber, errorMessage) )
		return;
		
	new id = data[0];
	
	//Check if we are still talking to the same user and if he is actually connected
	if( !is_user_connected(id) || g_userTicket[id] != data[1] )
		return;
		
	//If there were no results, the user didn't have access
	if(SQL_NumResults(query) == 0)
		client_print(id, print_chat, "You have no access to this hat.");
		
	//Set the hat
	static hatModel[64];
	SQL_ReadResult(query, 0, g_userHatName[id], 31);
	SQL_ReadResult(query, 1, hatModel, 63);
	
	setHat(id, hatModel);
}

/*
   Model Related
                 */
setHat(target, model[])
{
	if( !file_exists(model) )
		return;
		
	//If the player doesn't have a hat already, create the hat entity
	//Otherwise just set the model
	if(g_userHatEntity[target] < 1)
	{
		g_userHatEntity[target] = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"));
		
		if(g_userHatEntity[target] > 0)
		{
			set_pev(g_userHatEntity[target], pev_movetype, MOVETYPE_FOLLOW);
			set_pev(g_userHatEntity[target], pev_aiment, target);
			set_pev(g_userHatEntity[target], pev_rendermode, kRenderNormal);
			set_pev(g_userHatEntity[target], pev_renderamt, 0.0);
			engfunc(EngFunc_SetModel, g_userHatEntity[target], model);
		}
	} else
		engfunc(EngFunc_SetModel, g_userHatEntity[target], model);
}

removeHat(target)
{
	if(g_userHatEntity[target] > 0)
		engfunc(EngFunc_RemoveEntity, g_userHatEntity[target]);
		
	g_userHatName[target][0] = 0;
	g_userHatEntity[target] = 0;
}

public event_clientPrethink(id)
{
	static hatEntity;
	hatEntity = g_userHatEntity[id];
	
	if(is_user_alive(id) && g_userHatEntity[id] > 0)
	{
		static Float:invisibleAmount, Float:color;
			
		pev(id, pev_renderamt, invisibleAmount);
		pev(id, pev_rendercolor, color);
		
		set_pev(hatEntity, pev_renderfx, pev(id, pev_renderfx));
		set_pev(hatEntity, pev_rendercolor, color);
		set_pev(hatEntity, pev_rendermode, pev(id, pev_rendermode));
		set_pev(hatEntity, pev_renderamt, invisibleAmount);
	}
}

/*
   Helpers
           */
bool:isPlayerHatsEnabled(id)
{
	if(get_pcvar_num(cvar_hats) != 1)
	{
		client_print(id, print_chat, "Hats are currently disabled.");
		return false;
	}
	
	return true;
}

set_fail_state2(unformattedFailstate[], ...)
{
	new formattedFailstate[256];
	vformat(formattedFailstate, 255, unformattedFailstate, 2);
	
	set_fail_state(formattedFailstate);
}

bool:connectionErrorHandler(functionName[], errorNumber, errorMessage[])
{
	log_amx("<%s> Unable to connect to database: %s (%d)", functionName, errorMessage, errorNumber);
	
	return false;
}

bool:threadedQueryErrorHandler(functionName[], failstate, errorNumber, errorMessage[])
{
	if(failstate == TQUERY_CONNECT_FAILED)
		return connectionErrorHandler(functionName, errorNumber, errorMessage);
	
	if(failstate == TQUERY_QUERY_FAILED)
	{
		log_amx("<%s> Unable to query database: %s (%d)", functionName, errorMessage, errorNumber);
		
		return false;
	}
	
	if(errorNumber)
	{
		log_amx("<%s> Error while querying database: %s (%d)", functionName, errorMessage, errorNumber);
		
		return false;
	}
	
	return true;
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1026\\ f0\\ fs16 \n\\ par }
*/
