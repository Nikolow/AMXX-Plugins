new const PLUGINNAME[] = "Roundsleft"
new const VERSION[] = "0.2"
new const AUTHOR[] = "JGHG"

#include <amxmodx>
#include <amxmisc>
#include <engine>

// Globals below
new g_teamScore[2]
// Globals above

public sayRoundsLeft(id) {
	new maxRounds = get_cvar_num("mp_maxrounds")
	if (id) {
		if (maxRounds == 0) {
			ColorMessage(0, "^x03No rounds limit.")
		}
		else {
			new roundsleft = maxRounds - (g_teamScore[0] + g_teamScore[1])
			ColorMessage(0, "^x03%d ^x01rounds left.", roundsleft)
			speakroundsleft(id, roundsleft)
		}
	}

	return PLUGIN_CONTINUE
}

speakroundsleft(id, roundsleft) {
	new numbers[256]
	getnumbers(roundsleft, numbers, 255)
	client_cmd(id, "spk ^"%s round remaining^"", numbers)
	//client_print(0, print_chat, "%s round%s remain", numbers, roundsleft > 1 ? "s" : "")
}

public conRoundsLeft(id) {
	new maxRounds = get_cvar_num("mp_maxrounds")
	if (id)	console_print(id,"%d rounds left.",maxRounds - (g_teamScore[0] + g_teamScore[1]))
	else server_print("Remaining rounds: %d",maxRounds - (g_teamScore[0] + g_teamScore[1]))

	return PLUGIN_HANDLED
}

public teamScore(id) {
	new team[2]
	read_data(1,team,1)
	g_teamScore[(team[0]=='C')? 0 : 1] = read_data(2)

	return PLUGIN_CONTINUE
}

/*
public newround_event(id) {
	if (is_user_bot(id))
		return PLUGIN_CONTINUE

	new maxRounds = get_cvar_num("mp_maxrounds")
	if (maxRounds) {
		set_hudmessage(0, 100, 0, -1.0, 0.65, 2, 0.02, 10.0, 0.01, 0.1, 2)
		show_hudmessage(id, "%d rounds remaining", maxRounds - (g_teamScore[0] + g_teamScore[1]))
		client_print(id, print_chat, "%d rounds remaining", maxRounds - (g_teamScore[0] + g_teamScore[1]))
	}

	return PLUGIN_CONTINUE
}
*/

public endround_event() {
	server_print("endround_event, %d entities in game", entity_count())
	set_task(2.0, "endofroundspk")

	return PLUGIN_CONTINUE
}

public endofroundspk() {
	//server_print("endofroundspk")
	new maxRounds = get_cvar_num("mp_maxrounds")
	new roundsleft = maxRounds - (g_teamScore[0] + g_teamScore[1])
	if (maxRounds) {
		set_hudmessage(28, 134, 238, 0.65, 0.7, 2, 0.02, 10.0, 0.01, 0.1, random_num(346, 6715))
		if (roundsleft > 0)
			show_hudmessage(0, "%d round%s remaining", roundsleft, roundsleft > 1 ? "s" : "")
		else {
			new nextmap[64]
			get_cvar_string("amx_nextmap", nextmap, 63)
			show_hudmessage(0, "Rounds played, changing to %s...", nextmap)
		}
		//client_print(0, print_chat, "%d rounds remaining", roundsleft)
	}

	if (roundsleft > 0) {
		if (roundsleft == 1)
			client_cmd(0, "spk ^"this is the final round^"")
		else
			speakroundsleft(0, roundsleft)
	}
}

