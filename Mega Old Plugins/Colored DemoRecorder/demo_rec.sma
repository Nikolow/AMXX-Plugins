#include <amxmodx>
#include <colorchat>
#pragma semicolon 1

new g_Toggle, g_DMod, g_UseNI, g_RStartAfter, g_DemoName, g_DemoNamePrefix;

public plugin_init() { 
	register_plugin( "Auto Demo Recorder", "1.5", "IzI" );
	g_Toggle 		= register_cvar( "amx_demo",		"1" );
	g_DMod			= register_cvar( "amx_demo_mode",	"0" );
	g_UseNI 		= register_cvar( "amx_demo_steamid",	"0" );
	g_RStartAfter 		= register_cvar( "amx_demo_rectime",	"15" );	// If it is less than 5, it will automatically set to 5, but willn't apply the changes to the console. I recoment to use default settings.
	g_DemoName 		= register_cvar( "amx_demo_name",	"xD-GaminG-2" );
	g_DemoNamePrefix	= register_cvar( "amx_demo_prefix",	"EasyBlock" );
	register_dictionary( "demorecorder.txt" );
}

public client_putinserver( id ) {
	if( get_pcvar_num( g_Toggle ) ) {
		new Float:delay = get_pcvar_float( g_RStartAfter );
		if( delay < 5 )
			set_pcvar_float( g_RStartAfter, ( delay = 5.0 ) );
		set_task( delay, "Record", id );
	}
}

public Record( id ) {
	if( !is_user_connected( id ) || get_pcvar_num( g_Toggle ) != 1 )
		return;

	// Getting time, client SteamID, server's name, server's ip with port.
	new szSName[128], szINamePrefix[64], szTimedata[9];
	new iUseIN = get_pcvar_num( g_UseNI );
	new iDMod = get_pcvar_num( g_DMod );
	get_pcvar_string( g_DemoNamePrefix, szINamePrefix, 63 );
	get_time ( "%H:%M:%S", szTimedata, 8 );

	switch( iDMod ) {
		case 0: get_pcvar_string( g_DemoName, szSName, 127 );
		case 1: get_user_ip( 0, szSName, 127, 0 );
		case 2: get_user_name( 0, szSName, 127 );
	}

	if( iUseIN ) {
		new szCID[32];
		get_user_authid( id, szCID, 31 );
		format( szSName, 127, "[%s]%s", szCID, szSName );
	}

	// Replacing signs.
	replace_all( szSName, 127, ":", "_" );
	replace_all( szSName, 127, ".", "_" );
	replace_all( szSName, 127, "*", "_" );
	replace_all( szSName, 127, "/", "_" );
	replace_all( szSName, 127, "|", "_" );
	replace_all( szSName, 127, "\", "_" );
	replace_all( szSName, 127, "?", "_" );
	replace_all( szSName, 127, ">", "_" );
	replace_all( szSName, 127, "<", "_" );
	replace_all( szSName, 127, " ", "_" );

	// Displaying messages.
	client_cmd( id, "stop; record ^"%s^"", szSName );
	ColorChat(id, BLUE, "^x04[%s] ^x03Now ^x04we ^x03recording^x03 ^"%s.dem^"", szINamePrefix, szSName );
	ColorChat(id, BLUE, "^x04[%s]^x03 Demo ^x04recording^x03 has been^x04 started^x01 at^x03 %s", szINamePrefix, szTimedata );
	ColorChat(id, BLUE, "^x04[%s] ^x03xD-GaminG^x01 2 ^x03save^x04 all^x03 rights^x01 -_- ^x03#^x03xD-GaminG^x01 2", szINamePrefix );
}