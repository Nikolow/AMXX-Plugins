/*

	Unstuckване само чрез натискане на бутон (E, R, TAB).
	По-бързо и лесно, отколкото биндване на копче с команда.

*/

#include < amxmodx >
#include < amxmisc >
#include < fakemeta >
#include < engine >
#include < hamsandwich >

#define START_DISTANCE				32
#define MAX_ATTEMPTS				128

#define GetPlayerHullSize(%1) ((pev(%1, pev_flags) & FL_DUCKING) ? HULL_HEAD : HULL_HUMAN)

new Float:gf_LastCmdTime[ 33 ];

enum Coord_e 
{
	Float:x,
	Float:y, 
	Float:z
}

new const szPrefix[ ] = "^4[BetterPlay]^1 ";

/* for unstuc_button cvar

	0 - disable plugin
	
	1 - E button
	2 - R button
	3 - TAB button
*/
new cvar_unstuck_button, cvar_message_enabled, cvar_message_time;

new const unstuck_button_in[ ] = { 0, IN_USE, IN_RELOAD, IN_SCORE }
new const unstuck_button[ ][ ] = { "", "E", "R", "TAB" }

enum 
{
	ENABLE,
	DISABLE
}

new g_szUnstuck[ 33 ];

public plugin_init( )
{
	register_plugin( "Unstuck with button", "1.1", "Smiley" );
	register_forward( FM_CmdStart, "fwdCmdStart" );
	
	cvar_unstuck_button = register_cvar( "unstuck_button", "1" );
	cvar_message_enabled = register_cvar( "unstuck_message_enabled", "1" );
	cvar_message_time = register_cvar( "unstuck_message_time", "75" );
	
	RegisterHam( Ham_Spawn, "player", "fwdPSpawn", 1 );
	
	if( get_pcvar_num( cvar_unstuck_button ) && get_pcvar_num( cvar_message_enabled ) ) set_task( get_pcvar_float( cvar_message_time ), "TaskShowMessage", _, _, _, "b" );
}

public fwdPSpawn( id )
{
	if( is_user_alive( id ) )
	{
		g_szUnstuck[ id ] = ENABLE;
	}
}

public TaskShowMessage( )
{
	for( new i = 1; i <= 32; i++ )
	{
		if( !get_pcvar_num( cvar_unstuck_button ) || !get_pcvar_num( cvar_message_enabled ) ) continue;
		if( !is_user_connected( i ) ) continue;
		
		switch( random_num( 0, 1 ) )
		{
			case 0: ColorMessage( i, "%sPress^3 %s^1 to^4 unstuck^1.", szPrefix, unstuck_button[ get_pcvar_num( cvar_unstuck_button ) ] );
			case 1: ColorMessage( i, "%sNatisnete^3 %s^1 za da se^4 otkleshtite^1.", szPrefix, unstuck_button[ get_pcvar_num( cvar_unstuck_button ) ] );
		}
	}
}

public fwdCmdStart( id, handle )
{
	if( !is_user_connected( id ) || !get_pcvar_num( cvar_unstuck_button ) ) return FMRES_IGNORED;
	
	static iButtons, iOldButtons;
	
	iButtons = get_uc( handle, UC_Buttons );
	iOldButtons= entity_get_int( id, EV_INT_oldbuttons );

	if( is_user_alive( id ) && ( iButtons & unstuck_button_in[ get_pcvar_num( cvar_unstuck_button ) ] ) && !( iOldButtons & unstuck_button_in[ get_pcvar_num( cvar_unstuck_button ) ] ) && g_szUnstuck[ id ] == ENABLE )
	{
		CmdUnstuck( id );
	}
	
	return FMRES_IGNORED;
}

public CmdUnstuck(const id)
{
	new Float:f_MinFrequency = 4.0;
	new Float:f_ElapsedCmdTime = get_gametime() - gf_LastCmdTime[id];
	
	if(f_ElapsedCmdTime < f_MinFrequency)
	{
		client_print( id, print_center, "You must wait %.1f seconds before trying to free yourself.", f_MinFrequency - f_ElapsedCmdTime);
		return PLUGIN_HANDLED;
	}
	
	gf_LastCmdTime[id] = get_gametime();
	
	new i_Value;
	
	if((i_Value = UTIL_UnstickPlayer(id, START_DISTANCE, MAX_ATTEMPTS)) != 1)
	{
		switch(i_Value)
		{
			case 0: ColorMessage( id, "%sCouldn't find a free spot to move you too.", szPrefix );
			case -1: ColorMessage( id, "%sYou cannot free yourself as dead player.", szPrefix );
		}
	}
	return PLUGIN_CONTINUE;
}

UTIL_UnstickPlayer(const id, const i_StartDistance, const i_MaxAttempts)
{
	if(!is_user_alive(id)) return -1;
	
	static Float:vf_OriginalOrigin[Coord_e], Float:vf_NewOrigin[Coord_e];
	static i_Attempts, i_Distance;
	
	pev(id, pev_origin, vf_OriginalOrigin);
	
	i_Distance = i_StartDistance;
	
	while(i_Distance < 1000)
	{
		i_Attempts = i_MaxAttempts;
		
		while(i_Attempts--)
		{
			vf_NewOrigin[x] = random_float(vf_OriginalOrigin[x] - i_Distance, vf_OriginalOrigin[x] + i_Distance);
			vf_NewOrigin[y] = random_float(vf_OriginalOrigin[y] - i_Distance, vf_OriginalOrigin[y] + i_Distance);
			vf_NewOrigin[z] = random_float(vf_OriginalOrigin[z] - i_Distance, vf_OriginalOrigin[z] + i_Distance);
			
			engfunc(EngFunc_TraceHull, vf_NewOrigin, vf_NewOrigin, DONT_IGNORE_MONSTERS, GetPlayerHullSize(id), id, 0);
			
			if(get_tr2(0, TR_InOpen) && !get_tr2(0, TR_AllSolid) && !get_tr2(0, TR_StartSolid))
			{
				engfunc(EngFunc_SetOrigin, id, vf_NewOrigin);
				client_print( id, print_center, "You have successfully unstucked!" );
				return 1;
			}
		}
		
		i_Distance += i_StartDistance;
	}
	return 0;
}

stock ColorMessage( const id, const input[ ], any:... )
{
	new count = 1, players[ 32 ];
	static msg[ 191 ];
	vformat( msg, 190, input, 3 );
	
	if( id ) players[ 0 ] = id; else get_players( players, count, "ch" );
	{
		for( new i = 0; i < count; i++ )
		{
			if( is_user_connected( players[ i ] ) )
			{
				message_begin(MSG_ONE_UNRELIABLE, get_user_msgid( "SayText" ), _, players[ i ] ) ; 
				write_byte( players[ i ] );
				write_string( msg );
				message_end( );
			}
		}
	}
}

public api_enable_unstuck( index )
{
	g_szUnstuck[ index ] = ENABLE;
}

public api_disable_unstuck( index )
{
	g_szUnstuck[ index ] = DISABLE;
}
