#include <amxmodx>
#include <amxmisc>
#include <nvault>
#include <hamsandwich>
#include <cstrike>
#include <fun>
#include <fakemeta>

//#include <colorchat>

const gItemAmount = 16;

new gMoneyVault;
new gJBPoints[33];

new bool:gHasKatana[33];
new bool:gHasKnife[33];

new bool:gBoughtMac10[33];
new bool:gBoughtTMP[33];
new bool:gBoughtDeagle[33];
new bool:gBoughtFrag[33];
new bool:gBoughtFlash[33];
new bool:gBoughtSmoke[33];
new bool:gBoughtRambo[33];
new bool:gBoughtRegeneration[33];
new bool:gBoughtM4[33];
new bool:gBoughtSpeed[33];
new bool:gBoughtDoubleDamage[33];
new bool:gBoughtShield[33];

new gKnifeType[33];

new gChosenPlayer[33];

new gAdminControl[33];

new gpShopCvars[gItemAmount];

new Float:gMaxSpeed[33];


new gTotalBets[3];
new gBettingPot[3];

new gBetAmount[33];
new gBetTeam[33];
new bool:gBetted[33];

new bool:gBetCT;
new bool:gBetT;


new const gCvarNames[gItemAmount][] = 
{
	"katana",
	"proknife",
	"mac10",
	"tmp",
	"deagle",
	"health",
	"armor",
	"frag",
	"flashbang",
	"smoke",
	"rambo",
	"regen",
	"m4200hp",
	"speed",
	"doubledamage",
	"shield"
};

new const gCvarAmounts[gItemAmount][] = 
{
	"45000",
	"25000",
	"3200",
	"3200",
	"4000",
	"2000",
	"800",
	"1000",
	"500",
	"500",
	"10000",
	"1000",
	"8000",
	"1200",
	"3000",
	"1000"
	
}

new const gItemNames[gItemAmount][] = 
{
	"Katana Knife",
	"Professional Knife",
	"Mac-10",
	"TMP",
	"Deagle",
	"+100 HP",
	"+100 AP",
	"HE Grenade",
	"Flashbang",
	"Smoke Grenade",
	"Flying Rambo",
	"Health Regeneration",
	"M4A1 + 200 HP",
	"Faster Speed",
	"Double Damage",
	"Shield"
};

new const gPlayerModels[3][] = 
{
	"models/p_katana.mdl",
	"models/p_knife.mdl",
	"models/p_knife.mdl"
};

new const gViewModels[3][] = 
{
	"models/v_katana.mdl",
	"models/v_proff.mdl",
	"models/v_knife.mdl"
};

new const gVaultFile[] = "addons/amxmodx/data/vault/jb_shop.vault";

enum
{
	KATANA,
	KNIFE,
	MAC,
	TMP,
	DEAGLE,
	HP,
	AP,
	HE,
	FLASH,
	SMOKE,
	RAMBO,
	REGENERATION,
	M4,
	SPEED,
	DOUBLE_DAMAGE,
	SHIELD
};

enum
{
	KATANA,
	KNIFE,
	DEFAULT
};

enum
{
	CT = 1,
	T
}

enum
{
	GIVE,
	TAKE
}

new gpHeadshotReward;
new gpKillReward;
new gpKatanaReward;

new gpRamboHealth;

public plugin_init()
{
	register_plugin( "Jailbreak Shop", "1.0", "H3avY Ra1n" );
	
	register_event( "DeathMsg", "Event_DeathMsg", "a" );
	register_event( "CurWeapon", "Event_CurWeapon", "be", "1=1" );
	
	register_event("SendAudio", "TerroristsWin", "a", "2&%!MRAD_terwin")
	register_event("SendAudio", "CTsWin", "a", "2&%!MRAD_ctwin")
	register_event("SendAudio", "RoundDraw", "a", "2&%!MRAD_rounddraw")
	
	register_concmd( "amx_jbshop", "CmdAdminControl" );
	
	register_clcmd( "say", "CmdSay" );
	register_clcmd( "say_team", "CmdSay" );
	
	register_clcmd( "_amount_take", "CmdTake" );
	register_clcmd( "_amount_give", "CmdGive" );
	
	register_logevent( "Event_RoundEvent", 2, "1=Round_Start" );
	
	RegisterHam( Ham_Spawn, "player", "Event_PlayerSpawn", 1 );
	RegisterHam( Ham_TakeDamage, "player", "Event_TakeDamage", 0 );
	
	new buffer[32];
	for( new i = 0; i < gItemAmount; i++ )
	{
		formatex( buffer, 31, "jb_%s_cost", gCvarNames[i] );
		gpShopCvars[i] = register_cvar( buffer, gCvarAmounts[i] );
	}
	
	gpHeadshotReward 	= 		register_cvar( 	"jb_headshot_reward", 	"100" 	);
	gpKillReward 		= 		register_cvar( 	"jb_kill_reward", 		"200" 	);
	gpRamboHealth 		= 		register_cvar( 	"jb_rambo_health", 		"150" 	);
	gpKatanaReward 		= 		register_cvar( 	"jb_katana_reward", 	"400" 	);
	
	gMoneyVault 		= 		nvault_open( "jb_shop" );
}

public plugin_end()
{
	nvault_close( gMoneyVault );
}

public plugin_precache()
{
	for( new i = 0; i < 3; i++ )
	{
		precache_model( gPlayerModels[i] );
		precache_model( gViewModels[i] );
	}
	
	return PLUGIN_HANDLED;
}

