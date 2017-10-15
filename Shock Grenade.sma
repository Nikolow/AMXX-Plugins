#include <amxmodx>
#include <cstrike>
#include <fakemeta>
#include <fun>
#include <hamsandwich>

#define FFADE_IN		0x0000 
#define ICON_HASNADE		1
#define TASKID 6431
#define message_begin_fl(%1,%2,%3,%4) engfunc(EngFunc_MessageBegin, %1, %2, %3, %4)
#define write_coord_fl(%1) engfunc(EngFunc_WriteCoord, %1)
#define m_pPlayer		41
#define OFFSET_WEAPON_CSWID	43
#define MAX_WEAPONS		32
#define AMMO_FLASHBANG		11
#define AMMO_HEGRENADE		12
#define AMMO_SMOKEGRENADE	13
#define DMG_GRENADE		(1<<24)
#define STATUS_HIDE		0
#define STATUS_SHOW		1
#define STATUS_FLASH		2
#define shock_RADIUS		240.0
#define NT_FLASHBANG		(1<<0) // 1; CSW:25
#define NT_HEGRENADE		(1<<1) // 2; CSW:4
#define NT_SMOKEGRENADE		(1<<2) // 4; CSW:9

enum
{
	Float:x = 400.0, 	// x
	Float:y = 999.0, 	// y
	Float:z = 400.0 	// z
}

new sh_nadetypes, sh_by_radius, sh_hitself, sh_los, sh_maxdamage, sh_mindamage,sh_slow;
new maxPlayers, gmsgStatusIcon, mp_friendlyfire,bool:roundRestarting;
new shockKilled[33],hasshockNade[33], nadesBought[33];
new MsgScreenShake, gmsgScreenFade, smokeSpr, sprSpr3;
new g_slowdown[33] = 0, g_gametime[33] = 0

public plugin_init()
{
	register_plugin( "Shock Grenade", "1.2", "Dedihost n/ Nikolow" );

	sh_nadetypes = register_cvar("sh_nadetypes","2"); //Smoke - 4 || Flash - 1 | HE - 2
	sh_slow = register_cvar("sh_slow","1"); //da ima li zabavqne ?!

	sh_by_radius = register_cvar("sh_by_radius","20.0"); //radius kato float
	sh_hitself = register_cvar("sh_hitself","0"); //da te hitva li ako ti q metnesh
	sh_los = register_cvar("sh_los","1"); //da go zaseche li ako e na kraq na radiusa
	sh_maxdamage = register_cvar("sh_maxdamage","0.0"); //da pravi li dmg kato float
	sh_mindamage = register_cvar("sh_mindamage","0.0"); //minimalen dmg kato float

	mp_friendlyfire = get_cvar_pointer("mp_friendlyfire");
	
	MsgScreenShake = get_user_msgid("ScreenShake");
	
	maxPlayers = get_maxplayers();
	gmsgStatusIcon = get_user_msgid("StatusIcon");
	gmsgScreenFade = get_user_msgid("ScreenFade");
	
	register_forward(FM_SetModel,"fw_setmodel",1);
	register_message(get_user_msgid("DeathMsg"),"msg_deathmsg");
	
	register_event("TextMsg", "event_round_restart", "a", "2=#Game_Commencing", "2=#Game_will_restart_in");
	register_event("HLTV", "event_new_round", "a", "1=0", "2=0");

	RegisterHam(Ham_Spawn,"player","ham_player_spawn",1);
	RegisterHam(Ham_Think,"grenade","ham_grenade_think",0);
	RegisterHam(Ham_Use, "player_weaponstrip", "ham_player_weaponstrip_use", 1);
}

enum _:Sprites
{
	SPRITE_CYLINDER,
	SPRITE_SHOCK,
	SPRITE_BEAM2,
	SPRITE_FLAKE
}
new g_iSprites[ Sprites ];
new const g_szSndShock[] = "Nikolow/shock_explode.wav";
new const SPRITE_SPRITE3[]	= "sprites/Nikolow/shock_smoke.spr";
new const SPRITE_SMOKE[]	= "sprites/steam1.spr";

