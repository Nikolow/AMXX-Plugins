#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <fun>

new step[33],active,add_hp_c,step_cvar
public plugin_init() {
	register_plugin("+HP Admins", "0.1", "Advanced")
	register_forward(FM_PlayerPreThink,"player_think")
	register_cvar("regen_version", "0.1", FCVAR_SERVER|FCVAR_SPONLY)
	active = register_cvar("regen_on","1")
	add_hp_c = register_cvar("regen_addhp","1")
	step_cvar = register_cvar("regen_step","7")
}

public player_think(id)
{
	if(!get_pcvar_num(active) || !is_user_alive(id) || !is_user_admin(id)) return
	
	step[id]++
	
	if(step[id] == (get_pcvar_num(step_cvar) * 50))
	{
		step[id] = 0
		if(get_user_health(id) < 100) set_user_health(id,get_user_health(id) + get_pcvar_num(add_hp_c))
	}
}