public CmdSay( id )
{
	new message[256];
	read_args( message, 255 );
	
	remove_quotes( message );
	
	if( equal( message, "/knife" ) )
	{
		CmdKnife( id );
	}
	
	else if( equal( message, "/jbshop" ) || equal( message, "/shop" ) )
	{
		if( cs_get_user_team( id ) == CS_TEAM_T )
			CmdShop( id );
		
		else
			ChatColor( id, "^04JailBreak Shop -> ^03You must be a ^04Terrorist ^03to use the shop." );
		{
			
			//ColorChat( id, GREEN, "JailBreak Shop -> ^01You must be a ^03Terrorist ^01to use the shop." );
			return PLUGIN_HANDLED;
		}
	}
	
	else if( equal( message, "/top10" ) )
		CmdTop10( id );
	
	else if( equal( message, "/reset" ) )
		CmdReset( id );
	
	else if( message[0] == '/' && message[1] == 'c' && message[2] == 'a' && message[3] == 's' && message[4] == 'h' )
	{
		new command[32], name[32];
		
		parse( message, command, 31, name, 31 );
		
		new target = cmd_target( id, name, 0 );
		
		if( equal( name, "" ) ) target = id;
		
		if( !is_user_connected( target ) )
		{
			ChatColor( id, "^04JailBreak Shop -> ^03That is not a valid player!" );
			return PLUGIN_HANDLED;
		}
		
		else
		{
			new name[32];
			get_user_name( target, name, 31 );
			
			if( target == id )
			{
				ChatColor( id, "^04JailBreak Shop -> ^03You have ^04> %i JB$ <", gJBPoints[target] );
				
				//ColorChat( id, GREEN, "JailBreak Shop -> ^01You have > %i JB$ ^01<", gJBPoints[target] );
				
				new players[32], num;
				get_players( players, num );
				
				new player;
				
				for( new i = 0; i < num; i++ )
				{
					player = players[i];
					
					if( player == id )
						continue;
					
					ChatColor( player, "^04JailBreak Shop -> ^04%s ^03has ^04> ^%i JB$ <", name, gJBPoints[target] );
					
					//ColorChat( player, GREEN, "JailBreak Shop -> ^03%s ^01has > ^04%i JB$ ^01<", name, gJBPoints[target] );
				}
			}
			
			else ChatColor( 0, "^04JailBreak Shop -> ^04%s ^03has ^04> %i JB$ <", name, gJBPoints[target] );
			
			
			return PLUGIN_HANDLED;
		}
	}
	
	else if( message[0] == '/' && message[1] == 't' && message[2] == 'r' && message[3] == 'a' && message[4] == 'n' && message[5] == 's' && message[6] == 'f' && message[7] == 'e' && message[8] == 'r' )
	{
		new command[32], name[32], amount[32];
		
		parse( message, command, 31, name, 31, amount, 31 );
		
		new target = cmd_target( id, name, 0 );
		
		if( !is_user_connected( target ) )
		{
			ChatColor( id, "^04JailBreak Shop -> ^03That is not a valid player!" );
			//ColorChat( id, GREEN, "JailBreak Shop -> ^01That is not a valid player!" );
			return PLUGIN_HANDLED;
		}
		
		else
		{
			remove_quotes( amount );
			
			if( !is_str_num( amount ) )
			{
				ChatColor( id, "^04JailBreak Shop -> ^03That is not a valid amount!" );
				//ColorChat( id, GREEN, "JailBreak Shop -> ^01That is not a valid amount!" );
				return PLUGIN_HANDLED;
			}
			
			
			new amount2 = str_to_num( amount );
			
			if( amount2 > gJBPoints[id] )
			{
				ChatColor( id, "^04JailBreak Shop -> ^03You do not have that many ^04JB $^03." );
				//ColorChat( id, GREEN, "JailBreak Shop -> ^01You do not have that many ^04JB $^01." );
				return PLUGIN_HANDLED;
			}
			
			else if( amount2 < 0 )
			{
				ChatColor( id, "^04JailBreak Shop -> ^03You cannot transfer a negative amount!" );
				
				//ColorChat( id, GREEN, "JailBreak Shop -> ^01You cannot transfer a negative amount!" );
				return PLUGIN_HANDLED;
			}
			
			new targetName[32];
			get_user_name( target, targetName, 31 );
			
			new playerName[32];
			get_user_name( id, playerName, 31 );
			
			gJBPoints[target] += amount2;
			gJBPoints[id] -= amount2;
			
			ChatColor( 0, "JailBreak Shop -> ^04%s ^03transferred ^04%i JB$ ^03to ^04%s^03.", playerName, amount2, targetName );
			//ColorChat( 0, GREEN, "JailBreak Shop -> ^03%s ^01transferred %i ^04JB$ ^01to ^03%s^01.", playerName, amount2, targetName );
		}
		
		return PLUGIN_CONTINUE;
	}
	
	else if( message[0] == '/' && message[1] == 'g' && message[2] == 'a' && message[3] == 'm' && message[4] == 'b' && message[5] == 'l' && message[6] == 'e' )
	{
		new command[32], amount[32];
		parse( message, command, 31, amount, 31 );
		
		remove_quotes( amount );
		
		if( !is_str_num( amount ) )
		{
			ChatColor( id, "^04JailBreak Shop -> ^03That is not a valid amount!" );
			return PLUGIN_HANDLED;
		}
		
		new amount2 = str_to_num( amount );
		
		if( amount2 > gJBPoints[id] )
		{
			ChatColor( id, "^04JailBreak Shop -> ^03You don't have that much to gamble!" );
			return PLUGIN_HANDLED;
		}
		
		if( amount2 < 0 )
		{
			ChatColor( id, "^04JailBreak Shop -> ^03That is not a valid amount!" );
			//ColorChat( id, GREEN, "JailBreak Shop -> ^01That is not a valid amount!" );
			return PLUGIN_HANDLED;
		}
		
		new rand = random_num( 0, 1 );
		
		if( rand == 0 )
		{
			gJBPoints[id] += amount2;
			ChatColor( id, "^04JailBreak Shop -> ^03Congratulations! You won ^04%i JB$^03!", amount2 );
		}
		
		else
		{
			gJBPoints[id] -= amount2;
			ChatColor( id, "^04JailBreak Shop -> ^03Sorry, you lost ^04%i JB$ ^03.", amount2 );
		}
		
		return PLUGIN_HANDLED;
	}
	
	else if( message[0] == '/' && message[1] == 'b' && message[2] == 'e' && message[3] == 't' )
	{
		new command[32], team[32], amount[6];
		
		parse( message, command, 31, team, 31, amount, 5 );
		
		remove_quotes( amount );
		
		if( gBetted[id] )
		{
			ChatColor( id, "^04JailBreak Shop -> ^03You have already bet this round!" );
			return PLUGIN_HANDLED;
		}
		
		if( !is_str_num( amount ) )
		{
			ChatColor( id, "^04JailBreak Shop -> ^03That is not a valid amount!" );
			return PLUGIN_HANDLED;
		}
		
		if( !equali( team, "t" ) && !equali( team, "CT" ) )
		{
			ChatColor( id, "^04JailBreak Shop -> ^03That is not a valid team!" );
			return PLUGIN_HANDLED;
		}
		
		new amount2 = str_to_num( amount );
		
		if( amount2 > gJBPoints[id] )
		{
			ChatColor( id, "^04JailBreak Shop -> ^03You don't have that much to bet!" );
			return PLUGIN_HANDLED;
		}
		
		if( amount2 < 0 )
		{
			ChatColor( id, "^04JailBreak Shop -> ^03That is not a valid amount!" );
			//ColorChat( id, GREEN, "JailBreak Shop -> ^01That is not a valid amount!" );
			return PLUGIN_HANDLED;
		}
		
		gJBPoints[id] -= amount2;
		
		gBetAmount[id] = amount2;
		
		gBetted[id] = true;
		
		if( equali( team, "t" ) )
		{
			gBetTeam[id] = T;
			gBettingPot[T] += amount2;
			gTotalBets[T]++;
			
			gBetT = true;
		}
		
		else 
		{
			gBetTeam[id] = CT;
			gBettingPot[CT] += amount2;
			gTotalBets[CT]++;
			
			gBetCT = true;
		}
		
		new name[32];
		get_user_name( id, name, 31 );
		
		ChatColor( 0, "^04JailBreak Shop -> %s ^03bet ^04%i JB$ ^03on the %s. The pot for them is now ^04%i JB$^03.", name, amount2, ( gBetTeam[id] == T ) ? "Terrorists" : "CTs", gBettingPot[ gBetTeam[id] ] );
		
		return PLUGIN_HANDLED;
	}
	
	
	return PLUGIN_CONTINUE;
}