public plugin_precache()
{
	precache_sound( g_szSndShock );
	sprSpr3 = precache_model(SPRITE_SPRITE3);
	smokeSpr = precache_model(SPRITE_SMOKE);
	g_iSprites[ SPRITE_CYLINDER ] = precache_model( "sprites/white.spr" );
	g_iSprites[ SPRITE_SHOCK ] = precache_model( "sprites/Nikolow/shock_explode.spr" );
	g_iSprites[ SPRITE_BEAM2 ] = precache_model( "sprites/Nikolow/shock_trail.spr" );
	g_iSprites[ SPRITE_FLAKE ] = precache_model( "sprites/Nikolow/shock_flare.spr" );
}

public client_putinserver(id)
{
	shockKilled[id] = 0;
	hasshockNade[id] = 0;
}

public client_disconnect(id) remove_task(id+TASKID)

public fw_setmodel(ent,model[])
{
	new owner = pev(ent,pev_owner);
	if(!is_user_connected(owner)) return FMRES_IGNORED;
	
	new Float:dmgtime;
	pev(ent,pev_dmgtime,dmgtime);
	if(dmgtime == 0.0) return FMRES_IGNORED;
	
	new type, csw;
	if(model[7] == 'w' && model[8] == '_')
	{
		switch(model[9])
		{
			case 'h': { type = NT_HEGRENADE; csw = CSW_HEGRENADE; }
			case 'f': { type = NT_FLASHBANG; csw = CSW_FLASHBANG; }
			case 's': { type = NT_SMOKEGRENADE; csw = CSW_SMOKEGRENADE; }
		}
	}
	if(!type) return FMRES_IGNORED;
	
	new team = _:cs_get_user_team(owner);

	if(hasshockNade[owner] == csw || (get_pcvar_num(sh_nadetypes) & type))
	{
		if(hasshockNade[owner] == csw)
		{
			hasshockNade[owner] = 0;
		}

		set_pev(ent,pev_team,team);
		set_pev(ent,pev_bInDuck,1);
		
		// glowshell
		set_pev(ent,pev_rendermode,kRenderNormal);
		set_pev(ent,pev_renderfx,kRenderFxGlowShell);
		set_pev(ent,pev_rendercolor,{255.0, 200.0, 0.0});
		set_pev(ent,pev_renderamt,16.0);

		UTIL_BeamFollow( ent, g_iSprites[ SPRITE_BEAM2 ], 20, 10, 255, 200, 0, 255 ); 
	}

	return FMRES_IGNORED;
}

public msg_deathmsg(msg_id,msg_dest,msg_entity)
{
	new victim = get_msg_arg_int(2);
	if(!is_user_connected(victim) || !shockKilled[victim]) return PLUGIN_CONTINUE;

	static weapon[8];
	get_msg_arg_string(4,weapon,7);
	if(equal(weapon,"grenade")) set_msg_arg_string(4,"shockgrenade");

	return PLUGIN_CONTINUE;
}

public event_round_restart() roundRestarting = true;

public event_new_round()
{
	if(roundRestarting)
	{
		roundRestarting = false;
		
		for(new i=1;i<=maxPlayers;i++)
		{
			hasshockNade[i] = 0;
			g_slowdown[i] = 0
			g_gametime[i] = 0
		}
	}
}

public ham_player_spawn(id)
{
	nadesBought[id] = 0;
	
	return HAM_IGNORED;
}

public ham_grenade_think(ent)
{
	if(!pev_valid(ent) || !pev(ent,pev_bInDuck)) return HAM_IGNORED;
	
	new Float:dmgtime;
	pev(ent,pev_dmgtime,dmgtime);
	if(dmgtime > get_gametime()) return HAM_IGNORED;
	
	shocknade_explode(ent);

	return HAM_SUPERCEDE;
}

public ham_player_weaponstrip_use(ent, idcaller, idactivator, use_type, Float:value)
{
	if(idcaller >= 1 && idcaller <= maxPlayers)
	{
		hasshockNade[idcaller] = 0;
	}

	return HAM_IGNORED;
}

