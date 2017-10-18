/*================================================================================

	[ZP] Extra Item: Advanced Antidote Gun
	Copyright (C) 2010 by meTaLiCroSS, Viña del Mar, Chile
	
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
		
	- ConnorMcLeod: His MaxClip and Reload Speed plugin
	- KCE: His "Blocking weapon fire" tutorial
	- XxAvalanchexX: His "Beampoints from a player's weapon tip" tutorial

=================================================================================*/

#include <amxmodx>
#include <hamsandwich>
#include <fun>
#include <engine>
#include <cstrike>
#include <fakemeta>
#include <xs>
#include <zombieplague>
#include <zmvip>

/*================================================================================
 [Customizations]
=================================================================================*/

// Item Cost
const antidotegun_ap_cost = 30

// Sprites
new const antidotegun_sprite_beam[] = "sprites/zbeam6.spr"
new const antidotegun_sprite_ring[] = "sprites/shockwave.spr"

// Weapon Fire Sound, you can add more than 1
new const antidotegun_firesound[][] = { "weapons/gauss2.wav" }

// Hit Sound, you can add more than 1
new const antidotegun_hitsound[][] = { "warcraft3/frostnova.wav" }

// Ammo bought Sound, you can add more than 1
new const antidotegun_ammopickupsound[][] = { "items/9mmclip1.wav" }

// Weaponbox Glow RGB Colors	R	G	B
new antidotegun_wb_color[] = {	0, 	255, 	255 	}

// Uncomment this line if you want to add support to old ZP versions
// Use if it's necessary, from version 4.2 to below
// If you uncomment this line, this item can be buyed only in infection
// rounds, because the main disinfect native in old versions works
// only on infection rounds.
//#define OLD_VERSION_SUPPORT

/*================================================================================
 Customization ends here! Yes, that's it. Editing anything beyond
 here is not officially supported. Proceed at your own risk...
=================================================================================*/

// Booleans
new bool:g_bHasAntidoteGun[33], bool:g_bIsConnected[33], bool:g_bIsAlive[33]

// Cvar pointers
new cvar_enable, cvar_oneround, cvar_firerate, cvar_maxclip, cvar_maxbpammo, cvar_wboxglow, 
cvar_buyindelay, cvar_reloadspeed, cvar_hitslowdown

// Arrays
new g_iCurrentWeapon[33], Float:g_flLastFireTime[33]

// Variables
new g_iItemID, g_iMaxPlayers, g_msgSayText, g_msgDeathMsg, g_msgCurWeapon, g_msgAmmoX, 
g_msgAmmoPickup, g_msgScreenFade, g_sprBeam, g_sprRing, HamHook:g_iHhPostFrame_fw

// Offsets
const m_pPlayer = 		41
const m_fInReload =		54
const m_pActiveItem = 		373
const m_flNextAttack = 		83
const m_flTimeWeaponIdle = 	48
const m_flNextPrimaryAttack = 	46
const m_flNextSecondaryAttack =	47

// Some constants
const FFADE_IN = 		0x0000
const ENG_NULLENT = 		-1
const UNIT_SECOND =		(1<<12)
const AMMOID_GALIL = 		4
const GALIL_DFT_MAXCLIP =	35
const V_GAUSS_ANIM_FIRE = 	6
const V_GAUSS_ANIM_DRAW = 	8
const V_GAUSS_ANIM_RELOAD = 	2
const EV_INT_WEAPONKEY = 	EV_INT_impulse
const ANTIDOTEGUN_WPNKEY = 	2816

// Buy in delay cvar it's disabled 
// for old versions
#if defined OLD_VERSION_SUPPORT
	#pragma unused cvar_buyindelay
#endif

// Cached cvars
new bool:g_bCvar_Enabled, bool:g_bCvar_BuyUntilMode, Float:g_flCvar_FireRate,
Float:g_flCvar_ReloadSpeed, Float:g_flCvar_HitSlowdown, g_iCvar_MaxClip, g_iCvar_MaxBPAmmo

// Plug info.
#define PLUG_VERSION "0.6"
#define PLUG_AUTH "meTaLiCroSS"

// Macros
#define is_user_valid_alive(%1) 	(1 <= %1 <= g_iMaxPlayers && g_bIsAlive[%1])
#define is_user_valid_connected(%1) 	(1 <= %1 <= g_iMaxPlayers && g_bIsConnected[%1])

/*================================================================================
 [Init and Precache]
=================================================================================*/

