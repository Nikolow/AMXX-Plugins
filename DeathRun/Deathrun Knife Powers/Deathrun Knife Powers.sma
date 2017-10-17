/*

	Подобрена и готина версия на Knife Abilities плъгина за деатрън сървъри.
	Има доста ножове и доста интересни магии с тях.
	Плъгина работи с HUD меню-та, което е неговият минус, защото не пазя самият hud menu плъгин.
	Хубаво е да се премине към нормалните меню-та.

*/

#include <amxmodx>
#include <hud_menu>
#include <colorchat>
#include <engine>
#include <cstrike>
#include <fun>
#include <hamsandwich>
#include <fakemeta_util>
#include <chr_engine>//

/*teleporter*/
#define TELEPORT_INTERVAL 120.0
new Float:g_fLastUsed[33];
/*teleporter*/

/*auto unstuck*/
new stuck[33]
new cvar[3]
new const Float:size[][3] = {
	{0.0, 0.0, 1.0}, {0.0, 0.0, -1.0}, {0.0, 1.0, 0.0}, {0.0, -1.0, 0.0}, {1.0, 0.0, 0.0}, {-1.0, 0.0, 0.0}, {-1.0, 1.0, 1.0}, {1.0, 1.0, 1.0}, {1.0, -1.0, 1.0}, {1.0, 1.0, -1.0}, {-1.0, -1.0, 1.0}, {1.0, -1.0, -1.0}, {-1.0, 1.0, -1.0}, {-1.0, -1.0, -1.0},
	{0.0, 0.0, 2.0}, {0.0, 0.0, -2.0}, {0.0, 2.0, 0.0}, {0.0, -2.0, 0.0}, {2.0, 0.0, 0.0}, {-2.0, 0.0, 0.0}, {-2.0, 2.0, 2.0}, {2.0, 2.0, 2.0}, {2.0, -2.0, 2.0}, {2.0, 2.0, -2.0}, {-2.0, -2.0, 2.0}, {2.0, -2.0, -2.0}, {-2.0, 2.0, -2.0}, {-2.0, -2.0, -2.0},
	{0.0, 0.0, 3.0}, {0.0, 0.0, -3.0}, {0.0, 3.0, 0.0}, {0.0, -3.0, 0.0}, {3.0, 0.0, 0.0}, {-3.0, 0.0, 0.0}, {-3.0, 3.0, 3.0}, {3.0, 3.0, 3.0}, {3.0, -3.0, 3.0}, {3.0, 3.0, -3.0}, {-3.0, -3.0, 3.0}, {3.0, -3.0, -3.0}, {-3.0, 3.0, -3.0}, {-3.0, -3.0, -3.0},
	{0.0, 0.0, 4.0}, {0.0, 0.0, -4.0}, {0.0, 4.0, 0.0}, {0.0, -4.0, 0.0}, {4.0, 0.0, 0.0}, {-4.0, 0.0, 0.0}, {-4.0, 4.0, 4.0}, {4.0, 4.0, 4.0}, {4.0, -4.0, 4.0}, {4.0, 4.0, -4.0}, {-4.0, -4.0, 4.0}, {4.0, -4.0, -4.0}, {-4.0, 4.0, -4.0}, {-4.0, -4.0, -4.0},
	{0.0, 0.0, 5.0}, {0.0, 0.0, -5.0}, {0.0, 5.0, 0.0}, {0.0, -5.0, 0.0}, {5.0, 0.0, 0.0}, {-5.0, 0.0, 0.0}, {-5.0, 5.0, 5.0}, {5.0, 5.0, 5.0}, {5.0, -5.0, 5.0}, {5.0, 5.0, -5.0}, {-5.0, -5.0, 5.0}, {5.0, -5.0, -5.0}, {-5.0, 5.0, -5.0}, {-5.0, -5.0, -5.0}
}
/*auto unstuck*/

/*press buttons*/
const m_afButtonPressed = 246;
const m_afButtonReleased = 247;
/*end press buttons*/

/*cooldown*/
#define COOLDOWN 5 //minutes wait, before use /renew again
#define TASKID3 8569
new last_used[33];
new bool:waiting_response[33];
new cooldown = COOLDOWN;
/*cooldown*/

/*thor*/
new gCvarForDamage;
new gCvarForFrags;
new gSpriteIndex;
new const gThunderSprite[] = "sprites/lgtning.spr";
/*thor*/

/*hook*/
#define HOOKLIMIT 2 //kolko broiki hook da moje da polzva do sledvashtiq rund
new Hooking
new ishooked[32] = 0
new hookorigin[32][3]
new blockhook[33]
/*hook*/

/*knife blink*/
#define MIN_DISTANCE 50
new g_iEnemy[33];
new g_iInBlink[33];
new Float:g_fLastSlash[33];
new g_iCanceled[33];
new g_iSlash[33];

new cvar_iDistance;
new cvar_fSpeed;
new cvar_iAttackMode;
new cvar_fDelay;
new cvar_iTeamBlink;
new cvar_sGlowColor;
new cvar_iGlow;
new cvar_iInvincible;
new cvar_iEnable;
new cvar_iNotification;
new cvar_iDamage;
/*knife blink*/

#define IsPlayer(%1)	( 1 <= %1 <= g_iMaxPlayers )
#define TASKID 6663
#define TASKID2 6665
/*throw*/
new g_iMaxPlayers
new amx_throwknives, amx_knifeammo, amx_maxknifeammo, amx_knifedmg, amx_knifetossforce
new mp_friendlyfire

new bool:knifeout[33]
new bool:roundfreeze
new Float:tossdelay[33]
new knifeammo[33]
new holdammo[33]
/*end throw*/

/*dd jump*/
#define MAX_PLAYERS 32
#define m_afButtonPressed 246
#define m_flFallVelocity 251
new g_iJumpCount[MAX_PLAYERS+1]
new g_pCvarMultiJumps,  g_pCvarMaxFallVelocity, g_pCvarJumpVelocity
/*end dd jump*/

new g_useab[33] = 0 //da moje li da se polzva menuto

//Knives bools <:
new g_canusethrow[33] = 0
new g_jump[33] = 0
new g_speed[33] = 0
new g_booster[33] = 0
new g_blink[33] = 0
new canusehook[32] = 0
new g_inviser[33] = 0
new g_chancesp[33] = 0
new g_thor[33] = 0
new g_construct[33] = 0
new g_frogger[33] = 0
new g_teleporter[33] = 0

