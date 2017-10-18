#include <amxmodx>
#include <colorchat>

new const Version[] = "1.0"

public plugin_init()
{
    register_plugin("Admin Rules", Version, "Dark Boy :D -- html by advanced")
    
    register_clcmd("say /adminrules", "open_admin_rules")
}

public open_admin_rules(id)
{
    if(get_user_flags(id) & ADMIN_IMMUNITY)
    {
        show_motd(id, "addons/amxmodx/configs/adminrules.txt")
    }
    else
    {
        ColorChat(id, RED, "^x04This^x03 command^x01 is^x04 only^x01 for^x03 Admins!")
    }
}