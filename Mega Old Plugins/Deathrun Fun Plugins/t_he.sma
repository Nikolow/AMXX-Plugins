#include <amxmodx>
#include <hamsandwich>
#include <fun>

public plugin_init()
{
register_plugin("Give t hegrenade","1.0","Papyrus_kn")
RegisterHam(Ham_Spawn,"player","player_spawn",1)
}

public player_spawn(index)
{
set_task(1.0,"set_weapons",index)
} 

public set_weapons(index)
{
if(is_user_connected(index) && is_user_alive(index) && get_user_team(index) == 1)
{
strip_user_weapons(index)
give_item(index,"weapon_knife")
give_item(index,"weapon_hegrenade")
}
} 