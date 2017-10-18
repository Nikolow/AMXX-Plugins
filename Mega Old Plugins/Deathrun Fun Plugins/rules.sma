#include <amxmodx>

#define VERSION "1.0"

public plugin_init()
{
    register_plugin("Rules", VERSION, "Dark_Style");
    
    register_clcmd("say /rules", "open_hud_message");
    register_clcmd("say_team /rules", "open_hud_message");
}

public client_putinserver(id)
{
    if(is_user_connected(id))
    {
	set_task(7.0, "open_hud_message", id);
    }
    if(is_user_connected(id))
    {
	set_task(25.0, "open_hud_message1", id);
    }
}

public open_hud_message(id)
{
	if(is_user_alive(id)) 
	{
	set_hudmessage(255, 215, 0, -1.0, -0.60, 2, 3.0, 4.5)
	show_hudmessage(id, "Rules^n^n [Deathmach] Anonymous Gaming^n Server Hosted by smar7y^n Don't using ,NO-FLASH, kzh, Scripts, SlowMo etc. -->[kick/ban]^n Bugging -->[slay]^n Advertising is NOT allowed -->[kick/ban]^n Respect all admins / players! --->[slay]^n Swearing is NOT allowed -->[kick/ban]^n Die if you FALL down -->[slay]^n Don't insult admins/players! -->[slay/kick]^n If you break any rules --> Look Reasons ");
	}
}

public open_hud_message1(id)
{
	if(is_user_alive(id)) 
	{
	set_hudmessage(255, 215, 0, -1.0, -0.60, 2, 3.0, 4.5)
	show_hudmessage(id, "Dobre doshal v sarvara na smar7y ^n^n * Za da stava meleto vikaite priqteli ^n * Sarvara e zashtiten ot hakeri i vsqkakav vid pomoshtni sredstva ^n * Imame dobar ekip ^n * Sashto moje da stanete Sms-Admin ^n *^n^n Za vrazka skype strangezz * ^n^n Plugin edit by smar7y")
	}
}