/*

	При даване на reconnect, играчът бива наказван за Х време (от настройка).
	Има и настройки за имунитед.

*/

#include < amxmodx >
#include < hamsandwich >
#include < colorchat >

#define PLUGIN_NAME	"No Reconnect"
#define PLUGIN_VERSION	"1.8"
#define PLUGIN_AUTHOR	"Smiley"
#define PLUGIN_PREFIX	"[BetterPlay]"

new Trie:gIP;
new player_ip[ 64 ];

new noreconnect_time;
new noreconnect_reason;
new noreconnect_admin_imm;
new noreconnect_admin_flag;

new bool:szAdmin[ 33 ];

public plugin_init( )
{
	register_plugin( PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR );
	register_cvar( "noreconnect_version", PLUGIN_VERSION, FCVAR_SERVER | FCVAR_SPONLY );
	register_cvar( "noreconnect_author", PLUGIN_AUTHOR, FCVAR_SERVER | FCVAR_SPONLY );
	
	RegisterHam( Ham_Spawn, "player", "fwdPlayerSpawn", .Post = true );
	
	noreconnect_time = register_cvar( "noreconnect_time", "30" );
	noreconnect_reason = register_cvar( "noreconnect_reason", "Retry" );
	noreconnect_admin_imm = register_cvar( "noreconnect_admin_immunity", "1" );
	noreconnect_admin_flag = register_cvar( "noreconnect_admin_flag", "a" );
	
	gIP = TrieCreate( );
}

public client_authorized( player )
{
	new flag[ 33 ];
	get_pcvar_string( noreconnect_admin_flag, flag, charsmax( flag ) );
	
	szAdmin[ player ] = ( get_user_flags( player ) & read_flags( flag ) ) ? true : false;
	remove_task( player );
}

public client_disconnect( player )
{	
	if( is_user_bot( player ) ) return PLUGIN_CONTINUE;

	if( get_pcvar_num( noreconnect_admin_imm ) && szAdmin[ player ] ) return PLUGIN_CONTINUE;

	get_user_ip( player, player_ip, charsmax( player_ip ), 1 );
	TrieSetCell( gIP, player_ip, 1 );

	set_task( get_pcvar_float( noreconnect_time ), "DeleteCell", player );

	return PLUGIN_CONTINUE;
}

public DeleteCell( player )
{
	get_user_ip( player, player_ip, charsmax( player_ip ), 1 );
	if( TrieKeyExists( gIP, player_ip ) ) TrieDeleteKey( gIP, player_ip );
}

public fwdPlayerSpawn( player )
{
	if( !is_user_alive( player ) || !is_user_connected( player) || szAdmin[ player ] ) return HAM_HANDLED;

	get_user_ip( player, player_ip, charsmax( player_ip ), 1 );

	if( TrieKeyExists( gIP, player_ip ) )
	{
		new szReason[ 64 ], player_name[ 64 ], player_authid[ 64 ];
		get_pcvar_string( noreconnect_reason, szReason, 63 );
		get_user_name( player, player_name, charsmax( player_name ) );
		get_user_authid( player, player_authid, charsmax( player_authid ) );
		
		log_amx( "%s (IP: %s) (AuthID: %s) has been kicked (Reason: %s)", player_name, player_ip, player_authid, szReason ); 
	
		//set_hudmessage( 185, 185, 0, 0.08, 0.35, 0, 5.0, 10.0, 2.0, 0.15, -4 );
		//show_hudmessage( 0, "%s has been kicked.^nReason: %s", player_name, szReason );
		 
		ColorChat( 0, GREEN, "%s^3 %s^1 has been^4 kicked^1. Reason^4:^3 %s", PLUGIN_PREFIX, player_name, szReason );
		server_cmd( "kick #%d ^"%s is not allowed! Please wait %d second%s.^"", get_user_userid( player ), szReason, get_pcvar_num( noreconnect_time ), get_pcvar_num( noreconnect_time ) == 1 ? "" : "s" );
		
		TrieDeleteKey( gIP, player_ip );
	}
	
	return HAM_IGNORED;
}