public plugin_init() 
{
	// Plugin info
	register_plugin("[ZP] Extra Item: Advanced Antidote Gun", PLUG_VERSION, PLUG_AUTH)
	
	// Events
	register_event("CurWeapon", "event_CurWeapon", "b", "1=1")	
	register_event("HLTV", "event_RoundStart", "a", "1=0", "2=0")
	
	// Fakemeta Forwards
	register_forward(FM_SetModel, "fw_SetModel")
	register_forward(FM_CmdStart, "fw_CmdStart")
	register_forward(FM_UpdateClientData, "fw_UpdateClientData_Post", 1)
	
	// Hamsandwich Forwards
	RegisterHam(Ham_Killed, "player", "fw_PlayerKilled")
	RegisterHam(Ham_Spawn, "player", "fw_PlayerSpawn_Post", 1)
	RegisterHam(Ham_Item_Deploy, "weapon_galil", "fw_Galil_Deploy_Post", 1)
	RegisterHam(Ham_Item_AddToPlayer, "weapon_galil", "fw_Galil_AddToPlayer")
	RegisterHam(Ham_Weapon_Reload, "weapon_galil", "fw_Galil_Reload_Post", 1)
	g_iHhPostFrame_fw = RegisterHam(Ham_Item_PostFrame, "weapon_galil", "fw_Galil_PostFrame")
	
	// Cvars
	cvar_enable = register_cvar("zp_antidotegun_enable", "1")
	cvar_oneround = register_cvar("zp_antidotegun_oneround", "0")
	cvar_firerate = register_cvar("zp_antidotegun_fire_rate", "0.6")
	cvar_maxclip = register_cvar("zp_antidotegun_max_clip", "3")
	cvar_maxbpammo = register_cvar("zp_antidotegun_max_bpammo", "25")
	cvar_reloadspeed = register_cvar("zp_antidotegun_reload_speed", "2.5")
	cvar_wboxglow = register_cvar("zp_antidotegun_wbox_glow", "1")
	cvar_buyindelay = register_cvar("zp_antidotegun_buy_before_modestart", "0")
	cvar_hitslowdown = register_cvar("zp_antidotegun_hit_slowdown", "0.4")
	
	static szCvar[30]
	formatex(szCvar, charsmax(szCvar), "v%s by %s", PLUG_VERSION, PLUG_AUTH)
	register_cvar("zp_extra_adv_antidotegun", szCvar, FCVAR_SERVER|FCVAR_SPONLY)
	
	// Variables
	g_iMaxPlayers = get_maxplayers()
	g_msgAmmoX = get_user_msgid("AmmoX")
	g_msgSayText = get_user_msgid("SayText")
	g_msgDeathMsg = get_user_msgid("DeathMsg")
	g_msgCurWeapon = get_user_msgid("CurWeapon")
	g_msgAmmoPickup = get_user_msgid("AmmoPickup")
	g_msgScreenFade = get_user_msgid("ScreenFade")
	g_iItemID = zv_register_extra_item("Antidote Gun", "Desinfecting people", antidotegun_ap_cost, ZV_TEAM_HUMAN)
}

public plugin_precache()
{
	// Models
	precache_model("models/v_gauss.mdl")
	precache_model("models/p_gauss.mdl")
	precache_model("models/w_gauss.mdl")
	
	// Sprites
	g_sprBeam = precache_model(antidotegun_sprite_beam)
	g_sprRing = precache_model(antidotegun_sprite_ring)
	
	// Sounds
	static i
	for(i = 0; i < sizeof antidotegun_firesound; i++)
		precache_sound(antidotegun_firesound[i])
	for(i = 0; i < sizeof antidotegun_ammopickupsound; i++)
		precache_sound(antidotegun_ammopickupsound[i])
	for(i = 0; i < sizeof antidotegun_hitsound; i++)
		precache_sound(antidotegun_hitsound[i])
		
		
}

public plugin_cfg()
{
	// Cache some cvars after init is called
	cache_cvars()
	
	// Check the max clip cvar
	if(g_iCvar_MaxClip && g_iCvar_MaxClip != GALIL_DFT_MAXCLIP)
	{
		EnableHamForward(g_iHhPostFrame_fw)
	}
	else
	{
		// Should disable it if isn't necesary to check
		DisableHamForward(g_iHhPostFrame_fw)
	}
}

/*================================================================================
 [Main Events]
=================================================================================*/

