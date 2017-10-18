/* Originally made to the server of Tasca do Ze (tascadoze.com) */

#include < amxmodx >
#include < amxmisc >
#include < cstrike >
#include < csx >
#include < hamsandwich >
#include < sqlx >

new const PLUGIN[ ] = "Basic SkillPoints (SQL)"
new const VERSION[ ] = "1.1.9"
new const AUTHOR[ ] = "guipatinador"

#define ADMIN ADMIN_RCON
#define MAXCLASSES 5
#define MAXLEVELS 5
#define MAXPONTUATION 10000 // max skillpoints per player
#define MAX_PLAYERS 32

new const CLASSES[ MAXCLASSES ][ ] = {
	"BOT",
	"NOOB",
	"GAMER",
	"LEET",
	"TOP"
}

new const LEVELS[ MAXLEVELS ] = {
	500,
	1200,
	1800,
	2500,
	100000 /* high value (not reachable) */
}

new const SQL_TABLE[ ] = "skillpoints_v1"
new const PREFIX[ ] = "[SkillPoints]"

new g_iK
new const g_ChatAdvertise[ ][ ] = {
	"!g%s!n Write!t /myskill!n to see your SkillPoints",
	"!g%s!n Write!t /restartskill!n to restart your SkillPoints and level",
	"!g%s!n Write!t /rankskill!n to see your rank",
	"!g%s!n Write!t /topskill!n to see the top SkillPointers"
}

new g_iMaxPlayers
new g_szAuthID[ MAX_PLAYERS + 1 ][ 35 ]
new g_szName[ MAX_PLAYERS + 1 ][ 32 ]

new Handle:g_SqlTuple
new g_iCount
new g_iRank[ MAX_PLAYERS + 1 ]
new g_iCurrentKills[ MAX_PLAYERS + 1 ]
new g_szMotd[ 1024 ]

new g_pcvarHost
new g_pcvaruUser
new g_pcvarPass
new g_pcvarDB

new g_iPoints[ MAX_PLAYERS + 1 ]
new g_iLevels[ MAX_PLAYERS + 1 ]
new g_iClasses[ MAX_PLAYERS + 1 ]

new g_TimeBetweenAds

new bool:is_user_ignored[ MAX_PLAYERS + 1 ]
new bool:g_bRoundEnded

new g_iAdsOnChat
new g_iEnableAnnounceOnChat
new g_iEnableShowSkillPointsOnNick
new g_iHideChangeNickNotification
new g_iEnableSkillPointsCmd
new g_iEnableSkillPointsRestart
new g_iEnableSkillPointsCmdRank
new g_iEnableSkillPointsTop15
new g_iHideCmds
new g_iEnableWonPointsHour
new g_iWonPointsHour
new g_iLostPointsTK
new g_iLostPointsSuicide
new g_iWonPointsKill
new g_iLostPointsDeath
new g_iWonPointsHeadshot
new g_iLostPointsHeadshot
new g_iWonPointsKnife
new g_iLostPointsKnife
new g_iWonPointsGrenade
new g_iLostPointsGrenade
new g_iWonPointsTerrorists
new g_iWonPointsCounterTerrorists
new g_iLostPointsTerrorists
new g_iLostPointsCounterTerrorists
new g_iWonPointsPlanter
new g_iWonPointsPlanterExplode
new g_iWonPointsDefuser
new g_iWonPoints4k
new g_iWonPoints5k
new g_iNegativePoints

public plugin_init( )
{
	register_plugin( PLUGIN, VERSION, AUTHOR )
	
	register_clcmd( "say /myskill", "GetSkillPoints" )
	register_clcmd( "say_team /myskill", "GetSkillPoints" )
	register_clcmd( "say !myskill", "GetSkillPoints" )
	register_clcmd( "say_team !myskill", "GetSkillPoints" )
	register_clcmd( "say .myskill", "GetSkillPoints" )
	register_clcmd( "say_team .myskill", "GetSkillPoints" )
	
	register_clcmd( "say /restartskill", "RestartSkillPoints" )
	register_clcmd( "say_team /restartskill", "RestartSkillPoints" )
	register_clcmd( "say !restartskill", "RestartSkillPoints" )
	register_clcmd( "say_team !restartskill", "RestartSkillPoints" )
	register_clcmd( "say .restartskill", "RestartSkillPoints" )
	register_clcmd( "say_team .restartskill", "RestartSkillPoints" )
	
	register_clcmd( "say /rankskill", "SkillRank" )
	register_clcmd( "say_team /rankskill", "SkillRank" )
	register_clcmd( "say !rankskill", "SkillRank" )
	register_clcmd( "say_team !rankskill", "SkillRank" )
	register_clcmd( "say .rankskill", "SkillRank" )
	register_clcmd( "say_team .rankskill", "SkillRank" )
	
	register_clcmd( "say /topskill", "TopSkill" )
	register_clcmd( "say_team /topskill", "TopSkill" )
	register_clcmd( "say !topskill", "TopSkill" )
	register_clcmd( "say_team !topskill", "TopSkill" )
	register_clcmd( "say .topskill", "TopSkill" )
	register_clcmd( "say_team .topskill", "TopSkill" )
	
	register_concmd( "bps_give", "CmdGivePoints", ADMIN, "<target> <skillpoints to give>" )
	register_concmd( "bps_take", "CmdTakePoints", ADMIN, "<target> <skillpoints to take>" )
	
	RegisterHam( Ham_Spawn, "player", "FwdPlayerSpawnPost", 1 )
	
	register_message( get_user_msgid( "SayText" ), "MessageSayText" )
	
	register_event( "SendAudio", "TerroristsWin", "a", "2&%!MRAD_terwin" )
	register_event( "SendAudio", "CounterTerroristsWin", "a", "2&%!MRAD_ctwin" )
	
	register_event( "HLTV", "EventNewRound", "a", "1=0", "2=0" )
	register_logevent( "EventRoundEnd", 2, "1=Round_End" )
	
	g_iMaxPlayers = get_maxplayers( )
	
	RegisterCvars( )
	SqlInit( )
}

