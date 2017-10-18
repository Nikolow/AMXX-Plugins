#include <amxmodx> 

#define PLUGIN "Legal Settings" 
#define VERSION "1.0" 
#define AUTHOR "SpeeD" 

const FPS_MAX = 101; 
const FPS_MODEM = 0; 

public plugin_init()  
{ 
    register_plugin(PLUGIN, VERSION, AUTHOR); 
} 

public client_putinserver(id) 
{ 
    set_task(1.0, "QueryDelay", id); 
    set_task(2.0, "QueryDelay2", id); 
} 

public QueryDelay(id) 
{ 
    if(is_user_connected(id)) 
    query_client_cvar(id, "fps_modem", "FpsModemResult"); 
} 

public QueryDelay2(id) 
{ 
    if(is_user_connected(id)) 
    query_client_cvar(id, "fps_max", "FpsMaxResult"); 
} 

public FpsModemResult(id, const cvar[], const value[]) 
{ 
    if(str_to_num(value) != FPS_MODEM) 
    { 
        server_cmd("kick #%d ^"You are using an illegal setting fps_modem^"", get_user_userid(id));
         
        new szName[32]; 
        get_user_name(id, szName, charsmax(szName)); 
         
        client_print(0, print_chat, "[%s] uses settings different from fps_modem %d", szName, FPS_MODEM); 
    } 
} 

public FpsMaxResult(id, const cvar[], const value[]) 
{ 
    if(str_to_num(value) != FPS_MAX) 
    { 
        server_cmd("kick #%d ^"You are using an illegal setting fps_max^"", get_user_userid(id)); 
         
        new szName[32]; 
        get_user_name(id, szName, charsmax(szName)); 
         
        client_print(0, print_chat, "[%s] uses settings different from fps_max %d", szName, FPS_MAX); 
    } 
} 