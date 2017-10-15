#include < amxmodx >
#include < amxmisc >
#include < engine >
#include < fun >
#include < cstrike >
#include < fakemeta >
#include < hamsandwich >
#include < colorchat >

#pragma semicolon 1;

#define PLUGIN "blockmaker"
#define VERSION "1.0"
#define AUTHOR "infek"
#define SECONDS 80.0
#define CURCONFIG 90.0
#define BM_ADMIN_LEVEL ADMIN_MENU
#define MAX_VALUES 5
#define WORTHLESS_STR "Worthless"

#define TASK_ID_CONFIGVOTETIMER 909000 // Config Timer

new awpused[33], deagleused[33], hegrenadeused[33], flashbangused[33], smokegrenadeused[33]; //weapon blocks

new gKeysMainMenu;
new gKeysBlockMenu;
new gKeysNextPage;
new gKeysBlockSelectionMenu;
new gKeysTeleportMenu;
new gKeysMeasureMenu;
new gKeysLongJumpMenu;
new gKeysTimerMenu;
new gKeysRenderMenu;
new gKeysDefaultRenderMenu;
new gKeysOptionsMenu;
new gKeysChoiceMenu;
new gKeysConfigMenu;

new bool:g_is_poisoned[33]; // true or false on biohazard
new gmsgIcon; // icon on biohazard
new gmsgScreenFade; // green blink on biohazard

const Float:gfSnapDistance = 10.0;	//blocks snap together when they're within this value + the players snap gap

/* enum for menu option values */
enum
{
	N1, N2, N3, N4, N5, N6, N7, N8, N9, N0
};

/* enum for bit-shifted numbers 1 - 10*/
enum
{
	B1 = 1 << N1, B2 = 1 << N2, B3 = 1 << N3, B4 = 1 << N4, B5 = 1 << N5,
	B6 = 1 << N6, B7 = 1 << N7, B8 = 1 << N8, B9 = 1 << N9, B0 = 1 << N0,
};

/* enum for options with YES/NO confirmation */
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
	LARGE
};

enum
{
	X,
	Y,
	Z
};

/* hud message values */
const gHudRed = 10;
const gHudGreen = 30;
const gHudBlue = 200;
const Float:gfTextX = -1.0;
const Float:gfTextY = 0.84;
const gHudEffects = 0;
const Float:gfHudFxTime = 0.0;
const Float:gfHudHoldTime = 0.25;
const Float:gfHudFadeInTime = 0.0;
const Float:gfHudFadeOutTime = 0.0;
const gHudChannel = 2;

/* Task ID offsets */
enum( +=1000 )
{
	TASK_BHOPSOLID = 1000,
	TASK_BHOPSOLIDNOT,
	TASK_INVINCIBLE,
	TASK_STEALTH,
	TASK_ICE,
	TASK_SPRITE,
	TASK_CAMOUFLAGE,
	TASK_HONEY,
	TASK_FIRE,
	TASK_BOOTSOFSPEED,
	TASK_TELEPORT,
	TASK_NOSLOW,
	TASK_AUTOBHOP
}

/* Strings */
new const gszPrefix[] = "[BlockMaker]";
new const gszInfoTarget[] = "info_target";
new const gszHelpFilenameFormat[] = "blockmaker_v%s.txt";
new gszFile[128];
new gszNewFile[128];
new gszMainMenu[256];
new gszBlockMenu[256];
new gszNextPage[256];
new gszTeleportMenu[256];
new gszTimerMenu[256];
new gszRenderMenu[256];
new gszDefaultRenderMenu[256];
new gszMeasureMenu[512];
new gszLongJumpMenu[256];
new gszOptionsMenu[256];
new gszChoiceMenu[128];
new gszHelpTitle[64];
new gszHelpText[1600];
new gszHelpFilename[32];
new gszViewModel[33][32];
new gszConfigMenu[256];

const Float:SCALE_NORMAL =	1.0;
const Float:SCALE_LARGE =	2.0;
const Float:SCALE_SMALL =	0.25;


/* Block dimensions */
new Float:gfBlockSizeMinForX[3] =	{-4.0,	-32.0,	-32.0};
new Float:gfBlockSizeMaxForX[3] =	{ 4.0,	32.0,	32.0};
new Float:gfBlockSizeMinForY[3] =	{-32.0,	-4.0,	-32.0};
new Float:gfBlockSizeMaxForY[3] =	{ 32.0,	4.0,	32.0};
new Float:gfBlockSizeMinForZ[3] =	{-32.0,	-32.0,	-4.0};
new Float:gfBlockSizeMaxForZ[3] =	{ 32.0,	32.0,	4.0};
new Float:gfDefaultBlockAngles[3] =	{ 0.0,	0.0,	0.0 };

/* Block models */
new const gszBlockModelDefault[] =		"models/blockmaker/bm_block_platform.mdl";
new const gszBlockModelPlatform[] =		"models/blockmaker/bm_block_platform.mdl";
new const gszBlockModelBhop[] =			"models/blockmaker/bm_block_platform.mdl";
new const gszBlockModelDamage[] =		"models/blockmaker/bm_block_damage.mdl";
new const gszBlockModelHealer[] =		"models/blockmaker/bm_block_platform.mdl";
new const gszBlockModelInvincibility[] = 	"models/blockmaker/bm_block_invincibility.mdl";
new const gszBlockModelStealth[] =		"models/blockmaker/bm_block_stealth.mdl";
new const gszBlockModelSpeedBoost[] =		"models/blockmaker/bm_block_speedboost.mdl";
new const gszBlockModelNoFallDamage[] =		"models/blockmaker/bm_block_platform.mdl";
new const gszBlockModelIce[] =			"models/blockmaker/bm_block_ice.mdl";
new const gszBlockModelDeath[] =			"models/blockmaker/bm_block_platform.mdl";
new const gszBlockModelNuke[] =			"models/blockmaker/bm_block_nuke.mdl";
new const gszBlockModelCamouflage[] =		"models/blockmaker/bm_block_camouflage.mdl";
new const gszBlockModelLowGravity[] = 		"models/blockmaker/bm_block_lowgravity.mdl";
new const gszBlockModelFire[] =			"models/blockmaker/bm_block_fire.mdl";
new const gszBlockModelRandom[] =		"models/blockmaker/bm_block_random.mdl";
new const gszBlockModelSlap[] =			"models/blockmaker/bm_block_slap.mdl";
new const gszBlockModelHoney[] =			"models/blockmaker/bm_block_honey.mdl";
new const gszBlockModelBarrierCT[] =		"models/blockmaker/bm_block_barrier_ct.mdl";
new const gszBlockModelBarrierT[] =		"models/blockmaker/bm_block_barrier_t.mdl";
new const gszBlockModelBootsOfSpeed[] =		"models/blockmaker/bm_block_bootsofspeed.mdl";
new const gszBlockModelGlass[] =			"models/blockmaker/bm_block_glass.mdl";
new const gszBlockModelBhopNoSlow[] =		"models/blockmaker/bm_block_bhop_noslow.mdl";
new const gszBlockModelAutoBhop[] =		"models/blockmaker/bm_block_autobhop.mdl";
new const gszBlockModelDelayedBhop[] =		"models/blockmaker/bm_block_platform.mdl";
new const gszBlockModelBlind[] =			"models/blockmaker/bm_block_platform.mdl";
new const gszBlockModelDuck[] =			"models/blockmaker/bm_block_platform.mdl";
new const gszBlockModelHEGrenade[] =		"models/blockmaker/bm_block_platform.mdl";
new const gszBlockModelFlashbang[] =		"models/blockmaker/bm_block_platform.mdl";
new const gszBlockModelSmokeGrenade[] =		"models/blockmaker/bm_block_platform.mdl";
new const gszBlockModelDEagle[] =		"models/blockmaker/bm_block_platform.mdl";
new const gszBlockModelAWP[] =			"models/blockmaker/bm_block_platform.mdl";
new const gszBlockModelBiohazard[] =		"models/blockmaker/bm_block_platform.mdl";
new const gszBlockModelAntidote[] =		"models/blockmaker/bm_block_platform.mdl";
new const gszBlockModelMagicCarpet[] =          "models/blockmaker/bm_block_platform.mdl";
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
new const gszBlockModelSmallDefault[] =		"models/blockmaker/bm_block_platform_small.mdl";
new const gszBlockModelSmallPlatform[] =		"models/blockmaker/bm_block_platform_small.mdl";
new const gszBlockModelSmallBhop[] =		"models/blockmaker/bm_block_platform_small.mdl";
new const gszBlockModelSmallDamage[] =		"models/blockmaker/bm_block_damage_small.mdl";
new const gszBlockModelSmallHealer[] =		"models/blockmaker/bm_block_platform_small.mdl";
new const gszBlockModelSmallInvincibility[] =	"models/blockmaker/bm_block_invincibility_small.mdl";
new const gszBlockModelSmallStealth[] =		"models/blockmaker/bm_block_stealth_small.mdl";
new const gszBlockModelSmallSpeedBoost[] =	"models/blockmaker/bm_block_speedboost_small.mdl";
new const gszBlockModelSmallNoFallDamage[] =	"models/blockmaker/bm_block_platform_small.mdl";
new const gszBlockModelSmallIce[] =		"models/blockmaker/bm_block_ice_small.mdl";
new const gszBlockModelSmallDeath[] =		"models/blockmaker/bm_block_platform_small.mdl";
new const gszBlockModelSmallNuke[] =		"models/blockmaker/bm_block_nuke_small.mdl";
new const gszBlockModelSmallCamouflage[] =	"models/blockmaker/bm_block_camouflage_small.mdl";
new const gszBlockModelSmallLowGravity[] =	"models/blockmaker/bm_block_lowgravity_small.mdl";
new const gszBlockModelSmallFire[] =		"models/blockmaker/bm_block_fire_small.mdl";
new const gszBlockModelSmallRandom[] =		"models/blockmaker/bm_block_random_small.mdl";
new const gszBlockModelSmallSlap[] =		"models/blockmaker/bm_block_slap_small.mdl";
new const gszBlockModelSmallHoney[] =		"models/blockmaker/bm_block_honey_small.mdl";
new const gszBlockModelSmallBarrierCT[] =	"models/blockmaker/bm_block_barrier_ct_small.mdl";
new const gszBlockModelSmallBarrierT[] =		"models/blockmaker/bm_block_barrier_t_small.mdl";
new const gszBlockModelSmallBootsOfSpeed[] =	"models/blockmaker/bm_block_bootsofspeed_small.mdl";
new const gszBlockModelSmallGlass[] =		"models/blockmaker/bm_block_glass_small.mdl";
new const gszBlockModelSmallBhopNoSlow[] =	"models/blockmaker/bm_block_bhop_noslow_small.mdl";
new const gszBlockModelSmallAutoBhop[] =		"models/blockmaker/bm_block_autobhop_small.mdl";
new const gszBlockModelSmallDelayedBhop[] =	"models/blockmaker/bm_block_platform_small.mdl";
new const gszBlockModelSmallBlind[] =		"models/blockmaker/bm_block_platform_small.mdl";
new const gszBlockModelSmallDuck[] =		"models/blockmaker/bm_block_platform_small.mdl";
new const gszBlockModelSmallHEGrenade[] =	"models/blockmaker/bm_block_platform_small.mdl";
new const gszBlockModelSmallFlashbang[] =	"models/blockmaker/bm_block_platform_small.mdl";
new const gszBlockModelSmallSmokeGrenade[] =	"models/blockmaker/bm_block_platform_small.mdl";
new const gszBlockModelSmallDEagle[] =		"models/blockmaker/bm_block_platform_small.mdl";
new const gszBlockModelSmallAWP[] =		"models/blockmaker/bm_block_platform_small.mdl";
new const gszBlockModelSmallBiohazard[] =	"models/blockmaker/bm_block_platform_small.mdl";
new const gszBlockModelSmallAntidote[] =		"models/blockmaker/bm_block_platform_small.mdl";
new const gszBlockModelSmallMagicCarpet[] =          "models/blockmaker/bm_block_platform.mdl";
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
new const gszBlockModelLargeDefault[] =		"models/blockmaker/bm_block_platform_large.mdl";
new const gszBlockModelLargePlatform[] =		"models/blockmaker/bm_block_platform_large.mdl";
new const gszBlockModelLargeBhop[] =		"models/blockmaker/bm_block_platform_large.mdl";
new const gszBlockModelLargeDamage[] =		"models/blockmaker/bm_block_damage_large.mdl";
new const gszBlockModelLargeHealer[] =		"models/blockmaker/bm_block_platform_large.mdl";
new const gszBlockModelLargeInvincibility[] =	"models/blockmaker/bm_block_invincibility_large.mdl";
new const gszBlockModelLargeStealth[] =		"models/blockmaker/bm_block_stealth_large.mdl";
new const gszBlockModelLargeSpeedBoost[] =	"models/blockmaker/bm_block_speedboost_large.mdl";
new const gszBlockModelLargeNoFallDamage[] =	"models/blockmaker/bm_block_platform_large.mdl";
new const gszBlockModelLargeIce[] =		"models/blockmaker/bm_block_ice_large.mdl";
new const gszBlockModelLargeDeath[] =		"models/blockmaker/bm_block_platform_large.mdl";
new const gszBlockModelLargeNuke[] =		"models/blockmaker/bm_block_nuke_large.mdl";
new const gszBlockModelLargeCamouflage[] =	"models/blockmaker/bm_block_camouflage_large.mdl";
new const gszBlockModelLargeLowGravity[] =	"models/blockmaker/bm_block_lowgravity_large.mdl";
new const gszBlockModelLargeFire[] =		"models/blockmaker/bm_block_fire_large.mdl";
new const gszBlockModelLargeRandom[] =		"models/blockmaker/bm_block_random_large.mdl";
new const gszBlockModelLargeSlap[] =		"models/blockmaker/bm_block_slap_large.mdl";
new const gszBlockModelLargeHoney[] =		"models/blockmaker/bm_block_honey_large.mdl";
new const gszBlockModelLargeBarrierCT[] =	"models/blockmaker/bm_block_barrier_ct_large.mdl";
new const gszBlockModelLargeBarrierT[] =		"models/blockmaker/bm_block_barrier_t_large.mdl";
new const gszBlockModelLargeBootsOfSpeed[] =	"models/blockmaker/bm_block_bootsofspeed_large.mdl";
new const gszBlockModelLargeGlass[] =		"models/blockmaker/bm_block_glass_large.mdl";
new const gszBlockModelLargeBhopNoSlow[] =	"models/blockmaker/bm_block_bhop_noslow_large.mdl";
new const gszBlockModelLargeAutoBhop[] =		"models/blockmaker/bm_block_autobhop_large.mdl";
new const gszBlockModelLargeDelayedBhop[] =	"models/blockmaker/bm_block_platform_large.mdl";
new const gszBlockModelLargeBlind[] =		"models/blockmaker/bm_block_platform_large.mdl";
new const gszBlockModelLargeDuck[] =		"models/blockmaker/bm_block_platform_large.mdl";
new const gszBlockModelLargeHEGrenade[] =	"models/blockmaker/bm_block_platform_large.mdl";
new const gszBlockModelLargeFlashbang[] =	"models/blockmaker/bm_block_platform_large.mdl";
new const gszBlockModelLargeSmokeGrenade[] =	"models/blockmaker/bm_block_platform_large.mdl";
new const gszBlockModelLargeDEagle[] =		"models/blockmaker/bm_block_platform_large.mdl";
new const gszBlockModelLargeAWP[] =		"models/blockmaker/bm_block_platform_large.mdl";
new const gszBlockModelLargeBiohazard[] =	"models/blockmaker/bm_block_platform_large.mdl";
new const gszBlockModelLargeAntidote[] =		"models/blockmaker/bm_block_platform_large.mdl";
new const gszBlockModelLargeMagicCarpet[] =          "models/blockmaker/bm_block_platform.mdl";

/* Block sprites */
new const gszFireSprite[] =			"sprites/blockmaker/bm_block_fire_flame.spr";		//custom

/* Block sounds */
new const gszNukeExplosion[] =			"weapons/c4_explode1.wav";	//from CS
new const gszFireSoundFlame[] =			"ambience/flameburst1.wav";	//from HL
new const gszInvincibleSound[] =			"warcraft3/divineshield.wav";	//from WC3 plugin
new const gszCamouflageSound[] =			"warcraft3/antend.wav";		//from WC3 plugin
new const gszStealthSound[] =			"warcraft3/levelupcaster.wav";	//from WC3 plugin
new const gszBootsOfSpeedSound[] =		"warcraft3/purgetarget1.wav";	//from WC3 plugin
new const gszAutoBhopSound[] =			"blockmaker/boing.wav";		//from 'www.wavsource.com/sfx/sfx.htm'

/* Teleport */
new const Float:gfTeleportSizeMin[3] = {-16.0,-16.0,-16.0};
new const Float:gfTeleportSizeMax[3] = { 16.0, 16.0, 16.0};
new const Float:gfTeleportZOffset = 36.0;
new const gTeleportStartFrames = 20;
new const gTeleportEndFrames = 5;
new const gszTeleportSound[] =			"warcraft3/blinkarrival.wav";				//from WC3 plugin
new const gszTeleportSpriteStart[] =		"sprites/flare6.spr";				//from HL
new const gszTeleportSpriteEnd[] =		"sprites/blockmaker/bm_teleport_end.spr";		//custom


/* Timer */
new const gszTimerModelStart[] = "models/blockmaker/bm_timer_start.mdl";
new const gszTimerModelEnd[] = "models/blockmaker/bm_timer_end.mdl";
new Float:gfTimerSizeMin[3] = {-8.0,-8.0, 0.0};
new Float:gfTimerSizeMax[3] = { 8.0, 8.0, 60.0};
new Float:gfTimerTime[33];
new Float:gfScoreTimes[15];
new gszScoreNames[15][32];
new gszScoreSteamIds[15][32];
new bool:gbHasTimer[33];

/* Variables */
new gSpriteIdBeam;
new gSpriteIdFire;
new gMsgScreenFade;
new gBlockSize[33];
new gMenuBeforeOptions[33];
new gChoiceOption[33];
new gBlockMenuPage[33];
new gTeleportStart[33];
new gStartTimer[33];
new gGrabbed[33];
new gGroupedBlocks[33][256];
new gGroupCount[33];
new gMeasureToolBlock1[33];
new gMeasureToolBlock2[33];
new gLongJumpDistance[33];
new gLongJumpAxis[33];
new bool:gbMeasureToolEnabled[33];
new bool:gbSnapping[33];
new bool:gbNoFallDamage[33];
new bool:gbOnIce[33];
new bool:gbNoSlowDown[33];
new bool:gbLowGravity[33];
new bool:gbOnFire[33];
new bool:gbAutoBhop[33];
new bool:gbJustDeleted[33];
new bool:gbAdminGodmode[33];
new bool:gbAdminNoclip[33];
new Float:gfSnappingGap[33];
new Float:gfOldMaxSpeed[33];
new Float:gfGrablength[33];
new Float:gfNextHealTime[33];
new Float:gfNextDamageTime[33];
new Float:gfInvincibleNextUse[33];
new Float:gfInvincibleTimeOut[33];
new Float:gfStealthNextUse[33];
new Float:gfStealthTimeOut[33];
new Float:gfTrampolineTimeout[33];
new Float:gfSpeedBoostTimeOut[33];
new Float:gfNukeNextUse[33];
new Float:gfCamouflageNextUse[33];
new Float:gfCamouflageTimeOut[33];
new Float:gfRandomNextUse[33];
new Float:gfBootsOfSpeedTimeOut[33];
new Float:gfBootsOfSpeedNextUse[33];
new Float:gfAutoBhopTimeOut[33];
new Float:gfAutoBhopNextUse[33];
new Float:gvGrabOffset[33][3];
new Float:gvMeasureToolPos1[33][3];
new Float:gvMeasureToolPos2[33][3];
new gszCamouflageOldModel[33][32];


new Float:gfHEGrenadeNextUse[33];
new Float:gfFlashbangNextUse[33];
new Float:gfSmokeGrenadeNextUse[33];


/* BLOCK & TELEPORT TYPES */
const gBlockMax = 35;
new gSelectedBlockType[gBlockMax];
new gRender[gBlockMax];
new gRed[gBlockMax];
new gGreen[gBlockMax];
new gBlue[gBlockMax];
new gAlpha[gBlockMax];

new const gszBlockClassname[] = "bm_block";
new const gszSpriteClassname[] = "bm_sprite";
new const gszTeleportStartClassname[] = "bm_teleport_start";
new const gszTeleportEndClassname[] = "bm_teleport_end";
new const gszTimerClassname[] = "bm_timer";

enum
{
	TELEPORT_START,
	TELEPORT_END,
	TIMER_START,
	TIMER_END
};

enum         // Unused # Keys: 8,9,10
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
	BM_NUKE,		//L
	BM_CAMOUFLAGE,		//M
	BM_LOWGRAVITY,		//N
	BM_FIRE,		//O
	BM_SLAP,		//P
	BM_RANDOM,		//Q
	BM_HONEY,		//R
	BM_BARRIER_CT,		//S
	BM_BARRIER_T,		//T
	BM_BOOTSOFSPEED,	//U
	BM_GLASS,		//V
	BM_BHOP_NOSLOW,		//W
	BM_AUTO_BHOP,		//X
	BM_DELAYEDBHOP,		//Y
	BM_BLIND,		//Z
	BM_DUCK,		//1
	BM_HEGRENADE,		//2
	BM_FLASHBANG,		//3
	BM_SMOKEGRENADE,	//4
	BM_DEAGLE,		//5
	BM_AWP,			//6
	BM_BIOHAZARD,		//@
	BM_ANTIDOTE,		//#
	BM_MAGICCARPET          //7
};

enum
{
	NORMAL,
	GLOWSHELL,
	TRANSCOLOR,
	TRANSALPHA,
	TRANSWHITE
};

enum
{
	RENDER_TYPE,
	RENDER_TYPE_FX,
	RENDER_TYPE_ALPHA,
	RENDER_TYPE_RED,
	RENDER_TYPE_GREEN,
	RENDER_TYPE_BLUE
};

#define MAX_DEFAULT_RENDERS 8

new const DefaultRenderName[MAX_DEFAULT_RENDERS][32] = {
	"Normal",
	"Glow Shell",
	"Bright Transparent",
	"Distorted",
	"Normal Glowing Shell",
	"Transparent GlowShell",
	"Fat GlowShell",
	"Transparent"
};

new const DefaultRenderFx[MAX_DEFAULT_RENDERS] = {
	kRenderFxNone,
	kRenderFxGlowShell,
	kRenderFxNone,
	kRenderFxDistort,
	kRenderFxGlowShell,
	kRenderFxGlowShell,
	kRenderFxGlowShell,
	kRenderFxNone
};

new const DefaultRender[MAX_DEFAULT_RENDERS] = {
	kRenderNormal,
	kRenderNormal,
	kRenderTransAdd, 
	kRenderTransAlpha,
	kRenderTransAlpha,
	kRenderTransAdd,
	kRenderNormal,
	kRenderTransTexture
};

new const Float:DefaultRenderAlpha[MAX_DEFAULT_RENDERS] = {
	0.0,
	0.0,
	100.0,
	0.0,
	1.0,
	64.0,
	255.0,
	128.0
};

new const Float:DefaultRenderRGB[MAX_DEFAULT_RENDERS][3] = {
	{0.0, 0.0, 0.0},
	{128.0, 128.0, 128.0},
	{255.0, 255.0, 255.0},
	{0.0, 0.0, 0.0},
	{64.0, 64.0, 64.0},
	{64.0, 64.0, 64.0},
	{64.0, 64.0, 64.0},
	{64.0, 64.0, 64.0}
};

new const gszRenderTypes[6][32] = {
	"Normal",		/* src */
	"TransColor",		/* c*a+dest*(1-a) */
	"TransTexture",		/* src*a+dest*(1-a) */
	"DON'T USE(Glow)",	/* src*a+dest -- No Z buffer checks */
	"TransAlpha",		/* src*srca+dest*(1-srca) */
	"TransAdd"		/* src*a+dest */
};

new const gszRenderFxTypes[21][32] = {
	"None", 
	"PulseSlow", 
	"PulseFast", 
	"PulseSlowWide", 
	"PulseFastWide", 
	"FadeSlow", 
	"FadeFast", 
	"SolidSlow", 
	"SolidFast", 	   
	"StrobeSlow", 
	"StrobeFast", 
	"StrobeFaster", 
	"FlickerSlow", 
	"FlickerFast",
	"NoDissipation",
	"Distort",		/* Distort/scale/translate flicker */
	"Hologram",		/* kRenderFxDistort + distance fade */
	"DeadPlayer",		/* kRenderAmt is the player index */
	"Explode",		/* Scale up really big! */
	"GlowShell",		/* Glowing Shell */
	"ClampMinScale"		
};

