#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <fun>
#include <cstrike>
#include <fakemeta>
#include <hamsandwich>
#include <colorchat>

#pragma semicolon 1;

#define PLUGIN "Second Course Maker"
#define VERSION "v5.32"
#define AUTHOR "Necro"
#define BM_ADMIN_LEVEL ADMIN_IMMUNITY	//admin access level to use this plugin. ADMIN_MENU = flag 'a'

#define TASK_ID_CONFIGVOTETIMER 909000

new gKeysMainMenu;
new gKeysBlockMenu;
new gKeysBlockSelectionMenu;
new gKeysTeleportMenu;
new gKeysOptionsMenu;
new gKeysChoiceMenu;
new gKeysSaveLoadMenu;
new gKeysPropertiesMenu;
new gKeysRenderMenu;
new gKeysRenderFxTypeMenu;
new gKeysAdminMenu;

const Float:gfSnapDistance = 10.0;	//blocks snap together when they're within this value + the players snap gap

// enum for menu option values
enum
{
	N1, N2, N3, N4, N5, N6, N7, N8, N9, N0
};

// enum for bit-shifted numbers 1 - 10
enum
{
	B1 = 1 << N1, B2 = 1 << N2, B3 = 1 << N3, B4 = 1 << N4, B5 = 1 << N5,
	B6 = 1 << N6, B7 = 1 << N7, B8 = 1 << N8, B9 = 1 << N9, B0 = 1 << N0,
};

// enum for options with YES/NO confirmation
enum
{
	CHOICE_LOAD,
	CHOICE_DEL_BLOCKS,
	CHOICE_DEL_TELEPORTS
};

// enum for different block sizes
enum
{
	NORMAL,
	SMALL,
	LARGE,
	POLE
};

// enum for axes
enum
{
	X,
	Y,
	Z
};

// block scales
const Float:SCALE_SMALL = 0.25;
const Float:SCALE_NORMAL = 1.0;
const Float:SCALE_LARGE = 2.0;
const Float:SCALE_LJPOLE = 0.125;

// hud message values
const gHudRed = 10;
const gHudGreen = 30;
const gHudBlue = 200;
const Float:gfTextX = -1.0;
const Float:gfTextY = 0.80;
const gHudEffects = 0;
const Float:gfHudFxTime = 0.0;
const Float:gfHudHoldTime = 0.25;
const Float:gfHudFadeInTime = 0.0;
const Float:gfHudFadeOutTime = 0.0;
const gHudChannel = 2;

// Task ID offsets
const TASK_BHOPSOLID = 1000;
const TASK_BHOPSOLIDNOT = 2000;
const TASK_INVINCIBLE = 3000;
const TASK_STEALTH = 4000;
const TASK_ICE = 5000;
const TASK_SPRITE = 6000;
const TASK_HONEY = 8000;
const TASK_BOOTSOFSPEED = 10000;
const TASK_TELEPORT = 11000;

// strings
new const gszPrefix[] = "[SCM] ";
new const gszInfoTarget[] = "info_target";
new const gszHelpFilenameFormat[] = "blockmaker_v%s.txt";
new gszFile[128];
new gszNewFile[128];
new gszMainMenu[256];
new gszBlockMenu[256];
new gszTeleportMenu[256];
new gszOptionsMenu[256];
new gszChoiceMenu[128];
new gszSaveLoadMenu[256];
new gszPropertiesMenu[256];
new gszPropertiesMenu2[256];
new gszRenderMenu[256];
new gszRenderFxTypeMenu[256];
new gszAdminMenu[256];
new gszHelpTitle[64];
new gszHelpText[1600];
new gszHelpFilename[32];
new gszViewModel[33][32];

//Render Stuff
new gSelectedRenderType[33];
new gSelectedRenderMsg[33][8];
new gSelectedRenderFxType[33];
new gSelectedRenderFxMsg[33][16];
new gRenderRed[33];
new gRenderGreen[33];
new gRenderBlue[33];
new gRenderAmount[33];

new bool:gCantSave;

new Float:gVelocity[33][3];
new gEnt;

// block dimensions
new Float:gfBlockSizeMinForX[3] = {-4.0,-32.0,-32.0};
new Float:gfBlockSizeMaxForX[3] = { 4.0, 32.0, 32.0};
new Float:gfBlockSizeMinForY[3] = {-32.0,-4.0,-32.0};
new Float:gfBlockSizeMaxForY[3] = { 32.0, 4.0, 32.0};
new Float:gfBlockSizeMinForZ[3] = {-32.0,-32.0,-4.0};
new Float:gfBlockSizeMaxForZ[3] = { 32.0, 32.0, 4.0};
new Float:gfDefaultBlockAngles[3] = { 0.0, 0.0, 0.0 };

// pole dimensions
new Float:gfPoleSizeMinForX[3] = {-32.0,-4.0,-4.0};
new Float:gfPoleSizeMaxForX[3] = { 32.0, 4.0, 4.0};
new Float:gfPoleSizeMinForY[3] = {-4.0,-32.0,-4.0};
new Float:gfPoleSizeMaxForY[3] = { 4.0, 32.0, 4.0};
new Float:gfPoleSizeMinForZ[3] = {-4.0,-4.0,-32.0};
new Float:gfPoleSizeMaxForZ[3] = { 4.0, 4.0, 32.0};

// block models
new const gszBlockModelDefault[] = 	"models/Second/Normal/platform.mdl";
new const gszBlockModelPlatform[] = 	"models/Second/Normal/platform.mdl";
new const gszBlockModelBhop[] = 		"models/Second/Normal/bhop.mdl";
new const gszBlockModelDamage[] = 	"models/Second/Normal/damage.mdl";
new const gszBlockModelHealer[] = 	"models/Second/Normal/healer.mdl";
new const gszBlockModelInvincibility[] = "models/Second/Normal/platform.mdl";
new const gszBlockModelStealth[] = 	"models/Second/Normal/platform.mdl";
new const gszBlockModelTrampoline[] =	"models/Second/Normal/trampoline.mdl";
new const gszBlockModelSpeedBoost[] =	"models/Second/Normal/speedboost.mdl";
new const gszBlockModelNoFallDamage[] = 	"models/Second/Normal/nofalldamage.mdl";
new const gszBlockModelIce[] = 		"models/Second/Normal/ice.mdl";
new const gszBlockModelDeath[] = 	"models/Second/Normal/death.mdl";
new const gszBlockModelLowGravity[] = 	"models/Second/Normal/lowgravity.mdl";
new const gszBlockModelSlap[] = 		"models/Second/Normal/slap.mdl";
new const gszBlockModelHoney[] = 	"models/Second/Normal/honey.mdl";
new const gszBlockModelBarrierCT[] = 	"models/Second/Normal/barriert.mdl"; 
new const gszBlockModelBarrierT[] = 	"models/Second/Normal/barrierct.mdl";
new const gszBlockModelBootsOfSpeed[] = 	"models/Second/Normal/bootsofspeed.mdl";
new const gszBlockModelMagicCarpet[] = 	"models/Second/Normal/magiccarpet.mdl";
new const gszBlockModelDelayedBhop[] = 	"models/Second/Normal/bhop.mdl";
new const gszBlockModelWeapon[] = 	"models/Second/Normal/weaponblock.mdl";
new const gszBlockModelPoint[] = 	"models/Second/Normal/point.mdl";

// block sounds
new const gszInvincibleSound[] = "warcraft3/divineshield.wav";				//from WC3 plugin
new const gszStealthSound[] = "warcraft3/levelupcaster.wav";				//from WC3 plugin
new const gszBootsOfSpeedSound[] = "warcraft3/purgetarget1.wav";				//from WC3 plugin

// teleport
new const Float:gfTeleportSizeMin[3] = {-16.0,-16.0,-16.0};
new const Float:gfTeleportSizeMax[3] = { 16.0, 16.0, 16.0};
new const Float:gfTeleportZOffset = 36.0;
new const gTeleportStartFrames = 20;
new const gTeleportEndFrames = 5;
new const gszTeleportSound[] = "warcraft3/blinkarrival.wav";				//from WC3 plugin
new const gszTeleportSpriteStart[] = "sprites/flare6.spr";				//from HL
new const gszTeleportSpriteEnd[] = "sprites/blockmaker/bm_teleport_end.spr";		//custom

// global variables
new gSpriteIdBeam;
new gBlockSize[33];
new gMenuBeforeOptions[33];
new gChoiceOption[33];
new gBlockMenuPage[33];
new gTeleportStart[33];
new gGrabbed[33];
new gGroupedBlocks[33][256];
new gGroupCount[33];

// global booleans
new bool:gbSnapping[33];
new bool:gbNoFallDamage[33];
new bool:gbOnIce[33];
new bool:gbLowGravity[33];
new bool:gbJustDeleted[33];
new bool:gbAdminGodmode[33];
new bool:gbAdminNoclip[33];

// global floats
new Float:gfSnappingGap[33];
new Float:gfOldMaxSpeed[33];
new Float:gfGrablength[33];
new Float:gfNextHealTime[33];
new Float:gfNextDamageTime[33];
new Float:gfInvincibleNextUse[33];
new Float:gfInvincibleTimeOut[33];
new Float:gfStealthNextUse[33];
new Float:gfStealthTimeOut[33];
//new Float:gfTrampolineTimeout[33];
//new Float:gfSpeedBoostTimeOut[33];
new Float:gfBootsOfSpeedTimeOut[33];
new Float:gfBootsOfSpeedNextUse[33];

new bool:gbUsedWeapon[33];
new bool:gbUsedPoint[33];

// global vectors
new Float:gvGrabOffset[33][3];

// block & teleport types
const gBlockMax = 22;
new gSelectedBlockType[gBlockMax];
new gRender[gBlockMax];
new gRed[gBlockMax];
new gGreen[gBlockMax];
new gBlue[gBlockMax];
new gAlpha[gBlockMax];

new const gszBlockClassname[] = "bm_block";
new const gszTeleportStartClassname[] = "bm_teleport_start";
new const gszTeleportEndClassname[] = "bm_teleport_end";

enum
{
	TELEPORT_START,
	TELEPORT_END
};

enum //Free ID's: L, Q, O
{
	BM_PLATFORM,		//A
	BM_BHOP,		//B
	BM_DAMAGE,		//C
	BM_HEALER,		//D
	BM_NOFALLDAMAGE,	//I
	BM_ICE,			//J
	BM_TRAMPOLINE,		//G
	BM_SPEEDBOOST,		//H
	BM_INVINCIBILITY,	//E
	BM_STEALTH,		//F
	BM_DEATH,		//K
	BM_LOWGRAVITY,		//N
	BM_SLAP,		//P
	BM_HONEY,		//R
	BM_BARRIER_CT,		//S
	BM_BARRIER_T,		//T
	BM_BOOTSOFSPEED,	//U
	BM_MAGICCARPET,		//Y
	BM_DELAYEDBHOP,		//Z
	BM_SPAMDUCK,		//1
	BM_WEAPON,		//2
	BM_POINT		//3
};

enum
{
	NORMAL,
	GLOWSHELL,
	TRANSCOLOR,
	TRANSALPHA,
	TRANSWHITE
};

new const gszBlockNames[gBlockMax][32] =
{
	"Platform",
	"Bunnyhop",
	"Damage",
	"Healer",
	"No Fall Damage",
	"Ice",
	"Trampoline",
	"Speed Boost",
	"Invincibility",
	"Stealth",
	"Death",
	"Low Gravity",
	"Slap",
	"Honey",
	"CT Barrier",
	"T Barrier",
	"Boots Of Speed",
	"Magic Carpet",
	"Delayed Bhop",
	"Spam Duck",
	"Weapon",
	"Points"
};

new Float:gszDefaultProp1[gBlockMax] = {
	0.0,		//PLATFORM
	0.0,		//BHOP
	3.0,		//DAMAGE
	1.0,		//HEALER
	0.0,		//NO FALL DAMAGE
	0.0,		//ICE
	500.0,		//TRAMPOLINE
	800.0,		//SPEEDBOOST
	20.0,		//INVINCIBILITY
	20.0,		//STEALTH
	0.0,		//DEATH
	0.25,		//LOW GRAVITY
	0.0,		//SLAP
	0.0,		//HONEY
	0.0,		//CT BARRIER
	0.0,		//T BARRIER
	20.0,		//BOOTS OF SPEED
	2.0,		//MAGIC CARPET
	1.0,		//DELAYED BHOP
	0.0,		//SPAM DUCK
	0.0,		//WEAPON
	50.0		//POINTS
};

new Float:gszDefaultProp2[gBlockMax] = {
	0.0,		//PLATFORM
	0.0,		//BHOP
	0.5,		//DAMAGE
	0.5,		//HEALER
	0.0,		//NO FALL DAMAGE
	0.0,		//ICE
	0.0,		//TRAMPOLINE
	260.0,		//SPEEDBOOST
	60.0,		//INVINCIBILITY
	60.0,		//STEALTH
	0.0,		//DEATH
	200.0,		//LOW GRAVITY
	0.0,		//SLAP
	0.0,		//HONEY
	0.0,		//CT BARRIER
	0.0,		//T BARRIER
	60.0,		//BOOTS OF SPEED
	0.0,		//MAGIC CARPET
	0.0,		//DELAYED BHOP
	0.0,		//SPAM DUCK
	2.0,		//WEAPON
	50.0		//POINTS
};

new gszDefaultProp3[gBlockMax] = {
	2,		//PLATFORM
	0,		//BHOP
	1,		//DAMAGE
	1,		//HEALER
	2,		//NO FALL DAMAGE
	1,		//ICE
	1,		//TRAMPOLINE
	1,		//SPEEDBOOST
	1,		//INVINCIBILITY
	1,		//STEALTH
	1,		//DEATH
	1,		//LOW GRAVITY
	1,		//SLAP
	1,		//HONEY
	0,		//CT BARRIER
	0,		//T BARRIER
	1,		//BOOTS OF SPEED
	0,		//MAGIC CARPET
	0,		//DELAYED BHOP
	1,		//SPAM DUCK
	1,		//WEAPON
	1		//POINTS
};

// save IDs
new const gBlockSaveIds[gBlockMax] =
{
	'A', 'B', 'C', 'D', 'I', 'J', 'G', 'H', 'E', 'F', 'K', 'N', 'P', 'R', 'S', 'T', 'U', 'Y', 'Z', '1', '2', '3'
};

const gTeleportSaveId = '*';

//global array of strings to store the paths and filenames to the block models
new gszBlockModels[gBlockMax][256];

//max speed for player when they have the boots of speed
const Float:gfBootsMaxSpeed = 400.0;

//how many pages for the block selection menu
new gBlockMenuPagesMax;

//multitemplates
new gDir[128];
new gCurConfig[33] = "default";

new gCvarConfigVoteOnStartup;
new gCvarConfigVoteTimer;

new gLoadConfigOnNewRound[33];
new gLoadTemplateOnNewRound[32];
new gbLoadTemplateOnNewRound;

new gRocks;
new bool:gbAlreadyRocked[33];

new gMaxPlayers;

//PROPERTIES
new g_RenamingEnt[33];
new g_SelectedProp[33];

native hnsp_get_user_kpoints(const client);
native hnsp_set_user_kpoints(const client, const kpoints);
native hnsp_get_user_hpoints(const client);
native hnsp_set_user_hpoints(const client, const hpoints);
native hnsp_get_user_stealth(const client);
native hnsp_set_user_stealth(const client);

new bool:gAccess[33];
new bool:gGodmodeOn;

/***** PLUGIN START *****/
public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	register_cvar(PLUGIN, VERSION, FCVAR_SERVER, 0.0);
	
	//register client commands
	register_clcmd("say /scm", "showMainMenu");
	register_clcmd("+scmgrab", "cmdGrab", BM_ADMIN_LEVEL, "bind a key to +scmgrab");
	register_clcmd("-scmgrab", "cmdRelease", BM_ADMIN_LEVEL);
	register_clcmd("/rtt", "cmdRockTheTemplate");
	register_clcmd("rtt", "cmdRockTheTemplate");
	
	register_clcmd("Enter_New_Config", "cmdNewConfig");
	register_clcmd( "_________ENTER_VALUE", "cmdChangeValue");
	register_clcmd( "_________ENTER_NAME", "handleGiveAccess");
	register_clcmd( "__________ENTER_NAME", "handleRevivePlayer");
	
	//register forwards
	register_forward(FM_EmitSound, "forward_EmitSound");
	
	register_event("HLTV", "eventNewRound", "a", "1=0", "2=0");
	
	//create the menus
	createMenus();
	
	//register menus
	register_menucmd(register_menuid("bmMainMenu"), gKeysMainMenu, "handleMainMenu");
	register_menucmd(register_menuid("bmBlockMenu"), gKeysBlockMenu, "handleBlockMenu");
	register_menucmd(register_menuid("bmBlockSelectionMenu"), gKeysBlockSelectionMenu, "handleBlockSelectionMenu");
	register_menucmd(register_menuid("bmTeleportMenu"), gKeysTeleportMenu, "handleTeleportMenu");
	register_menucmd(register_menuid("bmOptionsMenu"), gKeysOptionsMenu, "handleOptionsMenu");
	register_menucmd(register_menuid("bmChoiceMenu"), gKeysChoiceMenu, "handleChoiceMenu");
	register_menucmd(register_menuid("bmSaveLoadMenu"), gKeysSaveLoadMenu, "handleSaveLoadMenu");
	register_menucmd(register_menuid("bmPropertiesMenu"),	gKeysPropertiesMenu, "handlePropertiesMenu");
	register_menucmd(register_menuid("bmRenderMenu"),	gKeysRenderMenu, "handleRenderMenu");
	register_menucmd(register_menuid("bmRenderFxTypeMenu"),	gKeysRenderFxTypeMenu, "handleRenderFxTypeMenu");
	register_menucmd(register_menuid("bmAdminMenu"), gKeysAdminMenu, "handleAdminMenu");
	
	//register CVARs
	register_cvar("bm_telefrags", "1");			//players near teleport exit die if someone comes through
	register_cvar("bm_damageamount", "5.0");		//damage you take per half-second on the damage block
	register_cvar("bm_healamount", "1.0");			//how much hp per half-second you get on the healing block
	register_cvar("bm_invincibletime", "20.0");		//how long a player is invincible
	register_cvar("bm_invinciblecooldown", "60.0");		//time before the invincible block can be used again
	register_cvar("bm_stealthtime", "20.0");		//how long a player is in stealth
	register_cvar("bm_stealthcooldown", "60.0");		//time before the stealth block can be used again
	register_cvar("bm_bootsofspeedtime", "20.0");		//how long the player has boots of speed
	register_cvar("bm_bootsofspeedcooldown", "60.0");	//time before boots of speed can be used again
	register_cvar("bm_teleportsound", "1");			//teleporters make sound
	
	gCvarConfigVoteOnStartup = register_cvar("bm_configvoteonstartup", "30", 0, 0.0);
	gCvarConfigVoteTimer = register_cvar("bm_configvotetimer", "30", 0, 0.0);
	
	//register events
	register_event("DeathMsg", "eventPlayerDeath", "a");
	register_event("TextMsg", "eventRoundRestart", "a", "2&#Game_C", "2&#Game_w");
	register_event("ResetHUD", "eventPlayerSpawn", "b");
	register_event("CurWeapon", "eventCurWeapon", "be");
	register_logevent("eventRoundRestart", 2, "1=Round_Start");
	
	gMaxPlayers = get_maxplayers();
	
	//make save folder in basedir (new saving/loading method)
	new szDir[64];
	new szMap[32];
	get_basedir(szDir, 64);
	add(szDir, 64, "/gamecenter");
	
	//make config folder if it doesn't already exist
	if (!dir_exists(gDir))
	{
		mkdir(gDir);
	}
	
	get_mapname(szMap, 32);
	
	formatex(gDir, 127, "%s/%s", gDir, szMap);
	
	if (!dir_exists(gDir))
	{
		mkdir(gDir);
	}
	
	set_task(1.0, "tskInitAfterCvars", 0, "", 0, "", 0);
}

public tskInitAfterCvars() {
	new value = get_pcvar_num(gCvarConfigVoteOnStartup);
	if ( value )
	{
		set_task(float(value), "tskConfigVote", TASK_ID_CONFIGVOTETIMER, "", 0, "", 0);
	}
}
 
public plugin_precache()
{
	//set block models to defaults
	gszBlockModels[BM_PLATFORM] = gszBlockModelPlatform;
	gszBlockModels[BM_BHOP] = gszBlockModelBhop;
	gszBlockModels[BM_DAMAGE] = gszBlockModelDamage;
	gszBlockModels[BM_HEALER] = gszBlockModelHealer;
	gszBlockModels[BM_NOFALLDAMAGE] = gszBlockModelNoFallDamage;
	gszBlockModels[BM_ICE] = gszBlockModelIce;
	gszBlockModels[BM_TRAMPOLINE] = gszBlockModelTrampoline;
	gszBlockModels[BM_SPEEDBOOST] = gszBlockModelSpeedBoost;
	gszBlockModels[BM_INVINCIBILITY] = gszBlockModelInvincibility;
	gszBlockModels[BM_STEALTH] = gszBlockModelStealth;
	gszBlockModels[BM_DEATH] = gszBlockModelDeath;
	gszBlockModels[BM_LOWGRAVITY] = gszBlockModelLowGravity;
	gszBlockModels[BM_SLAP] = gszBlockModelSlap;
	gszBlockModels[BM_HONEY] = gszBlockModelHoney;
	gszBlockModels[BM_BARRIER_CT] = gszBlockModelBarrierCT;
	gszBlockModels[BM_BARRIER_T] = gszBlockModelBarrierT;
	gszBlockModels[BM_BOOTSOFSPEED] = gszBlockModelBootsOfSpeed;
	gszBlockModels[BM_MAGICCARPET] = gszBlockModelMagicCarpet;
	gszBlockModels[BM_DELAYEDBHOP] = gszBlockModelDelayedBhop;
	gszBlockModels[BM_SPAMDUCK] = gszBlockModelDefault;
	gszBlockModels[BM_WEAPON] = gszBlockModelWeapon;
	gszBlockModels[BM_POINT] = gszBlockModelPoint;
	
	//setup default block rendering (unlisted block use normal rendering)
	setupBlockRendering(BM_INVINCIBILITY, GLOWSHELL, 255, 255, 255, 16);
	setupBlockRendering(BM_STEALTH, TRANSWHITE, 255, 255, 255, 100);
	
	//process block models config file
	processBlockModels();
	
	new szBlockModelSmall[256];
	new szBlockModelLarge[256];
	new szBlockModelPole[256];
	
	//precache blocks
	for (new i = 0; i < gBlockMax; ++i)
	{
		//get filenames for the small and large blocks based on normal block name
		setBlockModelNameSmall(szBlockModelSmall, gszBlockModels[i], 256);
		setBlockModelNameLarge(szBlockModelLarge, gszBlockModels[i], 256);
		setBlockModelNamePole(szBlockModelPole, gszBlockModels[i], 256);
		
		precache_model(gszBlockModels[i]);
		precache_model(szBlockModelSmall);
		precache_model(szBlockModelLarge);
		precache_model(szBlockModelPole);
	}
	
	precache_model(gszTeleportSpriteStart);
	precache_model(gszTeleportSpriteEnd);
	gSpriteIdBeam = precache_model("sprites/zbeam4.spr");
	
	//precache sounds
	precache_sound(gszTeleportSound);
	precache_sound(gszInvincibleSound);
	precache_sound(gszStealthSound);
	precache_sound(gszBootsOfSpeedSound);
}

public plugin_cfg()
{
	//format help text filename
	format(gszHelpFilename, 32, gszHelpFilenameFormat, VERSION);
	
	//create help title
	format(gszHelpTitle, sizeof(gszHelpTitle), "%s v%s by %s", PLUGIN, VERSION, AUTHOR);
	
	//read in help text from file
	new szConfigsDir[32];
	new szHelpFilename[64];
	new szLine[128];
	get_configsdir(szConfigsDir, 32);
	format(szHelpFilename, sizeof(szHelpFilename), "%s/%s", szConfigsDir, gszHelpFilename);
	
	//open help file for reading
	new f = fopen(szHelpFilename, "rt");
	
	//iterate through all the lines in the file
	new size = sizeof(gszHelpText);
	while (!feof(f))
	{
		fgets(f, szLine, 128);
		
		add(gszHelpText, size, szLine);
	}
	
	//close file
	fclose(f);
	
	//load blocks from file
	loadBlocks(0, 0, "default");
}

