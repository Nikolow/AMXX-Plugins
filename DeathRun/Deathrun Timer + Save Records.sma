#include <amxmodx>
#include <engine>
#include <hamsandwich>
#include <nvault>

new h_vault;

#define TaskID 3456
#define DeadID 3356
new sMap[35];
new HudObj, StatusText;
new TimerS[33] = 0; 
new iBest, sBest[64] = "";
new g_iMaxPlayers;

public plugin_init()
{
	register_plugin("DeathRun Timer + Save Records", "2.1", "Knopers");//Edited by (Owner123) and Nikolow;
	get_mapname(sMap, 34);
	
	RegisterHam(Ham_Spawn, "player", "EvSpawn", 1);
	RegisterHam(Ham_Killed, "player", "EvPlayerKilled", 1);
	register_logevent("eventResetTime", 2, "1=Round_Start");

	register_concmd("say /best", "ShowBest");
	
	HudObj = CreateHudSyncObj();
	StatusText = get_user_msgid("StatusText");
	
	h_vault = nvault_open("dr_records");
	LoadRecord();
	
	g_iMaxPlayers = get_maxplayers();
}

public plugin_end()
		nvault_close(h_vault);

public client_disconnect(id)
{
	if(task_exists(id + TaskID))
		remove_task(id + TaskID);

	if(task_exists(id + DeadID))
		remove_task(id + DeadID);
}

public EvSpawn(id)
{
	TimerS[id] = 0;
	
	if(task_exists(TaskID + id))
		remove_task(TaskID + id);
		
	if(task_exists(id + DeadID))
		remove_task(id + DeadID);
		
	if(get_user_team(id) == 2)
		Start(id);
}

public EvPlayerKilled(iVictim, iAttacker)
{
	if(task_exists(TaskID + iVictim))
		remove_task(TaskID + iVictim);
		
	set_task(1.0, "DeadTask", iVictim + DeadID, _, _, "b");
	
	if(get_user_team(iVictim) == 1 && get_user_team(iAttacker) == 2)
		Finish(iAttacker, iVictim);
}

public Start(id)
{
	TimerS[id] = 0;
	if(get_user_team(id) == 2)
	{
		if(task_exists(id + TaskID))
			remove_task(id + TaskID);
			
		fnShowTimer(id + TaskID);
		
		set_task(1.0, "fnShowTimer", id + TaskID, _, _, "b");
	}
}

