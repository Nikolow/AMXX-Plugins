#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <cstrike>
#include <csx>
#include <fun>
#include <fakemeta_util>

#define AUTHORS "SAMURAI & Black Rose"

#define ADMIN_ACCESS ADMIN_KICK

#define ICON_R 255
#define ICON_G 170
#define ICON_B 0

#define ANTI_LAGG 7.0	// Defines max calculations before a flame is spawned without check if onground
// This is  to prevent lagg at really narrow ents where you could end up with 400 calculations per flame
// Suggested: <= 10

new pnumplugin, pprice, pMlDamage, pMlRadius, pFireTime, pOverride;
new pTeamKill, pFireDmg, pMaxMolotovs, pBuyMenu, pBuyZone;

new gmsgScoreInfo, gmsgDeathMsg;

new g_pAllocModel, g_vAllocModel;

new g_frags[33];
new g_hasMolotov[33];
new g_restarted;
new g_MaxPlayers;
new g_bomb_map;

new firespr, smokespr[2];


public plugin_init() {
	
	register_plugin("Molotov Cocktail", "3.1c", AUTHORS);
	
	register_clcmd("say /molotov","buy_molotov");
	register_clcmd("say molotov","buy_molotov");
	register_concmd("molotov_give", "cmd_MolotovGive", ADMIN_ACCESS);
	register_concmd("molotov_override", "cmd_Override", ADMIN_ACCESS);
	register_concmd("molotov_cocktail", "cmd_PluginStatus", ADMIN_ACCESS);
	
	pnumplugin = register_cvar("molotov_tempcocktail","1", FCVAR_SPONLY);
	pOverride = register_cvar("molotov_tempoverride", "1", FCVAR_SPONLY); 
	
	pprice = register_cvar("molotov_price","1200");
	pMlDamage = register_cvar("molotov_damage","40.0");
	pMlRadius = register_cvar("molotov_radius","200.0");
	pFireTime = register_cvar("molotov_firetime", "6");
	pFireDmg = register_cvar("molotov_firedamage", "1");
	pTeamKill = register_cvar("molotov_tk", "0");
	pMaxMolotovs = register_cvar("molotov_max", "1");
	pBuyMenu = register_cvar("molotov_inmenu", "0");
	pBuyZone = register_cvar("molotov_buyzone", "0");
	
	register_event("CurWeapon", "Event_CurWeapon","be", "1=1");
	register_event("HLTV","event_new_round", "a","1=0", "2=0");
	register_event("TextMsg","Event_GameRestart","a","2=#Game_Commencing","2=#Game_will_restart_in");
	register_event("DeathMsg", "event_DeathMsg", "a");
	
	register_event("ShowMenu", "event_BuyMenuT", "b", "4=#T_BuyItem", "1=575");
	register_event("ShowMenu", "event_BuyMenuCT", "b", "4=#CT_BuyItem", "1=703");
	register_event("ShowMenu", "event_BuyMenuT", "b", "4=#DT_BuyItem", "1=575");
	register_event("ShowMenu", "event_BuyMenuCT", "b", "4=#DCT_BuyItem", "1=767");
	
	register_menucmd(register_menuid("#CT_BuyItem"), 1023, "handle_BuyMenuCT");
	register_menucmd(register_menuid("#T_BuyItem"), 1023, "handle_BuyMenuT");
	
	register_forward(FM_EmitSound, "fw_EmitSound");
	
	g_MaxPlayers = get_maxplayers();
	
	gmsgScoreInfo = get_user_msgid("ScoreInfo");
	gmsgDeathMsg = get_user_msgid("DeathMsg");
	
	g_pAllocModel = engfunc(EngFunc_AllocString, "models/p_molotov.mdl");
	g_vAllocModel = engfunc(EngFunc_AllocString, "models/v_molotov.mdl");
	
	g_bomb_map = engfunc(EngFunc_FindEntityByString, g_MaxPlayers, "classname", "info_bomb_target") ? 1 : 0;
}