public Event_CurWeapon( id )
{
	if( gBoughtSpeed[id] )
	{
		set_user_maxspeed( id, gMaxSpeed[id] );
	}
	
	if( !gHasKatana[id] && !gHasKnife[id] )
		return PLUGIN_CONTINUE;
	
	if( get_user_weapon( id ) != CSW_KNIFE )
		return PLUGIN_CONTINUE;
	
	set_pev( id, pev_weaponmodel2,  gPlayerModels[ gKnifeType[id] ] );
	set_pev( id, pev_viewmodel2, gViewModels[ gKnifeType[id] ] );
	
	return PLUGIN_CONTINUE;
}

public Event_PlayerSpawn( id )
{
	if( !is_user_alive( id ) )
		return HAM_IGNORED;
	
	if( get_user_noclip( id ) )
		set_user_noclip( id, 0 );
	
	if( cs_get_user_team( id ) == CS_TEAM_T )
	{
		strip_user_weapons( id );
		give_item( id, "weapon_knife" );
	}
	
	return HAM_HANDLED;
}

public Event_TakeDamage( victim, inflictor, attacker, Float:damage, damagebits )
{
	if( !is_user_connected( attacker ) || !is_user_connected( victim ) )
		return HAM_IGNORED;
	
	if( !gBoughtDoubleDamage[attacker] )
		return HAM_IGNORED;
	
	SetHamParamFloat( 4, damage * 2 );
	
	return HAM_HANDLED;
}

public Event_RoundEvent()
{
	for( new i = 0; i < sizeof( gBoughtDeagle ); i++ )
	{
		gBoughtDeagle[i] = false;
		gBoughtFlash[i] = false;
		gBoughtFrag[i] = false;
		gBoughtMac10[i] = false;
		gBoughtRambo[i] = false;
		gBoughtSmoke[i] = false;
		gBoughtTMP[i] = false;
		gBoughtRegeneration[i] = false;
		gBoughtM4[i] = false;
		gBoughtSpeed[i] = false;
		gBoughtShield[i] = false;
		gBetAmount[i] = 0;
		gBetted[i] = false;
		gBetTeam[i] = 0;
		
	}
	
	gTotalBets[T] = 0;
	gTotalBets[CT] = 0;
	gBettingPot[T] = 0;
	gBettingPot[CT] = 0;
	
	gBetCT = false;
	gBetT = false;
}

