#include <amxmodx>
#include <cstrike>
#include <fakemeta_util>
#include <hamsandwich>


///////////////////////////////////////////////////////// Defines ////////////////////////////////////////////////////
#define MAX_PLAYERS 32
#define TID_1 73551859
#define TID_2 95815573
#define OFFSET_CSMONEY 115
#define POST_FORWARD 1


///////////////////////////////////////////////////////// Constatnts ////////////////////////////////////////////////
new const g_sRemoveEntities[][] = {"func_bomb_target","info_bomb_target","hostage_entity","monster_scientist","func_hostage_rescue","info_hostage_rescue","info_vip_start","func_vip_safetyzone","func_escapezone","armoury_entity"};
new const MAX_REMOVED_ENTITIES = sizeof(g_sRemoveEntities);
new const g_sBlank[] = "";
new const g_sClassBreakable[] = "func_breakable";
new const g_sClassDoor[] = "func_door";
new const g_sClassDoorRotating[] = "func_door_rotating";
new const g_sA[] = "a";
new const g_sKnifeModel_p[] = "models/p_knife.mdl";
new const g_sKnifeModel_v[] = "models/v_knife.mdl";


///////////////////////////////////////////////////////// NEW's /////////////////////////////////////////////////////
new SayText, g_HostageEnt, g_Max, team1, team2, team11, team22, gVoteMenu, gVoting, g_AA_VoteMenu, 
g_AA_Voting, g_nMsgScreenFade, last, count, gVotes[2], g_AA_Votes[2],
g_iCurWeapon[ 33 ], grenade[32], g_iTeam[33];


///////////////////////////////////////////////////////// Cvars /////////////////////////////////////////////////////
new hns_enable, hns_gather, hns_prefix, hns_removebreakables, hns_removedoors, hns_hidetime, hns_givesmokes, 
hns_giveflashbangs, hns_waitbg_red, hns_waitbg_green, hns_waitbg_blue, hns_fakeknife, hns_boost, hns_footsteps;



///////////////////////////////////////////////////////// BOOLS /////////////////////////////////////////////////////
new bool:g_bConnected[33], bool:g_bAlive[33], bool:g_bRemovedBreakables, bool:g_bRemovedDoors, bool:g_bRemovedDoorsRotating, bool:g_knife = false, 
bool:g_gather = false, bool:g_draw = false, bool:g_voted = false, bool:g_restart_attempt[MAX_PLAYERS + 1],
bool:g_aa = false, bool:stop_count = true, bool:g_bHasHideKnife[33], bool:g_bFirstSpawn[33], bool:g_bRestore[33], bool:g_bSolid[33];


///////////////////////////////////////////////////////// Floats /////////////////////////////////////////////////////
new Float:g_gametime, g_owner


// Fake Hostage
public plugin_precache()
{
	register_forward(FM_Spawn, "fwdSpawn", 0);
	
	new allocHostageEntity = engfunc(EngFunc_AllocString, "hostage_entity");
	do
	{
		g_HostageEnt = engfunc(EngFunc_CreateNamedEntity, allocHostageEntity);
	}
	while( !pev_valid(g_HostageEnt) );
	
	engfunc(EngFunc_SetOrigin, g_HostageEnt, Float:{0.0, 0.0, -55000.0});
	engfunc(EngFunc_SetSize, g_HostageEnt, Float:{-1.0, -1.0, -1.0}, Float:{1.0, 1.0, 1.0});
	dllfunc(DLLFunc_Spawn, g_HostageEnt);
	
	return PLUGIN_CONTINUE;
}

public plugin_init() 
{
	register_plugin("HideNseek", "1.5", "Exolent");
	
	register_clcmd("say", "HandleSay");
	register_clcmd("say_team", "HandleSayTeam");
	register_clcmd("say /SSmenu", "MenuOpener");
	register_clcmd("say /score", "show_score");
	register_clcmd("say /knife", "hideknife");
	register_clcmd("say /hideknife", "hideknife");
	register_clcmd("fullupdate", "clcmd_fullupdate");
	
	hns_removebreakables = 			register_cvar("hns_removebreakables", "1");
	hns_removedoors = 			register_cvar("hns_removedoors", "1");
	hns_prefix = 				register_cvar("hns_prefix", "[HNS]");
	hns_enable = 				register_cvar( "hns_enable", "1" );
	hns_gather = 				register_cvar( "hns_gather", "0" );
	hns_hidetime = 				register_cvar("hns_hidetime","8");
	hns_givesmokes = 			register_cvar("hns_givesmokes","1");
	hns_fakeknife = 			register_cvar("hns_fakeknife","0");
	hns_giveflashbangs = 			register_cvar("hns_giveflashbangs","2");
	hns_waitbg_red = 			register_cvar("hns_waitbg_red","0");
	hns_waitbg_green = 			register_cvar("hns_waitbg_green","0");
	hns_waitbg_blue = 			register_cvar("hns_waitbg_blue","0");
	hns_boost = 				register_cvar("hns_boost", "0");
	hns_footsteps = 			register_cvar("hns_footsteps", "1");
	
	g_Max 			= get_maxplayers( );
	SayText 		= get_user_msgid ("SayText")
	g_nMsgScreenFade 	= get_user_msgid("ScreenFade");

	RegisterHam(Ham_Spawn, "player", "fwHamPlayerSpawnPost", 1);
	
	register_forward(FM_CmdStart, "fwdCmdStart", 0);
	register_forward(FM_ClientKill, "Forward_ClientKill");
	register_forward(FM_EmitSound, "fwdEmitSound", 0);
	register_forward( FM_PlayerPreThink, "FwdPreThink", POST_FORWARD );
	register_forward( FM_PlayerPostThink, "FwdPostThink" );
	register_forward( FM_AddToFullPack, "FwdFullPackPost", 1 );
    
	register_event("HLTV", "eventNewRound", g_sA, "1=0", "2=0");
	register_event("TextMsg","event_restart_attempt","a","2=#Game_will_restart_in");
	register_event("ScreenFade", "eventFlash", "be", "4=255", "5=255", "6=255", "7>199");
	register_event("TextMsg", "fire_in_the_hole", "b", "2&#Game_radio", "4&#Fire_in_the_hole");
	register_event("TextMsg", "fire_in_the_hole2", "b", "3&#Game_radio", "5&#Fire_in_the_hole");
	register_event("99", "grenade_throw", "b");
	register_event("DeathMsg","event_death","a");
	register_event("Money", "event_money", "be");
	register_event("ResetHUD","event_hud_reset","be");
	register_event("SendAudio","CTwin","a","1=0","2&%!MRAD_ctwin","3=100");
	register_event("SendAudio","Twin","a","1=0","2&%!MRAD_terwin","3=100");
	register_event( "CurWeapon", "EventCurWeapon", "be", "1=1" );

	register_logevent("RoundStart",2,"1=Round_Start");
	register_logevent("RoundEnd",2,"1=Round_End");
	register_logevent("Team_Win_New", 6, "0=Team");
	
	register_message(get_user_msgid("ScreenFade"), "Message_ScreenFade");
	register_message( get_user_msgid( "TextMsg" ), "message_textmsg" );
	register_message(get_user_msgid("Money"), "MessageMoney");
	register_message(get_user_msgid("HideWeapon"), "MessageHideWeapon");
	register_message(SayText, "MsgDuplicate")
	
	CheckMap();
	Check4Gather();
}

public Check4Gather()  if(get_pcvar_num(hns_gather)) stop_gather()

// Hide money
public MessageMoney(msgid, dest, id)
{
	set_pdata_int(id, OFFSET_CSMONEY, 0);
	set_msg_arg_int(1, ARG_LONG, 0);
}

public MessageHideWeapon(msgid, dest, id) set_msg_arg_int(1, ARG_BYTE, get_msg_arg_int(1) | (1<<5));

// Hostage
public fwdSpawn(ent)
{
	if( !pev_valid(ent) || ent == g_HostageEnt )
		return FMRES_IGNORED;
	
	new sClass[32];
	pev(ent, pev_classname, sClass, 31);
	
	for( new i = 0; i < MAX_REMOVED_ENTITIES; i++ )
	{
		if( equal(sClass, g_sRemoveEntities[i]) )
		{
			engfunc(EngFunc_RemoveEntity, ent);
			return FMRES_SUPERCEDE;
		}
	}
	
	return FMRES_IGNORED;
} 

public event_death() 
{	
	new victim = read_data(2);
	g_bAlive[victim] = false;
	
	new players[32], num, tnum, id
	tnum = 0
	get_players(players, num, "a")
	for (new i; i < num; ++i) 
	{
		if(cs_get_user_team(players[i]) == CS_TEAM_T) 
		{
			id = players[i]
			tnum = tnum+1
		}
	}

	if(tnum == 1) 
		set_task(0.1,"GiveWeapons",id)
}

public FwdPreThink( id )
{
		if( g_bAlive[id] && get_pcvar_num( hns_footsteps ) == get_user_team( id ) )
			set_pev( id, pev_flTimeStepSound, 999 );
			
		if( get_pcvar_num( hns_boost ) )
			return FMRES_IGNORED;
	
		static LastThink, i;
		if( LastThink > id )
		{
			for( i = 1; i < g_Max; i++ )
			{
				if( !g_bAlive[i] )
				{
					g_bSolid[i] = false;
					continue;
				}
				
				g_iTeam[i] = get_user_team( i );
				g_bSolid[i] = pev( i, pev_solid ) == SOLID_SLIDEBOX ? true : false;
			}
		}
			
		LastThink = id;
		
		if( !g_bSolid[id] )
			return FMRES_IGNORED;
			
		for( i = 1; i < g_Max; i++ )
		{
			if( !g_bSolid[i] || id == i )
				continue;
				
			if( get_user_team( i ) == get_user_team( id ) )
			{
				set_pev( i, pev_solid, SOLID_NOT );
				g_bRestore[i] = true;
			}
		}
	
		return FMRES_IGNORED;
}

