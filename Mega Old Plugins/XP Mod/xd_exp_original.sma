#define USING_CS

#include <amxmodx> 
#include <amxmisc> 
#include <nvault> 
#include <engine>
#include <fun>
#include <cstrike>
#include <fakemeta>
#include <colorchat>
#include <core>
#include <sqlx>
#include <hamsandwich>
#include <regex>
#include <hlsdk_const>

#if defined USING_CS
#include <cstrike>
#endif

// JUMPING
#define MINIMUM_FALL_SPEED 300
#define MAXIMUM_DAMAGE_FROM_JUMP 300.0

//STANDING
#define DAMAGE 99.0
#define DELAY 0.5

#define PLUGIN "xD eXperience Mod"
#define VERSION "2.0"
#define AUTHOR "xD-GaminG 2"

new amx_headsplash;
new Float:falling_speed[33];
new Float:damage_after[33][33];
new sprite_blood;
new sprite_bloodspray;
//new gmsgStatusText;

new const LEVELS[15] = {   
	200,         // 1 level
	250,         // 2 level
	330,         // 3 level
	550,      // 4 level
	1035,      // 5 level
	2100,      // 6 level
	2650,      // 7 level
	3300,      // 8 level
	4510,   // 9 level
	5790,// 10 level
	6795,// 11 level
	7880,// 12 level
	10000,// 13 level
	13500,//14 level
	17999 // 15 level
}; 

new PlayerXP[33], PlayerLevel[33], punkty[33], punktyhp[33], punktyarm[33], punktyrespawn[33], rank[33][32], punktysk1[33], punktysk2[33], punktysk3[33], skille[33], bronie[33], punktywzmoc[33], punktygranat[33], punktychodzenie[33], punktypistolety[33], punktykarabiny[33], punktyzestaw[33];
new gCvar_Kill, gCvar_HS, gCvar_Enable, g_Vault; 
new starthealth, startarmor;

new bool:uzyl[33]; 

public plugin_init() { 
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	//Eventy - LogEventy
	register_event("DeathMsg", "eDeath", "a"); 
	register_event("HLTV", "NewRound", "a", "1=0", "2=0");
	//register_event("ResetHUD", "resetModel", "b");
	register_logevent("EventRoundStart",2,"1=Round_Start");
	register_logevent("EventRoundEnd", 2, "1=Round_End");
	
	//Cvar
	gCvar_Enable    = register_cvar("xd_save", "1"); 
	gCvar_Kill    = register_cvar("xd_kill", "30"); 
	gCvar_HS    = register_cvar("xd_hs", "40"); 
	g_Vault        = nvault_open("exm_hns"); 
	
	register_concmd("xd_removexp", "cmd_take_exp", ADMIN_IMMUNITY, "<target> <amount>");  
	register_concmd("xd_addxp", "cmd_give_exp", ADMIN_IMMUNITY, "<target> <amount>"); 
	register_concmd("xd_removeptk", "cmd_take_ptk", ADMIN_IMMUNITY, "<target> <amount>");  
	register_concmd("xd_addptk", "cmd_give_ptk", ADMIN_IMMUNITY, "<target> <amount>"); 
	
	register_clcmd("say /menu", "menu_xp");  		// menu
	register_clcmd("say_team /menu", "menu_xp"); 		// menu
	register_clcmd("say /info", "gracze_info");  		// info
	register_clcmd("say_team /info", "gracze_info");  	// info
	register_clcmd("say /xphelp", "pomoc_noob");  		// skill 3
	register_clcmd("say_team /xphelp", "pomoc_noob");  	// skill 3
	register_clcmd("say /reset", "reset_napewno");  		// menu
	register_clcmd("say_team /reset", "reset_napewno"); 	// menu
	register_clcmd("say /xp", "xp_menu");  			// menu
	register_clcmd("say_team /xp", "xp_menu"); 		// menu
	register_clcmd("say /exp", "xp_menu");  			// menu
	register_clcmd("say_team /exp", "xp_menu"); 		// menu
	register_clcmd("say /vip", "dodatki_menu");  		// menu
	register_clcmd("say_team /vip", "dodatki_menu"); 	// menu
	
	// noob?
	//gmsgStatusText = get_user_msgid("StatusText");
	

	RegisterHam(Ham_TraceAttack, "player", "fw_traceattack");
	
	//Taski
	set_task(0.8, "UpdateHUD",0,"",0,"b");
	
	for (new id=0; id < 32; id++)
	{
		set_task(0.8, "rank_rangi",id,"",0,"b");
	}
	
	//HeadSplash
	amx_headsplash = register_cvar("xd_headsplash", "1"); // Register the on/off cvar.
	register_forward(FM_Touch, "forward_touch"); // Register the "touch" forward.
	register_forward(FM_PlayerPreThink, "forward_PlayerPreThink"); // TY Alka!
} 
public plugin_precache() {
	precache_model("models/player/vip/vip.mdl");
	precache_model("models/player/vip/vip.mdl");
	sprite_blood = precache_model("sprites/blood.spr");
	sprite_bloodspray = precache_model("sprites/bloodspray.spr");
	
	return PLUGIN_CONTINUE;
}

public resetModel(id, level, cid) {
	if (get_user_flags(id) & ADMIN_RESERVATION) {
		new CsTeams:userTeam = cs_get_user_team(id);
		if (userTeam == CS_TEAM_T) {
			cs_set_user_model(id, "xd_vip_tt");
		}
		else if(userTeam == CS_TEAM_CT) {
			cs_set_user_model(id, "xd_vip_ct");
		}
		else {
			cs_reset_user_model(id)
		}
	}
	
	return PLUGIN_CONTINUE;
}

public fw_traceattack(victim, attacker, Float:damage, Float:direction[3], ptr, bits)
{
	//victim
	//attacker
	//damage
	if(punktywzmoc[victim] >= 1)
	{
		SetHamParamFloat(3, damage / (0.3 * punktywzmoc[victim]) );
	}
	else if(punktywzmoc[attacker] >= 1)
	{
		SetHamParamFloat(3, damage * (0.4 * punktywzmoc[attacker]) );
	}
} 
public dodatki_menu(id)
{
	new msg0[128]
	format(msg0,127,"\w[\rxD eXperience Mod\w]\y Menu:");
	new dodatki_menu = menu_create(msg0, "dodatki_menu_wybierz")
	new msg1[128]
	format(msg1,127,"\wHow to \rbuy \yVIP \yAccess \w[EN]")
	menu_additem(dodatki_menu  , msg1, "1", 0)
	new msg2[128]
	format(msg2,127,"\wKak da \rkupite \yVIP \yAccess \w[BG]")
	menu_additem(dodatki_menu  , msg2, "2", 0)
	new msg3[128]
	format(msg3,127,"\wAdmin \rAwards \w| \rNagradi \w[BG]")
	menu_additem(dodatki_menu  , msg3, "3", 0)
	menu_setprop(dodatki_menu,MPROP_EXITNAME,"\yExit");
	
	
	menu_setprop(dodatki_menu,MPROP_PERPAGE,0);
	
	
	menu_display(id, dodatki_menu, 0)
}
public dodatki_menu_wybierz(id, dodatki_menu  , item)
{
	new data[6], iName[64]
	new acces, callback
	menu_item_getinfo(dodatki_menu, item, acces, data,5, iName, 63, callback)
	
	new klawisz = str_to_num(data)
	
	switch(klawisz)
	{ 
		case 1 : {
			show_motd (id,"vip_info_1.txt","VIP ACCESS [EN]");
		}
		case 2 : {
			show_motd (id,"vip_info_2.txt","VIP PRAVA [BG]")
		}
		case 3 : {
			show_motd (id,"vip_info_3.txt","Admin Nagradi || Award's   [BG]")
		}
		
	}
	return PLUGIN_CONTINUE;
}
// reset_napewno?
public xp_menu(id)
{
	new msg0[128]
	format(msg0,127,"\d[\yxD eXperience Mod\d]\w Menu");
	new xp_menu = menu_create(msg0, "xp_menu_wybierz")
	new msg1[128]
	format(msg1,127,"\yHead \rAward \yMenu")
	menu_additem(xp_menu  , msg1, "1", 0)
	new msg2[128]
	format(msg2,127,"\yReset \wyour \rRank \wand \rLevel \d[XP]^n")
	menu_additem(xp_menu  , msg2, "2", 0)
	new msg3[128]
	format(msg3,127,"\wPlayer Information")
	menu_additem(xp_menu  , msg3, "3", 0)
	new msg4[128]
	format(msg4,127,"\rVIP \yInformation")
	menu_additem(xp_menu  , msg4, "4", 0)
	new msg5[128]
	format(msg5,127,"\yGold \rVIP \wAccess^n")
	menu_additem(xp_menu  , msg5, "5", 0)
	new msg6[128]
	format(msg6,127,"\wChat \dInformation \rCommands")
	menu_additem(xp_menu  , msg6, "6", 0)
	new msg7[128]
	format(msg7,127,"\yVisit \wsite: \rhttp://xD-GaminG.info^n")
	menu_additem(xp_menu  , msg7, "7", 0)
	new msg8[128]
	format(msg8,127,"\yDisconnect \dserver \r[leave]")
	menu_additem(xp_menu  , msg8, "8", 0)
	new msg9[128]
	format(msg9,127,"\yStop \dplay \r[quit]^n")
	menu_additem(xp_menu  , msg9, "9", 0)
	new msg10[128]
	format(msg10,127,"\wExit")
	menu_additem(xp_menu  , msg10, "0", 0)
	menu_setprop(xp_menu,MPROP_EXIT,MEXIT_NEVER);
	
	menu_setprop(xp_menu,MPROP_PERPAGE,0);
	
	
	
	menu_display(id, xp_menu, 0)
}
public xp_menu_wybierz(id, xp_menu  , item)
{
	new data[6], iName[64]
	new acces, callback
	menu_item_getinfo(xp_menu, item, acces, data,5, iName, 63, callback)
	
	new klawisz = str_to_num(data)
	
	switch(klawisz)
	{ 
		case 1 : {
			menu_xp(id);
		}
		case 2 : {
			reset_napewno(id);
		}
		case 3 : {
			gracze_info(id);
		}
		case 4 : {
			dodatki_menu(id);
		}
		case 5 : {
			show_motd (id,"gold_vip.txt","Gold VIP")
		}
		case 6 : {
			ColorChat(id, RED, "^x01*^x04 Commands:^x03 /xp^x01,^x03 /exp^x01,^x03 /menu^x01,^x03 /xphelp^x01,^x03 /vip^x01,^x03 /info^x01 and^x04 more" );
		}
		case 7 : {
			ColorChat(id, RED, "^x01*^x04Web^x03 Site^x01 : http://^x03xD^x01-^x04GaminG^x01.^x03info" );
		}
		case 8: {
			client_cmd(id,"disconnect")
		}
		case 9 : {
			client_cmd(id,"quit")
		}
		
	}
	return PLUGIN_CONTINUE;
}
// reset_napewno?
public reset_napewno(id)
{
	new msg0[128]
	format(msg0,127,"\yRealy ??");
	new menu_reset = menu_create(msg0, "reset_wybierz")
	new msg1[128]
	format(msg1,127,"\wYes \d(Do you want realy reset \yRank\d and \yLevel\d ?)")
	menu_additem(menu_reset , msg1, "1", 0)
	new msg2[128]
	format(msg2,127,"\yNo")
	menu_additem(menu_reset , msg2, "2", 0)
	
	menu_setprop(menu_reset,MPROP_EXIT,MEXIT_NEVER);
	
	menu_setprop(menu_reset,MPROP_PERPAGE,0);
	
	
	menu_display(id, menu_reset, 0)
}
public reset_wybierz(id, menu_reset , item)
{
	new data[6], iName[64]
	new acces, callback
	menu_item_getinfo(menu_reset, item, acces, data,5, iName, 63, callback)
	
	new klawisz = str_to_num(data)
	
	switch(klawisz)
	{ 
		case 1 : {
			reset_punkty(id);
			ColorChat(id, TEAM_COLOR, "^x04**^x01 Reset^x03 successfully!");
			ColorChat(id, GREEN, "*^x01 You need^x03 %d", PlayerLevel[id]);
		}
		case 2 : {
			
			}
		
	}
	return PLUGIN_CONTINUE;
}
public reset_punkty(id) {
	
	punkty[id] = PlayerLevel[id];
	punktyhp[id] = 0;
	punktyarm[id] = 0;
	punktyrespawn[id] = 0;
	punktysk1[id] = 0;
	punktysk2[id] = 0;
	punktysk3[id] = 0;
	skille[id] = 0;
	bronie[id] = 0;
	punktywzmoc[id] = 0;
	punktychodzenie[id] = 0;
	punktygranat[id] = 0;
	punktypistolety[id] = 0;
	punktykarabiny[id] = 0;
	punktyzestaw[id] = 0;
	
	if(get_pcvar_num(gCvar_Enable) == 1) 
		SaveData(id);
}

