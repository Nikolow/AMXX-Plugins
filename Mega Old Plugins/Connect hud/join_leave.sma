#include <amxmodx>

public plugin_init() {
  register_plugin("Join/Leave Message","1.2","BigBaller")
  register_cvar("amx_join_message", "%name% is connecting.")
  register_cvar("amx_joined_message", "%name% is ready to play!")
  register_cvar("amx_leave_message", "Goodbye %name%, Please come back soon.")
  register_cvar("amx_join_leave","1")
}

public client_connect(id){
	new user[32], len
	user[0] = id
	len = get_user_name(id,user[1],31)
	set_task(2.0, "join_msg", 0, user,len + 2)
	return PLUGIN_CONTINUE
}

public client_putinserver(id){
	new user[32], len
	user[0] = id
	len = get_user_name(id,user[1],31)
	set_task(2.0, "joined_msg", 0, user,len + 2)
	return PLUGIN_CONTINUE
}

public client_disconnect(id){
	new user[32], len
	user[0] = id
	len = get_user_name(id, user[1], 31)
	set_task(2.0, "leave_msg", 0, user, len + 2)
	return PLUGIN_CONTINUE
}

public join_msg(user[]) {
        if (get_cvar_num("amx_join_leave")==0){
        return PLUGIN_HANDLED
        }
	if (get_cvar_num("amx_join_leave")==1){
	new message[192]
	get_cvar_string("amx_join_message", message, 191)
	replace(message, 191, "%name%", user[1])
	set_hudmessage(random(255), random(255), random(255), 0.05, 0.45, 0, 6.0, 6.0, 0.5, 0.15, 3)
	show_hudmessage(0, message)
	return PLUGIN_CONTINUE
	}
	return PLUGIN_CONTINUE
}

public joined_msg(user[]) {
        if (get_cvar_num("amx_join_leave")==0){
        return PLUGIN_HANDLED
        }
	if (get_cvar_num("amx_join_leave")==1){
	new message[192]
	get_cvar_string("amx_joined_message", message, 191)
	replace(message, 191, "%name%", user[1])
	set_hudmessage(random(255), random(255), random(255), 0.05, 0.45, 0, 6.0, 6.0, 0.5, 0.15, 3)
	show_hudmessage(0, message)
	return PLUGIN_CONTINUE
	}
	return PLUGIN_CONTINUE
}

public leave_msg(user[]) {
        if (get_cvar_num("amx_join_leave")==0){
        return PLUGIN_HANDLED
        }
	if (get_cvar_num("amx_join_leave")==1){
	new message[192]
	get_cvar_string("amx_leave_message", message, 191)
	replace(message, 191, "%name%", user[1])
	set_hudmessage(random(255), random(255), random(255), 0.05, 0.45, 0, 6.0, 6.0, 0.5, 0.15, 3)
	show_hudmessage(0, message)
	return PLUGIN_CONTINUE
	}
	return PLUGIN_CONTINUE
}