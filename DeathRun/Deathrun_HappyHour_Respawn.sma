#include <amxmodx> 
#include <fakemeta> 
#include <hamsandwich>
#include <cstrike> //

new bool:g_happyhour 
new cvar_init,cvar_end,cvar_on,message[80] 


public plugin_init()  
{ 
    register_plugin("Happy hour", "1.0", "Freestyle") 
     
    cvar_init = register_cvar("happyinit", "22") 
    cvar_end = register_cvar("happyend", "5") 
    cvar_on = register_cvar("happyhour", "1") 
     
    RegisterHam(Ham_Spawn, "player", "fw_PlayerSpawn_post",1)    
    RegisterHam(Ham_Killed, "player", "RevivePlayer", true) 
} 
public plugin_cfg() 
{ 
    if(get_pcvar_num(cvar_on)) 
    { 
        new data[3] 
        get_time("%H", data, 2) 
         
        if(get_pcvar_num(cvar_end) > str_to_num(data) >= get_pcvar_num(cvar_init)) 
        { 
            g_happyhour = true 
            formatex(message, charsmax(message), "[HAPPY HOUR]!! Start: %d - End: %d", get_pcvar_num(cvar_init), get_pcvar_num(cvar_end)) 
        }   
    } 
} 


public fw_PlayerSpawn_post(id) 
{ 
    if(message[0]) client_print(id,print_chat, message) 
} 

public RevivePlayer(id) 
{ 
    if(g_happyhour) 
    { 
        if (cs_get_user_team(id) == CS_TEAM_CT)
        {
           ExecuteHamB(Ham_CS_RoundRespawn, id);
        }
    } 
}  
