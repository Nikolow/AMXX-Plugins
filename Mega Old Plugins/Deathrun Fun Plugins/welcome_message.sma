#include <amxmodx>

new const VERSION[] = "1.0"

public plugin_init()
{
    register_plugin("Hud Message", VERSION, "Dark_Style")
}

public client_putinserver(id)
{
    set_task(19.0, "hud_msg", id)
}

public hud_msg(id)
{
    if(is_user_alive(id))
    {
        set_hudmessage(178, 34, 34, -1.0, -0.43, 2, 0.3, 7.0)
        show_hudmessage(id, "Dobre doshal v sarvara na smar7y ^n^n * Za da stava meleto vikaite priqteli ^n * Sarvara e zashtiten ot vsichki nejelani i nepozvoleni sredstva ^n * Imame dobar ekip ^n * Sashto moje da stanete Admin ^n *^n^n Za vrazka skype strangezz * ^n^n Plugin edit by smar7y")
    }
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1026\\ f0\\ fs16 \n\\ par }
*/
