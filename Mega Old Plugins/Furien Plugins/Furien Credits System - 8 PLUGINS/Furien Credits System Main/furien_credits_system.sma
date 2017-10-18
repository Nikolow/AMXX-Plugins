#include < amxmodx >
#include < amxmisc >
#include < cstrike >
#include < fakemeta >
#include < nvault >
#include < CC_ColorChat >

#pragma semicolon 1


#define PLUGIN "Furien Credits System"
#define VERSION "0.4.4"

#define	ONE_DAY_IN_SECONDS	86400

new const g_szTag[ ] = "[Furien Credits]";

new const g_szGiveCreditsFlag[ ] = "a";

new g_szName[ 33 ][ 32 ];
new g_iUserCredits[ 33 ];

new g_iCvarPruneDays;
new g_iCvarEntry;
new iVault;

public plugin_init( )
{
	register_plugin( PLUGIN, VERSION, "Askhanar" );
	register_cvar( "fcs_version", VERSION, FCVAR_SERVER | FCVAR_SPONLY ); 

	g_iCvarPruneDays = register_cvar( "fcs_prunedays", "15" );
	g_iCvarEntry = register_cvar( "fcs_entry_credits", "300" );
	
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
	
	register_clcmd( "amx_give_credits", "ClCmdGiveCredits" );
	register_clcmd( "amx_take_credits", "ClCmdTakeCredits" );
	
	register_forward( FM_ClientUserInfoChanged, "Fwd_ClientUserInfoChanged" );
	
	iVault  =  nvault_open(  "FurienCreditsSystem"  );
	
	if(  iVault  ==  INVALID_HANDLE  )
	{
		set_fail_state(  "nValut returned invalid handle!"  );
	}

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
		return 0;
	
	get_user_name( id, g_szName[ id ], sizeof ( g_szName[] ) -1 );
	LoadCredits( id );
	
	return 0;
	
}

public client_disconnect( id )
{
	if( is_user_bot( id ) )
		return 0;
		
	SaveCredits( id );
	
	return 0;
	
}

public ClCmdSay( id )
{
	static szArgs[192];
	read_args( szArgs, sizeof ( szArgs ) -1 );
	
	if( !szArgs[ 0 ] )
		return 0;
	
	new szCommand[ 15 ];
	remove_quotes( szArgs );
	
	if( equal( szArgs, "/credite", strlen( "/credite" ) )
		|| equal( szArgs, "/credits", strlen( "/credits" ) ) )
	{
		replace( szArgs, sizeof ( szArgs ) -1, "/", "" );
		formatex( szCommand, sizeof ( szCommand ) -1, "fcs_%s", szArgs );
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
			cs_set_user_money( id, 0 );
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
	get_user_name( id, _szName, sizeof ( _szName ) -1 );
	
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
	get_user_name( id, _szName, sizeof ( _szName ) -1 );
	
	ColorChat( 0, RED, "^x04%s^x01 Adminul^x03 %s^x01 i-a sters^x03 %i^x01 credite lui^x03 %s^x01.", g_szTag, szName, iCredits, _szName );
	
	return 1;
	
	
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

public plugin_end( )
{
	new iDays = get_pcvar_num( g_iCvarPruneDays );
	if( iDays > 0 )
	{
		nvault_prune( iVault, 0, get_systime( ) - ( iDays * ONE_DAY_IN_SECONDS ) );
	}
	
	nvault_close( iVault );
}