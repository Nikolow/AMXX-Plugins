#include < amxmodx >
#include < amxmisc >
#include < cstrike >
#include < fakemeta >
#include < nvault >

#pragma semicolon 1


#define PLUGIN "Furien Credits System AIO"
#define VERSION "0.8.7Stable"

#define	ONE_DAY_IN_SECONDS	86400
#define TASK_PTR	06091993
#define FCS_TEAM_FURIEN 	CS_TEAM_T
#define FCS_TEAM_ANTIFURIEN	CS_TEAM_CT

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

new const g_szTag[ ] = "[Furien Credits]";
new const g_szGiveCreditsFlag[ ] = "a";

new g_iCvarPruneDays;
new g_iCvarEntry;

new g_iCvarPTREnable;
new g_iCvarPTRMinutes;
new g_iCvarPTRCredits;

new g_iCvarKREnable;
new g_iCvarKRCredits;
new g_iCvarKRHSCredits;

new g_iCvarTSEnable;
new g_iCvarTSMaxCredits;

new g_iCvarWTREnable;
new g_iCvarWTRFurien;
new g_iCvarWTRAnti;

new g_szName[ 33 ][ 32 ];
new g_iUserCredits[ 33 ];
new g_iUserTime[ 33 ];

new iVault;
new g_iMaxPlayers;
public plugin_init( )
{
	register_plugin( PLUGIN, VERSION, "Askhanar" );
	register_cvar( "fcs_version_aio", VERSION, FCVAR_SERVER | FCVAR_SPONLY ); 

	g_iCvarPruneDays = register_cvar( "fcs_prunedays", "15" );
	g_iCvarEntry = register_cvar( "fcs_entry_credits", "300" );
	
	g_iCvarPTREnable = register_cvar( "fcs_ptr_enable", "1" );
	g_iCvarPTRMinutes = register_cvar( "fcs_ptr_minutes", "5" );
	g_iCvarPTRCredits = register_cvar( "fcs_ptr_credits", "15" );
	
	g_iCvarKREnable = register_cvar( "fcs_kr_enable", "1" );
	g_iCvarKRCredits = register_cvar( "fcs_kr_credits", "7" );
	g_iCvarKRHSCredits = register_cvar( "fcs_kr_hscredits", "3" );//( bonus, fcs_kr_credits + fcs_kr_hscredits )
	
	g_iCvarTSEnable = register_cvar("fcs_transfer_enable", "1" );
	g_iCvarTSMaxCredits = register_cvar("fcs_transfer_maxcredits", "50" );

	g_iCvarWTREnable = register_cvar( "fcs_wtr_enable", "1" );
	g_iCvarWTRFurien = register_cvar( "fcs_wtr_furien", "12" );
	g_iCvarWTRAnti = register_cvar( "fcs_wtr_antifurien", "20" );
	
	register_clcmd( "say", "ClCmdSay" );
	register_clcmd( "say_team", "ClCmdSay" );
	
	register_clcmd( "say /depozit", "ClCmdSayDepozit" );
	register_clcmd( "say /deposit", "ClCmdSayDepozit" );
	register_clcmd( "say_team /depozit", "ClCmdSayDepozit" );
	register_clcmd( "say_team /deposit", "ClCmdSayDepozit" );
	
	register_clcmd( "say /retrage", "ClCmdSayRetrage" );
	register_clcmd( "say /withdraw", "ClCmdSayRetrage" );
	register_clcmd( "say_team /retrage", "ClCmdSayRetrage" );
	register_clcmd( "say_team /withdraw", "ClCmdSayRetrage" );
	
	register_clcmd( "fcs_credite", "ClCmdCredits" );
	register_clcmd( "fcs_credits", "ClCmdCredits" );
	
	register_clcmd( "donate", "ClCmdFcsDonate" );
	register_clcmd( "transfer", "ClCmdFcsDonate" );
	
	register_clcmd( "amx_give_credits", "ClCmdGiveCredits" );
	register_clcmd( "amx_take_credits", "ClCmdTakeCredits" );
	
	register_forward( FM_ClientUserInfoChanged, "Fwd_ClientUserInfoChanged" );
	register_event( "DeathMsg","ev_DeathMsg", "a" );
	register_event( "SendAudio", "ev_SendAudioTerWin", "a", "2=%!MRAD_terwin" );
	register_event( "SendAudio", "ev_SendAudioCtWin", "a", "2=%!MRAD_ctwin" );
	
	
	iVault  =  nvault_open(  "FurienCreditsSystem"  );
	if(  iVault  ==  INVALID_HANDLE  )
		set_fail_state(  "nValut returned invalid handle!"  );
	
	set_task( 1.0, "task_PTRFunctions", TASK_PTR, _, _, "b", 0 );	
	g_iMaxPlayers = get_maxplayers( );

}

