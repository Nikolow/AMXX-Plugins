#include <amxmodx>
#include <amxmisc>

new const hud_messages[][] = 
{       
	"Server IP: 79.124.*****",
	"Head Admin skype: *****",
	"Add Server In Your Favorites, IP ADRESS: 79.124.****",
	"Stani ADMIN Skype: ******", 
	"Add Server In Your Favorites, IP ADRESS: 79.124.****",
	"Stani VIP Skype: *****"
};

public plugin_init()
 {
	register_plugin( "Message Hud", "1.0", "niki?" );
	
	set_task( 20.0, "RandomHudWithRandomColors", 0, "", 0, "b"  );
}

public RandomHudWithRandomColors()
{
	         set_hudmessage( random_num( 0, 255 ), random_num( 0, 255 ), random_num( 0, 255), -1.0, 0.03, random(3), 6.0, 8.0 );  
	         show_hudmessage( 0, "%s",hud_messages[ random_num( 0, charsmax( hud_messages ) ) ] );  
	
}