public event_CurWeapon(id)
{
	// Not alive...
	if(!g_bIsAlive[id])
		return PLUGIN_CONTINUE
		
	// Updating weapon array
	g_iCurrentWeapon[id] = read_data(2)
	
	// Zombie or Survivor
	if(zp_get_user_zombie(id) || zp_get_user_survivor(id))
		return PLUGIN_CONTINUE
		
	// Doesn't has an Antidote Gun and weapon isn't Galil
	if(!g_bHasAntidoteGun[id] || g_iCurrentWeapon[id] != CSW_GALIL) 
		return PLUGIN_CONTINUE
		
	// Change his models
	entity_set_string(id, EV_SZ_viewmodel, "models/v_gauss.mdl")
	entity_set_string(id, EV_SZ_weaponmodel, "models/p_gauss.mdl")
		
	return PLUGIN_CONTINUE
}

public event_RoundStart()
{
	// Some cvars cache on round start
	cache_cvars()
}

/*================================================================================
 [Zombie Plague Forwards]
=================================================================================*/

public zp_user_humanized_pre(id)
{
	// Update bool when was buyed an antidote
	g_bHasAntidoteGun[id] = false
}

public zp_user_infected_post(id)
{
	// Update bool when was infected
	g_bHasAntidoteGun[id] = false
}

