#include <amxmodx>
#include <engine>
#include <fakemeta>
#include <dhudmessage>
#include <zombieplague>

//#define g_bDebug;

const g_iTaskCountdownID = 57;
const g_iTaskLightningID = 75;

new const g_szSoundsRoundStart[][] =
{
	""
}
const g_iSizeSoundsRoundStart = sizeof g_szSoundsRoundStart - 1;

new const g_szSoundsThunderRoundStart[][] =
{
	"TalRasha/countdown/thunder",
	"TalRasha/countdown/thunder2"
}
const g_iSizeSoundsThunderRoundStart = sizeof g_szSoundsThunderRoundStart - 1;

new const g_szLightsThunderClap1[][2] =
{
	"z"
}
const g_iSizeLightsThunderClap1 = sizeof g_szLightsThunderClap1 - 1;

new const g_szLightsThunderClap2[][2] =
{
	"z"
}
const g_iSizeLightsThunderClap2 = sizeof g_szLightsThunderClap2 - 1;

#define MESSAGE_SOUND	"TalRasha/countdown/player.wav"

new const g_szSoundsCountdown[][] =
{
	"TalRasha/countdown/one",						// 1
	"TalRasha/countdown/two",						// 2
	"TalRasha/countdown/three",						// 3
	"TalRasha/countdown/four",						// 4
	"TalRasha/countdown/five",						// 5
	"TalRasha/countdown/six",						// 6
	"TalRasha/countdown/seven",						// 7
	"TalRasha/countdown/eight",						// 8
	"TalRasha/countdown/nine",						// 9
	"TalRasha/countdown/ten",						// 10
	"",												// 11
	"TalRasha/countdown/NewRoundIn",				// 12
	"",												// 13
	"",												// 14 
	"TalRasha/countdown/You_are_attacking",			// 15
	"",												// 16
	"",												// 17
	"fvox/biohazard_detected",						// 18
	"",												// 19
	"TalRasha/countdown/20_seconds",				// 20
	"",												// 21
	"TalRasha/countdown/New_assault_in",			// 22
	"",												// 23
	"sound/TalRasha/countdown/start.mp3",			// 24
	"",												// 25
	"TalRasha/countdown/care_infection",			// 26
	"",												// 27
	"",												// 28
	"TalRasha/countdown/sirena",					// 29
	"TalRasha/countdown/30_seconds" 				// 30
}
const g_iSizeSoundsCountdown = sizeof g_szSoundsCountdown - 1;

new const g_szLightsCountdownLevels[][2] =
{
	"b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m"
}
const g_iSizeLightsCountdownLevels = sizeof g_szLightsCountdownLevels - 1;

new const g_szSoundsModeStart[][] =
{
	"TalRasha/countdown/start_infect",
	"TalRasha/countdown/start_infect2",
	"TalRasha/countdown/start_infect3"
}
const g_iSizeSoundsModeStart = sizeof g_szSoundsModeStart - 1;

new const g_szSoundsThunderModeStart[][] =
{
	"TalRasha/countdown/thunder",
	"TalRasha/countdown/thunder2"
}
const g_iSizeSoundsThunderModeStart = sizeof g_szSoundsThunderModeStart - 1;

new g_pCvarEffects, g_pCvarDelay, g_pCvarLighting, g_iDelay, g_szLighting[2], g_iSeconds;

public plugin_init()
{
	register_plugin("Countdown", "1.7.3", "T a l R a s h a")
	
	register_dictionary("gameplay_countdown.txt")
	
	register_event("HLTV", "event_round_start", "a", "1=0", "2=0")
	
	g_pCvarEffects = register_cvar("zpnm_countdown_effects", "1");
}

IsMp3(const szSound[])
	return equali(szSound[strlen(szSound) - 4], ".mp3");

