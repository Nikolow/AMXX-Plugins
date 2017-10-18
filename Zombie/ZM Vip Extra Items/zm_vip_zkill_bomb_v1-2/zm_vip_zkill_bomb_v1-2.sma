/***************************************************************************\
		  ===========================================
		   * || [ZP] Kill Bomb For Zombies v1.2 || *
		  ===========================================

	-------------------
	 *||DESCRIPTION||*
	-------------------

	This plugins adds another extra item to Zombie Plague, A Kill Bomb.
	This item is for zombies and where the grenade is thrown the human 
	who is in range is killed.

	-------------
	 *||CVARS||*
	-------------

	- zp_zkill_bomb_extra_hp 100 
		- How much extra HP is awarded to the zombie who kills the
		  humans through this grenade.

	- zp_zkill_bomb_extra_frags 1
		- No of Frags awarded to zombies who kill humans through this 
		  grenade.
	
	- zp_zkill_bomb_ammo_packs 1
		- No of Ammo packs awarded to zombies who kill humans through this
		  grenade

	- zp_zkill_bomb_nem 1
		- Whether a Nemesis should be given the nade
		
	- zp_zkill_bomb_assassin 1
		- Whether an Assassin should be given the nade

	---------------
	 *||DEFINES||*
	---------------

	- #define EDITTED_VERSION
		- Of u use the editted version of ZP with Sniper And Assassin
		  mode than uncomment this.
		 [U need the zombieplaguenew1.3 include for the editted version]

	---------------
	 *||CREDITS||*
	---------------

	- MeRcyLeZZ ----> For some of the code parts
	- NiHiLaNTh ----> For the concussion grenade plugin which was handy
	- Sn!ff3r ------> For the kill bomb plugin 
	- meTaLiCroSS --> For the colour printing function
			  For Fixing a major bug

	------------------
	 *||CHANGE LOG||*
	------------------
	
	v1.0 ====> Initial Release
	v1.1 ====> Added a cvar for whether a nemesis and assassin can 
		   have the nade.
		   Fixed the bug regarding HE grenades
	v1.1 ====> Added a define for EDITTED VERSIONS of ZP
		   Fixed a bug regarding the model 

\***************************************************************************/

// Needed for detecting servers with this plugin
#define FCVAR_FLAGS (FCVAR_SERVER | FCVAR_SPONLY | FCVAR_UNLOGGED)

new const NADE_TYPE_ZKILLBOMB = 7979

/************************************************************\
|                  Customizations Section                    |
|         You can edit here according to your liking         |
\************************************************************/

// This is for those who use the editted version of ZP
// If you use that version then uncomment this line
// By removing the two slashed ( // )
//#define EDITTED_VERSION

// Radius of the explosion of the bomb
// No need to change this [Default=240.0]
new const Float:RADIUS = 240.0

// The trail sprite of the bomb after it is thrown
new const sprite_grenade_trail[] = "sprites/laserbeam.spr"

// The explosion ring sprite
new const sprite_grenade_ring[] = "sprites/shockwave.spr"

// Cost of this grenade in ammo packs
new const item_cost = 20

// Name of this grenade in extra items
new const item_name[] = "Kill Bomb"

// Description of this grenade in extra items
new const item_description[] = "Kills humans"

// The sound emitted when someone buys the grenade
new const recieving_sound[] = "items/9mmclip1.wav"

// The sound emitted when the grenade explodes
new const kill_sound[] = "zombie_plague/grenade_infect.wav"

// Notice given to the player who buys the grenade
new const info_notice[] = { "You have brought a Kill Bomb. Enjoy killing humans !" }

// HUD message given to the player who is Nemesis or Assassin
new const info_notice2[] = { "You have a Kill Bomb. Use it to kill humans !" }

// Model of the grenade
new const model_grenade_infect[] = "models/zombie_plague/v_grenade_infect.mdl"

/************************************************************\
|                  Customizations Ends Here..!!              |
|         You can edit the cvars in the plugin init          |
\************************************************************/

#include <amxmodx>
#include <hamsandwich>
#include <cstrike>
#include <fakemeta_util>
#include <zmvip>
#if defined EDITTED_VERSION
	#include <zombieplaguenew1.3>
