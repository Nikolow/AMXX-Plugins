#include < amxmodx >
#include < cstrike >
#include < nvault >

#define EXPIREDAYS 30

new const VAULTNAME[ ] = "connects"

new g_iVault
new g_szVaultKey[ 64 ]
new g_szVaultData[ 64 ]

new g_szConnects[ 32 ]

public plugin_init( )
{
	register_plugin( "Connects Counter", "0.1", "nICKy" )
	
	register_clcmd( "say /connects", "ViewConnects" )
}

public plugin_cfg( )
{	
	g_iVault = nvault_open( VAULTNAME )
	
	if ( g_iVault == INVALID_HANDLE )
		set_fail_state( "Error opening nVault" )
	
	nvault_prune( g_iVault, 0, get_systime( ) - ( 86400 * EXPIREDAYS ) )
}

public plugin_end( ) nvault_close( g_iVault )

public client_connect( id ) LoadConnects( id )

public client_authorized( id ) g_szConnects[ id ] += 1

public client_disconnect( id ) CheckAndSave( id )

public ViewConnects( id ) client_print(id, print_chat, "Connects: %d", g_szConnects[ id ])

CheckAndSave( id )
{
		new szName[ 32 ]
		get_user_name( id, szName, charsmax( szName ) )
	
		formatex( g_szVaultKey, charsmax( g_szVaultKey ), "%s-CONNECTS", szName[ id ] )
		formatex( g_szVaultData, charsmax( g_szVaultData ),"%i#", g_szConnects[ id ])
		nvault_set( g_iVault, g_szVaultKey, g_szVaultData)	
}

LoadConnects( id )
{
		new szName[ 32 ]
		get_user_name( id, szName, charsmax( szName ) )
		
		formatex( g_szVaultKey, charsmax( g_szVaultKey ),"%s-CONNECTS", szName[ id ] )
		formatex( g_szVaultData, charsmax( g_szVaultData ), "%i#", g_szConnects[ id ])
		nvault_get( g_iVault, g_szVaultKey, g_szVaultData, charsmax( g_szVaultData ) )
	
		replace_all( g_szVaultData, charsmax( g_szVaultData ), "#", " ")
	
		new szPlayerConnects[ 32 ]
	
		parse( g_szVaultData, szPlayerConnects, charsmax( szPlayerConnects ) )
	
		g_szConnects[ id ] = str_to_num( szPlayerConnects )
}
