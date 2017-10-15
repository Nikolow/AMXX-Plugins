#include <amxmodx>
#include <fakemeta>
#include <colorchat>

#pragma semicolon 1

enum AttackType
{
	STAB = 0,
	SLASH
};

enum TraceType
{
	TRACELINE = 0,
	TRACEHULL
};

enum Sound 
{
	WICKEDSICK = 0,
	GODLIKE
};

enum HitData
{
	AttackType:iAttack,
	Float:flDistance,
	iHitgroup,
	iAttacker,
	iVictim
};

new g_szTraceType[TraceType][] =
{
	"TraceLine",
	"TraceHull"
};

new g_szSound[Sound][] =
{
	"misc/wickedsick.wav",
	"misc/godlike.wav"
};

new g_HitData[HitData];

new g_szHitgroup[8][] =
{
	"Full Body",
	"Head",
	"Chest",
	"Stomach",
	"Left Arm",
	"Right Arm",
	"Left Leg",
	"Right Leg"
};

new bool:g_bKnifeHit;

new g_szNickname[33][32];

new g_pCVarFriendlyFire;

new g_pCVarSoundWickedSickStab;
new g_pCVarSoundGodlikeStab;
new g_pCVarSoundWickedSickSlash;
new g_pCVarSoundGodlikeSlash;

new g_pCVarHudColor;
new g_pCVarHudCoords;
new g_pCVarHudHoldtime;

public plugin_precache( )
{
	precache_sound( g_szSound[WICKEDSICK] );
	precache_sound( g_szSound[GODLIKE] );
}

public plugin_init( )
{
	register_plugin( "Knife Distance", "0.4", "SchlumPF" );
	
	g_pCVarSoundWickedSickStab = register_cvar( "kd_sound_wickedsick_stab", "30" );
	g_pCVarSoundGodlikeStab = register_cvar( "kd_sound_godlike_stab", "31" );
	g_pCVarSoundWickedSickSlash = register_cvar( "kd_sound_wickedsick_slash", "46" );
	g_pCVarSoundGodlikeSlash = register_cvar( "kd_sound_godlike_slash", "47" );
	
	g_pCVarHudColor = register_cvar( "kd_hud_color", "0 250 150" );
	g_pCVarHudCoords = register_cvar( "kd_hud_coords", "-0.75 -1.0" );
	g_pCVarHudHoldtime = register_cvar( "kd_hud_holdtime", "2.0" );
	
	register_forward( FM_TraceLine, "FM_TraceLine_Post", 1 );
	register_forward( FM_TraceHull, "FM_TraceHull_Post", 1 );
	
	register_event( "Damage", "eventDamage", "b" );
	
	g_pCVarFriendlyFire = get_cvar_pointer( "mp_friendlyfire" );
}

public FM_TraceLine_Post( Float:vecSrc[3], Float:vecEnd[3], noMonsters, skipEnt, tr )
{ 
	if( !is_user_alive( skipEnt ) )
	{
		return FMRES_IGNORED;
	}
	
	if( get_user_weapon( skipEnt ) != CSW_KNIFE )
	{
		return FMRES_IGNORED;
	}
	
	static button;
	button = pev( skipEnt, pev_button );
	
	if( !( button & IN_ATTACK ) && !( button & IN_ATTACK2 ) )
	{
		return FMRES_IGNORED;
	}
	
	static Float:flFraction;
	get_tr2( tr, TR_flFraction, flFraction );
	
	if( flFraction >= 1.0 )
	{
		return FMRES_IGNORED;
	}
	
	static pHit;
	pHit = get_tr2( tr, TR_pHit );
	
	if( get_user_team( skipEnt ) == get_user_team( pHit ) && !get_pcvar_num( g_pCVarFriendlyFire ) )
	{
		return FMRES_IGNORED;
	}

	static Float:vecEndPos[3];
	get_tr2( tr, TR_vecEndPos, vecEndPos );

	static Float:distance;
	distance = vector_distance( vecSrc, vecEndPos );
	
	static Float:range;
	range = distance / flFraction; // vector_distance( vecSrc, vecEnd )
	
	if( 31.89 < range < 32.1 )
	{
		GetTraceData( tr, skipEnt, pHit, distance, STAB );
	}
	else if( 47.89 < range < 48.1 )
	{
		GetTraceData( tr, skipEnt, pHit,  distance, SLASH );
	}
	
	return FMRES_IGNORED;
}

public FM_TraceHull_Post( Float:vecSrc[3], Float:vecEnd[3], noMonsters, hull, skipEnt, tr )
{
	if( !is_user_alive( skipEnt ) )
	{
		return FMRES_IGNORED;
	}
	
	if( get_user_weapon( skipEnt ) != CSW_KNIFE )
	{
		return FMRES_IGNORED;
	}
	
	static Float:flFraction;
	get_tr2( tr, TR_flFraction, flFraction );
	
	if( flFraction >= 1.0 )
	{
		return FMRES_IGNORED;
	}
	
	static pHit;
	pHit = get_tr2( tr, TR_pHit );
	
	if( get_user_team( skipEnt ) == get_user_team( pHit ) && !get_pcvar_num( g_pCVarFriendlyFire ) )
	{
		return FMRES_IGNORED;
	}
	
	static Float:vecEndPos[3];
	get_tr2( tr, TR_vecEndPos, vecEndPos );

	static Float:distance;
	distance = vector_distance( vecSrc, vecEndPos );
	
	static Float:range;
	range = distance / flFraction; // vector_distance( vecSrc, vecEnd )
	
	if( 31.89 < range < 32.1 )
	{
		GetTraceData( tr, skipEnt, pHit, distance, STAB );
	}
	else if( 47.89 < range < 48.1 )
	{
		GetTraceData( tr, skipEnt, pHit, distance, SLASH );
	}
	
	return FMRES_IGNORED;
}

