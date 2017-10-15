#include <amxmodx>
#include <fakemeta>
#include <cstrike>

#define PLUGIN "Simon Menu New"
#define VERSION "1.0"
#define AUTHOR "pRoxxx"

new victim, mxplr
new bool:NotT[33]

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_clcmd("say /punish", "punish_menu")
	register_logevent("back_toct", 2, "0=World triggered", "1=Round_End")
	mxplr = get_maxplayers()
}

public client_disconnect(id)
{
	NotT[id] = false
	
}

public client_connect(id)
{
	NotT[id] = false
	
}
	
public back_toct()
{
	static i
	for(i = 1; i < mxplr; i++)
	{
		if(!NotT[i])
		continue
		
		if(is_user_alive(i))
			user_kill(i)
			
		cs_set_user_team(i, CS_TEAM_CT)
	}
}
public punish_menu(id)
{
	if(!jb_is_user_simon(id) || !is_user_alive(id))
	return PLUGIN_HANDLED
	
	static m, i
	m = menu_create("Choose:", "phand")
	
	for(i = 1; i< mxplr; i++ )
	{
		if(get_user_team(i) != 2 || !is_user_alive(i) || i == id)
		continue
		
		static name[32], temp[10]
		
		get_user_name(i, name, 31)
		num_to_str(i, temp, 9)
		
		menu_additem(m, name, temp)
		
		
	}
	
	menu_display(id, m)
	
	return PLUGIN_HANDLED
}

public phand(id, menu, item)
{
	if(item == MENU_EXIT || !is_user_alive(id))
	{
		menu_destroy(menu)
		return PLUGIN_HANDLED
	}
	
	static data[6], name[64], accss, cllbck, vic
	menu_item_getinfo(menu, item, accss, data, 5, name, 63, cllbck)
	
	vic = str_to_num(data)
	if(is_user_alive(vic) && get_user_team(vic) == 2)
	{
		victim = vic
		pun_menu2(id)
		
	}
	menu_destroy(menu)
	return PLUGIN_HANDLED
	
}

public pun_menu2(id)
{
	if(!jb_is_user_simon(id) || !is_user_alive(id) || !is_user_alive(victim))
	return PLUGIN_HANDLED
	
	static m
	m = menu_create("\wChoose a punishment?", "phand2")
	
	menu_additem(m, "\yMake player \r1 HP", "1")
	
	menu_additem(m, "\yDrop \rAll Weapons", "2")
	
	menu_additem(m, "\yMake him Prisioner", "3")
	
	menu_additem(m, "\yKill him NOW !", "4")
	
	menu_additem(m, "\yMake him with No Money !", "5")
	
	menu_display(id, m)
	
	return PLUGIN_HANDLED
}

public phand2(id, menu, item)
{
	if(item == MENU_EXIT || !is_user_alive(id) || !is_user_alive(victim))
	{
		menu_destroy(menu)
		victim = 0
		return PLUGIN_HANDLED
	}
	
	static data[6], name[64], accss, cllbck, key
	menu_item_getinfo(menu, item, accss, data, 5, name, 63, cllbck)
	new user_money = cs_get_user_money(id)
	
	key = str_to_num(data)
	switch(key)
	{
		case 1:
		{
			set_pev(victim, pev_health, 1.0)
			
		}
		case 2:
		{
			fm_strip_user_weapons(victim)
			
		}
		case 3:
		{
			user_kill(victim)
			cs_set_user_team(victim, CS_TEAM_T)
			set_user_info(victim, "model", "jbemodel")
			set_pev(victim, pev_body, 2)
			set_pev(victim, pev_skin, random_num(0, 2))
			NotT[victim] = true
			
		}
		case 4:
		{
		user_kill(victim)	
		}
		
		case 5:
		{
		cs_set_user_money(id, user_money, 0)
		}
	}
	victim = 0
	menu_destroy(menu)
	return PLUGIN_HANDLED
	
}
stock fm_strip_user_weapons(index)
{
	new ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "player_weaponstrip"))
	if (!pev_valid(ent))
		return 0

	dllfunc(DLLFunc_Spawn, ent)
	dllfunc(DLLFunc_Use, ent, index)
	engfunc(EngFunc_RemoveEntity, ent)
	
	fm_give_item(index, "weapon_knife")

	return 1
}


stock fm_give_item(index, const item[])
{
	if (!equal(item, "weapon_", 7) && !equal(item, "ammo_", 5) && !equal(item, "item_", 5) && !equal(item, "tf_weapon_", 10))
		return 0

	new ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString,item))
	if (!pev_valid(ent))
		return 0

	new Float:origin[3]
	pev(index, pev_origin, origin)
	set_pev(ent, pev_origin, origin)
	set_pev(ent, pev_spawnflags, pev(ent, pev_spawnflags) | SF_NORESPAWN)
	dllfunc(DLLFunc_Spawn, ent)

	new save = pev(ent, pev_solid)
	dllfunc(DLLFunc_Touch, ent, index)
	if (pev(ent, pev_solid) != save)
		return ent

	engfunc(EngFunc_RemoveEntity, ent)

	return -1
}