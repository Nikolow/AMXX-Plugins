/*

	Разширен шоп плъгин, който се използва главно за блокмейкър сървъри, с доста айтъми и настройки.
	Лесна редакция по кода и голяма гъвкавост.

*/

#include < amxmodx >
#include < amxmisc >
#include < cstrike >
#include < engine >
#include < hamsandwich >
#include < fun >
#include < fakemeta >
#include < nvault >
#include < colorchat >

#define MAX_PLAYERS	32
#define PREFIX		"[BetterPlay BM Shop]"

#define PLUGIN_ACCESS	ADMIN_RCON
#define PLUGIN_VIP	ADMIN_KICK

#define MAX_BUY_ITEMS		3
#define TERRORIST_NEED_KILLS	2

#define SURVIVING_ROUNDS	2
#define SURVIVING_POINTS	2

#define MAX_FROSTIMM		3

//#define ADMIN_SCREEN_MENU

#if defined ADMIN_SCREEN_MENU
native user_flash_immunity( index, value );
#endif

new bool:hegrenade[ MAX_PLAYERS + 1 ], bool:flashbang[ MAX_PLAYERS + 1 ], bool:smokegrenade[ 33 ], bool:chameleon[ MAX_PLAYERS + 1 ], bool:godmode[ MAX_PLAYERS + 1 ], bool:speed[ MAX_PLAYERS + 1 ], bool:awp[ MAX_PLAYERS + 1 ], bool:deagle[ MAX_PLAYERS + 1 ], bool:health[ MAX_PLAYERS + 1 ], bool:armor[ MAX_PLAYERS + 1 ], bool:gravity[ MAX_PLAYERS + 1 ], bool:xp[ MAX_PLAYERS + 1 ], bool:antiflash[ MAX_PLAYERS + 1 ], bool:antihe[ MAX_PLAYERS + 1 ], bool:antifrost[ MAX_PLAYERS + 1 ];
new he_cost, flash_cost, smoke_cost, chameleon_cost, godmode_cost, speed_cost, chameleon_time, godmode_time, speed_time, awp_cost, awp_ammo, deagle_cost, deagle_ammo, health_cost, health_amount, armor_cost, armor_amount, gravity_cost, gravity_time, xp_cost, xp_amount, antiflash_cost, antihe_cost, antihe_max_immunes, antifrost_cost;

new chameleon_counter[ MAX_PLAYERS + 1 ], godmode_counter[ MAX_PLAYERS + 1 ], speed_counter[ MAX_PLAYERS + 1 ], gravity_counter[ MAX_PLAYERS + 1 ];
new iPoints[ MAX_PLAYERS + 1 ], shopused[ MAX_PLAYERS + 1 ], sync, vault;

new const PLUGIN[ ] = "BetterPlay HidenSeek Shop";
new const VERSION[ ] = "4.4";
new const AUTHOR[ ] = "Smiley";

new const t_models[ ][ ] = { "arctic", "leet", "guerilla", "terror" }
new const ct_models[ ][ ] = { "gign", "urban", "sas", "gsg9" }

new iKilled[ MAX_PLAYERS + 1 ], kill_points, headshot_points, grenade_points, R, G, B;

native hnsxp_get_user_xp( client );
native hnsxp_set_user_xp( client, xp );

native set_user_nofrost( client, chislo );

// anti-flash
new grenade[32], last, g_sync_check_data, bool:g_track_enemy, bool:g_track[ MAX_PLAYERS + 1 ];
new Float:g_gametime, g_owner
new Float:g_gametime2;
//

new cacheUserName[ 64 ], bool:iChance[ MAX_PLAYERS + 1 ], hh_start, hh_end, bool:iHappyHourStarted, iHeImmunes[ MAX_PLAYERS + 1 ], iBonusCount, cvar_bonus_on, bool:iShowTimeleft[ MAX_PLAYERS + 1 ], iCTWin[ MAX_PLAYERS + 1 ], bool:iRoundStart, bool:iAdmin[ MAX_PLAYERS + 1 ], bool:g_szHideHud[ MAX_PLAYERS + 1 ];
new frost_imm;

public plugin_init( )
{
	register_plugin( PLUGIN, VERSION, AUTHOR );
	register_cvar( "hnsshop_points_version", VERSION, FCVAR_SERVER | FCVAR_SPONLY );
	register_cvar( "hnsshop_points_author", AUTHOR, FCVAR_SERVER | FCVAR_SPONLY );
	
	register_concmd( "shop_give_points", "GivePoints", PLUGIN_ACCESS, "<name, #userid, authid> <points>" );
	register_concmd( "shop_remove_points", "RemovePoints", PLUGIN_ACCESS, "<name, #userid, authid> <points>" );
	register_concmd( "shop_donate_points", "DonatePoints", _, "<name, #userid, authid> <points>" );
	
	register_clcmd( "give", "Give" );
	register_clcmd( "remove", "Remove" );
	register_clcmd( "donate", "Donate" );
	
	register_event( "DeathMsg", "eDeath", "a" );
	register_event( "CurWeapon", "eCurWeapon", "be", "1=1" );
	
	// for anti-flash
	register_event( "ScreenFade", "eventFlash", "be", "4=255", "5=255", "6=255", "7>199" );
	register_event( "TextMsg", "fire_in_the_hole", "b", "2&#Game_radio", "4&#Fire_in_the_hole" );
	register_event( "TextMsg", "fire_in_the_hole2", "b", "3&#Game_radio", "5&#Fire_in_the_hole" );
	register_event( "99", "grenade_throw", "b" );
	
	set_task( 2.0, "bad_fix2", _, _, _, "b" );
	//
	
	RegisterHam( Ham_Spawn, "player", "fwdPlayerSpawn", 1 );
	RegisterHam( Ham_TakeDamage, "player", "fwdPlayerTakeDamage" );
	
	register_logevent( "logeventRoundStart", 2, "1=Round_Start" );
	register_logevent( "logeventRoundEnd", 2, "1=Round_End" );
	
	register_event( "TextMsg", "eventRound_Restart", "a", "2&#Game_C", "2&#Game_w" );
	
	register_clcmd( "say /shop", "CmdMainMenu" );
	register_clcmd( "say_team /shop", "CmdMainMenu" );
	
	register_clcmd( "say /showtimeleft", "CmdShowTimeleft" );
	
	he_cost = register_cvar( "shop_he_cost", "4" );
	flash_cost = register_cvar( "shop_flash_cost", "2" );
	smoke_cost = register_cvar( "shop_smoke_cost", "3" );
	chameleon_cost = register_cvar( "shop_chameleon_cost", "5" );
	godmode_cost = register_cvar( "shop_godmode_cost", "6" );
	speed_cost = register_cvar( "shop_speed_cost", "5" );
	awp_cost = register_cvar( "shop_awp_cost", "6" );
	deagle_cost = register_cvar( "shop_deagle_cost", "3" );
	health_cost = register_cvar( "shop_health_cost", "3" );
	armor_cost = register_cvar( "shop_armor_cost", "2" );
	gravity_cost = register_cvar( "shop_gravity_cost", "3" );
	xp_cost = register_cvar( "shop_xp_cost", "10" );
	antiflash_cost = register_cvar( "shop_antiflash_cost", "9" );
	antihe_cost = register_cvar( "shop_antihe_cost", "7" );
	antifrost_cost = register_cvar( "shop_antifrost_cost", "5" );
	
	awp_ammo = register_cvar( "shop_awp_ammo", "1" );
	deagle_ammo = register_cvar( "shop_deagle_ammo", "1" );
	
	health_amount = register_cvar( "shop_health_amount", "50" );
	armor_amount = register_cvar( "shop_armor_amount", "100" );
	xp_amount = register_cvar( "shop_xp_amount", "250" );
	
	chameleon_time = register_cvar( "shop_chameleon_time", "15" );
	godmode_time = register_cvar( "shop_godmode_time", "8" );
	speed_time = register_cvar( "shop_speed_time", "20" );
	gravity_time = register_cvar( "shop_gravity_time", "15" );
	
	kill_points = register_cvar( "shop_points_kill", "1" );
	headshot_points = register_cvar( "shop_points_headshot", "2" );
	grenade_points = register_cvar( "shop_points_grenade", "3" );
	
	antihe_max_immunes = register_cvar( "shop_antihe_max_immunes", "3" );
	
	sync = CreateHudSyncObj( );
	vault = nvault_open( "HidenSeekShop" );
	
	hh_start = register_cvar( "shop_hh_start", "17" );
	hh_end = register_cvar( "shop_hh_end", "05" );
	
	new ent = create_entity( "info_target" );
	entity_set_string( ent, EV_SZ_classname, "task_entity" );
	
	register_think( "task_entity", "CmdShowPoints" );
	entity_set_float( ent, EV_FL_nextthink, get_gametime( ) + 1.0 );
	
	set_task( 1.0, "taskLoadFile" );
	set_task( 1.0, "taskLoadColors" );
	
	set_task( 300.0, "taskAdvert", _, _, _, "b" );
	set_task( 300.0, "TaskAdvertising2", _, _, _, "b" );
	
	cvar_bonus_on = register_cvar( "shop_bonuspoints_on", "1" );
	iBonusCount = 0;
	
	frost_imm = 3;
	iHappyHourStarted = false;
}

public plugin_natives()
{
	register_library("hns_shop");
	register_native("hnsshop_get_user_points", "_get_points");
	register_native("hnsshop_set_user_points", "_set_points");
	
	register_native( "hide_shop_hud", "_hide_hud" );
}

public _get_points(plugin, params)
{
	return iPoints[get_param(1)];
}

public _set_points(plugin, params)
{
	new client = get_param(1);
	iPoints[client] = max(0, get_param(2));
	SavePoints(client);
	return iPoints[client];
}