public client_disconnect( id )
{
	SaveData( id );
	
	gJBPoints[id] = 0;
	
	gBoughtDeagle[id] = false;
	gBoughtFlash[id] = false;
	gBoughtFrag[id] = false;
	gBoughtMac10[id] = false;
	gBoughtRambo[id] = false;
	gBoughtSmoke[id] = false;
	gBoughtTMP[id] = false;
	gBoughtRegeneration[id] = false;
	gBoughtM4[id] = false;
	gBoughtSpeed[id] = false;
	gBoughtDoubleDamage[id] = false
	gBoughtShield[id] = false;
	gBetAmount[id] = 0;
	
	
	gHasKatana[id] = false;
	gHasKnife[id] = false;
}

public client_putinserver( id )
{
	gJBPoints[id] = 0;
	
	LoadData( id );
}

public Event_DeathMsg()
{
	new victim = read_data( 2 );
	new killer = read_data( 1 );
	new headshot = read_data( 3 );
	
	if( !is_user_connected( killer ) || !is_user_connected( victim ) )
		return PLUGIN_HANDLED;
	
	if( gBoughtDoubleDamage[victim] )
		gBoughtDoubleDamage[victim] = false;
	
	if( cs_get_user_team( killer ) != CS_TEAM_T )
		return PLUGIN_HANDLED;
	
	if( gKnifeType[killer] == KATANA )
	{
		gJBPoints[killer] += get_pcvar_num( gpKatanaReward );
		return PLUGIN_CONTINUE;
	}
	
	gJBPoints[killer] += get_pcvar_num( gpKillReward );
	
	if( headshot )
		gJBPoints[killer] += get_pcvar_num( gpHeadshotReward );
	
	return PLUGIN_HANDLED;
}

public CmdShop( id )
{
	new menuTitle[64];
	formatex( menuTitle, charsmax( menuTitle ), "Jailbreak Shop: [%i JB$]", gJBPoints[id] );
	
	new menu = menu_create( menuTitle, "ShopMenu_Handler" );
	
	new buffer[256], info[6];
	
	for( new i = 0; i < gItemAmount; i++ )
	{
		formatex( buffer, charsmax( buffer ), "\y%s \w[JB \y%i\w]", gItemNames[i], get_pcvar_num( gpShopCvars[i] ) );
		num_to_str( i, info, 5 );
		menu_additem( menu, buffer, info );
	}
	
	menu_display( id, menu, 0 );
}

