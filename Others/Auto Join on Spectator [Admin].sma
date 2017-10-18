/*
	Auto Join to Spectator by Smiley
	First Realise: 21.09.2015

	Плъгина има команда, която е само за администратори (/autojoin), която променя играта на сървъра.
	Тоест ако е включена опцията, всички играчи при тяхното влизане ще бъдат прехвърляне като наблюдаващи.
	По този начин администраторите могат да играят или да редактират нещата по картата (дали блокчета или реклами)
	на свобода, без да пречат другите играчи.

*/

#include < amxmodx >
#include < cstrike >
#include < nvault >

new g_szChoosed[ 33 ], g_szAdmin[ 33 ], vault;
new const g_szPrefix[ ] = "^4[Auto Join]";

public plugin_init( )
{
	register_plugin( "Auto Join to Spectator", "1.1", "Smiley" );
	
	register_clcmd( "say /autojoin", "clcmdCheckAccess" );
	register_clcmd( "say_team /autojoin", "clcmdCheckAccess" );

	vault = nvault_open( "AutoJoinToSpectator" );
	set_task( 420.0, "taskAdvert", _, _, _, "b" );
}

public client_authorized( id )
{
	g_szAdmin[ id ] = ( get_user_flags( id ) & ADMIN_BAN ) ? true : false;
	Load( id );
}

public client_disconnect( id ) 
{
	g_szAdmin[ id ] = false;
	Save( id );
}

public client_putinserver( id )
{
	set_task( 3.0, "taskCheckClient", id );
}

public taskCheckClient( id )
{
	if( !is_user_connected( id ) || !g_szChoosed[ id ] || !g_szAdmin[ id ] ) return;
	
	if( is_user_alive( id ) ) user_silentkill( id );
	cs_set_user_team( id, CS_TEAM_SPECTATOR );
}
	
public clcmdCheckAccess( id )
{
	if( !g_szAdmin[ id ] )
	{
		ColorMessage( id, "%s^1 You have not^3 access^1 to this^4 command^1!", g_szPrefix );
		return PLUGIN_CONTINUE;
	}
	
	ShowSelectMenu( id );
	return PLUGIN_CONTINUE;
}
		
public ShowSelectMenu( id )
{
	new menu = menu_create( "\rAuto \yJoin \dto \wSpectator", "SelectMenuHandler" );
	
	new text[ 64 ];
	formatex( text, charsmax( text ), "\yPress \dto \y%s", g_szChoosed[ id ] ? "Disable" : "Enable" );
	menu_additem( menu, text, "1", 0 );

	menu_setprop( menu, MPROP_EXIT, MEXIT_ALL );
	menu_display( id, menu, 0 );
}

public SelectMenuHandler( id, menu, item )
{
	if( item == MENU_EXIT )
	{
		menu_destroy( menu );
		return PLUGIN_HANDLED;
	}
	
	new iData[ 6 ], iName[ 63 ], iAccess, iCallback;
	menu_item_getinfo( menu, item, iAccess, iData, charsmax( iData ), iName, charsmax( iName ), iCallback );
	
	if( str_to_num( iData ) == 1 )
	{
		g_szChoosed[ id ] = !g_szChoosed[ id ];
		Save( id );
		
		ColorMessage( id, "%s^1 You have^3 successfully^4 %s^1 Auto Join to Spectator", g_szPrefix, g_szChoosed[ id ] ? "Enable" : "Disable" );
		if( g_szChoosed[ id ] ) ColorMessage( id, "%s^1 The^3 next time you connect^1 to the server will be transferred^4 automatically^1.", g_szPrefix );
	}
	
	menu_destroy( menu );
	return PLUGIN_HANDLED;
}

public Load( id )
{
	if( !is_user_bot( id ) && !is_user_hltv( id ) )
	{
		new data[ 256 ], name[ 33 ], ich[ 33 ];
		get_user_name( id, name, charsmax( name ) );
		
		format( data, charsmax( data ), "%i#", g_szChoosed[ id ] )
		nvault_get( vault, name, data, 255 );
		
		replace_all( data, 255, "#", " " );
		parse( data, ich, 32 );
		
		g_szChoosed[ id ] = str_to_num( ich );
	}
}

public Save( id )
{
	if( !is_user_bot( id ) && !is_user_hltv( id ) )
	{
		new data[ 256 ], name[ 33 ];
		get_user_name( id, name, charsmax( name ) );
		
		format( data, charsmax( data ), "%i#", g_szChoosed[ id ] )
		nvault_set( vault, name, data );
	}
}

public taskAdvert( )
{
	for( new i = 1; i <= get_maxplayers( ); i++ )
	{
		if( !is_user_connected( i ) || !g_szAdmin[ i ] ) continue;
		
		ColorMessage( i, "%s^1 Type^4 /autojoin^1 to^3 open^4 Auto Join^1 Menu.", g_szPrefix );
	}
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
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1026\\ f0\\ fs16 \n\\ par }
*/