public Shake(id)
{
	new Dura = UTIL_FixedUnsigned16(9.0, 1 << 12) //4.0
	new Freq = UTIL_FixedUnsigned16(5.0 , 1 << 8) //0.7
	new Ampl = UTIL_FixedUnsigned16(5.0, 1 << 12) //20.0
	
	message_begin(MSG_ONE , MsgScreenShake , {0,0,0} ,id)
	write_short( Ampl ) // --| Shake amount.
	write_short( Dura ) // --| Shake lasts this long.
	write_short( Freq ) // --| Shake noise frequency.
	message_end ()
}

UTIL_FixedUnsigned16 ( const Float:Value, const Scale ) return clamp( floatround( Value * Scale ), 0, 0xFFFF );

public shocknade_explode(ent)
{
	if(!pev_valid(ent)) 
		return FMRES_IGNORED;
	
	new nadeTeam = pev(ent,pev_team), owner = pev(ent,pev_owner), Float:nadeOrigin[3];
	pev(ent,pev_origin,nadeOrigin);
	
	///////////////////////////////////////////////////////////////
	//////////////////////
	///////////////
	// effects
	
	
	// make the smoke
	message_begin_fl(MSG_PVS,SVC_TEMPENTITY,nadeOrigin,0);
	write_byte(TE_SMOKE);
	write_coord_fl(nadeOrigin[0]); // x
	write_coord_fl(nadeOrigin[1]); // y
	write_coord_fl(nadeOrigin[2]); // z
	write_short(smokeSpr); // sprite
	write_byte(random_num(30,40)); // scale
	write_byte(5); // framerate
	message_end();
	
	if(!pev_valid(ent)) 
		return FMRES_IGNORED;
		
	new Float:vOrigin[ 3 ];
	pev( ent, pev_origin, vOrigin );
		
	UTIL_Explosion( ent, g_iSprites[ SPRITE_SHOCK ], 40, 15, 4 ); //30
		
	UTIL_DLight( ent, 100, 255, 200, 0, 255, 95, 20 ); //50
	UTIL_BeamCylinder( ent, g_iSprites[ SPRITE_CYLINDER ], 0, 3, 10, 255, 255, 200, 0, 255, 0 );
	UTIL_SpriteTrail( ent, g_iSprites[ SPRITE_FLAKE ], 30, 3, 2, 30, 0 );

	emit_sound(ent,CHAN_ITEM,g_szSndShock,VOL_NORM,ATTN_NORM,0,PITCH_HIGH);

	//remove_entity( ent );
	
	engfunc(EngFunc_MessageBegin, MSG_BROADCAST,SVC_TEMPENTITY, vOrigin, 0)
	write_byte(TE_EXPLOSION)
	engfunc(EngFunc_WriteCoord, vOrigin[0]) // x axis
	engfunc(EngFunc_WriteCoord, vOrigin[1]) // y axis
	engfunc(EngFunc_WriteCoord, vOrigin[2]+75) // z axis
	write_short(sprSpr3) 
	write_byte(22)
	write_byte(28)
	write_byte(TE_EXPLFLAG_NOSOUND)
	message_end()
	
	
	///////////////////////////////////////////////////////////////
	//////////////////////
	///////////////
	
	// explosion
	//emit_sound(ent,CHAN_ITEM,SOUND_EXPLODE,VOL_NORM,ATTN_NORM,0,PITCH_HIGH);

	// cache our cvars
	new ff = get_pcvar_num(mp_friendlyfire), Float:by_radius = get_pcvar_float(sh_by_radius),
	hitself = get_pcvar_num(sh_hitself), los = get_pcvar_num(sh_los), Float:maxdamage = get_pcvar_float(sh_maxdamage),
	Float:mindamage = get_pcvar_float(sh_mindamage)

	new ta, Float:targetOrigin[3], Float:distance, tr = create_tr2(), Float:fraction, Float:damage;
	for(new target=1;target<=maxPlayers;target++)
	{
		if(!is_user_alive(target) || pev(target,pev_takedamage) == DAMAGE_NO || (pev(target,pev_flags) & FL_GODMODE) ||(target == owner && !hitself))
			continue;
		
		ta = (_:cs_get_user_team(target) == nadeTeam);
		if(ta && !ff && target != owner) continue;
		
		if(!pev_valid(ent)) 
			return FMRES_IGNORED;
		
		pev(target,pev_origin,targetOrigin);
		distance = vector_distance(nadeOrigin,targetOrigin);
		
		if(distance > shock_RADIUS) continue;

		// check line of sight
		if(los)
		{
			nadeOrigin[2] += 2.0;
			engfunc(EngFunc_TraceLine,nadeOrigin,targetOrigin,DONT_IGNORE_MONSTERS,ent,tr);
			nadeOrigin[2] -= 2.0;

			get_tr2(tr,TR_flFraction,fraction);
			if(fraction != 1.0 && get_tr2(tr,TR_pHit) != target) continue;
		}

		// damaged
		if(maxdamage > 0.0)
		{
			damage = radius_calc(distance,shock_RADIUS,maxdamage,mindamage);
			if(ta) damage /= 2.0; // half damage for friendlyfire

			if(damage > 0.0)
			{
				shockKilled[target] = 1;
				ExecuteHamB(Ham_TakeDamage,target,ent,owner,damage,DMG_GRENADE);
				if(!is_user_alive(target)) continue; // dead now
				shockKilled[target] = 0;
			}
		}
		
		message_begin(MSG_ONE,gmsgScreenFade,_,target);
		write_short(floatround(4096.0 * 5)); // duration
		write_short(floatround(3072.0 * 4)); // hold time (4096.0 * 0.75)
		write_short(FFADE_IN); // flags
		write_byte(255); // red
		write_byte(200); // green
		write_byte(0); // blue
		write_byte(100); // alpha
		message_end();
		
		show_icon(target, STATUS_SHOW);

		// shock
		if(radius_calc(distance,shock_RADIUS,100.0,0.0) >= by_radius)
		{
			//tuk moq kod za preobrushtaneto
			if(!pev_valid(ent)) 
				return FMRES_IGNORED;
				
			set_pev(target, pev_punchangle, Float:{x, y, z})
			if(get_pcvar_num(sh_slow) == 1) 
			{
				g_slowdown[target] = 1;
				set_user_maxspeed(target, 200.0) 
				set_task(0.7,"remove_slow",target+TASKID,_,_,"b")
			}
			set_task(0.1, "Shake", target)
		}
	}
	
	if(!pev_valid(ent)) 
		return FMRES_IGNORED;

	free_tr2(tr);
	set_pev(ent,pev_flags,pev(ent,pev_flags)|FL_KILLME);
	
	return FMRES_SUPERCEDE;
}

