/*================================================================================

	[ZP] Extra Item: Nitrogen Galil
	Copyright (C) 2009 By metallicawOw #, Buenos Aires, Argentina
	
	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.
	
	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.
	
	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <http://www.gnu.org/licenses/>.
	
	In addition, as a special exception, the author gives permission to
	link the code of this program with the Half-Life Game Engine ("HL
	Engine") and Modified Game Libraries ("MODs") developed by Valve,
	L.L.C ("Valve"). You must obey the GNU General Public License in all
	respects for all of the code used other than the HL Engine and MODs
	from Valve. If you modify this file, you may extend this exception
	to your version of the file, but you are not obligated to do so. If
	you do not wish to do so, delete this exception statement from your
	version.
	
	Description: When you buy this item you will Frost Zombies While Shooting Them
	With your Nitrogen Galil.
	
	Changelog:
	v1.00: Creation of the plugin [24/11/09]
	v2.00: Fixed Some Bugs [6/12/09]
	v2.01: Added a Model to NG and Better Effects [6/12/09]
	v2.02: Added Frost Time in one Cvar [6/12/09]
	v2.03: Updated Some Things of Back Speed [20/12/09]
	
	ML:
	[ES] // metallicawOw #
	[EN] // metallicawOw #
	[NL] // crazyeffect
	[PL] // MmikiM
	
=================================================================================*/

#include <amxmodx>
#include <hamsandwich>
#include <zombieplague> 
#include <fakemeta>
#include <cstrike>
#include <engine>
#include <fun>
#include <zmvip>

//___________/ Values \___________________________________________________________________________________________
//**************************************************************************************************************************/
new gc_itemID
new bool:g_NitrogenGalil[33]
new g_Weapon[33] 
new g_FrozeN[33]
new NitrogenGalilSpr
new g_msgScreenFade
new g_iMaxPlayers
new g_HudSync
new FrostTime 
new BackSpeed1
new BackSpeed2

const UNIT_SECOND = (1<<12) 

//___________/ INIT \___________________________________________________________________________________________
//**************************************************************************************************************************/
public plugin_init()
{
	register_plugin("[ZP] Extra Item: Nitrogen Galil", "2.03", "metallicawOw #")
	
	// Cvars
	FrostTime = register_cvar("zp_ng_frost_time", "5.0") // Time to Remove the Frost Effect
	BackSpeed1 = register_cvar("zp_ng_back_spd_h", "240.0") // The Speed that Victim Recieve when is Human and g_FrozeN is false
	BackSpeed2 = register_cvar("zp_ng_back_spd_z", "230.0") // The Speed that Victim Recieve when is Zombie and g_FrozeN is false
	
	// Message IDS
	g_HudSync = CreateHudSyncObj()
	g_iMaxPlayers = get_maxplayers()
	g_msgScreenFade = get_user_msgid("ScreenFade")
	
	// ITEM NAME & COST
	gc_itemID = zv_register_extra_item("Nitrogen Galil", "Frosting zombies", 40, ZV_TEAM_HUMAN)
	
	// Events
	register_event("HLTV", "event_round_start", "a", "1=0", "2=0")
	register_event("CurWeapon", "event_CurWeapon", "b", "1=1") 
	
	// Forwards
	register_forward(FM_PlayerPreThink, "fw_PlayerPreThink")
	
	// Hams
	RegisterHam(Ham_TakeDamage, "player", "fw_TakeDamage")
	
	// Lang
	register_dictionary("nitrogen_galil.txt")
	
}

//___________/ PRECACHE \___________________________________________________________________________________________
//**************************************************************************************************************************/
public plugin_precache() 
{
	// Models
	precache_model("models/zombie_plague/v_nitrogen_galil.mdl"); 
	
	// Sounds
	precache_sound("warcraft3/impalehit.wav");
	
	// Sprites
	NitrogenGalilSpr = precache_model("sprites/shockwave.spr");
}

//___________/ Client PutinServer & Disconnect\___________________________________________________________________________________________
//**************************************************************************************************************************/
public client_putinserver(id)
{
	g_NitrogenGalil[id] = false
	g_FrozeN[id] = false 
}

