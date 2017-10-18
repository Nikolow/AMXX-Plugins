#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <geoip>
#include <fun>
#include <hamsandwich>
#include <sqlx>
#include <engine>

#pragma ctrlchar '\'

#define PLUGIN "#GroundJumperz | Menu"
#define VERSION "1.0"
#define AUTHOR "Trooligt"

#define TAG "#GroundJumperz"
#define Website "we dont have a  website yet but soon"
#define menusize 220

new g_pstatus[33], g_HideRank[33], g_ColorMode[33], g_Tag[33][10], g_Warning[33], g_Protected[33];
new ShowReason, Name[33], cStatus, cBanTime, Style[33], Reason[33], g_msgFade, Mappy[33];
new message[192], sayText, teamInfo, maxPlayers, tTransfer[33], IsMuted[33];
new strName[191], strText[191], alive[11];
new cVoting,cVotetype,cVoteYes,cVoteNo,cwarning;

new Handle:g_MySQL_Tuple, Handle:g_MySQL_Connection
new g_MySQL_Error[512], cHost[64], cUser[64], cPassword[64], cName[64], g_Players[33];

new const Vip_Cmd[][] = {
	"ecmenu", "cmdShowMenu",
	"menu", "cmdShowMenu",
	"EC_Tag", "AHTag",
	"EC_Map", "AHMap",
	"admin", "onlinevips",
	"admins", "onlinevips"
}
/* Reasons */
new TotalReasons = 14
new const REDEN[][64] = {
    "Abuse",
    "Racism",
    "Advertisement",
    "Bug Using",
    "Harrasment",
    "Blocking",
    "Porn Spray",
    "FunJump",
    "Understab",
    "Undercamp",
    "Scripts",
    "Afk",
    "Mic Spam",
    "Chat Spam"
}
/* Player Skills */
new const Skill[][64] = {
    "Player",	// 0
    "Owner", 	// 1
    "Admin", 	// 2
    "VIP", 	// 3
    "Members" 	// 4
}
/* Colors */
new TotalColors = 3
new const Color[][64] = {
    "Yellow (Normal)",
    "Green",
    "Team Color"
}
public plugin_init() {
	/* SQL */
	register_cvar("Menu_Host", "0", FCVAR_PROTECTED | FCVAR_SPONLY) 
	register_cvar("Menu_User", "0", FCVAR_PROTECTED | FCVAR_SPONLY)
	register_cvar("Menu_Password", "0", FCVAR_PROTECTED | FCVAR_SPONLY)
	register_cvar("Menu_Name", "0", FCVAR_PROTECTED | FCVAR_SPONLY)
	
	/* Normal */
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	/* Cvar's */
	cStatus 	= register_cvar("egmenu_status"		, "1");
	cBanTime	= register_cvar("egmenu_bantime"	, "60.0");
	cwarning	= register_cvar("egmenu_warning"	, "3");
	
	/* Other Stuff */
	g_msgFade = get_user_msgid("ScreenFade");
	
	/* Say Commands */
	for( new i=0; i < sizeof(Vip_Cmd); i +=2 ) {
		register_vipcmd(Vip_Cmd[i], Vip_Cmd[i+1])
	}
	
	/* Menu Register */
	register_menucmd(register_menuid("\\d#AwesomeJumpz:"),	(1<<0|1<<1),"VoteMenu");
	
	/* Color Say Stuff */
	sayText = get_user_msgid ("SayText")
	teamInfo = get_user_msgid ("TeamInfo")
	maxPlayers = get_maxplayers()
	register_message (sayText, "avoid_duplicated")
	register_clcmd ("say", "hook_say")
	register_clcmd ("say_team", "hook_teamsay")
}
public plugin_end() {
	SQL_FreeHandle(g_MySQL_Tuple)
}

/*
EncodedGaming:
	- Say Stuff
*/
stock register_vipcmd(const cmd[], const func[]) {
	new Temp[32]
	register_clcmd(cmd,func)
	formatex(Temp,31,"say %s", cmd)
	register_clcmd(Temp,func)
	formatex(Temp,31,"say_team %s", cmd)
	register_clcmd(Temp,func)
	formatex(Temp,31,"say /%s", cmd)
	register_clcmd(Temp,func)
	formatex(Temp,31,"say_team /%s", cmd)
	register_clcmd(Temp,func)
	formatex(Temp,31,"say .%s", cmd)
	register_clcmd(Temp,func)
	formatex(Temp,31,"say_team .%s", cmd)
	register_clcmd(Temp,func)
}
/*
EncodedGaming:	
	- Admins online
*/
public onlinevips(id) {
	new players[32],pnum, player;
	get_players(players,pnum);
		
	new temp[216],name[32], count
	
	for( new i; i<pnum; i++ ) {
		if(g_pstatus[players[i]] && !g_HideRank[players[i]]) {
			player = players[i]
			count++
			get_user_name(player,name,31)
			formatex(temp,215,"%s %s !y(!g%s!y),!team ",temp,name,Skill[g_pstatus[player]])
		}
	}
	if(count)
		ChatColor(id, "!g[%s]!y Admins Online:!team %s!y", TAG, temp)
	else
		ChatColor(id, "!g[%s]!y No admins online.", TAG)
}
/*
EncodedGaming:
	- Player Connected
*/