public cmd_Override(id,level,cid) {	
	
	if ( ! cmd_access(id, level,cid,1) ) 
		return PLUGIN_HANDLED;
	
	
	if ( ! get_pcvar_num(pnumplugin) )
		return PLUGIN_HANDLED;
	
	new arg[2];
	read_argv(1, arg, 1);
	
	new num = str_to_num(arg);
	
	if ( 1 < num < 0 ) {
		if ( id )
			client_print(id, print_console, "Invalid argument(%d). Valid arguments are ^"0^" and ^"1^".", num);
		else
			server_print("Invalid argument(%d). Valid arguments are ^"0^" and ^"1^".", num);
		return PLUGIN_HANDLED;
	}
	
	if ( num == get_pcvar_num(pOverride) ) {
		if ( id )
			client_print(id, print_console, "Override is already %s.", num ? "enabled" : "disabled");
		else
			server_print("Override is already %s.", num ? "enabled" : "disabled");
		return PLUGIN_HANDLED;
	}
	
	set_pcvar_num(pOverride, num);
	
	if ( id )
		client_print(id, print_console, "Override was %s.", num ? "enabled" : "disabled");
	else
		server_print("Override was %s.", num ? "enabled" : "disabled");
	
	if ( num )
		set_molotovs();
	else
		reset_molotovs();
	
	return PLUGIN_HANDLED;
}

public cmd_PluginStatus(id,level,cid) {
	
	if ( ! cmd_access(id,level,cid,2))  	
		return PLUGIN_HANDLED;
	
	
	new arg[2];
	read_argv(1, arg, 1);
	
	new num = str_to_num(arg);
	
	if ( 1 < num < 0 ) {
		if ( id )
			client_print(id, print_console, "Invalid argument(%d). Valid arguments are ^"0^" and ^"1^".", num);
		else
			server_print("Invalid argument(%d). Valid arguments are ^"0^" and ^"1^".", num);
		return PLUGIN_HANDLED;
	}
	
	if ( num == get_pcvar_num(pnumplugin) ) {
		if ( id )
			client_print(id, print_console, "Plugin is already %s.", num ? "enabled" : "disabled");
		else
			server_print("Plugin is already %s.", num ? "enabled" : "disabled");
		return PLUGIN_HANDLED;
	}
	
	set_pcvar_num(pnumplugin, num);
	
	if ( id )
		client_print(id, print_console, "Plugin was %s.", num ? "enabled" : "disabled");
	else
		server_print("Plugin was %s.", num ? "enabled" : "disabled");
	
	if ( num && get_pcvar_num(pOverride) )
		set_molotovs();
	else
		reset_molotovs();
	
	return PLUGIN_HANDLED;
}

public cmd_MolotovGive(id,level,cid) {
	
	if( !cmd_access(id,level,cid,2) ) 
		return PLUGIN_HANDLED;
	
	
	if ( ! get_pcvar_num(pnumplugin) )
		return PLUGIN_HANDLED;
	
	new arg[32];
	read_argv(1, arg, 31);
	
	new target;
	
	if ( ! arg[0] ) {
		if ( id )
			target = id;
		else
			server_print("You have to enter a name of a client to give the molotov to");
	}
	else
		target = cmd_target(id, arg, 6);
	
	if ( ! target ) 
	{
		id ? client_print(id, print_console, "None or multiple clients found with that name.") : server_print("None or multiple clients found with that name.");
		return PLUGIN_HANDLED;
	}
	
	if ( g_hasMolotov[target] == get_pcvar_num(pMaxMolotovs) ) {
		if ( g_hasMolotov[target] == 1 ) {
			if ( id )
				client_print(id, print_center, "Client already have a Molotov Cocktail.");
			else
				server_print("Client already have a Molotov Cocktail.");
		}
		else {
			if ( id )
				client_print(id, print_center, "Client already have %d Molotov Cocktails.", g_hasMolotov[target]);
			else
				server_print("Client already have %d Molotov Cocktails.", g_hasMolotov[target]);
		}
		
		return PLUGIN_CONTINUE;
	}
	
	if ( ! g_hasMolotov[target] && user_has_weapon(target, CSW_HEGRENADE) ) {
		if ( id )
			client_print(id, print_console, "Client already has a HE Grenade");
		else
			server_print("Client already has a HE Grenade");
		return PLUGIN_HANDLED;
	}
	
	g_hasMolotov[target]++;
	
	give_item(target, "weapon_hegrenade");
	cs_set_user_bpammo(target, CSW_HEGRENADE, g_hasMolotov[id]);
	client_print(target, print_chat, "You got a Molotov Cocktail!");
	
	return PLUGIN_HANDLED;
}

