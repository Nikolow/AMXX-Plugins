#include <  amxmodx  >
#include <  cstrike  >


#pragma semicolon 1


#define PLUGIN "Delayed Furien TeamSwap"
#define VERSION "1.2b"

#define		SWITCH_TASK		112233

/*======================================= - ¦ Askhanar ¦ - =======================================*/


public plugin_init(    )
{
	register_plugin(  PLUGIN,  VERSION,  "Askhanar" );
	register_event( "SendAudio",  "ev_SendAudioCounterWin",  "a",  "1=0",  "2=%!MRAD_ctwin"  );
	
}

/*======================================= - ¦ Askhanar ¦ - =======================================*/

public ev_SendAudioCounterWin(    ) 
{
	
	new iPlayers[  32  ],  iNum;
	get_players(  iPlayers,  iNum,  "ch" );
	
	if(  iNum  ) 
	{
		new  id;
		
		for(  --iNum;  iNum  >=  0;  iNum--  ) 
		{
			id  =  iPlayers[  iNum  ];
			BeginDelayedTeamChange(  id  );
			
		}
	}
}

/*======================================= - ¦ Askhanar ¦ - =======================================*/

public BeginDelayedTeamChange(  id  )
{
	
	switch(  id  ) 
	{ 
		
		case  1..6:  set_task(  0.1, "ChangeUserTeamWithDelay",  id  +  SWITCH_TASK  ); 
		case  7..13:  set_task(  0.2, "ChangeUserTeamWithDelay",  id  +  SWITCH_TASK  ); 
		case  14..20:  set_task(  0.3, "ChangeUserTeamWithDelay",  id  +  SWITCH_TASK  ); 
		case  21..26:  set_task(  0.4, "ChangeUserTeamWithDelay",  id  +  SWITCH_TASK  ); 
		case  27..32:  set_task(  0.5, "ChangeUserTeamWithDelay",  id  +  SWITCH_TASK  ); 
	} 
}

/*======================================= - ¦ Askhanar ¦ - =======================================*/

public ChangeUserTeamWithDelay(  id  )
{
	
	id  -=  SWITCH_TASK;
	if(  !is_user_connected(  id  )  )  return 1;
	
	switch(  cs_get_user_team(  id  )   ) 
	{
		
		case  CS_TEAM_T:  cs_set_user_team(  id,  CS_TEAM_CT  );
		case  CS_TEAM_CT:cs_set_user_team(  id,  CS_TEAM_T  );
			
	}
	
	return 0;
}

/*======================================= - ¦ Askhanar ¦ - =======================================*/