#else
	#include <zombieplague>
#endif

// Variables
new item_id
new has_bomb[33]
new cvar_fragsinfect, cvar_ammoinfect, cvar_humanbonushp , cvar_nemnade
#if defined EDITTED_VERSION
new cvar_assnade
#endif
new g_SyncMsg
new g_trailSpr, g_exploSpr, g_msgScoreInfo, g_msgDeathMsg, g_msgAmmoPickup, g_msgSayText 

/************************************************************\
|            [Plugin Initialization And Precache]            |
\************************************************************/

public plugin_init() 
{
	// Registrations
	register_plugin("[ZP] Kill Bomb For Zombies", "1.0", "@bdul!")
	RegisterHam(Ham_Think, "grenade", "fw_ThinkGrenade")
	RegisterHam(Ham_Killed, "player", "fw_PlayerKilled")
	register_forward(FM_SetModel, "fw_SetModel")	
	register_message(get_user_msgid("CurWeapon"), "message_cur_weapon")
	register_message(g_msgAmmoPickup, "message_ammopickup")
	register_event ( "HLTV", "event_round_start", "a", "1=0", "2=0" );
	
	// Cvars [You can edit these to you're liking]
	cvar_humanbonushp = register_cvar("zp_zkill_bomb_extra_hp","100")	
	cvar_fragsinfect = register_cvar("zp_zkill_bomb_extra_frags","1")
	cvar_ammoinfect = register_cvar("zp_zkill_bomb_ammo_packs","1")
	cvar_nemnade = register_cvar("zp_zkill_bomb_nem","1")
	#if defined EDITTED_VERSION
	cvar_assnade = register_cvar("zp_zkill_bomb_assassin","1")
	#endif
	
	// Add the cvar so we can detect it
	register_cvar ( "zp_zkill_bomb", "1.0", FCVAR_FLAGS )
	
	// Register it in the extra items
	item_id = zv_register_extra_item(item_name, item_description, item_cost, ZV_TEAM_ZOMBIE)
	
	// Messages needed for the plugin
	g_msgScoreInfo = get_user_msgid("ScoreInfo")
	g_msgDeathMsg = get_user_msgid("DeathMsg")
	g_msgAmmoPickup = get_user_msgid("AmmoPickup")
	g_msgSayText = get_user_msgid("SayText")
	
	g_SyncMsg = CreateHudSyncObj()
}

public plugin_precache()
{
	// Sprites precache
	g_trailSpr = engfunc(EngFunc_PrecacheModel, sprite_grenade_trail)
	g_exploSpr = engfunc(EngFunc_PrecacheModel, sprite_grenade_ring)
	
	// Model precache
	engfunc(EngFunc_PrecacheModel, model_grenade_infect)
	
	// Sounds precache
	engfunc(EngFunc_PrecacheSound, recieving_sound)
	engfunc(EngFunc_PrecacheSound, kill_sound)
	
}

/************************************************************\
|                     [Main Forwards]                        |
\************************************************************/

// New round started so reset the variable
public event_round_start()
{
	arrayset(has_bomb, false, 33)
}

// Client disconnected so reset the variable
public client_disconnect(id)
{
	has_bomb[id] = 0
}

// Someone was turned into nemesis
public zp_user_infected_post(id, infector)
{
	// Make sure it is a nemesis and the cvar is also on
	if (zp_get_user_nemesis(id) && (get_pcvar_num(cvar_nemnade) == 1))
		give_the_bomb(id) // Give him the bomb

	#if defined EDITTED_VERSION
	// Make sure it is an assassin and the cvar is also on
	else if (zp_get_user_assassin(id) && (get_pcvar_num(cvar_assnade) == 1))
		give_the_bomb(id) // Give him the bomb
	#endif
}

// Someone selected our extra item
public zv_extra_item_selected(id, itemid)
{
	// Make sure that the selected item is our item
	if(itemid == item_id)
	{	
		// Give him the bomb
		give_the_bomb(id)
	}
}

// The player turned back to a human
public zp_user_humanized_post ( Player, Survivor )
{
	// He doesn't haves the nade anymore
	if (has_bomb[Player])
		has_bomb[Player] = 0
}

