#include <amxmodx> 
#include <amxmisc> 
#include <hamsandwich> 
#include <fakemeta>
#include <colorchat>
#include <cstrike>

#define TIME 20.0 

new Float:player_origin[33][3]; 

public plugin_init() 
{ 
    RegisterHam(Ham_Spawn, "player", "e_Spawn", 1); 
} 
  
public e_Spawn(id) 
{ 
    if (cs_get_user_team(id)!=CS_TEAM_CT) return HAM_IGNORED;
    remove_task(id) 
    if(is_user_alive(id)) 
    { 
        set_task(0.8, "get_spawn", id); 
    } 
    return HAM_IGNORED; 
} 

public get_spawn(id) 
{ 
    pev(id, pev_origin, player_origin[id]); 
    set_task(TIME, "check_afk", id); 
} 
  
public check_afk(id) 
{ 
    if(is_user_alive(id)) 
    { 
        if(same_origin(id)) 
        { 
            user_kill(id); 
            new name[33]; 
            get_user_name(id, name, 32); 
            ColorChat(id, RED, "^x03[EasyBlock]^x04 %s ^x01was^x04 killed^x01 for^x03 AFK", name); // fixed error here too 
        } 
    } 
} 
  
public same_origin(id) 
{ 
    new Float:origin[3]; 
    pev(id, pev_origin, origin); 
    for(new i = 0; i < 3; i++) 
        if(origin[i] != player_origin[id][i]) 
            return 0; 
    return 1; 
} 