public remove_slow(TASK) 
{
	new id = TASK - TASKID
	g_gametime[id]++
	set_user_maxspeed(id, 100.0) 
	
	if(g_gametime[id] >= 10.0) 
	{
		set_user_maxspeed(id, 250.0) 
		g_slowdown[id] = 0
		g_gametime[id] = 0
		remove_task(id+TASKID)
		
		show_icon(id, STATUS_HIDE);
		
		return PLUGIN_HANDLED;
	}
	return PLUGIN_CONTINUE;
}

show_icon(id, status)
{
	message_begin(MSG_ONE,gmsgStatusIcon,_,id);
	write_byte(status); // status (0=hide, 1=show, 2=flash)
	write_string("dmg_shock"); // sprite name
	write_byte(255); // red
	write_byte(200); // green
	write_byte(0); // blue
	message_end();
}

Float:radius_calc(Float:distance,Float:radius,Float:maxVal,Float:minVal)
{
	if(maxVal <= 0.0) return 0.0;
	if(minVal >= maxVal) return minVal;
	return minVal + ((1.0 - (distance / radius)) * (maxVal - minVal));
}

UTIL_DLight( iEnt, iRadius, iRed, iGreen, iBlue, iBright, iLife, iDecay )
{
	new Float:vOrigin[ 3 ];
	pev( iEnt, pev_origin, vOrigin );
	
	message_begin( MSG_BROADCAST, SVC_TEMPENTITY );
	write_byte( TE_DLIGHT );
	engfunc( EngFunc_WriteCoord, vOrigin[ 0 ] );
	engfunc( EngFunc_WriteCoord, vOrigin[ 1 ] );
	engfunc( EngFunc_WriteCoord, vOrigin[ 2 ] );
	write_byte( iRadius );
	write_byte( iRed );
	write_byte( iGreen );
	write_byte( iBlue );
	write_byte( iBright );
	write_byte( iLife );
	write_byte( iDecay );
	message_end();
}