new const gszBlockValueNames[gBlockMax][32] =
{
	WORTHLESS_STR, //platform
	WORTHLESS_STR, //bhop
	"Damage per second", //damage
	"Heal per second", //healer
	WORTHLESS_STR, //nofalldamage
	"Ice Friction", //ice
	"Trampoline Velocity", //trampoline
	"SpeedBoost Velocity", //speedboost
	"Time", //invincibility
	"Time", //stealth
	WORTHLESS_STR, //death
	WORTHLESS_STR, //nuke
	"Time", //camouflage
	"Gravity Percentage", //lowgravity
	"Damage per sec", //fire
	"Damage on slap", //slap
	"Random", //random
	"Max Speed", //honey
	"Time Delay", //ctbarrier
	"Time Delay", //tbarrier
	"Time", //bootsofspeed
	WORTHLESS_STR,
	"Time Delay", //bhopnoslow
	"Time", //autobhop
	"Time Delay", //delaybhop
	"Team", //blindtrap
	"Team", //duck
	"Team", //hegren
	"Team", //flashbang
	"Team", //frost
	"Team", //deagle
	"Team", //awp
	"Team", //biohazard
	"", //antidote
	"Team"
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
	"Nuke",
	"Camouflage",
	"Low Gravity",
	"Fire",
	"Slap",
	"Random",
	"Honey",
	"CT Barrier",
	"T Barrier",
	"Boots Of Speed",
	"Glass",
	"Bunnyhop (No slow down)",
	"Auto Bunnyhop",
	"Delayed Bunnyhop",
	"Blind Trap",
	"Duck Jump",
	"High Explosive Grenade",
	"Flashbang",
	"Frost Grenade",
	"DEagle",
	"AWP",
	"Biohazard",
	"Antidote",
	"Magic Carpet"
};

// all these values must have -1.0 in the raray
new const Float:gBlockValues[gBlockMax][MAX_VALUES] = {
	
	//EXAMPLE OF A PROPERTY FOR EDITS
	//{-1.0, PROPERTY1, PROPERTY2, PROPERTY3, ....to be continued}, sample
	//{-1.0, 2.0, 4.0, 6.0, 8.0}, Propertys going by twos 2,4,6,8 etc. sample #2
	
	{-1.0, -1.0, -1.0, -1.0, -1.0}, // platform
	{-1.0, -1.0, -1.0, -1.0, -1.0}, // bhop
	{-1.0, 2.0, 5.0, 10.0, 20.0}, // damage
	{-1.0, 1.0, 2.0, 10.0, 20.0}, // healer
	{-1.0, -1.0, -1.0, -1.0,-1.0}, // no fall damage
	{-1.0, 0.05, 0.10, 0.20, 0.5}, // ice
	{-1.0, 250.0, 500.0, 800.0, 1200.0}, // trampoline
	{-1.0, 500.0,  1000.0, 1500.0, 2000.0}, // speed boost
	{-1.0, 5.0,  10.0, 30.0, 50.0}, // invincibility
	{-1.0, 5.0,  10.0, 30.0, 50.0}, // stealth
	{-1.0, -1.0, -1.0, -1.0,-1.0}, // death
	{-1.0, 5.0,  10.0, 30.0, 50.0}, // nuke
	{-1.0, 5.0,  10.0, 30.0, 50.0}, // camouflage
	{-1.0, 0.05,  0.25, 0.5, 10.0}, // low gravity
	{-1.0, 1.0, 2.0, 5.0, 10.0}, // fire
	{-1.0, 0.0, 1.0, 5.0, 10.0}, // slap
	{-1.0, -1.0, -1.0, -1.0,-1.0}, // random
	{-1.0, 0.0, 25.0, 100.0, 150.0}, // honey
	{-1.0, 0.1, 0.5, 2.0, 10.0}, // ct barrier
	{-1.0, 0.1, 0.5, 2.0, 10.0}, // t barrier
	{-1.0, 5.0,  10.0, 30.0, 50.0}, // boots of speed
	{-1.0, -1.0, -1.0, -1.0,-1.0}, // glass
	{-1.0, 0.5, 2.0, 5.0, 10.0}, // bhop no slow down
	{-1.0, 5.0,  10.0, 30.0, 50.0}, // auto bhop
	{-1.0, 0.7, 1.0, 2.0, 5.0}, // bhopdelayed
	{-1.0, -1.0, -1.0, 1.0,2.0}, // blind
	{-1.0, -1.0, -1.0, 1.0,2.0}, // duck
	{-1.0, -1.0, -1.0, 1.0,2.0}, // hegrenade
	{-1.0, -1.0, -1.0, 1.0,2.0}, // flashbang
	{-1.0, -1.0, -1.0, 1.0,2.0}, // smokegrenade
	{-1.0, -1.0, -1.0, 1.0,2.0}, // deagle
	{-1.0, -1.0, -1.0, 1.0,2.0}, // awp
	{-1.0, -1.0, -1.0, 1.0,2.0}, // bio
	{-1.0, -1.0, -1.0, 1.0,2.0}, // anti
	{-1.0, -1.0, -1.0, 1.0,2.0} // magiccarpet
};

// save IDs
new const gBlockSaveIds[gBlockMax] =
{
	'A',
	'B',
	'C',
	'D',
	'E',
	'F',
	'G',
	'H',
	'I',
	'J',
	'K',
	'L',
	'M',
	'N',
	'O',
	'P',
	'Q',
	'R',
	'S',
	'T',
	'U',
	'V',
	'W',
	'X',
	'Y',
	'Z',
	'1',
	'2',
	'3',
	'4',
	'5',
	'6',
	'@',
	'#',
	'7'
};

const gTeleportSaveId = '*';

const gTimerSaveId = '&';

//global array of strings to store the paths and filenames to the block models
new gszBlockModels[gBlockMax][64];
new gszBlockLargeModels[gBlockMax][64];
new gszBlockSmallModels[gBlockMax][64];

//array of blocks that the random block can be
const gRandomBlocksMax = 7;

new Float:gfNotRendering[3] = { -1.0, -1.0, -1.0 };

new const gRandomBlocks[gRandomBlocksMax] =
{
	BM_INVINCIBILITY,
	BM_STEALTH,
	BM_DEATH,
	BM_CAMOUFLAGE,
	BM_SLAP,
	BM_BOOTSOFSPEED,
	BM_FLASHBANG
};

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

/***** PLUGIN START *****/
public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	register_cvar(PLUGIN, VERSION, FCVAR_SERVER, 0.0);
	set_task(2.5, "poisonloop", 0, "", 0, "b");
	set_task(SECONDS, "sayrtt", _, _, _, "b" );
	set_task(CURCONFIG, "currentconfig", _, _, _, "b" );
	gmsgIcon = get_user_msgid("StatusIcon");
	gmsgScreenFade = get_user_msgid("ScreenFade");
	
	//register client commands
	register_clcmd("say /bm", "showMainMenu");
	register_clcmd("say /bcm", "showMainMenu");
	register_clcmd("+bmgrab", "cmdGrab", BM_ADMIN_LEVEL);
	register_clcmd("-bmgrab", "cmdRelease", BM_ADMIN_LEVEL);
	register_clcmd("say /dellall", "DellAll");
	register_clcmd("say /deleteall", "DellAll");
	register_clcmd("say /loadall", "LoadAll");
	register_clcmd("say /saveall", "SaveAll");
	register_clcmd("say /rtt", "cmdRockTheTemplate");
	register_clcmd("say rtt", "cmdRockTheTemplate");
	register_clcmd("say /config", "sayconfig");
	register_clcmd("say config", "sayconfig");
	register_clcmd("Enter_New_Config", "cmdNewConfig");
	
	//register forwards
	register_forward(FM_EmitSound, "forward_EmitSound");
	
	//create the menus
	createMenus();
	
	//register menus
	register_menucmd(register_menuid("bmMainMenu"), gKeysMainMenu, "handleMainMenu");
	register_menucmd(register_menuid("bmBlockMenu"), gKeysBlockMenu, "handleBlockMenu");
	register_menucmd(register_menuid("bmBlockSelectionMenu"), gKeysBlockSelectionMenu, "handleBlockSelectionMenu");
	register_menucmd(register_menuid("bmTeleportMenu"), gKeysTeleportMenu, "handleTeleportMenu");
	register_menucmd(register_menuid("bmTimerMenu"), gKeysTimerMenu, "handleTimerMenu");
	register_menucmd(register_menuid("bmMeasureMenu"), gKeysMeasureMenu, "handleMeasureMenu");
	register_menucmd(register_menuid("bmLongJumpMenu"), gKeysLongJumpMenu, "handleLongJumpMenu");
	register_menucmd(register_menuid("bmRenderMenu"), gKeysRenderMenu, "handleRenderMenu");
	register_menucmd(register_menuid("bmDefaultRenderMenu"), gKeysDefaultRenderMenu, "handleDefaultRenderMenu");
	register_menucmd(register_menuid("bmOptionsMenu"), gKeysOptionsMenu, "handleOptionsMenu");
	register_menucmd(register_menuid("bmChoiceMenu"), gKeysChoiceMenu, "handleChoiceMenu");
	register_menucmd(register_menuid("bmNextPage"), gKeysNextPage, "handleNextPage");
	register_menucmd(register_menuid("bmConfigMenu"), gKeysConfigMenu, "handleConfigMenu");
	
	//register CVARs
	register_cvar("bm_telefrags", "1");			//players near teleport exit die if someone comes through
	register_cvar("bm_firedamageamount", "20.0");		//damage you take per half-second on the fire block
	register_cvar("bm_damageamount", "5.0");		//damage you take per half-second on the damage block
	register_cvar("bm_healamount", "1.0");			//how much hp per half-second you get on the healing block
	register_cvar("bm_invincibletime", "20.0");		//how long a player is invincible
	register_cvar("bm_invinciblecooldown", "60.0");		//time before the invincible block can be used again
	register_cvar("bm_stealthtime", "20.0");		//how long a player is in stealth
	register_cvar("bm_stealthcooldown", "60.0");		//time before the stealth block can be used again
	register_cvar("bm_camouflagetime", "20.0");		//how long a player is in camouflage
	register_cvar("bm_camouflagecooldown", "60.0");		//time before the camouflage block can be used again
	register_cvar("bm_nukecooldown", "60.0");		//someone might have been invincible when it was used
	register_cvar("bm_randomcooldown", "30.0");		//time before the random block can be used again
	register_cvar("bm_bootsofspeedtime", "20.0");		//how long the player has boots of speed
	register_cvar("bm_bootsofspeedcooldown", "60.0");	//time before boots of speed can be used again
	register_cvar("bm_autobhoptime", "20.0");		//how long the player has auto bhop
	register_cvar("bm_autobhopcooldown", "60.0");		//time before auto bhop can be used again
	register_cvar("bm_teleportsound", "0");   // play a sound when teleporting
	//custom blocks
	register_cvar("bm_hegrenadecooldown", "60.0");		//time before the he grenade block can be used again
	register_cvar("bm_flashbangcooldown", "60.0");		//time before the flashbang block can be used again
	register_cvar("bm_smokegrenadecooldown", "60.0");	//time before the frost grenade block can be used again
	register_cvar("bm_slapdamageamount", "0.0");		//damage you take per half-second on the damage block
	
	gCvarConfigVoteOnStartup = register_cvar("bm_configvoteonstartup", "30", 0, 0.0);
	gCvarConfigVoteTimer = register_cvar("bm_configvotetimer", "30", 0, 0.0);
	
	//register events
	register_event("DeathMsg", "eventPlayerDeath", "a");
	register_event("TextMsg", "eventRoundRestart", "a", "2&#Game_C", "2&#Game_w");
	register_event("ResetHUD", "eventPlayerSpawn", "b");
	register_event("CurWeapon", "eventCurWeapon", "be");
	register_logevent("eventRoundRestart", 2, "1=Round_Start");
	register_event("HLTV","eventNewRound","a", "1=0","2=0");
	
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
	gszBlockModels[BM_TRAMPOLINE] = gszBlockModelDefault;
	gszBlockModels[BM_SPEEDBOOST] = gszBlockModelSpeedBoost;
	gszBlockModels[BM_INVINCIBILITY] = gszBlockModelInvincibility;
	gszBlockModels[BM_STEALTH] = gszBlockModelStealth;
	gszBlockModels[BM_DEATH] = gszBlockModelDeath;
	gszBlockModels[BM_NUKE] = gszBlockModelNuke;
	gszBlockModels[BM_CAMOUFLAGE] = gszBlockModelCamouflage;
	gszBlockModels[BM_LOWGRAVITY] = gszBlockModelLowGravity;
	gszBlockModels[BM_FIRE] = gszBlockModelFire;
	gszBlockModels[BM_SLAP] = gszBlockModelSlap;
	gszBlockModels[BM_RANDOM] = gszBlockModelRandom;
	gszBlockModels[BM_HONEY] = gszBlockModelHoney;
	gszBlockModels[BM_BARRIER_CT] = gszBlockModelBarrierCT;
	gszBlockModels[BM_BARRIER_T] = gszBlockModelBarrierT;
	gszBlockModels[BM_BOOTSOFSPEED] = gszBlockModelBootsOfSpeed;
	gszBlockModels[BM_GLASS] = gszBlockModelGlass;
	gszBlockModels[BM_BHOP_NOSLOW] = gszBlockModelBhopNoSlow;
	gszBlockModels[BM_AUTO_BHOP] = gszBlockModelAutoBhop;
	gszBlockModels[BM_DELAYEDBHOP] = gszBlockModelDelayedBhop;
	gszBlockModels[BM_BLIND] = gszBlockModelBlind;
	gszBlockModels[BM_DUCK] = gszBlockModelDuck;
	gszBlockModels[BM_HEGRENADE] = gszBlockModelHEGrenade;
	gszBlockModels[BM_FLASHBANG] = gszBlockModelFlashbang;
	gszBlockModels[BM_SMOKEGRENADE] = gszBlockModelSmokeGrenade;
	gszBlockModels[BM_DEAGLE] = gszBlockModelDEagle;
	gszBlockModels[BM_AWP] = gszBlockModelAWP;
	gszBlockModels[BM_BIOHAZARD] = gszBlockModelBiohazard;
	gszBlockModels[BM_ANTIDOTE] = gszBlockModelAntidote;
	gszBlockModels[BM_MAGICCARPET] = gszBlockModelMagicCarpet;
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	gszBlockLargeModels[BM_PLATFORM] = gszBlockModelLargePlatform;
	gszBlockLargeModels[BM_BHOP] = gszBlockModelLargeBhop;
	gszBlockLargeModels[BM_DAMAGE] = gszBlockModelLargeDamage;
	gszBlockLargeModels[BM_HEALER] = gszBlockModelLargeHealer;
	gszBlockLargeModels[BM_NOFALLDAMAGE] = gszBlockModelLargeNoFallDamage;
	gszBlockLargeModels[BM_ICE] = gszBlockModelLargeIce;
	gszBlockLargeModels[BM_TRAMPOLINE] = gszBlockModelLargeDefault;
	gszBlockLargeModels[BM_SPEEDBOOST] = gszBlockModelLargeSpeedBoost;
	gszBlockLargeModels[BM_INVINCIBILITY] = gszBlockModelLargeInvincibility;
	gszBlockLargeModels[BM_STEALTH] = gszBlockModelLargeStealth;
	gszBlockLargeModels[BM_DEATH] = gszBlockModelLargeDeath;
	gszBlockLargeModels[BM_NUKE] = gszBlockModelLargeNuke;
	gszBlockLargeModels[BM_CAMOUFLAGE] = gszBlockModelLargeCamouflage;
	gszBlockLargeModels[BM_LOWGRAVITY] = gszBlockModelLargeLowGravity;
	gszBlockLargeModels[BM_FIRE] = gszBlockModelLargeFire;
	gszBlockLargeModels[BM_SLAP] = gszBlockModelLargeSlap;
	gszBlockLargeModels[BM_RANDOM] = gszBlockModelLargeRandom;
	gszBlockLargeModels[BM_HONEY] = gszBlockModelLargeHoney;
	gszBlockLargeModels[BM_BARRIER_CT] = gszBlockModelLargeBarrierCT;
	gszBlockLargeModels[BM_BARRIER_T] = gszBlockModelLargeBarrierT;
	gszBlockLargeModels[BM_BOOTSOFSPEED] = gszBlockModelLargeBootsOfSpeed;
	gszBlockLargeModels[BM_GLASS] = gszBlockModelLargeGlass;
	gszBlockLargeModels[BM_BHOP_NOSLOW] = gszBlockModelLargeBhopNoSlow;
	gszBlockLargeModels[BM_AUTO_BHOP] = gszBlockModelLargeAutoBhop;
	gszBlockLargeModels[BM_DELAYEDBHOP] = gszBlockModelLargeDelayedBhop;
	gszBlockLargeModels[BM_BLIND] = gszBlockModelLargeBlind;
	gszBlockLargeModels[BM_DUCK] = gszBlockModelLargeDuck;
	gszBlockLargeModels[BM_HEGRENADE] = gszBlockModelLargeHEGrenade;
	gszBlockLargeModels[BM_FLASHBANG] = gszBlockModelLargeFlashbang;
	gszBlockLargeModels[BM_SMOKEGRENADE] = gszBlockModelLargeSmokeGrenade;
	gszBlockLargeModels[BM_DEAGLE] = gszBlockModelLargeDEagle;
	gszBlockLargeModels[BM_AWP] = gszBlockModelLargeAWP;
	gszBlockLargeModels[BM_BIOHAZARD] = gszBlockModelLargeBiohazard;
	gszBlockLargeModels[BM_ANTIDOTE] = gszBlockModelLargeAntidote;
	gszBlockLargeModels[BM_MAGICCARPET] = gszBlockModelLargeMagicCarpet;
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	gszBlockSmallModels[BM_PLATFORM] = gszBlockModelSmallPlatform;
	gszBlockSmallModels[BM_BHOP] = gszBlockModelSmallBhop;
	gszBlockSmallModels[BM_DAMAGE] = gszBlockModelSmallDamage;
	gszBlockSmallModels[BM_HEALER] = gszBlockModelSmallHealer;
	gszBlockSmallModels[BM_NOFALLDAMAGE] = gszBlockModelSmallNoFallDamage;
	gszBlockSmallModels[BM_ICE] = gszBlockModelSmallIce;
	gszBlockSmallModels[BM_TRAMPOLINE] = gszBlockModelSmallDefault;
	gszBlockSmallModels[BM_SPEEDBOOST] = gszBlockModelSmallSpeedBoost;
	gszBlockSmallModels[BM_INVINCIBILITY] = gszBlockModelSmallInvincibility;
	gszBlockSmallModels[BM_STEALTH] = gszBlockModelSmallStealth;
	gszBlockSmallModels[BM_DEATH] = gszBlockModelSmallDeath;
	gszBlockSmallModels[BM_NUKE] = gszBlockModelSmallNuke;
	gszBlockSmallModels[BM_CAMOUFLAGE] = gszBlockModelSmallCamouflage;
	gszBlockSmallModels[BM_LOWGRAVITY] = gszBlockModelSmallLowGravity;
	gszBlockSmallModels[BM_FIRE] = gszBlockModelSmallFire;
	gszBlockSmallModels[BM_SLAP] = gszBlockModelSmallSlap;
	gszBlockSmallModels[BM_RANDOM] = gszBlockModelSmallRandom;
	gszBlockSmallModels[BM_HONEY] = gszBlockModelSmallHoney;
	gszBlockSmallModels[BM_BARRIER_CT] = gszBlockModelSmallBarrierCT;
	gszBlockSmallModels[BM_BARRIER_T] = gszBlockModelSmallBarrierT;
	gszBlockSmallModels[BM_BOOTSOFSPEED] = gszBlockModelSmallBootsOfSpeed;
	gszBlockSmallModels[BM_GLASS] = gszBlockModelSmallGlass;
	gszBlockSmallModels[BM_BHOP_NOSLOW] = gszBlockModelSmallBhopNoSlow;
	gszBlockSmallModels[BM_AUTO_BHOP] = gszBlockModelSmallAutoBhop;
	gszBlockSmallModels[BM_DELAYEDBHOP] = gszBlockModelSmallDelayedBhop;
	gszBlockSmallModels[BM_BLIND] = gszBlockModelSmallBlind;
	gszBlockSmallModels[BM_DUCK] = gszBlockModelSmallDuck;
	gszBlockSmallModels[BM_HEGRENADE] = gszBlockModelSmallHEGrenade;
	gszBlockSmallModels[BM_FLASHBANG] = gszBlockModelSmallFlashbang;
	gszBlockSmallModels[BM_SMOKEGRENADE] = gszBlockModelSmallSmokeGrenade;
	gszBlockSmallModels[BM_DEAGLE] = gszBlockModelSmallDEagle;
	gszBlockSmallModels[BM_AWP] = gszBlockModelSmallAWP;
	gszBlockSmallModels[BM_BIOHAZARD] = gszBlockModelSmallBiohazard;
	gszBlockSmallModels[BM_ANTIDOTE] = gszBlockModelSmallAntidote;
	gszBlockSmallModels[BM_MAGICCARPET] = gszBlockModelSmallMagicCarpet;
	
	//setup default block rendering (unlisted block use normal rendering)
	setupBlockRendering(BM_INVINCIBILITY, GLOWSHELL, 255, 255, 255, 16);
	setupBlockRendering(BM_STEALTH, TRANSWHITE, 255, 255, 255, 100);
	setupBlockRendering(BM_GLASS, TRANSALPHA, 255, 255, 255, 50);
	
	//process block models config file
	processBlockModels();
	
	//precache blocks
	for (new i = 0; i < gBlockMax; ++i)
	{
		precache_model(gszBlockModels[i]);
		precache_model(gszBlockLargeModels[i]);
		precache_model(gszBlockSmallModels[i]);
	}
	
	
	//precache timer models
	precache_model(gszTimerModelStart);
	precache_model(gszTimerModelEnd);
	
	//precache sprites
	precache_model(gszTeleportSpriteStart);
	precache_model(gszTeleportSpriteEnd);
	gSpriteIdFire = precache_model(gszFireSprite);
	gSpriteIdBeam = precache_model("sprites/zbeam4.spr");
	
	//precache sounds
	precache_sound(gszTeleportSound);
	precache_sound(gszNukeExplosion);
	precache_sound(gszInvincibleSound);
	precache_sound(gszCamouflageSound);
	precache_sound(gszStealthSound);
	precache_sound(gszFireSoundFlame);
	precache_sound(gszBootsOfSpeedSound);
	precache_sound(gszAutoBhopSound);
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
	
	//get id for message 'ScreenFade'
	gMsgScreenFade = get_user_msgid("ScreenFade");
	
	//make the scoreboard times very large
	for (new i = 0; i < 15; ++i)
	{
		gfScoreTimes[i] = 999999.9;
	}
	
	//load blocks from file
	loadBlocks(0, 0, "default");
}