public pomoc_noob(id) {
	if (is_user_connected(id) )
	{
		new name[32];
		get_user_name( id, name, 31);
		ColorChat(id, GREEN, "[xD eXperience Mod]^x01 Hello^x03 %s^x01, this server using^x03 xD eXperience Mod^x04 (EXP) %s^x01 by^x03 xD-GaminG^x01.", name,VERSION);
		ColorChat(id, GREEN, "[xD eXperience Mod]^x01 Commands: ^x03 /xp^x01, ^x03 /vip^x01, ^x03 /xphelp^x01, ^x03 /menu^x01 and^x03 more^x01." );
	}
}

public eDeath() { 
	
	new attacker = read_data( 1 ); 
	new victim = read_data( 2 );      
	new headshot = read_data( 3 ); 
	
	if(get_user_team(attacker) != get_user_team(victim) && attacker != 0) {
		
		if (get_user_flags(attacker) & ADMIN_RESERVATION) {
			if(PlayerXP[attacker] < PlayerXP[victim]){
				if(headshot) {
					PlayerXP[attacker] += get_pcvar_num(gCvar_HS); 
					PlayerXP[attacker] += 5;
					PlayerXP[attacker] += 10;
					ColorChat(attacker, RED, "^x01 You got more^x03 XP^x01. You^x03 killed^x01 with^x03 HEAD^x04SHOT^x01.");
					ColorChat(attacker, RED, "^x04 Level -^x01 [^x03 %i^x01 ]^x04 XP -^x01 [^x03 %d^x01 ]",PlayerLevel[attacker],PlayerXP[attacker]);
					ColorChat(attacker, RED, "^x04 Shop Menu -^x01 [^x03 /menu^x01 ]^x04 Rank - ^x01[^x03 %s^x01 ]",rank[attacker]);
					//UpdateHUD(attacker);
					SaveData(attacker); 
				}
				else 
				{
					PlayerXP[attacker] += get_pcvar_num(gCvar_Kill); 
					PlayerXP[attacker] += 5;
					PlayerXP[attacker] += 10;
					ColorChat(attacker, RED, "^x01 You got more^x03 XP^x01. Your^x03 kill^x01 is^x03 Normal^x04!!!");
					ColorChat(attacker, RED, "^x04 Level -^x01 [^x03 %i^x01 ]^x04 XP -^x01 [^x03 %d^x01 ]",PlayerLevel[attacker],PlayerXP[attacker]);
					ColorChat(attacker, RED, "^x04 Shop Menu -^x01 [^x03 /menu^x01 ]^x04 Rank - ^x01[^x03 %s^x01 ]",rank[attacker]);
					//UpdateHUD(attacker);
					SaveData(attacker); 
				}
			}
			else
			{
				if(headshot) {
					PlayerXP[attacker] += get_pcvar_num(gCvar_HS); 
					PlayerXP[attacker] += 5; 
					ColorChat(attacker, RED, "^x01 You got more^x03 XP^x01. You^x03 killed^x01 with^x03 HEAD^x04SHOT^x01.");
					ColorChat(attacker, RED, "^x04 Level -^x01 [^x03 %i^x01 ]^x04 XP -^x01 [^x03 %d^x01 ]",PlayerLevel[attacker],PlayerXP[attacker]);
					ColorChat(attacker, RED, "^x04 Shop Menu -^x01 [^x03 /menu^x01 ]^x04 Rank - ^x01[^x03 %s^x01 ]",rank[attacker]);
					//UpdateHUD(attacker);
					SaveData(attacker); 
				}
				else 
				{
					PlayerXP[attacker] += get_pcvar_num(gCvar_Kill); 
					PlayerXP[attacker] += 5; 
					ColorChat(attacker, RED, "^x01 You got more^x03 XP^x01. Your^x03 kill^x01 is^x03 Normal^x04!!!");
					ColorChat(attacker, RED, "^x04 Level -^x01 [^x03 %i^x01 ]^x04 XP -^x01 [^x03 %d^x01 ]",PlayerLevel[attacker],PlayerXP[attacker]);
					ColorChat(attacker, RED, "^x04 Shop Menu -^x01 [^x03 /menu^x01 ]^x04 Rank - ^x01[^x03 %s^x01 ]",rank[attacker]);
					//UpdateHUD(attacker);
					SaveData(attacker); 
				}
			}
		}
		else 
		{
			if(PlayerXP[attacker] < PlayerXP[victim]){
				if(headshot) {
					PlayerXP[attacker] += get_pcvar_num(gCvar_HS); 
					PlayerXP[attacker] += 10;
					ColorChat(attacker, RED, "^x01 You got more^x03 XP^x01. You^x03 killed^x01 with^x03 HEAD^x04SHOT^x01.");
					ColorChat(attacker, RED, "^x04 Level -^x01 [^x03 %i^x01 ]^x04 XP -^x01 [^x03 %d^x01 ]",PlayerLevel[attacker],PlayerXP[attacker]);
					ColorChat(attacker, RED, "^x04 Shop Menu -^x01 [^x03 /menu^x01 ]^x04 Rank - ^x01[^x03 %s^x01 ]",rank[attacker]);
					//UpdateHUD(attacker);
					SaveData(attacker); 
				}
				else 
				{
					PlayerXP[attacker] += get_pcvar_num(gCvar_Kill); 
					PlayerXP[attacker] += 10;
					ColorChat(attacker, RED, "^x01 You got more^x03 XP^x01. Your^x03 kill^x01 is^x03 Normal^x04!!!");
					ColorChat(attacker, RED, "^x04 Level -^x01 [^x03 %i^x01 ]^x04 XP -^x01 [^x03 %d^x01 ]",PlayerLevel[attacker],PlayerXP[attacker]);
					ColorChat(attacker, RED, "^x04 Shop Menu -^x01 [^x03 /menu^x01 ]^x04 Rank - ^x01[^x03 %s^x01 ]",rank[attacker]);
					//UpdateHUD(attacker);
					SaveData(attacker); 
				}
			}
			else 
			{
				if(headshot) {
					PlayerXP[attacker] += get_pcvar_num(gCvar_HS); 
					ColorChat(attacker, RED, "^x01 You got more^x03 XP^x01. You^x03 killed^x01 with^x03 HEAD^x04SHOT^x01.");
					ColorChat(attacker, RED, "^x04 Level -^x01 [^x03 %i^x01 ]^x04 XP -^x01 [^x03 %d^x01 ]",PlayerLevel[attacker],PlayerXP[attacker]);
					ColorChat(attacker, RED, "^x04 Shop Menu -^x01 [^x03 /menu^x01 ]^x04 Rank - ^x01[^x03 %s^x01 ]",rank[attacker]);
					//UpdateHUD(attacker);
					SaveData(attacker); 
				}
				else 
				{
					PlayerXP[attacker] += get_pcvar_num(gCvar_Kill); 
					ColorChat(attacker, RED, "^x01 You got more^x03 XP^x01. Your^x03 kill^x01 is^x03 Normal^x04!!!");
					ColorChat(attacker, RED, "^x04 Level -^x01 [^x03 %i^x01 ]^x04 XP -^x01 [^x03 %d^x01 ]",PlayerLevel[attacker],PlayerXP[attacker]);
					ColorChat(attacker, RED, "^x04 Shop Menu -^x01 [^x03 /menu^x01 ]^x04 Rank - ^x01[^x03 %s^x01 ]",rank[attacker]);
					//UpdateHUD(attacker);
					SaveData(attacker); 
				}
			}
		}
		

		while(PlayerXP[attacker] >= LEVELS[PlayerLevel[attacker]]) { 
			ColorChat(attacker, RED, "^x01 Congratulations! XP^x03 %i^x01 level, type^x03 /menu^x01 to take^x03 advantage of a^x04 point^x01.", PlayerLevel[attacker + 1]);
			ColorChat(attacker, RED, "^x04 Level -^x01 [^x03 %i^x01 ]^x04 XP -^x01 [^x03 %d^x01 ]",PlayerLevel[attacker],PlayerXP[attacker]);
			ColorChat(attacker, RED, "^x04 Shop Menu -^x01 [^x03 /menu^x01 ]^x04 Rank - ^x01[^x03 %s^x01 ]",rank[attacker]);
			PlayerLevel[attacker] += 1; 
			punkty[attacker] += 1;
			//UpdateHUD(attacker);
			SaveData(attacker); 
		} 
		
		SaveData(attacker); 
		
	}
	if(punktyrespawn[victim] >= 1) {
		set_task(1.0, "respawn", victim)
	}  
	//UpdateHUD(attacker);
	SaveData(attacker); 
}