// Player got killed reset the variable
public fw_PlayerKilled(victim, attacker, shouldgib)
{
	has_bomb[victim] = 0	
}

public fw_ThinkGrenade(entity)
{    
	if(!pev_valid(entity))
		return HAM_IGNORED
        
	static Float:dmgtime    
	pev(entity, pev_dmgtime, dmgtime)
    
	if (dmgtime > get_gametime())
		return HAM_IGNORED    
    
	if(pev(entity, pev_flTimeStepSound) == NADE_TYPE_ZKILLBOMB)
	{
		kill_explode(entity)
		return HAM_SUPERCEDE
	}
    
	return HAM_IGNORED
} 

public fw_SetModel(entity, const model[])
{
	static Float:dmgtime
	pev(entity, pev_dmgtime, dmgtime)
	
	if (dmgtime == 0.0)
		return
	
	if (equal(model[7], "w_sm", 4))
	{	
		// Check whos is the owner of the nade
		new owner = pev(entity, pev_owner)		
		
		// Make sure only a zombie can own it
		if(zp_get_user_zombie(owner) && has_bomb[owner]) 
		{	
			// Set the glow on the model
			fm_set_rendering(entity, kRenderFxGlowShell, 255, 128, 0, kRenderNormal, 16)
			
			// Set the trail sprite 
			message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
			write_byte(TE_BEAMFOLLOW) // TE id
			write_short(entity) // entity
			write_short(g_trailSpr) // sprite
			write_byte(10) // life
			write_byte(10) // width
			write_byte(255) // r
			write_byte(128) // g
			write_byte(0) // b
			write_byte(200) // brightness
			message_end()
			
			set_pev(entity, pev_flTimeStepSound, NADE_TYPE_ZKILLBOMB)
		}
	}
	
}

/************************************************************\
|                     [Main funtions]                        |
\************************************************************/

// Grenade has exploded
public kill_explode(ent)
{
	// Has the round started ?
	if (!zp_has_round_started()) return
	
	// Get the Origin
	static Float:originF[3]
	pev(ent, pev_origin, originF)
	
	// Create the blast
	create_blast(originF)
	
	// Emit explosion sound
	engfunc(EngFunc_EmitSound, ent, CHAN_ITEM, kill_sound, 1.0, ATTN_NORM, 0, PITCH_NORM)
	
	// Get the attacker
	static attacker
	attacker = pev(ent, pev_owner)
	has_bomb[attacker] = 0
	
	// Collisions
	static victim , deathmsg_block
	
	// Get the current state of DeathMsg
	deathmsg_block = get_msg_block(g_msgDeathMsg)
	
	// Set it to be blocked [Bug Fix]
	set_msg_block(g_msgDeathMsg, BLOCK_SET)
	victim = -1
	
	#if defined EDITTED_VERSION
	while ((victim = engfunc(EngFunc_FindEntityInSphere, victim, originF, RADIUS)) != 0)
	{
		// If dead, zombie, survivor or sniper then continue the loop
		if (!is_user_alive(victim) || zp_get_user_zombie(victim) || zp_get_user_survivor(victim)|| zp_get_user_sniper(victim))
			continue;
		
		// Send the Death message
		SendDeathMsg(attacker, victim)
		
		// Update the frags
		UpdateFrags(attacker, victim, get_pcvar_num(cvar_fragsinfect), 1, 1)
		
		// Kill the victim
		user_kill(victim, 0)
		
		// Set the attackers ammo packs
		zp_set_user_ammo_packs(attacker,zp_get_user_ammo_packs(attacker) + get_pcvar_num(cvar_ammoinfect))
		
		// Set the attackers health
		fm_set_user_health(attacker, pev(attacker, pev_health)+get_pcvar_num(cvar_humanbonushp))
	}
	#else
	while ((victim = engfunc(EngFunc_FindEntityInSphere, victim, originF, RADIUS)) != 0)
	{
		// If dead, zombie, survivor then continue the loop
		if (!is_user_alive(victim) || zp_get_user_zombie(victim) || zp_get_user_survivor(victim))
			continue;
		
		// Send the Death message
		SendDeathMsg(attacker, victim)
		
		// Update the frags
		UpdateFrags(attacker, victim, get_pcvar_num(cvar_fragsinfect), 1, 1)
		
		// Kill the victim
		user_kill(victim, 0)
		
		// Set the attackers ammo packs
		zp_set_user_ammo_packs(attacker,zp_get_user_ammo_packs(attacker) + get_pcvar_num(cvar_ammoinfect))
		
		// Set the attackers health
		fm_set_user_health(attacker, pev(attacker, pev_health)+get_pcvar_num(cvar_humanbonushp))
	}
	#endif
	
	// Set the previous blocking state
	set_msg_block(g_msgDeathMsg, deathmsg_block)
	
	// Get the rid of the grenade
	engfunc(EngFunc_RemoveEntity, ent)
}