createMenus()
{
	//calculate maximum number of block menu pages from maximum amount of blocks
	gBlockMenuPagesMax = floatround((float(gBlockMax) / 8.0), floatround_ceil);
	
	//create main menu
	new size = sizeof(gszMainMenu);
	add(gszMainMenu, size, "\r[LA.HNS]\y Main Menu^n\rCreated by: \yiNfek^n^n");
	add(gszMainMenu, size, "\r1. \wBlock Menu^n");
	add(gszMainMenu, size, "\r2. \wTeleport Menu^n");
	add(gszMainMenu, size, "\r3. \wConfig Menu^n^n");
	add(gszMainMenu, size, "\r4. %sNoclip: %s^n");
	add(gszMainMenu, size, "\r5. %sGodmode: %s^n^n");
	add(gszMainMenu, size, "\r6. \wRender Menu^n");
	add(gszMainMenu, size, "\r7. \wSet Properties^n");
	add(gszMainMenu, size, "\r8. \wOptions Menu^n");
	add(gszMainMenu, size, "\r0. \yClose");
	gKeysMainMenu = B1 | B2 | B3 | B4 | B5 | B6 | B7 | B8 | B9 | B0;
	
	//create block menu
	size = sizeof(gszBlockMenu);
	add(gszBlockMenu, size, "\r[LA.HNS]\y Block Menu^n\rCreated by: \yiNfek^n\rPage: \y1/2^n^n");
	add(gszBlockMenu, size, "\r1. \wBlock Type: \y%s^n");
	add(gszBlockMenu, size, "\r2. %sCreate Block^n");
	add(gszBlockMenu, size, "\r3. %sConvert Block^n");
	add(gszBlockMenu, size, "\r4. %sDelete Block^n");
	add(gszBlockMenu, size, "\r5. %sRotate Block^n^n");
	add(gszBlockMenu, size, "\r6. %sNoclip: %s^n");
	add(gszBlockMenu, size, "\r7. %sGodmode: %s^n");
	add(gszBlockMenu, size, "\r8. \wChange Size^n^n");
	add(gszBlockMenu, size, "\r9. \yMore^n");
	add(gszBlockMenu, size, "\r0. \yBack");
	gKeysBlockMenu = B1 | B2 | B3 | B4 | B5 | B6 | B7 | B8 | B9 | B0;
	gKeysBlockSelectionMenu = B1 | B2 | B3 | B4 | B5 | B6 | B7 | B8 | B9 | B0;
	
	//create next page
	size = sizeof(gszNextPage);
	add(gszNextPage, size, "\r[LA.HNS]\y Block Menu^n\rCreated by: \yiNfek^n\rPage: \y2/2^n^n");
	add(gszNextPage, size, "\r1. %sRender Menu^n");
	add(gszNextPage, size, "\r2. \wSet Properties^n^n^n^n^n^n^n");
	add(gszNextPage, size, "\r9. \wOptions Menu^n^n");
	add(gszNextPage, size, "\r0. \yBack");
	gKeysNextPage = B1 | B2 | B3 | B4 | B5 | B6 | B7 | B8 | B9 | B0;
	
	//create teleport menu
	size = sizeof(gszTeleportMenu);
	add(gszTeleportMenu, size, "\r[LA.HNS]\y Teleport Menu^n\rCreated by: \yiNfek^n^n");
	add(gszTeleportMenu, size, "\r1. %sTeleport \yStart^n");
	add(gszTeleportMenu, size, "\r2. %sTeleport \rDestination^n");
	add(gszTeleportMenu, size, "\r3. %sSwitch Teleport \yStart\w/\rDestination^n");
	add(gszTeleportMenu, size, "\r4. %sDelete Teleport^n");
	add(gszTeleportMenu, size, "\r5. %sShow Teleport Path^n^n");
	add(gszTeleportMenu, size, "\r6. %sNoclip: %s^n");
	add(gszTeleportMenu, size, "\r7. %sGodmode: %s^n^n");
	add(gszTeleportMenu, size, "\r8. \wOptions Menu^n^n");
	add(gszTeleportMenu, size, "\r0. \yBack");
	gKeysTeleportMenu = B1 | B2 | B3 | B4 | B5 | B6 | B7 | B8 | B0;
	
	//create timer menu
	size = sizeof(gszTimerMenu);
	add(gszTimerMenu, size, "\yTimer Menu^n^n");
	add(gszTimerMenu, size, "\r1. %sTimer Start^n");
	add(gszTimerMenu, size, "\r2. %sTimer End^n");
	add(gszTimerMenu, size, "\r3. %sSwap Start/End^n");
	add(gszTimerMenu, size, "\r4. %sDelete Timer^n");
	add(gszTimerMenu, size, "\r5. %sRotate Timer^n^n");
	add(gszTimerMenu, size, "\r6. %sNoclip: %s^n");
	add(gszTimerMenu, size, "\r7. %sGodmode: %s^n^n");
	add(gszTimerMenu, size, "\r8. \wOptions Menu^n^n");
	add(gszTimerMenu, size, "\r0. \yBack");
	gKeysTimerMenu = B1 | B2 | B3 | B4 | B5 | B6 | B7 | B8 | B0;
	
	//measuring tool menu
	size = sizeof(gszMeasureMenu);
	add(gszMeasureMenu, size, "\yMeasuring Tool Menu^n^n");
	add(gszMeasureMenu, size, "\r1. \wBlock 1: \y%s^n");
	add(gszMeasureMenu, size, "\r2. \wBlock 2: \y%s^n");
	add(gszMeasureMenu, size, "\r3. \wPosition 1: \y%.2f, %.2f, %.2f^n");
	add(gszMeasureMenu, size, "\r4. \wPosition 2: \y%.2f, %.2f, %.2f^n^n");
	add(gszMeasureMenu, size, "\r5. %sMeasuring Tool: %s^n");
	add(gszMeasureMenu, size, "\r6. %sNoclip: %s^n");
	add(gszMeasureMenu, size, "\r7. %sGodmode: %s^n^n^n");
	add(gszMeasureMenu, size, "\r9. \wOptions Menu^n");
	add(gszMeasureMenu, size, "\y0. \yBack");
	gKeysMeasureMenu = B1 | B2 | B3 | B4 | B5 | B6 | B7 | B9 | B0;
	
	//long jump menu
	size = sizeof(gszLongJumpMenu);
	add(gszLongJumpMenu, size, "\yLong Jump Creator Menu^n^n");
	add(gszLongJumpMenu, size, "\r1. \wDistance +^n");
	add(gszLongJumpMenu, size, "\r2. %sCreate \y%d %sUnit Long Jump Along \y%s^n");
	add(gszLongJumpMenu, size, "\r3. \wDistance -^n");
	add(gszLongJumpMenu, size, "\r4. %sDelete Block^n");
	add(gszLongJumpMenu, size, "\r5. %sRotate^n^n");
	add(gszLongJumpMenu, size, "\r6. %sNoclip: %s^n");
	add(gszLongJumpMenu, size, "\r7. %sGodmode: %s^n");
	add(gszLongJumpMenu, size, "\r8. \wBlock Size: \y%s^n^n");
	add(gszLongJumpMenu, size, "\r9. \wOptions Menu^n");
	add(gszLongJumpMenu, size, "\y0. \yBack");
	gKeysLongJumpMenu = B1 | B2 | B3 | B4 | B5 | B6 | B7 | B8 | B9 | B0;
	
	size = sizeof(gszRenderMenu);
	add(gszRenderMenu, size, "\r[LA.HNS]\y Render Menu^n\rCreated by: \yiNfek^n^n");
	add(gszRenderMenu, size, "\r1. %sRender Mode^n");
	add(gszRenderMenu, size, "\r2. %sRender Effects^n");
	add(gszRenderMenu, size, "\r3. %sRender Types^n^n\y[RGB] Color & Amounts^n");
	add(gszRenderMenu, size, "\r4. %sRed^n");
	add(gszRenderMenu, size, "\r5. %sGreen^n");
	add(gszRenderMenu, size, "\r6. %sBlue^n");
	add(gszRenderMenu, size, "\r7. %sAmount^n^n");
	add(gszRenderMenu, size, "\r0. \yBack^n^n^n^n");
	gKeysRenderMenu = B1 | B2 | B3 | B4 | B5 | B6 | B7 | B8 | B9 | B0;
	
	size = sizeof(gszDefaultRenderMenu);
	add(gszDefaultRenderMenu, size, "\r[LA.HNS]\y Default Render Menu^n\rCreated by: \yiNfek^n^n");
	new i;
	new intStr[32];
	for(i = 0; i < MAX_DEFAULT_RENDERS; i++) {
		num_to_str(i + 1, intStr, 32);
		add(gszDefaultRenderMenu, size, "\r");
		add(gszDefaultRenderMenu, size, intStr);
		add(gszDefaultRenderMenu, size, ". %s");
		add(gszDefaultRenderMenu, size, DefaultRenderName[i]);
		add(gszDefaultRenderMenu, size, "^n");
	}
	add(gszDefaultRenderMenu, size, "^n\r0. \yBack");
	gKeysDefaultRenderMenu = B1 | B2 | B3 | B4 | B5 | B6 | B7 | B8 | B0;
	
	//create the options menu
	size = sizeof(gszOptionsMenu);
	add(gszOptionsMenu, size, "\r[LA.HNS]\y Options Menu^n\rCreated by: \yiNfek^n^n");
	add(gszOptionsMenu, size, "\r1. %sSnapping: %s^n");
	add(gszOptionsMenu, size, "\r2. %sSnapping gap: \y%.1f^n");
	add(gszOptionsMenu, size, "\r3. %sAdd to group^n");
	add(gszOptionsMenu, size, "\r4. %sClear group^n^n");
	add(gszOptionsMenu, size, "\r5. %sDelete all blocks^n");
	add(gszOptionsMenu, size, "\r6. %sDelete all teleports^n^n");
	add(gszOptionsMenu, size, "\r7. %sSave file \r(\y%s\r)^n");
	add(gszOptionsMenu, size, "\r8. %sLoad file \r(\ydefault\r)^n^n");
	add(gszOptionsMenu, size, "\r9. \wHelp^n^n");
	add(gszOptionsMenu, size, "\r0. \yBack");
	gKeysOptionsMenu = B1 | B2 | B3 | B4 | B5 | B6 | B7 | B8 | B9 | B0;
	
	size = sizeof(gszConfigMenu);
	add(gszConfigMenu, size, "\r[LA.HNS]\y Config Menu^n\r[Current Config: \y%s\r]^nCreated by: \yiNfek^n^n");
	add(gszConfigMenu, size, "\r1. %sSave Config^n");
	add(gszConfigMenu, size, "\r2. %sLoad New Config^n");
	add(gszConfigMenu, size, "\r3. %sCreate New Config^n");
	add(gszConfigMenu, size, "\r4. %sStart Config Vote^n^n");
	add(gszConfigMenu, size, "\r0. \yBack");
	gKeysConfigMenu = B1 | B2 | B3 | B4 | B0;
	
	//create choice (YES/NO) menu
	size = sizeof(gszChoiceMenu);
	add(gszChoiceMenu, size, "\y%s^n^n");
	add(gszChoiceMenu, size, "\r1. \wYes^n");
	add(gszChoiceMenu, size, "\r2. \wNo^n^n^n^n^n^n^n^n^n^n^n");
	add(gszChoiceMenu, size, "\r0. \yBack");
	gKeysChoiceMenu = B1 | B2 | B0;
}

