/*================================================================================
 
 -----------------------------------
 -*- [ZP] Extra Item : Player Aura -*-
 -----------------------------------
 
 ~~~~~~~~~~~~~~~
 - Description -
 ~~~~~~~~~~~~~~~
 
 This is just an extra item which gives the player a player aura. The player
 aura helps players to navigate and find zombies throughout the map. 

 ~~~~~~~~~~~~~~~
 - CVARS -
 ~~~~~~~~~~~~~~~
 ("zp_aura_radius", "20.0")
 This is the radius of the aura. 
 ("zp_aura_red", "255")
 This is the red colour of the aura. 
 ("zp_aura_green", "255")
 This is the green colour of the aura. 
 ("zp_aura_blue", "255")
 This is the blue colour of the aura. 
 ("zp_glow_on", "1")
 This is to have a glow or not. 
 ("zp_aura_round", "1")
 This is whether or not to remove aura every round. 
 
 ~~~~~~~~~~~~~~~
 - Change Logs -
 ~~~~~~~~~~~~~~~
 Version : 1.0
 First Release. 

 Version : 1.1
 Added some codes, removed hamsandwich module which wasnt required. 

 Version : 1.2
 Changed almost all of the codes, thanks to alan_el_more for his help. 

 Version : 1.3
 Fixed bug with some codes where player doesnt get aura after buying it. 
 (Had to change most of the codes back to the old ones. Sorry alan_el_more)

 Version : 1.4
 Added a CVAR for players to have a glow or not. 
 Also updated codes so that you lose the aura on every respawn. 

 Version : 1.5
 Want to have the aura every round? Added a CVAR for that. 
 Check the CVARs section above for the information. 
 
 Version : 1.6
 Fixed a minor misplacement of a code. Glow color should be okay now. 

================================================================================*/

#include <amxmodx>
#include <fakemeta>
#include <fakemeta_util>
#include <zombieplague>
#include <zmvip>

/*================================================================================
 [Plugin Customization]
=================================================================================*/

new const g_item_name[] = { "Player Aura" }
new const g_item_discription[] = { "Gives aura & glow" }
const g_item_cost = 10
new const g_sound_buyaura[] = { "items/nvg_on.wav" }

/*============================================================================*/

new g_itemid_playeraura, g_extra_glow, g_aura_round

public plugin_precache()
{
	precache_sound(g_sound_buyaura)
}

public plugin_init()
{
	register_plugin("[ZP] Extra Item: Player Aura", "1.6", "Zombie Lurker")
	
	g_itemid_playeraura = zv_register_extra_item(g_item_name, g_item_discription, g_item_cost, ZV_TEAM_HUMAN)
	g_extra_glow = register_cvar("zp_glow_on", "1")
	g_aura_round = register_cvar("zp_aura_round", "1")
	
	register_cvar("zp_aura_radius", "20.0")
	register_cvar("zp_aura_red", "255")
	register_cvar("zp_aura_green", "255")
	register_cvar("zp_aura_blue", "255")
}

public zv_extra_item_selected(player, itemid)
{
if (itemid == g_itemid_playeraura)
{
set_task(0.1, "BUYAURA", player, _, _, "b")
set_task(0.2, "BUYGLOW", player, _, _, "b")
engfunc(EngFunc_EmitSound, player, CHAN_BODY, g_sound_buyaura, 1.0, ATTN_NORM, 0, PITCH_NORM)
}
}

public BUYAURA(player)
{
if ((!zp_get_user_zombie(player)) && (is_user_alive(player)))
{
	static Float:originF[3]
	pev(player, pev_origin, originF)
	
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0)
	write_byte(TE_DLIGHT)
	engfunc(EngFunc_WriteCoord, originF[0]) // x
	engfunc(EngFunc_WriteCoord, originF[1]) // y
	engfunc(EngFunc_WriteCoord, originF[2]) // z
	write_byte(get_cvar_num("zp_aura_radius")) // radius
	write_byte(get_cvar_num("zp_aura_red")) // red
	write_byte(get_cvar_num("zp_aura_green")) // green
	write_byte(get_cvar_num("zp_aura_blue")) // blue
	write_byte(2) // life
	write_byte(0) // decay rate
	message_end()
	}
	else
	{
	if (get_pcvar_num(g_aura_round))
		remove_task(player)
	}
return PLUGIN_CONTINUE
}

public BUYGLOW(player)
{
if ((!zp_get_user_zombie(player)) && (is_user_alive(player)) && (get_pcvar_num(g_extra_glow)))
{
	fm_set_rendering(player, kRenderFxGlowShell, (get_cvar_num("zp_aura_red")), (get_cvar_num("zp_aura_green")), (get_cvar_num("zp_aura_blue")), kRenderNormal, 16);
	}
return PLUGIN_CONTINUE
}
