/*

	Плъгин, с който с командата /hide можете да пускате и спирате HUD съобщенията за информацията на екрана си.
	Плъгина работи, заедно с shop плъгина !

*/

#include < amxmodx >
#include < colorchat >

native hide_rank_hud( index, value );
native hide_shop_hud( index, value );

new bool:g_szHideRank[ 33 ], bool:g_szHideShop[ 33 ];

public plugin_init( )
{
	register_plugin( "Hide HUD", "1.0", "Smiley" );
	
	register_clcmd( "say /hide", "cmdHideMenu" );
	register_clcmd( "say_team /hide", "cmdHideMenu" );	
	
	set_task( 65.0, "TaskAdvertMessage", _, _, _, "b" );
}

public cmdHideMenu( id )
{
	new menu = menu_create( "[\rBetterPlay\w] \yHide \wHUD \rMenu", "HideMenuHandler" );
	
	g_szHideRank[ id ] ? menu_additem( menu, "\yRank \wHUD\d: \rInvisible", "1", 0 ) : menu_additem( menu, "\yRank \wHUD\d: \rVisible", "1", 0 );
	g_szHideShop[ id ] ? menu_additem( menu, "\yShop Points \wHUD\d: \rInvisible", "2", 0 ) : menu_additem( menu, "\yShop Points \wHUD\d: \rVisible", "2", 0 );

	menu_display( id, menu, 0 );
}

public HideMenuHandler( id, menu, item )
{
	if( item == MENU_EXIT )
	{
		menu_destroy( menu );
		return PLUGIN_HANDLED;
	}
	
	new iData[ 6 ], iName[ 63 ], iAccess, iCallback;
	menu_item_getinfo( menu, item, iAccess, iData, charsmax( iData ), iName, charsmax( iName ), iCallback );
	
	switch( str_to_num( iData ) )
	{
		case 1:
		{
			g_szHideRank[ id ] = !g_szHideRank[ id ];
			hide_rank_hud( id, g_szHideRank[ id ] ? 1 : 0 );
			cmdHideMenu( id );
		}
		case 2:
		{
			g_szHideShop[ id ] = !g_szHideShop[ id ];
			hide_shop_hud( id, g_szHideShop[ id ] ? 1 : 0 );
			cmdHideMenu( id );
		}
	}
	
	menu_destroy( menu );
	return PLUGIN_HANDLED;
}
	
public TaskAdvertMessage( )
{
	for( new id = 1; id <= 32; id++ )
	{
		if( is_user_connected( id ) )
		{
			ColorChat( id, RED, "^4[BetterPlay]^3 Type^4 /hide^1 to open^3 Hide-HUD Menu" );
		}
	}
}


		


/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1026\\ f0\\ fs16 \n\\ par }
*/