setupBlockRendering(blockType, renderType, red, green, blue, alpha)
{
	gRender[blockType] = renderType;
	gRed[blockType] = red;
	gGreen[blockType] = green;
	gBlue[blockType] = blue;
	gAlpha[blockType] = alpha;
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
	new szBlockModel[64];
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
		else if (equal(szType, "NUKE")) blockType = BM_NUKE;
		else if (equal(szType, "CAMOUFLAGE")) blockType = BM_CAMOUFLAGE;
		else if (equal(szType, "LOWGRAVITY")) blockType = BM_LOWGRAVITY;
		else if (equal(szType, "FIRE")) blockType = BM_FIRE;
		else if (equal(szType, "SLAP")) blockType = BM_SLAP;
		else if (equal(szType, "RANDOM")) blockType = BM_RANDOM;
		else if (equal(szType, "HONEY")) blockType = BM_HONEY;
		else if (equal(szType, "BARRIER_CT")) blockType = BM_BARRIER_CT;
		else if (equal(szType, "BARRIER_T")) blockType = BM_BARRIER_T;
		else if (equal(szType, "BOOTSOFSPEED")) blockType = BM_BOOTSOFSPEED;
		else if (equal(szType, "GLASS")) blockType = BM_GLASS;
		else if (equal(szType, "BHOP_NOSLOW")) blockType = BM_BHOP_NOSLOW;
		else if (equal(szType, "AUTO_BHOP")) blockType = BM_AUTO_BHOP;
		else if (equal(szType, "BHOP_DELAYED")) blockType = BM_DELAYEDBHOP;
		else if (equal(szType, "BLIND")) blockType = BM_BLIND;
		else if (equal(szType, "DUCK")) blockType = BM_DUCK;
		else if (equal(szType, "HEGRENADE")) blockType = BM_HEGRENADE;
		else if (equal(szType, "SMOKEGRENADE")) blockType = BM_SMOKEGRENADE;
		else if (equal(szType, "FLASHBANG")) blockType = BM_FLASHBANG;
		else if (equal(szType, "AWP")) blockType = BM_AWP;
		else if (equal(szType, "DEAGLE")) blockType = BM_DEAGLE;
		else if (equal(szType, "BIOHAZARD")) blockType = BM_BIOHAZARD;
		else if (equal(szType, "ANTIDOTE")) blockType = BM_ANTIDOTE;
		else if (equal(szType, "MAGICCARPET")) blockType = BM_MAGICCARPET;
		
		
		//if we're dealing with a valid block type
		if (blockType >= 0 && blockType < gBlockMax)
		{
			new bool:bDoRendering = false;
			
			//if block model file exists
			if (file_exists(szBlockModel))
			{
				//set block model for given block type
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
	
	
	//set default long jump distance and axis
	gLongJumpDistance[id] = 240;
	gLongJumpAxis[id] = X;
	
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
	//disable measure tool and reset values
	gbMeasureToolEnabled[id] = false;
	gMeasureToolBlock1[id] = 0;
	gMeasureToolBlock2[id] = 0;
	gvMeasureToolPos1[id][0] = 0.0;
	gvMeasureToolPos1[id][1] = 0.0;
	gvMeasureToolPos1[id][2] = 0.0;
	gvMeasureToolPos2[id][0] = 0.0;
	gvMeasureToolPos2[id][1] = 0.0;
	gvMeasureToolPos2[id][2] = 0.0;
}

public pfn_touch(ent, id)
{
	//if touch event involves a player
	if (id > 0 && id <= 32)
	{
		//if player is alive
		if (is_user_alive(id))
		{
			//if entity involved is a block
			if (isBlock(ent))
			{
				//get the blocktype
				new blockType = entity_get_int(ent, EV_INT_body);
				
				//if blocktype is a bunnyhop block or barrier
				if (blockType == BM_BHOP || blockType == BM_BARRIER_CT || blockType == BM_BARRIER_T || blockType == BM_BHOP_NOSLOW || BM_DELAYEDBHOP)
				{
					//if task does not already exist for bunnyhop block
					if (!task_exists(TASK_BHOPSOLIDNOT + ent) && !task_exists(TASK_BHOPSOLID + ent))
					{
						//get the players team
						new CsTeams:team = cs_get_user_team(id);
						
						//if players team is different to barrier
						if (blockType == BM_BARRIER_CT && team == CS_TEAM_T)
						{
							new Float:fValue = entity_get_float(ent, EV_FL_fuser2);
							if(fValue >= 0.0)
							{
								set_task(fValue, "taskSolidNot", TASK_BHOPSOLIDNOT + ent);
							} 
							else
							{
								//make block SOLID_NOT without any delay
								taskSolidNot(TASK_BHOPSOLIDNOT + ent);
							}
						}
						else if (blockType == BM_BARRIER_T && team == CS_TEAM_CT)
						{
							new Float:fValue = entity_get_float(ent, EV_FL_fuser2);
							if(fValue >= 0.0)
							{
								set_task(fValue, "taskSolidNot", TASK_BHOPSOLIDNOT + ent);
							} 
							else
							{
								//make block SOLID_NOT without any delay
								taskSolidNot(TASK_BHOPSOLIDNOT + ent);
							}
							
						}
						else if (blockType == BM_DELAYEDBHOP || blockType == BM_BHOP_NOSLOW)
						{
							new Float:fValue = entity_get_float(ent, EV_FL_fuser2);
							if(fValue >= 0.0)
							{
								set_task(fValue, "taskSolidNot", TASK_BHOPSOLIDNOT + ent);
							}
							else
							{
								//set bhop block to be SOLID_NOT after 0.1 seconds
								set_task(0.1, "taskSolidNot", TASK_BHOPSOLIDNOT + ent);
							}
						}
						else if (blockType == BM_BHOP)
						{
							//set bhop block to be SOLID_NOT after 0.1 seconds
							set_task(0.1, "taskSolidNot", TASK_BHOPSOLIDNOT + ent);
						}
					}
				}
			}
		}
	}
	
	return PLUGIN_CONTINUE;
}

public sayrtt(id)
{
	ColorChat(id, GREEN, "Dont like this^x03 template?^x04 Type^x03 /rtt^x04 or^x03 rtt^x04 to change to another template!");
}

public currentconfig(id)
{
	ColorChat(id, GREEN, "To find out the current config or template type^x03 /config^x04 or^x03 config!");
}

public sayconfig(id)
{
	new blockCount = 0;
	new ent = -1;
	while ((ent = find_ent_by_class(ent, gszBlockClassname)))
	{
		++blockCount;
	}		
	new teleCount = 0;
	while ((ent = find_ent_by_class(ent, gszTeleportStartClassname)))
	{
		++teleCount;
	}
	
	ColorChat(id, GREEN, "Template Loaded:^x03 %s^x01 **^x04 Blocks:^x03 %d^x04 Teleports:^x03 %d", gCurConfig, blockCount, teleCount);
}

public SaveAll(id)
{
	saveBlocks(id);
}

public LoadAll(id)
{
	loadBlocks(id, 0, "default");
}

public DellAll(id)
{
	deleteAllBlocks(id, true);
	deleteAllTeleports(id, true);
}

public poisonloop()
{
	for (new id = 1; id <= get_maxplayers(); ++id)
	{
		if ( g_is_poisoned[id] && is_user_alive(id) )
		{
			new health = get_user_health(id);
			new damage = 5;
			
			if(health - damage  <= 0)
			{
				fakedamage(id, "poison", 2.0, DMG_GENERIC);
			}
			else 
			{
				set_user_health(id, health - damage);                       
			}
			
			// Poison HUD Icon
			message_begin(MSG_ONE, gmsgIcon, {0,0,0}, id);
			write_byte(2);			// status (0=hide, 1=show, 2=flash)
			write_string("dmg_poison");	// sprite name
			write_byte(0);			// red
			write_byte(125);		// green
			write_byte(0);			// blue
			message_end();
			
			message_begin(MSG_ONE, gmsgScreenFade, {0,0,0}, id);
			write_short(4096*1);    // Duration
			write_short(4096*1);    // Hold time
			write_short(4096);    // Fade type
			write_byte(0);        // Red
			write_byte(150);        // Green
			write_byte(000);        // Blue
			write_byte(100);    // Alpha
			message_end();
			set_user_rendering(id, kRenderFxGlowShell, 0, 125, 0, kRenderNormal, 16);
			
			
			// Remove poison icon
			set_task(1.0, "remove_poisonicon", id);
		}
	}
}
public remove_poisonicon(id)
{
	if ( !is_user_connected(id) ) return;
	
	// Poison HUD Icon, reset to none
	message_begin(MSG_ONE, gmsgIcon, {0,0,0}, id);
	write_byte(0);				// status (0=hide, 1=show, 2=flash)
	write_string("dmg_poison");	// sprite name
	write_byte(0);		// red
	write_byte(0);		// green
	write_byte(0);		// blue
	message_end();
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
			if (gbOnIce[i] || gbNoSlowDown[i])
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
	if ((is_user_connected(id)) )
	{
		//display type of block that player is aiming at
		new ent, body;
		get_user_aiming(id, ent, body, 320);
		
		if (isBlock(ent) && (pev(id, pev_button) & IN_USE && !(pev(id, pev_oldbuttons) & IN_USE) ))
		{
			new blockType = entity_get_int(ent, EV_INT_body);
			new Float:fValue = entity_get_float(ent, EV_FL_fuser2);
			new RenderFxType = entity_get_int(ent, EV_INT_renderfx);
			new RenderType = entity_get_int(ent, EV_INT_rendermode);
			//new Float:Alpha = entity_get_float(ent, EV_FL_renderamt); 
			new fValueStr[32];
			new Float:RGB[3];
			new Name[32];
			new valueLine[64];
			entity_get_vector(ent, EV_VEC_rendercolor, RGB);
			entity_get_string(ent, EV_SZ_targetname, Name, 31);
			if(fValue >= 0) 
			{
				float_to_str(fValue, fValueStr, 32);
			}
			else 
			{
				fValueStr[0] = 0;
				strcat(fValueStr, "Default", 32);
			}
			
			if(!strcmp(Name, ""))
			{
				strcat(Name, "Unknown", 32);
			}
			
			set_hudmessage(gHudRed, gHudGreen, gHudBlue, gfTextX, gfTextY);//, gHudEffects, gfHudFxTime, gfHudHoldTime, gfHudFadeInTime, 2.0, gHudChannel);
			if (get_user_flags(id) & BM_ADMIN_LEVEL)
			{
				if(!strcmp(gszBlockValueNames[blockType], WORTHLESS_STR))
				{
					strcat(valueLine, "", 32);
				} 
				else if(strcmp(gszBlockValueNames[blockType], WORTHLESS_STR))
				{
					if(blockType == BM_AWP
					|| blockType == BM_DEAGLE
					|| blockType == BM_DUCK
					|| blockType == BM_BIOHAZARD
					|| blockType == BM_HEGRENADE
					|| blockType == BM_FLASHBANG
					|| blockType == BM_SMOKEGRENADE
					|| blockType == BM_MAGICCARPET )
					{
						format(valueLine, 63, "%s: %s^n", gszBlockValueNames[blockType], fValue == 2.0 ? "Counter-Terrorists" : fValue == 1.0 ? "Terrorists" : "All");
					}
					else
					{
						format(valueLine, 63, "%s: %s^n", gszBlockValueNames[blockType], fValueStr);
					}
					show_hudmessage(id, "%s^n%sRenderFx: %s ^nRender: %s^nCreated by: %s", gszBlockNames[blockType], valueLine, gszRenderFxTypes[RenderFxType], gszRenderTypes[RenderType], Name);
				}
			}
			else
			{
				show_hudmessage(id, "%s^n%s: %s^nCreated By: %s", gszBlockNames[blockType], gszBlockValueNames[blockType], fValueStr, Name);
			}
		}
		
		
		if (gbMeasureToolEnabled[id])
		{
			new Float:vOrigin1[3];
			new Float:vOrigin2[3];
			new Float:vSizeMax1[3];
			new Float:vSizeMax2[3];
			new Float:fDist = 0.0;
			new Float:fX = 0.0;
			new Float:fY = 0.0;
			new Float:fZ = 0.0;
			
			if (is_valid_ent(gMeasureToolBlock1[id]))
			{
				if (is_valid_ent(gMeasureToolBlock2[id]))
				{
					//get position and size information from the blocks
					entity_get_vector(gMeasureToolBlock1[id], EV_VEC_origin, vOrigin1);
					entity_get_vector(gMeasureToolBlock2[id], EV_VEC_origin, vOrigin2);
					entity_get_vector(gMeasureToolBlock1[id], EV_VEC_maxs, vSizeMax1);
					entity_get_vector(gMeasureToolBlock2[id], EV_VEC_maxs, vSizeMax2);
					
					//calculate differences on X, Y and Z
					fX = floatabs(vOrigin2[0] - vOrigin1[0]) - vSizeMax1[0] - vSizeMax2[0];
					fY = floatabs(vOrigin2[1] - vOrigin1[1]) - vSizeMax1[1] - vSizeMax2[1];
					fZ = (vOrigin2[2] + vSizeMax2[2]) - (vOrigin1[2] + vSizeMax1[2]);
					
					//make sure X and Y are never below 0.0
					if (fX < 0.0) fX = 0.0;
					if (fY < 0.0) fY = 0.0;
				}
				else
				{
					gMeasureToolBlock2[id] = 0;
				}
			}
			else
			{
				gMeasureToolBlock1[id] = 0;
			}
			
			//calculate the sums of the 2 positions
			new Float:pos1sum = gvMeasureToolPos1[id][0] + gvMeasureToolPos1[id][1] + gvMeasureToolPos1[id][2];
			new Float:pos2sum = gvMeasureToolPos2[id][0] + gvMeasureToolPos2[id][1] + gvMeasureToolPos2[id][2];
			
			//calculate distance between measure tool positions 1 and 2
			if (pos1sum != 0.0 && pos2sum != 0.0)
			{
				fDist = get_distance_f(gvMeasureToolPos1[id], gvMeasureToolPos2[id]);
			}
			
			//show the values to the player
			set_hudmessage(gHudRed, gHudGreen, gHudBlue, 0.02, 0.22, gHudEffects, gfHudFxTime, gfHudHoldTime, gfHudFadeInTime, gfHudFadeOutTime, gHudChannel);
			show_hudmessage(id, "X: %.2f^nY: %.2f^nZ: %.2f^nDistance: %.2f", fX, fY, fZ, fDist);
		}
		
		//make sure player is alive
		if (is_user_alive(id))
		{
			//if player has low gravity
			if (gbLowGravity[id])
			{
				//get players flags
				new flags = entity_get_int(id, EV_INT_flags);
				
				//if player has feet on the ground, set gravity to normal
				if (flags & FL_ONGROUND)
				{
					set_user_gravity(id);
					
					gbLowGravity[id] = false;
				}
			}
			
			//if player has auto bhop
			if (gbAutoBhop[id])
			{
				//get players old buttons
				new oldbuttons = get_user_oldbutton(id);
				
				//remove jump flag from old buttons
				oldbuttons &= ~IN_JUMP;
				entity_set_int(id, EV_INT_oldbuttons, oldbuttons);
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
			
			//make the trace small for some blocks
			vTrace[2] = pOrigin[2] - 1.0;
			
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
					new Float:fValue = entity_get_float(ent, EV_FL_fuser2);
					
					switch (blockType)
					{
						case BM_HEALER: actionHeal(id, fValue);
						case BM_DAMAGE: actionDamage(id, fValue);
						case BM_INVINCIBILITY: actionInvincible(id, false, fValue);
						case BM_STEALTH: actionStealth(id, false, fValue);
						case BM_TRAMPOLINE: actionTrampoline(id, fValue);
						case BM_SPEEDBOOST: actionSpeedBoost(id, fValue);
						case BM_DEATH: actionDeath(id);
						case BM_NUKE: actionNuke(id, false);
						case BM_LOWGRAVITY: actionLowGravity(id, fValue);
						case BM_CAMOUFLAGE: actionCamouflage(id, false, fValue);
						case BM_FIRE: actionFire(id, ent, fValue);
						case BM_SLAP: actionSlap(id, fValue);
						case BM_RANDOM: actionRandom(id, ent);
						case BM_HONEY: actionHoney(id, fValue);
						case BM_BOOTSOFSPEED: actionBootsOfSpeed(id, false, fValue);
						case BM_AUTO_BHOP: actionAutoBhop(id, false, fValue);
						case BM_DUCK: actionDuck(id, fValue);
						case BM_BLIND: actionBlind(id, fValue);
						case BM_HEGRENADE: actionHEGrenade(id, false, fValue);
						case BM_SMOKEGRENADE: actionSmokeGrenade(id, false, fValue);
						case BM_FLASHBANG: actionFlashbang(id, false, fValue);
						case BM_AWP: actionAWP(id, fValue);
						case BM_DEAGLE: actionDEagle(id, fValue);
						case BM_BIOHAZARD: actionBiohazard(id, fValue);
						case BM_ANTIDOTE: actionAntidote(id);
						case BM_MAGICCARPET: {
							if(fValue <= 0.0)
							{
								new Float:vVelocity[3];
								pev(id, pev_velocity, vVelocity);
								vVelocity[2] = 0.0;
								set_pev(ent, pev_velocity, vVelocity);
							}
							else if(fValue == 1.0)
							{
								if(get_user_team(id) == 1)
								{
									new Float:vVelocity[3];
									pev(id, pev_velocity, vVelocity);
									vVelocity[2] = 0.0;
									set_pev(ent, pev_velocity, vVelocity);
								}
								else if(get_user_team(id) == 2)
								{
									set_hudmessage(gHudRed, gHudGreen, gHudBlue, gfTextX, gfTextY, gHudEffects, gfHudFxTime, gfHudHoldTime, gfHudFadeInTime, gfHudFadeOutTime, gHudChannel);
									show_hudmessage(id, "This block is for Terrorists only");
								}
							}
							else if(fValue == 2.0)
							{
								if(get_user_team(id) == 2)
								{
									new Float:vVelocity[3];
									pev(id, pev_velocity, vVelocity);
									vVelocity[2] = 0.0;
									set_pev(ent, pev_velocity, vVelocity);
								}
								else if(get_user_team(id) == 1)
								{
									set_hudmessage(gHudRed, gHudGreen, gHudBlue, gfTextX, gfTextY, gHudEffects, gfHudFxTime, gfHudHoldTime, gfHudFadeInTime, gfHudFadeOutTime, gHudChannel);
									show_hudmessage(id, "This block is for Counter-Terrorists only");
								}
							}
						}
					}
				}
			}
			
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
					new Float:fValue = entity_get_float(ent, EV_FL_fuser2);
					
					switch (blockType)
					{
						case BM_TRAMPOLINE: actionTrampoline(id, fValue);
						case BM_NOFALLDAMAGE: actionNoFallDamage(id);
						case BM_ICE: actionOnIce(id, fValue);
						case BM_BHOP_NOSLOW: actionNoSlowDown(id);
					}
				}
			}
			
			//display amount of invincibility/stealth/camouflage/boots of speed timeleft
			new Float:fTime = halflife_time();
			new Float:fTimeleftInvincible = gfInvincibleTimeOut[id] - fTime;
			new Float:fTimeleftStealth = gfStealthTimeOut[id] - fTime;
			new Float:fTimeleftCamouflage = gfCamouflageTimeOut[id] - fTime;
			new Float:fTimeleftBootsOfSpeed = gfBootsOfSpeedTimeOut[id] - fTime;
			new Float:fTimeleftAutoBhop = gfAutoBhopTimeOut[id] - fTime;
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
			
			if (fTimeleftCamouflage >= 0.0)
			{
				//if player is a CT
				if (get_user_team(id) == 1)
				{
					format(szText, sizeof(szText), "You look like a Counter-Terrorist: %.1f^n", fTimeleftCamouflage);
				}
				else
				{
					format(szText, sizeof(szText), "You look like a Terrorist: %.1f^n", fTimeleftCamouflage);
				}
				
				add(szTextToShow, sizeof(szTextToShow), szText);
				bShowText = true;
			}
			
			if (fTimeleftBootsOfSpeed >= 0.0)
			{
				format(szText, sizeof(szText), "Boots of speed: %.1f^n", fTimeleftBootsOfSpeed);
				add(szTextToShow, sizeof(szTextToShow), szText);
				bShowText = true;
			}
			
			if (fTimeleftAutoBhop >= 0.0)
			{
				format(szText, sizeof(szText), "Auto bunnyhop: %.1f^n", fTimeleftAutoBhop);
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
							entity_get_vector(block, EV_VEC_vuser3, vOffset);
							
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

public forward_EmitSound(id, channel, sample[])
{
	if (is_user_alive(id) && containi(sample, "common/wpn_select.wav") >= 0)
	{
		actionTimer(id);
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

public eventRoundRestart(Float:vOrigin[3])
{
	//iterate through all players
	for (new id = 1; id <= get_maxplayers(); ++id)
	{
		//reset all players timers
		resetTimers(id);
		
		awpused[id] = false;
		deagleused[id] = false;
		hegrenadeused[id] = false;
		flashbangused[id] = false;
		smokegrenadeused[id] = false;
		g_is_poisoned[id] = false;
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
	gfCamouflageTimeOut[id] = 0.0;
	gfCamouflageNextUse[id] = 0.0;
	gfNukeNextUse[id] = 0.0;
	gbOnFire[id] = false;
	gfRandomNextUse[id] = 0.0;
	gfBootsOfSpeedTimeOut[id] = 0.0;
	gfBootsOfSpeedNextUse[id] = 0.0;
	gfAutoBhopTimeOut[id] = 0.0;
	gfAutoBhopNextUse[id] = 0.0;
	
	
	gfHEGrenadeNextUse[id] = 0.0;
	gfFlashbangNextUse[id] = 0.0 ;
	gfSmokeGrenadeNextUse[id] = 0.0;
	
	
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
	
	taskId = TASK_CAMOUFLAGE + id;
	if (task_exists(taskId))
	{
		remove_task(taskId);
		
		//change back to players old model
		cs_set_user_model(id, gszCamouflageOldModel[id]);
	}
	
	taskId = TASK_BOOTSOFSPEED + id;
	if (task_exists(taskId))
	{
		remove_task(taskId);
	}
	
	taskId = TASK_AUTOBHOP + id;
	if (task_exists(taskId))
	{
		remove_task(taskId);
	}
	
	//make sure player is connected
	if (is_user_connected(id))
	{
		//set players rendering to normal
		set_user_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderNormal, 255);
	}
	
	//player is not 'on ice'
	gbOnIce[id] = false;
	
	//player slows down after jumping
	gbNoSlowDown[id] = false;
	
	//player does not have auto bhop
	gbAutoBhop[id] = false;
	
	//player does not have a timer
	gbHasTimer[id] = false;
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
actionBiohazard(id, Float:fValue)
{
	if(fValue <= 0.0)
	{
		g_is_poisoned[id] = true;
	}
	else if(fValue == 1.0)
	{
		if(get_user_team(id) == 1)
		{
			g_is_poisoned[id] = true;
		}
		else if(get_user_team(id) == 2)
		{
			set_hudmessage(gHudRed, gHudGreen, gHudBlue, gfTextX, gfTextY, gHudEffects, gfHudFxTime, gfHudHoldTime, gfHudFadeInTime, gfHudFadeOutTime, gHudChannel);
			show_hudmessage(id, "This block is for Terrorists only");
		}
	}
	else if(fValue == 2.0)
	{
		if(get_user_team(id) == 2)
		{
			g_is_poisoned[id] = true;
		}
		else if(get_user_team(id) == 1)
		{
			set_hudmessage(gHudRed, gHudGreen, gHudBlue, gfTextX, gfTextY, gHudEffects, gfHudFxTime, gfHudHoldTime, gfHudFadeInTime, gfHudFadeOutTime, gHudChannel);
			show_hudmessage(id, "This block is for Counter-Terrorists only");
		}
	}
}

actionAntidote(id)
{
	g_is_poisoned[id] = false;
	set_user_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderNormal, 0);
}

actionHEGrenade(id, OverrideTimer, Float:fValue)
{
	//get game time
	new Float:fTime = halflife_time();
	
	//make sure player is alive
	if (fTime >= gfHEGrenadeNextUse[id] || OverrideTimer)
	{
		
		if(fValue <= 0.0)
		{
			
			//give the nade
			give_item(id, "weapon_hegrenade");
			//cooldown time
			gfHEGrenadeNextUse[id] = fTime + get_cvar_float("bm_hegrenadecooldown");
			
			//show a hud message
			new name[33];
			get_user_name(id, name, 32);
			set_hudmessage(255, 255, 255, -1.0, 0.20, 0, 6.0, 12.0, 0.0, 1.0, 3);
			show_hudmessage(0, "%s has picked up an HE Grenade!", name);
		}
		else if(fValue == 1.0)
		{
			if(get_user_team(id) == 1)
			{
				
				give_item(id, "weapon_hegrenade");
				//cooldown time
				gfHEGrenadeNextUse[id] = fTime + get_cvar_float("bm_hegrenadecooldown");
				
				//show a hud message
				new name[33];
				get_user_name(id, name, 32);
				set_hudmessage(255, 255, 255, -1.0, 0.20, 0, 6.0, 12.0, 0.0, 1.0, 3);
				show_hudmessage(0, "%s has picked up an HE Grenade!", name);
			}
			else if(get_user_team(id) == 2)
			{
				set_hudmessage(gHudRed, gHudGreen, gHudBlue, gfTextX, gfTextY, gHudEffects, gfHudFxTime, gfHudHoldTime, gfHudFadeInTime, gfHudFadeOutTime, gHudChannel);
				show_hudmessage(id, "This block is for Terrorists only");
			}
		}
		else if(fValue == 2.0)
		{
			if(get_user_team(id) == 2)
			{
				give_item(id, "weapon_hegrenade");
				//cooldown time
				gfHEGrenadeNextUse[id] = fTime + get_cvar_float("bm_hegrenadecooldown");
				
				//show a hud message
				new name[33];
				get_user_name(id, name, 32);
				set_hudmessage(255, 255, 255, -1.0, 0.20, 0, 6.0, 12.0, 0.0, 1.0, 3);
				show_hudmessage(0, "%s has picked up an HE Grenade!", name);
			}
			else if(get_user_team(id) == 1)
			{
				set_hudmessage(gHudRed, gHudGreen, gHudBlue, gfTextX, gfTextY, gHudEffects, gfHudFxTime, gfHudHoldTime, gfHudFadeInTime, gfHudFadeOutTime, gHudChannel);
				show_hudmessage(id, "This block is for Counter-Terrorists only");
			}
		}
		
	}
	else
	{
		set_hudmessage(gHudRed, gHudGreen, gHudBlue, gfTextX, gfTextY, gHudEffects, gfHudFxTime, gfHudHoldTime, gfHudFadeInTime, gfHudFadeOutTime, gHudChannel);
		show_hudmessage(id, "HE Grenade next use: %.1f", gfHEGrenadeNextUse[id] - fTime);
	}
}
actionFlashbang(id, OverrideTimer, Float:fValue)
{
	//get game time
	new Float:fTime = halflife_time();
	
	//make sure player is alive
	if (fTime >= gfFlashbangNextUse[id] || OverrideTimer)
	{
		if(fValue <= 0.0)
		{
			//give the nade
			give_item(id, "weapon_flashbang");
			//cooldown time
			gfFlashbangNextUse[id] = fTime + get_cvar_float("bm_flashbangcooldown");
			
			//show a hud message
			new name[33];
			get_user_name(id, name, 32);
			set_hudmessage(255, 255, 255, -1.0, 0.20, 0, 6.0, 12.0, 0.0, 1.0, 3);
			show_hudmessage(0, "%s has picked up a Flashbang!", name);
		}
		else if(fValue == 1.0)
		{
			if(get_user_team(id) == 1)
			{
				give_item(id, "weapon_flashbang");
				//cooldown time
				gfFlashbangNextUse[id] = fTime + get_cvar_float("bm_flashbangcooldown");
				
				//show a hud message
				new name[33];
				get_user_name(id, name, 32);
				set_hudmessage(255, 255, 255, -1.0, 0.20, 0, 6.0, 12.0, 0.0, 1.0, 3);
				show_hudmessage(0, "%s has picked up a Flashbang!", name);
			}
			else if(get_user_team(id) == 2)
			{
				set_hudmessage(gHudRed, gHudGreen, gHudBlue, gfTextX, gfTextY, gHudEffects, gfHudFxTime, gfHudHoldTime, gfHudFadeInTime, gfHudFadeOutTime, gHudChannel);
				show_hudmessage(id, "This block is for Terrorists only");
			}
		}
		else if(fValue == 2.0)
		{
			if(get_user_team(id) == 2)
			{
				give_item(id, "weapon_flashbang");
				//cooldown time
				gfFlashbangNextUse[id] = fTime + get_cvar_float("bm_flashbangcooldown");
				
				//show a hud message
				new name[33];
				get_user_name(id, name, 32);
				set_hudmessage(255, 255, 255, -1.0, 0.20, 0, 6.0, 12.0, 0.0, 1.0, 3);
				show_hudmessage(0, "%s has picked up a Flashbang!", name);
			}
			else if(get_user_team(id) == 1)
			{
				set_hudmessage(gHudRed, gHudGreen, gHudBlue, gfTextX, gfTextY, gHudEffects, gfHudFxTime, gfHudHoldTime, gfHudFadeInTime, gfHudFadeOutTime, gHudChannel);
				show_hudmessage(id, "This block is for Counter-Terrorists only");
			}
		}
	}
	else
	{
		set_hudmessage(gHudRed, gHudGreen, gHudBlue, gfTextX, gfTextY, gHudEffects, gfHudFxTime, gfHudHoldTime, gfHudFadeInTime, gfHudFadeOutTime, gHudChannel);
		show_hudmessage(id, "Flashbang next use: %.1f", gfFlashbangNextUse[id] - fTime);
	}
}

actionSmokeGrenade(id, OverrideTimer, Float:fValue)
{
	//get game time
	new Float:fTime = halflife_time();
	
	//make sure player is alive
	if (fTime >= gfSmokeGrenadeNextUse[id] || OverrideTimer)
	{
		if(fValue <= 0.0)
		{
			//give the nade
			give_item(id, "weapon_smokegrenade");
			//cooldown time
			gfSmokeGrenadeNextUse[id] = fTime + get_cvar_float("bm_smokegrenadecooldown");
			
			//show a hud message
			new name[33];
			get_user_name(id, name, 32);
			set_hudmessage(255, 255, 255, -1.0, 0.20, 0, 6.0, 12.0, 0.0, 1.0, 3);
			show_hudmessage(0, "%s has picked up a Smoke Grenade!", name);
		}
		else if(fValue == 1.0)
		{
			if(get_user_team(id) == 1)
			{
				give_item(id, "weapon_smokegrenade");
				//cooldown time
				gfSmokeGrenadeNextUse[id] = fTime + get_cvar_float("bm_smokegrenadecooldown");
				
				//show a hud message
				new name[33];
				get_user_name(id, name, 32);
				set_hudmessage(255, 255, 255, -1.0, 0.20, 0, 6.0, 12.0, 0.0, 1.0, 3);
				show_hudmessage(0, "%s has picked up a Smoke Grenade!", name);
			}
			else if(get_user_team(id) == 2)
			{
				set_hudmessage(gHudRed, gHudGreen, gHudBlue, gfTextX, gfTextY, gHudEffects, gfHudFxTime, gfHudHoldTime, gfHudFadeInTime, gfHudFadeOutTime, gHudChannel);
				show_hudmessage(id, "This block is for Terrorists only");
			}
		}
		else if(fValue == 2.0)
		{
			if(get_user_team(id) == 2)
			{
				give_item(id, "weapon_smokegrenade");
				//cooldown time
				gfSmokeGrenadeNextUse[id] = fTime + get_cvar_float("bm_smokegrenadecooldown");
				
				//show a hud message
				new name[33];
				get_user_name(id, name, 32);
				set_hudmessage(255, 255, 255, -1.0, 0.20, 0, 6.0, 12.0, 0.0, 1.0, 3);
				show_hudmessage(0, "%s has picked up a Smoke Grenade!", name);
			}
			else if(get_user_team(id) == 1)
			{
				set_hudmessage(gHudRed, gHudGreen, gHudBlue, gfTextX, gfTextY, gHudEffects, gfHudFxTime, gfHudHoldTime, gfHudFadeInTime, gfHudFadeOutTime, gHudChannel);
				show_hudmessage(id, "This block is for Counter-Terrorists only");
			}
		}
	}
	else
	{
		set_hudmessage(gHudRed, gHudGreen, gHudBlue, gfTextX, gfTextY, gHudEffects, gfHudFxTime, gfHudHoldTime, gfHudFadeInTime, gfHudFadeOutTime, gHudChannel);
		show_hudmessage(id, "Smoke Grenade next use: %.1f", gfSmokeGrenadeNextUse[id] - fTime);
	}
}
actionAWP(id, Float:fValue)
{
	if (is_user_alive(id) && !awpused[id])
	{
		if(fValue <= 0.0)
		{
			give_item(id, "weapon_awp");
			cs_set_weapon_ammo(find_ent_by_owner(1, "weapon_awp", id), 1);
			awpused[id] = true;
			new name[33];
			get_user_name(id, name, 32);
			set_hudmessage(255, 255, 255, -1.0, 0.20, 0, 6.0, 12.0, 0.0, 1.0, 3);
			show_hudmessage(0, "%s has picked up an AWP!", name);
		}
		else if(fValue == 1.0)
		{
			if(get_user_team(id) == 1)
			{
				give_item(id, "weapon_awp");
				cs_set_weapon_ammo(find_ent_by_owner(1, "weapon_awp", id), 1);
				awpused[id] = true;
				new name[33];
				get_user_name(id, name, 32);
				set_hudmessage(255, 255, 255, -1.0, 0.20, 0, 6.0, 12.0, 0.0, 1.0, 3);
				show_hudmessage(0, "%s has picked up an AWP!", name);
			}
			else if(get_user_team(id) == 2)
			{
				set_hudmessage(gHudRed, gHudGreen, gHudBlue, gfTextX, gfTextY, gHudEffects, gfHudFxTime, gfHudHoldTime, gfHudFadeInTime, gfHudFadeOutTime, gHudChannel);
				show_hudmessage(id, "This block is for Terrorists only");
			}
		}
		else if(fValue == 2.0)
		{
			if(get_user_team(id) == 2)
			{
				give_item(id, "weapon_awp");
				cs_set_weapon_ammo(find_ent_by_owner(1, "weapon_awp", id), 1);
				awpused[id] = true;
				new name[33];
				get_user_name(id, name, 32);
				set_hudmessage(255, 255, 255, -1.0, 0.20, 0, 6.0, 12.0, 0.0, 1.0, 3);
				show_hudmessage(0, "%s has picked up an AWP!", name);
			}
			else if(get_user_team(id) == 1)
			{
				set_hudmessage(gHudRed, gHudGreen, gHudBlue, gfTextX, gfTextY, gHudEffects, gfHudFxTime, gfHudHoldTime, gfHudFadeInTime, gfHudFadeOutTime, gHudChannel);
				show_hudmessage(id, "This block is for Counter-Terrorists only");
			}
		}
	}
	else
	{
		set_hudmessage(gHudRed, gHudGreen, gHudBlue, gfTextX, gfTextY, gHudEffects, gfHudFxTime, gfHudHoldTime, gfHudFadeInTime, gfHudFadeOutTime, gHudChannel);
		show_hudmessage(id, "Only one AWP per round");
	}
	
}
actionDEagle(id, Float:fValue)
{
	if (is_user_alive(id) && !deagleused[id])
	{
		if(fValue <= 0.0)
		{
			give_item(id, "weapon_deagle");
			cs_set_weapon_ammo(find_ent_by_owner(1, "weapon_deagle", id), 1);
			deagleused[id] = true;
			new name[33];
			get_user_name(id, name, 32);
			set_hudmessage(255, 255, 255, -1.0, 0.20, 0, 6.0, 12.0, 0.0, 1.0, 3);
			show_hudmessage(0, "%s has picked up a DEagle!", name);
		}
		else if(fValue == 1.0)
		{
			if(get_user_team(id) == 1)
			{
				give_item(id, "weapon_deagle");
				cs_set_weapon_ammo(find_ent_by_owner(1, "weapon_deagle", id), 1);
				deagleused[id] = true;
				new name[33];
				get_user_name(id, name, 32);
				set_hudmessage(255, 255, 255, -1.0, 0.20, 0, 6.0, 12.0, 0.0, 1.0, 3);
				show_hudmessage(0, "%s has picked up a DEagle!", name);
			}
			else if(get_user_team(id) == 2)
			{
				set_hudmessage(gHudRed, gHudGreen, gHudBlue, gfTextX, gfTextY, gHudEffects, gfHudFxTime, gfHudHoldTime, gfHudFadeInTime, gfHudFadeOutTime, gHudChannel);
				show_hudmessage(id, "This block is for Terrorists only");
			}
		}
		else if(fValue == 2.0)
		{
			if(get_user_team(id) == 2)
			{
				give_item(id, "weapon_deagle");
				cs_set_weapon_ammo(find_ent_by_owner(1, "weapon_deagle", id), 1);
				deagleused[id] = true;
				new name[33];
				get_user_name(id, name, 32);
				set_hudmessage(255, 255, 255, -1.0, 0.20, 0, 6.0, 12.0, 0.0, 1.0, 3);
				show_hudmessage(0, "%s has picked up a DEagle!", name);
			}
			else if(get_user_team(id) == 1)
			{
				set_hudmessage(gHudRed, gHudGreen, gHudBlue, gfTextX, gfTextY, gHudEffects, gfHudFxTime, gfHudHoldTime, gfHudFadeInTime, gfHudFadeOutTime, gHudChannel);
				show_hudmessage(id, "This block is for Counter-Terrorists only");
			}
		}
	}
	else
	{
		set_hudmessage(gHudRed, gHudGreen, gHudBlue, gfTextX, gfTextY, gHudEffects, gfHudFxTime, gfHudHoldTime, gfHudFadeInTime, gfHudFadeOutTime, gHudChannel);
		show_hudmessage(id, "Only one DEagle per round");
		
	}
}
actionDuck(id, Float:fValue)
{
	if(fValue <= 0.0)
	{
		set_pev(id, pev_bInDuck, 1);
	}
	else if (fValue == 1.0)
	{
		if(get_user_team(id) == 1)
		{
			set_pev(id, pev_bInDuck, 1);
		}
		else if(get_user_team(id) == 2)
		{
			set_hudmessage(gHudRed, gHudGreen, gHudBlue, gfTextX, gfTextY, gHudEffects, gfHudFxTime, gfHudHoldTime, gfHudFadeInTime, gfHudFadeOutTime, gHudChannel);
			show_hudmessage(id, "This block is for Terrorists only");
		}
	}
	else if (fValue == 2.0)
	{
		if(get_user_team(id) == 2)
		{
			set_pev(id, pev_bInDuck, 1);
		}
		else if(get_user_team(id) == 1)
		{
			set_hudmessage(gHudRed, gHudGreen, gHudBlue, gfTextX, gfTextY, gHudEffects, gfHudFxTime, gfHudHoldTime, gfHudFadeInTime, gfHudFadeOutTime, gHudChannel);
			show_hudmessage(id, "This block is for Counter-Terrorists only");
		}
	}
}
actionBlind(id, Float: fValue)
{
	if(fValue <= 0.0)
	{
		message_begin(MSG_ONE, get_user_msgid("ScreenFade"), {0,0,0}, id);
		write_short(4096*2);    // Duration
		write_short(4096*2);    // Hold time
		write_short(4096);    // Fade type
		write_byte(255);        // Red
		write_byte(255);        // Green
		write_byte(255);        // Blue
		write_byte(255);    // Alpha
		message_end();
	}
	else if (fValue == 1.0)
	{
		if(get_user_team(id) == 1)
		{
			message_begin(MSG_ONE, get_user_msgid("ScreenFade"), {0,0,0}, id);
			write_short(4096*2);    // Duration
			write_short(4096*2);    // Hold time
			write_short(4096);    // Fade type
			write_byte(255);        // Red
			write_byte(255);        // Green
			write_byte(255);        // Blue
			write_byte(255);    // Alpha
			message_end();
		}
		else if(get_user_team(id) == 2)
		{
			set_hudmessage(gHudRed, gHudGreen, gHudBlue, gfTextX, gfTextY, gHudEffects, gfHudFxTime, gfHudHoldTime, gfHudFadeInTime, gfHudFadeOutTime, gHudChannel);
			show_hudmessage(id, "This block is for Terrorists only");
		}
	}
	else if (fValue == 2.0)
	{
		if(get_user_team(id) == 2)
		{
			message_begin(MSG_ONE, get_user_msgid("ScreenFade"), {0,0,0}, id);
			write_short(4096*2);    // Duration
			write_short(4096*2);    // Hold time
			write_short(4096);    // Fade type
			write_byte(255);        // Red
			write_byte(255);        // Green
			write_byte(255);        // Blue
			write_byte(255);    // Alpha
			message_end();
		}
		else if(get_user_team(id) == 1)
		{
			set_hudmessage(gHudRed, gHudGreen, gHudBlue, gfTextX, gfTextY, gHudEffects, gfHudFxTime, gfHudHoldTime, gfHudFadeInTime, gfHudFadeOutTime, gHudChannel);
			show_hudmessage(id, "This block is for Counter-Terrorists only");
		}
	}
}



actionDamage(id, Float:fValue)
{
	if (halflife_time() >= gfNextDamageTime[id])
	{
		if (get_user_health(id) > 0)
		{
			new Float:amount = get_cvar_float("bm_damageamount");
			if(fValue >= 0.0)
			{
				amount = fValue;
			}
			fakedamage(id, "damage block", amount, DMG_CRUSH);
		}
		
		gfNextDamageTime[id] = halflife_time() + 0.5;
	}
}
actionHeal(id, Float:fValue)
{
	if (halflife_time() >= gfNextHealTime[id])
	{
		new hp = get_user_health(id);
		new amount = floatround(get_cvar_float("bm_healamount"), floatround_floor);
		if(fValue >= 0.0)
		{
			amount = floatround(fValue, floatround_floor);
		}
		new sum = (hp + amount);
		
		if (sum < 100)
		{
			set_user_health(id, sum);
		}
		else
		{
			set_user_health(id, 100);
		}
		
		gfNextHealTime[id] = halflife_time() + 0.5;
	}
}

actionInvincible(id, OverrideTimer, Float:fValue)
{
	new Float:fTime = halflife_time();
	
	if (fTime >= gfInvincibleNextUse[id] || OverrideTimer)
	{
		new Float:fTimeout = get_cvar_float("bm_invincibletime");
		if(fValue >= 0.0) {
			fTimeout = fValue;
		}
		
		set_user_godmode(id, 1);
		set_task(fTimeout, "taskInvincibleRemove", TASK_INVINCIBLE + id, "", 0, "a", 1);
		
		//only make player glow white for invincibility if player isn't already stealth
		if (fTime >= gfStealthTimeOut[id])
		{
			set_user_rendering(id, kRenderFxGlowShell, 255, 255, 255, kRenderNormal, 16);
		}
		
		//play invincibility sound
		emit_sound(id, CHAN_STATIC, gszInvincibleSound, 1.0, ATTN_NORM, 0, PITCH_NORM);
		
		gfInvincibleTimeOut[id] = fTime + fTimeout;
		gfInvincibleNextUse[id] = fTime + fTimeout + get_cvar_float("bm_invinciblecooldown");
	}
	else
	{
		set_hudmessage(gHudRed, gHudGreen, gHudBlue, gfTextX, gfTextY, gHudEffects, gfHudFxTime, gfHudHoldTime, gfHudFadeInTime, gfHudFadeOutTime, gHudChannel);
		show_hudmessage(id, "Invincibility next use: %.1f", gfInvincibleNextUse[id] - fTime);
	}
}

actionStealth(id, OverrideTimer, Float:fValue)
{
	new Float:fTime = halflife_time();
	
	//check if player is outside of cooldown time to use stealth
	if (fTime >= gfStealthNextUse[id] || OverrideTimer)
	{
		new Float:fTimeout = get_cvar_float("bm_stealthtime");
		if(fValue >= 0.0) {
			fTimeout = fValue;
		}
		
		//set a task to remove stealth after time out amount
		set_task(fTimeout, "taskStealthRemove", TASK_STEALTH + id, "", 0, "a", 1);
		
		//make player invisible
		set_user_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderTransColor, 0);
		
		//play stealth sound
		emit_sound(id, CHAN_STATIC, gszStealthSound, 1.0, ATTN_NORM, 0, PITCH_NORM);
		
		gfStealthTimeOut[id] = fTime + fTimeout;
		gfStealthNextUse[id] = fTime + fTimeout + get_cvar_float("bm_stealthcooldown");
	}
	else
	{
		set_hudmessage(gHudRed, gHudGreen, gHudBlue, gfTextX, gfTextY, gHudEffects, gfHudFxTime, gfHudHoldTime, gfHudFadeInTime, gfHudFadeOutTime, gHudChannel);
		show_hudmessage(id, "Stealth next use: %.1f", gfStealthNextUse[id] - fTime);
	}
}

actionTrampoline(id, Float:fValue)
{
	//if trampoline timeout has exceeded (needed to prevent velocity being given multiple times)
	if (halflife_time() >= gfTrampolineTimeout[id])
	{
		new Float:velocity[3];
		
		//set player Z velocity to make player bounce
		entity_get_vector(id, EV_VEC_velocity, velocity);
		velocity[2] = 650.0;					//jump velocity
		if(fValue >= 0.0) {
			velocity[2] = fValue;
		}
		entity_set_vector(id, EV_VEC_velocity, velocity);
		
		entity_set_int(id, EV_INT_gaitsequence, 6);   		//play the Jump Animation
		
		gfTrampolineTimeout[id] = halflife_time() + 0.5;
	}
}

actionSpeedBoost(id, Float:fValue)
{
	//if speed boost timeout has exceeded (needed to prevent speed boost being given multiple times)
	if (halflife_time() >= gfSpeedBoostTimeOut[id])
	{
		new Float:pAim[3];
		
		//set velocity on player in direction they're aiming
		if(fValue >= 0.0) 
		{
			velocity_by_aim(id, floatround(fValue, floatround_floor), pAim);
		}
		else 
		{
			velocity_by_aim(id, 1600, pAim);
		}
		pAim[2] = 260.0;					//make sure Z velocity is only as high as a jump
		entity_set_vector(id, EV_VEC_velocity, pAim);
		
		entity_set_int(id, EV_INT_gaitsequence, 6);   		//play the Jump Animation
		
		gfSpeedBoostTimeOut[id] = halflife_time() + 0.5;
	}
}

actionNoFallDamage(id)
{
	//set the player to not receive any fall damage (handled in client_PostThink)
	gbNoFallDamage[id] = true;
}

actionOnIce(id, Float:fValue)
{
	new taskid = TASK_ICE + id;
	
	if (!gbOnIce[id])
	{
		//save players maxspeed value
		gfOldMaxSpeed[id] = get_user_maxspeed(id);
		
		//make player feel like they're on ice
		if(fValue >= 0.0) {
			entity_set_float(id, EV_FL_friction, fValue);
		} else {
			entity_set_float(id, EV_FL_friction, 0.15);
		}
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
		fakedamage(id, "teh blox0rz of death", 10000.0, DMG_GENERIC);
	}
}

actionNuke(id, OverrideTimer)
{
	//get game time
	new Float:fTime = halflife_time();
	
	//make sure player is alive
	if (is_user_alive(id) && (fTime >= gfNukeNextUse[id] || OverrideTimer))
	{
		//get players team
		new CsTeams:playerTeam = cs_get_user_team(id);
		new CsTeams:team;
		
		//iterate through all players
		for (new i = 1; i <= 32; ++i)
		{
			//make sure player is alive
			if (is_user_alive(i))
			{
				team = cs_get_user_team(i);
				
				//if this player is on a different team to the player that used the nuke
				if ((team == CS_TEAM_T && playerTeam == CS_TEAM_CT) || (team == CS_TEAM_CT && playerTeam == CS_TEAM_T))
				{
					//slay player
					fakedamage(i, "a nuke", 10000.0, DMG_BLAST);
				}
			}
			
			//make sure player is connected
			if (is_user_connected(i))
			{
				//make the screen flash for a nuke effect
				message_begin(MSG_ONE, gMsgScreenFade, {0, 0, 0}, i);
				write_short(1024);	//duration
				write_short(1024);	//hold time
				write_short(4096);	//type (in / out)
				write_byte(255);	//red
				write_byte(255);	//green
				write_byte(255);	//blue
				write_byte(255);	//alpha
				message_end();
			}
		}
		
		//play explosion sound
		emit_sound(0, CHAN_STATIC, gszNukeExplosion, 1.0, ATTN_NORM, 0, PITCH_NORM);
		
		//set the time when the player can use the nuke again (someone might have been invincible)
		gfNukeNextUse[id] = fTime + get_cvar_float("bm_nukecooldown");
		
		//get the name of the player that used the nuke
		new szPlayerName[32];
		get_user_name(id, szPlayerName, 32);
		
		//setup hud message to show who nuked what team
		set_hudmessage(255, 255, 0, -1.0, 0.35, 0, 6.0, 10.0, 1.0, 1.0);
		
		//show message saying player nuked the other team
		if (playerTeam == CS_TEAM_T)
		{
			show_hudmessage(0, "%s just nuked the Counter-Terrorists", szPlayerName);
		}
		else
		{
			show_hudmessage(0, "%s just nuked the Terrorists", szPlayerName);
		}
	}
	else
	{
		set_hudmessage(gHudRed, gHudGreen, gHudBlue, gfTextX, gfTextY, gHudEffects, gfHudFxTime, gfHudHoldTime, gfHudFadeInTime, gfHudFadeOutTime, gHudChannel);
		show_hudmessage(id, "Nuke next use: %.1f", gfNukeNextUse[id] - fTime);
	}
}

actionCamouflage(id, OverrideTimer, Float:fValue)
{
	new Float:fTime = halflife_time();
	
	//check if player is outside of cooldown time to use camouflage
	if (fTime >= gfCamouflageNextUse[id] || OverrideTimer)
	{
		new Float:fTimeout = get_cvar_float("bm_camouflagetime");
		if(fValue >= 0.0) {
			fTime = fValue;
		}
		
		//get players team and model
		new szModel[32];
		new team;
		
		cs_get_user_model(id, szModel, 32);
		
		team = get_user_team(id);
		
		//save current player model
		gszCamouflageOldModel[id] = szModel;
		
		//change player model depending on their current team
		if (team == 1)		//TERRORIST
		{
			cs_set_user_model(id, "urban");
		}
		else
		{
			cs_set_user_model(id, "leet");
		}
		
		//play camouflage sound
		emit_sound(id, CHAN_STATIC, gszCamouflageSound, 1.0, ATTN_NORM, 0, PITCH_NORM);
		
		//set a task to remove camouflage after time out amount
		set_task(fTimeout, "taskCamouflageRemove", TASK_CAMOUFLAGE + id, "", 0, "a", 1);
		
		//set timers to prevent player from using camouflage again so soon
		gfCamouflageTimeOut[id] = fTime + fTimeout;
		gfCamouflageNextUse[id] = fTime + fTimeout + get_cvar_float("bm_camouflagecooldown");
	}
	else
	{
		set_hudmessage(gHudRed, gHudGreen, gHudBlue, gfTextX, gfTextY, gHudEffects, gfHudFxTime, gfHudHoldTime, gfHudFadeInTime, gfHudFadeOutTime, gHudChannel);
		show_hudmessage(id, "Camouflage next use: %.1f", gfCamouflageNextUse[id] - fTime);
	}
}

actionLowGravity(id, Float:fValue)
{
	if(fValue >= 0.0) {
		set_user_gravity(id, fValue);
	} else {
		//set player to have low gravity
		set_user_gravity(id, 0.25);
	}
	
	//set global boolean showing player has low gravity
	gbLowGravity[id] = true;
}

actionFire(id, ent, Float:fValue)
{
	if (halflife_time() >= gfNextDamageTime[id])
	{
		new hp = get_user_health(id);
		
		//if players health is greater than 0
		if (hp > 0)
		{
			//if player does not have godmode
			if (!get_user_godmode(id))
			{
				new Float:amount = get_cvar_float("bm_firedamageamount") / 10.0;
				if(fValue >= 0.0) {
					amount = fValue;
				}
				new Float:newAmount = hp - amount;
				
				//if this amount of damage won't kill the player
				if (newAmount > 0)
				{
					set_user_health(id, floatround(newAmount, floatround_floor));
				}
				else
				{
					//use fakedamage to kill the player
					fakedamage(id, "fire block", amount, DMG_BURN);
				}
			}
			
			//get halflife time and time for next fire sound from fire block
			new Float:fTime = halflife_time();
			new Float:fNextFireSoundTime = entity_get_float(ent, EV_FL_ltime); 
			
			//if the current time is greater than or equal to the next time to play the fire sound
			if (fTime >= fNextFireSoundTime)
			{
				//play the fire sound
				emit_sound(ent, CHAN_ITEM, gszFireSoundFlame, 0.6, ATTN_NORM, 0, PITCH_NORM);
				
				//set the fire blocks time
				entity_set_float(ent, EV_FL_ltime, fTime + 0.75);
			}
			
			//get effects vectors using block origin
			new Float:origin1[3];
			new Float:origin2[3];
			entity_get_vector(ent, EV_VEC_origin, origin1);
			entity_get_vector(ent, EV_VEC_origin, origin2);
			origin1[0] -= 32.0;
			origin1[1] -= 32.0;
			origin1[2] += 10.0;
			origin2[0] += 32.0;
			origin2[1] += 32.0;
			origin2[2] += 10.0;
			
			//get a random height for the flame
			new randHeight = random_num(0, 32) + 16;
			
			//show some effects
			message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
			write_byte(TE_BUBBLES);
			write_coord(floatround(origin1[0], floatround_floor));	//min start position
			write_coord(floatround(origin1[1], floatround_floor));
			write_coord(floatround(origin1[2], floatround_floor));
			write_coord(floatround(origin2[0], floatround_floor));	//max start position
			write_coord(floatround(origin2[1], floatround_floor));
			write_coord(floatround(origin2[2], floatround_floor));
			write_coord(randHeight);				//float height
			write_short(gSpriteIdFire);				//model index
			write_byte(10);						//count
			write_coord(1);						//speed
			message_end();
		}
		
		gfNextDamageTime[id] = halflife_time() + 0.05;
	}
}

actionSlap(id, Float: fValue)
{
	if(fValue <= 0.0)
	{
		user_slap(id, 0);
		user_slap(id, 0);
	}
	else if(fValue == 1.0)
	{
		user_slap(id, 1);
		user_slap(id, 0);
	}
	else if(fValue == 5.0)
	{
		user_slap(id, 5);
		user_slap(id, 0);
	}
	else if(fValue == 10.0)
	{
		user_slap(id, 10);
		user_slap(id, 0);
	}
	set_hudmessage(255, 255, 255, -1.0, 0.20, 0, 6.0, 12.0, 0.0, 1.0, 3);
	
	show_hudmessage(id, "GET OFF MY FACE!!!");
}

actionRandom(id, ent)
{
	new Float:fTime = halflife_time();
	
	//check if player is outside of cooldown time to use camouflage
	if (fTime >= gfRandomNextUse[id])
	{
		//get which type of block this is set to be
		new blockType = entity_get_int(ent, EV_INT_iuser4);
		
		//do the random block action
		switch (blockType)
		{
			case BM_INVINCIBILITY: actionInvincible(id, true, -1.0);
			case BM_STEALTH: actionStealth(id, true, 0.0);
			case BM_DEATH: actionDeath(id);
			case BM_CAMOUFLAGE: actionCamouflage(id, true, -1.0);
			case BM_SLAP: actionSlap(id, -1.0); 
			case BM_BOOTSOFSPEED: actionBootsOfSpeed(id, true, -1.0);
			case BM_AUTO_BHOP: actionAutoBhop(id, true, -1.0);
		}
		
		//set timer to prevent player from using the random block again so soon
		gfRandomNextUse[id] = fTime + get_cvar_float("bm_randomcooldown");
		
		//set this random block to another random block!
		new randNum = random_num(0, gRandomBlocksMax - 1);
		entity_set_int(ent, EV_INT_iuser4, gRandomBlocks[randNum]);
	}
	else
	{
		set_hudmessage(gHudRed, gHudGreen, gHudBlue, gfTextX, gfTextY, gHudEffects, gfHudFxTime, gfHudHoldTime, gfHudFadeInTime, gfHudFadeOutTime, gHudChannel);
		show_hudmessage(id, "Random block next use: %.1f", gfRandomNextUse[id] - fTime);
	}
}

actionHoney(id, Float:fValue)
{
	new taskid = TASK_HONEY + id;
	
	if(fValue >= 0.0) {
		set_user_maxspeed(id, fValue);
	} else {
		//make player feel like they're stuck in honey by lowering their maxspeed
		set_user_maxspeed(id, 50.0);
	}
	
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

actionBootsOfSpeed(id, bool:OverrideTimer, Float:fValue)
{
	new Float:fTime = halflife_time();
	
	//check if player is outside of cooldown time to use the boots of speed
	if (fTime >= gfBootsOfSpeedNextUse[id] || OverrideTimer)
	{
		new Float:fTimeout = get_cvar_float("bm_bootsofspeedtime");
		if(fValue >= 0.0) {
			fTimeout = fValue;
		}
		
		//set a task to remove the boots of speed after time out amount
		set_task(fTimeout, "taskBootsOfSpeedRemove", TASK_BOOTSOFSPEED + id, "", 0, "a", 1);
		
		//set the players maxspeed to 400 so they run faster!
		set_user_maxspeed(id, gfBootsMaxSpeed);
		
		//play boots of speed sound
		emit_sound(id, CHAN_STATIC, gszBootsOfSpeedSound, 1.0, ATTN_NORM, 0, PITCH_NORM);
		
		gfBootsOfSpeedTimeOut[id] = fTime + fTimeout;
		gfBootsOfSpeedNextUse[id] = fTime + fTimeout + get_cvar_float("bm_bootsofspeedcooldown");
	}
	else
	{
		set_hudmessage(gHudRed, gHudGreen, gHudBlue, gfTextX, gfTextY, gHudEffects, gfHudFxTime, gfHudHoldTime, gfHudFadeInTime, gfHudFadeOutTime, gHudChannel);
		show_hudmessage(id, "Boots of speed next use: %.1f", gfBootsOfSpeedNextUse[id] - fTime);
	}
}

actionNoSlowDown(id)
{
	new taskid = TASK_NOSLOW + id;
	
	gbNoSlowDown[id] = true;
	
	//remove any existing 'slow down' task
	if (task_exists(taskid))
	{
		remove_task(taskid);
	}
	
	//set task to remove 'no slow down' effect very soon
	set_task(0.1, "taskSlowDown", taskid);
}

actionAutoBhop(id, bool:OverrideTimer, Float:fValue)
{
	new Float:fTime = halflife_time();
	
	//check if player is outside of cooldown time to use the auto bhop
	if (fTime >= gfAutoBhopNextUse[id] || OverrideTimer)
	{
		new Float:fTimeout = get_cvar_float("bm_autobhoptime");
		if( fValue >= 0.0) {
			fTimeout = fValue;
		}
		
		//set a task to remove the auto bhop after time out amount
		set_task(fTimeout, "taskAutoBhopRemove", TASK_AUTOBHOP + id, "", 0, "a", 1);
		
		//set autobhop boolean
		gbAutoBhop[id] = true;
		
		//play boots of speed sound
		emit_sound(id, CHAN_STATIC, gszAutoBhopSound, 1.0, ATTN_NORM, 0, PITCH_NORM);
		
		gfAutoBhopTimeOut[id] = fTime + fTimeout;
		gfAutoBhopNextUse[id] = fTime + fTimeout + get_cvar_float("bm_autobhopcooldown");
	}
	else
	{
		set_hudmessage(gHudRed, gHudGreen, gHudBlue, gfTextX, gfTextY, gHudEffects, gfHudFxTime, gfHudHoldTime, gfHudFadeInTime, gfHudFadeOutTime, gHudChannel);
		show_hudmessage(id, "Auto bunnyhop next use: %.1f", gfAutoBhopNextUse[id] - fTime);
	}
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
		
		//play teleport sound
		new playSound = get_cvar_num("bm_teleportsound");
		if(playSound != 0) { 
			emit_sound(id, CHAN_STATIC, gszTeleportSound, 1.0, ATTN_NORM, 0, PITCH_NORM);
		}
	}
}


actionTimer(id)
{
	new Float:origin[3];
	new Float:radius = 100.0;
	new ent = -1;
	new bool:bNearStart = false;
	new bool:bNearEnd = false;
	
	//get players origin
	entity_get_vector(id, EV_VEC_origin, origin);
	
	//find entities in a sphere around the player
	while ((ent = find_ent_in_sphere(ent, origin, radius)))
	{
		//if entity is a timer
		if (isTimer(ent))
		{
			//get what type of timer it is (start/end)
			new timerType = entity_get_int(ent, EV_INT_body);
			
			switch (timerType)
			{
				case TIMER_START: bNearStart = true;
				case TIMER_END: bNearEnd = true;
			}
		}
	}
	
	if (bNearStart && bNearEnd)
	{
		//start or stop timer depending on whether or not the player has a timer
		if (gbHasTimer[id])
		{
			timerStop(id);
		}
		else
		{
			timerStart(id);
		}
	}
	else if (bNearStart)
	{
		timerStart(id);
	}
	else if (bNearEnd)
	{
		timerStop(id);
	}
}

public timerStart(id)
{
	//if player is alive
	if (is_user_alive(id))
	{
		//store the game time to calculate players time later
		gfTimerTime[id] = halflife_time();
		
		//if player already had a timer
		if (gbHasTimer[id])
		{
			client_print(id, print_chat, "%sTimer Re-started.", gszPrefix);
		}
		else
		{
			gbHasTimer[id] = true;
			
			client_print(id, print_chat, "%sTimer Started.", gszPrefix);
		}
	}
}

public timerStop(id)
{
	if (gbHasTimer[id])
	{
		gbHasTimer[id] = false;
		
		//get players name
		new szName[33];
		get_user_name(id, szName, 32);
		
		//calculate players time in minutes and seconds
		new Float:fTime = halflife_time() - gfTimerTime[id];
		new Float:fMins = fTime / 60.0;
		new mins = floatround(fMins, floatround_floor);
		new Float:fSecs = (fMins - mins) * 60.0;
		
		//format the players time into a string
		new szTime[17];
		format(szTime, 16, "%s%d:%s%.3f", (mins < 10 ? "0" : ""), mins, (fSecs < 10.0 ? "0" : ""), fSecs);
		
		//announce the players time
		client_print(0, print_chat, "%s'%s' just completed the course in %s", gszPrefix, szName, szTime);
		
		//player no longer has a timer
		gbHasTimer[id] = false;
		
		//add players time to scoreboard
		timerCheckScoreboard(id, fTime);
	}
}

public timerCheckScoreboard(id, Float:fTime)
{
	new szName[32], szSteamId[32];
	
	//get players name, steam ID and time
	get_user_name(id, szName, 32);
	get_user_authid(id, szSteamId, 32);
	fTime = halflife_time() - gfTimerTime[id];
	
	for (new i = 0; i < 15; i++)
	{
		//if the player was faster than a time on the scoreboard
		if (fTime < gfScoreTimes[i])
		{
			new pos = i;
			
			//get position where the player is already on the scoreboard (if any)
			while (!equali(gszScoreSteamIds[pos], szSteamId) && pos < 14)
			{
				pos++;
			}
			
			//shift scores down
			for (new j = pos; j > i; j--)
			{
				format(gszScoreSteamIds[j], 32, gszScoreSteamIds[j - 1]);
				format(gszScoreNames[j], 32, gszScoreNames[j - 1]);
				gfScoreTimes[j] = gfScoreTimes[j - 1];
			}
			
			//put player onto the scoreboard
			format(gszScoreSteamIds[i], 32, szSteamId);
			format(gszScoreNames[i], 32, szName);
			gfScoreTimes[i] = fTime;
			
			//if player got first place on the scoreboard
			if ((i + 1) == 1)
			{
				client_print(0, print_chat, "%s'%s' is now the fastest player on the course!", gszPrefix, szName);
			}
			else
			{
				client_print(0, print_chat, "%s'%s' is now rank %d on the scoreboard", gszPrefix, szName, (i + 1));
			}
			
			break;
		}
		
		//compare steam ID of player with steam ID on scoreboard
		if (equali(gszScoreSteamIds[i], szSteamId))
		{
			//break out of loop because player did not beat their old time
			break;
		}
	}
}

public timerShowScoreboard(id)
{
	new szLine[128];
	new szMapName[32];
	new szConfigsDir[32];
	new szHostName[32];
	new i = 0, len = 0;
	new szTop15File[96];
	new szCSS[512];
	new szTime[16];
	new szName[33];
	new szBuffer[2048];
	new bufSize = sizeof(szBuffer) - 1;
	
	get_mapname(szMapName, 31);
	get_configsdir(szConfigsDir, 31);
	get_cvar_string("hostname", szHostName, 31);
	
	format(szTop15File, 96, "%s/blockmaker_scoreboard.css", szConfigsDir);
	
	//get contents of CSS file
	
	len += format(szBuffer[len], bufSize-len, "<style>%s</style>", szCSS);
	len += format(szBuffer[len], bufSize-len, "<h1>%s</h1>", szMapName);
	
	// ************* START OF TABLE **************
	len += format(szBuffer[len], bufSize-len, "<table><tr><th>#<th>Player<th>Time");
	
	//iterate through the scoreboard
	for (i = 0; i < 15; i++)
	{
		//if top15 entry is blank
		if (gfScoreTimes[i] == 999999.9)
		{
			//create table row
			format(szLine, 127, "<tr><td>%d<td id=b><td id=c>", (i+1));
		}
		else
		{
			//make name HTML friendly
			htmlFriendly(szName);
			
			//calculate players time in minutes and seconds
			new Float:fMins = (gfScoreTimes[i] / 60.0);
			new mins = floatround(fMins, floatround_floor);
			new Float:fSecs = (fMins - mins) * 60.0;
			
			//format the players time into a string
			format(szTime, 16, "%s%d:%s%.3f", (mins < 10 ? "0" : ""), mins, (fSecs < 10.0 ? "0" : ""), fSecs);
			
			//create table row
			format(szLine, 127, "<tr><td id=a>%d<td id=b>%s<td id=c>%s", (i+1), gszScoreNames[i], szTime);
		}
		
		//append table row to szBuffer
		len += format(szBuffer[len], bufSize-len, szLine);
	}
	// ************** END OF TABLE ******************
	
	new szTitle[64];
	format(szTitle, 63, "Top 15 Climbers - %s", szHostName);
	show_motd(id, szBuffer, szTitle);
	
	return PLUGIN_HANDLED;
}

/***** TASKS *****/
public taskSolidNot(ent)
{
	ent -= TASK_BHOPSOLIDNOT;
	
	//make sure entity is valid
	if (is_valid_ent(ent))
	{
		//if block isn't being grabbed
		if (entity_get_int(ent, EV_INT_iuser2) == 0)
		{
			entity_set_int(ent, EV_INT_solid, SOLID_NOT);
			new Float:tmp[3];
			tmp[0] = float(entity_get_int(ent, EV_INT_renderfx));
			tmp[1] = float(entity_get_int(ent, EV_INT_rendermode));
			tmp[2] = entity_get_float(ent, EV_FL_renderamt);
			entity_set_vector(ent, EV_VEC_vuser1, tmp);
			entity_get_vector(ent, EV_VEC_rendercolor, tmp);
			entity_set_vector(ent, EV_VEC_vuser2, tmp);
			set_rendering(ent, kRenderFxNone, 255, 255, 255, kRenderTransAdd, 25);
			set_task(1.0, "taskSolid", TASK_BHOPSOLID + ent);
		}
	}
}

public taskSolid(ent)
{
	ent -= TASK_BHOPSOLID;
	
	//make sure entity is valid
	if (isBlock(ent))
	{
		//make block solid
		entity_set_int(ent, EV_INT_solid, SOLID_BBOX);
		
		//get the player ID of who has the block in a group (if anyone)
		new player = entity_get_int(ent, EV_INT_iuser1);
		
		//if the block is in a group
		if (player > 0)
		{
			//set the block so it is now 'being grouped' (for setting the rendering)
			groupBlock(0, ent);
		}
		else
		{
			new blockType = entity_get_int(ent, EV_INT_body);
			new Float:tmp[3];
			new Float:tmp2[3];
			entity_get_vector(ent, EV_VEC_vuser1, tmp);
			entity_get_vector(ent, EV_VEC_vuser2, tmp2);
			
			set_block_rendering(ent, gRender[blockType], floatround(tmp2[0]), floatround(tmp2[1]), floatround(tmp2[2]), floatround(tmp[2]));
			entity_set_int(ent, EV_INT_renderfx, floatround(tmp[0]));
			entity_set_int(ent, EV_INT_rendermode, floatround(tmp[1]));
			entity_set_vector(ent, EV_VEC_vuser1, gfNotRendering);
			
			
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

public taskCamouflageRemove(id)
{
	id -= TASK_CAMOUFLAGE;
	
	//if player is still connected
	if (is_user_connected(id))
	{
		//change back to players old model
		cs_set_user_model(id, gszCamouflageOldModel[id]);
	}
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

public taskSlowDown(id)
{
	id -= TASK_NOSLOW;
	
	//player no longer has 'no slow down'
	gbNoSlowDown[id] = false;
}

public taskAutoBhopRemove(id)
{
	id -= TASK_AUTOBHOP;
	
	//player no long has 'auto bhop'
	gbAutoBhop[id] = false;
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
						new newBlock = copyBlock(block);
						if(newBlock) {
							new Name[32];
							get_user_name(id, Name, 31);
							replace_all(Name, 31, " ", "_");
							entity_set_string(newBlock, EV_SZ_targetname, Name);
						}
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
					new Name[32];
					get_user_name(id, Name, 31);
					replace_all(Name, 31, " ", "_");
					entity_set_string(newBlock, EV_SZ_targetname, Name);
					
					//set new block to 'being grabbed'
					entity_set_int(newBlock, EV_INT_iuser2, id);
					
					//set player to grabbing new block
					gGrabbed[id] = newBlock;
				}
			}
			else
			{
				//tell the player they can't copy a block when it is in a stuck position
				ColorChat(id, GREEN, "%sYou cannot copy a block that is in a stuck position!", gszPrefix);
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
	//if player is grabbing a timer
	else if (isTimer(gGrabbed[id]))
	{
		//delete the timer
		gbJustDeleted[id] = deleteTimer(gGrabbed[id]);
	}
}

public cmdGrab(id)
{
	//make sure player has access to use this command
	if (get_user_flags(id) & BM_ADMIN_LEVEL)
	{
		//get the entity the player is aiming at and the length
		new ent, body;
		gfGrablength[id] = get_user_aiming(id, ent, body);
		
		//set booleans depending on entity type
		new bool:bIsBlock = isBlock(ent);
		new bool:bIsTeleport = isTeleport(ent);
		new bool:bIsTimer = isTimer(ent);
		
		//if the entity is a block or teleport
		if (bIsBlock || bIsTeleport || bIsTimer)
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
										entity_set_vector(block, EV_VEC_vuser3, vOffset);
										
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
				//if entity is a timer
				else if (bIsTimer)
				{
					//set the timer to 'being grabbed'
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
	new Name[32];
	
	//get players current view model then clear it
	entity_get_string(id, EV_SZ_viewmodel, gszViewModel[id], 32);
	entity_set_string(id, EV_SZ_viewmodel, "");
	
	get_user_origin(id, bOrigin, 1);			//position from eyes (weapon aiming)
	get_user_origin(id, iAiming, 3);			//end position from eyes (hit point for weapon)
	entity_get_vector(id, EV_VEC_origin, fpOrigin);		//get player position
	entity_get_vector(ent, EV_VEC_origin, fbOrigin);	//get block position
	IVecFVec(iAiming, fAiming);
	FVecIVec(fbOrigin, bOrigin);
	get_user_name(id, Name, 31);
	replace_all(Name, 31, " ", "_");
	entity_set_string(ent, EV_SZ_targetname, Name);
	
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
	if (get_user_flags(id) & BM_ADMIN_LEVEL)
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
						ColorChat(id, GREEN, "%sGroup deleted because all the blocks were stuck!", gszPrefix);
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
								ColorChat(id, GREEN, "%sBlock deleted because it was stuck!", gszPrefix);
							}
						}
						else
						{
							//indicate that the block is no longer being grabbed
							entity_set_int(gGrabbed[id], EV_INT_iuser2, 0);
							
							//magic carpet
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
			else if (isTimer(gGrabbed[id]))
			{
				//indicate that the timer is no longer being grabbed
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
	col = (get_user_flags(id) & BM_ADMIN_LEVEL ? "\w" : "\d");
	szGodmode = (get_user_godmode(id) ? "\yOn" : "\rOff");
	szNoclip = (get_user_noclip(id) ? "\yOn" : "\rOff");
	
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
	col = (get_user_flags(id) & BM_ADMIN_LEVEL ? "\w" : "\d");
	szGodmode = (get_user_godmode(id) ? "\yOn" : "\rOff");
	szNoclip = (get_user_noclip(id) ? "\yOn" : "\rOff");
	
	//format the main menu
	format(szMenu, 256, gszBlockMenu, gszBlockNames[gSelectedBlockType[id]], col, col, col, col, col, szNoclip, col, szGodmode, col, col);
	
	//show the block menu to the player
	show_menu(id, gKeysBlockMenu, szMenu, -1, "bmBlockMenu");
	
	return PLUGIN_HANDLED;
}

showNextPage(id)
{
	new col[3];
	new szMenu[256];
	col = (get_user_flags(id) & BM_ADMIN_LEVEL ? "\w" : "\d");
	
	//format the main menu
	format(szMenu, sizeof(szMenu), gszNextPage, col, col, col, col, col, col, col, col, col, col);
	
	//show the block menu to the player
	show_menu(id, gKeysNextPage, szMenu, -1, "bmNextPage");
	
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
	format(szTitle, sizeof(szTitle), "\yBlock \rSelection %d^n^n", gBlockMenuPage[id]);
	
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
		add(szBlockMenu, sizeof(szBlockMenu), "^n\r9. \yMore");
	}
	else
	{
		add(szBlockMenu, sizeof(szBlockMenu), "^n");
	}
	
	//add a back option to the menu
	add(szBlockMenu, sizeof(szBlockMenu), "^n\r0. \yBack");
	
	//display the block selection menu
	show_menu(id, gKeysBlockSelectionMenu, szBlockMenu, -1, "bmBlockSelectionMenu");
}

showTeleportMenu(id)
{
	new col[3];
	new szMenu[256];
	new szGodmode[6];
	new szNoclip[6];
	col = (get_user_flags(id) & BM_ADMIN_LEVEL ? "\w" : "\d");
	szGodmode = (get_user_godmode(id) ? "\yOn" : "\rOff");
	szNoclip = (get_user_noclip(id) ? "\yOn" : "\rOff");
	
	//format teleport menu
	format(szMenu, sizeof(szMenu), gszTeleportMenu, col, (gTeleportStart[id] ? "\w" : "\d"), col, col, col, col, szNoclip, col, szGodmode);
	
	show_menu(id, gKeysTeleportMenu, szMenu, -1, "bmTeleportMenu");
}

showTimerMenu(id)
{
	new col[3];
	new szMenu[256];
	new szGodmode[6];
	new szNoclip[6];
	col = (get_user_flags(id) & BM_ADMIN_LEVEL ? "\w" : "\d");
	szGodmode = (get_user_godmode(id) ? "\yOn" : "\rOff");
	szNoclip = (get_user_noclip(id) ? "\yOn" : "\rOff");
	
	//format timer menu
	format(szMenu, sizeof(szMenu), gszTimerMenu, col, (gStartTimer[id] ? "\w" : "\d"), col, col, col, col, szNoclip, col, szGodmode);
	
	show_menu(id, gKeysTimerMenu, szMenu, -1, "bmTimerMenu");
}

showMeasureMenu(id)
{
	new col[3];
	new szMenu[512];
	new szGodmode[6];
	new szNoclip[6];
	new szBlock1[40];
	new szBlock2[40];
	new szMeasureTool[16];
	
	col = (get_user_flags(id) & BM_ADMIN_LEVEL ? "\w" : "\d");
	
	//if players measuring block 1 is valid
	if (is_valid_ent(gMeasureToolBlock1[id]))
	{
		//add entity id to the start of the string followed by a hyphon seperator
		num_to_str(gMeasureToolBlock1[id], szBlock1, 40);
		add(szBlock1, 40, " - ");
		
		//if entity is a block
		if (isBlock(gMeasureToolBlock1[id]))
		{
			new blockType = entity_get_int(gMeasureToolBlock1[id], EV_INT_body);
			add(szBlock1, 40, gszBlockNames[blockType]);
		}
		else if (isTimer(gMeasureToolBlock1[id]))
		{
			//get what type of timer it is (start/end)
			new timerType = entity_get_int(gMeasureToolBlock1[id], EV_INT_body);
			
			switch (timerType)
			{
				case TIMER_START: add(szBlock1, 40, "Timer Start");
				case TIMER_END: add(szBlock1, 40, "Timer End");
			}
		}
	}
	else
	{
		szBlock1 = "\rNone";
	}
	
	//if players measuring block 2 is valid
	if (is_valid_ent(gMeasureToolBlock2[id]))
	{
		//add entity id to the start of the string followed by a hyphon seperator
		num_to_str(gMeasureToolBlock2[id], szBlock2, 40);
		add(szBlock2, 40, " - ");
		
		//if entity is a block
		if (isBlock(gMeasureToolBlock2[id]))
		{
			new blockType = entity_get_int(gMeasureToolBlock2[id], EV_INT_body);
			add(szBlock2, 40, gszBlockNames[blockType]);
		}
		else if (isTimer(gMeasureToolBlock2[id]))
		{
			//get what type of timer it is (start/end)
			new timerType = entity_get_int(gMeasureToolBlock2[id], EV_INT_body);
			
			switch (timerType)
			{
				case TIMER_START: add(szBlock2, 40, "Timer Start");
				case TIMER_END: add(szBlock2, 40, "Timer Stop");
			}
		}
	}
	else
	{
		szBlock2 = "\rNone";
	}
	
	szMeasureTool = (gbMeasureToolEnabled[id] ? "\yOn" : "\rOff");
	szNoclip = (get_user_noclip(id) ? "\yOn" : "\rOff");
	szGodmode = (get_user_godmode(id) ? "\yOn" : "\rOff");
	
	//format measure menu
	format(szMenu, sizeof(szMenu), gszMeasureMenu, szBlock1, szBlock2, gvMeasureToolPos1[id][0], gvMeasureToolPos1[id][1], gvMeasureToolPos1[id][2], gvMeasureToolPos2[id][0], gvMeasureToolPos2[id][1], gvMeasureToolPos2[id][2], col, szMeasureTool, col, szNoclip, col, szGodmode);
	
	//show the measure menu to the player
	show_menu(id, gKeysMeasureMenu, szMenu, -1, "bmMeasureMenu");
}

showLongJumpMenu(id)
{
	new col[3];
	new szMenu[256];
	new szGodmode[6];
	new szNoclip[6];
	new szSize[8];
	
	col = (get_user_flags(id) & BM_ADMIN_LEVEL ? "\w" : "\d");
	szNoclip = (get_user_noclip(id) ? "\yOn" : "\rOff");
	szGodmode = (get_user_godmode(id) ? "\yOn" : "\rOff");
	
	switch (gBlockSize[id])
	{
		case SMALL: szSize = "Small";
		case NORMAL: szSize = "Normal";
		case LARGE: szSize = "Large";
	}
	
	//format the long jump menu
	format(szMenu, sizeof(szMenu), gszLongJumpMenu, col, gLongJumpDistance[id], col, (gLongJumpAxis[id] == X ? "X" : "Y"), col, col, col, szNoclip, col, szGodmode, szSize);
	
	//show the long jump menu to the player
	show_menu(id, gKeysLongJumpMenu, szMenu, -1, "bmLongJumpMenu");
}


showRenderMenu(id) 
{
	new col[3];
	new szMenu[256];
	col = (get_user_flags(id) & BM_ADMIN_LEVEL ? "\w" : "\d");
	
	//format timer menu
	format(szMenu, sizeof(szMenu), gszRenderMenu, col, col, col, col, col, col, col);
	
	show_menu(id, gKeysRenderMenu, szMenu, -1, "bmRenderMenu");
}

showDefaultRenderMenu(id)
{
	new col[3];
	new szMenu[256];
	col = (get_user_flags(id) & BM_ADMIN_LEVEL ? "\w" : "\d");
	
	//format timer menu
	format(szMenu, sizeof(szMenu), gszDefaultRenderMenu, col, col, col, col, col, col, col, col);
	
	show_menu(id, gKeysDefaultRenderMenu, szMenu, -1, "bmDefaultRenderMenu");
}


showOptionsMenu(id, oldMenu)
{
	//set the oldmenu global variable so when the back key is pressed it goes back to the previous menu
	gMenuBeforeOptions[id] = oldMenu;
	
	new col[3];
	new szSnapping[6];
	new szMenu[256];
	col = (get_user_flags(id) & BM_ADMIN_LEVEL ? "\w" : "\d");
	szSnapping = (gbSnapping[id] ? "\yOn" : "\rOff");
	
	//format the options menu
	format(szMenu, sizeof(szMenu), gszOptionsMenu, col, szSnapping, col, gfSnappingGap[id], col, col, col, col, col, gCurConfig, col);
	
	//show the options menu to player
	show_menu(id, gKeysOptionsMenu, szMenu, -1, "bmOptionsMenu");
}

showConfigMenu(id)
{
	new col[3];
	new szMenu[256];
	col = (get_user_flags(id) & BM_ADMIN_LEVEL ? "\w" : "\d");
	
	//format the main menu
	format(szMenu, 256, gszConfigMenu, gCurConfig, col, col, col, col);
	
	//show the block menu to the player
	show_menu(id, gKeysConfigMenu, szMenu, -1, "bmConfigMenu");
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

public handleMainMenu(id, num)
{
	switch (num)
	{
		case N1: { showBlockMenu(id); }
		case N2: { showTeleportMenu(id); }
		case N3: { showConfigMenu(id); }
		case N4: { toggleNoclip(id); }
		case N5: { toggleGodmode(id); }
		case N6: { showRenderMenu(id); }
		case N7: { adjustValue(id); }
		case N8: { showOptionsMenu(id, 1); }
		case N0: { return; }
	}
	
	//selections 1, 2, 3, 4 and 8 show different menus
	if (num != N1 && num != N2 && num != N3 && num!= N6 && num != N8)
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
		case N8: { cmdAdjustSize(id); }
		case N9: { showNextPage(id); }
		case N0: { showMainMenu(id); }
	}
	
	//selections 1, 8 and 0 show different menus
	if (num != N1 && num != N0 && num != N9)
	{
		//display menu again
		showBlockMenu(id);
	}
}

public handleNextPage(id, num)
{
	switch (num)
	{
		case N1: { showRenderMenu(id); }
		case N2: { adjustValue(id); }
		case N3: { showOptionsMenu(id, 2); }
		case N0: { showBlockMenu(id); }
	}
	
	//selections 1, 8 and 0 show different menus
	if (num != N1 && num != N3 && num != N0)
	{
		//display menu again
		showNextPage(id);
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

public handleTimerMenu(id, num)
{
	switch (num)
	{
		case N1: { createTimerAiming(id, TIMER_START); }
		case N2: { createTimerAiming(id, TIMER_END); }
		case N3: { swapTimerAiming(id); }
		case N4: { deleteTimerAiming(id); }
		case N5: { rotateTimerAiming(id); }
		case N6: { toggleNoclip(id); }
		case N7: { toggleGodmode(id); }
		case N9: { showOptionsMenu(id, 4); }
		case N0: { showMainMenu(id); }
	}
	
	//selections 9 and 0 show different menus
	if (num != N9 && num != N0)
	{
		showTimerMenu(id);
	}
}

public handleMeasureMenu(id, num)
{
	switch (num)
	{
		case N1: { measureToolSelectBlock(id, 1); }
		case N2: { measureToolSelectBlock(id, 2); }
		case N3: { measureToolSelectPos(id, 1); }
		case N4: { measureToolSelectPos(id, 2); }
		case N5: { toggleMeasureTool(id); }
		case N6: { toggleNoclip(id); }
		case N7: { toggleGodmode(id); }
		case N9: { showOptionsMenu(id, 5); }
		case N0: { showMainMenu(id); }
	}
	
	//selections 9 and 0 show different menus
	if (num != N9 && num != N0)
	{
		showMeasureMenu(id);
	}
}

public handleLongJumpMenu(id, num)
{
	switch (num)
	{
		case N1: { longJumpDistance(id, 1); }
		case N2: { longJumpCreate(id); }
		case N3: { longJumpDistance(id, 2); }
		case N4: { deleteBlockAiming(id); }
		case N5: { longJumpRotate(id); }
		case N6: { toggleNoclip(id); }
		case N7: { toggleGodmode(id); }
		case N8: { changeBlockSize(id); }
		case N9: { showOptionsMenu(id, 6); }
		case N0: { showMainMenu(id); }
	}
	
	//selections 9 and 0 show different menus
	if (num != N9 && num != N0)
	{
		showLongJumpMenu(id);
	}
}


public handleRenderMenu(id, num) {
	switch (num) 
	{
		case N1: { showDefaultRenderMenu(id); }
		case N2: { adjustRenderValue(id, RENDER_TYPE_FX); }
		case N3: { adjustRenderValue(id, RENDER_TYPE); }
		case N4: { adjustRenderValue(id, RENDER_TYPE_RED); }
		case N5: { adjustRenderValue(id, RENDER_TYPE_GREEN); }
		case N6: { adjustRenderValue(id, RENDER_TYPE_BLUE); }
		case N7: { adjustRenderValue(id, RENDER_TYPE_ALPHA); }
		case N0: { showBlockMenu(id); }
		
	}
	if (num != N0 && num != N1) {
		showRenderMenu(id);
	}
}

public handleDefaultRenderMenu(id, num) {
	switch(num) {
		case N1: { setDefaultRender(id, 0); }
		case N2: { setDefaultRender(id, 1); }
		case N3: { setDefaultRender(id, 2); }
		case N4: { setDefaultRender(id, 3); }
		case N5: { setDefaultRender(id, 4); }
		case N6: { setDefaultRender(id, 5); }
		case N7: { setDefaultRender(id, 6); }
		case N8: { setDefaultRender(id, 7); }
		case N0: { showRenderMenu(id); }
	}
	if(num != N0) {
		showDefaultRenderMenu(id);
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
				case 4: showTimerMenu(id);
				case 5: showMeasureMenu(id);
				case 6: showLongJumpMenu(id);
				
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

public handleConfigMenu(id, num)
{
	new bool:isNotAdmin = false;
	switch (num)
	{
		case N1: saveBlocks(id);
		case N2: {
			if (get_user_flags(id) & BM_ADMIN_LEVEL) {
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
				
				menu_setprop(loadMenu, MPROP_EXITNAME, "Config Menu");
				
				if ( display )
				{
					menu_display(id, loadMenu, 0);
					return PLUGIN_CONTINUE;
				}
				else
				{
					client_print(id, print_chat, "%s There are no configs to load!", gszPrefix);
					showConfigMenu(id);
				}
			} else {
				isNotAdmin = true;
			}
		}
		case N3: {
			if (get_user_flags(id) & BM_ADMIN_LEVEL) {
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
		case N0: showMainMenu(id);
	}
	
	if (isNotAdmin) showConfigMenu(id);
	
	if (num != N2 && num != N4 && num != N0)
		showConfigMenu(id);
	
	return PLUGIN_HANDLED;
}



public cmdNewConfig(id)
{
	if ( !( get_user_flags(id) & BM_ADMIN_LEVEL) ) 
	{
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
		showConfigMenu(id);
	} else {
		menu_destroy(menu);
		showConfigMenu(id);
	}
}

measureToolSelectBlock(id, num)
{
	new ent;
	new body;
	get_user_aiming(id, ent, body);
	
	//if player is aiming at a block or a timer
	if (isBlock(ent) || isTimer(ent))
	{
		switch (num)
		{
			case 1:
			{
				//if block being aimed at is different than one already selected
				if (ent != gMeasureToolBlock2[id])
				{
					gMeasureToolBlock1[id] = ent;
				}
			}
			
			case 2:
			{
				//if block being aimed at is different than one already selected
				if (ent != gMeasureToolBlock1[id])
				{
					gMeasureToolBlock2[id] = ent;
				}
			}
			
			default:
			{
				log_amx("%sInvalid number in measureToolSelectBlock()", gszPrefix);
			}
		}
	}
}

measureToolSelectPos(id, num)
{
	new origin[3];
	new Float:vOrigin[3];
	
	//get the origin of where the player is aiming
	get_user_origin(id, origin, 3);
	IVecFVec(origin, vOrigin);
	
	switch (num)
	{
		case 1:
		{
			gvMeasureToolPos1[id] = vOrigin;
		}
		
		case 2:
		{
			gvMeasureToolPos2[id] = vOrigin;
		}
		
		default:
		{
			log_amx("%sInvalid number in measureToolSelectPos()", gszPrefix);
		}
	}
}

toggleMeasureTool(id)
{
	//make sure player has access to this command
	if (get_user_flags(id) & BM_ADMIN_LEVEL)
	{
		gbMeasureToolEnabled[id] = !gbMeasureToolEnabled[id];
	}
}

longJumpDistance(id, num)
{
	switch (num)
	{
		case 1:
		{
			if (gLongJumpDistance[id] < 300) gLongJumpDistance[id]++;
		}
		
		case 2:
		{
			if (gLongJumpDistance[id] > 200) gLongJumpDistance[id]--;
		}
		
		default:
		{
			log_amx("%sInvalid number in longJumpDistance()", gszPrefix);
		}
	}
}

longJumpCreate(id)
{
	//make sure player has access to this command
	if (get_user_flags(id) & BM_ADMIN_LEVEL)
	{
		new origin[3];
		new Float:vOrigin[3];
		new Float:fScale;
		new bool:bFailed = false;
		new axis;
		
		//get the origin of the player and add Z offset
		get_user_origin(id, origin, 3);
		IVecFVec(origin, vOrigin);
		vOrigin[2] += gfBlockSizeMaxForZ[2];
		
		//get scale depending on size
		switch (gBlockSize[id])
		{
			case SMALL: fScale = SCALE_SMALL;
			case NORMAL: fScale = SCALE_NORMAL;
			case LARGE: fScale = SCALE_LARGE;
		}
		
		//calculate half the jump distance and half the width of the block
		new Float:fDist = gLongJumpDistance[id] / 2.0;
		new Float:fHalfWidth = gfBlockSizeMaxForZ[0] * fScale;
		
		//move origin along X and create first block
		vOrigin[axis] -= (fDist + fHalfWidth);
		// keep track of the user's setting, since u expect teh lj to be created properly and not snap to crap
		new bool:origSnapping = gbSnapping[id];
		gbSnapping[id] = false;
		new block1 = createBlockSize(id, BM_PLATFORM, vOrigin, Z, gBlockSize[id]);
		
		//set axis on which to create the two blocks
		axis = gLongJumpAxis[id];
		
		//if first block is not stuck
		if (!isBlockStuck(block1))
		{
			//move origin along X and create second block
			vOrigin[axis] += (fDist + fHalfWidth) * 2;
			new block2 = createBlockSize(id, BM_PLATFORM, vOrigin, Z, gBlockSize[id]);
			
			//if block is stuck
			if (isBlockStuck(block2))
			{
				//delete both blocks
				deleteBlock(block1);
				deleteBlock(block2);
				bFailed = true;
			}
		}
		else
		{
			//delete the block
			deleteBlock(block1);
			bFailed = true;
		}
		gbSnapping[id] = origSnapping;
		//if long jump failed to create (because one of the blocks was stuck) notify the player
		if (bFailed)
		{
			client_print(id, print_chat, "%sLong jump failed to create because one or more of the blocks were stuck.", gszPrefix);
		}
	}
}

longJumpRotate(id)
{
	//swap between X and Y axes
	if (gLongJumpAxis[id] == X)
	{
		gLongJumpAxis[id] = Y;
	}
	else
	{
		gLongJumpAxis[id] = X;
	}
}

toggleGodmode(id)
{
	new szName[32];
	get_user_name(id, szName, 32);
	
	//make sure player has access to this command
	if (get_user_flags(id) & BM_ADMIN_LEVEL)
	{
		//if player has godmode
		if (get_user_godmode(id))
		{
			//turn off godmode for player
			set_user_godmode(id, 0);
			gbAdminGodmode[id] = false;
			
			ColorChat(0, GREEN, "[LA.HNS]^x03 %s^x04 Disabled Godmode.", szName);
		}
		else
		{
			//turn on godmode for player
			set_user_godmode(id, 1);
			gbAdminGodmode[id] = true;
			
			ColorChat(0, GREEN, "[LA.HNS]^x03 %s^x04 Enabled Godmode.", szName);
		}
	}
}

toggleNoclip(id)
{
	new szName[32];
	get_user_name(id, szName, 32);
	
	//make sure player has access to this command
	if (get_user_flags(id) & BM_ADMIN_LEVEL)
	{
		//if player has noclip
		if (get_user_noclip(id))
		{
			//turn off noclip for player
			set_user_noclip(id, 0);
			gbAdminNoclip[id] = false;
			
			ColorChat(0, GREEN, "[LA.HNS]^x03 %s^x04 Disabled Noclip.", szName);
		}
		else
		{
			//turn on noclip for player
			set_user_noclip(id, 1);
			gbAdminNoclip[id] = true;
			
			ColorChat(0, GREEN, "[LA.HNS]^x03 %s^x04 Enabled Noclip.", szName);
		}
	}
}

changeBlockSize(id)
{
	switch (gBlockSize[id])
	{
		case SMALL: gBlockSize[id] = NORMAL;
		case NORMAL: gBlockSize[id] = LARGE;
		case LARGE: gBlockSize[id] = SMALL;
	}
}

toggleSnapping(id)
{
	//make sure player has access to this command
	if (get_user_flags(id) & BM_ADMIN_LEVEL)
	{
		gbSnapping[id] = !gbSnapping[id];
	}
}

toggleSnappingGap(id)
{
	//make sure player has access to this command
	if (get_user_flags(id) & BM_ADMIN_LEVEL)
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
	new Float:fFireDamageAmount = get_cvar_float("bm_firedamageamount");
	new Float:fDamageAmount = get_cvar_float("bm_damageamount");
	new Float:fHealAmount = get_cvar_float("bm_healamount");
	new Float:fInvincibleTime = get_cvar_float("bm_invincibletime");
	new Float:fInvincibleCooldown = get_cvar_float("bm_invinciblecooldown");
	new Float:fStealthTime = get_cvar_float("bm_stealthtime");
	new Float:fStealthCooldown = get_cvar_float("bm_stealthcooldown");
	new Float:fCamouflageTime = get_cvar_float("bm_camouflagetime");
	new Float:fCamouflageCooldown = get_cvar_float("bm_camouflagecooldown");
	new Float:fNukeCooldown = get_cvar_float("bm_nukecooldown");
	new Float:fRandomCooldown = get_cvar_float("bm_randomcooldown");
	new Float:fBootsOfSpeedTime = get_cvar_float("bm_bootsofspeedtime");
	new Float:fBootsOfSpeedCooldown = get_cvar_float("bm_bootsofspeedcooldown");
	new Float:fAutoBhopTime = get_cvar_float("bm_autobhoptime");
	new Float:fAutoBhopCooldown = get_cvar_float("bm_autobhopcooldown");
	new TeleportSound = get_cvar_num("bm_teleportsound");
	
	//format the help text
	format(szHelpText, sizeof(szHelpText), gszHelpText, Telefrags, fFireDamageAmount, fDamageAmount, fHealAmount, fInvincibleTime, fInvincibleCooldown, fStealthTime, fStealthCooldown, fCamouflageTime, fCamouflageCooldown, fNukeCooldown, fRandomCooldown, fBootsOfSpeedTime, fBootsOfSpeedCooldown, fAutoBhopTime, fAutoBhopCooldown, TeleportSound);
	
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
			ColorChat(id, GREEN, "%sA line has been drawn to show the teleport path. Distance: %f units.", gszPrefix, fDist);
		}
	}
}

/* GROUPING BLOCKS */
groupBlockAiming(id)
{
	//make sure player has access to this command
	if (get_user_flags(id) & BM_ADMIN_LEVEL)
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
				ColorChat(id, GREEN, "%sBlock is already in a group by: %s", gszPrefix, szName);
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
		
		//get block type
		new blockType = entity_get_int(ent, EV_INT_body);
		
		//set rendering on block
		set_block_rendering(ent, gRender[blockType], gRed[blockType], gGreen[blockType], gBlue[blockType], gAlpha[blockType]);
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
			ColorChat(id, GREEN, "%sRemoved %d blocks from group, deleted %d stuck blocks", gszPrefix, blockCount, blocksDeleted);
		}
		else
		{
			//notify player how many blocks were cleared from group
			ColorChat(id, GREEN, "%sRemoved %d blocks from group", gszPrefix, blockCount);
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
	if (get_user_flags(id) & BM_ADMIN_LEVEL)
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
	if (get_user_flags(id) & BM_ADMIN_LEVEL)
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
		ColorChat(id, GREEN, "%sCan't swap teleport positions", gszPrefix);
	}
}

deleteTeleportAiming(id)
{
	//make sure player has access to this command
	if (get_user_flags(id) & BM_ADMIN_LEVEL)
	{
		//get entity that player is aiming at
		new ent, body;
		get_user_aiming(id, ent, body, 9999);
		
		//delete block that player is aiming at
		new bool:deleted = deleteTeleport(id, ent);
		
		if (deleted)
		{
			ColorChat(id, GREEN, "%sTeleport deleted!", gszPrefix);
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

/* TIMERS */
createTimerAiming(id, timerType)
{
	//make sure player has access to this command
	if (get_user_flags(id) & BM_ADMIN_LEVEL)
	{
		new origin[3];
		new Float:vOrigin[3];
		
		//get the origin of where the player is looking
		get_user_origin(id, origin, 3);
		IVecFVec(origin, vOrigin);
		
		//create the timer
		createTimer(id, timerType, vOrigin);
	}
}

createTimer(id, timerType, Float:vOrigin[3], Float:vAngles[3] = { 0.0, 0.0, 0.0 })
{
	new ent;
	
	switch (timerType)
	{
		case TIMER_START:
		{
			//if player has already created a timer start entity then delete it
			if (gStartTimer[id])
			{
				if (is_valid_ent(gStartTimer[id]))
				{
					remove_entity(gStartTimer[id]);
				}
			}
			
			ent = create_entity("func_button");
			
			//make sure entity was created successfully
			if (is_valid_ent(ent))
			{
				//set timer properties
				entity_set_string(ent, EV_SZ_classname, gszTimerClassname);
				entity_set_int(ent, EV_INT_body, timerType);
				entity_set_int(ent, EV_INT_solid, SOLID_BBOX);
				entity_set_int(ent, EV_INT_movetype, MOVETYPE_NONE);
				entity_set_model(ent, gszTimerModelStart);
				entity_set_vector(ent, EV_VEC_angles, vAngles);
				entity_set_size(ent, gfTimerSizeMin, gfTimerSizeMax);
				entity_set_origin(ent, vOrigin);
				
				//player has now created a timer start
				gStartTimer[id] = ent;
			}
		}
		
		case TIMER_END:
		{
			//make sure player has created a start timer entity
			if (isTimer(gStartTimer[id]))
			{
				ent = create_entity("func_button");
				
				//make sure entity was created successfully
				if (is_valid_ent(ent))
				{
					//set timer properties
					entity_set_string(ent, EV_SZ_classname, gszTimerClassname);
					entity_set_int(ent, EV_INT_body, timerType);
					entity_set_int(ent, EV_INT_solid, SOLID_BBOX);
					entity_set_int(ent, EV_INT_movetype, MOVETYPE_NONE);
					entity_set_model(ent, gszTimerModelEnd);
					entity_set_vector(ent, EV_VEC_angles, vAngles);
					entity_set_size(ent, gfTimerSizeMin, gfTimerSizeMax);
					entity_set_origin(ent, vOrigin);
					
					//link up start and end timers
					entity_set_int(ent, EV_INT_iuser1, gStartTimer[id]);
					entity_set_int(gStartTimer[id], EV_INT_iuser1, ent);
					
					//indicate that this player has no start timer entity
					gStartTimer[id] = 0;
				}
			}
		}
	}
	
	return ent;
}

swapTimerAiming(id)
{
	//make sure player has access to this command
	if (get_user_flags(id) & BM_ADMIN_LEVEL)
	{
		//get entity that player is aiming at
		new ent, body;
		get_user_aiming(id, ent, body, 9999);
		
		//swap the start & end timer positions
		if (isTimer(ent))
		{
			swapTimer(id, ent);
		}
	}
}

swapTimer(id, ent)
{
	new Float:vOriginEnt[3];
	new Float:vOriginTimer[3];
	new Float:vAngleEnt[3];
	new Float:vAngleTimer[3];
	
	//get the other end of the timer
	new timer = entity_get_int(ent, EV_INT_iuser1);
	
	//if the timer has another side
	if (is_valid_ent(timer))
	{
		//get timer properties
		new type = entity_get_int(ent, EV_INT_body);
		entity_get_vector(ent, EV_VEC_origin, vOriginEnt);
		entity_get_vector(ent, EV_VEC_angles, vAngleEnt);
		entity_get_vector(timer, EV_VEC_origin, vOriginTimer);
		entity_get_vector(timer, EV_VEC_angles, vAngleTimer);
		
		//delete old timers
		remove_entity(ent);
		remove_entity(timer);
		
		//create new timers at opposite positions
		if (type == TIMER_START)
		{
			createTimer(id, TIMER_START, vOriginTimer, vAngleTimer);
			createTimer(id, TIMER_END, vOriginEnt, vAngleEnt);
		}
		else if (type == TIMER_END)
		{
			createTimer(id, TIMER_START, vOriginEnt, vAngleEnt);
			createTimer(id, TIMER_END, vOriginTimer, vAngleTimer);
		}
		else
		{
			log_amx("Invalid timer type: %d", type);
		}
	}
	else
	{
		//tell player they cant swap because its only 1 sided
		ColorChat(id, GREEN, "%sCan't swap timer positions", gszPrefix);
	}
}

deleteTimerAiming(id)
{
	//make sure player has access to this command
	if (get_user_flags(id) & BM_ADMIN_LEVEL)
	{
		//get entity that player is aiming at
		new ent, body;
		get_user_aiming(id, ent, body, 9999);
		
		//delete timer that player is aiming at
		new bool:deleted = deleteTimer(ent);
		
		if (deleted)
		{
			client_print(id, print_chat, "%sTimer deleted!", gszPrefix);
			
			//make sure all players start timer entities are valid
			for (new i = 1; i <= 32; ++i)
			{
				if (!is_valid_ent(gStartTimer[i]))
				{
					gStartTimer[i] = 0;
				}
			}
		}
	}
}

bool:deleteTimer(ent)
{
	//if entity is a teleport then delete both the start and the end of the timer
	if (isTimer(ent))
	{
		//get entity id of the other side of the timer
		new timer = entity_get_int(ent, EV_INT_iuser1);
		
		//delete both the start and end positions of the timer
		if (timer)
		{
			remove_entity(timer);
		}
		
		remove_entity(ent);
		
		//timer was deleted
		return true;
	}
	
	//teleport was not deleted
	return false;
}

rotateTimerAiming(id)
{
	//make sure player has access to this command
	if (get_user_flags(id) & BM_ADMIN_LEVEL)
	{
		//get entity that player is aiming at
		new ent, body;
		get_user_aiming(id, ent, body, 9999);
		
		//rotate timer that player is aiming at
		if (isTimer(ent))
		{
			rotateTimer(ent);
		}
	}
}

rotateTimer(ent)
{
	new Float:vAngles[3]; 
	
	//get timer angles
	entity_get_vector(ent, EV_VEC_angles, vAngles);
	
	//change the timers angles depending on its current angle
	if (vAngles[1] == 0.0)
	{
		vAngles[1] = 90.0;
	}
	else if (vAngles[1] == 90.0)
	{
		vAngles[1] = 180.0;
	}
	else if (vAngles[1] == 180.0)
	{
		vAngles[1] = 270.0;
	}
	else if (vAngles[1] == 270.0)
	{
		vAngles[1] = 0.0;
	}
	
	//set the timers new angles
	entity_set_vector(ent, EV_VEC_angles, vAngles);
}

/* OPTIONS */
deleteAllBlocks(id, bool:bNotify)
{
	//make sure player has access to this command
	if (get_user_flags(id) & BM_ADMIN_LEVEL)
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
						ColorChat(i, GREEN, "%s'%s' deleted all the blocks from the map. Total blocks: %d", gszPrefix, szName, blockCount);
					}
				}
			}
		}
	}
}

deleteAllTeleports(id, bool:bNotify)
{
	//make sure player has access to this command
	if (get_user_flags(id) & BM_ADMIN_LEVEL)
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
						ColorChat(i, GREEN, "%s'%s' deleted all the teleports from the map. Total teleports: %d", gszPrefix, szName, teleCount);
					}
				}
			}
		}
	}
}

deleteAllTimers(id, bool:bNotify)
{
	//make sure player has access to this command
	if (get_user_flags(id) & BM_ADMIN_LEVEL)
	{
		new bool:bDeleted;
		new timerCount = 0;
		new ent = -1;
		
		//find all timer start entities in the map
		while ((ent = find_ent_by_class(ent, gszTimerClassname)))
		{
			//delete the timer
			bDeleted = deleteTimer(ent);
			
			//if timer was successfully deleted
			if (bDeleted)
			{
				//increment counter for how many timers have been deleted
				++timerCount;
			}
		}
		
		//if some timers were deleted
		if (timerCount > 0)
		{
			//get players name
			new szName[32];
			get_user_name(id, szName, 32);
			
			//iterate through all players
			for (new i = 1; i <= 32; ++i)
			{
				//make sure nobody has a timer start set
				gStartTimer[id] = 0;
				
				//make sure player is connected
				if (is_user_connected(i))
				{
					//notify all admins that the player deleted all the teleports
					if (bNotify && get_user_flags(i) & BM_ADMIN_LEVEL)
					{
						ColorChat(i, GREEN, "%s'%s' deleted all the teleports from the map. Total teleports: %d", gszPrefix, szName, timerCount);
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
	if (get_user_flags(id) & BM_ADMIN_LEVEL)
	{
		new origin[3];
		new Float:vOrigin[3];
		
		//get the origin of the player and add Z offset
		get_user_origin(id, origin, 3);
		IVecFVec(origin, vOrigin);
		vOrigin[2] += gfBlockSizeMaxForZ[2];
		
		//create the block
		createBlock(id, blockType, vOrigin, gfDefaultBlockAngles, gfBlockSizeMinForZ, gfBlockSizeMaxForZ, SCALE_NORMAL, -1.0);
	}
}

createBlockSize(const id, const blockType, Float:vOrigin[3], const axis, const size) {
	new Float:vSizeMin[3];
	new Float:vSizeMax[3];
	new Float:vAngles[3];
	new Float:fScale;
	
	//set mins, maxs and angles depending on axis
	switch (axis)
	{
		case X:
		{
			vSizeMin = gfBlockSizeMinForX;
			vSizeMax = gfBlockSizeMaxForX;
			vAngles[0] = 90.0;
		}
		
		case Y:
		{
			vSizeMin = gfBlockSizeMinForY;
			vSizeMax = gfBlockSizeMaxForY;
			vAngles[0] = 90.0;
			vAngles[2] = 90.0;
		}
		
		case Z:
		{
			vSizeMin = gfBlockSizeMinForZ;
			vSizeMax = gfBlockSizeMaxForZ;
			vAngles = gfDefaultBlockAngles;
		}
	}
	
	//set block model name and scale depending on size
	switch (size)
	{
		case SMALL:
		{
			fScale = SCALE_SMALL;
		}
		
		case NORMAL:
		{
			fScale = SCALE_NORMAL;
		}
		
		case LARGE:
		{
			fScale = SCALE_LARGE;
		}
	}
	
	return createBlock(id, blockType, vOrigin, vAngles, vSizeMin, vSizeMax, fScale, -1.0);
}

createBlock(const id, const blockType, Float:vOrigin[3], Float:vAngles[3], Float:vSizeMin[3], Float:vSizeMax[3], Float:fScale, Float:fValue)
{
	new ent = create_entity(gszInfoTarget);
	
	//make sure entity was created successfully
	if (is_valid_ent(ent))
	{
		//set block properties
		entity_set_string(ent, EV_SZ_classname, gszBlockClassname);
		entity_set_int(ent, EV_INT_solid, SOLID_BBOX);
		entity_set_int(ent, EV_INT_movetype, MOVETYPE_NONE);
		
		for (new i = 0; i < 3; ++i) {
			if(vSizeMin[i] != 4.0 && vSizeMin[i] != -4.0) {
				vSizeMin[i] *= fScale;
			}
			if(vSizeMax[i] != 4.0 && vSizeMax[i] != -4.0) {
				vSizeMax[i] *= fScale;
			}
		}
		
		
		
		//if its a valid block type
		if (blockType >= 0 && blockType < gBlockMax)
		{
			if(fScale == SCALE_NORMAL) {
				entity_set_model(ent, gszBlockModels[blockType]);
			} else if(fScale == SCALE_LARGE) {
				entity_set_model(ent, gszBlockLargeModels[blockType]);
			} else {
				entity_set_model(ent, gszBlockSmallModels[blockType]);
			}
		}
		else
		{
			entity_set_model(ent, gszBlockModelDefault);
		}
		
		entity_set_vector(ent, EV_VEC_angles, vAngles);
		entity_set_size(ent, vSizeMin, vSizeMax);
		entity_set_int(ent, EV_INT_body, blockType);
		entity_set_float(ent, EV_FL_fuser1, fScale);
		entity_set_float(ent, EV_FL_fuser2, fValue);
		// so we know we're not in a task where we change our rending values
		entity_set_vector(ent, EV_VEC_vuser1, gfNotRendering);
		new Name[32];
		get_user_name(id, Name, 31);
		replace_all(Name, 31, " ", "_");
		entity_set_string(ent, EV_SZ_targetname, Name);
		
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
			set_pev(ent, pev_v_angle, vOrigin); //Original Origin
		}
		
		//setup special properties for the random block
		if (blockType == BM_RANDOM)
		{
			//set this random block to a random block!
			new randNum = random_num(0, gRandomBlocksMax - 1);
			entity_set_int(ent, EV_INT_iuser4, gRandomBlocks[randNum]);
		}
		
		//set rendering on block
		set_block_rendering(ent, gRender[blockType], gRed[blockType], gGreen[blockType], gBlue[blockType], gAlpha[blockType]);
		
		//if blocktype is one which requires an additional sprite
		if (blockType == BM_FIRE || blockType == BM_TRAMPOLINE || blockType == BM_SPEEDBOOST)
		{
			//add sprite on top of the block
			new sprite = create_entity(gszInfoTarget);
			
			//make sure entity was created successfully
			if (sprite)
			{
				//create angle vector and rotate it so its horizontal
				new Float:vAngles[3];
				vAngles[0] = 90.0;
				vAngles[1] = 0.0;
				vAngles[2] = 0.0;
				
				//move the sprite up onto the top of the block, adding 0.15 to prevent flickering
				vOrigin[2] += vSizeMax[2] + 0.15;
				
				//set block properties
				entity_set_string(sprite, EV_SZ_classname, gszSpriteClassname);
				entity_set_int(sprite, EV_INT_solid, SOLID_NOT);
				entity_set_int(sprite, EV_INT_movetype, MOVETYPE_NONE);
				entity_set_vector(sprite, EV_VEC_angles, vAngles);
				
				//set sprite model depending on block type
				/*switch (blockType)
				{
				case BM_TRAMPOLINE: 
				if(fScale == SCALE_NORMAL) {
				entity_set_model(sprite, gszBlockSpriteTrampoline);
				} else if(fScale == SCALE_LARGE) {
				entity_set_model(sprite, gszBlockSpriteLargeTrampoline);
				} else {
				entity_set_model(sprite, gszBlockSpriteSmallTrampoline);
				}
				
				
				case BM_SPEEDBOOST: entity_set_model(sprite, gszBlockSpriteSpeedBoost);
				case BM_FIRE: 
				if(fScale == SCALE_NORMAL) {
				entity_set_model(sprite, gszBlockSpriteFire);
				} else if(fScale == SCALE_LARGE) {
				entity_set_model(sprite, gszBlockSpriteLargeFire);
				} else {
				entity_set_model(sprite, gszBlockSpriteSmallFire);
				}
				}*/
				//set the rendermode to additive and set the transparency
				entity_set_int(sprite, EV_INT_rendermode, 5);
				entity_set_float(sprite, EV_FL_renderamt, 255.0);
				
				//set origin of new sprite
				entity_set_origin(sprite, vOrigin);
				
				//link this sprite to the block
				entity_set_int(ent, EV_INT_iuser3, sprite);
				
				//set task for animating the sprite
				if (blockType == BM_FIRE || blockType == BM_TRAMPOLINE)
				{
					new params[2];
					params[0] = sprite;
					params[1] = 8;		//both the fire and trampoline sprites have 8 frames
					set_task(0.1, "taskSpriteNextFrame", TASK_SPRITE + sprite, params, 2, "b");
				}
			}
		}
		
		return ent;
	}
	
	return 0;
}

convertBlockAiming(id, const convertTo)
{
	//make sure player has access to this command
	if (get_user_flags(id) & BM_ADMIN_LEVEL)
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
								newBlock = convertBlock(id, block, convertTo);
								
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
							ColorChat(id, GREEN, "%sCouldn't convert %d blocks!", gszPrefix, blockCount);
						}
					}
					else
					{
						newBlock = convertBlock(id, ent, convertTo);
						
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

convertBlock(id, ent, const convertTo)
{
	
	new blockType = entity_get_int(ent, EV_INT_body);
	
	//if block to convert to is different to block to convert
	if (blockType != convertTo)
	{
		new Float:vOrigin[3];
		new Float:vAngles[3];
		new Float:vSizeMin[3];
		new Float:vSizeMax[3];
		new Float:fScale;
		
		
		//get block information from block player is aiming at
		entity_get_vector(ent, EV_VEC_origin, vOrigin);
		entity_get_vector(ent, EV_VEC_angles, vAngles);
		entity_get_vector(ent, EV_VEC_mins, vSizeMin);
		entity_get_vector(ent, EV_VEC_maxs, vSizeMax);
		fScale = entity_get_float(ent, EV_FL_fuser1);
		
		
		// since createBlock scales things for us, convert to unit vector
		for (new i = 0; i < 3; ++i) {
			if(vSizeMin[i] != 4.0 && vSizeMin[i] != -4.0) {
				vSizeMin[i] /= fScale;
			}
			if(vSizeMax[i] != 4.0 && vSizeMin[i] != -4.0) {
				vSizeMax[i] /= fScale;
			}
		}
		
		//if block is rotated and we're trying to convert it to a block that cannot be rotated
		if (vAngles[0] == 90.0 && (convertTo == BM_FIRE || convertTo == BM_TRAMPOLINE || convertTo == BM_SPEEDBOOST))
		{
			return 0;
		}
		else
		{
			//delete old block and create new one of given type
			deleteBlock(ent);
			return createBlock(id, convertTo, vOrigin, vAngles, vSizeMin, vSizeMax, fScale, -1.0);
		}
	}
	
	return ent;
}

deleteBlockAiming(id)
{
	//make sure player has access to this command
	if (get_user_flags(id) & BM_ADMIN_LEVEL)
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

adjustValue(id) {
	
	//make sure player has access to this command
	if (get_user_flags(id) & BM_ADMIN_LEVEL)
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
					if (!isBlockInGroup(id, ent) || gGroupCount[id] <= 1)
					{
						new Float:fValue = entity_get_float(ent, EV_FL_fuser2);
						new Float:fNextValue = -1.0;
						new blockType = entity_get_int(ent, EV_INT_body);
						
						
						for(new i = 0; i < MAX_VALUES; i++)
						{
							if(gBlockValues[blockType][i] == fValue)
							{
								fNextValue = gBlockValues[blockType][(i + 1)% MAX_VALUES];
							}
						}
						entity_set_float(ent, EV_FL_fuser2, fNextValue);
					} 
					else
					{
						client_print(id, print_chat, "Cannot set values on groups");
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
			else 
			{
				client_print(id, print_chat, "Cannot set values on block while being grabbed");
			}
		}
		else 
		{
			client_print(id, print_chat, "Aim at a block to set a property!");
		}
	} 
	
	return PLUGIN_HANDLED;
	
}

public cmdValue(id) {
	
	//make sure player has access to this command
	if (get_user_flags(id) & BM_ADMIN_LEVEL)
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
					if (!isBlockInGroup(id, ent) || gGroupCount[id] <= 1)
					{
						new arg[32];
						read_argv(1, arg, 31);
						new Float:fValue = str_to_float(arg);
						entity_set_float(ent, EV_FL_fuser2, fValue);
					} else {
						client_print(id, print_chat, "Cannot set values on groups");
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
			} else {
				client_print(id, print_chat, "Cannot set values on block while being grabbed");
			}
		} else {
			client_print(id, print_chat, "Cannot find block");
		}
	} 
	
	return PLUGIN_HANDLED;
	
}

public cmdNoClip(id) {
	toggleNoclip(id);
	return PLUGIN_HANDLED;
	
}

public cmdGodmode(id) {
	toggleGodmode(id);
	return PLUGIN_HANDLED;
	
}

public setDefaultRender(id, defaultRender) {
	//make sure player has access to this command
	if (get_user_flags(id) & BM_ADMIN_LEVEL)
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
						
						//iterate through all blocks in the players group
						for (new i = 0; i <= gGroupCount[id]; ++i)
						{
							block = gGroupedBlocks[id][i];
							
							//if block is still valid
							if (isBlockInGroup(id, block))
							{
								//rotate the block
								setDefaultRenderType(block, defaultRender);
							}
							
						}
						
					}
					else
					{
						setDefaultRenderType(ent, defaultRender);
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
	return PLUGIN_HANDLED;
	
}

public adjustRenderValue(id, renderType) {
	//make sure player has access to this command
	if (get_user_flags(id) & BM_ADMIN_LEVEL)
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
						
						//iterate through all blocks in the players group
						for (new i = 0; i <= gGroupCount[id]; ++i)
						{
							block = gGroupedBlocks[id][i];
							
							//if block is still valid
							if (isBlockInGroup(id, block))
							{
								//rotate the block
								adjustRenderValueBlock(block, renderType);
							}
							
						}
						
					}
					else
					{
						adjustRenderValueBlock(ent, renderType);
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
	return PLUGIN_HANDLED;
}


public cmdAdjustSize(id) {
	//make sure player has access to this command
	if (get_user_flags(id) & BM_ADMIN_LEVEL)
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
						
						//iterate through all blocks in the players group
						for (new i = 0; i <= gGroupCount[id]; ++i)
						{
							block = gGroupedBlocks[id][i];
							
							//if block is still valid
							if (isBlockInGroup(id, block))
							{
								//rotate the block
								adjustSizeBlock(block);
							}
							
						}
						
					}
					else
					{
						adjustSizeBlock(ent);
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
	return PLUGIN_HANDLED;
}



rotateBlockAiming(id)
{
	//make sure player has access to this command
	if (get_user_flags(id) & BM_ADMIN_LEVEL)
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
						
						//iterate through all blocks in the players group
						for (new i = 0; i <= gGroupCount[id]; ++i)
						{
							block = gGroupedBlocks[id][i];
							
							//if block is in players group
							if (isBlockInGroup(id, block))
							{
								//get block type
								new blockType = entity_get_int(block, EV_INT_body);
								
								//if block cannot be rotated
								if (!isBlockTypeRotatable(blockType))
								{
									//found a block that cannot be rotated
									bRotateGroup = false;
									
									break;
								}
							}
						}
						
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

setDefaultRenderType(ent, defaultRender) {
	//if entity is valid
	if (is_valid_ent(ent))
	{
		//client_print(id, print_chat, "%d %d %f", DefaultRender[defaultRender], DefaultRenderFx[defaultRender], DefaultRenderAlpha[defaultRender]);
		entity_set_int(ent, EV_INT_rendermode, DefaultRender[defaultRender]);
		entity_set_int(ent, EV_INT_renderfx, DefaultRenderFx[defaultRender]);
		entity_set_float(ent, EV_FL_renderamt, DefaultRenderAlpha[defaultRender]);
		entity_set_vector(ent, EV_VEC_rendercolor, DefaultRenderRGB[defaultRender]);
	}
	
}

Float:getNextRenderValue(Float:value) {
	value += 64.0;
	if(value > 255.0) {
		value -= 256.0;
	}
	return value;
}

adjustRenderValueBlock(ent, renderType) {
	//if entity is valid
	if (is_valid_ent(ent))
	{
		new RenderFxType = entity_get_int(ent, EV_INT_renderfx);
		new RenderType = entity_get_int(ent, EV_INT_rendermode);
		new Float:Alpha = entity_get_float(ent, EV_FL_renderamt);
		new Float:RGB[3];
		entity_get_vector(ent, EV_VEC_rendercolor, RGB);
		if((RenderType + 1) == kRenderGlow) {
			RenderType++;
		}
		
		switch(renderType)
		{
			case RENDER_TYPE:        { entity_set_int(ent, EV_INT_rendermode, (RenderType + 1) % (kRenderTransAdd + 1)); }
			case RENDER_TYPE_FX:     { entity_set_int(ent, EV_INT_renderfx, (RenderFxType + 1) % (kRenderFxClampMinScale + 1)); }
			case RENDER_TYPE_ALPHA:  { entity_set_float(ent, EV_FL_renderamt, getNextRenderValue(Alpha)); }
			case RENDER_TYPE_RED:    { RGB[0] = getNextRenderValue(RGB[0]); }
			case RENDER_TYPE_GREEN:  { RGB[1] = getNextRenderValue(RGB[1]); }
			case RENDER_TYPE_BLUE:   { RGB[2] = getNextRenderValue(RGB[2]); }
			
		}
		
		entity_set_vector(ent, EV_VEC_rendercolor, RGB);
	}
	
}


adjustSizeBlock(ent) {
	//if entity is valid
	if (is_valid_ent(ent))
	{
		
		new Float:vAngles[3]; 
		new Float:vSizeMin[3];
		new Float:vSizeMax[3];
		new blockType = entity_get_int(ent, EV_INT_body);
		
		//get block information 
		entity_get_vector(ent, EV_VEC_angles, vAngles);
		new Float:fScale = entity_get_float(ent, EV_FL_fuser1);
		//get the sprite attached to the top of the block
		//new sprite = entity_get_int(ent, EV_INT_iuser3);
		
		
		if(fScale == SCALE_NORMAL) 
		{
			fScale = SCALE_LARGE;
			/*if(blockType == BM_TRAMPOLINE) 
			{
			entity_set_model(sprite, gszBlockSpriteLargeTrampoline);
			}
			else if (blockType == BM_FIRE)
			{
			entity_set_model(sprite, gszBlockSpriteLargeFire);
			}*/
			entity_set_model(ent, gszBlockLargeModels[blockType]);
		} 
		else if(fScale == SCALE_SMALL) 
		{
			fScale = SCALE_NORMAL;
			/*if(blockType == BM_TRAMPOLINE)
			{
			entity_set_model(sprite, gszBlockSpriteTrampoline);
			} 
			else if (blockType == BM_FIRE)
			{
			entity_set_model(sprite, gszBlockSpriteFire);
			}*/
			entity_set_model(ent, gszBlockModels[blockType]);
		} 
		else 
		{
			fScale = SCALE_SMALL;
			/*if(blockType == BM_TRAMPOLINE) 
			{
			entity_set_model(sprite, gszBlockSpriteSmallTrampoline);
			} 
			else if (blockType == BM_FIRE) 
			{
			entity_set_model(sprite, gszBlockSpriteSmallFire);
			}*/
			entity_set_model(ent, gszBlockSmallModels[blockType]);
		}
		
		
		entity_set_float(ent, EV_FL_fuser1, fScale);
		
		
		//create new block using current block information with new angles and sizes
		if (vAngles[0] == 0.0 && vAngles[2] == 0.0)
		{
			vSizeMin = gfBlockSizeMinForZ;
			vSizeMax = gfBlockSizeMaxForZ;
		}
		else if (vAngles[0] == 90.0 && vAngles[2] == 0.0)
		{
			vSizeMin = gfBlockSizeMinForX;
			vSizeMax = gfBlockSizeMaxForX;
		}
		else
		{ 
			vSizeMin = gfBlockSizeMinForY;
			vSizeMax = gfBlockSizeMaxForY;
		}
		for (new i = 0; i < 3; ++i)
		{
			if(vSizeMin[i] != 4.0 && vSizeMin[i] != -4.0)
			{
				vSizeMin[i] *= fScale;
			}
			if(vSizeMax[i] != 4.0 && vSizeMax[i] != -4.0) 
			{
				vSizeMax[i] *= fScale;
			}
		}
		
		entity_set_size(ent, vSizeMin, vSizeMax);
	}
}


bool:rotateBlock(ent)
{
	//if entity is valid
	if (is_valid_ent(ent))
	{
		//get block type
		new blockType = entity_get_int(ent, EV_INT_body);
		
		//if block is a type that can be rotated (a block without a sprite, makes it easier!)
		if (isBlockTypeRotatable(blockType))
		{
			new Float:vAngles[3]; 
			new Float:vSizeMin[3];
			new Float:vSizeMax[3];
			new Float:fScale;
			
			//get block information 
			entity_get_vector(ent, EV_VEC_angles, vAngles);
			
			//create new block using current block information with new angles and sizes
			if (vAngles[0] == 0.0 && vAngles[2] == 0.0)
			{
				vAngles[0] = 90.0;
				vSizeMin = gfBlockSizeMinForX;
				vSizeMax = gfBlockSizeMaxForX;
			}
			else if (vAngles[0] == 90.0 && vAngles[2] == 0.0)
			{
				vAngles[0] = 90.0;
				vAngles[2] = 90.0;
				vSizeMin = gfBlockSizeMinForY;
				vSizeMax = gfBlockSizeMaxForY;
			}
			else
			{ 
				vAngles = gfDefaultBlockAngles;
				vSizeMin = gfBlockSizeMinForZ;
				vSizeMax = gfBlockSizeMaxForZ;
			}
			
			fScale = entity_get_float(ent, EV_FL_fuser1);
			for (new i = 0; i < 3; ++i)
			{
				if(vSizeMin[i] != 4.0 && vSizeMin[i] != -4.0) 
				{
					vSizeMin[i] *= fScale;
				}
				if(vSizeMax[i] != 4.0 && vSizeMax[i] != -4.0) 
				{
					vSizeMax[i] *= fScale;
				}
			}
			
			entity_set_vector(ent, EV_VEC_angles, vAngles);
			entity_set_size(ent, vSizeMin, vSizeMax);
			
			return true;
		}
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
		new blockType;
		new Float:fScale;
		new Float:fValue;
		new RenderType;
		new RenderTypeFx;
		new Float:Alpha;
		new Float:RGB[3];
		new entBlock;
		
		//get blocktype and origin of currently grabbed block
		blockType = entity_get_int(ent, EV_INT_body);
		entity_get_vector(ent, EV_VEC_origin, vOrigin);
		entity_get_vector(ent, EV_VEC_angles, vAngles);
		entity_get_vector(ent, EV_VEC_mins, vSizeMin);
		entity_get_vector(ent, EV_VEC_maxs, vSizeMax);
		fScale = entity_get_float(ent, EV_FL_fuser1);
		fValue = entity_get_float(ent, EV_FL_fuser2);
		RenderTypeFx = entity_get_int(ent, EV_INT_renderfx);
		RenderType = entity_get_int(ent, EV_INT_rendermode);
		Alpha = entity_get_float(ent, EV_FL_renderamt);
		entity_get_vector(ent, EV_VEC_rendercolor, RGB);
		
		for (new i = 0; i < 3; ++i) {
			if(vSizeMin[i] != 4.0 && vSizeMin[i] != -4.0) {
				vSizeMin[i] /= fScale;
			}
			if(vSizeMax[i] != 4.0 && vSizeMax[i] != -4.0) {
				vSizeMax[i] /= fScale;
			}
		}
		
		//create a block of the same type in the same location
		entBlock = createBlock(0, blockType, vOrigin, vAngles, vSizeMin, vSizeMax, fScale, fValue);
		if(entBlock != 0) {
			entity_set_int(entBlock, EV_INT_renderfx, RenderTypeFx);
			entity_set_int(entBlock, EV_INT_rendermode, RenderType);
			entity_set_float(entBlock, EV_FL_renderamt, Alpha);
			entity_set_vector(entBlock, EV_VEC_rendercolor, RGB);
		}
		return entBlock;
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

bool:isBlockTypeRotatable(blockType)
{
	if (blockType != BM_FIRE && blockType != BM_TRAMPOLINE && blockType != BM_SPEEDBOOST)
	{
		return true;
	}
	
	return true;
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


bool:isTimer(ent)
{
	//is it a valid entity
	if (is_valid_ent(ent))
	{
		//get classname of entity
		new szClassname[32];
		entity_get_string(ent, EV_SZ_classname, szClassname, 32);
		
		//if classname of entity matches global timer classname
		if (equal(szClassname, gszTimerClassname))
		{
			//entity is a timer
			return true;
		}
	}
	
	//entity is not a timer
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
	//make sure player has access to this command
	if (get_user_flags(id) & BM_ADMIN_LEVEL)
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
		new timerCount = 0;
		new szData[512];
		new Float:fScale;
		new Float:fValue;
		new RenderTypeFx;
		new RenderType;
		new Float:Alpha;
		new Float:RGB[3];
		new Name[32];
		new Float:tmp[3];
		new Float:tmp2[3];
		
		
		while ((ent = find_ent_by_class(ent, gszBlockClassname)))
		{
			//get block info
			blockType = entity_get_int(ent, EV_INT_body);
			if( blockType == BM_MAGICCARPET )
				pev(ent, pev_v_angle, vOrigin);
			else
			pev(ent, pev_origin, vOrigin);
			entity_get_vector(ent, EV_VEC_origin, vOrigin);
			entity_get_vector(ent, EV_VEC_angles, vAngles);
			fScale = entity_get_float(ent, EV_FL_fuser1);
			fValue = entity_get_float(ent, EV_FL_fuser2);
			RenderTypeFx = entity_get_int(ent, EV_INT_renderfx);
			RenderType = entity_get_int(ent, EV_INT_rendermode);
			Alpha = entity_get_float(ent, EV_FL_renderamt);
			entity_get_vector(ent, EV_VEC_rendercolor, RGB);
			entity_get_string(ent, EV_SZ_targetname, Name, 31);
			
			entity_get_vector(ent, EV_VEC_vuser1, tmp);
			if(tmp[0] != -1.0) {
				entity_get_vector(ent, EV_VEC_vuser2, tmp2);
				RGB[0] = tmp2[0];
				RGB[1] = tmp2[1];
				RGB[2] = tmp2[2];
				Alpha = tmp[2];
				RenderTypeFx = floatround(tmp[0]);
				RenderType = floatround(tmp[1]);
			}
			
			
			formatex(szData, 512, "%c %f %f %f %f %f %f %f %f %d %d %f %f %f %f %s^n", gBlockSaveIds[blockType], vOrigin[0], vOrigin[1], vOrigin[2], vAngles[0], vAngles[1], vAngles[2], fScale, fValue, RenderType, RenderTypeFx, Alpha, RGB[0], RGB[1], RGB[2], Name);
			//format block info and save it to file
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
		
		//iterate through timer end entities because you can't have an end without a start
		ent = -1;
		
		while ((ent = find_ent_by_class(ent, gszTimerClassname)))
		{
			//get the type of timer
			new timerType = entity_get_int(ent, EV_INT_body);
			
			//timer type must be an end
			if (timerType == TIMER_END)
			{
				//get the id of the start of the timer
				new timer = entity_get_int(ent, EV_INT_iuser1);
				
				//check that start of timer is a valid entity
				if (timer)
				{
					//get the origin of the start of the timer and its angles
					entity_get_vector(timer, EV_VEC_origin, vStart);
					entity_get_vector(timer, EV_VEC_angles, vAngles);
					
					//save the start timer information to file
					formatex(szData, 128, "%c %f %f %f %f %f %f^n", gTimerSaveId, vStart[0], vStart[1], vStart[2], vAngles[0], vAngles[1], vAngles[2]);
					fputs(file, szData);
					
					//get the origin of the end of the timer and its angles
					entity_get_vector(ent, EV_VEC_origin, vEnd);
					entity_get_vector(ent, EV_VEC_angles, vAngles);
					
					//save the end timer information to file
					formatex(szData, 128, "%c %f %f %f %f %f %f^n", gTimerSaveId, vEnd[0], vEnd[1], vEnd[2], vAngles[0], vAngles[1], vAngles[2]);
					fputs(file, szData);
					
					//2 timer entities count as 1 timer
					++timerCount;
				}
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
					ColorChat(i, GREEN, "%s'%s' saved %d block%s, %d teleporter%s and %d timer%s! Total entites in template '%s'! Total entites in map map: %d", gszPrefix, szName, blockCount, (blockCount == 1 ? "" : "s"), teleCount, (teleCount == 1 ? "" : "s"), timerCount, (timerCount == 1 ? "" : "s"), gCurConfig, entity_count());
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
	else if (get_user_flags(id) & BM_ADMIN_LEVEL)
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
				deleteAllTimers(id, false);
			}
			
			new szData[512];
			new szType[2];
			new sz1[16], sz2[16], sz3[16], sz4[16], sz5[16], sz6[16], sz7[16], sz8[16], szRender[16], szRenderFx[16], szAlpha[16], szRed[16], szGreen[16], szBlue[16], szName[32];
			new Float:vVec1[3];
			new Float:vVec2[3];
			new Float:fSizeMin[3];
			new Float:fSizeMax[3];
			new f = fopen(szPath, "rt");
			new blockCount = 0;
			new teleCount = 0;
			new timerCount = 0;
			new bool:bTimerStart = true;
			new Float:vTimerOrigin[3];
			new Float:vTimerAngles[3];
			new Float:fScale;
			new Float:fValue;
			new Float:RGB[3];
			new ent;
			
			copy(gCurConfig, 32, szConfigsName);
			
			
			//iterate through all the lines in the file
			while (!feof(f))
			{
				szType = "";
				fgets(f, szData, 512);
				parse(szData, szType, 1, sz1, 16, sz2, 16, sz3, 16, sz4, 16, sz5, 16, sz6, 16, sz7, 16, sz8, 16, szRender, 16, szRenderFx, 16, szAlpha, 16, szRed, 16, szGreen, 16, szBlue, 16, szName, 32);
				
				vVec1[0] = str_to_float(sz1);
				vVec1[1] = str_to_float(sz2);
				vVec1[2] = str_to_float(sz3);
				vVec2[0] = str_to_float(sz4);
				vVec2[1] = str_to_float(sz5);
				vVec2[2] = str_to_float(sz6);
				
				if(!strcmp(sz7, "")) {
					fScale = SCALE_NORMAL;
					fValue = -1.0;
				} else {
					fScale = str_to_float(sz7);
					if(!strcmp(sz8, "")) {
						fValue = -1.0;
					} else {
						fValue = str_to_float(sz8);
					}
				}
				
				
				if (strlen(szType) > 0)
				{
					//if type is not a teleport
					if (szType[0] != gTeleportSaveId)
					{
						//set block size depending on block angles
						if (vVec2[0] == 90.0 && vVec2[1] == 0.0 && vVec2[2] == 0.0)
						{
							fSizeMin = gfBlockSizeMinForX;
							fSizeMax = gfBlockSizeMaxForX;
						}
						else if (vVec2[0] == 90.0 && vVec2[1] == 0.0 && vVec2[2] == 90.0)
						{
							fSizeMin = gfBlockSizeMinForY;
							fSizeMax = gfBlockSizeMaxForY;
						}
						else
						{
							fSizeMin = gfBlockSizeMinForZ;
							fSizeMax = gfBlockSizeMaxForZ;
						}
						
						//increment block counter
						++blockCount;
					}
					
					ent = -1;
					//create block or teleport depending on type
					switch (szType[0])
					{
						case 'A': ent = createBlock(0, BM_PLATFORM, vVec1, vVec2, fSizeMin, fSizeMax, fScale, fValue);
						case 'B': ent = createBlock(0, BM_BHOP, vVec1, vVec2, fSizeMin, fSizeMax, fScale, fValue);
						case 'C': ent = createBlock(0, BM_DAMAGE, vVec1, vVec2, fSizeMin, fSizeMax, fScale, fValue);
						case 'D': ent = createBlock(0, BM_HEALER, vVec1, vVec2, fSizeMin, fSizeMax, fScale, fValue);
						case 'E': ent = createBlock(0, BM_NOFALLDAMAGE, vVec1, vVec2, fSizeMin, fSizeMax, fScale, fValue);
						case 'F': ent = createBlock(0, BM_ICE, vVec1, vVec2, fSizeMin, fSizeMax, fScale, fValue);
						case 'G': ent = createBlock(0, BM_TRAMPOLINE, vVec1, vVec2, fSizeMin, fSizeMax, fScale, fValue);
						case 'H': ent = createBlock(0, BM_SPEEDBOOST, vVec1, vVec2, fSizeMin, fSizeMax, fScale, fValue);
						case 'I': ent = createBlock(0, BM_INVINCIBILITY, vVec1, vVec2, fSizeMin, fSizeMax, fScale, fValue);
						case 'J': ent = createBlock(0, BM_STEALTH, vVec1, vVec2, fSizeMin, fSizeMax, fScale, fValue);
						case 'K': ent = createBlock(0, BM_DEATH, vVec1, vVec2, fSizeMin, fSizeMax, fScale, fValue);
						case 'L': ent = createBlock(0, BM_NUKE, vVec1, vVec2, fSizeMin, fSizeMax, fScale, fValue);
						case 'M': ent = createBlock(0, BM_CAMOUFLAGE, vVec1, vVec2, fSizeMin, fSizeMax, fScale, fValue);
						case 'N': ent = createBlock(0, BM_LOWGRAVITY, vVec1, vVec2, fSizeMin, fSizeMax, fScale, fValue);
						case 'O': ent = createBlock(0, BM_FIRE, vVec1, vVec2, fSizeMin, fSizeMax, fScale, fValue);
						case 'P': ent = createBlock(0, BM_SLAP, vVec1, vVec2, fSizeMin, fSizeMax, fScale, fValue);
						case 'Q': ent = createBlock(0, BM_RANDOM, vVec1, vVec2, fSizeMin, fSizeMax, fScale, fValue);
						case 'R': ent = createBlock(0, BM_HONEY, vVec1, vVec2, fSizeMin, fSizeMax, fScale, fValue);
						case 'S': ent = createBlock(0, BM_BARRIER_CT, vVec1, vVec2, fSizeMin, fSizeMax, fScale, fValue);
						case 'T': ent = createBlock(0, BM_BARRIER_T, vVec1, vVec2, fSizeMin, fSizeMax, fScale, fValue);
						case 'U': ent = createBlock(0, BM_BOOTSOFSPEED, vVec1, vVec2, fSizeMin, fSizeMax, fScale, fValue);
						case 'V': ent = createBlock(0, BM_GLASS, vVec1, vVec2, fSizeMin, fSizeMax, fScale, fValue);
						case 'W': ent = createBlock(0, BM_BHOP_NOSLOW, vVec1, vVec2, fSizeMin, fSizeMax, fScale, fValue);
						case 'X': ent = createBlock(0, BM_AUTO_BHOP, vVec1, vVec2, fSizeMin, fSizeMax, fScale, fValue);
						case 'Y': ent = createBlock(0, BM_DELAYEDBHOP, vVec1, vVec2, fSizeMin, fSizeMax, fScale, fValue);
						case 'Z': ent = createBlock(0, BM_BLIND, vVec1, vVec2, fSizeMin, fSizeMax, fScale, fValue);
						case '1': ent = createBlock(0, BM_DUCK, vVec1, vVec2, fSizeMin, fSizeMax, fScale, fValue);
						case '2': ent = createBlock(0, BM_HEGRENADE, vVec1, vVec2, fSizeMin, fSizeMax, fScale, fValue);
						case '3': ent = createBlock(0, BM_FLASHBANG, vVec1, vVec2, fSizeMin, fSizeMax, fScale, fValue);
						case '4': ent = createBlock(0, BM_SMOKEGRENADE, vVec1, vVec2, fSizeMin, fSizeMax, fScale, fValue);
						case '5': ent = createBlock(0, BM_DEAGLE, vVec1, vVec2, fSizeMin, fSizeMax, fScale, fValue);
						case '6': ent = createBlock(0, BM_AWP, vVec1, vVec2, fSizeMin, fSizeMax, fScale, fValue);
						case '@': ent = createBlock(0, BM_BIOHAZARD, vVec1, vVec2, fSizeMin, fSizeMax, fScale, fValue);
						case '#': ent = createBlock(0, BM_ANTIDOTE, vVec1, vVec2, fSizeMin, fSizeMax, fScale, fValue);
						case '7': ent = createBlock(0, BM_MAGICCARPET, vVec1, vVec2, fSizeMin, fSizeMax, fScale, fValue);
						
						
						
						case gTeleportSaveId:
						{
							createTeleport(0, TELEPORT_START, vVec1);
							createTeleport(0, TELEPORT_END, vVec2);
							
							//increment teleport count
							++teleCount;
						}
						
						case gTimerSaveId:
						{
							//is this the first timer info retrieved from file?
							if (bTimerStart)
							{
								//store start timer info
								vTimerOrigin[0] = vVec1[0];
								vTimerOrigin[1] = vVec1[1];
								vTimerOrigin[2] = vVec1[2];
								vTimerAngles[0] = vVec2[0];
								vTimerAngles[1] = vVec2[1];
								vTimerAngles[2] = vVec2[2];
								
								//the next timer to come along is the end of the timer
								bTimerStart = false;
							}
							else
							{
								//create the start of timer
								createTimer(0, TIMER_START, vTimerOrigin, vTimerAngles);
								
								//create the end of the timer
								createTimer(0, TIMER_END, vVec1, vVec2);
								
								//if another timer comes along then it'll be the start again
								bTimerStart = true;
								
								//increment timer count
								++timerCount;
							}
						}
						
						default:
						{
							log_amx("%sInvalid block type: %c in: %s", gszPrefix, szType[0], gszFile);
							
							//decrement block counter because a block was not created
							--blockCount;
						}
					}
					if (is_valid_ent(ent)) {
						// if its there
						if(strcmp(szRender, "")) {
							entity_set_int(ent, EV_INT_rendermode, str_to_num(szRender));
							entity_set_int(ent, EV_INT_renderfx, str_to_num(szRenderFx));
							entity_set_float(ent, EV_FL_renderamt, str_to_float(szAlpha)); 
							RGB[0] = str_to_float(szRed);
							RGB[1] = str_to_float(szGreen);
							RGB[2] = str_to_float(szBlue);
							entity_set_vector(ent, EV_VEC_rendercolor, RGB);
							if(strcmp(szName, "")) {
								entity_set_string(ent, EV_SZ_targetname, szName);
							}
						}
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
							client_print(i, print_chat, "%s'%s' loaded template: '%s' %d block%s, %d teleporter%s and %d timer%s! Total entites in map: %d", gszPrefix, szName, szConfigsName, blockCount, (blockCount == 1 ? "" : "s"), teleCount, (teleCount == 1 ? "" : "s"), timerCount, (timerCount == 1 ? "" : "s"), entity_count());
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

htmlFriendly(szString[])
{
	//replace < > in string with HTML friendly characters
	while (contain(szString, "<") != -1)
	{
		replace(szString, 2048, "<", "&lt");
	}
	
	while (contain(szString, ">") != -1)
	{
		replace(szString, 2048, ">", "&gt");
	}
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