// This function creates the rings when the grenade explodes
public create_blast(const Float:originF[3])
{
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0)
	write_byte(TE_BEAMCYLINDER) // TE id
	engfunc(EngFunc_WriteCoord, originF[0]) // x
	engfunc(EngFunc_WriteCoord, originF[1]) // y
	engfunc(EngFunc_WriteCoord, originF[2]) // z
	engfunc(EngFunc_WriteCoord, originF[0]) // x axis
	engfunc(EngFunc_WriteCoord, originF[1]) // y axis
	engfunc(EngFunc_WriteCoord, originF[2]+385.0) // z axis
	write_short(g_exploSpr) // sprite
	write_byte(0) // startframe
	write_byte(0) // framerate
	write_byte(4) // life
	write_byte(60) // width
	write_byte(0) // noise
	write_byte(255) // red
	write_byte(128) // green
	write_byte(0) // blue
	write_byte(200) // brightness
	write_byte(0) // speed
	message_end()
	
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0)
	write_byte(TE_BEAMCYLINDER) // TE id
	engfunc(EngFunc_WriteCoord, originF[0]) // x
	engfunc(EngFunc_WriteCoord, originF[1]) // y
	engfunc(EngFunc_WriteCoord, originF[2]) // z
	engfunc(EngFunc_WriteCoord, originF[0]) // x axis
	engfunc(EngFunc_WriteCoord, originF[1]) // y axis
	engfunc(EngFunc_WriteCoord, originF[2]+470.0) // z axis
	write_short(g_exploSpr) // sprite
	write_byte(0) // startframe
	write_byte(0) // framerate
	write_byte(4) // life
	write_byte(60) // width
	write_byte(0) // noise
	write_byte(255) // red
	write_byte(164) // green
	write_byte(0) // blue
	write_byte(200) // brightness
	write_byte(0) // speed
	message_end()
	
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0)
	write_byte(TE_BEAMCYLINDER) // TE id
	engfunc(EngFunc_WriteCoord, originF[0]) // x
	engfunc(EngFunc_WriteCoord, originF[1]) // y
	engfunc(EngFunc_WriteCoord, originF[2]) // z
	engfunc(EngFunc_WriteCoord, originF[0]) // x axis
	engfunc(EngFunc_WriteCoord, originF[1]) // y axis
	engfunc(EngFunc_WriteCoord, originF[2]+555.0) // z axis
	write_short(g_exploSpr) // sprite
	write_byte(0) // startframe
	write_byte(0) // framerate
	write_byte(4) // life
	write_byte(60) // width
	write_byte(0) // noise
	write_byte(255) // red
	write_byte(200) // green
	write_byte(0) // blue
	write_byte(200) // brightness
	write_byte(0) // speed
	message_end()
}

// Updates the frags of the attacker
public UpdateFrags(attacker, victim, frags, deaths, scoreboard)
{
	// Set the frags
	set_pev(attacker, pev_frags, float(pev(attacker, pev_frags) + frags))
	
	// Set the deaths
	fm_set_user_deaths(victim, fm_get_user_deaths(victim) + deaths)
	
	// Update scoreboard
	if (scoreboard)
	{	
		message_begin(MSG_BROADCAST, g_msgScoreInfo)
		write_byte(attacker) // id
		write_short(pev(attacker, pev_frags)) // frags
		write_short(fm_get_user_deaths(attacker)) // deaths
		write_short(0) // class?
		write_short(fm_get_user_team(attacker)) // team
		message_end()
		
		message_begin(MSG_BROADCAST, g_msgScoreInfo)
		write_byte(victim) // id
		write_short(pev(victim, pev_frags)) // frags
		write_short(fm_get_user_deaths(victim)) // deaths
		write_short(0) // class?
		write_short(fm_get_user_team(victim)) // team
		message_end()
	}
}

