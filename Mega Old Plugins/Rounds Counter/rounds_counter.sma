#include < amxmodx >
#include < cstrike >
#include < nvault >

#define EXPIREDAYS 30

new const VAULTNAME[ ] = "rounds"

new g_iVault
new g_szVaultKey[ 64 ]
new g_szVaultData[ 64 ]

new g_szRounds[ 32 ]

public plugin_init( )
{
	register_plugin( "Rounds Counter", "0.1", "nICKy" )
	
	register_clcmd( "say /rounds", "ViewRounds" )
	
	register_event( "SendAudio", "TerroristsWin", "a", "2&%!MRAD_terwin" )
	register_logevent( "RoundEnd", 2, "1=Round_End" )
}

public plugin_cfg( )
{	
	g_iVault = nvault_open( VAULTNAME )
	
	if ( g_iVault == INVALID_HANDLE )
		set_fail_state( "Error opening nVault" )
	
	nvault_prune( g_iVault, 0, get_systime( ) - ( 86400 * EXPIREDAYS ) )
}

public plugin_end( ) nvault_close( g_iVault )

public client_connect( id ) LoadRounds( id )

public client_disconnect( id ) CheckAndSave( id )

public ViewRounds( id ) client_print(id, print_chat, "Rounds: %d", g_szRounds[ id ])

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
	
		formatex( g_szVaultKey, charsmax( g_szVaultKey ), "%s-ROUNDS", szName[ id ] )
		formatex( g_szVaultData, charsmax( g_szVaultData ),"%i#", g_szRounds[ id ])
		nvault_set( g_iVault, g_szVaultKey, g_szVaultData)	
}

LoadRounds( id )
{
		new szName[ 32 ]
		get_user_name( id, szName, charsmax( szName ) )
		
		formatex( g_szVaultKey, charsmax( g_szVaultKey ),"%s-ROUNDS", szName[ id ] )
		formatex( g_szVaultData, charsmax( g_szVaultData ), "%i#", g_szRounds[ id ])
		nvault_get( g_iVault, g_szVaultKey, g_szVaultData, charsmax( g_szVaultData ) )
	
		replace_all( g_szVaultData, charsmax( g_szVaultData ), "#", " ")
	
		new szPlayerRounds[ 32 ]
	
		parse( g_szVaultData, szPlayerRounds, charsmax( szPlayerRounds ) )
	
		g_szRounds[ id ] = str_to_num( szPlayerRounds )
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1026\\ f0\\ fs16 \n\\ par }
*/
