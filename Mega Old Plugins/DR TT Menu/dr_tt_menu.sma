#include <amxmodx> 
#include <amxmisc> 
#include <hamsandwich> 
#include <fun> 
#include <cstrike> 

#define PLUGIN "Deathrun Terrorists Menu" 
#define VERSION "1.0" 
#define AUTHOR "SpeeD" 

public plugin_init()  
{ 
    register_plugin(PLUGIN, VERSION, AUTHOR) 
    RegisterHam( Ham_Spawn, "player", "fw_PlayerSpawn",1) 
    RegisterHam( Ham_Killed,"player", "fw_PlayerKilled") 
} 

public menu_handler(id, menu, item) 
{ 
    if( item == MENU_EXIT ) 
    { 
        menu_destroy(menu); 
        return PLUGIN_HANDLED; 
    } 
     
    new data[6], iName[64]; 
    new access, callback; 
     
    menu_item_getinfo(menu, item, access, data,5, iName, 63, callback); 
     
    new key = str_to_num(data); 
     
     
    switch( key )  
    { 
        case 1: set_user_health(id,250) 
            case 2: 
        { 
            give_item(id,"weapon_hegrenade") 
	   give_item(id,"weapon_flashbang")
        } 
        case 3:set_user_rendering(id,kRenderNormal,0,0,0,kRenderTransAlpha,67)
        } 
    return PLUGIN_CONTINUE 
} 

public fw_PlayerSpawn(id) 
{ 
     
    if(!is_user_alive(id) && !is_user_connected(id)) return 
     
    new CsTeams:team = cs_get_user_team(id); 
    if(team != CS_TEAM_T) return 
     
    new menu = menu_create("\r[\wMax-Play\r] \wDeathrun \rTerrorists \wMenu ", "menu_handler"); 
     
    menu_additem(menu,"\w250 \rHP [\wOn change \r/knife \wwill \rreturn to 100].","1",0) 
    menu_additem(menu,"\rHE, \wFlash.","2",0) 
    menu_additem(menu,"\rInvisibility \w(75%)","3",0) 
    menu_setprop(menu, MPROP_EXIT, MEXIT_ALL); 
    menu_display(id, menu, 0) 
} 

public fw_PlayerKilled(id) 
    set_user_rendering(id) 