public fwdCmdStart(plr, ucHandle, seed)
{
		if( !g_bAlive[plr] )
			return FMRES_IGNORED;
	
		static clip, ammo;
		if( get_user_weapon(plr, clip, ammo) != CSW_KNIFE )
			return FMRES_IGNORED;
		
		new CsTeams:team = cs_get_user_team(plr);
		
		if( team == CS_TEAM_T )
		{
			if(g_knife)
			{
				new button = get_uc(ucHandle, UC_Buttons);

				if( button&IN_ATTACK )
				{
					button &= ~IN_ATTACK;
					button |= IN_ATTACK2;
				}
				set_uc(ucHandle, UC_Buttons, button);
			}
			else
			{
				new button = get_uc(ucHandle, UC_Buttons);
				
				if( button&IN_ATTACK )
					button &= ~IN_ATTACK;
					
				if( button&IN_ATTACK2 )
					button &= ~IN_ATTACK2;
				
				set_uc(ucHandle, UC_Buttons, button);
			}
			
			return FMRES_SUPERCEDE;
		}
		else if( team == CS_TEAM_CT )
		{
			new button = get_uc(ucHandle, UC_Buttons);

			if( button&IN_ATTACK )
			{
				button &= ~IN_ATTACK;
				button |= IN_ATTACK2;
			}
			set_uc(ucHandle, UC_Buttons, button);
				
			return FMRES_SUPERCEDE;
		}
		
		return FMRES_IGNORED;
}

public voxSpeak(num) 
{
	new number[33]
	num_to_word(num,number,32)

	if(num > 0) 
		client_cmd(0, "spk ^"vox/%s^"",number)
}

public RoundStart() 
{
	if(task_exists(TID_1)) remove_task(TID_1)
	if(task_exists(TID_2)) remove_task(TID_2)
	
	if( get_pcvar_num(hns_removebreakables) )
		g_bRemovedBreakables = remove_entities(g_sClassBreakable);

	else if( g_bRemovedBreakables )
		g_bRemovedBreakables = restore_entities(g_sClassBreakable);
	
	if( get_pcvar_num(hns_removedoors) )
	{
		g_bRemovedDoors = remove_entities(g_sClassDoor);
		g_bRemovedDoorsRotating = remove_entities(g_sClassDoorRotating);
	}
	else
	{
		if( g_bRemovedDoors )
			g_bRemovedDoors = restore_entities(g_sClassDoor);
		
		if( g_bRemovedDoorsRotating )
			g_bRemovedDoorsRotating = restore_entities(g_sClassDoorRotating);
	}
	
	//set_task(float(floatround(get_cvar_float("mp_roundtime") * 60.0,floatround_floor)),"EndRound",TID_2)
	count = get_pcvar_num(hns_hidetime)

	if( !g_knife ) 
	{
		Qflash()
		ShowTime()
		voxSpeak(count)
		FreezCT()
		set_task(1.0,"SetTimer",0)
	}

	for( new i = 1 ; i <= g_Max ; i++ )
	{
		if( !is_user_connected(i) )
			continue;

		fm_strip_user_weapons(i);
		fm_give_item(i,"weapon_knife")
	}
}

bool:remove_entities(const class[])
{
	new bool:remove = false;
	
	new ent = g_Max, properties[32], Float:amt;
	while( (ent = engfunc(EngFunc_FindEntityByString, ent, "classname", class)) )
	{
		pev(ent, pev_renderamt, amt);
		formatex(properties, 31, "^"%i^" ^"%f^" ^"%i^"", pev(ent, pev_rendermode), amt, pev(ent, pev_solid));
		
		set_pev(ent, pev_message, properties);
		set_pev(ent, pev_rendermode, kRenderTransAlpha);
		set_pev(ent, pev_renderamt, 0.0);
		set_pev(ent, pev_solid, SOLID_NOT);
		
		remove = true;
	}
	
	return remove;
}

bool:restore_entities(const class[])
{
	new bool:remove = true;
	
	new ent = g_Max, properties[32], rendermode[4], amt[16], solid[4];
	while( (ent = engfunc(EngFunc_FindEntityByString, ent, "classname", class)) )
	{
		pev(ent, pev_message, properties, 31);
		parse(properties, rendermode, 3, amt, 15, solid, 3);
		
		set_pev(ent, pev_rendermode, str_to_num(rendermode));
		set_pev(ent, pev_renderamt, str_to_float(amt));
		set_pev(ent, pev_solid, str_to_num(solid));
		set_pev(ent, pev_message, g_sBlank);
		
		remove = false;
	}
	
	return remove;
}

public fwHamPlayerSpawnPost(iPlayer) 
{
	if( !g_bFirstSpawn[iPlayer] )
	{	
		g_bFirstSpawn[iPlayer] = true;
		hide_knife_message(iPlayer);
	}
	
	g_bAlive[iPlayer] = true;
	if (is_user_alive(iPlayer)) 
	{
		fm_strip_user_weapons(iPlayer);
		fm_give_item(iPlayer,"weapon_knife")
	}
} 

public hide_knife_message(iPlayer) if(is_user_connected(iPlayer)) hns_print(iPlayer, "If you want to^3 hide^1 your Knife, type in chat^4 /hideknife");

public Qflash() 
{
	new players[32],num
	get_players(players,num,"a")
	for (new i; i < num; ++i) 
	{
		if(cs_get_user_team(players[i]) == CS_TEAM_CT) 
			flashplayer(players[i],0)
	}
}

public SwitchTeams() 
{
	new players[32],num
	get_players(players,num)
	for (new i; i < num; ++i) 
	{
		if(cs_get_user_team(players[i]) == CS_TEAM_CT) 
			cs_set_user_team(players[i],CS_TEAM_T,CS_T_LEET)

		else if(cs_get_user_team(players[i]) == CS_TEAM_T) 
			cs_set_user_team(players[i],CS_TEAM_CT,CS_CT_URBAN)
	}
}

public CTwin() 
{
	client_print( 0, print_center, "Seekers Win" );

	if( !get_pcvar_num( hns_gather )) SwitchTeams()
}

public Twin() 
{
	client_print( 0, print_center, "Hiders Win" );
}

public FreezCT()
{
	new players[32], num
	get_players(players, num, "a")
	for (new i; i < num; ++i) 
	{
		if(cs_get_user_team(players[i]) == CS_TEAM_CT) 
		{
			flashplayer(players[i],0)
			set_pev(players[i],pev_flags,pev(players[i],pev_flags) | FL_FROZEN)
		}
	}
}

public SetTimer(id) 
{
	count = count-1
	ShowTime()
	voxSpeak(count)
	
	if(count > 0) 
		set_task(1.0,"SetTimer",TID_1)
	else 
		SetGame(id)
}

public ShowTime() 
{
	new players[32], num
	get_players(players, num, "a")
	for (new i; i < num; ++i) 
	{
		if(cs_get_user_team(players[i]) == CS_TEAM_CT) 
		{
			set_hudmessage(random(255), random(255), random(255), -1.0, 0.01, 0, 0.0, 1.1, 0.1, 0.1, 1);
			show_hudmessage(players[i],"Hiders have %d seconds to hide..",count)
		} 
		else if(cs_get_user_team(players[i]) == CS_TEAM_T) 
		{
			set_hudmessage(random(255), random(255), random(255), -1.0, 0.01, 0, 0.0, 1.1, 0.1, 0.1, 1);
			show_hudmessage(players[i],"You have %d seconds to hide..",count)
		}
	}
}

public SetGame(id) 
{
	new players[32], num
	get_players(players, num, "a")
	for (new i; i < num; ++i) 
	{
		if(cs_get_user_team(players[i]) == CS_TEAM_CT) 
		{
			flashplayer(players[i],1)
			set_pev(players[i],pev_flags,pev(players[i],pev_flags) - FL_FROZEN)
		} 
		if( !g_knife ) 
		{
			set_task(0.1,"GiveWeapons",players[i])
			status_messages(players[i])
		}
	}
}

public status_messages(id)
{
	new players[32], num
	get_players(players, num, "a")
	for (new i; i < num; ++i) 
	{
		if(cs_get_user_team(players[i]) == CS_TEAM_CT) 
		{
			set_hudmessage(random(255), random(255), random(255), -1.0, 0.01, 0, 0.0, 3.0, 0.1, 0.1, 1);
			show_hudmessage(players[i],"Game starts! Kill the Hiders!")
		} 
		else if(cs_get_user_team(players[i]) == CS_TEAM_T) 
		{
			set_hudmessage(random(255), random(255), random(255), -1.0, 0.01, 0, 0.0, 3.0, 0.1, 0.1, 1);
			show_hudmessage(players[i],"Game starts! Survive the round!")
		}
	}
		
}

public flashplayer(id,reset) 
{
	new hnstime = get_pcvar_num(hns_hidetime)
	if(reset) 
	{
		message_begin(MSG_ONE,g_nMsgScreenFade,_,id)
		write_short(0)
		write_short(0)
		write_short(0)
		write_byte(0)
		write_byte(0)
		write_byte(0)
		write_byte(0)
		message_end()
	} 
	else 
	{
		message_begin(MSG_ONE,g_nMsgScreenFade,_,id)
		write_short(hnstime)
		write_short(hnstime)
		write_short(1<<2)
		write_byte(get_pcvar_num(hns_waitbg_red))
		write_byte(get_pcvar_num(hns_waitbg_green))
		write_byte(get_pcvar_num(hns_waitbg_blue))
		write_byte(255)
		message_end()
	}
}

public Message_ScreenFade(osef, MSG_Type, id)
{
    if( get_msg_arg_int(4) != 255 || get_msg_arg_int(5) != 255 || get_msg_arg_int(6) != 255 )
        return
    
    static iAlpha
    iAlpha = get_msg_arg_int(7)
    if(iAlpha != 200 && iAlpha != 255)
        return

    if(get_user_team(id) != 1)
        return

    set_msg_arg_int(1, 0, 4)
    set_msg_arg_int(2, 0, 0)
    set_msg_arg_int(3, 0, 0)
    set_msg_arg_int(4, 0, 0)
    set_msg_arg_int(5, 0, 0)
    set_msg_arg_int(6, 0, 0)
    set_msg_arg_int(6, 0, 7)
}  

