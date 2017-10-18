#include <amxmodx>
#include <fakemeta_util>

new gCvarEnabled;
new gCvarColor;
new gCvarDuration;
new gCvarDelay;
new gCvarHitself;
new gCvarDamage;
new gScreenfade
new gTrail;
new gGlass;
new gExplotion;
new bool: rzucaj=true;

new const gTaskFrostnade = 3256
new const gModelGlass[] = "models/glassgibs.mdl"
new const gModelTrail[] = "sprites/lgtning.spr"
new const gModelExplotion[] = "sprites/shockwave.spr"
new const gSoundWave[] = "warcraft3/frostnova.wav";
new const gSoundFrosted[] = "warcraft3/impalehit.wav";
new const gSoundBreak[] = "warcraft3/impalelaunch1.wav";

new bool:gIsFrosted[33];
new bool:gRestartAttempt[33];

public plugin_init() {
	register_plugin("Zamrazajacy", "1.5", "vaX!")
	
	gCvarEnabled = register_cvar("hns_fn_enabled", "1")
	gCvarColor = register_cvar("hns_fn_color", "0 128 255")
	gCvarDuration = register_cvar("hns_fn_duration", "5.0")
	gCvarDelay = register_cvar("hns_fn_delay", "1.5")
	gCvarHitself = register_cvar("hns_fn_hitself", "1")
	gCvarDamage = register_cvar("hns_fn_damage", "0")
	gScreenfade = get_user_msgid("ScreenFade")
	
	register_logevent("logeventRoundEnd", 2, "1=Round_End");
	register_event("TextMsg", "event_RestartAttempt", "a", "2=#Game_will_restart_in");
	register_event("ResetHUD", "event_ResetHud", "be");
	register_event("DeathMsg","event_DeathMsg","a");
	register_event( "HLTV", "eventRoundStart", "a", "1=0", "2=0" );
	
	register_forward(FM_PlayerPreThink,"fwd_PlayerPreThink");
	register_forward(FM_SetModel, "fwd_SetModel");
	
}

public plugin_precache(){
	gTrail = precache_model(gModelTrail)
	gExplotion = precache_model(gModelExplotion)
	gGlass = precache_model(gModelGlass)
	
	precache_sound(gSoundWave)
	precache_sound(gSoundFrosted)
	precache_sound(gSoundBreak)
}

public eventRoundStart(){
	set_task(2.0,"rzucamy");
}

public rzucamy(){
	rzucaj=true;
}

public logeventRoundEnd(){
	rzucaj = false;
}

public event_RestartAttempt(){
	new players[32], num;
	get_players(players, num, "a");
	
	for (new i; i < num; ++i)
		gRestartAttempt[players[i]] = true;
}

public event_ResetHud(id){
	if (gRestartAttempt[id]){
		gRestartAttempt[id] = false;
		return;
	}
	event_PlayerSpawn(id);
}

public event_PlayerSpawn(id){
	if(gIsFrosted[id]) 
		RemoveFrost(id);
}

public event_DeathMsg(){
	new id = read_data(2);
	
	if(gIsFrosted[id])
		RemoveFrost(id)
}

public fwd_PlayerPreThink(id){
	if(gIsFrosted[id]){
		set_pev(id, pev_velocity, Float:{0.0,0.0,0.0})		
		set_pev(id, pev_flags, pev(id, pev_flags) | FL_FROZEN); 
	}
}

public fwd_SetModel(entity, const model[]){
	static id
	id = pev(entity, pev_owner);
	
	if (!is_user_connected(id))
		return;
		
	if(equal(model,"models/w_smokegrenade.mdl") && get_pcvar_num(gCvarEnabled)){
		static Red, Green, Blue
		GetColor(Red, Green, Blue)
		
		fm_set_rendering(entity,kRenderFxGlowShell, Red, Green, Blue, kRenderNormal, 16);
		
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
		write_byte(TE_BEAMFOLLOW);
		write_short(entity);	// entity
		write_short(gTrail);	// sprite
		write_byte(20);		// life
		write_byte(10);		// width
		write_byte(150); // red
		write_byte(150); // green
		write_byte(250); // blue
		write_byte(255);	// brightness
		message_end();
		
		set_pev(entity, pev_nextthink, get_gametime() + 10.0);
		
		static args[2]
		args[0] = entity;
		args[1] = id;
		
		set_task(get_pcvar_float(gCvarDelay), "ExplodeFrost", gTaskFrostnade, args, sizeof args)
	}
}

