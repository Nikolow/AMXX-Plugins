#include <amxmodx>
#include <hamsandwich>
#include <fun>

#define PLUGIN    "Skill"
#define AUTHOR    "Biscuit"
#define VERSION    "1.3"

#define SHOWMENU_TASK 2398271


new p_turbospeed,p_turbotime,p_godtime,p_lowgravtime,p_lowgrav,p_norgrav,p_Rechargetime,p_invistime,p_invis
new Delay[33],userpower[33]
new bool:godmode[33]
new bool:turbo[33]
new bool:lowgrav[33]
new bool:invisiblity[33]
new bool:usedelay[33]
new g_iCurTeam[ 33 ] = { 'U' , ... };

new Float:oldspeed[33]

public plugin_init()
{
    register_plugin(PLUGIN,VERSION,AUTHOR)
    
    //Event
    register_event("CurWeapon","weapon_change","be")
    register_event( "TeamInfo" , "fw_EvTeamInfo" , "a" );
    RegisterHam( Ham_ObjectCaps , "player", "Forward_ObjectCaps" )
    
    //Cvar
    p_turbospeed = register_cvar("CVAR_turbospeed","600")
    p_invis = register_cvar("CVAR_invis","15")
    p_lowgrav = register_cvar("CVAR_lowgrav","400")
    p_turbotime = register_cvar("CVAR_turbotime","15")
    p_godtime = register_cvar("CVAR_godmodetime","13")
    p_lowgravtime = register_cvar("CVAR_lowgravtime","13")
    p_invistime = register_cvar("CVAR_invistime","13")
    p_Rechargetime = register_cvar("CVAR_Rechargetime","10")
    
    
    //pointer
    p_norgrav = get_cvar_pointer("sv_gravity")
}


public fw_EvTeamInfo( )
{
    static id; id = read_data( 1 );
    static szTeam[ 2 ]; read_data( 2 , szTeam , 1 );
    
    if ( g_iCurTeam[ id ] != szTeam[ 0 ] )
    {
        //Change team occurred
        userpower[id] = 0
        g_iCurTeam[ id ] = szTeam[ 0 ];
        
        if(!task_exists(id+SHOWMENU_TASK))
            set_task(10.0,"Showmenu",id+SHOWMENU_TASK,_,_,"b")
    }
}  


public Forward_ObjectCaps(id)
{
    if (!is_user_connected(id) || !is_user_alive(id) || usedelay[id])
        return PLUGIN_CONTINUE
    
    else if(godmode[id] || turbo[id] || lowgrav[id] || invisiblity[id])
    {
        client_print(id,print_center,"Your power is not finish")
        return PLUGIN_HANDLED
    }
    else if(Delay[id])
    {
        client_print(id,print_center,"You need to wait %d secs to use your power again",Delay[id])
        return PLUGIN_HANDLED
    }
    else if(!userpower[id])
        client_print(id,print_center,"You need to select your power")
    
    set_power(id)
    usedelay[id] = true
    set_task(1.0,"removeusedelay",id)
    
    return PLUGIN_CONTINUE
}
public removeusedelay(id) usedelay[id] = false

public client_putinserver(id)
{
    userpower[id] = 0
    godmode[id] = false
    turbo[id] = false
    lowgrav[id] = false
    invisiblity[id] = false
    usedelay[id] = false
    if(!task_exists(id+SHOWMENU_TASK))
        set_task(10.0,"Showmenu",id+SHOWMENU_TASK,_,_,"b")
}

public client_disconnect(id)
{
    remove_task(id)
    remove_task(id+SHOWMENU_TASK)
}

public Showmenu(taskid)
{
    new id = taskid - SHOWMENU_TASK
    if(userpower[id])
    {
        remove_task(id+SHOWMENU_TASK)
        return PLUGIN_HANDLED
    }
    
    switch(get_user_team(id))
    {
        case 1:
        {
            new menu = menu_create("\rChoose one of the T skills:", "menu_handler");
            menu_additem(menu, "\wTurbo Speed", "1", 0)
            menu_additem(menu, "\wInvisiblity", "2", 0)
            menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
            menu_display(id, menu, 0)
        }
        case 2:
        {
            new menu = menu_create("\rChoose one of the CT skills:", "menu_handler");
            menu_additem(menu, "\wgodmode", "1", 0)
            menu_additem(menu, "\wlow gravity", "2", 0)
            menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
            menu_display(id, menu, 0)            
        }
    }
    return PLUGIN_CONTINUE
}

