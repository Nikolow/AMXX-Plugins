#include <amxmodx>
#include <fakemeta>

#define PLUGIN_NAME "No Name Change"
#define PLUGIN_VERSION "0.1"
#define PLUGIN_AUTHOR "VEN"

new const g_reason[] = "[SlackServ.com] Sorry, name change isn't allowed on this server"

new const g_name[] = "name"

public plugin_init() {
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR)
	register_forward(FM_ClientUserInfoChanged, "fwClientUserInfoChanged")
}

public fwClientUserInfoChanged(id, buffer) {
	if (!is_user_connected(id))
		return FMRES_IGNORED

	static name[32], val[32]
	get_user_name(id, name, sizeof name - 1)
	engfunc(EngFunc_InfoKeyValue, buffer, g_name, val, sizeof val - 1)
	if (equal(val, name))
		return FMRES_IGNORED

	engfunc(EngFunc_SetClientKeyValue, id, buffer, g_name, name)
	console_print(id, "%s", g_reason)

	return FMRES_SUPERCEDE
}
