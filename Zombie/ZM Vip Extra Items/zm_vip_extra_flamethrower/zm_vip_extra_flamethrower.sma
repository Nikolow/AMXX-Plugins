/*
				[ZP] Extra Item : Flamethrower
				      (Weapon For Humans)
					     by Fry!

					     
	Description :

			This is flamethrower, with this weapon is easier to burn zombies with very high damage.
			Although it costs very much, but after each kill you will gain extra ammo packs and extra frags (depends on cvars).
			
			To buy more fuel : +attack2
			
			In v0.8.6 - Changed purpose for this weapon, when it is purchased you will loose current weapons,
			and only giving flamethrower and you can't pick up other weapons.

	Cvars :
	
			zp_ft_cost "57" - How much it costs.
			zp_ft_fuelcost "10" - How much fuel will cost.
			zp_ft_fueltank "100" - How much fuel ammo will be in one clip.
			zp_ft_fuelvalue "1" - 1 fuel for 10 ammo packs.
			zp_ft_damage "25" - Damage done to zombies.
			zp_ft_xplode_dmg "100" - Explode done damage.
			zp_ft_damage_dis "120" - How far You can shoot flames.
			zp_ft_splash_dis "75" - How far fire will splash.
			zp_ft_ammo_after_kill "15" - Extra ammo packs after kill.
			zp_ft_frags_after_kill "5" - Extra frags after kill.
			zp_ft_removed_on_new_round <1|0> - Enable|Disable - remove|save dropped flamethrowers on new round.
	
	Credits :

			Cheap_Suit - For his flamethrower plugin. :)

	Changelog :

			29/10/2008 - v0.1 - First release
			31/10/2008 - v0.3 - rewrited all plugin, fixed some of my mistakes
			01/11/2008 - v0.4 - completely fixed bug due zombies could use flamethrower to kill humans.
			03/11/2008 - v0.4.1 - removed one annoying code line due players after dropcan't pick up it again.
			06/11/2008 - v0.5 - added feature that admins can buy this weapon only, added after you kill somebody you can get some ammo packs, added you can change by cvar how much frags you will gain after you kill zombie, added how much ammo packs you will lose when you kill a team mate and how much frags you will lose when kill a team mate.
			12/11/2008 - v0.7 - fixed index of bounds, and posibility that zombie sometimes still has a flamethrower, fixed that zombie can't drop flamethrower all the time, fixed friendly fire work too, so you can't kill team mate anymore, so I removed lose frags and ammo packs if kill team mate.
			22/11/2008 - v0.8 - after infection your flamethrower will be removed now and removed cstrike and fun module.
			25/02/2009 - v0.8.5 - removed admin commands, removed toggle cvar, removed buyzone and buy time too, removed unnecessary concmd, fixed zombies drop flamethrower after being infected.
			29/08/2009 - v0.8.6 -
						- Fixed : flamethrower model sometimes didn't disappeared after infection, extra 
						ammo packs and frags didn't get after each kill.
						- Changed : removed lots of stuff, removed some events, removed buying via chat, 
						removed cvar for admins only, purpose for weapon.
						- Added : cvar for fuel (buy value), cvar for dropped flamethrowers which can be saved in that place in new round, back cstrike module, hamsandwich module.
			26/12/2009 - v0.8.6 - Updated @ web (To remind myself)
*/

#include <amxmodx>
#include <cstrike>
#include <fakemeta>
#include <hamsandwich>
#include <engine>
#include <csx>
#include <xs>
#include <zombieplague>
#include <zmvip>

#define PLUGIN "[ZP] Extra Item : Flamethrower"
#define VERSION "0.8.6"
#define AUTHOR "Fry!"

const OFFSET_LINUX = 5
const OFFSET_CSTEAMS = 114
const OFFSET_CSDEATHS = 444

const PEV_ADDITIONAL_AMMO = pev_iuser1

