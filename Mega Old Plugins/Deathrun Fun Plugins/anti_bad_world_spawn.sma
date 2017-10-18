#include < amxmodx >
#include < amxmisc >
#include < hamsandwich >
#include < cstrike >
#include < fun >

#pragma semicolon 1

/****************************************
****                Plugin customization               ****
****************************************/

new const Plugin [ ] =		"Anti Bad World Spawn" ;
new const Version [ ] =	"1.0" ;
new const Author [ ] =		"Hattrick" ;

new Syncron ;

/****************************************
****                Plugin initialization                ****
****************************************/

public plugin_init ( )
{
	register_plugin ( Plugin , Version , Author ) ;
	
	register_clcmd ( "fullupdate" , "Fullupdate_Command" ) ;
	
	register_event ( "ResetHUD" , "Event_Protection_On" , "be" ) ;
	
	register_cvar ( "amx_bad_spawn" , "1" ) ;
	register_cvar ( "amx_bad_spawn_time" , "8" ) ;
	register_cvar ( "amx_bad_spawn_message" , "0" ) ;
	
	Syncron = CreateHudSyncObj ( ) ;
}

/****************************************
****              Plugin request modules              ****
****************************************/

public plugin_modules ( )
{
	require_module ( "HAMSANDWICH" ) ;
	require_module ( "CSTRIKE" ) ;
	require_module ( "FUN" ) ;
}

/****************************************
****                The principaly event               ****
****************************************/

public Event_Protection_On ( id )
{
	if ( get_cvar_num ( "amx_bad_spawn" ) == 1 )
	{
		set_task ( 0.5 , "Protect_Him" , id ) ;
		
		set_task ( 2.0 , "Respawn_Him" , id ) ;
		set_task ( 4.0 , "Respawn_Him" , id ) ;
		set_task ( 6.0 , "Respawn_Him" , id ) ;
		set_task ( 8.0 , "Respawn_Him" , id ) ;
		set_task ( 10.0 , "Respawn_Him" , id ) ;
		
		set_task ( 12.0 , "Stop_Respawn" , id ) ;
	}
	return PLUGIN_HANDLED ;
}

/****************************************
****                  Protect the player                  ****
****************************************/

public Protect_Him ( id )
{
	new Float:BadSpawnTime = get_cvar_float ( "amx_bad_spawn_time" ) ;
	new FTime = get_cvar_num ( "mp_freezetime" ) ;
	new BadSpawnSecs = get_cvar_num ( "amx_bad_spawn_time" ) ;
	
	set_user_godmode ( id , 1 ) ;
	
	if ( get_cvar_num ( "amx_bad_spawn_message" ) == 1 )
	{
		set_hudmessage ( 200 , 200 , 200 , -0.30 , 0.82 , 0 , 6.0 , BadSpawnTime+FTime , 0.1 , 0.2 , 4 ) ;
		ShowSyncHudMsg ( id , Syncron , "You'r protected for bad spawn^nFor %d seconds!" , BadSpawnSecs ) ;
	}
	
	set_task ( BadSpawnTime+FTime , "Stop_Protect" , id ) ;
	return PLUGIN_HANDLED ;
}

/****************************************
****                Respawn the player                ****
****************************************/

public Respawn_Him ( id )
{
	if ( is_user_alive ( id ) )
	{
		return PLUGIN_HANDLED ;
	}
	if ( get_user_team ( id ) == 3 || get_user_team ( id ) == 0 )
	{
		return PLUGIN_HANDLED ;
	}
	if ( get_user_team ( id ) == 1 || get_user_team ( id ) == 2 )
	{
		cs_set_user_team ( id , CS_TEAM_CT ) ;
		cs_set_user_deaths ( id , cs_get_user_deaths ( id )  - 1 ) ;
		ExecuteHamB ( Ham_CS_RoundRespawn , id ) ;
	}
	return PLUGIN_HANDLED ;
}

/****************************************
****                Remove protect task                ****
****************************************/

public Stop_Protect ( id )
{
	if ( ! is_user_connected ( id ) )
	{
		return PLUGIN_HANDLED ;
	}
	else
	{
		set_user_godmode ( id , 0 ) ;
	}
	return PLUGIN_HANDLED ;
}

/****************************************
****               Remove respawn task               ****
****************************************/

public Stop_Respawn ( id )
{
	if ( ! is_user_connected ( id ) )
	{
		return PLUGIN_HANDLED ;
	}
	else
	{
		remove_task ( id ) ;
	}
	return PLUGIN_HANDLED ;
}

/****************************************
****                If is disconnecting                ****
****************************************/

public client_disconnect ( id )
{
	remove_task ( id ) ;
	return PLUGIN_HANDLED ;
}

/****************************************
****                Block this command                ****
****************************************/

public Fullupdate_Command ( id )
{
	return PLUGIN_HANDLED ;
}