createMenus()
{
	//calculate maximum number of block menu pages from maximum amount of blocks
	gBlockMenuPagesMax = floatround((float(gBlockMax) / 8.0), floatround_ceil);
	
	//create main menu
	new size = sizeof(gszMainMenu);
	add(gszMainMenu, size, "\r[SCM] \ySecond Course Maker \wby \rzacky^n^n");
	add(gszMainMenu, size, "\r1. \wBlock Menu^n");
	add(gszMainMenu, size, "\r2. \wTeleport Menu^n^n");
	add(gszMainMenu, size, "\r3. \wSave/Load Menu^n");
	add(gszMainMenu, size, "\r4. \wCommands Menu^n^n");
	add(gszMainMenu, size, "\r6. %sNoclip: %s^n");
	add(gszMainMenu, size, "\r7. %sGodmode: %s^n^n");
	add(gszMainMenu, size, "\r8. \wSet Properties^n");
	add(gszMainMenu, size, "\r9. \wOptions Menu^n");
	add(gszMainMenu, size, "\r0. \wClose");
	gKeysMainMenu = B1 | B2 | B3 | B4 | B6 | B7 | B8 | B9 | B0;
	
	//create block menu
	size = sizeof(gszBlockMenu);
	add(gszBlockMenu, size, "\r[SCM] \yBlock Menu^n^n");
	add(gszBlockMenu, size, "\r1. \wBlock Type: \y%s^n");
	add(gszBlockMenu, size, "\r2. %sCreate Block^n");
	add(gszBlockMenu, size, "\r3. %sConvert Block^n");
	add(gszBlockMenu, size, "\r4. %sDelete Block^n");
	add(gszBlockMenu, size, "\r5. %sRotate Block^n^n");
	add(gszBlockMenu, size, "\r6. %sNoclip: %s^n");
	add(gszBlockMenu, size, "\r7. %sGodmode: %s^n");
	add(gszBlockMenu, size, "\r8. \wBlock Size: \y%s^n^n");
	add(gszBlockMenu, size, "\r9. \wOptions Menu^n");
	add(gszBlockMenu, size, "\r0. \wBack");
	gKeysBlockMenu = B1 | B2 | B3 | B4 | B5 | B6 | B7 | B8 | B9 | B0;
	gKeysBlockSelectionMenu = B1 | B2 | B3 | B4 | B5 | B6 | B7 | B8 | B9 | B0;
	
	//create teleport menu
	size = sizeof(gszTeleportMenu);
	add(gszTeleportMenu, size, "\r[SCM] \yTeleporter Menu^n^n");
	add(gszTeleportMenu, size, "\r1. %sTeleport Start^n");
	add(gszTeleportMenu, size, "\r2. %sTeleport Destination^n");
	add(gszTeleportMenu, size, "\r3. %sSwap Teleport Start/Destination^n");
	add(gszTeleportMenu, size, "\r4. %sDelete Teleport^n");
	add(gszTeleportMenu, size, "\r5. %sShow Teleport Path^n^n");
	add(gszTeleportMenu, size, "\r6. %sNoclip: %s^n");
	add(gszTeleportMenu, size, "\r7. %sGodmode: %s^n^n^n");
	add(gszTeleportMenu, size, "\r9. \wOptions Menu^n");
	add(gszTeleportMenu, size, "\r0. \wBack");
	gKeysTeleportMenu = B1 | B2 | B3 | B4 | B5 | B6 | B7 | B9 | B0;
	
	//create the options menu
	size = sizeof(gszOptionsMenu);
	add(gszOptionsMenu, size, "\r[SCM] \yOptions Menu^n^n");
	add(gszOptionsMenu, size, "\r1. %sSnapping: %s^n");
	add(gszOptionsMenu, size, "\r2. %sSnapping gap: \y%.1f^n");
	add(gszOptionsMenu, size, "\r3. %sAdd to group^n");
	add(gszOptionsMenu, size, "\r4. %sClear group^n^n");
	add(gszOptionsMenu, size, "\r5. %sDelete all blocks^n");
	add(gszOptionsMenu, size, "\r6. %sDelete all teleports^n^n");
	add(gszOptionsMenu, size, "\r7. %sSave to file^n");
	add(gszOptionsMenu, size, "\r8. %sLoad from file^n");
	add(gszOptionsMenu, size, "\r9. \wShow help^n");
	add(gszOptionsMenu, size, "\r0. \wBack");
	gKeysOptionsMenu = B1 | B2 | B3 | B4 | B5 | B6 | B7 | B8 | B9 | B0;
	
	//create choice (YES/NO) menu
	size = sizeof(gszChoiceMenu);
	add(gszChoiceMenu, size, "\y%s^n^n");
	add(gszChoiceMenu, size, "\r1. \wYes^n");
	add(gszChoiceMenu, size, "\r2. \wNo^n^n^n^n^n^n^n^n^n^n");
	add(gszChoiceMenu, size, "\r0. \wBack");
	gKeysChoiceMenu = B1 | B2 | B0;
	
	size = sizeof(gszSaveLoadMenu);
	add(gszSaveLoadMenu, size, "\r[SCM] \wSave/Load \yMenu \r[Current Config: \y%s\r]^n^n");
	add(gszSaveLoadMenu, size, "\r1. %sSave Current Config^n");
	add(gszSaveLoadMenu, size, "\r2. %sLoad New Config^n");
	add(gszSaveLoadMenu, size, "\r3. %sCreate New Config^n^n");
	add(gszSaveLoadMenu, size, "\r4. %sStart Config Vote^n^n");
	add(gszSaveLoadMenu, size, "\r9. \wOptions Menu^n");
	add(gszSaveLoadMenu, size, "\r0. \wBack");
	gKeysSaveLoadMenu = B1 | B2 | B3 | B4 | B9 | B0;
	
	size = sizeof(gszPropertiesMenu);
	add(gszPropertiesMenu, size, "\r[SCM] \ySet \wProperties^n");
	add(gszPropertiesMenu, size, "   \wCurrent Block: \y%s^n^n");
	add(gszPropertiesMenu, size, "%s");
	add(gszPropertiesMenu, size, "\r3. \wOn Top Only: %s^n^n");
	add(gszPropertiesMenu, size, "\r8. \wRendering Menu^n");
	add(gszPropertiesMenu, size, "\r9. \wFind new block^n");
	add(gszPropertiesMenu, size, "\r0. \wBack");
	gKeysPropertiesMenu = B1 | B2 | B3 | B4 | B8 | B9 | B0;
	
	size = sizeof(gszPropertiesMenu2);
	add(gszPropertiesMenu2, size, "\r[SCM] \ySet \wProperties^n");
	add(gszPropertiesMenu2, size, "   \yNo block selected!^n^n");
	add(gszPropertiesMenu2, size, "\r8. \wRendering Menu^n");
	add(gszPropertiesMenu2, size, "\r9. \wFind new block^n");
	add(gszPropertiesMenu2, size, "\r0. \wBack");
	
	size = sizeof(gszRenderMenu);
	add(gszRenderMenu, size, "\r[SCM] \yRender \wMenu^n^n");
	add(gszRenderMenu, size, "\r1. \wRender Mode: \y%s^n"); // block size switch
	add(gszRenderMenu, size, "\r2. \wRender FX: \y%s^n^n");
	add(gszRenderMenu, size, "\r3. %sRed: \y%d^n");
	add(gszRenderMenu, size, "\r4. %sGreen: \y%d^n");
	add(gszRenderMenu, size, "\r5. %sBlue: \y%d^n");
	add(gszRenderMenu, size, "\r6. %sAmount: \y%d^n^n");
	add(gszRenderMenu, size, "\r9. %sApply Render^n");
	add(gszRenderMenu, size, "\r0. \wBack");
	gKeysRenderMenu = B1 | B2 | B3 | B4 | B5 | B6 | B9 | B0;
	
	size = sizeof(gszRenderFxTypeMenu);
	add(gszRenderFxTypeMenu, size, "\r[SCM] \yRender FX \wType^n^n");
	add(gszRenderFxTypeMenu, size, "\r1. \wNone^n");
	add(gszRenderFxTypeMenu, size, "\r2. \wGlow Shell^n");
	add(gszRenderFxTypeMenu, size, "\r3. \wFast Pulse^n");
	add(gszRenderFxTypeMenu, size, "\r4. \wFast Pulse Wide^n");
	add(gszRenderFxTypeMenu, size, "\r5. \wSlow Pulse^n");
	add(gszRenderFxTypeMenu, size, "\r6. \wSlow Pulse Wide^n");
	add(gszRenderFxTypeMenu, size, "\r7. \wHologram^n");
	add(gszRenderFxTypeMenu, size, "\r8. \wStrobe Fast^n");
	add(gszRenderFxTypeMenu, size, "\r9. \wStrobe Slow^n^n");
	add(gszRenderFxTypeMenu, size, "\r0. \wBack");
	gKeysRenderFxTypeMenu = B1 | B2 | B3 | B4 | B5 | B6 | B7 | B8 | B9 | B0;
	
	size = sizeof(gszAdminMenu);
	add(gszAdminMenu, size, "\r[SCM] \yCommands \wMenu^n^n");
	add(gszAdminMenu, size, "\r1. %sRevive yourself^n");
	add(gszAdminMenu, size, "\r2. %sRevive Player^n");
	add(gszAdminMenu, size, "\r3. %sRevive Every one^n^n");
	add(gszAdminMenu, size, "\r7. %s%s godmode %s every one^n");
	add(gszAdminMenu, size, "\r8. %sGive access to SCM^n^n");
	add(gszAdminMenu, size, "\r9. \wOptions Menu^n");
	add(gszAdminMenu, size, "\r0. \wBack");
	gKeysAdminMenu = B1 | B2 | B3 | B7 | B8 | B9 | B0;
}

setupBlockRendering(blockType, renderType, red, green, blue, alpha)
{
	gRender[blockType] = renderType;
	gRed[blockType] = red;
	gGreen[blockType] = green;
	gBlue[blockType] = blue;
	gAlpha[blockType] = alpha;
}

setBlockModelNameLarge(szBlockModelTarget[256], szBlockModelSource[256], size)
{
	szBlockModelTarget = szBlockModelSource;
	replace(szBlockModelTarget, size, "Normal", "Large");
}

setBlockModelNameSmall(szBlockModelTarget[256], szBlockModelSource[256], size)
{
	szBlockModelTarget = szBlockModelSource;
	replace(szBlockModelTarget, size, "Normal", "Small");
}

setBlockModelNamePole(szBlockModelTarget[256], szBlockModelSource[256], size)
{
	szBlockModelTarget = szBlockModelSource;
	replace(szBlockModelTarget, size, "Normal", "Pole");
}