public plugin_precache()
{
	new i, szSound[64], iPosition, iPositionTemp, szFolder[64];
	
	precache_sound("TalRasha/chat/player.wav")
	
	for (i = 0; i <= g_iSizeSoundsRoundStart; i++)
	{
		if (!g_szSoundsRoundStart[i][0])
			continue;
		
		if (IsMp3(g_szSoundsRoundStart[i]))
			engfunc(EngFunc_PrecacheGeneric, g_szSoundsRoundStart[i])
		else
		{
			// Doesn't contain any spaces
			if (containi(g_szSoundsRoundStart[i], " ") == -1)
			{
				formatex(szSound, 63, "%s.wav", g_szSoundsRoundStart[i])
				
				engfunc(EngFunc_PrecacheSound, szSound)
			}
			// Contains spaces
			else
			{
				iPosition = 0;
				
				while ((iPositionTemp = containi(g_szSoundsRoundStart[i][iPosition], "/")) != -1)
				{
					#if defined g_bDebug
					log_to_file("CountDown.log", "Scanning ^"%s^" for ^"/^" symbols.", g_szSoundsRoundStart[i][iPosition])
					#endif
					
					iPosition += iPositionTemp + 1;
					
					#if defined g_bDebug
					log_to_file("CountDown.log", "^"/^" symbol found at position %d: ^"%s^"", iPositionTemp, g_szSoundsRoundStart[i][iPosition - 1])
					log_to_file("CountDown.log", "Remaining directories and sounds found: ^"%s^"", g_szSoundsRoundStart[i][iPosition])
					log_to_file("CountDown.log", "")
					#endif
				}
				
				if (iPosition)
				{
					formatex(szFolder, 63, g_szSoundsRoundStart[i])
					replace(szFolder, 63, g_szSoundsRoundStart[i][iPosition], "")
				}
				
				#if defined g_bDebug
				log_to_file("CountDown.log", "Directory found: ^"%s^"", szFolder)
				log_to_file("CountDown.log", "Sounds found: ^"%s^"", g_szSoundsRoundStart[i][iPosition])
				log_to_file("CountDown.log", "")
				#endif
				
				while ((iPositionTemp = containi(g_szSoundsRoundStart[i][iPosition], " ")) != -1)
				{
					#if defined g_bDebug
					log_to_file("CountDown.log", "Scanning ^"%s^" for ^" ^" symbols.", g_szSoundsRoundStart[i][iPosition])
					#endif
					
					formatex(szSound, 63, g_szSoundsRoundStart[i][iPosition])
					
					iPosition += iPositionTemp;
					
					#if defined g_bDebug
					log_to_file("CountDown.log", "^" ^" symbol found at position %d: ^"%s^"", iPositionTemp, g_szSoundsRoundStart[i][iPosition])
					#endif
					
					replace(szSound, 63, g_szSoundsRoundStart[i][iPosition], "")
					
					#if defined g_bDebug
					log_to_file("CountDown.log", "Found sound: ^"%s^"", szSound)
					#endif
					
					format(szSound, 63, "%s%s.wav", szFolder, szSound)
					engfunc(EngFunc_PrecacheSound, szSound)
					
					#if defined g_bDebug
					log_to_file("CountDown.log", "Precaching sound: ^"%s^"", szSound)
					#endif
					
					iPosition += 1;
					
					#if defined g_bDebug
					log_to_file("CountDown.log", "Remaining sounds found: ^"%s^"", g_szSoundsRoundStart[i][iPosition])
					log_to_file("CountDown.log", "")
					#endif
				}
				
				formatex(szSound, 63, "%s%s.wav", szFolder, g_szSoundsRoundStart[i][iPosition])
				engfunc(EngFunc_PrecacheSound, szSound)
				
				#if defined g_bDebug
				log_to_file("CountDown.log", "Precaching sound: ^"%s^"", szSound)
				log_to_file("CountDown.log", "")
				#endif
			}
		}
	}
	
	for (i = 0; i <= g_iSizeSoundsThunderRoundStart; i++)
	{
		if (!g_szSoundsThunderRoundStart[i][0])
			continue;
		
		if (IsMp3(g_szSoundsThunderRoundStart[i]))
			engfunc(EngFunc_PrecacheGeneric, g_szSoundsThunderRoundStart[i])
		else
		{
			// Doesn't contain any spaces
			if (containi(g_szSoundsThunderRoundStart[i], " ") == -1)
			{
				formatex(szSound, 63, "%s.wav", g_szSoundsThunderRoundStart[i])
				
				engfunc(EngFunc_PrecacheSound, szSound)
			}
			// Contains spaces
			else
			{
				iPosition = 0;
				
				while ((iPositionTemp = containi(g_szSoundsThunderRoundStart[i][iPosition], "/")) != -1)
				{
					#if defined g_bDebug
					log_to_file("CountDown.log", "Scanning ^"%s^" for ^"/^" symbols.", g_szSoundsThunderRoundStart[i][iPosition])
					#endif
					
					iPosition += iPositionTemp + 1;
					
					#if defined g_bDebug
					log_to_file("CountDown.log", "^"/^" symbol found at position %d: ^"%s^"", iPositionTemp, g_szSoundsThunderRoundStart[i][iPosition - 1])
					log_to_file("CountDown.log", "Remaining directories and sounds found: ^"%s^"", g_szSoundsThunderRoundStart[i][iPosition])
					log_to_file("CountDown.log", "")
					#endif
				}
				
				if (iPosition)
				{
					formatex(szFolder, 63, g_szSoundsThunderRoundStart[i])
					replace(szFolder, 63, g_szSoundsThunderRoundStart[i][iPosition], "")
				}
				
				#if defined g_bDebug
				log_to_file("CountDown.log", "Directory found: ^"%s^"", szFolder)
				log_to_file("CountDown.log", "Sounds found: ^"%s^"", g_szSoundsThunderRoundStart[i][iPosition])
				log_to_file("CountDown.log", "")
				#endif
				
				while ((iPositionTemp = containi(g_szSoundsThunderRoundStart[i][iPosition], " ")) != -1)
				{
					#if defined g_bDebug
					log_to_file("CountDown.log", "Scanning ^"%s^" for ^" ^" symbols.", g_szSoundsThunderRoundStart[i][iPosition])
					#endif
					
					formatex(szSound, 63, g_szSoundsThunderRoundStart[i][iPosition])
					
					iPosition += iPositionTemp;
					
					#if defined g_bDebug
					log_to_file("CountDown.log", "^" ^" symbol found at position %d: ^"%s^"", iPositionTemp, g_szSoundsThunderRoundStart[i][iPosition])
					#endif
					
					replace(szSound, 63, g_szSoundsThunderRoundStart[i][iPosition], "")
					
					#if defined g_bDebug
					log_to_file("CountDown.log", "Found sound: ^"%s^"", szSound)
					#endif
					
					format(szSound, 63, "%s%s.wav", szFolder, szSound)
					engfunc(EngFunc_PrecacheSound, szSound)
					
					#if defined g_bDebug
					log_to_file("CountDown.log", "Precaching sound: ^"%s^"", szSound)
					#endif
					
					iPosition += 1;
					
					#if defined g_bDebug
					log_to_file("CountDown.log", "Remaining sounds found: ^"%s^"", g_szSoundsThunderRoundStart[i][iPosition])
					log_to_file("CountDown.log", "")
					#endif
				}
				
				formatex(szSound, 63, "%s%s.wav", szFolder, g_szSoundsThunderRoundStart[i][iPosition])
				engfunc(EngFunc_PrecacheSound, szSound)
				
				#if defined g_bDebug
				log_to_file("CountDown.log", "Precaching sound: ^"%s^"", szSound)
				log_to_file("CountDown.log", "")
				#endif
			}
		}
	}
	
	for (i = 0; i <= g_iSizeSoundsCountdown; i++)
	{
		if (!g_szSoundsCountdown[i][0])
			continue;
		
		if (IsMp3(g_szSoundsCountdown[i]))
			engfunc(EngFunc_PrecacheGeneric, g_szSoundsCountdown[i])
		else
		{
			// Doesn't contain any spaces
			if (containi(g_szSoundsCountdown[i], " ") == -1)
			{
				formatex(szSound, 63, "%s.wav", g_szSoundsCountdown[i])
				
				engfunc(EngFunc_PrecacheSound, szSound)
			}
			// Contains spaces
			else
			{
				iPosition = 0;
				
				while ((iPositionTemp = containi(g_szSoundsCountdown[i][iPosition], "/")) != -1)
				{
					#if defined g_bDebug
					log_to_file("CountDown.log", "Scanning ^"%s^" for ^"/^" symbols.", g_szSoundsCountdown[i][iPosition])
					#endif
					
					iPosition += iPositionTemp + 1;
					
					#if defined g_bDebug
					log_to_file("CountDown.log", "^"/^" symbol found at position %d: ^"%s^"", iPositionTemp, g_szSoundsCountdown[i][iPosition - 1])
					log_to_file("CountDown.log", "Remaining directories and sounds found: ^"%s^"", g_szSoundsCountdown[i][iPosition])
					log_to_file("CountDown.log", "")
					#endif
				}
				
				if (iPosition)
				{
					formatex(szFolder, 63, g_szSoundsCountdown[i])
					replace(szFolder, 63, g_szSoundsCountdown[i][iPosition], "")
				}
				
				#if defined g_bDebug
				log_to_file("CountDown.log", "Directory found: ^"%s^"", szFolder)
				log_to_file("CountDown.log", "Sounds found: ^"%s^"", g_szSoundsCountdown[i][iPosition])
				log_to_file("CountDown.log", "")
				#endif
				
				while ((iPositionTemp = containi(g_szSoundsCountdown[i][iPosition], " ")) != -1)
				{
					#if defined g_bDebug
					log_to_file("CountDown.log", "Scanning ^"%s^" for ^" ^" symbols.", g_szSoundsCountdown[i][iPosition])
					#endif
					
					formatex(szSound, 63, g_szSoundsCountdown[i][iPosition])
					
					iPosition += iPositionTemp;
					
					#if defined g_bDebug
					log_to_file("CountDown.log", "^" ^" symbol found at position %d: ^"%s^"", iPositionTemp, g_szSoundsCountdown[i][iPosition])
					#endif
					
					replace(szSound, 63, g_szSoundsCountdown[i][iPosition], "")
					
					#if defined g_bDebug
					log_to_file("CountDown.log", "Found sound: ^"%s^"", szSound)
					#endif
					
					format(szSound, 63, "%s%s.wav", szFolder, szSound)
					engfunc(EngFunc_PrecacheSound, szSound)
					
					#if defined g_bDebug
					log_to_file("CountDown.log", "Precaching sound: ^"%s^"", szSound)
					#endif
					
					iPosition += 1;
					
					#if defined g_bDebug
					log_to_file("CountDown.log", "Remaining sounds found: ^"%s^"", g_szSoundsCountdown[i][iPosition])
					log_to_file("CountDown.log", "")
					#endif
				}
				
				formatex(szSound, 63, "%s%s.wav", szFolder, g_szSoundsCountdown[i][iPosition])
				engfunc(EngFunc_PrecacheSound, szSound)
				
				#if defined g_bDebug
				log_to_file("CountDown.log", "Precaching sound: ^"%s^"", szSound)
				log_to_file("CountDown.log", "")
				#endif
			}
		}
	}
	
	for (i = 0; i <= g_iSizeSoundsModeStart; i++)
	{
		if (!g_szSoundsModeStart[i][0])
			continue;
		
		if (IsMp3(g_szSoundsModeStart[i]))
			engfunc(EngFunc_PrecacheGeneric, g_szSoundsModeStart[i])
		else
		{
			// Doesn't contain any spaces
			if (containi(g_szSoundsModeStart[i], " ") == -1)
			{
				formatex(szSound, 63, "%s.wav", g_szSoundsModeStart[i])
				
				engfunc(EngFunc_PrecacheSound, szSound)
			}
			// Contains spaces
			else
			{
				iPosition = 0;
				
				while ((iPositionTemp = containi(g_szSoundsModeStart[i][iPosition], "/")) != -1)
				{
					#if defined g_bDebug
					log_to_file("CountDown.log", "Scanning ^"%s^" for ^"/^" symbols.", g_szSoundsModeStart[i][iPosition])
					#endif
					
					iPosition += iPositionTemp + 1;
					
					#if defined g_bDebug
					log_to_file("CountDown.log", "^"/^" symbol found at position %d: ^"%s^"", iPositionTemp, g_szSoundsModeStart[i][iPosition - 1])
					log_to_file("CountDown.log", "Remaining directories and sounds found: ^"%s^"", g_szSoundsModeStart[i][iPosition])
					log_to_file("CountDown.log", "")
					#endif
				}
				
				if (iPosition)
				{
					formatex(szFolder, 63, g_szSoundsModeStart[i])
					replace(szFolder, 63, g_szSoundsModeStart[i][iPosition], "")
				}
				
				#if defined g_bDebug
				log_to_file("CountDown.log", "Directory found: ^"%s^"", szFolder)
				log_to_file("CountDown.log", "Sounds found: ^"%s^"", g_szSoundsModeStart[i][iPosition])
				log_to_file("CountDown.log", "")
				#endif
				
				while ((iPositionTemp = containi(g_szSoundsModeStart[i][iPosition], " ")) != -1)
				{
					#if defined g_bDebug
					log_to_file("CountDown.log", "Scanning ^"%s^" for ^" ^" symbols.", g_szSoundsModeStart[i][iPosition])
					#endif
					
					formatex(szSound, 63, g_szSoundsModeStart[i][iPosition])
					
					iPosition += iPositionTemp;
					
					#if defined g_bDebug
					log_to_file("CountDown.log", "^" ^" symbol found at position %d: ^"%s^"", iPositionTemp, g_szSoundsModeStart[i][iPosition])
					#endif
					
					replace(szSound, 63, g_szSoundsModeStart[i][iPosition], "")
					
					#if defined g_bDebug
					log_to_file("CountDown.log", "Found sound: ^"%s^"", szSound)
					#endif
					
					format(szSound, 63, "%s%s.wav", szFolder, szSound)
					engfunc(EngFunc_PrecacheSound, szSound)
					
					#if defined g_bDebug
					log_to_file("CountDown.log", "Precaching sound: ^"%s^"", szSound)
					#endif
					
					iPosition += 1;
					
					#if defined g_bDebug
					log_to_file("CountDown.log", "Remaining sounds found: ^"%s^"", g_szSoundsModeStart[i][iPosition])
					log_to_file("CountDown.log", "")
					#endif
				}
				
				formatex(szSound, 63, "%s%s.wav", szFolder, g_szSoundsModeStart[i][iPosition])
				engfunc(EngFunc_PrecacheSound, szSound)
				
				#if defined g_bDebug
				log_to_file("CountDown.log", "Precaching sound: ^"%s^"", szSound)
				log_to_file("CountDown.log", "")
				#endif
			}
		}
	}
	
	for (i = 0; i <= g_iSizeSoundsThunderModeStart; i++)
	{
		if (!g_szSoundsThunderModeStart[i][0])
			continue;
		
		if (IsMp3(g_szSoundsThunderModeStart[i]))
			engfunc(EngFunc_PrecacheGeneric, g_szSoundsThunderModeStart[i])
		else
		{
			// Doesn't contain any spaces
			if (containi(g_szSoundsThunderModeStart[i], " ") == -1)
			{
				formatex(szSound, 63, "%s.wav", g_szSoundsThunderModeStart[i])
				
				engfunc(EngFunc_PrecacheSound, szSound)
			}
			// Contains spaces
			else
			{
				iPosition = 0;
				
				while ((iPositionTemp = containi(g_szSoundsThunderModeStart[i][iPosition], "/")) != -1)
				{
					#if defined g_bDebug
					log_to_file("CountDown.log", "Scanning ^"%s^" for ^"/^" symbols.", g_szSoundsThunderModeStart[i][iPosition])
					#endif
					
					iPosition += iPositionTemp + 1;
					
					#if defined g_bDebug
					log_to_file("CountDown.log", "^"/^" symbol found at position %d: ^"%s^"", iPositionTemp, g_szSoundsThunderModeStart[i][iPosition - 1])
					log_to_file("CountDown.log", "Remaining directories and sounds found: ^"%s^"", g_szSoundsThunderModeStart[i][iPosition])
					log_to_file("CountDown.log", "")
					#endif
				}
				
				if (iPosition)
				{
					formatex(szFolder, 63, g_szSoundsThunderModeStart[i])
					replace(szFolder, 63, g_szSoundsThunderModeStart[i][iPosition], "")
				}
				
				#if defined g_bDebug
				log_to_file("CountDown.log", "Directory found: ^"%s^"", szFolder)
				log_to_file("CountDown.log", "Sounds found: ^"%s^"", g_szSoundsThunderModeStart[i][iPosition])
				log_to_file("CountDown.log", "")
				#endif
				
				while ((iPositionTemp = containi(g_szSoundsThunderModeStart[i][iPosition], " ")) != -1)
				{
					#if defined g_bDebug
					log_to_file("CountDown.log", "Scanning ^"%s^" for ^" ^" symbols.", g_szSoundsThunderModeStart[i][iPosition])
					#endif
					
					formatex(szSound, 63, g_szSoundsThunderModeStart[i][iPosition])
					
					iPosition += iPositionTemp;
					
					#if defined g_bDebug
					log_to_file("CountDown.log", "^" ^" symbol found at position %d: ^"%s^"", iPositionTemp, g_szSoundsThunderModeStart[i][iPosition])
					#endif
					
					replace(szSound, 63, g_szSoundsThunderModeStart[i][iPosition], "")
					
					#if defined g_bDebug
					log_to_file("CountDown.log", "Found sound: ^"%s^"", szSound)
					#endif
					
					format(szSound, 63, "%s%s.wav", szFolder, szSound)
					engfunc(EngFunc_PrecacheSound, szSound)
					
					#if defined g_bDebug
					log_to_file("CountDown.log", "Precaching sound: ^"%s^"", szSound)
					#endif
					
					iPosition += 1;
					
					#if defined g_bDebug
					log_to_file("CountDown.log", "Remaining sounds found: ^"%s^"", g_szSoundsThunderModeStart[i][iPosition])
					log_to_file("CountDown.log", "")
					#endif
				}
				
				formatex(szSound, 63, "%s%s.wav", szFolder, g_szSoundsThunderModeStart[i][iPosition])
				engfunc(EngFunc_PrecacheSound, szSound)
				
				#if defined g_bDebug
				log_to_file("CountDown.log", "Precaching sound: ^"%s^"", szSound)
				log_to_file("CountDown.log", "")
				#endif
			}
		}
	}
}

