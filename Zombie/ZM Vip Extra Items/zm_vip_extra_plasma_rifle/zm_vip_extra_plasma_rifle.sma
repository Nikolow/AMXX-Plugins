/*======================================================*\
||	[ZP] Extra Item : Plasma Rifle			||
||	by Sh0oT3R					||
\*======================================================*/

#include <amxmodx>
#include <amxmisc>
#include <hamsandwich>
#include <engine>
#include <cstrike>
#include <fakemeta>
#include <xs>
#include <zombieplague>
#include <zmvip>

#define fm_create_entity(%1) engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, %1))

#define VERSION "1.0"
#define AUTHOR "Sh0oT3R"

#define FIRERATE 0.2
#define HITSD 0.7
#define RELOADSPEED 5.0
#define DAMAGE 250.0
#define DAMAGE_MULTI 3.0

#define CSW_WPN CSW_FAMAS
new const weapon[] = "weapon_famas"

new const g_Item_Description[] = "Plasma launcher"
new const g_Cost = 40
new const spr_beam[] = "sprites/plasma/plasma_beam.spr"
new const spr_exp[] = "sprites/plasma/plasma_exp.spr"
new const spr_blood[] = "sprites/blood.spr"
new const snd_fire[][] = { "zombie_plague/plasma/plasma_fire.wav" }
new const snd_reload[][] = { "zombie_plague/plasma/plasma_reload.wav" }
new const snd_hit[][] = { "zombie_plague/plasma/plasma_hit.wav" }

new bool:g_HasRifle[33]
new g_iCurWpn[33], Float:g_flLastFireTime[33]
new g_iItemId, g_sprBeam, g_sprExp, g_sprBlood, g_msgDamage, g_msgScreenFade, g_msgScreenShake

const m_pPlayer = 		41
const m_fInReload =		54
const m_pActiveItem = 		373
const m_flNextAttack = 		83
const m_flTimeWeaponIdle = 	48
const m_flNextPrimaryAttack = 	46
const m_flNextSecondaryAttack =	47

const UNIT_SECOND =		(1<<12)
const ENG_NULLENT = 		-1
const WPN_MAXCLIP =		25
const ANIM_FIRE = 		5
const ANIM_DRAW = 		10
const ANIM_RELOAD =		9
const EV_INT_WEAPONKEY = 	EV_INT_impulse
const WPNKEY = 			2816

public plugin_init() 
{
	register_plugin("[ZP] Extra Item: Plasma Rifle", VERSION, AUTHOR)
	
	register_event("HLTV", "Event_NewRound", "a", "1=0", "2=0");
	register_event("CurWeapon", "event_CurWeapon", "b", "1=1")	

	register_forward(FM_CmdStart, "fw_CmdStart")
	register_forward(FM_UpdateClientData, "fw_UpdateClientData_Post", 1)
	
	RegisterHam(Ham_Killed, "player", "fw_PlayerKilled")
	RegisterHam(Ham_Item_Deploy, weapon, "fw_Deploy_Post", 1)
	RegisterHam(Ham_Item_AddToPlayer, weapon, "fw_AddToPlayer")
	RegisterHam(Ham_Weapon_Reload, weapon, "fw_Reload_Post", 1)
	RegisterHam(Ham_Item_PostFrame, weapon, "fw_PostFrame")
	
	g_iItemId = zv_register_extra_item("Plasma Rifle", g_Item_Description, g_Cost, ZP_TEAM_HUMAN)
	
	g_msgDamage = get_user_msgid("Damage")
	g_msgScreenFade = get_user_msgid("ScreenFade")
	g_msgScreenShake = get_user_msgid("ScreenShake")
}