public buy_molotov(id) {
	
	if ( ! get_pcvar_num(pnumplugin) )
		return PLUGIN_HANDLED;
	
	if ( get_pcvar_num(pOverride) ) {
		if ( get_pcvar_num(pBuyMenu) )
			client_print(id, print_center, "Buy them in the buy equipment menu.");
		else
			client_print(id, print_center, "Just buy a hegrenade and get molotov automaticly!");
		return PLUGIN_HANDLED;
	}
	
	if ( ! is_user_alive(id) ) {
		client_print(id, print_center, "You can't buy Molotov Cocktails because you are dead.");
		return PLUGIN_HANDLED;
	}
	
	if ( ! cs_get_user_buyzone(id) && get_pcvar_num(pBuyZone) ) {
		client_print(id, print_center, "You are not in a buyzone.");
		return PLUGIN_HANDLED;
	}
	
	new money = cs_get_user_money(id);
	
	if ( money < get_pcvar_num(pprice) ) {
		client_print(id, print_center, "You don't have enough $ to buy a Molotov Cocktail.");
		return PLUGIN_HANDLED;
	}
	
	if ( g_hasMolotov[id] == get_pcvar_num(pMaxMolotovs) ) {
		if ( g_hasMolotov[id] == 1 )
			client_print(id, print_center, "You already have a Molotov Cocktail.");
		else
			client_print(id, print_center, "You already have %d Molotov Cocktails.", g_hasMolotov[id]);
		return PLUGIN_HANDLED;
	}
	
	if ( ! g_hasMolotov[id] && user_has_weapon(id, CSW_HEGRENADE) ) {
		client_print(id, print_center, "You already have a HE Grenade");
		return PLUGIN_HANDLED;
	}
	
	g_hasMolotov[id]++;
	
	cs_set_user_money(id, money - get_pcvar_num(pprice) );
	give_item(id, "weapon_hegrenade");
	cs_set_user_bpammo(id, CSW_HEGRENADE, g_hasMolotov[id]);
	client_print(id, print_chat, "You got a Molotov Cocktail!");
	
	return PLUGIN_HANDLED;
}

public plugin_precache() {
	
	precache_model("models/p_molotov.mdl");
	precache_model("models/v_molotov.mdl");
	precache_model("models/w_molotov.mdl");
	
	firespr = precache_model("sprites/flame.spr");
	
	smokespr[0] = precache_model("sprites/black_smoke3.spr");
	smokespr[1] = precache_model("sprites/steam1.spr");
	
	precache_sound("misc/molotov_fire.wav");
	precache_sound("misc/molotov_explosion.wav");
}

public fw_EmitSound(ent, channel, sample[]) {
	
	if ( equal(sample[8], "he_bounce", 9) ) {
		
		new model[32];
		pev(ent, pev_model, model, 31);
		
		if ( equal(model[9], "molotov.mdl") )
			grenade_explode(ent);
	}
}