const PRIMARY_WEAPONS_BIT_SUM = (1<<CSW_SCOUT)|(1<<CSW_XM1014)|(1<<CSW_MAC10)|(1<<CSW_AUG)|(1<<CSW_UMP45)|(1<<CSW_SG550)|(1<<CSW_GALIL)|(1<<CSW_FAMAS)|(1<<CSW_AWP)|(1<<CSW_MP5NAVY)|(1<<CSW_M249)|(1<<CSW_M3)|(1<<CSW_M4A1)|(1<<CSW_TMP)|(1<<CSW_G3SG1)|(1<<CSW_SG552)|(1<<CSW_AK47)|(1<<CSW_P90)
const SECONDARY_WEAPONS_BIT_SUM = (1<<CSW_P228)|(1<<CSW_ELITE)|(1<<CSW_FIVESEVEN)|(1<<CSW_USP)|(1<<CSW_GLOCK18)|(1<<CSW_DEAGLE)
//const ALLOWED_WEAPONS_BITSUM = (1<<CSW_KNIFE)|(1<<CSW_HEGRENADE)|(1<<CSW_FLASHBANG)|(1<<CSW_SMOKEGRENADE)|(1<<CSW_C4)

new const flamethrower_sound[] = "zombie_plague/flamethrower.wav"
new const ammopickup_sound[] = "items/ammopickup2.wav"

new const zerxplode_sprite[] = "sprites/zerogxplode.spr"
new const xplodefire_sprite[] = "sprites/explode1.spr"
new const fire_sprite[] = "sprites/xfire.spr"

new const p_zombie_knife_model[] = "models/zombie_plague/v_knife_zombie.mdl"

new const v_knife_model[] = "models/v_knife.mdl"
new const p_knife_model[] = "models/p_knife.mdl"

new const v_shield_model[] = "models/shield/v_shield_knife.mdl"
new const p_shield_model[] = "models/shield/p_shield_knife.mdl"

new const w_ft_model[] = "models/zombie_plague/w_flamethrower.mdl"
new const v_ft_model[] = "models/zombie_plague/v_flamethrower.mdl"
new const p_ft_model[] = "models/zombie_plague/p_flamethrower.mdl"

new g_item_name[] = "Flamethrower"
new g_item_discription[] = "Fire weapon"
new g_msgScoreInfo
new wpn_ft, sprite_fire, sprite_burn, sprite_xplo
new g_itemid_ft, g_ft_damage, g_ft_xplode_dmg, g_ft_cost, g_ft_fuelcost, g_ft_fueltank, 
g_ft_fuelvalue, g_ft_damage_dis, g_ft_splash_dis, g_ft_extra_ammo_packs, g_ft_extra_frags, g_ft_remove
new g_FuelTank[33], g_Activated[33], g_hasFlamethrower[33], g_FireFlamethrower[33], g_BuyFuel[33]
new Float:g_Delay[33]

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	register_cvar("zp_extra_flamethrower", VERSION,FCVAR_SERVER|FCVAR_EXTDLL|FCVAR_UNLOGGED|FCVAR_SPONLY)
	
	g_ft_cost = register_cvar("zp_ft_cost", "57")
	g_ft_fuelcost = register_cvar("zp_ft_fuelcost", "10")
	g_ft_fueltank = register_cvar("zp_ft_fueltank", "100")
	g_ft_fuelvalue = register_cvar("zp_ft_fuelvalue", "1")
	g_ft_damage = register_cvar("zp_ft_damage", "25")
	g_ft_xplode_dmg = register_cvar("zp_ft_xplode_dmg", "100")
	g_ft_damage_dis = register_cvar("zp_ft_damage_dis", "120")
	g_ft_splash_dis = register_cvar("zp_ft_splash_dis", "75")
	g_ft_extra_ammo_packs = register_cvar("zp_ft_ammo_after_kill", "15")
	g_ft_extra_frags = register_cvar("zp_ft_frags_after_kill", "5")
	g_ft_remove = register_cvar("zp_ft_removed_on_new_round", "1")
	
	g_itemid_ft = zv_register_extra_item(g_item_name, g_item_discription, get_pcvar_num(g_ft_cost), ZV_TEAM_HUMAN | ZV_TEAM_SURVIVOR)

	g_msgScoreInfo = get_user_msgid("ScoreInfo")
	
	register_event("DeathMsg", "DeathMsg", "a")
	register_event("CurWeapon", "CurWeapon", "be", "1=1")
	register_event("TextMsg", "WeaponDrop", "be", "2=#Weapon_Cannot_Be_Dropped")
	
	register_forward(FM_CmdStart, "fw_CmdStart")
	register_forward(FM_PlayerPostThink, "fw_PlayerPostThink")
	register_forward(FM_UpdateClientData, "fw_UpdateClientData_Post", 1)
	
	RegisterHam(Ham_Spawn, "player", "fw_PlayerSpawn_Post", 1)
	RegisterHam(Ham_Touch, "weaponbox", "fw_TouchWeapon")
	
	register_think("flamethrower", "think_Flamethrower")
	register_touch("flamethrower", "player", "touch_Flamethrower")
	
	wpn_ft = custom_weapon_add("weapon_flamethrower", 0, "flamethrower")
}