processBlockModels()
{     
	//get full path to block models config file
	new szBlockModelsFile[96];
	get_configsdir(szBlockModelsFile, 96);
	add(szBlockModelsFile, 96, "/blockmaker_models.ini");
	
	//open block models config file for reading
	new f = fopen(szBlockModelsFile, "rt");
	new szData[160];
	new szType[32];
	new szBlockModel[256];
	new szRender[16];
	new szRed[8];
	new szGreen[8];
	new szBlue[8];
	new szAlpha[8];
	new blockType;
	new render;
	new red;
	new green;
	new blue;
	new alpha;
	
	//iterate through all the lines in the file
	while (!feof(f))
	{
		//clear data
		szBlockModel = "";
		szRender = "";
		szRed = "";
		szGreen = "";
		szBlue = "";
		szAlpha = "";
		blockType = -1;
		
		//get and parse a line of data from file
		fgets(f, szData, 160);
		parse(szData, szType, 24, szBlockModel, 64, szRender, 16, szRed, 8, szGreen, 8, szBlue, 8, szAlpha, 8);
		
		//replace '\' with '/' in block model path
		replace_all(szBlockModel, 64, "\", "/");
		
		if (equal(szType, "PLATFORM")) blockType = BM_PLATFORM;
		else if (equal(szType, "BHOP")) blockType = BM_BHOP;
		else if (equal(szType, "DAMAGE")) blockType = BM_DAMAGE;
		else if (equal(szType, "HEALER")) blockType = BM_HEALER;
		else if (equal(szType, "NOFALLDAMAGE")) blockType = BM_NOFALLDAMAGE;
		else if (equal(szType, "ICE")) blockType = BM_ICE;
		else if (equal(szType, "TRAMPOLINE")) blockType = BM_TRAMPOLINE;
		else if (equal(szType, "SPEEDBOOST")) blockType = BM_SPEEDBOOST;
		else if (equal(szType, "INVINCIBILITY")) blockType = BM_INVINCIBILITY;
		else if (equal(szType, "STEALTH")) blockType = BM_STEALTH;
		else if (equal(szType, "DEATH")) blockType = BM_DEATH;
		else if (equal(szType, "LOWGRAVITY")) blockType = BM_LOWGRAVITY;
		else if (equal(szType, "SLAP")) blockType = BM_SLAP;
		else if (equal(szType, "HONEY")) blockType = BM_HONEY;
		else if (equal(szType, "BARRIER_CT")) blockType = BM_BARRIER_CT;
		else if (equal(szType, "BARRIER_T")) blockType = BM_BARRIER_T;
		else if (equal(szType, "BOOTSOFSPEED")) blockType = BM_BOOTSOFSPEED;
		
		//if we're dealing with a valid block type
		if (blockType >= 0 && blockType < gBlockMax)
		{
			new bool:bDoRendering = false;
			
			//if block model file exists
			if (file_exists(szBlockModel))
			{
				//set block models for given block type
				gszBlockModels[blockType] = szBlockModel;
				
				//block model file does exist so process rendering values as well
				bDoRendering = true;
			}
			else
			{
				if (equal(szBlockModel, "DEFAULT"))
				{
					//block is set to use default so process rendering values
					bDoRendering = true;
				}
			}
			
			//process rendering values
			if (bDoRendering)
			{
				render = NORMAL;
				red = 255;
				green = 255;
				blue = 255;
				alpha = 255;
				
				if (equal(szRender, "GLOWSHELL")) render = GLOWSHELL;
				if (equal(szRender, "TRANSCOLOR")) render = TRANSCOLOR;
				if (equal(szRender, "TRANSALPHA")) render = TRANSALPHA;
				if (equal(szRender, "TRANSWHITE")) render = TRANSWHITE;
				
				if (strlen(szRed) > 0) red = str_to_num(szRed);
				if (strlen(szGreen) > 0) green = str_to_num(szGreen);
				if (strlen(szBlue) > 0) blue = str_to_num(szBlue);
				if (strlen(szAlpha) > 0) alpha = str_to_num(szAlpha);
				
				//set blocks rendering values
				setupBlockRendering(blockType, render, red, green, blue, alpha);
			}
		}
	}
	
	//close file
	fclose(f);
}

/***** FORWARDS *****/
public client_authorized(id) {
	if (get_user_flags(id) & BM_ADMIN_LEVEL)
		gAccess[id] = true;
	else
		gAccess[id] = false;
}

public client_connect(id)
{
	//make sure snapping is on by default
	gbSnapping[id] = true;
	
	//players chosen snapping gap defaults to 0.0 units
	gfSnappingGap[id] = 0.0;
	
	//make sure players can die
	gbNoFallDamage[id] = false;
	
	//players block selection menu is on page 1
	gBlockMenuPage[id] = 1;
	
	//player doesn't have godmode or noclip
	gbAdminGodmode[id] = false;
	gbAdminNoclip[id] = false;
	
	//player doesn't have any blocks grouped
	gGroupCount[id] = 0;
	
	// Render Shit
	gSelectedRenderType[id] = kRenderNormal;
	gSelectedRenderMsg[id] = "Normal";
	gSelectedRenderFxType[id] = kRenderFxNone;
	gSelectedRenderFxMsg[id] = "None";
	gRenderRed[id] = 255;
	gRenderGreen[id] = 255;
	gRenderBlue[id] = 255;
	gRenderAmount[id] = 255;
	
	gGodmodeOn = false;
	
	//reset players timers
	resetTimers(id);
}

public client_disconnect(id)
{
	//clear players group
	groupClear(id);
	
	//if player was grabbing an entity when they disconnected
	if (gGrabbed[id])
	{
		//if entity is valid
		if (is_valid_ent(gGrabbed[id]))
		{
			//set the entity to 'not being grabbed'
			entity_set_int(gGrabbed[id], EV_INT_iuser2, 0);
		}
		
		gGrabbed[id] = 0;
	}
}

public pfn_touch(ent, id)
{
	//if touch event involves a player
	if (id > 0 && id <= 32 && is_user_alive(id) && isBlock(ent))
	{
		if (pev(ent, pev_fixangle) == 0)
			blockActions(ent, id);
		
		else if ((pev(id, pev_flags) & FL_ONGROUND) && pev(id, pev_groundentity) == ent && pev(ent, pev_fixangle) == 1)
			blockActions(ent, id);
	}
	
	return PLUGIN_CONTINUE;
}

blockActions(ent, id) {
	//get the blocktype
	new blockType = entity_get_int(ent, EV_INT_body);
	
	switch (blockType)
	{
		case BM_HEALER: actionHeal(id, ent);
		case BM_DAMAGE: actionDamage(id, ent);
		case BM_INVINCIBILITY: actionInvincible(id, false, ent);
		case BM_STEALTH: actionStealth(id, false, ent);
		case BM_TRAMPOLINE: actionTrampoline(id, ent);
		case BM_SPEEDBOOST: actionSpeedBoost(id, ent);
		case BM_DEATH: actionDeath(id);
		case BM_LOWGRAVITY: if (pev(ent, pev_fixangle) == 0) actionLowGravity(id, ent);
		case BM_SLAP: actionSlap(id);
		case BM_HONEY: actionHoney(id);
		case BM_BOOTSOFSPEED: actionBootsOfSpeed(id, false, ent);
		case BM_SPAMDUCK: actionSpamDuck(id);
		case BM_ICE: actionOnIce(id);
		case BM_MAGICCARPET: {
			new Float:flProp1;
			pev(ent, pev_fuser1, flProp1);
			
			new iProp1 = floatround(flProp1);
			
			if (iProp1 == 3) {
				new Float:vVelocity[3];
				pev(id, pev_velocity, vVelocity);
				vVelocity[2] = 0.0;
				set_pev(ent, pev_velocity, vVelocity);
			}
			else if (get_user_team(id) == iProp1) {
				new Float:vVelocity[3];
				pev(id, pev_velocity, vVelocity);
				vVelocity[2] = 0.0;
				set_pev(ent, pev_velocity, vVelocity);
			}
		}
		case BM_WEAPON: actionWeapon(id, ent);
		case BM_POINT: actionPoint(id, ent);
	}
			
	//if blocktype is a bunnyhop block or barrier
	if (blockType == BM_BHOP || blockType == BM_BARRIER_CT || blockType == BM_BARRIER_T || blockType == BM_DELAYEDBHOP)
	{		
		//if task does not already exist for bunnyhop block
		if (!task_exists(TASK_BHOPSOLIDNOT + ent) && !task_exists(TASK_BHOPSOLID + ent))
		{
			//get the players team
			new CsTeams:team = cs_get_user_team(id);
					
			//if players team is different to barrier
			if (blockType == BM_BARRIER_CT && team == CS_TEAM_T)
			{
				//make block SOLID_NOT without any delay
				taskSolidNot(TASK_BHOPSOLIDNOT + ent);
			}
			else if (blockType == BM_BARRIER_T && team == CS_TEAM_CT)
			{
				//make block SOLID_NOT without any delay
				taskSolidNot(TASK_BHOPSOLIDNOT + ent);
			}
			else if (blockType == BM_BHOP)
			{
				//set bhop block to be SOLID_NOT after 0.1 seconds
				set_task(0.1, "taskSolidNot", TASK_BHOPSOLIDNOT + ent);
			}
			else if (blockType == BM_DELAYEDBHOP)
			{
				new Float:flProp1;
				pev(ent, pev_fuser1, flProp1);
				
				set_task(flProp1, "taskSolidNot", TASK_BHOPSOLIDNOT + ent);
			}
		}
	}
}

public server_frame()
{
	new ent;
	new Float:vOrigin[3];
	new bool:entNear = false;
	new tele;
	new entinsphere;
	
	//iterate through all players and remove slow down after jumping
	for (new i = 1; i <= 32; ++i)
	{
		if (is_user_alive(i))
		{
			if (gbOnIce[i])
			{
				entity_set_float(i, EV_FL_fuser2, 0.0);
			}
		}
	}
	
	//find all teleport start entities in map and if a player is close to one, teleport the player
	while ((ent = find_ent_by_class(ent, gszTeleportStartClassname)))
	{
		new Float:vOrigin[3];
		entity_get_vector(ent, EV_VEC_origin, vOrigin);
		
		//teleport players and grenades within a sphere around the teleport start entity
		entinsphere = -1;
		while ((entinsphere = find_ent_in_sphere(entinsphere, vOrigin, 32.0)))
		{
			//get classname of entity
			new szClassname[32];
			entity_get_string(entinsphere, EV_SZ_classname, szClassname, 32);
			
			//if entity is a player
			if (entinsphere > 0 && entinsphere <= 32)
			{
				//only teleport player if they're alive
				if (is_user_alive(entinsphere))
				{
					//teleport the player
					actionTeleport(entinsphere, ent);
				}
			}
			//or if entity is a grenade
			else if (equal(szClassname, "grenade"))
			{
				//get the end of the teleport
				tele = entity_get_int(ent, EV_INT_iuser1);
				
				//if the end of the teleport exists
				if (tele)
				{
					//set the end of the teleport to be not solid
					entity_set_int(tele, EV_INT_solid, SOLID_NOT);	//can't be grabbed or deleted
					
					//teleport the grenade
					actionTeleport(entinsphere, ent);
					
					//set a time in the teleport it will become solid after 2 seconds
					entity_set_float(tele, EV_FL_ltime, halflife_time() + 2.0);
				}
			}
		}
	}
	
	//make teleporters SOLID_NOT when players are near them
	while ((ent = find_ent_by_class(ent, gszTeleportEndClassname)))
	{
		//get the origin of the teleport end entity
		entity_get_vector(ent, EV_VEC_origin, vOrigin);
		
		//compare this origin with all player and grenade origins
		entinsphere = -1;
		while ((entinsphere = find_ent_in_sphere(entinsphere, vOrigin, 64.0)))
		{
			//get classname of entity
			new szClassname[32];
			entity_get_string(entinsphere, EV_SZ_classname, szClassname, 32);
			
			//if entity is a player
			if (entinsphere > 0 && entinsphere <= 32)
			{
				//make sure player is alive
				if (is_user_alive(entinsphere))
				{
					entNear = true;
					
					break;
				}
			}
			//or if entity is a grenade
			else if (equal(szClassname, "grenade"))
			{
				entNear = true;
				
				break;
			}
		}
		
		//set the solid type of the teleport end entity depending on whether or not a player is near
		if (entNear)
		{
			//only do this if it is not being grabbed
			if (entity_get_int(ent, EV_INT_iuser2) == 0)
			{
				entity_set_int(ent, EV_INT_solid, SOLID_NOT);	//can't be grabbed or deleted
			}
		}
		else
		{
			//get time from teleport end entity to check if it can go solid
			new Float:fTime = entity_get_float(ent, EV_FL_ltime);
			
			//only set teleport end entity to solid if its 'solid not' time has elapsed
			if (halflife_time() >= fTime)
			{
				entity_set_int(ent, EV_INT_solid, SOLID_BBOX);	//CAN be grabbed and deleted
			}
		}
	}
	
	//find all block entities
	while ((ent = find_ent_by_class(ent, gszBlockClassname)))
	{
		//get block type
		new blockType = entity_get_int(ent, EV_INT_body);
		
		//if block is a speed boost
		if (blockType == BM_SPEEDBOOST)
		{
			new Float:vOrigin[3];
			new Float:pOrigin[3];
			new Float:dist = 9999.9;
			new Float:playerDist = 9999.9;
			new nearestPlayer = 0;
			
			//get the origin of the speed boost block
			entity_get_vector(ent, EV_VEC_origin, vOrigin);
			
			//compare this origin with all players origins to find the nearest player to the block
			for (new id = 1; id <= 32; ++id)
			{
				//if player is alive
				if (is_user_alive(id))
				{
					//get player origin
					entity_get_vector(id, EV_VEC_origin, pOrigin);
					
					//get the distance from the block to the player
					dist = get_distance_f(vOrigin, pOrigin);
					
					if (dist < playerDist)
					{
						nearestPlayer = id;
						playerDist = dist;
					}
				}
			}
			
			//if we found a player within 100 units of the speed boost block
			if (nearestPlayer > 0 && playerDist < 200.0)
			{
				//get the sprite on top of the speed boost block
				new sprite = entity_get_int(ent, EV_INT_iuser3);
				
				//make sure sprite entity is valid
				if (sprite)
				{
					new Float:vAngles[3];
					
					//get the direction the player is looking
					entity_get_vector(nearestPlayer, EV_VEC_angles, vAngles);
					
					//set the angles of the sprite to be the same as the player
					vAngles[0] = 90.0;	//always make sure sprite is flat to the block
					vAngles[1] += 90.0;	//rotate the sprite by 90 because it doesnt point up (PAT!)
					entity_set_vector(sprite, EV_VEC_angles, vAngles);
				}
			}
		}
	}
}

public client_PreThink(id)
{
	//make sure player is connected
	if (is_user_connected(id))
	{
		//display type of block that player is aiming at
		new ent, body;
		get_user_aiming(id, ent, body, 320);
		
		if ((pev(id, pev_button) & IN_USE) && !(pev(id, pev_oldbuttons) & IN_USE))
		{
			if (isBlock(ent)) {
				new blockType = entity_get_int(ent, EV_INT_body);
				
				new szOnTopOnly[20];
				
				static Float:flPropertie1, Float:flPropertie2;
				pev( ent, pev_fuser1, flPropertie1 );
				pev( ent, pev_fuser2, flPropertie2 );
				
				if (pev(ent, pev_fixangle) == 0) szOnTopOnly = "On Top Only: No";
				else if (pev(ent, pev_fixangle) == 1) szOnTopOnly = "On Top Only: Yes";
				else if (pev(ent, pev_fixangle) == 2) szOnTopOnly = "";
					
				// -1.0 / 0.80
				set_hudmessage(gHudRed, gHudGreen, gHudBlue, gfTextX, gfTextY, gHudEffects, gfHudFxTime, 3.0, 0.0, gfHudFadeOutTime, gHudChannel);
					
				switch( blockType ) {
					case BM_HEALER:		show_hudmessage(id, "Block Type: %s^nHealth Per Interval: %i^nInterval: %.1f^n%s", gszBlockNames[blockType], floatround( flPropertie1 ), flPropertie2, szOnTopOnly);
					case BM_TRAMPOLINE:	show_hudmessage(id, "Block Type: %s^nUpward Speed: %i^n%s", gszBlockNames[blockType], floatround( flPropertie1 ), szOnTopOnly);
					case BM_DELAYEDBHOP:	show_hudmessage(id, "Block Type: %s^nDelay before disappear: %.1f^n%s", gszBlockNames[blockType], flPropertie1, szOnTopOnly);
					case BM_SPEEDBOOST:	show_hudmessage(id, "Block Type: %s^nForward Speed: %i^nUpward Speed: %i^n%s", gszBlockNames[blockType], floatround( flPropertie1 ), floatround( flPropertie2 ), szOnTopOnly);
					case BM_DAMAGE:		show_hudmessage(id, "Block Type: %s^nDamage Per Interval: %i^nInterval: %.1f^n%s", gszBlockNames[blockType], floatround( flPropertie1 ), flPropertie2, szOnTopOnly);
					case BM_LOWGRAVITY:	show_hudmessage(id, "Block Type: %s^nGravity: %i^n%s", gszBlockNames[blockType], floatround( flPropertie1 * 800.0 ), szOnTopOnly);
					case BM_STEALTH, BM_INVINCIBILITY, BM_BOOTSOFSPEED: show_hudmessage(id, "Block Type: %s^nTime of usage: %i^nDelay After Usage: %i^n%s", gszBlockNames[blockType], floatround( flPropertie1 ), floatround( flPropertie2 ), szOnTopOnly);
					case BM_MAGICCARPET: {
						static iProp1;
						iProp1 = floatround(flPropertie1);
						static szTeam[33];
						
						switch(iProp1) {
							case 1: format(szTeam, 32, "Terrorists");
							case 2: format(szTeam, 32, "Counter-Terrorists");
							case 3: format(szTeam, 32, "T's and CT's");
						}
						
						show_hudmessage(id, "Block Type: %s^nTeam: %s^n%s", gszBlockNames[blockType], szTeam, szOnTopOnly);
					}
					case BM_WEAPON: {
						static szProp[32];
						pev(ent, pev_message, szProp, 31);
						
						show_hudmessage(id, "Block Type: %s^nWeapon: %s^nBullets: %i^n%s", gszBlockNames[blockType], szProp, floatround(flPropertie2), szOnTopOnly);
					}
					case BM_POINT: show_hudmessage(id, "Block Type: %s^nKill-Points: %i^nHide-Points: %i^n%s", gszBlockNames[blockType], floatround( flPropertie1 ), floatround(flPropertie2), szOnTopOnly);
					default:		show_hudmessage(id, "Block Type: %s^n%s", gszBlockNames[blockType], szOnTopOnly);
				}
			}
		}
		
		//make sure player is alive
		if (is_user_alive(id))
		{
			//if player has low gravity
			if (gbLowGravity[id])
			{
				//get players flags
				new flags = entity_get_int(id, EV_INT_flags);
				
				if (gEnt != -1) actionLowGravity(id, gEnt);
				
				//if player has feet on the ground, set gravity to normal
				if (flags & FL_ONGROUND)
				{
					set_user_gravity(id);
					
					gbLowGravity[id] = false;
				}
			}
						
			if(	gVelocity[id][0] != 0.0
			||	gVelocity[id][1] != 0.0
			||	gVelocity[id][2] != 0.0
			){
				set_pev(id, pev_velocity, gVelocity[id]);
				gVelocity[id][0] = 0.0;
				gVelocity[id][1] = 0.0;
				gVelocity[id][2] = 0.0;
			}
			
			//trace directly down to see if there is a block beneath player
			new Float:pOrigin[3];
			new Float:pSize[3];
			new Float:pMaxs[3];
			new Float:vTrace[3];
			new Float:vReturn[3];
			entity_get_vector(id, EV_VEC_origin, pOrigin);
			entity_get_vector(id, EV_VEC_size, pSize);
			entity_get_vector(id, EV_VEC_maxs, pMaxs);
			
			//calculate position of players feet
			pOrigin[2] = pOrigin[2] - ((pSize[2] - 36.0) - (pMaxs[2] - 36.0));
			
			//make the trace longer for other blocks
			vTrace[2] = pOrigin[2] - 20.0;
			
			//do 4 traces for each corner of the player
			for (new i = 0; i < 4; ++i)
			{
				switch (i)
				{
					case 0: { vTrace[0] = pOrigin[0] - 16; vTrace[1] = pOrigin[1] + 16; }
					case 1: { vTrace[0] = pOrigin[0] + 16; vTrace[1] = pOrigin[1] + 16; }
					case 2: { vTrace[0] = pOrigin[0] + 16; vTrace[1] = pOrigin[1] - 16; }
					case 3: { vTrace[0] = pOrigin[0] - 16; vTrace[1] = pOrigin[1] - 16; }
				}
				
				ent = trace_line(id, pOrigin, vTrace, vReturn);
				
				//if entity found is a block
				if (isBlock(ent))
				{
					new blockType = entity_get_int(ent, EV_INT_body);
					
					switch (blockType)
					{
						case BM_NOFALLDAMAGE: actionNoFallDamage(id);
						case BM_LOWGRAVITY: if (pev(ent, pev_fixangle) == 1) actionLowGravity(id, ent);
						case BM_TRAMPOLINE: actionNoFallDamage(id);
					}
				}
			}
			
			//display amount of invincibility/stealth/camouflage/boots of speed timeleft
			new Float:fTime = halflife_time();
			new Float:fTimeleftInvincible = gfInvincibleTimeOut[id] - fTime;
			new Float:fTimeleftStealth = gfStealthTimeOut[id] - fTime;
			new Float:fTimeleftBootsOfSpeed = gfBootsOfSpeedTimeOut[id] - fTime;
			new szTextToShow[256] = "";
			new szText[48];
			new bool:bShowText = false;
			
			if (fTimeleftInvincible >= 0.0)
			{
				format(szText, sizeof(szText), "Invincible: %.1f^n", fTimeleftInvincible);
				add(szTextToShow, sizeof(szTextToShow), szText);
				bShowText = true;
			}
			
			if (fTimeleftStealth >= 0.0)
			{
				format(szText, sizeof(szText), "Stealth: %.1f^n", fTimeleftStealth);
				add(szTextToShow, sizeof(szTextToShow), szText);
				bShowText = true;
			}
						
			if (fTimeleftBootsOfSpeed >= 0.0)
			{
				format(szText, sizeof(szText), "Boots of speed: %.1f^n", fTimeleftBootsOfSpeed);
				add(szTextToShow, sizeof(szTextToShow), szText);
				bShowText = true;
			}
			
			//if there is some text to show then show it
			if (bShowText)
			{
				set_hudmessage(gHudRed, gHudGreen, gHudBlue, gfTextX, gfTextY, gHudEffects, gfHudFxTime, gfHudHoldTime, gfHudFadeInTime, gfHudFadeOutTime, gHudChannel);
				show_hudmessage(id, szTextToShow);
			}
		}
		
		//get players buttons
		new buttons = get_user_button(id);
		new oldbuttons = get_user_oldbutton(id);
		
		//if player has grabbed an entity
		if (gGrabbed[id] > 0)
		{
			//check for a single press on the following buttons
			if (buttons & IN_JUMP && !(oldbuttons & IN_JUMP)) cmdJump(id);
			if (buttons & IN_DUCK && !(oldbuttons & IN_DUCK)) cmdDuck(id);
			if (buttons & IN_ATTACK && !(oldbuttons & IN_ATTACK)) cmdAttack(id);
			if (buttons & IN_ATTACK2 && !(oldbuttons & IN_ATTACK2)) cmdAttack2(id);
			
			//prevent player from using attack
			buttons &= ~IN_ATTACK;
			entity_set_int(id, EV_INT_button, buttons);
			
			//if player has grabbed a valid entity
			if (is_valid_ent(gGrabbed[id]))
			{
				//if block the player is grabbing is in their group and group count is larger than 1
				if (isBlockInGroup(id, gGrabbed[id]) && gGroupCount[id] > 1)
				{
					new Float:vMoveTo[3];
					new Float:vOffset[3];
					new Float:vOrigin[3];
					new block;
					
					//move the block the player has grabbed and get the move vector
					moveGrabbedEntity(id, vMoveTo);
					
					//move the rest of the blocks in the players group using vector for grabbed block
					for (new i = 0; i <= gGroupCount[id]; ++i)
					{
						block = gGroupedBlocks[id][i];
						
						//if block is still in this players group
						if (isBlockInGroup(id, block))
						{
							//get offset vector from block
							entity_get_vector(block, EV_VEC_vuser1, vOffset);
							
							vOrigin[0] = vMoveTo[0] - vOffset[0];
							vOrigin[1] = vMoveTo[1] - vOffset[1];
							vOrigin[2] = vMoveTo[2] - vOffset[2];
							
							//move grouped block
							moveEntity(id, block, vOrigin, false);
						}
					}
				}
				else
				{
					//move the entity the player has grabbed
					moveGrabbedEntity(id);
				}
			}
			else
			{
				cmdRelease(id);
			}
		}
		
		//if player has just deleted something
		if (gbJustDeleted[id])
		{
			//if player is pressing attack2
			if (buttons & IN_ATTACK2)
			{
				//prevent player from using attack2
				buttons &= ~IN_ATTACK2;
				entity_set_int(id, EV_INT_button, buttons);
			}
			else
			{
				//player has now NOT just deleted something
				gbJustDeleted[id] = false;
			}
		}
	}
	
	return PLUGIN_CONTINUE;
}

public client_PostThink(id)
{
	//if player is alive
	if (is_user_alive(id))
	{
		//if player is set to not get fall damage
		if (gbNoFallDamage[id])
		{
			entity_set_int(id,  EV_INT_watertype, -3);
			gbNoFallDamage[id] = false;
		}
	}
}

#define MAX_VOTES 7
new gConfigVotes[MAX_VOTES];
new gConfigVoteTimer;
new bool:gConfigVoted[33];

public tskConfigVote()
{
	ConfigVote();
	
	return PLUGIN_CONTINUE;
}


ConfigVote(plr=0)
{
	if ( GetNumConfigs() <= 1 )
	{
		if ( plr )
		{
			client_print(plr, print_chat, "%s You need more than one config to do this.", gszPrefix);
		}
		
		return 0;
	}
	
	// Reset vote
	remove_task(TASK_ID_CONFIGVOTETIMER, 0);
	gConfigVoteTimer = get_pcvar_num(gCvarConfigVoteTimer);
	for ( new i = 0; i < MAX_VOTES; i++ )
	{
		gConfigVotes[i] = 0;
	}
	for ( new i = 1; i <= gMaxPlayers; i++ )
	{
		gConfigVoted[i] = false;
	}
	
	
	new menu = menu_create("Vote for a template", "mnuConfigVote", 0); // We will update the title in the task
	menu_setprop(menu, MPROP_EXIT, MEXIT_NEVER);

	new szConfig[33], count;
	new dirh = open_dir(gDir, "", 0);
	
	while ( next_file(dirh, szConfig, 32) && count < MAX_VOTES )
	{
		if ( szConfig[0] == '.' )
		{
			continue;
		}
			
		new szPath[129];
		format(szPath, 128, "%s/%s", gDir, szConfig);
		new lineCount = file_size(szPath, 1);
		
		replace(szConfig, 32, ".bm", "");
		
		new szInfo[129], szCount[3];
		num_to_str(count, szCount, 2);
		format(szInfo, 128, "%s - %i objects", szConfig, lineCount - 1);
		menu_additem(menu, szInfo, szCount, 0, -1);
		
		count++;
	}
	
	close_dir(dirh);
	
	new aMenu[1];
	aMenu[0] = menu;
	set_task(1.0, "tskConfigVoteTimer", TASK_ID_CONFIGVOTETIMER, aMenu, 1, "b", 0);
	
	return 1;
}


public tskConfigVoteTimer(const aMenu[1])
{
	gConfigVoteTimer--;
	
	new szTitle[33];
	format(szTitle, 32, "Vote for a template - \r%i", gConfigVoteTimer);
	menu_setprop(aMenu[0], MPROP_TITLE, szTitle);
	
	for ( new i = 1; i <= gMaxPlayers; i++ )
	{
		if ( is_user_connected(i) && !gConfigVoted[i] )
		{
			menu_display(i, aMenu[0], 0);
		}
	}
	
	if ( !gConfigVoteTimer )
	{
		remove_task(TASK_ID_CONFIGVOTETIMER, 0);
		
		for ( new i = 1; i <= gMaxPlayers; i++ )
		{
			if ( is_user_connected(i) )
			{
				menu_cancel(i);
			}
		}
		
		menu_destroy(aMenu[0]);
		
		new highestVotes;
		new highestVoteId;
		for ( new i = 0; i < MAX_VOTES; i++ )
		{
			if ( gConfigVotes[i] > highestVotes )
			{
				highestVotes = gConfigVotes[i];
				highestVoteId = i;
			}
		}
		
		new szConfig[33];
		GetConfigByNum(highestVoteId, szConfig);
		
		if ( equal(szConfig, gCurConfig, 0) )
		{
			client_print(0, print_chat, "%s Vote winner is same as currently loaded config (%s), not loading.", gszPrefix, gCurConfig);
			return;
		}
		
		if ( gLoadConfigOnNewRound[0] == '*' )
		{
			copy(gLoadConfigOnNewRound, 32, szConfig);
			client_print(0, print_chat, "%s Vote winner: '%s' [%i votes]. Loading template once round finishes.", gszPrefix, szConfig, highestVotes);
		}
		else
		{
			client_print(0, print_chat, "%s Vote winner: '%s' [%i votes]. Loading template once round finished.", gszPrefix, szConfig, highestVotes);
			
			copy(gLoadTemplateOnNewRound, 31, szConfig);
			gbLoadTemplateOnNewRound = true;
		}
	}
	
	return;
}


public mnuConfigVote(plr, menu, item)
{
	if ( item == MENU_EXIT )
	{
		return PLUGIN_CONTINUE;
	}
	
	new szConfigNum[3],  _access, callback;
	menu_item_getinfo(menu, item, _access, szConfigNum, 2, "", 0, callback);
	
	new configNum = str_to_num(szConfigNum);
	
	new szName[32];
	get_user_name(plr, szName, 31);
	
	new szConfig[33];
	GetConfigByNum(configNum, szConfig);
	
	if ( get_user_flags(plr) & BM_ADMIN_LEVEL )
	{
		gConfigVotes[configNum] += 2;
		client_print(0, print_chat, "%s [VIP] '%s' voted for '%s' [+2 votes]", gszPrefix, szName, szConfig);
	}
	else
	{
		gConfigVotes[configNum]++;
		client_print(0, print_chat, "%s '%s' voted for '%s'", gszPrefix, szName, szConfig);
	}
	
	gConfigVoted[plr] = true;
	
	new count;
	for ( new i = 0; i < MAX_VOTES; i++ )
	{
		if ( gConfigVotes[i] )
		{
			count++;
		}
	}
	
	if ( count == get_playersnum(0) )
	{
		gConfigVoteTimer = 1;
		client_print(0, print_chat, "%s Everyone has voted, ending vote.", gszPrefix);
	}
	
	return PLUGIN_CONTINUE;
}

GetConfigByNum(configNum, szConfig[])
{
	new num, bool:found;
	
	new dirh = open_dir(gDir, "", 0);
	
	while ( next_file(dirh, szConfig, 32) )
	{
		if ( szConfig[0] == '.' )
		{
			continue;
		}
		
		if ( num == configNum )
		{
			found = true;
			replace(szConfig, 32, ".bm", "");
			break;
		}
		
		num++;
	}
	
	close_dir(dirh);
	
	return found ? 1 : 0;
}


GetNumConfigs()
{
	new num = 0;
	
	new dirh = open_dir(gDir, "", 0);
	
	new szConfig[33];
	while ( next_file(dirh, szConfig, 32) )
	{
		if ( szConfig[0] == '.' )
		{
			continue;
		}
		
		num++;
	}
	
	close_dir(dirh);
	
	return num;
}

/***** EVENTS *****/
public eventPlayerDeath()
{
	new id = read_data(2);
	
	resetTimers(id);
}

public eventRoundRestart()
{
	//iterate through all players
	for (new id = 1; id <= 32; ++id)
	{
		//reset all players timers
		resetTimers(id);
	}
}

public eventPlayerSpawn(id)
{
	//if player has godmode enabled
	if (gbAdminGodmode[id])
	{
		//re-enable godmode on player
		set_user_godmode(id, 1);
	}
	
	//if player has noclip enabled
	if (gbAdminNoclip[id])
	{
		//re-enable noclip on player
		set_user_noclip(id, 1);
	}
}

public eventNewRound() {
	static numRounds;
	numRounds++;
	if ( numRounds == 5 && GetNumConfigs() > 1 )
	{
		numRounds = 0;
		
		client_print(0, print_chat, "%s 5 rounds finished, starting template vote.", gszPrefix); // TODO: CVar
		gLoadConfigOnNewRound[0] = '*';
		ConfigVote();
	}
	
	if ( strlen(gLoadConfigOnNewRound) && gLoadConfigOnNewRound[0] != '*' )
	{
		loadBlocks(0, 1, gLoadConfigOnNewRound);
		
		client_print(0, print_chat, "%s Loaded template '%s'", gszPrefix, gLoadConfigOnNewRound);
		
		copy(gLoadConfigOnNewRound, 32, "");
	}
	else if (gbLoadTemplateOnNewRound) {
		loadBlocks(0, 1, gLoadTemplateOnNewRound);
		
		client_print(0, print_chat, "%s Loaded template '%s'", gszPrefix, gLoadTemplateOnNewRound);
		
		gbLoadTemplateOnNewRound = false;
		copy(gLoadTemplateOnNewRound, 31, "");
	}
	
	new ent, Float:vOrigin[3];
	while ((ent = find_ent_by_class(ent, gszBlockClassname))) {
		new blockType = pev(ent, pev_body);
		
		if (blockType == BM_MAGICCARPET) {
			pev(ent, pev_v_angle, vOrigin);
			set_pev(ent, pev_velocity, Float:{0.0, 0.0, 0.0});
			
			engfunc(EngFunc_SetOrigin, ent, vOrigin);
		}
	}
}

resetTimers(id)
{
	gfInvincibleTimeOut[id] = 0.0;
	gfInvincibleNextUse[id] = 0.0;
	gfStealthTimeOut[id] = 0.0;
	gfStealthNextUse[id] = 0.0;
	gfBootsOfSpeedTimeOut[id] = 0.0;
	gfBootsOfSpeedNextUse[id] = 0.0;
	
	//remove any task this player might have
	new taskId = TASK_INVINCIBLE + id;
	if (task_exists(taskId)) 
	{
		remove_task(taskId);
	}
	
	taskId = TASK_STEALTH + id;
	if (task_exists(taskId))
	{
		remove_task(taskId);
	}
		
	taskId = TASK_BOOTSOFSPEED + id;
	if (task_exists(taskId))
	{
		remove_task(taskId);
	}
	
	//make sure player is connected
	if (is_user_connected(id))
	{
		if (hnsp_get_user_stealth(id))
			hnsp_set_user_stealth(id);
		else
			set_user_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderNormal, 255);
	}
	
	//player is not 'on ice'
	gbOnIce[id] = false;
			
	gbUsedWeapon[id] = false;
	gbUsedPoint[id] = false;
}

public eventCurWeapon(id)
{
	new Float:fTime = halflife_time();
	new Float:fTimeleftBootsOfSpeed = gfBootsOfSpeedTimeOut[id] - fTime;
	
	//if the player has the boots of speed
	if (fTimeleftBootsOfSpeed >= 0.0)
	{
		//set their max speed so they obtain their speed after changing weapon
		set_user_maxspeed(id, gfBootsMaxSpeed);
	}
}

/***** BLOCK ACTIONS *****/
actionDamage(id, ent)
{
	if (halflife_time() >= gfNextDamageTime[id])
	{
		new Float:flProp1, Float:flProp2;
		
		pev(ent, pev_fuser1, flProp1);
		pev(ent, pev_fuser2, flProp2);
		
		if (get_user_health(id) > 0)
		{
			fakedamage(id, "damage block", flProp1, DMG_CRUSH);
		}
		
		gfNextDamageTime[id] = halflife_time() + flProp2;
	}
}

actionHeal(id, ent)
{
	if (halflife_time() >= gfNextHealTime[id])
	{
		new Float:flPropertie1, Float:flPropertie2;
		pev( ent, pev_fuser1, flPropertie1 );
		pev( ent, pev_fuser2, flPropertie2 );
		
		new iHealth = ( get_user_health( id ) + floatround( flPropertie1 ) );
		
		if( iHealth < 100 ) {
			set_pev( id, pev_health, float( iHealth ) );
		} else {
			if( get_user_health( id ) < 100 )
				set_pev( id, pev_health, 100.0 );
		}
		
		gfNextHealTime[id] = halflife_time() + flPropertie2;
	}
}

actionInvincible(id, OverrideTimer, ent)
{
	new Float:fTime = halflife_time();
	
	if (fTime >= gfInvincibleNextUse[id] || OverrideTimer)
	{
		new Float:flPropertie1, Float:flPropertie2;
		pev( ent, pev_fuser1, flPropertie1 );
		pev( ent, pev_fuser2, flPropertie2 );
		
		set_user_godmode(id, 1);
		set_task(flPropertie1, "taskInvincibleRemove", TASK_INVINCIBLE + id, "", 0, "a", 1);
		
		//only make player glow white for invincibility if player isn't already stealth
		if (fTime >= gfStealthTimeOut[id])
		{
			set_user_rendering(id, kRenderFxGlowShell, 255, 255, 255, kRenderNormal, 16);
		}
		
		//play invincibility sound
		emit_sound(id, CHAN_STATIC, gszInvincibleSound, 1.0, ATTN_NORM, 0, PITCH_NORM);
		
		gfInvincibleTimeOut[id] = fTime + flPropertie1;
		gfInvincibleNextUse[id] = fTime + flPropertie1 + flPropertie2;
	}
	else
	{
		set_hudmessage(gHudRed, gHudGreen, gHudBlue, gfTextX, gfTextY, gHudEffects, gfHudFxTime, gfHudHoldTime, gfHudFadeInTime, gfHudFadeOutTime, gHudChannel);
		show_hudmessage(id, "Invincibility next use: %.1f", gfInvincibleNextUse[id] - fTime);
	}
}

actionStealth(id, OverrideTimer, ent)
{
	new Float:fTime = halflife_time();
	
	//check if player is outside of cooldown time to use stealth
	if (fTime >= gfStealthNextUse[id] || OverrideTimer)
	{
		new Float:flPropertie1, Float:flPropertie2;
		pev( ent, pev_fuser1, flPropertie1 );
		pev( ent, pev_fuser2, flPropertie2 );
		
		//set a task to remove stealth after time out amount
		set_task(flPropertie1, "taskStealthRemove", TASK_STEALTH + id, "", 0, "a", 1);
		
		//make player invisible
		set_user_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderTransColor, 0);
		
		//play stealth sound
		emit_sound(id, CHAN_STATIC, gszStealthSound, 1.0, ATTN_NORM, 0, PITCH_NORM);
		
		gfStealthTimeOut[id] = fTime + flPropertie1;
		gfStealthNextUse[id] = fTime + flPropertie1 + flPropertie2;
	}
	else
	{
		set_hudmessage(gHudRed, gHudGreen, gHudBlue, gfTextX, gfTextY, gHudEffects, gfHudFxTime, gfHudHoldTime, gfHudFadeInTime, gfHudFadeOutTime, gHudChannel);
		show_hudmessage(id, "Stealth next use: %.1f", gfStealthNextUse[id] - fTime);
	}
}

actionTrampoline(id, ent)
{
	//if trampoline timeout has exceeded (needed to prevent velocity being given multiple times)
	//if (halflife_time() >= gfTrampolineTimeout[id])
	//{
		//new Float:velocity[3];
		new Float:flProperty1;
		
		//set player Z velocity to make player bounce
		pev( id, pev_velocity, gVelocity[id] );
		
		pev( ent, pev_fuser1, flProperty1);

		if( flProperty1 == 0.0 )
			gVelocity[id][2] = 500.0;
		else
			gVelocity[id][2] = flProperty1;
		
		//set_pev(id, pev_velocity, velocity);
		
		set_pev(id, pev_gaitsequence, 6);   		//play the Jump Animation
		
		//gfTrampolineTimeout[id] = halflife_time() + 0.5;
	//}
}