public ShopMenu_Handler( id, menu, item )
{
	if( item == MENU_EXIT )
	{
		menu_destroy( menu );
		return PLUGIN_HANDLED;
	}
	
	if( !is_user_alive( id ) )
	{
		client_print( id, print_chat, "JailBreak Shop -> You cannot buy something when you are dead!" );
		return PLUGIN_HANDLED;
	}
	
	new data[6], szName[64];
	new access, callback;
	
	menu_item_getinfo( menu, item, access, data, 5, szName, 63, callback );
	
	new key = str_to_num( data );
	
	new cost = get_pcvar_num( gpShopCvars[key] );
	
	if( gJBPoints[id] < cost )
	{
		ChatColor( id, "^04JailBreak Shop -> ^03You do not have enough ^04JB$ ^03to buy this item." );
		return PLUGIN_HANDLED;
	}
	
	switch( key )
	{
		case KATANA: 
		{
			if( gHasKatana[id] )
			{
				ChatColor( id, "^04JailBreak Shop -> ^03You already have that!" );
				
				//ColorChat( id, GREEN, "JailBreak Shop -> ^01You already have that!" );
				return PLUGIN_HANDLED;
			}
			
			gHasKatana[id] = true;
			
			set_pev( id, pev_viewmodel2, gViewModels[KATANA] );
			set_pev( id, pev_weaponmodel2, gPlayerModels[KATANA] );
		}
		
		case KNIFE: 
		{
			if( gHasKnife[id] )
			{
				ChatColor( id, "^04JailBreak Shop -> ^03You already have that!" );
				//ColorChat( id, GREEN, "JailBreak Shop -> ^01You already have that!" );
				return PLUGIN_HANDLED;
			}
			
			gHasKnife[id] = true;
			
			set_pev( id, pev_viewmodel2, gViewModels[KNIFE] );
			set_pev( id, pev_weaponmodel2, gPlayerModels[KNIFE] );
		}
		
		case MAC:
		{
			if( gBoughtMac10[id] )
			{
				ChatColor( id, "^04JailBreak Shop -> ^03You already have that!" );
				//ColorChat( id, GREEN, "JailBreak Shop -> ^01You already have that!" );
				return PLUGIN_HANDLED;
			}
			
			gBoughtMac10[id] = true;
			
			give_item( id, "weapon_mac10" );
			cs_set_user_bpammo( id, CSW_MAC10, 30 );
		}
		
		case TMP:
		{
			if( gBoughtTMP[id] )
			{
				ChatColor( id, "^04JailBreak Shop -> ^03You already have that!" );
				//ColorChat( id, GREEN, "JailBreak Shop -> ^01You already have that!" );
				return PLUGIN_HANDLED;
			}
			
			
			gBoughtTMP[id] = true;
			
			give_item( id, "weapon_tmp" );
			cs_set_user_bpammo( id, CSW_TMP, 30 );
		}
		
		case DEAGLE:
		{
			if( gBoughtDeagle[id] )
			{
				ChatColor( id, "^04JailBreak Shop -> ^03You already have that!" );
				//ColorChat( id, GREEN, "JailBreak Shop -> ^01You already have that!" );
				return PLUGIN_HANDLED;
			}
			
			gBoughtDeagle[id] = true;
			
			give_item( id, "weapon_deagle" );
			cs_set_user_bpammo( id, CSW_DEAGLE, 14 );
		}
		
		case HP:
		{
			new hp = get_user_health( id );
			
			
			if( hp == 500 )
			{
				ChatColor( id, "^04JailBreak Shop -> ^03You already have the ^04max health^03." );
				
				//ColorChat( id, GREEN, "JailBreak Shop -> ^01You already have the ^03max health^01." );
				
				return PLUGIN_HANDLED;
			}
			
			else if( hp + 100 > 500 )
			{
				set_user_health( id, 500 );
			}
			
			else
			{
				set_user_health( id, hp + 100 );
			}
		}
		
		case AP:
		{
			new ap = get_user_armor( id );
			
			if( ap == 500 )
			{
				ChatColor( id, "^04JailBreak Shop -> ^03You already have the ^04max armor^03." );
				
				//ColorChat( id, GREEN, "JailBreak Shop -> ^01You already have the ^03max armor^01." );
				return PLUGIN_HANDLED;
			}
			
			else if( ap + 100 > 500 )
			{
				set_user_armor( id, 500 );
			}
			
			else set_user_armor( id, ap + 100 );
			
		}
		
		case HE:
		{
			if( gBoughtFrag[id] )
			{
				ChatColor( id, "^04JailBreak Shop -> ^03You already have that!" );
				//ColorChat( id, GREEN, "JailBreak Shop -> ^01You already have that!" );
				return PLUGIN_HANDLED;
			}
			
			gBoughtFrag[id] = true;
			
			give_item( id, "weapon_hegrenade" );
		}
		
		case FLASH:
		{
			if( gBoughtFlash[id] )
			{
				ChatColor( id, "^04JailBreak Shop -> ^03You already have that!" );
				//ColorChat( id, GREEN, "JailBreak Shop -> ^01You already have that!" );
				return PLUGIN_HANDLED;
			}
			
			gBoughtFlash[id] = true;
			
			give_item( id, "weapon_flashbang" );
		}
		
		case SMOKE:
		{
			if( gBoughtSmoke[id] )
			{
				ChatColor( id, "^04JailBreak Shop -> ^03You already have that!" );
				//ColorChat( id, GREEN, "JailBreak Shop -> ^01You already have that!" );
				return PLUGIN_HANDLED;
			}
			
			gBoughtSmoke[id] = true;
			
			give_item( id, "weapon_smokegrenade" );
		}
		
		case RAMBO:
		{
			if( gBoughtRambo[id] )
			{
				ChatColor( id, "^04JailBreak Shop -> ^03You already have that!" );
				//ColorChat( id, GREEN, "JailBreak Shop -> ^01You already have that!" );
				return PLUGIN_HANDLED;
			}
			
			
			new players[32], num;
			get_players( players, num, "ae", "CT" );
			
			set_user_health( id, num * get_pcvar_num( gpRamboHealth ) );
			
			set_user_noclip( id, 1 );
			
			give_item( id, "weapon_m4a1" );
			
		}
		
		case REGENERATION:
		{
			if( gBoughtRegeneration[id] )
			{
				ChatColor( id, "^04JailBreak Shop -> ^03You already bought that this round!" );
				
				//ColorChat( id, GREEN, "JailBreak Shop -> ^01You already bought that this round!" );
				return PLUGIN_HANDLED;
			}
			
			if( get_user_health( id ) >= 100 )
			{
				ChatColor( id, "^04JailBreak Shop -> ^03You already have 100+ HP!" );
				
				//ColorChat( id, GREEN, "JailBreak Shop -> ^01You already have more hp!" );
				return PLUGIN_HANDLED;
			}
			
			set_user_health( id, 100 );
		}
		
		case M4:
		{
			if( gBoughtM4[id] )
			{
				ChatColor( id, "^04JailBreak Shop -> ^03You already have that!" );
				//ColorChat( id, GREEN, "JailBreak Shop -> ^01You already bought that this round!" );
				return PLUGIN_HANDLED;
			}
			
			if( get_user_health( id ) < 200 )
			{
				set_user_health( id, 200 );
			}
			
			give_item( id, "weapon_m4a1" );
			cs_set_user_bpammo( id, CSW_M4A1, 90 );
			
		}
		
		case SPEED:
		{
			if( gBoughtSpeed[id] )
			{
				ChatColor( id, "^04JailBreak Shop -> ^03You already have that!" );
				//ColorChat( id, GREEN, "JailBreak Shop -> ^01You already bought that item this round." );
				return PLUGIN_HANDLED;
			}
			
			
			new Float:maxspeed = get_user_maxspeed( id ) + 80.0;
			
			set_user_maxspeed( id, maxspeed );
			
			gBoughtSpeed[id] = true;
			
			gMaxSpeed[id] = maxspeed;
		}
		
		case DOUBLE_DAMAGE:
		{
			if( gBoughtDoubleDamage[id] )
			{
				ChatColor( id, "^04JailBreak Shop -> ^03You already have that!" );
				//ColorChat( id, GREEN, "JailBreak Shop -> ^01You already bought that item this round." );
				return PLUGIN_HANDLED;
			}
			
			gBoughtDoubleDamage[id] = true;
		}
		
		case SHIELD:
		{
			if( gBoughtShield[id] )
			{
				ChatColor( id, "^04JailBreak Shop -> ^03You already have that!" );
				//ColorChat( id, GREEN, "JailBreak Shop -> ^01You already bought that item this round." );
				return PLUGIN_HANDLED;
			}
			
			gBoughtShield[id] = true;
			
			give_item( id, "weapon_shield" );
		}
		
	}
	
	gJBPoints[id] -= cost;
	
	ChatColor( id, "^04JailBreak Shop -> ^03You have successfully bought ^04%s^03.", gItemNames[key] );
	//ColorChat( id, GREEN, "JailBreak Shop -> ^01You have successfully bought ^03%s^01.", gItemNames[key] );
	
	return PLUGIN_HANDLED;
}

