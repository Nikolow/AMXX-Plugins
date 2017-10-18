#include <amxmodx>

new HIGHPING_MAX = 100
new HIGHPING_TIME = 15
new HIGHPING_TESTS = 8

new iNumTests[33]

public plugin_init() {
	register_plugin("HPK","0.1","Advanced")
	if (HIGHPING_TIME < 15) HIGHPING_TIME = 15
	if (HIGHPING_TESTS < 4) HIGHPING_TESTS = 4
	return PLUGIN_CONTINUE
}

public client_disconnect(id) {
	remove_task(id)
	return PLUGIN_CONTINUE
}
	
public client_putinserver(id) {
	iNumTests[id] = 0
	if (!is_user_bot(id)) {
		new param[1]
		param[0] = id
		set_task(30.0, "showWarn", id, param, 1)
	}
	return PLUGIN_CONTINUE
}

kickPlayer(id) {
	new name[32]
	get_user_name(id, name, 31)
	new uID = get_user_userid(id)
	server_cmd("banid 1 #%d", uID)
	client_cmd(id, "echo ^"[HPK] Sorry but you have high ping, try later...^"; disconnect")
	ColorMessage(0, "^3[HPK]^4 %s ^1was ^4disconnected ^1due to ^3high ^4ping^1!", name)
	return PLUGIN_CONTINUE
} 

public checkPing(param[]) {
	new id = param[0]
	if ((get_user_flags(id) & ADMIN_IMMUNITY) || (get_user_flags(id) & ADMIN_RESERVATION)) {
		remove_task(id)
		ColorMessage(id, "^4[HPK] ^3Ping ^1checking ^4disabled ^1due to ^3immunity^1...")
		return PLUGIN_CONTINUE
	}
	new p, l
	get_user_ping(id, p, l)
	if (p > HIGHPING_MAX)
		++iNumTests[id]
	else
		if (iNumTests[id] > 0) --iNumTests[id]
	if (iNumTests[id] > HIGHPING_TESTS)
		kickPlayer(id)
	return PLUGIN_CONTINUE
}

public showWarn(param[]) {
	ColorMessage(param[0], "^4[HPK] ^3Players ^1with ping ^4higher ^1than^3 %dms ^1will be ^3kicked!", HIGHPING_MAX)
	set_task(float(HIGHPING_TIME), "checkPing", param[0], param, 1, "b")
	return PLUGIN_CONTINUE
}



/*START - ColorChat */
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
/*END - ColorChat */