public RoundEnd() 
{
	count = get_pcvar_num(hns_hidetime)
	set_cvar_num("mp_freezetime",0)

	if( get_pcvar_num( hns_enable ))
	{
		if( get_pcvar_num( hns_gather ))
		{
			if (team1 + team2 == 8)
			{
				hns_print(0, "8 rounds passed. That was a^3 First Half !");
				hns_print(0, "Score:^3 Hiders^4 %d^1 -^4 %d^3 Seekers", team1, team2);
				hns_print(0, "8 rounds passed. It's time to change teams !");
				
				tree()
				
				hns_print(0, "Round will be^3 restarted^1 after^4 20^1 seconds.", team1, team2);
				set_task(20.0, "res3");
			}

			if (g_draw)
			{
				if( team11 + team22 == 3)
				{
					tree()
					nz()

				}
			}
		}
	}
}

public EventCurWeapon( plr )
{
	g_iCurWeapon[ plr ] = read_data( 2 );
	
	if( g_bHasHideKnife[plr] && cs_get_user_team(plr) == CS_TEAM_T )
	{
		new sModel[32];
		
		pev(plr, pev_viewmodel2, sModel, 31);
		if( equali(sModel, g_sKnifeModel_v, 0) )
			set_pev(plr, pev_viewmodel2, g_sBlank);
		
		pev(plr, pev_weaponmodel2, sModel, 31);
		if( equali(sModel, g_sKnifeModel_p, 0) )
			set_pev(plr, pev_weaponmodel2, g_sBlank);
	}
}

public GiveWeapons(id) 
{
	if(get_pcvar_num(hns_enable))
	{
		if (is_user_alive(id)) 
		{
			if (cs_get_user_team(id) == CS_TEAM_T) 
			{
				if(!g_knife)
				{
					if(get_pcvar_num(hns_givesmokes)) 
					{
						fm_give_item(id,"weapon_smokegrenade")
						cs_set_user_bpammo(id,CSW_SMOKEGRENADE, get_pcvar_num(hns_givesmokes))
					}
					
					if(get_pcvar_num(hns_giveflashbangs)) 
					{
						if(get_pcvar_num(hns_giveflashbangs) > 1) 
						{
							fm_give_item(id,"weapon_flashbang")
							fm_give_item(id,"weapon_flashbang")
						}
						cs_set_user_bpammo(id,CSW_FLASHBANG,get_pcvar_num(hns_giveflashbangs))
					}
				}
			}
			else if (cs_get_user_team(id) == CS_TEAM_CT) 
				fm_give_item(id,"weapon_knife")
		}
	}
}

public clcmd_fullupdate() 
	return PLUGIN_HANDLED_MAIN
 
public event_restart_attempt() 
{
	new players[32], num
	get_players(players, num, "a")
	for (new i; i < num; ++i) 
	{
		g_restart_attempt[players[i]] = true
	}
}
 
public event_hud_reset(id) 
{
	if (g_restart_attempt[id]) 
	{
		g_restart_attempt[id] = false
		return
	}
	
	if( !g_knife )
	{
		if(cs_get_user_team(id) == CS_TEAM_CT) 
		{
			flashplayer(id,0)
			set_pev(id,pev_flags,pev(id,pev_flags) | FL_FROZEN)
		}
	}
}

public plugin_cfg() 
{
	set_cvar_num("mp_freezetime",0)
	count = get_pcvar_num(hns_hidetime)
}

public event_money(id) cs_set_user_money(id,0,0)

public client_putinserver(plr) 
{
	g_bConnected[plr] = true;
	g_bAlive[plr] = false;
	g_bFirstSpawn[plr] = false;
	g_bHasHideKnife[plr] = bool:(get_pcvar_num(hns_fakeknife) == 1);
}
public client_disconnect(plr) g_bConnected[plr] = false;


///////////////////////////////////////////////////////////
////////////////////// Grenade Funcs //////////////////////
///////////////////////////////////////////////////////////
// NE SAMO TUK !

public eventFlash(id) 
{
	new Float:gametime = get_gametime()
	if(gametime != g_gametime) 
	{
		g_owner = get_grenade_owner()
		g_gametime = gametime
	}
	if(is_user_connected(g_owner) && g_owner != id && get_user_team(id) == get_user_team(g_owner)) 
		flashplayer(id,1)
}

public grenade_throw() 
{
	if(read_datanum() < 2)
		return PLUGIN_HANDLED_MAIN
	if(read_data(1) == 11 && (read_data(2) == 0 || read_data(2) == 1)) 
		add_grenade_owner(last)
	return PLUGIN_CONTINUE
}

public fire_in_the_hole() 
{
	new name[32]
	read_data(3, name, 31)
	last = get_user_index(name)
	return PLUGIN_CONTINUE
}

public fire_in_the_hole2() 
{
	new name[32]
	read_data(4, name, 31)
	last = get_user_index(name)
	return PLUGIN_CONTINUE
}

add_grenade_owner(owner) 
{
	for(new i = 0; i < 32; i++) 
	{
		if(grenade[i] == 0) 
		{
			grenade[i] = owner
			return
		}
	}
}

get_grenade_owner() 
{
	new which = grenade[0]
	for(new i = 1; i < 32; i++) 
		grenade[i-1] = grenade[i]

	grenade[31] = 0
	return which
}

// block kill
public Forward_ClientKill(id) return FMRES_SUPERCEDE  

// block jointeam
public client_command( client )
{
	static const szJoinCommand[ ] = "jointeam";
    
	static szCommand[ 10 ];
	read_argv( 0, szCommand, 9 );
    
	if( equal( szCommand, szJoinCommand ) && CS_TEAM_T <= cs_get_user_team( client ) <= CS_TEAM_CT )
		return PLUGIN_HANDLED;

	return PLUGIN_CONTINUE;
}  





///////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////// START Gather /////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////





///////////////////////////////////////////////////////////
////////////////////// Menu Funcs /////////////////////////
///////////////////////////////////////////////////////////

public MenuOpener(id)
{
	if (!(get_user_flags(id) & ADMIN_RCON))
		hns_print(id, "^3 You don't have acces to this command !!!");
	else
		HeadMenu(id);
}

back(id) set_task(0.1, "HeadMenu", id)

public HeadMenu(id)
{
	new menu = menu_create("\rAdmin Menu", "MenuHandler");
	
	menu_additem(menu, "\wRound Restart", "1" );
	
	menu_additem(menu, "\w3 restarts and Go", "2" );
	
	menu_additem(menu, "\wChange Teams", "3" );
	
	if( g_gather ) 
		menu_additem(menu, "\wStop Gather \d[Status: \yON\d]", "4");
	else
		menu_additem(menu, "\wStart Gather \d[Status \rOFF\d]", "4");
	
	if( g_knife ) 
		menu_additem(menu, "\wStop Knife Round \d[Status: \yON\d]", "5" );
	else
		menu_additem(menu, "\wStart Knife Round \d[Status: \rOFF\d]", "5" );

	menu_additem(menu, "\wAiraccelerate Menu", "6" );

	menu_additem(menu, "\wScore Settings", "7" );
	
	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL)
	menu_display(id, menu)
}

public MenuHandler(id, menu, item)
{
	if (item == MENU_EXIT)
	{
		menu_destroy(menu)
		return PLUGIN_HANDLED;
	}
	
	new data[6], name[64], acces, callback
	menu_item_getinfo(menu, item, acces, data, charsmax(data), name, charsmax(name), callback)
	new key = str_to_num(data)
	
	switch (key)
	{
		case 1: 
		{
			one();
			HeadMenu(id);
		}
		case 2: 
		{
			two();
			HeadMenu(id);
		}
		case 3: 
		{
			tree();
			HeadMenu(id);
		}
		case 4: 
		{
			four();
			HeadMenu(id);
		}
		case 5: 
		{
			six(id);
			HeadMenu(id);
		}
		case 6: aa_menu(id);
		case 7: score_settings(id);
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}



///////////////////////////////////////////////////////////
//////////////////// Restart Funcs ////////////////////////
///////////////////////////////////////////////////////////

one()
{
	server_cmd("sv_restart 1");

	hns_print(0, "^3Restarting^1 round.");
}

two()
{
	server_cmd("sv_restart 1");
	set_task(1.0, "res");
	set_task(4.0, "res2");
	
	hns_print(0, "Round will be^4 restarted^3 3^1 times^1 !");
}

public res() server_cmd( "sv_restart 1" );

public res2(id)
{
	server_cmd( "sv_restart 1" );
	set_task(8.0, "live_hud", id)
}

public res3()
{
	hns_print(0, "Round will be^4 restarted^3 3^1 times^1 !");
	server_cmd("sv_restart 1");
	set_task(1.0, "res");
	set_task(4.0, "res2");
	set_task(6.0, "half");
}

public live_hud()
{
	for( new i = 1 ; i <= g_Max ; i++ )
	{
		if( !is_user_connected(i) )
			continue;

		set_hudmessage(255, 255, 255, -1.0, 0.28, 0, 5.0, 5.0, 3.0, 3.0, 4)
		show_hudmessage(i, "!!! LIVE !!! LIVE !!! LIVE !!!");
		
		set_hudmessage(0, 255, 0, -1.0, 0.31, 0, 5.0, 5.0, 3.0, 3.0, 2)
		show_hudmessage(i, "!!! LIVE !!! LIVE !!! LIVE !!! LIVE !!!");

		set_hudmessage(255, 0, 0, -1.0, 0.34, 0, 5.0, 5.0, 3.0, 3.0, 3)
		show_hudmessage(i, "!!! LIVE !!! LIVE !!! LIVE !!! LIVE !!! LIVE !!!");
	}
}

public half() hns_print(0, "^3 First Half^4 Over!^3 Second Half^4 Started!");

nz()
{
	server_cmd("sv_restart 1");
	set_task(2.0, "res");
}




///////////////////////////////////////////////////////////
///////////////// Change Teams Func ///////////////////////
///////////////////////////////////////////////////////////

tree()
{
	SwitchTeams()

	server_cmd( "sv_restart 1" );

	hns_print(0, "Teams will be changed.^3 [Hiders^4 <>^3 Seekers]");
}



///////////////////////////////////////////////////////////
/////////////// Start/Stop Gather Func ////////////////////
///////////////////////////////////////////////////////////

public stop_gather()
{
	server_cmd("amx_painshockfree 1");
	server_cmd("mp_forcecamera 2");
	server_cmd("hns_hidetime 8");
	set_pcvar_num(hns_gather, 0)
	hns_print(0, "^3Gather Mod^1 has been^4 stopped^1 and^3 Normal Mod^1 has been^4 started !");
	server_cmd("mp_timelimit 20");
	
	// reskame score-to
	// before draw
	team1 = 0;
	team2 = 0;
	// after draw
	team11 = 0;
	team22 = 0;
	// stop showing draw hud 
	g_draw = false;
	
	g_gather = false
	one();
}

four()
{
	if(get_pcvar_num(hns_gather)) 
	{
		server_cmd("amx_painshockfree 1");
		server_cmd("mp_forcecamera 2");
		server_cmd("hns_hidetime 8");
		set_pcvar_num(hns_gather, 0)
		hns_print(0, "^3Gather Mod^1 has been^4 stopped^1 and^3 Normal Mod^1 has been^4 started !");
		server_cmd("mp_timelimit 20");
		g_gather = false
		one();
	}
	else
	{
		server_cmd("amx_painshockfree 0");
		server_cmd("mp_timelimit 40");
		server_cmd("hns_hidetime 15");
		server_cmd("mp_forcecamera 2");
		set_pcvar_num(hns_gather, 1);
		hns_print(0, "^3Gather Mod^1 has been^4 started^1 and^3 Normal Mod^1 has been^4 stopped !");
		g_gather = true
		two();
	}
	// reskame score-to
	// before draw
	team1 = 0;
	team2 = 0;
	// after draw
	team11 = 0;
	team22 = 0;
	// stop showing draw hud 
	g_draw = false;
}


///////////////////////////////////////////////////////////
//////////////// Start Knife Round Func ///////////////////
///////////////////////////////////////////////////////////

six(id)
{
	if ( !g_knife) 
	{
		server_cmd( "hns_enable 0" );
		server_cmd("sv_restart 1");
		g_knife = true
		set_task(5.0, "knife_message_on", id)
	} 
	else
	{
		server_cmd( "hns_enable 1" );
		server_cmd("sv_restart 1");
		g_knife = false
		set_task(2.0, "knife_message_off", id)
	}
}



///////////////////////////////////////////////////////////
///////////////// Airaccelerate Func //////////////////////
///////////////////////////////////////////////////////////

public aa_menu(id)
{
	new menu = menu_create("\rAdmin Menu \d- \rAiraccelerate Menu", "aa_menu_func");
	
	menu_additem(menu, "\wStart Airaccelrate Vote", "1" );
	
	if( !g_aa ) 
		menu_additem(menu, "\wSet \r10 \wAiraccelerate \d[AA: \y100\d]", "2" );
	else
		menu_additem(menu, "\wSet \y100 \wAiraccelerate \d[AA: \r10\d]", "2" );
	
	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL)
	menu_display(id, menu)
}

