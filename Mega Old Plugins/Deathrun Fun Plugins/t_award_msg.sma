#include <amxmodx>

#define VERSION "1.0"

public plugin_init()
{
    register_plugin("Color Message", VERSION, "Dark_Style")
    
    register_logevent("new_round", 2, "1=Round_Start")
}

public new_round(id)
{
    set_task(5.0, "msg", id) // колко секунди след началото на рунда, да се покаже съобщението.. 
}

public msg(id)
{
    if(is_user_alive(id) && get_user_team(id) == 1)
    {
        ColorMessage(id, "^3[Deathrun] ^1You have^4 125 HP ^1 and ^4One He grenade !")
    }
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
 