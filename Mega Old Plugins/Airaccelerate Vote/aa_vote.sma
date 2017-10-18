#include <amxmodx> 

#define VERSION "1.0"

new VoteMenu, Voting, g_sv_aa
new PlayerVotes[3]
new StartVoteSeconds, EndVoteSeconds, PluginPrefix

public plugin_init() 
{
	register_plugin("Vote for airaccelerate", VERSION, "Dark_Style & Kostov")
	register_cvar("vote_for_aa", VERSION, FCVAR_SERVER|FCVAR_SPONLY)
	
	StartVoteSeconds = register_cvar("amx_start_voteaa",  "25.0")
	EndVoteSeconds   = register_cvar("amx_end_voteaa",    "15.0")
	PluginPrefix     = register_cvar("amx_voteaa_prefix", "Boost")
	
	g_sv_aa = get_cvar_pointer("sv_airaccelerate")
	
	set_task(get_pcvar_float(StartVoteSeconds), "StartAAVote")
} 

public StartAAVote(id) 
{ 
	VoteMenu = menu_create("\rChoose airaccelerate for this map?", "OffsetAAVote")
	
	menu_additem(VoteMenu, "airaccelerate 10", "10")
	menu_additem(VoteMenu, "airaccelerate 100", "100")
	
	new iPlayers[32], iNum, iTempID
	get_players(iPlayers, iNum)
	
	for(new i; i < iNum; i++) 
	{ 
		iTempID = iPlayers[i]
		menu_display(iTempID, VoteMenu, 0)
		Voting++
	}
	
	set_task(get_pcvar_float(EndVoteSeconds), "EndAAVote")
	
	return PLUGIN_HANDLED
} 

public OffsetAAVote(id, VoteMenu, item) 
{ 
	if(item == MENU_EXIT) 
		return PLUGIN_HANDLED
	
	new data[4], UserName[32], Prefix[64] 
	new access, callback
	menu_item_getinfo(VoteMenu,item,access, data,3, _,_, callback)
	get_pcvar_string(PluginPrefix, Prefix, sizeof Prefix - 1)
	get_user_name(id, UserName, sizeof UserName - 1)
	
	new iVoteID = str_to_num(data);
	VoteAA(0, "^4[%s] ^3 %s ^1voted for^3 %d airaccelerate", Prefix, UserName, iVoteID) 
	
	PlayerVotes[iVoteID/50]++
 
	return PLUGIN_HANDLED
}
 
public EndAAVote() 
{
	new Prefix[64]
	get_pcvar_string(PluginPrefix, Prefix, sizeof Prefix - 1)
	if(PlayerVotes[1] < PlayerVotes[0] > PlayerVotes[2]) 
	{ 
		VoteAA(0, "^4[%s] ^1sv_airaccelerate ^3has been set to^4 10", Prefix)
		set_pcvar_num(g_sv_aa, 10)
	} 
	else if(PlayerVotes[1] < PlayerVotes[2] > PlayerVotes[0]) 
	{ 
		VoteAA(0, "^4[%s] ^1sv_airaccelerate ^3has been set to^4 100", Prefix) 
		set_pcvar_num(g_sv_aa, 100)
	}
	
	menu_destroy(VoteMenu); 
	Voting = 0; 
} 

/*START - ColorChat */
stock VoteAA(const id, const input[], any:...){
	new count = 1, players[32];
	static msg[ 191 ];
	vformat(msg, 190, input, 3);
	if (id) players[0] = id; else get_players(players , count , "ch"); {
		for (new i = 0; i < count; i++){
			if (is_user_connected(players[i])){
				message_begin(MSG_ONE_UNRELIABLE , get_user_msgid("SayText"), _, players[i]);
				write_byte(players[i]);
				write_string(msg);
				message_end();}}}
}
/*END - ColorChat */	  