public CmdKnife( id )
{
	if( !gHasKatana[id] && !gHasKnife[id] )
	{
		ChatColor( id, "^04JailBreak Shop -> ^03You must buy one of the knives from the ^04shop ^03to use this command." );
		//ColorChat( id, GREEN, "JailBreak Shop -> ^01You must buy one of the knives from the ^03shop ^01to use this command." );
		return PLUGIN_HANDLED;
	}
	
	new menu = menu_create( "Choose Knife Model:", "KnifeMenu_Handler" );
	
	menu_additem( menu, "Katana Knife", "0" );
	menu_additem( menu, "Professional Knife", "1" );
	menu_additem( menu, "Default Skin", "2" );
	
	menu_display( id, menu, 0 );
	
	return PLUGIN_HANDLED;
}

public KnifeMenu_Handler( id, menu, item )
{
	new access, callback;
	new data[6], szName[64];
	
	menu_item_getinfo( menu, item, access, data, 5, szName, 63, callback );
	
	new key = str_to_num( data );
	
	switch( key )
	{
		case KNIFE:
		{
			if( !gHasKnife[id] )
			{
				ChatColor( id, "^04JailBreak Shop -> ^03You have not yet bought that knife from the ^04shop^03." );
				
				//ColorChat( id, GREEN, "JailBreak Shop -> ^01You have not yet bought that knife from the ^03shop^01." );
				return PLUGIN_HANDLED;
			}
		}
		
		case KATANA:
		{
			if( !gHasKatana[id] )
			{
				ChatColor( id, "^04JailBreak Shop -> ^03You have not yet bought that knife from the ^04shop^03." );
				//ColorChat( id, GREEN, "JailBreak Shop -> ^01You have not yet bought that knife from the ^03shop^01." );
				return PLUGIN_HANDLED;
			}
		}
	}
	
	gKnifeType[id] = str_to_num( data );
	
	if( get_user_weapon( id ) == CSW_KNIFE )
	{
		set_pev( id, pev_viewmodel2, gViewModels[ gKnifeType[id] ] );
		set_pev( id, pev_weaponmodel2, gPlayerModels[ gKnifeType[id] ] );
	}
	
	return PLUGIN_HANDLED;
}

public CmdAdminControl( id )
{
	if( !( get_user_flags( id ) & ADMIN_IMMUNITY ) )
	{
		console_print( id, "JailBreak Shop -> You are not an admin." );
		return PLUGIN_HANDLED;
	}
	
	new menu = menu_create( "Admin Control:", "AdminMenu_Handler" );
	
	menu_additem( menu, "Reset All Shop Data", "120" );
	menu_additem( menu, "Take Points Away", "1" );
	menu_additem( menu, "Give Points", "0" );
	
	menu_display( id, menu, 0 );
	
	return PLUGIN_HANDLED;
}

public AdminMenu_Handler( id, menu, item )
{
	new access, callback;
	new data[6], szName[64];
	
	menu_item_getinfo( menu, item, access, data, 5, szName, 63, callback );
	
	new key = str_to_num( data );
	
	switch( key )
	{
		case 120:
		{
			if( file_exists( gVaultFile ) )
			{
				nvault_close( gMoneyVault );
				delete_file( gVaultFile );
			}
			
			new players[32], num;
			get_players( players, num );
			
			new name[32];
			get_user_name( id, name, 31 );
			
			ChatColor( 0, "^04JailBreak Shop -> ^03ADMIN ^04%s ^03deleted all shop data.", name );
			
			gMoneyVault = nvault_open( "jb_shop" );
			
			for( new i = 0; i < num; i++ )
			{
				LoadData( players[i] );
			}
			
			menu_destroy( menu );
			return PLUGIN_HANDLED;
		}
		
	}
	
	gAdminControl[id] = key;
	
	ShowPlayerMenu( id );
	
	menu_destroy( menu );
	
	
	return PLUGIN_HANDLED;
}

public ShowPlayerMenu( id )
{
	new menu = menu_create( "Choose a Player:", "PlayerMenu_Handler" );
	
	new players[32], num;
	get_players( players, num );
	
	new name[32], data[6];
	
	new player;
	
	for( new i = 0; i < num; i++ )
	{
		player = players[i];
		get_user_name( player, name, 31 );
		
		num_to_str( player, data, 5 );
		
		menu_additem( menu, name, data );
	}
	
	menu_display( id, menu, 0 );
}

public PlayerMenu_Handler( id, menu, item )
{
	new access, callback;
	new data[6], szName[64];
	
	menu_item_getinfo( menu, item, access, data, 5, szName, 63, callback );
	
	new player = str_to_num( data );
	
	if( !is_user_connected( player ) )
	{
		client_print( id, print_chat, "JailBreak Shop -> That is no longer a valid player." );
		menu_destroy( menu );
		
		ShowPlayerMenu( id );
		return PLUGIN_HANDLED;
	}
	
	gChosenPlayer[id] = player;
	
	switch( gAdminControl[id] )
	{
		case GIVE: client_cmd( id, "messagemode _amount_give" );
		case TAKE: client_cmd( id, "messagemode _amount_take" );
	}
	
	menu_destroy( menu );
	
	return PLUGIN_HANDLED;
}