actionSpeedBoost(id, ent)
{
	//if speed boost timeout has exceeded (needed to prevent speed boost being given multiple times)
	//if (halflife_time() >= gfSpeedBoostTimeOut[id])
	//{
		//new Float:pAim[3];
		new Float:flProperty1, Float:flProperty2;
		
		pev( ent, pev_fuser1, flProperty1);
		
		if( flProperty1 == 0.0 )
			velocity_by_aim(id, 800, gVelocity[id]);
		else
			velocity_by_aim(id, floatround( flProperty1 ), gVelocity[id]);
		
		pev( ent, pev_fuser2, flProperty2);
		
		gVelocity[id][2] = flProperty2;					//make sure Z velocity is only as high as a jump
		//entity_set_vector(id, EV_VEC_velocity, pAim);
		
		entity_set_int(id, EV_INT_gaitsequence, 6);   		//play the Jump Animation
		
		//gfSpeedBoostTimeOut[id] = halflife_time() + 0.5;
	//}
}

actionNoFallDamage(id)
{
	//set the player to not receive any fall damage (handled in client_PostThink)
	gbNoFallDamage[id] = true;
}

actionOnIce(id)
{
	new taskid = TASK_ICE + id;
	
	if (!gbOnIce[id])
	{
		//save players maxspeed value
		gfOldMaxSpeed[id] = get_user_maxspeed(id);
		
		//make player feel like they're on ice
		entity_set_float(id, EV_FL_friction, 0.15);
		set_user_maxspeed(id, 600.0);
		
		//player is now 'on ice'
		gbOnIce[id] = true;
	}
	
	//remove any existing 'not on ice' task
	if (task_exists(taskid))
	{
		remove_task(taskid);
	}
	
	//set task to remove 'on ice' effect very soon (task replaced if player is still on ice before task time reached)
	set_task(0.1, "taskNotOnIce", taskid);
}

actionDeath(id)
{
	//if player does not have godmode enabled (admin godmode or invincibility)
	if (!get_user_godmode(id))
	{
		//kill player by inflicting massive damage
		fakedamage(id, "the block of death", 10000.0, DMG_GENERIC);
	}
}

actionLowGravity(id, ent)
{
	new Float:flProp1;
	pev(ent, pev_fuser1, flProp1);
	
	//set player to have low gravity
	set_user_gravity(id, flProp1);
	gEnt = -1;
	
	//gGravity[id] = flProp1;
	
	//set global boolean showing player has low gravity
	gbLowGravity[id] = true;
}

actionSlap(id)
{
	user_slap(id, 0);
	user_slap(id, 0);
	set_hudmessage(255, 255, 255, -1.0, 0.20, 0, 6.0, 12.0, 0.0, 1.0, 3);
	
	show_hudmessage(id, "GET OFF MY FACE!!!");
}

actionHoney(id)
{
	new taskid = TASK_HONEY + id;
	
	//make player feel like they're stuck in honey by lowering their maxspeed
	set_user_maxspeed(id, 50.0);
	
	//remove any existing 'in honey' task
	if (task_exists(taskid))
	{
		remove_task(taskid);
	}
	else
	{
		//half the players velocity the first time they touch it
		new Float:vVelocity[3];
		entity_get_vector(id, EV_VEC_velocity, vVelocity);
		vVelocity[0] = vVelocity[0] / 2.0;
		vVelocity[1] = vVelocity[1] / 2.0;
		entity_set_vector(id, EV_VEC_velocity, vVelocity);
	}
	
	//set task to remove 'in honey' effect very soon (task replaced if player is still in honey before task time reached)
	set_task(0.1, "taskNotInHoney", taskid);
}

actionBootsOfSpeed(id, bool:OverrideTimer, ent)
{
	new Float:fTime = halflife_time();
	
	//check if player is outside of cooldown time to use the boots of speed
	if (fTime >= gfBootsOfSpeedNextUse[id] || OverrideTimer)
	{
		new Float:flPropertie1, Float:flPropertie2;
		pev( ent, pev_fuser1, flPropertie1 );
		pev( ent, pev_fuser2, flPropertie2 );
		
		//set a task to remove the boots of speed after time out amount
		set_task(flPropertie1, "taskBootsOfSpeedRemove", TASK_BOOTSOFSPEED + id, "", 0, "a", 1);
		
		//set the players maxspeed to 400 so they run faster!
		set_user_maxspeed(id, gfBootsMaxSpeed);
		
		//play boots of speed sound
		emit_sound(id, CHAN_STATIC, gszBootsOfSpeedSound, 1.0, ATTN_NORM, 0, PITCH_NORM);
		
		gfBootsOfSpeedTimeOut[id] = fTime + flPropertie1;
		gfBootsOfSpeedNextUse[id] = fTime + flPropertie1 + flPropertie2;
	}
	else
	{
		set_hudmessage(gHudRed, gHudGreen, gHudBlue, gfTextX, gfTextY, gHudEffects, gfHudFxTime, gfHudHoldTime, gfHudFadeInTime, gfHudFadeOutTime, gHudChannel);
		show_hudmessage(id, "Boots of speed next use: %.1f", gfBootsOfSpeedNextUse[id] - fTime);
	}
}

actionSpamDuck(id)
	set_pev(id, pev_bInDuck, 1);

actionWeapon(id, ent) {
	set_hudmessage(gHudRed, gHudGreen, gHudBlue, gfTextX, gfTextY, gHudEffects, gfHudFxTime, gfHudHoldTime, gfHudFadeInTime, gfHudFadeOutTime, gHudChannel);
	
	if (cs_get_user_team(id) == CS_TEAM_CT) {
		show_hudmessage(id, "Counter-Terrorists can't use this block");
		return PLUGIN_HANDLED;
	}
	
	if (gbUsedWeapon[id]) {
		show_hudmessage(id, "You can't get a weapon until next round");
		return PLUGIN_HANDLED;
	}
	
	new szProp1[32], Float:flProp2;
	pev(ent, pev_message, szProp1, 31);
	pev(ent, pev_fuser2, flProp2);
	
	new iProp2 = floatround(flProp2);
	
	new szWeapon[32];
	format(szWeapon, 31, "weapon_%s", szProp1);
	
	give_item(id, szWeapon);
	
	if (!equal(szProp1, "hegrenade") && !equal(szProp1, "flashbang") && !equal(szProp1, "smokegrenade")) {
		cs_set_weapon_ammo(find_ent_by_owner(-1, szWeapon, id), iProp2);
		ColorChat(id, GREY, "^x04%s^x03 You Were Given a^x04 %s ^x03with^x04 %i^x03 bullets", gszPrefix, szProp1, iProp2);
	} else
		ColorChat(id, GREY, "^x04%s^x03 You were given a^x04 %s", gszPrefix, szProp1);
	
	gbUsedWeapon[id] = true;
	return PLUGIN_HANDLED;
}

actionPoint(id, ent) {
	set_hudmessage(gHudRed, gHudGreen, gHudBlue, gfTextX, gfTextY, gHudEffects, gfHudFxTime, gfHudHoldTime, gfHudFadeInTime, gfHudFadeOutTime, gHudChannel);
	
	if (cs_get_user_team(id) == CS_TEAM_CT) {
		show_hudmessage(id, "Counter-Terrorists can't use this block");
		return PLUGIN_HANDLED;
	}
	
	if (gbUsedPoint[id]) {
		show_hudmessage(id, "You can't get points until next round");
		return PLUGIN_HANDLED;
	}
	
	new Float:flProp1, Float:flProp2;
	pev(ent, pev_fuser1, flProp1);
	pev(ent, pev_fuser2, flProp2);
	
	new iProp1 = floatround(flProp1);
	new iProp2 = floatround(flProp2);
	
	hnsp_set_user_kpoints(id, hnsp_get_user_kpoints(id) + iProp1);
	hnsp_set_user_hpoints(id, hnsp_get_user_hpoints(id) + iProp2);
	gbUsedPoint[id] = true;
	
	ColorChat(id, GREY, "^x04%s^x03 You were given^x04 %i ^x03Kill-Points and^x04 %i ^x03Hide-Points", gszPrefix, iProp1, iProp2);
	return PLUGIN_HANDLED;
}

actionTeleport(id, ent)
{
	//get end entity id
	new tele = entity_get_int(ent, EV_INT_iuser1);
	
	//if teleport end id is valid
	if (tele)
	{
		//get end entity origin
		new Float:vTele[3];
		entity_get_vector(tele, EV_VEC_origin, vTele);
		
		//if id of entity being teleported is a player and telefrags CVAR is set then kill any nearby players
		if ((id > 0 && id <= 32) && get_cvar_num("bm_telefrags") > 0)
		{
			new player = -1;
			
			do
			{
				player = find_ent_in_sphere(player, vTele, 16.0);
				
				//if entity found is a player
				if (player > 0 && player <= 32)
				{
					//if player is alive, and is not the player that went through the teleport
					if (is_user_alive(player) && player != id)
					{
						//kill the player
						user_kill(player, 1);
					}
				}
			}while(player);
		}
		
		//get origin of the start of the teleport
		new Float:vOrigin[3];
		new origin[3];
		entity_get_vector(ent, EV_VEC_origin, vOrigin);
		FVecIVec(vOrigin, origin);
		
		//show some teleporting effects
		message_begin(MSG_PVS, SVC_TEMPENTITY, origin);
		write_byte(TE_IMPLOSION);
		write_coord(origin[0]);
		write_coord(origin[1]);
		write_coord(origin[2]);
		write_byte(64);		// radius
		write_byte(100);	// count
		write_byte(6);		// life
		message_end();
		
		//teleport player
		entity_set_vector(id, EV_VEC_origin, vTele);
		
		//reverse players Z velocity
		new Float:vVelocity[3];
		entity_get_vector(id, EV_VEC_velocity, vVelocity);
		vVelocity[2] = floatabs(vVelocity[2]);
		entity_set_vector(id, EV_VEC_velocity, vVelocity);
		
		//if teleport sound CVAR is set
		if (get_cvar_num("bm_teleportsound") > 0)
		{
			//play teleport sound
			emit_sound(id, CHAN_STATIC, gszTeleportSound, 1.0, ATTN_NORM, 0, PITCH_NORM);
		}
	}
}

/***** TASKS *****/
public taskSolidNot( ent ) {
	ent -= TASK_BHOPSOLIDNOT;
	
	if( pev_valid( ent ) ) {
		if( pev( ent, pev_iuser2 ) == 0 ) {
			new Float:flRenderColor[ 3 ], Float:flRenderAmt, iRenderFX, iRenderMode;
			
			if( pev( ent, pev_iuser1 ) == 0 ) {
				iRenderFX	= pev( ent, pev_renderfx );
				iRenderMode	= pev( ent, pev_rendermode );
				pev( ent, pev_rendercolor, flRenderColor );
				pev( ent, pev_renderamt, flRenderAmt );
				
				set_pev( ent, pev_speed, flRenderAmt );
				set_pev( ent, pev_oldorigin, flRenderColor );
				set_pev( ent, pev_euser1, iRenderFX );
				set_pev( ent, pev_euser2, iRenderMode );
			}
			
			set_pev( ent, pev_solid, SOLID_NOT );
			set_rendering( ent, kRenderFxNone, 255, 255, 255, kRenderTransAdd, 25 );
			set_task( 1.0, "taskSolid", TASK_BHOPSOLID + ent );
			
			gCantSave = true;
		}
	}
}

public taskSolid( ent ) {
	ent -= TASK_BHOPSOLID;
	
	if( isBlock( ent ) ) {
		set_pev( ent, pev_solid, SOLID_BBOX );
		
		// An uber render fix
		new Float:flRenderColor[ 3 ], Float:flRenderAmt, iRenderFX, iRenderMode;
		
		iRenderFX	= pev( ent, pev_euser1 );
		iRenderMode	= pev( ent, pev_euser2 );
		pev( ent, pev_oldorigin, flRenderColor );
		pev( ent, pev_speed, flRenderAmt );
		
		// Remove our render temporary information
		set_pev( ent, pev_speed, 0.0 );
		set_pev( ent, pev_oldorigin, { 0.0, 0.0, 0.0 } );
		set_pev( ent, pev_euser1, 0 );
		set_pev( ent, pev_euser2, 0 );
		
		//get the player ID of who has the block in a group (if anyone)
		new player = pev( ent, pev_iuser1 );
		
		gCantSave = false;
		
		//if the block is in a group
		if( player > 0 ) {
			set_pev( ent, pev_renderamt, flRenderAmt );
			set_pev( ent, pev_rendercolor, flRenderColor );
			set_pev( ent, pev_renderfx, iRenderFX );
			set_pev( ent, pev_rendermode , iRenderMode );
			
			//set the block so it is now 'being grouped' (for setting the rendering)
			groupBlock( 0, ent );
		} else {
			new blockType = pev( ent, pev_body );
			
			set_block_rendering( ent, gRender[blockType], gRed[blockType], gGreen[blockType], gBlue[blockType], gAlpha[blockType] );
			
			set_pev( ent, pev_renderamt, flRenderAmt );
			set_pev( ent, pev_rendercolor, flRenderColor );
			set_pev( ent, pev_renderfx, iRenderFX );
			set_pev( ent, pev_rendermode , iRenderMode );
		}
	}
}
public taskInvincibleRemove(id)
{
	id -= TASK_INVINCIBLE;
	
	//make sure player is alive
	if (is_user_alive(id))
	{
		set_user_godmode(id, 0);
		
		//only set players rendering back to normal if player is not stealth
		if (halflife_time() >= gfStealthTimeOut[id])
		{
			if (hnsp_get_user_stealth(id))
				hnsp_set_user_stealth(id);
			else
				set_user_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderNormal, 16);
		}
	}
}

public taskStealthRemove(id)
{
	id -= TASK_STEALTH;
	
	//make sure player is connected
	if (is_user_connected(id))
	{
		//only set players rendering back to normal if player is not invincible
		if (halflife_time() >= gfInvincibleTimeOut[id])
		{
			if (hnsp_get_user_stealth(id))
				hnsp_set_user_stealth(id);
			else
				set_user_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderNormal, 255);
		}
		else	//if player is invincible then set player to glow white
		{
			set_user_rendering(id, kRenderFxGlowShell, 255, 255, 255, kRenderTransColor, 16);
		}
	}
}

public taskNotOnIce(id)
{
	id -= TASK_ICE;
	
	//make player run normally
	entity_set_float(id, EV_FL_friction, 1.0);
	
	if (gfOldMaxSpeed[id] > 100.0)
	{
		set_user_maxspeed(id, gfOldMaxSpeed[id]);
	}
	else
	{
		set_user_maxspeed(id, 250.0);
	}
	
	//no longer 'on ice'
	gbOnIce[id] = false;
	gfOldMaxSpeed[id] = 0.0;
}

public taskNotInHoney(id)
{
	id -= TASK_HONEY;
	
	//if player is alive
	if (is_user_alive(id))
	{
		//make player move normally
		set_user_maxspeed(id, 250.0);
		
		//this will set the players maxspeed faster if they have the boots of speed!
		eventCurWeapon(id);
	}
}

public taskBootsOfSpeedRemove(id)
{
	id -= TASK_BOOTSOFSPEED;
	
	//set players speed back to normal
	if (is_user_alive(id))
	{
		set_user_maxspeed(id, 250.0);
	}
}

public taskSpriteNextFrame(params[])
{
	new ent = params[0];
	
	//make sure entity is valid
	if (is_valid_ent(ent))
	{
		new frames = params[1];
		new Float:current_frame = entity_get_float(ent, EV_FL_frame);
		
		if (current_frame < 0.0 || current_frame >= frames)
		{
			entity_set_float(ent, EV_FL_frame, 1.0);
		}
		else
		{
			entity_set_float(ent, EV_FL_frame, current_frame + 1.0);
		}
	}
	else
	{
		remove_task(TASK_SPRITE + ent);
	}
}

/***** COMMANDS *****/
public cmdJump(id)
{
	//if the object the player is grabbing isn't too close
	if (gfGrablength[id] > 72.0)
	{
		//move the object closer
		gfGrablength[id] -= 16.0;
	}
}

public cmdDuck(id)
{
	//move the object further away
	gfGrablength[id] += 16.0;
}

public cmdAttack(id)
{
	//if entity being grabbed is a block
	if (isBlock(gGrabbed[id]))
	{
		//if block the player is grabbing is in their group and group count is larger than 1
		if (isBlockInGroup(id, gGrabbed[id]) && gGroupCount[id] > 1)
		{
			new block;
			
			//move the rest of the blocks in the players group using vector for grabbed block
			for (new i = 0; i <= gGroupCount[id]; ++i)
			{
				block = gGroupedBlocks[id][i];
				
				//if this block is in this players group
				if (isBlockInGroup(id, block))
				{
					//only copy the block if it is not stuck
					if (!isBlockStuck(block))
					{
						//copy the block
						copyBlock(block);
					}
				}
			}
		}
		else
		{
			//only copy the block the player has grabbed if it is not stuck
			if (!isBlockStuck(gGrabbed[id]))
			{
				//copy the block
				new newBlock = copyBlock(gGrabbed[id]);
				
				//if new block was created successfully
				if (newBlock)
				{
					//set currently grabbed block to 'not being grabbed'
					entity_set_int(gGrabbed[id], EV_INT_iuser2, 0);
					
					//set new block to 'being grabbed'
					entity_set_int(newBlock, EV_INT_iuser2, id);
					
					//set player to grabbing new block
					gGrabbed[id] = newBlock;
				}
			}
			else
			{
				//tell the player they can't copy a block when it is in a stuck position
				client_print(id, print_chat, "%sYou cannot copy a block that is in a stuck position!", gszPrefix);
			}
		}
	}
}

public cmdAttack2(id)
{
	//if player is grabbing a block
	if (isBlock(gGrabbed[id]))
	{
		//if block the player is grabbing is in their group and group count is larger than 1
		if (isBlockInGroup(id, gGrabbed[id]) && gGroupCount[id] > 1)
		{
			new block;
			
			//iterate through all blocks in the players group
			for (new i = 0; i <= gGroupCount[id]; ++i)
			{
				block = gGroupedBlocks[id][i];
				
				//if block is still valid
				if (is_valid_ent(block))
				{
					//if block is still in this players group
					if (isBlockInGroup(id, block))
					{
						//delete the block
						gbJustDeleted[id] = deleteBlock(block);
					}
				}
			}
		}
		else
		{
			//delete the block
			gbJustDeleted[id] = deleteBlock(gGrabbed[id]);
		}
	}
	//if player is grabbing a teleport
	else if (isTeleport(gGrabbed[id]))
	{
		//delete the teleport
		gbJustDeleted[id] = deleteTeleport(id, gGrabbed[id]);
	}
}

public cmdGrab(id)
{
	//make sure player has access to use this command
	if (gAccess[id])
	{
		//get the entity the player is aiming at and the length
		new ent, body;
		gfGrablength[id] = get_user_aiming(id, ent, body);
		
		//set booleans depending on entity type
		new bool:bIsBlock = isBlock(ent);
		new bool:bIsTeleport = isTeleport(ent);
		
		//if the entity is a block or teleport
		if (bIsBlock || bIsTeleport)
		{
			//get who is currently grabbing the entity (if anyone)
			new grabber = entity_get_int(ent, EV_INT_iuser2);
			
			//if entity is not being grabbed by someone else
			if (grabber == 0 || grabber == id)
			{
				//if entity is a block
				if (bIsBlock)
				{
					//get the player ID of who has the block in a group (if anyone)
					new player = entity_get_int(ent, EV_INT_iuser1);
					
					//if the block is not in a group or is in this players group
					if (player == 0 || player == id)
					{
						//set the block to 'being grabbed'
						setGrabbed(id, ent);
						
						//if this block is in this players group and group count is greater than 1
						if (player == id && gGroupCount[id] > 1)
						{
							new Float:vGrabbedOrigin[3];
							new Float:vOrigin[3];
							new Float:vOffset[3];
							new block;
							
							//get origin of the block
							entity_get_vector(ent, EV_VEC_origin, vGrabbedOrigin);
							
							//iterate through all blocks in players group
							for (new i = 0; i <= gGroupCount[id]; ++i)
							{
								block = gGroupedBlocks[id][i];
								
								//if block is still valid
								if (is_valid_ent(block))
								{
									player = entity_get_int(ent, EV_INT_iuser1);
									
									//if block is still in this players group
									if (player == id)
									{
										//get origin of block in players group
										entity_get_vector(block, EV_VEC_origin, vOrigin);
										
										//calculate offset from grabbed block
										vOffset[0] = vGrabbedOrigin[0] - vOrigin[0];
										vOffset[1] = vGrabbedOrigin[1] - vOrigin[1];
										vOffset[2] = vGrabbedOrigin[2] - vOrigin[2];
										
										//save offset value in grouped block
										entity_set_vector(block, EV_VEC_vuser1, vOffset);
										
										//indicate that entity is being grabbed
										entity_set_int(block, EV_INT_iuser2, id);
									}
								}
							}
						}
					}
				}
				//if entity is a teleporter
				else if (bIsTeleport)
				{
					//set the teleport to 'being grabbed'
					setGrabbed(id, ent);
				}
			}
		}
	}
	
	return PLUGIN_HANDLED;
}

setGrabbed(id, ent)
{
	new Float:fpOrigin[3];
	new Float:fbOrigin[3];
	new Float:fAiming[3];
	new iAiming[3];
	new bOrigin[3];
	
	//get players current view model then clear it
	entity_get_string(id, EV_SZ_viewmodel, gszViewModel[id], 32);
	entity_set_string(id, EV_SZ_viewmodel, "");
	
	get_user_origin(id, bOrigin, 1);			//position from eyes (weapon aiming)
	get_user_origin(id, iAiming, 3);			//end position from eyes (hit point for weapon)
	entity_get_vector(id, EV_VEC_origin, fpOrigin);		//get player position
	entity_get_vector(ent, EV_VEC_origin, fbOrigin);	//get block position
	IVecFVec(iAiming, fAiming);
	FVecIVec(fbOrigin, bOrigin);
	
	//set gGrabbed
	gGrabbed[id] = ent;
	gvGrabOffset[id][0] = fbOrigin[0] - iAiming[0];
	gvGrabOffset[id][1] = fbOrigin[1] - iAiming[1];
	gvGrabOffset[id][2] = fbOrigin[2] - iAiming[2];
	
	//indicate that entity is being grabbed
	entity_set_int(ent, EV_INT_iuser2, id);
}

public cmdRelease(id)
{
	//make sure player has access to use this command
	if (gAccess[id])
	{
		//if player is grabbing an entity
		if (gGrabbed[id])
		{
			//if entity player is grabbing is a block
			if (isBlock(gGrabbed[id]))
			{
				//if block the player is grabbing is in their group and group count is > 1
				if (isBlockInGroup(id, gGrabbed[id]) && gGroupCount[id] > 1)
				{
					new block;
					new bool:bGroupIsStuck = true;
					
					//iterate through all blocks in the players group
					for (new i = 0; i <= gGroupCount[id]; ++i)
					{
						block = gGroupedBlocks[id][i];
						
						//if this block is in this players group
						if (isBlockInGroup(id, block))
						{
							//indicate that entity is no longer being grabbed
							entity_set_int(block, EV_INT_iuser2, 0);
							
							//start off thinking all blocks in group are stuck
							if (bGroupIsStuck)
							{
								//if block is not stuck
								if (!isBlockStuck(block))
								{
									//at least one of the blocks in the group are not stuck
									bGroupIsStuck = false;
								}
							}
						}
					}
					
					//if all the blocks in the group are stuck
					if (bGroupIsStuck)
					{
						//iterate through all blocks in the players group
						for (new i = 0; i <= gGroupCount[id]; ++i)
						{
							block = gGroupedBlocks[id][i];
							
							//if this block is in this players group
							if (isBlockInGroup(id, block))
							{
								//delete the block
								deleteBlock(block);
							}
						}
						
						//tell the player all the blocks were deleted because they were stuck
						client_print(id, print_chat, "%sGroup deleted because all the blocks were stuck!", gszPrefix);
					}
				}
				else
				{
					//if block player has grabbed is valid
					if (is_valid_ent(gGrabbed[id]))
					{
						//if the block is stuck
						if (isBlockStuck(gGrabbed[id]))
						{
							//delete the block
							new bool:bDeleted = deleteBlock(gGrabbed[id]);
							
							//if the block was deleted successfully
							if (bDeleted)
							{
								//tell the player the block was deleted and why
								client_print(id, print_chat, "%sBlock deleted because it was stuck!", gszPrefix);
							}
						}
						else
						{
							//indicate that the block is no longer being grabbed
							entity_set_int(gGrabbed[id], EV_INT_iuser2, 0);
							
							new blockType = pev(gGrabbed[id], pev_body);
							
							if( blockType == BM_MAGICCARPET ) {
								new Float:vOrigin[3];
								pev(gGrabbed[id], pev_origin, vOrigin);
								
								set_pev(gGrabbed[id], pev_v_angle, vOrigin);
							}
						}
					}
				}
			}
			else if (isTeleport(gGrabbed[id]))
			{
				//indicate that the teleport is no longer being grabbed
				entity_set_int(gGrabbed[id], EV_INT_iuser2, 0);
			}
			
			//set the players view model back to what it was
			entity_set_string(id, EV_SZ_viewmodel, gszViewModel[id]);
			
			//indicate that player is not grabbing an object
			gGrabbed[id] = 0;
		}
	}
	
	return PLUGIN_HANDLED;
}