// Send the death message
public SendDeathMsg(attacker, victim)
{
	message_begin(MSG_BROADCAST, g_msgDeathMsg)
	write_byte(attacker) // killer
	write_byte(victim) // victim
	write_byte(0) // headshot flag
	write_string("infection") // killer's weapon
	message_end()
}

// Replace models
public replace_models(id)
{
	if (!is_user_alive(id))
		return
	
	if(get_user_weapon(id) == CSW_SMOKEGRENADE && has_bomb[id])
	{
		set_pev(id, pev_viewmodel2, model_grenade_infect)
		
	}
}

public message_cur_weapon(msg_id, msg_dest, msg_entity)
{
	replace_models(msg_entity)
}

give_the_bomb(id)
{
	// Now he haves the bomb!
	has_bomb[id] = 1
	
	#if defined EDITTED_VERSION
	// Make sure that the person is not an Assassin or Nemesis
	if (!zp_get_user_nemesis(id) && !zp_get_user_assassin(id))
		// Notify him
		zp_colored_print(id, "|g|[ZP]|y| %s", info_notice)
	#else  // Person is using a normal ZP 4.3
	// Make sure that the person is not a Nemesis
	if (!zp_get_user_nemesis(id))
		// Notify him
		zp_colored_print(id, "|g|[ZP]|y| %s", info_notice)
	#endif
	
	#if defined EDITTED_VERSION
	// If the person is Nemesis or Assassin notify him through HUD message
	if (zp_get_user_nemesis(id) || zp_get_user_assassin(id))
	{
		set_hudmessage(250, 120, 5, -1.0, 0.25, 2, 2.0, 10.0)
		ShowSyncHudMsg(id, g_SyncMsg,"%s", info_notice2)
	}
	#else // Person is using a normal ZP 4.3
	// If the person is Nemesis notify him through HUD message
	if (zp_get_user_nemesis(id))
	{
		set_hudmessage(250, 120, 5, -1.0, 0.25, 2, 2.0, 10.0)
		ShowSyncHudMsg(id, g_SyncMsg,"%s", info_notice2)
	}
	#endif
	
	// Already own one
	if (user_has_weapon(id, CSW_SMOKEGRENADE))
	{
		// Increase BP ammo on it instead
		cs_set_user_bpammo(id, CSW_SMOKEGRENADE, cs_get_user_bpammo(id, CSW_SMOKEGRENADE) + 1)
		
		// Flash the ammo in hud
		message_begin(MSG_ONE_UNRELIABLE, g_msgAmmoPickup, _, id)
		write_byte(CSW_SMOKEGRENADE)
		write_byte(1)
		message_end()
		
		// Play Clip Purchase Sound
		engfunc(EngFunc_EmitSound, id, CHAN_ITEM, recieving_sound, 1.0, ATTN_NORM, 0, PITCH_NORM)
	}
	else
		// Give weapon to the player
		fm_give_item(id, "weapon_smokegrenade")
}

/************************************************************\
|                     [Stock funtions]                       |
\************************************************************/

stock fm_set_user_deaths(id, value)
{
	set_pdata_int(id, 444, value, 5)
}

stock fm_get_user_deaths(id)
{
	return get_pdata_int(id, 444, 5)
}


stock fm_get_user_team(id)
{
	return get_pdata_int(id, 114, 5)
}

// Prints chat in colours [ BY meTaLiCroSS ]
stock zp_colored_print(const id, const input[], any:...)
{
	new iCount = 1, iPlayers[32]
	
	static szMsg[191]
	vformat(szMsg, charsmax(szMsg), input, 3)
	
	replace_all(szMsg, 190, "|g|", "^4") // green txt
	replace_all(szMsg, 190, "|y|", "^1") // orange txt
	replace_all(szMsg, 190, "|ctr|", "^3") // team txt
	replace_all(szMsg, 190, "|w|", "^0") // team txt
	
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