public aa_menu_func(id, menu, item)
{
	if (item == MENU_EXIT)
	{
		menu_destroy(menu)
		return PLUGIN_HANDLED;
	}
	
	new data[6], name[64], acces, callback
	menu_item_getinfo(menu, item, acces, data, charsmax(data), name, charsmax(name), callback)
	new key = str_to_num(data)
	
	switch (key)
	{
		case 1: Start_AA_Vote( id )
		case 2: 
		{
			seven();
			aa_menu(id);
		}
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

seven()
{
	if ( get_cvar_num( "sv_airaccelerate") == 100) 
	{
		server_cmd( "sv_airaccelerate 10" );
		hns_print(0, "^3Airaccelerate^1 has been changed to^4 10.");
		g_aa = true
	}
	else if ( get_cvar_num( "sv_airaccelerate" ) == 10) 
	{
		server_cmd( "sv_airaccelerate 100" );
		hns_print(0, "^3Airaccelerate^1 has been changed to^4 100.");
		g_aa = false
	}
}



///////////////////////////////////////////////////////////
////////////// Gather Knife Round Funcs ///////////////////
///////////////////////////////////////////////////////////

public knife_message_on()
{
	for( new i = 1 ; i <= g_Max ; i++ )
	{
		if( !is_user_connected(i) )
			continue;
			
		set_hudmessage(255, 255, 255, -1.0, 0.28, 0, 5.0, 5.0, 3.0, 3.0, 1)
		show_hudmessage(i, "Knife Round has been started !");
		
		set_hudmessage(0, 255, 0, -1.0, 0.31, 0, 5.0, 5.0, 3.0, 3.0, 2)
		show_hudmessage(i, "Knife Round has been started !");
			
		set_hudmessage(255, 0, 0, -1.0, 0.34, 0, 5.0, 5.0, 3.0, 3.0, 3)
		show_hudmessage(i, "Knife Round has been started !");
			
		hns_print(i, "^3Knife Round^1 has been^4 started^1 !");
		hns_print(i, "^3Knife Round^1 has been^4 started^1 !");
		hns_print(i, "^3Knife Round^1 has been^4 started^1 !");
	}
}

public knife_message_off()
{
	for( new i = 1 ; i <= g_Max ; i++ )
	{
		if( !is_user_connected(i) )
			continue;

		hns_print(i, "^3Knife Round^1 has been^4 STOPPED^1 !");
		hns_print(i, "^3Knife Round^1 has been^4 STOPPED^1 !");
		hns_print(i, "^3Knife Round^1 has been^4 STOPPED^1 !");
	}
}



///////////////////////////////////////////////////////////
/////////////////////// Score Funcs ///////////////////////
///////////////////////////////////////////////////////////

public chat_score()
{
	if (team1 + team2 < 8) 
		hns_print(0, "Score:^3 Hiders^4 %d^1 -^4 %d^3 Seekers", team1, team2);

	else if (team1 + team2 > 8)
		hns_print(0, "Score:^3 Hiders^4 %d^1 -^4 %d^3 Seekers", team2, team1);

	else if (team1 + team2 == 8)
		hns_print(0, "Score:^3 Hiders^4 %d^1 -^4 %d^3 Seekers", team2, team1);
}

public chat_score2()
{
	if (team1 + team2 < 8) 
		hns_print(0, "Score:^3 Hiders^4 %d^1 -^4 %d^3 Seekers", team1, team2);

	else if (team1 + team2 > 8)
		hns_print(0, "Score:^3 Hiders^4 %d^1 -^4 %d^3 Seekers", team2, team1);

	else if (team1 + team2 == 8)
		hns_print(0, "Score:^3 Hiders^4 %d^1 -^4 %d^3 Seekers", team2, team1);
}

public scoree()
{
	set_hudmessage(0, 255, 0, -1.0, 0.31, 0, 5.0, 5.0, 3.0, 3.0, 3)
	show_hudmessage(0,"Hiders %d - %d Seekers", team2, team1);
}

public show_score(id)
{
	if(get_pcvar_num(hns_gather)) 
	{
		if(g_draw)
		{
			if(team11 + team22 < 3)
				hns_print(id, "Score After Draw:^3 Hiders^4 %d^1 -^4 %d^3 Seekers", team11, team22);
			else if(team11 + team22 > 3)
				hns_print(id, "Score After Draw:^3 Hiders^4 %d^1 -^4 %d^3 Seekers", team22, team11);
		}
		else
		{
			if (team1 + team2 < 8) 
				hns_print(id, "Score:^3 Hiders^4 %d^1 -^4 %d^3 Seekers", team1, team2);
			else if (team1 + team2 > 8)
				hns_print(id, "Score:^3 Hiders^4 %d^1 -^4 %d^3 Seekers", team2, team1);
		}
	}
}

public score_settings(id)
{
	new menu = menu_create("\rAdmin Menu \d- \rScore Settings", "score_hand");
	
	menu_additem(menu, "\wReset Score + Restart Round", "1" );
	menu_additem(menu, "\wReset Score After Draw + Restart Round^n", "2" );
	
	if( stop_count )
		menu_additem(menu, "\wStop Counting Score \d[Status: \yON\y]^n", "3" );
	else
		menu_additem(menu, "\wStart Counting Score \d[Status: \rOFF\y]^n", "3" );
		
	menu_additem(menu, "\wHiders Settings Score \d[\yAdd \d/ \rRemove\d]", "4" );
	menu_additem(menu, "\wSeekers Settings Score \d[\yAdd \d/ \rRemove\d]^n", "5" );
	
	if(g_draw) menu_additem(menu, "\wStop Showing Score-After-Draw HUD^n^n", "6" );
	
	menu_additem(menu, "\wBack", "7" );
	
	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL)
	menu_display(id, menu)
}

public score_hand(id, menu, item)
{
	if (item == MENU_EXIT)
	{
		menu_destroy(menu)
		return PLUGIN_HANDLED;
	}
	
	new data[6], name[64], acces, callback
	menu_item_getinfo(menu, item, acces, data, charsmax(data), name, charsmax(name), callback)
	new key = str_to_num(data)
	
	switch (key)
	{
		case 1: 
		{
			team1 = 0;
			team2 = 0;
			hns_print(0, "The score has been^3 restarted^1 !");
			score_settings(id);
			one()
		}
		case 2:
		{
			team11 = 0;
			team22 = 0;
			hns_print(0, "The score after draw has been^3 restarted^1 !");
			score_settings(id)
			one()
		}
		case 3: 
		{
			stop_count2();
			score_settings(id);
		}
		case 4:	team1_settings(id);
		case 5:	team2_settings(id);
		case 6:
		{
			g_draw = false;
			hns_print(id, "The^3 Score-After-Draw HUD^1 is^4 disabled^1 !");
			score_settings(id)
		}
		case 7: back(id);
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

public team1_settings(id)
{
	new menu = menu_create("\rAdmin Menu \d- \rHiders Score Settings", "team1_score_hand");
	
	menu_additem(menu, "\yAdd \w+1 Score for \yHiders", "1" );
	menu_additem(menu, "\rRemove \w-1 Score for \yHiders^n^n", "2" );
	
	menu_additem(menu, "\wBack", "3" );
	
	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL)
	menu_display(id, menu)
}

public team1_score_hand(id, menu, item)
{
	if (item == MENU_EXIT)
	{
		menu_destroy(menu)
		return PLUGIN_HANDLED;
	}
	
	new data[6], name[64], acces, callback
	menu_item_getinfo(menu, item, acces, data, charsmax(data), name, charsmax(name), callback)
	new key = str_to_num(data)
	
	switch (key)
	{
		case 1: 
		{
			team1_add()
			hns_print(0, "Adding^3 +1 Score^1 for^4 Hiders!");
			set_task(1.0, "chat_score2", id)
			team1_settings(id)
		}
		case 2: 
		{
			team1_remove()
			hns_print(0, "Removing^3 -1 Score^1 for^4 Hiders!");
			set_task(1.0, "chat_score2", id)
			team1_settings(id)
		}
		case 3:
		{
			set_task(0.1, "score_settings", id)
		}
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

public team2_settings(id)
{
	new menu = menu_create("\rAdmin Menu \d- \rSeekers Score Settings", "team2_score_hand");
	
	menu_additem(menu, "\yAdd \w+1 Score for \ySeekers", "1" );
	menu_additem(menu, "\rRemove \w-1 Score for \ySeekers^n^n", "2" );
	
	menu_additem(menu, "\wBack", "3" );
	
	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL)
	menu_display(id, menu)
}

public team2_score_hand(id, menu, item)
{
	if (item == MENU_EXIT)
	{
		menu_destroy(menu)
		return PLUGIN_HANDLED;
	}
	
	new data[6], name[64], acces, callback
	menu_item_getinfo(menu, item, acces, data, charsmax(data), name, charsmax(name), callback)
	new key = str_to_num(data)
	
	switch (key)
	{
		case 1: 
		{
			team2_add()
			hns_print(0, "Adding^3 +1 Score^1 for^4 Seekers!");
			set_task(1.0, "chat_score2", id)
			team2_settings(id)
		}
		case 2: 
		{
			team2_remove()
			hns_print(0, "Removing^3 -1 Score^1 for^4 Seekers!");
			set_task(1.0, "chat_score2", id)
			team2_settings(id)
		}
		case 3: set_task(0.1, "score_settings", id)
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

public team1_add()
{
	if (team1 + team2 < 8) 
		team1 ++;

	else if (team1 + team2 > 8) 
		team2 ++;
		
	else if (team1 + team2 == 8) 
		team2 ++;
		
	else if (team1 + team2 > 16)
		return PLUGIN_CONTINUE;
		
	else if (team1 + team2 == 16)
		return PLUGIN_CONTINUE;

	return PLUGIN_CONTINUE;
}
	
public team2_add()
{
	if (team1 + team2 < 8) 
		team2 ++;
		
	else if (team1 + team2 > 8) 
		team1 ++;
		
	else if (team1 + team2 == 8) 
		team1 ++;
		
	else if (team1 + team2 > 16)
		return PLUGIN_CONTINUE;
		
	else if (team1 + team2 == 16)
		return PLUGIN_CONTINUE;

	return PLUGIN_CONTINUE;
}
	
public team1_remove()
{
	if (team1 + team2 < 8) 
		team1 --;
		
	else if (team1 + team2 > 8) 
		team2 --;
		
	else if (team1 + team2 == 8) 
		team2 --;
		
	else if (team1 + team2 > 16)
		return PLUGIN_CONTINUE;
		
	else if (team1 + team2 == 16)
		return PLUGIN_CONTINUE;

	return PLUGIN_CONTINUE;
}
	
public team2_remove()
{
	if (team1 + team2 < 8) 
		team2 --;
		
	else if (team1 + team2 > 8) 
		team1 --;
		
	else if (team1 + team2 == 8) 
		team1 --;
		
	else if (team1 + team2 > 16)
		return PLUGIN_CONTINUE;
		
	else if (team1 + team2 == 16)
		return PLUGIN_CONTINUE;

	return PLUGIN_CONTINUE;
}

stop_count2()
{
	if( stop_count )
	{
		stop_count = false
		hns_print(0, "The score^3 counting^1 has been^4 PAUSED^1 !");
	}
	else
	{
		stop_count = true
		hns_print(0, "The score^3 counting^1 has been^4 unPAUSED^1 !");
		one()
	}
}



////////////////////////////////////////////////////////////////////////////
//////////////////// CHANGE CVARS FOR SPEC. MAPS ///////////////////////////
////////////////////////////////////////////////////////////////////////////

public CheckMap()
{
	new MapName[32]
	get_mapname(MapName,31)
	
	if(containi(MapName,"awp_rooftops") != -1 || equali(MapName,"tentical"))
	{
		server_cmd("hns_removebreakables 1")
		server_cmd("hns_removedoors 1")
	}
	
	else if(containi(MapName,"de_winter_inferno") != -1 || equali(MapName,"tentical"))
	{
		server_cmd("hns_removebreakables 0")
		server_cmd("hns_removedoors 1")
	}
		
	else if(containi(MapName,"de_inferno") != -1 || equali(MapName,"tentical"))
	{
		server_cmd("hns_removebreakables 0")
		server_cmd("hns_removedoors 1")
	}
	
	else if(containi(MapName,"de_nuke_winter") != -1 || equali(MapName,"tentical"))
	{
		server_cmd("hns_removebreakables 0")
		server_cmd("hns_removedoors 1")
	}
	
	else if(containi(MapName,"de_nuke") != -1 || equali(MapName,"tentical"))
	{
		server_cmd("hns_removebreakables 0")
		server_cmd("hns_removedoors 1")
	}
		
	else if(containi(MapName,"de_piranesi") != -1 || equali(MapName,"tentical"))
	{
		server_cmd("hns_removebreakables 0")
		server_cmd("hns_removedoors 0")
	}
	
	else if(containi(MapName,"de_vertigo") != -1 || equali(MapName,"tentical"))
	{
		server_cmd("hns_removebreakables 0")
		server_cmd("hns_removedoors 0")
	}
	
	else if(containi(MapName,"de_torn") != -1 || equali(MapName,"tentical"))
	{
		server_cmd("hns_removebreakables 0")
		server_cmd("hns_removedoors 0")
	}
	
	else if(containi(MapName,"de_cbble") != -1 || equali(MapName,"tentical"))
	{
		server_cmd("hns_removebreakables 0")
		server_cmd("hns_removedoors 0")
	}
	
	else if(containi(MapName,"de_dust2_xmas_2013") != -1 || equali(MapName,"tentical"))
	{
		server_cmd("hns_removebreakables 0")
		server_cmd("hns_removedoors 0")
	}
	
	else if(containi(MapName,"de_dust2") != -1 || equali(MapName,"tentical"))
	{
		server_cmd("hns_removebreakables 0")
		server_cmd("hns_removedoors 0")
	}
	
	else if(containi(MapName,"de_chateau") != -1 || equali(MapName,"tentical"))
	{
		server_cmd("hns_removebreakables 1")
		server_cmd("hns_removedoors 1")
	}
	
	else if(containi(MapName,"de_airstrip") != -1 || equali(MapName,"tentical"))
	{
		server_cmd("hns_removebreakables 0")
		server_cmd("hns_removedoors 0")
	}
		
	else if(containi(MapName,"cs_assault_snow") != -1 || equali(MapName,"tentical"))
	{
		server_cmd("hns_removebreakables 0")
		server_cmd("hns_removedoors 1")
	}
		
	else if(containi(MapName,"cs_assault") != -1 || equali(MapName,"tentical"))
	{
		server_cmd("hns_removebreakables 1")
		server_cmd("hns_removedoors 0")
	}
		
	else if(containi(MapName,"cs_italyrm_xmas_2012") != -1 || equali(MapName,"tentical"))
	{
		server_cmd("hns_removebreakables 1")
		server_cmd("hns_removedoors 1")
	}
	
	else if(containi(MapName,"hns_mie") != -1 || equali(MapName,"tentical"))
	{
		server_cmd("hns_removebreakables 0")
		server_cmd("hns_removedoors 0")
	}
		
	else if(containi(MapName,"hns_bagdad") != -1 || equali(MapName,"tentical"))
	{
		server_cmd("hns_removebreakables 1")
		server_cmd("hns_removedoors 0")
	}
	
	else if(containi(MapName,"cs_siesta") != -1 || equali(MapName,"tentical"))
	{
		server_cmd("hns_removebreakables 0")
		server_cmd("hns_removedoors 0")
	}
	
	server_cmd("mp_timelimit 25")

	return PLUGIN_CONTINUE
}



////////////////////////////////////////////////////////////////////////////
//////////////////////////// SHOWING SCORE /////////////////////////////////
////////////////////////////////////////////////////////////////////////////

public eventNewRound()
{
	if( get_pcvar_num( hns_enable ))
	{
		if( get_pcvar_num( hns_gather ))
		{
			if (g_draw)
			{
				new total1 = team1 + team11
				new total2 = team2 + team22
				
				if (team11 + team22 < 3)
				{
					set_hudmessage(0, 255, 0, -1.0, 0.31, 0, 5.0, 5.0, 3.0, 3.0, 2);
					show_hudmessage(0, "Total Score: Hiders: %d - %d Seekers^nScore After Draw: Hiders %d - %d Seekers", total1, total2, team11, team22);
		
					hns_print(0, "Total Score:^3 Hiders^4 %d^1 -^4 %d^3 Seekers", total1, total2);
					hns_print(0, "Score After Draw:^3 Hiders^4 %d^1 -^4 %d^3 Seekers", team11, team22);
				}
				if (team11 + team22 == 3)
				{
					set_hudmessage(0, 255, 0, -1.0, 0.31, 0, 5.0, 5.0, 3.0, 3.0, 2);
					show_hudmessage(0, "Total Score: Hiders: %d - %d Seekers^nScore After Draw: Hiders %d - %d Seekers", total2, total1, team22, team11);
				
					hns_print(0, "Total Score:^3 Hiders^4 %d^1 -^4 %d^3 Seekers", total2, total1);
					hns_print(0, "Score After Draw:^3 Hiders^4 %d^1 -^4 %d^3 Seekers", team22, team11);
				}
				if (team22 == 1 && team11 == 2)
				{
					set_hudmessage(0, 255, 0, -1.0, 0.31, 0, 5.0, 5.0, 3.0, 3.0, 2);
					show_hudmessage(0, "Total Score: Hiders: %d - %d Seekers^nScore After Draw: Hiders %d - %d Seekers", total1, total2, team11, team22);
				
					hns_print(0, "Total Score:^3 Hiders^4 %d^1 -^4 %d^3 Seekers", total1, total2);
					hns_print(0, "Score:^3 Hiders^4 2^1 -^4 1^3 Seekers", team11, team22);
				}
				if (team11 + team22 > 3)
				{
					set_hudmessage(0, 255, 0, -1.0, 0.31, 0, 5.0, 5.0, 3.0, 3.0, 2);
					show_hudmessage(0, "Total Score: Hiders: %d - %d Seekers^nScore After Draw: Hiders %d - %d Seekers", total2, total1, team22, team11);
				
					hns_print(0, "Total Score:^3 Hiders^4 %d^1 -^4 %d^3 Seekers", total2, total1);
					hns_print(0, "Score After Draw:^3 Hiders^4 %d^1 -^4 %d^3 Seekers", team22, team11);
				}

				if (team11 + team22 == 6)
				{
					hns_print(0, "Match Over !!!");
					hns_print(0, "Total Score:^3 Hiders^4 %d^1 -^4 %d^3 Seekers", total1, total2);
					hns_print(0, "Score After Draw:^3 Hiders^4 %d^1 -^4 %d^3 Seekers", team22, team11);
					hns_print(0, "Match Over !!!");
					
					for( new i = 1 ; i <= g_Max ; i++ )
					{
						if( !is_user_connected(i) )
							continue;
							
						set_hudmessage(255, 255, 255, -1.0, 0.28, 0, 5.0, 5.0, 3.0, 3.0, 4)
						show_hudmessage(i,"Match Over ");
						
						set_hudmessage(0, 255, 0, -1.0, 0.31, 0, 5.0, 5.0, 3.0, 3.0, 2)
						show_hudmessage(i,"Match Over ");
							
						set_hudmessage(255, 0, 0, -1.0, 0.34, 0, 5.0, 5.0, 3.0, 3.0, 3)
						show_hudmessage(i,"Match Over ");
					}
					hns_print(0, "Soon the^3 Gather^1 mod will be^4 disabled.");
					
					g_draw = false;
					set_task(5.0, "stop_gather")
				}
				
				
				if (team11 + team22 > 6)
				{
					hns_print(0, "Match Over !!!");
					hns_print(0, "Total Score:^3 Hiders^4 %d^1 -^4 %d^3 Seekers", total2, total1);
					hns_print(0, "Score After Draw:^3 Hiders^4 %d^1 -^4 %d^3 Seekers", team22, team11);
					hns_print(0, "Match Over !!!");
					
					for( new i = 1 ; i <= g_Max ; i++ )
					{
						if( !is_user_connected(i) )
							continue;
							
						set_hudmessage(255, 255, 255, -1.0, 0.28, 0, 5.0, 5.0, 3.0, 3.0, 4)
						show_hudmessage(i,"Match Over");
						
						set_hudmessage(0, 255, 0, -1.0, 0.31, 0, 5.0, 5.0, 3.0, 3.0, 2)
						show_hudmessage(i,"Match Over");
							
						set_hudmessage(255, 0, 0, -1.0, 0.34, 0, 5.0, 5.0, 3.0, 3.0, 3)
						show_hudmessage(i,"Match Over");
					}
					hns_print(0, "Soon the^3 Gather^1 mod will be^4 disabled.");
					g_draw = false;
					set_task(5.0, "stop_gather");
				}
				
				
				if (team11 == 4)
				{
					hns_print(0, "Match Over !!!");
					hns_print(0, "Total Score:^3 Hiders^4 %d^1 -^4 %d^3 Seekers", total2, total1);
					hns_print(0, "Score After Draw:^3 Hiders^4 %d^1 -^4 %d^3 Seekers", team22, team11);
					hns_print(0, "Match Over !!!");
					
					for( new i = 1 ; i <= g_Max ; i++ )
					{
						if( !is_user_connected(i) )
							continue;
							
						set_hudmessage(255, 255, 255, -1.0, 0.28, 0, 5.0, 5.0, 3.0, 3.0, 4)
						show_hudmessage(i,"Match Over");
						
						set_hudmessage(0, 255, 0, -1.0, 0.31, 0, 5.0, 5.0, 3.0, 3.0, 2)
						show_hudmessage(i,"Match Over");
							
						set_hudmessage(255, 0, 0, -1.0, 0.34, 0, 5.0, 5.0, 3.0, 3.0, 3)
						show_hudmessage(i,"Match Over");
					}
					hns_print(0, "Soon the^3 Gather^1 mod will be^4 disabled.");
					
					g_draw = false;
					set_task(5.0, "stop_gather");
				}
				
				if (team22 == 4)
				{
					hns_print(0, "Match Over !!!");
					hns_print(0, "Total Score:^3 Hiders^4 %d^1 -^4 %d^3 Seekers", total2, total1);
					hns_print(0, "Score After Draw:^3 Hiders^4 %d^1 -^4 %d^3 Seekers", team22, team11);
					hns_print(0, "Match Over !!!");
					
					for( new i = 1 ; i <= g_Max ; i++ )
					{
						if( !is_user_connected(i) )
							continue;
							
						set_hudmessage(255, 255, 255, -1.0, 0.28, 0, 5.0, 5.0, 3.0, 3.0, 4)
						show_hudmessage(i,"Match Over");
						
						set_hudmessage(0, 255, 0, -1.0, 0.31, 0, 5.0, 5.0, 3.0, 3.0, 2)
						show_hudmessage(i,"Match Over");
							
						set_hudmessage(255, 0, 0, -1.0, 0.34, 0, 5.0, 5.0, 3.0, 3.0, 3)
						show_hudmessage(i,"Match Over");
					}
					hns_print(0, "Soon the^3 Gather^1 mod will be^4 disabled.");
					
					g_draw = false;
					set_task(5.0, "stop_gather");
				}
			}

			else
			{
				if (team11 + team22 == 3)
				{
					return PLUGIN_CONTINUE;
				}
				
				if (team1 + team2 < 8) 
				{
					set_hudmessage(0, 255, 0, -1.0, 0.31, 0, 5.0, 5.0, 3.0, 3.0, 2);
					show_hudmessage(0, "Score^nHiders %d - %d Seekers", team1, team2);
				
					hns_print(0, "Score:^3 Hiders^4 %d^1 -^4 %d^3 Seekers", team1, team2);
				}
				else if (team1 + team2 > 8)
				{
					set_hudmessage(0, 255, 0, -1.0, 0.31, 0, 5.0, 5.0, 3.0, 3.0, 2);
					show_hudmessage(0, "Score^nHiders %d - %d Seekers", team2, team1);
				
					hns_print(0, "Score:^3 Hiders^4 %d^1 -^4 %d^3 Seekers", team2, team1);
				}
				
				if (team1 + team2 == 16)
				{
					hns_print(0, "Score:^3 Hiders^4 %d^1 -^4 %d^3 Seekers", team2, team1);
				}

				else if (team1 + team2 > 16)
				{
					hns_print(0, "Match Over !!!");
					hns_print(0, "Score:^3 Hiders^4 %d^1 -^4 %d^3 Seekers", team2, team1);
					
					hns_print(0, "Soon the^3 Gather^1 mod will be^4 disabled.");
					
					set_task(5.0, "stop_gather");
				}
				
				if (team1 == 9) 
				{
					hns_print(0, "Match Over !!!");
					hns_print(0, "Score:^3 Hiders^4 %d^1 -^4 %d^3 Seekers", team2, team1);
					
					for( new i = 1 ; i <= g_Max ; i++ )
					{
						if( !is_user_connected(i) )
							continue;
							
						set_hudmessage(255, 255, 255, -1.0, 0.28, 0, 5.0, 5.0, 3.0, 3.0, 4)
						show_hudmessage(i,"Match Over");
						
						set_hudmessage(0, 255, 0, -1.0, 0.31, 0, 5.0, 5.0, 3.0, 3.0, 2)
						show_hudmessage(i,"Match Over");
							
						set_hudmessage(255, 0, 0, -1.0, 0.34, 0, 5.0, 5.0, 3.0, 3.0, 3)
						show_hudmessage(i,"Match Over");
					}
					hns_print(0, "Soon the^3 Gather^1 mod will be^4 disabled.");
					
					set_task(5.0, "stop_gather");
				}
				else if (team1 > 9) 
				{
					hns_print(0, "Match Over !!!");
					hns_print(0, "Score:^3 Hiders^4 %d^1 -^4 %d^3 Seekers", team2, team1);
					
					for( new i = 1 ; i <= g_Max ; i++ )
					{
						if( !is_user_connected(i) )
							continue;
							
						set_hudmessage(255, 255, 255, -1.0, 0.28, 0, 5.0, 5.0, 3.0, 3.0, 4)
						show_hudmessage(i,"Match Over");
						
						set_hudmessage(0, 255, 0, -1.0, 0.31, 0, 5.0, 5.0, 3.0, 3.0, 2)
						show_hudmessage(i,"Match Over");
							
						set_hudmessage(255, 0, 0, -1.0, 0.34, 0, 5.0, 5.0, 3.0, 3.0, 3)
						show_hudmessage(i,"Match Over");
					}
					hns_print(0, "Soon the^3 Gather^1 mod will be^4 disabled.");
					
					set_task(5.0, "stop_gather");
				}
				else if (team2 == 9) 
				{
					hns_print(0, "Match Over !!!");
					hns_print(0, "Score:^3 Hiders^4 %d^1 -^4 %d^3 Seekers", team2, team1);
					
					for( new i = 1 ; i <= g_Max ; i++ )
					{
						if( !is_user_connected(i) )
							continue;
							
						set_hudmessage(255, 255, 255, -1.0, 0.28, 0, 5.0, 5.0, 3.0, 3.0, 4)
						show_hudmessage(i,"Match Over");
						
						set_hudmessage(0, 255, 0, -1.0, 0.31, 0, 5.0, 5.0, 3.0, 3.0, 2)
						show_hudmessage(i,"Match Over");
							
						set_hudmessage(255, 0, 0, -1.0, 0.34, 0, 5.0, 5.0, 3.0, 3.0, 3)
						show_hudmessage(i,"Match Over");
					}
					hns_print(0, "Soon the^3 Gather^1 mod will be^4 disabled.");
					
					set_task(5.0, "stop_gather");
				}
				else if (team2 > 9) 
				{
					hns_print(0, "Match Over !!!");
					hns_print(0, "Score:^3 Hiders^4 %d^1 -^4 %d^3 Seekers", team2, team1);
					
					for( new i = 1 ; i <= g_Max ; i++ )
					{
						if( !is_user_connected(i) )
							continue;
							
						set_hudmessage(255, 255, 255, -1.0, 0.28, 0, 5.0, 5.0, 3.0, 3.0, 4)
						show_hudmessage(i,"Match Over");
						
						set_hudmessage(0, 255, 0, -1.0, 0.31, 0, 5.0, 5.0, 3.0, 3.0, 2)
						show_hudmessage(i,"Match Over");
							
						set_hudmessage(255, 0, 0, -1.0, 0.34, 0, 5.0, 5.0, 3.0, 3.0, 3)
						show_hudmessage(i,"Match Over");
					}
					hns_print(0, "Soon the^3 Gather^1 mod will be^4 disabled.");
					
					set_task(5.0, "stop_gather");
				}
				
				if (team1 == 8 && team2 == 8) 
				{
					hns_print(0, "After^3 Second Half^1 the match is^4 DRAW^1 !");
					hns_print(0, "Now we will play^3 more^4 3^1 rounds like^3 Hiders^1 and^4 Seekers^1 !");
					hns_print(0, "Score:^3 Hiders^4 %d^1 -^4 %d^3 Seekers", team2, team1);
					
					tree();
					set_task(10.0, "res");
					hns_print(0, "Round will be restarted after^3 10^1 seconds !");
					
					g_draw = true;
				}
			}
		}
		
	}
	
	return PLUGIN_CONTINUE;
}



////////////////////////////////////////////////////////////////////////////
//////////////////////////// GIVING SCORE //////////////////////////////////
////////////////////////////////////////////////////////////////////////////

public message_textmsg(msg_id, dest, id)
{
	static sMessage[16];
	get_msg_arg_string( 2, sMessage, sizeof  sMessage - 1 );

	if(hns_gather)
	{
		if( ( sMessage[1] == 'T' && sMessage[12] == 'W' ) || ( sMessage[1] == 'T' && sMessage[8]  == 'B' ) || ( sMessage[1] == 'H' && sMessage[14] == 'R' ) )
		{
			if( stop_count )
			{
				if(g_draw)
				{
					if (team11 + team22 < 3)
						team11 ++;
						
					else if(team11 + team22 > 3)
						team22 ++;
						
					else if(team11 + team22 == 3)
						team22 ++;
						
					else if(team11 + team22 > 6)
						return PLUGIN_CONTINUE;
						
					else if(team11 + team22 == 6)
						return PLUGIN_CONTINUE;
				}
				else
				{
					if (team1 + team2 < 8) 
						team1 ++;
						
					else if (team1 + team2 > 8) 
						team2 ++;
						
					else if (team1 + team2 == 8) 
						team2 ++;
						
					else if (team1 + team2 > 16)
						return PLUGIN_CONTINUE;
						
					else if (team1 + team2 == 16)
						return PLUGIN_CONTINUE;
				}
			}
		}
		
		if( equal( sMessage, "#CTs_Win" ) )
		{
			if( stop_count )
			{
				if(g_draw)
				{
					if (team11 + team22 < 3)
						team22 ++;
						
					else if(team11 + team22 > 3)
						team11 ++;
						
					else if(team11 + team22 == 3)
						team11 ++;
						
					else if(team11 + team22 > 6)
						return PLUGIN_CONTINUE;
						
					else if(team11 + team22 == 6)
						return PLUGIN_CONTINUE;
				}
				else
				{
					if (team1 + team2 < 8) 
						team2 ++;
						
					else if (team1 + team2 > 8) 
						team1 ++;
						
					else if (team1 + team2 == 8) 
						team1 ++;
						
					else if (team1 + team2 > 16)
						return PLUGIN_CONTINUE;
						
					else if (team1 + team2 == 16)
						return PLUGIN_CONTINUE;
				}
			}
		}
	}
	return PLUGIN_HANDLED;
}




////////////////////////////////////////////////////////////////////////////
//////////////////////////// VOTE Funcs ////////////////////////////////////
////////////////////////////////////////////////////////////////////////////

public Team_Win_New()
{
	static szTeam[10]
	read_logargv(1, szTeam, 9)
	
	if(g_knife) 
	{
		if(szTeam[0] == 'T')
		{
			new players[32], playerCount, player
			get_players(players, playerCount, "ce", "TERRORIST")

			for(new i=0; i<playerCount; i++)
			{
				player = players[i]        
				StartVote( player )
			}
		}
		else
		{
			new players2[32], playerCount2, player_ct
			get_players(players2, playerCount2, "ce", "CT")

			for(new i=0; i<playerCount2; i++)
			{
				player_ct = players2[i]        
				StartVote( player_ct )
			}
		}
	}
}



/////////////////////////////////////////////////////////////////
/////////////////////////// Side Vote ///////////////////////////
/////////////////////////////////////////////////////////////////

public StartVote( id )
{
	if ( gVoting )
	{
		hns_print( id, "There is already a vote going." );
		return PLUGIN_HANDLED;
	}

	gVotes[0] = gVotes[1] = 0;

	gVoteMenu = menu_create( "\rChoose side:", "menu_handler" );

	menu_additem( gVoteMenu, "I want to stay", "", 0 );
	menu_additem( gVoteMenu, "I want to change our teams", "", 0 );
	
	menu_setprop(gVoteMenu,MPROP_EXIT,MEXIT_NEVER)  

	menu_display( id, gVoteMenu, 0 );
	gVoting++;

	set_task(10.0, "EndVote" );

	return PLUGIN_HANDLED;
}
 
public menu_handler( id, menu, item )
{
	gVotes[ item ]++;

	return PLUGIN_HANDLED;
}

public EndVote(id)
{
	if ( gVotes[0] > gVotes[1] )
		hns_print(0, "^3Winners said:^1 We want to stay at this team !^4 [%d votes]", gVotes[0] );

	else if ( gVotes[0] < gVotes[1] )
	{
		hns_print(0, "^3Winners said:^1 We want to change our teams !^4 [%d vota]", gVotes[1] );
		tree();
	}
	else
		hns_print(0, "^4Vote Failed !", gVotes[0] );
	
	six(id); //spirame knife
	g_voted = true;
	Start_AA_Vote( id ); // puskame vot za aa [ za vsichki ]

	menu_destroy( gVoteMenu );

	gVoting = 0;
}



/////////////////////////////////////////////////////////////////
////////////////////// Airaccelerate Vote ///////////////////////
/////////////////////////////////////////////////////////////////
public Start_AA_Vote( id )
{
	if ( g_AA_Voting )
	{
		hns_print( id, "There is already a vote going." );
		return PLUGIN_HANDLED;
	}

	g_AA_Votes[0] = g_AA_Votes[1] = 0;

	g_AA_VoteMenu = menu_create( "\rChoose Airaccelerate:", "menu_AA_handler" );

	menu_additem( g_AA_VoteMenu, "10 Airaccelerate", "", 0 );
	menu_additem( g_AA_VoteMenu, "100 Airaccelerate", "", 0 );
	
	menu_setprop(g_AA_VoteMenu,MPROP_EXIT,MEXIT_NEVER)  
	
	new players[32], pnum, tempid;
	get_players( players, pnum );

	for ( new i; i < pnum; i++ )
	{
		tempid = players[i];

		menu_display( tempid, g_AA_VoteMenu, 0 );

		g_AA_Voting++;
	}

	set_task(10.0, "End_AA_Vote" );

	return PLUGIN_HANDLED;
}
 
public menu_AA_handler( id, menu, item )
{
	/*
	if(is_user_bot(id))
		return PLUGIN_HANDLED;
	// shtoto testvam s botove i vadi greshka tuk !
	*/

	g_AA_Votes[ item ]++;
	
	new data[6], access, callback
	menu_item_getinfo(menu, item, access, data, 5, "", 0, callback)
	new key = str_to_num(data)
	
	if(g_AA_Votes[ key ] == 1)
		hns_print(id, "You voted for^3 10^4 Airaccelerate");
	else if(g_AA_Votes[ key ] == 0)
		hns_print(id, "You voted for^3 100^4 Airaccelerate");

	return PLUGIN_HANDLED;
}

public End_AA_Vote(id)
{
	if ( g_AA_Votes[0] > g_AA_Votes[1] )
	{
		hns_print(0, "We will play^3 10^4 airaccelerate^1 !^4 [%d votes]", g_AA_Votes[0] );
		server_cmd( "sv_airaccelerate 10" );
	}
	else if ( g_AA_Votes[0] < g_AA_Votes[1] )
	{
		hns_print(0, "We will play^3 100^4 airaccelerate^1 !^4 [%d votes]", g_AA_Votes[1] );
		server_cmd( "sv_airaccelerate 100" );
	}
	else
		hns_print(0, "Vote Failed", g_AA_Votes[0] );

	menu_destroy( g_AA_VoteMenu );
	
	if(g_voted)
	{
		hns_print(0, "The match will^3 Start^1 soon !");
		set_task(12.0, "start_match");
		
		g_voted = false;
	}

	g_AA_Voting = 0;
}

public start_match()
{
	four(); // puskame gathera
	two(); // reskame 3 puti i puskame GO
}















////////////////////////////////////////////////////////////////////////////
////////////////////////////// CHAT Messages ///////////////////////////////
////////////////////////////////////////////////////////////////////////////

make_SayText(receiver, sender, sMessage[])
{
	if( !sender )
		return 0;
	
	message_begin(receiver ? MSG_ONE : MSG_ALL, SayText, {0, 0, 0}, receiver);
	write_byte(sender);
	write_string(sMessage);
	message_end();
	
	return 1;
}

hns_print(plr, const sFormat[], any:...)
{
	static i; i = plr ? plr : get_player();
	if( !i )
	{
		return 0;
	}
	
	new sPrefix[16];
	get_pcvar_string(hns_prefix, sPrefix, 15);
	
	new sMessage[256];
	new len = formatex(sMessage, 255, "^x04%s^x01 ", sPrefix);
	vformat(sMessage[len], 255-len, sFormat, 3);
	sMessage[192] = '^0';
	
	make_SayText(plr, i, sMessage);
	
	return 1;
}

get_player()
{
	for( new plr = 1; plr <= g_Max; plr++ )
	{
		if( g_bConnected[plr] )
			return plr;
	}
	
	return 0;
}



////////////////////////////////////////////////////////////////////////////
//////////////////////////// CHAT Funcs ////////////////////////////////////
////////////////////////////////////////////////////////////////////////////

public HandleSay(id) 
{
	new arg[192], szName[32], target[32]
	static argv[36]
	
	read_args(arg, charsmax(arg))
	read_argv(1, argv, charsmax(argv))
	get_user_name(id, szName, charsmax(szName))
	parse(argv, argv, charsmax(argv), target, charsmax(target))
	
	replace_all( arg, charsmax( arg ), "%s", "" );
	
	remove_quotes(arg)

	if(arg[0] == '@' || equal(arg, "/fps") || equal(arg, "") || equal(arg, " ") || equal(arg, "/hideknife") ) // Ignores Admin Hud Messages, Admin Slash commands
		return PLUGIN_CONTINUE
	
	remove_quotes(arg)
	
	new SzAlive = is_user_alive(id)
	new CsTeams:team = cs_get_user_team(id);
	
	if(is_valid_msg(arg)) 
	{
		if(get_user_flags(id) & ADMIN_PASSWORD)
		{
			if( team == CS_TEAM_CT )
				(SzAlive ? format(arg, charsmax(arg), "^4[Seekers]^3 %s: ^4%s", szName, arg) : format(arg, charsmax(arg), "^4[Seekers]^1 *DEAD*^3 %s: ^4%s", szName, arg))
			else if( team == CS_TEAM_T )
				(SzAlive ? format(arg, charsmax(arg), "^4[Hiders]^3 %s: ^4%s", szName, arg) : format(arg, charsmax(arg), "^4[Hiders]^1 *DEAD*^3 %s: ^4%s", szName, arg))
			else
				(SzAlive ? format(arg, charsmax(arg), "^4[SPEC]^3 %s: ^4%s", szName, arg) : format(arg, charsmax(arg), "^4[SPEC]^1 *DEAD*^3 %s: ^4%s", szName, arg))
		}
		else
		{
			if( team == CS_TEAM_CT )
				(SzAlive ? format(arg, charsmax(arg), "^4[Seekers]^3 %s: ^1%s", szName, arg) : format(arg, charsmax(arg), "^4[Seekers]^1 *DEAD*^3 %s: ^1%s", szName, arg))
			else if( team == CS_TEAM_T )
				(SzAlive ? format(arg, charsmax(arg), "^4[Hiders]^3 %s: ^1%s", szName, arg) : format(arg, charsmax(arg), "^4[Hiders]^1 *DEAD*^3 %s: ^1%s", szName, arg))
			else
				(SzAlive ? format(arg, charsmax(arg), "^4[SPEC]^3 %s: ^1%s", szName, arg) : format(arg, charsmax(arg), "^4[SPEC]^1 *DEAD*^3 %s: ^1%s", szName, arg))
		}
	}
	
	for(new i = 1; i <= g_Max; i++) 
	{
			if(!is_user_connected(i)) 
				continue
			
			message_begin(MSG_ONE, SayText, {0, 0, 0}, i)
			write_byte(id)
			write_string(arg)
			message_end()
	}
	return PLUGIN_CONTINUE;
}

bool:is_valid_msg(const arg[]) 
{
	if( arg[0] == '@' || !strlen(arg))  return false
	return true
}

public HandleSayTeam(id) 
{
	new arg[192], szName[32]
	
	read_args(arg, charsmax(arg))
	get_user_name(id, szName, charsmax(szName))
	
	remove_quotes(arg)
	
	replace_all( arg, charsmax( arg ), "%s", "" );
	
	new SzAlive = is_user_alive(id)
	new CsTeams:team = cs_get_user_team(id);
	
	new playerTeam = get_user_team(id)
	new playerTeamName[19]

	switch(playerTeam) // Team names which appear on team-only messages
	{
		case 1:
			copy(playerTeamName, 11, "Team Chat")

		case 2:
			copy(playerTeamName, 18, "Team Chat")

		default:
			copy(playerTeamName, 9, "Team Chat")
	}
	
	if(is_valid_msg(arg)) 
	{
		if(get_user_flags(id) & ADMIN_PASSWORD)
		{
			if( team == CS_TEAM_CT )
				(SzAlive ? format(arg, charsmax(arg), "^1[%s] ^4[Seekers]^3 %s: ^4%s", playerTeamName, szName, arg) : format(arg, charsmax(arg), "^1[%s] ^4[Seekers]^1 *DEAD*^3 %s: ^4%s", playerTeamName, szName, arg))
			else if( team == CS_TEAM_T )
				(SzAlive ? format(arg, charsmax(arg), "^1[%s] ^4[Hiders]^3 %s: ^4%s", playerTeamName, szName, arg) : format(arg, charsmax(arg), "^1[%s] ^4[Hiders]^1 *DEAD*^3 %s: ^4%s", playerTeamName, szName, arg))
			else
				(SzAlive ? format(arg, charsmax(arg), "^1[%s] ^4[SPEC]^3 %s: ^4%s", playerTeamName, szName, arg) : format(arg, charsmax(arg), "^1[%s] ^4[SPEC]^1 *DEAD*^3 %s: ^4%s", playerTeamName, szName, arg))
		}
		else
		{
			if( team == CS_TEAM_CT )
				(SzAlive ? format(arg, charsmax(arg), "^1[%s] ^4[Seekers]^3 %s: ^1%s", playerTeamName, szName, arg) : format(arg, charsmax(arg), "^1[%s] ^4[Seekers]^1 *DEAD*^3 %s: ^1%s", playerTeamName, szName, arg))
			else if( team == CS_TEAM_T )
				(SzAlive ? format(arg, charsmax(arg), "^1[%s] ^4[Hiders]^3 %s: ^1%s", playerTeamName, szName, arg) : format(arg, charsmax(arg), "^1[%s] ^4[Hiders]^1 *DEAD*^3 %s: ^1%s", playerTeamName, szName, arg))
			else
				(SzAlive ? format(arg, charsmax(arg), "^1[%s] ^4[SPEC]^3 %s: ^1%s", playerTeamName, szName, arg) : format(arg, charsmax(arg), "^1[%s] ^4[SPEC]^1 *DEAD*^3 %s: ^1%s", playerTeamName, szName, arg))
		}
	}
	
	for(new i = 1; i <= g_Max; i++) 
	{
		if(!is_user_connected(i)) 
			continue

		if(get_user_team(i) == playerTeam)
		{
			message_begin(MSG_ONE, SayText, {0, 0, 0}, i)
			write_byte(id)
			write_string(arg)
			message_end()
		}
	}
	return PLUGIN_CONTINUE;
}

public MsgDuplicate(id) return PLUGIN_HANDLED



////////////////////////////////////////////////////////////////////////////
////////////////////////// HideKnife Funcs /////////////////////////////////
////////////////////////////////////////////////////////////////////////////

public hideknife(plr) //Toggle
{
	g_bHasHideKnife[plr] = !g_bHasHideKnife[plr];
	
	
	if(cs_get_user_team(plr) == CS_TEAM_T)
		hns_print(plr, "Your knife visibility now is^x03 %s.^x01 To^x03 %s,^x01 type^x04 /hideknife^x01 in chat.", g_bHasHideKnife[plr] ? "enabled" : "disabled", g_bHasHideKnife[plr] ? "disable" : "enable");
	else if( cs_get_user_team(plr) == CS_TEAM_CT)
		hns_print(plr, "You can see the knife only like Hider.");
		
		
	if( g_bAlive[plr] && cs_get_user_team(plr) == CS_TEAM_T && get_user_weapon(plr) == CSW_KNIFE )
	{
		if( g_bHasHideKnife[plr] )
		{
			set_pev(plr, pev_viewmodel2, g_sBlank);
			set_pev(plr, pev_weaponmodel2, g_sBlank);
		}
		else
		{
			set_pev(plr, pev_viewmodel2, g_sKnifeModel_v);
			set_pev(plr, pev_weaponmodel2, g_sKnifeModel_p);
		}
	}
	
	return PLUGIN_CONTINUE;
}

public fwdEmitSound(iEntity, iChannel, const sSample[], Float:fVolume, Float:fAttenuation, iFlags, iPitch) //Block sound
{
	if( 1 <= iEntity <= 32 && g_bHasHideKnife[iEntity] && cs_get_user_team(iEntity) == CS_TEAM_T && sSample[0] == 'w' && equali(sSample, "weapons/knife_deploy1.wav") )
		return FMRES_SUPERCEDE;
	
	return FMRES_IGNORED;
}






////////////////////////////////////////////////////////////////////////////
//////////////////////// Part of Semiclip Funcs ////////////////////////////
////////////////////////////////////////////////////////////////////////////

public FwdPostThink( id ) 
{	
	if( !get_pcvar_num( hns_boost ))
	{
		static i;
		for( i = 1; i < g_Max; i++ )
		{
			if( g_bRestore[i] )
			{
				set_pev( i, pev_solid, SOLID_SLIDEBOX );
				g_bRestore[i] = false;
			}
		}
	}
}

public FwdFullPackPost( es, e, ent, host, hostflags, player, set )
{
	if( !player || get_pcvar_num( hns_boost ) )
		return FMRES_IGNORED;

	if( g_bSolid[host] && g_bSolid[ent] && g_iTeam[host] == g_iTeam[ent] )
	{
		static iAlpha;
		iAlpha = 255;

		set_es( es, ES_Solid, SOLID_NOT );
		set_es( es, ES_RenderMode, kRenderTransAlpha );
		set_es( es, ES_RenderAmt, iAlpha );
	}
		
	return FMRES_IGNORED;	
}