public cmdRockTheTemplate(id) {
	if (GetNumConfigs() <= 1) {
		client_print(id, print_chat, "%s You can't do this because there is only 1 template", gszPrefix);
		return PLUGIN_HANDLED;
	}
	
	if (gbAlreadyRocked[id]) {
		client_print(id, print_chat, "%s You have already rocked the template", gszPrefix);
		return PLUGIN_HANDLED;
	}
	
	if (task_exists(TASK_ID_CONFIGVOTETIMER)) {
		client_print(id, print_chat, "%s A vote is already going on or is going to start soon", gszPrefix);
		return PLUGIN_HANDLED;
	}
	
	gRocks++;
	gbAlreadyRocked[id] = true;
	
	new iRocksNeeded = get_rocks_needed();
	
	if (gRocks >= iRocksNeeded) {
		client_print(0, print_chat, "%s Enough rock the templates, starting template vote", gszPrefix);
		
		gRocks = 0;
		
		set_task(5.0, "tskConfigVote", TASK_ID_CONFIGVOTETIMER);
		
		for (new i = 1; i <= gMaxPlayers; i++) {
			gbAlreadyRocked[i] = false;
		}
	} else {
		new szName[32];
		get_user_name(id, szName, 31);
		
		client_print(0, print_chat, "%s '%s' rocked the template. %d rocks more is needed to start a template vote", gszPrefix, szName, iRocksNeeded - gRocks);
	}
	
	return PLUGIN_HANDLED;
}

/* MENUS */
public showMainMenu(id)
{
	new col[3];
	new szMenu[256];
	new szGodmode[6];
	new szNoclip[6];
	col = (gAccess[id] ? "\w" : "\d");
	szNoclip = (get_user_noclip(id) ? "\yOn" : "\rOff");
	szGodmode = (get_user_godmode(id) ? "\yOn" : "\rOff");
	
	//format the main menu
	format(szMenu, 256, gszMainMenu, col, szNoclip, col, szGodmode);
	
	//show the main menu to the player
	show_menu(id, gKeysMainMenu, szMenu, -1, "bmMainMenu");
	return PLUGIN_HANDLED;
}

showBlockMenu(id)
{
	new col[3];
	new szMenu[256];
	new szGodmode[6];
	new szNoclip[6];
	new szSize[8];
	col = (gAccess[id] ? "\w" : "\d");
	szNoclip = (get_user_noclip(id) ? "\yOn" : "\rOff");
	szGodmode = (get_user_godmode(id) ? "\yOn" : "\rOff");
	
	switch (gBlockSize[id])
	{
		case SMALL: szSize = "Small";
		case NORMAL: szSize = "Normal";
		case LARGE: szSize = "Large";
		case POLE: szSize = "Pole";
	}
	
	//format the main menu
	format(szMenu, 256, gszBlockMenu, gszBlockNames[gSelectedBlockType[id]], col, col, col, col, col, szNoclip, col, szGodmode, szSize);
	
	//show the block menu to the player
	show_menu(id, gKeysBlockMenu, szMenu, -1, "bmBlockMenu");
	
	return PLUGIN_HANDLED;
}

showBlockSelectionMenu(id)
{
	//create block selection menu 1 (first 8 blocks)
	new szBlockMenu[256];
	new szTitle[32];
	new szEntry[32];
	new num;
	new startBlock;
	
	//format the page number into the menu title
	format(szTitle, sizeof(szTitle), "\yBlock Selection %d^n^n", gBlockMenuPage[id]);
	
	//add the title to the menu
	add(szBlockMenu, sizeof(szBlockMenu), szTitle);
	
	//calculate the block that the menu will start on
	startBlock = (gBlockMenuPage[id] - 1) * 8;
	
	//iterate through 8 blocks to add to the menu
	for (new i = startBlock; i < startBlock + 8; ++i)
	{
		//make sure the loop doesn't go above the maximum number of blocks
		if (i < gBlockMax)
		{
			//calculate the menu item number
			num = (i - startBlock) + 1;
			
			//format the block name into the menu entry
			format(szEntry, sizeof(szEntry), "\r%d. \w%s^n", num, gszBlockNames[i]);
		}
		else
		{
			//format a blank menu entry
			format(szEntry, sizeof(szEntry), "^n");
		}
		
		//add the entry to the menu
		add(szBlockMenu, sizeof(szBlockMenu), szEntry);
	}
	
	//if the block selection page the player is on is less than the maximum page
	if (gBlockMenuPage[id] < gBlockMenuPagesMax)
	{
		add(szBlockMenu, sizeof(szBlockMenu), "^n\r9. \wMore");
	}
	else
	{
		add(szBlockMenu, sizeof(szBlockMenu), "^n");
	}
	
	//add a back option to the menu
	add(szBlockMenu, sizeof(szBlockMenu), "^n\r0. \wBack");
	
	//display the block selection menu
	show_menu(id, gKeysBlockSelectionMenu, szBlockMenu, -1, "bmBlockSelectionMenu");
}

showTeleportMenu(id)
{
	new col[3];
	new szMenu[256];
	new szGodmode[6];
	new szNoclip[6];
	col = (gAccess[id] ? "\w" : "\d");
	szNoclip = (get_user_noclip(id) ? "\yOn" : "\rOff");
	szGodmode = (get_user_godmode(id) ? "\yOn" : "\rOff");
	
	//format teleport menu
	format(szMenu, sizeof(szMenu), gszTeleportMenu, col, (gTeleportStart[id] ? "\w" : "\d"), col, col, col, col, szNoclip, col, szGodmode);
	
	show_menu(id, gKeysTeleportMenu, szMenu, -1, "bmTeleportMenu");
}

showOptionsMenu(id, oldMenu)
{
	//set the oldmenu global variable so when the back key is pressed it goes back to the previous menu
	gMenuBeforeOptions[id] = oldMenu;
	
	new col[3];
	new szSnapping[6];
	new szMenu[256];
	col = (gAccess[id] ? "\w" : "\d");
	szSnapping = (gbSnapping[id] ? "\yOn" : "\rOff");
	
	//format the options menu
	format(szMenu, sizeof(szMenu), gszOptionsMenu, col, szSnapping, col, gfSnappingGap[id], col, col, col, col, col, col);
	
	//show the options menu to the player
	show_menu(id, gKeysOptionsMenu, szMenu, -1, "bmOptionsMenu");
}

showChoiceMenu(id, gChoice, const szTitle[96])
{
	gChoiceOption[id] = gChoice;
	
	//format choice menu using given title
	new szMenu[128];
	format(szMenu, sizeof(szMenu), gszChoiceMenu, szTitle);
	
	//show the choice menu to the player
	show_menu(id, gKeysChoiceMenu, szMenu, -1, "bmChoiceMenu");
}

showRenderMenu(id) {
	new col[3];
	new szMenu[256];
	
	col = (gAccess[id] ? "\w" : "\d");
	
	format(szMenu, sizeof(szMenu), gszRenderMenu, gSelectedRenderMsg[id], gSelectedRenderFxMsg[id], col, gRenderRed[id], col, gRenderGreen[id], col, gRenderBlue[id], col, gRenderAmount[id], col);
	
	show_menu(id, gKeysRenderMenu, szMenu, -1, "bmRenderMenu");
}

showRenderFxTypeMenu(id) {
	//new szMenu[256];
	//format(szMenu, sizeof(szMenu), gszRenderFxTypeMenu);
	
	show_menu(id, gKeysRenderFxTypeMenu, gszRenderFxTypeMenu, -1, "bmRenderFxTypeMenu");
}

showSaveLoadMenu(id)
{
	new col[3];
	new szMenu[256];
	col = (gAccess[id] ? "\w" : "\d");
	
	//format the main menu
	format(szMenu, 256, gszSaveLoadMenu, gCurConfig, col, col, col, col);
	
	//show the block menu to the player
	show_menu(id, gKeysSaveLoadMenu, szMenu, -1, "bmSaveLoadMenu");
}

showAdminMenu(id)
{
	new col[3], szGodmode[2][5];
	new szMenu[256];
	col = (gAccess[id] ? "\w" : "\d");
	
	if (gGodmodeOn) {
		format(szGodmode[0], 4, "Remove");
		format(szGodmode[1], 4, "from");
	} else {
		format(szGodmode[0], 4, "Set");
		format(szGodmode[1], 4, "on");
	}
	
	//format the main menu
	format(szMenu, 256, gszAdminMenu, col, col, col, col, szGodmode[0], szGodmode[1], col);
	
	//show the block menu to the player
	show_menu(id, gKeysAdminMenu, szMenu, -1, "bmAdminMenu");
}

showPropertiesMenu(id) {
	new iKeys;
	
	if( !pev_valid( g_RenamingEnt[id] ) ) {
		iKeys = B8 | B9 | B0;
		show_menu(id, iKeys, gszPropertiesMenu2, -1, "bmPropertiesMenu");
	} else {
		iKeys = B1 | B4 | B8 | B9 | B0;
		new szMenu[256], col[3], szProps[ 128 ];
		
		new blockType = pev( g_RenamingEnt[id], pev_body );
		new szOnTopOnly[10];
		
		if (pev(g_RenamingEnt[id], pev_fixangle) == 0) formatex(szOnTopOnly, 9, "\rNo");
		else if (pev(g_RenamingEnt[id], pev_fixangle) == 1) formatex(szOnTopOnly, 9, "\yYes");
		else if (pev(g_RenamingEnt[id], pev_fixangle) == 2) formatex(szOnTopOnly, 9, "\rIgnored");
		
		col = (get_user_flags( id ) & BM_ADMIN_LEVEL ? "\w" : "\d");
		
		switch( blockType ) {
			case BM_SPEEDBOOST: {
				iKeys = B1 | B2 | B3 | B8 | B9 | B0;
				
				new Float:flProp1, Float:flProp2;
				pev( g_RenamingEnt[id], pev_fuser1, flProp1 );
				pev( g_RenamingEnt[id], pev_fuser2, flProp2 );
				
				format( szProps, sizeof( szProps ), "\r1. \wForward Speed: \r%i^n\r2. \wUpward Speed: \r%i^n", floatround( flProp1 ), floatround( flProp2 ) );
			}
			case BM_TRAMPOLINE: {
				iKeys = B1 | B3 | B8 | B9 | B0;
				
				new Float:flProp1;
				pev( g_RenamingEnt[id], pev_fuser1, flProp1 );
				
				format( szProps, sizeof( szProps ), "\r1. \wUpward Speed: \r%i^n", floatround( flProp1 ) );
			}
			case BM_DELAYEDBHOP: {
				iKeys = B1 | B3 | B8 | B9 | B0;
				
				new Float:flProp1;
				pev( g_RenamingEnt[id], pev_fuser1, flProp1 );
				
				format( szProps, sizeof( szProps ), "\r1. \wDelay before disappear: \r%.1f^n", flProp1 );
			}
			case BM_HEALER: {
				iKeys = B1 | B2 | B3 | B8 | B9 | B0;
							
				new Float:flProp1, Float:flProp2;
				pev( g_RenamingEnt[id], pev_fuser1, flProp1 );
				pev( g_RenamingEnt[id], pev_fuser2, flProp2 );
				
				format( szProps, sizeof( szProps ), "\r1. \wHealth Per Interval: \r%i^n\r2. \wInterval: \r%.1f^n", floatround( flProp1 ), flProp2 );
			}
			case BM_DAMAGE: {
				iKeys = B1 | B2 | B3 | B8 | B9 | B0;
				
				new Float:flProp1, Float:flProp2;
				pev( g_RenamingEnt[id], pev_fuser1, flProp1 );
				pev( g_RenamingEnt[id], pev_fuser2, flProp2 );
				
				format( szProps, sizeof( szProps ), "\r1. \wDamage Per Interval: \r%i^n\r2. \wInterval: \r%.1f^n", floatround( flProp1 ), flProp2 );
			}
			case BM_LOWGRAVITY: {
				iKeys = B1 | B3 | B8 | B9 | B0;
				
				new Float:flProp1;
				pev ( g_RenamingEnt[id], pev_fuser1, flProp1 );
				
				format( szProps, sizeof( szProps ), "\r1. \wGravity: \r%i^n", floatround( flProp1 * 800.0 ) );
			}
			case BM_STEALTH, BM_INVINCIBILITY, BM_BOOTSOFSPEED: {
				iKeys = B1 | B2 | B3 | B8 | B9 | B0;
				
				new Float:flProp1, Float:flProp2;
				pev( g_RenamingEnt[id], pev_fuser1, flProp1 );
				pev( g_RenamingEnt[id], pev_fuser2, flProp2 );
				
				format( szProps, sizeof( szProps ), "\r1. \wTime of usage: \r%i^n\r2. \wDelay After Usage: \r%i^n", floatround( flProp1 ), floatround( flProp2 ) );
			}
			case BM_MAGICCARPET: {
				iKeys = B1 | B3 | B8 | B9 | B0;
				
				new Float:flProp1;
				pev(g_RenamingEnt[id], pev_fuser1, flProp1);
				
				new szTeam[33];
				new iProp1 = floatround(flProp1);
				
				switch(iProp1) {
					case 1: format(szTeam, 32, "Terrorists \y(1)");
					case 2: format(szTeam, 32, "Counter-Terrorists \y(2)");
					case 3: format(szTeam, 32, "All \y(3)");
				}
				
				format(szProps, sizeof(szProps), "\r1. \wTeam: \r%s^n", szTeam);
			}
			case BM_WEAPON: {
				iKeys = B1 | B2 | B3 | B8 | B9 | B0;
				
				new szProp1[32], Float:flProp2;
				pev(g_RenamingEnt[id], pev_message, szProp1, 31);
				pev(g_RenamingEnt[id], pev_fuser2, flProp2);
				
				format( szProps, sizeof( szProps ), "\r1. \wWeapon: \r%s^n\r2. \wAmmo: \r%i^n", szProp1, floatround( flProp2 ) );
			}
			
			case BM_POINT: {
				iKeys = B1 | B2 | B3 | B8 | B9 | B0;
				
				new Float:flProp1, Float:flProp2;
				pev( g_RenamingEnt[id], pev_fuser1, flProp1 );
				pev( g_RenamingEnt[id], pev_fuser2, flProp2 );
				
				format( szProps, sizeof( szProps ), "\r1. \wKill-Points: \r%i^n\r2. \wHide-Points: \r%i^n", floatround( flProp1 ), floatround(flProp2) );
			}
			
			default: iKeys = B3 | B8 | B9 | B0;
		}
			
		format(szMenu, sizeof(szMenu), gszPropertiesMenu, gszBlockNames[blockType], szProps, szOnTopOnly);
		show_menu(id, iKeys, szMenu, -1, "bmPropertiesMenu");
	}
}

public handlePropertiesMenu(id, num) {
	switch (num) {
		case N1: {
			if (gAccess[id]) {
				g_SelectedProp[id] = 1;
				
				/*if (pev(g_RenamingEnt[id], pev_body) == BM_TRAIN) {
					new flOrigin[3];
					pev(id, pev_origin, flOrigin);
					set_pev(g_RenamingEnt[id], pev_vuser4, flOrigin);
					set_pev(g_RenamingEnt[id], pev_vuser3, flOrigin);
					
					showPropertiesMenu(id);
				} else*/
				cmdChangeValueCMD( id );
			}
		}
		case N2: {
			if (gAccess[id]) {
				g_SelectedProp[id] = 2;
				cmdChangeValueCMD( id );
			}
		}
		case N3: {
			new iProp3 = pev(g_RenamingEnt[id], pev_fixangle);
			
			if (iProp3 == 2)
				return PLUGIN_CONTINUE;
			
			if (iProp3 == 1)
				set_pev(g_RenamingEnt[id], pev_fixangle, 0);
			else
				set_pev(g_RenamingEnt[id], pev_fixangle, 1);
		}
		case N8: showRenderMenu(id);
		case N9: findNewBlock(id);
		case N0: {
			g_RenamingEnt[id] = 0;
			showMainMenu(id);
		}
	}
	
	if (num != N0 && num != N1 && num != N2 && num != N8)
		showPropertiesMenu(id);
	
	if (num == N1 && !pev_valid(g_RenamingEnt[id])) {
		g_RenamingEnt[id] = 0;
		showPropertiesMenu(id);
	}
	
	return PLUGIN_HANDLED;
}

findNewBlock(id) {
	if (gAccess[id]) {
		new ent, body;
		get_user_aiming(id, ent, body);
		
		if( isBlock(ent) ) {
			new grabber = pev(ent, pev_iuser2);
			
			if( grabber == 0 ) {
				new player = pev(ent, pev_iuser1);
				
				if( player == 0 ) {
					g_RenamingEnt[id] = ent;
				}
			} else
				client_print( id, print_chat, "%s Error happened :(", gszPrefix );
		} else
			client_print( id, print_chat, "%s Error: Only blocks allowed :(", gszPrefix );
	} else
		client_print( id, print_chat, "%s Error: You dont have access :(", gszPrefix );
}

public handleRenderMenu(id, num)
{
	switch (num)
	{
		case N1: { changeRenderMode(id); }
		case N2: { showRenderFxTypeMenu(id); }
		case N3: {
			if (gAccess[id]) {
				gRenderRed[id] += 10;

				if( gRenderRed[id] > 255 )
					gRenderRed[id] = 0;
			}
		}
		case N4: {
			if (gAccess[id]) {
				gRenderGreen[id] += 10;

				if( gRenderGreen[id] > 255 )
					gRenderGreen[id] = 0;
			}
		}
		case N5: {
			if (gAccess[id]) {
				gRenderBlue[id] += 10;

				if( gRenderBlue[id] > 255 )
					gRenderBlue[id] = 0;
			}
		}
		case N6: {
			if (gAccess[id]) {
				gRenderAmount[id] += 5;

				if( gRenderAmount[id] > 255 )
					gRenderAmount[id] = 0;
			}
		}
		case N9: { applyRender(id); }
		case N0: { showPropertiesMenu(id); }
	}
	
	if ( num != N2 && num != N0 )
		showRenderMenu(id);
}

public handleRenderFxTypeMenu(id, num) {
	switch (num) {
		case N1: {
			gSelectedRenderFxType[id] = kRenderFxNone;
			gSelectedRenderFxMsg[id] = "None";
		}
		case N2: {
			gSelectedRenderFxType[id] = kRenderFxGlowShell;
			gSelectedRenderFxMsg[id] = "Glow Shell";
		}
		case N3: {
			gSelectedRenderFxType[id] = kRenderFxPulseFast;
			gSelectedRenderFxMsg[id] = "Fast Pulse";
		}
		case N4: {
			gSelectedRenderFxType[id] = kRenderFxPulseFastWide;
			gSelectedRenderFxMsg[id] = "Fast Pulse Wide";
		}
		case N5: {
			gSelectedRenderFxType[id] = kRenderFxPulseSlow;
			gSelectedRenderFxMsg[id] = "Slow Pulse";
		}
		case N6: {
			gSelectedRenderFxType[id] = kRenderFxPulseSlowWide;
			gSelectedRenderFxMsg[id] = "Slow Pulse Wide";
		}
		case N7: {
			gSelectedRenderFxType[id] = kRenderFxHologram;
			gSelectedRenderFxMsg[id] = "Hologram";
		}
		case N8: {
			gSelectedRenderFxType[id] = kRenderFxStrobeFast;
			gSelectedRenderFxMsg[id] = "Strobe Fast";
		}
		case N9: {
			gSelectedRenderFxType[id] = kRenderFxStrobeSlow;
			gSelectedRenderFxMsg[id] = "Strobe Slow";
		}
		case N0: {
			showRenderMenu(id);
		}
	}
	if (num != N0)
		showRenderMenu(id);
}

public applyRender(id) {
	if (gAccess[id]) {
		new ent, body;
		get_user_aiming(id, ent, body);
		
		if( isBlock(ent) ) {
			new grabber = pev(ent, pev_iuser2);
			
			if(grabber == 0 || grabber == id) {
			//	new player = pev(ent, pev_iuser1);
				
			//	if (player == 0 || player == id)
			//	{
					// render gogo lamer
					
					new Float:flRenderColors[ 3 ];

					flRenderColors[0] = float( gRenderRed[id] );
					flRenderColors[1] = float( gRenderGreen[id] );
					flRenderColors[2] = float( gRenderBlue[id] );
					set_pev( ent, pev_renderfx, gSelectedRenderFxType[id]);
					set_pev( ent, pev_rendercolor, flRenderColors);
					set_pev( ent, pev_rendermode, gSelectedRenderType[id]);
					if( gSelectedRenderFxType[id] == kRenderFxGlowShell )
						set_pev( ent, pev_renderamt, 16.0 );
					else
						set_pev( ent, pev_renderamt, float( gRenderAmount[id] ) );
			//	}
			}
		} else
			client_print(id, print_chat, "Aim on a block to apply render");
	}
	
	return PLUGIN_HANDLED;
}

changeRenderMode(id)
{
	switch (gSelectedRenderType[id])
	{
		case kRenderNormal: {
			gSelectedRenderType[id] = kRenderTransAdd;
			gSelectedRenderMsg[id] = "Add";
		}
		case kRenderTransAdd: {
			gSelectedRenderType[id] = kRenderTransAlpha;
			gSelectedRenderMsg[id] = "Alpha";
		}
		case kRenderTransAlpha: {
			gSelectedRenderType[id] = kRenderNormal;
			gSelectedRenderMsg[id] = "Normal";
		}
	}
}

public handleMainMenu(id, num)
{
	switch (num)
	{
		case N1: { showBlockMenu(id); }
		case N2: { showTeleportMenu(id); }
		case N3: { showSaveLoadMenu(id); }
		case N4: { showAdminMenu(id); }
		case N6: { toggleNoclip(id); }
		case N7: { toggleGodmode(id); }
		case N8: { showPropertiesMenu(id); }
		case N9: { showOptionsMenu(id, 1); }
		case N0: { return; }
	}
	
	//selections 1, 2, 3, 4, 5 and 9 show different menus
	if (num != N1 && num != N2 && num != N3 && num != N4 && num!= N5 && num != N8 && num != N9)
	{
		//display menu again
		showMainMenu(id);
	}
}

public handleBlockMenu(id, num)
{
	switch (num)
	{
		case N1: { showBlockSelectionMenu(id); }
		case N2: { createBlockAiming(id, gSelectedBlockType[id]); }
		case N3: { convertBlockAiming(id, gSelectedBlockType[id]); }
		case N4: { deleteBlockAiming(id); }
		case N5: { rotateBlockAiming(id); }
		case N6: { toggleNoclip(id); }
		case N7: { toggleGodmode(id); }
		case N8: { changeBlockSize(id); }
		case N9: { showOptionsMenu(id, 2); }
		case N0: { showMainMenu(id); }
	}
	
	//selections 1, 9 and 0 show different menus
	if (num != N1 && num != N9 && num != N0)
	{
		//display menu again
		showBlockMenu(id);
	}
}

public handleBlockSelectionMenu(id, num)
{
	switch (num)
	{
		case N9:
		{
			//goto next block selection menu page
			++gBlockMenuPage[id];
			
			//make sure the player can't go above the maximum block selection page
			if (gBlockMenuPage[id] > gBlockMenuPagesMax)
			{
				gBlockMenuPage[id] = gBlockMenuPagesMax;
			}
			
			//show block selection menu again
			showBlockSelectionMenu(id);
		}
		
		case N0:
		{
			//goto previous block selection menu page
			--gBlockMenuPage[id];
			
			//show block menu if player goes back too far
			if (gBlockMenuPage[id] < 1)
			{
				showBlockMenu(id);
				gBlockMenuPage[id] = 1;
			}
			else
			{
				//show block selection menu again
				showBlockSelectionMenu(id);
			}
		}
		
		default:
		{
			//offset the num value using the players block selection page number
			num += (gBlockMenuPage[id] - 1) * 8;
			
			//if block number is within range
			if (num < gBlockMax)
			{
				gSelectedBlockType[id] = num;
				showBlockMenu(id);
			}
			else
			{
				showBlockSelectionMenu(id);
			}
		}
	}
}

public handleTeleportMenu(id, num)
{
	switch (num)
	{
		case N1: { createTeleportAiming(id, TELEPORT_START); }
		case N2: { createTeleportAiming(id, TELEPORT_END); }
		case N3: { swapTeleportAiming(id); }
		case N4: { deleteTeleportAiming(id); }
		case N5: { showTeleportPath(id); }
		case N6: { toggleNoclip(id); }
		case N7: { toggleGodmode(id); }
		case N9: { showOptionsMenu(id, 3); }
		case N0: { showMainMenu(id); }
	}
	
	//selections 9 and 0 show different menus
	if (num != N9 && num != N0)
	{
		showTeleportMenu(id);
	}
}

