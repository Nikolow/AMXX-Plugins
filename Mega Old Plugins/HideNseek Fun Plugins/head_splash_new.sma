#include		< amxmodx >
#include 		< hamsandwich>
#include 		< fakemeta_util >

#define write_coord_f(%1) 		engfunc(EngFunc_WriteCoord,%1)

#pragma semicolon 	1;

new g_SpriteMF;
new g_SpriteBlood[ 2 ];

new Float:g_fDelayPerHit = 0.5;
new Float:g_fDamagePerHit = 2.0;
new Float:g_fNextHitHeadSplash[ 33 ][ 32 ];

public plugin_init() 
{
	register_plugin( "Remake of HeadSplash", "1.0", "forti.FastFrags" );
	
	register_forward( FM_Touch, "Foward_Touch" );
}

public plugin_precache()
{
	g_SpriteMF = engfunc( EngFunc_PrecacheModel, "sprites/muzzleflash4.spr" );
	
	g_SpriteBlood[ 0 ] = engfunc( EngFunc_PrecacheModel, "sprites/blood.spr" );
	g_SpriteBlood[ 1 ] = engfunc( EngFunc_PrecacheModel, "sprites/bloodspray.spr" );
}
	
public Foward_Touch( id, iEnt )
{
	if( is_user_alive( id ) && is_user_alive( iEnt ) )
	{	
		if( get_user_team( id ) != get_user_team( iEnt ) )
		{
			if( //pev( id, pev_flags ) & FL_ONGROUND &&
			pev( iEnt, pev_flags ) & FL_ONGROUND )
			{
				if( pev( id, pev_groundentity ) == iEnt )
				{
					if( g_fNextHitHeadSplash[ id ][ iEnt ] <= get_gametime() )
					{
						g_fNextHitHeadSplash[ id ][ iEnt ] = get_gametime() + g_fDelayPerHit;
						
						if( !fm_get_user_godmode( iEnt ) )
							forti_TakeDamage( iEnt, id );
						
					}
				}
			}
		}
	}
}

stock forti_TakeDamage( iReceiver, iAttacker )
{
	static Float:fOrigin[ 3 ], Float:fDamage;
	pev( iReceiver, pev_origin, fOrigin );	
	
	fDamage = g_fDamagePerHit; 
	
	if( get_user_health( iReceiver ) <= floatround( fDamage ) )
	{
		message_begin( MSG_BROADCAST, SVC_TEMPENTITY );
		write_byte( TE_EXPLOSION );
		write_coord_f( fOrigin[ 0 ] );
		write_coord_f( fOrigin[ 1 ] );
		write_coord_f( fOrigin[ 2 ] );
		write_short( g_SpriteMF );
		write_byte( 40 );
		write_byte( 15 );
		write_byte( 4 );
		message_end();
	}
	else
	{
		message_begin( MSG_BROADCAST, SVC_TEMPENTITY );
		write_byte( TE_BLOODSPRITE );
		write_coord_f( fOrigin[ 0 ] + 8.0 );
		write_coord_f( fOrigin[ 1 ] );
		write_coord_f( fOrigin[ 2 ] + 26.0 );
		write_short( g_SpriteBlood[ 1 ] );
		write_short( g_SpriteBlood[ 0 ] );
		write_byte( random_num( 200, 250 ) );
		write_byte( 4 );
		message_end();
	}
	
	ExecuteHam( Ham_TakeDamage, iReceiver, "", iAttacker, fDamage, DMG_GENERIC );
}