public Finish(id, idTT)
{
	if(TimerS[id] <= 10 || !task_exists(TaskID + id))
		return PLUGIN_CONTINUE;
	
	if(idTT > 0 && idTT < 33)
	{
		remove_task(TaskID + id);
		new skName[32];
		get_user_name(id, skName, 31);
		new sMsg[128];
		format(sMsg, 127, "^x04 [ PREFIX ]^x03 %s^x01 finished the map in^x03 %02d:%02d", skName, TimerS[id] / 60, TimerS[id] % 60);
		ColorChat(0, sMsg);
		if(TimerS[id] < iBest || iBest < 1)
		{
			iBest = TimerS[id];
			sBest = skName;
			
			format(sMsg, 127, "^x04 [ PREFIX ]^x03 %s^x01 made a^x04 new record^x01 on the map. His time:^x03 %02d:%02d", skName, TimerS[id] / 60, TimerS[id] % 60);
			ColorChat(0, sMsg);
			
			replace_all(sBest, 63, "^"", "''");
			SaveRecord();
		}
		else
		{
			format(sMsg, 127, "^x04 [ PREFIX ]^x03 %s^x01 didn't beat the best record. Best Record is:^x03 %02d:%02d", skName, iBest / 60, iBest % 60);
			ColorChat(0, sMsg);
		}
	}
	else
	{
		remove_task(TaskID + id);
		new sName[32];
		get_user_name(id, sName, 31);
		new sMsg[128];
		format(sMsg, 127, "^x04 [ PREFIX ]^x03 %s^x01 finished the map in^x03 %02d:%02d", sName, TimerS[id] / 60, TimerS[id] % 60);
		ColorChat(0, sMsg);
		if(TimerS[id] < iBest || iBest < 1)
		{
			iBest = TimerS[id];
			sBest = sName;
			
			format(sMsg, 127, "^x04 [ PREFIX ]^x03 %s^x01 made a^x04 new record^x01 on the map. His time:^x03 %02d:%02d", sName, TimerS[id] / 60, TimerS[id] % 60);
			ColorChat(0, sMsg);
			
			replace_all(sBest, 63, "^"", "''");
			SaveRecord();
		}
		else
		{
			format(sMsg, 127, "^x04 [ PREFIX ]^x03 %s^x01 didn't beat the best record. Best Record is:^x03 %02d:%02d", sName, iBest / 60, iBest % 60);
			ColorChat(0, sMsg);
		}
	}
	return PLUGIN_CONTINUE;
}

public fnShowTimer(idTask)
{
	new id = idTask - TaskID;
	TimerS[id] ++;
	
	new sSMsg[32];
	format(sSMsg, 31, "Timer: %02d:%02d", TimerS[id] / 60, TimerS[id] % 60);
	message_begin(MSG_ONE, StatusText, {0,0,0}, id);
	write_byte(0);
	write_string(sSMsg);
	message_end();
}

public eventResetTime()
{
	for(new id = 1; id < g_iMaxPlayers; id++)
	{
		if(!is_user_connected(id) || !is_user_alive(id))
			continue;
		
		if(!task_exists(id + TaskID))
			continue;
		
		remove_task(id + TaskID);
		TimerS[id] = 0;
		set_task(1.0, "fnShowTimer", id + TaskID, _, _, "b");
	}
}

public ShowBest(id)
{
	new sMsg[128];
	
	if(!sBest[0])
		format(sMsg, 127, "^x04 [ PREFIX ]^x01 There is no record on this map.");
	else
		format(sMsg, 127, "^x04 [ PREFIX ]^x01 Map Record^x04 :^x03 %02d:%02d^x01 -^x04 %s", iBest / 60, iBest % 60, sBest);
	
	ColorChat(0, sMsg);
}
stock ColorChat(id, sMessage[])
{
	new SayText = get_user_msgid("SayText");
	if(id == 0)
	{
		for(new i = 1; i < 33; i++)
		{
			if(is_user_connected(i))
			{
				message_begin(MSG_ONE, SayText, { 0, 0, 0 }, i);
				write_byte(i);
				write_string(sMessage);
				message_end();
			}
		}
	}
	else
	{
		message_begin(MSG_ONE, SayText, { 0, 0, 0 }, id);
		write_byte(id);
		write_string(sMessage);
		message_end();
	}
}
public DeadTask(Spect)
{
	Spect -= DeadID;
	if(!is_user_connected(Spect) || is_user_alive(Spect))
	{
		remove_task(Spect + DeadID);
		return PLUGIN_CONTINUE;
	}
	new id = entity_get_int(Spect, EV_INT_iuser2);
	if(id <= 0 || id >= 33 || !is_user_alive(id))
		return PLUGIN_CONTINUE;
	new Name[32];
	get_user_name(id, Name, 31);
	
	set_hudmessage(255, 255, 255, -1.0, 0.2, 2, 0.05, 1.0, 0.1, 3.0, -1);
	ShowSyncHudMsg(Spect, HudObj, "%s^nPlayer time: %02d:%02d", Name, TimerS[id] / 60, TimerS[id] % 60);
	
	return PLUGIN_CONTINUE;
}

public SaveRecord()
{
	new sData[128];

	format(sData, 127,"^"%s^" ^"%02d^"", sBest, iBest);
	nvault_set(h_vault, sMap, sData);
	
	return PLUGIN_CONTINUE
}

public LoadRecord()
{
	new sData[128];
 
	format(sData, 127,"^"%s^" ^"%02d^"", sBest, iBest);
	nvault_get(h_vault, sMap, sData, 127);
	
	new RecordName[64], RecordS[3];
	parse(sData, RecordName, 63, RecordS, 2);
	
	sBest = RecordName;
	iBest = str_to_num(RecordS);
	
	return PLUGIN_CONTINUE;
}  