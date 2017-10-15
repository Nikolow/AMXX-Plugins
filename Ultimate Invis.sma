#include <amxmodx>
#include <cstrike>
#include <fakemeta>
#include <hamsandwich>

#pragma semicolon 1

new bool:g_bPlayerInvisible[33], bool:g_bWaterInvisible[33], bool: g_bChatBoxe[33];
new bool:g_bWaterEntity[1386], bool:g_bWaterFound;

new g_iSpectatedId[33];

public plugin_init( )
{
    register_plugin( "Ultimate Invis", "0.1", "");
    
    register_clcmd( "say /invis", "menuInvisDisplay" );
    register_clcmd( "say_team /invis", "menuInvisDisplay" );
    register_menucmd( register_menuid( "\yUltimate Invis \w-- \rBetter FPS^n^n" ), 1023, "menuInvisAction" );
    
    register_forward( FM_PlayerPreThink, "fwdPlayerPreThink_Pre", 0 );
    register_forward( FM_AddToFullPack, "fwdAddToFullPack_Post", 1 );
    
    RegisterHam( Ham_Spawn, "player", "hamSpawnPlayer_Post", 1 );
}

public plugin_cfg( )
{
    new ent = engfunc( EngFunc_FindEntityByString, -1, "classname", "func_water" );
    while( ent )
    {
        if( !g_bWaterFound )
            g_bWaterFound = true;

        g_bWaterEntity[ent] = true;
        
        ent = engfunc( EngFunc_FindEntityByString, ent, "classname", "func_water" );
    }
}

public fwdPlayerPreThink_Pre( plr )
    if( !is_user_alive( plr ) )
        g_iSpectatedId[plr] = pev( plr, pev_iuser2 );

public fwdAddToFullPack_Post( es_handle, e, ent, host, hostflags, player, pset )
{
    if( player )
    {
        if( g_bPlayerInvisible[host] && host != ent )
        {
				if (!is_user_alive(ent))
					return;

				if( ent != g_iSpectatedId[host] && cs_get_user_team( host ) == cs_get_user_team( ent ) && is_user_connected(ent)  )
				{
					set_es( es_handle, ES_Origin, { 999999999.0, 999999999.0, 999999999.0 } );
					set_es( es_handle, ES_RenderMode, kRenderTransAlpha );
					set_es( es_handle, ES_RenderAmt, 0 );
				}
			
        }
    }
    else if( g_bWaterInvisible[host] )
        if( g_bWaterEntity[ent] )
            set_es( es_handle, ES_Effects, EF_NODRAW );
}

public hamSpawnPlayer_Post( plr )
{
    g_iSpectatedId[plr] = 0;
}

public menuInvisDisplay( plr )
{
    static menu[2048];

    new len = format( menu, sizeof menu - 1, "\yUltimate Invis \w-- \rBetter FPS^n^n" );
    
    len += format( menu[len], sizeof menu - len, "\r1. \wTeammates: %s^n", g_bPlayerInvisible[plr] ? "\yInvisible" : "\rVisible" );
    len += format( menu[len], sizeof menu - len, "\r2. \wChatBox: %s^n", g_bChatBoxe[plr] ? "\yInvisible" : "\rVisible" );
    len += format( menu[len], sizeof menu - len, "%s^n^n", g_bWaterFound ? ( g_bWaterInvisible[plr] ? "\r3. \wWater: \yInvisible^n^n" : "\r3. \wWater: \rVisible^n^n" ) : "^n^n" );
    len += format( menu[len], sizeof menu - len, "^n\r0. \wExit" );
    
    show_menu( plr, ( 1<<0 | 1<<1 | 1<<9 ), menu, -1 );
        
    return PLUGIN_HANDLED;
}

public menuInvisAction( plr, key )
{
    switch( key )
    {
        case 0: //1
        {
            g_bPlayerInvisible[plr] = !g_bPlayerInvisible[plr];
            menuInvisDisplay( plr );
        }
	    case 1: //2
		{
			g_bChatBoxe[plr] = !g_bChatBoxe[plr];
			client_cmd(plr,"hud_saytext");
			menuInvisDisplay( plr );
     
		}
		case 2: //3
        {
            g_bWaterInvisible[plr] = !g_bWaterInvisible[plr];
            menuInvisDisplay( plr );
        }
        case 9: show_menu( plr, 3, "" ); //0
    }
}

public client_connect( plr )
{
    g_bPlayerInvisible[plr] = false;
    g_bWaterInvisible[plr] = false;
    g_bChatBoxe[plr] = false;
    g_iSpectatedId[plr] = 0;
}
