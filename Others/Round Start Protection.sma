/*

	В началото на всеки рунд, всички играчи имат защита от умиране от Х секунди.
	Има допълнителни настройки за glow, време и прочие.

*/

#include < amxmodx >
#include < cstrike >
#include < fun >
#include < colorchat >

#define MAX_PLAYERS	32

new g_szCounter[ MAX_PLAYERS + 1 ];
new const g_szPrefix[ ] = "[Protection]";

new cvar_enabled, cvar_protection_during, cvar_protection_glow_enabled, cvar_protection_glow_color[ 3 ];
new cvar_hnsmod_enabled, cvar_speak_enabled;

new const speak_type[ ][ ] =
{
	"", "zvox", "fvox", "vox"
}

public plugin_precache( )
{
	precache_sound( "zvox/one.wav" );
}

public plugin_init( )
{
	register_plugin( "Protection", "1.3", "Smiley" );
	
	cvar_enabled = register_cvar( "protect_enabled", "1" );
	cvar_protection_during = register_cvar( "protect_during", "10" );
	cvar_protection_glow_enabled = register_cvar( "protect_glow_enabled", "0" );
	
	cvar_hnsmod_enabled = register_cvar( "protect_hns_enabled", "1" );
	cvar_speak_enabled = register_cvar( "protect_speak_enabled", "0" );
	
	cvar_protection_glow_color[ 1 ] = register_cvar( "protect_glow_color_t", "255 0 0" );
	cvar_protection_glow_color[ 2 ] = register_cvar( "protect_glow_color_ct", "0 0 255" );
	
	register_logevent( "logevRoundStart", 2, "1=Round_Start" );
	register_logevent( "logevRoundEnd", 2, "1=Round_End" );
	
	if( get_pcvar_num( cvar_hnsmod_enabled ) && get_pcvar_num( cvar_speak_enabled ) )
	{
		set_cvar_num( "hns_timersounds", 0 );
	}
}

public logevRoundStart( )
{
	for( new i = 1; i <= MAX_PLAYERS; i++ )
	{
		if( !is_user_connected( i ) || is_user_bot( i ) || is_user_hltv( i ) || !is_user_alive( i ) || !get_pcvar_num( cvar_enabled ) ) continue;
		
		new CsTeams:team = cs_get_user_team( i );
		if( team == CS_TEAM_SPECTATOR || team == CS_TEAM_UNASSIGNED ) continue;
			
		set_user_godmode( i, 0 );
		
		if( team != CS_TEAM_CT ) continue;
		set_task( 0.125, "TaskSetGodmode", i );
		
		if( get_pcvar_num( cvar_protection_glow_enabled ) )
		{
			new iColor[ 12 ], iParse[ 3 ][ 33 ];
			get_pcvar_string( cvar_protection_glow_color[ get_user_team( i ) ], iColor, charsmax( iColor ) );
			parse( iColor, iParse[ 0 ], charsmax( iParse ), iParse[ 1 ], charsmax( iParse ), iParse[ 2 ], charsmax( iParse ) );
			
			set_user_rendering( i, kRenderFxGlowShell, str_to_num( iParse[ 0 ] ), str_to_num( iParse[ 1 ] ), str_to_num( iParse[ 2 ] ), kRenderNormal, 16 );
		}
		
		if( get_pcvar_num( cvar_hnsmod_enabled ) ) 
		{
			g_szCounter[ i ] = get_cvar_num( "hns_hidetime" ) + 2;
		}
		else
		{
			g_szCounter[ i ] = get_pcvar_num( cvar_protection_during );
		}
		
		ColorChat( i, GREEN, "%s^1 All^3 players^4 will^1 have^3 protection^4 for^1 %d^3 second%s", g_szPrefix, g_szCounter[ i ], g_szCounter[ i ] == 1 ? "" : "s" );
		TaskProtectionTimer( i );
	}
}

public TaskSetGodmode( i )
{
	if( is_user_connected( i ) && is_user_alive( i ) )
	{
		set_user_godmode( i, 1 );
	}
}

public TaskProtectionTimer( i )
{
	if( !is_user_connected( i ) || !is_user_alive( i ) )
	{
		remove_task( i );
		return PLUGIN_HANDLED;
	}
	
	if( g_szCounter[ i ] == 0 )
	{
		client_print( i, print_center, "Protection Expired!" );
		
		set_user_godmode( i, 0 );
		if( get_pcvar_num( cvar_protection_glow_enabled ) ) set_user_rendering( i, kRenderFxGlowShell, 0, 0, 0, kRenderNormal, 16 );
	}
	else
	{
		client_print( i, print_center, "Protection: %d second%s.", g_szCounter[ i ], g_szCounter[ i ] == 1 ? "" : "s" );
	
		if( get_pcvar_num( cvar_speak_enabled ) && g_szCounter[ i ] <= 3 )
		{
			new sound[ 16 ];
			num_to_word( g_szCounter[ i ], sound, charsmax( sound ) );
			client_cmd( i, "spk %s/%s.wav", speak_type[ g_szCounter[i] ], sound );
		}		
	}
	
	g_szCounter[ i ]--;
	
	if( g_szCounter[ i ] >= 0 )
		set_task( 1.0, "TaskProtectionTimer", i );
		
	return PLUGIN_CONTINUE;
}

public logevRoundEnd( )
{
	for( new i = 1; i <= MAX_PLAYERS; i++ )
	{
		if( !is_user_connected( i ) || is_user_bot( i ) || is_user_hltv( i ) || !is_user_alive( i ) || !get_pcvar_num( cvar_enabled ) ) continue;
		
		new CsTeams:team = cs_get_user_team( i );
		if( team == CS_TEAM_SPECTATOR || team == CS_TEAM_UNASSIGNED ) continue;
			
		set_user_godmode( i, 1 );
	}
}
		
	
	
	
		
		
		
		


/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1026\\ f0\\ fs16 \n\\ par }
*/