public Event_CurWeapon(id) {
	
	if ( ! get_pcvar_num(pnumplugin) || ! is_user_alive(id) )
		return PLUGIN_CONTINUE;
	
	if ( ! g_hasMolotov[id] && ! get_pcvar_num(pOverride) )
		return PLUGIN_CONTINUE;
	
	new WeaponID = get_user_weapon(id, WeaponID, WeaponID);
	
	if ( WeaponID != CSW_HEGRENADE )
		return PLUGIN_CONTINUE;
	
	set_pev(id, pev_viewmodel, g_vAllocModel);
	set_pev(id, pev_weaponmodel, g_pAllocModel);
	set_pev(id, pev_weaponanim, 9);
	
	return PLUGIN_CONTINUE;
}

public Event_GameRestart() g_restarted = 1;

public event_DeathMsg() g_hasMolotov[read_data(2)] = 0;

public event_new_round() {
	
	if ( ! get_pcvar_num(pnumplugin) )
		return PLUGIN_CONTINUE;
	
	for ( new i ; i < g_MaxPlayers ; i++ ) {
		if ( g_frags[i] && is_user_connected(i) )
			set_user_frags(i, get_user_frags(i) + g_frags[i]);
		g_frags[i] = 0;
	}
	
	if ( g_restarted ) {
		for ( new i ; i < g_MaxPlayers ; i++ )
			g_hasMolotov[i] = 0;
		g_restarted = 0;
	}
	
	if ( get_pcvar_num(pOverride) )
		set_molotovs();
	else
		reset_molotovs();
	
	return PLUGIN_CONTINUE;
}

public event_BuyMenuCT(id) {
	
	if ( ! get_pcvar_num(pnumplugin) || ! get_pcvar_num(pBuyMenu) )
		return PLUGIN_CONTINUE;
	
	new Override = get_pcvar_num(pOverride);
	
	new menu[1024];
	new len = formatex(menu, 1023, "\yBuy Equipment\R$ Cost");
	len += formatex(menu[len], 1023-len, "^n^n\w1. Kevlar Vest\R\y650");
	len += formatex(menu[len], 1023-len, "^n\w2. Kevlar Vest & Helmet\R\y1000");
	len += formatex(menu[len], 1023-len, "^n\w3. Flashbang\R\y200");
	
	if ( Override )
		len += formatex(menu[len], 1023-len, "^n\w4. Molotov Cocktail\R\y%d", get_pcvar_num(pprice));
	else 
		len += formatex(menu[len], 1023-len, "^n\w4. HE Grenade\R\y300");
	
	len += formatex(menu[len], 1023-len, "^n\w5. Smoke Grenade\R\y300");
	len += formatex(menu[len], 1023-len, "^n\w6. NightVision Goggles\R\y1250");
	len += formatex(menu[len], 1023-len, "^n\%c7. Defuse Kit\R\y200 ", g_bomb_map ? 'w' : 'd');
	len += formatex(menu[len], 1023-len, "^n\w8. Tactical Shield\R\y2200");
	
	if ( ! Override )
		len += formatex(menu[len], 1023-len, "^n\w9. Molotov Cocktail\R\y%d", get_pcvar_num(pprice));
	
	len += formatex(menu[len], 1023-len, "^n^n\w0. Exit");
	
	show_menu(id, read_data(1)|MENU_KEY_9, menu, -1, "#CT_BuyItem");
	
	return PLUGIN_HANDLED;
}

