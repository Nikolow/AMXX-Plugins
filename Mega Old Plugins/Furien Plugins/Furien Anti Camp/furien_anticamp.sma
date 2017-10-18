#include < amxmodx >
#include < fakemeta >
#include < hamsandwich >

#pragma semicolon 1


#define PLUGIN "Furien Anti-Camp"
#define VERSION "0.0.1"

// --|Pentru teste.. cateva mesajela fiecare functie.. sa imi dau seama unde si ce nu merge.
// --|Lasati // in fata!
//#define TESTING

#define TASK_SPAWN	06081993

// --| ColorChat.
enum Color
{
	NORMAL = 1, 		// Culoarea care o are jucatorul setata in cvar-ul scr_concolor.
	GREEN, 			// Culoare Verde.
	TEAM_COLOR, 		// Culoare Rosu, Albastru, Gri.
	GREY, 			// Culoarea Gri.
	RED, 			// Culoarea Rosu.
	BLUE, 			// Culoarea Albastru.
};

new TeamName[  ][  ] = 
{
	"",
	"TERRORIST",
	"CT",
	"SPECTATOR"
};
// --| ColorChat.

new const g_szTag[ ] = "[Furien Anti-Camp]";
new const g_szClassName[ ] = "Askhanar's_MagicEntity";

new Float:g_fUserOrigin[ 33 ][ 3 ];
new Float:g_fUserOldOrigin[ 33 ][ 3 ];

new bool:g_bSpawnCheckEnabled = false;

new bool:g_bAlive[ 33 ];
new bool:g_bConnected[ 33 ];
new bool:g_bUserIsCamping[ 33 ];

new g_iUserCampSeconds[ 33 ];
new g_iMagicEntity;

public plugin_init( )
{
	register_plugin( PLUGIN, VERSION, "Askhanar" );
	
	register_event( "HLTV", "ev_HookRoundStart", "a", "1=0", "2=0" );
	
	RegisterHam( Ham_Spawn, "player", "Ham_PlayerSpawnPost", true );
	RegisterHam( Ham_Killed, "player", "Ham_PlayerKilledPost", true );
	
	
	new iEnt;
	CreateMagicEntity:
	
	iEnt = engfunc( EngFunc_CreateNamedEntity, engfunc( EngFunc_AllocString, "info_target" ) );
	if( !iEnt || !pev_valid( iEnt ) )
		goto CreateMagicEntity;
	
	set_pev( iEnt, pev_classname, g_szClassName );
	set_pev( iEnt, pev_nextthink, get_gametime(  ) + 0.3 );
	register_forward( FM_Think, "FM_MagicEntityThink" );
	
	g_iMagicEntity = iEnt;
	
}

public client_putinserver( id )
{
	if( is_user_bot( id ) )
		return PLUGIN_CONTINUE;
	
	g_bConnected[ id ] = true;
	g_bAlive[ id ] = false;
	g_bUserIsCamping[ id ] = false;

	// --| Stupid compiler..
	return PLUGIN_CONTINUE;
}

public client_disconnect( id )
{
	
	if( is_user_bot( id ) )
		return PLUGIN_CONTINUE;
	
	
	g_bConnected[ id ] = false;
	g_bAlive[ id ] = false;
	g_bUserIsCamping[ id ] = false;
	
	// --| Stupid compiler..
	return PLUGIN_CONTINUE;
}

public Ham_PlayerSpawnPost( id )
{
	if( !is_user_alive( id ) )
		return HAM_IGNORED;
		
	#if defined TESTING
	client_print( 0, print_chat, "Functia PlayerSpawn a fost chemata!" );
	#endif
	g_bAlive[ id ] = true;
	g_bUserIsCamping[ id ] = false;
	g_iUserCampSeconds[ id ] = 0;
	
	return HAM_IGNORED;
}

public Ham_PlayerKilledPost( id )
{
	#if defined TESTING
	client_print( 0, print_chat, "Functia PlayerKilled a fost chemata!" );
	#endif
	g_bAlive[ id ] = false;
}

public ev_HookRoundStart( )
{
	remove_task( TASK_SPAWN );
	
	#if defined TESTING
	client_print( 0, print_chat, "Functia RoundRestart a fost chemata!" );
	#endif
	
	g_bSpawnCheckEnabled = true;
	set_task( 25.0, "TaskDisableSpawnCheck", TASK_SPAWN );
}

