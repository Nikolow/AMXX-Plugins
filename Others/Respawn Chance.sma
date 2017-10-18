/*

	Respawn Chance плъгин, с който при написване на команда (от по-долу) имате шанс да бъдете възроден.
	Има настройки, разгледайте ги по-долу.

*/

#include < amxmodx >
#include < cstrike >
#include < hamsandwich >
#include < colorchat >

#define PLUGIN_VERSION		"1.0"
#define PLUGIN_PREFIX		"[BetterPlay]"

new Float:iNextUse[ 33 ];
new cvar_next_use, cvar_chance, cvar_limit_enable, cvar_maxrespawn, iLimit[ 33 ], bool:iRoundEnd;

new const szCommand[ ][ ] =
{
	"respawnme", "reviveme", "revive me", "respawn me", "/revive", "/reviveme"
};

public plugin_init( )
{
	register_plugin( "Respawn Chance", PLUGIN_VERSION, "Smiley" );
	
	register_logevent( "EventRound_Start", 2, "1=Round_Start" );
	register_logevent( "EventRound_End", 2, "1=Round_End" );

	register_clcmd( "say", "handleSay" );
	register_clcmd( "say_team", "handleSay" );
	
	cvar_next_use = register_cvar( "amx_respawnchance_next_use", "45" );
	cvar_chance = register_cvar( "amx_respawnchance_chance", "10" );
	cvar_limit_enable = register_cvar( "amx_respawnchance_limit", "1" );
	cvar_maxrespawn = register_cvar( "amx_respawnchance_maxrespawn", "2" );
}

public client_putinserver( id ) iNextUse[ id ] = -5000.0;

public handleSay( id )
{
	new message[ 192 ];
	read_args( message, charsmax( message ) );
	remove_quotes( message );
	
	for( new i = 0; i < sizeof( szCommand ); i++ )
	{	
		if( equal( message, szCommand[ i ] ) )
		{
			cmdRespawn( id );
		}
	}
}

cmdRespawn( id )
{
	new CsTeams:team = cs_get_user_team( id );
	
	if( iLimit[ id ] >= get_pcvar_num( cvar_maxrespawn ) && get_pcvar_num( cvar_limit_enable ) )
	{
		ColorChat( id, GREEN, "%s^1 Can be^3 revived^4 only^3 %d^1 times for^4 one^3 round^1!", PLUGIN_PREFIX, get_pcvar_num( cvar_maxrespawn ) );
		return PLUGIN_HANDLED;
	}
	
	if( team == CS_TEAM_SPECTATOR )
	{
		ColorChat( id, GREEN, "%s^1 Spectators^1 can't^4 respawn^3 silly!", PLUGIN_PREFIX );
		return PLUGIN_HANDLED;
	}
	
	if( is_user_alive( id ) )
	{
		ColorChat( id, GREEN, "%s^1 This^3 command^1 is only^4 for^3 Dead^1 Players^4!", PLUGIN_PREFIX );
		return PLUGIN_HANDLED;
	}
	
	if( iRoundEnd )
	{
		ColorChat( id, GREEN, "%s^1 The round ended^1, you don't^4 want to waste^3 your chance!", PLUGIN_PREFIX );
		return PLUGIN_HANDLED;
	}
	
	if( get_gametime( ) < iNextUse[ id ] + get_pcvar_float( cvar_next_use ) )
	{
		new times = floatround( iNextUse[ id ] + get_pcvar_num( cvar_next_use ) - get_gametime( ) + 1 );
		
		ColorChat( id, GREEN, "%s^1 Please^3 wait^4 %d^1 second%s^4 to^3 use^1 the^4 respawn chance^3 again^1.", PLUGIN_PREFIX, times, times == 1 ? "" : "s" );
		return PLUGIN_HANDLED;
	}
	
	switch( random_num( 1, get_pcvar_num( cvar_chance ) ) )
	{
		case 1: set_task( 1.0, "TaskRespawn", id );
		default: ColorChat( id, GREEN, "%s^1 Sorry, you didn't^4 respawn this time!", PLUGIN_PREFIX );
	}
	
	iNextUse[ id ] = get_gametime( );
	
	return PLUGIN_CONTINUE;
}

public TaskRespawn( id )
{
	if( !is_user_connected( id ) || is_user_alive( id ) ) return PLUGIN_HANDLED;
	
	new username[ 64 ];
	get_user_name( id, username, charsmax( username ) );
	
	if( get_pcvar_num( cvar_limit_enable ) ) iLimit[ id ]++;
	
	ExecuteHamB( Ham_CS_RoundRespawn, id );
	
	set_hudmessage( random( 256 ), random( 256 ), random( 256 ), -1.0, 0.30, 1, 6.0, 5.0, 0.5, 0.15, -1 );
	show_hudmessage( 0, "%s won and has been respawned!", username );
	
	ColorChat( 0, GREEN, "%s^3 %s^1 won and has^4 been^3 respawned^1!", PLUGIN_PREFIX, username );

	return PLUGIN_HANDLED;
}

public EventRound_Start( ) 
{
	if( get_pcvar_num( cvar_limit_enable ) ) arrayset( iLimit, 0, charsmax( iLimit ) );
	iRoundEnd = false;
}

public EventRound_End( ) iRoundEnd = true;

	


	
	
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ ansicpg1251\\ deff0\\ deflang1026{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ f0\\ fs16 \n\\ par }
*/