public plugin_precache()
{
	engfunc(EngFunc_PrecacheSound, flamethrower_sound)
	engfunc(EngFunc_PrecacheSound, ammopickup_sound)
	
	sprite_xplo = engfunc(EngFunc_PrecacheModel, zerxplode_sprite)
	sprite_fire = engfunc(EngFunc_PrecacheModel, xplodefire_sprite)
	sprite_burn = engfunc(EngFunc_PrecacheModel, fire_sprite)
	
	engfunc(EngFunc_PrecacheModel, p_zombie_knife_model)
	engfunc(EngFunc_PrecacheModel, v_knife_model)
	engfunc(EngFunc_PrecacheModel, p_knife_model)
	engfunc(EngFunc_PrecacheModel, v_shield_model)
	engfunc(EngFunc_PrecacheModel, p_shield_model)
	engfunc(EngFunc_PrecacheModel, w_ft_model)
	engfunc(EngFunc_PrecacheModel, v_ft_model)
	engfunc(EngFunc_PrecacheModel, p_ft_model)
}

public zv_extra_item_selected(id, itemid)
{
	if (itemid == g_itemid_ft)
	{
		if (g_hasFlamethrower[id])
		{
			zp_set_user_ammo_packs(id, zp_get_user_ammo_packs(id) + get_pcvar_num(g_ft_cost))
			client_print(id, print_center, "[ZP] You already own this weapon")
			
			return PLUGIN_HANDLED
		}
		
		else
		{
			fm_strip_user_weapons(id)
			fm_give_item(id, "weapon_knife")
			
			g_hasFlamethrower[id] = 1
			g_FuelTank[id] = get_pcvar_num(g_ft_fueltank)
		
			new temp[2], weaponID = get_user_weapon(id, temp[0], temp[1])
		
			if (weaponID == CSW_KNIFE) 
			{
				g_Activated[id] = true
				set_flamethrower_model(id)
			}
		
			emit_sound(id, CHAN_ITEM, ammopickup_sound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
		}
	}
	
	return PLUGIN_HANDLED
}

public zp_user_infect_attempt(id, infector, nemesis)
{
	if (!g_Activated[id])
		return PLUGIN_CONTINUE
	
	if (!zp_get_user_zombie(id))
	{
		if (g_hasFlamethrower[id])
		{
			if (WeaponDrop(id))
				set_zknife_model(id)
		}
	}

	return PLUGIN_CONTINUE
}

public fw_PlayerSpawn_Post(id)
{
	if (!is_user_alive(id))
		return HAM_IGNORED
	
	if (get_pcvar_num(g_ft_remove) == 1)
	{
		new ft = -1
	
		while ((ft = engfunc(EngFunc_FindEntityByString, ft, "classname", "flamethrower")) != 0)
		{
			engfunc(EngFunc_RemoveEntity, ft)
		}
	}
	
	return HAM_IGNORED
}

public DeathMsg() 
{ 
	new id = read_data(2)
	
	if (g_hasFlamethrower[id])
	{
		WeaponDrop(id)
	}
}

public WeaponDrop(id)
{
	if (!is_user_alive(id) || !g_Activated[id])
		return PLUGIN_CONTINUE
	
	g_hasFlamethrower[id] = 0
	drop_flamethrower(id)
	
	return PLUGIN_HANDLED
}

public CurWeapon(id)
{
	if (!is_user_alive(id) || !g_hasFlamethrower[id]) 
		return PLUGIN_CONTINUE
	
	new WeaponID = read_data(2)
	switch (WeaponID) 
	{
		case CSW_KNIFE:
		{
			set_task(0.3, "task_ActivateFlamethrower", id)
			set_flamethrower_model(id)
			set_pev(id, pev_weaponanim, 9)
		}
		default: g_Activated[id] = 0
	}
	
	return PLUGIN_CONTINUE
}

public task_ActivateFlamethrower(id) 
{
	if (!is_user_alive(id))
		return PLUGIN_CONTINUE
	
	new temp[2], weaponID = get_user_weapon(id, temp[0], temp[1])
	
	if (weaponID == CSW_KNIFE) 
		g_Activated[id] = 1
		
	return PLUGIN_CONTINUE
}

public fw_TouchWeapon(weapon, id)
{
	if (!pev_valid(weapon) || !is_user_alive(id) || zp_get_user_zombie(id))
		return HAM_IGNORED
		
	if (g_hasFlamethrower[id] || has_shield(id))
		return HAM_SUPERCEDE
		
	static plrClip, plrAmmo, plrWeapon
	plrWeapon = get_user_weapon(id, plrClip, plrAmmo)

	if ((1<<plrWeapon) == PRIMARY_WEAPONS_BIT_SUM || g_hasFlamethrower[id])
		return HAM_SUPERCEDE
	
	return HAM_IGNORED
}
	
public touch_Flamethrower(ent, id)
{
	new owner = pev(ent, pev_owner)
	
	if (pev_valid(owner) || !is_user_alive(id) || zp_get_user_zombie(id))
		return PLUGIN_CONTINUE
	
	g_hasFlamethrower[id] = true
	g_FuelTank[id] = pev(ent, pev_iuser4)
	show_fuel_percentage(id)
	emit_sound(id, CHAN_ITEM, ammopickup_sound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	
	new temp[2], weaponID = get_user_weapon(id, temp[0], temp[1])
	
	if (weaponID == CSW_KNIFE)
	{
		g_Activated[id] = true
		set_flamethrower_model(id)
		set_pev(id, pev_weaponanim, 9)
	}
		
	if ((1<<weaponID) == PRIMARY_WEAPONS_BIT_SUM || g_hasFlamethrower[id])
	{
		if (weaponID != CSW_KNIFE)
		{
			if (drop_flamethrower(id))
			{
				pev_valid(ent)
				engfunc(EngFunc_RemoveEntity, ent)
			}
		}
	}
	
	engfunc(EngFunc_RemoveEntity, ent)
	
	return PLUGIN_CONTINUE
}

public fw_UpdateClientData_Post(id, sendweapons, cd_handle) 
{
	if (!g_hasFlamethrower[id] || !g_Activated[id])
		return FMRES_IGNORED
		
	set_cd(cd_handle, CD_ID, 0)
	return FMRES_HANDLED
}

public fw_CmdStart(id, uc_handle, seed) 
{
	if (!g_hasFlamethrower[id] || !g_Activated[id])
		return FMRES_IGNORED
	
	new buttons = get_uc(uc_handle, UC_Buttons)
	if (buttons & IN_ATTACK)
	{
		g_FireFlamethrower[id] = 1
	
		buttons &= ~IN_ATTACK
		set_uc(uc_handle, UC_Buttons, buttons)
	} 
	
	else 
		g_FireFlamethrower[id] = 0
		
	if (buttons & IN_ATTACK2) 
	{
		g_BuyFuel[id] = 1
		
		buttons &= ~IN_ATTACK2
		set_uc(uc_handle, UC_Buttons, buttons)
	} 
	
	else 
		g_BuyFuel[id] = 0
		
	return FMRES_HANDLED
}

public fw_PlayerPostThink(id)
{
	if (!is_user_alive(id) || zp_get_user_zombie(id))
		return FMRES_IGNORED
			
	if (!g_hasFlamethrower[id] || !g_Activated[id])
		return FMRES_IGNORED
	
	if (pev(id, pev_waterlevel) > 1)
		return FMRES_IGNORED

	if (has_shield(id))
	{
		WeaponDrop(id)
		return FMRES_IGNORED
	}
		
	if (g_BuyFuel[id])
	{
		if ((g_Delay[id] + 0.2) < get_gametime())
		{
			buy_fuel(id)
			g_Delay[id] = get_gametime()
		}
	}
	
	if (g_FireFlamethrower[id])
	{
		if (g_FuelTank[id] > 0)
		{
			if ((g_Delay[id] + 0.2) < get_gametime())
			{
				g_FuelTank[id] -= 1
				g_Delay[id] = get_gametime()
			}
			
			new Float:fOrigin[3], Float:fVelocity[3]
			entity_get_vector(id,EV_VEC_origin, fOrigin)
			VelocityByAim(id, 35, fVelocity)
		
			new Float:fTemp[3], iFireOrigin[3]
			xs_vec_add(fOrigin, fVelocity, fTemp)
			FVecIVec(fTemp, iFireOrigin)
			
			new Float:fFireVelocity[3], iFireVelocity[3]
			VelocityByAim(id, get_pcvar_num(g_ft_damage_dis), fFireVelocity)
			FVecIVec(fFireVelocity, iFireVelocity)
			
			flame_stuff(id, iFireOrigin, iFireVelocity)
			
			new doDamage
			switch (get_cvar_num("mp_friendlyfire"))
			{
				case 0: doDamage = 0
				case 1: doDamage = 0
			}
			
			show_fuel_percentage(id)
			direct_damage(id, doDamage)
			indirect_damage(id, doDamage)
			custom_weapon_shot(wpn_ft, id)
		} 
		
		else
			client_print(id, print_center, "Out of Fuel")
	}
	
	return FMRES_IGNORED
}

public think_Flamethrower(ent)
{
	if (is_valid_ent(ent) && entity_get_float(ent, EV_FL_health) < 950.0) 
	{
		new Float:fOrigin[3], iOrigin[3]
		entity_get_vector(ent, EV_VEC_origin, fOrigin)
		FVecIVec(fOrigin, iOrigin)
	
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
		write_byte(99)
		write_short(ent)
		message_end()
	
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
		write_byte(3)
		write_coord(iOrigin[0])
		write_coord(iOrigin[1])
		write_coord(iOrigin[2])
		write_short(sprite_xplo)
		write_byte(50)
		write_byte(15)
		write_byte(0)
		message_end()
		
		RadiusDamage(fOrigin, get_pcvar_num(g_ft_xplode_dmg), entity_get_int(ent, EV_INT_iuser4))
		remove_entity(ent)
	}
	
	if (is_valid_ent(ent)) 
		entity_set_float(ent, EV_FL_nextthink, halflife_time() + 0.01)
}

public flame_stuff(id, origin[3], velocity[3])
{
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(120)
	write_coord(origin[0])
	write_coord(origin[1])
	write_coord(origin[2])
	write_coord(velocity[0])
	write_coord(velocity[1])
	write_coord(velocity[2] + 5)
	write_short(sprite_fire)
	write_byte(1)
	write_byte(10)
	write_byte(1)
	write_byte(5)
	message_end()
	
	emit_sound(id, CHAN_WEAPON, flamethrower_sound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
}

public direct_damage(id, doDamage)
{
	new ent, body
	get_user_aiming(id, ent, body, get_pcvar_num(g_ft_damage_dis) + 500)
	
	if (ent > 0 && is_user_alive(ent))
	{
		if (!doDamage)
		{
			if (zp_get_user_zombie(id) != zp_get_user_zombie(ent)) 
			{
				damage_user(id, ent, get_pcvar_num(g_ft_damage))
				custom_weapon_dmg(wpn_ft, id, ent, get_pcvar_num(g_ft_damage))
			}
		}
		else
		{
			damage_user(id, ent, get_pcvar_num(g_ft_damage))	
			custom_weapon_dmg(wpn_ft, id, ent, get_pcvar_num(g_ft_damage))
		}
	}
}

public indirect_damage(id, doDamage)
{
	new Players[32], iNum
	get_players(Players, iNum, "a")
	for (new i = 0; i < iNum; ++i) if(id != Players[i])
	{
		new target = Players[i]
	
		new Float:fOrigin[3], Float:fOrigin2[3]
		entity_get_vector(id,EV_VEC_origin, fOrigin)
		entity_get_vector(target, EV_VEC_origin, fOrigin2)
			
		new temp[3], Float:fAim[3]
		get_user_origin(id, temp, 3)
		IVecFVec(temp, fAim)
		
		new Float:fDistance = get_pcvar_num(g_ft_damage_dis) + 500.0
		if (get_distance_f(fOrigin, fOrigin2) > fDistance)
			continue 
		
		new iDistance = get_distance_to_line(fOrigin, fOrigin2, fAim)
		if (iDistance > get_pcvar_num(g_ft_splash_dis) || iDistance < 0 || !fm_is_ent_visible(id, target))
			continue 
			
		if (!doDamage)
		{
			if (zp_get_user_zombie(id) != zp_get_user_zombie(target))
			{
				damage_user(id, target, get_pcvar_num(g_ft_damage))
				custom_weapon_dmg(wpn_ft, id, target, get_pcvar_num(g_ft_damage))
			}
		}
		else 
		{
			damage_user(id, target, get_pcvar_num(g_ft_damage) / 2)
			custom_weapon_dmg(wpn_ft, id, target, get_pcvar_num(g_ft_damage) / 2)
		}
	}
}

public buy_fuel(id)
{
	if (g_FuelTank[id] >= get_pcvar_num(g_ft_fueltank))
		return PLUGIN_CONTINUE
				
	new user_packs = zp_get_user_ammo_packs(id)
	new cost_packs = get_pcvar_num(g_ft_fuelcost)
	if (user_packs >= cost_packs)
	{
		g_FuelTank[id] += get_pcvar_num(g_ft_fuelvalue)
		show_fuel_percentage(id)
		zp_set_user_ammo_packs(id, user_packs - cost_packs)

		return PLUGIN_CONTINUE
	}
	
	return PLUGIN_CONTINUE
}

public drop_flamethrower(id)
{
	new Float:fVelocity[3], Float:fOrigin[3]
	entity_get_vector(id, EV_VEC_origin, fOrigin)
	VelocityByAim(id, 34, fVelocity)
	
	fOrigin[0] += fVelocity[0]
	fOrigin[1] += fVelocity[1]

	VelocityByAim(id, 300, fVelocity)
	
	new ent = create_entity("info_target")
	if(is_valid_ent(ent))
	{
		entity_set_string(ent, EV_SZ_classname, "flamethrower")
		entity_set_model(ent, w_ft_model)
		entity_set_int(ent, EV_INT_movetype, MOVETYPE_TOSS)
		entity_set_int(ent, EV_INT_solid, SOLID_TRIGGER)
		entity_set_vector(ent, EV_VEC_origin, fOrigin)
		entity_set_vector(ent, EV_VEC_velocity, fVelocity)
		entity_set_int(ent, EV_INT_iuser4, g_FuelTank[id])
		entity_set_float(ent, EV_FL_takedamage, 1.0)
		entity_set_float(ent, EV_FL_health, 1000.0)
		entity_set_size(ent, Float:{-2.5, -2.5, -1.5}, Float:{2.5, 2.5, 1.5})
		entity_set_float(ent, EV_FL_nextthink, halflife_time() + 0.01)
	}
	
	g_FuelTank[id] = 0
	g_Activated[id] = 0
	g_hasFlamethrower[id] = 0
	
	if (has_shield(id))
		set_shield_model(id)
	else 
		set_knife_model(id)
		
	return PLUGIN_CONTINUE
}

public show_fuel_percentage(id)
{
	set_hudmessage(255, 170, 0, 0.91, 0.95, _, _, 1.0, _, _, 4)
	show_hudmessage(id, "Fuel Tank: %d%%", get_percent(g_FuelTank[id], get_pcvar_num(g_ft_fueltank)))
}

public set_flamethrower_model(id)
{
	set_pev(id, pev_viewmodel2, v_ft_model)
	set_pev(id, pev_weaponmodel2, p_ft_model)
}

public set_zknife_model(id)
{
	set_pev(id, pev_weaponmodel2, p_zombie_knife_model)
}

public set_knife_model(id)
{
	set_pev(id, pev_viewmodel2, v_knife_model)
	set_pev(id, pev_weaponmodel2, p_knife_model)	
}

public set_shield_model(id)
{
	set_pev(id, pev_weaponmodel2, v_shield_model)
	set_pev(id, pev_weaponmodel2, p_shield_model)
}

stock damage_user(id, victim, damage)
{
	new iHealth = get_user_health(victim)
	if (iHealth > damage) 
		fakedamage(victim, "weapon_flamethrower", float(damage), DMG_BURN)
	else
	{
		user_silentkill(victim)
		make_deathmsg(id, victim, 0, "flamethrower")
		
		new iOrigin[3]
		get_user_origin(victim, iOrigin, 0)
		
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
		write_byte(17)
		write_coord(iOrigin[0])
		write_coord(iOrigin[1])
		write_coord(iOrigin[2] + 10)
		write_short(sprite_burn)
		write_byte(30)
		write_byte(40)
		message_end()
			
		if (fm_cs_get_user_team(id) != fm_cs_get_user_team(victim))
		{
			fm_set_user_frags(id, get_user_frags(id) + get_pcvar_num(g_ft_extra_frags))
			zp_set_user_ammo_packs(id, zp_get_user_ammo_packs(id) + get_pcvar_num(g_ft_extra_ammo_packs))
		}
		
		message_begin(MSG_ALL, g_msgScoreInfo) 
		write_byte(id) 
		write_short(get_user_frags(id)) 
		write_short(get_user_deaths(id)) 
		write_short(0) 
		write_short(get_user_team(id)) 
		message_end() 
		
		message_begin(MSG_ALL, g_msgScoreInfo) 
		write_byte(victim) 
		write_short(get_user_frags(victim))
		write_short(get_user_deaths(victim))
		write_short(0)
		write_short(get_user_team(victim))
		message_end()
	}
}

stock get_percent(value, tvalue)       
	return floatround(floatmul(float(value) / float(tvalue) , 100.0))  

stock get_distance_to_line(Float:pos_start[3], Float:pos_end[3], Float:pos_object[3])  
{  
	new Float:vec_start_end[3], Float:vec_start_object[3], Float:vec_end_object[3], Float:vec_end_start[3]
	xs_vec_sub(pos_end, pos_start, vec_start_end) 		// vector from start to end 
	xs_vec_sub(pos_object, pos_start, vec_start_object) 	// vector from end to object 
	xs_vec_sub(pos_start, pos_end, vec_end_start) 		// vector from end to start 
	xs_vec_sub(pos_end, pos_object, vec_end_object) 		// vector object to end 
	
	new Float:len_start_object = getVecLen(vec_start_object) 
	new Float:angle_start = floatacos(xs_vec_dot(vec_start_end, vec_start_object) / (getVecLen(vec_start_end) * len_start_object), degrees)  
	new Float:angle_end = floatacos(xs_vec_dot(vec_end_start, vec_end_object) / (getVecLen(vec_end_start) * getVecLen(vec_end_object)), degrees)  

	if(angle_start <= 90.0 && angle_end <= 90.0) 
		return floatround(len_start_object * floatsin(angle_start, degrees)) 
	return -1  
}

stock Float:getVecLen(Float:Vec[3])
{ 
	new Float:VecNull[3] = {0.0, 0.0, 0.0}
	new Float:len = get_distance_f(Vec, VecNull)
	return len
}

stock bool:fm_is_ent_visible(index, entity) 
{
	new Float:origin[3], Float:view_ofs[3], Float:eyespos[3]
	pev(index, pev_origin, origin)
	pev(index, pev_view_ofs, view_ofs)
	xs_vec_add(origin, view_ofs, eyespos)

	new Float:entpos[3]
	pev(entity, pev_origin, entpos)
	engfunc(EngFunc_TraceLine, eyespos, entpos, 0, index)

	switch(pev(entity, pev_solid)) 
	{
		case SOLID_BBOX..SOLID_BSP: return global_get(glb_trace_ent) == entity
	}
	
	new Float:fraction
	global_get(glb_trace_fraction, fraction)
	if(fraction == 1.0)
		return true
		
	return false
}

stock bool:has_shield(id)
{
	new modelName[32]
	entity_get_string(id, EV_SZ_viewmodel, modelName, 31)

	if (containi(modelName, "v_shield_") != -1)
		return true
		
	return false
}

stock fm_cs_get_user_team(id)
{
	return get_pdata_int(id, OFFSET_CSTEAMS, OFFSET_LINUX)
}

stock fm_cs_set_user_deaths(id, value)
{
	set_pdata_int(id, OFFSET_CSDEATHS, value, OFFSET_LINUX)
}

stock fm_set_user_frags(index, frags) 
{
	set_pev(index, pev_frags, float(frags))

	return 1
}

stock fm_strip_user_weapons(index) 
{
	new ent = fm_create_entity("player_weaponstrip")
	if (!pev_valid(ent))
		return 0

	dllfunc(DLLFunc_Spawn, ent)
	dllfunc(DLLFunc_Use, ent, index)
	engfunc(EngFunc_RemoveEntity, ent)

	return 1
}

stock drop_weapons(id, dropwhat)
{
	static weapons[32], num, i, weaponid
	num = 0
	get_user_weapons(id, weapons, num)
	
	for (i = 0; i < num; i++)
	{
		weaponid = weapons[i]
		
		if ((dropwhat == 1 && ((1<<weaponid) & PRIMARY_WEAPONS_BIT_SUM)) || (dropwhat == 2 && ((1<<weaponid) & SECONDARY_WEAPONS_BIT_SUM)))
		{
			static wname[32], weapon_ent
			get_weaponname(weaponid, wname, charsmax(wname))
			weapon_ent = fm_find_ent_by_owner(-1, wname, id)
			
			set_pev(weapon_ent, PEV_ADDITIONAL_AMMO, cs_get_user_bpammo(id, weaponid))
			
			engclient_cmd(id, "drop", wname)
			cs_set_user_bpammo(id, weaponid, 0)
		}
	}
}

stock fm_find_ent_by_owner(index, const classname[], owner, jghgtype = 0) 
{
	new strtype[11] = "classname", ent = index
	switch (jghgtype) {
		case 1: strtype = "target"
		case 2: strtype = "targetname"
	}

	while ((ent = engfunc(EngFunc_FindEntityByString, ent, strtype, classname)) && pev(ent, pev_owner) != owner) {}

	return ent
}

stock fm_create_entity(const classname[])
	return engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, classname))

stock fm_give_item(index, const item[]) 
{
	if (!equal(item, "weapon_", 7) && !equal(item, "ammo_", 5) && !equal(item, "item_", 5) && !equal(item, "tf_weapon_", 10))
		return 0

	new ent = fm_create_entity(item)
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