public UpdateHUD(id) {
	for (new id=0; id < 32; id++) {
		
		//new HUD[255]
		
		if (!is_user_connected(id))
			continue
		
		if (is_user_alive(id))
		{
			if(PlayerLevel[ id ] >= 15) {
				set_hudmessage(222,133,0,-1.0, 0.01,0,1.0, 12.0)
				show_hudmessage(id, "Congratulations ! You are passed | WIN !!!^nYour level is Max / 15^nYour eXp is Max / 18100^nNow your rank is EasyBlock GOD");
			}
			else 
			{
				set_hudmessage(0,178,0,0.01, 0.18,0,1.0, 12.0)
				show_hudmessage(id, "Level: %i / 15^nExp: %d / %d ^nNeed +%d eXp^nRank: %s",PlayerLevel[id],PlayerXP[id],LEVELS[PlayerLevel[id]], LEVELS[PlayerLevel[id]] - PlayerXP[id], rank[id]);
			}
		}
	}  
}


public rank_rangi(id) {
	
	switch(PlayerLevel[id])
	{
		case  10..15:
		{
			rank[id] = "OptiMax ";
		}
		case  9:
		{
			rank[id] = "Semi-Pro";
		}
		case  8:
		{
			rank[id] = "Co0L k0x. -.-";
		}
		case  7:
		{
			rank[id] = "ModeRate!";
		}
		case  6:
		{
			rank[id] = "Medium skilled ;d";
		}
		case  5:
		{
			rank[id] = "Regular";
		}
		case  4:
		{
			rank[id] = "Low (I love miX)";
		}
		case  3:
		{
			rank[id] = "Amator EasyBlock'er";
		}
		case 2:
		{
			rank[id] = "H0use Lover ;]";
		}
		case 1:
		{
			rank[id] = "Bitcher -.-";
		}
		case 0:
		{
			rank[id] = "Newbie";
		}
	}
}
// XP MENU
public menu_xp(id)
{
	new msg0[128]
	format(msg0,127,"\yHead Menu \d(Page \y1\d)^n^n\yLevel: \r%i^n\w    Experience: \d[%d / %d]^n\yPoints: \r%d",PlayerLevel[id],PlayerXP[id],LEVELS[PlayerLevel[id]],punkty[id])
	
	//show_hudmessage(id, "Level: %i / 15^nExp: %d / %d ^nNeed +%d eXp^nRank: %s",PlayerLevel[id],PlayerXP[id],LEVELS[PlayerLevel[id]], LEVELS[PlayerLevel[id]] - PlayerXP[id], rank[id]);
	
	new menu_exp = menu_create(msg0, "exp_wybierz")
	new msg1[128]
	format(msg1,127,"\wHP \r[\y%d\w/\y5\r] \d(\rNeed Level 2\d)",punktyhp[id])
	menu_additem(menu_exp , msg1, "1", 0)
	new msg2[128]
	format(msg2,127,"\wArmor \r[\y%d\w/\y5\r]",punktyarm[id])
	menu_additem(menu_exp , msg2, "2", 0)
	new msg3[128]
	format(msg3,127,"\wRespawn \r[\y%d\w/\y1\r] \d(\rNeed Level \y10\d)",punktyrespawn[id])
	menu_additem(menu_exp , msg3, "3", 0)
	new msg4[128]
	format(msg4,127,"\wInvisible \r[\y%d\w/\w1\r] \d(\rNeed Level \y8\d)",punktysk1[id])
	menu_additem(menu_exp , msg4, "4", 0)
	new msg5[128]
	format(msg5,127,"\wCamouflage \r[\y%d\w/\w1\r] \d(\rNeed Level \y5\d)",punktysk2[id])
	menu_additem(menu_exp , msg5, "5", 0)
	new msg6[128]
	format(msg6,127,"\wGravity \r[\y%d\w/\y1\r] \d(\rNeed Level \y15\d)",punktysk3[id])
	menu_additem(menu_exp , msg6, "6", 0)
	new msg7[128]
	format(msg7,127,"\wWeapons \r[\y%d\w/\y2\r]",bronie[id])
	menu_additem(menu_exp , msg7, "7", 0)
	new msg8[128]
	format(msg8,127,"\wStrengthening \r[\y%d\w/\y10\r]^n",punktywzmoc[id])
	menu_additem(menu_exp , msg8, "8", 0)
	new msg9[128]
	format(msg9,127,"\wNext Page")
	menu_additem(menu_exp , msg9, "9", 0)
	new msg10[128]
	format(msg10,127,"\wExit")
	menu_additem(menu_exp , msg10, "0", 0)
	
	menu_setprop(menu_exp,MPROP_EXIT,MEXIT_NEVER);
	
	menu_setprop(menu_exp,MPROP_PERPAGE,0);
	
	
	
	menu_display(id, menu_exp, 0)
}  

