#include <amxmodx> 

#pragma semicolon 1

#define PLUGIN "Freezetime"
#define VERSION "1.0"


new const InvasionSounds[6][ ] =
{
	"timestart",
	"timer01",
	"timer02",
	"timer03",
	"timer04",
	"timer05"
};

new mp_freezetime;

new SyncHudMessage;
new SecondsUntillInvasion = 6;


public plugin_init( )
{
	register_plugin(PLUGIN, VERSION, "Askhanar" );
	
	register_event("HLTV", "eventRoundStart", "a", "1=0", "2=0");
	
	mp_freezetime = get_cvar_pointer("mp_freezetime");
	set_pcvar_num(mp_freezetime, 5);
	SyncHudMessage = CreateHudSyncObj( );
}
public plugin_precache( )
{
	new soundpath[64];
	for(new i = 0; i < 6; i++)
	{
		formatex(soundpath, sizeof(soundpath) -1, "misc/%s.wav", InvasionSounds[i]);
		precache_sound(soundpath);
	}
}
public eventRoundStart( )
{
	set_task(0.1, "CountDown");
}
public CountDown( )
{
	if( SecondsUntillInvasion > 0 )
	{
		TerroTeamEffects( );
		CounterTeamEffects( );
		
		set_hudmessage(0, 255, 0, -1.0, 0.29, 0, 0.0, 1.0, 0.0, 1.0, 4);
		client_cmd(0, "spk misc/%s", InvasionSounds[SecondsUntillInvasion]);
		static const Seconds[6][ ] = {"","o","doua","trei","patru","cinci"};
		ShowSyncHudMsg(0, SyncHudMessage, "Furienii vor invada planeta in %s secund%s !", Seconds[SecondsUntillInvasion], SecondsUntillInvasion == 1 ? "a" : "e");
		
	}
	else if( SecondsUntillInvasion <= 0 )
	{
		set_hudmessage(255, 0, 0, -1.0, 0.29, 0, 0.0, 5.5, 0.0, 1.0, 4);
		ShowSyncHudMsg(0, SyncHudMessage, "Furienii au invadat planeta !");
		client_cmd(0, "spk misc/%s", InvasionSounds[SecondsUntillInvasion]);
		
		return 1;
	}
	
	SecondsUntillInvasion -= 1;
	
	set_task(1.0, "CountDown");
	
	return 0;
} 
public TerroTeamEffects( )
{
	new iPlayers[32];
	new iPlayersNum;
	
	get_players(iPlayers, iPlayersNum, "aceh", "TERRORIST");
	
	for( new i = 0 ; i < iPlayersNum ; i++ )
	{
		if( is_user_connected(iPlayers[i]) )
		{      
			ShakeScreen(iPlayers[i], 0.9);
			FadeScreen(iPlayers[i], 0.5, 230, 0, 0, 180);
		}
	}
}
public CounterTeamEffects( )
{
	new iPlayers[32];
	new iPlayersNum;
	
	get_players(iPlayers, iPlayersNum, "aceh", "CT");
	
	for( new i = 0; i < iPlayersNum ; i++ )
	{
		if( is_user_connected(iPlayers[i]) )
		{      
			ShakeScreen(iPlayers[i], 0.9);
			FadeScreen(iPlayers[i], 0.5, 0, 0, 230, 180);
		}
	}
}
public ShakeScreen(id, const Float:seconds)
{
	message_begin(MSG_ONE, get_user_msgid("ScreenShake"), {0, 0, 0}, id);
	write_short(floatround(4096.0 * seconds, floatround_round));
	write_short(floatround(4096.0 * seconds, floatround_round));
	write_short(1<<13);
	message_end( );
}

public FadeScreen(id, const Float:seconds, const red, const green, const blue, const alpha)
{      
	message_begin(MSG_ONE, get_user_msgid("ScreenFade"), _, id);
	write_short(floatround(4096.0 * seconds, floatround_round));
	write_short(floatround(4096.0 * seconds, floatround_round));
	write_short(0x0000);
	write_byte(red);
	write_byte(green);
	write_byte(blue);
	write_byte(alpha);
	message_end( );
}