public plugin_natives( )
{
	register_library( "skillpoints" )
	
	register_native( "skillpoints", "_skillpoints" )
}


public _skillpoints( plugin, params )
{
	if( params != 1 )
	{
		return 0
	}
	
	new id = get_param( 1 )
	if( !id )
	{
		return 0
	}
	
	return g_iPoints[ id ]
}

public RegisterCvars( )
{
	g_iAdsOnChat = register_cvar( "bps_ads", "1" )
	g_TimeBetweenAds = register_cvar( "bps_time_between_ads", "300.0" )
	g_iEnableAnnounceOnChat = register_cvar( "bps_announce_on_chat", "1" )
	g_iEnableShowSkillPointsOnNick = register_cvar( "bps_skillpoints_on_nick", "1" )
	g_iHideChangeNickNotification = register_cvar( "bps_hide_change_nick_notification", "1" )
	g_iEnableSkillPointsCmd = register_cvar( "bps_skillpoints_cmd", "1" )
	g_iEnableSkillPointsRestart = register_cvar( "bps_skillpoints_cmd_restart", "1" )
	g_iEnableSkillPointsCmdRank = register_cvar( "bps_skillpoints_cmd_rank", "1" )
	g_iEnableSkillPointsTop15 = register_cvar( "bps_skillpoints_cmd_top15", "1" )
	g_iHideCmds = register_cvar( "bps_hide_cmd", "0" )
	g_iEnableWonPointsHour = register_cvar( "bps_enable_win_per_hour", "1" )
	g_iWonPointsHour = register_cvar( "bps_won_points_hour", "5" )
	g_iLostPointsTK = register_cvar( "bps_lost_points_tk", "5" )
	g_iLostPointsSuicide = register_cvar( "bps_lost_points_suicide", "1" )
	g_iWonPointsKill = register_cvar( "bps_won_points_kill", "1" )
	g_iLostPointsDeath = register_cvar( "bps_lost_points_kill", "1" )
	g_iWonPointsHeadshot = register_cvar( "bps_won_points_headshot", "2" )
	g_iLostPointsHeadshot = register_cvar( "bps_lost_points_headshot", "2" )
	g_iWonPointsKnife = register_cvar( "bps_won_points_knife", "3" )
	g_iLostPointsKnife = register_cvar( "bps_lost_points_knife", "3" )
	g_iWonPointsGrenade = register_cvar( "bps_won_points_grenade", "3" )
	g_iLostPointsGrenade = register_cvar( "bps_lost_points_grenade", "3" )
	g_iWonPointsTerrorists = register_cvar( "bps_won_points_ts", "1" )
	g_iWonPointsCounterTerrorists = register_cvar( "bps_won_points_cts", "1" )
	g_iLostPointsTerrorists = register_cvar( "bps_lost_points_ts", "1" )
	g_iLostPointsCounterTerrorists = register_cvar( "bps_lost_points_cts", "1" )
	g_iWonPointsPlanter = register_cvar( "bps_won_points_planter", "1" )
	g_iWonPointsPlanterExplode = register_cvar( "bps_won_points_planter_explode", "2" ) 
	g_iWonPointsDefuser = register_cvar( "bps_won_points_defuser", "3" )
	g_iWonPoints4k = register_cvar( "bps_won_points_4k", "4" )
	g_iWonPoints5k = register_cvar( "bps_won_points_5k", "5" )
	g_iNegativePoints = register_cvar( "bps_negative_points", "0" )
	
	g_pcvarHost = register_cvar( "bps_sql_host", "", FCVAR_PROTECTED )
	g_pcvaruUser = register_cvar( "bps_sql_user", "", FCVAR_PROTECTED )
	g_pcvarPass = register_cvar( "bps_sql_pass", "", FCVAR_PROTECTED )
	g_pcvarDB = register_cvar( "bps_sql_db", "", FCVAR_PROTECTED )
	
	if( get_pcvar_num( g_iAdsOnChat ) )
	{
		set_task( get_pcvar_float( g_TimeBetweenAds ), "ChatAdvertisements", _, _, _, "b" )
	}
}

public SqlInit( )
{
	new szHost[ 32 ]
	new szUser[ 32 ]
	new szPass[ 32 ]
	new szDB[ 32 ]
	
	get_pcvar_string( g_pcvarHost, szHost, charsmax( szHost ) )
	get_pcvar_string( g_pcvaruUser, szUser, charsmax( szUser ) )
	get_pcvar_string( g_pcvarPass, szPass, charsmax( szPass ) )
	get_pcvar_string( g_pcvarDB, szDB, charsmax( szDB ) )
	
	g_SqlTuple = SQL_MakeDbTuple( szHost, szUser, szPass, szDB )
	
	new g_Error[ 512 ]
	new ErrorCode
	new Handle:SqlConnection = SQL_Connect( g_SqlTuple, ErrorCode, g_Error, charsmax( g_Error ) )
	
	if( SqlConnection == Empty_Handle )
	{
		set_fail_state( g_Error )
	}
	
	new Handle:Queries
	Queries = SQL_PrepareQuery( SqlConnection, "CREATE TABLE IF NOT EXISTS %s ( ip VARCHAR( 35 ) PRIMARY KEY, nick VARCHAR( 32 ), skillpoints INT( 7 ), level INT( 2 ) )", SQL_TABLE )
	
	if( !SQL_Execute( Queries ) )
	{
		SQL_QueryError( Queries, g_Error, charsmax( g_Error ) )
		set_fail_state( g_Error )
	}
	
	SQL_FreeHandle( Queries )
	SQL_FreeHandle( SqlConnection )
	
	MakeTop15( )
}

