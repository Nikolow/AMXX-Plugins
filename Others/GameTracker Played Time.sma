/*

	С командата /playedtime всеки играч може да си провери изиграното време в Геймтрейкър, стига да е регистриран сървъра
	и да не е баннат !

*/

#include < amxmodx >
#include < amxmisc >

#define PLUGIN "GT Played Time"
#define VERSION "1.1.5"

new const g_szGameTracker[ ] = "http://www.gametracker.com/player";

new g_szServerIp[ 32 ];
new g_szCustomUrl[ 128 ];

public plugin_init( )
{
	register_plugin( PLUGIN, VERSION, "Askhanar" );
	
	register_clcmd( "say", "HookClCmdSayOrSayTeam" );
	register_clcmd( "say_team", "HookClCmdSayOrSayTeam" );

	register_clcmd( "gt_playedtime", "ClCmdPlayedTime" );
	
	get_user_ip( 0, g_szServerIp, sizeof ( g_szServerIp ) -1, 0 );
}

public HookClCmdSayOrSayTeam( id )
{
	static szArgs[ 192 ], szCommand[ 192 ];
	read_args( szArgs, sizeof ( szArgs ) -1 );
	
	if( !szArgs[ 0 ] )
		return PLUGIN_CONTINUE;
	
	remove_quotes( szArgs );
	
	if( equal( szArgs,  "/playedtime", strlen(  "playetime" ) ) )
	{
		replace( szArgs, sizeof ( szArgs ) -1, "/", ""  );
		formatex( szCommand, sizeof ( szCommand ) -1, "gt_%s", szArgs );
		client_cmd( id, szCommand );
		return PLUGIN_HANDLED;
	}
	
	if( equal( szArgs,  "/info", strlen(  "playetime" ) ) )
	{
		//replace( szArgs, sizeof ( szArgs ) -1, "/", ""  );
		//formatex( szCommand, sizeof ( szCommand ) -1, "gt_playedtime" );
		client_cmd( id, "gt_playedtime" );
		return PLUGIN_HANDLED;
	}
	
	if( equal( szArgs,  "/time", strlen(  "playetime" ) ) )
	{
		//replace( szArgs, sizeof ( szArgs ) -1, "/", ""  );
		//formatex( szCommand, sizeof ( szCommand ) -1, "gt_playedtime" );
		client_cmd( id, "gt_playedtime" );
		return PLUGIN_HANDLED;
	}
	
	return PLUGIN_CONTINUE;
}

public ClCmdPlayedTime( id )  
{
	
	new szFirstArg[ 32 ];
    	read_argv( 1, szFirstArg, sizeof ( szFirstArg ) -1 );

	if( equali( szFirstArg, "" ) ) 
		DisplayPlayedTime( id, id );
	
	else
	{
		
	
		new iPlayer = cmd_target( id, szFirstArg, 8 );
		if(!iPlayer || iPlayer == id )
			return PLUGIN_CONTINUE;
	
		DisplayPlayedTime( id, iPlayer );
	}
	
	return PLUGIN_CONTINUE;
}

public DisplayPlayedTime( id, iPlayer )
{
	new szName[ 32 ];
	get_user_name( iPlayer, szName, sizeof ( szName ) -1 );
	MakeNameSafe( szName, sizeof( szName ) -1 );
	
	formatex( g_szCustomUrl, sizeof ( g_szCustomUrl ) -1, "%s/%s/%s/",
		g_szGameTracker, szName, g_szServerIp );
		
	show_motd( id, g_szCustomUrl );
	
}

MakeNameSafe( szName[ ], iLen )
{
	replace_all( szName, iLen, "#", "%23" );
	replace_all( szName, iLen, "?", "%3F" );
	replace_all( szName, iLen, ":", "%3A" );
	replace_all( szName, iLen, ";", "%3B" );
	replace_all( szName, iLen, "/", "%2F" );
	replace_all( szName, iLen, ",", "%2C" );
	replace_all( szName, iLen, "$", "%24" );
	replace_all( szName, iLen, "@", "%40" );
	replace_all( szName, iLen, "+", "%2B" );
	replace_all( szName, iLen, "=", "%3D" );
	replace_all( szName, iLen, "®", "В®" );
	
}
