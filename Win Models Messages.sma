#include <amxmodx>
#include <fakemeta>
#include <cstrike>

new Hands[33], MaxPlayers

new const MODELS[3][] =
{
	"",
	"models/4V_Mdls/WinMessages/HidersWin.mdl",
	"models/4V_Mdls/WinMessages/SeekersWin.mdl"
};

new const MODELS_FLIP[3][] =
{
	"",
	"models/4V_Mdls/WinMessages/HidersWin-f.mdl",
	"models/4V_Mdls/WinMessages/SeekersWin-f.mdl"
};


new g_iModelIndex[3], g_iWinTeam, g_iModelIndexFlip[3];

public plugin_init()
{
	register_plugin("Win Messages", "1.0", "ADVanced edit, 93()|29!/<" );
	register_event("HLTV", "EventRoundStart", "a", "1=0", "2=0" );
	register_event("CurWeapon", "EventCurWeapon", "be", "1=1");
	register_event("SendAudio", "t_win", "a", "2&%!MRAD_terwin") 
	register_event("SendAudio", "ct_win", "a", "2&%!MRAD_ctwin")

	MaxPlayers = get_maxplayers();

	register_cvar("Shidla", "Win Messages 1.0", FCVAR_SERVER|FCVAR_SPONLY);
	register_cvar("hns_new_win_messages", "Win Messages 1.0", FCVAR_SERVER|FCVAR_SPONLY);
}

public plugin_precache()
{
	for (new i = 1; i <= 2; i++)
	{
		precache_model(MODELS[i]);
		g_iModelIndex[i] = engfunc(EngFunc_AllocString, MODELS[i]);
		precache_model(MODELS_FLIP[i]);
		g_iModelIndexFlip[i] = engfunc(EngFunc_AllocString, MODELS_FLIP[i]);
	}
}

public client_connect(id)
{

}

public Hands_CVAR_Value(id, const cvar[], const value[])
{
	if(1 <= id <= MaxPlayers)	// Bug Fix
		Hands[id] = str_to_num(value)
}

public client_disconnect(id)
{
	Hands[id] = 0
}

public ct_win()
{
	g_iWinTeam = 2
	new iPlayers[32], iNum;
	get_players(iPlayers, iNum, "ch");
	for (new i; i < iNum; i++)
	{
		cs_set_user_nvg(iPlayers[i], 1);

		if (get_user_weapon(iPlayers[i]) != CSW_KNIFE)
			set_pev(iPlayers[i], pev_viewmodel, g_iModelIndexFlip[2]);
		else
			set_pev(iPlayers[i], pev_viewmodel, g_iModelIndex[2]);
	}
}

public t_win()
{
	g_iWinTeam = 1
	new iPlayers[32], iNum;
	get_players(iPlayers, iNum, "ch");
	for (new i; i < iNum; i++)
	{
		//client_cmd(iPlayers[i], "cl_righthand ^"1^"");
		cs_set_user_nvg(iPlayers[i], 1);

		if (get_user_weapon(iPlayers[i]) != CSW_KNIFE)
			set_pev(iPlayers[i], pev_viewmodel, g_iModelIndexFlip[1]);
		else
			set_pev(iPlayers[i], pev_viewmodel, g_iModelIndex[1]);
	}
}

public EventRoundStart()
{
	g_iWinTeam = 0

	for (new i = 1; i <= MaxPlayers; i++)
	{
		if(!is_user_connected(i))
			continue;		// xPaw fix)))
	}
}

public EventCurWeapon(const id)
{
	if (g_iWinTeam > 0)
	{
		//client_cmd(id, "cl_righthand ^"1^"");

		if (get_user_weapon(id) != CSW_KNIFE)
			set_pev(id, pev_viewmodel, g_iModelIndexFlip[g_iWinTeam]);
		else
			set_pev(id, pev_viewmodel, g_iModelIndex[g_iWinTeam]);
	}
}