public ExplodeFrost(const args[2]){ 	
	if(rzucaj){
		static ent
		ent = args[0]
	
		new id = args[1];
	
		// invalid entity
		if (!pev_valid(ent)) 
			return;
	
		// get origin
		static origin[3], Float:originF[3]
		pev(ent, pev_origin, originF);
		FVecIVec(originF, origin);
	
		// explosion
		CreateBlast(origin);
	
		// frost nade explode sound
		engfunc(EngFunc_EmitSound, ent, CHAN_WEAPON, gSoundWave, 1.0, ATTN_NORM, 0, PITCH_NORM)
	
		// collisions
		static victim
		victim = -1;
	
		while((victim = engfunc(EngFunc_FindEntityInSphere, victim, originF, 240.0)) != 0){
			if(!is_user_alive(victim) || gIsFrosted[victim])
			continue;
			
			if(get_pcvar_num(gCvarHitself)){
				if(get_user_team(id) == get_user_team(victim)){
					if(victim != id || !is_user_alive(id))
						continue;
				
				}
			}
		
			else {
				if(get_user_team(id) == get_user_team(victim))
					continue;
			}
		
			static Red, Green, Blue
			GetColor(Red, Green, Blue)		
	
			fm_set_rendering(victim, kRenderFxGlowShell, Red, Green, Blue, kRenderNormal,25)
			engfunc(EngFunc_EmitSound, victim, CHAN_WEAPON, gSoundFrosted, 1.0, ATTN_NORM, 0, PITCH_NORM)
	
			message_begin(MSG_ONE, gScreenfade, _, victim);
			write_short(~0); // duration
			write_short(~0); // hold time
			write_short(0x0004); // flags: FFADE_STAYOUT
			write_byte(Red); // red
			write_byte(Green); // green
			write_byte(Blue); // blue
			write_byte(150); // alpha
			message_end();
		
		
			if(pev(victim, pev_flags) & FL_ONGROUND)
				set_pev(victim, pev_gravity, 999999.9) 
			
			else
				set_pev(victim, pev_gravity, 0.000001) 
		
			if(get_pcvar_num(gCvarDamage)){
				new Float:health;
				pev(victim, pev_health, health);
			
				health -= float(get_pcvar_num(gCvarDamage))
			
				if(health <= 0){
					user_silentkill(victim);
					make_deathmsg(id, victim, 0, "frostnade")
				}
			
				else
					set_pev(victim, pev_health, health);
			}
			gIsFrosted[victim] = true;	
			set_task(get_pcvar_float(gCvarDuration), "RemoveFrost", victim)
		}
	
		engfunc(EngFunc_RemoveEntity, ent)
	}
}

public RemoveFrost(id){
	if(!gIsFrosted[id]) // not alive / not frozen anymore
		return;
		
	// unfreeze
	gIsFrosted[id] = false;
	set_pev(id, pev_flags, pev(id, pev_flags) & ~FL_FROZEN);
	set_pev(id, pev_gravity, 1.0)
	engfunc(EngFunc_EmitSound, id, CHAN_VOICE, gSoundBreak, 1.0, ATTN_NORM, 0, PITCH_NORM)
	
	fm_set_rendering(id)
	
	message_begin(MSG_ONE, gScreenfade, _, id);
	write_short(0); // duration
	write_short(0); // hold time
	write_short(0); // flags
	write_byte(0); // red
	write_byte(0); // green
	write_byte(0); // blue
	write_byte(0); // alpha
	message_end();
	
	static origin[3], Float:originF[3]
	pev(id, pev_origin, originF)
	FVecIVec(originF, origin)

	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(TE_BREAKMODEL);
	write_coord(origin[0]);		// x
	write_coord(origin[1]);		// y
	write_coord(origin[2] + 24);	// z
	write_coord(16);		// size x
	write_coord(16);		// size y
	write_coord(16);		// size z
	write_coord(random_num(-50,50));// velocity x
	write_coord(random_num(-50,50));// velocity y
	write_coord(25);		// velocity z
	write_byte(10);			// random velocity
	write_short(gGlass);		// model
	write_byte(10);			// count
	write_byte(25);			// life
	write_byte(0x01);		// flags: BREAK_GLASS
	message_end();
}
	
CreateBlast(const origin[3]){
	static Red, Green, Blue
	GetColor(Red, Green, Blue)
	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(TE_BEAMCYLINDER);
	write_coord(origin[0]); // start X
	write_coord(origin[1]); // start Y
	write_coord(origin[2]); // start Z
	write_coord(origin[0]); // something X
	write_coord(origin[1]); // something Y
	write_coord(origin[2] + 385); // something Z
	write_short(gExplotion); // sprite
	write_byte(0); // startframe
	write_byte(0); // framerate
	write_byte(4); // life
	write_byte(60); // width
	write_byte(0); // noise
	write_byte(Red); // red
	write_byte(Green); // green
	write_byte(Blue); // blue
	write_byte(200); // brightness
	write_byte(0); // speed
	message_end();

	// medium ring
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(TE_BEAMCYLINDER);
	write_coord(origin[0]); // start X
	write_coord(origin[1]); // start Y
	write_coord(origin[2]); // start Z
	write_coord(origin[0]); // something X
	write_coord(origin[1]); // something Y
	write_coord(origin[2] + 470); // something Z
	write_short(gExplotion); // sprite
	write_byte(0); // startframe
	write_byte(0); // framerate
	write_byte(4); // life
	write_byte(60); // width
	write_byte(0); // noise
	write_byte(Red); // red
	write_byte(Green); // green
	write_byte(Blue); // blue
	write_byte(200); // brightness
	write_byte(0); // speed
	message_end();

	// largest ring
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(TE_BEAMCYLINDER);
	write_coord(origin[0]); // start X
	write_coord(origin[1]); // start Y
	write_coord(origin[2]); // start Z
	write_coord(origin[0]); // something X
	write_coord(origin[1]); // something Y
	write_coord(origin[2] + 555); // something Z
	write_short(gExplotion); // sprite
	write_byte(0); // startframe
	write_byte(0); // framerate
	write_byte(4); // life
	write_byte(60); // width
	write_byte(0); // noise
	write_byte(150); // red
	write_byte(150); // green
	write_byte(250); // blue
	write_byte(200); // brightness
	write_byte(0); // speed
	message_end();
}

GetColor(&r, &g, &b){
	new Color[16], Red[4], Green[4], Blue[4];
	get_pcvar_string(gCvarColor, Color, 15)
	parse(Color, Red, 3, Green, 3, Blue, 3)
	
	r = str_to_num(Red)
	g = str_to_num(Green)
	b = str_to_num(Blue)
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
