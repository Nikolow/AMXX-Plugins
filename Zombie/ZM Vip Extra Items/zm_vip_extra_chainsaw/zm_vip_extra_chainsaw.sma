/*================================================================================

	[ZP] Extra Item: Chainsaw
	Copyright (C) 2009 by meTaLiCroSS, Viña del Mar, Chile
	
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
	
	** Credits:
		
	- B!gBud: Some code of his Jetpack + Bazooka
	- jtp10181: For his AMX Ultimate Gore plugin and good blood effects

=================================================================================*/

#include <amxmodx>
#include <fakemeta>
#include <engine>
#include <hamsandwich>
#include <zombieplague>
#include <zmvip>

/*================================================================================
 [Customization]
=================================================================================*/

// Item Cost
const chainsaw_ap_cost = 30 // Ammo packs Cost

// Custom Chainsaw Models
new const chainsaw_viewmodel[] = "models/chainsaw/v_chainsaw.mdl"	// View Weapon Model (v_)
new const chainsaw_playermodel[] = "models/chainsaw/p_chainsaw.mdl"	// Player Weapon Model (p_)
new const chainsaw_worldmodel[] = "models/chainsaw/w_chainsaw.mdl"	// World Weapon Model (w_)

// Custom Chainsaw Sounds
new const chainsaw_sounds[][] =
{
	"chainsaw/chainsaw_deploy.wav",		// Deploy Sound (knife_deploy1.wav)
	"chainsaw/chainsaw_hit1.wav",		// Hit 1 (knife_hit1.wav)
	"chainsaw/chainsaw_hit2.wav",		// Hit 2 (knife_hit2.wav)
	"chainsaw/chainsaw_hit1.wav",		// Hit 3 (knife_hit3.wav)
	"chainsaw/chainsaw_hit2.wav",		// Hit 4 (knife_hit4.wav)
	"chainsaw/chainsaw_hitwall.wav",	// Hit Wall (knife_hitwall1.wav)
	"chainsaw/chainsaw_miss.wav",		// Slash 1 (knife_slash1.wav)
	"chainsaw/chainsaw_miss.wav",		// Slash 2 (knife_slash2.wav)
	"chainsaw/chainsaw_stab.wav"		// Stab (knife_stab1.wav)
}

// Dropped Chainsaw Size
new Float:chainsaw_mins[3] = { -2.0, -2.0, -2.0 }
new Float:chainsaw_maxs[3] = { 2.0, 2.0, 2.0 }


/*================================================================================
 Customization ends here! Yes, that's it. Editing anything beyond
 here is not officially supported. Proceed at your own risk...
=================================================================================*/

// Variables
new g_iItemID, g_msgCurWeapon, g_msgSayText

// Arrays
new g_iHasChainsaw[33], g_iCurrentWeapon[33]

// Cvar Pointers
new cvar_enable, cvar_dmgmult, cvar_oneround, cvar_sounds, cvar_dmggore, cvar_dropflags,
cvar_pattack_rate, cvar_sattack_rate, cvar_pattack_recoil, cvar_sattack_recoil, cvar_body_xplode

// Flags
const DROPFLAG_NORMAL = 		(1<<0) // "a", with "drop" clcmd (pressing G by default)
const DROPFLAG_INDEATH =	(1<<1) // "b", death victim
const DROPFLAG_INFECTED =	(1<<2) // "c", user infected
const DROPFLAG_SURVHUMAN =	(1<<3) // "d", user become survivor

// Offsets
const m_pPlayer = 		41
const m_flNextPrimaryAttack = 	46
const m_flNextSecondaryAttack =	47
const m_flTimeWeaponIdle = 	48

// Old Knife Sounds (DON'T CHANGE)
new const oldknife_sounds[][] =
{
	"weapons/knife_deploy1.wav",	// Deploy Sound
	"weapons/knife_hit1.wav",	// Hit 1
	"weapons/knife_hit2.wav",	// Hit 2
	"weapons/knife_hit3.wav",	// Hit 3
	"weapons/knife_hit4.wav",	// Hit 4
	"weapons/knife_hitwall1.wav",	// Hit Wall
	"weapons/knife_slash1.wav",	// Slash 1
	"weapons/knife_slash2.wav",	// Slash 2
	"weapons/knife_stab.wav"	// Stab
}

