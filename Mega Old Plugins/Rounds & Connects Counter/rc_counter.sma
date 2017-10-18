#include < amxmodx >
#include < cstrike >
#include < nvault >

#define EXPIREDAYS_ROUNDS 30
#define EXPIREDAYS_CONNECTS 30

new const VAULTNAME_ROUNDS[ ] = "rounds"
new const VAULTNAME_CONNECTS[ ] = "connects"

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
	register_plugin( "Rounds & Connects Counter", "0.2", "nICKy" )
	
	register_clcmd( "say /rounds", "ViewRounds" )
	register_clcmd( "say /connects", "ViewConnects" )
	
	register_event( "SendAudio", "TerroristsWin", "a", "2&%!MRAD_terwin" )
	register_logevent( "RoundEnd", 2, "1=Round_End" )
}

public plugin_cfg( )
{	
	g_iVault_ROUNDS = nvault_open( VAULTNAME_ROUNDS )
	g_iVault_CONNECTS = nvault_open( VAULTNAME_CONNECTS )
	
	//if ( g_iVault == INVALID_HANDLE )
	//	set_fail_state( "Error opening nVault" )
	
	nvault_prune( g_iVault_ROUNDS, 0, get_systime( ) - ( 86400 * EXPIREDAYS_ROUNDS ) )
	nvault_prune( g_iVault_CONNECTS, 0, get_systime( ) - ( 86400 * EXPIREDAYS_CONNECTS ) )
}

public plugin_end( )
{
	nvault_close( g_iVault_ROUNDS )
	nvault_close( g_iVault_CONNECTS )
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
}

public client_authorized( id ) g_szConnects[ id ] += 1

public ViewRounds( id ) client_print(id, print_chat, "Rounds: %d", g_szRounds[ id ])
public ViewConnects( id ) client_print(id, print_chat, "Connects: %d", g_szConnects[ id ])

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
