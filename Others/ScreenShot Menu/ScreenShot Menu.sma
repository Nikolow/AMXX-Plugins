/*
	Название: Screen Shot Menu
	Автор: Bonaqua | DimaS
	Версия: 1.2
	
	Description:
	Данный плагин добовляет возможность делать снимок экрана на стороне клиента.
	
	Version:
	v1.0
	- Первый релиз
	
	v1.1
	- Исправлены ошибки
	
	v1.2
	- Добавлен вывод информации о том что администратор сделал скриншот игроку.
	- Наложен (вотемарк на скрин).
	- Добавлен Cvar amx_ssm_watermark
	- Добавлен Cvar amx_ssm_enabled
	- Добавлен Cvar amx_ssm_message
	- Добавлен Cvar amx_ssm_watermark_enabled
	- Добавлен вывод кваров в cfg файл.
	
	Created Screen Shot Menu by Bonaqua and DimaS for www.csgames.ru
	Web Help - www.csgames.ru
	
	Нашёл баг ? Сообщи нам на форум www.csgames.ru
*/

#include <amxmodx>
#include <fun>
#include <icolourchat>
#include <dhudmessage>

new const PLUGIN[]		= "Screen Shot Menu"
new const VERSION[]		= "1.2"
new const NAME[]		= "Bonaqua | DimaS"

new const FILE[]		= "ss_menu.cfg"			// Файл с настройками

new const OPEN_ACCESS	= ADMIN_IMMUNITY

const Float:HUD_MESSAGE_X = 0.01
const Float:HUD_MESSAGE_Y = 0.82
const Float:HUD_WATERMARK_X = -1.0
const Float:HUD_WATERMARK_Y = 0.88

new pcv_watermark_enabled
new pcv_watermark
new pcv_enable
new pcv_msg

public plugin_init()
{
	register_plugin( PLUGIN, VERSION, NAME )
	
	pcv_enable				= register_cvar("amx_ssm_enabled", "0")
	pcv_msg					= register_cvar("amx_ssm_message", "0")
	pcv_watermark_enabled	= register_cvar("amx_ssm_watermark_enabled", "0")
	pcv_watermark 			= register_cvar("amx_ssm_watermark", "")

	register_clcmd("ss_menu", "iScreenShotMenu")
	register_clcmd("say ss_menu", "iScreenShotMenu")
	register_clcmd("say /ss_menu", "iScreenShotMenu")
	register_clcmd("say_team ss_menu", "iScreenShotMenu")
	register_clcmd("say_team /ss_menu", "iScreenShotMenu")
}

public plugin_cfg()
{
	new ConfigsDir[64]
	get_localinfo("amxx_configsdir", ConfigsDir, charsmax(ConfigsDir))
	format(ConfigsDir, charsmax(ConfigsDir), "%s/%s", ConfigsDir, FILE)
	
	if (!file_exists(ConfigsDir))
	{
		server_print("==================================================================")
		server_print("File [%s] not found!", ConfigsDir)
		server_print("==================================================================")
		return;
	}
	server_cmd("exec ^"%s^"", ConfigsDir)
}

public iScreenShotMenu(id)
{
	if(!get_pcvar_num(pcv_enable))
	{
		ChatColor(id, "^4[%s]^1 Меню снятие скриншотов выключено!", PLUGIN)
		return false
	}
		
	if(get_user_flags(id) & OPEN_ACCESS)
	{
		
		new szLen[1024 char]
		formatex(szLen, charsmax(szLen), "\r[%s]\d Выбирайте игрока:", PLUGIN)
		new iMenu = menu_create(szLen, "menu_handler")

		new s_Players[32], i_Num, iPlayer
		new s_Name[32], s_Player[10]

		get_players(s_Players, i_Num)

		for (new i; i < i_Num; i++)
		{ 
			iPlayer = s_Players[i]

			get_user_name(iPlayer, s_Name, charsmax(s_Name))
			num_to_str(iPlayer, s_Player, charsmax(s_Player))

			menu_additem(iMenu, s_Name, s_Player, 0)
		}
		
		menu_display(id, iMenu, 0)
		return PLUGIN_HANDLED
	}
	else
	ChatColor(id, "^3[^4%s^3]^1 В доступе отказано!", PLUGIN)
	return PLUGIN_HANDLED
}
 
public menu_handler(id, menu, item)
{
	if (item == MENU_EXIT)
	{
		menu_destroy(menu)
		return PLUGIN_HANDLED
	}

	new s_Data[6], s_Name[64], i_Access, i_Callback
	menu_item_getinfo(menu, item, i_Access, s_Data, charsmax(s_Data), s_Name, charsmax(s_Name), i_Callback)
	new iPlayer = str_to_num(s_Data)
	
	if(!is_user_connected(iPlayer))
	{
		ChatColor(id, "^4[%s]^1 Игрок не подключён к серверу!", PLUGIN)
		iScreenShotMenu(id)

		return PLUGIN_HANDLED
	}
	
	iScreenShotMenu(id)
	
	iScreenShotMsg(iPlayer, id)
	
	set_task(0.3, "iScreenShotFunct", iPlayer)

	menu_destroy(menu)
	return PLUGIN_HANDLED
}

iScreenShotMsg(id, iPlayer)
{
	if(get_pcvar_num(pcv_msg))
	{
		new playername[128], adminname[128], times[32]
		
		get_user_name(id, playername, charsmax(playername))
		get_user_name(iPlayer, adminname, charsmax(adminname))
		
		get_time("%d.%m.%Y - %H:%M:%S", times, 31)
		
		set_hudmessage( 225, 225, 225, HUD_MESSAGE_X, HUD_MESSAGE_Y, 1, 1.0, 5.0 )
		show_hudmessage( id , "[%s]^nАдминистратор: %s^nСделал скриншот игроку: %s^nСкриншот был сделан: %s", PLUGIN , adminname, playername, times)
		
		log_to_file("addons\amxmodx\logs\ss_menu.log", "Администратор '%s' сделал скриншот игроку '%s'", adminname, playername)
	}
	
	if(get_pcvar_num(pcv_watermark_enabled))
	{
		new Watermark[32]
		get_pcvar_string(pcv_watermark, Watermark, 31)
		
		set_dhudmessage( 0, 225, 0, HUD_WATERMARK_X, HUD_WATERMARK_Y, 2, 1.0, 5.0 )
		show_dhudmessage( id , Watermark)
	}
}

public iScreenShotFunct(id)
{ 
	client_cmd(id, "snapshot")
}