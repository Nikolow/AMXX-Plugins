#include <amxmodx>
#include <zombieplague>
#include <zmvip>

new bool:haslaser[33] = false
new sprite, red, green , blue
new g_lsight
new g_iMaxPlayers

public plugin_init()
{
	register_plugin("[ZP] Extra Item: Laser Sight","1.0","fiendshard")
	register_event("HLTV", "event_round_start", "a", "1=0", "2=0") 
	g_lsight = zv_register_extra_item("Laser Sight (1 Round)", "Laser Sight", 10, ZP_TEAM_HUMAN)
	g_iMaxPlayers = get_maxplayers()
}

public plugin_precache() 
{
	sprite = precache_model("sprites/white.spr")
}

public client_putinserver(id)
{
	haslaser[id] = false
}

public client_disconnect(id)
{
	haslaser[id] = false
}

public zp_extra_item_selected(id, itemid)
{
	if (itemid == g_lsight)
		haslaser[id] = true
	red = 255
	green = 0
	blue = 0
	return PLUGIN_CONTINUE
}

public client_PreThink(id)
{	
	if(haslaser[id] == true)
	{
		new e[3]
		get_user_origin(id, e, 3)
		
		message_begin( MSG_BROADCAST,SVC_TEMPENTITY)
		write_byte (TE_BEAMENTPOINT)
		write_short(id | 0x1000)
		write_coord (e[0])		// Start X
		write_coord (e[1])		// Start Y
		write_coord (e[2])		// Start Z

		write_short(sprite)		// Sprite
		
		write_byte (1)      		// Start frame				
		write_byte (10)     		// Frame rate					
		write_byte (1)			// Life
		write_byte (5)   		// Line width				
		write_byte (0)    		// Noise
		write_byte (red) 		// Red
		write_byte (green)		// Green
		write_byte (blue)		// Blue
		write_byte (150)     		// Brightness					
		write_byte (25)      		// Scroll speed					
		message_end()
	}
	return PLUGIN_HANDLED
}

public hook_death(id)
{
	haslaser[id] = false
}

public zv_user_infected_post(id, infector)
{
	haslaser[id] = false
	return PLUGIN_CONTINUE
}

public event_round_start()
{
	for (new i = 1; i <= g_iMaxPlayers; i++)
	{
		if (!is_user_connected(i))
			continue
		if (haslaser[i])
		{
			haslaser[i] = false
		}
	}
}