public plugin_natives()
{
	
	register_library( "fcs" );
	register_native( "fcs_get_user_credits", "_fcs_get_user_credits" );
	register_native( "fcs_set_user_credits", "_fcs_set_user_credits" );
	
}

public _fcs_get_user_credits( iPlugin, iParams )
{
	return g_iUserCredits[  get_param( 1 )  ];
}

public _fcs_set_user_credits(  iPlugin, iParams  )
{
	new id = get_param( 1 );
	g_iUserCredits[ id ] = max( 0, get_param( 2 ) );
	SaveCredits( id );
	return g_iUserCredits[ id ];
}

public client_authorized( id )
{
	if( is_user_bot( id ) )
		return PLUGIN_CONTINUE;
	
	get_user_name( id, g_szName[ id ], sizeof ( g_szName[] ) -1 );
	LoadCredits( id );
	
	g_iUserTime[ id ] = 0;
	return PLUGIN_CONTINUE;
	
}

public client_disconnect( id )
{
	if( is_user_bot( id ) )
		return PLUGIN_CONTINUE;
		
	SaveCredits( id );
	
	return PLUGIN_CONTINUE;
	
}

public ClCmdSay( id )
{
	static szArgs[192];
	read_args( szArgs, sizeof ( szArgs ) -1 );
	
	if( !szArgs[ 0 ] )
		return 0;
	
	new szCommand[ 15 ];
	remove_quotes( szArgs[ 0 ] );
	
	if( equal( szArgs, "/credite", strlen( "/credite" ) )
		|| equal( szArgs, "/credits", strlen( "/credits" ) ) )
	{
		replace( szArgs, sizeof ( szArgs ) -1, "/", "" );
		formatex( szCommand, sizeof ( szCommand ) -1, "fcs_%s", szArgs );
		client_cmd( id, szCommand );
		return 1;
	}
	else if( equal( szArgs,  "/transfer", strlen(  "/transfer" ) )
		|| equal( szArgs,  "/donate",  strlen(  "/donate" ) ) )
	{
		replace( szArgs, sizeof ( szArgs ) -1, "/", "" );
		formatex( szCommand, sizeof ( szCommand ) -1, "%s", szArgs );
		client_cmd( id, szCommand );
		return 1;
	}
		
	return 0;
}

public ClCmdCredits( id )
{
	if( !is_user_connected( id ) )
		return 1;
		
	new szArg[ 32 ];
    	read_argv( 1, szArg, sizeof ( szArg ) -1 );

	if( equal( szArg, "" ) ) 
	{
		
		ColorChat( id, RED, "^x04%s^x01 Ai^x03 %i^x01 credite.", g_szTag, g_iUserCredits[ id ] );
		return 1;
	}
	
    	new iPlayer = cmd_target( id, szArg, 8 );
    	if( !iPlayer || !is_user_connected( iPlayer ) )
	{
		ColorChat( id, RED,"^x04%s^x01 Jucatorul specificat nu a fost gasit!", g_szTag, szArg );
		return 1;
	}

	new szName[ 32 ];
	get_user_name( iPlayer, szName, sizeof ( szName ) -1 );
	ColorChat( id, RED,"^x04%s^x01 Jucatorul^x03 %s^x01 are^x03 %i^x01 credit%s", g_szTag, szName, g_iUserCredits[ iPlayer ], g_iUserCredits[ iPlayer ] == 1 ? "." : "e." );
	
	return 1;
	
}

