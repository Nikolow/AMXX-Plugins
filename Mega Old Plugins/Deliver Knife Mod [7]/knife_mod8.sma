#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <fakemeta>
#include <fun>
#include <hamsandwich>
#include <xs>

#define UKM_PREFIX "CanndyCore's DeathRun"
#define is_true_player(%1) (1 <= %1 <= 32)
#define TELEPORT_INTERVAL 120.0

//Knives` Bools:
new const gThunderSprite[] = "sprites/lgtning.spr";
new autobinded[33]
new Float:g_fLastUsed[33];
new g_knife_cclass[33]
enum
{
	WOLF,
	NINJA,
	WEREWOLF,
	SATUR,
	MUTANT,
	PREDATOR,
	MEGATRON,
	ZEUS
}

new gMsgScreenFade
new gMsgSayText
new gCvarForDamage;
new gCvarForFrags;
new gSpriteIndex;

// Директории на моделите
new const model_wolfknife [] = "models/royal/v_wolf.mdl"
new const model_ninjafknife [] = "models/royal/v_ninja.mdl"
new const model_werewolfknife [] = "models/royal/v_werewolf.mdl"
new const model_saturknife [] = "models/royal/v_satur.mdl"
new const model_mutantknife [] = "models/royal/v_mutant.mdl"
new const model_hishtnikknife [] = "models/royal/v_hishtnik.mdl"
new const model_megatronknife [] = "models/royal/v_megatron.mdl"
new const model_zeusknife [] = "models/royal/v_storm.mdl"

new const sound_choseone [] = "fvox/bell.wav"

public plugin_init() 
{
	//Registrirvame plugina
	register_plugin("[UKM] Ultimate 7 Knives Knife Mod", "1.0", "DeviLeR")
	
	//Nujni neshta
	register_event("CurWeapon", "Knifeabilities", "be", "1=1")
	register_event("Health", "EventHealth", "be", "1>0")
	register_logevent("RoundStart", 2, "0=World triggered", "1=Round_Start");
	RegisterHam(Ham_TakeDamage, "player", "fwdTakeDamage", 0)
	
	//Регистрираме командите
	register_clcmd("say /knife", "knifemenuopen")
	register_clcmd("say_team /knife", "knifemenuopen")
	register_clcmd("abilities", "knivesability")
	register_clcmd( "+fulger", "commandThunderOn" );
	register_clcmd( "-fulger", "commandThunderOff" );
	register_concmd( "amx_thundereffect", "commandThunderEffect", ADMIN_ALL, "" );
  
	gCvarForDamage = register_cvar( "thunder_damage", "5" );
	gCvarForFrags = register_cvar( "thunder_frags", "1" );
	
	set_task(120.0, "autocomm", 0, _, _, "b")
	gMsgScreenFade = get_user_msgid("ScreenFade");
	gMsgSayText = get_user_msgid("SayText");
}

public plugin_precache()
{
  gSpriteIndex = precache_model( gThunderSprite );
  precache_model(model_wolfknife)
  precache_model(model_ninjafknife)
  precache_model(model_werewolfknife)
  precache_model(model_saturknife)
  precache_model(model_mutantknife)
  precache_model(model_hishtnikknife)
  precache_model(model_megatronknife)
  precache_model(model_zeusknife)
  
  precache_sound(sound_choseone)
}

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


public knifemenuopen(id) 
{
	new menu = menu_create("\yChoose your knife:", "opciq");

	menu_additem(menu, "\wWolfMan \r[\yDouble damage\r]", "1", 0);
	menu_additem(menu, "\wNinja \r[\yNo footsteps\r]", "2", 0);
	menu_additem(menu, "\wWerewolf \r[\yHigh Speed\r]", "3", 0);
	menu_additem(menu, "\wSatur \r[\yLow Gravity\r]", "4", 0);
	menu_additem(menu, "\wMutant \r[\yHeal up to 300\r]", "5", 0);
	menu_additem(menu, "\wPredator \r[\y80% Invisibility\r]", "6", 0);
	menu_additem(menu, "\wMegatron \r[\yCan Teleport\r]", "7", 0);
	menu_additem(menu, "\wZeus \r[\yThunder\r]","8", 0);

	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
	menu_display(id, menu, 0);
}