public menu_handler(id, menu, item)
{
    
    if( item == MENU_EXIT )
    {
        menu_destroy(menu);
        return PLUGIN_HANDLED;
    }
    
    new data[6], iName[64];
    new access, callback;
    
    menu_item_getinfo(menu, item, access, data,5, iName, 63, callback);
    new key = str_to_num(data);
    
    switch(get_user_team(id))
    {
        case 1:    //Ts team
        {
            switch(key)
            {
                case 1: userpower[id] = 1
                case 2: userpower[id] = 2
            }
        }
        case 2:
        {
            switch(key)
            {
                case 1:    userpower[id] = 3
                case 2:    userpower[id] = 4
            }
        }
    }
    menu_destroy(menu);
    return PLUGIN_HANDLED;
} 


public set_power(id)
{
    switch(userpower[id])
    {
        case 1:
        {
            turbo[id] = true
            oldspeed[id] = get_user_maxspeed(id)
            set_user_maxspeed(id, get_pcvar_float(p_turbospeed))
            client_print(id,print_center,"You have %d seconds Turbo Speed!",get_pcvar_num(p_turbotime))
            client_cmd(id,"spk sound/ambience/carpalarm01.wav")
            set_task(get_pcvar_float(p_turbotime),"Removepower",id)
        }
        case 2:
        {
            invisiblity[id] = true
            set_user_rendering(id,kRenderFxGlowShell,0,0,0,kRenderTransAlpha,get_pcvar_num(p_invis))
            client_print(id,print_center,"You have %d seconds Invisiblity",get_pcvar_num(p_invistime))
            set_task(get_pcvar_float(p_invistime),"Removepower",id)
        }
        case 3:
        {
            godmode[id] = true
            set_user_godmode(id, 1)
            set_user_rendering(id,kRenderFxGlowShell,0,0,0,kRenderTransAlpha,255)
            client_print(id,print_center,"You have %d seconds Godmode!",get_pcvar_num(p_godtime))
            client_cmd(id,"spk sound/ambience/carpalarm01.wav")
            set_task(get_pcvar_float(p_godtime),"Removepower",id)
        }
        case 4:
        {
            lowgrav[id] = true
            set_user_gravity(id , get_pcvar_float(p_lowgrav) / 800)
            client_print(id,print_center,"You have %d seconds Low gravity!",get_pcvar_num(p_lowgravtime))
            set_task(get_pcvar_float(p_lowgravtime),"Removepower",id)
        }
    }
}
public weapon_change(id)
{
    if(turbo[id])
        set_user_maxspeed(id, get_pcvar_float(p_turbospeed))
    else if(lowgrav[id])
        set_user_gravity(id , get_pcvar_float(p_lowgrav) / 800)
}
public Removepower(id)
{
    switch(userpower[id])
    {
        case 1:
        {
            turbo[id] = false
            client_print(id,print_center,"Your Turbo Speed is over!!")
            set_user_maxspeed(id, oldspeed[id])
            Countdown(id)
        }
        case 2:
        {
            invisiblity[id] = false
            client_print(id,print_center,"Your invis is over")
            set_user_rendering(id,kRenderFxGlowShell,0,0,0,kRenderNormal,25)
        }
        case 3:
        {
            godmode[id] = false
            client_print(id,print_center,"Your godmode is over!")
            set_user_rendering(id,kRenderFxGlowShell,0,0,0,kRenderNormal,25)
            set_user_godmode(id, 0)
        }
        case 4:
        {
            lowgrav[id] = false
            client_print(id,print_center,"Your low gravity is over")
            set_user_gravity(id,get_pcvar_float(p_norgrav) / 800)
        }
    }
    Delay[id] = get_pcvar_num(p_Rechargetime)
    Countdown(id)
}

public Countdown(id)
{
    if(Delay[id] >0)
    {
        Delay[id]--
        set_task(1.0,"Countdown",id)
    }
}