public ClCmdSayDepozit( id)
{
	
	if( !is_user_connected( id ) )
		return 1;
		
	new iTeam = get_user_team( id );
	
	if( 1 <= iTeam <= 2 )
	{
		new iMoney = cs_get_user_money( id );
		if( iMoney >= 16000 )
		{
			
			ColorChat( id, RED, "^x04%s^x01 Ai depozitat^x03 16000$^x01 si ai primit^x03 1^x01 credit.", g_szTag );
			cs_set_user_money( id, iMoney - 16000 );
			g_iUserCredits[ id ] += 1;
			
			SaveCredits( id );
			return 1;
		}
		else
		{
			ColorChat( id, RED, "^x04%s^x01 Iti trebuie^x03 16000$^x01 pentru a putea depozita.", g_szTag );
			return 1;
		}
	}
	
	return 1;

}

public ClCmdSayRetrage( id)
{
	
	new iTeam = get_user_team( id );
	
	if( 1 <= iTeam <= 2 )
	{
		
		if( g_iUserCredits[ id ] > 0 )
		{
			new iMoney = cs_get_user_money( id );
			
			ColorChat( id, RED, "^x04%s^x01 Ai retras^x03 1^x01 credit si, ai primi^x03 16000$^x01.", g_szTag );
			cs_set_user_money( id, iMoney + 16000 );
			
			g_iUserCredits[ id ] -=1;
			SaveCredits( id );
			
			if( ( iMoney + 16000 ) > 16000 )
			{
				ColorChat( id, RED, "^x04%s^x03 ATENTIE^x01, ai^x03 %i$^x01 !", g_szTag, iMoney + 16000 );
				ColorChat( id, RED, "^x04%s^x01 La spawn, vei pierde tot ce depaseste suma de^x03 16000$^x01.", g_szTag );
				return 1;
			}
		}
		else
		{
			ColorChat(id, RED, "^x04%s^x03 NU^x01 ai ce sa retragi, ai^x03 0^x01 credite.", g_szTag );
			return 1;
		}
		
	}
	
	return 1;

}

public ClCmdGiveCredits( id )
{
	
	if( !( get_user_flags( id ) & read_flags( g_szGiveCreditsFlag ) ) )
	{
		client_cmd( id, "echo NU ai acces la aceasta comanda!" );
		return 1;
	}
	
	new szFirstArg[ 32 ], szSecondArg[ 10 ];
	
	read_argv( 1, szFirstArg, sizeof ( szFirstArg ) -1 );
	read_argv( 2, szSecondArg, sizeof ( szSecondArg ) -1 );
	
	if( equal( szFirstArg, "" ) || equal( szSecondArg, "" ) )
	{
		client_cmd( id, "echo amx_give_credits < nume/ @ALL/ @T/ @CT > < credite >" );
		return 1;
	}
	
	new iPlayers[ 32 ];
	new iPlayersNum;
	
	new iCredits = str_to_num( szSecondArg );
	if( iCredits <= 0 )
	{
		client_cmd( id, "echo Valoare creditelor trebuie sa fie mai mare decat 0!" );
		return 1;
	}
	
	if( szFirstArg[ 0 ] == '@' )
	{
		
		switch ( szFirstArg[ 1 ] )
		{
			case 'A':
			{
				if( equal( szFirstArg, "@ALL" ) )
				{
					
					get_players( iPlayers, iPlayersNum, "ch" );
					for( new i = 0; i < iPlayersNum ; i++ )
						g_iUserCredits[ iPlayers[ i ] ] += iCredits;
						
					new szName[ 32 ];
					get_user_name( id, szName, sizeof ( szName ) -1 );
					ColorChat( 0, RED, "^x04^%s^x01 Adminul^x03 %s^x01 le-a dat^x03 %i^x01 credite tuturor jucatorilor!", g_szTag, szName, iCredits );
					return 1;
				}
			}
			
			case 'T':
			{
				if( equal( szFirstArg, "@T" ) )
				{
					
					get_players( iPlayers, iPlayersNum, "ceh", "TERRORIST" );
					if( iPlayersNum == 0 )
					{
						client_cmd( id, "echo NU se afla niciun jucator in aceasta echipa!" );
						return 1;
					}
					for( new i = 0; i < iPlayersNum ; i++ )
						g_iUserCredits[ iPlayers[ i ] ] += iCredits;
						
					new szName[ 32 ];
					get_user_name( id, szName, sizeof ( szName ) -1 );
					ColorChat( 0, RED, "^x04^%s^x01 Adminul^x03 %s^x01 le-a dat^x03 %i^x01 credite jucatorilor de la^x03 TERO^x01!", g_szTag, szName, iCredits );
					return 1;
				}
			}
			
			case 'C':
			{
				if( equal( szFirstArg, "@CT" ) )
				{
					
					get_players( iPlayers, iPlayersNum, "ceh", "CT" );
					if( iPlayersNum == 0 )
					{
						client_cmd( id, "echo NU se afla niciun jucator in aceasta echipa!" );
						return 1;
					}
					for( new i = 0; i < iPlayersNum ; i++ )
						g_iUserCredits[ iPlayers[ i ] ] += iCredits;
						
					new szName[ 32 ];
					get_user_name( id, szName, sizeof ( szName ) -1 );
					ColorChat( 0, RED, "^x04^%s^x01 Adminul^x03 %s^x01 le-a dat^x03 %i^x01 credite jucatorilor de la^x03 CT^x01!", g_szTag, szName, iCredits );
					return 1;
				}
			}
		}
	}
		
	new iPlayer = cmd_target( id, szFirstArg, 8 );
	if( !iPlayer )
	{
		client_cmd( id, "echo Jucatorul %s nu a fost gasit!", szFirstArg );
		return 1;
	}
	
	g_iUserCredits[ iPlayer ] += iCredits;
	
	new szName[ 32 ], _szName[ 32 ];
	get_user_name( id, szName, sizeof ( szName ) -1 );
	get_user_name( iPlayer, _szName, sizeof ( _szName ) -1 );
	
	ColorChat( 0, RED, "^x04%s^x01 Adminul^x03 %s^x01 i-a dat^x03 %i^x01 credite lui^x03 %s^x01.", g_szTag, szName, iCredits, _szName );
	
	return 1;
	
	
}

