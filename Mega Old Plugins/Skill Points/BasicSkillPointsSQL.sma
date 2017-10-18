#include < amxmodx >
#include < amxmisc >
#include < cstrike >
#include < csx >
#include < hamsandwich >
#include < sqlx >

#define MAXCLASSES 11 // max rank names
#define MAXLEVELS 11 // max levels
#define MAXPONTUATION 10000 // max skillpoints per player
#define MAX_PLAYERS 32

new const CLASSES[ MAXCLASSES ][ ] = {
	"Newbie", // 1
	"Learner", // 2
	"Member", // 3
	"Semi-Pro", // 4
	"Pro", // 5
	"Veteran", // 6
	"BunnyHopper", // 7
	"Killer", // 8
	"ADVanced", // 9
	"Chuck Norris", // 10
	"SlackServ Optimaxer" /* 10 (not reachable) */
}

new const LEVELS[ MAXLEVELS ] = {
	20, // newbie - 1
	40, // learner - 2
	100, // member - 3 
	170, // semi-pro - 4
	250, // pro - 5
	350, // veteran - 6
	480, // bunnyhopper - 7
	600, // killer - 8
	850, // advanced - 9
	1500, // chuck norris - 10
	100000 /* ss optimaxer - 10 >> high value (not reachable) */
}

new const SQL_TABLE[ ] = "hns_skill_points"
new const PREFIX[ ] = "[SkillPoints]"

new g_iK
new const g_ChatAdvertise[ ][ ] = {
	"!g%s!t Write in chat!g /me!t to see your Skill Points",
	"!g%s!t Write in chat!g /rank!t to see your rank",
	"!g%s!t Write in chat!g /top15!t to see the Top Skill Pointers"
}

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

new bool:is_user_ignored[ MAX_PLAYERS + 1 ]
new bool:g_bRoundEnded

new g_TimeBetweenAds
new g_iHideCmds
new g_iWonPointsHour
new g_iWonPointsHeadshot
new g_iWonPointsKnife
new g_iWonPointsTerrorists
new g_iWonPoints5k
new g_iWonPoints6k
new g_iNegativePoints

public plugin_init( )
{
	register_plugin( "HideNseek Basic SkillPoints [SQL]", "1.2.0", "guipatinador" ) /* Nicky >> big edit */
	
	register_clcmd( "say /myskill", "GetSkillPoints" )
	register_clcmd( "say /me", "GetSkillPoints" )
	register_clcmd( "say /skill", "GetSkillPoints" )
	register_clcmd( "say /points", "GetSkillPoints" )
	
	register_clcmd( "say /rankskill", "SkillRank" )
	register_clcmd( "say /rank", "SkillRank" )
	register_clcmd( "say /rankstats", "SkillRank" )
	
	register_clcmd( "say /topskill", "TopSkill" )
	register_clcmd( "say /top", "TopSkill" )
	register_clcmd( "say /top10", "TopSkill" )
	register_clcmd( "say /top15", "TopSkill" )
	
	register_message( get_user_msgid( "SayText" ), "MessageSayText" )
	
	register_event( "SendAudio", "TerroristsWin", "a", "2&%!MRAD_terwin" )
	
	register_event( "HLTV", "EventNewRound", "a", "1=0", "2=0" )
	register_logevent( "EventRoundEnd", 2, "1=Round_End" )
	
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
	g_TimeBetweenAds = register_cvar( "bps_time_between_ads", "300.0" )
	g_iHideCmds = register_cvar( "bps_hide_cmd", "1" )
	g_iWonPointsHour = register_cvar( "bps_won_points_hour", "5" )
	g_iWonPointsHeadshot = register_cvar( "bps_won_points_headshot", "2" )
	g_iWonPointsKnife = register_cvar( "bps_won_points_knife", "1" )
	g_iWonPointsTerrorists = register_cvar( "bps_won_points_ts", "1" )
	g_iWonPoints5k = register_cvar( "bps_won_points_5k", "2" )
	g_iWonPoints6k = register_cvar( "bps_won_points_6k", "3" )
	g_iNegativePoints = register_cvar( "bps_negative_points", "0" )
	
	g_pcvarHost = register_cvar( "bps_sql_host", "localhost", FCVAR_PROTECTED )
	g_pcvaruUser = register_cvar( "bps_sql_user", "amxbans", FCVAR_PROTECTED )
	g_pcvarPass = register_cvar( "bps_sql_pass", "g1bs0n0", FCVAR_PROTECTED )
	g_pcvarDB = register_cvar( "bps_sql_db", "amxbans", FCVAR_PROTECTED )
	
	set_task( get_pcvar_float( g_TimeBetweenAds ), "ChatAdvertisements", _, _, _, "b" )
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
	SQL_FreeHandle( g_SqlTuple )

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
	
	set_task( 3600.0, "GiveSkillPointsHour", id, _, _, "b" )
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
		remove_task( id )
	
	CheckLevelAndSave( id )
	is_user_ignored[ id ] = true
}

