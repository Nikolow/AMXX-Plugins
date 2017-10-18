#include < amxmodx >
#include < fakemeta >
#include < colorchat >

new HEALTH, MAX_HP, HP_DELAY, Float:g_flLastCall[ 33 ]

public plugin_init( ) 
{
	register_plugin( "Medic - Heal", "0.2", "Nickyy" )
	
	HEALTH = register_cvar( "medic_health", "20" )
	MAX_HP = register_cvar( "medic_maxhp", "80" )
	HP_DELAY = register_cvar( "medic_healdelay", "30" );
	
	register_clcmd( "say /medic", "medic" )
	register_clcmd( "say /heal", "medic" )
	register_clcmd( "say_team /medic", "medic" )
	register_clcmd( "say_team /heal", "medic" )
}

public client_disconnect(id)
	remove_task(id);

public medic( id ) 
{
	if ( ! is_user_alive(id) )
		return PLUGIN_HANDLED;
		
	new HP = get_user_health( id );
	
	//start copy<>paste code from xtreme medic plugin here
	new Float:Time = get_gametime();
	if(Time - get_pcvar_float(HP_DELAY) <= g_flLastCall[id])
	{
		new Result = floatround(g_flLastCall[id] - (Time - get_pcvar_float(HP_DELAY)));
		
		ColorChat(id, RED, "[MAX-PLAY.com]^1 You must wait^4 %d^1 seconds to call again.", Result);
		return PLUGIN_HANDLED;
	}
	g_flLastCall[id] = Time; //end here copy<>paste code :p
	
	if(HP < get_pcvar_num ( MAX_HP ) )
	{
		new playerCount, i, players[ 32 ], name[ 33 ];
		get_players( players, playerCount, "ach" );
		get_user_name( id, name, 32 )
					
		for( i=1; i <= playerCount; i++ )
			if( get_user_team( id ) == get_user_team( i ) )
				ColorChat( i , GREY , "^x01%s^x04 (RADIO)^x01:^x03 Medic!" , name )

		new Float: ADD_HP = get_pcvar_float( HEALTH );	
		if(HP + ADD_HP > get_pcvar_num( MAX_HP ) )
			set_pev(id, pev_health, get_pcvar_float( MAX_HP ) )
		else
			set_pev(id, pev_health, HP + ADD_HP);
	}
	return PLUGIN_HANDLED;
}