public ClCmdTakeCredits( id )
{
	
	if( !( get_user_flags( id ) & read_flags( g_szGiveCreditsFlag ) ) )
	{
		client_cmd( id, "echo NU ai acces la aceasta comanda!" );
		return 1;
	}
	
	new szFirstArg[ 32 ], szSecondArg[ 10 ];
	
	read_argv( 1, szFirstArg, sizeof ( szFirstArg ) -1 );
	read_argv( 2, szSecondArg, sizeof ( szSecondArg ) -1 );
	
	if( equal( szFirstArg, "" ) || equal( szSecondArg, "" ) )
	{
		client_cmd( id, "echo amx_take_credits < nume > < credite >" );
		return 1;
	}
	
	new iCredits = str_to_num( szSecondArg );
	if( iCredits <= 0 )
	{
		client_cmd( id, "echo Valoare creditelor trebuie sa fie mai mare decat 0!" );
		return 1;
	}
			
	new iPlayer = cmd_target( id, szFirstArg, 8 );
	if( !iPlayer )
	{
		client_cmd( id, "echo Jucatorul %s nu a fost gasit!", szFirstArg );
		return 1;
	}
	
	if( g_iUserCredits[ iPlayer ] < iCredits )
	{
		client_cmd( id, "echo Jucatorul %s nu are atatea credite!Are doar %i", szFirstArg, g_iUserCredits[ iPlayer ] );
		return 1;
	}
	
	g_iUserCredits[ iPlayer ] -= iCredits;
	
	new szName[ 32 ], _szName[ 32 ];
	get_user_name( id, szName, sizeof ( szName ) -1 );
	get_user_name( iPlayer, _szName, sizeof ( _szName ) -1 );
	
	ColorChat( 0, RED, "^x04%s^x01 Adminul^x03 %s^x01 i-a sters^x03 %i^x01 credite lui^x03 %s^x01.", g_szTag, szName, iCredits, _szName );
	
	return 1;
	
	
}

