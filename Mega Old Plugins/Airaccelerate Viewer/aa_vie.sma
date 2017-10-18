#include <amxmodx>

new const VERSION[] = "1.0"

public plugin_init()
{
    register_plugin("Show Airaccelerate", VERSION, "Dark_Style")
    
    register_clcmd("say /aa", "show_airaccelerate")
}

public show_airaccelerate(id)
{
    ColorMessage(id, "^1This ^4server ^1running with^3 %i ^4airaccelerate", get_cvar_num("sv_airaccelerate"))
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