public GiveSkillPointsHour( id )
{
	g_iPoints[ id ] += get_pcvar_num( g_iWonPointsHour )
	
	ClientPrintColor( id, "!g%s!t You earned!!g %i!t point%s for playing more one hour", PREFIX, get_pcvar_num( g_iWonPointsHour ), get_pcvar_num( g_iWonPointsHour ) > 1 ? "s" : "" )
}

public client_death( killer, victim, wpnindex, hitplace )
{		
	if( is_user_ignored[ killer ] )
	{
		return
	}
	g_iCurrentKills[ killer ]++
	
	if( hitplace == HIT_HEAD )
	{
		g_iPoints[ killer ] += get_pcvar_num( g_iWonPointsHeadshot )
		
		if( get_pcvar_num( g_iWonPointsHeadshot ) )
		{
			ClientPrintColor( killer, "!g%s!t You earned!g %i!t point%s by killing!n %s!t with!g a headshot", PREFIX, get_pcvar_num( g_iWonPointsHeadshot ), get_pcvar_num( g_iWonPointsHeadshot ) > 1 ? "s" : "" ,g_szName[ victim ] )
		}
		
		return
	}
	
	if( wpnindex == CSW_KNIFE )
	{
		g_iPoints[ killer ] += get_pcvar_num( g_iWonPointsKnife )
		
		if( get_pcvar_num( g_iWonPointsKnife ) )
		{
			ClientPrintColor( killer, "!g%s!t You earned!g %i!t point%s by killing!n %s!t with!g knife", PREFIX, get_pcvar_num( g_iWonPointsKnife ), get_pcvar_num( g_iWonPointsKnife ) > 1 ? "s" : "" ,g_szName[ victim ] )
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
						
						ClientPrintColor( i, "!g%s!t Your team!n (Hiders)!t have won!g %i!t point%s for winning the round", PREFIX, get_pcvar_num( g_iWonPointsTerrorists ), get_pcvar_num( g_iWonPointsTerrorists ) > 1 ? "s" : "" )
					}
				}
			}
		}
	}
	g_bRoundEnded = true
}

public EventNewRound( )
{
	g_bRoundEnded = false
	
	MakeTop15( )
}

public EventRoundEnd( )
	set_task( 0.5, "SavePointsAtRoundEnd" )

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
			if( g_iCurrentKills[ i ] == 5 && get_pcvar_num( g_iWonPoints5k ) )
			{
				g_iPoints[ i ] += get_pcvar_num( g_iWonPoints5k )
				
				ClientPrintColor( i, "!g%s!t You earned!g %i!t point%s for killing!n 5!t in a round", PREFIX, get_pcvar_num( g_iWonPoints5k ), get_pcvar_num( g_iWonPoints5k ) > 1 ? "s" : "" )
			}
			if( g_iCurrentKills[ i ] >= 6 && get_pcvar_num( g_iWonPoints6k ) )
			{
				g_iPoints[ i ] += get_pcvar_num( g_iWonPoints6k )
				
				ClientPrintColor( i, "!g%s!t You earned!g %i!t point%s for killing!n 6!t in a round", PREFIX, get_pcvar_num( g_iWonPoints6k ), get_pcvar_num( g_iWonPoints6k ) > 1 ? "s" : "" )
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
		
		ClientPrintColor( 0, "!g%s!n %s!t increased one level!!g Level:!t %s!g Total points:!t %d", PREFIX, g_szName[ id ], CLASSES[ g_iLevels[ id ] ], g_iPoints[ id ] )
		
	}
	
	new szTemp[ 512 ]
	formatex( szTemp, charsmax( szTemp ), "UPDATE %s SET nick = '%s', skillpoints = '%i', level = '%i' WHERE ip = '%s'", SQL_TABLE, g_szName[ id ], g_iPoints[ id ], g_iLevels[ id ], g_szAuthID[ id ] )
	
	SQL_ThreadQuery( g_SqlTuple, "IgnoreHandle", szTemp )
	
	if( g_iPoints[ id ] >= MAXPONTUATION )
		ClientPrintColor( id, "!g%s!t You have reached!g the maximum!t SkillPoints!", PREFIX )
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
	SQL_FreeHandle( Query )

