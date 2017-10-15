#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include <cstrike>
#include <dhudmessage>

#define TASK_TIMER 803891

new g_counter

new Float:RoundStartTime

new g_Time_Interval;
const MAX_PLAYERS = 32;

new g_iRespawn[MAX_PLAYERS+1], g_TeamInfoCounter[MAX_PLAYERS+1], CsTeams:g_iPlayerTeam[MAX_PLAYERS+1];
new g_pCvarRespawnTime, g_pCvarRespawnDelay, g_pCvarMaxHealth;

public plugin_init()
{
	register_plugin("Dr.Respawn", "1.1", "???"); 
	
	RegisterHam(Ham_Killed, "player", "fwdPlayerKilledPost", 1);
	RegisterHam(Ham_Spawn, "player", "fwdPlayerSpawnPost", 1);
	
	register_event("TeamInfo", "eTeamInfo", "a");
	
	register_logevent( "LogEventRoundStart", 2, "1=Round_Start" )
	
	g_pCvarRespawnTime = register_cvar("amx_respawn_tickets", "0"); //Set to 0 for unlimited respawns
	g_pCvarRespawnDelay = register_cvar("amx_respawn_delay", "1");
	g_pCvarMaxHealth = register_cvar("amx_max_health", "100");
	g_Time_Interval = register_cvar("amx_max_time", "180");
	
	set_msg_block( get_user_msgid( "ClCorpse" ), BLOCK_SET );
}
public LogEventRoundStart()
{
	RoundStartTime = get_gametime()
	
	new iPlayers[32]
	new iNum
	get_players( iPlayers, iNum )
	for( new i = 0; i < iNum; i++ ) g_iRespawn[iPlayers[i]] = true

	g_RespTimer = get_pcvar_num(mpc4timer) - 1
	
	set_task(1.0, "effect", TASK_TIMER, "", 0, "b")
}

public effect()
{
	if (g_RespTimer > 0)
	{ 
		if (g_RespTimer <= 180 && g_RespTimer > 10)
		{
			switch (g_RespTimer) 
			{
				default: set_hudmessage( random(255), random(255), random(255), 0.30, 0.05, 1, 0.0, 1.0, 0.0, 0.0, -1)
			}
			show_hudmessage( 0, "Respawn Time: %d seconds remaining", floatround(fSec))
		}
		
		if (g_RespTimer <= 10 && g_RespTimer > 0)
		{
		
			switch (g_RespTimer) 
			{
				default: set_hudmessage( random(255), random(255), random(255), 0.30, 0.05, 1, 0.0, 1.0, 0.0, 0.0, -1)
			}
			show_hudmessage( 0, "Respawn Time: %d seconds remaining", floatround(fSec))
			
			new temp[48]
			num_to_word(g_RespTimer, temp, 47)
			client_cmd(0, "spk ^"vox/%s^"", temp)
		}
		--g_RespTimer
	}
	else 
		remove_task(TASK_TIMER)
}

public Runda_Terminata()
{
	if(RoundStartTime)
	{
		set_dhudmessage(random(255), random(255), random(255), -1.0, 0.30, 1, 0.5, 2.0, 0.5, 3.0)
		show_dhudmessage( 0, "Respawn mode is disabled!")
	}
}

public fwdPlayerKilledPost(iVictim, iKiller, iShoudlGib)
{
	if(g_iRespawn[iVictim]++ < get_pcvar_num(g_pCvarRespawnTime) || get_pcvar_num(g_pCvarRespawnTime) == 0)
		set_task(get_pcvar_float(g_pCvarRespawnDelay), "taskRespawnPlayer", iVictim);
	return HAM_IGNORED;
}

public fwdPlayerSpawnPost(iClient)
	if(is_user_alive(iClient))
		set_pev(iClient, pev_health, get_pcvar_float(g_pCvarMaxHealth));

public taskRespawnPlayer(id)
{
	if(is_user_connected(id) && RoundStartTime + get_pcvar_num(g_Time_Interval) >= get_gametime() && g_iRespawn[id] && !is_user_alive(id) && cs_get_user_team(id) != CS_TEAM_SPECTATOR) 
	{
		ExecuteHamB(Ham_CS_RoundRespawn, id)
		g_iRespawn[id] = false
		return PLUGIN_HANDLED;
	}
	return PLUGIN_HANDLED;
}  

public eTeamInfo() 
{ 
	new iClient = read_data(1);
	new szTeam[2];
	read_data(2, szTeam, charsmax(szTeam));
	
	switch(szTeam[0])
	{
		case 'T': 
		{
			if(g_TeamInfoCounter[iClient] == 2 || g_iPlayerTeam[iClient] == CS_TEAM_SPECTATOR)
				set_task(get_pcvar_float(g_pCvarRespawnDelay), "taskRespawnPlayer",  iClient);

			g_iPlayerTeam[iClient] = CS_TEAM_T;
		}
		case 'C': 
		{
			if(g_TeamInfoCounter[iClient] == 2 || g_iPlayerTeam[iClient] == CS_TEAM_SPECTATOR)
				set_task(get_pcvar_float(g_pCvarRespawnDelay), "taskRespawnPlayer",  iClient);
			
			g_iPlayerTeam[iClient] = CS_TEAM_CT;
		}
		case 'S':
		{
			remove_task(iClient);
			g_iPlayerTeam[iClient] = CS_TEAM_SPECTATOR;
		}
	}
}

public TimeCounter() 
{
	g_counter++
	
	new Float:iRestartTime = get_pcvar_float(g_Time_Interval) - g_counter
	new Float:fSec
	fSec = iRestartTime 
	
	if(get_pcvar_num(g_Time_Interval) - g_counter < 180 && get_pcvar_num(g_Time_Interval) - g_counter !=0)
	{
		set_hudmessage( random(255), random(255), random(255), 0.30, 0.05, 1, 0.0, 1.0, 0.0, 0.0, -1)
		show_hudmessage( 0, "Respawn Time: %d seconds remaining", floatround(fSec))
	}
	
	if(get_pcvar_num(g_Time_Interval) - g_counter < 11 && get_pcvar_num(g_Time_Interval) - g_counter !=0)
	{
		static szNum[32]
		num_to_word(get_pcvar_num(g_Time_Interval) - g_counter, szNum, 31)
	}
	
	if(get_pcvar_num(g_Time_Interval) - g_counter < 1 && get_pcvar_num(g_Time_Interval) - g_counter !=0)
		Runda_Terminata()
	
	if(g_counter == get_pcvar_num(g_Time_Interval))
		g_counter = 0
}