public CmdTake( id )
{
	if( !( get_user_flags( id ) & ADMIN_IMMUNITY ) )
	{
		ChatColor( id, "^04JailBreak Shop -> ^03You are not an admin." );
		
		//ColorChat( id, GREEN, "JailBreak Shop -> ^01You are not an admin." );
		return PLUGIN_HANDLED;
	}
	
	new message[256];
	read_args( message, 255 );
	
	remove_quotes( message );
	if( !is_str_num( message ) )
	{
		ChatColor( id, "^04JailBreak Shop -> ^03That is not a valid number." );
		
		//ColorChat( id, GREEN, "JailBreak Shop -> ^01That is not a valid number." );
		return PLUGIN_HANDLED;
	}
	
	new amount = str_to_num( message );
	
	if( gJBPoints[ gChosenPlayer[id] ] >= amount )
		gJBPoints[ gChosenPlayer[id] ] -= amount;
	
	else gJBPoints[ gChosenPlayer[id] ] = 0;
	
	new playerName[32];
	get_user_name( gChosenPlayer[id], playerName, 31 );
	
	ChatColor( id, "^04JailBreak Shop -> ^03You took away ^04%i JB $ ^03from ^04%s^03.", amount, playerName );
	//ColorChat( id, GREEN, "JailBreak Shop -> ^01You took away %i ^04JB $ ^01from ^03%s^01.", amount, playerName );
	
	return PLUGIN_HANDLED;
}

public CmdGive( id )
{
	if( !( get_user_flags( id ) & ADMIN_IMMUNITY ) )
	{
		ChatColor( id, "^04JailBreak Shop -> ^03You are not an admin." );
		//ColorChat( id, GREEN, "JailBreak Shop -> ^01You are not an admin." );
		return PLUGIN_HANDLED;
	}
	
	new message[256];
	read_args( message, 255 );
	
	remove_quotes( message );
	
	if( !is_str_num( message ) )
	{
		ChatColor( id, "^04JailBreak Shop -> ^03That is not a valid number." );
		//ColorChat( id, GREEN, "JailBreak Shop -> ^01That is not a valid number." );
		return PLUGIN_HANDLED;
	}
	
	new amount = str_to_num( message );
	
	gJBPoints[ gChosenPlayer[id] ] += amount;
	
	new playerName[32];
	get_user_name( gChosenPlayer[id], playerName, 31 );
	
	ChatColor( id, "^04JailBreak Shop -> ^03You gave ^04%i JB $ ^03to ^04%s^03.", amount, playerName );
	//ColorChat( id, GREEN, "JailBreak Shop -> ^01You gave %i ^04JB $ ^01to ^03%s^01.", amount, playerName );
	
	return PLUGIN_HANDLED;
}

public CmdTop10( id )
{
	new array[33];
	
	for( new i = 0; i < sizeof( array ); i++ )
		array[i] = i;
	
	new holder;
	
	for( new i = 0; i < sizeof array ;i++ )
	{
		for( new j = 0; j < i; j++ )
		{
			if( gJBPoints[ array[i] ] > gJBPoints[ array[ j ] ] )
			{
				holder = array[i];
				array[i] = array[j];
				array[j] = holder;
			}
		}
	}
	
	new message[2048];
	
	new len;
	
	len = formatex( message, 2047, "<body bgcolor=#000000><font color=#FFB000><pre>" );
	len += formatex( message[len], 2047 - len, "%2s %-22.22s %8s %10s %6s^n", "#", "Nick", "JB $", "Katana", "Pro-Knife" );
	
	new name[32];
	new count = 0;
	for( new i = 0 ; i < sizeof array; i++ )
	{
		if( is_user_connected( array[i] ) )
		{
			get_user_name( array[i], name, 31 );
			len += formatex( message[len], 2047 - len, "%-2d %-22.22s %-8d %10s %10s^n", count + 1, name, gJBPoints[ array[i] ], ( gHasKatana[ array[i] ] ? "Yes" : "No" ), ( gHasKnife[ array[i] ] ? "Yes" : "No" ) );
			count++;
		}
		
		if( count == 10 )
			break;
	}
	
	show_motd( id, message, "Jailbreak Shop Top10" );
}

public CmdReset( id )
{
	new menu = menu_create( "Are you sure you want to reset all of your shop?:", "ResetMenu_Handler" );
	menu_additem( menu, "Yes (Continue)", "1" );
	menu_additem( menu, "No (Exit this menu)", "0" );
	
	menu_display( id, menu, 0 );
}

public ResetMenu_Handler( id, menu, item )
{
	if( item == MENU_EXIT )
	{
		menu_destroy( menu );
		return PLUGIN_HANDLED;
	}
	
	new access, callback;
	new data[6], szName[64];
	
	menu_item_getinfo( menu, item, access, data, 5, szName, 63, callback );
	
	new key = str_to_num( data );
	
	if( key == 0 )
	{
		menu_destroy( menu );
		return PLUGIN_HANDLED;
	}
	
	else
	{
		Reset( id );
	}
	
	menu_destroy( menu );
	return PLUGIN_HANDLED;
}

public Reset( id )
{
	gJBPoints[id] = 0;
	
	gBoughtDeagle[id] = false;
	gBoughtFlash[id] = false;
	gBoughtFrag[id] = false;
	gBoughtMac10[id] = false;
	gBoughtRambo[id] = false;
	gBoughtSmoke[id] = false;
	gBoughtTMP[id] = false;
	gBoughtRegeneration[id] = false;
	gBoughtM4[id] = false;
	gBoughtSpeed[id] = false;
	gBoughtDoubleDamage[id] = false
	gBoughtShield[id] = false;
	gBoughtSpeed[id] = false;
	
	gHasKatana[id] = false;
	gHasKnife[id] = false;
	
	SaveData( id );
	
	ChatColor( id, "^04JailBreak Shop -> ^03You have successfully reset your shop info." );
	
	//ColorChat( id, GREEN, "JailBreak Shop -> ^01You have successfully reset your shop info." );
	
	return PLUGIN_HANDLED;
}