stock getnumbers(number, wordnumbers[], length) {
	if (number < 0) {
		format(wordnumbers, length, "error")
		return
	}

	new numberstr[20]
	num_to_str(number, numberstr, 19)
	new stlen = strlen(numberstr), bool:getzero = false, bool:jumpnext = false
	if (stlen == 1)
		getzero = true

	do {
		if (jumpnext)
			jumpnext = false
		else if (numberstr[0] != '0') {
			switch (stlen) {
				case 9: {
					if (getsingledigit(numberstr[0], wordnumbers, length))
						format(wordnumbers, length, "%s hundred%s", wordnumbers, numberstr[1] == '0' && numberstr[2] == '0' ? " million" : "")
				}
				case 8: {
					jumpnext = gettens(wordnumbers, length, numberstr)
					if (jumpnext)
						format(wordnumbers, length, "%s million", wordnumbers)
				}
				case 7: {
					getsingledigit(numberstr[0], wordnumbers, length)
					format(wordnumbers, length, "%s million", wordnumbers)
				}
				case 6: {
					if (getsingledigit(numberstr[0], wordnumbers, length))
						format(wordnumbers, length, "%s hundred%s", wordnumbers, numberstr[1] == '0' && numberstr[2] == '0' ? " thousand" : "")
				}
				case 5: {
					jumpnext = gettens(wordnumbers, length, numberstr)
					if (numberstr[0] == '1' || numberstr[1] == '0')
						format(wordnumbers, length, "%s thousand", wordnumbers)
				}
				case 4: {
					getsingledigit(numberstr[0], wordnumbers, length)
					format(wordnumbers, length, "%s thousand", wordnumbers)
				}
				case 3: {
					getsingledigit(numberstr[0], wordnumbers, length)
					format(wordnumbers, length, "%s hundred", wordnumbers)
				}
				case 2: jumpnext = gettens(wordnumbers, length, numberstr)
				case 1: {
					getsingledigit(numberstr[0], wordnumbers, length, getzero)
					break // could've trimmed, but of no use here
				}
				default: {
					format(wordnumbers, length, "%s TOO LONG", wordnumbers)
					break
				}
			}
		}

		jghg_trim(numberstr, length, 1)
		stlen = strlen(numberstr)
	}
	while (stlen > 0)

	// Trim a char from left if first char is a space (very likely)
	if (wordnumbers[0] == ' ')
		jghg_trim(wordnumbers, length, 1)
}

// Returns true if next char should be jumped
stock bool:gettens(wordnumbers[], length, numberstr[]) {
	new digitstr[11], bool:dont = false, bool:jumpnext = false
	switch (numberstr[0]) {
		case '1': {
			jumpnext = true
			switch (numberstr[1]) {
				case '0': digitstr = "ten"
				case '1': digitstr = "eleven"
				case '2': digitstr = "twelve"
				case '3': digitstr = "thirteen"
				case '4': digitstr = "fourteen"
				case '5': digitstr = "fifteen"
				case '6': digitstr = "sixteen"
				case '7': digitstr = "seventeen"
				case '8': digitstr = "eighteen"
				case '9': digitstr = "nineteen"
				default: digitstr = "TEENSERROR"
			}
		}
		case '2': digitstr = "twenty"
		case '3': digitstr = "thirty"
		case '4': digitstr = "fourty"
		case '5': digitstr = "fifty"
		case '6': digitstr = "sixty"
		case '7': digitstr = "seventy"
		case '8': digitstr = "eighty"
		case '9': digitstr = "ninety"
		case '0': dont = true // do nothing
		default : digitstr = "TENSERROR"
	}
	if (!dont)
		format(wordnumbers, length, "%s %s", wordnumbers, digitstr)

	return jumpnext
}

// Returns true when sets, else false
stock getsingledigit(digit[], numbers[], length, bool:getzero = false) {
	new digitstr[11]
	switch (digit[0]) {
		case '1': digitstr = "one"
		case '2': digitstr = "two"
		case '3': digitstr = "three"
		case '4': digitstr = "four"
		case '5': digitstr = "five"
		case '6': digitstr = "six"
		case '7': digitstr = "seven"
		case '8': digitstr = "eight"
		case '9': digitstr = "nine"
		case '0': {
			if (getzero)
				digitstr = "zero"
			else
				return false
		}
		default : digitstr = "digiterror"
	}
	format(numbers, length, "%s %s", numbers, digitstr)

	return true
}