// XP MENU
public menu_xp_2(id)
{
	new msg0[128]
	format(msg0,127,"\yHead Menu \d(Page \y2\d)^n^n\yLevel: \r%i^n\w    Experience: \d[%d / %d]^n\yPoints: \r%d",PlayerLevel[id],PlayerXP[id],LEVELS[PlayerLevel[id]],punkty[id])
	new menu_exp_2 = menu_create(msg0, "exp_wybierz_2")
	new msg1[128]
	format(msg1,127,"\wWalk = no sound \r[\y%d\w/\y1\r]",punktychodzenie[id])
	menu_additem(menu_exp_2 , msg1, "1", 0)
	new msg2[128]
	format(msg2,127,"\wGrenade \r[\y%d\w/\y2\r]",punktygranat[id])
	menu_additem(menu_exp_2 , msg2, "2", 0)
	new msg3[128]
	format(msg3,127,"\wPostol \r[\y%d\w/\y5\r] \d(\rNeed Level \y15\d)",punktypistolety[id])
	menu_additem(menu_exp_2 , msg3, "3", 0)
	new msg4[128]
	format(msg4,127,"\wRifles \r[\y%d\w/\y5\r] \d(\rNeed Level \y15\d)",punktykarabiny[id])
	menu_additem(menu_exp_2 , msg4, "4", 0)
	new msg5[128]
	format(msg5,127,"\wSet Weapons \r[\y%d\w/\y5\r] \d(\rNeed Level \y15\d)^n^n^n",punktyzestaw[id])
	menu_additem(menu_exp_2 , msg5, "5", 0)
	new msg6[128]
	format(msg6,127,"")
	new msg7[128]
	format(msg7,127,"")
	new msg8[128]
	format(msg8,127,"")
	new msg9[128]
	format(msg9,127,"\wBack\y (page 1)")
	menu_additem(menu_exp_2, msg9, "9", 0)
	new msg10[128]
	format(msg10,127,"\wExit")
	menu_additem(menu_exp_2 , msg10, "0", 0)
	
	menu_setprop(menu_exp_2,MPROP_EXIT,MEXIT_NEVER);
	
	menu_setprop(menu_exp_2,MPROP_PERPAGE,0);
	
	
	menu_display(id, menu_exp_2, 0)
}  
public exp_wybierz(id, menu_exp , item)
{
	new data[6], iName[64]
	new acces, callback
	menu_item_getinfo(menu_exp, item, acces, data,5, iName, 63, callback)
	
	new klawisz = str_to_num(data)
	
	switch(klawisz)
	{ 
		case 1 : { 
			if(PlayerLevel[id] <= 1) {
				ColorChat(id, RED, "^x04[xD eXperience Mod]^x01 Need^x03 2^x01 level");
			}
			else if(punkty[id] == 0) {
				ColorChat(id, RED, "^x04[xD eXperience Mod]^x01 Need^x03 points^x01 for this^x04!!!");
			}
			else 
			{
				if(punktyhp[id] >= 5) {
					ColorChat(id, GREEN, "[xD eXperience Mod]^x01 Now you have^x03 %i^x04 /^x03 5^x01!", punktyhp[id]);
				}
				else 
				{
					punkty[id] -= 1;
					punktyhp[id] += 1;
					ColorChat(id, RED, "^x04*^x01 All is^x03 successfully^x04!");
					ColorChat(id, RED, "^x03*^x04 Item:^x03 HP^x04!");
					ColorChat(id, RED, "^x03*^x01 Description:^x03 HP^x04 Power^x01,^x03 Hard to^x01 Kill^x04!");
				}
			}
			menu_destroy(menu_exp); 
			menu_xp(id); 
			SaveData(id);
			return PLUGIN_HANDLED; 
		}
		case 2 :  { 
			if(punkty[id] == 0) {
				ColorChat(id, RED, "^x04[xD eXperience Mod]^x01 Need^x03 points^x01 for this^x04!!!");
			}
			else 
			{
				if(punktyarm[id] >= 5) {
					ColorChat(id, GREEN, "[xD eXperience Mod]^x01 Sorry, you already have^x03 %i^x04 /^x03 5^x01!", punktyarm[id]);
				}
				else 
				{
					punkty[id] -= 1;
					punktyarm[id] += 1;
					ColorChat(id, RED, "^x04*^x01 All is^x03 successfully^x04!!!");
					ColorChat(id, RED, "^x03*^x04 Item:^x03 Armor^x04!");
					ColorChat(id, RED, "^x03*^x01 Description:^x03 Armor^x04 Power^x01,^x03 Hard to^x04 Kill^x01 with^x03 HEADshot^x04!");
				}
			}
			menu_destroy(menu_exp); 
			menu_xp(id); 
			SaveData(id);
			return PLUGIN_HANDLED; 
		}
		case 3 :  { 
			if(PlayerLevel[id] <= 9) {
				ColorChat(id, GREEN, "[xD eXperience Mod]^x01 Need^x03 10^x01 level!");
			}
			else if(punkty[id]<= 0) {
				ColorChat(id, RED, "^x04[xD eXperience Mod]^x01 Need^x03 points^x01 for this^x04!!!");
			}
			else 
			{
				if(punktyrespawn[id] >= 1) {
					ColorChat(id, GREEN, "[xD eXperience Mod]^x01 Sorry, you already have^x03 %i^x04 /^x03 1^x01!", punktyrespawn[id]);
				}
				else 
				{
					punkty[id] -= 1;
					punktyrespawn[id] += 1;
					ColorChat(id, RED, "^x04*^x01 All is^x03 successfully^x04!!!");
					ColorChat(id, RED, "^x03*^x04 Item:^x03 Respawn^x04!");
					ColorChat(id, RED, "^x03*^x01 Description:^x03 Respawn after kill^x04!");
				}
			}
			menu_destroy(menu_exp); 
			menu_xp(id); 
			SaveData(id);
			return PLUGIN_HANDLED; 
		}
		case 4 :  { 
			if(PlayerLevel[id] <= 7) {
				ColorChat(id, GREEN, "[xD eXperience Mod]^x01 Need^x03 8^x01 level!");
			}
			else if(punkty[id] <= 1) { // else if
				ColorChat(id, RED, "^x04[xD eXperience Mod]^x01 Need^x03 points^x01 for this^x04!!!");
			}
			else if(skille[id] >= 2) {
				ColorChat(id, GREEN, "[xD eXperience Mod]^x01 You can have a maximum^x03 2^x01 skille!");
			}
			else 
			{
				if(punktysk1[id] >= 1) {
					ColorChat(id, GREEN, "[xD eXperience Mod]^x01 Sorry, you already have^x03 %i^x04 /^x03 1^x01!", punktysk1[id]);
				}
				else 
				{
					punkty[id] -= 2;
					punktysk1[id] += 1;
					skille[id] += 1;
					ColorChat(id, RED, "^x04*^x01 All is^x03 successfully^x04!!!");
					ColorChat(id, RED, "^x03*^x04 Item:^x03 Invisible^x04!");
					ColorChat(id, RED, "^x03*^x01 Description:^x03 Invisible^x04 Power^x01,^x03 Small^x04 Visible^x01 and^x03 Hard to^x01 Kill^x04!");
				}
			}
			menu_destroy(menu_exp); 
			menu_xp(id);
			SaveData(id);
			return PLUGIN_HANDLED; 
		}
		case 5 :  { 
			if(PlayerLevel[id] <= 4) {
				ColorChat(id, GREEN, "[xD eXperience Mod]^x01 Need^x03 5^x01 level!");
			}
			else if(punkty[id] <= 1) { // else if
				ColorChat(id, RED, "^x04[xD eXperience Mod]^x01 Need^x03 points^x01 for this^x04!!!");
			}
			else if(skille[id] >= 2) {
				ColorChat(id, GREEN, "[xD eXperience Mod]^x01 You can have a maximim^x03 2^x01 skille!");
			}
			else 
			{
				if(punktysk2[id] >= 1) {
					ColorChat(id, GREEN, "[xD eXperience Mod]^x01 Sorry, you already have^x03 %i^x04 /^x03 1^x01!", punktysk2[id]);
				}
				else 
				{
					punkty[id] -= 2;
					punktysk2[id] += 1;
					skille[id] += 1;
					ColorChat(id, RED, "^x04*^x01 All is^x03 successfully^x04!!!");
					ColorChat(id, RED, "^x03*^x04 Item:^x03 Camouflage^x04!");
					ColorChat(id, RED, "^x03*^x01 Description:^x03 Camouflage^x04 Power^x01,^x03 T^x01 or^x03 CT^x04 view^x01 and^x03 Hard to^x01 Observable^x04!");
				}
			}
			menu_destroy(menu_exp); 
			menu_xp(id); 
			SaveData(id);
			return PLUGIN_HANDLED;
		}
		case 6 :  { 
			if(PlayerLevel[id] <= 14) {
				ColorChat(id, GREEN, "[xD eXperience Mod]^x01 Need^x03 15^x01 level!");
			}
			else if(punkty[id] <= 1) { // else if
				ColorChat(id, RED, "^x04[xD eXperience Mod]^x01 Need^x03 points^x01 for this^x04!!!");
			}
			else if(skille[id] >= 2) {
				ColorChat(id, GREEN, "[xD eXperience Mod]^x01 You can have a maximum^x03 2^x01 skille!");
			}
			else 
			{
				if(punktysk3[id] >= 1) {
					ColorChat(id, GREEN, "[xD eXperience Mod]^x01 Sorry, you already have^x03 %i^x04 /^x03 1^x01!", punktysk3[id]);
				}
				else 
				{
					punkty[id] -= 2;
					punktysk3[id] += 1;
					skille[id] += 1;
					ColorChat(id, RED, "^x04*^x01 All is^x03 successfully^x04!!!");
					ColorChat(id, RED, "^x03*^x04 Item:^x03 Gravity^x04!");
					ColorChat(id, RED, "^x03*^x01 Description:^x03 Gravity^x04 Power^x01^x04!");
				}
			}
			menu_destroy(menu_exp);
			menu_xp(id);
			SaveData(id);
			return PLUGIN_HANDLED ;
		}
		
		case 7: { 
			if(punkty[id] == 0) {
				ColorChat(id, RED, "^x04[xD eXperience Mod]^x01 Need^x03 points^x01 for this^x04!!!");
			}
			else 
			{
				if(bronie[id] >= 2) {
					ColorChat(id, GREEN, "[xD eXperience Mod]^x01 Sorry, you already have^x03 %i^x04 /^x03 2^x01!", bronie[id]);
				}
				else 
				{
					punkty[id] -= 1;
					bronie[id] += 1;
					ColorChat(id, RED, "^x04*^x01 All is^x03 successfully^x04!!!");
					ColorChat(id, RED, "^x03*^x04 Item:^x03 Weapons^x04!");
					ColorChat(id, RED, "^x03*^x01 Description:^x03 Weapon^x04 Power^x01,^x03 Got more^x01 Weapons^x04!");
				}
			}
			menu_destroy(menu_exp); 
			menu_xp(id); 
			SaveData(id);
			return PLUGIN_HANDLED; 
		}
		case 8: { 
			
			if(punkty[id]<= 0) {
				ColorChat(id, RED, "^x04[xD eXperience Mod]^x01 Need^x03 points^x01 for this^x04!!!");
			}
			else 
			{
				if(punktywzmoc[id] >= 10) {
					ColorChat(id, GREEN, "[xD eXperience Mod]^x01 Sorry, you already have^x03 %i^x04 /^x03 10^x01!", punktywzmoc[id]);
				}
				else 
				{
					punkty[id] -= 1;
					punktywzmoc[id] += 1;
					ColorChat(id, RED, "^x04*^x01 All is^x03 successfully^x04!!!");
					ColorChat(id, RED, "^x03*^x04 Item:^x03 Strengthening^x04!");
					ColorChat(id, RED, "^x03*^x01 Description:^x03 Strengthening^x04 Power^x01,^x03 Got more^x01 Strengthening^x04!");
				}
			}
			menu_destroy(menu_exp); 
			menu_xp(id); 
			SaveData(id);
			return PLUGIN_HANDLED; 
		}
		case 9: { 
			menu_xp_2(id);
			menu_destroy(menu_exp); 
		}
	}
	return PLUGIN_CONTINUE;
}
public exp_wybierz_2(id, menu_exp_2 , item)
{
	new data[6], iName[64]
	new acces, callback
	menu_item_getinfo(menu_exp_2, item, acces, data,5, iName, 63, callback)
	
	new klawisz = str_to_num(data)
	
	switch(klawisz)
	{ 
		case 1: { 
			if(punkty[id] == 0) {
				ColorChat(id, RED, "^x04[xD eXperience Mod]^x01 Need^x03 points^x01 for this^x04!!!");
			}
			else 
			{
				if(punktychodzenie[id] >= 1) {
					ColorChat(id, GREEN, "[xD eXperience Mod]^x01 Sorry, you already have^x03 %i^x04 /^x03 1^x01!", punktychodzenie[id]);
				}
				else 
				{
					punkty[id] -= 1;
					punktychodzenie[id] += 1;
					ColorChat(id, RED, "^x04*^x01 All is^x03 successfully^x04!!!");
					ColorChat(id, RED, "^x03*^x04 Item:^x03 Walk = no sound^x04!");
					ColorChat(id, RED, "^x03*^x01 Description:^x03 No sound walk^x04 Power^x01,^x03 You are^x04 No sound^x01 Walker^x04!");
				}
			}
			menu_destroy(menu_exp_2); 
			menu_xp_2(id); 
			SaveData(id);
			return PLUGIN_HANDLED; 
		}
		case 2: { 
			if(punkty[id] == 0) {
				ColorChat(id, RED, "^x04[xD eXperience Mod]^x01 Need^x03 points^x01 for this^x04!!!");
			}
			else 
			{
				if(punktygranat[id] >= 2) {
					ColorChat(id, GREEN, "[xD eXperience Mod]^x01 Sorry, you already have^x03 %i^x04 /^x03 2^x01!", punktygranat[id]);
				}
				else 
				{
					punkty[id] -= 1;
					punktygranat[id] += 1;
					ColorChat(id, RED, "^x04*^x01 All is^x03 successfully^x04!!!");
					ColorChat(id, RED, "^x03*^x04 Item:^x03 Grenades^x04!");
					ColorChat(id, RED, "^x03*^x01 Description:^x03 Grenade^x04 Power^x01,^x03 You got^x04 all^x01 Grenades^x04!");
				}
			}
			menu_destroy(menu_exp_2); 
			menu_xp_2(id); 
			SaveData(id);
			return PLUGIN_HANDLED; 
		}
		case 3: { 
			if(PlayerLevel[id] <= 14) {
				ColorChat(id, GREEN, "[xD eXperience Mod]^x01 Need^x03 15^x01 level!");
			}
			else if(punkty[id] == 0) {
				ColorChat(id, RED, "^x04[xD eXperience Mod]^x01 Need^x03 points^x01 for this^x04!!!");
			}
			else 
			{
				if(punktypistolety[id] >= 5) {
					ColorChat(id, GREEN, "[xD eXperience Mod]^x01 Sorry, you already have^x03 %i^x04 /^x03 5^x01!", punktypistolety[id]);
				}
				else 
				{
					punkty[id] -= 1;
					punktypistolety[id] += 1;
					ColorChat(id, RED, "^x04*^x01 All is^x03 successfully^x04!!!");
					ColorChat(id, RED, "^x03*^x04 Item:^x03 Pistols^x04!");
					ColorChat(id, RED, "^x03*^x01 Description:^x03 Pistols^x04 Power^x01,^x03 You got^x01 Pistols^x04!");
				}
			}
			menu_destroy(menu_exp_2); 
			menu_xp_2(id); 
			SaveData(id);
			return PLUGIN_HANDLED; 
		}
		case 4: { 
			if(PlayerLevel[id] <= 14) {
				ColorChat(id, GREEN, "[xD eXperience Mod]^x01 Need^x03 15^x01 level!");
			}
			else if(punkty[id] == 0) {
				ColorChat(id, RED, "^x04[xD eXperience Mod]^x01 Need^x03 points^x01 for this^x04!!!");
			}
			else 
			{
				if(punktykarabiny[id] >= 5) {
					ColorChat(id, GREEN, "[xD eXperience Mod]^x01 Sorry, you already have^x03 %i^x04 /^x03 5^x01!", punktykarabiny[id]);
				}
				else 
				{
					punkty[id] -= 1;
					punktykarabiny[id] += 1;
					ColorChat(id, RED, "^x04*^x01 All is^x03 successfully^x04!!!");
					ColorChat(id, RED, "^x03*^x04 Item:^x03 Rifles^x04!");
					ColorChat(id, RED, "^x03*^x01 Description:^x03 Rifles^x04 Power^x01,^x03 You got^x01 Rifles^x04!");
				}
			}
			menu_destroy(menu_exp_2); 
			menu_xp_2(id); 
			SaveData(id);
			return PLUGIN_HANDLED; 
		}
		case 5: { 
			if(PlayerLevel[id] <= 14) {
				ColorChat(id, GREEN, "[xD eXperience Mod]^x01 Need^x03 15^x01 level!");
			}
			else if(punkty[id] == 0) {
				ColorChat(id, RED, "^x04[xD eXperience Mod]^x01 Need^x03 points^x01 for this^x04!!!");
			}
			else 
			{
				if(punktyzestaw[id] >= 5) {
					ColorChat(id, GREEN, "[xD eXperience Mod]^x01 Sorry, you already have^x03 %i^x04 /^x03 5^x01!", punktyzestaw[id]);
				}
				else 
				{
					punkty[id] -= 1;
					punktyzestaw[id] += 1;
					ColorChat(id, RED, "^x04*^x01 All is^x03 successfully^x04!!!");
					ColorChat(id, RED, "^x03*^x04 Item:^x03 Set more Weapons^x04!");
					ColorChat(id, RED, "^x03*^x01 Description:^x03 More Weapons^x04 Power^x01,^x03 You got^x04 more^x01 Weapons^x04!");
				}
			}
			menu_destroy(menu_exp_2); 
			menu_xp_2(id); 
			SaveData(id);
			return PLUGIN_HANDLED; 
		}
		case 9: { 
			menu_xp(id);
			menu_destroy(menu_exp_2); 
		}
	}
	return PLUGIN_CONTINUE;
}
public gracze_info( id ) {
	new alldata[2048];
	#if defined USING_CS
	alldata="<html><head><title>Levele graczy</title></head><body><center><table border='1'><tr><th width='200' align='center' cellpadding='5'>Nick</th><th width='40'>Level</th><th width='40'>Exp</th></tr>"
	new iPlayers[32],iNum
	get_players(iPlayers,iNum)
	for(new g=0;g<iNum;g++)
	{
		new i=iPlayers[g]
		if(is_user_connected(i))
		{
			new name[20]
			get_user_name(i,name,19)
			format(alldata,2047,"%s<tr><td>%s</td><td align='center'>%i</td><td align='center'>%i</td>",alldata,name,PlayerLevel[i],PlayerXP[i])
		}
	}
	format(alldata,2047,"%s</table></center></body></html>",alldata)
	#else
	alldata="Nick            Level            Exp            ^n"
	new iPlayers[32],iNum
	get_players(iPlayers,iNum)
	for(new g=0;g<iNum;g++)
	{
		new i=iPlayers[g]
		if(is_user_connected(i))
		{
			new name[20]
			get_user_name(i,name,19)
			new toadd=20-strlen(name)
			new spaces[20]=""
			add(spaces,19,"                   ",toadd)
			format(alldata,2047,"%s^n%s %s %i     %i",alldata,name,spaces,PlayerLevel[i],PlayerXP[i]);
		}
	}
	#endif
	show_motd( id, alldata, "Player Information" );
}
public NewRound() {
	for (new id=0; id < 32; id++)
	{
		uzyl[id] = false;
		SaveData(id);
		//UpdateHUD(id);
	}
}

