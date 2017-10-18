#include <amxmodx>
#include <amxmisc>

#pragma semicolon 1

#define FILENAME "crashRestore.txt"

new g_crashRestoreFile[64];

public plugin_init() 
{
	register_plugin("crashRestoration", "0.1", "MaximusBrood");
	
	new currentMapname[32];
	get_mapname(currentMapname, 31);
	
	get_configsdir(g_crashRestoreFile, 63);
	format(g_crashRestoreFile, 63, "%s/%s", g_crashRestoreFile, FILENAME);
	
	//Just check if there still is a file availible
	//If there is, we have proof the server crashed
	if(file_exists(g_crashRestoreFile))
	{
		//Read the file
		new crashRestoreFilePointerRead = fopen(g_crashRestoreFile, "rt");
		
		if(crashRestoreFilePointerRead)
		{
			new mapname[32];
			fgets(crashRestoreFilePointerRead, mapname, 31);
			
			//We don't need it anymore, so delete the file
			delete_file(g_crashRestoreFile);
			
			//If it is a valid map and not the current one, mapchange to it
			if(is_map_valid(mapname) && !equali(currentMapname, mapname) )
			{
				log_amx("Crash has been detected! (%s was previous map)", mapname);
				server_cmd("amx_map %s", mapname);
				server_exec();
			}
			
			//Closing up
			fclose(crashRestoreFilePointerRead);
		}
	}
	
	//Lets make a new file with the current mapname in it
	//We already made sure the file is deleted
	new crashRestoreFilePointerWrite = fopen(g_crashRestoreFile, "wt");
	
	if(crashRestoreFilePointerWrite)
	{
		fprintf(crashRestoreFilePointerWrite, "%s", currentMapname);
		
		fclose(crashRestoreFilePointerWrite);
	}
}

public plugin_end()
{
	//We've reached the end without crashes
	//Lets delete the crash restoration file
	if(file_exists(g_crashRestoreFile))
		delete_file(g_crashRestoreFile);
		
	return PLUGIN_HANDLED;
}

/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ ansicpg1251\\ deff0\\ deflang1026{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ f0\\ fs16 \n\\ par }
*/