public plugin_init()
{
	register_plugin("[DR] KnifePowers", "1.0", "val")
        /*command*/
        register_clcmd("say /knifes", "powers")
        register_clcmd("say_team /knifes", "powers")
        register_clcmd("say /knives", "powers")
        register_clcmd("say_team /knives", "powers")
        register_clcmd("say /knife", "powers")
        register_clcmd("say_team /knife", "powers")
        register_clcmd("say /knive", "powers")
        register_clcmd("say_team /knive", "powers")
        register_clcmd("say /renew", "powers2")
        register_clcmd("say_team /renew", "powers2")
        /*command*/

        /*hook*/
        register_clcmd("+hook","hook_on")
        register_clcmd("-hook","hook_off")
        /*hook*/

        /*frogger*/
        register_forward(FM_CmdStart,"ITEM_Forward_CmdStart");
        /*frogger*/

        /*autounstuck*/
	cvar[0] = register_cvar("amx_autounstuck","1")
	cvar[1] = register_cvar("amx_autounstuckeffects","1")
	cvar[2] = register_cvar("amx_autounstuckwait","7")
	set_task(0.1,"checkstuck",0,"",0,"b")
        /*autounstuck*/

        /*throw power*/
	register_event("ResetHUD","new_spawn","b")
	register_event("CurWeapon","check_knife","b","1=1")
	register_event("DeathMsg", "player_death", "a")
	register_logevent("round_start", 2, "1=Round_Start") 
	register_logevent("round_end", 2, "1=Round_End")
        register_event("TextMsg", "round_end", "a", "2&#Game_C", "2&#Game_w")
	RegisterHam(Ham_Spawn, "player", "Spawn_player", 1)
	register_clcmd("throw_knife","command_knife",0,"- throws a knife if the plugin is enabled")
	register_clcmd("drop", "ClientCommand_Drop")

	amx_throwknives = register_cvar("amx_throwknives","1",FCVAR_SERVER)
	amx_knifeammo = register_cvar("amx_knifeammo","20")
	amx_knifetossforce = register_cvar("amx_knifetossforce","1200")
	amx_maxknifeammo = register_cvar("amx_maxknifeammo","30")
	amx_knifedmg = register_cvar("amx_knifedmg","65")
	register_cvar("amx_dropknives","1")
	register_cvar("amx_knifeautoswitch","1")
	register_cvar("amx_tknifelog","0")

        check_cvars()
        set_task(20.0,"Bind")
	g_iMaxPlayers = get_maxplayers()
	mp_friendlyfire = get_cvar_pointer("mp_friendlyfire")
        /*throw power end*/

        /*press E*/
        RegisterHam(Ham_ObjectCaps, "player", "fwdObjectCaps"); // Player Presses Use
        /*press E*/

        /*thor*/
        register_clcmd( "+thor", "commandThunderOn" );
        register_clcmd( "-thor", "commandThunderOff" );
        gCvarForDamage = register_cvar( "thunder_damage", "15" );
        gCvarForFrags = register_cvar( "thunder_frags", "1" );
        /*thor*/

        /*knife blink*/
	register_forward(FM_TraceLine, "FW_TraceLine_Post", 1);
	register_forward(FM_PlayerPreThink, "FW_PlayerPreThink");
	RegisterHam(Ham_TakeDamage, "player", "EVENT_TakeDamage");
	register_event("CurWeapon", "EVENT_CurWeapon", "be", "1=1");
	
	cvar_iDistance = register_cvar("amx_kb_distance", "350");
	cvar_fSpeed = register_cvar("amx_kb_speed", "1000.0");
	cvar_iAttackMode = register_cvar("amx_kb_attackmode", "0");
	cvar_fDelay = register_cvar("amx_kb_delay", "1.0");
	cvar_iTeamBlink = register_cvar("amx_kb_teamblink", "1");
	cvar_sGlowColor = register_cvar("amx_kb_glowcolor", "255 0 0");
	cvar_iGlow = register_cvar("amx_kb_glow", "1");
	cvar_iInvincible = register_cvar("amx_kb_invincible", "1");
	cvar_iEnable = register_cvar("amx_kb_enable", "1");
	cvar_iNotification = register_cvar("amx_kb_notification", "0");
	cvar_iDamage = register_cvar("amx_kb_damage", "0");
        /*knife blink*/

        /*teleporter*/
        register_clcmd("teleporter", "knivesability")
        /*teleporter*/


        /*dd jump*/
        RegisterHam(Ham_Player_Jump, "player", "OnCBasePlayer_Jump", false)

        g_pCvarMultiJumps = register_cvar("mp_multijumps", "2") //kolko puti da moje da skacha
        g_pCvarMaxFallVelocity = register_cvar("mp_multijump_maxfallvelocity", "500")
        g_pCvarJumpVelocity = register_cvar("mp_multijumps_jumpvelocity", "268.328157")
        /*dd jump*/
}


public Bind() {
for(new client=1; client<=g_iMaxPlayers; client++)
{
    if(is_user_connected(client))
    {
        ColorChat(client,GREEN,"Please, Bind the /knife command to one of your keyboard buttons for easy to use knife menu!")
    }
}  
}

public check_cvars() {
	if(get_pcvar_num(amx_knifeammo) > get_pcvar_num(amx_maxknifeammo)) {
		server_print("[AMXX] amx_knifeammo can not be greater than amx_maxknifeammo, adjusting amx_maxknifeammo")
		set_pcvar_num(amx_maxknifeammo,get_pcvar_num(amx_knifeammo))
	}
	if (get_pcvar_num(amx_knifedmg) < 1 ) {
		server_print("[AMXX] amx_knifedmg can not be set lower than 1, setting cvar to 1 now.")
		set_pcvar_num(amx_knifedmg,0)
	}
	if (get_pcvar_num(amx_knifetossforce) < 200 ) {
		server_print("[AMXX] amx_knifetossforce can not be set lower than 200, setting cvar to 200 now.")
		set_pcvar_num(amx_knifetossforce,200)
	}
}

/*Precacher*/
public plugin_precache()
{
        /*for throwing*/
	precache_sound("weapons/knife_hitwall1.wav")
	precache_sound("weapons/knife_hit4.wav")
	precache_sound("weapons/knife_deploy1.wav")
	precache_model("models/w_knifepack.mdl")
	precache_model("models/w_throwingknife.mdl")
        /*end of throw needed*/

        /*thor*/
        gSpriteIndex = precache_model( gThunderSprite );
        /*thor*/

        /*constructer*/
	precache_model("models/pallet_with_bags.mdl")
        /*constructer*/

        precache_sound("hook/hook.wav")
        Hooking = precache_model("sprites/hook/hook.spr")
}
/*End precacher*/


public powers(id) {
if(!is_user_alive(id)) {
ColorChat(id,GREEN,"You must be ^x01alive^x04, to use this knife powers menu!");
return PLUGIN_HANDLED;
}

if(g_useab[id] == 1) {
ColorChat(id,GREEN,"You already choose a knife, you can again when type^x01 /renew in chat!");
return PLUGIN_HANDLED;
}

new menu = hudmenu_create("Knife Powers", "MenuSelect", 0, 255, 0,0.01, 0.5, 1);   

hudmenu_additem(menu, "Throwing Man", 1);
hudmenu_additem(menu, "Inviso-Jumperer", 2);
hudmenu_additem(menu, "Unlimiter", 3);
hudmenu_additem(menu, "Booster", 4);
hudmenu_additem(menu, "Blinker", 5);
hudmenu_additem(menu, "Thor",6);
hudmenu_additem(menu, "Weapon Chancer",7);
hudmenu_additem(menu, "Invisibility User",8);
hudmenu_additem(menu, "Constructer",9);
hudmenu_additem(menu, "Hooker",10);
hudmenu_additem(menu, "Frogger",11);
hudmenu_additem(menu, "Teleporter",12);

hudmenu_display(id, menu, 0);


return PLUGIN_HANDLED;
}