public _hide_hud( plugin, params ) { if( get_param( 2 ) <= 0 ) { g_szHideHud[ get_param( 1 ) ] = false; } else { g_szHideHud[ get_param( 1 ) ] = true; } }

public taskAdvert( ) { for( new i = 1; i <= MAX_PLAYERS; i++ ) { if( is_user_connected( i ) ) { ColorChat( i, GREEN, "%s^1 Write^3 /showtimeleft^4 to view^1 timeleft in^3 HUD^4. Write command^1 again to^3 hide^4 HUD^1.", PREFIX ); } } }
public TaskAdvertising2( ) { for( new i = 1; i <= MAX_PLAYERS; i++ ) { if( is_user_connected( i ) ) { ColorChat( i, GREEN, "%s^1 Whrite ^3/shop ^1for buy ^4items.", PREFIX ); } } }

public eventRound_Restart( ) if( get_pcvar_num( cvar_bonus_on ) ) iBonusCount = 0;
public CmdShowTimeleft( id ) iShowTimeleft[ id ] = !iShowTimeleft[ id ];

public CmdChance( id )
{
	if( !is_user_alive( id ) )
	{
		ColorChat( id, GREEN, "%s^1 Need to be^3 alive to^4 use this^1 command!", PREFIX );
		return PLUGIN_HANDLED;
	}
	
	switch( random_num( 0, 4 ) )
	{
		case 0:
		{
			iPoints[ id ]++;
			ColorChat( id, GREEN, "%s^1 You^4 won^1 and^3 win^4 1^1 point^3.", PREFIX );
		}
		default: ColorChat( id, GREEN, "%s^1 You lost!^3 Try again^4 next respawn^1.", PREFIX );
	}
	
	iChance[ id ] = true;
	CmdMainMenu( id );
	
	if( callfunc_begin( "Reset", "HNSMenu.amxx" ) == 1 )
	{
		callfunc_push_int( id );
		callfunc_end( );
	}
	
	return PLUGIN_HANDLED;
}

public taskLoadColors( )
{
	switch( random_num( 0, 5 ) )
	{
		case 0: 
		{
			R = 255;
			G = 255;
			B = 0;
		}
		case 1:
		{
			R = 0;
			G = 127;
			B = 255;
		}
		case 2: R = G = B = 255;
			case 3:
		{
			R = 0;
			G = 255;
			B = 0;
		}
		case 4:
		{
			R = 255;
			G = B = 0;
		}
		case 5:
		{
			R = random( 255 );
			G = random( 255 );
			B = random( 255 );
		}
	}
	
	return PLUGIN_HANDLED;
}

public client_authorized( id ) 
{
	LoadPoints( id );
	
	iAdmin[ id ] = ( get_user_flags( id ) & PLUGIN_VIP ) ? true : false;
	
	iShowTimeleft[ id ] = true;
}

public client_disconnect( id ) SavePoints( id );

public CmdShowPoints( ent )
{
	static iPlayers[ 32 ], iNum, i, id;
	get_players( iPlayers, iNum, "ch" );
	
	for( i = 0; i < iNum; i++ )
	{
		id = iPlayers[ i ];
		
		if( !is_user_connected( id ) || !is_user_alive( id ) || g_szHideHud[ id ] ) continue;
		
		if( iShowTimeleft[ id ] ) 
		{
			if( get_cvar_num( "mp_timelimit" ) ) 
			{
				set_hudmessage( R, G, B, 0.01, 0.91, 0, 0.8, 0.8 );
				ShowSyncHudMsg( id, sync, "Health: %d | Point%s: %d | XP: %d | Timeleft: %d:%02d", get_user_health( id ), iPoints[ id ] == 1 ? "" : "s", iPoints[ id ], hnsxp_get_user_xp( id ), ( get_timeleft( ) / 60 ), ( get_timeleft( ) % 60 ) );
			}
			else 
			{
				iShowTimeleft[ id ] = false;
			}
		}
		else 
		{
			set_hudmessage( R, G, B, 0.01, 0.91, 0, 0.8, 0.8 );
			ShowSyncHudMsg( id, sync, "Health: %d | Armor: %d | Point%s: %d | XP: %d", get_user_health( id ), get_user_armor( id ), iPoints[ id ] == 1 ? "" : "s", iPoints[ id ], hnsxp_get_user_xp( id ) );	
		}
	}
	
	entity_set_float( ent, EV_FL_nextthink, get_gametime( ) + 0.1 );
}

public GivePoints( id, level, cid )
{
	if( !cmd_access( id, level, cid, 3) ) return PLUGIN_HANDLED;
	
	new arg[35];
	read_argv(1, arg, sizeof(arg) - 1);
	
	new target = cmd_target( id, arg, CMDTARGET_NO_BOTS );
	if( !target ) return PLUGIN_HANDLED;
	
	read_argv(2, arg, sizeof(arg) - 1);
	new points = str_to_num(arg);
	
	if( points <= 0 ) return PLUGIN_HANDLED;
	
	iPoints[ target ] += points;
	SavePoints( target );
	
	new name1[ 33 ], name2[ 33 ]
	get_user_name( id, name1, charsmax( name1 ) );
	get_user_name( target, name2, charsmax( name2 ) );
	
	if( get_cvar_num( "amx_show_activity" ) == 2 ) ColorChat( 0, GREEN, "%s^1 ADMIN:^3 %s^1 give^4 %d^1 point%s to^3 %s.", PREFIX, name1, points, points > 1 ? "s" : "", name2 );
	
	return PLUGIN_HANDLED;
}

public RemovePoints( id, level, cid )
{
	if( !cmd_access( id, level, cid, 3) ) return PLUGIN_HANDLED;
	
	new arg[35];
	read_argv(1, arg, sizeof(arg) - 1);
	
	new target = cmd_target( id, arg, CMDTARGET_NO_BOTS );
	if( !target ) return PLUGIN_HANDLED;
	
	read_argv(2, arg, sizeof(arg) - 1);
	new points = str_to_num(arg);
	
	if( points <= 0 ) return PLUGIN_HANDLED;
	
	iPoints[ target ] -= points;
	SavePoints( target );
	
	new name1[ 33 ], name2[ 33 ]
	get_user_name( id, name1, charsmax( name1 ) );
	get_user_name( target, name2, charsmax( name2 ) );
	
	if( get_cvar_num( "amx_show_activity" ) == 2 ) ColorChat( 0, GREEN, "%s^1 ADMIN:^3 %s^1 removed^4 %d^1 point%s from^3 %s.", PREFIX, name1, points, points > 1 ? "s" : "", name2 );
	
	return PLUGIN_HANDLED;
}

public DonatePoints( id, level, cid )
{
	if( !cmd_access( id, level, cid, 3) ) return PLUGIN_HANDLED;
	
	new arg[35];
	read_argv(1, arg, sizeof(arg) - 1);
	
	new target = cmd_target( id, arg, CMDTARGET_NO_BOTS );
	if( !target ) return PLUGIN_HANDLED;
	
	read_argv(2, arg, sizeof(arg) - 1);
	new points = str_to_num(arg);
	
	if( points <= 0 ) return PLUGIN_HANDLED;
	
	if( iPoints[ id ] < points ) points = iPoints[ id ];
	
	iPoints[ id ] -= points;
	iPoints[ target ] += points;
	
	SavePoints( id );
	SavePoints( target );
	
	new name1[ 33 ], name2[ 33 ]
	get_user_name( id, name1, charsmax( name1 ) );
	get_user_name( target, name2, charsmax( name2 ) );
	
	ColorChat( 0, GREEN, "%s^3 %s^1 donate^4 %d^1 point%s to^3 %s.", PREFIX, name1, points, points > 1 ? "s" : "", name2 );
	
	return PLUGIN_HANDLED;
}