public SaveData( id )
{
	new key[64], data[64];
	
	new name[32];
	get_user_name( id, name, 31 );
	
	format( key, charsmax( key ), "%s-STEAMID", name );
	
	new katana;
	new knife;
	
	if( gHasKatana[id] ) katana = 1;
	
	if( gHasKnife[id] ) knife = 1;
	
	format( data, charsmax( data ), "%i %i %i", gJBPoints[id], katana, knife );
	
	nvault_set( gMoneyVault, key, data );
}

public LoadData( id )
{
	new key[64], retrieve[64];
	
	new name[32];
	get_user_name( id, name, 31 );
	
	format( key, charsmax( key ), "%s-STEAMID", name );
	
	nvault_get( gMoneyVault, key, retrieve, charsmax( retrieve ) );
	
	new pointString[6], katanaString[6], knifeString[6];
	
	parse( retrieve, pointString, 5, katanaString, 5, knifeString, 5 );
	
	new point = str_to_num( pointString );
	
	new katana = str_to_num( katanaString );
	
	new knife = str_to_num( knifeString );
	
	gJBPoints[id] = point;
	
	if( katana == 1 )
		gHasKatana[id] = true;
	
	else gHasKatana[id] = false;
	
	if( knife == 1 )
	{ 
		gHasKnife[id] = true;
	}
	
	else gHasKnife[id] = false;
		
	if( gHasKatana[id] )
		gKnifeType[id] = KATANA;
}

public ChatColor( id, const message[], any:... )
{
	new text[256];
	
	vformat( text, 255, message, 3 );
	
	new team[10];
	
	if( id == 0 )
	{
		new players[32], num, player;
		get_players( players, num );
		
		for( new i = 0; i < num; i++ )
		{
			player = players[i];
			
			if( !is_user_connected( player ) )
				continue;
			
			get_user_team( player, team, 9 );
			
			changeTeamInfo( player, "SPECTATOR" );
			writeMessage( player, text );
			changeTeamInfo( player, team );
		}
	}
	
	else
	{
		if( !is_user_connected( id ) )
			return PLUGIN_HANDLED;
		
		get_user_team( id, team, 9 );
		
		changeTeamInfo( id, "SPECTATOR" );
		writeMessage( id, text );
		changeTeamInfo( id, team );
	}
	
	
	return PLUGIN_HANDLED;	
}

public changeTeamInfo ( player, team[] )
{
	message_begin( MSG_ONE, get_user_msgid( "TeamInfo" ), _, player );
	write_byte( player );
	write_string( team );
	message_end();
}


public writeMessage ( player, message[] )
{
	message_begin( MSG_ONE, get_user_msgid( "SayText" ), { 0, 0, 0 }, player );
	write_byte( player );
	write_string( message );
	message_end();
}

public TerroristsWin()
{
	new players[32], num, player;
	get_players( players, num );
	
	for( new i = 0; i < num; i++ )
	{
		player = players[i];
		if( !gBetted[player] || !is_user_connected( player ) )
			continue;
		
		if( !( gBetCT && gBetT ) )
		{
			ChatColor( player, "^04JailBreak Shop -> ^03Since nobody else betted against you, you win nothing." );
			return PLUGIN_HANDLED;
		}
		
		else if( gBetTeam[player] == T )
		{
			new Float:money = float( ( gBetAmount[player] / gBettingPot[T] ) * gBettingPot[CT] );
			
			cs_set_user_money( player, gBetAmount[player] + floatround( money ) );
			
			ChatColor( player, "^04JailBreak Shop -> ^03You won the bet! You received ^04%d JB$ ^03for winning.", floatround( money ) );
		}	
		
		gBetAmount[player] = 0;
		gBetTeam[player] = 0;
		gBetted[player] = false;
		
	}
	
	return PLUGIN_HANDLED;
}

public CTsWin()
{
	new players[32], num, player;
	get_players( players, num );
	
	for( new i = 0; i < num; i++ )
	{
		player = players[i];
		if( !gBetted[player] || !is_user_connected( player ) )
			continue;
		
		if( !( gBetCT && gBetT ) )
		{
			ChatColor( player, "^04JailBreak Shop -> ^03Since nobody else betted against you, you win nothing." );
			return PLUGIN_HANDLED;
		}
		
		
		else if( gBetTeam[player] == CT )
		{
			new Float:money = float( ( gBetAmount[player] / gBettingPot[CT] ) * gBettingPot[T] );
			
			cs_set_user_money( player, gBetAmount[player] + floatround( money ) );
			
			ChatColor( player, "^04JailBreak Shop -> ^03You won the bet! You received ^04%d JB$ ^03for winning.", floatround( money ) );
		}
		
		gBetAmount[player] = 0;
		gBetTeam[player] = 0;
		gBetted[player] = false;
	}
	
	return PLUGIN_HANDLED;
	
}

public RoundDraw()
{
	
	new players[32], num, player;
	get_players( players, num );
	
	for( new i = 0; i < num; i++ )
	{
		player = players[i];
		
		if( !gBetted[player] || !is_user_connected( player ) )
			continue;
		
		ChatColor( player, "^04JailBreak Shop -> ^03Since nobody won the round, you win nothing." );
		
		gJBPoints[player] += gBetAmount[player];
		
		gBetAmount[player] = 0;
		gBetTeam[player] = 0;
		gBetted[player] = false;
	}
	
	gTotalBets[T] = 0;
	gTotalBets[CT] = 0;
}