public handleOptionsMenu(id, num)
{
	switch (num)
	{
		case N1: { toggleSnapping(id); }
		case N2: { toggleSnappingGap(id); }
		case N3: { groupBlockAiming(id); }
		case N4: { groupClear(id); }
		case N5: { showChoiceMenu(id, CHOICE_DEL_BLOCKS, "Are you sure you want to erase all blocks on the map?"); }
		case N6: { showChoiceMenu(id, CHOICE_DEL_TELEPORTS, "Are you sure you want to erase all teleports on the map?"); }
		case N7: { saveBlocks(id); }
		case N8: { showChoiceMenu(id, CHOICE_LOAD, "Loading will erase all blocks and teleports, do you want to continue?"); }
		case N9: { showHelp(id); }
		
		case N0:  //back to previous menu
		{
			switch (gMenuBeforeOptions[id])
			{
				case 1: showMainMenu(id);
				case 2: showBlockMenu(id);
				case 3: showTeleportMenu(id);
				case 4: showSaveLoadMenu(id);
				case 5: showAdminMenu(id);
				
				//for some reason the players 'gMenuBeforeOptions' number is invalid
				default: log_amx("%sPlayer ID: %d has an invalid gMenuBeforeOptions: %d", gszPrefix, id, gMenuBeforeOptions[id]);
			}
		}
	}
	
	//these selections show a different menu
	if (num != N5 && num != N6 && num != N8 && num != N0)
	{
		//display menu again
		showOptionsMenu(id, gMenuBeforeOptions[id]);
	}
}

public handleAdminMenu(id, num) {
	switch (num) {
		case N1: {
			if (gAccess[id])
				ExecuteHam(Ham_CS_RoundRespawn, id);
		}
		case N2: cmdRevivePlayer(id);
		case N3: {
			if (gAccess[id]) {
				for (new i = 1; i <= gMaxPlayers; i++)
					ExecuteHam(Ham_CS_RoundRespawn, i);
			}
		}
		
		case N7: {
			if (gAccess[id]) {
				new szName[33];
				get_user_name(id, szName, 32);
				
				if (!gGodmodeOn) {
					set_user_godmode(0, 1);
					gGodmodeOn = true;
					client_print(0, print_chat, "%s %s set godmode on everyone", gszPrefix, szName);
				} else {
					set_user_godmode(0, 0);
					gGodmodeOn = false;
					client_print(0, print_chat, "%s %s removed godmode from everyone", gszPrefix, szName);
				}
			}
		}
		case N8: cmdGiveAccess(id);
		case N9: showOptionsMenu(id, 5);
		case N0: showMainMenu(id);
	}
	
	if (num == N1 && num == N3 && num == N7)
		showAdminMenu(id);
}

public handleChoiceMenu(id, num)
{
	switch (num)
	{
		case N1:	//YES
		{
			switch (gChoiceOption[id])
			{
				case CHOICE_LOAD: loadBlocks(id, 0, "default");
				case CHOICE_DEL_BLOCKS: deleteAllBlocks(id, true);
				case CHOICE_DEL_TELEPORTS: deleteAllTeleports(id, true);
				
				default:
				{
					log_amx("%sInvalid choice in handleChoiceMenu()", gszPrefix);
				}
			}
		}
	}
	
	//show options menu again
	showOptionsMenu(id, gMenuBeforeOptions[id]);
}

public handleSaveLoadMenu(id, num)
{
	new bool:isNotAdmin = false;
	switch (num)
	{
		case N1: saveBlocks(id);
		case N2: {
			if (gAccess[id]) {
				new szTitle[49];
				format(szTitle, 48, "Load Menu - Current: %s", gCurConfig);
				
				new loadMenu = menu_create(szTitle, "mnuLoad", 0);
				
				new szFileName[33], bool:display;
				new dir = open_dir(gDir, "", 0); // First file is always '.', right?
				
				while ( next_file(dir, szFileName, 32) )
				{
					if ( szFileName[0] == '.' )
					{
						continue;
					}
					
					replace(szFileName, 32, ".bm", "");
					display = true;
					menu_additem(loadMenu, szFileName, "");
				}
				close_dir(dir);
				
				menu_setprop(loadMenu, MPROP_EXITNAME, "Save/Load Menu");
				
				if ( display )
				{
					menu_display(id, loadMenu, 0);
					return PLUGIN_CONTINUE;
				}
				else
				{
					client_print(id, print_chat, "%s There are no configs to load!", gszPrefix);
					showSaveLoadMenu(id);
				}
			} else {
				isNotAdmin = true;
			}
		}
		case N3: {
			if (gAccess[id]) {
				client_print(id, print_chat, "%s Enter name for the new config", gszPrefix);
				client_cmd(id, "messagemode Enter_New_Config");
			}
		}
		case N4: {
			if ( !task_exists(TASK_ID_CONFIGVOTETIMER, 0) )
			{
				ConfigVote();
			}
			else
			{
				client_print(id, print_chat, "%s A vote is already started!", gszPrefix);
			}
		}
		case N9: showOptionsMenu(id, 4);
		case N0: showMainMenu(id);
	}
	
	if (isNotAdmin) showSaveLoadMenu(id);
	
	if (num != N2 && num != N4 && num != N9 && num != N0)
		showSaveLoadMenu(id);
	
	return PLUGIN_HANDLED;
}

public cmdNewConfig(id)
{
	if (!gAccess[id]) {
		client_print(id, print_chat, "%s You don't have access to do this", gszPrefix);
		return PLUGIN_HANDLED;
	}
	
	new szArg[33];
	read_argv(1, szArg, 32);
	
	if ( !strlen(szArg) )
	{
		return PLUGIN_HANDLED;
	}
	else if ( !IsStringAlphaNumeric(szArg) )
	{
		client_print(id, print_chat, "%s Config name must be alphanumeric.", gszPrefix);
		
		return PLUGIN_HANDLED;
	}
	
	new szPath[129];
	format(szPath, 128, "%s/%s.bm", gDir, szArg);
	
	if ( !file_exists(szPath) )
	{
		new f = fopen(szPath, "wt");
		fputs(f, "");
		fclose(f);
		
		new szName[32];
		get_user_name(id, szName, 31);
		
		client_print(0, print_chat, "%s %s created config '%s'.", gszPrefix, szName, szArg);
	}
	else
	{
		client_print(id, print_chat, "%s That config already exists!", gszPrefix);
	}
	
	return PLUGIN_HANDLED;
}

public mnuLoad(id, menu, item)
{
	if ( item != MENU_EXIT )
	{
		new szItem[33], _access, callback;
		menu_item_getinfo(menu, item, _access, "", 0, szItem, 32, callback);
		
		loadBlocks(id, 1, szItem);
		
		menu_destroy(menu);
		showSaveLoadMenu(id);
	} else {
		menu_destroy(menu);
		showSaveLoadMenu(id);
	}
}

/// PROPERTIES WTF!
///////////////////////////
public cmdChangeValueCMD ( id ) {
	if( pev_valid(g_RenamingEnt[id]) ) {
		new grabber = pev(g_RenamingEnt[id], pev_iuser2);
		
		if( grabber == 0 ) {
			new player = pev(g_RenamingEnt[id], pev_iuser1);
			
			if( player == 0 ) {
				if (pev(g_RenamingEnt[id], pev_body, BM_WEAPON))
					client_print( id, print_chat, "%s Enter new weapon.", gszPrefix );
				else
					client_print( id, print_chat, "%s Enter new value.", gszPrefix );
				client_cmd( id, "messagemode _________ENTER_VALUE" );
				client_cmd( id, "spk fvox/blip" );
			}
		} else
			client_print( id, print_chat, "%s Error happened :(", gszPrefix );
	} else
		client_print( id, print_chat, "%s Error: Block isnt valid :(", gszPrefix );
}

public cmdChangeValue( id, level, cid ) {
	if (!gAccess[id]) {
		client_print(id, print_chat, "%s You don't have access to do this", gszPrefix);
		return PLUGIN_HANDLED;
	}
	
	if ( !pev_valid(g_RenamingEnt[id]) ) {
		client_print( id, print_chat, "%s^x01 Error: Your entity is not valid^x03 :(", gszPrefix );
		showPropertiesMenu(id);
		return PLUGIN_HANDLED;
	}
	
	new Float:flNewValue, szArg[32];
	read_argv(1, szArg, 31);
	flNewValue = str_to_float( szArg );
	
	new iProp;
	switch( g_SelectedProp[id] ) {
		case 1: iProp = pev_fuser1;
		case 2: iProp = pev_fuser2;
	}
	
	new blockType = pev( g_RenamingEnt[id], pev_body );
	
	if (blockType == BM_WEAPON && g_SelectedProp[id] == 1) {
		set_pev(g_RenamingEnt[id], pev_message, szArg);
		client_print( id, print_chat, "%s New weapon! %s.", gszPrefix, szArg );
		
		showPropertiesMenu(id);
		return PLUGIN_HANDLED;
	}
	
	switch( blockType ) {
		case BM_TRAMPOLINE: {
			if( flNewValue > 1200.0 )
				flNewValue = 1200.0;
		
			if( flNewValue < 200.0 )
				flNewValue = 200.0;
		}
		case BM_SPEEDBOOST: {
			if( flNewValue > 1200.0 )
				flNewValue = 1200.0;
			
			if( flNewValue < 200.0 )
				flNewValue = 200.0;
		}
		case BM_HEALER: {
			switch( g_SelectedProp[id] ) {
				case 1: {
					if( flNewValue > 100.0 )
						flNewValue = 100.0;
					
					if( flNewValue < 1.0 )
						flNewValue = 1.0;
				}
				case 2: {
					if( flNewValue > 5.0 )
						flNewValue = 5.0;
					
					if( flNewValue < 0.1 )
						flNewValue = 0.1;
				}
			}
		}
		case BM_DELAYEDBHOP: {
			if( flNewValue > 3.0 )
				flNewValue = 3.0;
			
			if( flNewValue < 0.2 )
				flNewValue = 0.2;
		}
		case BM_DAMAGE: {
			switch( g_SelectedProp[id] ) {
				case 1: {
					if( flNewValue > 15.0 )
						flNewValue = 15.0;
					
					if( flNewValue < 1.0 )
						flNewValue = 1.0;
				}
				case 2: {
					if( flNewValue > 5.0 )
						flNewValue = 5.0;
					
					if( flNewValue < 0.1 )
						flNewValue = 0.1;
				}
			}
		}
		case BM_LOWGRAVITY: {
			if (flNewValue > 600.0 )
				flNewValue = 600.0;
			
			if (flNewValue < 80.0)
				flNewValue = 80.0;
		}
		/*case BM_MAGICCARPET: {
			if (flNewValue > 3.0)
				flNewValue = 3.0;
			
			if (flNewValue < 1.0)
				flNewValue = 1.0;
		}*/
		case BM_STEALTH, BM_INVINCIBILITY, BM_BOOTSOFSPEED: {
			switch( g_SelectedProp[id] ) {
				case 1: {
					if( flNewValue > 20.0 )
						flNewValue = 20.0;
					
					if( flNewValue < 5.0 )
						flNewValue = 5.0;
				}
				case 2: {
					if( flNewValue > 120.0 )
						flNewValue = 120.0;
					
					if( flNewValue < 25.0 )
						flNewValue = 25.0;
				}
			}
		}
		case BM_WEAPON: {
			if (flNewValue > 10.0)
				flNewValue = 10.0;
			
			if (flNewValue < 1.0)
				flNewValue = 1.0;
		}
		case BM_POINT: {
			if (flNewValue > 100.0)
				flNewValue = 100.0;
			
			if (flNewValue < 5.0)
				flNewValue = 5.0;
		}
		/*case BM_TRAIN: {
			if( g_SelectedProp[id] == 2 ) {
				if( flNewValue > 300.0 )
					flNewValue = 300.0;
				
				if( flNewValue < 20.0 ) // pff uber slow x'D
					flNewValue = 20.0;
			}
		}*/
	}
	
	if ( blockType == BM_LOWGRAVITY )
		set_pev( g_RenamingEnt[id], iProp, flNewValue / 800.0 );
	else
		set_pev( g_RenamingEnt[id], iProp, flNewValue);
	
	showPropertiesMenu(id);
	
	switch( blockType ) {
		case BM_DELAYEDBHOP: client_print( id, print_chat, "%s New value of propertie! %.1f.", gszPrefix, flNewValue );
		case BM_HEALER: {
			switch( g_SelectedProp[id] ) {
				case 1: client_print( id, print_chat, "%s New value of propertie! %i.", gszPrefix, floatround( flNewValue ) );
				case 2: client_print( id, print_chat, "%s New value of propertie! %.1f.", gszPrefix, flNewValue );
			}
		}
		case BM_DAMAGE: {
			switch( g_SelectedProp[id] ) {
				case 1: client_print( id, print_chat, "%s New value of propertie! %i.", gszPrefix, floatround( flNewValue ) );
				case 2: client_print( id, print_chat, "%s New value of propertie! %.1f.", gszPrefix, flNewValue );
			}
		}
		default: client_print( id, print_chat, "%s New value of propertie! %i.", gszPrefix, floatround( flNewValue ) );
	}
	
	return PLUGIN_HANDLED;
}

public cmdGiveAccess( id ) {
	if(get_user_flags(id) & BM_ADMIN_LEVEL) {
		client_print( id, print_chat, "%s Enter name of the player you want to give access to.", gszPrefix );
		client_cmd( id, "messagemode _________ENTER_NAME" );
		client_cmd( id, "spk fvox/blip" );
	} else
		showAdminMenu(id);
}

public handleGiveAccess( id, level, cid ) {
	new szArg[32];
	read_argv(id, szArg, 31);
	
	new iPlayer = cmd_target( id, szArg, 4 );
	
	if (iPlayer) {
		if (iPlayer == id) {
			client_print(id, print_chat, "%s You can't give yourself access since you already have", gszPrefix);
			showAdminMenu(id);
			return PLUGIN_HANDLED;
		}
		
		gAccess[iPlayer] = true;
		
		new szName[33], szName2[33];
		get_user_name(id, szName, 32);
		get_user_name(iPlayer, szName2, 32);
		
		client_print(0, print_chat, "%s %s gave %s access to SCM", gszPrefix, szName, szName2);
	} else
		client_print(id, print_chat, "%s Couldn't find player named %s", gszPrefix, szArg);
	
	showAdminMenu(id);
	return PLUGIN_HANDLED;
}

public cmdRevivePlayer( id ) {
	if(gAccess[id]) {
		client_print( id, print_chat, "%s Enter name of the player you want to revive.", gszPrefix );
		client_cmd( id, "messagemode __________ENTER_NAME" );
		client_cmd( id, "spk fvox/blip" );
	} else
		showAdminMenu(id);
}

public handleRevivePlayer( id, level, cid ) {
	new szArg[32];
	read_argv(id, szArg, 31);
	
	new iPlayer = cmd_target( id, szArg, 4 );
	
	if (iPlayer) {
		if (iPlayer == id) {
			client_print(id, print_chat, "%s Revive yourself with button one", gszPrefix);
			showAdminMenu(id);
			return PLUGIN_HANDLED;
		}
		
		ExecuteHam(Ham_CS_RoundRespawn, iPlayer);
		
		new szName[33], szName2[33];
		get_user_name(id, szName, 32);
		get_user_name(iPlayer, szName2, 32);
		
		client_print(0, print_chat, "%s %s revived %s", gszPrefix, szName, szName2);
	} else
		client_print(id, print_chat, "%s Couldn't find player named %s", gszPrefix, szArg);
	
	showAdminMenu(id);
	return PLUGIN_HANDLED;
}

toggleGodmode(id)
{
	//make sure player has access to this command
	if (gAccess[id])
	{
		//if player has godmode
		if (get_user_godmode(id))
		{
			//turn off godmode for player
			set_user_godmode(id, 0);
			gbAdminGodmode[id] = false;
		}
		else
		{
			//turn on godmode for player
			set_user_godmode(id, 1);
			gbAdminGodmode[id] = true;
		}
	}
}

toggleNoclip(id)
{
	//make sure player has access to this command
	if (gAccess[id])
	{
		//if player has noclip
		if (get_user_noclip(id))
		{
			//turn off noclip for player
			set_user_noclip(id, 0);
			gbAdminNoclip[id] = false;
		}
		else
		{
			//turn on noclip for player
			set_user_noclip(id, 1);
			gbAdminNoclip[id] = true;
		}
	}
}

changeBlockSize(id)
{
	switch (gBlockSize[id])
	{
		case SMALL: gBlockSize[id] = NORMAL;
		case NORMAL: gBlockSize[id] = LARGE;
		case LARGE: gBlockSize[id] = POLE;
		case POLE: gBlockSize[id] = SMALL;
	}
}

toggleSnapping(id)
{
	//make sure player has access to this command
	if (gAccess[id])
	{
		gbSnapping[id] = !gbSnapping[id];
	}
}

toggleSnappingGap(id)
{
	//make sure player has access to this command
	if (gAccess[id])
	{
		//increment this players snapping gap by 5
		gfSnappingGap[id] += 4.0;
		
		//if this players snapping gap gets too big then loop it back to 0
		if (gfSnappingGap[id] > 40.0)
		{
			gfSnappingGap[id] = 0.0;
		}
	}
}

showHelp(id)
{
	//get cvar values
	new szHelpText[1600];
	
	new Telefrags = get_cvar_num("bm_telefrags");
	new Float:fDamageAmount = get_cvar_float("bm_damageamount");
	new Float:fHealAmount = get_cvar_float("bm_healamount");
	new Float:fInvincibleTime = get_cvar_float("bm_invincibletime");
	new Float:fInvincibleCooldown = get_cvar_float("bm_invinciblecooldown");
	new Float:fStealthTime = get_cvar_float("bm_stealthtime");
	new Float:fStealthCooldown = get_cvar_float("bm_stealthcooldown");
	new Float:fBootsOfSpeedTime = get_cvar_float("bm_bootsofspeedtime");
	new Float:fBootsOfSpeedCooldown = get_cvar_float("bm_bootsofspeedcooldown");
	new TeleportSound = get_cvar_num("bm_teleportsound");
	
	//format the help text
	format(szHelpText, sizeof(szHelpText), gszHelpText, Telefrags, fDamageAmount, fHealAmount, fInvincibleTime, fInvincibleCooldown, fStealthTime, fStealthCooldown, fBootsOfSpeedTime, fBootsOfSpeedCooldown, TeleportSound);
	
	//show the help
	show_motd(id, szHelpText, gszHelpTitle);
}

showTeleportPath(id)
{
	//get the entity the player is aiming at
	new ent, body;
	get_user_aiming(id, ent, body);
	
	//if entity found is a teleport
	if (isTeleport(ent))
	{
		//get other side of teleport
		new tele = entity_get_int(ent, EV_INT_iuser1);
		
		//if there is another end to the teleport
		if (tele)
		{
			//get origins of the start and end teleport entities
			new life = 50;
			new Float:vOrigin1[3];
			new Float:vOrigin2[3];
			entity_get_vector(ent, EV_VEC_origin, vOrigin1);
			entity_get_vector(tele, EV_VEC_origin, vOrigin2);
			
			//draw a line in between the 2 origins
			drawLine(vOrigin1, vOrigin2, life);
			
			//get the distance between the points
			new Float:fDist = get_distance_f(vOrigin1, vOrigin2);
			
			//notify that a line has been drawn between the start and end of the teleport
			client_print(id, print_chat, "%sA line has been drawn to show the teleport path. Distance: %f units.", gszPrefix, fDist);
		}
	}
}

/* GROUPING BLOCKS */
groupBlockAiming(id)
{
	//make sure player has access to this command
	if (gAccess[id])
	{
		//get the entity the player is aiming at
		new ent, body;
		get_user_aiming(id, ent, body);
		
		//is entity is a block
		if (isBlock(ent))
		{
			//get whether or not block is already being grouped
			new player = entity_get_int(ent, EV_INT_iuser1);
			
			//if block is not in a group
			if (player == 0)
			{
				//increment group value
				++gGroupCount[id];
				
				//add this entity to the players group
				gGroupedBlocks[id][gGroupCount[id]] = ent;
				
				//set the block so it is now 'being grouped'
				groupBlock(id, ent);
				
			}
			//if block is in this players group
			else if (player == id)
			{
				//remove block from being grouped
				groupRemoveBlock(ent);
			}
			//if another player has the block grouped
			else
			{
				//get id and name of who has the block grouped
				new szName[32];
				new player = entity_get_int(ent, EV_INT_iuser1);
				get_user_name(player, szName, 32);
				
				//notify player who the block is being grouped by
				client_print(id, print_chat, "%sBlock is already in a group by: %s", gszPrefix, szName);
			}
		}
	}
}

groupBlock(id, ent)
{
	//if entity is valid
	if (is_valid_ent(ent))
	{
		//if id passed in is a player
		if (id > 0 && id <= 32)
		{
			//set block so it is now being grouped
			entity_set_int(ent, EV_INT_iuser1, id);
		}
		
		// An uber render fix
		new Float:flRenderColor[ 3 ], Float:flRenderAmt, iRenderFX, iRenderMode;
		iRenderFX       = pev( ent, pev_renderfx );
		iRenderMode     = pev( ent, pev_rendermode );
		pev( ent, pev_rendercolor, flRenderColor );
		pev( ent, pev_renderamt, flRenderAmt );
		
		set_pev( ent, pev_speed, flRenderAmt );
		set_pev( ent, pev_oldorigin, flRenderColor );
		set_pev( ent, pev_euser1, iRenderFX );
		set_pev( ent, pev_euser2, iRenderMode );
		
		//make block glow red to show it is grouped
		set_rendering(ent, kRenderFxGlowShell, 255, 0, 0, kRenderNormal, 16);
	}
}

groupRemoveBlock(ent)
{
	//make sure entity is a block
	if (isBlock(ent))
	{
		//remove block from being grouped (stays in players gGroupedBlocks[id][] array
		entity_set_int(ent, EV_INT_iuser1, 0);
		
		new Float:flRenderColor[3], Float:flRenderAmt, iRenderFX, iRenderMode;
		
		iRenderFX       = pev( ent, pev_euser1 );
		iRenderMode     = pev( ent, pev_euser2 );
		pev( ent, pev_oldorigin, flRenderColor );
		pev( ent, pev_speed, flRenderAmt );
			
		// Remove our render temporary information
		set_pev( ent, pev_speed, 0.0 );
		set_pev( ent, pev_oldorigin, { 0.0, 0.0, 0.0 } );
		set_pev( ent, pev_euser1, 0 );
		set_pev( ent, pev_euser2, 0 );
		
		//get block type
		new blockType = entity_get_int(ent, EV_INT_body);
		
		//set rendering on block
		set_block_rendering(ent, gRender[blockType], gRed[blockType], gGreen[blockType], gBlue[blockType], gAlpha[blockType]);
		
		set_pev( ent, pev_renderamt, flRenderAmt );
		set_pev( ent, pev_rendercolor, flRenderColor );
		set_pev( ent, pev_renderfx, iRenderFX );
		set_pev( ent, pev_rendermode , iRenderMode );
	}
}

groupClear(id)
{
	new blockCount = 0;
	new blocksDeleted = 0;
	new block;
	
	//remove all players blocks from being grouped
	for (new i = 0; i <= gGroupCount[id]; ++i)
	{
		block = gGroupedBlocks[id][i];
		
		//if block is in this players group
		if (isBlockInGroup(id, block))
		{
			//if block is stuck
			if (isBlockStuck(block))
			{
				//delete the stuck block
				deleteBlock(block);
				
				//count how many blocks have been deleted
				++blocksDeleted;
			}
			else
			{
				//remove block from being grouped
				groupRemoveBlock(block);
				
				//count how many blocks have been removed from group
				++blockCount;
			}
		}
	}
	
	//set players group count to 0
	gGroupCount[id] = 0;
	
	//if player is connected
	if (is_user_connected(id))
	{
		//if some blocks were deleted
		if (blocksDeleted > 0)
		{
			//notify player how many blocks were cleared from group and deleted
			client_print(id, print_chat, "%sRemoved %d blocks from group, deleted %d stuck blocks", gszPrefix, blockCount, blocksDeleted);
		}
		else
		{
			//notify player how many blocks were cleared from group
			client_print(id, print_chat, "%sRemoved %d blocks from group", gszPrefix, blockCount);
		}
	}
}

/* BLOCK & TELEPORT OPERATIONS */
moveGrabbedEntity(id, Float:vMoveTo[3] = {0.0, 0.0, 0.0})
{
	new iOrigin[3], iLook[3];
	new Float:fOrigin[3], Float:fLook[3], Float:fDirection[3], Float:fLength;
	
	get_user_origin(id, iOrigin, 1);		//Position from eyes (weapon aiming)
	get_user_origin(id, iLook, 3);			//End position from eyes (hit point for weapon)
	IVecFVec(iOrigin, fOrigin);
	IVecFVec(iLook, fLook);
	
	fDirection[0] = fLook[0] - fOrigin[0];
	fDirection[1] = fLook[1] - fOrigin[1];
	fDirection[2] = fLook[2] - fOrigin[2];
	fLength = get_distance_f(fLook, fOrigin);
	
	if (fLength == 0.0) fLength = 1.0;		//avoid division by 0
	
	//calculate the position to move the block
	vMoveTo[0] = (fOrigin[0] + fDirection[0] * gfGrablength[id] / fLength) + gvGrabOffset[id][0];
	vMoveTo[1] = (fOrigin[1] + fDirection[1] * gfGrablength[id] / fLength) + gvGrabOffset[id][1];
	vMoveTo[2] = (fOrigin[2] + fDirection[2] * gfGrablength[id] / fLength) + gvGrabOffset[id][2];
	vMoveTo[2] = float(floatround(vMoveTo[2], floatround_floor));
	
	//move the block and its sprite (if it has one)
	moveEntity(id, gGrabbed[id], vMoveTo, true);
}