public eDeath( )
{
	new attacker = read_data( 1 );
	new attacked = read_data( 2 );
	
	new AttackedName[ 33 ];
	get_user_name( attacked, AttackedName, charsmax( AttackedName ) );
	
	if( is_user_connected( attacker ) && attacked != attacker && is_user_alive( attacker ) )
	{
		new iTime[ 3 ], weapon[ 33 ];
		get_time( "%H", iTime, charsmax( iTime ) );
		read_data( 4, weapon, charsmax( weapon ) );
		
		if( get_pcvar_num( hh_start ) < get_pcvar_num( hh_end ) ? ( get_pcvar_num( hh_start ) <= str_to_num( iTime ) && str_to_num( iTime ) < get_pcvar_num( hh_end ) ) : ( get_pcvar_num( hh_start ) <= str_to_num( iTime ) || str_to_num( iTime ) < get_pcvar_num( hh_end ) ) )
		{
			if( cs_get_user_team( attacker ) == CS_TEAM_T )
			{
				iKilled[ attacker ]++;
				
				if( iKilled[ attacker ] == TERRORIST_NEED_KILLS )
				{
					new point = iAdmin[ attacker ] ? 3 : 2;
					new kills = TERRORIST_NEED_KILLS;
					
					iPoints[ attacker ] += point;
					iKilled[ attacker ] = 0;
					
					SavePoints( attacker );
					ColorChat( attacker, GREEN, "%s^1 You made^3 %d^4 kill%s^1, so you^3 receive^4 %d^1 point%s^4 (happyhour)^1.", PREFIX, kills, kills == 1 ? "" : "s", point, point == 1 ? "" : "s" );
				}
			}
			else if( cs_get_user_team( attacker ) == CS_TEAM_CT )
			{	
				new message_kill[ 33 ], message_vip[ 64 ],  points;
				
				if( read_data( 3 ) )
				{
					points = get_pcvar_num( headshot_points ) * 3;
					formatex( message_kill, charsmax( message_kill ), " ^1with^3 headshot^1" );
				}
				else
				{
					if( equal( weapon, "grenade" ) )
					{
						points = get_pcvar_num( grenade_points ) * 3;
						formatex( message_kill, charsmax( message_kill ), " ^1with^3 grenade^1" );
					}
					else
					{
						points = get_pcvar_num( kill_points ) * 3;
						formatex( message_kill, charsmax( message_kill ), "" );
					}
				}
				
				new reward;
				if( iAdmin[ attacker ] )
				{
					reward = points + points;
				}
				else
				{
					reward = points;
				}
				
				iAdmin[ attacker ] ? formatex( message_vip, charsmax( message_vip ), " (Bonus:^3 %d^4 Point%s^1 for^4 VIP^3 Users^1)", points, points == 1 ? "" : "s" ) : formatex( message_vip, charsmax( message_vip ), " (buy^3 VIP^1 to get^4 more^3 Points^1)" );
				
				iPoints[ attacker ] += reward;
				SavePoints( attacker );
				
				ColorChat( attacker, GREEN, "%s^1 You received^3 %d^4 point%s^1 for killing^4 %s%s ^4(happyhour)^1%s", PREFIX, reward, reward == 1 ? "" : "s", AttackedName, message_kill, message_vip );
			}
		}
		else
		{
			if( cs_get_user_team( attacker ) == CS_TEAM_T )
			{
				iKilled[ attacker ]++;
				
				if( iKilled[ attacker ] == TERRORIST_NEED_KILLS )
				{
					new point = iAdmin[ attacker ] ? 2 : 1;
					new kills = TERRORIST_NEED_KILLS;
					
					iPoints[ attacker ] += point;
					iKilled[ attacker ] = 0;
					
					SavePoints( attacker );
					ColorChat( attacker, GREEN, "%s^1 You made^3 %d^4 kill%s^1, so you^3 receive^4 %d^1 point%s.", PREFIX, kills, kills == 1 ? "" : "s", point, point == 1 ? "" : "s" );
				}
			}
			else if( cs_get_user_team( attacker ) == CS_TEAM_CT )
			{	
				new message_kill[ 33 ], message_vip[ 64 ],  points;
				
				if( read_data( 3 ) )
				{
					points = get_pcvar_num( headshot_points );
					formatex( message_kill, charsmax( message_kill ), " ^1with^3 headshot^1" );
				}
				else
				{
					if( equal( weapon, "grenade" ) )
					{
						points = get_pcvar_num( grenade_points );
						formatex( message_kill, charsmax( message_kill ), " ^1with^3 grenade^1" );
					}
					else
					{
						points = get_pcvar_num( kill_points );
						formatex( message_kill, charsmax( message_kill ), "" );
					}
				}
				
				new reward;
				if( iAdmin[ attacker ] )
				{
					reward = points + points;
				}
				else
				{
					reward = points;
				}
				
				iAdmin[ attacker ] ? formatex( message_vip, charsmax( message_vip ), " (Bonus:^3 %d^4 Point%s^1 for^4 VIP^3 Users^1)", points, points == 1 ? "" : "s" ) : formatex( message_vip, charsmax( message_vip ), " (buy^3 VIP^1 to get^4 more^3 Points^1)" );
				
				iPoints[ attacker ] += reward;
				SavePoints( attacker );
				
				ColorChat( attacker, GREEN, "%s^1 You received^3 %d^4 point%s^1 for killing^4 %s%s%s", PREFIX, reward, reward == 1 ? "" : "s", AttackedName, message_kill, message_vip );
			}
		}
	}
	
	iCTWin[ attacked ] = 0;
}

public logeventRoundStart( ) 
{
	new iTime[ 3 ], iHour;
	get_time( "%H", iTime, charsmax( iTime ) );
	iHour = str_to_num( iTime );
	
	for( new i = 1; i <= MAX_PLAYERS; i++ )
	{
		if( !is_user_connected( i ) ) continue;
		
		shopused[ i ] = MAX_BUY_ITEMS;
		
		#if defined ADMIN_SCREEN_MENU
		user_flash_immunity( i, 0 );
		#endif
		
		antiflash[ i ] = false;
		
		set_task( 1.0, "taskRoundStart" );
	}
	
	if( get_pcvar_num( cvar_bonus_on ) )
	{	
		if( iBonusCount == 4 )
		{
			set_task( 1.0, "taskGiveBonusPoints" );
			iBonusCount = 0;
		}
		else iBonusCount++;
	}
	
	if( !iHappyHourStarted )
	{
		if( iHour == get_pcvar_num( hh_start ) )
		{
			iHappyHourStarted = true;
			
			ColorChat( 0, GREEN, "%s^3 Happy Hour^1 Stared!", PREFIX );
			ColorChat( 0, GREEN, "%s^3 All players^1 will gain^4 double points^3 now!", PREFIX );
		}
	}
	else
	{
		if( iHour == get_pcvar_num( hh_end ) )
		{
			iHappyHourStarted = false;
			
			ColorChat( 0, GREEN, "%s^3 Happy Hour^1 Ended!", PREFIX );
			ColorChat( 0, GREEN, "%s^3 All players^1 will gain^4 normal points^3 now!", PREFIX );
		}
	}
}

public taskRoundStart( ) iRoundStart = true;

public taskGiveBonusPoints( )
{
	new iPlayers[ 32 ], iName[ 33 ], iNum, id;
	get_players( iPlayers, iNum, "ach" );
	
	id = iPlayers[ random_num( 0, iNum ) ];
	
	if( !is_user_connected( id ) || is_user_bot( id ) || is_user_hltv( id ) ) return PLUGIN_CONTINUE;
	
	new CsTeams:team = cs_get_user_team( id );
	if( team == CS_TEAM_SPECTATOR ) return PLUGIN_CONTINUE;
	
	get_user_name( id, iName, charsmax( iName ) );
	
	iPoints[ id ] += 2;
	ColorChat( 0, GREEN, "%s^1 This round^3 %s^1 received^4 2^1 points.", PREFIX, iName );
	
	return PLUGIN_CONTINUE;
}

public logeventRoundEnd( )
{
	for( new i = 1; i <= 32; i++ )
	{
		if( !is_user_connected( i ) || !is_user_alive( i ) || !iRoundStart ) continue;
		
		if( cs_get_user_team( i ) != CS_TEAM_CT ) continue;
		
		new rounds = SURVIVING_ROUNDS;
		new points = SURVIVING_POINTS;
		
		if( iCTWin[ i ] == rounds )
		{
			new pt = iAdmin[ i ] ? points * 2 : points;
			iCTWin[ i ] = 0;
			
			ColorChat( i, GREEN, "%s^1 You received^3 %d^4 Point%s^1 for^3 surviving^4 %d^1 round%s.", PREFIX, pt, pt == 1 ? "" : "s", rounds, rounds == 1 ? "" : "s" );
			
			iPoints[ i ] += pt;
			SavePoints( i );
		}
		else iCTWin[ i ]++;
	}
}

public fwdPlayerSpawn( id )
{
	if( !is_user_alive( id ) ) return PLUGIN_CONTINUE;
	
	iChance[ id ] = false;
	
	hegrenade[ id ] = false;
	flashbang[ id ] = false;
	smokegrenade[ id ] = false;
	chameleon[ id ] = false;
	godmode[ id ] = false;
	
	speed[ id ] = false;
	
	awp[ id ] = false;
	deagle[ id ] = false;
	
	health[ id ] = false;
	armor[ id ] = false;
	
	gravity[ id ] = false;
	xp[ id ] = false;
	
	antihe[ id ] = false;
	iHeImmunes[ id ] = 0;
	
	set_user_nofrost( id, 0 );
	antifrost[ id ] = false;
	
	iRoundStart = false;
	remove_task( id );
	
	set_user_godmode( id, 0 );
	set_user_gravity( id, 1.0 );
	
	client_cmd( id, "cl_forwardspeed 400" );
	
	return PLUGIN_CONTINUE;
}

public fwdPlayerTakeDamage( this, idinflictor, idattacker, Float:damage, damagebits )
{
	if( damagebits & ( 1<<24 ) )
	{
		new Float:gOrigin[ 3 ], Float:tOrigin[ 3 ]; 
		pev( idinflictor, pev_origin, gOrigin );
		pev( this, pev_origin, tOrigin );
		
		if( vector_distance( gOrigin, tOrigin ) <= 255.0 )
		{
			if( !antihe[ this ] )
			{
				SetHamParamFloat( 4, random_float( 30.0, 70.0 ) );
			}
			else
			{
				new ahe = iAdmin[ this ] ? get_pcvar_num( antihe_max_immunes ) * 2 : get_pcvar_num( antihe_max_immunes );
				
				if( iHeImmunes[ this ] < ahe )
				{
					iHeImmunes[ this ]++;
					client_print( this, print_center, "Immunity from HEGrenades: %d of %d", iHeImmunes[ this ], ahe );
					
					SetHamParamFloat( 4, 0.0 );
					BlindPlayer( this, 1.0, 1.0, 255, 0, 0, 150 );
					
					if( idattacker != this )
					{
						new UserName[ 64 ];
						get_user_name( this, UserName, charsmax( UserName ) );
						
						ColorChat( idattacker, GREEN, "%s^3 %s^1 is protected^4 from^3 HE Grenades^1!", PREFIX, UserName );
					}
					else 
					{
						ColorChat( this, GREEN, "%s^1 You have^3 protection^1 from^4 HE Grenades^1 and you can not^3 kill^4 yourself^1.", PREFIX );
					}
				}
			}
		}
	}
}