// Plug info.
#define PLUG_VERSION "0.9"
#define PLUG_AUTH "meTaLiCroSS"

/*================================================================================
 [Init and Precache]
=================================================================================*/

public plugin_init()
{
	// Plugin Register
	register_plugin("[ZP] Extra Item: Chainsaw", PLUG_VERSION, PLUG_AUTH)
	
	// Events	
	register_event("HLTV", "event_RoundStart", "a", "1=0", "2=0")
	register_event("CurWeapon", "event_CurWeapon", "b", "1=1")
	
	// Cvars
	cvar_enable = register_cvar("zp_chainsaw_enable", "1")
	cvar_sounds = register_cvar("zp_chainsaw_custom_sounds", "1")
	cvar_dmgmult = register_cvar("zp_chainsaw_damage_mult", "8.4")
	cvar_dmggore = register_cvar("zp_chainsaw_gore_in_damage", "1")
	cvar_oneround = register_cvar("zp_chainsaw_oneround", "0")
	cvar_dropflags = register_cvar("zp_chainsaw_drop_flags", "abcd")
	cvar_body_xplode = register_cvar("zp_chainsaw_victim_explode", "1")
	cvar_pattack_rate = register_cvar("zp_chainsaw_attack1_rate", "0.6")
	cvar_sattack_rate = register_cvar("zp_chainsaw_attack2_rate", "1.2")
	cvar_pattack_recoil = register_cvar("zp_chainsaw_attack1_recoil", "-5.6")
	cvar_sattack_recoil = register_cvar("zp_chainsaw_attack2_recoil", "-8.0")
	
	new szCvar[30]
	formatex(szCvar, charsmax(szCvar), "v%s by %s", PLUG_VERSION, PLUG_AUTH)
	register_cvar("zp_extra_chainsaw", szCvar, FCVAR_SERVER|FCVAR_SPONLY)
	
	// Fakemeta Forwards
	register_forward(FM_EmitSound, "fw_EmitSound")
	
	// Engine Forwards
	register_touch("cs_chainsaw", "player", "fw_Chainsaw_Touch")
	
	// Ham Forwards
	RegisterHam(Ham_Spawn, "player", "fw_PlayerSpawn_Post", 1)
	RegisterHam(Ham_Killed, "player", "fw_PlayerKilled")
	RegisterHam(Ham_TakeDamage, "player", "fw_TakeDamage")
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_knife", "fw_Knife_PrimaryAttack_Post", 1)
	RegisterHam(Ham_Weapon_SecondaryAttack, "weapon_knife", "fw_Knife_SecondaryAttack_Post", 1)
	
	// Variables
	g_iItemID = zv_register_extra_item("Chainsaw", "Chansaw for cutting zombies", chainsaw_ap_cost, ZV_TEAM_HUMAN)
	
	// Message ID's vars
	g_msgSayText = get_user_msgid("SayText")
	g_msgCurWeapon = get_user_msgid("CurWeapon")
	
	// Client Commands
	register_clcmd("drop", "clcmd_drop")
}

public plugin_precache()
{
	// Models
	precache_model(chainsaw_viewmodel)
	precache_model(chainsaw_playermodel)
	precache_model(chainsaw_worldmodel)
	
	// Sounds
	for(new i = 0; i < sizeof chainsaw_sounds; i++)
		precache_sound(chainsaw_sounds[i])
		
	precache_sound("items/gunpickup2.wav")
}

/*================================================================================
 [Main Events]
=================================================================================*/

public event_RoundStart()
{
	// Remove chainsaws (entities)
	remove_entity_name("cs_chainsaw")
}

public event_CurWeapon(id)
{
	// Not alive...
	if(!is_user_alive(id))
		return PLUGIN_CONTINUE
		
	// Updating weapon array
	g_iCurrentWeapon[id] = read_data(2)
	
	// Check
	if(zp_get_user_zombie(id) || zp_get_user_survivor(id))
		return PLUGIN_CONTINUE
		
	// Has chainsaw and weapon is Knife
	if(!g_iHasChainsaw[id] || g_iCurrentWeapon[id] != CSW_KNIFE) 
		return PLUGIN_CONTINUE
		
	entity_set_string(id, EV_SZ_viewmodel, chainsaw_viewmodel)
	entity_set_string(id, EV_SZ_weaponmodel, chainsaw_playermodel)
		
	return PLUGIN_CONTINUE
}

