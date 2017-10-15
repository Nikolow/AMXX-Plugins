#include <amxmodx>
#include <fakemeta>
#include <engine>

#define XO_WEAPON		4
#define m_iGrenadeType		96

enum _:Sprites
{
	SPRITE_BEAM,
	SPRITE_EXPLOSION,
	SPRITE_EXPLOSION2,
	SPRITE_SMOKE,
	SPRITE_CYLINDER,
	SPRITE_FLARE
}

new g_iSprites[ Sprites ];
new _MsgTempEntity, _pfnEmitSound;

new const g_szSndExplosion[] = "/Nikolow/he_explode.wav";
public plugin_precache()
{
	precache_sound( g_szSndExplosion );
	
	g_iSprites[ SPRITE_BEAM ] = precache_model( "sprites/Nikolow/he_trail.spr" );
	g_iSprites[ SPRITE_EXPLOSION ] = precache_model( "sprites/Nikolow/he_explode.spr" );
	g_iSprites[ SPRITE_EXPLOSION2 ] = precache_model( "sprites/Nikolow/he_explode2.spr" );
	g_iSprites[ SPRITE_SMOKE ] = precache_model( "sprites/Nikolow/he_smoke.spr" );
	g_iSprites[ SPRITE_CYLINDER ] = precache_model( "sprites/white.spr" );
	g_iSprites[ SPRITE_FLARE ] = precache_model( "sprites/Nikolow/he_3dmflaora.spr" );
}

public plugin_init() register_plugin( "Grenade Effects", "0.1", "hornet" );
	
public Message_TempEntity()
{
	new iType = get_msg_arg_int( 1 );
	
	if( iType != TE_EXPLOSION ) return PLUGIN_CONTINUE;
	
	return PLUGIN_HANDLED;
}
	
public pfnEmitSound( iEnt, iChannel, szSound[], Float:flVolume, Float:flAtt, Flags, iPitch )
{
	if( equal( szSound, "weapons/debris1.wav" ) || equal( szSound, "weapons/debris2.wav" ) || equal( szSound, "weapons/debris3.wav" ) )
	{
		if(!pev_valid(iEnt)) 
			return FMRES_IGNORED;

		new Float:vOrigin[ 3 ];
		pev( iEnt, pev_origin, vOrigin );
		
		vOrigin[ 2 ] -= 35.0;
		set_pev( iEnt, pev_origin, vOrigin );
		
		UTIL_Explosion( iEnt, g_iSprites[ SPRITE_EXPLOSION ], 50, 30, 4 );
		UTIL_Explosion( iEnt, g_iSprites[ SPRITE_EXPLOSION2 ], 50, 10, 4 );
		
		UTIL_Smoke( iEnt, g_iSprites[ SPRITE_SMOKE ], 30, 30 );
		UTIL_Smoke( iEnt, g_iSprites[ SPRITE_SMOKE ], 15, 25 );
		
		UTIL_DLight( iEnt, 100, 255, 128, 0, 255, 50, 20 );
		UTIL_BeamCylinder( iEnt, g_iSprites[ SPRITE_CYLINDER ], 0, 6, 20, 255, 255, 128, 0, 255, 0 );
		UTIL_SpriteTrail( iEnt, g_iSprites[ SPRITE_FLARE ], 20, 3, 3, 50, 0 );
		
		engfunc( EngFunc_EmitSound, iEnt, iChannel, g_szSndExplosion, flVolume, flAtt, Flags, iPitch );
		
		UnregisterEffects( iEnt );
		
		return FMRES_SUPERCEDE;
	}
	
	return FMRES_IGNORED;
}

public grenade_throw( id, iEnt, iWeapon )
{
	if( !_MsgTempEntity )
	{
		_MsgTempEntity = register_message( SVC_TEMPENTITY, "Message_TempEntity" );
		_pfnEmitSound = register_forward( FM_EmitSound, "pfnEmitSound" );
	}
	
	switch( iWeapon )
	{
		case CSW_HEGRENADE:
		{
			UTIL_BeamFollow( iEnt, g_iSprites[ SPRITE_BEAM ], 12, 40, 255, 128, 0, 255 );
			UTIL_BeamFollow( iEnt, g_iSprites[ SPRITE_BEAM ], 8, 30, 255, 135, 40, 150 );
			UTIL_BeamFollow( iEnt, g_iSprites[ SPRITE_BEAM ], 5, 5, 255, 255, 255, 255 );
		}
	}
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

UTIL_Smoke( iEnt, iSprite, iScale, iFramerate )
{
	new Float:vOrigin[ 3 ];
	pev( iEnt, pev_origin, vOrigin );
	
	message_begin( MSG_BROADCAST, SVC_TEMPENTITY );
	write_byte( TE_SMOKE );
	engfunc( EngFunc_WriteCoord, vOrigin[ 0 ] );
	engfunc( EngFunc_WriteCoord, vOrigin[ 1 ] );
	engfunc( EngFunc_WriteCoord, vOrigin[ 2 ] );
	write_short( iSprite );
	write_byte( iScale );
	write_byte( iFramerate );
	message_end();
}

UnregisterEffects( iIndex )
{
	new iEnt = 0;
	
	while( ( iEnt = find_ent_by_class( iEnt, "grenade" ) ) )
	{
		if( !( get_pdata_int( iEnt, m_iGrenadeType, XO_WEAPON ) & ( 1 << 8 ) ) && iEnt != iIndex )
			return;
	}
	
	unregister_message( SVC_TEMPENTITY, _MsgTempEntity );
	unregister_forward( FM_EmitSound, _pfnEmitSound );
	
	_MsgTempEntity = 0;
}