public plugin_cfg()
{
	g_pCvarDelay = get_cvar_pointer("zp_delay");
	g_pCvarLighting = get_cvar_pointer("zp_lighting");
}

public event_round_start(id)
{
	g_iDelay = get_pcvar_num(g_pCvarDelay) - 1;
	
	if (g_iDelay < 0)
		return;
	
	remove_task(g_iTaskCountdownID)
	remove_task(g_iTaskLightningID)
	
	if (g_szLighting[0])
	{
		engfunc(EngFunc_LightStyle, 0, g_szLighting)
		set_pcvar_string(g_pCvarLighting, g_szLighting);
		
		g_szLighting = "";
	}
	
	new iRandom;
	
	iRandom = random_num(0, g_iSizeSoundsRoundStart);
	client_cmd(0, "%s ^"%s^"", !IsMp3(g_szSoundsRoundStart[iRandom]) ? "spk" : "mp3 play", g_szSoundsRoundStart[iRandom])
	
	if (get_pcvar_num(g_pCvarEffects))
	{
		get_pcvar_string(g_pCvarLighting, g_szLighting, 1)
		
		set_pcvar_string(g_pCvarLighting, "0")
		
		g_iSeconds = 10; // 1 second of lightning, 0.1 seconds for each light level
		TaskThunderClapRoundStart(g_iTaskLightningID)
		set_task(0.1, "TaskThunderClapRoundStart", g_iTaskLightningID, _, _, "b")
		
		iRandom = random_num(0, g_iSizeSoundsThunderRoundStart);
		
		client_cmd(0, "%s ^"%s^"", !IsMp3(g_szSoundsThunderRoundStart[iRandom]) ? "spk" : "mp3 play", g_szSoundsThunderRoundStart[iRandom])
	}
	else
	{	
		g_iSeconds = g_iDelay;
		
		set_task(1.0, "CountDown", g_iTaskCountdownID, _, _, "b")
	}
}

