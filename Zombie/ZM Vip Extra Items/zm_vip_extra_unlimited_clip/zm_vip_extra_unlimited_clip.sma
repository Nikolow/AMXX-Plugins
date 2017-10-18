/*================================================================================
	
	-------------------------------------------
	-*- [ZP] Extra Item: Unlimited Clip 1.0 -*-
	-------------------------------------------
	
	~~~~~~~~~~~~~~~
	- Description -
	~~~~~~~~~~~~~~~
	
	This item/upgrade gives players unlimited clip ammo for a single round.
	
================================================================================*/

#include <amxmodx>
#include <fakemeta>
#include <zombieplague>
#include <zmvip>

/*================================================================================
 [Plugin Customization]
=================================================================================*/

new const g_item_name[] = { "Unlimited Clip" } // Item name
new const g_item_descritpion[] = { "(single round)" } // Item descritpion
const g_item_cost = 10 // Price (ammo)

/*============================================================================*/

// CS Offsets
#if cellbits == 32
const OFFSET_CLIPAMMO = 51
#else
const OFFSET_CLIPAMMO = 65
#endif
const OFFSET_LINUX_WEAPONS = 4

// Max Clip for weapons
new const MAXCLIP[] = { -1, 13, -1, 10, 1, 7, -1, 30, 30, 1, 30, 20, 25, 30, 35, 25, 12, 20,
			10, 30, 100, 8, 30, 30, 20, 2, 7, 30, 30, -1, 50 }

new g_itemid_infammo, g_has_unlimited_clip[33]

public plugin_init()
{
	register_plugin("[ZP] Extra: Unlimited Clip", "1.0", "MeRcyLeZZ")
	
	g_itemid_infammo = zv_register_extra_item(g_item_name, g_item_descritpion, g_item_cost, ZV_TEAM_HUMAN)	
	
	register_event("HLTV", "event_round_start", "a", "1=0", "2=0")
	register_message(get_user_msgid("CurWeapon"), "message_cur_weapon")
	set_cvar_num("zp_vip_unlimited_ammo", 0)
}

// Player buys our upgrade, set the unlimited ammo flag
public zv_extra_item_selected(player, itemid)
{
	if (itemid == g_itemid_infammo)
		g_has_unlimited_clip[player] = true
}

// Reset flags for all players on newround
public event_round_start()
{
	for (new id; id <= 32; id++) g_has_unlimited_clip[id] = false;
}

// Unlimited clip code
public message_cur_weapon(msg_id, msg_dest, msg_entity)
{
	// Player doesn't have the unlimited clip upgrade
	if (!g_has_unlimited_clip[msg_entity])
		return;
	
	// Player not alive or not an active weapon
	if (!is_user_alive(msg_entity) || get_msg_arg_int(1) != 1)
		return;
	
	static weapon, clip
	weapon = get_msg_arg_int(2) // get weapon ID
	clip = get_msg_arg_int(3) // get weapon clip
	
	// Unlimited Clip Ammo
	if (MAXCLIP[weapon] > 2) // skip grenades
	{
		set_msg_arg_int(3, get_msg_argtype(3), MAXCLIP[weapon]) // HUD should show full clip all the time
		
		if (clip < 2) // refill when clip is nearly empty
		{
			// Get the weapon entity
			static wname[32], weapon_ent
			get_weaponname(weapon, wname, sizeof wname - 1)
			weapon_ent = fm_find_ent_by_owner(-1, wname, msg_entity)
			
			// Set max clip on weapon
			fm_set_weapon_ammo(weapon_ent, MAXCLIP[weapon])
		}
	}
}

// Find entity by its owner (from fakemeta_util)
stock fm_find_ent_by_owner(entity, const classname[], owner)
{
	while ((entity = engfunc(EngFunc_FindEntityByString, entity, "classname", classname)) && pev(entity, pev_owner) != owner) {}
	
	return entity;
}

// Set Weapon Clip Ammo
stock fm_set_weapon_ammo(entity, amount)
{
	set_pdata_int(entity, OFFSET_CLIPAMMO, amount, OFFSET_LINUX_WEAPONS);
}
