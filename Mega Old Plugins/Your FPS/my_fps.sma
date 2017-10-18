#include <amxmodx>
#include <engine>

new g_count[33]
new g_fps[33]

public plugin_init() {
    register_plugin("Get FPS", "1.0", "Advanced")
    register_clcmd("say /fps","get_fps")
    register_clcmd("say fps","get_fps")
    register_clcmd("say_team /fps","get_fps")
    register_clcmd("say_team fps","get_fps")
}

public get_fps(id)
{
    ColorMessage(id, "^1Your ^4FPS ^1is:^3 %i",g_fps[id])
    
    return PLUGIN_HANDLED;
}

public client_PostThink(id)
{
    g_count[id]++
    
    static lastendtime[33]
    // did second passed?
    if (floatround(get_gametime())==lastendtime[id]) return;
    
    lastendtime[id] = floatround(get_gametime())
    
    g_fps[id] = g_count[id]
    g_count[id] = 0
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