public ClCmdFcsDonate( id )
{
	if(  get_pcvar_num(  g_iCvarTSEnable  )  !=  1  )
	{
		ColorChat( id, RED, "^x04%s^x01 Comanda dezactivata de catre server!",  g_szTag  );
		return PLUGIN_HANDLED;
	}
	
	new szFirstArg[ 32 ], szSecondArg[ 10 ];
	
    	read_argv( 1, szFirstArg, sizeof ( szFirstArg ) -1 );
	read_argv( 2, szSecondArg, sizeof ( szSecondArg ) -1 );
	
	if( equal( szFirstArg, "" ) || equal( szSecondArg, "" ) )
	{
		ColorChat( id, RED, "^x04%s^x01 Folosire:^x03 /transfer^x01 sau^x03 /donate^x01 <^x03 nume^x01 > <^x03 credite^x01 >.", g_szTag );
		return 1;
	}
	
	new iPlayer = cmd_target( id, szFirstArg, 8 );
	
	if( !iPlayer  )
	{
		ColorChat( id, RED, "^x04%s^x01 Acel jucator nu a fost gasit.", g_szTag );
		return PLUGIN_HANDLED;
	}
	
	//if( iPlayer == id )
	//{
	//	ColorChat(  id,  RED, "^x04%s^x01 Nu-ti poti transfera credite.", g_szTag );
	//	return PLUGIN_HANDLED;
	//}
	
	
	new iCredits;
	iCredits = str_to_num( szSecondArg );
	
	
	if( iCredits <= 0 )
	{
		ColorChat( id, RED, "^x04%s^x01 Trebuie sa introduci o valoare mai mare de 0.", g_szTag );
		return PLUGIN_HANDLED;
	}
	
	new iMaxCredits = get_pcvar_num( g_iCvarTSMaxCredits );
	if( iCredits > iMaxCredits )
	{
		ColorChat( id, RED, "^x04%s^x01 Poti transfera maxim^x03 %i^x01 credit%s o data!", g_szTag, iMaxCredits, iMaxCredits == 1 ? "" : "e" );
		return PLUGIN_HANDLED;
	}
	
	if( g_iUserCredits[ id ] <  iCredits  )
	{
		ColorChat(  id,  RED, "^x04%s^x01 Nu ai destule credite, ai doar^x03 %i credit%s^x01.",  g_szTag, g_iUserCredits[ id ], g_iUserCredits[ id ] == 1 ? "" : "e"  );
		return 1;
	}
	
	g_iUserCredits[ id ] -= iCredits;
	g_iUserCredits[ iPlayer ] += iCredits;
	
	SaveCredits( id );
	SaveCredits( iPlayer );
	
	new szFirstName[ 32 ], szSecondName[ 32 ];
	
	get_user_name( id, szFirstName, sizeof ( szFirstName )  -1 );
	get_user_name( iPlayer, szSecondName, sizeof ( szSecondName )  -1 );
	
	ColorChat( 0, RED, "^x04%s^x03 %s^x01 i-a transferat^03 %i credit%s^x01 lui^x03 %s^x01 .", g_szTag, szFirstName, iCredits, iCredits == 1 ? "" : "e", szSecondName );
	return PLUGIN_HANDLED;
}

public Fwd_ClientUserInfoChanged( id, szBuffer )
{
	if ( !is_user_connected( id ) ) 
		return FMRES_IGNORED;
	
	static szNewName[ 32 ];
	
	engfunc( EngFunc_InfoKeyValue, szBuffer, "name", szNewName, sizeof ( szNewName ) -1 );
	
	if ( equal( szNewName, g_szName[ id ] ) )
		return FMRES_IGNORED;
	
	SaveCredits(  id  );
	
	ColorChat( id, RED, "^x04%s^x01 Tocmai ti-ai schimbat numele din^x03 %s^x01 in^x03 %s^x01 !", g_szTag, g_szName[ id ], szNewName );
	ColorChat( id, RED, "^x04%s^x01 Am salvat^x03 %i^x01 credite pe numele^x03 %s^x01 !", g_szTag, g_iUserCredits[ id ], g_szName[ id ] );
	
	copy( g_szName[ id ], sizeof ( g_szName[] ) -1, szNewName );
	LoadCredits( id );
	
	ColorChat( id, RED, "^x04%s^x01 Am incarcat^x03 %i^x01 credite de pe noul nume (^x03 %s^x01 ) !", g_szTag, g_iUserCredits[ id ], g_szName[ id ] );
	
	return FMRES_IGNORED;
}