public CmdMainMenu( id )
{
	new iTitle[ 64 ]
	formatex( iTitle, charsmax( iTitle ), "\yBetterPlay \d- \wHidenSeek BM \rShop^n\yMain Menu^n^n\wYour point%s: \y%i", iPoints[ id ] > 1 ? "s" : "", iPoints[ id ] );
	
	new menu = menu_create( iTitle, "CmdMainMenuHandler" );
	
	shopused[ id ] ? menu_additem( menu, "\wItems \yMenu", "1", 0 ) : menu_additem( menu, "\dItems Menu", "1", 0 );
	
	menu_additem( menu, "\wPlayer \rPoints \yMenu", "2", 0 );
	
	iChance[ id ] ? menu_additem( menu, "\dChance to win 1 Point^n", "3", 0 ) : menu_additem( menu, "\yChance \wto \rwin \y1 \wPoint^n", "3", 0 );
	
	( get_user_flags( id ) & PLUGIN_ACCESS ) ? menu_additem( menu, "\wGive \rPoints \yto \wPlayer", "4", 0 ) : menu_additem( menu, "\dGive Points to Player \y(\rOnly for admin\y)", "4", 0 );
	( get_user_flags( id ) & PLUGIN_ACCESS ) ? menu_additem( menu, "\wRemove \rPoints \yfrom \wPlayer^n", "5", 0 ) : menu_additem( menu, "\dRemove Points from Player \y(\rOnly for admin\y)^n", "5", 0 );
	
	menu_additem( menu, "\wDonate \rPoints \yto \wPlayer", "6", 0 );
	
	menu_setprop( menu, MPROP_EXIT, MEXIT_ALL );
	menu_display( id, menu, 0 );
}

public CmdMainMenuHandler( id, menu, item )
{
	if( item == MENU_EXIT )
	{
		menu_destroy( menu );
		return PLUGIN_HANDLED;
	}
	
	new iData[ 6 ], iName[ 63 ], iAccess, iCallback;
	menu_item_getinfo( menu, item, iAccess, iData, charsmax( iData ), iName, charsmax( iName ), iCallback );
	
	switch( str_to_num( iData ) )
	{
		case 1: 
		{
			if( shopused[ id ] ) CmdItemsMenu( id );
			else
			{
				CmdMainMenu( id );
				client_cmd( id, "spk buttons/button10.wav" );
				BlindPlayer( id, 0.35, 0.35, 255, 0, 0, 225 );
			}
		}
		case 2: CmdPlayerPointsMenu( id );
			case 3:
		{
			if( iChance[ id ] )
			{
				CmdMainMenu( id );
				client_cmd( id, "spk buttons/button10.wav" );
				BlindPlayer( id, 0.35, 0.35, 255, 0, 0, 225 );
			}
			else CmdChance( id );
		}
		case 4:
		{
			if( !( get_user_flags( id ) & PLUGIN_ACCESS ) )
			{
				CmdMainMenu( id );
				client_cmd( id, "spk buttons/button10.wav" );
				BlindPlayer( id, 0.35, 0.35, 255, 0, 0, 225 );
				
				return PLUGIN_HANDLED;
			}
			
			CmdGiveMenu( id );
		}
		case 5:
		{
			if( !( get_user_flags( id ) & PLUGIN_ACCESS ) )
			{
				CmdMainMenu( id );
				client_cmd( id, "spk buttons/button10.wav" );
				BlindPlayer( id, 0.35, 0.35, 255, 0, 0, 225 );
				
				return PLUGIN_HANDLED;
			}
			
			CmdRemoveMenu( id );
		}
		case 6: CmdDonateMenu( id );
		}
	
	menu_destroy( menu );
	return PLUGIN_HANDLED;
}

public CmdItemsMenu( id )
{
	if( !is_user_alive( id ) )
	{
		ColorChat( id, GREEN, "%s^1 Need to be^3 alive to^4 use the^1 shop!", PREFIX );
		CmdMainMenu( id );
		client_cmd( id, "spk buttons/button10.wav" );
		BlindPlayer( id, 0.35, 0.35, 255, 0, 0, 225 );
		
		return PLUGIN_HANDLED;
	}
	
	new iTitle[ 64 ], iText[ 15 ][ 64 ];
	formatex( iTitle, charsmax( iTitle ), "\yBetterPlay \d- \wHidenSeek BM \rShop^n\yItems Menu^n^n\wYour point%s: \y%i", iPoints[ id ] > 1 ? "s" : "", iPoints[ id ] );
	
	new menu = menu_create( iTitle, "CmdItemsMenuHandler" );
	
	if( cs_get_user_team( id ) == CS_TEAM_T )
	{
		formatex( iText[ 1 ], 63, "\wFlashbang - \y%d Point%s.", get_pcvar_num( flash_cost ), get_pcvar_num( flash_cost ) > 1 ? "s" : "" );
		formatex( iText[ 2 ], 63, "\wFrost Nade - \y%d Point%s.", get_pcvar_num( smoke_cost ), get_pcvar_num( smoke_cost ) > 1 ? "s" : "" );
		
		menu_additem( menu, iText[ 1 ], "2", 0 );
		menu_additem( menu, iText[ 2 ], "3", 0 );
	}
	else if( cs_get_user_team( id ) == CS_TEAM_CT )
	{
		new hp = iAdmin[ id ] ? get_pcvar_num( health_amount ) * 2 : get_pcvar_num( health_amount );
		new ap = iAdmin[ id ] ? get_pcvar_num( armor_amount ) * 2 : get_pcvar_num( armor_amount );
		new ahe = iAdmin[ id ] ? get_pcvar_num( antihe_max_immunes ) * 2 : get_pcvar_num( antihe_max_immunes );
		new afn = iAdmin[ id ] ? frost_imm * 2 : frost_imm;
		
		formatex( iText[ 0 ], 63, "\wHE Grenade - \y%d Point%s.", get_pcvar_num( he_cost ), get_pcvar_num( he_cost ) > 1 ? "s" : "" );
		formatex( iText[ 3 ], 63, "\wChameleon - \y%d Point%s.", get_pcvar_num( chameleon_cost ), get_pcvar_num( chameleon_cost ) > 1 ? "s" : "" );
		formatex( iText[ 4 ], 63, "\wGodmode - \y%d Point%s.", get_pcvar_num( godmode_cost ), get_pcvar_num( godmode_cost ) > 1 ? "s" : "" );
		formatex( iText[ 5 ], 63, "\wSpeed - \y%d Point%s.", get_pcvar_num( speed_cost ), get_pcvar_num( speed_cost ) > 1 ? "s" : "" );
		formatex( iText[ 6 ], 63, "\wAWP \r[\d%d \ybullet%s\r] \w- \y%d Point%s.", get_pcvar_num( awp_ammo ), get_pcvar_num( awp_ammo ) > 1 ? "s" : "", get_pcvar_num( awp_cost ), get_pcvar_num( awp_cost ) > 1 ? "s" : "" );
		formatex( iText[ 7 ], 63, "\wDeagle \r[\d%d \ybullet%s\r] \w- \y%d Point%s.", get_pcvar_num( deagle_ammo ), get_pcvar_num( deagle_ammo ) > 1 ? "s" : "", get_pcvar_num( deagle_cost ), get_pcvar_num( deagle_cost ) > 1 ? "s" : "" );
		formatex( iText[ 8 ], 63, "\w+%d \rHealth - \y%d Point%s.", hp, get_pcvar_num( health_cost ), get_pcvar_num( health_cost ) > 1 ? "s" : "" );
		formatex( iText[ 9 ], 63, "\w+%d \rArmor - \y%d Point%s.", ap, get_pcvar_num( armor_cost ), get_pcvar_num( armor_cost ) > 1 ? "s" : "" );
		formatex( iText[ 10 ], 63, "\wGravity - \y%d Point%s.", get_pcvar_num( gravity_cost ), get_pcvar_num( gravity_cost ) > 1 ? "s" : "" );
		formatex( iText[ 12 ], 63, "\wFlash Immunity \r[\d1 \yround\r] \w- \y%d Point%s.", get_pcvar_num( antiflash_cost ), get_pcvar_num( antiflash_cost ) > 1 ? "s" : "" );
		formatex( iText[ 13 ], 63, "\wHE Immunity \r[\yfrom \d%d \wgrenade%s\r] \w- \y%d Point%s.", ahe, ahe == 1 ? "" : "s", get_pcvar_num( antihe_cost ), get_pcvar_num( antihe_cost ) > 1 ? "s" : "" );
		formatex( iText[ 14 ], 63, "\wFrost Immunity \r[\yfrom \d%d \wnade%s\r] \w- \y%d Point%s.", afn, afn == 1 ? "" : "s", get_pcvar_num( antifrost_cost ), get_pcvar_num( antifrost_cost ) > 1 ? "s" : "" );
		
		menu_additem( menu, iText[ 0 ], "1", 0 );
		menu_additem( menu, iText[ 3 ], "4", 0 );
		menu_additem( menu, iText[ 4 ], "5", 0 );
		menu_additem( menu, iText[ 5 ], "6", 0 );
		menu_additem( menu, iText[ 6 ], "7", 0 );
		menu_additem( menu, iText[ 7 ], "8", 0 );
		menu_additem( menu, iText[ 8 ], "9", 0 );
		menu_additem( menu, iText[ 9 ], "10", 0 );
		menu_additem( menu, iText[ 10 ], "11", 0 );
		menu_additem( menu, iText[ 12 ], "13", 0 );
		menu_additem( menu, iText[ 13 ], "14", 0 );
		menu_additem( menu, iText[ 14 ], "15", 0 );
	}
	
	formatex( iText[ 11 ], 63, "\w%d XP - \y%d Point%s.", get_pcvar_num( xp_amount ), get_pcvar_num( xp_cost ), get_pcvar_num( xp_cost ) > 1 ? "s" : "" );
	menu_additem( menu, iText[ 11 ], "12", 0 );
	
	menu_setprop( menu, MPROP_EXIT, MEXIT_ALL );
	menu_display( id, menu, 0 );
	
	return PLUGIN_HANDLED;
}

