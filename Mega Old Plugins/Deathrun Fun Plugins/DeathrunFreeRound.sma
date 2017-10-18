#include < amxmodx >
#include < cstrike >
#include < fakemeta >
#include < hamsandwich >

const m_toggle_state = 41;

#define TASK_VOTE  237439

enum _:VOTES {
	VOTE_YES,
	VOTE_NO
};

new g_iVotes[ VOTES ];
new bool:g_bVoted[ 33 ];
new bool:g_bFreeRound;
new bool:g_bWillFree;
new bool:g_bVoting;
new g_iCountdown;
new g_iRounds;
new g_iPrinted;
new g_iMenuID;
new g_iMaxplayers;
new g_iMsgSayText;
new g_pWaitRounds;

public plugin_init( ) {
	new const VERSION[ ] = "1.0";
	
	register_plugin( "Deathrun: Free Round", VERSION, "xPaw" );
	
	new p = register_cvar( "deathrun_freeround", VERSION, FCVAR_SERVER | FCVAR_SPONLY );
	set_pcvar_string( p, VERSION );
	
	g_pWaitRounds = register_cvar( "freerun_wait_rounds", "5" );
	g_iMaxplayers = get_maxplayers( );
	g_iMsgSayText = get_user_msgid( "SayText" );
	g_iMenuID     = register_menuid( "DrunFreeRoundVote" );
	
	register_menucmd( g_iMenuID, ( MENU_KEY_1 | MENU_KEY_2 | MENU_KEY_0 ), "HandleVote" );
	
	register_clcmd( "say /free",      "CmdFreeRound" );
	register_clcmd( "say /freeround", "CmdFreeRound" );
	
	RegisterHam( Ham_Use, "func_rot_button", "FwdHamUse_Button" );
	RegisterHam( Ham_Use, "func_button",     "FwdHamUse_Button" );
	RegisterHam( Ham_Use, "button_target",   "FwdHamUse_Button" );
	
	register_event( "CurWeapon", "EventCurWeapon", "be", "1=1", "2!29" );
	register_event( "HLTV",      "EventNewRound",  "a",  "1=0", "2=0" );
	register_event( "TextMsg",   "EventRestart",   "a",  "2&#Game_C", "2&#Game_w" );
}

public EventNewRound( ) {
	if( g_bFreeRound ) {
		g_bFreeRound = false;
		g_iRounds    = 0;
		g_iPrinted   = 0;
		
		return;
	}
	else if( g_bWillFree ) {
		g_iRounds    = 0;
		g_iPrinted   = 0;
		g_bWillFree  = false;
		g_bFreeRound = true;
		
		set_task( 2.0, "PrintMessage" );
		
		return;
	}
	
	g_iRounds++;
	
	if( g_iPrinted < 4 && g_iRounds >= get_pcvar_num( g_pWaitRounds ) ) {
		GreenPrint( 0, "This server is using^3 Deathrun Free Round System^1 say^4 /free^1 to start vote!" );
		
		g_iPrinted++;
	}
}

public EventRestart( ) {
	g_bFreeRound = false;
	g_bWillFree  = false;
	g_bVoting    = false;
	g_iPrinted   = 0;
	g_iRounds    = 0;
	
	remove_task( TASK_VOTE );
}

public EventCurWeapon( id )
	if( g_bFreeRound )
		engclient_cmd( id, "weapon_knife" );

