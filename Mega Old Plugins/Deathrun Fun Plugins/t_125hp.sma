
#include <amxmodx> 
#include <hamsandwich> 
#include <fun> 

public plugin_init() 
{ 
    register_plugin("125 hp for ò","1,0", "Papyrus_kn") 
    RegisterHam(Ham_Spawn,"player", "givehp",1) 
} 

public givehp(id) if(is_user_alive(id) && get_user_team(id) == 1) set_user_health(id,125) 