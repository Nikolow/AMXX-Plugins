/* Plugin generated by AMXX-Studio */

#include < amxmodx >
#include < csx >
//#include < fcs >
//#include < CC_ColorChat >

#define PLUGIN "FCS Bomb Events"
#define VERSION "0.1.5"		//.5 am inclus fcs si CC_ColorChat direct in .sma


enum Color
{
	NORMAL = 1, 		// Culoarea care o are jucatorul setata in cvar-ul scr_concolor.
	GREEN, 			// Culoare Verde.
	TEAM_COLOR, 		// Culoare Rosu, Albastru, Gri.
	GREY, 			// Culoarea Gri.
	RED, 			// Culoarea Rosu.
	BLUE, 			// Culoarea Albastru.
}

new TeamName[  ][  ] = 
{
	"",
	"TERRORIST",
	"CT",
	"SPECTATOR"
}





//--| Furien Credits System .inc file
/*
 * Returns a players credits
 * 
 * @param		client - The player index to get points of
 * 
 * @return		The credits client
 * 
 */

native fcs_get_user_credits(client);

/*
 * Sets <credits> to client
 * 
 * @param		client - The player index to set points to
 * @param		credits - The amount of credits to set to client
 * 
 * @return		The credits of client
 * 
 */

native fcs_set_user_credits(client, credits);

/*
 * Adds <credits> points to client
 * 
 * @param		client - The player index to add points to
 * @param		credits - The amount of credits to add to client
 * 
 * @return		The credits of client
 * 
 */

stock fcs_add_user_credits(client, credits)
{
	return fcs_set_user_credits(client, fcs_get_user_credits(client) + credits);
}

/*
 * Subtracts <credits>  from client
 * 
 * @param		client - The player index to subtract points from
 * @param		credits - The amount of credits to substract from client
 * 
 * @return		The credits of client
 * 
 */

stock fcs_sub_user_credits(client, credits)
{
	return fcs_set_user_credits(client, fcs_get_user_credits(client) - credits);
}

//--| End of Furien Credits System .inc file

new const g_szTag[ ] = "[Furien Credits]";

new g_iCvarEnableBE;
new g_iCvarPlanted;
new g_iCvarExplode;
new g_iCvarDefused;

public plugin_init( )
{
	register_plugin( PLUGIN, VERSION, "Askhanar" );
	
	g_iCvarEnableBE = register_cvar( "fcs_be_enable", "1" );
	g_iCvarPlanted = register_cvar( "fcs_be_planted", "5" );
	g_iCvarExplode = register_cvar( "fcs_be_explode", "10" );
	g_iCvarDefused = register_cvar( "fcs_be_defused", "15" );
	
	
	// Add your code here...
}


public bomb_planted( iPlanter )
{
	
	if( get_pcvar_num( g_iCvarEnableBE ) == 0 )
		return PLUGIN_CONTINUE;
		
	new iPlanted = get_pcvar_num( g_iCvarPlanted );
	
	if( iPlanted == 0 || !is_user_connected( iPlanter ) )
		return PLUGIN_CONTINUE;
		
	fcs_add_user_credits( iPlanter, iPlanted );
	ColorChat( iPlanter, RED, "^x04%s^x01 You earned^x03 %i^x01 credits for planting the bomb!", g_szTag, iPlanted );
	
	return PLUGIN_CONTINUE;
	
}

public bomb_explode( iPlanter, iDefuser )
{
	
	if( get_pcvar_num( g_iCvarEnableBE ) == 0 )
		return PLUGIN_CONTINUE;
		
	new iExplode = get_pcvar_num( g_iCvarExplode );
	
	if( iExplode == 0 || !is_user_connected( iPlanter ) )
		return PLUGIN_CONTINUE;
		
	fcs_add_user_credits( iPlanter, iExplode );
	ColorChat( iPlanter, RED, "^x04%s^x01 You earned^x03 %i^x01 credits for bomb exploding!", g_szTag, iExplode );
	
	return PLUGIN_CONTINUE;
	
}

public bomb_defused( iDefuser )
{
	
	if( get_pcvar_num( g_iCvarEnableBE ) == 0 )
		return PLUGIN_CONTINUE;
		
	new iDefused = get_pcvar_num( g_iCvarDefused );
	
	if( iDefused == 0 || !is_user_connected( iDefuser ) )
		return PLUGIN_CONTINUE;
		
	fcs_add_user_credits( iDefuser, iDefused );
	ColorChat( iDefuser, RED, "^x04%s^x01 You earned^x03 %i^x01 credits for defusing the bomb!", g_szTag, iDefused );
	
	return PLUGIN_CONTINUE;
	
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
	write_byte(  id  )		
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