public TaskThunderClapRoundStart(iTaskID)
{
	if (g_iSeconds)
	{
		new iRandom;
		
		if (g_iSeconds % 2 == 0)
		{
			iRandom = random_num(0, g_iSizeLightsThunderClap1);
			
			engfunc(EngFunc_LightStyle, 0, g_szLightsThunderClap1[iRandom])
		}
		else
		{
			iRandom = random_num(0, g_iSizeLightsThunderClap2);
			
			engfunc(EngFunc_LightStyle, 0, g_szLightsThunderClap2[iRandom])
		}
		
		g_iSeconds--;
	}
	else
	{
		remove_task(iTaskID)
		
		if (get_pcvar_num(g_pCvarEffects))
		{
			if (g_iDelay > g_iSizeLightsCountdownLevels)
				engfunc(EngFunc_LightStyle, 0, g_szLightsCountdownLevels[g_iSizeLightsCountdownLevels])
			else
				engfunc(EngFunc_LightStyle, 0, g_szLightsCountdownLevels[g_iDelay])
		}
		else
		{
			if (!g_szLighting[0])
				return;
			
			engfunc(EngFunc_LightStyle, 0, g_szLighting)
			set_pcvar_string(g_pCvarLighting, g_szLighting)
			
			g_szLighting = "";
		}
		
		g_iSeconds = g_iDelay;
		CountDown(g_iTaskCountdownID)
		set_task(1.0, "CountDown", g_iTaskCountdownID, _, _, "b")
	}
}