public CmdItemsMenuHandler( id, menu, item )
{
	if( item == MENU_EXIT )
	{
		menu_destroy( menu );
		CmdMainMenu( id );
		return PLUGIN_HANDLED;
	}
	
	new iData[ 6 ], iName[ 63 ], iAccess, iCallback, iUserName[ 33 ];
	menu_item_getinfo( menu, item, iAccess, iData, charsmax( iData ), iName, charsmax( iName ), iCallback );
	get_user_name( id, iUserName, charsmax( iUserName ) );
	
	if( !is_user_alive( id ) ) return PLUGIN_HANDLED;
	
	switch( str_to_num( iData ) )
	{
		case 1:
		{
			if( hegrenade[ id ] ) 
			{
				AlreadyUsed( id );
				return PLUGIN_HANDLED;
			}
			
			if( iPoints[ id ] >= get_pcvar_num( he_cost ) )
			{
				if( !user_has_weapon( id, CSW_HEGRENADE ) )
				{
					give_item( id, "weapon_hegrenade" );
					iPoints[ id ] -= get_pcvar_num( he_cost );
					hegrenade[ id ] = true;
					
					shopused[ id ]--;
					LeftItems( id );
					
					ColorChat( id, GREEN, "%s^3 You^1 bought^4 HE Grenade^1!", PREFIX );
					SavePoints( id );						
				}
			}
			else
			{
				NoPoints( id );
				return PLUGIN_HANDLED;
			}
		}
		case 2:
		{
			if( flashbang[ id ] ) 
			{
				AlreadyUsed( id );
				return PLUGIN_HANDLED;
			}
			
			if( iPoints[ id ] >= get_pcvar_num( flash_cost ) )
			{
				if( !user_has_weapon( id, CSW_FLASHBANG ) )
				{
					give_item( id, "weapon_flashbang" );
					iPoints[ id ] -= get_pcvar_num( flash_cost );
					flashbang[ id ] = true;
					
					shopused[ id ]--;
					LeftItems( id );
					
					ColorChat( id, GREEN, "%s^3 You^1 bought^4 Flashbang^1!", PREFIX );
					SavePoints( id );
				}
			}
			else
			{
				NoPoints( id );
				return PLUGIN_HANDLED;
			}
		}
		case 3:
		{
			if( smokegrenade[ id ] ) 
			{
				AlreadyUsed( id );
				return PLUGIN_HANDLED;
			}
			
			if( iPoints[ id ] >= get_pcvar_num( smoke_cost ) )
			{
				if( !user_has_weapon( id, CSW_SMOKEGRENADE ) )
				{
					give_item( id, "weapon_smokegrenade" );
					iPoints[ id ] -= get_pcvar_num( smoke_cost );
					smokegrenade[ id ] = true;
					
					shopused[ id ]--;
					LeftItems( id );
					
					ColorChat( id, GREEN, "%s^3 You^1 bought^4 Frostnade^1!", PREFIX );
					SavePoints( id );
				}
			}
			else
			{
				NoPoints( id );
				return PLUGIN_HANDLED;
			}
		}
		case 4:
		{
			if( chameleon[ id ] ) 
			{
				AlreadyUsed( id );
				return PLUGIN_HANDLED;
			}
			
			if( iPoints[ id ] >= get_pcvar_num( chameleon_cost ) )
			{
				if( cs_get_user_team( id ) == CS_TEAM_CT )
				{
					cs_set_user_model( id, t_models[ random_num( 0, 3 ) ] );
				}
				else if( cs_get_user_team( id ) == CS_TEAM_T )
				{
					cs_set_user_model( id, ct_models[ random_num( 0, 3 ) ] );
				}
				
				iPoints[ id ] -= get_pcvar_num( chameleon_cost );
				chameleon[ id ] = true;
				
				shopused[ id ]--;
				LeftItems( id );
				
				if( get_pcvar_num( chameleon_time ) != 0 )
				{
					chameleon_counter[ id ] = get_pcvar_num( chameleon_time );
					ChameleonCounter( id );
					
					ColorChat( id, GREEN, "%s^3 You^1 bought^4 Chameleon^3 for^4 %d^1 second%s.", PREFIX, get_pcvar_num( chameleon_time ), get_pcvar_num( chameleon_time ) > 1 ? "s" : "" );
				}
				else
				{
					ColorChat( id, GREEN, "%s^3 You^1 bought^4 Chameleon^3 for^4 1^1 round.", PREFIX );
					
				}
				
				SavePoints( id );
			}
			else
			{
				NoPoints( id );
				return PLUGIN_HANDLED;
			}
		}
		case 5:
		{
			if( godmode[ id ] ) 
			{
				AlreadyUsed( id );
				return PLUGIN_HANDLED;
			}
			
			if( iPoints[ id ] >= get_pcvar_num( godmode_cost ) )
			{
				set_user_godmode( id, 1 );
				
				iPoints[ id ] -= get_pcvar_num( godmode_cost );
				godmode[ id ] = true;
				
				shopused[ id ]--;
				LeftItems( id );	
				
				if( get_pcvar_num( godmode_time ) != 0 )
				{
					godmode_counter[ id ] = get_pcvar_num( godmode_time );
					GodmodeCounter( id );
					
					ColorChat( id, GREEN, "%s^3 You^1 bought^4 Godmode^3 for^4 %d^1 second%s.", PREFIX, get_pcvar_num( godmode_time ), get_pcvar_num( godmode_time ) > 1 ? "s" : "" );
				}
				else
				{
					ColorChat( id, GREEN, "%s^3 You^1 bought^4 buy^4 Godmode^3 for^4 1^1 round.", PREFIX );
				}
				
				SavePoints( id );
			}
			else
			{
				NoPoints( id );
				return PLUGIN_HANDLED;
			}		
		}
		case 6:
		{
			if( speed[ id ] ) 
			{
				AlreadyUsed( id );
				return PLUGIN_HANDLED;
			}
			
			if( iPoints[ id ] >= get_pcvar_num( speed_cost ) )
			{
				set_user_maxspeed( id, 700.0 );
				client_cmd( id, "cl_forwardspeed 700" );
				
				iPoints[ id ] -= get_pcvar_num( speed_cost );
				speed[ id ] = true;
				
				shopused[ id ]--;
				LeftItems( id );
				
				if( get_pcvar_num( speed_time ) != 0 )
				{
					speed_counter[ id ] = get_pcvar_num( speed_time );
					SpeedCounter( id );
					ColorChat( id, GREEN, "%s^3 You^1 bought^4 Speed^3 for^4 %d^1 second%s.", PREFIX, get_pcvar_num( speed_time ), get_pcvar_num( speed_time ) > 1 ? "s" : "" );
				}
				else
				{
					ColorChat( id, GREEN, "%s^3 You^1 bought^4 Speed^3 for^4 1^1 round.", PREFIX );
				}
				
				SavePoints( id );
			}
			else
			{
				NoPoints( id );
				return PLUGIN_HANDLED;
			}
		}
		case 7:
		{
			if( awp[ id ] ) 
			{
				AlreadyUsed( id );
				return PLUGIN_HANDLED;
			}
			
			if( iPoints[ id ] >= get_pcvar_num( awp_cost ) )
			{
				if( !user_has_weapon( id, CSW_AWP ) )
				{
					give_item( id, "weapon_awp" );
					cs_set_weapon_ammo( find_ent_by_owner( 1, "weapon_awp", id ), get_pcvar_num( awp_ammo ) );	
					
					iPoints[ id ] -= get_pcvar_num( awp_cost );
					awp[ id ] = true;
					
					shopused[ id ]--;
					LeftItems( id );
					
					ColorChat( id, GREEN, "%s^3 You^1 bought^4 AWP^1 witch^3 %d^4 bullet%s^1.", PREFIX, get_pcvar_num( awp_ammo ), get_pcvar_num( awp_ammo ) == 1 ? "" : "s" );
					SavePoints( id );
				}
			}
			else
			{
				NoPoints( id );
				return PLUGIN_HANDLED;
			}
		}
		case 8:
		{
			if( deagle[ id ] ) 
			{
				AlreadyUsed( id );
				return PLUGIN_HANDLED;
			}
			
			if( iPoints[ id ] >= get_pcvar_num( deagle_cost ) )
			{
				if( !user_has_weapon( id, CSW_DEAGLE ) )
				{
					give_item( id, "weapon_deagle" );
					cs_set_weapon_ammo( find_ent_by_owner( 1, "weapon_deagle", id ), get_pcvar_num( deagle_ammo ) );	
					
					iPoints[ id ] -= get_pcvar_num( deagle_cost );
					deagle[ id ] = true;
					
					shopused[ id ]--;
					LeftItems( id );
					
					ColorChat( id, GREEN, "%s^3 You^1 bought^4 Deagle^1 witch^3 %d^4 bullet%s^1.", PREFIX, get_pcvar_num( deagle_ammo ), get_pcvar_num( deagle_ammo ) == 1 ? "" : "s" );
					SavePoints( id );
				}
			}
			else
			{
				NoPoints( id );
				return PLUGIN_HANDLED;
			}
		}
		case 9:
		{
			if( health[ id ] ) 
			{
				AlreadyUsed( id );
				return PLUGIN_HANDLED;
			}
			
			if( iPoints[ id ] >= get_pcvar_num( health_cost ) )
			{
				if( get_user_health( id ) < 255 )
				{
					new hp = iAdmin[ id ] ? get_pcvar_num( health_amount ) * 2 : get_pcvar_num( health_amount );
					
					set_user_health( id, get_user_health( id ) + hp );
					client_cmd( id, "spk items/smallmedkit1.wav" );
					
					iPoints[ id ] -= get_pcvar_num( health_cost );
					health[ id ] = true;
					
					shopused[ id ]--;
					LeftItems( id );
					
					ColorChat( id, GREEN, "%s^3 You^1 bought^4 +%d Health!", PREFIX, hp );
					SavePoints( id );
				}
			}
			else
			{
				NoPoints( id );
				return PLUGIN_HANDLED;
			}
		}
		case 10:
		{
			if( armor[ id ] ) 
			{
				AlreadyUsed( id );
				return PLUGIN_HANDLED;
			}
			
			if( iPoints[ id ] >= get_pcvar_num( armor_cost ) )
			{
				if( get_user_armor( id ) < 300 )
				{
					new ap = iAdmin[ id ] ? get_pcvar_num( armor_amount ) * 2 : get_pcvar_num( armor_amount );
					
					cs_set_user_armor( id, get_user_armor( id ) + ap, ap <= 100 ? CS_ARMOR_KEVLAR : CS_ARMOR_VESTHELM ); 
					client_cmd( id, "spk items/ammopickup2.wav" );
					
					iPoints[ id ] -= get_pcvar_num( armor_cost );
					armor[ id ] = true;
					
					shopused[ id ]--;
					LeftItems( id );
					
					ColorChat( id, GREEN, "%s^3 You^1 bought^4 +%d Armor!", PREFIX, ap );
					SavePoints( id );
				}
			}
			else
			{
				NoPoints( id );
				return PLUGIN_HANDLED;
			}
		}
		case 11:
		{
			if( gravity[ id ] ) 
			{
				AlreadyUsed( id );
				return PLUGIN_HANDLED;
			}
			
			if( iPoints[ id ] >= get_pcvar_num( gravity_cost ) )
			{
				set_user_gravity( id, 0.4 );
				
				iPoints[ id ] -= get_pcvar_num( gravity_cost );
				gravity[ id ] = true;
				
				shopused[ id ]--;
				LeftItems( id );
				
				if( get_pcvar_num( gravity_time ) != 0 )
				{
					gravity_counter[ id ] = get_pcvar_num( gravity_time );
					GravityCounter( id );
					
					ColorChat( id, GREEN, "%s^3 You^1 bought^4 Gravity^3 for^4 %d^1 second%s.", PREFIX, get_pcvar_num( gravity_time ), get_pcvar_num( gravity_time ) > 1 ? "s" : "" );
				}
				else
				{
					ColorChat( id, GREEN, "%s^3 You^1 bought^4 Gravity^3 for^4 1^1 round.", PREFIX );		
				}
				
				SavePoints( id );
			}
			else
			{
				NoPoints( id );
				return PLUGIN_HANDLED;
			}
		}
		case 12:
		{
			if( xp[ id ] ) 
			{
				AlreadyUsed( id );
				return PLUGIN_HANDLED;
			}
			
			if( iPoints[ id ] >= get_pcvar_num( xp_cost ) )
			{
				hnsxp_set_user_xp( id, hnsxp_get_user_xp( id ) + get_pcvar_num( xp_amount ) );
				
				iPoints[ id ] -= get_pcvar_num( xp_cost );
				xp[ id ] = true;
				
				shopused[ id ]--;
				LeftItems( id );
				
				ColorChat( 0, GREEN, "%s^3 %s^1 buy^4 %d^3 XP^1!", PREFIX, iUserName, get_pcvar_num( xp_amount ) );
				SavePoints( id );
			}
			else
			{
				NoPoints( id );
				return PLUGIN_HANDLED;
			}
		}
		case 13:
		{
			if( antiflash[ id ] ) 
			{
				AlreadyUsed( id );
				return PLUGIN_HANDLED;
			}
			if( iPoints[ id ] >= get_pcvar_num( antiflash_cost ) )
			{
				iPoints[ id ] -= get_pcvar_num( antiflash_cost );
				antiflash[ id ] = true;
				
				#if defined ADMIN_SCREEN_MENU
				user_flash_immunity( id, 1 );
				#endif
				
				shopused[ id ]--;
				LeftItems( id );
				
				ColorChat( 0, GREEN, "%s^3 %s^1 bought^4 Flash Immunity^1!", PREFIX, iUserName );
				SavePoints( id );
			}
			else
			{
				NoPoints( id );
				return PLUGIN_HANDLED;
			}
		}
		case 14:
		{
			if( antihe[ id ] ) 
			{
				AlreadyUsed( id );
				return PLUGIN_HANDLED;
			}
			
			if( iPoints[ id ] >= get_pcvar_num( antihe_cost ) )
			{
				iPoints[ id ] -= get_pcvar_num( antihe_cost );
				antihe[ id ] = true;
				
				shopused[ id ]--;
				LeftItems( id );
				
				ColorChat( 0, GREEN, "%s^3 %s^1 bought^4 He Immunity^1!", PREFIX, iUserName );
				SavePoints( id );
			}
			else
			{
				NoPoints( id );
				return PLUGIN_HANDLED;
			}
		}
		case 15:
		{	
			if( antifrost[ id ] ) 
			{
				AlreadyUsed( id );
				return PLUGIN_HANDLED;
			}
			
			if( iPoints[ id ] >= get_pcvar_num( antifrost_cost ) )
			{
				iPoints[ id ] -= get_pcvar_num( antifrost_cost );
				
				new afn = iAdmin[ id ] ? frost_imm * 2 : frost_imm;
				set_user_nofrost( id, afn );
				
				antifrost[ id ] = true;
				shopused[ id ]--;
				
				LeftItems( id );		
				ColorChat( 0, GREEN, "%s^3 %s^1 bought^4 Frost Immunity^1!", PREFIX, iUserName );
				
				SavePoints( id );
			}
			else
			{
				NoPoints( id );
				return PLUGIN_HANDLED;
			}
		}
	}
	
	menu_destroy( menu );
	CmdMainMenu( id );
	return PLUGIN_HANDLED;
}