public EventRoundStart(id) {
	
	//uzyl[id] = false
	new iPlayers[32], iNum;
	get_players( iPlayers, iNum );
	
	for( new g = 0; g<iNum ;g++ )
	{
		new id = iPlayers[g];
		
		new name[32];
		get_user_name( id, name, 31 );
		
		starthealth = get_user_health( id );
		startarmor = get_user_armor( id );
		
		set_user_health( id, punktyhp[id] * 10 + starthealth );
		set_user_armor( id, punktyarm[id] * 80+  startarmor );
		
		if(bronie[id] >= 1) {
			set_task(5.0, "weapon_chance", id);
		}
		
		if(punktychodzenie[id] >= 1) {
			set_user_footsteps(id, 1);
		}
		if(punktygranat[id] >= 1) {
			set_task(5.0, "weapon_granaty", id);
		}
		UpdateHUD(id);
	}
}

public weapon_chance(id) {
	
	new los = random_num(1, 100);
	
	if(los <= 7 * bronie[id]){ // 7 * bronie[id]
		if(punktypistolety[id] >= 1) {
			new bronie_los = random_num(1,2)
			
			switch(bronie_los)  {
				case 1: {
					give_item( id, "weapon_glock18" );
					cs_set_user_bpammo(id, CSW_GLOCK18, 0);
					cs_set_weapon_ammo( find_ent_by_owner( 4, "weapon_glock18", id ), 4); 
					ColorChat(id, RED, "^x04[xD Award]^x01 You got^x03 Glock^x01 with^x03 4^x04 bullets^x01!", 7 * bronie[id]);
				}
				case 2: {
					give_item( id, "weapon_fiveseven" );
					cs_set_user_bpammo(id, CSW_FIVESEVEN, 0);
					cs_set_weapon_ammo( find_ent_by_owner( 3, "weapon_fiveseven", id ), 3); 
					ColorChat(id, RED, "^x04[xD Award]^x01 You got^x03 FiveSeven^x01 with^x03 3^x04 bullets^x01!", 7 * bronie[id]);
				}
			}
		}
		else 
		{
			new bronie_los = random_num(1,3)
			
			switch(bronie_los)  {
				case 1: {
					give_item( id, "weapon_p228" );
					cs_set_user_bpammo(id, CSW_P228, 0);
					cs_set_weapon_ammo( find_ent_by_owner( 1, "weapon_p228", id ), 1); 
					ColorChat(id, RED, "^x04[xD Award]^x01 You got^x03 a Pop Gun^x01 with^x03 1^x04 bullet^x01!", 7 * bronie[id]);
				}
				case 2: {
					give_item( id, "weapon_m3" );
					cs_set_user_bpammo(id, CSW_M3, 0);
					cs_set_weapon_ammo( find_ent_by_owner( 1, "weapon_m3", id ), 1); 
					ColorChat(id, RED, "^x04[xD Award]^x01 You got^x03 M3^x01 with^x03 1^x04 bullet^x01!", 7 * bronie[id]);
				}
				case 3: {
					give_item( id, "weapon_tmp" );
					cs_set_user_bpammo(id, CSW_TMP, 0);
					cs_set_weapon_ammo( find_ent_by_owner( 2, "weapon_tmp", id ), 2); 
					ColorChat(id, RED, "^x04[xD Award]^x01 You got^x03 Wiertare^x01 with^x03 2^x04 bullets^x01!", 7 * bronie[id]);
					
				}
			}
			
		} 
	}
	else if(los <= 17 * bronie[id]){   // 10 * bronie[id]
		new bronie_los = random_num(1,4)
		
		switch(bronie_los)  {
			case 1: {
				give_item( id, "weapon_mac10" );
				cs_set_user_bpammo(id, CSW_MAC10, 0);
				cs_set_weapon_ammo( find_ent_by_owner( 1, "weapon_mac10", id ), 1); 
				ColorChat(id, RED, "^x04[xD Award]^x01 You got^x03 Uzi^x01 with^x03 1^x04 bullet^x01!", 10 * bronie[id]);
			}
			case 2: {
				give_item( id, "weapon_mp5navy" );
				cs_set_user_bpammo(id, CSW_MP5NAVY, 0);
				cs_set_weapon_ammo( find_ent_by_owner( 1, "weapon_mp5navy", id ), 1); 
				ColorChat(id, RED, "^x04[xD Award]^x01 You got^x03 MP5Navy^x01 with^x03 1^x04 bullet^x01!", 10 * bronie[id]);
			}
			case 3: {
				give_item( id, "weapon_glock18" );
				cs_set_user_bpammo(id, CSW_GLOCK18, 0);
				cs_set_weapon_ammo( find_ent_by_owner( 1, "weapon_glock18", id ), 1); 
				ColorChat(id, RED, "^x04[xD Award]^x01 You got^x03 Glock^x01 with^x03 1^x04 bullet^x01!", 10 * bronie[id]);
				
			}
			case 4: {
				give_item( id, "weapon_usp" );
				cs_set_user_bpammo(id, CSW_USP, 0);
				cs_set_weapon_ammo( find_ent_by_owner( 1, "weapon_usp", id ), 1); 
				ColorChat(id, GREEN, "^x04[xD Award]^x01 You got^x03 USP^x01 with^x03 1^x04 bullet^x01!", 10 * bronie[id]);
				
			}
		}
		
	}  
	else if(los <= 25 * bronie[id]){   // 8 * bronie[id]
		new bronie_los = random_num(1,3)
		
		switch(bronie_los)  {
			case 1: {
				give_item( id, "weapon_xm1014" );
				cs_set_user_bpammo(id, CSW_XM1014, 0);
				cs_set_weapon_ammo( find_ent_by_owner( 1, "weapon_xm1014", id ), 1); 
				ColorChat(id, RED, "^x04[xD Award]^x01 You got^x03 XM1014^x01 with^x03 1^x04 bullet^x01!", 8 * bronie[id]);
			}
			case 2: {
				give_item( id, "weapon_fiveseven" );
				cs_set_user_bpammo(id, CSW_FIVESEVEN, 0);
				cs_set_weapon_ammo( find_ent_by_owner( 1, "weapon_fiveseven", id ), 1); 
				ColorChat(id, RED, "^x04[xD Award]^x01 You got^x03 FiveSeven^x01 with^x03 1^x04 bullet^x01!", 8 * bronie[id]);
			}
			case 3: {
				give_item( id, "weapon_elite" );
				cs_set_user_bpammo(id, CSW_ELITE, 0);
				cs_set_weapon_ammo( find_ent_by_owner( 1, "weapon_elite", id ), 1); 
				ColorChat(id, RED, "^x04[xD Award]^x01 You got^x03 Elite^x01 with^x03 1^x04 bullet^x01!", 8 * bronie[id]);
				
			}
		}
		
	} 
	else if(los <= 28 * bronie[id]){   // 3 * bronie[id]
		if(punktyzestaw[id] >= 1){
			new bronie_los = random_num(1,2)
			
			switch(bronie_los)  {
				case 1: {
					
					give_item( id, "weapon_m4a1" );
					cs_set_user_bpammo(id, CSW_M4A1, 0);
					cs_set_weapon_ammo( find_ent_by_owner( 1, "weapon_m4a1", id ), 1); 
					give_item( id, "weapon_glock18" );
					cs_set_user_bpammo(id, CSW_GLOCK18, 0);
					cs_set_weapon_ammo( find_ent_by_owner( 1, "weapon_glock18", id ), 1); 
					ColorChat(id, RED, "^x04[xD Award]^x01 You got^x03 M4A1^x01 and^x03 Glock^x01 with^x03 1^x04 bullets^x01!", 3 * bronie[id]);
				}
				case 2: {
					give_item( id, "weapon_ak47" );
					cs_set_user_bpammo(id, CSW_AK47, 0);
					cs_set_weapon_ammo( find_ent_by_owner( 1, "weapon_ak47", id ), 1); 
					give_item( id, "weapon_fiveseven" );
					cs_set_user_bpammo(id, CSW_FIVESEVEN, 0);
					cs_set_weapon_ammo( find_ent_by_owner( 1, "weapon_fiveseven", id ), 1); 
					ColorChat(id, RED, "^x04[xD Award]^x01 You got^x03 AK47^x01 and^x03 FiveSeven^x01 with^x03 1^x04 bullets^x01!", 3 * bronie[id]);
				}
			}
		}
		else if(punktykarabiny[id] >= 1) {
			new bronie_los = random_num(1,2)
			
			switch(bronie_los)  {
				case 1: {
					give_item( id, "weapon_m4a1" );
					cs_set_user_bpammo(id, CSW_M4A1, 0);
					cs_set_weapon_ammo( find_ent_by_owner( 1, "weapon_m4a1", id ), 1);  
					ColorChat(id, RED, "^x04[xD Award]^x01 You got^x03 M4A1^x01 with^x03 1^x04 bullet^x01!", 3 * bronie[id]);
				}
				case 2: {
					give_item( id, "weapon_ak47" );
					cs_set_user_bpammo(id, CSW_AK47, 0);
					cs_set_weapon_ammo( find_ent_by_owner( 1, "weapon_ak47", id ), 1);  
					ColorChat(id, RED, "^x04[xD Award]^x01 You got^x03 Ak-47^x01 with^x03 1^x04 bullet^x01!", 3 * bronie[id]);
				}
				
			}
		}
		else 
		{
			new bronie_los = random_num(1,3)
			
			switch(bronie_los)  {
				case 1: {
					give_item( id, "weapon_awp" );
					cs_set_user_bpammo(id, CSW_AWP, 0);
					cs_set_weapon_ammo( find_ent_by_owner( 1, "weapon_awp", id ), 1); 
					ColorChat(id, RED, "^x04[xD Award]^x01 You got^x03 Awp^x01 with^x03 1^x04 bullet^x01!", 3 * bronie[id]);
				}
				case 2: {
					give_item( id, "weapon_deagle" );
					cs_set_user_bpammo(id, CSW_DEAGLE, 0);
					cs_set_weapon_ammo( find_ent_by_owner( 1, "weapon_deagle", id ), 1); 
					ColorChat(id, RED, "^x04[xD Award]^x01 You got^x03 Deagle^x01 with^x03 1^x04 bullet^x01!", 3 * bronie[id]);
				}
				case 3: {
					give_item( id, "weapon_tmp" );
					cs_set_user_bpammo(id, CSW_TMP, 0);
					cs_set_weapon_ammo( find_ent_by_owner( 2, "weapon_tmp", id ), 2); 
					ColorChat(id, RED, "^x04[xD Award]^x01 You got^x03 Wiertare^x01 with^x03 2^x04 bullets^x01!", 3 * bronie[id]);
					
				}
			}
			
		} 
	}
	else { 
		ColorChat(id, RED, "^x04Commands^x01:^x03 /xp^x01,^x03 /exp^x01,^x03 /menu^x01,^x03 /xphelp^x01 and^x04 more^x03...");
	}
}
public weapon_granaty(id) {
	
	new los = random_num(1, 100);
	
	if(los <= 50 * punktygranat[id]){
		if (get_user_team(id) == 1) // 1 - terro
		{
			give_item(id, "weapon_smokegrenade"); 
			give_item(id, "weapon_hegrenade"); 
			give_item(id, "weapon_flashbang"); 
			give_item(id, "weapon_flashbang"); 
			ColorChat(id, RED, "^x04[xD Award]^x01 You got^x03 grenades!^x04 >^x01 >^x04  >^x01 [^x03HE^x01,^x03 Flash^x01,^x03 Smoke^x01]", 50 * punktygranat[id]);
		}
		else
		{
			//give_item(id, "weapon_smokegrenade"); 
			give_item(id, "weapon_hegrenade"); 
			//give_item(id, "weapon_flashbang"); 
			//give_item(id, "weapon_flashbang"); 
			ColorChat(id, RED, "^x04[xD Award]^x01 You got^x03 Explosive^x04 Grenade^x01!", 50 * punktygranat[id]);
		}
		
	}
	
	else { // 49 procent ze nic nie wypadnie
		ColorChat(id, RED, "^x04[xD eXperience Mod]^x03 Bad^x04 luck^x01 .. you^x04 got^x03 nothing^x01.");
	}
}
public EventRoundEnd(id) {
	for (new id=0; id < 32; id++) {
		
		SaveData(id); 
		if(is_user_alive(id) && get_user_team(id) == 1) { // && get_user_team == 1
		ColorChat(id, RED, "^x01 You got^x03 more^x04 exp^x01 for the^x03 survival^x01 of the^x04 round^x01!!!");
		ColorChat(id, RED, "^x04 Level -^x01 [^x03 %i^x01 ]^x04 XP -^x01 [^x03 %d^x01 ]",PlayerLevel[id],PlayerXP[id]);
		ColorChat(id, RED, "^x04 Shop Menu -^x01 [^x03 /menu^x01 ]^x04 Rank - ^x01[^x03 %s^x01 ]",rank[id]);
		PlayerXP[id] += 5;
		}
	}
}
public client_connect(id) { 
	if(get_pcvar_num(gCvar_Enable) == 1) 
		LoadData(id); 
}
public client_disconnect(id) { 
	if(get_pcvar_num(gCvar_Enable) == 1) 
		SaveData(id);
	
	PlayerXP[id] = 0; 
	PlayerLevel[id] = 0; 
	punkty[id] = 0;
	punktyhp[id] = 0;
	punktyarm[id] = 0;
	punktyrespawn[id] = 0;
	punktysk1[id] = 0;
	punktysk2[id] = 0;
	punktysk3[id] = 0;
	skille[id] = 0;
	bronie[id] = 0;
	punktywzmoc[id] = 0;
	punktychodzenie[id] = 0;
	punktygranat[id] = 0;
	punktypistolety[id] = 0;
	punktykarabiny[id] = 0;
	punktyzestaw[id] = 0;
} 

