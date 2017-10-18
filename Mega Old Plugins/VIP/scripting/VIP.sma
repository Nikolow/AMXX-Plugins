#include <amxmodx>
#include <cstrike>
#include <hamsandwich>
#include <fun>

#define VIP_ACCESS ADMIN_LEVEL_A // vip access level

new cvar_heg,cvar_smoke,cvar_flash, hs_hp,hs_money, kill_hp,kill_money, vip_model,vip_t_model_name,vip_ct_model_name,
cvar_armor_type, cvar_armor,
t_mdl_cvar_str[32],t_mdl_str[128], ct_mdl_cvar_str[32],ct_mdl_str[128]
public plugin_precache()
{
	vip_model = register_cvar("vip_change_model","1")
	vip_t_model_name = register_cvar("vip_t_model_name","T_VIP")
	vip_ct_model_name = register_cvar("vip_ct_model_name","CT_VIP")
	
	if(get_pcvar_num(vip_model))
	{
		get_pcvar_string(vip_t_model_name,t_mdl_cvar_str,31)
		formatex(t_mdl_str,127,"models/player/%s/%s.mdl",t_mdl_cvar_str,t_mdl_cvar_str)
		precache_model(t_mdl_str)
		
		get_pcvar_string(vip_ct_model_name,ct_mdl_cvar_str,31)
		formatex(ct_mdl_str,127,"models/player/%s/%s.mdl",ct_mdl_cvar_str,ct_mdl_cvar_str)
		precache_model(ct_mdl_str)
	}
}

public plugin_init() {
	register_plugin("VIP Extras", "1.3", "VeCo")
	
	cvar_heg = register_cvar("vip_give_hegrenade","1")
	cvar_smoke = register_cvar("vip_give_smokegrenade","0")
	cvar_flash = register_cvar("vip_give_flashbang","0")
	
	hs_hp = register_cvar("vip_hs_hp","10")
	hs_money = register_cvar("vip_hs_money","800")
	
	kill_hp = register_cvar("vip_kill_hp","5")
	kill_money = register_cvar("vip_kill_money","500")
	
	cvar_armor_type = register_cvar("vip_armor_type","0")
	cvar_armor = register_cvar("vip_armor","0")
	
	register_event("DeathMsg","hook_death","a")
	RegisterHam(Ham_Spawn,"player","player_spawn",1)
}

public player_spawn(id)
{
	if(is_user_alive(id) && (get_user_flags(id) & VIP_ACCESS))
	{
		if(get_pcvar_num(cvar_heg)) give_item(id,"weapon_hegrenade")
		if(get_pcvar_num(cvar_smoke)) give_item(id,"weapon_smokegrenade")
		
		switch(get_pcvar_num(cvar_flash))
		{
			case 1: give_item(id,"weapon_flashbang")
			case 2:
			{
				give_item(id,"weapon_flashbang")
				give_item(id,"weapon_flashbang")
			}
			
		}
		
		if(get_pcvar_num(vip_model))
		{
			switch(cs_get_user_team(id))
			{
				case CS_TEAM_T: cs_set_user_model(id,t_mdl_cvar_str)
				case CS_TEAM_CT: cs_set_user_model(id,ct_mdl_cvar_str)
			}
		}
		
		if(get_pcvar_num(cvar_armor_type) > 0) cs_set_user_armor(id,get_pcvar_num(cvar_armor),CsArmorType:get_pcvar_num(cvar_armor_type))
	}
}

public hook_death()
{
	new killer = read_data(1)
	new victim = read_data(2)
	new hs = read_data(3)
	
	if(is_user_connected(killer) && is_user_connected(victim) && (get_user_flags(killer) & VIP_ACCESS) && killer != victim && get_user_team(killer) != get_user_team(victim))
	{
		if(hs)
		{
			set_user_health(killer,get_user_health(killer) + get_pcvar_num(hs_hp))
			cs_set_user_money(killer,cs_get_user_money(killer) + get_pcvar_num(hs_money))
		} else {
			set_user_health(killer,get_user_health(killer) + get_pcvar_num(kill_hp))
			cs_set_user_money(killer,cs_get_user_money(killer) + get_pcvar_num(kill_money))
		}
	}
}
