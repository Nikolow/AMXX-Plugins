#include < amxmodx >
#include < cstrike >
#include < nvault >
#include < time >
#include < colorchat >

#define MAX_PLAYERS 32

#define EXPIREDAYS_ROUNDS 30
#define EXPIREDAYS_CONNECTS 30

new const VAULTNAME_ROUNDS[ ] = "rounds"
new const VAULTNAME_CONNECTS[ ] = "connects"
new const VAULTNAME_TIME[ ] = "time"

new g_szName[MAX_PLAYERS+1][32]
new g_iLastPlayedTime[MAX_PLAYERS+1]

new g_iVault_TIME
new g_iVault_ROUNDS
new g_szVaultKey_ROUNDS[ 64 ]
new g_szVaultData_ROUNDS[ 64 ]

new g_iVault_CONNECTS
new g_szVaultKey_CONNECTS[ 64 ]
new g_szVaultData_CONNECTS[ 64 ]

new g_szRounds[ 32 ]
new g_szConnects[ 32 ]

public plugin_init( )
{
	register_plugin( "Player Info", "0.4", "nICKy" )
	register_dictionary("time.txt")

	register_clcmd(" say /time", "ViewTime" )
	register_clcmd( "say /rounds", "ViewRounds" )
	register_clcmd( "say /connects", "ViewConnects" )
	register_clcmd( "say /all", "ViewAll" )
	
	register_event( "SendAudio", "TerroristsWin", "a", "2&%!MRAD_terwin" )
	register_logevent( "RoundEnd", 2, "1=Round_End" )
}

public plugin_cfg( )
{	
	g_iVault_ROUNDS = nvault_open( VAULTNAME_ROUNDS )
	g_iVault_CONNECTS = nvault_open( VAULTNAME_CONNECTS )
	g_iVault_TIME = nvault_open( VAULTNAME_TIME )
	
	//if ( g_iVault == INVALID_HANDLE )
	//	set_fail_state( "Error opening nVault" )
	
	nvault_prune( g_iVault_ROUNDS, 0, get_systime( ) - ( 86400 * EXPIREDAYS_ROUNDS ) )
	nvault_prune( g_iVault_CONNECTS, 0, get_systime( ) - ( 86400 * EXPIREDAYS_CONNECTS ) )
}

public plugin_end( )
{
	nvault_close( g_iVault_ROUNDS )
	nvault_close( g_iVault_CONNECTS )
	nvault_close( g_iVault_TIME )
}

public client_connect( id )
{
	LoadRounds( id )
	LoadConnects( id )
}

public client_disconnect( id )
{
	CheckAndSave( id )
	CheckAndSave2( id )
	new szTime[32]
	formatex(szTime, charsmax(szTime), "%d", get_user_total_playtime( id ))
	nvault_set(g_iVault_TIME, g_szName[id], szTime)
}

public client_authorized( id ) 
{
	set_task(10.0, "view_connect", id)
	g_szConnects[ id ] += 1
	new szTime[32]
	get_user_name(id, g_szName[id], charsmax(g_szName[]))
	nvault_get(g_iVault_TIME, g_szName[id], szTime, charsmax(szTime))
	g_iLastPlayedTime[id] = str_to_num(szTime)
}

public view_connect( id )
{
	new szTime[128]
	new szName[32]
	get_time_length(id, get_user_total_playtime( id ), timeunit_seconds, szTime, charsmax(szTime))
	get_user_name(id, szName, charsmax(szName)) 
	ColorChat( 0, GREY, "^x04 **^x01 %s^x03 has connected^x01 [^x03 Time:^x04 %s^x01 |^x03 Connects:^x04 %d^x01 |^x03 Rounds:^x04 %d^x01 ]", szName, szTime, g_szConnects[ id ], g_szRounds[ id ])
}

get_user_total_playtime( id )
{
	return g_iLastPlayedTime[id] + get_user_time(id)
}

public ViewTime( id )
{
	new szTime[128]
	get_time_length(id, get_user_total_playtime( id ), timeunit_seconds, szTime, charsmax(szTime))
	ColorChat( id, GREY, "Played Time:^x04 %s", szTime)
}

public ViewAll( id )
{
	new szName[32]
	new szTime[128]
	get_time_length(id, get_user_total_playtime( id ), timeunit_seconds, szTime, charsmax(szTime))
	get_user_name(id, szName, charsmax(szName)) 
	ColorChat( id, GREY, "^x03Player^x04 %s^x03 Information^x01 [^x03 Time:^x04 %s^x01 |^x03 Connects:^x04 %d^x01 |^x03 Rounds:^x04 %d^x01 ]", szName, szTime, g_szConnects[ id ], g_szRounds[ id ])
}