public GetTraceData( tr, attacker, victim, Float:distance, AttackType:attack )
{
	g_HitData[iAttack] = any:attack;
	g_HitData[flDistance] = any:distance;
	g_HitData[iHitgroup] = get_tr2( tr, TR_iHitgroup );
	g_HitData[iAttacker] = attacker;
	g_HitData[iVictim] = victim;
	
	g_bKnifeHit = true;
}

public eventDamage( )
{
	if( g_bKnifeHit )
	{
		g_bKnifeHit = false;
		
		static victim;
		victim = g_HitData[iVictim];
		
		if( !( 1 <= victim <= 32 ) )
		{
			return PLUGIN_CONTINUE;
		}
		
		static attacker;
		attacker = g_HitData[iAttacker];
		
		static Float:distance;
		distance = g_HitData[flDistance];
		
		static Float:health;
		pev( victim, pev_health, health );
		
		static r, g, b;
		GetHudColor( r, g, b );
		
		static Float:x, Float:y;
		GetHudCoords( x, y );
		
		set_hudmessage( r, g, b, x, y, 0, 0.0, get_pcvar_float( g_pCVarHudHoldtime ), 0.0, 0.0, 1 );
		
		if( g_HitData[iAttack] == STAB )
		{
			show_hudmessage( attacker, "Stab Stats (%s)^nDistance: %f (max: 32.0)^nHit: %s (%s)^nDamage: %i"\
				, g_szTraceType[TraceType:!g_HitData[iHitgroup]],\
				distance, g_szNickname[victim],\
				g_szHitgroup[g_HitData[iHitgroup]], pev( victim, pev_dmg_take ) );
		
			if( health < 0.0 )
			{
				ColorChat( victim, BLUE, "[Knife Distance] %s stabbed you within %f units (%s)!",\
					g_szNickname[attacker],\
					distance, g_szHitgroup[g_HitData[iHitgroup]] );
				
				if( distance >= get_pcvar_float( g_pCVarSoundGodlikeStab ) )
				{
					ColorChat( 0, RED, "[Knife Distance] %s stabbed %s within %f units (%s)!",\
						g_szNickname[attacker], g_szNickname[victim],\
						distance, g_szHitgroup[g_HitData[iHitgroup]] );
					client_cmd( 0, "spk %s", g_szSound[GODLIKE] );
						
				}
				else if( distance >= get_pcvar_float( g_pCVarSoundWickedSickStab ) )
				{
					ColorChat( 0, GREEN, "[Knife Distance] %s stabbed %s within %f units (%s)!",\
						g_szNickname[attacker], g_szNickname[victim],\
						distance, g_szHitgroup[g_HitData[iHitgroup]] );
					client_cmd( 0, "spk %s", g_szSound[WICKEDSICK] );
				}
			}
		}
		else
		{
			show_hudmessage( attacker, "Slash Stats (%s)^nDistance: %f (max: 48.0)^nHit: %s (%s)^nDamage: %i"\
				, g_szTraceType[TraceType:!g_HitData[iHitgroup]],\
				distance, g_szNickname[victim],\
				g_szHitgroup[g_HitData[iHitgroup]], pev( victim, pev_dmg_take ) );
			
			if( health < 0.0 )
			{
				ColorChat( victim, BLUE, "[Knife Distance] %s slashed you within %f units (%s)!",\
					g_szNickname[attacker],\
					distance, g_szHitgroup[g_HitData[iHitgroup]] );
				
				if( distance >= get_pcvar_float( g_pCVarSoundGodlikeSlash ) )
				{
					ColorChat( 0, RED, "[Knife Distance] %s slashed %s within %f units (%s)!",\
						g_szNickname[attacker], g_szNickname[victim],\
						distance, g_szHitgroup[g_HitData[iHitgroup]] );
					client_cmd( 0, "spk %s", g_szSound[GODLIKE] );
				}
				else if( distance >= get_pcvar_float( g_pCVarSoundWickedSickSlash ) )
				{
					ColorChat( 0, GREEN, "[Knife Distance] %s slashed %s within %f units (%s)!",\
						g_szNickname[attacker], g_szNickname[victim],\
						distance, g_szHitgroup[g_HitData[iHitgroup]] );
					client_cmd( 0, "spk %s", g_szSound[WICKEDSICK] );
				}
			}
		}
	}
	
	return PLUGIN_CONTINUE;
}

public client_infochanged( plr )
{
	static curName[32], newName[32];
	get_user_name( plr, curName, 31 );
	get_user_info( plr, "name", newName, 31 );
	
	if( !equal( newName, curName ) )
	{
		copy( g_szNickname[plr], 31, newName );
	}
}

public GetHudColor( &r, &g, &b )
{
	static color[16], piece[5];
	get_pcvar_string( g_pCVarHudColor, color, 15 );
	
	strbreak( color, piece, 4, color, 15 );
	r = str_to_num( piece );
	
	strbreak( color, piece, 4, color, 15 );
	g = str_to_num( piece );
	b = str_to_num( color );
}

public GetHudCoords( &Float:x, &Float:y )
{
	static coords[16], piece[10];
	get_pcvar_string( g_pCVarHudCoords, coords, 15 );
	
	strbreak( coords, piece, 9, coords, 15 );
	x = str_to_float( piece );
	y = str_to_float( coords );
}