public MenuSelect(id, item, key, menu)
{

if(key == MENU_EXIT)
{
hudmenu_destroy(menu);
return PLUGIN_HANDLED;
}



switch(key)

{

case 1:
{
g_useab[id] = 1
g_canusethrow[id] = 1
ColorChat(id,GREEN,"You choose^x01 Throwing Man [You can throw your knife]");
ColorChat(id,GREEN,"Please,^x01 bind 'key' throw_knife^x04 to use the ability");
}

case 2:
{
g_useab[id] = 1
g_jump[id] = 1
set_user_rendering(id, kRenderFxNone, 0, 0, 0, kRenderTransAlpha, 50) 
ColorChat(id,GREEN,"You choose^x01 Inviso-Jumperer [Double Jump with Space + Invis]");
}

case 3:
{
g_useab[id] = 1
g_speed[id] = 1
set_user_gravity(id,0.4)
set_task(1.0,"speed",id+TASKID,_,_,"b")
ColorChat(id,GREEN,"You choose^x01 Unlimiter [Gravity And Speed]");
}

case 4:
{
g_useab[id] = 1
g_booster[id] = 1
set_task(5.0,"booster",id+TASKID2,_,_,"b")
ColorChat(id,GREEN,"You choose^x01 Booster [Regenerate HP to 250]");
}

case 5:
{
g_useab[id] = 1
g_blink[id] = 1
ColorChat(id,GREEN,"You choose^x01 Blinker [Aim and press Attack to blink]");
}

case 6:
{
g_useab[id] = 1
g_thor[id] = 1
ColorChat(id,GREEN,"You choose^x01 Thor [Lighting attack]");
ColorChat( id, GREEN, "Please, bind key^x01 +thor^x04 to use the ability of Thor!");
}

case 7:
{
g_useab[id] = 1
g_chancesp[id] = 1
ColorChat(id,GREEN,"You choose^x01 Weapon Chancer [At Spawn]");
}

case 8:
{
g_useab[id] = 1
g_inviser[id] = 1
ColorChat(id,GREEN,"You choose^x01 Invisibility User [Press E to full invis]");
}

case 9:
{
g_useab[id] = 1
g_construct[id] = 1
ColorChat(id,GREEN,"You choose^x01 Constructer");
}

case 10:
{
g_useab[id] = 1
canusehook[id] = 1
ColorChat(id,GREEN,"You choose^x01 Hooker [You can hook %d times]",HOOKLIMIT);
ColorChat(id,GREEN,"Please, bind^x01 +hook^x04 at one button in your keyboard!");
}

case 11:
{
g_useab[id] = 1
g_frogger[id] = 1
ColorChat(id,GREEN,"You choose^x01 Frogger [You can jump like frog with CTRL+Space]");
}

case 12:
{
g_useab[id] = 1
g_teleporter[id] = 1
ColorChat(id,GREEN,"You choose^x01 Teleporter [You can teleport at wached position]");
ColorChat(id,GREEN,"Please, bind^x01 teleporter^x04 at one button in your keyboard!");
}

}

hudmenu_destroy(menu);
return PLUGIN_HANDLED;
}
/*End of the menu horizont*/



public player_death() {
	new id = read_data(2)
	knife_drop(id)
}


public knife_drop(id) {
	
	if(!get_cvar_num("amx_dropknives") || knifeammo[id] <= 0 || !get_cvar_num("amx_throwknives")) return

	new Float: Origin[3], Float: Velocity[3]
	entity_get_vector(id, EV_VEC_origin, Origin)

	new knifedrop = create_entity("info_target")
	if(!knifedrop) return

	entity_set_string(knifedrop, EV_SZ_classname, "knife_pickup")
	entity_set_model(knifedrop, "models/w_knifepack.mdl")

	new Float:MinBox[3] = {-1.0, -1.0, -1.0}
	new Float:MaxBox[3] = {1.0, 1.0, 1.0}
	entity_set_vector(knifedrop, EV_VEC_mins, MinBox)
	entity_set_vector(knifedrop, EV_VEC_maxs, MaxBox)

	entity_set_origin(knifedrop, Origin)

	entity_set_int(knifedrop, EV_INT_effects, 32)
	entity_set_int(knifedrop, EV_INT_solid, 1)
	entity_set_int(knifedrop, EV_INT_movetype, 6)
	entity_set_edict(knifedrop, EV_ENT_owner, id)

	VelocityByAim(id, 400 , Velocity)
	entity_set_vector(knifedrop, EV_VEC_velocity ,Velocity)
	holdammo[id] = knifeammo[id]
	knifeammo[id] = 0
}

public check_knife(id) {
	if(!get_cvar_num("amx_throwknives")) return

	new weapon = read_data(2)
	if(weapon == CSW_KNIFE && g_canusethrow[read_data(1)] == 1) {
		knifeout[id] = true
		/*if(knifeammo[id] > 1) {
			client_print(id, print_center,"You have %d knives",knifeammo[id])
		}
		else if(knifeammo[id] == 1) {
			client_print(id, print_center,"You have %d knife",knifeammo[id])
		}*/
		client_print(id, print_center,"You have %d throwing %s",knifeammo[id], knifeammo[id] == 1 ? "knife" : "knives")
	}
	else {
		knifeout[id] = false
	}
}

public kill_all_entity(classname[]) {
	new iEnt = find_ent_by_class(-1, classname)
	new tEnt
	while(iEnt > 0) {
		tEnt = iEnt
		iEnt = find_ent_by_class(iEnt, classname)
		remove_entity(tEnt)
	}
}

public new_spawn(id) {

	if(knifeammo[id] < get_cvar_num("amx_knifeammo")) knifeammo[id] = get_cvar_num("amx_knifeammo")
	if(knifeammo[id] > get_cvar_num("amx_maxknifeammo")) knifeammo[id] = get_cvar_num("amx_maxknifeammo")
	tossdelay[id] = 0.0
}

public client_connect(id) {

	knifeammo[id] = get_cvar_num("amx_knifeammo")
	holdammo[id] = 0
	tossdelay[id] = 0.0
	knifeout[id] = false
        g_useab[id] = 0
        g_canusethrow[id] = 0
        g_jump[id] = 0
        remove_task(id+TASKID)
        remove_task(id+TASKID2)
        g_speed[id] = 0
        g_booster[id] = 0
        g_blink[id] = 0
        canusehook[id] = 0
        last_used[id] = 0;
        remove_hook(id)
        g_inviser[id] = 0
        g_chancesp[id] = 0
        g_thor[id] = 0
        g_construct[id] = 0
        g_frogger[id] = 0
        g_teleporter[id] = 0
}

public client_disconnect(id) {

	knifeammo[id] = 0
	holdammo[id] = 0
	tossdelay[id] = 0.0
	knifeout[id] = false
        g_useab[id] = 0
        g_canusethrow[id] = 0
        g_jump[id] = 0
        g_speed[id] = 0
        g_booster[id] = 0
        g_blink[id] = 0
        canusehook[id] = 0
        last_used[id] = 0;
        remove_hook(id)
        g_inviser[id] = 0
        g_chancesp[id] = 0
        g_thor[id] = 0
        g_construct[id] = 0
        g_frogger[id] = 0
        g_teleporter[id] = 0
}

public round_start() {
	roundfreeze = false
}


public round_end() {
	roundfreeze = true
	kill_all_entity("throwing_knife")
	kill_all_entity("knife_pickup")


	new ent
	while ((ent = engfunc(EngFunc_FindEntityByString, ent, "classname", "npc_onna")))
        engfunc(EngFunc_RemoveEntity, ent)  
}

