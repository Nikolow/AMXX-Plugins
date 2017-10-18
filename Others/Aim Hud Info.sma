/*

	При Aim-ване на играча с мишката, показва информация за него като: Име, Кръв и Дистанция до вас.
	Може да се съчетае с друг XP/Points Ranks плъгин и се вкара информация.

*/

#include < amxmodx >
#include < cstrike >
#include < fakemeta >

#define VERSION		"1.0"
new g_szSyncHud, g_szMaxPlayers;
new g_szStatusValue, g_szStatusText;

public plugin_init( )
{
	register_plugin( "Show Names on HUD", VERSION, "Smiley" );
	register_forward( FM_PlayerPreThink, "fwdPlayerPreThink", 0 );

	g_szSyncHud = CreateHudSyncObj( );
	g_szMaxPlayers = get_maxplayers( );
	
	g_szStatusValue = get_user_msgid( "StatusValue" );
	g_szStatusText = get_user_msgid( "StatusText" );
	
	register_message( g_szStatusValue, "MessageStatusValue" );
}

public fwdPlayerPreThink( id )
{
	if( !is_user_alive( id ) ) return FMRES_IGNORED;
	
	new iTarget, iBody, Float:iDist;
	iDist = get_user_aiming( id, iTarget, iBody, 9999 );
	
	if( 0 < iTarget <= g_szMaxPlayers )
	{
		new CsTeams:MyTeam = cs_get_user_team( id );
		new CsTeams:TargetTeam = cs_get_user_team( iTarget );
		
		new UserName[ 64 ], g_szMessage[ 128 ];
		get_user_name( iTarget, UserName, charsmax( UserName ) );
		
		if( TargetTeam == MyTeam ) formatex( g_szMessage, charsmax( g_szMessage ), "Friend: %s^nHealth: %i^nDistance: %.2f", UserName, get_user_health( iTarget ), iDist );
		else formatex( g_szMessage, charsmax( g_szMessage ), "Enemy: %s^nDistance: %.2f", UserName, iDist );
		
		switch( TargetTeam ) 
		{
			case CS_TEAM_CT: set_hudmessage( 0, 63, 127, -1.0, 0.22, 0, 0.0, 0.15, 0.0, 0.0, -1 );
			case CS_TEAM_T: set_hudmessage( 127, 0, 0, -1.0, 0.22, 0, 0.0, 0.15, 0.0, 0.0, -1 );
		}
		
		ShowSyncHudMsg( id, g_szSyncHud, g_szMessage );
	}
	
	return FMRES_IGNORED;
}

public MessageStatusValue( )
{
	set_msg_block( g_szStatusText, BLOCK_SET );
}