public zv_extra_item_selected(id, itemid)
{
	// It's an antidote gun itemid
	if(itemid == g_iItemID)
	{
		// Should be enabled
		if(g_bCvar_Enabled)
		{
			// Buy until round starts?
			if (!zp_has_round_started() && !g_bCvar_BuyUntilMode)
			{
				client_printcolor(id, "/g[ZP]/y You must wait until the round starts")
				
				#if defined OLD_VERSION_SUPPORT
				zp_set_user_ammo_packs(id, zp_get_user_ammo_packs(id) + antidotegun_ap_cost)
				return PLUGIN_CONTINUE
				#else
				return ZV_PLUGIN_HANDLED
				#endif
			}
			
			#if defined OLD_VERSION_SUPPORT
			// Check actual mode id
			if(zp_is_plague_round() || zp_is_swarm_round() || zp_is_nemesis_round() || zp_is_survivor_round())
			{
				client_printcolor(id, "/g[ZP]/y You can't buy this gun in this round")
				zp_set_user_ammo_packs(id, zp_get_user_ammo_packs(id) + antidotegun_ap_cost)
				return PLUGIN_CONTINUE
			}
			#endif
			
			// Some vars with info
			new iWpnID, iAmmo, iBPAmmo, bool:bAlreadyHasGalil = bool:user_has_weapon(id, CSW_GALIL)
			
			// Already has this gun
			if(g_bHasAntidoteGun[id] && bAlreadyHasGalil)
			{
				// Update the current backpack ammo
				iBPAmmo = cs_get_user_bpammo(id, CSW_GALIL)
				
				// We can't give more ammo
				if(iBPAmmo >= g_iCvar_MaxBPAmmo)
				{
					client_printcolor(id, "/g[ZP]/y Your Antidote Gun backpack ammo it's full")
					
					#if defined OLD_VERSION_SUPPORT
					zp_set_user_ammo_packs(id, zp_get_user_ammo_packs(id) + antidotegun_ap_cost)
					return PLUGIN_CONTINUE
					#else
					return ZV_PLUGIN_HANDLED
					#endif
				}

				// Get the new ammo it are going to be used by the player
				static iNewAmmo
				iNewAmmo = g_iCvar_MaxBPAmmo - iBPAmmo
				
				// Give the new amount of ammo
				cs_set_user_bpammo(id, CSW_GALIL, iBPAmmo + iNewAmmo)
				
				// Flash ammo in hud
				message_begin(MSG_ONE_UNRELIABLE, g_msgAmmoPickup, _, id)
				write_byte(AMMOID_GALIL) // ammo id
				write_byte(iNewAmmo) // ammo amount
				message_end()
				
				// Play clip purchase sound
				emit_sound(id, CHAN_ITEM, antidotegun_ammopickupsound[random_num(0, sizeof antidotegun_ammopickupsound - 1)], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
			}
			else
			{	
				// We need to get if has an ordinary galil
				if(bAlreadyHasGalil)
					ham_strip_weapon(id, "weapon_galil")
					
				// Update player bool
				g_bHasAntidoteGun[id] = true
				
				// Give and store the weapon id
				iWpnID = give_item(id, "weapon_galil")
				
				// Set the normal weapon ammo
				if(g_iCvar_MaxClip && g_iCvar_MaxClip != GALIL_DFT_MAXCLIP)
					cs_set_weapon_ammo(iWpnID, g_iCvar_MaxClip)
					
				// Set the max bpammo
				cs_set_user_bpammo(id, CSW_GALIL, g_iCvar_MaxBPAmmo)
			}
			
			// We should update this var if isn't info into.
			if(!iWpnID) iWpnID = find_ent_by_owner(ENG_NULLENT, "weapon_galil", id)
				
			// Yes or yes we need to update this vars with the current ammo amount
			iAmmo = cs_get_weapon_ammo(iWpnID)
			iBPAmmo = cs_get_user_bpammo(id, CSW_GALIL)
				
			// Force to change his gun
			engclient_cmd(id, "weapon_galil")
			
			// Update the player ammo
			update_ammo_hud(id, iAmmo, iBPAmmo)
		}
		else
		{
			// A message
			client_printcolor(id, "/g[ZP]/y Antidote Gun item has been disabled. /gContact Admin")
			
			#if defined OLD_VERSION_SUPPORT
			zp_set_user_ammo_packs(id, zp_get_user_ammo_packs(id) + antidotegun_ap_cost)
			return PLUGIN_CONTINUE
			#else
			return ZV_PLUGIN_HANDLED
			#endif
		}
	}
	
	return PLUGIN_CONTINUE
}

/*================================================================================
 [Main Forwards]
=================================================================================*/

public client_putinserver(id)
{
	// Updating bools
	g_bIsConnected[id] = true
	g_bHasAntidoteGun[id] = false
}

public client_disconnect(id)
{
	// Updating bools
	g_bIsAlive[id] = false
	g_bIsConnected[id] = false
	g_bHasAntidoteGun[id] = false
}

public fw_PlayerSpawn_Post(id)
{
	// Not alive...
	if(!is_user_alive(id))
		return HAM_IGNORED
		
	// Player is alive
	g_bIsAlive[id] = true
	
	// Remove Weapon
	if(get_pcvar_num(cvar_oneround) || !g_bCvar_Enabled)
	{
		if(g_bHasAntidoteGun[id])
		{
			// Reset player vars
			g_bHasAntidoteGun[id] = false
			
			// Strip his galil
			ham_strip_weapon(id, "weapon_galil")
		}
	}
	
	return HAM_IGNORED
}

public fw_PlayerKilled(victim, attacker, shouldgib)
{
	// Player victim
	if(is_user_valid_connected(victim))
	{
		// Victim is not alive
		g_bIsAlive[victim] = false
		
		// Reset player vars
		g_bHasAntidoteGun[victim] = false
		
		return HAM_HANDLED
	}
	
	return HAM_IGNORED
}

public fw_CmdStart(id, handle, seed)
{
	// Skip not alive users
	if(!is_user_valid_alive(id))
		return FMRES_IGNORED
		
	// Without an antidote gun
	if(!g_bHasAntidoteGun[id])
		return FMRES_IGNORED
		
	// Not human
	if(zp_get_user_zombie(id) || zp_get_user_survivor(id))
		return FMRES_IGNORED
	
	// Isn't holding a Galil
	if(g_iCurrentWeapon[id] != CSW_GALIL)
		return FMRES_IGNORED
		
	// Get Buttons
	static iButton
	iButton = get_uc(handle, UC_Buttons)
	
	// User pressing +attack Button
	if(iButton & IN_ATTACK)
	{
		// Buttons
		set_uc(handle, UC_Buttons, iButton & ~IN_ATTACK)
		
		// Some vars
		static Float:flCurrentTime
		flCurrentTime = halflife_time()
		
		// Fire rate not over yet
		if (flCurrentTime - g_flLastFireTime[id] < g_flCvar_FireRate)
			return FMRES_IGNORED
			
		// Another vars with info
		static iWpnID, iClip
		iWpnID = get_pdata_cbase(id, m_pActiveItem, 5)
		iClip = cs_get_weapon_ammo(iWpnID)
		
		// Skip if is in reload
		if(get_pdata_int(iWpnID, m_fInReload, 4))
			return FMRES_IGNORED
		
		// To don't reload instantly (bugfix)
		set_pdata_float(iWpnID, m_flNextPrimaryAttack, g_flCvar_FireRate, 4)
		set_pdata_float(iWpnID, m_flNextSecondaryAttack, g_flCvar_FireRate, 4)
		set_pdata_float(iWpnID, m_flTimeWeaponIdle, g_flCvar_FireRate, 4)
		
		// Update last fire time array
		g_flLastFireTime[id] = flCurrentTime
		
		// 0 bullets
		if(iClip <= 0)
		{
			// Play empty clip sound
			ExecuteHamB(Ham_Weapon_PlayEmptySound, iWpnID)

			return FMRES_IGNORED
		}
			
		// Process fire
		primary_attack(id)
		
		// Real fire push knockback
		launch_push(id, 40)
		
		// Update Ammo
		cs_set_weapon_ammo(iWpnID, --iClip)
		update_ammo_hud(id, iClip, cs_get_user_bpammo(id, CSW_GALIL))
		
		return FMRES_IGNORED
	}
	
	return FMRES_IGNORED
}

public fw_SetModel(entity, model[])
{
	// Entity is not valid
	if(!is_valid_ent(entity))
		return FMRES_IGNORED;
		
	// Entity model is not w_galil
	if(!equal(model, "models/w_galil.mdl")) 
		return FMRES_IGNORED;
		
	// Get classname
	static szClassName[33]
	entity_get_string(entity, EV_SZ_classname, szClassName, charsmax(szClassName))
		
	// Not a Weapon box
	if(!equal(szClassName, "weaponbox"))
		return FMRES_IGNORED
	
	// Some vars
	static iOwner, iStoredGalilID
	
	// Get owner
	iOwner = entity_get_edict(entity, EV_ENT_owner)
	
	// Get drop weapon index (galil) to use in fw_Galil_AddToPlayer forward
	iStoredGalilID = find_ent_by_owner(ENG_NULLENT, "weapon_galil", entity)
	
	// Entity classname is weaponbox, and galil has founded
	if(g_bHasAntidoteGun[iOwner] && is_valid_ent(iStoredGalilID))
	{
		// Setting weapon options
		entity_set_int(iStoredGalilID, EV_INT_WEAPONKEY, ANTIDOTEGUN_WPNKEY)
		
		// Reset user vars
		g_bHasAntidoteGun[iOwner] = false
		
		// Set weaponbox new model
		entity_set_model(entity, "models/w_gauss.mdl")
		
		// Glow
		if(get_pcvar_num(cvar_wboxglow))
			set_rendering(entity, kRenderFxGlowShell, antidotegun_wb_color[0], antidotegun_wb_color[1], antidotegun_wb_color[2], kRenderNormal, 25)
		
		return FMRES_SUPERCEDE
	}
	
	return FMRES_IGNORED
}

public fw_UpdateClientData_Post(id, sendweapons, handle)
{
	// Skip not alive users
	if(!is_user_valid_alive(id))
		return FMRES_IGNORED
		
	// Without an antidote gun
	if(!g_bHasAntidoteGun[id])
		return FMRES_IGNORED
		
	// Not human
	if(zp_get_user_zombie(id) || zp_get_user_survivor(id))
		return FMRES_IGNORED
	
	// Isn't holding a Galil
	if(g_iCurrentWeapon[id] != CSW_GALIL)
		return FMRES_IGNORED
		
	// Player can't attack with the AG
	set_cd(handle, CD_flNextAttack, halflife_time() + 0.001)

	return FMRES_HANDLED
}

public fw_Galil_Deploy_Post(galil)
{
	// Get galil owner
	static id
	id = get_pdata_cbase(galil, m_pPlayer, 4)
	
	// The current galil owner has an antidote gun?
	if(is_user_valid_connected(id) && g_bHasAntidoteGun[id])
	{
		// Update the current ammo
		update_ammo_hud(id, cs_get_weapon_ammo(galil), cs_get_user_bpammo(id, CSW_GALIL))
		
		// Send the draw animation
		set_user_weaponanim(id, V_GAUSS_ANIM_DRAW)
	}
	
	return HAM_IGNORED
}

public fw_Galil_AddToPlayer(galil, player)
{
	// Is an antidote gun?
	if(is_valid_ent(galil) && is_user_valid_connected(player) && entity_get_int(galil, EV_INT_WEAPONKEY) == ANTIDOTEGUN_WPNKEY)
	{
		// Set vars
		g_bHasAntidoteGun[player] = true
		
		// Reset weapon options
		entity_set_int(galil, EV_INT_WEAPONKEY, 0)
		
		return HAM_HANDLED
	}
	
	return HAM_IGNORED
}

public fw_Galil_PostFrame(galil)
{
	// Get galil owner
	static id
	id = get_pdata_cbase(galil, m_pPlayer, 4)
	
	// His owner has an antidote gun?
	if(is_user_valid_alive(id) && g_bHasAntidoteGun[id])
	{
		// Some vars
		static Float:flNextAttack, iBpAmmo, iClip, iInReload
		
		// Weapon is on middle reload
		iInReload = get_pdata_int(galil, m_fInReload, 4)
		
		// Next player attack
		flNextAttack = get_pdata_float(id, m_flNextAttack, 5)
		
		// Player back pack ammo
		iBpAmmo = cs_get_user_bpammo(id, CSW_GALIL)
		
		// Current weapon clip
		iClip = cs_get_weapon_ammo(galil)
		
		// End of reload
		if(iInReload && flNextAttack <= 0.0)
		{
			// Get the minimun amount between maxclip sub. current clip 
			// and the player backpack ammo
			new j = min(g_iCvar_MaxClip - iClip, iBpAmmo)
			
			// Set the new weapon clip
			cs_set_weapon_ammo(galil, iClip + j)
	
			// Set the new player backpack ammo
			cs_set_user_bpammo(id, CSW_GALIL, iBpAmmo-j)
			
			// Update the weapon offset "inreload" to 0 ("false")
			iInReload = 0
			set_pdata_int(galil, m_fInReload, 0, 4)
		}
	
		// Get the current player buttons
		static iButton
		iButton = get_user_button(id)
		
		// The player stills pressing the fire button
		if((iButton & IN_ATTACK2 && get_pdata_float(galil, m_flNextSecondaryAttack, 4) <= 0.0) || (iButton & IN_ATTACK && get_pdata_float(galil, m_flNextPrimaryAttack, 4) <= 0.0))
			return
	
		// Trying to reload pressing the reload button when isn't it
		if(iButton & IN_RELOAD && !iInReload)
		{
			// The current weapon clip exceed the new max clip
			if(iClip >= g_iCvar_MaxClip)
			{
				// Retrieve player reload button
				entity_set_int(id, EV_INT_button, iButton & ~IN_RELOAD)
				
				// Send idle animation
				set_user_weaponanim(id, 0)
			}
			// The current weapon clip it's the same like the old max weapon clip
			else if(iClip == GALIL_DFT_MAXCLIP)
			{
				// Has an amount of bpammo?
				if(iBpAmmo)
				{
					// Should make a reload
					antidotegun_reload(id, galil, 1)
				}
			}
		}
	}
	
	// Credits and thanks to ConnorMcLeod for his Weapon MaxClip plugin!
}

public fw_Galil_Reload_Post(galil)
{
	// Get galil owner
	static id
	id = get_pdata_cbase(galil, m_pPlayer, 4)
	
	// It's in reload and his owner has an antidote gun?
	if(is_user_valid_alive(id) && g_bHasAntidoteGun[id] && get_pdata_int(galil, m_fInReload, 4))
	{	
		// Change normal reload options
		antidotegun_reload(id, galil)
	}
}

/*================================================================================
 [Internal Functions]
=================================================================================*/

cache_cvars()
{
	// Some cvars
	g_bCvar_Enabled = bool:get_pcvar_num(cvar_enable)
	g_flCvar_FireRate = get_pcvar_float(cvar_firerate)
	g_flCvar_ReloadSpeed = get_pcvar_float(cvar_reloadspeed)
	g_flCvar_HitSlowdown = get_pcvar_float(cvar_hitslowdown)
	g_iCvar_MaxClip = clamp(get_pcvar_num(cvar_maxclip), 0, 120)
	g_iCvar_MaxBPAmmo = clamp(get_pcvar_num(cvar_maxbpammo), 1, 90)
	
	#if defined OLD_VERSION_SUPPORT
	g_bCvar_BuyUntilMode = false
	#else
	g_bCvar_BuyUntilMode = bool:get_pcvar_num(cvar_buyindelay)
	#endif
}

primary_attack(id)
{
	// Fire Effect
	set_user_weaponanim(id, V_GAUSS_ANIM_FIRE)
	entity_set_vector(id, EV_VEC_punchangle, Float:{ -1.5, 0.0, 0.0 })
	emit_sound(id, CHAN_WEAPON, antidotegun_firesound[random_num(0, sizeof antidotegun_firesound - 1)], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	
	// Some vars
	static iTarget, iBody, iEndOrigin[3]
	
	// Get end origin from eyes
	get_user_origin(id, iEndOrigin, 3)
	
	// Make gun beam
	beam_from_gun(id, iEndOrigin)
	
	// Get user aiming
	get_user_aiming(id, iTarget, iBody)
	
	// Do sound by a new entity
	new iEnt = create_entity("info_target")
	
	// Integer vector into a Float vector
	static Float:flOrigin[3]
	IVecFVec(iEndOrigin, flOrigin)
	
	// Set entity origin
	entity_set_origin(iEnt, flOrigin)
	
	// Sound
	emit_sound(iEnt, CHAN_WEAPON, antidotegun_hitsound[random_num(0, sizeof antidotegun_firesound - 1)], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	
	// Remove entity
	remove_entity(iEnt)
	
	// Aim target it's a player
	if(is_user_valid_alive(iTarget))
	{	
		// Hit slowdown, first should be enabled
		if(g_flCvar_HitSlowdown > 0.0)
		{
			// Get his current velocity vector
			static Float:flVelocity[3]
			get_user_velocity(iTarget, flVelocity)
			
			// Multiply his velocity by a number
			xs_vec_mul_scalar(flVelocity, g_flCvar_HitSlowdown, flVelocity)
			
			// Set his new velocity vector
			set_user_velocity(iTarget, flVelocity)	
		}
		
		// It's allowed to be disinfected
		if(zp_get_user_zombie(iTarget) && !zp_get_user_nemesis(iTarget) && !zp_get_user_last_zombie(iTarget))
		{
			// Disinfect user
			#if defined OLD_VERSION_SUPPORT
			zp_disinfect_user(iTarget)
			#else
			zp_disinfect_user(iTarget, 1)
			#endif
			
			// Death message
			message_begin(MSG_BROADCAST, g_msgDeathMsg)
			write_byte(id) // killer
			write_byte(iTarget) // victim
			write_byte(iBody == HIT_HEAD ? 1 : 0) // headshot flag
			write_string("antidote gun") // killer's weapon
			message_end()
			
			// Screen fade fx
			message_begin(MSG_ONE_UNRELIABLE, g_msgScreenFade, _, iTarget)
			write_short(UNIT_SECOND*1) // duration
			write_short(UNIT_SECOND/2) // hold time
			write_short(FFADE_IN) // fade type
			write_byte(0) // r
			write_byte(255) // g
			write_byte(255) // b
			write_byte(227) // alpha
			message_end()
			
			// Beam Cylinder fx
			message_begin(MSG_PVS, SVC_TEMPENTITY, iEndOrigin)
			write_byte(TE_BEAMCYLINDER) // TE id
			write_coord(iEndOrigin[0]) // position.x
			write_coord(iEndOrigin[1]) // position.y
			write_coord(iEndOrigin[2]) // position.z
			write_coord(iEndOrigin[0]) // x axis
			write_coord(iEndOrigin[1]) // y axis
			write_coord(iEndOrigin[2] + 385) // z axis
			write_short(g_sprRing) // sprite
			write_byte(0) // startframe
			write_byte(0) // framerate
			write_byte(4) // life
			write_byte(30) // width
			write_byte(0) // noise
			write_byte(0) // red
			write_byte(255) // green
			write_byte(255) // blue
			write_byte(200) // brightness
			write_byte(0) // speed
			message_end()
		}
		// Can't be disinfected
		else
		{
			// Faster particles
			message_begin(MSG_PVS, SVC_TEMPENTITY, iEndOrigin)
			write_byte(TE_PARTICLEBURST) // TE id
			write_coord(iEndOrigin[0]) // position.x
			write_coord(iEndOrigin[1]) // position.y
			write_coord(iEndOrigin[2]) // position.z
			write_short(45) // radius
			write_byte(208) // particle color
			write_byte(10) // duration * 10 will be randomized a bit
			message_end()
		}
	}
	else
	{
		// Aim target entity it's valid and isn't worldspawn?
		if((iTarget > 0) && is_valid_ent(iTarget))
		{
			// Get aim target classname
			static szClassname[32]
			entity_get_string(iTarget, EV_SZ_classname, szClassname, charsmax(szClassname))
			
			// It's a breakable entity
			if(equal(szClassname, "func_breakable"))
			{
				// Get destroy this ent
				force_use(id, iTarget)
			}
		}
	}
}

antidotegun_reload(id, galil, force_reload = 0)
{
	// Next player attack time
	set_pdata_float(id, m_flNextAttack, g_flCvar_ReloadSpeed, 5)

	// Send to the player the reload animation
	set_user_weaponanim(id, V_GAUSS_ANIM_RELOAD)
	
	// Update the weapon offset "inreload" to 1 ("true")
	if(force_reload)
		set_pdata_int(galil, m_fInReload, 1, 4)

	// Next idle weapon time, soonest time ItemPostFrame will call WeaponIdle.
	set_pdata_float(galil, m_flTimeWeaponIdle, g_flCvar_ReloadSpeed + 0.5, 4)
	
	// I'll be honest, i don't know what do this.
	entity_set_float(id, EV_FL_frame, 200.0)
}

update_ammo_hud(id, iAmmoAmount, iBPAmmoAmount)
{
	// Display the new antidotegun bullets
	if(iAmmoAmount != -1)
	{
		message_begin(MSG_ONE_UNRELIABLE, g_msgCurWeapon, _, id)
		write_byte(1) // active
		write_byte(CSW_GALIL) // weapon
		write_byte(iAmmoAmount) // clip
		message_end()
	}
	
	// Display the new amount of BPAmmo
	if(iBPAmmoAmount != -1)
	{
		message_begin(MSG_ONE_UNRELIABLE, g_msgAmmoX, _, id)
		write_byte(AMMOID_GALIL) // ammoid
		write_byte(iBPAmmoAmount) // ammo amount
		message_end()
	}
}

beam_from_gun(id, iEndOrigin[3])
{
	// Make a cool beam
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_BEAMENTPOINT) // TE id
	write_short(id | 0x1000) // start entity
	write_coord(iEndOrigin[0]) // endposition.x
	write_coord(iEndOrigin[1]) // endposition.y
	write_coord(iEndOrigin[2]) // endposition.z
	write_short(g_sprBeam)    // sprite index
	write_byte(1)	// framestart
	write_byte(1)	// framerate
	write_byte(1)	// life in 0.1's
	write_byte(10)	// width
	write_byte(0)	// noise
	write_byte(0)	// r
	write_byte(255)	// g
	write_byte(255)	// b
	write_byte(200)	// brightness
	write_byte(0)	// speed
	message_end()
	
	// Dynamic Light
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY, iEndOrigin)
	write_byte(TE_DLIGHT) // TE id
	write_coord(iEndOrigin[0]) // position.x
	write_coord(iEndOrigin[1]) // position.y
	write_coord(iEndOrigin[2]) // position.z
	write_byte(30) // radius
	write_byte(0) // red
	write_byte(255) // green
	write_byte(255) // blue
	write_byte(10) // life
	write_byte(45) // decay rate
	message_end()
	
	// Sparks
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY, iEndOrigin)
	write_byte(TE_SPARKS) // TE id
	write_coord(iEndOrigin[0]) // position.x
	write_coord(iEndOrigin[1]) // position.y
	write_coord(iEndOrigin[2]) // position.z
	message_end()
}

