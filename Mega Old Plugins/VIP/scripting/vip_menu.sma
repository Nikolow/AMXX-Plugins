#pragma semicolon 1
 
#include <amxmodx>
#include <cstrike>
#include <engine>
#include <fun>
#include <hamsandwich>
 
#define ADMIN_JBVIP ADMIN_LEVEL_A

new const VERSION[] = { "0.2" };

new const PREFIX[] = { "!g[VIP]" };
 
new VipUsed[33];
new HasSpeed[33];
 
new Float:fast_speed = 250.0;
new Float:normal_speed = 250.0;
 
public plugin_init()
{
    register_plugin("VIP Menu", VERSION, "Advanced");
 
    RegisterHam(Ham_Spawn, "player", "FwdHamSpawn_Post", 1);
    RegisterHam( Ham_Item_PreFrame, "player", "FwdPreFrame_Post", 1);
   
    register_clcmd("say vipmenu", "cmdVmenu");
    register_clcmd("say /vipmenu", "cmdVmenu");
    register_clcmd("say !vipmenu", "cmdVmenu");
    register_clcmd("say vshop", "cmdVmenu");
    register_clcmd("say /vshop", "cmdVmenu");
    register_clcmd("say !vshop", "cmdVmenu");
    register_clcmd("say vmenu", "cmdVmenu");
    register_clcmd("say /vmenu", "cmdVmenu");
    register_clcmd("say !vmenu", "cmdVmenu");
    register_clcmd("say_team vipmenu", "cmdVmenu");
    register_clcmd("say_team /vipmenu", "cmdVmenu");
    register_clcmd("say_team !vipmenu", "cmdVmenu");
    register_clcmd("say_team vshop", "cmdVmenu");
    register_clcmd("say_team /vshop", "cmdVmenu");
    register_clcmd("say_team !vshop", "cmdVmenu");
    register_clcmd("say_team vmenu", "cmdVmenu");
    register_clcmd("say_team /vmenu", "cmdVmenu");
    register_clcmd("say_team !vmenu", "cmdVmenu");
}
 
 
public FwdPreFrame_Post(id)
{
    if(!is_user_alive(id))
    {
        return PLUGIN_HANDLED;
    }
 
    if(!HasSpeed[id])
    {
        return PLUGIN_HANDLED;
    }
   
    else if(HasSpeed[id])
    {
        set_user_maxspeed(id, fast_speed);
    }
   
    return PLUGIN_HANDLED;
}
 
public FwdHamSpawn_Post(id)
{
    if( is_user_alive(id) )
    {
        HasSpeed[id] = false;
        VipUsed[id] = false;
        set_user_maxspeed(id, normal_speed);
        set_user_rendering( id, _, 0, 0, 0, _, 0 );  
    }
}
 
public cmdVmenu(id)
{
    if(cs_get_user_team(id) == CS_TEAM_CT && get_user_flags(id) & ADMIN_JBVIP && !VipUsed[id])
    {
        VipCTMenu(id);
    }
   
    else if(cs_get_user_team(id) == CS_TEAM_T && get_user_flags(id) & ADMIN_JBVIP && !VipUsed[id])
    {
        VipTMenu(id);
    }
   
    else if(VipUsed[id])
    {
        client_printc(id, "!t%s !nYou !gAlready !nused !tVIP Menu!n this round. Please !gwait !tnext !nround", PREFIX);
    }
   
    else
    {
        client_printc(id, "!t%s !gOnly !tVIP!n may !guse !nthe !tVIP !gMenu", PREFIX);
        return PLUGIN_HANDLED;
    }
   
    return PLUGIN_HANDLED;
}
 
public VipCTMenu(id)
{
    new menu = menu_create("\rCT \yVIP \wMenu:^n\r", "VipTMenu_handler");
 
    menu_additem(menu, "\yAK47\w and \yDeagle \r[\d1 bullets\r]", "1", 0);
    menu_additem(menu, "\dFlash \wGrenade ", "2", 0);
    menu_additem(menu, "\y+50\r hp\w and \y+100 \rarmor", "3", 0);
   
    menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
    menu_display(id, menu, 0);
}
 
