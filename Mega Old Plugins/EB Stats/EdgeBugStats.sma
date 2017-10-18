#include < amxmodx >
#include < fakemeta >
#include < hamsandwich >

//#define USE_CONNOR_COLOR_NATIVE // Uncomment this line to use ConnorMcLeod's ChatColor
#define USE_SOUNDS // Uncomment this if you want to hear sounds

new const PREFIX[ ] = "[XJ]"; // Change to your own if you want to

#if defined USE_CONNOR_COLOR_NATIVE
	#include < chatcolor >
#else
	#include < colorchat >
	
	#define Red RED
	#define DontChange GREEN
	#define client_print_color ColorChat
#endif

new g_iBeamSprite;
new g_iEdgebugs[ 33 ];
new g_iFlags[ 33 ][ 2 ];
new g_iFrameTime[ 33 ][ 2 ];

new bool:g_bEdgeBug[ 33 ];
new bool:g_bFalling[ 33 ];
new Float:g_flJumpOff[ 33 ];
new Float:g_vTouchedVelocity[ 33 ][ 3 ];

public plugin_init( ) {
	register_plugin( "Edgebug Stats", "2.0", "xPaw" );
	
	register_cvar( "edgebug_stats", "2.0", FCVAR_SERVER | FCVAR_EXTDLL | FCVAR_SPONLY );
	
	register_forward( FM_CmdStart, "FwdCmdStart" );
	
	RegisterHam( Ham_Player_PreThink, "player", "FwdHamPlayerPreThink" );
	RegisterHam( Ham_Touch, "player", "FwdHamPlayerTouch" );
	
	set_cvar_string( "sv_cheats",      "0" );
	set_cvar_string( "sv_gravity",     "800" );
	set_cvar_string( "sv_stepsize",    "18" );
	set_cvar_string( "sv_maxspeed",    "320" );
	set_cvar_string( "edgefriction",   "2" );
	set_cvar_string( "mp_footsteps",   "1" );
	set_cvar_string( "sv_maxvelocity", "2000" );
}

public plugin_precache( ) {
	g_iBeamSprite = precache_model( "sprites/dot.spr" );
	
#if defined USE_SOUNDS
	precache_sound( "jumpstats/godlike.wav" );
	precache_sound( "jumpstats/holyshit.wav" );
#endif
}

public client_putinserver( id )
	Clear( id );

public FwdCmdStart( const id, const iHandle ) {
	g_iFrameTime[ id ][ 1 ] = g_iFrameTime[ id ][ 0 ];
	g_iFrameTime[ id ][ 0 ] = get_uc( iHandle, UC_Msec );
}

public FwdHamPlayerPreThink( const id ) {
	if( !is_user_alive( id ) )
		return FMRES_IGNORED;
	
	static iFlags;
	iFlags = pev( id, pev_flags );
	
	g_iFlags[ id ][ 1 ] = g_iFlags[ id ][ 0 ];
	g_iFlags[ id ][ 0 ] = iFlags;
	
	if( !g_bFalling[ id ] && !( iFlags & FL_ONGROUND ) && g_iFlags[ id ][ 1 ] & FL_ONGROUND ) {
		g_bFalling[ id ] = true;
		
		static Float:vOrigin[ 3 ];
		pev( id, pev_origin, vOrigin );
		
		g_flJumpOff[ id ] = vOrigin[ 2 ] - ( iFlags & FL_DUCKING ? 18.0 : 36.0 );
	}
	
	if( g_bFalling[ id ] ) {
		if( iFlags & FL_ONGROUND ) {
			Clear( id );
			
			return FMRES_IGNORED;
		}
		
		if( g_bEdgeBug[ id ] ) {
			g_bEdgeBug[ id ] = false;
			
			new Float:vVelocity[ 3 ];
			pev( id, pev_velocity, vVelocity );
			
			new iEngineFps    = floatround( 1 / ( g_iFrameTime[ id ][ 0 ] * 0.001 ) );
			new iPossibleGain = 2000 / iEngineFps;
			
			if( floatabs( vVelocity[ 2 ] ) <= iPossibleGain
			&&  floatabs( g_vTouchedVelocity[ id ][ 2 ] ) > iPossibleGain
			&&  floatabs( g_iFrameTime[ id ][ 1 ] * 0.4 + vVelocity[ 2 ] ) < 0.00009 ) {
				new Float:vOrigin[ 3 ], Float:flFallVelocity;
				pev( id, pev_flFallVelocity, flFallVelocity );
				pev( id, pev_origin, vOrigin );
				
				vOrigin[ 2 ] -= ( iFlags & FL_DUCKING ? 18.0 : 36.0 );
				
				new iDistance = floatround( ( g_flJumpOff[ id ] - vOrigin[ 2 ] ), floatround_floor );
				
				if( iDistance < 17 ) {
					Clear( id );
					
					return FMRES_IGNORED;
				}
				
				PrintMessage( id, iDistance, floatround( flFallVelocity ), iEngineFps, vOrigin );
				
				g_flJumpOff[ id ] = vOrigin[ 2 ];
			}
		}
	}
	
	return FMRES_IGNORED;
}