public plugin_precache()
{
	precache_model("models/zombie_plague/plasma/v_plasma.mdl")
	precache_model("models/zombie_plague/plasma/p_plasma.mdl")

	g_sprBlood = precache_model(spr_blood)
	g_sprBeam = precache_model(spr_beam)
	g_sprExp = precache_model(spr_exp)
	
	static i
	for(i = 0; i < sizeof snd_fire; i++)
		precache_sound(snd_fire[i])
	for(i = 0; i < sizeof snd_hit; i++)
		precache_sound(snd_hit[i])
	for(i = 0; i < sizeof snd_reload; i++)
		precache_sound(snd_reload[i])	
}
public event_CurWeapon(id)
{
	if(!is_user_alive(id))
	return PLUGIN_CONTINUE
		
	g_iCurWpn[id] = read_data(2)
	
	if(zp_get_user_zombie(id) || zp_get_user_survivor(id))
		return PLUGIN_CONTINUE
		
	if(!g_HasRifle[id] || g_iCurWpn[id] != CSW_WPN) 
		return PLUGIN_CONTINUE
		
	entity_set_string(id, EV_SZ_viewmodel, "models/zombie_plague/plasma/v_plasma.mdl")
	entity_set_string(id, EV_SZ_weaponmodel, "models/zombie_plague/plasma/p_plasma.mdl")
	return PLUGIN_CONTINUE
}
public zp_user_humanized_pre(id)
{
	g_HasRifle[id] = false
}
public zp_user_infected_post(id)
{
	g_HasRifle[id] = false
}
public fw_PlayerKilled(victim, attacker, shouldgib)
{
	if(is_user_alive(victim))
	{
		g_HasRifle[victim] = false
		return HAM_HANDLED
	}
	return HAM_IGNORED
}