public VipCTMenu_handler(id, menu, item)
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
 
    switch(key)
    {
        case 1:
        {
            set_user_health(id, get_user_health(id) + 50);
            set_user_armor(id, get_user_armor(id) + 100);
            VipUsed[id] = true;
           
            client_printc(id, "!t%s !nYou have just !grecieved !t50 !gHP!n and !t100 !gArmor!n!", PREFIX);
        }
        case 2:
        {
            give_item(id, "weapon_glock18");
            cs_set_weapon_ammo(find_ent_by_owner(1, "weapon_glock18", id), 1);
           
            VipUsed[id] = true;
           
            client_printc(id, "!t%s !nYou have just !grecieved an !tGlock!n with !t1!g bullet!n!", PREFIX);
        }
        case 3:
        {
            VipUsed[id] = true;
	    
            give_item(id, "weapon_smokegrenade");
           
            client_printc(id, "!t%s !nYou have just !grecieved !tFrost Grenade!n!", PREFIX);
        }
    }
 
    menu_destroy(menu);
    return PLUGIN_HANDLED;
}
 
public VipTMenu(id)
{
    new menu = menu_create("\rTT \yVIP \wMenu:^n\r", "VipCTMenu_handler");
 
    menu_additem(menu, "\y+50\r hp\w and \y+100\r armor", "1", 0);
    menu_additem(menu, "\wGlock \r[\d1 bullet\r]", "2", 0);
    menu_additem(menu, "\dFrost \wGrenade", "3", 0);
   
    menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
    menu_display(id, menu, 0);
}
 
public VipTMenu_handler(id, menu, item)
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
 
    switch(key)
    {
	case 1:
        {    
            give_item(id, "weapon_deagle");
            cs_set_weapon_ammo(find_ent_by_owner(1, "weapon_deagle", id), 1);
            give_item(id, "weapon_ak47");
            cs_set_weapon_ammo(find_ent_by_owner(1, "weapon_ak47", id), 1);
           
            client_printc(id, "!t%s !nYou have just !grecieved a !tDeagle!n and !tAK47!n with !g1 !tbullets!n!", PREFIX);
           
            VipUsed[id] = true;
        }
        case 2:
        {
            VipUsed[id] = true;
	    
            give_item(id, "weapon_flashbang");
           
            client_printc(id, "!t%s !nYou have just !grecieved !tFlash Grenade!n", PREFIX);
        }
       
        case 3:
        {
            set_user_health(id, get_user_health(id) + 50);
            set_user_armor(id, get_user_armor(id) + 100);
            VipUsed[id] = true;
           
            client_printc(id, "!t%s !nYou have just !grecieved !t50 !gHP!n and !t100 !gArmor!n!", PREFIX);
        }	
    }
 
    menu_destroy(menu);
    return PLUGIN_HANDLED;
}
 
// Colour Chat
stock client_printc(const id, const input[], any:...)
{
    new count = 1, players[32];
    static msg[191];
    vformat(msg, 190, input, 3);
   
    replace_all(msg, 190, "!g", "^x04"); // Green Color
    replace_all(msg, 190, "!n", "^x01"); // Default Color
    replace_all(msg, 190, "!t", "^x03"); // Team Color
   
    if (id) players[0] = id; else get_players(players, count, "ch");
    {
        for (new i = 0; i < count; i++)
        {
            if (is_user_connected(players[i]))
            {
                message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("SayText"), _, players[i]);
                write_byte(players[i]);
                write_string(msg);
                message_end();
            }
        }
    }
}  
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ ansicpg1251\\ deff0\\ deflang1026{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ f0\\ fs16 \n\\ par }
*/