public opciq(id, menu, item)
{    
	new data[6], iName[64], access, callback
    
	menu_item_getinfo(menu, item, access, data,5, iName, 63, callback) 
    
	new key = str_to_num(data)
	new health = get_user_health(id)
	
	set_user_rendering(id, kRenderFxNone, 0, 0, 0, kRenderTransAlpha, 255)
	set_user_maxspeed(id, 240.0)
	set_user_footsteps(id, 0);
	set_user_gravity(id , 1.0)
	if(health > 100)
	{
		set_user_health(id, 100)
	}
	remove_task(id)
	
	client_cmd(id, "spk %s", sound_choseone);
	
	switch(key)
	{      
		case 1:
		{
			g_knife_cclass[id] = WOLF
			ham_strip_weapon(id, "weapon_knife");
			give_item(id, "weapon_knife")

			set_hudmessage(200, 200, 200, -1.0, 0.25, 0, 5.0, 5.0, 0.1, 0.2, -1)
			show_hudmessage(id, "Your knife is WolfMan!")
			
			message_begin(MSG_ONE_UNRELIABLE, gMsgScreenFade, {0, 0, 0}, id); 
			write_short(1<<12) 
			write_short(1<<8)
			write_short(0x0001)
			write_byte(205)
			write_byte(205)
			write_byte(0) 
			write_byte(200)
			message_end()
	
			ColorMessage(id, "^x04[%s]^x01 You've chosen^x04 WolfMan^x01 [^x03 Double damage^x01 ].", UKM_PREFIX)
		}
		case 2:
		{
			g_knife_cclass[id] = NINJA
			ham_strip_weapon(id, "weapon_knife");
			give_item(id, "weapon_knife")

			set_hudmessage(0, 191, 255, -1.0, 0.25, 0, 5.0, 5.0, 0.1, 0.2, -1)
			show_hudmessage(id, "Your knife is Ninja!")
			
			message_begin(MSG_ONE_UNRELIABLE, gMsgScreenFade, {0, 0, 0}, id); 
			write_short(1<<12) 
			write_short(1<<8)
			write_short(0x0001)
			write_byte(190)
			write_byte(190)
			write_byte(0) 
			write_byte(200)
			message_end()
			
			ColorMessage(id, "^x04[%s]^x01 You've chosen^x04 Ninja^x01 [^x03 No Footsteps^x01 ].", UKM_PREFIX)
		}
		case 3:
		{
			g_knife_cclass[id] = WEREWOLF
			ham_strip_weapon(id, "weapon_knife");
			give_item(id, "weapon_knife")

			set_hudmessage(0, 0, 255, -1.0, 0.25, 0, 5.0, 5.0, 0.1, 0.2, -1)
			show_hudmessage(id, "Your knife is Werewolf!")
			
			message_begin(MSG_ONE_UNRELIABLE, gMsgScreenFade, {0, 0, 0}, id); 
			write_short(1<<12) 
			write_short(1<<8)
			write_short(0x0001)
			write_byte(0)
			write_byte(206)
			write_byte(209) 
			write_byte(200)
			message_end()
			
			ColorMessage(id, "^x04[%s]^x01 You've chosen^x04 Werewolf^x01 [^x03 High Speed^x01 ].", UKM_PREFIX)
		}
		case 4:
		{
			g_knife_cclass[id] = SATUR
			ham_strip_weapon(id, "weapon_knife");
			give_item(id, "weapon_knife")
			
			set_hudmessage(165, 42, 42, -1.0, 0.25, 0, 5.0, 5.0, 0.1, 0.2, -1)
			show_hudmessage(id, "Your knife is Satur!")
			client_cmd(id, "bind ^"v^" ^"abilities^"")
			
			message_begin(MSG_ONE_UNRELIABLE, gMsgScreenFade, {0, 0, 0}, id); 
			write_short(1<<12) 
			write_short(1<<8)
			write_short(0x0001)
			write_byte(255)
			write_byte(127)
			write_byte(80) 
			write_byte(200)
			message_end()
			
			ColorMessage(id, "^x04[%s]^x01 You've chosen^x04 Satur^x01 [^x03 Low gravity^x01 ].", UKM_PREFIX)
		}
		case 5:
		{
			g_knife_cclass[id] = MUTANT
			ham_strip_weapon(id, "weapon_knife");
			give_item(id, "weapon_knife")

			set_hudmessage(160, 32, 240, -1.0, 0.25, 0, 5.0, 5.0, 0.1, 0.2, -1)
			show_hudmessage(id, "Your knife is Mutant!")
			
			message_begin(MSG_ONE_UNRELIABLE, gMsgScreenFade, {0, 0, 0}, id); 
			write_short(1<<12) 
			write_short(1<<8)
			write_short(0x0001)
			write_byte(208)
			write_byte(32)
			write_byte(144) 
			write_byte(200)
			message_end()
			
			ColorMessage(id, "^x04[%s]^x01 You've chosen^x04 Mutant^x01 [^x03 Heal up to 300^x01 ].", UKM_PREFIX)
			
			set_task(1.0,"EventHealth",id)
		}
		case 6:
		{
			g_knife_cclass[id] = PREDATOR
			ham_strip_weapon(id, "weapon_knife");
			give_item(id, "weapon_knife")
			
			set_user_rendering(id, kRenderFxNone, 0, 0, 0, kRenderTransAlpha, 51)

			set_hudmessage(0, 0, 205, -1.0, 0.25, 0, 5.0, 5.0, 0.1, 0.2, -1)
			show_hudmessage(id, "Your knife is Predator!")
			
			message_begin(MSG_ONE_UNRELIABLE, gMsgScreenFade, {0, 0, 0}, id); 
			write_short(1<<12) 
			write_short(1<<8)
			write_short(0x0001)
			write_byte(30)
			write_byte(144)
			write_byte(255) 
			write_byte(200)
			message_end()
			
			ColorMessage(id, "^x04[%s]^x01 You've chosen^x04 Predator^x01 [^x03 80% Invisibility^x01 ].", UKM_PREFIX)
		}
		case 7:
		{
			g_knife_cclass[id] = MEGATRON
			ham_strip_weapon(id, "weapon_knife");
			give_item(id, "weapon_knife")

			set_hudmessage(250, 128, 114, -1.0, 0.25, 0, 5.0, 5.0, 0.1, 0.2, -1)
			show_hudmessage(id, "Your knife is Megatron!")
			client_cmd(id, "bind ^"v^" ^"abilities^"");
			
			message_begin(MSG_ONE_UNRELIABLE, gMsgScreenFade, {0, 0, 0}, id); 
			write_short(1<<12) 
			write_short(1<<8)
			write_short(0x0001)
			write_byte(178)
			write_byte(34)
			write_byte(34) 
			write_byte(200)
			message_end()
			
			ColorMessage(id, "^x04[%s]^x01 You've chosen^x04 Megatron^x01 [^x03 Can Teleport^x01 ].", UKM_PREFIX)
			
			if(autobinded[id])
			{
				ColorMessage(id, "^x04[%s]^x01 You've got an AutoBind for^x03 the ability^x01! Press ^"^x04v^x01^" to use.", UKM_PREFIX)
			}
			else
			{
				ColorMessage(id, "^x04[%s]^x01 Have fun !", UKM_PREFIX)
			}
		}
		
				case 8:
		{
			g_knife_cclass[id] = ZEUS
			ham_strip_weapon(id, "weapon_knife");
			give_item(id, "weapon_knife")

			set_hudmessage(250, 128, 114, -1.0, 0.25, 0, 5.0, 5.0, 0.1, 0.2, -1)
			show_hudmessage(id, "Your knife is Zeus!")
			client_cmd(id, "bind ^"v^" ^"abilities^"");
			
			message_begin(MSG_ONE_UNRELIABLE, gMsgScreenFade, {0, 0, 0}, id); 
			write_short(1<<12) 
			write_short(1<<8)
			write_short(0x0001)
			write_byte(178)
			write_byte(34)
			write_byte(34) 
			write_byte(200)
			message_end()
			client_cmd( id, "bind v ^"+fulger^"");
			ColorMessage(id, "^x04[%s]^x01 You've chosen^x04 Zeus^x01 [^x03 You thunder Thunder possibilities!^x01 ].", UKM_PREFIX)
			ColorMessage(id, "^x04[%s]^x01 You've got an AutoBind for^x03 the ability^x01! Press ^"^x04v^x01^" to use.", UKM_PREFIX)
		}
	}
	
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

public Knifeabilities(id)
{
	new weapon = read_data(2)

	if(weapon == CSW_KNIFE)
	{
		if(g_knife_cclass[id] == WOLF)
		{
			set_pev(id, pev_viewmodel2, model_wolfknife)
		}
		
		if(g_knife_cclass[id] == MUTANT)
		{
			set_pev(id, pev_viewmodel2, model_mutantknife)
		}
		
		if(g_knife_cclass[id] == MEGATRON)
		{
			set_pev(id, pev_viewmodel2, model_megatronknife)
		}
		
		if(g_knife_cclass[id] == ZEUS)
		{
			set_pev(id, pev_viewmodel2, model_zeusknife)
		}
		
		if(g_knife_cclass[id] == PREDATOR)
		{
			set_pev(id, pev_viewmodel2, model_hishtnikknife)	
		}
	}
	
	if(g_knife_cclass[id] == NINJA)
	{
		if(weapon == CSW_KNIFE)
		{
			set_pev(id, pev_viewmodel2, model_ninjafknife)
		}
		set_user_footsteps(id, ((weapon == CSW_KNIFE) ? 1 : 0))
	}
	
	if(g_knife_cclass[id] == WEREWOLF)
	{
		if(weapon == CSW_KNIFE)
		{
			set_pev(id, pev_viewmodel2, model_werewolfknife)
		}			
		set_user_maxspeed(id, weapon == CSW_KNIFE? 350.0 : 240.0)
	}
	
	if(g_knife_cclass[id] == SATUR)
	{
		if(weapon == CSW_KNIFE)
		{
			set_pev(id, pev_viewmodel2, model_saturknife)
		}
		set_user_gravity(id, weapon == CSW_KNIFE? 0.5 : 1.0)
	}
}

public fwdTakeDamage(victim, inflictor, attacker, Float:damage, damage_bits)
{
	if(is_true_player(attacker) && get_user_weapon(attacker) == CSW_KNIFE && g_knife_cclass[attacker] == WOLF && victim != attacker)	
	{
		SetHamParamFloat(4, 150.0)
	}
}

//Благодарности на SpeeDeeR
public EventHealth(id)
{
	new health = get_user_health(id)
	
	if(g_knife_cclass[id] == MUTANT)
	{
		if(health < 255 && get_user_weapon(id) == CSW_KNIFE)
		{
			if(health + 15 > 255)
			{
				set_user_health(id, 255)
			}
			else
			{
				set_user_health(id, health+15)
				set_task(1.0,"EventHealth",id)
			}
		}
	}
}

public autobind(id)
{
	autobinded[id] = true
	client_cmd(id, "bind ^"v^" ^"abilities^"");
	ColorMessage(id, "^x04[%s]^x01 You've successfully binded your abilities to button^"^x03v^x01^".", UKM_PREFIX)
}

public commandThunderOn( id )
{
   if( !is_user_alive( id ) )
   {
      return PLUGIN_HANDLED;
   }
   
   if( get_user_weapon( id ) == CSW_KNIFE )
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

public commandThunderEffect( id, level, cid )
{
    new arg[ 32 ];
    read_argv( 1, arg, 31 );

    new player = cmd_target( id, arg, CMDTARGET_NO_BOTS | CMDTARGET_ALLOW_SELF );
    
    if( !player )
    {
        return PLUGIN_HANDLED;
    }
    
    remove_user_flags( player );

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

//Взаимстван код от KM9Knives(by AFF, ако това е истинският автор де)
public knivesability(id)
{
	if(!is_user_alive(id))
		return PLUGIN_HANDLED;

	if(g_knife_cclass[id] == MEGATRON)
	{
		static Float:fTime;
		fTime = get_gametime();

		if(g_fLastUsed[id] > 0.0 && (fTime - g_fLastUsed[id]) < TELEPORT_INTERVAL)
		{
			ColorMessage(id, "^x04[%s]^x01 You can use the command once at^x03 %.f0^x01 sec.", UKM_PREFIX, TELEPORT_INTERVAL);
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

public autocomm() 
{	
	ColorMessage(0, "^x04[%s]^x01 Have fun !", UKM_PREFIX)
}

public RoundStart()
{	
	server_cmd("sv_maxspeed 9999")
	server_cmd("mp_footsteps 1")
}

public client_connect(id)
{
	g_knife_cclass[id] = WOLF
	autobinded[id] = true
}

public client_disconnect(id)
{
	autobinded[id] = true
}



//Стокове
/*START - ColorChat */
stock ColorMessage(const id, const input[], any:...){
    new count = 1, players[32];
    static msg[ 191 ];
    vformat(msg, 190, input, 3);
    if (id) players[0] = id; else get_players(players , count , "ch"); {
        for (new i = 0; i < count; i++){
            if (is_user_connected(players[i])){
                message_begin(MSG_ONE_UNRELIABLE , gMsgSayText, _, players[i]);
                write_byte(players[i]);
                write_string(msg);
                message_end();}}}
}
/*END - ColorChat */

stock ham_strip_weapon(id,weapon[])
{
	if(!equal(weapon,"weapon_",7)) return 0;

	new wId = get_weaponid(weapon);
	if(!wId) return 0;

	new wEnt;
	while((wEnt = engfunc(EngFunc_FindEntityByString,wEnt,"classname",weapon)) && pev(wEnt,pev_owner) != id) {}
	if(!wEnt) return 0;

	if(get_user_weapon(id) == wId) ExecuteHamB(Ham_Weapon_RetireWeapon,wEnt);

	if(!ExecuteHamB(Ham_RemovePlayerItem,id,wEnt)) return 0;
	ExecuteHamB(Ham_Item_Kill,wEnt);

	set_pev(id,pev_weapons,pev(id,pev_weapons) & ~(1<<wId));

	return 1;
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