public event_BuyMenuT(id) {
	
	if ( ! get_pcvar_num(pnumplugin) || ! get_pcvar_num(pBuyMenu) )
		return PLUGIN_CONTINUE;
	
	new Override = get_pcvar_num(pOverride);
	
	new menu[1024];
	new len = formatex(menu, 1023, "\yBuy Equipment\R$ Cost");
	len += formatex(menu[len], 1023-len, "^n^n\w1. Kevlar Vest\R\y650");
	len += formatex(menu[len], 1023-len, "^n\w2. Kevlar Vest & Helmet\R\y1000");
	len += formatex(menu[len], 1023-len, "^n\w3. Flashbang\R\y200");
	
	if ( Override )
		len += formatex(menu[len], 1023-len, "^n\w4. Molotov Cocktail\R\y%d", get_pcvar_num(pprice));
	else
		len += formatex(menu[len], 1023-len, "^n\w4. HE Grenade\R\y300");
	
	len += formatex(menu[len], 1023-len, "^n\w5. Smoke Grenade\R\y300");
	len += formatex(menu[len], 1023-len, "^n\w6. NightVision Goggles\R\y1250");
	
	if ( !Override )
		len += formatex(menu[len], 1023-len, "^n\w7. Molotov Cocktail\R\y%d", get_pcvar_num(pprice));
	
	len += formatex(menu[len], 1023-len, "^n^n\w0. Exit");
	
	show_menu(id, read_data(1)|MENU_KEY_7, menu, -1, "#T_BuyItem");
	
	return PLUGIN_HANDLED;
}

public handle_BuyMenuCT(id, key) 
{
	 
	if ( get_pcvar_num(pOverride) ) 
	{
		if ( key != 3 )
		return PLUGIN_CONTINUE;
	}
    
	else 
	{
		if ( key != 8 )
		return PLUGIN_CONTINUE;
	}
    
	handle_BuyMenu(id);
    
	return PLUGIN_HANDLED;
}

public handle_BuyMenuT(id, key) 
{
    
	if ( get_pcvar_num(pOverride) ) 
	{
		if ( key != 3 )
		return PLUGIN_CONTINUE;
	}
    
	else 
	{
		if ( key != 6 )
		return PLUGIN_CONTINUE;
	}
    
	handle_BuyMenu(id);
    
	return PLUGIN_HANDLED;
}

stock handle_BuyMenu(id) {
	
	new money = cs_get_user_money(id);
	
	if ( money < get_pcvar_num(pprice) ) {
		client_print(id, print_center, "You don't have enough $ to buy a Molotov Cocktail.");
		return PLUGIN_HANDLED;
	}
	
	if ( g_hasMolotov[id] == get_pcvar_num(pMaxMolotovs) ) {
		if ( g_hasMolotov[id] == 1 )
			client_print(id, print_center, "You already have a Molotov Cocktail.");
		else
			client_print(id, print_center, "You already have %d Molotov Cocktails.", g_hasMolotov[id]);
		return PLUGIN_HANDLED;
	}
	
	else if ( ! g_hasMolotov[id] && user_has_weapon(id, CSW_HEGRENADE) ) {
		client_print(id, print_center, "You already have a HE Grenade");
		return PLUGIN_HANDLED;
	}
	
	g_hasMolotov[id]++;
	
	cs_set_user_money(id, money - get_pcvar_num(pprice) );
	give_item(id, "weapon_hegrenade");
	cs_set_user_bpammo(id, CSW_HEGRENADE, g_hasMolotov[id]);
	client_print(id, print_chat, "You got a Molotov Cocktail!");
	
	return PLUGIN_HANDLED;
}

public grenade_throw(id, ent, wid) {
	
	if ( ! get_pcvar_num(pnumplugin) || ! is_user_connected(id) || wid != CSW_HEGRENADE )
		return PLUGIN_CONTINUE;
	
	if ( ! g_hasMolotov[id] && ! get_pcvar_num(pOverride) )
		return PLUGIN_CONTINUE;
	
	g_hasMolotov[id]--;
	engfunc(EngFunc_SetModel, ent, "models/w_molotov.mdl");
	set_pev(ent, pev_nextthink, 99999.0);
	
	return PLUGIN_CONTINUE;
}