public CmdPlayerPointsMenu( id )
{
	new iTitle[ 64 ];
	formatex( iTitle, charsmax( iTitle ), "\yBetterPlay \d- \wHidenSeek BM \rShop^n\yPlayerPoints Menu^n^n\wYour point%s: \y%i", iPoints[ id ] > 1 ? "s" : "", iPoints[ id ] );
	
	new menu = menu_create( iTitle, "CmdPlayerPointsHandler" );
	
	new name[ 33 ], ip[ 33 ];
	for( new i = 1; i <= 32; i++ )
	{
		if( !is_user_connected( i ) ) continue;
		
		get_user_name( i, name, charsmax( name ) );
		get_user_ip( i, ip, charsmax( ip ), 0 );
		
		menu_additem( menu, name, ip );
	}
	
	menu_display( id, menu );
}

public CmdPlayerPointsHandler( id, menu, item )
{
	if( item == MENU_EXIT )
	{
		menu_destroy( menu );
		CmdMainMenu( id );
		return PLUGIN_HANDLED;
	}
	
	static iAccess, iIP[ 33 ], iCallBack;
	menu_item_getinfo( menu, item, iAccess, iIP, charsmax( iIP ), _, _, iCallBack );
	menu_destroy( menu );
	
	new player = find_player( "d", iIP );
	
	if( !is_user_connected( player ) )
	{
		CmdMainMenu( id );
		return PLUGIN_HANDLED;
	}
	
	new name[ 33 ];
	get_user_name( player, name, charsmax( name ) );
	
	static motd[ 2500 ];
	new len = copy( motd, sizeof( motd ) - 1, "<html>");
	
	len += format( motd[ len ], sizeof( motd ) - len - 1, "<b><font size=^"4^">Name:</font></b> %s<br><br>", name );
	len += format( motd[ len ], sizeof( motd ) - len - 1, "<b><font size=^"4^">Point%s:</font></b> %i<br><br>", iPoints[ player ] == 1 ? "" : "s", iPoints[ player ] );
	
	len += format( motd[ len ], sizeof( motd ) - len - 1, "</html>" );
	
	show_motd( id, motd, "Player Points" );
	
	CmdPlayerPointsMenu( id );
	
	return PLUGIN_HANDLED;
}

public CmdGiveMenu( id )
{
	new iTitle[ 64 ];
	formatex( iTitle, charsmax( iTitle ), "\yBetterPlay \d- \wHidenSeek BM \rShop^n\yGive Menu^n^n\wYour point%s: \y%i", iPoints[ id ] > 1 ? "s" : "", iPoints[ id ] );
	
	new menu = menu_create( iTitle, "CmdGiveMenuHandler" );
	
	new iPlayers[ 32 ], iNum, tempid[ 10 ], iName[ 33 ];
	get_players( iPlayers, iNum, "ch" );
	
	for( new i; i < iNum; i++ )
	{
		new plr = iPlayers[ i ];
		
		num_to_str( plr, tempid, charsmax( tempid ) );
		get_user_name( plr, iName, charsmax( iName ) );
		
		menu_additem( menu, iName, tempid, 0 );
	}
	
	menu_setprop( menu, MPROP_EXIT, MEXIT_ALL );
	menu_display( id, menu );
}

public CmdGiveMenuHandler( id, menu, item )
{
	if( item == MENU_EXIT )
	{
		menu_destroy( menu );
		CmdMainMenu( id );
		return PLUGIN_HANDLED;
	}
	
	new iData[ 6 ], iName[ 63 ], iAccess, iCallback;
	menu_item_getinfo( menu, item, iAccess, iData, charsmax( iData ), iName, charsmax( iName ), iCallback );
	
	get_user_name( str_to_num( iData ), cacheUserName, charsmax( cacheUserName ) );
	client_cmd( id, "messagemode give" );
	
	menu_destroy( menu );
	return PLUGIN_HANDLED;
}