public CmdFreeRound( id ) {
	if( cs_get_user_team( id ) != CS_TEAM_T ) {
		GreenPrint( id, "This command is only for terrorists!" );
		
		return PLUGIN_CONTINUE;
	}
	else if( g_bFreeRound ) {
		GreenPrint( id, "It is free round already!" );
		
		return PLUGIN_CONTINUE;
	}
	else if( g_bVoting ) {
		GreenPrint( id, "The voting is already in process!" );
		
		return PLUGIN_CONTINUE;
	}
	else if( g_bWillFree ) {
		GreenPrint( id, "Next round will be free! Vote is over!" );
		
		return PLUGIN_CONTINUE;
	}
	
	new iWaitRounds = get_pcvar_num( g_pWaitRounds ) - g_iRounds;
	
	if( iWaitRounds > 0 ) {
		GreenPrint( id, "You need to wait^3 %i^1 rounds to start vote!", iWaitRounds );
		
		return PLUGIN_CONTINUE;
	}
	
	new szName[ 32 ];
	get_user_name( id, szName, 31 );
	
	GreenPrint( 0, "Vote has been started by^3 %s^1.", szName );
	
	set_hudmessage( random(255), random(255), random(255), -1.0, 0.3, 1, 3.0, 3.0, 2.0, 1.0, -1 );
	show_hudmessage( 0, "Free round vote has been started by %s^nVoting Will begin shortly.", szName );
	
	g_iVotes[ VOTE_YES ] = 0;
	g_iVotes[ VOTE_NO ] = 0;
	g_iRounds = 0;
	g_bVoting = true;
	g_iPrinted = 0;
	g_bWillFree = false;
	
	arrayset( g_bVoted, false, 32 );
	
	remove_task( TASK_VOTE );
	g_iCountdown = 15;
	
	set_task( 3.5, "PreTask", TASK_VOTE );
	
	return PLUGIN_CONTINUE;
}

public PrintMessage( ) {
	GreenPrint( 0, "It is a^4 Free round^1, no guns, no traps!" );
	
	set_hudmessage( random(255), random(255), random(255), -1.0, 0.35, 1, 3.0, 3.0, 2.0, 1.0, -1 );
	show_hudmessage( 0, "This round WE playing FREE - Go kill T with Knife" );
}

public PreTask( ) {
	remove_task( TASK_VOTE );
	
	set_task( 1.0, "TaskVoteTimer", TASK_VOTE, _, _, "b" );
}

public TaskVoteTimer( ) {
	g_iCountdown--;
	
	if ( !g_iCountdown ) {
		remove_task( TASK_VOTE );
		
		g_bVoting = false;
		
		new iVotes, iHighVotes, iHighVotesID;
		
		for( new i; i < VOTES; i++ ) {
			iVotes = g_iVotes[ i ];
			
			if( iVotes >= iHighVotes ) {
				iHighVotes = iVotes;
				iHighVotesID = i;
			}
		}
		
		if( iHighVotes > 0 ) {
			if( iHighVotesID == VOTE_YES )
				g_bWillFree = true;
			
			GreenPrint( 0, "Vote is over. %s^1 [^3 %i^1 votes (^4%i%%) ^1]", g_bWillFree ? "Next round will be free!" : "Next round won't be free!", iHighVotes, GetPercent( g_iVotes[ iHighVotesID ], g_iVotes[ VOTE_YES ] + g_iVotes[ VOTE_NO ] ) );
		} else
			GreenPrint( 0, "Vote is over. No one voted." );
		
		for( new i = 1; i <= g_iMaxplayers; i++ )
			if( is_user_connected( i ) )
				ShowVoteMenu( i, 1 );
	} else {
		for( new i = 1; i <= g_iMaxplayers; i++ )
			if( is_user_connected( i ) )
				ShowVoteMenu( i, 0 );
	}
}