public TaskDisableSpawnCheck( )
{
	#if defined TESTING
	client_print( 0, print_chat, "Functia DisableSpawn a fost chemata!" );
	#endif
	g_bSpawnCheckEnabled = false;
}

public FM_MagicEntityThink( iEnt )
{
	
	if( iEnt != g_iMagicEntity || !pev_valid( iEnt ) )
		return FMRES_IGNORED;
		
	set_pev( iEnt, pev_nextthink, get_gametime(  ) + 1.0 );

		
	#if defined TESTING
	client_print( 0, print_chat, "Entitatea gandeste!" );
	#endif
	
	static iPlayers[ 32 ];
	static iPlayersNum;
	
	get_players( iPlayers, iPlayersNum, "ce", "CT" );
	if( !iPlayersNum )
		return FMRES_IGNORED;
		
	static id, i;
	for( i = 0; i < iPlayersNum; i++ )
	{
		id = iPlayers[ i ];
		
		if( g_bConnected[ id ] )
		{
			if( g_bAlive[ id ] )
			{
				pev( id, pev_origin, g_fUserOrigin[ id ] );
					
				if( g_fUserOrigin[ id ][ 0 ] == g_fUserOldOrigin[ id ][ 0 ]
					&& g_fUserOrigin[ id ][ 1 ] == g_fUserOldOrigin[ id ][ 1 ]
					&& g_fUserOrigin[ id ][ 2 ] == g_fUserOldOrigin[ id ][ 2 ] )
				{
					g_iUserCampSeconds[ id ]++;
					#if defined TESTING
					client_print( 0, print_chat, "Originile sunt aceleasi!" );
					#endif
					
					if( g_iUserCampSeconds[ id ] == 5 )
					{
						
						#if defined TESTING
						client_print( 0, print_chat, "Ecranul este inegrit!" );
						#endif
						
						g_bUserIsCamping[ id ] = true;
						FadeScreen( id );
					}
					
					else if( g_iUserCampSeconds[ id ] > 5 && g_bSpawnCheckEnabled )
					{
						
						#if defined TESTING
						client_print( 0, print_chat, "Verificare dupa spawn!" );
						#endif
						
						if( g_iUserCampSeconds[ id ] == 11 )
						{
							new szName[ 32 ];
							get_user_name( id, szName, sizeof ( szName ) -1 );
							ColorChat( 0, RED, "^x04%s^x03 %s^x01 a primit slay pentru ca este afk!", g_szTag, szName );
							
							user_silentkill( id );
							
							g_bUserIsCamping[ id ] = false;
							g_iUserCampSeconds[ id ] = 0;
							
							ResetScreen( id );
							
						}
						else
							ColorChat( id, RED, "^x04%s^x01 Vei primi slay in^x03 %i^x01 secund%s daca nu te misti!",
								g_szTag, 11 - g_iUserCampSeconds[ id ], ( 11 - g_iUserCampSeconds[ id ]  ) == 1 ? "a" : "e" );
					}
				}
	
				else if( g_fUserOrigin[ id ][ 0 ] != g_fUserOldOrigin[ id ][ 0 ]
					|| g_fUserOrigin[ id ][ 1 ] != g_fUserOldOrigin[ id ][ 1 ]
					|| g_fUserOrigin[ id ][ 2 ] != g_fUserOldOrigin[ id ][ 2 ] ) 
				{
	
					#if defined TESTING
					client_print( 0, print_chat, "Orinigile nu sunt aceleasi!" );
					#endif
					
					if( g_bUserIsCamping[ id ] )
					{
						
						#if defined TESTING
						client_print( 0, print_chat, "Scoatem blindul!" );
						#endif
						
						ResetScreen( id );
					}
					
					g_iUserCampSeconds[ id ] = 0;
					g_bUserIsCamping[ id ] = false;
				}
			}
		}
		
		#if defined TESTING
		client_print( 0, print_chat, "Origini salvate in globala!" );
		#endif
		
		g_fUserOldOrigin[ id ][ 0 ] = g_fUserOrigin[ id ][ 0 ];
		g_fUserOldOrigin[ id ][ 1 ] = g_fUserOrigin[ id][ 1 ];
		g_fUserOldOrigin[ id ][ 2 ] = g_fUserOrigin[ id ][ 2 ];
	
	}
	
	return FMRES_IGNORED;
}