public vexd_pfntouch(pToucher, pTouched)
{
	if( !is_valid_ent(pToucher) )
	{
		return
	}
	if(!get_pcvar_num(amx_throwknives))
	{
		return
	}

	static Classname[32], owner, Float:kOrigin[3]
	entity_get_string(pToucher, EV_SZ_classname, Classname, 31)
	owner = entity_get_edict(pToucher, EV_ENT_owner)
	entity_get_vector(pToucher, EV_VEC_origin, kOrigin)

	static const knife_pickup[] = "knife_pickup"
	static const throwing_knife[] = "throwing_knife"
	if(equal(Classname,knife_pickup))
	{
		if( !is_valid_ent(pTouched) || !IsPlayer(pTouched) )
		{
			return
		}
		
		check_cvars()
	/*	static Class2[32]   
		static const player[] = "player"  
		entity_get_string(pTouched, EV_SZ_classname, Class2, 31)
		if(!equal(Class2,player) || knifeammo[pTouched] >= get_pcvar_num(amx_maxknifeammo))
		{
			return
		}*/
		if( knifeammo[pTouched] >= get_pcvar_num(amx_maxknifeammo))
		{
			return
		}

		if((knifeammo[pTouched] + holdammo[owner]) > get_pcvar_num(amx_maxknifeammo))
		{
			holdammo[owner] -= get_pcvar_num(amx_maxknifeammo) - knifeammo[pTouched]
			knifeammo[pTouched] = get_pcvar_num(amx_maxknifeammo)
			emit_sound(pToucher, CHAN_ITEM, "weapons/knife_deploy1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
		}
		else
		{
			knifeammo[pTouched] += holdammo[owner]
			emit_sound(pToucher, CHAN_ITEM, "weapons/knife_deploy1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
			remove_entity(pToucher)
		}
		client_print(pTouched, print_center,"You have %i knives",knifeammo[pTouched])
	}

	else if(equal(Classname,throwing_knife))
	{
		check_cvars()
		if(is_user_alive(pTouched))
		{
			new movetype = entity_get_int(pToucher, EV_INT_movetype)
			if(movetype == MOVETYPE_NONE && knifeammo[pTouched] < get_pcvar_num(amx_maxknifeammo))
			{
				if(knifeammo[pTouched] < get_pcvar_num(amx_maxknifeammo))
				{
					knifeammo[pTouched] += 1
				}
				client_print(pTouched,print_center,"You have %i knives",knifeammo[pTouched])
				emit_sound(pToucher, CHAN_ITEM, "weapons/knife_deploy1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
				remove_entity(pToucher)
			}
			else if(movetype != MOVETYPE_NONE)
			{
				if(owner == pTouched)
				{
					return
				}

				remove_entity(pToucher)

				if(get_pcvar_num(mp_friendlyfire) == 0 && get_user_team(pTouched) == get_user_team(owner))
				{
					return
				}

				new pTdead[33]
				entity_set_float(pTouched, EV_FL_dmg_take, get_pcvar_float(amx_knifedmg))

				if((get_user_health(pTouched) - get_pcvar_num(amx_knifedmg)) <= 0)
				{
					pTdead[pTouched] = 1
				}
				else
				{
					set_user_health(pTouched, get_user_health(pTouched) - get_pcvar_num(amx_knifedmg))
				}

				if(get_user_team(pTouched) == get_user_team(owner))
				{
					new name[32]
					get_user_name(owner,name,31)
					client_print(0,print_chat,"%s attacked a teammate",name)
				}

				emit_sound(pTouched, CHAN_ITEM, "weapons/knife_hit4.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)

				if(pTdead[pTouched])
				{
					if(get_user_team(pTouched) == get_user_team(owner))
					{
						set_user_frags(owner, get_user_frags(owner) - 1)
						client_print(owner,print_center,"You killed a teammate")
					}
					else
					{
						set_user_frags(owner, get_user_frags(owner) + 1)
					}

					new gmsgScoreInfo = get_user_msgid("ScoreInfo")
					new gmsgDeathMsg = get_user_msgid("DeathMsg")

					//Kill the victim and block the messages
					set_msg_block(gmsgDeathMsg,BLOCK_ONCE)
					set_msg_block(gmsgScoreInfo,BLOCK_ONCE)
					user_kill(pTouched,1)

					//Update killers scorboard with new info
					message_begin(MSG_BROADCAST,gmsgScoreInfo)
					write_byte(owner)
					write_short(get_user_frags(owner))
					write_short(get_user_deaths(owner))
					write_short(0)
					write_short(get_user_team(owner))
					message_end()

					//Update victims scoreboard with correct info
					message_begin(MSG_BROADCAST,gmsgScoreInfo)
					write_byte(pTouched)
					write_short(get_user_frags(pTouched))
					write_short(get_user_deaths(pTouched))
					write_short(0)
					write_short(get_user_team(pTouched))
					message_end()

					//Replaced HUD death message
					message_begin(MSG_BROADCAST,gmsgDeathMsg,{0,0,0},0)
					write_byte(owner)
					write_byte(pTouched)
					write_byte(0)
					write_string("knife")
					message_end()

					new tknifelog[16]
					if (get_cvar_num("amx_tknifelog")) tknifelog = "throwing_knife"
					else tknifelog = "knife"

					new namea[32], authida[35], teama[32]
					new namev[32], authidv[35], teamv[32]
					get_user_name(owner,namea,31)
					get_user_authid(owner,authida,34)
					get_user_team(owner,teama,31)
					get_user_name(pTouched,namev,31)
					get_user_authid(pTouched,authidv,34)
					get_user_team(pTouched,teamv,31)

					log_message("^"%s<%d><%s><%s>^" killed ^"%s<%d><%s><%s>^" with ^"%s^"",
					namea,get_user_userid(owner),authida,teama,namev,get_user_userid(pTouched),authidv,teamv,tknifelog)
				}
			}
		}
		else
		{
			static szClass[16]
			entity_get_string(pTouched, EV_SZ_classname, szClass, charsmax(szClass))
			if( !equal(szClass, throwing_knife) )
			{
				entity_set_int(pToucher, EV_INT_movetype, MOVETYPE_NONE)
				emit_sound(pToucher, CHAN_ITEM, "weapons/knife_hitwall1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
			}
		}
	}
}

public ClientCommand_Drop( id )
{
	if( get_user_weapon(id) == CSW_KNIFE )
	{
		command_knife(id)
		return PLUGIN_HANDLED_MAIN
	}
	return PLUGIN_CONTINUE
}

public command_knife(id) {

	if(!is_user_alive(id) || !get_cvar_num("amx_throwknives") || roundfreeze || g_canusethrow[id] == 0) return PLUGIN_HANDLED

	if(get_cvar_num("amx_knifeautoswitch")) {
		knifeout[id] = true
		//engclient_cmd(id,"weapon_knife")
		client_cmd(id,"weapon_knife")
	}

	if(!knifeammo[id]) client_print(id,print_center,"You are out of knives",knifeammo[id])
	if(!knifeout[id] || !knifeammo[id]) return PLUGIN_HANDLED

	if(tossdelay[id] > get_gametime() - 0.5) return PLUGIN_HANDLED
	else tossdelay[id] = get_gametime()

	knifeammo[id]--

	if (knifeammo[id] == 1) {
		client_print(id,print_center,"You have %i knife",knifeammo[id])
	}
	else {
		client_print(id,print_center,"You have %i knives",knifeammo[id])
	}

	new Float: Origin[3], Float: Velocity[3], Float: vAngle[3], Ent

	entity_get_vector(id, EV_VEC_origin , Origin)
	entity_get_vector(id, EV_VEC_v_angle, vAngle)

	Ent = create_entity("info_target")

	if (!Ent) return PLUGIN_HANDLED

	entity_set_string(Ent, EV_SZ_classname, "throwing_knife")
	entity_set_model(Ent, "models/w_throwingknife.mdl")

	new Float:MinBox[3] = {-1.0, -7.0, -1.0}
	new Float:MaxBox[3] = {1.0, 7.0, 1.0}
	entity_set_vector(Ent, EV_VEC_mins, MinBox)
	entity_set_vector(Ent, EV_VEC_maxs, MaxBox)

	vAngle[0] -= 90

	entity_set_origin(Ent, Origin)
	entity_set_vector(Ent, EV_VEC_angles, vAngle)

	entity_set_int(Ent, EV_INT_effects, 2)
	entity_set_int(Ent, EV_INT_solid, 1)
	entity_set_int(Ent, EV_INT_movetype, 6)
	entity_set_edict(Ent, EV_ENT_owner, id)

	VelocityByAim(id, get_cvar_num("amx_knifetossforce") , Velocity)
	entity_set_vector(Ent, EV_VEC_velocity ,Velocity)
	
	return PLUGIN_HANDLED
}

public OnCBasePlayer_Jump(id)
{
   if( !is_user_alive(id) )
   {
      return HAM_IGNORED
   }

   new fFlags = pev(id, pev_flags)
   if(   fFlags & FL_WATERJUMP
   ||   pev(id, pev_waterlevel) >= 2
   ||   !(get_pdata_int(id, m_afButtonPressed) & IN_JUMP)   )
   {
      return HAM_IGNORED
   }

   if(   fFlags & FL_ONGROUND   )
   {
      g_iJumpCount[id] = 0
      return HAM_IGNORED
   }

   new iMulti = get_pcvar_num(g_pCvarMultiJumps)

   if( iMulti )
   {
      if(  g_jump[id] == 1  && get_user_weapon( id ) == CSW_KNIFE  )
      {
         if(   get_pdata_float(id, m_flFallVelocity) < get_pcvar_float(g_pCvarMaxFallVelocity)
         &&   ++g_iJumpCount[id] <= iMulti   )
         {
            new Float:fVelocity[3]
            pev(id, pev_velocity, fVelocity)
            fVelocity[2] = get_pcvar_float(g_pCvarJumpVelocity)
            set_pev(id, pev_velocity, fVelocity)
            return HAM_HANDLED
         }
      }
   }

   return HAM_IGNORED
}

public speed(TASK){
new id = TASK - TASKID
if(is_user_alive(id) && is_user_connected(id) && g_speed[id] == 1 && get_user_weapon( id ) == CSW_KNIFE) {
set_user_maxspeed(id,500.0)
}
}

public booster(TASK) {
new id = TASK - TASKID2
if(is_user_alive(id) && is_user_connected(id) && g_booster[id] == 1 && get_user_health(id) < 250 && get_user_weapon( id ) == CSW_KNIFE) {
set_user_health(id,get_user_health(id)+5)
}
}





public FW_TraceLine_Post(Float:start[3], Float:end[3], conditions, id, trace){
	
	if (!CHECK_Enabled(id)) return FMRES_IGNORED;
	if (!CHECK_ValidPlayer(id)) return FMRES_IGNORED;
        if(g_blink[id] == 0) return FMRES_IGNORED;
	
	new iWeaponID = get_user_weapon(id);
	
	if ( iWeaponID != CSW_KNIFE ){
		
		OP_Cancel(id);
		return FMRES_IGNORED;
	}
	
	new enemy = g_iEnemy[id];
	
	if (!enemy){
		
		enemy = get_tr2(trace, TR_pHit);
		
		if ( !CHECK_ValidPlayer(enemy) || !CHECK_ValidTeam(id, enemy) ){
			
			OP_Cancel(id);
			return FMRES_IGNORED;
		}
		
		g_iEnemy[id] = enemy;
	}
	
	return FMRES_IGNORED;
}

public FW_PlayerPreThink(id){
	
	if (!CHECK_Enabled(id)) return FMRES_IGNORED;
	if (!CHECK_ValidPlayer(id)) return FMRES_IGNORED;
        if(g_blink[id] == 0) return FMRES_IGNORED;
	
	new iWeaponID = get_user_weapon(id);
	
	if ( iWeaponID != CSW_KNIFE ){
		
		OP_Cancel(id);
		return FMRES_IGNORED;
	}
	
	new button = pev(id,pev_button);
	new validButton = CHECK_ValidButton(id);
	
	if (!validButton){
		
		if ( button & IN_ATTACK )
			validButton = IN_ATTACK;
		else
			validButton = IN_ATTACK2;
	}
	
	if ( !(button & validButton) ){
		
		OP_Cancel(id)
		return FMRES_IGNORED;
	}
	
	if (g_iSlash[id])
		g_iSlash[id] = 0;
	
	OP_NearEnemy(id);
	
	if( g_iInBlink[id] ){
		
		OP_SetBlink(id);
		OP_Blink(id);
		g_iCanceled[id] = 0;
	}

	return FMRES_IGNORED;
}

public EVENT_CurWeapon(id){
	
	if (read_data(2)!=CSW_KNIFE || !get_pcvar_num(cvar_iNotification)) return PLUGIN_CONTINUE;
	
        if(g_blink[id] == 0) return PLUGIN_CONTINUE;

	if ( g_fLastSlash[id]+get_pcvar_float(cvar_fDelay)<=get_gametime() )
		OP_Notification(id);
	
	return PLUGIN_CONTINUE;
}

public EVENT_TakeDamage(this, inflictor, attacker, Float:damage, damagetype){
	
	if (!CHECK_ValidPlayer(this) || !CHECK_ValidPlayer(attacker)) return HAM_IGNORED;
	
	if (g_iInBlink[attacker]) return HAM_SUPERCEDE;
	
	if (!g_iSlash[attacker]) return HAM_IGNORED;

        if(g_blink[attacker] == 0) return HAM_IGNORED;
	
	new new_damage = get_pcvar_num(cvar_iDamage);
	
	new_damage = max(new_damage, -1);
	
	switch (new_damage){
		
		case (-1): {
			
			new_damage = pev(this, pev_health);	// instant death
		}
		case (0): {
			
			new_damage = floatround(damage);	// normal damage
		}
	}									// anything above is cutsom damage
	
	SetHamParamFloat(4, float(new_damage));
	
	return HAM_HANDLED;
}

// ================================================== //
// 			OPERATIONS
// ================================================== //

public OP_NearEnemy(id){
	
	new enemy = g_iEnemy[id];
	new Float:time = get_gametime();
	new Float:delay = get_pcvar_float(cvar_fDelay);
	
	if (!enemy || g_fLastSlash[id]+delay>time){
		
		g_iInBlink[id] = 0;
		return;
	}
	
	new origin[3], origin_enemy[3];
	
	get_user_origin(id, origin, 0);
	get_user_origin(enemy, origin_enemy, 0);
	
	new distance = get_distance(origin, origin_enemy);
	new MaxDistance = get_pcvar_num(cvar_iDistance);
	
	if ( MIN_DISTANCE<=distance<=MaxDistance){
		
		g_iInBlink[id] = 1;
		return;
		
	}else if (MIN_DISTANCE>distance && g_iInBlink[id])
	{
		OP_Slash(id);
	}
	OP_Cancel(id);
}

public OP_Blink(id){
	
	new Float:new_velocity[3];
	new Float:speed = get_pcvar_float(cvar_fSpeed)
	new enemy = g_iEnemy[id];
	new Float:origin_enemy[3];
	
	pev(enemy, pev_origin, origin_enemy);
	entity_set_aim(id, origin_enemy);
	
	get_speed_vector2(id, enemy, speed, new_velocity)
	set_pev(id, pev_velocity, new_velocity);
}

public OP_Cancel(id){
	
	g_iInBlink[id] = 0;
	g_iEnemy[id] = 0;
	if (!g_iCanceled[id]){
		
		OP_SetBlink(id);
		g_iCanceled[id] = 1;
	}
}

public OP_Slash(id){
	
	set_pev(id, pev_velocity, {0.0,0.0,0.0});		// stop player's blink
	
	new weaponID = get_user_weapon(id, _, _);
	
	if(weaponID == CSW_KNIFE){
		
		new weapon[32]
		
		get_weaponname(weaponID,weapon,31)
		
		new ent = fm_find_ent_by_owner(-1,weapon,id)
		
		if(ent){
			
			set_pdata_float(ent,46, 0.0);
			set_pdata_float(ent,47, 0.0);
			g_iSlash[id] = 1;
			g_fLastSlash[id] = get_gametime();
			if (get_pcvar_num(cvar_iNotification)){
				
				set_task(get_pcvar_float(cvar_fDelay), "OP_Notification", id);
				client_print(id, print_center, "BLINKED!");
			}
		}
	}  
}

public OP_GetGlowColor(&red, &green, &blue){
	
	new arg[16]
	
	get_pcvar_string(cvar_sGlowColor, arg, 15);
	
	new iRed[5], iGreen[7], iBlue[5];
	
	parse(arg, iRed, 4, iGreen, 6, iBlue, 4);
	
	red = str_to_num(iRed);
	green = str_to_num(iGreen);
	blue = str_to_num(iBlue);
}

public OP_SetGlow(id, mode){
	
	new red, green, blue;
	
	if (mode)
		OP_GetGlowColor(red, green, blue);
	
	fm_set_user_rendering(id, kRenderFxGlowShell, red, green, blue, kRenderNormal, 16);
}

public OP_SetBlink(id){
	
	new blink = g_iInBlink[id];
	
	if (blink>1)
		return;
	
	if (get_pcvar_num(cvar_iGlow))
		OP_SetGlow(id, blink);
	else
		OP_SetGlow(id, 0);
	
	if (get_pcvar_num(cvar_iInvincible))
		fm_set_user_godmode(id, blink);
	else
		fm_set_user_godmode(id, 0);
	
	if (blink)
		g_iInBlink[id] += 1;
}


public OP_Notification(id){
	
	client_print(id, print_center, "KNIFE BLINK READY");
}

// ================================================== //
// 			CHECKS
// ================================================== //


public CHECK_Enabled(id){
	
	if ( get_pcvar_num(cvar_iEnable) && !roundfreeze )
		return 1;
	
	if (CHECK_ValidPlayer(id))
		OP_Cancel(id);
	return 0;
}

public CHECK_ValidPlayer(id){
	
	if (1<=id<=g_iMaxPlayers && is_user_alive(id))
		return 1;
	
	return 0;
}

public CHECK_ValidButton(id){
	
	new mode = get_pcvar_num(cvar_iAttackMode);
	
	switch (mode){
		
		case 1: return IN_ATTACK;
		case 2: return IN_ATTACK2;
	}
	return 0;
}

public CHECK_ValidTeam(id, enemy){
	
	if (get_pcvar_num(cvar_iTeamBlink))
		return 1;							// TeamBlink active, blink to anyone
	
	if ( get_user_team(id) == get_user_team(enemy) )
		return 0;							// don't blink to same team
	
	return 1;								// enemy is in a different team
}

public powers2(client) {


        if( (get_systime() - last_used[client]) < cooldown*60) {
            ColorChat(client,GREEN,"[AMXX] You must wait %d minute%s to use this command again.",cooldown, cooldown == 1 ? "" : "s")
            return
        }
        last_used[client] = get_systime()
        waiting_response[client] = true;

	g_useab[client] = 0
	g_canusethrow[client] = 0
        g_jump[client] = 0
        set_user_rendering(client)
        set_user_gravity(client,1.0) 
        set_user_maxspeed(client,250.0)
        g_speed[client] = 0
        g_booster[client] = 0
        g_blink[client] = 0
        canusehook[client] = 0
        remove_hook(client)
        g_inviser[client] = 0
        g_chancesp[client] = 0
        g_thor[client] = 0
        g_construct[client] = 0
        g_frogger[client] = 0
        g_teleporter[client] = 0
        ColorChat(client,GREEN,"You can use the /knife now! :)")
}

public Spawn_player(player)
{
         if(is_user_alive(player) && is_user_connected(player))
         {
         blockhook[player] = 0



         if(random_num(0, 100) == 1 && g_chancesp[player] == 1)
         {
                 give_item(player, "weapon_awp");
                 cs_set_user_bpammo(player, CSW_AWP, 90)

                 ColorChat(player, GREEN, "[AMXX] OMG! Lucky you.. you got a awp! (1 procent chance!)");
         }
 
         if(random_num(0, 100) <= 13 && g_chancesp[player] == 1)
         {
                 give_item(player, "weapon_fiveseven");
                 cs_set_user_bpammo(player, CSW_FIVESEVEN, 90)

                 ColorChat(player, GREEN, "[AMXX] Lucky you.. you got a fiveseven!");
         }
 
         if(random_num(0, 100) <= 6 && g_chancesp[player] == 1)
         {
                give_item(player, "weapon_deagle");
                cs_set_user_bpammo(player, CSW_DEAGLE, 90)
 
                ColorChat(player, GREEN, "[AMXX] Lucky you.. you got a deagle!");
         }
 
 
         if(random_num(0, 100) <= 15 && g_chancesp[player] == 1)
         {
                  give_item(player, "weapon_scout");
                  cs_set_user_bpammo(player, CSW_SCOUT, 90)
 
                  ColorChat(player, GREEN, "[AMXX] Lucky you.. you got a scout to jump easier!");
         }

         if(random_num(0, 100) <= 20 && g_chancesp[player] == 1)
         {
                  give_item(player, "weapon_m3");
                  cs_set_user_bpammo(player, CSW_M3, 90)
 
                  ColorChat(player, GREEN, "[AMXX] Lucky you.. you got a m3!");
         }

         if(random_num(0, 100) <= 30 && g_chancesp[player] == 1)
         {
                  give_item(player, "weapon_ak47");
                  cs_set_user_bpammo(player, CSW_AK47, 90)
 
                  ColorChat(player, GREEN, "[AMXX] Lucky you.. you got a m3!");
         }
     
         if(random_num(0, 100) <= 40 && g_chancesp[player] == 1)
         {
                  give_item(player, "weapon_hegrenade");
                  ColorChat(player, GREEN, "[AMXX] Lucky you.. you got a HE!");
         }        

         }
}

public hook_on(id,level,cid)
{
                if(!is_user_alive(id))
                {
                ColorChat(id,GREEN, "You must be alive, to use hook");
                return PLUGIN_HANDLED;
                }

               
                if(canusehook[id] == 0 ||  get_user_weapon( id ) != CSW_KNIFE)
                {
                        return PLUGIN_HANDLED
                }
 
                if(blockhook[id]<HOOKLIMIT && get_user_weapon( id ) == CSW_KNIFE)
                {
                        get_user_origin(id,hookorigin[id],3)
 
                        ishooked[id] = true
                        ++blockhook[id]
                        emit_sound(id,CHAN_STATIC,"hook/hook.wav",1.0,ATTN_NORM,0,PITCH_NORM)
                        set_task(0.1,"hook_task",id,"",0,"ab")
                        hook_task(id)
                }
                else
                {
                        ColorChat(id,GREEN, "You reached the limit %d for hook!",HOOKLIMIT)
                        return PLUGIN_HANDLED
                }
       
                return PLUGIN_HANDLED
}
 
 
public is_hooked(id)
{
return ishooked[id]
}
 
 
public hook_off(id)
{    
remove_hook(id)
return PLUGIN_HANDLED
}
 
 
public hook_task(id)
{
        if(!is_user_connected(id) || !is_user_alive(id))
        {
                remove_hook(id)
        }
 
 
        remove_beam(id)
        draw_hook(id)
 
 
        new origin[3], Float:velocity[3]
        get_user_origin(id,origin)
        new distance = get_distance(hookorigin[id],origin)
        if(distance > 25)
        {
                velocity[0] = (hookorigin[id][0] - origin[0]) * (2.0 * 300 / distance)
                velocity[1] = (hookorigin[id][1] - origin[1]) * (2.0 * 300 / distance)
                velocity[2] = (hookorigin[id][2] - origin[2]) * (2.0 * 300 / distance)
 
 
                entity_set_vector(id,EV_VEC_velocity,velocity)
        }
        else
        {
                entity_set_vector(id,EV_VEC_velocity,Float:{0.0,0.0,0.0})
                remove_hook(id)
        }
}
 
 
public draw_hook(id)
{
        message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
        write_byte(1) // TE_BEAMENTPOINT
        write_short(id) // entid
        write_coord(hookorigin[id][0]) // origin
        write_coord(hookorigin[id][1]) // origin
        write_coord(hookorigin[id][2]) // origin
        write_short(Hooking) // sprite index
        write_byte(0) // start frame
        write_byte(0) // framerate
        write_byte(100) // life
        write_byte(10) // width
        write_byte(0) // noise
        if(get_user_team(id) == 1)
        {
                write_byte(random_num(0, 255))
                write_byte(random_num(0, 255))
                write_byte(random_num(0, 255))
        }
        else
        {
                write_byte(random_num(0, 255))
                write_byte(random_num(0, 255))
                write_byte(random_num(0, 255))
        }
        write_byte(250) // brightness
        write_byte(1) // speed
        message_end()
}
 
 
public remove_hook(id)
{
        if(task_exists(id))
        {
                remove_task(id)
        }
        remove_beam(id)
        ishooked[id] = false
}
 
 
public remove_beam(id)
{
        message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
        write_byte(99)
        write_short(id)
        message_end()
}


public fwdObjectCaps(iClient)
{
if(!is_user_alive(iClient) && (g_inviser[iClient] == 0 || g_construct[iClient] == 0))
return HAM_IGNORED;

/*invisible E*/
if(get_pdata_int(iClient, m_afButtonPressed, 5) & IN_USE && g_inviser[iClient] == 1 && get_user_weapon( iClient ) == CSW_KNIFE)
{
set_user_rendering(iClient, kRenderFxNone, 0, 0, 0, kRenderTransAlpha, 0) 
ColorChat(iClient,GREEN,"You are invisible for anyone now!")
}
if(get_pdata_int(iClient, m_afButtonReleased, 5) & IN_USE && g_inviser[iClient] == 1 && get_user_weapon( iClient ) == CSW_KNIFE)
{
set_user_rendering(iClient, kRenderFxNone, 0, 0, 0, kRenderTransAlpha, 255) 
ColorChat(iClient,GREEN,"You are visible!")
}
/*inivisble E*/

/*construct E*/
if(get_pdata_int(iClient, m_afButtonPressed, 5) & IN_USE && g_construct[iClient] == 1 && get_user_weapon( iClient ) == CSW_KNIFE)
{
createent(iClient)
}
/*construct E*/

return HAM_IGNORED;
}

/*thor*/
stock show_beam( StartOrigin[ 3 ], EndOrigin[ 3 ] )
{
   message_begin( MSG_BROADCAST, SVC_TEMPENTITY );
   write_byte( TE_BEAMPOINTS );
   write_coord( StartOrigin[ 0 ] );
   write_coord( StartOrigin[ 1 ] );
   write_coord( StartOrigin[ 2 ] );
   write_coord( EndOrigin[ 0 ] );
   write_coord( EndOrigin[ 1 ] );
   write_coord( EndOrigin[ 2 ] );
   write_short( gSpriteIndex );
   write_byte( 1 );
   write_byte( 1 );
   write_byte( 3 );
   write_byte( 33);
   write_byte( 0 );
   write_byte( 255 );
   write_byte( 255 );
   write_byte( 255 );
   write_byte( 200 );
   write_byte( 0 );
   message_end();
}

public commandThunderOn( id )
{
   if( !is_user_alive( id ) && g_thor[id] == 0 )
   {
      return PLUGIN_HANDLED;
   }
   
   if( get_user_weapon( id ) == CSW_KNIFE && g_thor[id] == 1)
   {
      new target, body;
      get_user_aiming( id, target, body );
   
      if( is_valid_ent( target ) && is_user_alive( target ) )
      {
         if( get_user_team( id ) == get_user_team( target ) )
         {
            return PLUGIN_HANDLED;
         }

         new iPlayerOrigin[ 3 ], iEndOrigin[ 3 ];

         get_user_origin( id, iPlayerOrigin );
         get_user_origin( target, iEndOrigin );
      
         show_beam( iPlayerOrigin, iEndOrigin );
         ExecuteHam( Ham_TakeDamage, target, 0, id, float( get_pcvar_num( gCvarForDamage ) ), DMG_ENERGYBEAM );
         entity_set_float( id, EV_FL_frags, get_user_frags( id ) + float( get_pcvar_num( gCvarForFrags ) ) );
      }
   }
   
   return PLUGIN_HANDLED;
}

public commandThunderOff( id )
{
   message_begin( MSG_BROADCAST, SVC_TEMPENTITY );
   write_byte( TE_KILLBEAM );
   write_short( id );
   message_end();

   return PLUGIN_HANDLED;
}

/*autounstuck*/
public checkstuck() {
	if(get_pcvar_num(cvar[0]) >= 1) {
		static players[32], pnum, player
		get_players(players, pnum)
		static Float:origin[3]
		static Float:mins[3], hull
		static Float:vec[3]
		static o,i
		for(i=0; i<pnum; i++){
			player = players[i]
			if (is_user_connected(player) && is_user_alive(player) && (g_construct[player] == 1 || g_teleporter[player] == 1)) {
				pev(player, pev_origin, origin)
				hull = pev(player, pev_flags) & FL_DUCKING ? HULL_HEAD : HULL_HUMAN
				if (!is_hull_vacant(origin, hull,player) && !get_user_noclip(player) && !(pev(player,pev_solid) & SOLID_NOT)) {
					++stuck[player]
					if(stuck[player] >= get_pcvar_num(cvar[2])) {
						pev(player, pev_mins, mins)
						vec[2] = origin[2]
						for (o=0; o < sizeof size; ++o) {
							vec[0] = origin[0] - mins[0] * size[o][0]
							vec[1] = origin[1] - mins[1] * size[o][1]
							vec[2] = origin[2] - mins[2] * size[o][2]
							if (is_hull_vacant(vec, hull,player)) {
								engfunc(EngFunc_SetOrigin, player, vec)
								effects(player)
								set_pev(player,pev_velocity,{0.0,0.0,0.0})
								o = sizeof size
							}
						}
					}
				}
				else
				{
					stuck[player] = 0
				}
			}
		}
	}
}

stock bool:is_hull_vacant(const Float:origin[3], hull,id) {
	static tr
	engfunc(EngFunc_TraceHull, origin, origin, 0, hull, id, tr)
	if (!get_tr2(tr, TR_StartSolid) || !get_tr2(tr, TR_AllSolid)) //get_tr2(tr, TR_InOpen))
		return true
	
	return false
}

public effects(id) {
	if(get_pcvar_num(cvar[1])) {
		set_hudmessage(255,150,50, -1.0, 0.65, 0, 6.0, 1.5,0.1,0.7) // HUDMESSAGE
		show_hudmessage(id,"You should be unstucked now!") // HUDMESSAGE
		message_begin(MSG_ONE_UNRELIABLE,105,{0,0,0},id )      
		write_short(1<<10)   // fade lasts this long duration
		write_short(1<<10)   // fade lasts this long hold time
		write_short(1<<1)   // fade type (in / out)
		write_byte(20)            // fade red
		write_byte(255)    // fade green
		write_byte(255)        // fade blue
		write_byte(255)    // fade alpha
		message_end()
		client_cmd(id,"spk fvox/blip.wav")
	}
}
/*auto unstuck*/
public createent(id)
{

    new Float:origin[3]

    GetFrontOrigin(id,64,origin)

    new ent = create_entity("info_target")

    entity_set_origin(ent,origin);

    entity_set_float(ent,EV_FL_takedamage,1.0)
    entity_set_float(ent,EV_FL_health,100.0)

    entity_set_string(ent,EV_SZ_classname,"npc_onna");
    entity_set_model(ent,"models/pallet_with_bags.mdl");
    entity_set_int(ent,EV_INT_solid, 2)

    entity_set_byte(ent,EV_BYTE_controller1,125);
    entity_set_byte(ent,EV_BYTE_controller2,125);
    entity_set_byte(ent,EV_BYTE_controller3,125);
    entity_set_byte(ent,EV_BYTE_controller4,125);

    new Float:maxs[3] = {16.0,16.0,36.0}
    new Float:mins[3] = {-16.0,-16.0,-36.0}
    entity_set_size(ent,mins,maxs)

    entity_set_float(ent,EV_FL_animtime,2.0)
    entity_set_float(ent,EV_FL_framerate,1.0)
    entity_set_int(ent,EV_INT_sequence,0);


    drop_to_floor(ent)

}
GetFrontOrigin(id, AddUnits = 1, Float:origin[3])
{
    entity_get_vector(id, EV_VEC_origin, origin);

    // want eyes origin ? then uncomment following line :
    // origin[2] += entity_get_int(id, EV_INT_flags) & FL_DUCKING ? 12.0 ; 18.0;

    new Float:velocity[3];
    velocity_by_aim(id, AddUnits, velocity);

    // #include < xs >
    xs_vec_add(origin, velocity, origin);
}  

/*frogger*/
public ITEM_Forward_CmdStart(id, uc_handle, seed) 
{ 
    if (g_frogger[id] == 1 && is_user_connected(id) && is_user_alive(id) && get_user_weapon(id) == CSW_KNIFE)
	{
		static Button, oldButton;
		Button = get_uc(uc_handle, UC_Buttons);
		oldButton = pev(id, pev_oldbuttons);

		//if(Button & IN_JUMP && !(oldButton & IN_JUMP) && pev(id,pev_flags) & FL_ONGROUND)
		if(Button & IN_JUMP && (Button & IN_DUCK) && !(oldButton & IN_JUMP) && pev(id,pev_flags) & FL_ONGROUND)
		{
			new Float: Angle[3];
			new Float: Out[3];

			entity_get_vector(id,EV_VEC_angles,Angle)
			angle_vector(Angle,ANGLEVECTOR_FORWARD,Out);

			//new Float: velocity[3];
			//Out[0]=Out[0]*4000;
			Out[0]=Out[0]*500;
			Out[1]=Out[1]*500;
			Out[2]=Out[2] + 300;

			//get_user_velocity(id,velocity);
			//velocity[2]=400.0;
			//elocity[0]=700.0;
			//velocity_by_aim(id, 800, velocity);
			set_pev(id,pev_velocity,Out);
			//set_user_velocity(id,velocity);
		}
	}
}  
/*end frogger*/

/*teleporter*/
public knivesability(id)
{
	if(!is_user_alive(id) && !is_user_connected(id))
		return PLUGIN_HANDLED;

	if(g_teleporter[id] == 1 && get_user_weapon(id) == CSW_KNIFE)
	{
		static Float:fTime;
		fTime = get_gametime();

		if(g_fLastUsed[id] > 0.0 && (fTime - g_fLastUsed[id]) < TELEPORT_INTERVAL)
		{
			ColorChat(id,GREEN, "^x04You can use the command once at^x01 %.f^x01 sec.", TELEPORT_INTERVAL);
			return PLUGIN_HANDLED;
		}   
	
		static Float:start[3], Float:dest[3] 
		pev(id, pev_origin, start) 
		pev(id, pev_view_ofs, dest) 
		xs_vec_add(start, dest, start) 
		pev(id, pev_v_angle, dest) 
	
		engfunc(EngFunc_MakeVectors, dest) 
		global_get(glb_v_forward, dest) 
		xs_vec_mul_scalar(dest, 9999.0, dest) 
		xs_vec_add(start, dest, dest) 
		engfunc(EngFunc_TraceLine, start, dest, IGNORE_MONSTERS, id, 0) 
		get_tr2(0, TR_vecEndPos, start) 
		get_tr2(0, TR_vecPlaneNormal, dest) 
	
		static const player_hull[] = {HULL_HUMAN, HULL_HEAD} 
		engfunc(EngFunc_TraceHull, start, start, DONT_IGNORE_MONSTERS, player_hull[_:!!(pev(id, pev_flags) & FL_DUCKING)], id, 0)
		
		if(!get_tr2(0, TR_StartSolid) && !get_tr2(0, TR_AllSolid) && get_tr2(0, TR_InOpen)) 
		{ 
			engfunc(EngFunc_SetOrigin, id, start) 
			return PLUGIN_HANDLED 
		}
	
		static Float:size[3] 
		pev(id, pev_size, size) 
		
		xs_vec_mul_scalar(dest, (size[0] + size[1]) / 2.0, dest) 
		xs_vec_add(start, dest, dest) 
		engfunc(EngFunc_SetOrigin, id, dest) 
	
		g_fLastUsed[id] = fTime;
	}

	return PLUGIN_HANDLED;
}

/*teleporter*/