public SkillRank( id )
{
		if( is_user_ignored[ id ] )
			return PLUGIN_HANDLED_MAIN
		
		new Data[ 1 ]
		Data[ 0 ] = id
		
		new szTemp[ 512 ]
		format( szTemp, charsmax( szTemp ), "SELECT COUNT(*) FROM %s WHERE skillpoints >= %i", SQL_TABLE, g_iPoints[ id ] )
		
		SQL_ThreadQuery( g_SqlTuple, "GetSkillRank", szTemp, Data, 1 )
	
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
	
	ClientPrintColor( id, "!g%s!t Your rank is!g %i!t of!g %i!t players with!g %i!t points.", PREFIX, g_iRank[ id ], g_iCount, g_iPoints[ id ] )
}

public TopSkill( id )
{
	show_motd( id, g_szMotd, "Top SkillPointers" )
	
	return ( get_pcvar_num( g_iHideCmds ) == 0 ) ? PLUGIN_CONTINUE : PLUGIN_HANDLED_MAIN
}

public MakeTop15( )
{	
	new szQuery[ 512 ]
	formatex( szQuery, charsmax( szQuery ), "SELECT nick, skillpoints FROM %s ORDER BY skillpoints DESC LIMIT 15", SQL_TABLE )
	
	SQL_ThreadQuery( g_SqlTuple, "MakeTop15_QueryHandler", szQuery )
}

public MakeTop15_QueryHandler( FailState, Handle:Query, Error[ ], Errcode, Data[ ], DataSize )
{
	if( SQL_IsFail( FailState, Errcode, Error ) )
	{
		return
	}
	
	new szName[ 32 ]
	new iPoints
	
	static iDefaultLen;
	new iLen = iDefaultLen;
	
	iLen += formatex( g_szMotd[ iLen ], charsmax( g_szMotd ) - iLen, "<STYLE>body{background:#e6eae9;color:#847282;font-family:sans-serif}table{width:100%%;line-height:160%%;font-size:12px}.q{border:1px solid #717d7d}.b{background:#717d7d}</STYLE><table cellpadding=2 cellspacing=0 border=0>");
		
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
		
		//iLen += formatex( g_szMotd[ iLen ], charsmax( g_szMotd ) - iLen, "%i %-32.32s %i^n", i, szName, iPoints )
		iLen += formatex( g_szMotd[ iLen ], charsmax( g_szMotd ) - iLen, "<tr align=center%s><td>%d<td>%s<td>%i", ((i%2)==0) ? " bgcolor=#e6eae9" : " bgcolor=#f5fbfb", i, szName, iPoints ); 
		i++
		
		SQL_NextRow( Query )
	}
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
		if( is_user_ignored[ id ] )
			return PLUGIN_HANDLED_MAIN
		
		if( g_iLevels[ id ] < ( MAXLEVELS - 1 ) )
		{
			ClientPrintColor( id, "!g%s!t Total points:!g %d!t Level:!g %s!t Points to the next level:!g %d", PREFIX, g_iPoints[ id ], CLASSES[ g_iLevels[ id ] ], ( LEVELS[ g_iLevels[ id ] ] - g_iPoints[ id ] ) )
		}
		
		else
		{
			ClientPrintColor( id, "!g%s!t Total points:!g %d!t Level:!g %s!t [Last level]", PREFIX, g_iPoints[ id ], CLASSES[ g_iLevels[ id ] ] )
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

public MessageSayText( iMsgID, iDest, iReceiver )
{
		new const Cstrike_Name_Change[ ] = "#Cstrike_Name_Change"
		
		new szMessage[ sizeof( Cstrike_Name_Change ) + 1 ]
		get_msg_arg_string( 2, szMessage, charsmax( szMessage ) )
		
		return equal( szMessage, Cstrike_Name_Change ) ? PLUGIN_HANDLED : PLUGIN_CONTINUE
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
