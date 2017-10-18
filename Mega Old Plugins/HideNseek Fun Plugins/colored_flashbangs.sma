#include <amxmodx>

new g_nMsgScreenFade

public plugin_init()
{
	register_plugin("Colored Flashbangs","1.0","v3x")
	register_event("ScreenFade","FlashedEvent","be","4=255","5=255","6=255","7>199")
	g_nMsgScreenFade = get_user_msgid("ScreenFade")
}

public FlashedEvent( id )
{
	new iRed,iGreen,iBlue

	iRed =   random_num(0,255)
	iGreen = random_num(0,255)
	iBlue =  random_num(0,255)

	message_begin( MSG_ONE,g_nMsgScreenFade,{0,0,0},id )
	write_short( read_data( 1 ) )	// Duration
	write_short( read_data( 2 ) )	// Hold time
	write_short( read_data( 3 ) )	// Fade type
	write_byte ( iRed )		// Red
	write_byte ( iGreen )		// Green
	write_byte ( iBlue )		// Blue
	write_byte ( read_data( 7 ) )	// Alpha
	message_end()

	return PLUGIN_HANDLED
}