public client_connect(id) {
	MySQL_Connect()
	// The id comes from WHO connects, so we get the right person
	
	// We need his Steam id to be able to save it
	new steam_id[21], name[32]
	// 20 is the number in steam_id[] - 1,  21-1 = 20, called data bytes here
	get_user_authid(id, steam_id, 20)
	get_user_name(id, name, 31) // Again, 32 - 1 = 31
	new FormatQuery[256];
	/* 1. Look in the database if our user is already there */
	format(FormatQuery, 255, "SELECT id,pstatus,hiderank,colormode,warning,protection,tag FROM MenuAccess WHERE steam_id=\"%s\"", steam_id)

	// This is how we connect to the MySQL, just a bounch of code, dont bother about it xD
	new Handle:Query = SQL_PrepareQuery(g_MySQL_Connection, FormatQuery)

	if(!SQL_Execute(Query)) {
		SQL_QueryError(Query, g_MySQL_Error, 511)
		server_print("(EE) %s", g_MySQL_Error)
		return PLUGIN_HANDLED
	}

	/* 2a. IF he is already in the database */
	if(SQL_MoreResults(Query)) {
		g_Players[id] = SQL_ReadResult(Query, 0)
		g_pstatus[id] 	= SQL_ReadResult(Query, 1)
		g_HideRank[id] 	= SQL_ReadResult(Query, 2)
		g_ColorMode[id] = SQL_ReadResult(Query, 3)
		g_Warning[id] = SQL_ReadResult(Query, 4)
		g_Protected[id] = SQL_ReadResult(Query, 5)
		new Tag[32]; 	SQL_ReadResult(Query, 6, Tag, 31)
		copy(g_Tag[id],9,Tag)
		format(FormatQuery, 255, "UPDATE MenuAccess SET name=\"%s\" WHERE steam_id=\"%s\"", name, steam_id)
		SQL_SimpleQuery(g_MySQL_Connection, FormatQuery)
		
	}

	/* 2b. IF he IS NOT, then we create him */
	else {
		format(FormatQuery, 255, "INSERT INTO MenuAccess (`name`, `steam_id`) VALUES (\"%s\", \"%s\")", name, steam_id)

		new Handle:Query = SQL_PrepareQuery(g_MySQL_Connection, FormatQuery);

		if(!SQL_Execute(Query)) {
			SQL_QueryError(Query, g_MySQL_Error, 511)
			server_print("(EE) %s", g_MySQL_Error)
			SQL_FreeHandle(Query)
			return PLUGIN_HANDLED
		}
		g_Players[id] = SQL_GetInsertId(Query)
		SQL_FreeHandle(Query);
	}
	
	return PLUGIN_HANDLED
}
public Save_MySql(id) {
	new szSteamId[32], szTemp[512]
	get_user_authid(id, szSteamId, charsmax(szSteamId))

	// Here we will update the user hes information in the database where the steamid matches.
	format(szTemp,charsmax(szTemp),"UPDATE MenuAccess SET `pstatus` = '%i', `hiderank` = '%i', `colormode` = '%i', `warning` = '%i', `protection` = '%i', `tag` = '%s' WHERE `steam_id` = '%s'", g_pstatus[id], g_HideRank[id], g_ColorMode[id], g_Warning[id], g_Protected[id], g_Tag[id], szSteamId);
	SQL_SimpleQuery(g_MySQL_Connection, szTemp)
}
/*
public Load_MySql(id) {
	new szSteamId[32], szTemp[512]
	get_user_authid(id, szSteamId, charsmax(szSteamId))
	
	new Data[1]; Data[0] = id
	
	//we will now select from the table `tutorial` where the steamid match
	format(szTemp,charsmax(szTemp), "SELECT id,pstatus,hiderank,colormode,warning,protection,tag FROM MenuAccess WHERE steam_id=\"%s\"", szSteamId)
	SQL_ThreadQuery(g_MySQL_Tuple,"register_client",szTemp,Data,1)
}

public register_client(FailState,Handle:Query,Error[],Errcode,Data[],DataSize) {
	if(FailState == TQUERY_CONNECT_FAILED) {
		log_amx("Load - Could not connect to SQL database.  [%d] %s", Errcode, Error)
	}
	else if(FailState == TQUERY_QUERY_FAILED) {
		log_amx("Load Query failed. [%d] %s", Errcode, Error)
	}
	
	new id
	id = Data[0]
	
	if(SQL_NumResults(Query) < 1) 
	{
		//.if there are no results found
		
		new szSteamId[32]
		get_user_authid(id, szSteamId, charsmax(szSteamId)) // get user's steamid
		
		//  if its still pending we can't do anything with it
		if (equal(szSteamId,"ID_PENDING"))
			return PLUGIN_HANDLED
		
		new szTemp[512]
		new name[32]; get_user_name(id, name, 31);
		// now we will insturt the values into our table.
		format(FormatQuery, 255, "INSERT INTO MenuAccess (`name`, `steam_id`) VALUES (\"%s\", \"%s\")", name, szSteamId)
		SQL_ThreadQuery(g_MySQL_Tuple,"IgnoreHandle",szTemp)
	} 
	else  {
		// if there are results found
		g_Players[id] 	= SQL_ReadResult(Query, 0)
		g_pstatus[id] 	= SQL_ReadResult(Query, 1)
		g_HideRank[id] 	= SQL_ReadResult(Query, 2)
		g_ColorMode[id] = SQL_ReadResult(Query, 3)
		g_Warning[id] = SQL_ReadResult(Query, 4)
		g_Protected[id] = SQL_ReadResult(Query, 5)
		new Tag[32]; 	SQL_ReadResult(Query, 6, Tag, 31)

		copy(g_Tag[id],9,Tag)
	}
	
	return PLUGIN_HANDLED
}
public IgnoreHandle(FailState,Handle:Query,Error[],Errcode,Data[],DataSize)
{
    SQL_FreeHandle(Query)
    
    return PLUGIN_HANDLED
}

EncodedGaming:
	- Menus
*/
public cmdShowMenu(id) {
	if(get_pcvar_num(cStatus) && is_user_connected(id)) {
		ScreenFadeIn(id)
		MainMenu(id)
	}
	return PLUGIN_HANDLED;
}
public MainMenu(id) {
	new Temp[101]
	formatex(Temp,100, "\\y[\\r%s\\y] Main Menu\n\\wWebsite:\\r %s", TAG, Website)
	new menu = menu_create(Temp, "menuHandler");
	if(g_pstatus[id]==1 || get_user_flags(id) & ADMIN_RCON) menu_additem(menu, "\\rOwner\\w Menu", "1", 0);
	else menu_additem(menu, "\\dOwner\\w Menu", "1", 0);
	if(g_pstatus[id]==1 || g_pstatus[id]==2)  menu_additem(menu, "\\rAdmin\\w Menu", "2", 0);
	else menu_additem(menu, "\\dAdmin\\w Menu", "2", 0);	
	if(g_pstatus[id]==1 || g_pstatus[id]==2 || g_pstatus[id]==3)  menu_additem(menu, "\\rVip\\w Menu", "3", 0);
	else menu_additem(menu, "\\dVip\\w Menu", "3", 0);
	if(g_pstatus[id]==1 || g_pstatus[id]==2 || g_pstatus[id]==4)  menu_additem(menu, "\\rMember\\w Menu", "4", 0);
	else menu_additem(menu, "\\dMember\\w Menu", "4", 0);
	menu_display(id, menu, 0)
}
public menuHandler(id, menu, key) {
	if( key == MENU_EXIT ) {
		ScreenFadeOut(id)
		menu_destroy(menu)
		return PLUGIN_HANDLED
	}
	switch(key) {
		case 0: {
			if(g_pstatus[id]==1 || get_user_flags(id) & ADMIN_RCON) OwnerMenu(id)
			else cmdShowMenu(id)
		}
		case 1: {
			if(g_pstatus[id]==1 || g_pstatus[id]==2) AdminMenu(id)
			else cmdShowMenu(id)
		}
		case 2: {
			if(g_pstatus[id]==1 || g_pstatus[id]==2 || g_pstatus[id]==3) VipMenu(id)
			else cmdShowMenu(id)
		}
		case 3: {
			if(g_pstatus[id]==1 || g_pstatus[id]==2 || g_pstatus[id]==4) MemberMenu(id)
			else cmdShowMenu(id)
		}
	}
	menu_destroy(menu)
	return PLUGIN_HANDLED
}
public OwnerMenu(id) {
	new Temp[64]
	formatex(Temp,63, "\\y[\\r%s\\y] Admin Menu", TAG)
	new Ownermenu = menu_create(Temp, "OwnermenuHandler");
	if(g_HideRank[id]) formatex(Temp,63, "\\rHideRank\\y [True]")
	formatex(Temp,63, "\\rChange Tag\\y [%s]\n\\y[Ranks]", g_Tag[id])
	menu_additem(Ownermenu, Temp, "1", 0);
	menu_additem(Ownermenu, "\\rGive\\w Player\\r Rank", "2", 0);
	menu_additem(Ownermenu, "\\rRemove\\w Player\\r Rank\n\\y[Protection]", "3", 0);
	menu_additem(Ownermenu, "\\rGive\\w Player\\r Protection", "4", 0);
	menu_additem(Ownermenu, "\\rRemove\\w Player\\r Protection\n\\y[warning]", "5", 0);
	menu_additem(Ownermenu, "\\rGive\\r Warning", "6", 0);
	menu_additem(Ownermenu, "\\rRemove\\r Warning", "7", 0);
	menu_display(id, Ownermenu, 0)
}
public OwnermenuHandler(id, menu, key) {
	if( key == MENU_EXIT ) {
		MainMenu(id)
		menu_destroy(menu);
		return PLUGIN_HANDLED
	}
	switch(key) {
		case 0: { 
			client_cmd(id, "messagemode AH_Tag")
		}
		case 1: { 
			ShowReason=1
			PlayerList(id, 0)
		}
		case 2: { 
			ShowReason=2
			PlayerList(id, 0)
		}
		case 3: {
			ShowReason=0
			Style[id] = 7 	// Give Protection
			PlayerList(id, 1);
		}
		case 4: {
			ShowReason=0
			Style[id] = 8 	// Remove Protection
			PlayerList(id, 0);
		}
		case 5: {
			ShowReason=0
			Style[id] = 5 	// Give Warning
			PlayerList(id, 1);
		}
		case 6: {
			ShowReason=0
			Style[id] = 6 	// Remove Warning
			PlayerList(id, 0);
		}
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED
}
public RankList(id) {
	new Rankmenu, Temp[64]
	formatex(Temp,63, "\\y[\\r%s\\y] Choose a Rank:", TAG)
	Rankmenu = menu_create(Temp, "RankHandler");
	formatex(Temp,63, "\\r%s", Skill[1])
	menu_additem(Rankmenu, Temp, "1", 0);
	formatex(Temp,63, "\\r%s", Skill[2])
	menu_additem(Rankmenu, Temp, "2", 0);
	formatex(Temp,63, "\\r%s", Skill[3])
	menu_additem(Rankmenu, Temp, "3", 0);
	formatex(Temp,63, "\\r%s", Skill[4])
	menu_additem(Rankmenu, Temp, "4", 0);
	menu_display(id, Rankmenu);
	return PLUGIN_HANDLED;
}
/*
public makevip(id) {
	if(get_user_flags(id) & ADMIN) {
		new arg[32],arg2[10]
		read_argv(1,arg,31)
		read_argv(2,arg2,9)
		
		new num = str_to_num(arg2)
		if(num < 0 || num > 4) {
			ChatColor(id, "!g%s!y Take a number between!team 0 !y-!team 4!y.", TAG)
			console_print(id, "number between 0 and 4 please")
			return PLUGIN_HANDLED;
		}
		new data[85];
		formatex(data, 84, "\"%s\" \"0\" \"1\" \"%s\"",arg2, Skill[str_to_num(arg2)])
		ChatColor(0, "!g%s!team %s!y gives!team %s!y a new Rank. (!g%s!y)", TAG, szName2, szName, Skill[str_to_num(arg2)])
	
		new data[85];
		formatex(data, 84, "\"%s\" \"0\" \"1\" \"VIP\"",arg2)
		
		fvault_set_data(vaultname_vip, arg, data);
		console_print(id, "%s became a vip",arg)
	}
	else
	{
		ColorChat(id,RED,"\x01[\x04%s\x01] You don't have acces to this command", sTag)
	}
	return PLUGIN_HANDLED;
}*/

public RankHandler(id, menu, key) {
	if( key == MENU_EXIT ) {
		menu_destroy(menu);
		ScreenFadeOut(id)
		return PLUGIN_HANDLED;
	}
	new szName[32], szName2[32], steam_id[21];
	get_user_name(Name[id], szName, 31)
	get_user_name(id, szName2, 31)
	get_user_authid(Name[id], steam_id, 20)

	g_pstatus[Name[id]] = key+1
	g_HideRank[Name[id]] = 0
	g_ColorMode[Name[id]] = 0
	g_Warning[Name[id]] = 0
	g_Protected[Name[id]] = 0
	copy(g_Tag[id],9,Skill[key+1])
	if(is_user_connected(id) && is_user_connected(Name[id]))
		ChatColor(0, "!g[%s]!team %s!y gives!team %s!y a new Rank. !g[%s]!y", TAG, szName2, szName, Skill[key+1])
	
	Save_MySql(Name[id])
	
	menu_destroy(menu);
	ScreenFadeOut(id);
	return PLUGIN_HANDLED;
}
public GiveProtection(id) {
	new szName[32], szName2[32], steam_id[21];
	get_user_name(Name[id], szName, 31)
	get_user_name(id, szName2, 31)
	get_user_authid(Name[id], steam_id, 20)

	g_Protected[Name[id]] += 1
	
	if(is_user_connected(id) && is_user_connected(Name[id]))
		ChatColor(0, "!g[%s]!team %s!y gives!team %s!y protection. !g[%s]!y", TAG, szName2, szName, Skill[id])
	
	Save_MySql(Name[id])
	
	ScreenFadeOut(id);
	return PLUGIN_HANDLED;
}
public RemoveProtection(id) {
	new szName[32], szName2[32], steam_id[21];
	get_user_name(Name[id], szName, 31)
	get_user_name(id, szName2, 31)
	get_user_authid(Name[id], steam_id, 20)

	g_Protected[Name[id]] = 0
	
	if(is_user_connected(id) && is_user_connected(Name[id]))
		ChatColor(0, "!g[%s]!team %s!y removed!team %s!y's protection. !g[%s]!y", TAG, szName2, szName, Skill[id])
	
	Save_MySql(Name[id])

	ScreenFadeOut(id);
	return PLUGIN_HANDLED;
}
public GiveWarning(id) {
	new szName[32], szName2[32], steam_id[21];
	get_user_name(Name[id], szName, 31)
	get_user_name(id, szName2, 31)
	get_user_authid(Name[id], steam_id, 20)

	g_Warning[Name[id]] += 1
	
	if(is_user_connected(id) && is_user_connected(Name[id]))
		ChatColor(0, "!g[%s]!team %s!y gives!team %s!y a warning for!team %s!y. !g[%s]!y", TAG, szName2, szName, REDEN[Reason[id]], Skill[id])
	
	if(g_Warning[Name[id]] == get_pcvar_num(cwarning)) {
		ChatColor(0, "!g[%s]!team %s!y's admin is removed. !g[!ywarning:!team %i!y/!team%i!g]", TAG, szName, g_Warning[Name[id]], get_pcvar_num(cwarning))
		g_pstatus[Name[id]] = 0
		g_HideRank[Name[id]] = 0
		g_ColorMode[Name[id]] = 0
		g_Warning[Name[id]] = 0
		g_Protected[Name[id]] = 0
		copy(g_Tag[Name[id]],9,Skill[0])
	}
	Save_MySql(Name[id])
	
	ScreenFadeOut(id);
	return PLUGIN_HANDLED;
}
public RemoveWarning(id) {
	new szName[32], szName2[32], steam_id[21];
	get_user_name(Name[id], szName, 31)
	get_user_name(id, szName2, 31)
	get_user_authid(Name[id], steam_id, 20)

	if(!g_Warning[Name[id]])
		ChatColor(id, "!g[%s]!team %s!y doesn't have!team warning!y...", TAG, szName)
	
	else if(is_user_connected(id) && is_user_connected(Name[id])) {
		g_Warning[Name[id]] += 1
		ChatColor(0, "!g[%s]!team %s!y removed a warning of !team %s!y. !g[%s]!y", TAG, szName2, szName, Skill[id])
	}
	
	Save_MySql(Name[id])

	ScreenFadeOut(id);
	return PLUGIN_HANDLED;
}
public AdminMenu(id) {
	new Temp[64]
	formatex(Temp,63, "\\y[\\r%s\\y] Admin Menu", TAG)
	new Adminmenu = menu_create(Temp, "AdminmenuHandler");
	if(g_HideRank[id]) formatex(Temp,63, "\\rHideRank\\y [True]")
	else formatex(Temp,63, "\\rHideRank\\y [False]")
	menu_additem(Adminmenu, Temp, "1", 0);
	formatex(Temp,63, "\\rChange Tag\\y [%s]", g_Tag[id])
	menu_additem(Adminmenu, Temp, "2", 0);
	formatex(Temp,63, "\\rText Color\\y [%s]\n", Color[g_ColorMode[id]])
	menu_additem(Adminmenu, Temp, "3", 0);
	menu_additem(Adminmenu, "\\rSlap\\w Player", "4", 0);
	menu_additem(Adminmenu, "\\rSlay\\w Player", "5", 0);
	menu_additem(Adminmenu, "\\rKick\\w Player", "6", 0);
	menu_additem(Adminmenu, "\\rBan\\w Player", "7", 0);
	menu_additem(Adminmenu, "\\rTransfer\\w Player", "8", 0);
	menu_additem(Adminmenu, "\\rMap\\w Change", "9", 0);
	menu_additem(Adminmenu, "\\rRevive\\w Player", "10", 0);
	menu_additem(Adminmenu, "\\wGive\\r Noclip", "11", 0);
	menu_additem(Adminmenu, "\\wGive\\r Glow", "12", 0);
	menu_additem(Adminmenu, "\\wGive\\r Drug", "13", 0);
	menu_additem(Adminmenu, "\\wGive\\r Godmode", "14", 0);
	menu_additem(Adminmenu, "\\wGive/Remove\\r Voice Mute", "15", 0);
	menu_display(id, Adminmenu, 0)
}
public AdminmenuHandler(id, menu, key) {
	if( key == MENU_EXIT ) {
		MainMenu(id)
		menu_destroy(menu);
		return PLUGIN_HANDLED
	}

	switch(key) {
		case 0: { 
			HideRank(id)
		}
		case 1: { 
			client_cmd(id, "messagemode AH_Tag")
		}
		case 2: {
			if(g_ColorMode[id] == TotalColors-1)
				g_ColorMode[id]=0
			else
				g_ColorMode[id]++
			AdminMenu(id)
		}
		case 3: { 
			Style[id] = 0 // Slap
			PlayerList(id, 0)
		}
		case 4:  {
			Style[id] = 1 // Slay
			PlayerList(id, 0)
		}
		case 5: {
			Style[id] = 2 // Kick
			PlayerList(id, 0)
		}
		case 6: {
			Style[id] = 3 // Ban
			PlayerList(id, 0)
		}
		case 7: {
			showtransfermenu(id)
		}
		case 8: { 
			client_cmd(id, "messagemode AH_Map")
		}
		case 9: {
			ShowReason=4
			PlayerList(id, 0)
		}
		case 10: {
			Style[id] = 6 // Give Noclip
			ShowReason=3
			PlayerList(id, 0)
		}
		case 11: {
			Style[id] = 7 // Give Glow
			ShowReason=3
			PlayerList(id, 0)
		}
		case 12: {
			Style[id] = 8 // Give Drug
			ShowReason=3
			PlayerList(id, 0)
		}
		case 13: {
			PlayerList2(id)
		}
		case 14: {
			Style[id] = 9 // Give / Remove Mute
			ShowReason=3
			PlayerList(id, 0)
		}
	}
	menu_destroy(menu);
	ScreenFadeOut(id)
	return PLUGIN_HANDLED;
}
public VipMenu(id) {
	new Temp[64]
	formatex(Temp,63, "\\y[\\r%s\\y] Vip Menu\n\\w[\\r%i\\y/\\w%i]", TAG, g_Warning[id], get_pcvar_num(cwarning))
	new Vipmenu = menu_create(Temp, "VipmenuHandler");
	if(g_HideRank[id]) formatex(Temp,63, "\\rHideRank\\y [True]")
	else formatex(Temp,63, "\\rHideRank\\y [False]")
	menu_additem(Vipmenu, Temp, "1", 0);
	formatex(Temp,63, "\\rText Color\\y [%s]\n", Color[g_ColorMode[id]])
	menu_additem(Vipmenu, Temp, "2", 0);
	menu_additem(Vipmenu, "\\rSlap\\w Player", "3", 0);
	menu_additem(Vipmenu, "\\rSlay\\w Player", "4", 0);
	menu_additem(Vipmenu, "\\rKick\\w Player", "5", 0);
	menu_additem(Vipmenu, "\\rTransfer\\w Player", "6", 0);
	menu_additem(Vipmenu, "\\wGive/Remove\\r Voice Mute", "7", 0);
	menu_display(id, Vipmenu, 0);
}
public VipmenuHandler(id, menu, key) {
	if( key == MENU_EXIT ) {
		MainMenu(id)
		menu_destroy(menu);
		return PLUGIN_HANDLED
	}

	switch(key) {
		case 0: { 
			HideRank(id)
		}
		case 1: {
			if(g_ColorMode[id] == TotalColors-1)
				g_ColorMode[id]=0
			else
				g_ColorMode[id]++
			VipMenu(id)
		}
		case 2: { 
			Style[id] = 0 // Slap
			PlayerList(id, 0)
		}
		case 3:  {
			Style[id] = 1 // Slay
			PlayerList(id, 0)
		}
		case 4: {
			Style[id] = 2 // Kick
			PlayerList(id, 0)
		}
		case 5: {
			showtransfermenu(id)
		}
		case 6: {
			Style[id] = 9 // Give / Remove Mute
			ShowReason=3
			PlayerList(id, 0)
		}
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}
public MemberMenu(id) {
	new Temp[64]
	formatex(Temp,63, "\\y[\\r%s\\y] Member Menu", TAG)
	new Membermenu = menu_create(Temp, "MembermenuHandler");
	if(g_HideRank[id]) formatex(Temp,63, "\\rHideRank\\y [True]")
	else formatex(Temp,63, "\\rHideRank\\y [False]")
	menu_additem(Membermenu, Temp, "1", 0);
	formatex(Temp,63, "\\rChange Tag\\y [%s]", g_Tag[id])
	menu_additem(Membermenu, Temp, "2", 0);
	formatex(Temp,63, "\\rText Color\\y [%s]\n", Color[g_ColorMode[id]])
	menu_additem(Membermenu, Temp, "3", 0);
	menu_additem(Membermenu, "\\rSlap\\w Player", "3", 0);
	menu_additem(Membermenu, "\\rSlay\\w Player", "4", 0);
	menu_additem(Membermenu, "\\rKick\\w Player", "5", 0);
	menu_additem(Membermenu, "\\rBan\\w Player", "6", 0);
	menu_additem(Membermenu, "\\rTransfer\\w Player", "7", 0);
	menu_display(id, Membermenu, 0)
}
public MembermenuHandler(id, menu, key) {
	if( key == MENU_EXIT ) {
		MainMenu(id)
		menu_destroy(menu);
		return PLUGIN_HANDLED
	}

	switch(key) {
		case 0: { 
			HideRank(id)
		}
		case 1: { 
			client_cmd(id, "messagemode AH_Tag")
		}
		case 2: {
			if(g_ColorMode[id] == TotalColors-1)
				g_ColorMode[id]=0
			else
				g_ColorMode[id]++
			MemberMenu(id)
		}
		case 3: { 
			Style[id] = 0 // Slap
			PlayerList(id, 0)
		}
		case 4:  {
			Style[id] = 1 // Slay
			PlayerList(id, 0)
		}
		case 5: {
			Style[id] = 2 // Kick
			PlayerList(id, 0)
		}
		case 6: {
			Style[id] = 3 // Ban
			PlayerList(id, 0)
		}
		case 7: {
			showtransfermenu(id)
		}
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}
/*
EncodedGaming:
	- Players & Reasons (Menu)
*/
public PlayerList(id, num) {
	new Playermenu, Temp[64]
	formatex(Temp,63, "\\y[\\r%s\\y] Choose a player:", TAG)
	Playermenu = menu_create(Temp, "PlayerHandler");
	
	new players[32], pnum, tempid;
	new szName[32], szTempid[10];
	get_players(players, pnum, "ch");
	for( new i; i<pnum; i++ ) {
		tempid = players[i];
		if(num == 1)
			if(!g_pstatus[tempid])
				continue;
		//if (get_user_flags(players[i]) & ADMIN_IMMUNITY)
		//	continue;
			
		
		get_user_name(tempid, szName, 31);
		num_to_str(tempid, szTempid, 9);
		menu_additem(Playermenu, szName, szTempid, 0);
	}
	menu_display(id, Playermenu);
	return PLUGIN_HANDLED;
}
public ReasonList(id) {
	new Reasonmenu, Temp[64]
	formatex(Temp,63, "\\y[\\r%s\\y] Choose a reason:", TAG)
	Reasonmenu = menu_create(Temp, "ReasonHandler");
	new key[6]
	for(new i; i < TotalReasons; i++) {
		num_to_str(i,key,sizeof(key)-1)
		menu_additem(Reasonmenu, REDEN[i], key, 0);
	}
	menu_display(id, Reasonmenu);
	return PLUGIN_HANDLED;
}
public ReasonHandler(id, menu, item) {
	if( item == MENU_EXIT ) {
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	new data[6], iName[64];
	new access, callback;
	menu_item_getinfo(menu, item, access, data,5, iName, 63, callback);
	
	Reason[id] = str_to_num(data);
	
	switch(Style[id]) {
		case 0: SlapPlayer(id) 		// Slap
		case 1: SlayPlayer(id) 		// Slay
		case 2: KickPlayer(id) 		// Kick
		case 3: BanPlayer(id)  		// Ban
		case 4: showvotemenu(id)	// Vote stuff
		case 5: GiveWarning(id)		// Give Warning
		case 6: RemoveWarning(id)	// Remove Warning
		case 7: GiveProtection(id)	// Give Warning
		case 8: RemoveProtection(id)	// Remove Warning
		case 9: MuteVoice(id)		// Mute Voice
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}
public PlayerHandler(id, menu, item) {
	if( item == MENU_EXIT ) {
		menu_destroy(menu);
		ScreenFadeOut(id)
		return PLUGIN_HANDLED;
	}
	new data[6], iName[64];
	new access, callback;
	menu_item_getinfo(menu, item, access, data,5, iName, 63, callback);
	
	Name[id] = str_to_num(data);
	if(!ShowReason) ReasonList(id)
	else if(ShowReason==1) RankList(id)
	else if(ShowReason==2) RemoveRank(id)
	else if(ShowReason==3) {
		switch(Style[id]) {
			case 6: GiveNoclip(id) 		// Noclip
			case 7: GiveGlow(id) 		// Glow
			case 8: GiveDrug(id) 		// Drug
		}
	}
	else if(ShowReason==4) RevivePlayer(id)
	ShowReason=0
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}
/* GODMODE PLAYER LIST */
public PlayerList2(id) {
	new Playermenu2, Temp[64]
	formatex(Temp,63, "\\y[\\r%s\\y] Choose a player:", TAG)
	Playermenu2 = menu_create(Temp, "PlayerHandler2");
	
	new players[32], pnum, tempid;
	new szName[32], szTempid[10];
	get_players(players, pnum, "ch");
	for( new i; i<pnum; i++ ) {
		if(id == tempid  && !is_user_bot(id) && is_user_connected(id)) {
			new temp[100]
			num_to_str(tempid, szTempid, 9);
			if(get_user_godmode(id))
				formatex(temp, sizeof(temp)-1, "\\r%s \\y[Remove] \\d[Me]", Name)
			else if(!get_user_godmode(id))
				formatex(temp, sizeof(temp)-1, "\\r%s \\y[Give] \\d[Me]", Name)
			menu_additem(Playermenu2, temp, szTempid, 0);
		}
		else if(get_user_godmode(id) && !is_user_bot(id) && is_user_connected(id)) {
			new temp[100]
			num_to_str(tempid, szTempid, 9);
			formatex(temp, sizeof(temp)-1, "\\y%s\\y [Remove]", Name)
			menu_additem(Playermenu2, temp, szTempid, 0);
		}
		else if(!get_user_godmode(id) && !is_user_bot(id) && is_user_connected(id)) {
			new temp[100]
			num_to_str(tempid, szTempid, 9);
			formatex(temp, sizeof(temp)-1, "\\y%s\\y [Give]", Name)
			menu_additem(Playermenu2, temp, szTempid, 0);
		}
		tempid = players[i];
		get_user_name(tempid, szName, 31);
		num_to_str(tempid, szTempid, 9);
		menu_additem(Playermenu2, szName, szTempid, 0);
	}
	menu_display(id, Playermenu2);
	return PLUGIN_HANDLED;
}
public PlayerHandler2(id, menu, item) {
	if( item == MENU_EXIT ) {
		menu_destroy(menu);
		ScreenFadeOut(id)
		return PLUGIN_HANDLED;
	}
	new data[6], iName[64];
	new access, callback;
	menu_item_getinfo(menu, item, access, data,5, iName, 63, callback);
	
	Name[id] = str_to_num(data);
	GiveGodmode(id)
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}
/*
EncodedGaming:
	- Remove Rank
*/
public RemoveRank(id) {
	new szName[32]; get_user_name(id, szName, 31)
	new szName2[32]; get_user_name(Name[id], szName2, 31)
	ChatColor(0, "!g[%s]!team %s!y removed!team %s!y's Rank.", TAG, szName, szName2)
	
	g_pstatus[Name[id]] = 0
	g_HideRank[Name[id]] = 0
	g_ColorMode[Name[id]] = 0
	g_Warning[Name[id]] = 0
	g_Protected[Name[id]] = 0
	
	copy(g_Tag[Name[id]],9,Skill[0])
	
	Save_MySql(Name[id])
	ScreenFadeOut(id)
}
/*
EncodedGaming:
	- Tag
	- Map
*/
public AHTag(id) {
	if(g_pstatus[id] > 0) {
		new tag[10]; read_argv(1,tag,9)
		
		copy(g_Tag[id],9,tag)
	
		ChatColor(id, "!g[%s]!y Your tag is changed.", TAG)
		new steam_id[20]; get_user_authid(id, steam_id, 20)

		Save_MySql(id)
	}
	else {
		ChatColor(id, "!g[%s]!y You don't have acces to this command.", TAG)
	}
	ScreenFadeOut(id)
	return PLUGIN_HANDLED;
}
public AHMap(id) {
	if(g_pstatus[id] == 1 || g_pstatus[id] == 2) {
		new mapname[50]
		read_argv(1,mapname,49)
		strtolower(mapname);
		copy(Mappy[id],49,mapname)
		if(is_map_valid(Mappy[id])) {
			new szName[32]; get_user_name(id, szName, 32);
			ChatColor(id, "!g[%s]!team %s!y changed map to!team %s!y. !g[%s]", TAG, szName, Mappy[id], Skill[g_pstatus[id]]);
			new data[85]; formatex(data, 84, "changelevel %s", Mappy[id])
			server_cmd(data)
		} 
		else 
			ChatColor(id, "!g[%s]!team %s!y is not on the server.", TAG)
	}
	else {
		ChatColor(id, "!g[%s]!y You don't have acces to this command.", TAG)
	}
	ScreenFadeOut(id)
	return PLUGIN_HANDLED;
}
/*
EncodedGaming:
	- Functions
*/
public SlapPlayer(id) {
	new name[32], name2[32]
	get_user_name(id, name, 31)
	get_user_name(Name[id], name2, 31)
	if(is_user_alive(Name[id])) {
		user_slap(Name[id], 0)
		user_slap(Name[id], 0)
		if(id == Name[id]) {
			ChatColor(0, "!g[%s]!team %s !ygives himself a hard slap. !g[%s]", TAG, name, Skill[g_pstatus[id]])
			ScreenFadeOut(id)
			return PLUGIN_HANDLED
		}
		else if(g_Protected[Name[id]])
			ChatColor(0, "!g[%s] !team%s!y is protected!", TAG, name2);
		else 
			ChatColor(0, "!g[%s] !team%s!y slapped !team%s!y for !team'%s'!g [%s]", TAG, name, name2, REDEN[Reason[id]], Skill[g_pstatus[id]])
	}
	else ChatColor(id, "!g[%s]!team %s !yis dead?", TAG, name2)
	ScreenFadeOut(id)
	return PLUGIN_HANDLED;
}
public SlayPlayer(id) {
	new name[32], name2[32]
	get_user_name(id, name, 31)
	get_user_name(Name[id], name2, 31)
	if(is_user_alive(Name[id])) {
		if(id == Name[id]) {
			user_silentkill(id)
			make_deathmsg(id, Name[id], 1, "deagle")
			ChatColor(0, "!g[%s] !team%s!y takes a revolver, points at hes head and fires. !g[%s]", TAG, name, Skill[g_pstatus[id]])
			ScreenFadeOut(id)
			return PLUGIN_HANDLED;
		}
		else if(g_Protected[Name[id]])
			ChatColor(0, "!g[%s] !team%s!y is protected!", TAG, name2);
		else {
			user_silentkill(Name[id])
			make_deathmsg(id, Name[id], 0, "worldspawn")
			ChatColor(0, "!g[%s] !team%s!y slayed !team%s!y for !team'%s'!g [%s]", TAG, name, name2, REDEN[Reason[id]], Skill[g_pstatus[id]])
		}
	}
	else ChatColor(id, "!g[%s]!team %s !yis dead?", TAG, name2)
	ScreenFadeOut(id)
	return PLUGIN_HANDLED;
}
public KickPlayer(id) {
	new name[32], name2[32]
	get_user_name(id, name, 31)
	get_user_name(Name[id], name2, 31)
	if(id == Name[id]) {
		server_cmd("kick \"%s\"",name)
		ChatColor(0, "!g[%s] !team%s !ygot tired of the game and kicked himself. !g[%s]", TAG, name, Skill[g_pstatus[id]])
		ScreenFadeOut(id)
		return PLUGIN_HANDLED;
	}
	else if(g_Protected[Name[id]])
			ChatColor(0, "!g[%s] !team%s!y is protected!", TAG, name2);
	else {
		server_cmd("kick \"%s\"",name2)
		ChatColor(0, "!g[%s] !team%s!y kicked !team%s!y for !team'%s'!g [%s]", TAG, name, name2, REDEN[Reason[id]], Skill[g_pstatus[id]])
	}
	ScreenFadeOut(id)
	return PLUGIN_HANDLED;
}
public BanPlayer(id) {
	new name[32], name2[32]
	get_user_name(id, name, 31)
	get_user_name(Name[id], name2, 31)
	new szAuthID[32]; get_user_authid(Name[id], szAuthID, 31);
	if(g_Protected[Name[id]])
		ChatColor(0, "!g[%s] !team%s!y is protected!", TAG, name2);
	else {
		server_cmd ("amx_ban \"%s\" %d \"%s\"", szAuthID, get_pcvar_num (cBanTime), REDEN[Reason[id]])
		
		//server_cmd("banid %i #%i Banned;writeid",get_pcvar_num(cBanTime),get_user_userid(Name[id]))
		//server_cmd("kick #%s \"%s banned u for %s\"", Name[id], name, REDEN[Reason[id]])
		ChatColor(0, "!g[%s] !team%s!y banned !team%s!y for !team'%s'!g [%s]", TAG, name, name2, REDEN[Reason[id]], Skill[g_pstatus[id]])
	}
	ScreenFadeOut(id)
}
public HideRank(id) {
	if(is_user_connected(id)) {
		if(g_HideRank[id]) {
			g_HideRank[id]=0
			ChatColor(id, "!g[%s]!y Your Rank is not hidded anymore.", TAG)
		}
		else {
			g_HideRank[id]++
			ChatColor(id, "!g[%s]!y Your Rank is hidden now", TAG)
		}
		//g_HideRank[Name[id]] = 1
		Save_MySql(id)
	}
	ScreenFadeOut(id)
	return PLUGIN_HANDLED;
}
public MuteVoice(id) {
	if(!is_user_connected(Name[id]))
		return PLUGIN_HANDLED;
	
	if(IsMuted[id]) {
		IsMuted[id]++;
		set_speak( id, SPEAK_MUTED );
		
		new name[32]; get_user_name(id, name, 31)
		new name2[32]; get_user_name(Name[id], name2, 31)
		if(g_Protected[Name[id]])
			ChatColor(0, "!g[%s] !team%s!y is protected!", TAG, name2);
		else
			ChatColor(0,"!g[%s] !team%s!y muted !team%s!y's voice for !g1!ymap!g [%s]", TAG, name, name2, REDEN[Reason[id]], Skill[g_pstatus[id]])
	} else {
		IsMuted[id]=0
		set_speak( id, SPEAK_NORMAL );
	
		new name[32]; get_user_name(id, name, 31)
		new name2[32]; get_user_name(Name[id], name2, 31)
		if(g_Protected[Name[id]])
			ChatColor(0, "!g[%s] !team%s!y is protected!", TAG, name2);
		else
			ChatColor(0,"!g[%s] !team%s!y unmuted !team%s!y's voice. [%s]", TAG, name, name2, Skill[g_pstatus[id]])
	}
	ScreenFadeOut(id)
	return PLUGIN_HANDLED;
}
public GiveDrug(id) {
	if(!is_user_alive(Name[id]))
		return PLUGIN_HANDLED;
	
	message_begin(MSG_ONE, get_user_msgid("SetFOV"), {0,0,0}, Name[id])
	write_byte(170)
	message_end()
	
	new name[32]; get_user_name(id, name, 31)
	new name2[32]; get_user_name(Name[id], name2, 31)
	if(id == Name[id]) {
		ChatColor(0, "!g[%s] !team%s !ygives himself !team'Drugs'!y. !g[%s]", TAG, name, Skill[g_pstatus[id]])
		ScreenFadeOut(id)
		set_task(10.0, "DrugStop", Name[id]);
		return PLUGIN_HANDLED;
	}
	else if(g_Protected[Name[id]])
		ChatColor(0, "!g[%s] !team%s!y is protected!", TAG, name2);
	else
		ChatColor(0,"!g[%s] !team%s!y gives !team'Drugs'!y to !team%s!y for !g10!ysec!g [%s]", TAG, name, name2, Skill[g_pstatus[id]])
	set_task(10.0, "DrugStop", Name[id]);
	ScreenFadeOut(id)
	return PLUGIN_HANDLED;
}
public DrugStop(id) {
	if(is_user_alive(id)) {
		message_begin(MSG_ONE, get_user_msgid("SetFOV"), {0,0,0}, id)
		write_byte(90)
		message_end()
	}
}
public GiveGlow(id) {
	if(!is_user_alive(Name[id]))
		return PLUGIN_HANDLED;
	set_user_rendering(Name[id], kRenderFxGlowShell, random_num(0,255), random_num(0,255), random_num(0,255), kRenderNormal, 0);
	new name[32]; get_user_name(id, name, 31)
	new name2[32]; get_user_name(Name[id], name2, 31)
	if(id == Name[id]) {
		ChatColor(0, "!g[%s]!team %s !ygives himself a !team'Random Glow'!y. !g[%s]", TAG, name, Skill[g_pstatus[id]])
		ScreenFadeOut(id)
		return PLUGIN_HANDLED;
	}
	else if(g_Protected[Name[id]])
		ChatColor(0, "!g[%s] !team%s!y is protected!", TAG, name2);
	else 
		ChatColor(0,"!g[%s] !team%s!y gives a !team'Random Glow'!y to !team%s!y.!g [%s]", TAG, name, name2, Skill[g_pstatus[id]])
	ScreenFadeOut(id)
	return PLUGIN_HANDLED;
}
public GiveNoclip(id) {
	if(!is_user_alive(Name[id]))
		return PLUGIN_HANDLED;
	
	set_user_noclip(Name[id], 1)
	new name[32]; get_user_name(id, name, 31)
	new name2[32]; get_user_name(Name[id], name2, 31)
	ChatColor(0,"!g[%s] !team%s!y gives !team'Noclip'!y to !team%s!y for !g10!ysec!g [%s]", TAG, name, name2, Skill[g_pstatus[id]])
	ScreenFadeOut(id)
	set_task(10.0, "ResetNoclip", Name[id])
	return PLUGIN_HANDLED;
}	
public ResetNoclip(id) {
	if(is_user_alive(id)) {
		new name[32]
		get_user_name(id, name, 31)
		set_user_noclip(id, 0)
		ChatColor(0,"!g[%s] !team%s!y's NoClip is removed.", TAG, name)
	}
}
public RevivePlayer(id) {
	ExecuteHamB( Ham_CS_RoundRespawn, Name[id] );	
	new name[32]; get_user_name(id, name, 31)
	new name2[32]; get_user_name(Name[id], name2, 31)
	if(id == Name[id])
		ChatColor(0, "!g[%s]!team %s!y revived himself. !g[%s]", TAG, name, Skill[g_pstatus[id]])
	else
		ChatColor(0,"!g[%s] !team%s!y revived !team%s!g [%s]", TAG, name, name2, Skill[g_pstatus[id]])
	
	ScreenFadeOut(id)
}
public GiveGodmode(id) {
	if(!is_user_alive(Name[id]))
		return PLUGIN_HANDLED;
	
	new name[32]; get_user_name(id, name, 31)
	new name2[32]; get_user_name(Name[id], name2, 31)
	if(id == Name[id] && !get_user_godmode(Name[id])) {
		set_user_godmode(Name[id], 1)
		ChatColor(0, "!g[%s]!team %s!y gives himself godmode. !g[%s]", TAG, name, Skill[g_pstatus[id]])
	}
	else if(g_Protected[Name[id]])
		ChatColor(0, "!g[%s] !team%s!y is protected!", TAG, name2);
	else if(id == Name[id] && get_user_godmode(Name[id])) {
		set_user_godmode(Name[id], 0)
		ChatColor(0, "!g[%s]!team %s!y removes his godmode. !g[%s]", TAG, name, Skill[g_pstatus[id]])
	}
	else if(!get_user_godmode(Name[id])) {
		set_user_godmode(Name[id], 1)
		ChatColor(0,"!g[%s] !team%s!y gives!team %s !ygodmode. !g[%s]", TAG, name, name2, Skill[g_pstatus[id]])
	}
	else if(get_user_godmode(Name[id])) {
		set_user_godmode(Name[id], 0)
		ChatColor(0,"!g[%s] !team%s!y removes!team %s!y's godmode. !g[%s]", TAG, name, name2, Skill[g_pstatus[id]])
	}
	ScreenFadeOut(id)
	return PLUGIN_HANDLED;
}
/*
EncodedGaming:
	- Screen Fade: In & Out
*/
ScreenFadeIn(id) {
	message_begin(MSG_ONE, g_msgFade, {0,0,0}, id); 	// use the magic #1 for "one client" 
	write_short( ~0 ); 	// fade lasts this long duration 
	write_short( ~0 ); 	// fade lasts this long hold time 
	write_short( 1<<12 ); 	// fade type 
	write_byte( 0 ); 	// fade red 
	write_byte( 0 ); 	// fade green 
	write_byte( 0 ); 	// fade blue  
	write_byte( 0 ); 	// fade alpha  
	message_end( );
	return PLUGIN_CONTINUE;
}
ScreenFadeOut(id) {
	message_begin(MSG_ONE, g_msgFade, {0,0,0}, id); 	// use the magic #1 for "one client"  
	write_short( 1<<12 ); 	// fade lasts this long duration  
	write_short( 1<<8 ); 	// fade lasts this long hold time  
	write_short( 1<<1 ); 	// fade type
	write_byte( 0 ); 	// fade red  
	write_byte( 0 ); 	// fade green  
	write_byte( 0 ); 	// fade blue
	write_byte( 0 ); 	// fade alpha  
	message_end( );
	return PLUGIN_CONTINUE;
}
/*
EncodedGaming:
	- Load & Save Data

public SaveData( const id )  {     
	new szAuthID[ 35 ];
	new vaultkey[ 35 ], vaultdata[ 21 ]; 
    
	get_user_authid( id, szAuthID, 34 );
	
	format( vaultkey, 34, "%s", szAuthID );
	format( vaultdata, 20," %i %i %i %s ", g_pstatus[id], g_HideRank[id], g_ColorMode[id], g_Tag[id]); 

	nvault_set( g_VipDatabase, vaultkey, vaultdata ); 
}  

public LoadData( const id )  { 
	new szAuthID[ 35 ]; 
	new vaultkey[ 35 ], vaultdata[ 21 ];
	
	new type[10],arg[32],arg2[32],arg3[10]
    
	get_user_authid( id, szAuthID, 34 ); 
    
	format( vaultkey, 34, "%s", szAuthID );
	format( vaultdata, 20," %i %i %i %s ", g_pstatus[id], g_HideRank[id], g_ColorMode[id], g_Tag[id]); 

	nvault_get( g_VipDatabase, vaultkey, vaultdata, 255 ); 
	
	parse( vaultdata, type, 9, arg, 31, arg2, 31, arg3, 9 ); 
    
	g_pstatus[id] = str_to_num( type ); 
	g_HideRank[id] = str_to_num( arg ); 
    
	g_ColorMode[id] = str_to_num( arg2 );
	g_Tag[id] = arg3
}
public SaveData(id) { 
	new szAuthId[64], data[129];
	get_user_authid(id, szAuthId, 63);
	
	new key[501], stats[701];
	formatex(key, 500, "%s-Data", szAuthId);
	format(stats,700,"%i %i %i %s", g_pstatus[id], g_HideRank[id], g_ColorMode[id], g_Tag[id]) 
	nvault_set(g_VipDatabase, key, stats);
	nvault_set(g_VipDatabase, szAuthId, data);
	return PLUGIN_CONTINUE 
}  
public LoadData(id) { 
	new szAuthId[64], data[129];
	get_user_authid(id, szAuthId, 63);
	
	new key[501], stats[34];
	formatex(key, 500, "%s-Data", szAuthId);
	
	nvault_get(g_VipDatabase, key, stats, 33);
	
	new A[3][32], Tag[10]; parse(stats, A[0], 31, A[1], 31, A[2], 31, Tag, 9) 
	g_pstatus[id] = str_to_num(A[0])
	g_HideRank[id] = str_to_num(A[1])
	g_ColorMode[id] = str_to_num(A[2])
	g_Tag[id] = Tag																											
	nvault_get(g_VipDatabase, szAuthId, data, 128);
	return PLUGIN_CONTINUE;
} 

EncodedGaming:
	- ChatColor
*/
stock ChatColor(const id, const input[], any:...) {
	new count = 1, players[32]
	static msg[191]
	vformat(msg, 190, input, 3)
    
	replace_all(msg, 190, "!g", "\4") // Green Color
	replace_all(msg, 190, "!y", "\1") // Default Color
	replace_all(msg, 190, "!team", "\3") // Team Color
    
	if (id) players[0] = id; else get_players(players, count, "ch") 
	{
		for (new i = 0; i < count; i++) {
			message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("SayText"), _, players[i])
			write_byte(players[i]);
			write_string(msg);
			message_end();
		}
	}
}
/*
EncodedGaming:
	- Color Say
*/
public avoid_duplicated (msgId, msgDest, receiver)
{
	return PLUGIN_HANDLED
}
public hook_say(id)
{
	read_args (message, 191)
	remove_quotes (message)
	
	if (message[0] == '@' || message[0] == '/' || message[0] == '!' || equal (message, "")) // Ignores Admin Hud Messages, Admin Slash commands, 
		// Gungame commands and empty messages
	return PLUGIN_CONTINUE
	
	new playerTeam = get_user_team(id)
	
	new name[32]
	get_user_name (id, name, 31)
	
	new bool:admin = false
	
	if(g_pstatus[id] && !g_HideRank[id])
		admin = true
	
	
	new isAlive
	
	if (is_user_alive (id))
	{
		isAlive = 1
		alive = "\x01"
	}
	else
	{
		isAlive = 0
		alive = "\x01*DEAD* "
	}
	
	static color[10]
	
	
	
	if (admin)
	{
		get_user_team (id, color, 9)
		format (strName, 191, "%s\x04[%s]\x03 %s", alive, g_Tag[id], name)
		
		
		// Message
		switch (g_ColorMode[id])
		{
			case 0:	// Yellow
				format (strText, 191, "%s", message)
			
			case 1:	// Green
				format (strText, 191, "\x04%s", message)
			
			case 2:
			{
				switch (playerTeam) // Team names which appear on team-only messages
				{
					case 1: copy (color, 9, "TERRORIST")
					case 2: copy (color, 9, "CT")
					default: copy (color, 9, "SPECTATOR")
				}
				format (strText, 191, "\x03%s", message)
			}
		}
	}
	
	else 	// Player is not admin. Team-color name : Yellow message
	{
		get_user_team (id, color, 9)
		
		format (strName, 191, "%s\x03%s", alive, name)
		
		format (strText, 191, "%s", message)
	}
	
	format (message, 191, "%s\x01 :  %s", strName, strText)
	
	sendMessage (color, isAlive)	// Sends the colored message
	
	return PLUGIN_CONTINUE
}


public hook_teamsay(id)
{
	new playerTeam = get_user_team(id)
	new playerTeamName[19]
	
	switch (playerTeam) // Team names which appear on team-only messages
	{
		case 1:
			copy (playerTeamName, 11, "Terrorists")
		
		case 2:
			copy (playerTeamName, 18, "Counter-Terrorists")
		
		default:
			copy (playerTeamName, 9, "Spectator")
	}
	
	read_args (message, 191)
	remove_quotes (message)
	
	if (message[0] == '@' || message[0] == '/' || message[0] == '!' || equal (message, "")) // Ignores Admin Hud Messages, Admin Slash commands, 
		// Gungame commands and empty messages
	return PLUGIN_CONTINUE
	
	
	new name[32]
	get_user_name (id, name, 31)
	
	new bool:admin = false
	
	if(g_pstatus[id] && !g_HideRank[id])
		admin = true
	
	
	new isAlive
	
	if (is_user_alive (id))
	{
		isAlive = 1
		alive = "\x01"
	}
	else
	{
		isAlive = 0
		alive = "\x01*DEAD* "
	}
	
	static color[10]
	
	
	
	if (admin)
	{
		get_user_team (id, color, 9)
		format (strName, 191, "%s(%s)\x04[%s] \x03%s", alive, playerTeamName, g_Tag[id], name)
		
		// Message
		switch (g_ColorMode[id]) {
			case 0:	// Yellow
				format (strText, 191, "%s", message)
			
			case 1:	// Green
				format (strText, 191, "\x04%s", message)
			
			case 2:
			{
				switch (playerTeam) // Team names which appear on team-only messages
				{
					case 1: copy (color, 9, "TERRORIST")
					case 2: copy (color, 9, "CT")
					default: copy (color, 9, "SPECTATOR")
				}
				format (strText, 191, "\x03%s", message)
			}
		}
	}
	
	else 	// Player is not admin. Team-color name : Yellow message
	{
		get_user_team (id, color, 9)
		
		format (strName, 191, "%s(%s) \x03%s", alive, playerTeamName, name)
		
		format (strText, 191, "%s", message)
	}
	
	format (message, 191, "%s \x01:  %s", strName, strText)
	
	sendTeamMessage (color, isAlive, playerTeam)	// Sends the colored message
	
	return PLUGIN_CONTINUE	
}
public sendMessage (color[], alive)
{
	new teamName[10]
	
	for (new player = 1; player < maxPlayers; player++)
	{
		if (!is_user_connected(player))
			continue
		
		get_user_team (player, teamName, 9)	// Stores user's team name to change back after sending the message
			
		changeTeamInfo (player, color)		// Changes user's team according to color choosen
			
		writeMessage (player, message)		// Writes the message on player's chat
			
		changeTeamInfo (player, teamName)	// Changes user's team back to original
	}
}


public sendTeamMessage (color[], alive, playerTeam) {
	new teamName[10]
	
	for (new player = 1; player < maxPlayers; player++) {
		if (!is_user_connected(player))
			continue
		
		if (get_user_team(player) == playerTeam)
		{
			get_user_team (player, teamName, 9)	// Stores user's team name to change back after sending the message
				
			changeTeamInfo (player, color)		// Changes user's team according to color choosen
				
			writeMessage (player, message)		// Writes the message on player's chat
				
			changeTeamInfo (player, teamName)	// Changes user's team back to original
		}
	}
}
public changeTeamInfo (player, team[]) {
	message_begin (MSG_ONE, teamInfo, _, player)	// Tells to to modify teamInfo (Which is responsable for which time player is)
	write_byte (player)				// Write byte needed
	write_string (team)				// Changes player's team
	message_end()					// Also Needed
}
public writeMessage (player, message[]) {
	message_begin (MSG_ONE, sayText, {0, 0, 0}, player)	// Tells to modify sayText (Which is responsable for writing colored messages)
	write_byte (player)					// Write byte needed
	write_string (message)					// Effectively write the message, finally, afterall
	message_end ()						// Needed as always
}
/*
EncodedGaming:
	- Transfer Player
*/
public TransferMenu(id, menu, item) {
	if( item == MENU_EXIT ) {
		menu_destroy(menu);
		MainMenu(id)
		return PLUGIN_HANDLED;
	}
	
	new data[6], iName[64];
	new access, callback;
	menu_item_getinfo(menu, item, access, data,5, iName, 63, callback);
	
	new player = str_to_num(data)
	
	if(!player) {
		switch(tTransfer[id])	{
			case 2: tTransfer[id]=0
			default: tTransfer[id]++
		}
		showtransfermenu(id)
		return PLUGIN_CONTINUE;
	}
	
	new name[2][32]
	get_user_name(player,name[1],31)
	get_user_name(id,name[0],31)
	
	switch(tTransfer[id]) {
		case 0: {
			cs_set_user_team(player, CS_TEAM_CT)
			user_silentkill(player)
			ChatColor(0, "!g[%s] !team%s !ytransfered !team%s!y to the 'Counter-Terrorists'. !g[%s]", TAG, name[0] ,name[1], Skill[g_pstatus[id]])
		}
		case 1: {
			cs_set_user_team(player, CS_TEAM_T)
			user_silentkill(player)
			ChatColor(0, "!g[%s] !team%s !ytransfered !team%s!y to the 'Terrorists'. !g[%s]", TAG, name[0] ,name[1], Skill[g_pstatus[id]])
		}
		case 2: {
			cs_set_user_team(player, CS_TEAM_SPECTATOR)
			user_silentkill(player)
			ChatColor(0, "!g[%s] !team%s !ytransfered !team%s!y to the 'Spectators'. !g[%s]", TAG, name[0] ,name[1], Skill[g_pstatus[id]])
		}
	}
	/*
	new ctime[64]
	get_time("%m/%d/%Y - %H:%M:%S", ctime, 63)
	
	new temp[100]
	formatex(temp,99, "%s : Transfer %s",ctime,name[1])
	VipLog(id, temp)
	*/
	showtransfermenu(id)
	return PLUGIN_CONTINUE;
}
public showtransfermenu(id) {
	new menu = menu_create("\\dEncodedGaming:\\y Transfer Menu", "TransferMenu");
	
	new players[32], name[32], pnum, player;
	new szplayer[6]
	get_players(players,pnum)
	
	switch(tTransfer[id]) {
		case 0:menu_additem(menu, "\\r Counter Terrorist\n", "0", 0);
		case 1:menu_additem(menu, "\\r Terrorist\n", "0", 0);
		case 2:menu_additem(menu, "\\r Spectator\n", "0", 0);
	}
	
	for( new i; i<pnum; i++ ) {
		player = players[i]
		if((tTransfer[id] == 0 && get_user_team(player) == 2) 
		     || (tTransfer[id] == 1 && get_user_team(player) == 1)
		     || (tTransfer[id] == 2 && get_user_team(player) == 3))
			continue;
		else {
			get_user_name(players[i],name,31)
			num_to_str(player,szplayer,5)
			menu_additem(menu, name, szplayer, 0);
		}
	}
	
	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
	menu_display(id, menu, 0);
}
/*
AwesomeHosting/
	 - Vote menu
*/
public showvotemenu(id)
{
	new name[32], name2[32]
	get_user_name(Name[id],name,31)
	get_user_name(id,name2,31)
	
	new keys = (1<<0|1<<1);
		
	new szMenuBody[menusize - 1];
	new line[84]
	switch(cVotetype) {
		case 1:formatex(line,99,"\\r %s \\ywanne kick\\r %s \\yfor\\r %s\n\\w Do you accept?", name2, name, REDEN[Reason[id]])
		case 2:formatex(line,99,"\\r %s \\ywanne ban\\r %s \\yfor\\r %s\n\\w Do you accept?", name2, name, REDEN[Reason[id]])
		case 3:formatex(line,99,"\\r %s \\ywanne slay\\r %s \\yfor\\r %s\n\\w Do you accept?", name2, name, REDEN[Reason[id]])
	}
	
	new nLen = format(szMenuBody, menusize, "\\d#AwesomeJumpz:%s\n",line);
		
	nLen += format(szMenuBody[nLen], menusize-nLen, "\n\\w1. Yes");
	nLen += format(szMenuBody[nLen], menusize-nLen, "\n\\w2. No");
	
	cVoteYes=0
	cVoteNo=0
	
	new players[32], pnum;
	get_players(players, pnum);
	
	for( new i; i<pnum; i++ ) {
		show_menu(players[i], keys, szMenuBody, 10);
	}
	set_task(10.0, "EndVote", id);
}

public VoteMenu(id, key) {
	switch(key) {
		case 0: {
			if(cVoting) {
				cVoteYes++
				ChatColor(id, "!g[%s]!y You voted!team Yes!y.", TAG)
			}
		}
		case 1: {
			if(cVoting) {
				cVoteNo++
				ChatColor(id, "!g[%s]!y You voted!team No!y.", TAG)
			}
		}
	}
	return PLUGIN_HANDLED
}
	
public EndVote(id)
{
	new name[32]
	get_user_name(Name[id],name,31)
	
	if(cVoteYes > cVoteNo) {
		switch(cVotetype) {
			case 1: {
				ChatColor(id, "!g[%s]!y Vote to kick!team %s!y succesfull.", TAG, name)
				
				server_cmd("kick \"%s\"",name)
			}
			case 2: {
				ChatColor(id, "!g[%s]!y Vote to ban!team %s!y succesfull.", TAG, name)
				
				server_cmd("banid %i #%i Banned;writeid",get_pcvar_num(cBanTime),get_user_userid(Name[id]))
				server_cmd("kick \"%s\"",name)
			}
			case 3: {
				ChatColor(id, "!g[%s]!y Vote to slay!team %s!y succesfull.", TAG, name)
				
				user_silentkill(Name[id])
				make_deathmsg(id, Name[id], 1, "deagle")
			}
		}
	}
	else {
		switch(cVotetype) {
			case 1: {
				ChatColor(id, "!g[%s]!y Vote to kick!team %s!y failed.", TAG, name)
			}
			case 2: {
				ChatColor(id, "!g[%s]!y Vote to ban!team %s!y failed.", TAG, name)
			}
			case 3: {
				ChatColor(id, "!g[%s]!y Vote to slay!team %s!y failed.", TAG, name)
			}
		}
	}
	
	cVoting = 0
}
/*
	SQL
*/
public MySQL_Init() {
	if(!g_MySQL_Tuple) {
		// All these CVARS needs to be loaded in the server for example in server.cfg or sql.ini
		get_cvar_string("Menu_Host", cHost, 63)
		get_cvar_string("Menu_User", cUser, 63)
		get_cvar_string("Menu_Password", cPassword, 63)
		get_cvar_string("Menu_Name", cName, 63)

		// Make the Tuple from this information
		g_MySQL_Tuple = SQL_MakeDbTuple(cHost, cUser, cPassword, cName, 5)
	}
}
public MySQL_Connect() {
	MySQL_Init()

	if(!g_MySQL_Connection) {
		new ErrorCode

		g_MySQL_Connection = SQL_Connect(g_MySQL_Tuple, ErrorCode, g_MySQL_Error, 511)

		if(g_MySQL_Connection == Empty_Handle) {
			server_print("(EE) Can't connect to the database, check your settings")
			set_fail_state(g_MySQL_Error)
		} else {
			// Success!
			SQL_SimpleQuery(g_MySQL_Connection, "SET NAMES utf8")
			/* Table doesn't Exist? Oo */
			
			new Handle:Queries
			// we must now prepare some random queries
			Queries = SQL_PrepareQuery(g_MySQL_Connection,"CREATE TABLE IF NOT EXISTS MenuAccess (`id` int(5), `name` varchar(32), `steam_id` varchar(21), `pstatus` int(11), `hiderank` int(11), `colormode` int(11), `warning` int(11), `protection` int(11), `tag` varchar(10))");
			
			if(!SQL_Execute(Queries)) {
				//if there were any problems the plugin will set itself to bad load.
				SQL_QueryError(Queries,g_MySQL_Error,charsmax(g_MySQL_Error))
				set_fail_state(g_MySQL_Error)      
			}
		}
	}
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1053\\ f0\\ fs16 \n\\ par }
*/