/*================================================================================
 [Stocks]
=================================================================================*/

stock set_user_weaponanim(id, anim)
{
	entity_set_int(id, EV_INT_weaponanim, anim)
	message_begin(MSG_ONE, SVC_WEAPONANIM, {0, 0, 0}, id)
	write_byte(anim)
	write_byte(entity_get_int(id, EV_INT_body))
	message_end()
}

stock launch_push(id, velamount) // from my Nemesis Rocket Launcher plugin.
{
	static Float:flNewVelocity[3], Float:flCurrentVelocity[3]
	
	velocity_by_aim(id, -velamount, flNewVelocity)
	
	get_user_velocity(id, flCurrentVelocity)
	xs_vec_add(flNewVelocity, flCurrentVelocity, flNewVelocity)
	
	set_user_velocity(id, flNewVelocity)	
}

stock ham_strip_weapon(id, weapon[])
{
	if(!equal(weapon,"weapon_",7)) 
		return 0
	
	new wId = get_weaponid(weapon)
	
	if(!wId) return 0
	
	new wEnt
	
	while((wEnt = find_ent_by_class(wEnt, weapon)) && entity_get_edict(wEnt, EV_ENT_owner) != id) {}
	
	if(!wEnt) return 0
	
	if(get_user_weapon(id) == wId) 
		ExecuteHamB(Ham_Weapon_RetireWeapon,wEnt);
	
	if(!ExecuteHamB(Ham_RemovePlayerItem,id,wEnt)) 
		return 0
		
	ExecuteHamB(Ham_Item_Kill, wEnt)
	
	entity_set_int(id, EV_INT_weapons, entity_get_int(id, EV_INT_weapons) & ~(1<<wId))

	return 1
}

stock client_printcolor(id, const input[], any:...)
{
	static iPlayersNum[32], iCount; iCount = 1
	static szMsg[191]
	
	vformat(szMsg, charsmax(szMsg), input, 3)
	
	replace_all(szMsg, 190, "/g", "^4") // green txt
	replace_all(szMsg, 190, "/y", "^1") // orange txt
	replace_all(szMsg, 190, "/ctr", "^3") // team txt
	replace_all(szMsg, 190, "/w", "^0") // team txt
	
	if(id) iPlayersNum[0] = id
	else get_players(iPlayersNum, iCount, "ch")
		
	for (new i = 0; i < iCount; i++)
	{
		if (g_bIsConnected[iPlayersNum[i]])
		{
			message_begin(MSG_ONE_UNRELIABLE, g_msgSayText, _, iPlayersNum[i])
			write_byte(iPlayersNum[i])
			write_string(szMsg)
			message_end()
		}
	}
}