stock jghg_trim(stringtotrim[], len, charstotrim, bool:fromleft = true) {
	if (charstotrim <= 0)
		return

	if (fromleft) {
		new maxlen = strlen(stringtotrim)
		if (charstotrim > maxlen)
			charstotrim = maxlen

		format(stringtotrim, len, "%s", stringtotrim[charstotrim])
	}
	else {
		new maxlen = strlen(stringtotrim) - charstotrim
		if (maxlen < 0)
			maxlen = 0

		format(stringtotrim, maxlen, "%s", stringtotrim)
	}
}

public addrounds(id, level, cid) {
	if (!cmd_access(id, level, cid, 2))
		return PLUGIN_HANDLED

	new arg[32]
	read_argv(1, arg, 31)
	new arglength = strlen(arg)
	for (new i = 0; i < arglength; i++) {
		if (!isdigit(arg[i])) {
			if (i != 0 || arg[0] != '-') {
				console_print(id, "Error: Enter only numbers, ie ^"amx_addrounds 10^"")
				return PLUGIN_HANDLED
			}
		}
	}

	new roundstoadd = str_to_num(arg)

	if (roundstoadd == 0) {
		console_print(id, "Error: Well duuuh. Enter a positive or negative value, ie ^"amx_addrounds 10^"")
		return PLUGIN_HANDLED
	}

	new originalmaxrounds = get_cvar_num("mp_maxrounds")

	new newmaxrounds = originalmaxrounds + roundstoadd

	if (newmaxrounds < 1)
		newmaxrounds = 1

	new roundschanged = newmaxrounds - originalmaxrounds

	new Float:displayrounds = float(roundschanged)
	displayrounds *= displayrounds
	displayrounds = floatsqroot(displayrounds)

	console_print(id, "%sing %d rounds...", roundschanged > 0 ? "Add" : "Remov", floatround(displayrounds))

	set_cvar_num("mp_maxrounds", newmaxrounds)

	conRoundsLeft(id)

	return PLUGIN_HANDLED
}

public plugin_init() {
	register_plugin(PLUGINNAME, VERSION, AUTHOR)
 	register_clcmd("say timeleft", "sayRoundsLeft")
 	register_clcmd("say roundsleft", "sayRoundsLeft", 0, "- displays remaining rounds")
 	register_concmd("amx_roundsleft", "conRoundsLeft", 0, "- displays remaining rounds")
 	register_concmd("amx_addrounds", "addrounds", ADMIN_CFG, "<rounds> - add/remove remaining rounds")
	register_event("TeamScore", "teamScore", "ab")
	//register_event("ResetHUD", "newround_event", "b")
	/*
	register_event("SendAudio","endround_event","a","2&%!MRAD_terwin","2&%!MRAD_ctwin","2&%!MRAD_rounddraw")
	register_event("TextMsg","endround_event","a","2&#Game_C","2&#Game_w")
	register_event("TextMsg","endround_event","a","2&#Game_will_restart_in")
	*/
	/*
	register_logevent("death_event",5,"1=killed","3=with")
	// L 03/08/2004 - 13:32:34: "xian<2><BOT><CT>" killed "SuperKaka<1><BOT><TERRORIST>" with "usp"
	// L 03/08/2004 - 13:32:34: World triggered "Round_End"
	*/
	// L 03/08/2004 - 13:32:34: World triggered "Round_End"
	/*register_logevent("endround_event", 3, "2=Round_End")
	register_logevent("endround_event", 3, "1=Round_End")
	register_logevent("endround_event", 3, "0=Round_End")
	register_logevent("endround_event", 3, "3=Round_End")*/
	register_logevent("endround_event", 2, "0=World triggered", "1=Round_End")
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