public CountDown(iTaskID)
{
	// Check for the external "TASK_MAKEZOMBIE" from inside ZPNM
	if (!task_exists(3000, 1)) //2010
	{
		remove_task(iTaskID)
		
		return;
	}
	
	set_dhudmessage(random_num(57, 255), random_num(0, 255), random_num(0, 255), -1.0, 0.39, 0, 6.0, 0.001, 0.1, 1.0)
	show_dhudmessage(0, "%L", LANG_PLAYER, "TALRASHA_COUNTDOWN", g_iSeconds + 1)
	
	if (g_iSeconds <= g_iSizeSoundsCountdown && g_szSoundsCountdown[g_iSeconds][0])
		client_cmd(0, "%s ^"%s^"", !IsMp3(g_szSoundsCountdown[g_iSeconds]) ? "spk" : "mp3 play", g_szSoundsCountdown[g_iSeconds])
	
	if (g_iSeconds <= g_iSizeLightsCountdownLevels && g_szLightsCountdownLevels[g_iSeconds][0] && get_pcvar_num(g_pCvarEffects))
		engfunc(EngFunc_LightStyle, 0, g_szLightsCountdownLevels[g_iSeconds])
	
	if(g_iSeconds == 29)
	{
		for(new i = 0; i <= get_maxplayers(); i++)
		{
			if(is_user_connected(i))
			{
				message_begin(MSG_ONE, get_user_msgid("ScreenFade"), _, i)
				write_short(0) // duration
				write_short(0) // hold time
				write_short(0x0004) // fade type
				write_byte(50) // red
				write_byte(0) // green
				write_byte(0) // blue
				write_byte(255) // alpha
				message_end()
			}
		}
	}
		
	if(g_iSeconds == 25)
	{
		set_dhudmessage(255, 0, 0, -1.0, 0.35, 0, 6.0, 0.001, 0.1, 1.0)
		show_dhudmessage(0, "%L", LANG_PLAYER, "TALRASHA_WARNING");
		
		for(new i = 0; i <= get_maxplayers(); i++)
		{
			if(is_user_connected(i))
			{
				message_begin(MSG_ONE, get_user_msgid("ScreenFade"), _, i)
				write_short(0) // duration
				write_short(0) // hold time
				write_short(0x0004) // fade type
				write_byte(0) // red
				write_byte(0) // green
				write_byte(50) // blue
				write_byte(255) // alpha
				message_end()
			}
		}
	}
	
	if(g_iSeconds == 23)
	{
		for(new i = 0; i <= get_maxplayers(); i++)
		{
			if(is_user_connected(i))
			{
				message_begin(MSG_ONE, get_user_msgid("ScreenFade"), _, i)
				write_short((1<<12)) // duration
				write_short(0) // hold time
				write_short(0x0000) // fade type
				write_byte(0) // red
				write_byte(0) // green
				write_byte(50) // blue
				write_byte(255) // alpha
				message_end()
			}
		}	
	}
	
	if(g_iSeconds == 21)
	{
		set_dhudmessage(0, 0, 255, -1.0, 0.3, 0, 6.0, 0.001, 0.1, 1.0)
		show_dhudmessage(0, "%L", LANG_PLAYER, "TALRASHA_BIO_DANGER");
	}
	
	if(g_iSeconds == 17)
	{
		set_dhudmessage(255, 0, 0, -1.0, 0.35, 0, 6.0, 0.001, 0.1, 1.0)
		show_dhudmessage(0, "%L", LANG_PLAYER, "TALRASHA_WARNING");
	}
		
	if(g_iSeconds == 14)
	{
		set_dhudmessage(0, 0, 255, -1.0, 0.3, 0, 6.0, 0.001, 0.1, 1.0)
		show_dhudmessage(0, "%L", LANG_PLAYER, "TALRASHA_ATTACKING");
		
		message_begin(MSG_BROADCAST, get_user_msgid("ScreenShake"))
		write_short((1<<12)*4) // amplitude
		write_short((1<<12)*2) // duration
		write_short((1<<12)*10) // frequency
		message_end()
		
		PlaySound(0, MESSAGE_SOUND)
	}
		
	if(g_iSeconds == 11)
	{
		set_dhudmessage(0, 0, 255, -1.0, 0.3, 0, 6.0, 0.001, 0.1, 1.0)
		show_dhudmessage(0, "%L", LANG_PLAYER, "TALRASHA_EVACUATION");
	}
	
	if(g_iSeconds == 9)
	{
		message_begin(MSG_BROADCAST, get_user_msgid("ScreenShake"))
		write_short((1<<12)*4) // amplitude
		write_short((1<<12)*3) // duration
		write_short((1<<12)*12) // frequency
		message_end()
		
		PlaySound(0, MESSAGE_SOUND)
	}
		
	if(g_iSeconds == 8)
	{
		set_dhudmessage(255, 0, 0, -1.0, 0.35, 0, 6.0, 0.001, 0.1, 1.0)
		show_dhudmessage(0, "%L", LANG_PLAYER, "TALRASHA_WARNING");
	}
		
	if(g_iSeconds == 6)
	{
		set_dhudmessage(0, 0, 255, -1.0, 0.3, 0, 6.0, 0.001, 0.1, 1.0)
		show_dhudmessage(0, "%L", LANG_PLAYER, "TALRASHA_PREPARE_ZOMBIES");
	}
		
	if(g_iSeconds == 4)
	{
		set_dhudmessage(255, 255, 255, -1.0, 0.3, 0, 6.0, 0.001, 0.1, 1.0)
		show_dhudmessage(0, "%L", LANG_PLAYER, "TALRASHA_PREPARE_WEAPON");
			
		message_begin(MSG_BROADCAST, get_user_msgid("ScreenShake"))
		write_short((1<<12)*5) // amplitude
		write_short((1<<12)*4) // duration
		write_short((1<<12)*15) // frequency
		message_end()

		PlaySound(0, MESSAGE_SOUND)
	}
		
	if(g_iSeconds == 2)
	{
		set_dhudmessage(255, 0, 0, -1.0, 0.35, 0, 6.0, 0.001, 0.1, 1.0)
		show_dhudmessage(0, "%L", LANG_PLAYER, "TALRASHA_TVIRUS");

		PlaySound(0, MESSAGE_SOUND)
	}
		
	if(g_iSeconds == 1)
		PlaySound(0, MESSAGE_SOUND)
		
	if(g_iSeconds == 0)
	{
		set_dhudmessage(0, 255, 0, -1.0, 0.6, 0, 6.0, 0.001, 0.1, 1.0)
		show_dhudmessage(0, "%L", LANG_PLAYER, "TALRASHA_INFECTION_START");

		PlaySound(0, MESSAGE_SOUND)
	}
	
	g_iSeconds--
	
	if (g_iSeconds < 0)
		remove_task(iTaskID)
}