public SaveData(id) { 
	new AuthID[35]; 
	get_user_authid(id, AuthID, 34); 
	
	new vaultkey[64], vaultdata[256]; 
	format(vaultkey, 63, "%s-Mod", AuthID); 
	format(vaultdata, 255, "%d#%d#%d#%d#%d#%d#%d#%d#%d#%d#%d#%d#%d#%d#%d#%d#%d#", PlayerXP[id], PlayerLevel[id], punkty[id], punktyhp[id], punktyarm[id], punktyrespawn[id], punktysk1[id], punktysk2[id], punktysk3[id], skille[id], bronie[id], punktywzmoc[id], punktychodzenie[id], punktygranat[id], punktypistolety[id], punktykarabiny[id], punktyzestaw[id]); 
	nvault_set(g_Vault, vaultkey, vaultdata); 
	return PLUGIN_CONTINUE; 
} 

public LoadData(id) { 
	new AuthID[35]; 
	get_user_authid(id,AuthID,34); 
	
	new vaultkey[64], vaultdata[256]; 
	format(vaultkey, 63, "%s-Mod", AuthID); 
	format(vaultdata, 255, "%d#%d#%d#%d#%d#%d#%d#%d#%d#%d#%d#%d#%d#%d#%d#%d#%d#", PlayerXP[id], PlayerLevel[id], punkty[id], punktyhp[id], punktyarm[id], punktyrespawn[id], punktysk1[id], punktysk2[id], punktysk3[id], skille[id],bronie[id], punktywzmoc[id], punktychodzenie[id], punktygranat[id], punktypistolety[id], punktykarabiny[id], punktyzestaw[id]); 
	nvault_get(g_Vault, vaultkey, vaultdata,255); 
	
	replace_all(vaultdata, 255, "#", " "); 
	
	new playerxp1[32], playerlevel1[32], punkty1[32], punktyhp1[32], punktyarm1[32], punktyrespawn1[32], punktysk11[32], punktysk22[32], punktysk33[32], skille1[32], bronie1[32], punktywzmoc1[32], punktychodzenie1[32], punktygranat1[32], punktypistolety1[32], punktykarabiny1[32], punktyzestaw1[32];
	
	parse(vaultdata, playerxp1, 31, playerlevel1, 31, punkty1, 31, punktyhp1, 31, punktyarm1, 31, punktyrespawn1, 31, punktysk11, 31, punktysk22, 31, punktysk33, 31, skille1, 31, bronie1, 31, punktywzmoc1, 31, punktychodzenie1,31,  punktygranat1, 31, punktypistolety1, 31, punktykarabiny1, 31, punktyzestaw1); 
	
	PlayerXP[id] = str_to_num(playerxp1); 
	PlayerLevel[id] = str_to_num(playerlevel1); 
	punkty[id] = str_to_num(punkty1); 
	punktyhp[id] = str_to_num(punktyhp1); 
	punktyarm[id] = str_to_num(punktyarm1); 
	punktyrespawn[id] = str_to_num(punktyrespawn1); 
	punktysk1[id] = str_to_num(punktysk11);
	punktysk2[id] = str_to_num(punktysk22);
	punktysk3[id] = str_to_num(punktysk33);
	skille[id] = str_to_num(skille1);
	bronie[id] = str_to_num(bronie1);
	punktywzmoc[id] = str_to_num(punktywzmoc1);
	punktychodzenie[id] = str_to_num(punktychodzenie1);
	punktygranat[id] = str_to_num(punktygranat1);
	punktypistolety[id] = str_to_num(punktypistolety1);
	punktykarabiny[id] = str_to_num(punktykarabiny1);
	punktyzestaw[id] = str_to_num(punktyzestaw1);
	
	return PLUGIN_CONTINUE; 
}


