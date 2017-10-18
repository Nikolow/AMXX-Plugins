#include <amxmodx>

new const Version[] =    "0.0.1"

public plugin_init()
{
    register_plugin("Requires accept question", Version, "Advanced")
}

public client_putinserver(id)
{
    set_task(20.0, "anti_dev", id)
}

public anti_dev(id)
{
    if(is_user_connected(id))
    {
        new menu = menu_create("\yThis server requires:^n\d- \rdeveloper 0^n\d- \rfps_max 101^n\d- \rcl_forwardspeed 400^n\d- \rcl_sidespeed 400^n\d- \rcl_backspeed 400^n^n\yDo you accept this?", "menu_handler")
        
        menu_additem(menu, "Yes", "1", 0)
        menu_additem(menu, "No \r[ \wYou will be kicked! \r]", "2", 0)
        
        menu_display(id, menu, 0)
    }
}

public menu_handler(id, menu, item)
{
    if(is_user_connected(id))
    {
        if(item == MENU_EXIT)
        {
            anti_dev(id)
        }
        
        new data[6], iName[64], access, callback
        menu_item_getinfo(menu, item, access, data,5, iName, 63, callback)
        
        new key = str_to_num(data)
        
        switch(key)
        {
            case 1:
            {
                client_cmd(id, "developer 0; alias developer")
                client_cmd(id, "fps_max 101; alias fps_max")
                client_cmd(id, "cl_sidespeed 400; alias cl_sidespeed")
                client_cmd(id, "cl_forwardspeed 400; alias cl_forwardspeed")
                client_cmd(id, "cl_backspeed 400; alias cl_backspeed")
            }
            case 2:
            {
                client_cmd(id, "disconnect")
            }
        }
    }
    menu_destroy(menu)
    return PLUGIN_HANDLED
} 