/*================================================================================
 [Main Functions]
=================================================================================*/

public clcmd_drop(id)
{
	// Has Chainsaw		Weapon is Knife
	if(g_iHasChainsaw[id] && g_iCurrentWeapon[id] == CSW_KNIFE)
	{
		if(check_drop_flag(DROPFLAG_NORMAL))
		{
			drop_chainsaw(id)
			return PLUGIN_HANDLED
		}
	}
	
	return PLUGIN_CONTINUE
}

public drop_chainsaw(id) 
{
	// Get Aim and Origin
	static Float:flAim[3], Float:flOrigin[3]
	VelocityByAim(id, 64, flAim)
	entity_get_vector(id, EV_VEC_origin, flOrigin)
	
	// Changing Origin coords
	flOrigin[0] += flAim[0]
	flOrigin[1] += flAim[1]
	
	// Creating the Entity
	new iEnt = create_entity("info_target")
	
	// Classname
	entity_set_string(iEnt, EV_SZ_classname, "cs_chainsaw")
	
	// Origin
	entity_set_origin(iEnt, flOrigin)
	
	// Models
	entity_set_model(iEnt, chainsaw_worldmodel)
	
	// Size
	set_size(iEnt, chainsaw_mins, chainsaw_maxs)
	entity_set_vector(iEnt, EV_VEC_mins, chainsaw_mins)
	entity_set_vector(iEnt, EV_VEC_maxs, chainsaw_maxs)
	
	// Solid Type
	entity_set_int(iEnt, EV_INT_solid, SOLID_TRIGGER)
	
	// Movetype
	entity_set_int(iEnt, EV_INT_movetype, MOVETYPE_TOSS)
	
	// Var's
	g_iHasChainsaw[id] = false
	
	// Model bugfix
	reset_user_knife(id)
}

public reset_user_knife(id)
{
	// Execute weapon Deploy
	if(user_has_weapon(id, CSW_KNIFE))
		ExecuteHamB(Ham_Item_Deploy, find_ent_by_owner(-1, "weapon_knife", id))
		
	// Updating Model
	engclient_cmd(id, "weapon_knife")
	emessage_begin(MSG_ONE, g_msgCurWeapon, _, id)
	ewrite_byte(1) // active
	ewrite_byte(CSW_KNIFE) // weapon
	ewrite_byte(-1) // clip
	emessage_end()
}

/*================================================================================
 [ZombiePlague Forwards]
=================================================================================*/

