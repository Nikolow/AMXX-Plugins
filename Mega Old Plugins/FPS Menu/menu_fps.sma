#include <amxmodx> 
#include <fakemeta>

#define PLG_VERSION "1.2"

new FPS = 0;
new Float:NC = 0.0;

new Float:g_nc[33] = 0.0;

new LASTFPS;
new textovariable;

new Pcvar[5];

new g_fps[33];
new g_lastfps[33];
new g_average[10];

public plugin_init()
{ 
    register_plugin("FPS & Ping Status", PLG_VERSION ,"adv")
    
    register_forward(FM_StartFrame,"ForwardStartFrame")
    register_forward(FM_PlayerPreThink,"PreThink")
    
    register_concmd( "say /fps", "infomenu" );
    
    register_cvar("amx_statusinfo_version", PLG_VERSION, FCVAR_SERVER | FCVAR_SPONLY );
    
    Pcvar[0] = register_cvar("amx_statusinfo", "1");
    Pcvar[1] = register_cvar("amx_statusinfo_msg", "1");
    Pcvar[2] = register_cvar("amx_statusinfo_interval", "120.0");
    
    textovariable = get_user_msgid("SayText");
    set_task(60.0, "msglala");
}

public client_putinserver(id)
    g_nc[id] = get_gametime();
    
public client_disconnect(id)
    remove_task(id);

public ForwardStartFrame()
{
    new Float:HLT = get_gametime();
    if(NC >= HLT)
    {
        FPS++;
    }
    else
    {
        NC = NC + 1;
        LASTFPS = FPS;
        new rand = random_num(0,9);
        g_average[rand] = FPS;
        FPS = 0;
    }
}

public PreThink(id) 
{
    new Float:HLT = get_gametime();
    if( g_nc[id] >= HLT)
    {
        g_fps[id]++;
    }
    else
    {
        g_nc[id] = g_nc[id] + 1.0;
        g_lastfps[id] = g_fps[id];
        g_fps[id] = 0;
    }
}

GetAverage()
{    
    new Average;
    
    for(new i = 0; i < 10; i++)
    {
        new calculo = g_average[i];
        Average += calculo;
    }
    
    return Average / 10;
}

GetPing()
{
    new Playersnum,Players[32],Player,Count,Ping,Loss,Average;
    get_players(Players,Playersnum,"ch");
    
    if( Playersnum < 1 )
        return 0;
        
    for(Count = 0; Count < Playersnum; Count++)
    {
        Player = Players[Count];
        get_user_ping(Player,Ping,Loss);
        Average += Ping;
    }
    
    return Average / Playersnum;
}

GetFps()
{
    new Playersnum,Players[32],Player,Count, Average;
    get_players(Players,Playersnum,"ch");
    
    if( Playersnum < 1 )
        return 0;
    
    for(Count = 0; Count < Playersnum; Count++)
    {
        Player = Players[Count];
        Average += g_lastfps[Player];
    }
    
    return Average / Playersnum;
}

public msglala()
{
    set_task(get_pcvar_float(Pcvar[2]), "msglala")
    
    if( get_pcvar_num(Pcvar[0]) != 1 )
        return;
    
    if( get_pcvar_num(Pcvar[1]) != 1 )
        return;
    
    for( new i = 1; i <= 32 ; i++)
    {
        if( is_user_connected(i) && !is_user_bot(i) )
            print(i,"^x04Say ^x01in^x04 chat ^x03/fps,^x01 to view all ^x03Players ^x04info")
    }
}

public infomenu(id)
{
    if( get_pcvar_num(Pcvar[0]) != 1 )
        return;

    new msgtitulo[64];
    formatex(msgtitulo, 63, "\rFPS \yand \rPing \yViewer - \wAverage: \y%i", LASTFPS, GetAverage());
    new menu = menu_create(msgtitulo, "menuinfo");
    new contador = 0;
    
    for( new i = 1; i <= 32; i++)
    {
        if( is_user_connected(i) && !is_user_bot(i) )
        {
            contador++;
            new msg[128], name[32], numero[5], ping, loss;
            get_user_name(i, name, 31);
            get_user_ping(i, ping, loss);
            formatex(msg, 127, "\y%s \wwith \y%i \rFPS \wand \y%i \rPing", name, g_lastfps[i], ping );
            num_to_str(contador, numero, 4);
            menu_additem(menu, msg, numero, 0);
        }
    }
    
    menu_display(id, menu, 0);
    set_task(1.0, "infomenu", id, _, _, "b");
}

public menuinfo(id, menu, item)
{
    if(item == MENU_EXIT)
    {
        remove_task(id);
        return PLUGIN_HANDLED;
    }
    
    return 0;
}

print(id, const msg[], {Float,Sql,Result,_}:...)
{
    new message[192];
    vformat(message, 191, msg, 3);
    
    message_begin(MSG_ONE_UNRELIABLE, textovariable, _, id);
    write_byte(id);
    write_string(message);
    message_end();
}