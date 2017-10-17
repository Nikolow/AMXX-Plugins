/*

	Когато спектейтвате някого, горе в дясно има HUD, с информацията за наблюдавания.
	Информация като: Парите му, Кръвта му, Неговият Пинг, Неговото FPS, Армора му.
	Полезен за всякакъв вид сървъри. Най-удобен е за JUMP, където се вижда FPS на играча.

*/


#include <amxmodx>
#include <fakemeta>
#include <engine>
#include <cstrike>

#pragma semicolon 1

#define RED 64
#define GREEN 64
#define BLUE 64
#define UPDATEINTERVAL 1.0

// Comment below if you do not want /speclist showing up on chat
#define ECHOCMD

// Admin flag used for immunity
#define FLAG ADMIN_IMMUNITY

new const PLUGIN[] = "SpecList";
new const VERSION[] = "1.2a";
new const AUTHOR[] = "SasaiLalka"; // ? едит ? ме ?

new gMaxPlayers;
new gCvarOn;
new gCvarImmunity;
new bool:gOnOff[33] = { true, ... };
new g_fps[33][11]; 
new g_i[33]; 

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	register_cvar(PLUGIN, VERSION, FCVAR_SERVER, 0.0);
	gCvarOn = register_cvar("amx_speclist", "1", 0, 0.0);
	gCvarImmunity = register_cvar("amx_speclist_immunity", "1", 0, 0.0);
	
	register_clcmd("speclist", "cmdSpecList", -1, "");
	
	gMaxPlayers = get_maxplayers();
	
	set_task(UPDATEINTERVAL, "tskShowSpec", 123094, "", 0, "b", 0);
}

public cmdSpecList(id)
{
	if( gOnOff[id] )
	{
		Color_Print(id, "!y[!gSpectator List!y] !yThe list is !tDisabled");
		gOnOff[id] = false;
	}
	else
	{
		Color_Print(id, "!y[!gSpectator List!y] !yThe list is !tEnabled");
		gOnOff[id] = true;
	}
	
	#if defined ECHOCMD
	return PLUGIN_CONTINUE;
	#else
	return PLUGIN_HANDLED;
	#endif
}

public tskShowSpec()
{
	if( !get_pcvar_num(gCvarOn) )
	{
		return PLUGIN_CONTINUE;
	}
	
	static szHud[1102];//32*33+45
	static szName[34];
	static bool:send;
	
	// FRUITLOOOOOOOOOOOOPS!
	for( new alive = 1; alive <= gMaxPlayers; alive++ )
	{
		new bool:sendTo[33];
		send = false;
		
		if( !is_user_alive(alive) )
		{
			continue;
		}
		new ping,loss;
		sendTo[alive] = true;
		get_user_ping(alive, ping, loss); 
		get_user_name(alive, szName, 32);
		format(szHud, 245, "Player: %s^nMoney: $%d | HP: %d^nPing: %i | FPS: %i | Armor: %d^n^nSpectators:^n", szName, cs_get_user_money(alive), get_user_health(alive), ping, get_user_fps(alive), get_user_armor(alive));
		
		for( new dead = 1; dead <= gMaxPlayers; dead++ )
		{
			if( is_user_connected(dead) )
			{
				if( is_user_alive(dead)
				|| is_user_bot(dead) )
				{
					continue;
				}
				
				if( pev(dead, pev_iuser2) == alive )
				{
					if( !(get_pcvar_num(gCvarImmunity)&&get_user_flags(dead, 0)&FLAG) )
					{
						get_user_name(dead, szName, 32);
						add(szName, 33, "^n", 0);
						add(szHud, 1101, szName, 0);
						send = true;
					}

					sendTo[dead] = true;
					
				}
			}
		}
		
		if( send == true )
		{
			for( new i = 1; i <= gMaxPlayers; i++ )
			{
				if( sendTo[i] == true
				&& gOnOff[i] == true )
				{
					set_hudmessage(RED, GREEN, BLUE,
						0.75, 0.15, 0, 0.0, UPDATEINTERVAL + 0.1, 0.0, 0.0, -1);
					
					show_hudmessage(i, szHud);
				}
			}
		}
	}
	
	return PLUGIN_CONTINUE;
}

public client_PreThink(id)
        g_fps[id][10]++; 

public client_putinserver(id) 
    set_task(0.1, "count", id, "", 0, "b"); 
        
public count(id) { 
 
    if ( g_i[id] < 9 )
        g_i[id]++; 
    else
        g_i[id] = 0; 
          
    g_fps[id][g_i[id]] = g_fps[id][10]; 
    g_fps[id][10] = 0; 
} 
 
get_user_fps(id)  
{ 
    new i; 
    new j = 0; 
      
    for ( i = 0; i < 9; i++ ) 
        j += g_fps[id][i]; 
      
    return j - 5; 
}

public client_connect(id)
{
	gOnOff[id] = true;
}

public client_disconnect(id)
{
	gOnOff[id] = true;
}

stock Color_Print(const id, const input[], any:...)
{
    new iCount = 1, iPlayers[32];

    static szMsg[191];
    vformat(szMsg, charsmax(szMsg), input, 3);

    replace_all(szMsg, 190, "!g", "^4");
    replace_all(szMsg, 190, "!y", "^1");
    replace_all(szMsg, 190, "!t", "^3");
    replace_all(szMsg, 190, "/w", "^0");

    if(id) iPlayers[0] = id;
    else get_players(iPlayers, iCount, "ch");

    for (new i = 0; i < iCount; i++)
    {
        if (is_user_connected(iPlayers[i]))
        {
            message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("SayText"), _, iPlayers[i]);
            write_byte(iPlayers[i]);
            write_string(szMsg);
            message_end();
        }
    }
}
