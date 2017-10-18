/*================================================================================
	
	-------------------------------------------------
	-*- [ZP] Extra Item: Anti-Infection Armor 1.0 -*-
	-------------------------------------------------
	
	~~~~~~~~~~~~~~~
	- Description -
	~~~~~~~~~~~~~~~
	
	This item gives humans some armor that offers protection
	against zombie injuries.
	
================================================================================*/

#include <amxmodx>
#include <fakemeta>
#include <zombieplague>
#include <zmvip>

/*================================================================================
 [Plugin Customization]
=================================================================================*/

new const g_item_name[] = { "Anti-Infection armor" }
new const g_item_description[] = { "Gives security from infection" }
const g_item_cost = 12

new const g_sound_buyarmor[] = { "items/tr_kevlar.wav" }
const g_armor_amount = 100
const g_armor_limit = 999

/*============================================================================*/

// Item IDs
new g_itemid_humanarmor

public plugin_precache()
{
	precache_sound(g_sound_buyarmor)
}

public plugin_init()
{
	register_plugin("[ZP] Extra: Anti-Infection Armor", "1.0", "MeRcyLeZZ")
	
	g_itemid_humanarmor = zv_register_extra_item( g_item_name, g_item_description, g_item_cost, ZP_TEAM_HUMAN)
}

// Human buys our upgrade, give him some armor
public zv_extra_item_selected(player, itemid)
{
	if (itemid == g_itemid_humanarmor)
	{
		set_pev(player, pev_armorvalue, float(min(pev(player, pev_armorvalue)+g_armor_amount, g_armor_limit)))
		engfunc(EngFunc_EmitSound, player, CHAN_BODY, g_sound_buyarmor, 1.0, ATTN_NORM, 0, PITCH_NORM)
	}
}