UTIL_Explosion( iEnt, iSprite, iScale, iFramerate, Flags )
{
	new Float:vOrigin[ 3 ];
	pev( iEnt, pev_origin, vOrigin );
	
	message_begin( MSG_BROADCAST, SVC_TEMPENTITY );
	write_byte( TE_EXPLOSION );
	engfunc( EngFunc_WriteCoord, vOrigin[ 0 ] );
	engfunc( EngFunc_WriteCoord, vOrigin[ 1 ] );
	engfunc( EngFunc_WriteCoord, vOrigin[ 2 ] );
	write_short( iSprite );
	write_byte( iScale );
	write_byte( iFramerate );
	write_byte( Flags );
	message_end();
}

UTIL_SpriteTrail( iEnt, iSprite, iCount, iLife, iScale, iVelocity, iVary )
{
	new Float:vOrigin[ 3 ];
	pev( iEnt, pev_origin, vOrigin );
	
	message_begin( MSG_BROADCAST, SVC_TEMPENTITY );
	write_byte( TE_SPRITETRAIL );
	engfunc( EngFunc_WriteCoord, vOrigin[ 0 ] );
	engfunc( EngFunc_WriteCoord, vOrigin[ 1 ] );
	engfunc( EngFunc_WriteCoord, vOrigin[ 2 ] + 100 );
	engfunc( EngFunc_WriteCoord, vOrigin[ 0 ] + random_float( -200.0, 200.0 ) );
	engfunc( EngFunc_WriteCoord, vOrigin[ 1 ] + random_float( -200.0, 200.0 ) );
	engfunc( EngFunc_WriteCoord, vOrigin[ 2 ] );
	write_short( iSprite );
	write_byte( iCount );
	write_byte( iLife );
	write_byte( iScale );
	write_byte( iVelocity );
	write_byte( iVary );
	message_end();
}

UTIL_BeamFollow( iEnt, iSprite, iLife, iWidth, iRed, iGreen, iBlue, iBright )
{
	message_begin( MSG_BROADCAST, SVC_TEMPENTITY );
	write_byte( TE_BEAMFOLLOW );
	write_short( iEnt );
	write_short( iSprite );
	write_byte( iLife );
	write_byte( iWidth );
	write_byte( iRed );
	write_byte( iGreen );
	write_byte( iBlue );
	write_byte( iBright );
	message_end()
}

UTIL_BeamCylinder( iEnt, iSprite, iFramerate, iLife, iWidth, iAmplitude, iRed, iGreen, iBlue, iBright, iSpeed )
{
	new Float:vOrigin[ 3 ];
	pev( iEnt, pev_origin, vOrigin );
	
	message_begin( MSG_BROADCAST, SVC_TEMPENTITY );
	write_byte( TE_BEAMCYLINDER );
	engfunc( EngFunc_WriteCoord, vOrigin[ 0 ] );
	engfunc( EngFunc_WriteCoord, vOrigin[ 1 ] );
	engfunc( EngFunc_WriteCoord, vOrigin[ 2 ] + 10 );
	engfunc( EngFunc_WriteCoord, vOrigin[ 0 ] );
	engfunc( EngFunc_WriteCoord, vOrigin[ 1 ] + 400 );
	engfunc( EngFunc_WriteCoord, vOrigin[ 2 ] + 400 );
	write_short( iSprite );
	write_byte( 0 );
	write_byte( iFramerate );
	write_byte( iLife );
	write_byte( iWidth );
	write_byte( iAmplitude );
	write_byte( iRed );
	write_byte( iGreen );
	write_byte( iBlue );
	write_byte( iBright );
	write_byte( iSpeed );
	message_end()
}