public zv_extra_item_selected(id, itemid)
{
	if (itemid == g_iItemID)
	{
		// Check cvar
		if(get_pcvar_num(cvar_enable))
		{
			// Already has a Chainsaw
			if (g_iHasChainsaw[id])
			{
				zp_set_user_ammo_packs(id, zp_get_user_ammo_packs(id) + chainsaw_ap_cost)
				client_printcolor(id, "/g[ZP]/y You already have a /gChainsaw")
			}
			else 
			{
				// Boolean
				g_iHasChainsaw[id] = true
				
				// Emiting Sound
				emit_sound(id, CHAN_WEAPON, "items/gunpickup2.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
				
				// Client Print
				client_printcolor(id, "/g[ZP]/y You now have a /gChainsaw")
				
				// Change weapon to Knife
				reset_user_knife(id)
			}
		}
		// Isn't enabled...
		else
		{
			zp_set_user_ammo_packs(id, zp_get_user_ammo_packs(id) + chainsaw_ap_cost)
			client_printcolor(id, "/g[ZP]/y Chainsaw item has been disabled. /gContact Admin")
		}
	}
}

public zp_user_infected_pre(id, infector)
{
	// Drop in infection
	if (g_iHasChainsaw[id])
	{
		if(check_drop_flag(DROPFLAG_INFECTED))
			drop_chainsaw(id)
		else
		{
			g_iHasChainsaw[id] = false
			reset_user_knife(id)
		}
	}
}

public zp_user_humanized_post(id)
{
	// Is survivor
	if(zp_get_user_survivor(id) && g_iHasChainsaw[id])
	{
		if(check_drop_flag(DROPFLAG_SURVHUMAN))
			drop_chainsaw(id)
		else
		{
			g_iHasChainsaw[id] = false
			reset_user_knife(id)
		}
	}
}

/*================================================================================
 [Main Forwards]
=================================================================================*/

public client_putinserver(id)
{
	g_iHasChainsaw[id] = false
}

public client_disconnect(id)
{
	g_iHasChainsaw[id] = false
}
	
public fw_PlayerSpawn_Post(id)
{
	// Check Oneround Cvar and Strip all the Chainsaws
	if(get_pcvar_num(cvar_oneround) || !get_pcvar_num(cvar_enable))
	{
		// Has Chainsaw
		if(g_iHasChainsaw[id])
		{
			// Var's
			g_iHasChainsaw[id] = false

			// Update Knife
			reset_user_knife(id)
		}
	}
}

public fw_TakeDamage(victim, inflictor, attacker, Float:damage, damage_bits)
{	
	// Check
	if(victim == attacker || !attacker)
		return HAM_IGNORED
		
	// Attacker is not a Player
	if(!is_user_connected(attacker))
		return HAM_IGNORED
		
	// Has chainsaw and Weapon is knife
	if(g_iHasChainsaw[attacker] && g_iCurrentWeapon[attacker] == CSW_KNIFE)
	{
		// Gore
		if(get_pcvar_num(cvar_dmggore))
			a_lot_of_blood(victim)
			
		// Damage mult.
		SetHamParamFloat(4, damage * get_pcvar_float(cvar_dmgmult))	

	}

	return HAM_IGNORED
}

public fw_PlayerKilled(victim, attacker, shouldgib)
{
	// Check
	if(victim == attacker || !attacker)
		return HAM_IGNORED
		
	// Attacker is not a Player
	if(!is_user_connected(attacker))
		return HAM_IGNORED
		
	// Attacker Has a Chainsaw
	if(g_iHasChainsaw[attacker] && g_iCurrentWeapon[attacker] == CSW_KNIFE && !zp_get_user_nemesis(victim) && get_pcvar_num(cvar_body_xplode))
		SetHamParamInteger(3, 2) // Body Explodes
	
	// Victim Has a Chainsaw
	if(g_iHasChainsaw[victim])
	{
		if(check_drop_flag(DROPFLAG_INDEATH))
			drop_chainsaw(victim)
		else
		{
			g_iHasChainsaw[victim] = false
			reset_user_knife(victim)
		}
	}
	
	return HAM_IGNORED
}

public fw_Chainsaw_Touch(saw, player)
{
	// Entities are not valid
	if(!is_valid_ent(saw) || !is_valid_ent(player))
		return PLUGIN_CONTINUE
		
	// Is a valid player?
	if(!is_user_connected(player))
		return PLUGIN_CONTINUE
		
	// Alive, Zombie or Survivor
	if(!is_user_alive(player) || zp_get_user_zombie(player) || zp_get_user_survivor(player) || g_iHasChainsaw[player])
		return PLUGIN_CONTINUE
		
	// Var's
	g_iHasChainsaw[player] = true
	
	// Emiting Sound
	emit_sound(player, CHAN_WEAPON, "items/gunpickup2.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
	
	// Knife Deploy
	reset_user_knife(player)
	
	// Remove dropped chainsaw
	remove_entity(saw)
		
	return PLUGIN_CONTINUE
}

public fw_EmitSound(id, channel, const sound[])
{
	// Non-player entity
	if(!is_user_connected(id))
		return FMRES_IGNORED
		
	// Not Alive / Zombie / Doesn't have a Chainsaw
	if(!is_user_alive(id) || zp_get_user_zombie(id) || zp_get_user_survivor(id) || !g_iHasChainsaw[id] || !get_pcvar_num(cvar_sounds))
		return FMRES_IGNORED
		
	// Check sound
	for(new i = 0; i < sizeof chainsaw_sounds; i++)
	{
		if(equal(sound, oldknife_sounds[i]))
		{
			// Emit New sound and Stop old Sound
			emit_sound(id, channel, chainsaw_sounds[i], 1.0, ATTN_NORM, 0, PITCH_NORM)
			return FMRES_SUPERCEDE
		}
	}
			
	return FMRES_IGNORED
}

public fw_Knife_PrimaryAttack_Post(knife)
{	
	// Get knife owner
	static id
	id = get_pdata_cbase(knife, m_pPlayer, 4)
	
	// has a Chainsaw
	if(is_user_connected(id) && g_iHasChainsaw[id])
	{
		// Get new fire rate
		static Float:flRate
		flRate = get_pcvar_float(cvar_pattack_rate)
		
		// Set new rates
		set_pdata_float(knife, m_flNextPrimaryAttack, flRate, 4)
		set_pdata_float(knife, m_flNextSecondaryAttack, flRate, 4)
		set_pdata_float(knife, m_flTimeWeaponIdle, flRate, 4)
		
		// Get new recoil
		static Float:flPunchAngle[3]
		flPunchAngle[0] = get_pcvar_float(cvar_pattack_recoil)
		
		// Punch their angles
		entity_set_vector(id, EV_VEC_punchangle, flPunchAngle)
		
	}
	
	return HAM_IGNORED
}

public fw_Knife_SecondaryAttack_Post(knife)
{	
	// Get knife owner
	static id
	id = get_pdata_cbase(knife, m_pPlayer, 4)
	
	// has a Chainsaw
	if(is_user_connected(id) && g_iHasChainsaw[id])
	{
		// Get new fire rate
		static Float:flRate
		flRate = get_pcvar_float(cvar_sattack_rate)
		
		// Set new rates
		set_pdata_float(knife, m_flNextPrimaryAttack, flRate, 4)
		set_pdata_float(knife, m_flNextSecondaryAttack, flRate, 4)
		set_pdata_float(knife, m_flTimeWeaponIdle, flRate, 4)
		
		// Get new recoil
		static Float:flPunchAngle[3]
		flPunchAngle[0] = get_pcvar_float(cvar_sattack_recoil)
		
		// Punch their angles
		entity_set_vector(id, EV_VEC_punchangle, flPunchAngle)
	}
	
	return HAM_IGNORED
}

/*================================================================================
 [Internal Functions]
=================================================================================*/

check_drop_flag(flag)
{
	new szFlags[10]
	get_pcvar_string(cvar_dropflags, szFlags, charsmax(szFlags))
	
	if(read_flags(szFlags) & flag)
		return true
		
	return false
}

a_lot_of_blood(id) // ROFL, thanks to jtp10181 for his AMX Ultimate Gore plugin.
{
	// Get user origin
	static iOrigin[3]
	get_user_origin(id, iOrigin)
	
	// Blood spray
	message_begin(MSG_PVS, SVC_TEMPENTITY, iOrigin)
	write_byte(TE_BLOODSTREAM)
	write_coord(iOrigin[0])
	write_coord(iOrigin[1])
	write_coord(iOrigin[2]+10)
	write_coord(random_num(-360, 360)) // x
	write_coord(random_num(-360, 360)) // y
	write_coord(-10) // z
	write_byte(70) // color
	write_byte(random_num(50, 100)) // speed
	message_end()
	
	// Write Small splash decal
	for (new j = 0; j < 4; j++) 
	{
		message_begin(MSG_PVS, SVC_TEMPENTITY, iOrigin)
		write_byte(TE_WORLDDECAL)
		write_coord(iOrigin[0]+random_num(-100, 100))
		write_coord(iOrigin[1]+random_num(-100, 100))
		write_coord(iOrigin[2]-36)
		write_byte(random_num(190, 197)) // index
		message_end()
	}
}

/*================================================================================
 [Stocks]
=================================================================================*/

stock client_printcolor(const id, const input[], any:...)
{
	new iCount = 1, iPlayers[32]
	
	static szMsg[191]
	vformat(szMsg, charsmax(szMsg), input, 3)
	
	replace_all(szMsg, 190, "/g", "^4") // green txt
	replace_all(szMsg, 190, "/y", "^1") // orange txt
	replace_all(szMsg, 190, "/ctr", "^3") // team txt
	replace_all(szMsg, 190, "/w", "^0") // team txt
	
	if(id) iPlayers[0] = id
	else get_players(iPlayers, iCount, "ch")
		
	for (new i = 0; i < iCount; i++)
	{
		if (is_user_connected(iPlayers[i]))
		{
			message_begin(MSG_ONE_UNRELIABLE, g_msgSayText, _, iPlayers[i])
			write_byte(iPlayers[i])
			write_string(szMsg)
			message_end()
		}
	}
}
