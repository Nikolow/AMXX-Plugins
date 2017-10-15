#include <amxmodx>
#include <amxmisc>

#define MAX_OPTIONS 7

new g_pMenu
new g_pCountSystem
new g_pTimelimit

new g_voteCount[MAX_OPTIONS]
new g_iVoteTimes[MAX_OPTIONS]
new g_iNumOptions = 0
new bool:g_bMenuExists = false

public plugin_init()
{
	register_plugin("MaxRounds Vote", "0.5", "Fysiks")

	g_pCountSystem	= register_cvar("amx_countsys",	"0")
	register_srvcmd("amx_maxrounds_votes", "set_vote_times")

	// Load up the old default values
	g_iVoteTimes[0] = 20
	g_iVoteTimes[1] = 30
	g_iVoteTimes[2] = 40
	g_iNumOptions = 3
	build_menu()

	set_task(90.0, "start_vote")
}

public plugin_cfg()
{
	g_pTimelimit = get_cvar_pointer("mp_maxrounds")
}

public set_vote_times()
{
	new buff[8]
	new args = clamp( read_argc(), 0, MAX_OPTIONS+1)
	g_iNumOptions = args - 1

	if (args <= 1)
	{
		return
	}

	for (new i = 1; i < args; i++)
	{
		read_argv(i, buff, charsmax(buff))
		g_iVoteTimes[i-1] = str_to_num(buff)
	}
	build_menu()
}

build_menu()
{
	if( g_bMenuExists ) // if( g_pMenu ) ??
		menu_destroy(g_pMenu)

	g_pMenu = menu_create("\wChoose \rmax \wrounds for this map?", "menu_handler")
	g_bMenuExists = true

	new option[64], szNum[12]
	for(new i = 0; i < g_iNumOptions; i++)
	{
		formatex(option, charsmax(option), "\r%d \wrounds", g_iVoteTimes[i])
		// server_print(">>>> %d <> %s <<<<", g_iVoteTimes[i], option) // debug
		formatex(szNum, charsmax(option), "%d", i)
		menu_additem(g_pMenu, option, szNum)
	}
	menu_setprop(g_pMenu, MPROP_EXIT, MEXIT_ALL)
}

public start_vote(id)
{
	new players[32], inum, i
	get_players(players, inum, "ch")

	for(i = 0; i < inum; i++)
		menu_display(players[i], g_pMenu, 0)

	for(i = 0; i < g_iNumOptions; i++)
		g_voteCount[i] = 0

	set_task(15.0, "CountVotes")
	// server_print("<><><><><><><><><><><><><><><><><><><>") // debug
	return PLUGIN_CONTINUE
}

public menu_handler(id, g_pMenu, item)
{
	if(item == MENU_EXIT)
		return PLUGIN_HANDLED

	new data[6], name[32]
	new iAccess, callback

	menu_item_getinfo(g_pMenu, item, iAccess, data, 5, "", 0, callback)

	new key = str_to_num(data)
	get_user_name(id, name, 31)

	ColorMessage(0, "^x03%s ^x01voted for ^x03%d ^x01rounds!", name, g_iVoteTimes[key])

	g_voteCount[key]++

	return PLUGIN_HANDLED
}

public CountVotes()
{
	new votesNum = 0

	if( get_pcvar_num(g_pCountSystem) )
	{
		new sum_time = 0
		new iTime

		for(new i = 0; i < g_iNumOptions; i++)
		{
			votesNum += g_voteCount[i]
			sum_time += g_voteCount[i] * g_iVoteTimes[i]
		}

		if(votesNum)
		{
			iTime = floatround(float(sum_time) / float(votesNum), floatround_ceil)
			if (iTime - (iTime = iTime / 10 * 10) >= 5) // What does this do??
				iTime += 10

			ColorMessage(0, "Voting ^x04successful^x01. Map will be played: ^x03%d ^x01rounds!", iTime)

			set_pcvar_num(g_pTimelimit, iTime)
		}
		else
		{
			ColorMessage(0, "^x03Nobody ^x01voted on time - Voting failed.")
		}
	}
	else
	{
		new best = 0

		for(new i=0;i<(g_iNumOptions);i++)
		{
			if(g_voteCount[i] > g_voteCount[best])
				best = i
		}

		for(new i = 0; i < g_iNumOptions; i++)
			votesNum += g_voteCount[i]

		new iRequired = votesNum ? floatround(get_cvar_float("amx_vote_ratio") * float(votesNum), floatround_ceil) : 1
		new iResult = g_voteCount[best]

		if(iResult >= iRequired)
		{
			new new_time = g_iVoteTimes[best]

			ColorMessage(0, "Voting ^x04successful^x01. Map will be played: ^x03%d ^x01rounds!", new_time)

			set_pcvar_num(g_pTimelimit, new_time)
		}
		else
		{
			ColorMessage(0, "^x03Nobody ^x01voted on time - Voting failed.")
		}
	}
}

   stock ColorMessage(const id, const input[], any:...){
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