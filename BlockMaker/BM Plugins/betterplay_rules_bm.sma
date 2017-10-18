/*

	/rules плъгин, с който при написване на командата излиза MOTD екран с правила.
	Правилата са прост HTML и лесно се редактират при вече готов код от Smiley.

*/

#include < amxmodx >
#include < colorchat >

#define TASK_DELAY		6.0
#define MESSAGE_TIME		60.0

#define PREFIX			"[BetterPlay]"
new const g_szServerRules[ ] = 	"Blockmaker Rules";

public plugin_init( )
{
	register_plugin( "BetterPlay Rules", "1.0", "Smiley" );
	
	register_clcmd( "say /rules", "cmdShowRules" );
	register_clcmd( "say_team /rules", "cmdShowRules" );
	
	set_task( MESSAGE_TIME, "TaskAdvertMessage", _, _, _, "b" );
}

public client_putinserver( id )
{
	set_task( TASK_DELAY, "TaskRules", id );
}

public TaskRules( id )
{
	if( is_user_connected( id ) && !is_user_alive( id ) )
	{
		cmdShowRules( id );
	}
}

public cmdShowRules( id )
{
	// HTML Code by Smiley
	static motd[ 2500 ];
	
	new len = formatex( motd, sizeof( motd ) - 1, 		"<body bgcolor=black text=#DCDCDC>" );
	len += formatex( motd[ len ], sizeof( motd ) - len - 1,	"<center>" );
	
	len += formatex( motd[ len ], sizeof( motd ) - len - 1,	"<ul> </br><b><font color=#B0C4DE size=+3>BetterPlay.info</font> <font color=FAAFBE size=+3>%s</font></b></br></br>", g_szServerRules );
	len += formatex( motd[ len ], sizeof( motd ) - len - 1,	"<b><font color=B0C4DE>1.</font> Swearing/Advertising/Spam <font color=FAAFBE>is not allowed!</font> (Punishment: Gag or ban for 3 hours.)</b> </br>" );
	len += formatex( motd[ len ], sizeof( motd ) - len - 1,	"<b><font color=B0C4DE>2.</font> FunJumping <font color=FAAFBE>is not allowed!</font> (Punishment: Slay or ban for 3 hours.)</b> </br>" );
	len += formatex( motd[ len ], sizeof( motd ) - len - 1,	"<b><font color=B0C4DE>3.</font> Camping at teleports <font color=FAAFBE>is not allowed!</font> (Punishment: Ban for 3 hours.)</b> </br>" );
	len += formatex( motd[ len ], sizeof( motd ) - len - 1,	"<b><font color=B0C4DE>4.</font> Camping more than 15 seconds <font color=FAAFBE>is not allowed!</font> (Punishment: Slay or ban for 3 hours.)</b> </br>" );
	len += formatex( motd[ len ], sizeof( motd ) - len - 1,	"<b><font color=B0C4DE>5.</font> Retry <font color=FAAFBE>is not allowed!</font> (Punishment: Ban for 1 day.)</b> </br>" );
	len += formatex( motd[ len ], sizeof( motd ) - len - 1,	"<b><font color=B0C4DE>6.</font> Stab/Understab <font color=FAAFBE>is not allowed!</font> (Punishment: Slay or ban for 3 hours.)</b> </br>" );
	len += formatex( motd[ len ], sizeof( motd ) - len - 1,	"<b><font color=B0C4DE>7.</font> Block/Underblock <font color=FAAFBE>is not allowed!</font> (Punishment: Ban for 3 hours.)</b> </br>" );
	len += formatex( motd[ len ], sizeof( motd ) - len - 1,	"<b><font color=B0C4DE>8.</font> Boosting <font color=FAAFBE>is not allowed!</font> (Punishment: Slay or ban for 3 hours.)</b> </br>" );
	len += formatex( motd[ len ], sizeof( motd ) - len - 1,	"<b><font color=B0C4DE>9.</font> Killing AFK Players <font color=FAAFBE>is not allowed!</font> (Punishment: Slay or ban for 3 hours.)</b> </br>" );
	
	len += formatex( motd[ len ], sizeof( motd ) - len - 1,	"</center>" );

	show_motd( id, motd, "BetterPlay.info Rules" );
}

public TaskAdvertMessage( )
{
	for( new id = 1; id <= 32; id++ )
	{
		if( is_user_connected( id ) )
		{
			ColorChat( id, RED, "^4%s^3 Type^4 /rules^1 to view^3 Server Rules^1.", PREFIX );
		}
	}
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1026\\ f0\\ fs16 \n\\ par }
*/