PlaySound(id, const sound[])
{
	client_cmd(id, "spk ^"%s^"", sound)
}

public TaskThunderClapModeStart(iTaskID)
{
	if (g_iSeconds)
	{
		new iRandom;
		
		if (g_iSeconds % 2 != 0)
		{
			iRandom = random_num(0, g_iSizeLightsThunderClap1);
			
			engfunc(EngFunc_LightStyle, 0, g_szLightsThunderClap1[iRandom])
		}
		else
		{
			iRandom = random_num(0, g_iSizeLightsThunderClap2);
			
			engfunc(EngFunc_LightStyle, 0, g_szLightsThunderClap2[iRandom])
		}
		
		g_iSeconds--
	}
	else
	{
		remove_task(iTaskID)
		
		if (!g_szLighting[0])
			return;
		
		engfunc(EngFunc_LightStyle, 0, g_szLighting)
		set_pcvar_string(g_pCvarLighting, g_szLighting)
		
		g_szLighting = "";
	}
}

public zp_user_infected_post(id)
{
	if((zp_get_user_zombie(id) && !zp_get_user_nemesis(id)))
	{
		random_num(0, g_iSizeSoundsModeStart);
		client_cmd(0, "%s ^"%s^"", !IsMp3(g_szSoundsModeStart[random_num(0,2)]) ? "spk" : "mp3 play", g_szSoundsModeStart[random_num(0,2)])
	}
}

