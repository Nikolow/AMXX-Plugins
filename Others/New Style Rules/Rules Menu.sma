/*

	Прост rules плъгин, с който при влизане затъмнява екрана на играча и му изкарва меню, 
	с което трябва да избере дали се съгласява с правилата.
	Има готов HTML код на правилата в rules.txt

*/

#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <engine>
#include <colorchat>

#define PLUGIN	"Agreement"
#define AUTHOR	"dejan"
#define VERSION	"1.0"

//#define Website "this EasyBlock server"

new bool:array[33];
new g_msgFade;

public plugin_init()
{
	register_plugin( "Agreement", VERSION, "dejan" )
	register_clcmd("say /rules","server_rules")
	register_clcmd("say rules","server_rules")
	register_clcmd("say !rules","server_rules")
	
	register_logevent( "EventJoinTeam", 3, "1=joined team" );
	
	g_msgFade = get_user_msgid("ScreenFade");
}

public client_disconnect(id)
{
	array[id] = false;
}

public EventJoinTeam()
{
	new iPlayer = GetLoguserIndex();
	
	if(!array[iPlayer])
	{
		set_task(3.0, "ScreenFadeIn", iPlayer)
		set_task(3.0, "mmenu", iPlayer)
	}
}

GetLoguserIndex()
{
    new szArg[61];
    read_logargv(0,szArg, charsmax(szArg));
    
    new szName[32];
    parse_loguser(szArg, szName, charsmax(szName));
    
    return get_user_index(szName);
}

public server_rules(id)
{
	show_motd(id, "addons/amxmodx/configs/rules.txt", "xD-GaminG 2 Server Rules");
}

public mmenu(id)
{
	new Temp[101]
	formatex(Temp,100, "xD-GaminG 2 Server Rules")
	new menu = menu_create(Temp, "smenu");
	menu_additem(menu, "\wI Agree", "1", 0);
	menu_additem(menu, "\rI Disagree", "2", 0);
	menu_addblank(menu, 0);
	menu_addblank(menu, 0);
	menu_additem(menu, "\yShow The Rules", "3", 0);
	menu_setprop(menu, MPROP_EXIT, MEXIT_NEVER);
	menu_display(id, menu, 0)
	
	//show_motd(id, "rules.txt", "Server Rules");
}  

public smenu(id, menu, item)
{
    if( item == MENU_EXIT )
    {
        menu_destroy( menu );
        return PLUGIN_HANDLED;
    }
    new data[6], iName[64];
    new access, callback;
    
    menu_item_getinfo( menu, item, access, data,5, iName, 63, callback );
    new key = str_to_num( data );
    switch( key )
    {
        case 1:
        {
			ScreenFadeOut(id)
			ColorChat(id, RED, "^x04Have^x03 Fun ^x01Playing On ^x03The ^x04Server^x01!")
			array[id] = true;
        }
        case 2:
        {
            server_cmd( "kick #%d", get_user_userid( id ) )
        }
        case 3:
        {
            mmenu(id)
            show_motd(id, "addons/amxmodx/configs/rules.txt", "xD-GaminG 2 Server Rules");
        }
    }  
    menu_destroy( menu );
    return PLUGIN_HANDLED;
}

public ScreenFadeIn(id) 
{
	message_begin(MSG_ONE, g_msgFade, {0,0,0}, id); 
	write_short( ~0 );
	write_short( ~0 );
	write_short( 1<<20 ); 
	write_byte( 0 );
	write_byte( 0 );
	write_byte( 0 );
	write_byte( 220 );
	message_end( );
	return PLUGIN_CONTINUE;
}

public ScreenFadeOut(id) 
{
	message_begin(MSG_ONE, g_msgFade, {0,0,0}, id); 
	write_short( 1<<12 );
	write_short( 1<<8 ); 
	write_short( 1<<1 ); 
	write_byte( 0 );
	write_byte( 0 );
	write_byte( 0 );
	write_byte( 128 );
	message_end( );
	return PLUGIN_CONTINUE;
}