public cmd_give_exp( id, level,cid ) { 
	if( ! cmd_access ( id, level, cid, 3 ) ) 
		return PLUGIN_HANDLED; 
	
	new target[32], amount[21], reason[21]; 
	
	read_argv( 1, target, 31 ); 
	read_argv(2, amount, 20 ); 
	read_argv( 3, reason, 20 ); 
	
	new player = cmd_target( id, target, 8 ); 
	
	if( ! player )  
		return PLUGIN_HANDLED; 
	
	new admin_name[32], player_name[32]; 
	get_user_name( id, admin_name, 31 ); 
	get_user_name( player, player_name, 31 ); 
	
	new expnum = str_to_num( amount ); 
	
	PlayerXP[player] += expnum; 
	
	switch( get_cvar_num ( "amx_show_activity" ) ) { 
		case 1: client_print( 0, print_chat, "ADMIN: Ohh. Player %s got %i exp.", expnum, player_name ); 
			case 2: client_print( 0, print_chat, "%s add %i eXp for %s.", admin_name, expnum, player_name ); 
		} 
	
	ColorChat(player, RED, "^x04[xD Give Mode]^x01 You^x04 got^x03 %i^x04 exp^x01 (^x04Total^x01:^x03 %d^x01)", expnum, PlayerXP[player] ); 
	SaveData( id ); 
	
	return PLUGIN_CONTINUE; 
} 

public cmd_take_exp( id, level,cid ) { 
	if( ! cmd_access ( id, level, cid, 3 ) ) 
		return PLUGIN_HANDLED; 
	
	new target[32], amount[21], reason[21]; 
	
	read_argv( 1, target, 31 ); 
	read_argv( 2, amount, 20 ); 
	read_argv( 3, reason, 20 ); 
	
	new player = cmd_target( id, target, 8 ); 
	
	if( ! player )  
		return PLUGIN_HANDLED; 
	
	new admin_name[32], player_name[32]; 
	get_user_name( id, admin_name, 31 ); 
	get_user_name( player, player_name, 31 ); 
	
	new expnum = str_to_num( amount ); 
	
	PlayerXP[player] -= expnum; 
	
	switch(get_cvar_num("amx_show_activity")){ 
		case 1: client_print( 0, print_chat, "ADMIN: took %i points from %s.", expnum, player_name ); 
			case 2: client_print( 0, print_chat, "%s: took %i points from %s.", admin_name, expnum, player_name ); 
		} 
	
	ColorChat(player, RED, "^x04[xD Take Mode]^x01 You^x03 LOST^x04 %i^x03 eXp^x01 (^x04Total^x01:^x03 %d^x01)", expnum, PlayerXP[player] ); 
	SaveData( id ); 
	
	return PLUGIN_CONTINUE; 
}  

public cmd_give_ptk( id, level,cid ) { 
	if( ! cmd_access ( id, level, cid, 3 ) ) 
		return PLUGIN_HANDLED; 
	
	new target[32], amount[21], reason[21]; 
	
	read_argv( 1, target, 31 ); 
	read_argv(2, amount, 20 ); 
	read_argv( 3, reason, 20 ); 
	
	new player = cmd_target( id, target, 8 ); 
	
	if( ! player )  
		return PLUGIN_HANDLED; 
	
	new admin_name[32], player_name[32]; 
	get_user_name( id, admin_name, 31 ); 
	get_user_name( player, player_name, 31 ); 
	
	new expnum = str_to_num( amount ); 
	
	punkty[player] += expnum; 
	
	switch( get_cvar_num ( "amx_show_activity" ) ) { 
		case 1: client_print( 0, print_chat, "ADMIN: Ohh. Player %s got %i exp.", expnum, player_name ); 
		case 2: client_print( 0, print_chat, "%s add %i eXp for %s.", admin_name, expnum, player_name ); 
		} 
	
	ColorChat(player, RED, "^x04[xD Give Mode]^x01 You^x04 got^x03 %i^x04 exp^x01 (^x04Total^x01:^x03 %d^x01)", expnum, punkty[player] ); 
	SaveData( id ); 
	
	return PLUGIN_CONTINUE; 
} 

public cmd_take_ptk( id, level,cid ) { 
	if( ! cmd_access ( id, level, cid, 3 ) ) 
		return PLUGIN_HANDLED; 
	
	new target[32], amount[21], reason[21]; 
	
	read_argv( 1, target, 31 ); 
	read_argv( 2, amount, 20 ); 
	read_argv( 3, reason, 20 ); 
	
	new player = cmd_target( id, target, 8 ); 
	
	if( ! player )  
		return PLUGIN_HANDLED; 
	
	new admin_name[32], player_name[32]; 
	get_user_name( id, admin_name, 31 ); 
	get_user_name( player, player_name, 31 ); 
	
	new expnum = str_to_num( amount ); 
	
	punkty[player] -= expnum; 
	
	switch(get_cvar_num("amx_show_activity")){ 
		case 1: client_print( 0, print_chat, "ADMIN: took %i points from %s.", expnum, player_name ); 
		case 2: client_print( 0, print_chat, "%s: took %i eXp from %s.", admin_name, expnum, player_name ); 
		} 
	
	ColorChat(player, RED, "^x04[xD Take Mode]^x01 You^x03 LOST^x04 %i^x03 eXp^x01 (^x04Total^x01:^x03 %d^x01)", expnum, punkty[player] ); 
	SaveData( id ); 
	
	return PLUGIN_CONTINUE; 
}  

public respawn(id) {
	
	new losik = random_num(0,2)
	
	switch(losik)  {
		case 0:  {
			
		}
		case 1: {
			ExecuteHamB(Ham_CS_RoundRespawn, id);
			ColorChat(id, RED, "^x04[xD Respawn]^x01 You have been^x03 RESPAWNED^x04!!!");
			ColorChat(id, RED, "^x04[xD Respawn]^x01 You have been^x04 RESPAWNED^x03!!!");
			ColorChat(id, RED, "^x04[xD Respawn]^x03 You have been^x01 RESPAWNED^x04!!!");
			EventRoundStart(id);
		}
		case 2:  {
			
		}
	}
}