public plugin_end( )
{
	SQL_FreeHandle( g_SqlTuple )
}

public client_authorized( id )
{
	g_szAuthID[ id ][ 0 ] = EOS
	g_szName[ id ][ 0 ]  = EOS
	
	get_user_ip( id , g_szAuthID[ id ], charsmax( g_szAuthID[ ] ) )
	get_user_info( id, "name", g_szName[ id ], charsmax( g_szName[ ] ) )
	
	replace_all( g_szName[ id ], charsmax( g_szName[ ] ), "'", "*" )
	replace_all( g_szName[ id ], charsmax( g_szName[ ] ), "^"", "*" )
	replace_all( g_szName[ id ], charsmax( g_szName[ ] ), "`", "*" )
	replace_all( g_szName[ id ], charsmax( g_szName[ ] ), "´", "*" )
	
	if( is_user_hltv( id ) || is_user_bot( id ) )
	{
		is_user_ignored[ id ] = true
		return
	}
	else
	{
		is_user_ignored[ id ] = false
	}
	
	g_iPoints[ id ] = 0
	g_iLevels[ id ] = 0
	g_iClasses[ id ] = 0
	g_iCurrentKills[ id ] = 0
	
	LoadPoints( id )
	
	if( get_pcvar_num( g_iEnableWonPointsHour ) && get_pcvar_num( g_iWonPointsHour ) )
	{
		set_task( 3600.0, "GiveSkillPointsHour", id, _, _, "b" )
	}
}

public client_infochanged( id )
{
	if( !is_user_connected( id ) )
	{
		return	
	}
	
	new szNewName[ 32 ]
	get_user_info( id, "name", szNewName, charsmax( szNewName ) ) 
	
	new iLen = strlen( szNewName )
	
	new iPos = iLen - 1
	
	if( szNewName[ iPos ] == '>' )
	{    
		new i
		for( i = 1; i < 7; i++ )
		{    
			if( szNewName[ iPos - i ] == '<' )
			{    
				iLen = iPos - i
				szNewName[ iLen ] = EOS
				break
			}
		}
	}
	
	trim( szNewName )
	
	if( !equal( g_szName[ id ], szNewName ) )   
	{     
		copy( g_szName[ id ], charsmax( g_szName[ ] ), szNewName )
	} 
}

public client_disconnect( id )
{
	if( is_user_ignored[ id ] )
	{
		return
	}
	
	if( task_exists( id ) )
	{
		remove_task( id )
	}
	
	CheckLevelAndSave( id )
	is_user_ignored[ id ] = true
}

public GiveSkillPointsHour( id )
{
	g_iPoints[ id ] += get_pcvar_num( g_iWonPointsHour )
	
	if( get_pcvar_num( g_iEnableAnnounceOnChat ) )
	{
		ClientPrintColor( id, "!g%s!n You earned!t %i!n point%s for playing more one hour", PREFIX, get_pcvar_num( g_iWonPointsHour ), get_pcvar_num( g_iWonPointsHour ) > 1 ? "s" : "" )
	}
}

public client_death( killer, victim, wpnindex, hitplace, TK )
{		
	if( is_user_ignored[ killer ] )
	{
		return
	}
	
	if( TK )
	{
		g_iPoints[ killer ] -= get_pcvar_num( g_iLostPointsTK )
		
		if( get_pcvar_num( g_iEnableAnnounceOnChat ) && get_pcvar_num( g_iLostPointsTK ) )
		{
			ClientPrintColor( killer, "!g%s!n You have lost!t %i!n point%s by killing a teammate", PREFIX, get_pcvar_num( g_iLostPointsTK ), get_pcvar_num( g_iLostPointsTK ) > 1 ? "s" : ""  )
		}
		
		return
	}
	
	if( killer == victim )
	{
		g_iPoints[ killer ] -= get_pcvar_num( g_iLostPointsSuicide )
		
		if( get_pcvar_num( g_iEnableAnnounceOnChat ) && get_pcvar_num( g_iLostPointsSuicide ) )
		{
			ClientPrintColor( killer, "!g%s!n You have lost!t %i!n point%s for committing suicide", PREFIX, get_pcvar_num( g_iLostPointsSuicide ), get_pcvar_num( g_iLostPointsSuicide ) > 1 ? "s" : ""  )
		}
		
		return
	}
	
	g_iCurrentKills[ killer ]++
	
	if( killer != victim && ( 1 <= killer <= g_iMaxPlayers ) && ( 1 <= victim <= g_iMaxPlayers ) && !( hitplace == HIT_HEAD ) && !( wpnindex == CSW_KNIFE ) && !( wpnindex == CSW_HEGRENADE ) && !TK )
	{
		g_iPoints[ killer ] += get_pcvar_num( g_iWonPointsKill )
		
		if( get_pcvar_num( g_iEnableAnnounceOnChat ) && get_pcvar_num( g_iWonPointsKill ) )
		{
			ClientPrintColor( killer, "!g%s!n You earned!t %i!n point%s by killing %s", PREFIX, get_pcvar_num( g_iWonPointsKill ), get_pcvar_num( g_iWonPointsKill ) > 1 ? "s" : "", g_szName[ victim ] )
		}
		
		if( !is_user_ignored[ victim ] )
		{
			g_iPoints[ victim ] -= get_pcvar_num( g_iLostPointsDeath )
			
			if( get_pcvar_num( g_iEnableAnnounceOnChat ) && get_pcvar_num( g_iLostPointsDeath ) )
			{
				ClientPrintColor( victim, "!g%s!n You have lost!t %i!n point%s for dying", PREFIX, get_pcvar_num( g_iLostPointsDeath ), get_pcvar_num( g_iLostPointsDeath ) > 1 ? "s" : "" )
			}
		}
		
		return
	}
	
	if( hitplace == HIT_HEAD && wpnindex != CSW_KNIFE && !TK )
	{
		g_iPoints[ killer ] += get_pcvar_num( g_iWonPointsHeadshot )
		
		if( get_pcvar_num( g_iEnableAnnounceOnChat ) && get_pcvar_num( g_iWonPointsHeadshot ) )
		{
			ClientPrintColor( killer, "!g%s!n You earned!t %i!n point%s by killing %s with a headshot", PREFIX, get_pcvar_num( g_iWonPointsHeadshot ), get_pcvar_num( g_iWonPointsHeadshot ) > 1 ? "s" : "" ,g_szName[ victim ] )
		}
		
		if( !is_user_ignored[ victim ] )
		{
			g_iPoints[ victim ] -= get_pcvar_num( g_iLostPointsHeadshot )
			
			if( get_pcvar_num( g_iEnableAnnounceOnChat ) && get_pcvar_num( g_iLostPointsHeadshot ) )
			{
				ClientPrintColor( victim, "!g%s!n You have lost!t %i!n point%s for dying with a headshot", PREFIX, get_pcvar_num( g_iLostPointsHeadshot ), get_pcvar_num( g_iLostPointsHeadshot ) > 1 ? "s" : "" )
			}
		}
		
		return
	}
	
	if( wpnindex == CSW_KNIFE && !TK )
	{
		g_iPoints[ killer ] += get_pcvar_num( g_iWonPointsKnife )
		
		if( get_pcvar_num( g_iEnableAnnounceOnChat ) && get_pcvar_num( g_iWonPointsKnife ) )
		{
			ClientPrintColor( killer, "!g%s!n You earned!t %i!n point%s by killing %s with knife", PREFIX, get_pcvar_num( g_iWonPointsKnife ), get_pcvar_num( g_iWonPointsKnife ) > 1 ? "s" : "" ,g_szName[ victim ] )
		}
		
		if( !is_user_ignored[ victim ] )
		{
			g_iPoints[ victim ] -= get_pcvar_num( g_iLostPointsKnife )
			
			if( get_pcvar_num( g_iEnableAnnounceOnChat ) && get_pcvar_num( g_iLostPointsKnife ) )
			{
				ClientPrintColor( victim, "!g%s!n You have lost!t %i!n point%s for dying with knife", PREFIX, get_pcvar_num( g_iLostPointsKnife ), get_pcvar_num( g_iLostPointsKnife ) > 1 ? "s" : "" )
			}
		}
		
		return
	}
	
	if( wpnindex == CSW_HEGRENADE && killer != victim && !TK )
	{
		g_iPoints[ killer ] += get_pcvar_num( g_iWonPointsGrenade )
		
		if( get_pcvar_num( g_iEnableAnnounceOnChat ) && get_pcvar_num( g_iWonPointsGrenade ) )
		{
			ClientPrintColor( killer, "!g%s!n You earned!t %i!n point%s by killing %s with a grenade", PREFIX, get_pcvar_num( g_iWonPointsGrenade ), get_pcvar_num( g_iWonPointsGrenade ) > 1 ? "s" : "" ,g_szName[ victim ] )
		}
		
		if( !is_user_ignored[ victim ] )
		{
			g_iPoints[ victim ] -= get_pcvar_num( g_iLostPointsGrenade )
			
			if( get_pcvar_num( g_iEnableAnnounceOnChat ) && get_pcvar_num( g_iLostPointsGrenade ) )
			{
				ClientPrintColor( victim, "!g%s!n You have lost!t %i!n point%s for dying with a grenade", PREFIX, get_pcvar_num( g_iLostPointsGrenade ), get_pcvar_num( g_iLostPointsGrenade ) > 1 ? "s" : "" )
			}
		}
		
		return
	}
}

public TerroristsWin( )
{
	if( g_bRoundEnded )
	{
		return	
	}
	
	new Players[ MAX_PLAYERS ]
	new iNum
	new i
	
	get_players( Players, iNum, "ch" )
	
	for( --iNum; iNum >= 0; iNum-- )
	{
		i = Players[ iNum ]
		
		if( !is_user_ignored[ i ] )
		{
			switch( cs_get_user_team( i ) )
			{
				case( CS_TEAM_T ):
				{
					if( get_pcvar_num( g_iWonPointsTerrorists ) )
					{
						g_iPoints[ i ] += get_pcvar_num( g_iWonPointsTerrorists )
						
						if( get_pcvar_num( g_iEnableAnnounceOnChat ) )
						{
							ClientPrintColor( i, "!g%s!n Your team!t (T)!n have won!t %i!n point%s for winning the round", PREFIX, get_pcvar_num( g_iWonPointsTerrorists ), get_pcvar_num( g_iWonPointsTerrorists ) > 1 ? "s" : "" )
						}
					}
				}
				
				case( CS_TEAM_CT ):
				{
					if( get_pcvar_num( g_iLostPointsCounterTerrorists ) )
					{
						g_iPoints[ i ] -= get_pcvar_num( g_iLostPointsCounterTerrorists )
						
						if( get_pcvar_num( g_iEnableAnnounceOnChat ) )
						{
							ClientPrintColor( i, "!g%s!n Your team!t (CT)!n have lost!t %i!n point%s for losing the round", PREFIX, get_pcvar_num( g_iLostPointsCounterTerrorists ), get_pcvar_num( g_iLostPointsCounterTerrorists ) > 1 ? "s" : "" )
						}
					}
				}
			}
		}
	}
	
	g_bRoundEnded = true
}

public CounterTerroristsWin( )
{
	if( g_bRoundEnded )
	{
		return	
	}
	
	new Players[ MAX_PLAYERS ]
	new iNum
	new i
	
	get_players( Players, iNum, "ch" )
	
	for( --iNum; iNum >= 0; iNum-- )
	{
		i = Players[ iNum ]
		
		if( !is_user_ignored[ i ] )
		{
			switch( cs_get_user_team( i ) )
			{
				case( CS_TEAM_T ):
				{
					if( get_pcvar_num( g_iLostPointsTerrorists ) )
					{
						g_iPoints[ i ] -= get_pcvar_num( g_iLostPointsTerrorists )
						
						if( get_pcvar_num( g_iEnableAnnounceOnChat ) )
						{
							ClientPrintColor( i, "!g%s!n Your team!t (T)!n have lost!t %i!n point%s for losing the round", PREFIX, get_pcvar_num( g_iLostPointsTerrorists ), get_pcvar_num( g_iLostPointsTerrorists ) > 1 ? "s" : "" )
						}
					}
				}
				
				case( CS_TEAM_CT ):
				{
					if( get_pcvar_num( g_iWonPointsCounterTerrorists ) )
					{
						g_iPoints[ i ] += get_pcvar_num( g_iWonPointsCounterTerrorists )
						
						if( get_pcvar_num( g_iEnableAnnounceOnChat ) )
						{
							ClientPrintColor( i, "!g%s!n Your team!t (CT)!n have won!t %i!n point%s for winning the round", PREFIX, get_pcvar_num( g_iWonPointsCounterTerrorists ), get_pcvar_num( g_iWonPointsCounterTerrorists ) > 1 ? "s" : "" )
						}
					}
				}
			}
		}
	}
	
	g_bRoundEnded = true
}

public bomb_planted( planter )
{
	if( !is_user_ignored[ planter ] && get_pcvar_num( g_iWonPointsPlanter ) )
	{
		g_iPoints[ planter ] += get_pcvar_num( g_iWonPointsPlanter )
		
		if( get_pcvar_num( g_iEnableAnnounceOnChat ) )
		{
			ClientPrintColor( planter, "!g%s!n You earned!t %i!n point%s for planting the bomb", PREFIX, get_pcvar_num( g_iWonPointsPlanter ), get_pcvar_num( g_iWonPointsPlanter ) > 1 ? "s" : "" )
		}
	}
}

public bomb_explode( planter, defuser )
{
	if( !is_user_ignored[ planter ] && get_pcvar_num( g_iWonPointsPlanterExplode ) )
	{
		g_iPoints[ planter ] += get_pcvar_num( g_iWonPointsPlanterExplode )
		
		if( get_pcvar_num( g_iEnableAnnounceOnChat ) )
		{
			ClientPrintColor( planter, "!g%s!n You earned!t %i!n point%s with the bomb explosion", PREFIX, get_pcvar_num( g_iWonPointsPlanterExplode ), get_pcvar_num( g_iWonPointsPlanterExplode ) > 1 ? "s" : "" )
		}
	}
}

public bomb_defused( defuser )
{
	if( !is_user_ignored[ defuser ] && get_pcvar_num( g_iWonPointsDefuser ) )
	{
		g_iPoints[ defuser ] += get_pcvar_num( g_iWonPointsDefuser )
		
		if( get_pcvar_num( g_iEnableAnnounceOnChat ) )
		{
			ClientPrintColor( defuser, "!g%s!n You earned!t %i!n point%s for disarming the bomb", PREFIX, get_pcvar_num( g_iWonPointsDefuser ), get_pcvar_num( g_iWonPointsDefuser ) > 1 ? "s" : "" )
		}
	}
}

public EventNewRound( )
{
	g_bRoundEnded = false
	
	MakeTop15( )
}

public EventRoundEnd( )
{
	set_task( 0.5, "SavePointsAtRoundEnd" )
}

public SavePointsAtRoundEnd( )
{
	new Players[ MAX_PLAYERS ]
	new iNum
	new i
	
	get_players( Players, iNum, "ch" )
	
	for( --iNum; iNum >= 0; iNum-- )
	{
		i = Players[ iNum ]
		
		if( !is_user_ignored[ i ] )
		{
			if( g_iCurrentKills[ i ] == 4 && get_pcvar_num( g_iWonPoints4k ) )
			{
				g_iPoints[ i ] += get_pcvar_num( g_iWonPoints4k )
				
				if( get_pcvar_num( g_iEnableAnnounceOnChat ) )
				{
					ClientPrintColor( i, "!g%s!n You earned!t %i!n point%s for killing 4 in a round", PREFIX, get_pcvar_num( g_iWonPoints4k ), get_pcvar_num( g_iWonPoints4k ) > 1 ? "s" : "" )
				}
			}
			
			if( g_iCurrentKills[ i ] >= 5 && get_pcvar_num( g_iWonPoints5k ) )
			{
				g_iPoints[ i ] += get_pcvar_num( g_iWonPoints5k )
				
				if( get_pcvar_num( g_iEnableAnnounceOnChat ) )
				{
					ClientPrintColor( i, "!g%s!n You earned!t %i!n point%s for killing 5 in a round", PREFIX, get_pcvar_num( g_iWonPoints5k ), get_pcvar_num( g_iWonPoints5k ) > 1 ? "s" : "" )
				}
			}
			
			CheckLevelAndSave( i )
		}
	}
}

public CheckLevelAndSave( id )
{
	if( !get_pcvar_num( g_iNegativePoints) )
	{
		if( g_iPoints[ id ] < 0 )
		{
			g_iPoints[ id ] = 0
		}
		
		if( g_iLevels[ id ] < 0 )
		{
			g_iLevels[ id ] = 0
		}
	}
	
	while( g_iPoints[ id ] >= LEVELS[ g_iLevels[ id ] ] )
	{
		g_iLevels[ id ] += 1
		g_iClasses[ id ] += 1
		
		if( get_pcvar_num( g_iEnableAnnounceOnChat ) )
		{
			ClientPrintColor( 0, "!g%s!n %s increased one level! Level:!t %s!n Total points:!t %d", PREFIX, g_szName[ id ], CLASSES[ g_iLevels[ id ] ], g_iPoints[ id ] )
		}
	}
	
	new szTemp[ 512 ]
	formatex( szTemp, charsmax( szTemp ), "UPDATE %s SET nick = '%s', skillpoints = '%i', level = '%i' WHERE ip = '%s'", SQL_TABLE, g_szName[ id ], g_iPoints[ id ], g_iLevels[ id ], g_szAuthID[ id ] )
	
	SQL_ThreadQuery( g_SqlTuple, "IgnoreHandle", szTemp )
	
	if( g_iPoints[ id ] >= MAXPONTUATION )
	{		
		if( get_pcvar_num( g_iEnableAnnounceOnChat ) )
		{
			ClientPrintColor( id, "!g%s!n You have reached the maximum SkillPoints! Your SkillPoints and level will start again", PREFIX )
		}
		
		g_iPoints[ id ] = 0
		g_iLevels[ id ] = 0
		g_iClasses[ id ] = 0
		
		CheckLevelAndSave( id )
	}
}

public LoadPoints( id )
{
	new Data[ 1 ]
	Data[ 0 ] = id
	
	new szTemp[ 512 ]
	format( szTemp, charsmax( szTemp ), "SELECT skillpoints, level FROM %s WHERE ip = '%s'", SQL_TABLE, g_szAuthID[ id ] )
	
	SQL_ThreadQuery( g_SqlTuple, "RegisterClient", szTemp, Data, 1 )
}

public RegisterClient( FailState, Handle:Query, Error[ ], Errcode, Data[ ], DataSize )
{
	if( SQL_IsFail( FailState, Errcode, Error ) )
	{
		return
	}
	
	new id
	id = Data[ 0 ]
	
	if( SQL_NumResults( Query ) < 1 )
	{
		new szTemp[ 512 ]
		format( szTemp, charsmax( szTemp ), "INSERT INTO %s ( ip, nick, skillpoints, level ) VALUES( '%s', '%s', '%i', '%i' )", SQL_TABLE, g_szAuthID[ id ], g_szName[ id ], g_iPoints[ id ], g_iLevels[ id ]  )
		
		SQL_ThreadQuery( g_SqlTuple, "IgnoreHandle", szTemp )
	} 
	
	else
	{
		g_iPoints[ id ] = SQL_ReadResult( Query, 0 )
		g_iLevels[ id ] = SQL_ReadResult( Query, 1 )
	}
}

public IgnoreHandle( FailState, Handle:Query, Error[ ], Errcode, Data[ ], DataSize )
{
	SQL_FreeHandle( Query )
}

public SkillRank( id )
{
	if( !get_pcvar_num( g_iEnableSkillPointsCmdRank ) )
	{
		ClientPrintColor( id, "!g%s!n Command disabled", PREFIX )
	}
	
	else
	{
		if( is_user_ignored[ id ] )
		{
			ClientPrintColor( id, "!g%s!n Only for Steam accounts ", PREFIX )
			return PLUGIN_HANDLED_MAIN
		}
		
		new Data[ 1 ]
		Data[ 0 ] = id
		
		new szTemp[ 512 ]
		format( szTemp, charsmax( szTemp ), "SELECT COUNT(*) FROM %s WHERE skillpoints >= %i", SQL_TABLE, g_iPoints[ id ] )
		
		SQL_ThreadQuery( g_SqlTuple, "GetSkillRank", szTemp, Data, 1 )
	}
	
	return ( get_pcvar_num( g_iHideCmds ) == 0 ) ? PLUGIN_CONTINUE : PLUGIN_HANDLED_MAIN
}

public GetSkillRank( FailState, Handle:Query, Error[ ], Errcode, Data[ ], DataSize )
{
	if( SQL_IsFail( FailState, Errcode, Error ) )
	{
		return
	}
	
	new id
	id = Data[ 0 ]
	
	g_iRank[ id ] = SQL_ReadResult( Query, 0 )
	
	if( g_iRank[ id ] == 0 )
	{
		g_iRank[ id ] = 1
	}
	
	TotalRows( id )
}

public TotalRows( id )
{
	new Data[ 1 ]
	Data[ 0 ] = id
	
	new szTemp[ 512 ]
	format( szTemp, charsmax( szTemp ), "SELECT COUNT(*) FROM %s", SQL_TABLE )
	
	SQL_ThreadQuery( g_SqlTuple, "GetTotalRows", szTemp, Data, 1 )
}

public GetTotalRows( FailState, Handle:Query, Error[ ], Errcode, Data[ ], DataSize )
{
	if( SQL_IsFail( FailState, Errcode, Error ) )
	{
		return
	}
	
	new id
	id = Data[ 0 ]
	
	g_iCount = SQL_ReadResult( Query, 0 )
	
	ClientPrintColor( id, "!g%s!n Your rank is!t %i!n of!t %i!n players with!t %i!n points ", PREFIX, g_iRank[ id ], g_iCount, g_iPoints[ id ] )
}

public TopSkill( id )
{
	if( !get_pcvar_num( g_iEnableSkillPointsTop15 ) )
	{
		ClientPrintColor( id, "!g%s!n Command disabled", PREFIX )
	}
	
	else
	{
		show_motd( id, g_szMotd, "Top SkillPointers" )
	}
	
	return ( get_pcvar_num( g_iHideCmds ) == 0 ) ? PLUGIN_CONTINUE : PLUGIN_HANDLED_MAIN
}

public MakeTop15( )
{	
	new szQuery[ 512 ]
	formatex( szQuery, charsmax( szQuery ), "SELECT nick, skillpoints FROM %s ORDER BY skillpoints DESC LIMIT 15", SQL_TABLE )
	
	SQL_ThreadQuery( g_SqlTuple, "MakeTop15_QueryHandler", szQuery )
}

// dsa1
new const g_szCups[ ][ ] = {
    "http://rayish.com/plugins/rayish/images/rank/1.png",
    "http://rayish.com/plugins/rayish/images/rank/2.png",
    "http://rayish.com/plugins/rayish/images/rank/3.png"
}; 

public MakeTop15_QueryHandler( FailState, Handle:Query, Error[ ], Errcode, Data[ ], DataSize )
{
	if( SQL_IsFail( FailState, Errcode, Error ) )
	{
		return
	}
	
	new szName[ 32 ]
	new iPoints
	
	// new iLen	
	static iDefaultLen;
	new iLen = iDefaultLen;
	
	// old - iLen = format( g_szMotd, charsmax( g_szMotd ), "<body bgcolor=#000000><font color=#FFB000><pre>" )
	iLen += formatex( g_szMotd[ iLen ], charsmax( g_szMotd ) - iLen, "<STYLE>body{background:#e6eae9;color:#847282;font-family:sans-serif}table{width:100%%;line-height:160%%;font-size:12px}.q{border:1px solid #717d7d}.b{background:#717d7d}</STYLE><table cellpadding=2 cellspacing=0 border=0>");
		
	// old - iLen += format( g_szMotd[ iLen ], charsmax( g_szMotd ) - iLen,"%s %-32.32s %3s^n", "#", "Player", "SkillPoints" )
	if( !iDefaultLen )
	{
		iLen += formatex( g_szMotd[ iLen ], charsmax( g_szMotd ) - iLen, "<br><br<br><br><b><table bgcolor=#bddbdd><tr align=center bgcolor=#cae8ea><th width=5%%>Position<th width=20%%>Nick<th width=10%%>Points</b>" );
	}
	
	new i = 1
	while( SQL_MoreResults( Query ) )
	{
		SQL_ReadResult( Query, 0, szName, charsmax( szName ) )
		iPoints = SQL_ReadResult( Query, 1 )
		
		replace_all( szName, charsmax( szName ), "<", "[" )
		replace_all( szName, charsmax( szName ), ">", "]" )
		
		//iLen += format( g_szMotd[ iLen ], charsmax( g_szMotd ) - iLen, "%i %-32.32s %i^n", i, szName, iPoints )
		new iMaxCups = sizeof( g_szCups );
		if( i < iMaxCups ) 
		{
			iLen += formatex( g_szMotd[ iLen ], charsmax( g_szMotd ) - iLen, "<tr align=center%s><td><img src=^"%s^"/><td>%s<td>%i", ((i%2)==0) ? " bgcolor=#e6eae9" : " bgcolor=#f5fbfb", g_szCups[ i ], szName, iPoints ); 

		}
		else
		{
			iLen += formatex( g_szMotd[ iLen ], charsmax( g_szMotd ) - iLen, "<tr align=center%s><td>%d<td>%s<td>%i", ((i%2)==0) ? " bgcolor=#e6eae9" : " bgcolor=#f5fbfb", (i+1), szName, iPoints ); 
		}
		
		i++
		
		SQL_NextRow( Query )
	}
	
	//iLen += format( g_szMotd[ iLen ], charsmax( g_szMotd ) - iLen, "</body></font></pre>" )
}

SQL_IsFail( const FailState, const Errcode, const Error[ ] )
{
	if( FailState == TQUERY_CONNECT_FAILED )
	{
		log_amx( "[Error] Could not connect to SQL database: %s", Error )
		return true
	}
	
	if( FailState == TQUERY_QUERY_FAILED )
	{
		log_amx( "[Error] Query failed: %s", Error )
		return true
	}
	
	if( Errcode )
	{
		log_amx( "[Error] Error on query: %s", Error )
		return true
	}
	
	return false
}

public GetSkillPoints( id )
{
	if( !get_pcvar_num( g_iEnableSkillPointsCmd ) )
	{
		ClientPrintColor( id, "!g%s!n Command disabled", PREFIX )
	}
	
	else
	{
		if( is_user_ignored[ id ] )
		{
			//ClientPrintColor( id, "!g%s!n Only for Steam accounts ", PREFIX )
			return PLUGIN_HANDLED_MAIN
		}
		
		if( g_iLevels[ id ] < ( MAXLEVELS - 1 ) )
		{
			ClientPrintColor( id, "!g%s!n Total points:!t %d!n Level:!t %s!n Points to the next level:!t %d", PREFIX, g_iPoints[ id ], CLASSES[ g_iLevels[ id ] ], ( LEVELS[ g_iLevels[ id ] ] - g_iPoints[ id ] ) )
		}
		
		else
		{
			ClientPrintColor( id, "!g%s!n Total points:!t %d!n Level:!t %s!n (last level)", PREFIX, g_iPoints[ id ], CLASSES[ g_iLevels[ id ] ] )
		}
	}
	
	return ( get_pcvar_num( g_iHideCmds ) == 0 ) ? PLUGIN_CONTINUE : PLUGIN_HANDLED_MAIN
}

public ChatAdvertisements( )
{
	new Players[ MAX_PLAYERS ]
	new iNum
	new i
	
	get_players( Players, iNum, "ch" )
	
	for( --iNum; iNum >= 0; iNum-- )
	{
		i = Players[ iNum ]
		
		if( !is_user_ignored[ i ] )
		{
			ClientPrintColor( i, g_ChatAdvertise[ g_iK ], PREFIX )
		}
	}
	
	g_iK++
	
	if( g_iK >= sizeof g_ChatAdvertise )
	{
		g_iK = 0
	}
}

public CmdGivePoints( id, level, cid )
{
	if ( !cmd_access( id, level, cid, 3 ) )
	{
		return PLUGIN_HANDLED
	}
	
	new Arg1[ 32 ]
	new Arg2[ 6 ]
	
	read_argv( 1, Arg1, charsmax( Arg1 ) )
	read_argv( 2, Arg2, charsmax( Arg2 ) )
	
	new iPlayer = cmd_target( id, Arg1, 1 )
	new iPoints = str_to_num( Arg2 )
	
	if ( !iPlayer )
	{
		console_print( id, "Sorry, player %s could not be found or targetted!", Arg1 )
		return PLUGIN_HANDLED
	}
	
	if( is_user_ignored[ iPlayer ] )
	{
		console_print( id, "Sorry, player %s is actually ignored", Arg1 )
		return PLUGIN_HANDLED
	}
	
	if( iPoints > 0 )
	{
		g_iPoints[ iPlayer ] += iPoints
		CheckLevelAndSave( iPlayer )
		
		if( get_pcvar_num( g_iEnableAnnounceOnChat ) )
		{
			ClientPrintColor( 0, "!g%s!n %s gave!t %i!n SkillPoint%s to %s", PREFIX, g_szName[ id ], iPoints, iPoints > 1 ? "s" : "", g_szName[ iPlayer ] )
		}
	}
	
	return PLUGIN_HANDLED
}

public CmdTakePoints( id, level, cid )
{
	if ( !cmd_access( id, level, cid, 3 ) )
	{
		return PLUGIN_HANDLED
	}
	
	new Arg1[ 32 ]
	new Arg2[ 6 ]
	
	read_argv( 1, Arg1, charsmax( Arg1 ) )
	read_argv( 2, Arg2, charsmax( Arg2 ) )
	
	new iPlayer = cmd_target( id, Arg1, 1 )
	new iPoints = str_to_num( Arg2 )
	
	if ( !iPlayer )
	{
		console_print( id, "Sorry, player %s could not be found or targetted!", Arg1 )
		return PLUGIN_HANDLED
	}
	
	if( is_user_ignored[ iPlayer ] )
	{
		console_print( id, "Sorry, player %s is actually ignored", Arg1 )
		return PLUGIN_HANDLED
	}
	
	if( iPoints > 0 )
	{
		g_iPoints[ iPlayer ] -= iPoints
		CheckLevelAndSave( iPlayer )
		
		if( get_pcvar_num( g_iEnableAnnounceOnChat ) )
		{
			ClientPrintColor( 0, "!g%s!n %s take!t %i!n SkillPoint%s from %s", PREFIX, g_szName[ id ], iPoints, iPoints > 1 ? "s" : "", g_szName[ iPlayer ] )
		}
	}
	
	return PLUGIN_HANDLED
}

public RestartSkillPoints( id )
{
	if( !get_pcvar_num( g_iEnableSkillPointsRestart ) )
	{
		ClientPrintColor( id, "!g%s!n Command disabled", PREFIX )
	}
	
	else
	{
		if( is_user_ignored[ id ] )
		{
			//ClientPrintColor( id, "!g%s!n Only for Steam accounts ", PREFIX )
			return PLUGIN_HANDLED_MAIN
		}
		
		g_iPoints[ id ] = 0
		g_iLevels[ id ] = 0
		g_iClasses[ id ] = 0
		
		CheckLevelAndSave( id )
		
		if( get_pcvar_num( g_iEnableAnnounceOnChat ) )
		{
			ClientPrintColor( id, "!g%s!n Your SkillPoints and level will start again", PREFIX )
		}
	}
	
	return ( get_pcvar_num( g_iHideCmds ) == 0 ) ? PLUGIN_CONTINUE : PLUGIN_HANDLED_MAIN
}

public FwdPlayerSpawnPost( id )
{	
	if( is_user_ignored[ id ] || !is_user_alive( id ) )
	{
		return
	}
	
	g_iCurrentKills[ id ] = 0
	
	if( get_pcvar_num( g_iEnableShowSkillPointsOnNick ) )
	{
		new szName[ 32 ]
		get_user_info( id, "name", szName, charsmax( szName ) )
		
		new iLen = strlen( szName )
		
		new iPos = iLen - 1
		
		if( szName[ iPos ] == '>' )
		{    
			new i
			for( i = 1; i < 7; i++ )
			{    
				if( szName[ iPos - i ] == '<' )
				{    
					iLen = iPos - i
					szName[ iLen ] = EOS
					break
				}
			}
		}
		
		format( szName[ iLen ], charsmax( szName ) - iLen, szName[ iLen-1 ] == ' ' ? "<%d>" : " <%d>", g_iPoints[ id ] )    
		set_user_info( id, "name", szName )
	}	
}

public MessageSayText( iMsgID, iDest, iReceiver )
{
	if( get_pcvar_num( g_iHideChangeNickNotification ) )
	{
		new const Cstrike_Name_Change[ ] = "#Cstrike_Name_Change"
		
		new szMessage[ sizeof( Cstrike_Name_Change ) + 1 ]
		get_msg_arg_string( 2, szMessage, charsmax( szMessage ) )
		
		return equal( szMessage, Cstrike_Name_Change ) ? PLUGIN_HANDLED : PLUGIN_CONTINUE
	}
	
	return PLUGIN_CONTINUE
}

stock ClientPrintColor( id, String[ ], any:... )
{
	new szMsg[ 192 ]
	vformat( szMsg, charsmax( szMsg ), String, 3 )
	
	replace_all( szMsg, charsmax( szMsg ), "!n", "^1" )
	replace_all( szMsg, charsmax( szMsg ), "!t", "^3" )
	replace_all( szMsg, charsmax( szMsg ), "!g", "^4" )
	
	static msgSayText = 0
	static fake_user
	
	if( !msgSayText )
	{
		msgSayText = get_user_msgid( "SayText" )
		fake_user = get_maxplayers( ) + 1
	}
	
	message_begin( id ? MSG_ONE_UNRELIABLE : MSG_BROADCAST, msgSayText, _, id )
	write_byte( id ? id : fake_user )
	write_string( szMsg )
	message_end( )
}