public LoadCredits( id )
{
	static szData[ 256 ],  iTimestamp;
	
	if(  nvault_lookup( iVault, g_szName[ id ], szData, sizeof ( szData ) -1, iTimestamp ) )
	{
		static szCredits[ 15 ];
		parse( szData, szCredits, sizeof ( szCredits ) -1 );
		g_iUserCredits[ id ] = str_to_num( szCredits );
		return;
	}
	else
	{
		g_iUserCredits[ id ] = get_pcvar_num( g_iCvarEntry );
	}
	
}


public SaveCredits(  id  )
{
	
	static szData[ 256 ];
	formatex( szData, sizeof ( szData ) -1, "%i", g_iUserCredits[ id ] );
	
	nvault_set( iVault, g_szName[ id ], szData );
}


public task_PTRFunctions( )
{
	if( get_pcvar_num( g_iCvarPTREnable ) != 1 )
		return;
		
	static iPlayers[ 32 ];
	static iPlayersNum;
	
	get_players( iPlayers, iPlayersNum, "ch" );
	if( !iPlayersNum )
		return;
	
	static id, i;
	for( i = 0; i < iPlayersNum; i++ )
	{
		id = iPlayers[ i ];
		
		g_iUserTime[ id ]++;
		static iTime;
		iTime = get_pcvar_num( g_iCvarPTRMinutes ) ;
		
		if( g_iUserTime[ id ] >= iTime * 60 )
		{
			g_iUserTime[ id ] -= iTime * 60;
			
			static iCredits;
			iCredits = get_pcvar_num( g_iCvarPTRCredits );
			
			g_iUserCredits[ id ] += iCredits;
			ColorChat( id, RED, "^x04%s^x01 Ai primit^x03 %i^x01 credite pentru^x03 %i^x01 minute jucate!",
				g_szTag, iCredits, iTime );
				
			SaveCredits( id );
				
		}
	}
	
}

public ev_DeathMsg( )
{
	if( get_pcvar_num( g_iCvarKREnable ) != 1 )
		return;
	new iKiller = read_data( 1 );
	if( iKiller == read_data( 2 ) )
		return;
		
	new iCredits = get_pcvar_num( g_iCvarKRCredits );
	
	if( read_data( 3 ) )
		iCredits += get_pcvar_num( g_iCvarKRHSCredits );
		
	g_iUserCredits[ iKiller ] += iCredits;
	SaveCredits( iKiller );
	
}

public ev_SendAudioTerWin( )
{
	static iCvarEnable, iCvarFurienReward;
	iCvarEnable = get_pcvar_num( g_iCvarWTREnable );
	iCvarFurienReward = get_pcvar_num( g_iCvarWTRFurien );
	
	if( iCvarEnable != 1 || iCvarFurienReward == 0 )
		return;
		
	GiveTeamReward( FCS_TEAM_FURIEN, iCvarFurienReward );
	
}


public ev_SendAudioCtWin( )
{
	
	static iCvarEnable, iCvarAntiReward;
	iCvarEnable = get_pcvar_num( g_iCvarWTREnable );
	iCvarAntiReward = get_pcvar_num( g_iCvarWTRAnti );
	
	if( iCvarEnable != 1 || iCvarAntiReward == 0 )
		return;
		
	GiveTeamReward( FCS_TEAM_ANTIFURIEN, iCvarAntiReward );
}

public GiveTeamReward( const CsTeams:iTeam, iCredits )
{
	
	for(  new id = 1;  id <= g_iMaxPlayers;  id++   )
	{
		if( cs_get_user_team( id ) == iTeam )
		{
			ColorChat( id, RED, "^x04%s^x01 Ai primit^x03 %i^x01 credit%s pentru castigarea rundei!", g_szTag, iCredits, iCredits == 1 ? "" : "e" );
			g_iUserCredits[ id ] += iCredits;
			SaveCredits( id );
		}
	}
}

public plugin_end( )
{
	new iDays = get_pcvar_num( g_iCvarPruneDays );
	if( iDays > 0 )
	{
		nvault_prune( iVault, 0, get_systime( ) - ( iDays * ONE_DAY_IN_SECONDS ) );
	}
	
	nvault_close( iVault );
}

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