public CmdRemoveMenu( id )
{
	new iTitle[ 64 ];
	formatex( iTitle, charsmax( iTitle ), "\yBetterPlay \d- \wHidenSeek BM \rShop^n\yRemove Menu^n^n\wYour point%s: \y%i", iPoints[ id ] > 1 ? "s" : "", iPoints[ id ] );
	
	new menu = menu_create( iTitle, "CmdRemoveMenuHandler" );
	
	new iPlayers[ 32 ], iNum, tempid[ 10 ], iName[ 33 ];
	get_players( iPlayers, iNum, "ch" );
	
	for( new i; i < iNum; i++ )
	{
		new plr = iPlayers[ i ];
		
		num_to_str( plr, tempid, charsmax( tempid ) );
		get_user_name( plr, iName, charsmax( iName ) );
		
		menu_additem( menu, iName, tempid, 0 );
	}
	
	menu_setprop( menu, MPROP_EXIT, MEXIT_ALL );
	menu_display( id, menu );
}

public CmdRemoveMenuHandler( id, menu, item )
{
	if( item == MENU_EXIT )
	{
		menu_destroy( menu );
		CmdMainMenu( id );
		return PLUGIN_HANDLED;
	}
	
	new iData[ 6 ], iName[ 63 ], iAccess, iCallback;
	menu_item_getinfo( menu, item, iAccess, iData, charsmax( iData ), iName, charsmax( iName ), iCallback );
	
	get_user_name( str_to_num( iData ), cacheUserName, charsmax( cacheUserName ) );
	client_cmd( id, "messagemode remove" );
	
	menu_destroy( menu );
	return PLUGIN_HANDLED;
}

public CmdDonateMenu( id )
{
	new iTitle[ 64 ];
	formatex( iTitle, charsmax( iTitle ), "\rBetterPlay \d- \yHidenSeek BM Shop^nDonate Menu^n^n\wYour point%s: \y%i", iPoints[ id ] > 1 ? "s" : "", iPoints[ id ] );
	
	new menu = menu_create( iTitle, "CmdDonateMenuHandler" );
	
	new iPlayers[ 32 ], iNum, tempid[ 10 ], iName[ 33 ];
	get_players( iPlayers, iNum, "ch" );
	
	for( new i; i < iNum; i++ )
	{
		new plr = iPlayers[ i ];
		
		num_to_str( plr, tempid, charsmax( tempid ) );
		get_user_name( plr, iName, charsmax( iName ) );
		
		menu_additem( menu, iName, tempid, 0 );
	}
	
	menu_setprop( menu, MPROP_EXIT, MEXIT_ALL );
	menu_display( id, menu );
}

public CmdDonateMenuHandler( id, menu, item )
{
	if( item == MENU_EXIT )
	{
		menu_destroy( menu );
		CmdMainMenu( id );
		return PLUGIN_HANDLED;
	}
	
	new iData[ 6 ], iName[ 63 ], iAccess, iCallback;
	menu_item_getinfo( menu, item, iAccess, iData, charsmax( iData ), iName, charsmax( iName ), iCallback );
	
	get_user_name( str_to_num( iData ), cacheUserName, charsmax( cacheUserName ) );
	client_cmd( id, "messagemode donate" );
	
	menu_destroy( menu );
	return PLUGIN_HANDLED;
}

public Give( id )
{
	if( !( get_user_flags( id ) & PLUGIN_ACCESS ) ) return PLUGIN_HANDLED;
	
	new arg[ 33 ];
	read_argv( 1, arg, charsmax( arg ) );
	
	if( !is_str_num( arg ) )
	{
		ColorChat( id, GREEN, "%s^1 Invalid input,^3 please try^4 again^1.", PREFIX );
		client_cmd( id, "messagemode give" );
		
		return PLUGIN_HANDLED;
	}
	
	client_cmd( id, "shop_give_points ^"%s^" %d", cacheUserName, str_to_num( arg ) );
	CmdMainMenu( id );
	
	return PLUGIN_HANDLED;
}

public Remove( id )
{
	if( !( get_user_flags( id ) & PLUGIN_ACCESS ) ) return PLUGIN_HANDLED;
	
	new arg[ 33 ];
	read_argv( 1, arg, charsmax( arg ) );
	
	if( !is_str_num( arg ) )
	{
		ColorChat( id, GREEN, "%s^1 Invalid input,^3 please try^4 again^1.", PREFIX );
		client_cmd( id, "messagemode remove" );
		
		return PLUGIN_HANDLED;
	}
	
	client_cmd( id, "shop_remove_points ^"%s^" %d", cacheUserName, str_to_num( arg ) );
	CmdMainMenu( id );
	
	return PLUGIN_HANDLED;
}

public Donate( id )
{
	new arg[ 33 ];
	read_argv( 1, arg, charsmax( arg ) );
	
	if( !is_str_num( arg ) )
	{
		ColorChat( id, GREEN, "%s^1 Invalid input,^3 please try^4 again^1.", PREFIX );
		client_cmd( id, "messagemode donate" );
		
		return PLUGIN_HANDLED;
	}
	
	if( iPoints[ id ] < str_to_num( arg ) ) return PLUGIN_HANDLED;
	
	client_cmd( id, "shop_donate_points ^"%s^" %d", cacheUserName, str_to_num( arg ) );
	CmdMainMenu( id );
	
	return PLUGIN_HANDLED;
}

public ChameleonCounter( id )
{		
	if( is_user_connected( id ) )
	{
		if( chameleon_counter[ id ] == 0 )
		{
			set_hudmessage( 255, 0, 0, -1.0, 0.2, 1, 0.02, 3.0,_,_,-1 );
			show_hudmessage( id,"Chameleon expired." );
			
			if( cs_get_user_team( id ) == CS_TEAM_CT )
			{
				cs_set_user_model( id, ct_models[ random_num( 0, 3 ) ] );
			}
			else if( cs_get_user_team( id ) == CS_TEAM_T )
			{
				cs_set_user_model( id, t_models[ random_num( 0, 3 ) ] );
			}
			
			return PLUGIN_HANDLED;
		}
		else
		{
			set_hudmessage( R, G, B, -1.0, 0.2, 0, 0.02, 0.8,_,_,-1 );
			show_hudmessage( id, "Chameleon expires in %d second%s.", chameleon_counter[ id ], chameleon_counter[ id ] > 1 ? "s" : "" );
		}
		
		chameleon_counter[ id ]--;
		
		if( chameleon_counter[ id ] >= 0 ) set_task( 1.0, "ChameleonCounter", id );
	}
	return PLUGIN_HANDLED;
}

public GodmodeCounter( id )
{		
	if( is_user_connected( id ) )
	{
		if( godmode_counter[ id ] == 0 )
		{
			set_hudmessage( 255, 0, 0, -1.0, 0.23, 1, 0.02, 3.0,_,_,-1 );
			show_hudmessage( id,"Godmode expired." );
			set_user_godmode( id, 0 );
			return PLUGIN_HANDLED;
		}
		else
		{
			set_hudmessage( R, G, B, -1.0, 0.23, 0, 0.02, 0.8,_,_,-1 );
			show_hudmessage( id, "Godmode expires in %d second%s.", godmode_counter[ id ], godmode_counter[ id ] > 1 ? "s" : "" );
		}
		
		godmode_counter[ id ]--;
		
		if( godmode_counter[ id ] >= 0 ) set_task( 1.0, "GodmodeCounter", id );
	}
	return PLUGIN_HANDLED;
}

public SpeedCounter( id )
{		
	if( is_user_connected( id ) )
	{
		if( speed_counter[ id ] == 0 )
		{
			set_hudmessage( 255, 0, 0, -1.0, 0.26, 1, 0.02, 3.0,_,_,-1 );
			show_hudmessage( id,"Speed expired." );
			
			set_user_maxspeed( id, 250.0 );
			client_cmd( id, "cl_forwardspeed 400" );
			speed[ id ] = false;
			
			return PLUGIN_HANDLED;
		}
		else
		{
			set_hudmessage( R, G, B, -1.0, 0.26, 0, 0.02, 0.8,_,_,-1 );
			show_hudmessage( id, "Speed expires in %d second%s.", speed_counter[ id ], speed_counter[ id ] > 1 ? "s" : "" );
		}
		
		speed_counter[ id ]--;
		
		if( speed_counter[ id ] >= 0 ) set_task( 1.0, "SpeedCounter", id );
	}
	return PLUGIN_HANDLED;
}

public GravityCounter( id )
{		
	if( is_user_connected( id ) )
	{
		if( gravity_counter[ id ] == 0 )
		{
			set_hudmessage( 255, 0, 0, -1.0, 0.29, 1, 0.02, 3.0,_,_,-1 );
			show_hudmessage( id,"Gravity expired." );
			set_user_gravity( id );
			return PLUGIN_HANDLED;
		}
		else
		{
			set_hudmessage( R, G, B, -1.0, 0.29, 0, 0.02, 0.8,_,_,-1 );
			show_hudmessage( id, "Gravity expires in %d second%s.", gravity_counter[ id ], gravity_counter[ id ] > 1 ? "s" : "" );
		}
		
		gravity_counter[ id ]--;
		
		if( gravity_counter[ id ] >= 0 ) set_task( 1.0, "GravityCounter", id );
	}
	return PLUGIN_HANDLED;
}

public eCurWeapon( id ) 
{
	if( speed[ id ] ) 
	{
		set_user_maxspeed( id, 700.0 );
	}
}