public client_disconnect(id)
{
	g_NitrogenGalil[id] = false
	g_FrozeN[id] = false
}

//___________/ ZP EXTRA ITEM SELECTED \___________________________________________________________________________________________
//**************************************************************************************************************************/
public zv_extra_item_selected(player, itemid)
{
	// check if the selected item matches any of our registered ones
	if (itemid == gc_itemID) 
	{
		client_print(player, print_chat, "%L", LANG_PLAYER, "PURCHASE_NG") 
		
		g_NitrogenGalil[player] = true
		
		strip_user_weapons(player)
		
		give_item(player, "weapon_knife")
		
		give_item(player, "weapon_galil")
		
		cs_set_user_bpammo(player, CSW_GALIL, 300)  
		
		new gcName[32]
		
		get_user_name(player, gcName, charsmax(gcName))
		
		set_hudmessage(34, 138, 255, -1.0, 0.17, 1, 0.0, 5.0, 1.0, 1.0, -1)
		
		ShowSyncHudMsg(0, g_HudSync, "%L", LANG_PLAYER, "NOTICE_NG", gcName) 
	}
}

//___________/ ZP User Infected \___________________________________________________________________________________________
//**************************************************************************************************************************/
public zp_user_infected_post(infected, infector)
{
	if (g_NitrogenGalil[infected])
	{
		g_NitrogenGalil[infected] = false
	}
}

//___________/ Event Round Start \___________________________________________________________________________________________
//**************************************************************************************************************************/
public event_round_start()
{
	for (new i = 1; i <= g_iMaxPlayers; i++)
	{
		if (!is_user_connected(i))
			continue
		
		if (g_NitrogenGalil[i])
		{
			g_NitrogenGalil[i] = false
		}
		if(g_FrozeN[i])
		{
			g_FrozeN[i] = false
		}
	}
}

//___________/ TakeDamage \___________________________________________________________________________________________
//**************************************************************************************************************************/
public fw_TakeDamage(victim, inflictor, attacker, Float:damage, damage_type)
{
	if(!is_user_connected(attacker) || !is_user_connected(victim) || zp_get_user_nemesis(victim) || attacker == victim || !attacker)
	return HAM_IGNORED
	
	// For Frost Effect Ring
	static Float:originF[3]
	pev(victim, pev_origin, originF)
	
	// For Frost Effect Sound
	static originF2[3] 
	get_user_origin(victim, originF2)
		
	if (g_NitrogenGalil[attacker] && get_user_weapon(attacker) == CSW_GALIL)
	{	
		FrostEffect(victim)
		
		FrostEffectRing(originF) 
		
		FrostEffectSound(originF2)  
		
		client_print(attacker, print_center, "%L", LANG_PLAYER, "ENEMY_FROST_NG")
	}
	else
	{
		if(g_NitrogenGalil[attacker])
		{
			client_print(attacker, print_center, "%L", LANG_PLAYER, "ONLY_NG")
		}
	}
	 
	
	if(zp_get_user_nemesis(victim))
	{
		client_print(attacker, print_center, "%L", LANG_PLAYER, "NEMESIS_INMUNE_NG")
		
		return HAM_IGNORED
	}
	return PLUGIN_HANDLED;
}

//___________/ Event Cur Weapon \___________________________________________________________________________________________
//**************************************************************************************************************************/
public event_CurWeapon(id)
{
	if (!is_user_alive(id))
		return PLUGIN_CONTINUE
		
	g_Weapon[id] = read_data(2)
	
	if(zp_get_user_zombie(id) || zp_get_user_survivor(id))
		return PLUGIN_CONTINUE
		
	if(!g_NitrogenGalil[id] || g_Weapon[id] != CSW_GALIL) 
		return PLUGIN_CONTINUE
		
	entity_set_string(id, EV_SZ_viewmodel, "models/zombie_plague/v_nitrogen_galil.mdl") 
	
	return PLUGIN_CONTINUE
}

