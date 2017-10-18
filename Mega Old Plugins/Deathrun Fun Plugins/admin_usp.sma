#include <amxmodx>
#include <amxmisc>
#include <hamsandwich>
#include <cstrike>
#include <fun>

public plugin_init() {
    register_plugin("Admin CT USP", "1.0", "<VeCo>")
    
    RegisterHam(Ham_Spawn,"player","player_spawn",1)
}

public player_spawn(id)
{
    if(!is_user_alive(id) || !(get_user_flags(id) & ADMIN_KICK) || cs_get_user_team(id) != CS_TEAM_CT) return
    
    set_task(1.0,"give_weapons",id)
}

public give_weapons(id)
{
    if(!is_user_connected(id) || !is_user_alive(id)) return
    
    give_item(id,"weapon_usp")
    cs_set_user_bpammo(id,CSW_USP,0)
} 
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ ansicpg1251\\ deff0\\ deflang1026{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ f0\\ fs16 \n\\ par }
*/