public ViewRounds( id ) ColorChat(id, GREY, "Played Rounds:^x04 %d", g_szRounds[ id ])
public ViewConnects( id ) ColorChat(id, GREY, "Connects:^x04 %d", g_szConnects[ id ])

public TerroristsWin( )
{
	new players[ 32 ]
	new num
	new i
	
	get_players( players, num, "ch" )
	
	for( --num; num >= 0; num-- )
	{
		i = players[ num ]

		switch( cs_get_user_team( i ) )
		{
			case( CS_TEAM_T ):
			{
				if( is_user_alive(i))
					g_szRounds[ i ] += 1
			}
			case( CS_TEAM_CT ):
			{
				if( is_user_alive(i))
					g_szRounds[ i ] += 1
			}
		}
	}
}

public RoundEnd( )
{
	new players[ 32 ]
	new num
	new i
	
	get_players( players, num, "ch" )
	
	for( --num; num >= 0; num-- )
	{
		i = players[ num ]
		
		CheckAndSave( i )
	}
}

CheckAndSave( id )
{
		new szName[ 32 ]
		get_user_name( id, szName, charsmax( szName ) )
	
		formatex( g_szVaultKey_ROUNDS, charsmax( g_szVaultKey_ROUNDS ), "%s-ROUNDS", szName[ id ] )
		formatex( g_szVaultData_ROUNDS, charsmax( g_szVaultData_ROUNDS ),"%i#", g_szRounds[ id ])
		nvault_set( g_iVault_ROUNDS, g_szVaultKey_ROUNDS, g_szVaultData_ROUNDS)	
}

LoadRounds( id )
{
		new szName[ 32 ]
		get_user_name( id, szName, charsmax( szName ) )
		
		formatex( g_szVaultKey_ROUNDS, charsmax( g_szVaultKey_ROUNDS ),"%s-ROUNDS", szName[ id ] )
		formatex( g_szVaultData_ROUNDS, charsmax( g_szVaultData_ROUNDS ), "%i#", g_szRounds[ id ])
		nvault_get( g_iVault_ROUNDS, g_szVaultKey_ROUNDS, g_szVaultData_ROUNDS, charsmax( g_szVaultData_ROUNDS ) )
	
		replace_all( g_szVaultData_ROUNDS, charsmax( g_szVaultData_ROUNDS ), "#", " ")
	
		new szPlayerRounds[ 32 ]
	
		parse( g_szVaultData_ROUNDS, szPlayerRounds, charsmax( szPlayerRounds ) )
	
		g_szRounds[ id ] = str_to_num( szPlayerRounds )
}

CheckAndSave2( id )
{
		new szName[ 32 ]
		get_user_name( id, szName, charsmax( szName ) )
	
		formatex( g_szVaultKey_CONNECTS, charsmax( g_szVaultKey_CONNECTS ), "%s-CONNECTS", szName[ id ] )
		formatex( g_szVaultData_CONNECTS, charsmax( g_szVaultData_CONNECTS ),"%i#", g_szConnects[ id ])
		nvault_set( g_iVault_CONNECTS, g_szVaultKey_CONNECTS, g_szVaultData_CONNECTS)	
}

LoadConnects( id )
{
		new szName[ 32 ]
		get_user_name( id, szName, charsmax( szName ) )
		
		formatex( g_szVaultKey_CONNECTS, charsmax( g_szVaultKey_CONNECTS ),"%s-CONNECTS", szName[ id ] )
		formatex( g_szVaultData_CONNECTS, charsmax( g_szVaultData_CONNECTS ), "%i#", g_szConnects[ id ])
		nvault_get( g_iVault_CONNECTS, g_szVaultKey_CONNECTS, g_szVaultData_CONNECTS, charsmax( g_szVaultData_CONNECTS ) )
	
		replace_all( g_szVaultData_CONNECTS, charsmax( g_szVaultData_CONNECTS ), "#", " ")
	
		new szPlayerConnects[ 32 ]
	
		parse( g_szVaultData_CONNECTS, szPlayerConnects, charsmax( szPlayerConnects ) )
	
		g_szConnects[ id ] = str_to_num( szPlayerConnects )
}
