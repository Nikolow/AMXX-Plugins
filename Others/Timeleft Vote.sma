/*

	Вот в началото на картата, за времето, което да се изиграе картата.

*/

#include < amxmodx >
#include < amxmisc >
#include < colorchat >

#define PLUGIN			"Timeleft Vote"
#define VERSION			"1.1"

#define MINUTES_IN_MENU		5

new iChoose, iVoted, Menu[ 500 ], pcv_start_delay, pcv_vote_duration, pcv_timelimit;
const g_keys_mode = ( 1 << 0 ) | ( 1 << 1 ) | ( 1 << 2 ) | ( 1 << 3 ) | ( 1 << 4 );

new const mins[ MINUTES_IN_MENU ] = { 10, 15, 20, 25, 30 }
new const szPrefix[ ] = "[BetterPlay]";

public plugin_init( )
{
	register_plugin( PLUGIN, VERSION, "Smiley" );
	
	pcv_start_delay = register_cvar( "timeleftvote_start_delay", "30" );
	pcv_vote_duration = register_cvar( "timeleftvote_duration", "15" );
	pcv_timelimit = get_cvar_pointer( "mp_timelimit" );

	register_menu( "VoteMenu", g_keys_mode, "HandleMenuVote" );
	set_task( get_pcvar_float( pcv_start_delay ), "StartVote" );
		
	new len = 0;

	len += formatex( Menu[ len ], charsmax( Menu ) - len, "\rBetterPlay \d- \yTimeleft \wVote^n^n" );
	len += formatex( Menu[ len ], charsmax( Menu ) - len, "\r1. \y10 \wminutes^n" );
	len += formatex( Menu[ len ], charsmax( Menu ) - len, "\r2. \y15 \wminutes^n" );
	len += formatex( Menu[ len ], charsmax( Menu ) - len, "\r3. \y20 \wminutes^n" );
	len += formatex( Menu[ len ], charsmax( Menu ) - len, "\r4. \y25 \wminutes^n" );
	len += formatex( Menu[ len ], charsmax( Menu ) - len, "\r5. \y30 \wminutes^n" );
	
	iChoose = iVoted = 0;
	set_task( 2.0, "TaskResetTimeLimit" );
}

public TaskResetTimeLimit( )
{
	if( !get_pcvar_num( pcv_timelimit ) )
	{
		set_pcvar_float( pcv_timelimit, float( mins[ random( MINUTES_IN_MENU - 1 ) ] ) );
	}
}

public StartVote( )
{
	for( new i = 1; i <= 32; i++ )
	{
		if( !is_user_connected( i ) ) continue;
		
		show_menu( i, g_keys_mode, Menu, get_pcvar_num( pcv_vote_duration ) - 1, "VoteMenu" );
	}
	
	set_task( get_pcvar_float( pcv_vote_duration ) - 1.0, "TaskNoVoted" );
	set_task( get_pcvar_float( pcv_vote_duration ), "EndVote" );
}

public HandleMenuVote( id, key )
{
	iChoose += mins[ key ];
	iVoted++;

	new name[ 33 ];
	get_user_name( id, name, charsmax( name ) );
	
	ColorChat( 0, GREEN, "%s^3 %s^1 voted for^4 %d^3 minutes", szPrefix, name, mins[ key ] );
}

public TaskNoVoted( )
{
	if( !iChoose || !iVoted ) 
	{
		iChoose += mins[ random( MINUTES_IN_MENU - 1 ) ];
		iVoted++;
	}	
}

public EndVote( )
{
	if( !iChoose || !iVoted ) return;
	
	new Float:Value = float( iChoose / iVoted );
	set_pcvar_float( pcv_timelimit, Value );

	ColorChat( 0, GREEN, "%s^1 The time limit^3 for this map^4 will be^1 %.1f^3 minutes.", szPrefix, Value );
	iChoose = iVoted = 0;
}
	

	