FadeScreen( id )
{      
	

	message_begin(MSG_ONE, get_user_msgid( "ScreenFade" ), _, id );
	write_short(1<<0); // fade lasts this long duration 
	write_short(1<<0); // fade lasts this long hold time 
	write_short(1<<2); // fade type HOLD 
	write_byte(0); // fade red 
	write_byte(0); // fade green 
	write_byte(0); // fade blue  
	write_byte(255); // fade alpha  
	message_end();

			
}

ResetScreen( id )
{
	
	message_begin(MSG_ONE, get_user_msgid( "ScreenFade" ), _, id );
	write_short(1<<12); // fade lasts this long duration  
	write_short(1<<8); // fade lasts this long hold time  
	write_short(1<<1); // fade type OUT 
	write_byte(0); // fade red  
	write_byte(0); // fade green  
	write_byte(0); // fade blue    
	write_byte(255); // fade alpha    
	message_end();
}


// --| ColorChat.
ColorChat(  id, Color:iType, const msg[  ], { Float, Sql, Result, _}:...  )
{
	
	// Daca nu se afla nici un jucator pe server oprim TOT. Altfel dam de erori..
	if( !get_playersnum( ) ) return;
	
	new szMessage[ 256 ];

	switch( iType )
	{
		 // Culoarea care o are jucatorul setata in cvar-ul scr_concolor.
		case NORMAL:	szMessage[ 0 ] = 0x01;
		
		// Culoare Verde.
		case GREEN:	szMessage[ 0 ] = 0x04;
		
		// Alb, Rosu, Albastru.
		default: 	szMessage[ 0 ] = 0x03;
	}

	vformat(  szMessage[ 1 ], 251, msg, 4  );

	// Ne asiguram ca mesajul nu este mai lung de 192 de caractere.Altfel pica server-ul.
	szMessage[ 192 ] = '^0';
	

	new iTeam, iColorChange, iPlayerIndex, MSG_Type;
	
	if( id )
	{
		MSG_Type  =  MSG_ONE_UNRELIABLE;
		iPlayerIndex  =  id;
	}
	else
	{
		iPlayerIndex  =  CC_FindPlayer(  );
		MSG_Type = MSG_ALL;
	}
	
	iTeam  =  get_user_team( iPlayerIndex );
	iColorChange  =  CC_ColorSelection(  iPlayerIndex,  MSG_Type, iType);

	CC_ShowColorMessage(  iPlayerIndex, MSG_Type, szMessage  );
		
	if(  iColorChange  )	CC_Team_Info(  iPlayerIndex, MSG_Type,  TeamName[ iTeam ]  );

}

CC_ShowColorMessage(  id, const iType, const szMessage[  ]  )
{
	
	static bool:bSayTextUsed;
	static iMsgSayText;
	
	if(  !bSayTextUsed  )
	{
		iMsgSayText  =  get_user_msgid( "SayText" );
		bSayTextUsed  =  true;
	}
	
	message_begin( iType, iMsgSayText, _, id  );
	write_byte(  id  );		
	write_string(  szMessage  );
	message_end(  );
}

CC_Team_Info( id, const iType, const szTeam[  ] )
{
	static bool:bTeamInfoUsed;
	static iMsgTeamInfo;
	if(  !bTeamInfoUsed  )
	{
		iMsgTeamInfo  =  get_user_msgid( "TeamInfo" );
		bTeamInfoUsed  =  true;
	}
	
	message_begin( iType, iMsgTeamInfo, _, id  );
	write_byte(  id  );
	write_string(  szTeam  );
	message_end(  );

	return 1;
}

CC_ColorSelection(  id, const iType, Color:iColorType)
{
	switch(  iColorType  )
	{
		
		case RED:	return CC_Team_Info(  id, iType, TeamName[ 1 ]  );
		case BLUE:	return CC_Team_Info(  id, iType, TeamName[ 2 ]  );
		case GREY:	return CC_Team_Info(  id, iType, TeamName[ 0 ]  );

	}

	return 0;
}

CC_FindPlayer(  )
{
	new iMaxPlayers  =  get_maxplayers(  );
	
	for( new i = 1; i <= iMaxPlayers; i++ )
		if(  is_user_connected( i )  )
			return i;
	
	return -1;
}
// --| ColorChat.