public LoadPoints( id )
{
	if( !is_user_bot( id ) && !is_user_hltv( id ) )
	{
		new vaultdata[ 256 ], points[ 33 ], UserName[ 33 ];
		get_user_name( id, UserName, charsmax( UserName ) );
		
		format( vaultdata, charsmax( vaultdata ), "%i#", iPoints[ id ] );
		nvault_get( vault, UserName, vaultdata, 255 );
		
		replace_all( vaultdata, 255, "#", " " );
		parse( vaultdata, points, 32 );
		
		iPoints[ id ] = str_to_num( points );
	}
}

public SavePoints( id )
{
	if( !is_user_bot( id ) && !is_user_hltv( id ) )
	{
		new vaultdata[ 256 ], UserName[ 33 ];
		get_user_name( id, UserName, charsmax( UserName ) );
		
		format( vaultdata, charsmax( vaultdata ), "%i#", iPoints[ id ] );
		nvault_set( vault, UserName, vaultdata );
	}
}

AlreadyUsed( id ) 
{ 
ColorChat( id, GREEN, "%s^1 You^3 have^4 already^1 purchased^3 this^4 article^1!", PREFIX );
BlindPlayer( id, 0.8, 0.8, 0, 255, 0, 150 );
} 

NoPoints( id )
{
ColorChat( id, GREEN, "%s^1 You^3 don't^4 have^1 enough^3 points^4 to^1 purchase^3 this^4 article^1!", PREFIX );
BlindPlayer( id, 0.8, 0.8, 255, 0, 0, 150 );
}

LeftItems( id )
{
set_hudmessage( 200, 100, 0, -1.0, 0.35, 0, 4.0, 4.0, 0.1, 0.1, 2 );

if( shopused[ id ] ) 
{
show_hudmessage( id, "You can buy %d item%s.", shopused[ id ], shopused[ id ] == 1 ? "" : "s" );
}
else 
{
show_hudmessage( id, "Please wait for the next round, ^nif you want to buy articles." );
}
}

BlindPlayer( index, Float:fDuration, Float:fHoldTime, cRed, cGreen, cBlue, cAlpha )
{
message_begin( MSG_ONE_UNRELIABLE, get_user_msgid( "ScreenFade" ), { 0, 0, 0 }, index );

write_short( floatround( 4096.0 * fDuration, floatround_round ) );
write_short( floatround( 4096.0 * fHoldTime, floatround_round ) );
write_short( 4096 );

write_byte( cRed );
write_byte( cGreen );
write_byte( cBlue );
write_byte( cAlpha );

message_end( );
}

/// NoFlash Blinding - Start
public bad_fix2()
{
new Float:gametime = get_gametime();
if( gametime - g_gametime2 > 2.5 ) for(new i = 0; i < 32; i++) grenade[i] = 0;
}

public eventFlash( id )
{
new Float:gametime = get_gametime();

if(gametime != g_gametime)
{ 
g_owner = get_grenade_owner();
g_gametime = gametime;

for(new i = 0; i < 33; i++) g_track[i] = false;

g_track_enemy = false;
}    

if(is_user_connected(g_owner) && antiflash[ id ] )
{
g_track_enemy = true;

message_begin(MSG_ONE, get_user_msgid("ScreenFade"), {0,0,0}, id);
write_short(1);
write_short(1);
write_short(1);
write_byte(0);
write_byte(0);
write_byte(0);
write_byte(255);
message_end();
}
}

public flash_delay()
{
if(g_track_enemy == false) 
{
for(new i = 0; i < 33; i++) 
{
if(g_track[i] == true && is_user_connected(i)) 
{
message_begin(MSG_ONE, get_user_msgid("ScreenFade"), {0,0,0}, i);
write_short(1);
write_short(1);
write_short(1);
write_byte(0);
write_byte(0);
write_byte(0);
write_byte(255);
message_end();
}
}
}
}

public grenade_throw() 
{
if(g_sync_check_data == 0) return PLUGIN_CONTINUE;

g_sync_check_data--;

if(read_datanum() < 2) return PLUGIN_HANDLED_MAIN;
if(read_data(1) == 11 && (read_data(2) == 0 || read_data(2) == 1)) add_grenade_owner(last);

return PLUGIN_CONTINUE;
}

public fire_in_the_hole()
{
new name[32];
read_data(3, name, 31);

new temp_last = get_user_index(name);
new junk;

if((temp_last == 0) || (!is_user_connected(temp_last))) return PLUGIN_CONTINUE;

if(get_user_weapon(temp_last,junk,junk) == CSW_FLASHBANG) 
{
last = temp_last;
g_sync_check_data = 2; 
}

return PLUGIN_CONTINUE;
}

public fire_in_the_hole2() 
{
new name[32];
read_data(4, name, 31);

new temp_last = get_user_index(name);
new junk;

if((temp_last == 0) || (!is_user_connected(temp_last))) return PLUGIN_CONTINUE;

if(get_user_weapon(temp_last,junk,junk) == CSW_FLASHBANG) 
{    
last = temp_last;
g_sync_check_data = 2;
}

return PLUGIN_CONTINUE;
}

add_grenade_owner(owner) 
{
new Float:gametime = get_gametime();
g_gametime2 = gametime;

for(new i = 0; i < 32; i++) 
{
if(grenade[i] == 0) 
{
grenade[i] = owner;
return;
}
}
}

get_grenade_owner() 
{
new which = grenade[0];

for(new i = 1; i < 32; i++) grenade[i-1] = grenade[i];

grenade[31] = 0;
return which;
}

// from XxAvalanchexX "Flashbang Dynamic Light"
public fw_emitsound(entity,channel,const sample[],Float:volume,Float:attenuation,fFlags,pitch) {
if(!equali(sample,"weapons/flashbang-1.wav") && !equali(sample,"weapons/flashbang-2.wav"))
return FMRES_IGNORED;

new Float:gametime = get_gametime();

//in case no one got flashed, the sound happens after all the flashes, same game time
if(gametime != g_gametime) {
g_owner = get_grenade_owner();
return FMRES_IGNORED;
}
return FMRES_IGNORED;
}
// NoFlash Blinding - End 

public taskLoadFile( )
{
new file[ 124 ], dir[ 124 ];
get_configsdir( dir, charsmax( dir ) );
formatex( file, charsmax( file ), "%s/HidenSeekShop.cfg", dir );

if( file_exists( file ) )
{
server_cmd( "exec %s", file );
server_exec( );
}
else
{
CreateFile( file );
log_amx( "HidenSeekShop.cfg is not found in configs folder. File is created..." );
}
}

CreateFile( const file[ ] )
{
new i = fopen( file, "wt" );

fprintf( i, "// %s v%s by %s^n^n", PLUGIN, VERSION, AUTHOR );

fprintf( i, "shop_he_cost %i^n", get_pcvar_num( he_cost ) );
fprintf( i, "shop_flash_cost %i^n", get_pcvar_num( flash_cost ) );
fprintf( i, "shop_smoke_cost %i^n", get_pcvar_num( smoke_cost ) );
fprintf( i, "shop_chameleon_cost %i^n", get_pcvar_num( chameleon_cost ) );
fprintf( i, "shop_godmode_cost %i^n", get_pcvar_num( godmode_cost ) );
fprintf( i, "shop_speed_cost %i^n", get_pcvar_num( speed_cost ) );
fprintf( i, "shop_awp_cost %i^n", get_pcvar_num( awp_cost ) );
fprintf( i, "shop_deagle_cost %i^n", get_pcvar_num( deagle_cost ) );
fprintf( i, "shop_health_cost %i^n", get_pcvar_num( health_cost ) );
fprintf( i, "shop_armor_cost %i^n", get_pcvar_num( armor_cost ) );
fprintf( i, "shop_gravity_cost %i^n", get_pcvar_num( gravity_cost ) );
fprintf( i, "shop_xp_cost %i^n", get_pcvar_num( xp_cost ) );
fprintf( i, "shop_antiflash_cost %i^n", get_pcvar_num( antiflash_cost ) );
fprintf( i, "shop_antihe_cost %i^n", get_pcvar_num( antihe_cost ) );
fprintf( i, "shop_antifrost_cost %i^n^n", get_pcvar_num( antifrost_cost ) );

fprintf( i, "shop_chameleon_time %i^n", get_pcvar_num( chameleon_time ) );
fprintf( i, "shop_godmode_time %i^n", get_pcvar_num( godmode_time ) );
fprintf( i, "shop_speed_time %i^n", get_pcvar_num( speed_time ) );
fprintf( i, "shop_gravity_time %i^n^n", get_pcvar_num( gravity_time ) );

fprintf( i, "shop_awp_ammo %i^n", get_pcvar_num( awp_ammo ) );
fprintf( i, "shop_deagle_ammo %i^n^n", get_pcvar_num( deagle_ammo ) );

fprintf( i, "shop_health_amount %i^n", get_pcvar_num( health_amount ) );
fprintf( i, "shop_armor_amount %i^n", get_pcvar_num( armor_amount ) );
fprintf( i, "shop_xp_amount %i^n^n", get_pcvar_num( xp_amount ) );

fprintf( i, "shop_points_kill %i^n", get_pcvar_num( kill_points ) );
fprintf( i, "shop_points_headshot %i^n", get_pcvar_num( headshot_points ) );
fprintf( i, "shop_points_grenade %i^n^n", get_pcvar_num( grenade_points ) );

fprintf( i, "shop_bonuspoints_on %i^n", get_pcvar_num( cvar_bonus_on ) );
fprintf( i, "shop_antihe_max_immunes %i^n^n", get_pcvar_num( antihe_max_immunes ) );

fprintf( i, "shop_hh_start %i^n", get_pcvar_num( hh_start ) );
fprintf( i, "shop_hh_end %i", get_pcvar_num( hh_end ) );

fclose( i );
}






