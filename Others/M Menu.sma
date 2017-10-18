/*

	Прост плъгин, с който при натискане на копчето М, отваря меню, което може много лесно да бъде редактирано.
	Сменят се само имената на опциите и технте функции, които изпълняват.
	Съответно в момента изпълняват чат команди с client_cmd.

*/


#include < amxmodx >
#include < amxmisc >
#include < cstrike >
#include < engine >
#include < hamsandwich >

new bool:iChance[ 33 ], iAdmin[ 33 ];

public plugin_init( )
{
	register_plugin( "HNS Menu", "1.0", "Smiley" );
	register_clcmd( "chooseteam", "CmdBlock" )
	
	RegisterHam( Ham_Spawn, "player", "fwdPlayerSpawn", 1 );
}

public client_authorized( id ) iAdmin[ id ] = ( get_user_flags( id ) & ADMIN_KICK ) ? true : false;

public fwdPlayerSpawn( id ) if( is_user_alive( id ) ) iChance[ id ] = false;

public CmdBlock( id )
{
	if( is_user_alive( id ) || !is_user_alive( id ) )
	{
		FunctionOpenHNSMenu( id );
		return PLUGIN_HANDLED;
	}
	
	return PLUGIN_CONTINUE;
}

public Reset( id ) iChance[ id ] = true;

public FunctionOpenHNSMenu( id )
{
	new CsTeams:team = cs_get_user_team( id );
	if( team == CS_TEAM_SPECTATOR ) return PLUGIN_CONTINUE;
	
	new iMenu = menu_create( "\yBetterPlay \d- \wHNS BM \dGame-Play \rMenu", "cmdHNSMenuHandler" );
	
	menu_additem( iMenu, "\yShop \wMenu^n", "1", 0 );
	
	menu_additem( iMenu, "\yXP \wMenu", "2", 0 );
	menu_additem( iMenu, "\yXP \wTop^n", "3", 0 );
	
	menu_additem( iMenu, "\yServer \wList", "4", 0 );
	menu_additem( iMenu, "\yRock \dThe \wVote", "5", 0 );
	iAdmin[ id ] ? menu_additem( iMenu, "\yAdmin \wMenu^n", "6", 0 ) : menu_additem( iMenu, "\dAdmin Menu^n", "6", 0 );

	if( iChance[ id ] ) menu_additem( iMenu, "\dChance to win 1 Point", "7", 0 );
	else if( !is_user_alive( id ) ) menu_additem( iMenu, "\dChance to win 1 Point", "7", 0 );
	else menu_additem( iMenu, "\yChance \wto \rwin \y1 \wPoint", "7", 0 );

	menu_setprop( iMenu, MPROP_EXIT, MEXIT_ALL );
	menu_display( id, iMenu, 0 );
	
	return PLUGIN_CONTINUE;
}

public cmdHNSMenuHandler( id, iMenu, item )
{
	if( item == MENU_EXIT )
	{
		menu_destroy( iMenu );
		return PLUGIN_HANDLED;
	}
	
	new iData[ 32 ], iName[ 63 ], iAccess, iCallback;
	menu_item_getinfo( iMenu, item, iAccess, iData, charsmax( iData ), iName, charsmax( iName ), iCallback );

	switch( str_to_num( iData ) )
	{
		case 1: client_cmd( id, "say /shop" );
		case 2: client_cmd( id, "say /xp" );
		case 3: client_cmd( id, "say /xptop" );
		case 4: client_cmd( id, "say /server" );
		case 5: client_cmd( id, "say rockthevote" );
		case 6: iAdmin[ id ] ? client_cmd( id, "say /amenu" ) : FunctionOpenHNSMenu( id );
		case 7:
		{
			if( iChance[ id ] ) FunctionOpenHNSMenu( id );
			else if( !is_user_alive( id ) ) FunctionOpenHNSMenu( id );
			else
			{
				Reset( id );
				if( callfunc_begin( "CmdChance", "HidenSeekShop.amxx" ) == 1 )
				{
					callfunc_push_int( id );
					callfunc_end( );
				}
			}
		}
	}
	
	menu_destroy( iMenu );
	return PLUGIN_HANDLED;
}
	
	
				