public FwdHamPlayerTouch( const id, const iEntity ) {
	if( !g_bFalling[ id ] )
		return HAM_IGNORED;
	
	/*if( iEntity > 0 && pev_valid( iEntity ) ) {
		static szClassname[ 8 ];
		pev( iEntity, pev_classname, szClassname, 7 );
		
		if( !equal( szClassname, "player" ) && !equal( szClassname, "func_", 5 ) ) {
			Clear( id );
			
			return HAM_IGNORED;
		}
	}*/
	
	static Float:vVelocity[ 3 ];
	pev( id, pev_velocity, vVelocity );
	
	if( vVelocity[ 2 ] >= 0.0 )
		return HAM_IGNORED;
	
	if( ( g_iFlags[ id ][ 0 ] & FL_INWATER && pev( id, pev_waterlevel ) >= 2 ) /*|| pev( id, pev_movetype ) == MOVETYPE_FLY*/ ) {
		Clear( id );
		
		return FMRES_IGNORED;
	}
	
	static Float:flGravity;
	pev( id, pev_gravity, flGravity );
	
	if( flGravity != 1.0 ) {
		Clear( id );
		
		return FMRES_IGNORED;
	}
	
	static Float:vOrigin[ 3 ], Float:flMagic;
	pev( id, pev_origin, vOrigin );
	
	flMagic = floatabs( vOrigin[ 2 ] - floatround( vOrigin[ 2 ], floatround_tozero ) );
	
	if( flMagic == 0.03125 || flMagic == 0.96875 ) { // Lt.Rat is watching you !
		g_bEdgeBug[ id ]         = true;
		g_vTouchedVelocity[ id ] = vVelocity;
	}
	
	return HAM_IGNORED;
}

Clear( const id ) {
	g_bEdgeBug[ id ]  = false;
	g_bFalling[ id ]  = false;
	g_iEdgebugs[ id ] = 0;
}

PrintMessage( const id, const iDistance, const iSpeed, const iEngineFps, Float:vOrigin[ 3 ] ) {
	g_iEdgebugs[ id ]++;
	
	new szTag[ 10 ], szMessage[ 256 ];
	
	switch( g_iEdgebugs[ id ] ) {
		case 1: { }
		case 2: szTag = "Double ";
		case 3: szTag = "Triple ";
		default: formatex( szTag, 9, "%ix ", g_iEdgebugs[ id ] );
	}
	
	engclient_print( id, engprint_console, "^nSuccessful %sEdgebug was made! Fall Distance: %i units. Fall Speed: %i u/s. Engine FPS: %i^n", szTag, iDistance, iSpeed, iEngineFps );
	
	formatex( szMessage, 255, "Successful %sEdgebug was made!^nFall Distance: %i units.^nFall Speed: %i u/s^nEngine FPS: %i", szTag, iDistance, iSpeed, iEngineFps );
	
	set_hudmessage( 255, 127, 0, -1.0, 0.65, 0, 6.0, 6.0, 0.7, 0.7, 3 );
	show_hudmessage( id, szMessage );
	
	MakeBeam( id, vOrigin );
	
	// Print stats to spectators
	new iPlayers[ 32 ], iNum, iSpec;
	get_players( iPlayers, iNum, "bch" );
	
	for( new i; i < iNum; i++ ) {
		iSpec = iPlayers[ i ];
		
		if( iSpec == pev( id, pev_iuser2 ) ) {
			show_hudmessage( id, szMessage );
			
			MakeBeam( iSpec, vOrigin );
		}
	}
	
//	if( iDistance < 1000 )
//		return;
	
	new szName[ 32 ];
	get_user_name( id, szName, 31 );
	
	client_print_color( 0, iDistance >= 2500 ? Red : DontChange, "%s %s did %sEdgebug! Fall distance is %i units with %i u/s.", PREFIX, szName, szTag, iDistance, iSpeed );
	
#if defined USE_SOUNDS
	if( iDistance >= 2500 )
		client_cmd( 0, "spk ^"%s^"", g_iEdgebugs[ id ] > 1 ? "jumpstats/holyshit.wav" : "jumpstats/godlike.wav" );
#endif
}

MakeBeam( const id, Float:vOrigin[ 3 ] ) {
	new Float:vOrigin2[ 3 ];
	vOrigin2 = vOrigin;
	
	vOrigin[ 0 ] += 16.0;
	DrawLine( id, vOrigin, vOrigin2, { 255, 0, 0 } );
	
	vOrigin[ 0 ] -= 16.0;
	vOrigin[ 1 ] += 16.0;
	DrawLine( id, vOrigin, vOrigin2, { 0, 0, 255 } );
	
	vOrigin[ 1 ] -= 16.0;
	vOrigin[ 2 ] += 16.0;
	DrawLine( id, vOrigin, vOrigin2, { 0, 255, 0 } );
}

DrawLine( const id, Float:vOrigin1[ 3 ], Float:vOrigin2[ 3 ], iColor[ 3 ] ) {
	message_begin( MSG_ONE_UNRELIABLE, SVC_TEMPENTITY, _, id );
	write_byte( TE_BEAMPOINTS );
	engfunc( EngFunc_WriteCoord, vOrigin1[ 0 ] );
	engfunc( EngFunc_WriteCoord, vOrigin1[ 1 ] );
	engfunc( EngFunc_WriteCoord, vOrigin1[ 2 ] );
	engfunc( EngFunc_WriteCoord, vOrigin2[ 0 ] );
	engfunc( EngFunc_WriteCoord, vOrigin2[ 1 ] );
	engfunc( EngFunc_WriteCoord, vOrigin2[ 2 ] );
	write_short( g_iBeamSprite );
	write_byte( 1 );
	write_byte( 1 );
	write_byte( 65 );
	write_byte( 5 );
	write_byte( 0 ); 
	write_byte( iColor[ 0 ] );
	write_byte( iColor[ 1 ] ); 
	write_byte( iColor[ 2 ] );
	write_byte( 255 ); 
	write_byte( 0 );
	message_end( );
}