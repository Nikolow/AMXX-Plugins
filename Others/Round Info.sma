/*

	Всеки рунд изписва на всички играчи полезна информация като: Кой рунд е, Коя карта е и Колко играчи има.

*/

#include < amxmodx >
#include < amxmisc >
#include < colorchat >

#define VERSION		"1.0"
#define PREFIX		"[BetterPlay]"


new cvar_on, iRoundCounter;

public plugin_init( )
{
	register_plugin( "Information", VERSION, "Smiley" );
	cvar_on = register_cvar( "information_on", "1" );
	register_event( "HLTV", "EventNewRound", "a", "1=0", "2=0" );
	
	iRoundCounter = 0;
}		
		
public EventNewRound( )
{
	set_task(0.3,"information");
	
	return PLUGIN_CONTINUE;
}

public information()
{
	if( !get_pcvar_num( cvar_on ) ) return PLUGIN_CONTINUE;
	
	iRoundCounter++;
	
	for( new id = 1; id <= 32; id++ )
	{
		if( !is_user_connected( id ) ) continue;
		
		new players, maxplayers, mapname[ 64 ];
		players = get_playersnum( );
		maxplayers = get_maxplayers( );
		get_mapname( mapname, charsmax( mapname ) );
			
		ColorChat( id, GREEN, "%s^1 Round:^3 %i^4 |^1 Map:^3 %s^4 |^1 Player%s:^3 %i^4/^3%i", PREFIX, iRoundCounter, mapname, players == 1 ? "" : "s", players, maxplayers );
	}	
	return PLUGIN_CONTINUE;
}	