public forward_touch(toucher, touched) // This function is called every time a player touches another player.
{
	// NOTE: The toucher is the player standing/falling on top of the other (touched) player's head.
	if(!is_user_alive(toucher) || !is_user_alive(touched)) // The touching players can't be dead.
		return;
	
	if(!get_pcvar_num(amx_headsplash)) // If the plugin is disabled, stop messing with things.
		return;
	
	if(falling_speed[touched]) // Check if the touched player is falling. If he/she is, don't continue.
		return;
	
	if(get_user_team(toucher) == get_user_team(touched) && !get_cvar_num("mp_friendlyfire")) // If the touchers are in the same team and friendly fire is off, don't continue.
		return;
	
	new touched_origin[3], toucher_origin[3];
	get_user_origin(touched, touched_origin); // Get the origins of the players so it's possible to check if the toucher is standing on the touched's head.
	get_user_origin(toucher, toucher_origin);
	
	new Float:toucher_minsize[3], Float:touched_minsize[3];
	pev(toucher,pev_mins,toucher_minsize);
	pev(touched,pev_mins,touched_minsize); // If touche*_minsize is equal to -18.0, touche* is crouching.
	
	if(touched_minsize[2] != -18.0) // If the touched player IS NOT crouching, check if the toucher is on his/her head.
	{
		if(!(toucher_origin[2] == touched_origin[2]+72 && toucher_minsize[2] != -18.0) && !(toucher_origin[2] == touched_origin[2]+54 && toucher_minsize[2] == -18.0))
		{
			return;
		}
	}
	else // If the touched player is crouching, check if the toucher is on his/her head
	{
		if(!(toucher_origin[2] == touched_origin[2]+68 && toucher_minsize[2] != -18.0) && !(toucher_origin[2] == touched_origin[2]+50 && toucher_minsize[2] == -18.0))
		{
			return;
		}
	}
	
	if(falling_speed[toucher] >= MINIMUM_FALL_SPEED) // If the toucher is falling in the required speed or faster, then landing on top of the touched's head, do some damage to the touched. MUHAHAHAHAHA!!!
	{
		new Float:damage = ((falling_speed[toucher] - MINIMUM_FALL_SPEED + 30) * (falling_speed[toucher] - MINIMUM_FALL_SPEED + 30)) / 1300;
		if(damage > MAXIMUM_DAMAGE_FROM_JUMP) // Make shure that the touched player don't take too much damage.
			damage = MAXIMUM_DAMAGE_FROM_JUMP;
		damage_player(touched, toucher, damage); // Damage or kill the touched player.
		damage_after[toucher][touched] = 0.0; // Reset.
	}
	if(is_user_alive(touched) && damage_after[toucher][touched] <= get_gametime()) // This makes shure that you won't get damaged every frame you have some one on your head. It also makes shure that players won't get damaged faster on fast servers than laggy servers.
	{
		damage_after[toucher][touched] = get_gametime() + DELAY;
		damage_player(touched, toucher, DAMAGE); // Damage or kill the touched player.
	}
}

public forward_PlayerPreThink(id) // This is called every time before a player "thinks". A player thinks many times per second.
{
	//falling_speed[id] = entity_get_float(id, EV_FL_flFallVelocity); // Store the falling speed of the soon to be "thinking" player.
	pev(id, pev_flFallVelocity, falling_speed[id])
}

public damage_player(pwned, pwnzor, Float:damage) // Damages or kills a player. Home made HAX
{
	//new attacker = read_data ( 1 );
	//new victim = read_data(2);
	new health = get_user_health(pwned);
	if(get_user_team(pwned) == get_user_team(pwnzor)) // If both players are in the same team, reduce the damage.
		damage /= 1.4;
	new CsArmorType:armortype;
	cs_get_user_armor(pwned, armortype);
	if(armortype == CS_ARMOR_VESTHELM)
		damage *= 0.7;
	if(health >  damage)
	{
		new pwned_origin[3];
		get_user_origin(pwned, pwned_origin);
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY); // BLOOOOOOOOOOOD!!
		write_byte(TE_BLOODSPRITE);
		write_coord(pwned_origin[0]+8);
		write_coord(pwned_origin[1]);
		write_coord(pwned_origin[2]+26);
		write_short(sprite_bloodspray);
		write_short(sprite_blood);
		write_byte(248);
		write_byte(4);
		message_end();
		
		new ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "trigger_hurt"));
		if(!ent)
			return;
		new value[16];
		float_to_str(damage * 2, value, sizeof value - 1);
		set_kvd(0, KV_ClassName, "trigger_hurt");
		set_kvd(0, KV_KeyName, "dmg");
		set_kvd(0, KV_Value, value);
		set_kvd(0, KV_fHandled, 0);
		dllfunc(DLLFunc_KeyValue, ent, 0);
		num_to_str(DMG_GENERIC, value, sizeof value - 1);
		set_kvd(0, KV_ClassName, "trigger_hurt");
		set_kvd(0, KV_KeyName, "damagetype");
		set_kvd(0, KV_Value, value);
		set_kvd(0, KV_fHandled, 0);
		dllfunc(DLLFunc_KeyValue, ent, 0);
		set_kvd(0, KV_ClassName, "trigger_hurt");
		set_kvd(0, KV_KeyName, "origin");
		set_kvd(0, KV_Value, "8192 8192 8192");
		set_kvd(0, KV_fHandled, 0);
		dllfunc(DLLFunc_KeyValue, ent, 0);
		dllfunc(DLLFunc_Spawn, ent);
		set_pev(ent, pev_classname, "head_splash");
		dllfunc(DLLFunc_Touch, ent, pwned);
		engfunc(EngFunc_RemoveEntity, ent);
	}
	else
	{
		new pwned_origin[3];
		get_user_origin(pwned, pwned_origin);
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY); // BLOOOOOOOOOOOD!!
		write_byte(TE_BLOODSPRITE);
		write_coord(pwned_origin[0]+8);
		write_coord(pwned_origin[1]);
		write_coord(pwned_origin[2]+26);
		write_short(sprite_bloodspray);
		write_short(sprite_blood);
		write_byte(248);
		write_byte(12);
		message_end();
		
		set_pev(pwned, pev_frags, float(get_user_frags(pwned) + 1));
		user_silentkill(pwned);
		make_deathmsg(pwnzor, pwned, 1, "his/her feet :)");
		

		if (get_user_flags(pwnzor) && ADMIN_RESERVATION) {
			if(PlayerXP[pwnzor] < PlayerXP[pwned]){
				
				PlayerXP[pwnzor] += 7;
				PlayerXP[pwnzor] += 10;
				PlayerXP[pwnzor] += 5;
				ColorChat(pwnzor, RED, "^x04[xD eXperience Mod]^x01 You got^x03 more^x04 exp^x01 for^x03 killing^x01 a player with^x04 Head^x03 Splash");
				//UpdateHUD(attacker);
			}
			else 
			{
				PlayerXP[pwnzor] += 7;
				PlayerXP[pwnzor] += 5;
				ColorChat(pwnzor, RED, "^x04[xD eXperience Mod]^x01 You got^x03 more^x04 exp^x01 for^x03 killing^x01 a player with^x04 Head^x03 Splash");
				//UpdateHUD(attacker);
			}
		}
		
		else 
		{
			if(PlayerLevel[pwnzor] < PlayerLevel[pwned]){
				
				PlayerXP[pwnzor] += 7
				PlayerXP[pwnzor] += 10;
				ColorChat(pwnzor, RED, "^x04[xD eXperience Mod]^x01 You got^x03 more^x04 exp^x01 for^x03 killing^x01 a player with^x04 Head^x03 Splash");
				//UpdateHUD(attacker);
			}
			else 
			{
				PlayerXP[pwnzor] += 7
				ColorChat(pwnzor, RED, "^x04[xD eXperience Mod]^x01 You got^x03 more^x04 exp^x01 for^x03 killing^x01 a player with^x04 Head^x03 Splash");
				//UpdateHUD(attacker);
			}
		}
		
		while(PlayerXP[pwnzor] >= LEVELS[PlayerLevel[pwnzor]]) { 
			ColorChat(pwnzor, RED, "[EXP MOD]^x01 Congratulations! You pocket^x03 %i^x01 level, type^x03 /menu^x01 to take^x03 advantage^x01 of the^x04 point.", PlayerLevel[pwnzor + 1]);
			PlayerLevel[pwnzor] += 1; 
			punkty[pwnzor] += 1;
			//UpdateHUD(pwnzor);
		} 
		
		if(get_user_team(pwnzor) != get_user_team(pwned)) // If it was a team kill, the pwnzor's money should get reduced instead of increased.
		{
			set_pev(pwnzor, pev_frags, float(get_user_frags(pwnzor) + 1));
			cs_set_user_money(pwnzor, cs_get_user_money(pwnzor) + 300);
			
		}
		else
		{
			set_pev(pwnzor, pev_frags, float(get_user_frags(pwnzor) - 1));
			cs_set_user_money(pwnzor, cs_get_user_money(pwnzor) - 300);
			
		}
		
		message_begin(MSG_ALL, get_user_msgid("ScoreInfo")); // Fixes the scoreboard.
		write_byte(pwnzor);
		write_short(get_user_frags(pwnzor));
		write_short(cs_get_user_deaths(pwnzor));
		write_short(0);
		write_short(get_user_team(pwnzor));
		message_end();
		
		message_begin(MSG_ALL, get_user_msgid("ScoreInfo"));
		write_byte(pwned);
		write_short(get_user_frags(pwned));
		write_short(cs_get_user_deaths(pwned));
		write_short(0);
		write_short(get_user_team(pwned));
		message_end();
		set_pev(pwned, pev_frags, float(get_user_frags(pwned) - 1));
		
		SaveData(pwnzor);
		//UpdateHUD(pwnzor);
	}
}
