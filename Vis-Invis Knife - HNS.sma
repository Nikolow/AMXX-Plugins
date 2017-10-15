#include <amxmodx>
#include <cstrike>
#include <fakemeta>
#include <hamsandwich>
#include <nvault>
#include <colorchat2>

#define m_pPlayer 41  // (weapon_*) owner entity

new g_Vault;
new g_iMenu;
new bool:g_bShow[33];

public plugin_init()
{
	register_plugin( "Simple knife menu", "1.1", "???" );
	
	register_clcmd( "say /knife", "Knife_Toggle" );

	RegisterHam( Ham_Item_Deploy, "weapon_knife", "Ham_Item_Deploy_Post", 1 );
	
	g_Vault = nvault_open( "Show_Knife" );

	g_iMenu = menu_create( "Show knife? \r[As terrorist]", "Knife_Menu_Handle" );

	menu_additem( g_iMenu, "Yes", "1" );
	menu_additem( g_iMenu, "No", "0" );

	menu_setprop( g_iMenu, MEXIT_ALL, 0 );
}

public client_putinserver(id)
{
	new szAuthid[35];
	get_user_authid(id, szAuthid, 34);

	new get[3];
	
	if ( nvault_get(g_Vault, szAuthid, get, 2) ) // data exists
	{
		g_bShow[id] = (get[0] == 't');
	}
	else // no data exists, so set the default values
	{
		g_bShow[id] = true;
		set_task( 5.0, "Knife_Menu", id ); // Show it at first connection by authid
	}
}

public Knife_Toggle(id)
{
	g_bShow[id] = !g_bShow[id];

	ColorChat( id, GREY, "^x04 [PREFIX]^x01 Your Knife now is^x03 %svisible^x01 as terrorist.", g_bShow[id] ? "" : "in" ); // Used whenever you are in game

	new Data[3];
	new Authid[35];
	
	Data[0] = g_bShow[id] ? 't' : 'f';
	Data[1] = '^0'; // end of string

	get_user_authid(id, Authid, charsmax(Authid));
	nvault_set( g_Vault, Authid, Data );
}

public Knife_Menu(id) 
{
	menu_display( id, g_iMenu );
}

public Knife_Menu_Handle(id, menu, item)
{
	new Data[3];
	new Dummy[35];
	menu_item_getinfo( menu, item, Dummy[0], Data, charsmax(Data), _, _, Dummy[0] );
	
	if ( g_bShow[id] == !!str_to_num(Data) ) // !! would turn it to false, then into true, or true, and then in false, same shit.
	{
		ColorChat( id, GREY, "^x04 [PREFIX]^x01 Your knife already is^x03 %svisible^x01 as terrorist.", g_bShow[id] ? "" : "in"); // Used only at first connect
	}
	else
	{
		g_bShow[id] = !g_bShow[id];
		ColorChat( id, GREY, "^x04 [PREFIX]^x01 Knife now is^x03 %svisible^x01 as terrorist. Type^x04 /knife^x01 to switch your plan.", g_bShow[id] ? "" : "in" ); // Used only at first connect
	}

	//menu_destroy(menu);

	Data[0] = g_bShow[id] ? 't' : 'f';
	Data[1] = '^0'; // end of string

	get_user_authid(id, Dummy, charsmax(Dummy));
	nvault_set( g_Vault, Dummy, Data );

	return PLUGIN_HANDLED;
}

public Ham_Item_Deploy_Post(iEnt)
{
	if ( pev_valid(iEnt) != 2 ) // pvPrivateData not initialized
		return HAM_IGNORED;
		
	static iPlrId; // can be called many times
	iPlrId = get_pdata_cbase( iEnt, m_pPlayer, 4 );
	
	if ( pev_valid(iPlrId) != 2 ) // player's pvPrivateData not initialized (cs_get_user_team patch)
		return HAM_IGNORED;

	if ( is_user_alive(iPlrId) && !g_bShow[iPlrId] && cs_get_user_team(iPlrId) == CS_TEAM_T ) // alive - with invisible knife - terrorist
		set_pev( iPlrId, pev_viewmodel, 0 ) ;
		
	return HAM_IGNORED;
}