public Event_NewRound()
{
	for (new i = 1; i <= get_maxplayers(); i++)
	{
		g_HasRifle[i] = false
	}
}
public client_putinserver(id)
{
	g_HasRifle[id] = false
}
public client_disconnect(id)
{
	g_HasRifle[id] = false
}
public zv_extra_item_selected(id, itemid)
{
	if(itemid == g_iItemId)
	{		
		new bool:HasWpn = bool:user_has_weapon(id, CSW_WPN)
		
		if(!g_HasRifle[id] && !HasWpn)
		{
			g_HasRifle[id] = true	
			fm_give_item(id, weapon)	
			cs_set_user_bpammo(id, CSW_WPN, 100)	
			engclient_cmd(id, weapon)
		}
		else
		{
			zp_set_user_ammo_packs(id, zp_get_user_ammo_packs(id) + g_Cost)
			return PLUGIN_CONTINUE
		}
	}
	return PLUGIN_CONTINUE
}
public fw_CmdStart(id, handle, seed)
{
	if(!is_user_alive(id))
		return FMRES_IGNORED
	
	if(!g_HasRifle[id])
		return FMRES_IGNORED
		
	if(zp_get_user_zombie(id) || zp_get_user_survivor(id))
		return FMRES_IGNORED
	
	if(g_iCurWpn[id] != CSW_WPN)
		return FMRES_IGNORED
		
	static iButton
	iButton = get_uc(handle, UC_Buttons)
	
	if(iButton & IN_ATTACK)
	{
		set_uc(handle, UC_Buttons, iButton & ~IN_ATTACK)
		
		static Float:flCurTime
		flCurTime = halflife_time()
		
		if(flCurTime - g_flLastFireTime[id] < FIRERATE)
			return FMRES_IGNORED
			
		static iWpnID, iClip
		iWpnID = get_pdata_cbase(id, m_pActiveItem, 5)
		iClip = cs_get_weapon_ammo(iWpnID)
		
		if(get_pdata_int(iWpnID, m_fInReload, 4))
			return FMRES_IGNORED
		
		set_pdata_float(iWpnID, m_flNextPrimaryAttack, FIRERATE, 4)
		set_pdata_float(iWpnID, m_flNextSecondaryAttack, FIRERATE, 4)
		set_pdata_float(iWpnID, m_flTimeWeaponIdle, FIRERATE, 4)
		g_flLastFireTime[id] = flCurTime
		if(iClip <= 0)
		{
			ExecuteHamB(Ham_Weapon_PlayEmptySound, iWpnID)
			return FMRES_IGNORED
		}
		primary_attack(id)
		make_punch(id, 50)
		cs_set_weapon_ammo(iWpnID, --iClip)
		
		return FMRES_IGNORED
	}
	
	return FMRES_IGNORED
}
public fw_UpdateClientData_Post(id, sendweapons, handle)
{
	if(!is_user_alive(id))
		return FMRES_IGNORED
		
	if(!g_HasRifle[id])
		return FMRES_IGNORED
		
	if(zp_get_user_zombie(id) || zp_get_user_survivor(id))
		return FMRES_IGNORED
	
	if(g_iCurWpn[id] != CSW_WPN)
		return FMRES_IGNORED
		
	set_cd(handle, CD_flNextAttack, halflife_time() + 0.001)
	return FMRES_HANDLED
}
public fw_Deploy_Post(wpn)
{
	static id
	id = get_pdata_cbase(wpn, m_pPlayer, 4)
	
	if(is_user_connected(id) && g_HasRifle[id])
	{
		set_wpnanim(id, ANIM_DRAW)
	}
	return HAM_IGNORED
}
public fw_AddToPlayer(wpn, id)
{
	if(is_valid_ent(wpn) && is_user_connected(id) && entity_get_int(wpn, EV_INT_WEAPONKEY) == WPNKEY)
	{
		g_HasRifle[id] = true
		entity_set_int(wpn, EV_INT_WEAPONKEY, 0)
		return HAM_HANDLED
	}
	return HAM_IGNORED
}
public fw_PostFrame(wpn)
{
	static id
	id = get_pdata_cbase(wpn, m_pPlayer, 4)

	if(is_user_alive(id) && g_HasRifle[id])
	{
		static Float:flNextAttack, iBpAmmo, iClip, iInReload
		iInReload = get_pdata_int(wpn, m_fInReload, 4)
		flNextAttack = get_pdata_float(id, m_flNextAttack, 5)
		iBpAmmo = cs_get_user_bpammo(id, CSW_WPN)
		iClip = cs_get_weapon_ammo(wpn)
		
		if(iInReload && flNextAttack <= 0.0)
		{
			new iRemClip = min(WPN_MAXCLIP - iClip, iBpAmmo)
			cs_set_weapon_ammo(wpn, iClip + iRemClip)
			cs_set_user_bpammo(id, CSW_WPN, iBpAmmo-iRemClip)
			iInReload = 0
			set_pdata_int(wpn, m_fInReload, 0, 4)
		}
		static iButton
		iButton = get_user_button(id)

		if((iButton & IN_ATTACK2 && get_pdata_float(wpn, m_flNextSecondaryAttack, 4) <= 0.0) || (iButton & IN_ATTACK && get_pdata_float(wpn, m_flNextPrimaryAttack, 4) <= 0.0))
			return
		
		if(iButton & IN_RELOAD && !iInReload)
		{
			if(iClip >= WPN_MAXCLIP)
			{
				entity_set_int(id, EV_INT_button, iButton & ~IN_RELOAD)
				set_wpnanim(id, 0)
			}
			else if(iClip == WPN_MAXCLIP)
			{
				if(iBpAmmo)
				{
					reload(id, wpn, 1)
				}
			}
		}
	}
}
public fw_Reload_Post(wpn)
{
	static id
	id = get_pdata_cbase(wpn, m_pPlayer, 4)
	
	if(is_user_alive(id) && g_HasRifle[id] && get_pdata_int(wpn, m_fInReload, 4))
	{		
		reload(id, wpn)
	}
}
public primary_attack(id)
{
	set_wpnanim(id, ANIM_FIRE)
	entity_set_vector(id, EV_VEC_punchangle, Float:{ -1.5, 0.0, 0.0 })
	emit_sound(id, CHAN_WEAPON, snd_fire[random_num(0, sizeof snd_fire - 1)], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)

	static iTarget, iBody, iEndOrigin[3], iStartOrigin[3]
	get_user_origin(id, iStartOrigin, 1) 
	get_user_origin(id, iEndOrigin, 3)
	fire_effects(iStartOrigin, iEndOrigin)
	get_user_aiming(id, iTarget, iBody)
	
	new iEnt = create_entity("info_target")
	
	static Float:flOrigin[3]
	IVecFVec(iEndOrigin, flOrigin)
	entity_set_origin(iEnt, flOrigin)
	remove_entity(iEnt)
	
	if(is_user_alive(iTarget))
	{	
		if(HITSD > 0.0)
		{
			static Float:flVelocity[3]
			get_user_velocity(iTarget, flVelocity)
			xs_vec_mul_scalar(flVelocity, HITSD, flVelocity)
			set_user_velocity(iTarget, flVelocity)	
		}
		if(zp_get_user_zombie(iTarget) || zp_get_user_nemesis(iTarget))
		{
			new iHp = pev(iTarget, pev_health)
			new Float:iDamage, iBloodScale
			if(iBody == HIT_HEAD)
			{
				iDamage = DAMAGE
				iBloodScale = 10
			}
			else
			{
				iDamage = DAMAGE*DAMAGE_MULTI
				iBloodScale = 25
			}
			if(iHp > iDamage) 
			{
				make_blood(iTarget, iBloodScale)
				set_pev(iTarget, pev_health, iHp-iDamage)
				damage_effects(iTarget)
			}
			else if(iHp <= iDamage)
			{
				ExecuteHamB(Ham_Killed, iTarget, id, 2)
			}
		}
	}
	else
	{
		emit_sound(id, CHAN_WEAPON, snd_hit[random_num(0, sizeof snd_hit - 1)], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	}
}
stock fire_effects(iStartOrigin[3], iEndOrigin[3])
{
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(0)    
	write_coord(iStartOrigin[0])
	write_coord(iStartOrigin[1])
	write_coord(iStartOrigin[2])
	write_coord(iEndOrigin[0])
	write_coord(iEndOrigin[1])
	write_coord(iEndOrigin[2])
	write_short(g_sprBeam)
	write_byte(1) 
	write_byte(5) 
	write_byte(10) 
	write_byte(25) 
	write_byte(0) 
	write_byte(0)     
	write_byte(255)      
	write_byte(0)      
	write_byte(100) 
	write_byte(0) 
	message_end()
	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(3)
	write_coord(iEndOrigin[0])
	write_coord(iEndOrigin[1])
	write_coord(iEndOrigin[2])
	write_short(g_sprExp)
	write_byte(10)
	write_byte(15)
	write_byte(4)
	message_end()	
}
stock reload(id, wpn, force_reload = 0)
{
	set_pdata_float(id, m_flNextAttack, RELOADSPEED, 5)
	set_wpnanim(id, ANIM_RELOAD)
	emit_sound(id, CHAN_WEAPON, snd_reload[random_num(0, sizeof snd_reload - 1)], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	
	if(force_reload)
		set_pdata_int(wpn, m_fInReload, 1, 4)
}
stock damage_effects(id)
{
	message_begin(MSG_ONE_UNRELIABLE, g_msgDamage, _, id)
	write_byte(0)
	write_byte(0)
	write_long(DMG_NERVEGAS)
	write_coord(0) 
	write_coord(0)
	write_coord(0)
	message_end()
	
	message_begin(MSG_ONE_UNRELIABLE, g_msgScreenFade, {0,0,0}, id)
	write_short(1<<13)
	write_short(1<<14)
	write_short(0x0000)
	write_byte(0)
	write_byte(255)
	write_byte(0)
	write_byte(100) 
	message_end()
		
	message_begin(MSG_ONE, g_msgScreenShake, {0,0,0}, id)
	write_short(0xFFFF)
	write_short(1<<13)
	write_short(0xFFFF) 
	message_end()
}
stock make_blood(id, scale)
{
	new Float:iVictimOrigin[3]
	pev(id, pev_origin, iVictimOrigin)
	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY) 
	write_byte(115)
	write_coord(floatround(iVictimOrigin[0]+random_num(-20,20))) 
	write_coord(floatround(iVictimOrigin[1]+random_num(-20,20))) 
	write_coord(floatround(iVictimOrigin[2]+random_num(-20,20))) 
	write_short(g_sprBlood)
	write_short(g_sprBlood) 
	write_byte(248) 
	write_byte(scale) 
	message_end()
}
stock set_wpnanim(id, anim)
{
	entity_set_int(id, EV_INT_weaponanim, anim)
	message_begin(MSG_ONE, SVC_WEAPONANIM, {0, 0, 0}, id)
	write_byte(anim)
	write_byte(entity_get_int(id, EV_INT_body))
	message_end()
}
stock make_punch(id, velamount) 
{
	static Float:flNewVelocity[3], Float:flCurrentVelocity[3]
	velocity_by_aim(id, -velamount, flNewVelocity)
	get_user_velocity(id, flCurrentVelocity)
	xs_vec_add(flNewVelocity, flCurrentVelocity, flNewVelocity)
	set_user_velocity(id, flNewVelocity)	
}
stock fm_give_item(index, const item[])
{
	if (!equal(item, "weapon_", 7) && !equal(item, "ammo_", 5) && !equal(item, "item_", 5) && !equal(item, "tf_weapon_", 10))
		return 0;

	new ent = fm_create_entity(item);
	if (!pev_valid(ent))
		return 0;
	
	new Float:origin[3];
	pev(index, pev_origin, origin);
	set_pev(ent, pev_origin, origin);
	set_pev(ent, pev_spawnflags, pev(ent, pev_spawnflags) | SF_NORESPAWN);
	dllfunc(DLLFunc_Spawn, ent);
	
	new save = pev(ent, pev_solid);
	dllfunc(DLLFunc_Touch, ent, index);
	if (pev(ent, pev_solid) != save)
		return ent;
	
	engfunc(EngFunc_RemoveEntity, ent);
	
	return -1;
}