public grenade_explode(ent) {
	
	new Float:fOrigin[3];
	pev(ent, pev_origin, fOrigin);
	
	new owner = pev(ent, pev_owner);
	new ent2 = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"));
	
	new param[5], iOrigin[3];
	param[0] = owner;
	param[1] = iOrigin[0] = floatround(fOrigin[0]);
	param[2] = iOrigin[1] = floatround(fOrigin[1]);
	param[3] = iOrigin[2] = floatround(fOrigin[2]);
	param[4] = ent2;
	
	radius_damage(owner, fOrigin, get_pcvar_float(pMlDamage), get_pcvar_float(pMlRadius), DMG_BLAST);
	emit_sound(ent, CHAN_AUTO, "misc/molotov_explosion.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
	
	engfunc(EngFunc_RemoveEntity, ent);
	
	ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"));
	
	new param2[2];
	param2[0] = ent;
	param2[1] = ent2;
	
	random_fire(iOrigin, ent2);
	
	new Float:FireTime = get_pcvar_float(pFireTime);
	
	set_task(0.2, "fire_damage", 56235 + random_num(-100, 100), param, 5, "a", floatround(FireTime / 0.2, floatround_floor));
	set_task(1.0, "fire_sound", 37235 + random_num(-100, 100), param2, 2, "a", floatround(FireTime) - 1);
	set_task(FireTime, "fire_stop", 27367 + random_num(-100, 100), param2, 2);
	
	return PLUGIN_CONTINUE;
}

public fire_sound(param[])
	emit_sound(param[0], CHAN_AUTO, "misc/molotov_fire.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM);

new Float:g_i;
new Float:g_g;

public fire_stop(param[]) {
	g_g = 0.0;
	g_i = 0.0;
	engfunc(EngFunc_RemoveEntity, param[0]);
}

public fire_damage(param[]) {
	
	new iOrigin[3], Float:fOrigin[3];
	iOrigin[0] = param[1];
	iOrigin[1] = param[2];
	iOrigin[2] = param[3];
	
	random_fire(iOrigin, param[4]);
	
	IVecFVec(iOrigin, fOrigin);
	radius_damage(param[0], fOrigin, get_pcvar_float(pFireDmg), get_pcvar_float(pMlRadius), DMG_BURN, 0);
}

stock radius_damage(attacker, Float:origin[3], Float:damage, Float:range, dmgtype, calc = 1) {
	
	new Float:pOrigin[3], Float:dist, Float:tmpdmg/*, iOrigin[3] */;
	new i, ateam = get_user_team(attacker), TK = get_pcvar_num(pTeamKill);
	
	while ( i++ < g_MaxPlayers ) {
		
		if ( ! is_user_alive(i) )
			continue;
		
		if ( ! TK && ateam == get_user_team(i) )
			continue;
		
		pev(i, pev_origin, pOrigin);
		dist = get_distance_f(origin, pOrigin);
		
		if ( dist > range )
			continue;
		
		if ( calc )
			tmpdmg = damage - ( damage / range ) * dist;
		else
			tmpdmg = damage;
		
		if ( pev(i, pev_health) < tmpdmg )
			kill(attacker, i);
		else
			fm_fakedamage(i, "molotov", tmpdmg, dmgtype);
		
		// FVecIVec(pOrigin, iOrigin);
		// Flame(iOrigin, 1);
	}
	
	while ( ( i = engfunc(EngFunc_FindEntityInSphere, i, origin, range) ) ) {
		if ( pev(i, pev_takedamage) ) {
			if ( calc ) {
				pev(i, pev_origin, pOrigin);
				tmpdmg = damage - ( damage / range ) * get_distance_f(origin, pOrigin);
			}
			else
				tmpdmg = damage;
			
			// FVecIVec(pOrigin, iOrigin);
			// Flame(iOrigin, 1);
			
			fm_fakedamage(i, "molotov", tmpdmg, dmgtype);
		}
	}
}

stock random_fire(Origin[3], ent) {
	
	new range = get_pcvar_num(pMlRadius);
	new iOrigin[3];
	
	for ( new i = 1 ; i <= 5 ; i++ ) {
		
		g_i++;
		g_g++;
		
		iOrigin[0] = Origin[0] + random_num(-range, range);
		iOrigin[1] = Origin[1] + random_num(-range, range);
		iOrigin[2] = Origin[2];
		iOrigin[2] = ground_z(iOrigin, ent);
		
		while ( get_distance(iOrigin, Origin) > range ) {
			g_g++;
			iOrigin[0] = Origin[0] + random_num(-range, range);
			iOrigin[1] = Origin[1] + random_num(-range, range);
			iOrigin[2] = Origin[2];
			if ( g_g / g_i >= ANTI_LAGG )
				iOrigin[2] = ground_z(iOrigin, ent, 1);
			else
				iOrigin[2] = ground_z(iOrigin, ent);
		}
		
		if ( ! ( i % 4 ) )
			Flame(iOrigin, (!(i%4)));
		else
			Flame(iOrigin, 0);
	}
}

stock Flame(iOrigin[3], smoke) {
	
	new rand = random_num(5, 15);
	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(TE_SPRITE);
	write_coord(iOrigin[0]);
	write_coord(iOrigin[1]);
	write_coord(iOrigin[2] + rand * 10);
	write_short(firespr);
	write_byte(rand);
	write_byte(100);
	message_end();
	
	if ( smoke ) {
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
		write_byte(TE_SMOKE);
		write_coord(iOrigin[0]);
		write_coord(iOrigin[1]);
		write_coord(iOrigin[2] + 120);
		write_short(smokespr[random_num(0, 1)]);
		write_byte(random_num(10, 30));
		write_byte(random_num(10, 20));
		message_end();
	}
	
}

stock kill(k, v) {
	
	user_silentkill(v);
	
	new kteam = get_user_team(k);
	new vteam = get_user_team(v);
	
	new kfrags = get_user_frags(k) + 1;
	new kdeaths = get_user_deaths(k);
	if ( kteam == vteam )
		kfrags = get_user_frags(k) - 2;
	
	new vfrags = get_user_frags(v);
	new vdeaths = get_user_deaths(v);
	
	message_begin(MSG_ALL, gmsgScoreInfo);
	write_byte(k);
	write_short(kfrags);
	write_short(kdeaths);
	write_short(0);
	write_short(kteam);
	message_end();
	
	message_begin(MSG_ALL, gmsgScoreInfo);
	write_byte(v);
	write_short(vfrags + 1);
	write_short(vdeaths);
	write_short(0);
	write_short(vteam);
	message_end();
	
	message_begin(MSG_ALL, gmsgDeathMsg, {0,0,0}, 0);
	write_byte(k);
	write_byte(v);
	write_byte(0);
	write_string("molotov");
	message_end();
	
	g_frags[k]++;
	
	if ( kteam != vteam )
		cs_set_user_money(k, cs_get_user_money(k) + 300);
	else
		cs_set_user_money(k, cs_get_user_money(k) - 300);
}

stock ground_z(iOrigin[3], ent, skip = 0) {
	
	iOrigin[2] += random_num(5, 80);
	
	new Float:fOrigin[3];
	
	IVecFVec(iOrigin, fOrigin);
	
	set_pev(ent, pev_origin, fOrigin);
	
	engfunc(EngFunc_DropToFloor, ent);
	
	if ( ! skip && ! engfunc(EngFunc_EntIsOnFloor, ent) )
		return ground_z(iOrigin, ent);
	
	pev(ent, pev_origin, fOrigin);
	
	return floatround(fOrigin[2]);
}

stock reset_molotovs() {
	new ent = g_MaxPlayers;
	while ((ent = engfunc(EngFunc_FindEntityByString, ent, "model", "models/w_molotov.mdl")))
		engfunc(EngFunc_SetModel, ent, "models/w_hegrenade.mdl");
}

stock set_molotovs() {
	new ent = g_MaxPlayers;
	while ((ent = engfunc(EngFunc_FindEntityByString, ent, "model", "models/w_hegrenade.mdl")))
		engfunc(EngFunc_SetModel, ent, "models/w_molotov.mdl");
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