moveEntity(id, ent, Float:vMoveTo[3], bool:bDoSnapping)
{
	//if entity is a block
	if (isBlock(ent))
	{
		//do snapping for entity if snapping boolean passed in is true
		if (bDoSnapping)
		{
			doSnapping(id, ent, vMoveTo);
		}
		
		//set the position of the block
		entity_set_origin(ent, vMoveTo);
		
		//get the sprite that sits above the block (if any)
		new sprite = entity_get_int(ent, EV_INT_iuser3);
		
		//if sprite entity is valid
		if (sprite)
		{
			//get size of block
			new Float:vSizeMax[3];
			entity_get_vector(ent, EV_VEC_maxs, vSizeMax);
			
			//move the sprite onto the top of the block
			vMoveTo[2] += vSizeMax[2] + 0.15;
			entity_set_origin(sprite, vMoveTo);
		}
	}
	else
	{
		//set the position of the entity
		entity_set_origin(ent, vMoveTo);
	}
}

/* TELEPORTS */
createTeleportAiming(const id, const teleportType)
{
	//make sure player has access to this command
	if (gAccess[id])
	{
		//get where player is aiming for origin of teleport entity
		new pOrigin[3], Float:vOrigin[3];
		get_user_origin(id, pOrigin, 3);
		IVecFVec(pOrigin, vOrigin);
		vOrigin[2] += gfTeleportZOffset;
		
		//create the teleport of the given type
		createTeleport(id, teleportType, vOrigin);
	}
}

createTeleport(const id, const teleportType, Float:vOrigin[3])
{
	new ent = create_entity(gszInfoTarget);
	
	if (is_valid_ent(ent))
	{
		switch (teleportType)
		{
			case TELEPORT_START:
			{
				//if player has already created a teleport start entity then delete it
				if (gTeleportStart[id])
				{
					remove_entity(gTeleportStart[id]);
				}
				
				//set teleport properties
				entity_set_string(ent, EV_SZ_classname, gszTeleportStartClassname);
				entity_set_int(ent, EV_INT_solid, SOLID_BBOX);
				entity_set_int(ent, EV_INT_movetype, MOVETYPE_NONE);
				entity_set_model(ent, gszTeleportSpriteStart);
				entity_set_size(ent, gfTeleportSizeMin, gfTeleportSizeMax);
				entity_set_origin(ent, vOrigin);
				
				//set the rendermode and transparency
				entity_set_int(ent, EV_INT_rendermode, 5);	//rendermode
				entity_set_float(ent, EV_FL_renderamt, 255.0);	//visable 
				
				//set task for animating sprite
				new params[2];
				params[0] = ent;
				params[1] = gTeleportStartFrames;
				set_task(0.1, "taskSpriteNextFrame", TASK_SPRITE + ent, params, 2, "b");
				
				//store teleport start entity to a global variable so it can be linked to the end entity 
				gTeleportStart[id] = ent;
			}
			
			case TELEPORT_END:
			{
				//make sure there is a teleport start entity
				if (gTeleportStart[id])
				{
					//set teleport properties
					entity_set_string(ent, EV_SZ_classname, gszTeleportEndClassname);
					entity_set_int(ent, EV_INT_solid, SOLID_BBOX);
					entity_set_int(ent, EV_INT_movetype, MOVETYPE_NONE);
					entity_set_model(ent, gszTeleportSpriteEnd);
					entity_set_size(ent, gfTeleportSizeMin, gfTeleportSizeMax);
					entity_set_origin(ent, vOrigin);
					
					//set the rendermode and transparency
					entity_set_int(ent, EV_INT_rendermode, 5);	//rendermode
					entity_set_float(ent, EV_FL_renderamt, 255.0);	//visable 
					
					//link up teleport start and end entities
					entity_set_int(ent, EV_INT_iuser1, gTeleportStart[id]);
					entity_set_int(gTeleportStart[id], EV_INT_iuser1, ent);
					
					//set task for animating sprite
					new params[2];
					params[0] = ent;
					params[1] = gTeleportEndFrames;
					set_task(0.1, "taskSpriteNextFrame", TASK_SPRITE + ent, params, 2, "b");
					
					//indicate that this player has no teleport start entity waiting for an end
					gTeleportStart[id] = 0;
				}
				else
				{
					//delete entity that was created because there is no start entity
					remove_entity(ent);
				}
			}
		}
	}
	else
	{
		log_amx("%sCouldn't create 'env_sprite' entity", gszPrefix);
	}
}

swapTeleportAiming(id)
{
	//make sure player has access to this command
	if (gAccess[id])
	{
		//get entity that player is aiming at
		new ent, body;
		get_user_aiming(id, ent, body, 9999);
		
		//swap teleport start and destination
		if (isTeleport(ent))
		{
			swapTeleport(id, ent);
		}
	}
}

swapTeleport(id, ent)
{
	new Float:vOriginEnt[3];
	new Float:vOriginTele[3];
	
	//get the other end of the teleport
	new tele = entity_get_int(ent, EV_INT_iuser1);
	
	//if the teleport has another side
	if (is_valid_ent(tele))
	{
		//get teleport properties
		entity_get_vector(ent, EV_VEC_origin, vOriginEnt);
		entity_get_vector(tele, EV_VEC_origin, vOriginTele);
		
		new szClassname[32];
		entity_get_string(ent, EV_SZ_classname, szClassname, 32);
		
		//delete old teleport
		deleteTeleport(id, ent);
		
		//create new teleport at opposite positions
		if (equal(szClassname, gszTeleportStartClassname))
		{
			createTeleport(id, TELEPORT_START, vOriginTele);
			createTeleport(id, TELEPORT_END, vOriginEnt);
		}
		else if (equal(szClassname, gszTeleportEndClassname))
		{
			createTeleport(id, TELEPORT_START, vOriginEnt);
			createTeleport(id, TELEPORT_END, vOriginTele);
		}
	}
	else
	{
		//tell player they cant swap because its only 1 sided
		client_print(id, print_chat, "%sCan't swap teleport positions", gszPrefix);
	}
}

deleteTeleportAiming(id)
{
	//make sure player has access to this command
	if (gAccess[id])
	{
		//get entity that player is aiming at
		new ent, body;
		get_user_aiming(id, ent, body, 9999);
		
		//delete block that player is aiming at
		new bool:deleted = deleteTeleport(id, ent);
		
		if (deleted)
		{
			client_print(id, print_chat, "%sTeleport deleted!", gszPrefix);
		}
	}
}

bool:deleteTeleport(id, ent)
{
	//if entity is a teleport then delete both the start and the end of the teleport
	if (isTeleport(ent))
	{
		//get entity id of the other side of the teleport
		new tele = entity_get_int(ent, EV_INT_iuser1);
		
		//clear teleport start entity if it was just deleted
		if (gTeleportStart[id] == ent || gTeleportStart[id] == tele)
		{
			gTeleportStart[id] = 0;
		}
		
		//remove tasks that exist to animate the teleport sprites
		if (task_exists(TASK_SPRITE + ent))
		{
			remove_task(TASK_SPRITE + ent);
		}
		
		if (task_exists(TASK_SPRITE + tele))
		{
			remove_task(TASK_SPRITE + tele);
		}
		
		//delete both the start and end positions of the teleporter
		if (tele)
		{
			remove_entity(tele);
		}
		
		remove_entity(ent);
		
		//delete was deleted
		return true;
	}
	
	//teleport was not deleted
	return false;
}

/* OPTIONS */
deleteAllBlocks(id, bool:bNotify)
{
	//make sure player has access to this command
	if (gAccess[id])
	{
		new bool:bDeleted;
		new blockCount = 0;
		new ent = -1;
		
		//find all blocks in the map
		while ((ent = find_ent_by_class(ent, gszBlockClassname)))
		{
			//delete the block
			bDeleted = deleteBlock(ent);
			
			//if block was successfully deleted
			if (bDeleted)
			{
				//increment counter for how many blocks have been deleted
				++blockCount;
			}
		}
		
		//if some blocks were deleted
		if (blockCount > 0)
		{
			//get players name
			new szName[32];
			get_user_name(id, szName, 32);
			
			//iterate through all players
			for (new i = 1; i <= 32; ++i)
			{
				//make sure nobody is grabbing a block because they've all been deleted!
				gGrabbed[id] = 0;
				
				//make sure player is connected
				if (is_user_connected(i))
				{
					//notify all admins that the player deleted all the blocks
					if (bNotify && get_user_flags(i) & BM_ADMIN_LEVEL)
					{
						client_print(i, print_chat, "%s'%s' deleted all the blocks from the map. Total blocks: %d", gszPrefix, szName, blockCount);
					}
				}
			}
		}
	}
}

deleteAllTeleports(id, bool:bNotify)
{
	//make sure player has access to this command
	if (gAccess[id])
	{
		new bool:bDeleted;
		new teleCount = 0;
		new ent = -1;
		
		//find all teleport start entities in the map
		while ((ent = find_ent_by_class(ent, gszTeleportStartClassname)))
		{
			//delete the teleport
			bDeleted = deleteTeleport(id, ent);
			
			//if teleport was successfully deleted
			if (bDeleted)
			{
				//increment counter for how many teleports have been deleted
				++teleCount;
			}
		}
		
		//if some teleports were deleted
		if (teleCount > 0)
		{
			//get players name
			new szName[32];
			get_user_name(id, szName, 32);
			
			//iterate through all players
			for (new i = 1; i <= 32; ++i)
			{
				//make sure nobody has a teleport start set
				gTeleportStart[id] = 0;
				
				//make sure player is connected
				if (is_user_connected(i))
				{
					//notify all admins that the player deleted all the teleports
					if (bNotify && get_user_flags(i) & BM_ADMIN_LEVEL)
					{
						client_print(i, print_chat, "%s'%s' deleted all the teleports from the map. Total teleports: %d", gszPrefix, szName, teleCount);
					}
				}
			}
		}
	}
}

/***** BLOCKS *****/
createBlockAiming(const id, const blockType)
{
	//make sure player has access to this command
	if (gAccess[id])
	{
		new origin[3];
		new Float:vOrigin[3];
		
		//get the origin of the player and add Z offset
		get_user_origin(id, origin, 3);
		IVecFVec(origin, vOrigin);
		vOrigin[2] += gfBlockSizeMaxForZ[2];
		
		//create the block
		createBlock(id, blockType, vOrigin, Z, gBlockSize[id]);
	}
}

createBlock(const id, const blockType, Float:vOrigin[3], const axis, const size)
{
	new ent = create_entity(gszInfoTarget);
	
	//make sure entity was created successfully
	if (is_valid_ent(ent))
	{
		//set block properties
		entity_set_string(ent, EV_SZ_classname, gszBlockClassname);
		entity_set_int(ent, EV_INT_solid, SOLID_BBOX);
		entity_set_int(ent, EV_INT_movetype, MOVETYPE_NONE);
		
		new Float:vSizeMin[3];
		new Float:vSizeMax[3];
		new Float:vAngles[3];
		new Float:fScale;
		new szBlockModel[256];
		
		//set mins, maxs and angles depending on axis
		switch (axis)
		{
			case X:
			{
				if (size == POLE)
				{
					vSizeMin = gfPoleSizeMinForX;
					vSizeMax = gfPoleSizeMaxForX;
				}
				else
				{
					vSizeMin = gfBlockSizeMinForX;
					vSizeMax = gfBlockSizeMaxForX;
				}
				
				vAngles[0] = 90.0;
			}
			
			case Y:
			{
				if (size == POLE)
				{
					vSizeMin = gfPoleSizeMinForY;
					vSizeMax = gfPoleSizeMaxForY;
				}
				else
				{
					vSizeMin = gfBlockSizeMinForY;
					vSizeMax = gfBlockSizeMaxForY;
				}
				
				vAngles[0] = 90.0;
				vAngles[2] = 90.0;
			}
			
			case Z:
			{
				if (size == POLE)
				{
					vSizeMin = gfPoleSizeMinForZ;
					vSizeMax = gfPoleSizeMaxForZ;
				}
				else
				{
					vSizeMin = gfBlockSizeMinForZ;
					vSizeMax = gfBlockSizeMaxForZ;
				}
				
				vAngles = gfDefaultBlockAngles;
			}
		}
		
		//set block model name and scale depending on size
		switch (size)
		{
			case SMALL:
			{
				setBlockModelNameSmall(szBlockModel, gszBlockModels[blockType], 256);
				fScale = SCALE_SMALL;
			}
			
			case NORMAL:
			{
				szBlockModel = gszBlockModels[blockType];
				fScale = SCALE_NORMAL;
			}
			
			case LARGE:
			{
				setBlockModelNameLarge(szBlockModel, gszBlockModels[blockType], 256);
				fScale = SCALE_LARGE;
			}
			
			case POLE:
			{
				setBlockModelNamePole(szBlockModel, gszBlockModels[blockType], 256);
			}
		}
		
		if (size != POLE)
		{
			//adjust size min/max vectors depending on scale
			for (new i = 0; i < 3; ++i)
			{
				if (vSizeMin[i] != 4.0 && vSizeMin[i] != -4.0)
				{
					vSizeMin[i] *= fScale;
				}
				
				if (vSizeMax[i] != 4.0 && vSizeMax[i] != -4.0)
				{
					vSizeMax[i] *= fScale;
				}
			}
		}
		
		//if it's a valid block type
		if (blockType >= 0 && blockType < gBlockMax)
		{
			entity_set_model(ent, szBlockModel);
		}
		else
		{
			entity_set_model(ent, gszBlockModelDefault);
		}
		
		entity_set_vector(ent, EV_VEC_angles, vAngles);
		entity_set_size(ent, vSizeMin, vSizeMax);
		entity_set_int(ent, EV_INT_body, blockType);
		
		if (blockType == BM_WEAPON)
			set_pev(ent, pev_message, "fiveseven");
		else
			set_pev(ent, pev_fuser1, gszDefaultProp1[blockType]);
		
		set_pev(ent, pev_fuser2, gszDefaultProp2[blockType]);
		set_pev(ent, pev_fixangle, gszDefaultProp3[blockType]);
		
		//if a player is creating the block
		if (id > 0 && id <= 32)
		{
			//do snapping for new block
			doSnapping(id, ent, vOrigin);
		}
		
		//set origin of new block
		entity_set_origin(ent, vOrigin);
		
		//if blocktype is magic carpet
		if( blockType == BM_MAGICCARPET ) {
			set_pev(ent, pev_movetype, MOVETYPE_FLY);
			set_pev(ent, pev_v_angle, vOrigin); // Original Origin
		}
		
		//set rendering on block
		set_block_rendering(ent, gRender[blockType], gRed[blockType], gGreen[blockType], gBlue[blockType], gAlpha[blockType]);
		
		return ent;
	}
	
	return 0;
}

convertBlockAiming(id, const convertTo)
{
	//make sure player has access to this command
	if (gAccess[id])
	{
		//get entity that player is aiming at
		new ent, body;
		get_user_aiming(id, ent, body);
		
		//if player is aiming at a block
		if (isBlock(ent))
		{
			//get who is currently grabbing the block (if anyone)
			new grabber = entity_get_int(ent, EV_INT_iuser2);
			
			//if entity is not being grabbed by someone else
			if (grabber == 0 || grabber == id)
			{
				//get the player ID of who has the block in a group (if anyone)
				new player = entity_get_int(ent, EV_INT_iuser1);
				
				//if the block is not in a group or is in this players group
				if (player == 0 || player == id)
				{
					new newBlock;
					
					//if block is in the players group and group count is larger than 1
					if (isBlockInGroup(id, ent) && gGroupCount[id] > 1)
					{
						new block;
						new blockCount = 0;
						
						//iterate through all blocks in the players group
						for (new i = 0; i <= gGroupCount[id]; ++i)
						{
							block = gGroupedBlocks[id][i];
							
							//if this block is in this players group
							if (isBlockInGroup(id, block))
							{
								//convert the block
								newBlock = convertBlock(id, block, convertTo, true);
								
								//if block was converted
								if (newBlock != 0)
								{
									//new block is now in the group
									gGroupedBlocks[id][i] = newBlock;
									
									//set the block so it is now 'being grouped'
									groupBlock(id, newBlock);
								}
								//count how many blocks could NOT be converted
								else
								{
									++blockCount;
								}
							}
						}
						
						//if some blocks could NOT be converted
						if (blockCount > 1)
						{
							client_print(id, print_chat, "%sCouldn't convert %d blocks!", gszPrefix, blockCount);
						}
					}
					else
					{
						newBlock = convertBlock(id, ent, convertTo, false);
						
						//if block was not converted
						if (newBlock == 0)
						{
							//get the block type
							new blockType = entity_get_int(ent, EV_INT_body);
							
							client_print(id, print_chat, "%sYou cannot convert a %s block into a %s block while it is rotated!", gszPrefix, gszBlockNames[blockType], gszBlockNames[convertTo]);
						}
					}
				}
				else
				{
					//get name of player who has this block in their group
					new szName[32]; 
					get_user_name(player, szName, 32);
					
					//notify player who has this block in their group
					client_print(id, print_chat, "%s%s currently has this block in their group!", gszPrefix, szName);
				}
			}
		}
	}
}

convertBlock(id, ent, const convertTo, const bool:bPreserveSize)
{
	new Float:vOrigin[3];
	new Float:vSizeMax[3];
	new axis;
	
	//get block information from block player is aiming at
	entity_get_vector(ent, EV_VEC_origin, vOrigin);
	entity_get_vector(ent, EV_VEC_maxs, vSizeMax);
	
	//work out the block size
	new size = SMALL;
	new Float:fMax = vSizeMax[0] + vSizeMax[1] + vSizeMax[2];
	if (fMax > 36.0) size = POLE;
	if (fMax > 64.0) size = NORMAL;
	if (fMax > 128.0) size = LARGE;
	
	//work out the axis orientation
	for (new i = 0; i < 3; ++i)
	{
		if (vSizeMax[i] == 4.0 && size != POLE)
		{
			axis = i;
			break;
		}
		
		if (vSizeMax[i] == 32.0 && size == POLE)
		{
			axis = i;
			break;
		}
	}
	
	//delete old block and create new one of given type
	deleteBlock(ent);
		
	if (bPreserveSize)
	{
		return createBlock(id, convertTo, vOrigin, axis, size);
	}
	else
	{
		return createBlock(id, convertTo, vOrigin, axis, gBlockSize[id]);
	}
	
	return ent;
}

deleteBlockAiming(id)
{
	//make sure player has access to this command
	if (gAccess[id])
	{
		//get entity that player is aiming at
		new ent, body;
		get_user_aiming(id, ent, body);
		
		//if entity player is aiming at is a block
		if (isBlock(ent))
		{
			//get who is currently grabbing the block (if anyone)
			new grabber = entity_get_int(ent, EV_INT_iuser2);
			
			//if entity is not being grabbed by someone else
			if (grabber == 0 || grabber == id)
			{
				//get the player ID of who has the block in a group (if anyone)
				new player = entity_get_int(ent, EV_INT_iuser1);
				
				//if the block is not in a group or is in this players group
				if (player == 0 || player == id)
				{
					//if block is not being grabbed
					if (entity_get_int(ent, EV_INT_iuser2) == 0)
					{
						//if block is in the players group and group count is larger than 1
						if (isBlockInGroup(id, ent) && gGroupCount[id] > 1)
						{
							new block;
							
							//iterate through all blocks in the players group
							for (new i = 0; i <= gGroupCount[id]; ++i)
							{
								block = gGroupedBlocks[id][i];
								
								//if block is still valid
								if (is_valid_ent(block))
								{
									//get player id of who has this block in their group
									new player = entity_get_int(block, EV_INT_iuser1);
									
									//if block is still in this players group
									if (player == id)
									{
										//delete the block
										deleteBlock(block);
									}
								}
							}
						}
						else
						{
							//delete the block
							deleteBlock(ent);
						}
					}
				}
				else
				{
					//get name of player who has this block in their group
					new szName[32]; 
					get_user_name(player, szName, 32);
					
					//notify player who has this block in their group
					client_print(id, print_chat, "%s%s currently has this block in their group!", gszPrefix, szName);
				}
			}
		}
	}
}

bool:deleteBlock(ent)
{
	//if entity is a block
	if (isBlock(ent))
	{
		//get the sprite attached to the top of the block
		new sprite = entity_get_int(ent, EV_INT_iuser3);
		
		//if sprite entity is valid
		if (sprite)
		{
			//remove the task for the animation of the sprite (if one exists)
			if (task_exists(TASK_SPRITE + sprite))
			{
				remove_task(TASK_SPRITE + sprite);
			}
			
			//delete the sprite
			remove_entity(sprite);
		}
		
		//delete the block
		remove_entity(ent);
		
		//block was deleted
		return true;
	}
	
	//block was not deleted
	return false;
}

rotateBlockAiming(id)
{
	//make sure player has access to this command
	if (gAccess[id])
	{
		//get block that player is aiming at
		new ent, body;
		get_user_aiming(id, ent, body);
		
		//if entity found is a block
		if (isBlock(ent))
		{
			//get who is currently grabbing the block (if anyone)
			new grabber = entity_get_int(ent, EV_INT_iuser2);
			
			//if entity is not being grabbed by someone else
			if (grabber == 0 || grabber == id)
			{
				//get the player ID of who has the block in a group (if anyone)
				new player = entity_get_int(ent, EV_INT_iuser1);
				
				//if the block is not in a group or is in this players group
				if (player == 0 || player == id)
				{
					//if block is in the players group and group count is larger than 1
					if (isBlockInGroup(id, ent) && gGroupCount[id] > 1)
					{
						new block;
						new bool:bRotateGroup = true;
						
						//if we can rotate the group
						if (bRotateGroup)
						{
							//iterate through all blocks in the players group
							for (new i = 0; i <= gGroupCount[id]; ++i)
							{
								block = gGroupedBlocks[id][i];
								
								//if block is still valid
								if (isBlockInGroup(id, block))
								{
									//rotate the block
									rotateBlock(block);
								}
							}
						}
						else
						{
							//notify player that their group cannot be rotated
							client_print(id, print_chat, "%sYour group contains blocks that cannot be rotated!", gszPrefix);
						}
					}
					else
					{
						//rotate the block and get rotated block ID
						new bool:bRotatedBlock = rotateBlock(ent);
						
						//if block did not rotate successfully
						if (!bRotatedBlock)
						{
							//get block type
							new blockType = entity_get_int(ent, EV_INT_body);
							
							//notify player block couldn't rotate
							client_print(id, print_chat, "%s%s blocks cannot be rotated!", gszPrefix, gszBlockNames[blockType]);
						}
					}
				}
				else
				{
					//get name of player who has this block in their group
					new szName[32]; 
					get_user_name(player, szName, 32);
					
					//notify player who has this block in their group
					client_print(id, print_chat, "%s%s currently has this block in their group!", gszPrefix, szName);
				}
			}
		}
	}
}

bool:rotateBlock(ent)
{
	//if entity is valid
	if (is_valid_ent(ent))
	{
		new Float:vAngles[3]; 
		new Float:vSizeMin[3];
		new Float:vSizeMax[3];
		new Float:fTemp;
		
		//get block information
		entity_get_vector(ent, EV_VEC_angles, vAngles);
		entity_get_vector(ent, EV_VEC_mins, vSizeMin);
		entity_get_vector(ent, EV_VEC_maxs, vSizeMax);
		
		//create new block using current block information with new angles and sizes
		if (vAngles[0] == 0.0 && vAngles[2] == 0.0)
		{
			vAngles[0] = 90.0;
		}
		else if (vAngles[0] == 90.0 && vAngles[2] == 0.0)
		{
			vAngles[0] = 90.0;
			vAngles[2] = 90.0;
		}
		else
		{ 
			vAngles = gfDefaultBlockAngles;
		}
		
		//shift vector values along
		fTemp = vSizeMin[0];
		vSizeMin[0] = vSizeMin[2];
		vSizeMin[2] = vSizeMin[1];
		vSizeMin[1] = fTemp;
		
		fTemp = vSizeMax[0];
		vSizeMax[0] = vSizeMax[2];
		vSizeMax[2] = vSizeMax[1];
		vSizeMax[1] = fTemp;
		
		//set the blocks new angle
		entity_set_vector(ent, EV_VEC_angles, vAngles);
		
		//set the blocks new size
		entity_set_size(ent, vSizeMin, vSizeMax);
		
		return true;
	}
	
	return false;
}