ShowVoteMenu( id, bResults = 0 ) {
	new iMenu = GetUserMenu( id );
	
	if( ( iMenu && iMenu != g_iMenuID ) && g_iCountdown <= 14 )
		return;
	
	menu_cancel( id ); // Radios and other piece of shit bug fix :D
	
	new szMenu[ 196 ], iLen;
	
	if( bResults )
		iLen = formatex( szMenu, charsmax( szMenu ), "\rResults of the vote:^n^n" );
	else
		iLen = formatex( szMenu, charsmax( szMenu ), "\rDo you want a free round?^n^n" );
	
	new iVotesTotal = g_iVotes[ VOTE_YES ] + g_iVotes[ VOTE_NO ];
	
	iLen += formatex( szMenu[ iLen ], charsmax( szMenu ) - 1, "\r1. \wYes \d(%i%%)^n", GetPercent( g_iVotes[ VOTE_YES ], iVotesTotal ) );
	iLen += formatex( szMenu[ iLen ], charsmax( szMenu ) - 1, "\r2. \wNo \d(%i%%)^n^n", GetPercent( g_iVotes[ VOTE_NO ], iVotesTotal ) );
	
	if( bResults ) {
		if( g_bWillFree )
			iLen += formatex( szMenu[ iLen ], charsmax( szMenu ) - 1, "  \yNext round will be free!" );
		else {
			if( !iVotesTotal )
				iLen += formatex( szMenu[ iLen ], charsmax( szMenu ) - 1, "  \yNo one voted!" );
		}
		
		show_menu( id, ( MENU_KEY_1 | MENU_KEY_2 | MENU_KEY_0 ), szMenu, -1, "DrunFreeRoundVote" );
		
		set_task( 5.0, "CloseMenu", id );
	} else {
		iLen += formatex( szMenu[ iLen ], charsmax( szMenu ) - 1, "  \dseconds remaining: \r%i", g_iCountdown );
		
		show_menu( id, ( MENU_KEY_1 | MENU_KEY_2 ), szMenu, -1, "DrunFreeRoundVote" );
	}
}

public CloseMenu( id )
	if( GetUserMenu( id ) == g_iMenuID )
		client_cmd( id, "slot1" );

GetUserMenu( id ) {
	new iMenu, iKeys;
	get_user_menu( id, iMenu, iKeys );
	
	return iMenu;
}

public HandleVote( id, iKey ) {
	if( !g_bVoting || !task_exists( TASK_VOTE ) )
		return;
	
	if( g_bVoted[ id ] ) {
		ShowVoteMenu( id, 0 );
		
		return;
	}
	
	if( iKey > 1 )
		return;
	
	new iVotes = ( /* get_user_flags( id ) & ADMIN_KICK ||*/ get_user_team( id ) == 1 ) ? 2 : 1;
	
	g_bVoted[ id ] = true;
	g_iVotes[ iKey ] += iVotes;
	
	new szName[ 32 ];
	get_user_name( id, szName, 31 );
	
	GreenPrint( 0, "^3%s^1 voted^4 %s^1. [^4+%i^1 vote%s]", szName, iKey == VOTE_YES ? "for" : "against", iVotes, iVotes == 1 ? "" : "s" );
	
	ShowVoteMenu( id, 0 );
}

public FwdHamUse_Button( iEntity, id, iActivator, iUseType, Float:flValue ) {
	if( g_bFreeRound && iUseType == 2 && flValue == 1.0 && is_user_alive( id )
	&&  get_user_team( id ) == 1 && get_pdata_int( iEntity, m_toggle_state, 4 ) == 1 ) {
		/* Oh hi this code actually happen! :D */
		
		set_hudmessage( random(255), random(255), random(255), -1.0, 0.25, 0, 2.0, 2.0, 0.2, 0.2, 3 );
		show_hudmessage( id, "It is free round!^nYou can't use buttons!" );
		
		return HAM_SUPERCEDE;
	}
	
	return HAM_IGNORED;
}

GetPercent( is, of ) // Brad
	return ( of != 0 ) ? floatround( floatmul( float( is ) / float( of ), 100.0 ) ) : 0;

GreenPrint( id, const message[ ], any:... ) {
	static szMessage[ 192 ], iLen;
	if( !iLen )
		iLen = formatex( szMessage, 191, "^4[ Deathrun ]^1 " );
	
	vformat( szMessage[ iLen ], 191 - iLen, message, 3 );
	
	message_begin( id ? MSG_ONE_UNRELIABLE : MSG_BROADCAST, g_iMsgSayText, _, id );
	write_byte( id ? id : 1 );
	write_string( szMessage );
	message_end( );
	
	return 1;
}