public zp_round_started(iMode, id)
{
	
	remove_task(g_iTaskCountdownID)
	remove_task(g_iTaskLightningID)
	
	new iRandom;
	
	/*if (iMode == MODE_ASSASSIN)
		return;
	else if (!get_pcvar_num(g_pCvarEffects))
	{
		if (g_szLighting[0])
		{
			engfunc(EngFunc_LightStyle, 0, g_szLighting)
			set_pcvar_string(g_pCvarLighting, g_szLighting);
			
			g_szLighting = "z";
		}
		
		return;
	}*/
	

	for(new i = 0; i <= get_maxplayers(); i++)
	{
		if(is_user_connected(i))
		{
			message_begin(MSG_ONE, get_user_msgid("ScreenFade"), _, i)
			write_short((1<<12)) // duration
			write_short(0) // hold time
			write_short(0x0000) // fade type
			write_byte(0) // red
			write_byte(0) // green
			write_byte(50) // blue
			write_byte(255) // alpha
			message_end()

			message_begin(MSG_BROADCAST, get_user_msgid("ScreenShake"))
			write_short((1<<12)*6) // amplitude
			write_short((1<<12)*2) // duration
			write_short((1<<12)*22) // frequency
			message_end()
		}
	}
	
	iRandom = random_num(0, g_iSizeSoundsThunderModeStart);
	client_cmd(0, "%s ^"%s^"", !IsMp3(g_szSoundsThunderModeStart[iRandom]) ? "spk" : "mp3 play", g_szSoundsThunderModeStart[iRandom])
	
	g_iSeconds = 15;
	TaskThunderClapModeStart(g_iTaskLightningID)
	set_task(0.1, "TaskThunderClapModeStart", g_iTaskLightningID, _, _, "b")
}

stock MsgScreenFade(id)
{
	static msg_screenfade; if(!msg_screenfade) msg_screenfade = get_user_msgid("ScreenFade");
	message_begin(MSG_ONE_UNRELIABLE, msg_screenfade, {0,0,0}, id);
	write_short(1<<10);
	write_short(1<<10);
	write_short(0x0000);
	write_byte(0);
	write_byte(0);
	write_byte(200);
	write_byte(75);
	message_end();
}

stock MsgScreenFade_2(id)
{
	static msg_screenfade; if(!msg_screenfade) msg_screenfade = get_user_msgid("ScreenFade");
	message_begin(MSG_ONE_UNRELIABLE, msg_screenfade, {0,0,0}, id);
	write_short(1<<10);
	write_short(1<<10);
	write_short(0x0000);
	write_byte(200);
	write_byte(0);
	write_byte(0);
	write_byte(75);
	message_end();
}