//___________/ Player Pre Think \___________________________________________________________________________________________
//**************************************************************************************************************************/
// Forward Player PreThink
public fw_PlayerPreThink(id)
{
	// Not alive
	if (!is_user_alive(id))
		return;
		
	// Set Player MaxSpeed
	if (g_FrozeN[id]) 
	{
		set_pev(id, pev_velocity, Float:{0.0,0.0,0.0}) // stop motion
		set_pev(id, pev_maxspeed, 1.0) // prevent from moving
	}
	else 
	{
		if(!zp_get_user_zombie(id))
		{
			set_pev(id, pev_maxspeed, get_pcvar_float(BackSpeed1)) // Change this in Cvar if you Want
		}
		else
		{
			set_pev(id, pev_maxspeed, get_pcvar_float(BackSpeed2)) // Change this in Cvar if you Want
		}
	}
}  
	//___________/ Effects \___________________________________________________________________________________________
//**************************************************************************************************************************/
// Frost Effect
public FrostEffect(id)
{
	// Only effect alive unfrozen zombies
	if (!is_user_alive(id) || !zp_get_user_zombie(id) || g_FrozeN[id])
	return;
	
	message_begin(MSG_ONE_UNRELIABLE, g_msgScreenFade, _, id)
	write_short(UNIT_SECOND*1) // duration
	write_short(UNIT_SECOND*1) // hold time
	write_short(0x0000) // fade type
	write_byte(0) // red
	write_byte(50) // green
	write_byte(200) // blue
	write_byte(100) // alpha
	message_end()
	
	// Light blue glow while frozen
	#if defined HANDLE_MODELS_ON_SEPARATE_ENT
	fm_set_rendering(g_ent_playermodel[id], kRenderFxGlowShell, 0, 100, 200, kRenderNormal, 25)
	#else
	fm_set_rendering(id, kRenderFxGlowShell, 0, 100, 200, kRenderNormal, 25)
	#endif
	
	g_FrozeN[id] = true
	set_task(get_pcvar_float(FrostTime), "RemoveFrost", id) // Time to Remove Frost Effect 
}

// Frost Effect Sound
public FrostEffectSound(iOrigin[3])
{
	new Entity = create_entity("info_target")
	
	new Float:flOrigin[3]
	IVecFVec(iOrigin, flOrigin)
	
	entity_set_origin(Entity, flOrigin)
	
	emit_sound(Entity, CHAN_WEAPON, "warcraft3/impalehit.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	
	remove_entity(Entity)
}

// Frost Effect Ring
FrostEffectRing(const Float:originF3[3])
{
	// Largest ring
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF3, 0)
	write_byte(TE_BEAMCYLINDER) // TE id
	engfunc(EngFunc_WriteCoord, originF3[0]) // x
	engfunc(EngFunc_WriteCoord, originF3[1]) // y
	engfunc(EngFunc_WriteCoord, originF3[2]) // z
	engfunc(EngFunc_WriteCoord, originF3[0]) // x axis
	engfunc(EngFunc_WriteCoord, originF3[1]) // y axis
	engfunc(EngFunc_WriteCoord, originF3[2]+100.0) // z axis
	write_short(NitrogenGalilSpr) // sprite
	write_byte(0) // startframe
	write_byte(0) // framerate
	write_byte(4) // life
	write_byte(60) // width
	write_byte(0) // noise
	write_byte(41) // red
	write_byte(138) // green
	write_byte(255) // blue
	write_byte(200) // brightness
	write_byte(0) // speed
	message_end()
}

// Remove Frost Effect
public RemoveFrost(id)
{
	// Not alive or not frozen anymore
	if (!is_user_alive(id) || !g_FrozeN[id])
		return;
	
	// Unfreeze
	g_FrozeN[id] = false;
	
	// Remove glow
	#if defined HANDLE_MODELS_ON_SEPARATE_ENT
	fm_set_rendering(g_ent_playermodel[id])
	#else
	fm_set_rendering(id)
	#endif
}

// Set entity's rendering type (from fakemeta_util)
stock fm_set_rendering(entity, fx = kRenderFxNone, r = 255, g = 255, b = 255, render = kRenderNormal, amount = 16)
{
	static Float:color[3]
	color[0] = float(r)
	color[1] = float(g)
	color[2] = float(b)
	
	set_pev(entity, pev_renderfx, fx)
	set_pev(entity, pev_rendercolor, color)
	set_pev(entity, pev_rendermode, render)
	set_pev(entity, pev_renderamt, float(amount))
} 
