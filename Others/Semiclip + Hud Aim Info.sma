/*

	Semiclip плъгин, заедно с информация на името на играча при аймване.
	Може да се комбинира с други XP/Points Ranks плъгини за повече информация.

*/

#include <amxmodx>
#include <fakemeta>

#define NAME_HUD_ENABLED

#if defined NAME_HUD_ENABLED
#include < cstrike >

new g_szStatusValue, g_szStatusText, g_szSyncHud;
#endif

#pragma semicolon 1
#define DISTANCE 120

new g_iTeam[33];
new bool:g_bSolid[33];
new bool:g_bHasSemiclip[33];
new Float:g_fOrigin[33][3];

new g_iForwardId[3];
new g_iMaxPlayers;

public plugin_init( )
{
	register_plugin( "Semiclip & View Name in HUD", "1.2", "SchlumPF*, Smiley" );
	
	g_iForwardId[0] = register_forward( FM_PlayerPreThink, "fwdPlayerPreThink" );
	g_iForwardId[1] = register_forward( FM_PlayerPostThink, "fwdPlayerPostThink" );
	g_iForwardId[2] = register_forward( FM_AddToFullPack, "fwdAddToFullPack_Post", 1 );
		
	g_iMaxPlayers = get_maxplayers( );
	
	#if defined NAME_HUD_ENABLED
	g_szSyncHud = CreateHudSyncObj( );
	g_szStatusValue = get_user_msgid( "StatusValue" );
	g_szStatusText = get_user_msgid( "StatusText" );
	
	register_message( g_szStatusValue, "MessageStatusValue" );
	#endif
}

#if defined NAME_HUD_ENABLED
public MessageStatusValue( )
{
	set_msg_block( g_szStatusText, BLOCK_SET );
}
#endif

public fwdPlayerPreThink( plr )
{
	#if defined NAME_HUD_ENABLED
	new iTarget, iBody;
	get_user_aiming( plr, iTarget, iBody, 9999 );
	
	if( 0 < iTarget <= g_iMaxPlayers && is_user_alive( plr ) )
	{
		new CsTeams:MyTeam = cs_get_user_team( plr );
		new CsTeams:TargetTeam = cs_get_user_team( iTarget );
		
		new UserName[ 64 ], g_szMessage[ 128 ];
		get_user_name( iTarget, UserName, charsmax( UserName ) );
		
		if( TargetTeam == MyTeam ) formatex( g_szMessage, charsmax( g_szMessage ), "Friend: %s^nHealth: %i", UserName, get_user_health( iTarget ) );
		else formatex( g_szMessage, charsmax( g_szMessage ), "Enemy: %s", UserName );
		
		switch( TargetTeam ) 
		{
			case CS_TEAM_CT: set_hudmessage( 0, 63, 127, -1.0, 0.22, 0, 0.0, 0.15, 0.0, 0.0, -1 );
			case CS_TEAM_T: set_hudmessage( 127, 0, 0, -1.0, 0.22, 0, 0.0, 0.15, 0.0, 0.0, -1 );
		}
		
		ShowSyncHudMsg( plr, g_szSyncHud, g_szMessage );
	}
	#endif
	
	static id, last_think;

	if( last_think > plr )
	{
		for( id = 1 ; id <= g_iMaxPlayers ; id++ )
		{
			if( is_user_alive( id ) )
			{
				g_iTeam[id] = get_user_team( id );
				
				g_bSolid[id] = pev( id, pev_solid ) == SOLID_SLIDEBOX ? true : false;
				pev( id, pev_origin, g_fOrigin[id] );
			}
			else
			{
				g_bSolid[id] = false;
			}
		}
	}

	last_think = plr;

	if( g_bSolid[plr] )
	{
		for( id = 1 ; id <= g_iMaxPlayers ; id++ )
		{
			if( g_bSolid[id] && get_distance_f( g_fOrigin[plr], g_fOrigin[id] ) <= DISTANCE && id != plr )
			{
				if( g_iTeam[plr] != g_iTeam[id] )
					return FMRES_IGNORED;
	
				set_pev( id, pev_solid, SOLID_NOT );
				g_bHasSemiclip[id] = true;
			}
		}
	}

	return FMRES_IGNORED;
}

public fwdPlayerPostThink( plr )
{
	static id;

	for( id = 1 ; id <= g_iMaxPlayers ; id++ )
	{
		if( g_bHasSemiclip[id] )
		{
			set_pev( id, pev_solid, SOLID_SLIDEBOX );
			g_bHasSemiclip[id] = false;
		}
	}
}

public fwdAddToFullPack_Post( es_handle, e, ent, host, hostflags, player, pset )
{
	if( player )
	{
		if( g_bSolid[host] && g_bSolid[ent] && get_distance_f( g_fOrigin[host], g_fOrigin[ent] ) <= DISTANCE )
		{
			if( g_iTeam[host] != g_iTeam[ent] ) return FMRES_IGNORED;
				
			set_es( es_handle, ES_Solid, SOLID_NOT ); // makes semiclip flawless
	
			set_es( es_handle, ES_RenderMode, kRenderTransAlpha );
			set_es( es_handle, ES_RenderAmt, 85 );
		}
	}
	
	return FMRES_IGNORED;
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1026\\ f0\\ fs16 \n\\ par }
*/