copyBlock(ent)
{
	//if entity is valid
	if (is_valid_ent(ent))
	{
		new Float:vOrigin[3];
		new Float:vAngles[3];
		new Float:vSizeMin[3];
		new Float:vSizeMax[3];
		new Float:fMax;
		new blockType;
		new size;
		new axis;
		
		//get blocktype and origin of currently grabbed block
		blockType = entity_get_int(ent, EV_INT_body);
		entity_get_vector(ent, EV_VEC_origin, vOrigin);
		entity_get_vector(ent, EV_VEC_angles, vAngles);
		entity_get_vector(ent, EV_VEC_mins, vSizeMin);
		entity_get_vector(ent, EV_VEC_maxs, vSizeMax);
		
		//work out the block size
		size = SMALL;
		fMax = vSizeMax[0] + vSizeMax[1] + vSizeMax[2];
		if (fMax > 36.0) size = POLE;
		if (fMax > 64.0) size = NORMAL;
		if (fMax > 128.0) size = LARGE;
		
		new Float:flProp1, Float:flProp2, iProp3;
		
		pev(ent, pev_fuser1, flProp1);
		pev(ent, pev_fuser2, flProp2);
		iProp3 = pev(ent, pev_fixangle);
		
		//work out the axis orientation
		for (new i = 0; i < 3; ++i)
		{
			if (vSizeMax[i] == 4.0 && size != POLE)
			{
				axis = i;
				break;
			}
			
			if (vSizeMax[i] == 32.0 && size == POLE) {
				axis = i;
				break;
			}
		}
		
		new iCreatedEntity;
		//create a block of the same type in the same location
		iCreatedEntity = createBlock(0, blockType, vOrigin, axis, size);
		
		if (is_valid_ent(iCreatedEntity)) {
			set_pev(iCreatedEntity, pev_fuser1, flProp1);
			set_pev(iCreatedEntity, pev_fuser2, flProp2);
			set_pev(iCreatedEntity, pev_fixangle, iProp3);
		}
		
		return iCreatedEntity;
	}
	
	return 0;
}

set_block_rendering(ent, type, red, green, blue, alpha)
{
	if (isBlock(ent))
	{
		switch (type)
		{
			case GLOWSHELL: set_rendering(ent, kRenderFxGlowShell, red, green, blue, kRenderNormal, alpha);
			case TRANSCOLOR: set_rendering(ent, kRenderFxGlowShell, red, green, blue, kRenderTransColor, alpha);
			case TRANSALPHA: set_rendering(ent, kRenderFxNone, red, green, blue, kRenderTransColor, alpha);
			case TRANSWHITE: set_rendering(ent, kRenderFxNone, red, green, blue, kRenderTransAdd, alpha);
			default: set_rendering(ent, kRenderFxNone, red, green, blue, kRenderNormal, alpha);
		}
	}
}

bool:IsStringAlphaNumeric(const szString[])
{
	for ( new i = 0; i < strlen(szString); i++ )
	{
		if ( (szString[i] >= 'a' && szString[i] <= 'z')
		|| (szString[i] >= 'A' && szString[i] <= 'Z')
		|| (szString[i] >= '0' && szString[i] <= '9')
		|| szString[i] == '_'
		|| szString[i] == '-' )
		{
			continue;
		}
		else
		{
			return false;
		}
	}
	
	return true;
}

/* BLOCK TESTS */
bool:isBlockInGroup(id, ent)
{
	//is entity valid
	if (is_valid_ent(ent))
	{
		//get player who has this block in their group (if anyone)
		new player = entity_get_int(ent, EV_INT_iuser1);
		
		if (player == id)
		{
			return true;
		}
	}
	
	return false;
}

bool:isBlock(ent)
{
	//is it a valid entity
	if (is_valid_ent(ent))
	{
		//get classname of entity
		new szClassname[32];
		entity_get_string(ent, EV_SZ_classname, szClassname, 32);
		
		//if classname of entity matches global block classname
		if (equal(szClassname, gszBlockClassname) || equal(szClassname, "bcm"))
		{
			//entity is a block
			return true;
		}
	}
	
	//entity is not a block
	return false;
}

bool:isBlockStuck(ent)
{
	//first make sure the entity is valid
	if (is_valid_ent(ent))
	{
		new content;
		new Float:vOrigin[3];
		new Float:vPoint[3];
		new Float:fSizeMin[3];
		new Float:fSizeMax[3];
		
		//get the size of the block being grabbed
		entity_get_vector(ent, EV_VEC_mins, fSizeMin);
		entity_get_vector(ent, EV_VEC_maxs, fSizeMax);
		
		//get the origin of the block
		entity_get_vector(ent, EV_VEC_origin, vOrigin);
		
		//decrease the size values of the block
		fSizeMin[0] += 1.0;
		fSizeMax[0] -= 1.0;
		fSizeMin[1] += 1.0;
		fSizeMax[1] -= 1.0; 
		fSizeMin[2] += 1.0;
		fSizeMax[2] -= 1.0;
		
		//get the contents of the centre of all 6 faces of the block
		for (new i = 0; i < 14; ++i)
		{
			//start by setting the point to the origin of the block (the middle)
			vPoint = vOrigin;
			
			//set the values depending on the loop number
			switch (i)
			{
				//corners
				case 0: { vPoint[0] += fSizeMax[0]; vPoint[1] += fSizeMax[1]; vPoint[2] += fSizeMax[2]; }
				case 1: { vPoint[0] += fSizeMin[0]; vPoint[1] += fSizeMax[1]; vPoint[2] += fSizeMax[2]; }
				case 2: { vPoint[0] += fSizeMax[0]; vPoint[1] += fSizeMin[1]; vPoint[2] += fSizeMax[2]; }
				case 3: { vPoint[0] += fSizeMin[0]; vPoint[1] += fSizeMin[1]; vPoint[2] += fSizeMax[2]; }
				case 4: { vPoint[0] += fSizeMax[0]; vPoint[1] += fSizeMax[1]; vPoint[2] += fSizeMin[2]; }
				case 5: { vPoint[0] += fSizeMin[0]; vPoint[1] += fSizeMax[1]; vPoint[2] += fSizeMin[2]; }
				case 6: { vPoint[0] += fSizeMax[0]; vPoint[1] += fSizeMin[1]; vPoint[2] += fSizeMin[2]; }
				case 7: { vPoint[0] += fSizeMin[0]; vPoint[1] += fSizeMin[1]; vPoint[2] += fSizeMin[2]; }
				
				//centre of faces
				case 8: { vPoint[0] += fSizeMax[0]; }
				case 9: { vPoint[0] += fSizeMin[0]; }
				case 10: { vPoint[1] += fSizeMax[1]; }
				case 11: { vPoint[1] += fSizeMin[1]; }
				case 12: { vPoint[2] += fSizeMax[2]; }
				case 13: { vPoint[2] += fSizeMin[2]; }
			}
			
			//get the contents of the point on the block
			content = point_contents(vPoint);
			
			//if the point is out in the open
			if (content == CONTENTS_EMPTY || content == 0)
			{
				//block is not stuck
				return false;
			}
		}
	}
	else
	{
		//entity is invalid but don't say its stuck
		return false;
	}
	
	//block is stuck
	return true;
}

bool:isTeleport(ent)
{
	if (is_valid_ent(ent))
	{
		//get classname of entity
		new szClassname[32];
		entity_get_string(ent, EV_SZ_classname, szClassname, 32);
		
		//compare classnames
		if (equal(szClassname, gszTeleportStartClassname) || equal(szClassname, gszTeleportEndClassname))
		{
			//entity is a teleport
			return true;
		}
	}
	
	//entity is not a teleport
	return false;
}

doSnapping(id, ent, Float:fMoveTo[3])
{
	//if player has snapping enabled
	if (gbSnapping[id])
	{
		new Float:fSnapSize = gfSnapDistance + gfSnappingGap[id];
		new Float:vReturn[3];
		new Float:dist;
		new Float:distOld = 9999.9;
		new Float:vTraceStart[3];
		new Float:vTraceEnd[3];
		new tr;
		new trClosest = 0;
		new blockFace;
		
		//get the size of the block being grabbed
		new Float:fSizeMin[3];
		new Float:fSizeMax[3];
		entity_get_vector(ent, EV_VEC_mins, fSizeMin);
		entity_get_vector(ent, EV_VEC_maxs, fSizeMax);
		
		//do 6 traces out from each face of the block
		for (new i = 0; i < 6; ++i)
		{
			//setup the start of the trace
			vTraceStart = fMoveTo;
			
			switch (i)
			{
				case 0: vTraceStart[0] += fSizeMin[0];		//edge of block on -X
				case 1: vTraceStart[0] += fSizeMax[0];		//edge of block on +X
				case 2: vTraceStart[1] += fSizeMin[1];		//edge of block on -Y
				case 3: vTraceStart[1] += fSizeMax[1];		//edge of block on +Y
				case 4: vTraceStart[2] += fSizeMin[2];		//edge of block on -Z
				case 5: vTraceStart[2] += fSizeMax[2];		//edge of block on +Z
			}
			
			//setup the end of the trace
			vTraceEnd = vTraceStart;
			
			switch (i)
			{
				case 0: vTraceEnd[0] -= fSnapSize;
				case 1: vTraceEnd[0] += fSnapSize;
				case 2: vTraceEnd[1] -= fSnapSize;
				case 3: vTraceEnd[1] += fSnapSize;
				case 4: vTraceEnd[2] -= fSnapSize;
				case 5: vTraceEnd[2] += fSnapSize;
			}
			
			//trace a line out from one of the block faces
			tr = trace_line(ent, vTraceStart, vTraceEnd, vReturn);
			
			//if the trace found a block and block is not in group or block to snap to is not in group
			if (isBlock(tr) && (!isBlockInGroup(id, tr) || !isBlockInGroup(id, ent)))
			{
				//get the distance from the grabbed block to the found block
				dist = get_distance_f(vTraceStart, vReturn);
				
				//if distance to found block is less than the previous block
				if (dist < distOld)
				{
					trClosest = tr;
					distOld = dist;
					
					//save the block face where the trace came from
					blockFace = i;
				}
			}
		}
		
		//if there is a block within the snapping range
		if (is_valid_ent(trClosest))
		{
			//get origin of closest block
			new Float:vOrigin[3];
			entity_get_vector(trClosest, EV_VEC_origin, vOrigin);
			
			//get sizes of closest block
			new Float:fTrSizeMin[3];
			new Float:fTrSizeMax[3];
			entity_get_vector(trClosest, EV_VEC_mins, fTrSizeMin);
			entity_get_vector(trClosest, EV_VEC_maxs, fTrSizeMax);
			
			//move the subject block to the origin of the closest block
			fMoveTo = vOrigin;
			
			//offset the block to be on the side where the trace hit the closest block
			if (blockFace == 0) fMoveTo[0] += (fTrSizeMax[0] + fSizeMax[0]) + gfSnappingGap[id];
			if (blockFace == 1) fMoveTo[0] += (fTrSizeMin[0] + fSizeMin[0]) - gfSnappingGap[id];
			if (blockFace == 2) fMoveTo[1] += (fTrSizeMax[1] + fSizeMax[1]) + gfSnappingGap[id];
			if (blockFace == 3) fMoveTo[1] += (fTrSizeMin[1] + fSizeMin[1]) - gfSnappingGap[id];
			if (blockFace == 4) fMoveTo[2] += (fTrSizeMax[2] + fSizeMax[2]) + gfSnappingGap[id];
			if (blockFace == 5) fMoveTo[2] += (fTrSizeMin[2] + fSizeMin[2]) - gfSnappingGap[id];
		}
	}
}

/***** FILE HANDLING *****/
saveBlocks(id)
{
	if (gCantSave)
		client_print(id, print_chat, "%s You can't save because someone just jumped on a bhop", gszPrefix);
		
	//make sure player has access to this command
	else if (gAccess[id])
	{
		new szPath[129];
		format(szPath, 128, "%s/%s.bm", gDir, gCurConfig);
		
		new file = fopen(szPath, "wt");
		new ent = -1;
		new blockType;
		new Float:vOrigin[3];
		new Float:vAngles[3];
		new Float:vStart[3];
		new Float:vEnd[3];
		new blockCount = 0;
		new teleCount = 0;
		new szData[128];
		new Float:fMax;
		new size;
		new Float:vSizeMax[3];
		new Float:flPropertie1, Float:flPropertie2, iProp3;
		new Float:flRenderColor[ 3 ], Float:flRenderAmt, iRenderFX, iRenderMode;
		new szWeapon[32];
		
		while ((ent = find_ent_by_class(ent, gszBlockClassname)))
		{
			//get block info
			blockType = entity_get_int(ent, EV_INT_body);
			if( blockType == BM_MAGICCARPET )
				pev(ent, pev_v_angle, vOrigin);
			else
				pev(ent, pev_origin, vOrigin);
			entity_get_vector(ent, EV_VEC_angles, vAngles);
			entity_get_vector(ent, EV_VEC_maxs, vSizeMax);
			
			size = SMALL;
			fMax = vSizeMax[0] + vSizeMax[1] + vSizeMax[2];
			if (fMax > 36.0) size = POLE;
			if (fMax > 64.0) size = NORMAL;
			if (fMax > 128.0) size = LARGE;
			
			iRenderFX	= pev( ent, pev_renderfx );
			iRenderMode	= pev( ent, pev_rendermode );
			pev( ent, pev_rendercolor, flRenderColor );
			pev( ent, pev_renderamt, flRenderAmt );
			
			pev( ent, pev_fuser1, flPropertie1 );
			pev( ent, pev_fuser2, flPropertie2 );
			iProp3 = pev(ent, pev_fixangle);
			
			//format block info and save it to file
			if (blockType == BM_WEAPON) {
				pev(ent, pev_message, szWeapon, 31);
				formatex(szData, 128, "%c %f %f %f %f %f %f %d %s %.1f %i %i %i %f %f %f %f^n", gBlockSaveIds[blockType], vOrigin[0], vOrigin[1], vOrigin[2], vAngles[0], vAngles[1], vAngles[2], size, szWeapon, flPropertie2, iProp3, iRenderFX, iRenderMode, flRenderAmt, flRenderColor[0], flRenderColor[1], flRenderColor[2]);
			} else
				formatex(szData, 128, "%c %f %f %f %f %f %f %d %.1f %.1f %i %i %i %f %f %f %f^n", gBlockSaveIds[blockType], vOrigin[0], vOrigin[1], vOrigin[2], vAngles[0], vAngles[1], vAngles[2], size, flPropertie1, flPropertie2, iProp3, iRenderFX, iRenderMode, flRenderAmt, flRenderColor[0], flRenderColor[1], flRenderColor[2]);
			
			fputs(file, szData);
			
			//increment block count
			++blockCount;
		}
		
		//iterate through teleport end entities because you can't have an end without a start
		ent = -1;
		
		while ((ent = find_ent_by_class(ent, gszTeleportEndClassname)))
		{
			//get the id of the start of the teleporter
			new tele = entity_get_int(ent, EV_INT_iuser1);
			
			//check that start of teleport is a valid entity
			if (tele)
			{
				//get the origin of the start of the teleport and save it to file
				entity_get_vector(tele, EV_VEC_origin, vStart);
				entity_get_vector(ent, EV_VEC_origin, vEnd);
				
				formatex(szData, 128, "%c %f %f %f %f %f %f^n", gTeleportSaveId, vStart[0], vStart[1], vStart[2], vEnd[0], vEnd[1], vEnd[2]);
				fputs(file, szData);
				
				//2 teleport entities count as 1 teleporter
				++teleCount;
			}
		}
		
		//get players name
		new szName[32];
		get_user_name(id, szName, 32);
		
		//notify all admins that the player saved blocks to file
		for (new i = 1; i <= 32; ++i)
		{
			//make sure player is connected
			if (is_user_connected(i))
			{
				if (get_user_flags(i) & BM_ADMIN_LEVEL)
				{
					client_print(i, print_chat, "%s'%s' saved %d block%s and %d teleporter%s in template '%s'! Total entites in map: %d", gszPrefix, szName, blockCount, (blockCount == 1 ? "" : "s"), teleCount, (teleCount == 1 ? "" : "s"), gCurConfig, entity_count());
				}
			}
		}
		
		//close file
		fclose(file);
	}
}

loadBlocks(id, number, const szConfigsName[])
{
	new bool:bAccess = false;
	
	//if this function was called on map load, ID is 0
	if (id == 0)
	{
		bAccess = true;
	}
	//make sure user calling this function has access
	else if (gAccess[id])
	{
		bAccess = true;
	}
	
	if (bAccess)
	{
		new szPath[129];
		format(szPath, 128, "%s/%s.bm", gDir, szConfigsName);
		
		//if map file exists
		if (file_exists(szPath))
		{
			//if a player is loading then first delete all the old blocks, teleports and timers
			if (id > 0 && id <= 32 || number == 1)
			{
				deleteAllBlocks(id, false);
				deleteAllTeleports(id, false);
			}
			
			new szData[128];
			new szType[2];
			new sz1[16], sz2[16], sz3[16], sz4[16], sz5[16], sz6[16], sz7[16], sz8[16], sz9[16], sz10[16];
			new Float:vVec1[3];
			new Float:vVec2[3];
			new axis;
			new size;
			new f = fopen(szPath, "rt");
			new blockCount = 0;
			new teleCount = 0;
			new Float:flProperty1, Float:flProperty2, iProp3;
			new iCreatedEntity;
			
			new szRenderColor[3][16], szRenderFX[3], szRenderMode[3], szRenderAmt[16];
			new Float:flRenderColor[ 3 ], Float:flRenderAmt, iRenderFX, iRenderMode;
			
			copy(gCurConfig, 32, szConfigsName);
			
			//iterate through all the lines in the file
			while (!feof(f))
			{
				szType = "";
				fgets(f, szData, 128);
				parse(szData, szType, 1, sz1, 16, sz2, 16, sz3, 16, sz4, 16, sz5, 16, sz6, 16, sz7, 16, sz8, 16, sz9, 16, sz10, 16, szRenderFX, 2, szRenderMode, 2, szRenderAmt, 16, szRenderColor[0], 16, szRenderColor[1], 16, szRenderColor[2], 16);
				
				vVec1[0] = str_to_float(sz1);
				vVec1[1] = str_to_float(sz2);
				vVec1[2] = str_to_float(sz3);
				vVec2[0] = str_to_float(sz4);
				vVec2[1] = str_to_float(sz5);
				vVec2[2] = str_to_float(sz6);
				size = str_to_num(sz7);
				
				flProperty1 = str_to_float(sz8);
				flProperty2 = str_to_float(sz9);
				iProp3 = str_to_num(sz10);
				
				flRenderColor[0] = str_to_float( szRenderColor[0] );
				flRenderColor[1] = str_to_float( szRenderColor[1] );
				flRenderColor[2] = str_to_float( szRenderColor[2] );
				flRenderAmt = str_to_float( szRenderAmt );
				
				iRenderFX = str_to_num( szRenderFX );
				iRenderMode = str_to_num( szRenderMode );
				
				if (strlen(szType) > 0)
				{
					//if type is not a teleport
					if (szType[0] != gTeleportSaveId)
					{
						//set axis orientation depending on block angles
						if (vVec2[0] == 90.0 && vVec2[1] == 0.0 && vVec2[2] == 0.0)
						{
							axis = X;
						}
						else if (vVec2[0] == 90.0 && vVec2[1] == 0.0 && vVec2[2] == 90.0)
						{
							axis = Y;
						}
						else
						{
							axis = Z;
						}
						
						//increment block counter
						++blockCount;
					}		
					
					//create block or teleport depending on type
					switch (szType[0])
					{
						case 'A': iCreatedEntity = createBlock(0, BM_PLATFORM, vVec1, axis, size);
						case 'B': iCreatedEntity = createBlock(0, BM_BHOP, vVec1, axis, size);
						case 'C': iCreatedEntity = createBlock(0, BM_DAMAGE, vVec1, axis, size);
						case 'D': iCreatedEntity = createBlock(0, BM_HEALER, vVec1, axis, size);
						case 'E': iCreatedEntity = createBlock(0, BM_INVINCIBILITY, vVec1, axis, size);
						case 'F': iCreatedEntity = createBlock(0, BM_STEALTH, vVec1, axis, size);
						case 'G': iCreatedEntity = createBlock(0, BM_TRAMPOLINE, vVec1, axis, size);
						case 'H': iCreatedEntity = createBlock(0, BM_SPEEDBOOST, vVec1, axis, size);
						case 'I': iCreatedEntity = createBlock(0, BM_NOFALLDAMAGE, vVec1, axis, size);
						case 'J': iCreatedEntity = createBlock(0, BM_ICE, vVec1, axis, size);
						case 'K': iCreatedEntity = createBlock(0, BM_DEATH, vVec1, axis, size);
						case 'N': iCreatedEntity = createBlock(0, BM_LOWGRAVITY, vVec1, axis, size);
						case 'P': iCreatedEntity = createBlock(0, BM_SLAP, vVec1, axis, size);
						case 'R': iCreatedEntity = createBlock(0, BM_HONEY, vVec1, axis, size);
						case 'S': iCreatedEntity = createBlock(0, BM_BARRIER_CT, vVec1, axis, size);
						case 'T': iCreatedEntity = createBlock(0, BM_BARRIER_T, vVec1, axis, size);
						case 'U': iCreatedEntity = createBlock(0, BM_BOOTSOFSPEED, vVec1, axis, size);
						case 'Y': iCreatedEntity = createBlock(0, BM_MAGICCARPET, vVec1, axis, size);
						case 'Z': iCreatedEntity = createBlock(0, BM_DELAYEDBHOP, vVec1, axis, size);
						case '1': iCreatedEntity = createBlock(0, BM_SPAMDUCK, vVec1, axis, size);
						case '2': iCreatedEntity = createBlock(0, BM_WEAPON, vVec1, axis, size);
						case '3': iCreatedEntity = createBlock(0, BM_POINT, vVec1, axis, size);
						
						case gTeleportSaveId:
						{
							createTeleport(0, TELEPORT_START, vVec1);
							createTeleport(0, TELEPORT_END, vVec2);
							
							//increment teleport count
							++teleCount;
						}
						
						default:
						{
							log_amx("%sInvalid block type: %c in: %s", gszPrefix, szType[0], gszFile);
							
							//decrement block counter because a block was not created
							--blockCount;
						}
					}
					if (pev_valid(iCreatedEntity)) {
						new blockType = entity_get_int(iCreatedEntity, EV_INT_body);
						
						set_pev( iCreatedEntity, pev_renderfx, iRenderFX );
						set_pev( iCreatedEntity, pev_rendermode, iRenderMode );
						set_pev( iCreatedEntity, pev_rendercolor, flRenderColor );
						set_pev( iCreatedEntity, pev_renderamt, flRenderAmt );
						
						if (blockType == BM_WEAPON)
							set_pev(iCreatedEntity, pev_message, sz8);
						else
							set_pev(iCreatedEntity, pev_fuser1, flProperty1);
						
						set_pev(iCreatedEntity, pev_fuser2, flProperty2);
						set_pev(iCreatedEntity, pev_fixangle, iProp3);
					}
				}
			}
			
			fclose(f);
			
			//if a player is loading the blocks
			if (id > 0 && id <= 32)
			{
				//get players name
				new szName[32];
				get_user_name(id, szName, 32);
				
				//notify all admins that the player loaded blocks from file
				for (new i = 1; i <= 32; ++i)
				{
					//make sure player is connected
					if (is_user_connected(i))
					{
						if (get_user_flags(i) & BM_ADMIN_LEVEL)
						{
							client_print(i, print_chat, "%s'%s' loaded template '%s' which has %d block%s and %d teleporter%s! Total entites in map: %d", gszPrefix, szName, szConfigsName, blockCount, (blockCount == 1 ? "" : "s"), teleCount, (teleCount == 1 ? "" : "s"), entity_count());
						}
					}
				}
			}
		}
		else
		{
			//if a player is loading the blocks
			if (id > 0 && id <= 32)
			{
				//notify player that the file could not be found
				client_print(id, print_chat, "%sCouldn't find file: %s", gszPrefix, gszNewFile);
			}
		}
	}
}

/* MISC */
drawLine(Float:vOrigin1[3], Float:vOrigin2[3], life)
{
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(TE_BEAMPOINTS);
	write_coord(floatround(vOrigin1[0], floatround_floor));
	write_coord(floatround(vOrigin1[1], floatround_floor));
	write_coord(floatround(vOrigin1[2], floatround_floor));
	write_coord(floatround(vOrigin2[0], floatround_floor));
	write_coord(floatround(vOrigin2[1], floatround_floor));
	write_coord(floatround(vOrigin2[2], floatround_floor));
	write_short(gSpriteIdBeam);		//sprite index
	write_byte(0);				//starting frame
	write_byte(1);				//frame rate in 0.1's
	write_byte(life);			//life in 0.1's
	write_byte(5);				//line width in 0.1's
	write_byte(0);				//noise amplitude in 0.01's
	write_byte(255);			//red
	write_byte(255);			//green
	write_byte(255);			//blue
	write_byte(255);			//brightness
	write_byte(0);				//scroll speed in 0.1's
	message_end();
}

get_rocks_needed()
{
	return floatround(0.40 * float(get_realplayersnum()), floatround_ceil);
}

stock get_realplayersnum()
{
	new players[32], playerCnt;
	get_players(players, playerCnt, "ch");
	
	return playerCnt;
}