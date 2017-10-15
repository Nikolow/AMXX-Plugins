#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <engine>
#include <fakemeta>
#include <hamsandwich>
#include <fun>
#include <sockets>

#pragma semicolon 1;

#define PLUGIN_NAME				"BLOCK MAKER"
#define PLUGIN_VERSION				"1.0"
#define PLUGIN_AUTHOR				"str3e7-cs team"
#define PLUGIN_PREFIX				"Str3e7-CS"


#define get_bit(%1,%2) 		( %1 &   1 << ( %2 & 31 ) )
#define set_bit(%1,%2)	 	( %1 |=  ( 1 << ( %2 & 31 ) ) )
#define clear_bit(%1,%2)	( %1 &= ~( 1 << ( %2 & 31 ) ) )

#define TASK_TIMER 7000
#define MAX_PLAYERS 32

new HeUsed[42];
new FlashUsed[42];
new SmokeUsed[42];

native hnsxp_get_user_xp( id );
native hnsxp_set_user_xp( id, xp );

stock hnsxp_add_user_xp( id, xp )
{
	return hnsxp_set_user_xp( id, hnsxp_get_user_xp( id ) + xp );
}


new const g_blank[] =				"";

new const g_block_classname[] =			"BCM_Block";
new const g_start_classname[] =			"BCM_TeleportStart";
new const g_destination_classname[] =		"BCM_TeleportDestination";

new const g_model_platform[] =			"models/str3e7-cs/Platform.mdl";
new const g_model_bhop[] =			"models/str3e7-cs/Bhop.mdl";
new const g_model_damage[] =			"models/str3e7-cs/Damage.mdl";
new const g_model_healer[] =			"models/str3e7-cs/Health.mdl";
new const g_model_no_fall_damage[] =		"models/str3e7-cs/Nofall.mdl";
new const g_model_ice[] =			"models/str3e7-cs/Ice.mdl";
new const g_model_trampoline[] =		"models/str3e7-cs/Trampoline.mdl";
new const g_model_speed_boost[] =		"models/str3e7-cs/SpeedBoost.mdl";
new const g_model_death[] =			"models/str3e7-cs/Death.mdl";
new const g_model_low_gravity[] =		"models/str3e7-cs/LowGravity.mdl";
new const g_model_slap[] =			"models/str3e7-cs/Slap.mdl";
new const g_model_honey[] =			"models/str3e7-cs/Honey.mdl";
new const g_model_ct_barrier[] =		"models/str3e7-cs/Platform.mdl";
new const g_model_t_barrier[] =			"models/str3e7-cs/Platform.mdl";
new const g_model_glass[] =			"models/str3e7-cs/Glass.mdl";
new const g_model_no_slow_down_bhop[] =		"models/str3e7-cs/NoSlowDown.mdl";
new const g_model_delayed_bhop[] =		"models/str3e7-cs/DelayedBhop.mdl";
new const g_model_invincibility[] =		"models/str3e7-cs/Invincible.mdl";
new const g_model_stealth[] =			"models/str3e7-cs/Stealth.mdl";
new const g_model_boots_of_speed[] =		"models/str3e7-cs/BootsOfSpeed.mdl";
new const g_model_weapon_block[] =		"models/str3e7-cs/WeaponPick.mdl";
new const g_model_duck_block[] =		"models/str3e7-cs/Duck.mdl";
new const g_model_xp_block[] =			"models/str3e7-cs/Xp.mdl";
new const g_model_blind_trap[] =		"models/str3e7-cs/Blind.mdl";
new const g_model_superman[] =			"models/str3e7-cs/Superman.mdl";
new const g_model_money[] =			"models/str3e7-cs/Money.mdl";
new const g_model_teleport[] =			"models/str3e7-cs/Teleport.mdl";
new const g_model_destination[] =		"models/str3e7-cs/Destination.mdl";
new const g_model_magiccarpet[] =		"models/str3e7-cs/Carpet.mdl";
new const g_model_he[] =                        "models/str3e7-cs/He.mdl";
new const g_model_flash[] =                     "models/str3e7-cs/Flash.mdl";
new const g_model_smoke[] =                     "models/str3e7-cs/Frost.mdl";
new const g_model_m4a1[] =                      "models/str3e7-cs/M4a1.mdl";
new const g_model_m3[] =                        "models/str3e7-cs/Shotgun.mdl";
new const g_model_awp[] =                       "models/str3e7-cs/Awp.mdl";
new const g_model_deagle[] =                    "models/str3e7-cs/Deagle.mdl";
new const g_model_usp[] =                       "models/str3e7-cs/Usp.mdl";
new const g_model_glock[] =                     "models/str3e7-cs/Glock.mdl";
new const g_model_ak47[] =                      "models/str3e7-cs/Ak47.mdl";
new const g_model_light[] =                     "models/str3e7-cs/Light.mdl";
new const g_model_quake[] =                     "models/str3e7-cs/EarthQuake.mdl";
new const g_model_muza[] =			"models/str3e7-cs/MusicBlock.mdl";

new const g_sprite_teleport_start[] =		"sprites/blockmaker/teleport_start.spr";
new const g_sprite_teleport_destination[] =	"sprites/blockmaker/teleport_end.spr";
new const g_teleport_start_frames = 20;
new const g_teleport_end_frames = 5;

new const g_sound_invincibility[] = 		  "str3e7-cs/invincibility.wav"; 
new const g_sound_stealth[] = 			  "str3e7-cs/stealth.wav"; 
new const g_sound_boots_of_speed[] = 		  "str3e7-cs/bootsofspeed.wav"; 
new const g_sound_supermario[] = 		  "str3e7-cs/superman.wav"; 
new const g_sound_xpblock[] = 		          "str3e7-cs/xpblock.wav"; 
new const g_sound_money[] = 		          "str3e7-cs/money.wav";
new const g_sound_teleport[] = 		          "str3e7-cs/teleport.wav";
new const g_sound_teleports[] = 		  "str3e7-cs/teleport1.wav";
new const g_sound_death[] =                       "str3e7-cs/death.wav";
new const g_sound_death_bounce[] =                "str3e7-cs/bouncedeath.wav";
new const g_sound_trampoline[] =                  "str3e7-cs/trampoline.wav";

new const gsz1[] =        "str3e7-cs/v1.wav";
new const gsz2[] =        "str3e7-cs/v2.wav";
new const gsz3[] =        "str3e7-cs/v3.wav";
new const gsz4[] =        "str3e7-cs/v4.wav";
new const gsz5[] =        "str3e7-cs/v5.wav";
new const gsz6[] =        "str3e7-cs/v6.wav";
new const gsz7[] =        "str3e7-cs/v7.wav";
new const gsz8[] =        "str3e7-cs/v8.wav";
new const gsz9[] =        "str3e7-cs/v9.wav";
new const gsz10[] =       "str3e7-cs/v10.wav";
new const gsz11[] =       "str3e7-cs/v11.wav";

enum ( <<= 1 )
{
	B1 = 1,
	B2,
	B3,
	B4,
	B5,
	B6,
	B7,
	B8,
	B9,
	B0
};

enum
{
	K1,
	K2,
	K3,
	K4,
	K5,
	K6,
	K7,
	K8,
	K9,
	K0
};

enum
{
	CHOICE_DELETE,
	CHOICE_LOAD,
	CHOICE_DEL_CONFIG,
	CHOICE_LOAD_CONFIG
};

enum
{
	CONFIG_NAME,
	CONFIG_RENAME
};

enum
{
	X,
	Y,
	Z
};

enum ( += 1000 )
{
	TASK_SPRITE = 1000,
	TASK_SOLID,
	TASK_SOLIDNOT,
	TASK_ICE,
	TASK_HONEY,
	TASK_NOSLOWDOWN,
	TASK_INVINCIBLE,
	TASK_STEALTH,
	TASK_BOOTSOFSPEED,
	TASK_SUPERMAN,
	TASK_MOVEBACK
};

enum { AUTOMATIC_NONE, AUTOMATIC_ROUND, AUTOMATIC_RANDOM, AUTOMATIC_VOTE };

const BLOCK_DELETE_CHUNK = 50;
const Float:LOADING_DELAY = 2.5;

new g_file[256];
new g_new_file[256];
new g_config_file[256];

new g_keys_main_menu;
new g_keys_block_menu;
new g_keys_block_selection_menu;
new g_keys_properties_menu;
new g_keys_teleport_menu;
new g_keys_config_menu;
new g_keys_config_selection_menu;
new g_keys_config_vote_menu;
new g_keys_options_menu;
new g_keys_choice_menu;

new g_main_menu[256];
new g_block_menu[256];
new g_teleport_menu[256];
new g_config_menu[256];
new g_options_menu[256];
new g_choice_menu[256];

const MAX_CONFIGS = 32;
new g_config_names[MAX_CONFIGS][32];
new g_config_index[MAX_CONFIGS];
new g_config_count = 0;
new g_current_config = 0;
new g_voted_config = -1;
new g_config_vote[32];
new g_config_vote_menu[32];
new g_rock_the_config[32];
new bool:g_in_config_vote = false;
new bool:g_vote_config_locked = false;

new g_connected;
new g_alive;
new g_admin;
new g_snapping;
new g_viewing_properties_menu;
new g_no_fall_damage;
new g_ice;
new g_low_gravity;
new g_no_slow_down;
new g_has_hud_text;
new g_block_status;
new g_awp_used;
new g_deagle_used;
new g_usp_used;
new g_tmp_used;
new g_aug_used;
new g_m3_used;
new g_mac10_used;
new g_ak47_used;
new g_c4_used;
new g_hegrenade_used;
new g_smokegrenade_used;
new g_flashgrenade_used;
new g_money_used;
new g_reseted;
new g_noclip;
new g_godmode;
new g_auto_block_properties;
new g_iHasVoted;
new g_iHasVotedAlready;
new g_bootsofspeed;
new g_max_players;
new g_block_count;
new g_iMsgId_SayText;
new gmsgScreenFade;
new g_load_start_line;
new stuck;


new g_rounds = 0;
new g_iTimer = 20;

new Dir[64];
new Map[32];

new Ak47Used[43];
new GlockUsed[43];
new UspUsed[43];
new DeagleUsed[43];
new AwpUsed[43];
new M3Used[43];
new M4a1Used[43];
new XpUsed[43];
new g_selected_block_size[33];
new g_choice_option[33];
new g_block_selection_page[33];
new g_teleport_start[33];
new g_teleport_block_start[33];
new g_grabbed[33];
new g_szViewModel[33][32];
new g_grouped_blocks[33][256];
new g_group_count[33];
new g_property_info[33][2];
new g_slap[33][5];
new g_honey[33];
new g_boots_of_speed[33];
new g_menu_before_options[33];
new g_config_menu_page[33];
new g_value_types[33];

new Float:gfMuzaNextUse[33];
new Float:gfMuzaTimeOut[33];

new Float:g_snapping_gap[33];
new Float:g_grab_offset[33][3];
new Float:g_grab_length[33];
new Float:g_next_damage_time[33];
new Float:g_next_heal_time[33];
new Float:g_invincibility_time_out[33];
new Float:g_invincibility_next_use[33];
new Float:g_stealth_time_out[33];
new Float:g_stealth_next_use[33];
new Float:g_boots_of_speed_time_out[33];
new Float:g_boots_of_speed_next_use[33];
new Float:g_superman_time_out[33];
new Float:g_superman_next_use[33];
new Float:g_blind_next_use[33];
new Float:g_set_velocity[33][3];
new Float:g_next_xp_time[33];

enum
{
	PLATFORM,
	BHOP,
	DAMAGE,
	HEALER,
	NO_FALL_DAMAGE,
	ICE,
	TRAMPOLINE,
	SPEED_BOOST,
	DEATH,
	LOW_GRAVITY,
	SLAP,
	HONEY,
	CT_BARRIER,
	T_BARRIER,
	GLASS,
	NO_SLOW_DOWN_BHOP,
	DELAYED_BHOP,
	INVINCIBILITY,
	STEALTH,
	BOOTS_OF_SPEED,
	WEAPON_BLOCK,
	DUCK_BLOCK,
	XP,
        BLIND_TRAP,
	SUPERMAN,
	MONEY,
	BOUNCE_DEATH,
	TELEPORT,
	DESTINATION,
	MAGIC_CARPET,
        HE,
        FLASH,
        SMOKE,
        M4A1,
        M3,
        AWP,
        DEAGLE,
        USP,
        GLOCK,
        AK47,
        LIGHT,
        QUAKE,
        MUZA,
  
        TOTAL_BLOCKS
};

enum
{
	TELEPORT_START,
	TELEPORT_DESTINATION
};

enum
{
	NORMAL,
	SMALL,
	LARGE,
	POLE
};

enum
{
	NORMAL,
	GLOWSHELL,
	TRANSCOLOR,
	TRANSALPHA,
	TRANSWHITE
};

const TOTAL_BLOCKS = 43;
new MAX_BLOCKS;
new g_selected_block_type[TOTAL_BLOCKS];
new g_render[TOTAL_BLOCKS];
new g_red[TOTAL_BLOCKS];
new g_green[TOTAL_BLOCKS];
new g_blue[TOTAL_BLOCKS];
new g_alpha[TOTAL_BLOCKS];

new g_pCvar_ShowMessage;
new g_pCvar_Enable;
new g_pCvar_LoadingRounds;
new g_pCvar_AutoLoading;

new const g_block_names[TOTAL_BLOCKS][] =
{
	"Platform",
	"Bhop",
	"Damage",
	"Healer",
	"No Fall Damage",
	"Ice",
	"Trampoline",
	"Speed Boost",
	"Death",
	"Low Gravity",
	"Slap",
	"Honey",
	"CT Barrier",
	"VIP Barrier",
	"Glass",
	"No Slow Bhop",
	"Delayed Bhop",
	"Invincibility",
	"Stealth",
	"Boots Of Speed",
	"Weapon",
	"Duck",
	"XP Block",
	"Blind Trap",
	"Superman",
	"Money",
	"Bouncing Death",
	"Teleport Block",
	"Destination",
	"Magic Carpet",
        "High Explosive",
        "Flash",
        "Smoke",
        "M4a1 Gun",
        "Shotgun",
        "Awp Gun",
        "Deagle",
        "Usp",
        "Glock",
        "AK47",
        "Light",
        "Quake",
        "Music Block"
};

new const g_property1_name[TOTAL_BLOCKS][] =
{
	"",
	"No Fall Damage",
	"Damage Per Interval",
	"Health Per Interval",
	"",
	"Friction",
	"Jump",
	"Forward Speed",
	"",
	"Gravity",
	"Hardness",
	"Speed In Honey",
	"Admin Access",
	"",
	"",
	"No Fall Damage",
	"Delay Before Dissapear",
	"",
	"",
	"",
	"Weapons",
	"",
	"XP Amount",
	"Bind Red",
	"Superman Power",
	"Money",
	"Bouncing Height",
	"Teleport Name",
	"Destination Name",
	"Magic Carpet",
        "",
        "",
        "",
        "",
        "",
        "",
        "",
        "",
        "",
        "",
        "",
        "",
        ""
};

new const g_property1_default_value[TOTAL_BLOCKS][] =
{
	"",
	"0",
	"5",
	"1",
	"",
	"0.50",
	"400",
	"900",
	"",
	"200",
	"2",
	"75",
	"1",
	"",
	"",
	"0",
	"1",
	"10",
	"10",
	"10",
	"1",
	"",
	"200",
	"255",
	"10",
	"3000",
	"400",
	"Name",
	"Name",
	"4",
        "",
        "",
        "",
        "1",
        "1",
        "1",
        "1",
        "1",
        "",
        "",
        "",
        "",
        ""
};

new const g_property2_name[TOTAL_BLOCKS][] =
{
	"",
	"",
	"Interval Between Damage",
	"Interval Between Heals",
	"",
	"",
	"",
	"Upward Speed",
	"",
	"",
	"",
	"",
	"",
	"",
	"Money",
	"",
	"",
	"Delay After Usage",
	"Delay After Usage",
	"Delay After Usage",
	"Bullets",
	"",
	"Delay After Usage",
	"Blind Green",
	"Delay After Usage",
	"",
	"",
	"",
	"",
	"Delay Before Respawn",
        "",
        "",
        "",
        "",
        "",
        "",
        "",
        "",
        "",
        "",
        "",
        "",
        ""
};
 
new const g_property2_default_value[TOTAL_BLOCKS][] =
{
	"",
	"",
	"0.5",
	"0.5",
	"",
	"",
	"",
	"200",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"200",
	"200",
	"200",
	"1",
	"",
	"200",
	"255",
	"60",
	"",
	"",
	"",
	"",
	"5",
        "",
        "",
        "",
        "1",
        "1",
        "1",
        "1",
        "1",
        "",
        "",
        "",
        "",
        "" 
};

new const g_property3_name[TOTAL_BLOCKS][] =
{
	"Transparency",
	"Transparency",
	"Transparency",
	"Transparency",
	"Transparency",
	"Transparency",
	"Transparency",
	"Transparency",
	"Transparency",
	"Transparency",
	"Transparency",
	"Transparency",
	"Transparency",
	"Transparency",
	"",
	"Transparency",
	"Transparency",
	"",
	"",
	"Speed",
	"Transparency",
	"Transparency",
	"Transparency",
	"Blind Blue",
	"Transparency",
	"Transparency",
	"Transparency",
	"Transparency",
	"Transparency",
	"Transparency",
        "Transparency",
        "Transparency",
        "Transparency",
        "Transparency",
        "Transparency",
        "Transparency",
        "Transparency",
        "Transparency",
        "Transparency",
        "Transparency",
        "Transparency",
        "Transparency",
        "Transparency"
};

new const g_property3_default_value[TOTAL_BLOCKS][] =
{
	"255",
	"255",
	"255",
	"255",
	"255",
	"255",
	"200",
	"255",
	"255",
	"255",
	"255",
	"255",
	"255",
	"255",
	"",
	"255",
	"255",
	"",
	"",
	"1000",
	"255",
	"255",
	"255",
	"255",
	"255",
	"255",
	"255",
	"255",
	"255",
	"255",
        "255",
        "255",
        "255",
        "255",
        "255",
        "255",
        "255",
        "255",
        "255",
        "255",
        "255",
        "255",
        "255"
};

new const g_property4_name[TOTAL_BLOCKS][] =
{
	"",
	"On Top Only",
	"On Top Only",
	"On Top Only",
	"",
	"",
	"On Top Only",
	"On Top Only",
	"On Top Only",
	"On Top Only",
	"On Top Only",
	"On Top Only",
	"On Top Only",
	"On Top Only",
	"",
	"On Top Only",
	"On Top Only",
	"On Top Only",
	"On Top Only",
	"On Top Only",
	"On Top Only",
	"On Top Only",
	"On Top Only",
	"Alpha Amount",
	"On Top Only",
	"On Top Only",
	"On Top Only",
	"On Top Only",
	"On Top Only",
	"On Top Only",
        "On Top Only",
        "On Top Only",
        "On Top Only",
        "On Top Only",
        "On Top Only",
        "On Top Only",
        "On Top Only",
        "On Top Only",
        "On Top Only",
        "On Top Only",
        "On Top Only",
        "On Top Only",
        "On Top Only"
};

new const g_property4_default_value[TOTAL_BLOCKS][] =
{
	"",
	"1",
	"1",
	"0",
	"",
	"",
	"1",
	"1",
	"1",
	"0",
	"1",
	"1",
	"0",
	"0",
	"",
	"1",
	"1",
	"1",
	"1",
	"1",
	"1",
	"1",
	"1",
	"255",
	"1",
	"1",
	"0",
	"1",
	"1",
	"0",
        "1",
        "1",
        "1",
        "1",
        "1",
        "1",
        "1",
        "1",
        "1",
        "1",
        "",
        "",
        "1"
};

new const g_block_save_ids[TOTAL_BLOCKS] =
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
	'3',
	'X',
	'Y',
	'Z',
	'8',
	'4',
	'5',
	'6',
	'7',
        'W',
        '9',
        '1',
        '%',
        '#',
        '@',
        'a',
        'b',
        'c',
        'd',
        'g',
        'f',
        'h'
};

new g_block_models[TOTAL_BLOCKS][256];
new g_block_selection_pages_max;

public plugin_precache()
{
	g_block_models[PLATFORM] =		g_model_platform;
	g_block_models[BHOP] =			g_model_bhop;
	g_block_models[DAMAGE] =		g_model_damage;
	g_block_models[HEALER] =		g_model_healer;
	g_block_models[NO_FALL_DAMAGE] =	g_model_no_fall_damage;
	g_block_models[ICE] =			g_model_ice;
	g_block_models[TRAMPOLINE] =		g_model_trampoline;
	g_block_models[SPEED_BOOST] =		g_model_speed_boost;
	g_block_models[DEATH] =			g_model_death;
	g_block_models[LOW_GRAVITY] =		g_model_low_gravity;
	g_block_models[SLAP] =			g_model_slap;
	g_block_models[HONEY] =			g_model_honey;
	g_block_models[CT_BARRIER] =		g_model_ct_barrier;
	g_block_models[T_BARRIER] =		g_model_t_barrier;
	g_block_models[GLASS] =			g_model_glass;
	g_block_models[NO_SLOW_DOWN_BHOP] =	g_model_no_slow_down_bhop;
	g_block_models[DELAYED_BHOP] =		g_model_delayed_bhop;
	g_block_models[INVINCIBILITY] =		g_model_invincibility;
	g_block_models[STEALTH] =		g_model_stealth;
	g_block_models[BOOTS_OF_SPEED] =	g_model_boots_of_speed;
	g_block_models[WEAPON_BLOCK] =		g_model_weapon_block;
	g_block_models[DUCK_BLOCK] =		g_model_duck_block;
	g_block_models[XP] =		        g_model_xp_block;
	g_block_models[BLIND_TRAP] =		g_model_blind_trap;
	g_block_models[SUPERMAN] =		g_model_superman;
	g_block_models[MONEY] =			g_model_money;
	g_block_models[BOUNCE_DEATH] =		g_model_death;
	g_block_models[TELEPORT] =		g_model_teleport;
	g_block_models[DESTINATION] =		g_model_destination;
	g_block_models[MAGIC_CARPET] =		g_model_magiccarpet;
        g_block_models[HE]=                     g_model_he;
        g_block_models[FLASH_]=                  g_model_flash;
        g_block_models[SMOKE]=                  g_model_smoke;
	g_block_models[M4A1]=                   g_model_m4a1;
        g_block_models[M3]=                     g_model_m3;
        g_block_models[AWP]=                    g_model_awp;
        g_block_models[DEAGLE]=                 g_model_deagle;
        g_block_models[USP]=                    g_model_usp;
        g_block_models[GLOCK] =                 g_model_glock;
        g_block_models[AK47]=                   g_model_ak47;
        g_block_models[LIGHT]=                  g_model_light;
        g_block_models[QUAKE]=                  g_model_quake;
        g_block_models[MUZA]=                   g_model_muza;

	SetupBlockRendering(GLASS, TRANSWHITE, 255, 255, 255, 100);
	SetupBlockRendering(INVINCIBILITY, GLOWSHELL, 0, 150, 255, 16);
        SetupBlockRendering(STEALTH, GLOWSHELL, 255, 255, 255, 16);
	SetupBlockRendering(XP, GLOWSHELL, 255, 150, 0, 16);
        SetupBlockRendering(WEAPON_BLOCK, GLOWSHELL, 255, 0, 0, 16);
        SetupBlockRendering(XP, GLOWSHELL, 255, 150, 0, 16);
        SetupBlockRendering(HE, GLOWSHELL, 0, 0, 255, 16);
        SetupBlockRendering(FLASH, GLOWSHELL, 0, 0, 255, 16);
        SetupBlockRendering(SMOKE, GLOWSHELL, 0, 0, 255, 16);
        SetupBlockRendering(M4A1, GLOWSHELL, 255, 0, 0, 16);
        SetupBlockRendering(M3, GLOWSHELL, 255, 0, 0, 16);
        SetupBlockRendering(AWP, GLOWSHELL, 255, 0, 0, 16);
        SetupBlockRendering(DEAGLE, GLOWSHELL, 255, 0, 0, 16);
        SetupBlockRendering(USP, GLOWSHELL, 255, 0, 0, 16);
        SetupBlockRendering(GLOCK, GLOWSHELL, 255, 0, 0, 16);
        SetupBlockRendering(AK47, GLOWSHELL, 255, 0, 0, 16);
	
	new block_model_small[256];
	new block_model_large[256];
	new block_model_pole[256];

	for ( new i = 0; i < TOTAL_BLOCKS; ++i )
	{
		SetBlockModelNameSmall(block_model_small, g_block_models[i], 256);
		SetBlockModelNameLarge(block_model_large, g_block_models[i], 256);
		SetBlockModelNamePole(block_model_pole, g_block_models[i], 256);
		
		precache_model(g_block_models[i]);
		precache_model(block_model_small);
		precache_model(block_model_large);
		precache_model(block_model_pole);
	}
	
	precache_model(g_sprite_teleport_start);
	precache_model(g_sprite_teleport_destination);     
        precache_sound(g_sound_invincibility);
        precache_sound(g_sound_stealth);
        precache_sound(g_sound_boots_of_speed);
        precache_sound(g_sound_supermario);
        precache_sound(g_sound_xpblock);
        precache_sound(g_sound_money);
        precache_sound(g_sound_teleport);
        precache_sound(g_sound_teleports);
        precache_sound(g_sound_death);
        precache_sound(g_sound_death_bounce);
        precache_sound(g_sound_trampoline);
        precache_sound(gsz1);
	precache_sound(gsz2);
	precache_sound(gsz3);
	precache_sound(gsz4);
	precache_sound(gsz5);
	precache_sound(gsz6);
	precache_sound(gsz7);
	precache_sound(gsz8);
	precache_sound(gsz9);
	precache_sound(gsz10);
	precache_sound(gsz11);

}

public plugin_init()
{
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR);

	register_clcmd("say /strafe-bm",			"CmdMainMenu", ADMIN_MENU);
	register_clcmd("say /strafe-bm",			"CmdMainMenu", ADMIN_MENU);
	register_clcmd("say rtt",			"CmdRockTheConfig");
	register_clcmd("say /rtt",			"CmdRockTheConfig");
	register_clcmd("say rtc",			"CmdRockTheConfig");
	register_clcmd("say /rtc",			"CmdRockTheConfig");
	register_clcmd("say rockthetemplate",		"CmdRockTheTemplate", ADMIN_MENU);
	register_clcmd("say /rockthetemplate",		"CmdRockTheTemplate", ADMIN_MENU);
	register_clcmd("say config",			"CmdConfig");
	register_clcmd("say /config",			"CmdConfig");
	
	register_clcmd("BCM_SetProperty",		"SetPropertyBlock",	-1);
	
	register_clcmd("+BMGrab",		"CmdGrab",		-1, g_blank);
	register_clcmd("-BMGrab",		"CmdRelease",		-1, g_blank);
	
	register_clcmd("Enter_Value", 		"CmdEnterValue");
	register_clcmd("BCM_Configs", 		"CmdConfigs", 		-1);
	
	g_pCvar_ShowMessage = register_cvar("BCM_Show_Messages", "0");
	g_pCvar_Enable = register_cvar("BCM_Enable", "1");
	g_pCvar_LoadingRounds = register_cvar("BCM_loadingrounds", "0");
	g_pCvar_AutoLoading = register_cvar("BCM_automaticloading", "0");
	
	CreateMenus();
	
	register_menucmd(register_menuid("BcmMainMenu"),		g_keys_main_menu,		"HandleMainMenu");
	register_menucmd(register_menuid("BcmBlockMenu"),		g_keys_block_menu,		"HandleBlockMenu");
	register_menucmd(register_menuid("BcmBlockSelectionMenu"),	g_keys_block_selection_menu,	"HandleBlockSelectionMenu");
	register_menucmd(register_menuid("BcmPropertiesMenu"),		g_keys_properties_menu,		"HandlePropertiesMenu");
	register_menucmd(register_menuid("BcmTeleportMenu"),		g_keys_teleport_menu,		"HandleTeleportMenu");
	register_menucmd(register_menuid("BcmConfigMenu"), 		g_keys_config_menu, 		"HandleConfigMenu");
	register_menucmd(register_menuid("BcmConfigSelectionMenu"), 	g_keys_config_selection_menu, 	"HandleConfigSelectionMenu");
	register_menucmd(register_menuid("BcmConfigVoteMenu"), 		g_keys_config_vote_menu, 	"HandleConfigVoteMenu");
	register_menucmd(register_menuid("BcmOptionsMenu"),		g_keys_options_menu,		"HandleOptionsMenu");
	register_menucmd(register_menuid("BcmChoiceMenu"),		g_keys_choice_menu,		"HandleChoiceMenu");
	
	RegisterHam(Ham_Spawn,		"player",	"FwdPlayerSpawn",	1);
	RegisterHam(Ham_Killed,		"player",	"FwdPlayerKilled",	1);
	
	register_forward(FM_CmdStart,			"FwdCmdStart");
	register_message(get_user_msgid("StatusValue"),	"MsgStatusValue");

	register_event( "CurWeapon", 	"EventCurWeaponModelView", 	"be", 	"1!0" );
	register_event( "CurWeapon",	"EventCurWeapon",		"be" );
	//register_event("HLTV", "EventNewRound", "a", "1=0", "2=0");
	register_logevent( "EventNewRound" , 2 , "1=Round_End" );

	gmsgScreenFade = get_user_msgid("ScreenFade");
	g_iMsgId_SayText = get_user_msgid( "SayText" );
	g_max_players =	get_maxplayers();
	

	for(new x = 0; x < g_max_players; x++)
		g_rock_the_config[x] = 0;
	
	//make save folder in basedir (new saving/loading method)
	get_basedir(Dir, 64);
	add(Dir, 64, "/blockmaker");
	
	//make config folder if it doesn't already exist
	if (!dir_exists(Dir))
		mkdir(Dir);
	
	get_mapname(Map, 64);
	
	if(equali(Map, "awp_map") || equali(Map, "de_dust_igz"))
		MAX_BLOCKS = 999;
	else
		MAX_BLOCKS = 999;
	
	formatex(g_config_file, 96, "%s/%s.bm.config", Dir, Map);

}

public plugin_cfg()
{
	LoadBlockConfigurations();
	newLoad(0);
}

LoadBlockConfigurations() {
	g_config_count = 1;
	g_config_index[0] = 0;
	copy(g_config_names[0], 32, "Default");
	if (file_exists(g_config_file)) {
		new fp = fopen(g_config_file, "rt");
		new index[16];
		new name[32];
		new data[128];
		while (!feof(fp) && (g_config_count < MAX_CONFIGS)) {
			fgets(fp, data, 128);
			if(2 == parse(data, index, 16, name, 32)) {
				copy(g_config_names[g_config_count], 32, name);
				g_config_index[g_config_count] = str_to_num(index);
				g_config_count ++;
			}
			
		}
		fclose(fp);
	}
	new TOTAL_CONFIGS;
	TOTAL_CONFIGS = random_num(0, g_config_count-1);
	GetConfigFileName(TOTAL_CONFIGS, g_new_file);
	g_current_config = TOTAL_CONFIGS;
}

SaveBlockConfigurations() {
	new fp = fopen(g_config_file, "wt");
	new data[128];
	for(new i = 1; i < g_config_count; i++) {
		formatex(data, 128, "%d ^"%s^"^n", g_config_index[i], g_config_names[i]);
		fputs(fp, data);
	}
	fclose(fp);
}

public CmdConfigs(id)
	for(new i = 0; i < g_config_count; i++)
		BCM_Print(id, "^1 %d^3/^1%s.", g_config_index[i], g_config_names[i]);

public client_putinserver(id)
{
	if(bool:!is_user_hltv(id))
		set_bit(g_connected, id);
	
	clear_bit(g_alive, id);
	
	if(is_user_admin(id))
	set_bit(g_admin, id);
	
	clear_bit(g_viewing_properties_menu, id);
	
	set_bit(g_snapping, id);

	g_snapping_gap[id] =			0.0;

	g_group_count[id] =			0;
	
	clear_bit(g_noclip, id);
	clear_bit(g_godmode, id);
	clear_bit(g_reseted, id);
	clear_bit(g_iHasVotedAlready, id);
	
	ResetPlayer(id);
}

public client_disconnect(id)
{
	
	clear_bit(g_connected, id);
	clear_bit(g_alive, id);
	clear_bit(g_admin, id);
	
	ClearGroup(id);
	
	if ( g_grabbed[id] )
	{
		if ( is_valid_ent(g_grabbed[id]) )
		{
			entity_set_int(g_grabbed[id], EV_INT_iuser2, 0);
		}
		
		g_grabbed[id] =	0;
	}
}

CreateMenus()
{
	g_block_selection_pages_max = floatround((float(TOTAL_BLOCKS) / 8.0), floatround_ceil);
	
	new size = charsmax(g_main_menu);
	add(g_main_menu, size, "\r[Str3e7-CS]^n\wBlockmaker ^n^n");
	add(g_main_menu, size, "\r1. \yBlock Menu^n");
	add(g_main_menu, size, "\r2. \yTeleport Menu^n");
	add(g_main_menu, size, "\r3. \yConfig Menu^n^n");
	add(g_main_menu, size, "\r6. \yUse Noclip: ^n");
	add(g_main_menu, size, "\r7. \yUse God: ^n^n");
	add(g_main_menu, size, "\r9. \yOptions Menu^n^n");
	add(g_main_menu, size, "\r0. Close");
	g_keys_main_menu =		B1 | B2 | B3 | B6 | B7 | B9 | B0;
	
	size = charsmax(g_block_menu);
	add(g_block_menu, size, "\r[Str3e7-CS]^n\wBlock Menu^n\yBlock Count: \y(\r%d\w/\r%d\y)^n^n");
	add(g_block_menu, size, "\r1. \yBlock Type: \y%s^n");
	add(g_block_menu, size, "\r2. \y%sCreate Block^n");
	add(g_block_menu, size, "\r3. \y%sConvert Block^n");
	add(g_block_menu, size, "\r4. \y%sDelete Block^n");
	add(g_block_menu, size, "\r5. \y%sRotate Block^n^n");
	add(g_block_menu, size, "\r6. \yAdjust Size: \y%s^n");
	add(g_block_menu, size, "\r7. \y%sSet Properties^n^n");
	add(g_block_menu, size, "\r9. \yOptions Menu^n^n");
	add(g_block_menu, size, "\r0. Back");
	g_keys_block_menu =		B1 | B2 | B3 | B4 | B5 | B6 | B7 | B9 | B0;
	g_keys_block_selection_menu =	B1 | B2 | B3 | B4 | B5 | B6 | B7 | B8 | B9 | B0;
	g_keys_properties_menu =	B1 | B2 | B3 | B4 | B0;
	
	size = charsmax(g_teleport_menu);
	add(g_teleport_menu, size, "\r[Str3e7-CS]^n\wTeleport Menu^n^n");
	add(g_teleport_menu, size, "\r1. \y%sCreate Start^n");
	add(g_teleport_menu, size, "\r2. \y%sCreate Destination^n");
	add(g_teleport_menu, size, "\r3. \y%sSwap Start/Destination^n");
	add(g_teleport_menu, size, "\r4. \y%sDelete Teleport^n^n");
	add(g_teleport_menu, size, "\r6. \yUse Noclip: ^n");
	add(g_teleport_menu, size, "\r7. \yUse God: ^n^n");
	add(g_teleport_menu, size, "\r9. \yOptions Menu^n^n");
	add(g_teleport_menu, size, "\r0. \wBack");
	g_keys_teleport_menu =		B1 | B2 | B3 | B4 | B6 | B7 | B9 | B0;
	
	size = charsmax(g_config_menu);
	add(g_config_menu, size, "\r[Str3e7-CS]^n\wConfiguration Menu \y(\rbe sure to save first!\y)^n^n");
	add(g_config_menu, size, "\r1. \y%sLoad Config^n");
	add(g_config_menu, size, "\r2. \y%sCreate and Load new Config^n");
	add(g_config_menu, size, "\r3. \y%sDelete current Config (\y%s\w)^n");
	add(g_config_menu, size, "\r4. \y%sRename current Config (\y%s\w)^n^n");
	add(g_config_menu, size, "\r0. Back");
	g_keys_config_menu = 		B1 | B2 | B3 | B4 | B0;
	g_keys_config_selection_menu = 	B1 | B2 | B3 | B4 | B5 | B6 | B7 | B8 | B9 | B0;
	g_keys_config_vote_menu = 	B1 | B2 | B3 | B4 | B5 | B6 | B7 | B8 | B9 | B0;
	
	size = charsmax(g_options_menu);
	add(g_options_menu, size, "\r[Str3e7-CS]^n\wOptions Menu^n^n");
	add(g_options_menu, size, "\r1. \y%sSnapping: %s^n");
	add(g_options_menu, size, "\r2. \y%sSnapping Gap: \y%.1f^n^n");
	add(g_options_menu, size, "\r3. \y%sAdd to Group^n");
	add(g_options_menu, size, "\r4. \y%sClear Group^n^n");
	add(g_options_menu, size, "\r5. \y%sDelete All^n");
	add(g_options_menu, size, "\r6. \y%sAuto display info: %s^n^n");
	add(g_options_menu, size, "\r7. \y%sSave to file^n");
	add(g_options_menu, size, "\r8. \y%sLoad from file^n^n");
	add(g_options_menu, size, "\y0. \rBack");
	g_keys_options_menu =		B1 | B2 | B3 | B4 | B5 | B6 | B7 | B8 | B0;
	
	size = charsmax(g_choice_menu);
	add(g_choice_menu, size, "\r[Str3e7-CS]^n\w%s^n^n");
	add(g_choice_menu, size, "\r1. \yYes^n");
	add(g_choice_menu, size, "\r2. \yNo^n^n^n");
	add(g_choice_menu, size, "\r3. \yJust \yBlocks^n");
	add(g_choice_menu, size, "\r4. \yJust \yTeleports^n");
	add(g_choice_menu, size, "\y0. \rBack");
	g_keys_choice_menu =		B1 | B2 | B3 | B4 | B0;

}

new g_iRounds;

public EventNewRound(id) {
	if( g_iRounds >= 6 ) {
		BCM_Print( 0, "^1 This is ^3 Blockmaker^4 %s Updated! ^3Good luck to all players and have fun.", PLUGIN_VERSION );
		g_iRounds = 0;
	}
	
	g_iRounds++;
	
	if(g_in_config_vote) {
		return PLUGIN_HANDLED;
	}
	new type = get_pcvar_num(g_pCvar_AutoLoading);
	new bool:loadAnyways = false;
	if(g_voted_config >= 0) {
		loadAnyways = true;
		type = AUTOMATIC_VOTE;
	}
	if(!loadAnyways && type == AUTOMATIC_NONE) {
		return PLUGIN_HANDLED;
	}
	
	if(g_current_config == g_voted_config)
	{
		loadAnyways = false;
		g_voted_config = -1;
		BCM_Print(0, "^1Due to the same^3 config^1 no^4 loading^1 necessary.");
		
		return PLUGIN_HANDLED;
	}
	
	g_rounds++;
	new roundLimit = get_pcvar_num(g_pCvar_LoadingRounds);
	if(!loadAnyways && roundLimit == 0) {
		return PLUGIN_HANDLED;
	}
	if(!loadAnyways && ((g_rounds + 1) % roundLimit == 0)) {
		VoteConfigs();
	}
	if(!loadAnyways && (g_rounds % roundLimit != 0)) {
		return PLUGIN_HANDLED;
	}
	g_rounds = 0;
	for(new x = 0; x < g_max_players; x++) {
		g_rock_the_config[x] = 0;
	}
	
	if(type == AUTOMATIC_RANDOM) {
		g_current_config = random_num(0, g_config_count - 1);
	} else if(type == AUTOMATIC_ROUND) {
		g_current_config++;
		g_current_config = g_current_config % g_config_count;
	} else if(type == AUTOMATIC_VOTE) {
		g_current_config = g_voted_config;
		g_voted_config = -1;
	}
	
	GetConfigFileName(g_current_config, g_new_file);
	BCM_Print(0, "^1Config^3 loaded^1 is: ^4[^3%s^4]^1.", g_config_names[g_current_config]);
	DeleteAll(0, false);
	g_load_start_line = 0;
	set_task(LOADING_DELAY, "TaskLoad", 0);
	return PLUGIN_HANDLED;
	
}


public ShowVoteMenu() {
	for(new x = 0; x < g_max_players; x++) {
		if(is_user_connected(x)) {
			ShowConfigVoteMenu(x);
		}
	}
}
public VoteConfigs() {
	
	for(new x = 0; x < g_max_players; x++) {
		g_config_vote[x] = -1;
		g_config_vote_menu[x] = 0;
		g_rock_the_config[x] = 0;
	}
	g_in_config_vote = true;
	
	BCM_Print(0, "^1Voting for a^3 Config^1 will start in^4 10^1 Seconds");
	set_task(10.0, "ShowVoteMenu");
	set_task(30.0, "VoteDone");
}	

public VoteDone() {
	new voteCount[MAX_CONFIGS];
	for(new x = 0; x < g_max_players; x++) {
		if(g_config_vote[x] > -1) {
			voteCount[g_config_vote[x]]++;
		}
	}
	
	new numMax = 0;
	new amount = 0;
	for(new x = 0; x < MAX_CONFIGS; x++) {
		if(voteCount[x] > numMax) {
			numMax = voteCount[x];
			amount = 1;
		} else if(voteCount[x] == numMax) {
			amount++;
		}
	}
	new maxCount;// = random_num(1, amount) - 1;
	for(new x = 0; x < MAX_CONFIGS; x++) {
		if(voteCount[x] == numMax) {
			if(maxCount == 0) {
				g_voted_config = x;
			}
			maxCount--;
		}
	}
	
	BCM_Print(0, "^1Config Voting^3 Finished^1, Result is:^4 [^3%s^4]^1.", g_config_names[g_voted_config]);
	g_in_config_vote = false;
}

public CmdRockTheTemplate(id) {
	if ( !get_bit(g_admin, id) )
	{
		console_print(id, "You have no access to that command");
		return PLUGIN_HANDLED;
	}
	
	if(!g_vote_config_locked)
	{
		new szName[32];
		get_user_name(id, szName, 31);
		BCM_Print(id, "Admin:^3 %s^1 has started a^4 vote^1.", szName);
	}
	
	g_vote_config_locked = true;
	set_task(180.0, "UnlockVoteConfig");
	VoteConfigs();
	
	new Players[32];
	new playerCount, i;
	get_players(Players, playerCount);
	for (i=0; i<playerCount; i++) 
		clear_bit(g_iHasVoted, Players[ i ]);
	
	return PLUGIN_HANDLED;
}

public CmdRockTheConfig(id) {
	
	if(g_vote_config_locked) {
		BCM_Print(id, "You Must Wait To Rock The Config Again!");
		return PLUGIN_HANDLED;
	}
	
	if(g_in_config_vote) {
		BCM_Print(0, "Template Voting in Progress.");
		return PLUGIN_HANDLED;
	}
	g_rock_the_config[id] = 1;
	new count = 0;
	new connected = 0;
	for(new x = 0; x < g_max_players; x++) {
		if(is_user_connected(x)) {
			connected++;
			if(g_rock_the_config[x] != 0) {
				count ++;
			}
		}
	}
	if( floatround(float(connected) * 0.8) - count < 1 )
	{
		BCM_Print(0, "^1Enough people have^3 Rock The Config");
	}
	else if(get_bit(g_iHasVoted, id))
	{
		BCM_Print(id, "^1You have already^3 rock the template^1!");
	}
	else
	{
		BCM_Print(id, "^1Need [^3%d^1] More to^3 Rock The Config", floatround(float(connected) * 0.8) - count);
		set_bit(g_iHasVoted, id);

		new Players[32];
		new playerCount, i, iPlayer;
		new szName[32];
		get_user_name(id, szName, 31);
		get_players(Players, playerCount);
		for (i=0; i<playerCount; i++) 
		{
			iPlayer = Players[ i ];
			if(iPlayer != id)
			{
				BCM_Print(iPlayer, "^3%s^1 has^3 Rock The Config^1 out of [^4 %d^1/^4%d^1 ]", szName, count, floatround(float(connected) * 0.8));
			}
		}
	}
	
	if(floatround(float(connected) * 0.8) <= count) {
		g_vote_config_locked = true;
		//set_task(get_pcvar_float(g_pCvar_TimeUnlockRtt), "UnlockVoteConfig");
		set_task(180.0, "UnlockVoteConfig");
		VoteConfigs();
		
		new Players[32];
		new playerCount, i;
		get_players(Players, playerCount);
		for (i=0; i<playerCount; i++) 
			clear_bit(g_iHasVoted, Players[ i ]);
	}
	return PLUGIN_HANDLED;	
}

public UnlockVoteConfig() {
	g_vote_config_locked = false;
}

public CmdConfig(id) {
	GetConfigFileName(g_current_config, g_new_file);
	BCM_Print(id, "^1The Current Config is^4 [^x03%s^x04]^1.", g_config_names[g_current_config]);
}

SetupBlockRendering(block_type, render_type, red, green, blue, alpha)
{
	g_render[block_type] =		render_type;
	g_red[block_type] =		red;
	g_green[block_type] =		green;
	g_blue[block_type] =		blue;
	g_alpha[block_type] =		alpha;
}

SetBlockModelNameLarge(block_model_target[256], block_model_source[256], size)
{
	block_model_target = block_model_source;
	replace(block_model_target, size, ".mdl", "_large.mdl");
}

SetBlockModelNameSmall(block_model_target[256], block_model_source[256], size)
{
	block_model_target = block_model_source;
	replace(block_model_target, size, ".mdl", "_small.mdl");
}

SetBlockModelNamePole(block_model_target[256], block_model_source[256], size)
{
	block_model_target = block_model_source;
	replace(block_model_target, size, ".mdl", "_pole.mdl");
}

public FwdPlayerSpawn(id)
{
	if ( !is_user_alive(id) ) return HAM_IGNORED;
	
	set_bit(g_alive, id);
	
	if ( get_bit(g_noclip, id) )		set_user_noclip(id, 1);
	if ( get_bit(g_godmode, id) )		set_user_godmode(id, 1);
	
	if ( !get_bit(g_reseted, id) )
	{
		ResetPlayer(id);
	}
	
	clear_bit(g_reseted, id);
       
        HeUsed[id] = false;
        FlashUsed[id] = false;
        SmokeUsed[id] = false;
        M3Used[id] = false;
        M4a1Used[id] = false;
        AwpUsed[id] = false;
        DeagleUsed[id] = false;
        UspUsed[id] = false;
        GlockUsed[id] = false;
        Ak47Used[id] = false;
	
	return HAM_IGNORED;
}

public FwdPlayerKilled(id)
{
	if(is_user_alive(id))
		set_bit(g_alive, id);
	else
		clear_bit(g_alive, id);
	
	ResetPlayer(id);

}

public FwdCmdStart(id, handle)
{
	if ( !get_bit(g_connected, id) ) return FMRES_IGNORED;
	
	static buttons, oldbuttons;
	buttons =	get_uc(handle, UC_Buttons);
	oldbuttons =	entity_get_int(id, EV_INT_oldbuttons);
	
	if ( get_bit(g_alive, id)
	&& buttons & IN_USE
	&& !( oldbuttons & IN_USE )
	&& !get_bit(g_has_hud_text, id) )
	{
		static iEntity, body;
		get_user_aiming(id, iEntity, body, 1000);
		
		if ( IsBlock(iEntity) )
		{
			static block_type, szCreator[32], szLastMover[32];
			block_type = entity_get_int(iEntity, EV_INT_body);
		
			pev(iEntity, pev_targetname, szCreator, 31);
			replace_all(szCreator, 31, "_", " ");
			pev(iEntity, pev_target, szLastMover, 31);
			replace_all(szLastMover, 31, "_", " ");
			
			set_hudmessage(0, 191, 255, -1.0, 0.3, 1, 3.0, 3.5, 3.7, 2.0, 2);
			show_hudmessage(id, "Template: %s^nBlock Count: %d", g_config_names[g_current_config], g_block_count);
			
			static property[5];
			
			static message[512], len;
			len = format(message, charsmax(message), "Type: %s^nCreator: %s^nLast Mover: %s", g_block_names[block_type], szCreator, szLastMover);
			
			if ( g_property1_name[block_type][0] && get_bit(g_admin, id) )
			{
				GetProperty(iEntity, 1, property);
				switch ( block_type )
				{
					case BHOP, NO_SLOW_DOWN_BHOP:
					{
						if( property[0] == '1' )
						{
							len += format(message[len], charsmax(message) - len, "^n%s", g_property1_name[block_type]);
						}
					}
					case MAGIC_CARPET:
					{
						len += format(message[len], charsmax(message) - len, "^n%s: %s", g_property1_name[block_type], property[0] == '4' ? "Off" : property[0] == '3' ? "All" : property[0] == '2' ? "Counter-Terrorists" : "Terrorists");
					}
					case SLAP:
					{
						len += format(message[len], charsmax(message) - len, "^n%s: %s", g_property1_name[block_type], property[0] == '3' ? "High" : property[0] == '2' ? "Medium" : "Low");
					}
					case CT_BARRIER, T_BARRIER:
					{
						len += format(message[len], charsmax(message) - len, "^n%s: %s", g_property1_name[block_type], property[0] == '3' ? "All Admins Only" : property[0] == '2' ? "Team Admins Only" : "Normal");
					}
					case WEAPON_BLOCK:
					{
						len += format(message[len], charsmax(message) - len, "^n%s: %s", g_property1_name[block_type], property[0] == '9' ? "Famas" : property[0] == '8' ? "AK47" : property[0] == '7' ? "Mac 10" : property[0] == '6' ? "Shotgun" : property[0] == '5' ? "Aug" : property[0] == '4' ? "Tmp" : property[0] == '3' ? "Usp" : property[0] == '2' ? "Deagle" : "Awp");
					}
					case PLATFORM, DAMAGE, HEALER, NO_FALL_DAMAGE, ICE, TRAMPOLINE, SPEED_BOOST, DEATH, LOW_GRAVITY, HONEY, DELAYED_BHOP, INVINCIBILITY, STEALTH,\
					BOOTS_OF_SPEED, DUCK_BLOCK, XP, BLIND_TRAP, SUPERMAN, MONEY, M4A1, M3, AWP, DEAGLE, USP, BOUNCE_DEATH, TELEPORT, DESTINATION:
					{
						len += format(message[len], charsmax(message) - len, "^n%s: %s", g_property1_name[block_type], property);
					}
				}
			}
			if ( g_property2_name[block_type][0] && get_bit(g_admin, id) )
			{
				GetProperty(iEntity, 2, property);
				
				len += format(message[len], charsmax(message) - len, "^n%s: %s", g_property2_name[block_type], property);
			}
			if ( g_property3_name[block_type][0]
			&& ( block_type == BOOTS_OF_SPEED
			|| block_type == BLIND_TRAP
				|| property[0] != '0'
				&& property[0] != '2'
				&& property[1] != '5'
				&& property[2] != '5' ) )
			{
				GetProperty(iEntity, 3, property);
				
				len += format(message[len], charsmax(message) - len, "^n%s: %s", g_property3_name[block_type], property);
			}
			if ( g_property4_name[block_type][0] && get_bit(g_admin, id) )
			{
				GetProperty(iEntity, 4, property);
				if( block_type == BLIND_TRAP )
				{
					len += format(message[len], charsmax(message) - len, "^n%s: %s", g_property4_name[block_type], property);
				}
				if( block_type == HEALER )
				{
					len += format(message[len], charsmax(message) - len, "^n%s: %s", g_property1_name[block_type], property[0] == '3' ? "Health/Armor" : property[0] == '2' ? "Armor" : "Health");
				}
				else
				{
					len += format(message[len], charsmax(message) - len, "^n%s: %s", g_property4_name[block_type], property[0] == '1' ? "Yes" : "No");
				}
			}
			
			set_hudmessage(0, 191, 255, -1.0, 0.3, 1, 3.0, 3.5, 3.7, 2.0, 2);
			show_hudmessage(id, message);
		}
	}
	
	if ( !g_grabbed[id] ) return FMRES_IGNORED;
	
	if ( buttons & IN_JUMP
	&& !( oldbuttons & IN_JUMP ) ) if ( g_grab_length[id] > 72.0 ) g_grab_length[id] -= 16.0;
	
	if ( buttons & IN_DUCK
	&& !( oldbuttons & IN_DUCK ) ) g_grab_length[id] += 16.0;
	
	if ( buttons & IN_ATTACK
	&& !( oldbuttons & IN_ATTACK ) ) CmdAttack(id);
	
	if ( buttons & IN_ATTACK2
	&& !( oldbuttons & IN_ATTACK2 ) ) CmdAttack2(id);
	
	if ( !is_valid_ent(g_grabbed[id]) )
	{
		CmdRelease(id);
		return FMRES_IGNORED;
	}
	
	if ( !IsBlockInGroup(id, g_grabbed[id]) && g_group_count[id] > 1 )
	{
		MoveGrabbedEntity(id);
		return FMRES_IGNORED;
	}
	
	static block;
	static Float:move_to[3];
	static Float:offset[3];
	static Float:origin[3];
	
	MoveGrabbedEntity(id, move_to);
	
	for ( new i = 0; i <= g_group_count[id]; ++i )
	{
		block = g_grouped_blocks[id][i];
		
		if ( !IsBlockInGroup(id, block) ) continue;
		
		entity_get_vector(block, EV_VEC_vuser1, offset);
		
		origin[0] = move_to[0] - offset[0];
		origin[1] = move_to[1] - offset[1];
		origin[2] = move_to[2] - offset[2];
		
		MoveEntity(id, block, origin, false);
	}
	
	return FMRES_IGNORED;
}

public EventCurWeapon(id)
{
	static block, property[5];
	new Float:gametime = get_gametime();
	new Float:time_out = g_boots_of_speed_time_out[id] - gametime;
	
	if (time_out >= 0.0)
	{
		GetProperty(block, 3, property);
		entity_set_float(id, EV_FL_maxspeed, str_to_float(property));
	}

	else if ( get_bit(g_ice, id) )
	{
		entity_set_float(id, EV_FL_maxspeed, 400.0);
	}
	else if ( g_honey[id] )
	{
		block = g_honey[id];
		GetProperty(block, 1, property);
		
		entity_set_float(id, EV_FL_maxspeed, str_to_float(property));
	}

	//ResetMaxspeed(id);
}

public pfn_touch(iEntity, id)
{
	if ( !( 1 <= id <= g_max_players )
	|| !get_bit(g_alive, id)
	|| !IsBlock(iEntity) ) return PLUGIN_CONTINUE;
	
	new block_type =	entity_get_int(iEntity, EV_INT_body);
	if ( block_type == GLASS ) return PLUGIN_CONTINUE;
	
	new flags =		entity_get_int(id, EV_INT_flags);
	new groundentity =	entity_get_edict(id, EV_ENT_groundentity);
	
	static property[5];
	GetProperty(iEntity, 4, property);
	
	if ( property[0] == '0'
	|| ( ( !property[0]
		|| property[0] == '1'
		|| property[0] == '/'
		|| block_type == BLIND_TRAP || block_type == HEALER )
	&& flags & FL_ONGROUND
	&& groundentity == iEntity ) )
	{
		switch ( block_type )
		{
			case BHOP, NO_SLOW_DOWN_BHOP:		ActionBhop(iEntity);
			case DAMAGE:				ActionDamage(id, iEntity);
			case HEALER:				ActionHeal(id, iEntity);
			case TRAMPOLINE:			ActionTrampoline(id, iEntity);
			case SPEED_BOOST:			ActionSpeedBoost(id, iEntity);
			case DEATH:				ActionDeath(id);
			case SLAP:
                        {
				GetProperty(iEntity, 1, property);
				g_slap[id] = property;
			}
			case LOW_GRAVITY:			ActionLowGravity(id, iEntity);
			case HONEY:				ActionHoney(id, iEntity);
			case CT_BARRIER:			ActionCTBarrier(id, iEntity);
			case T_BARRIER:				ActionTBarrier(id, iEntity);
			case DELAYED_BHOP:			ActionDelayedBhop(iEntity);
			case STEALTH:				ActionStealth(id, iEntity);
			case INVINCIBILITY:			ActionInvincibility(id, iEntity);
			case BOOTS_OF_SPEED:			ActionBootsOfSpeed(id, iEntity);
			case WEAPON_BLOCK:			ActionWeaponBlock(id, iEntity);
			case DUCK_BLOCK:			ActionDuckBlock(id);
			case XP:				ActionXp(id, iEntity);
			case SUPERMAN:				ActionSuperman(id, iEntity);
			case BLIND_TRAP:			ActionBlindTrap(id, iEntity);
			case MONEY:				ActionMoney(id, iEntity);
			case BOUNCE_DEATH:               	ActionDeathBounce(id);
			case TELEPORT:				ActionTeleportBlock(id, iEntity);
			case MAGIC_CARPET:			ActionMagicCarpet(id, iEntity);
                        case HE:                                ActionHe(id, iEntity);
                        case FLASH:                             ActionFlash(id, iEntity);
                        case SMOKE:                             ActionSmoke(id ,iEntity);
                        case M4A1:                              ActionM4a1(id, iEntity);
                        case M3:                                ActionM3(id, iEntity);
                        case AWP:                               ActionAwp(id, iEntity);
                        case DEAGLE:                            ActionDeagle(id, iEntity);
                        case USP:                               ActionUsp(id, iEntity);
                        case GLOCK:                             ActionGlock(id, iEntity);
                        case AK47:                              ActionAk47(id, iEntity);
                        case LIGHT:                             ActionLight(id);
                        case QUAKE:                             ActionQuake(id);
                        case MUZA:                              ActionMuza(id, iEntity);
		}
	}
	
	if ( flags & FL_ONGROUND
	&& groundentity == iEntity )
	{
		switch ( block_type )
		{
			case BHOP:
			{
				GetProperty(iEntity, 1, property);
				if ( property[0] == '1' )
				{
					set_bit(g_no_fall_damage, id);
				}
			}
			case NO_FALL_DAMAGE:			set_bit(g_no_fall_damage, id);
			case ICE:				ActionIce(id, iEntity);
			case NO_SLOW_DOWN_BHOP:
			{
				ActionNoSlowDown(id);
				
				GetProperty(iEntity, 1, property);
				if ( property[0] == '1' )
				{
					set_bit(g_no_fall_damage, id);
				}
			}
		}
	}
	
	return PLUGIN_CONTINUE;
}

public client_PreThink(id)
{
	if ( !get_bit(g_alive, id) ) return PLUGIN_CONTINUE;

	new Float:gametime =			get_gametime();
	new Float:timeleft_invincibility =	g_invincibility_time_out[id] - gametime;
	new Float:timeleft_stealth =		g_stealth_time_out[id] - gametime;
	new Float:timeleft_boots_of_speed =	g_boots_of_speed_time_out[id] - gametime;
	new Float:timeleft_superman =		g_superman_time_out[id] - gametime;
	
	if ( timeleft_invincibility >= 0.0
	|| timeleft_stealth >= 0.0
	|| timeleft_boots_of_speed >= 0.0
	|| timeleft_superman >= 0.0 )
		
	{
		new text[48], text_to_show[256];
		
		format(text, charsmax(text), "%s %s", PLUGIN_PREFIX, PLUGIN_VERSION);
		add(text_to_show, charsmax(text_to_show), text);
	
		if ( timeleft_invincibility >= 0.0 )
		{
			format(text, charsmax(text), "^nInvincible %.1f", timeleft_invincibility);
			add(text_to_show, charsmax(text_to_show), text);
		}
		
		if ( timeleft_stealth >= 0.0 )
		{
			format(text, charsmax(text), "^nStealth %.1f", timeleft_stealth);
			add(text_to_show, charsmax(text_to_show), text);
		}
		
		if ( timeleft_boots_of_speed >= 0.0 )
		{
			format(text, charsmax(text), "^nBoots Of Speed %.1f", timeleft_boots_of_speed);
			add(text_to_show, charsmax(text_to_show), text);
		}
		if ( timeleft_superman >= 0.0 )
		{
			format(text, charsmax(text), "^nTimed Gravity: %.1f^n", timeleft_superman);
			add(text_to_show, charsmax(text_to_show), text);
		}
		
		set_hudmessage(255, 51, 0, -1.0, 0.20, 1, 6.0, 12.0, 0.0, 1.0, 10);
		show_hudmessage(id, text_to_show);	
		
		set_bit(g_has_hud_text, id);
	}
	else
	{
		clear_bit(g_has_hud_text, id);
	}
	
	if ( get_bit(g_ice, id) || get_bit(g_no_slow_down, id) )
	{
		entity_set_float(id, EV_FL_fuser2, 0.0);
	}
	
	if ( g_set_velocity[id][0] != 0.0
	|| g_set_velocity[id][1] != 0.0
	|| g_set_velocity[id][2] != 0.0 )
	{
		entity_set_vector(id, EV_VEC_velocity, g_set_velocity[id]);
		
		g_set_velocity[id][0] = 0.0;
		g_set_velocity[id][1] = 0.0;
		g_set_velocity[id][2] = 0.0;
	}
	
	if ( get_bit(g_low_gravity, id) )
	{
		if ( entity_get_int(id, EV_INT_flags) & FL_ONGROUND )
		{
			entity_set_float(id, EV_FL_gravity, 1.0);
			clear_bit(g_low_gravity, id);
		}
                {
                set_hudmessage(255, 51, 0, -1.0, 0.35, 1, 6.0, 12.0, 0.0, 1.0, 2);
                show_hudmessage(id, "You stepped on moon and have gravity.."); 
                }
	}
	
	if ( g_slap[id][0] )
	{
		new slap_times = str_to_num(g_slap[id]) * 2;
		while ( slap_times )
                {
			user_slap(id, 0);
			slap_times--;
		}
                {
		set_hudmessage(255, 51, 0, -1.0, 0.35, 1, 6.0, 12.0, 0.0, 1.0, 2);
                show_hudmessage(id, "Get away from the angry fist..");
                }
                g_slap[id][0] = 0;
	}		
	
	return PLUGIN_CONTINUE;
}

public server_frame()
{
	static iEntity;
	static entinsphere;
	static Float:origin[3];
	
	while ( ( iEntity = find_ent_by_class(iEntity, g_start_classname) ) )
	{
		entity_get_vector(iEntity, EV_VEC_origin, origin);
		
		entinsphere = -1;
		while ( ( entinsphere = find_ent_in_sphere(entinsphere, origin, 40.0) ) )
		{
			static classname[32];
			entity_get_string(entinsphere, EV_SZ_classname, classname, charsmax(classname));
			
			if ( 1 <= entinsphere <= g_max_players && get_bit(g_alive, entinsphere) )
			{
				ActionTeleport(entinsphere, iEntity);
			}
			else if ( equal(classname, "grenade") )
			{
				entity_set_int(iEntity, EV_INT_solid, SOLID_NOT);
				ActionTeleport(entinsphere, iEntity);
				entity_set_float(iEntity, EV_FL_ltime, get_gametime() + 2.0);
			}
			else if ( get_gametime() >= entity_get_float(iEntity, EV_FL_ltime) )
			{
				entity_set_int(iEntity, EV_INT_solid, SOLID_BBOX);
			}
		}
	}
	
	static bool:ent_near;
	
	ent_near = false;
	while ( ( iEntity = find_ent_by_class(iEntity, g_destination_classname) ) )
	{
		entity_get_vector(iEntity, EV_VEC_origin, origin);
		
		entinsphere = -1;
		while ( ( entinsphere = find_ent_in_sphere(entinsphere, origin, 64.0) ) )
		{
			static classname[32];
			entity_get_string(entinsphere, EV_SZ_classname, classname, charsmax(classname));
			
			if ( 1 <= entinsphere <= g_max_players && get_bit(g_alive, entinsphere)
			|| equal(classname, "grenade") )
			{
				ent_near = true;
				break;
			}
		}
		
		if ( ent_near )
		{
			if ( !entity_get_int(iEntity, EV_INT_iuser2) )
			{
				entity_set_int(iEntity, EV_INT_solid, SOLID_NOT);
			}
		}
		else
		{
			entity_set_int(iEntity, EV_INT_solid, SOLID_BBOX);
		}
	}
}

public client_PostThink(id)
{
	if ( !get_bit(g_alive, id) ) return PLUGIN_CONTINUE;
	
	if ( get_bit(g_no_fall_damage, id) )
	{
		entity_set_int(id,  EV_INT_watertype, -3);
		clear_bit(g_no_fall_damage, id);
	}
	
	return PLUGIN_CONTINUE;
}

ActionMuza(id, ent)   
{
if (halflife_time() >= gfMuzaTimeOut[id])
{
new Float:fTime = halflife_time();   
new Float:flPropertie1, Float:flPropertie2;

pev( ent, pev_fuser1, flPropertie1 );
pev( ent, pev_fuser2, flPropertie2 );

new Float:fTimeout = get_cvar_float("bm_muzatime");

gfMuzaTimeOut[id] = fTime + fTimeout;
gfMuzaNextUse[id] = fTime + fTimeout + get_cvar_float("bm_muzacooldown");
{
  switch(random_num(0,10))
  {
    case 0:
        emit_sound(id, CHAN_STREAM, gsz1, 0.8, ATTN_NORM, 0, PITCH_NORM);
    case 1:
        emit_sound(id, CHAN_STREAM, gsz2, 0.8, ATTN_NORM, 0, PITCH_NORM);
    case 2:
        emit_sound(id, CHAN_STREAM, gsz3, 0.8, ATTN_NORM, 0, PITCH_NORM);
    case 3:
        emit_sound(id, CHAN_STREAM, gsz4, 0.8, ATTN_NORM, 0, PITCH_NORM);
    case 4:
        emit_sound(id, CHAN_STREAM, gsz5, 0.8, ATTN_NORM, 0, PITCH_NORM);
    case 5:
        emit_sound(id, CHAN_STREAM, gsz6, 0.8, ATTN_NORM, 0, PITCH_NORM);
    case 6:
        emit_sound(id, CHAN_STREAM, gsz7, 0.8, ATTN_NORM, 0, PITCH_NORM);
    case 7:
        emit_sound(id, CHAN_STREAM, gsz8, 0.8, ATTN_NORM, 0, PITCH_NORM);
    case 8:
        emit_sound(id, CHAN_STREAM, gsz9, 0.8, ATTN_NORM, 0, PITCH_NORM);
    case 9:
        emit_sound(id, CHAN_STREAM, gsz10, 0.8, ATTN_NORM, 0, PITCH_NORM);
    case 10:
        emit_sound(id, CHAN_STREAM, gsz11, 0.8, ATTN_NORM, 0, PITCH_NORM);
    }
}
}
}

ActionQuake(id){
    if(is_user_alive(id)){
        new g_msgScreenDrug=get_user_msgid("ScreenShake");
        message_begin(MSG_ONE,g_msgScreenDrug, {0,0,0},id);
        write_short(255<<14);
        write_short(10<<14);
        write_short(255<<14);
        message_end();
    }
}

ActionLight(id)
{
    new origin[3];
    get_user_origin(id, origin);
                            
    message_begin(MSG_BROADCAST,SVC_TEMPENTITY,origin);
    
    if ( get_user_team ( id ) == 1 ) {              
     	  write_byte(TE_DLIGHT);
    	  write_coord(origin[0]);
    	  write_coord(origin[1]); 
    	  write_coord(origin[2]);  
    	  write_byte(50);
    	  write_byte(255);
    	  write_byte(0);
    	  write_byte(0);
    	  write_byte(255);
    	  write_byte(50); 
    	  message_end();
    }
    if ( get_user_team ( id ) == 2 ) {
          write_byte(TE_DLIGHT);
    	  write_coord(origin[0]);
    	  write_coord(origin[1]); 
    	  write_coord(origin[2]);  
    	  write_byte(50);
    	  write_byte(0);
    	  write_byte(0);
    	  write_byte(255);
    	  write_byte(255);
    	  write_byte(50); 
    	  message_end();
    }
    if ( get_user_team ( id ) == 3 ) {
	  write_byte(TE_DLIGHT);
    	  write_coord(origin[0]);
    	  write_coord(origin[1]); 
    	  write_coord(origin[2]);  
    	  write_byte(50);
    	  write_byte(69);
    	  write_byte(69);
    	  write_byte(69);
    	  write_byte(255);
    	  write_byte(50); 
    	  message_end();
    }
}

ActionBhop(iEntity)
{
	if ( task_exists(TASK_SOLIDNOT + iEntity)
	|| task_exists(TASK_SOLID + iEntity) ) return PLUGIN_HANDLED;
	
	set_task(0.1, "TaskSolidNot", TASK_SOLIDNOT + iEntity);
	
	return PLUGIN_HANDLED;
}

ActionM4a1(id, iEntity)
{
if (is_user_alive(id) && !M4a1Used[id] && get_user_team(id) == 1)
{
static property[5];
GetProperty(iEntity, 1, property);
give_item(id, "weapon_m4a1");
cs_set_weapon_ammo(find_ent_by_owner(1, "weapon_m4a1", id), 1);
M4a1Used[id] = true;
message_begin(MSG_ONE, gmsgScreenFade, {0,0,0}, id);
write_short(4096*1);    // Duration
write_short(4096*1);    // Hold time
write_short(4096);    // Fade type
write_byte(148);        // Red
write_byte(100);        // Green
write_byte(211);        // Blue
write_byte(100);    // Alpha
message_end();   
new name[42];
get_user_name(id, name, 32);
set_hudmessage(255, 105, 180, -1.0, 0.10, 1, 6.0, 12.0, 0.0, 1.0, 6);
show_hudmessage(id, "OMG! %s has picked up a M4A1! ^nWith 1 bullet..", name);
BCM_Print(0, "^1%s^3 has picked up an^4 M4A1 ^1with^3 1 bullet!", name);
}

else
{
set_hudmessage(255, 51, 0, -1.0, 0.35, 0, 6.0, 2.0, 1.0, 1.0);
show_hudmessage(id, "Next Use: Next Round");
}

if (is_user_alive(id) && get_user_team(id) == 2)
{
set_hudmessage(255, 105, 180, -1.0, 0.50, 1, 6.0, 12.0, 0.0, 1.0, 8);
show_hudmessage(id, "This block is for Terrorists Only !");
message_begin(MSG_ONE, gmsgScreenFade, {0,0,0}, id);
write_short(4096*1);    // Duration
write_short(4096*1);    // Hold time
write_short(4096);    // Fade type
write_byte(148);        // Red
write_byte(100);        // Green
write_byte(211);        // Blue
write_byte(100);    // Alpha
message_end();  
}
return PLUGIN_HANDLED;
}

ActionM3(id, iEntity)
{
if (is_user_alive(id) && !M3Used[id] && get_user_team(id) == 1)
{
static property[5];
GetProperty(iEntity, 1, property);
give_item(id, "weapon_m3");
cs_set_weapon_ammo(find_ent_by_owner(1, "weapon_m3", id), 1);
M3Used[id] = true;
message_begin(MSG_ONE, gmsgScreenFade, {0,0,0}, id);
write_short(4096*1);    // Duration
write_short(4096*1);    // Hold time
write_short(4096);    // Fade type
write_byte(148);        // Red
write_byte(100);        // Green
write_byte(211);        // Blue
write_byte(100);    // Alpha
message_end();   
new name[42];
get_user_name(id, name, 32);
set_hudmessage(255, 250, 205, -1.0, 0.10, 1, 6.0, 12.0, 0.0, 1.0, 6);
show_hudmessage(id, "OMG! %s found the Shotgun! ^nWith 1 bullet..", name);
BCM_Print(0, "^1%s^3 has picked up an^4 Shotgun ^1with^3 1 bullet!", name);
}

else
{
set_hudmessage(255, 51, 0, -1.0, 0.35, 0, 6.0, 2.0, 1.0, 1.0);
show_hudmessage(id, "Next Use: Next Round");
}

if (is_user_alive(id) && get_user_team(id) == 2)
{
set_hudmessage(255, 250, 205, -1.0, 0.50, 1, 6.0, 12.0, 0.0, 1.0, 8);
show_hudmessage(id, "This block is for Terrorists Only !");
message_begin(MSG_ONE, gmsgScreenFade, {0,0,0}, id);
write_short(4096*1);    // Duration
write_short(4096*1);    // Hold time
write_short(4096);    // Fade type
write_byte(148);        // Red
write_byte(100);        // Green
write_byte(211);        // Blue
write_byte(100);    // Alpha
message_end();  
}
return PLUGIN_HANDLED;
}

ActionAwp(id, iEntity)
{

if (is_user_alive(id) && !AwpUsed[id] && get_user_team(id) == 1)
{
static property[5];
GetProperty(iEntity, 1, property);
give_item(id, "weapon_awp");
cs_set_weapon_ammo(find_ent_by_owner(1, "weapon_awp", id), 1);
AwpUsed[id] = true;
message_begin(MSG_ONE, gmsgScreenFade, {0,0,0}, id);
write_short(4096*1);    // Duration
write_short(4096*1);    // Hold time
write_short(4096);    // Fade type
write_byte(148);        // Red
write_byte(100);        // Green
write_byte(211);        // Blue
write_byte(100);    // Alpha
message_end();  
new name[42];
get_user_name(id, name, 32);
set_hudmessage(0, 255, 0, -1.0, 0.10, 1, 6.0, 12.0, 0.0, 1.0, 6);
show_hudmessage(id, "OMFG! %s has picked up an AWP! ^nWith 1 bullet..", name);
BCM_Print(0, "^1%s^3 has picked up an^4 AWP ^1with^3 1 bullet!", name);
}

else
{
set_hudmessage(0, 255, 0, -1.0, 0.35, 0, 6.0, 2.0, 1.0, 1.0);
show_hudmessage(id, "Next Use: Next Round");
}

if (is_user_alive(id) && get_user_team(id) == 2)
{
set_hudmessage(0, 255, 0, -1.0, 0.50, 1, 6.0, 12.0, 0.0, 1.0, 8);
show_hudmessage(id, "This block is for Terrorists Only !");
message_begin(MSG_ONE, gmsgScreenFade, {0,0,0}, id);
write_short(4096*1);    // Duration
write_short(4096*1);    // Hold time
write_short(4096);    // Fade type
write_byte(148);        // Red
write_byte(100);        // Green
write_byte(211);        // Blue
write_byte(100);    // Alpha
message_end();  
}
return PLUGIN_HANDLED;
}

ActionDeagle(id, iEntity)
{

if (is_user_alive(id) && !DeagleUsed[id] && get_user_team(id) == 1)
{
static property[5];
GetProperty(iEntity, 1, property);
give_item(id, "weapon_deagle");
cs_set_weapon_ammo(find_ent_by_owner(1, "weapon_deagle", id), 1);
DeagleUsed[id] = true;
message_begin(MSG_ONE, gmsgScreenFade, {0,0,0}, id);
write_short(4096*1);    // Duration
write_short(4096*1);    // Hold time
write_short(4096);    // Fade type
write_byte(148);        // Red
write_byte(100);        // Green
write_byte(211);        // Blue
write_byte(100);    // Alpha
message_end();   
new name[42];
get_user_name(id, name, 32);
set_hudmessage(255, 215, 0, -1.0, 0.10, 1, 6.0, 12.0, 0.0, 1.0, 6);
show_hudmessage(id, "OMG! %s has picked up an Deagle! ^nWith 1 bullet..", name);
BCM_Print(0, "^1%s^3 has picked up an^4 Deagle ^1with^3 1 bullet!", name);
}

else
{
set_hudmessage(255, 51, 0, -1.0, 0.35, 0, 6.0, 2.0, 1.0, 1.0);
show_hudmessage(id, "Next Use: Next Round");
}

if (is_user_alive(id) && get_user_team(id) == 2)
{
set_hudmessage(255, 215, 0, -1.0, 0.50, 1, 6.0, 12.0, 0.0, 1.0, 8);
show_hudmessage(id, "This block is for Terrorists Only !");
message_begin(MSG_ONE, gmsgScreenFade, {0,0,0}, id);
write_short(4096*1);    // Duration
write_short(4096*1);    // Hold time
write_short(4096);    // Fade type
write_byte(148);        // Red
write_byte(100);        // Green
write_byte(211);        // Blue
write_byte(100);    // Alpha
message_end();  
}
return PLUGIN_HANDLED;
}

ActionUsp(id, iEntity)
{
if (is_user_alive(id) && !UspUsed[id] && get_user_team(id) == 1)
{
static property[5];
GetProperty(iEntity, 1, property);
give_item(id, "weapon_usp");
cs_set_weapon_ammo(find_ent_by_owner(1, "weapon_usp", id), 1);
UspUsed[id] = true;
message_begin(MSG_ONE, gmsgScreenFade, {0,0,0}, id);
write_short(4096*1);    // Duration
write_short(4096*1);    // Hold time
write_short(4096);    // Fade type
write_byte(148);        // Red
write_byte(100);        // Green
write_byte(211);        // Blue
write_byte(100);    // Alpha
message_end();   
new name[42];
get_user_name(id, name, 32);
set_hudmessage(255, 0, 0, -1.0, 0.10, 1, 6.0, 12.0, 0.0, 1.0, 6);
show_hudmessage(id, "OMG! %s has picked up a USP! ^nWith 1 bullet..", name);
BCM_Print(0, "^1%s^3 has picked up an^4 USP ^1with^3 1 bullet!", name);
}

else
{
set_hudmessage(255, 51, 0, -1.0, 0.35, 0, 6.0, 2.0, 1.0, 1.0);
show_hudmessage(id, "Next Use: Next Round");
}

if (is_user_alive(id) && get_user_team(id) == 2)
{
set_hudmessage(255, 0, 0, -1.0, 0.50, 1, 6.0, 12.0, 0.0, 1.0, 8);
show_hudmessage(id, "This block is for Terrorists Only !");
message_begin(MSG_ONE, gmsgScreenFade, {0,0,0}, id);
write_short(4096*1);    // Duration
write_short(4096*1);    // Hold time
write_short(4096);    // Fade type
write_byte(148);        // Red
write_byte(100);        // Green
write_byte(211);        // Blue
write_byte(100);    // Alpha
message_end();  
}
return PLUGIN_HANDLED;
}  

ActionGlock(id, iEntity)
{
if (is_user_alive(id) && !GlockUsed[id] && get_user_team(id) == 1)
{
static property[5];
GetProperty(iEntity, 1, property);
give_item(id, "weapon_glock18");
cs_set_weapon_ammo(find_ent_by_owner(3, "weapon_glock18", id), 2);
GlockUsed[id] = true;
message_begin(MSG_ONE, gmsgScreenFade, {0,0,0}, id);
write_short(4096*1);    // Duration
write_short(4096*1);    // Hold time
write_short(4096);    // Fade type
write_byte(148);        // Red
write_byte(100);        // Green
write_byte(211);        // Blue
write_byte(100);    // Alpha
message_end();  
new name[42];
get_user_name(id, name, 32);
set_hudmessage(72, 118, 255, -1.0, 0.10, 1, 6.0, 12.0, 0.0, 1.0, 6);
show_hudmessage(id, "%s has picked up a Glock! ^nWith 2 bullets..", name);
BCM_Print(0, "^1%s^3 has picked up an^4 Glock ^1with^3 2 bullets!", name);
}

else
{
set_hudmessage(200, 51, 200, -1.0, 0.35, 0, 6.0, 2.0, 1.0, 1.0);
show_hudmessage(id, "Next Use: Next Round");
}

if (is_user_alive(id) && get_user_team(id) == 2)
{
set_hudmessage(72, 118, 255, -1.0, 0.50, 1, 6.0, 12.0, 0.0, 1.0, 8);
show_hudmessage(id, "This block is for Terrorists Only !");
message_begin(MSG_ONE, gmsgScreenFade, {0,0,0}, id);
write_short(4096*1);    // Duration
write_short(4096*1);    // Hold time
write_short(4096);    // Fade type
write_byte(148);        // Red
write_byte(100);        // Green
write_byte(211);        // Blue
write_byte(100);    // Alpha
message_end();  
}
return PLUGIN_HANDLED;
}  

ActionAk47(id, iEntity)
{
if (is_user_alive(id) && !Ak47Used[id] && get_user_team(id) == 1)
{
static property[5];
GetProperty(iEntity, 1, property);
give_item(id, "weapon_ak47");
cs_set_weapon_ammo(find_ent_by_owner(1, "weapon_ak47", id), 1);
Ak47Used[id] = true;
message_begin(MSG_ONE, gmsgScreenFade, {0,0,0}, id);
write_short(4096*1);    // Duration
write_short(4096*1);    // Hold time
write_short(4096);    // Fade type
write_byte(148);        // Red
write_byte(100);        // Green
write_byte(211);        // Blue
write_byte(100);    // Alpha
message_end();  
new name[42];
get_user_name(id, name, 32);
set_hudmessage(238, 180, 34, -1.0, 0.10, 1, 6.0, 12.0, 0.0, 1.0, 6);
show_hudmessage(id, "OMG! %s has picked up an Ak47! ^nWith 1 bullet..", name);
BCM_Print(0, "^1%s^3 has picked up an^4 AK47 ^1with^3 1 bullet!", name);
}

else
{
set_hudmessage(200, 51, 0, -1.0, 0.35, 0, 6.0, 2.0, 1.0, 1.0);
show_hudmessage(id, "Next Use: Next Round");

}

if (is_user_alive(id) && get_user_team(id) == 2)
{
set_hudmessage(238, 180, 34, -1.0, 0.50, 1, 6.0, 12.0, 0.0, 1.0, 8);
show_hudmessage(id, "This block is for Terrorists Only !");
message_begin(MSG_ONE, gmsgScreenFade, {0,0,0}, id);
write_short(4096*1);    // Duration
write_short(4096*1);    // Hold time
write_short(4096);    // Fade type
write_byte(148);        // Red
write_byte(100);        // Green
write_byte(211);        // Blue
write_byte(100);    // Alpha
message_end();  
}
return PLUGIN_HANDLED;
}     

ActionDeath(id)	
{
	if (!get_user_godmode(id))
	{
		new szPlayerName[32];
		get_user_name(id, szPlayerName, 31);
		BCM_Print(0, "^1myxaha ^3%s^1 stepped ^4on the ^3Death^1.", szPlayerName);
		fakedamage(id, "the block of death", 10000.0, DMG_GENERIC);
		emit_sound(id, CHAN_STATIC, g_sound_death, 1.0, ATTN_NORM, 0, PITCH_NORM);
                {
                set_hudmessage(255, 0, 0, -1.0, 0.60, 1, 6.0, 12.0, 0.0, 1.0, 8);
                show_hudmessage(id, "You have been terminated..");
                message_begin(MSG_ONE, gmsgScreenFade, {0,0,0}, id);
                write_short(4096*2);    // Duration
                write_short(4096*2);    // Hold time
                write_short(4096);    // Fade type
                write_byte(0);        // Red
                write_byte(0);        // Green
                write_byte(0);        // Blue
                write_byte(200);    // Alpha
                message_end();
                }
	}
}

ActionDamage(id, iEntity)
{
new Float:gametime = get_gametime();
if ( !( gametime >= g_next_damage_time[id] )
|| get_user_health(id) <= 0
|| get_user_godmode(id) ) return PLUGIN_HANDLED;
message_begin(MSG_ONE, gmsgScreenFade, {0,0,0}, id);
write_short(4096*1);    // Duration
write_short(4096*1);    // Hold time
write_short(4096);    // Fade type
write_byte(150);        // Red
write_byte(0);        // Green
write_byte(0);        // Blue
write_byte(100);    // Alpha
message_end();  

static property[5];

GetProperty(iEntity, 1, property);
fakedamage(id, "Damage Block", str_to_float(property), DMG_CRUSH);

GetProperty(iEntity, 2, property);
g_next_damage_time[id] = gametime + str_to_float(property);

return PLUGIN_HANDLED;
}

ActionHeal(id, iEntity)
{
	new Float:gametime = get_gametime();
	
	static property[5];
	GetProperty(iEntity, 4, property);
	switch ( property[0] )
	{
		case '1':
		{
			if ( !( gametime >= g_next_heal_time[id] ) ) return PLUGIN_HANDLED;
	
			new hp = get_user_health(id);
		        
			if( hp >= 150 ) {
				g_next_heal_time[id] = gametime;         
				return PLUGIN_HANDLED;
                        }
			
			GetProperty(iEntity, 1, property);
			new Float:new_health = get_user_health(id) + str_to_float(property);
			
			if ( new_health < 150 )	entity_set_float(id, EV_FL_health, new_health);
			else			entity_set_float(id, EV_FL_health, 150.0);
			{
                        set_hudmessage(255, 51, 0, -1.0, 0.70, 1, 6.0, 12.0, 0.0, 1.0, 1);
                        show_hudmessage(id, "Recovering your life..");
                        }
			static Float:interval;
			GetProperty(iEntity, 2, property);
			interval = str_to_float(property);
			g_next_heal_time[id] = gametime + interval;
			
			return PLUGIN_HANDLED;
		}
		case '2':
		{
			if ( !( gametime >= g_next_heal_time[id] ) ) return PLUGIN_HANDLED;
	
			new armor = get_user_armor(id);
		  
			if( armor >= 100 ) {
				g_next_heal_time[id] = gametime;         
				return PLUGIN_HANDLED;
			}
			
			GetProperty(iEntity, 1, property);
			new Float:new_armor = get_user_armor(id) + str_to_float(property);
			
			if ( new_armor < 100 )	entity_set_float(id, EV_FL_armorvalue, new_armor);
			else			entity_set_float(id, EV_FL_armorvalue, 100.0);
			{
                        set_hudmessage(255, 51, 0, -1.0, 0.70, 1, 6.0, 12.0, 0.0, 1.0, 1);
                        show_hudmessage(id, "Recovering your Armor..");
                        }
			static Float:interval;
			GetProperty(iEntity, 2, property);
			interval = str_to_float(property);
			g_next_heal_time[id] = gametime + interval;
			
			return PLUGIN_HANDLED;
		}
		case '3':
		{
			if ( !( gametime >= g_next_heal_time[id] ) ) return PLUGIN_HANDLED;
	
			new hp = get_user_health(id);
			if( hp <= 150 ) {
				g_next_heal_time[id] = gametime;   
				GetProperty(iEntity, 1, property);
				new Float:new_health = get_user_health(id) + str_to_float(property);
				
				if ( new_health < 150 )	entity_set_float(id, EV_FL_health, new_health);
				else			entity_set_float(id, EV_FL_health, 150.0);
			
                        }
			
			new armor = get_user_armor(id);
			if( armor <= 100 ) {
				g_next_heal_time[id] = gametime;   
				GetProperty(iEntity, 1, property);
				new Float:new_armor = get_user_armor(id) + str_to_float(property);
				
				if ( new_armor < 100 )	entity_set_float(id, EV_FL_armorvalue, new_armor);
				else			entity_set_float(id, EV_FL_armorvalue, 100.0);

                        }
			static Float:interval;
			GetProperty(iEntity, 2, property);
			interval = str_to_float(property);
			g_next_heal_time[id] = gametime + interval;
                       
                        {
                        set_hudmessage(255, 51, 0, -1.0, 0.70, 1, 6.0, 12.0, 0.0, 1.0, 1);
                        show_hudmessage(id, "Recovering your Health / Armor..");
                        }
		}
		
	}
	return PLUGIN_HANDLED;
}

ActionIce(id, iEntity)
{
	if ( !get_bit(g_ice, id) )
	{
		static property[5];
		GetProperty(iEntity, 1, property);
		new Float:new_friction = str_to_float(property);
		if(new_friction >= 0.0)  
		{
			entity_set_float(id, EV_FL_friction, new_friction);
		
		} else {
			
			entity_set_float(id, EV_FL_friction, 0.15);
		}
		entity_set_float(id, EV_FL_maxspeed, 600.0);
		
		set_bit(g_ice, id);
	}
	
	new task_id = TASK_ICE + id;
	if ( task_exists(task_id) ) 
	{
		remove_task(task_id);
	}
	set_task(0.1, "TaskNotOnIce", task_id);
}

ActionTrampoline(id, iEntity)
{
	static property1[5];
	GetProperty(iEntity, 1, property1);
	
	entity_get_vector(id, EV_VEC_velocity, g_set_velocity[id]);
	
	g_set_velocity[id][2] = str_to_float(property1);
	
        emit_sound(id, CHAN_STATIC, g_sound_trampoline, 1.0, ATTN_NORM, 0, PITCH_NORM);
	entity_set_int(id, EV_INT_gaitsequence, 6);
	
	set_bit(g_no_fall_damage, id);
}

ActionSpeedBoost(id, iEntity)
{
	static property[5];
	
	GetProperty(iEntity, 1, property);
	velocity_by_aim(id, str_to_num(property), g_set_velocity[id]);
	
	GetProperty(iEntity, 2, property);
	g_set_velocity[id][2] = str_to_float(property);
	
	entity_set_int(id, EV_INT_gaitsequence, 6);
}

ActionLowGravity(id, iEntity)
{
	if ( get_bit(g_low_gravity, id) ) return PLUGIN_HANDLED;
	
	static property1[5];
	GetProperty(iEntity, 1, property1);
	
	entity_set_float(id, EV_FL_gravity, str_to_float(property1) / 800);
	
	set_bit(g_low_gravity, id);
	
	return PLUGIN_HANDLED;
}

ActionHoney(id, iEntity)
{
	if ( g_honey[id] != iEntity )
	{
		static property1[5];
		GetProperty(iEntity, 1, property1);
		
		new Float:speed = str_to_float(property1);
		entity_set_float(id, EV_FL_maxspeed, speed == 0 ? -1.0 : speed);
		{
                set_hudmessage(255, 51, 0, -1.0, 0.70, 1, 6.0, 12.0, 0.0, 1.0, 12);
                show_hudmessage(id, "You Are Slowing Down..");
                }
		g_honey[id] = iEntity;
	}
	
	new task_id = TASK_HONEY + id;
	if ( task_exists(task_id) )
	{
		remove_task(task_id);
	}
	else
	{
		static Float:velocity[3];
		entity_get_vector(id, EV_VEC_velocity, velocity);
		
		velocity[0] /= 2.0;
		velocity[1] /= 2.0;
		
		entity_set_vector(id, EV_VEC_velocity, velocity);
	}

	set_task(0.1, "TaskNotInHoney", task_id);
}

ActionCTBarrier(id, iEntity)
{
	static property[5];
	GetProperty(iEntity, 1, property);
	new CsTeams:playerTeam = cs_get_user_team(id);
	switch ( property[0] )
	{
		case '1'://Normal
		{
			if(playerTeam == CS_TEAM_CT)
			{
				return;
			}
			if(playerTeam == CS_TEAM_T)
			{
				TaskSolidNot(TASK_SOLIDNOT + iEntity);
			}
		}
		case '2': // Team admins only
		{
			if(playerTeam == CS_TEAM_CT )
			{
				return;
			}
			if(playerTeam == CS_TEAM_T && get_bit(g_admin, id) )
			{
				TaskSolidNot(TASK_SOLIDNOT + iEntity);
			}
		}
		case '3':
		{
			if(playerTeam == CS_TEAM_CT || playerTeam == CS_TEAM_T && get_bit(g_admin, id) )
			{
				TaskSolidNot(TASK_SOLIDNOT + iEntity);
			}
		}
	}
}

ActionTBarrier(id, iEntity)
{
	if ( task_exists(TASK_SOLIDNOT + iEntity)
	|| task_exists(TASK_SOLID + iEntity) ) return PLUGIN_HANDLED;
	
	if (get_user_flags(id) & ADMIN_RESERVATION) TaskSolidNot(TASK_SOLIDNOT + iEntity);
	
	return PLUGIN_HANDLED;
}

ActionNoSlowDown(id)
{
	set_bit(g_no_slow_down, id);
	
	new task_id = TASK_NOSLOWDOWN + id;
	if ( task_exists(task_id) ) remove_task(task_id);
	
	set_task(0.1, "TaskSlowDown", task_id);
}

ActionDelayedBhop(iEntity)
{
	if ( task_exists(TASK_SOLIDNOT + iEntity)
	|| task_exists(TASK_SOLID + iEntity) ) return PLUGIN_HANDLED;
	
	static property1[5];
	GetProperty(iEntity, 1, property1);
	
	set_task(str_to_float(property1), "TaskSolidNot", TASK_SOLIDNOT + iEntity);
	return PLUGIN_HANDLED;
}

ActionInvincibility(id, iEntity)
{
	new Float:gametime = get_gametime();
	if ( gametime >= g_invincibility_next_use[id] )
	{
		static property[5];
		
		entity_set_float(id, EV_FL_takedamage, DAMAGE_NO);
		
		if ( gametime >= g_stealth_time_out[id] )
		{
			set_user_rendering(id, kRenderFxGlowShell, 0, 51, 0, kRenderNormal, 16);
		}
		
		emit_sound(id, CHAN_STATIC, g_sound_invincibility, 1.0, ATTN_NORM, 0, PITCH_NORM);
		
		static Float:time_out;
		GetProperty(iEntity, 1, property);
		time_out = str_to_float(property);
		set_task(time_out, "TaskRemoveInvincibility", TASK_INVINCIBLE + id, "", 0, "a", 1);
		
		static Float:delay;
		GetProperty(iEntity, 2, property);
		delay = str_to_float(property);
		
		g_invincibility_time_out[id] = gametime + time_out;
		g_invincibility_next_use[id] = gametime + time_out + delay;
	}
	else if ( !get_bit(g_has_hud_text, id) )
	{
		set_hudmessage(255, 51, 0, -1.0, 0.80, 1, 6.0, 12.0, 0.0, 1.0, 8);
		show_hudmessage(id, "%s %s^nInvincibility^nNext Use %.1f", PLUGIN_PREFIX, PLUGIN_VERSION, g_invincibility_next_use[id] - gametime);
                message_begin(MSG_ONE, gmsgScreenFade, {0,0,0}, id);
                write_short(4096*1);    // Duration
                write_short(4096*1);    // Hold time
                write_short(4096);    // Fade type
                write_byte(148);        // Red
                write_byte(100);        // Green
                write_byte(211);        // Blue
                write_byte(100);    // Alpha
                message_end(); 
	}
}

ActionStealth(id, iEntity)
{
	new Float:gametime = get_gametime();
	if ( gametime >= g_stealth_next_use[id] )
	{
		static property[5];
		
		set_user_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderTransColor, 0);
		
		set_bit(g_block_status, id);
		
		emit_sound(id, CHAN_STATIC, g_sound_stealth, 1.0, ATTN_NORM, 0, PITCH_NORM);
		
		static Float:time_out;
		GetProperty(iEntity, 1, property);
		time_out = str_to_float(property);
		set_task(time_out, "TaskRemoveStealth", TASK_STEALTH + id, "", 0, "a", 1);
		
		static Float:delay;
		GetProperty(iEntity, 2, property);
		delay = str_to_float(property);
		
		g_stealth_time_out[id] = gametime + time_out;
		g_stealth_next_use[id] = gametime + time_out + delay;
	}
	else if ( !get_bit(g_has_hud_text, id) )
	{
		set_hudmessage(255, 51, 0, -1.0, 0.80, 1, 6.0, 12.0, 0.0, 1.0, 8);
		show_hudmessage(id, "%s %s^nStealth^nNext Use %.1f", PLUGIN_PREFIX, PLUGIN_VERSION, g_stealth_next_use[id] - gametime);
                message_begin(MSG_ONE, gmsgScreenFade, {0,0,0}, id);
                write_short(4096*1);    // Duration
                write_short(4096*1);    // Hold time
                write_short(4096);    // Fade type
                write_byte(148);        // Red
                write_byte(100);        // Green
                write_byte(211);        // Blue
                write_byte(100);    // Alpha
                message_end();  
	}
}

ActionBootsOfSpeed(id, iEntity)
{
	new Float:gametime = get_gametime();
	if ( !g_boots_of_speed[id] )
	{
		set_bit(g_bootsofspeed, id);
		static property[5];
		
		GetProperty(iEntity, 3, property);
		entity_set_float(id, EV_FL_maxspeed, str_to_float(property));
		
		g_boots_of_speed[id] = iEntity;
		
		emit_sound(id, CHAN_STATIC, g_sound_boots_of_speed, 1.0, ATTN_NORM, 0, PITCH_NORM);
		
		static Float:time_out;
		GetProperty(iEntity, 1, property);
		time_out = str_to_float(property);
		set_task(time_out, "TaskRemoveBootsOfSpeed", TASK_BOOTSOFSPEED + id, "", 0, "a", 1);
		
		static Float:delay;
		GetProperty(iEntity, 2, property);
		delay = str_to_float(property);
		
		g_boots_of_speed_time_out[id] = gametime + time_out;
		g_boots_of_speed_next_use[id] = gametime + time_out + delay;
	}
	else if ( !get_bit(g_has_hud_text, id) )
	{
		set_hudmessage(255, 51, 0, -1.0, 0.80, 1, 6.0, 12.0, 0.0, 1.0, 8);
		show_hudmessage(id, "%s %s^nBoots Of Speed^nNext Use %.1f", PLUGIN_PREFIX, PLUGIN_VERSION, g_boots_of_speed_next_use[id] - gametime);
                message_begin(MSG_ONE, gmsgScreenFade, {0,0,0}, id);
                write_short(4096*1);    // Duration
                write_short(4096*1);    // Hold time
                write_short(4096);    // Fade type
                write_byte(148);        // Red
                write_byte(100);        // Green
                write_byte(211);        // Blue
                write_byte(100);    // Alpha
                message_end(); 
	}

}

ActionWeaponBlock(id, iEntity)
{
	new CsTeams:playerTeam = cs_get_user_team(id);
	if(is_user_alive(id) && playerTeam == CS_TEAM_T)
	{
		static property[5];
		GetProperty(iEntity, 1, property);
		new szPlayerName[32];
		get_user_name(id, szPlayerName, 32);
		switch ( property[0] )
		{
			case '1':
			{
				if(!get_bit(g_awp_used, id) )
				{
					if( !user_has_weapon(id, CSW_AWP) )
					{
						give_item(id, "weapon_awp");
					}
					new weapon_id = find_ent_by_owner(-1, "weapon_awp", id);
					if(weapon_id)
					{
						GetProperty(iEntity, 2, property);
						cs_set_weapon_ammo(weapon_id, str_to_num(property));
					}
					cs_set_user_bpammo(id, CSW_AWP, 0);
					set_bit(g_awp_used, id);
					
					set_hudmessage(255, 0, 0, -1.0, 0.35, 0, 6.0, 10.0, 1.0, 1.0);
					BCM_Print(0, "^1%s ^3found the ^4AWP Gun ^3with %d bullet%s!", szPlayerName, str_to_num(property), str_to_num(property) == 1 ? "" : "s" );
				}
			}
			case '2':
			{
				if(!get_bit(g_deagle_used, id))
				{
					if( !user_has_weapon(id, CSW_DEAGLE) )
					{
						give_item(id, "weapon_deagle");
					}
					new weapon_id = find_ent_by_owner(-1, "weapon_deagle", id);
					if(weapon_id)
					{
						GetProperty(iEntity, 2, property);
						cs_set_weapon_ammo(weapon_id, str_to_num(property));
					}
					cs_set_user_bpammo(id, CSW_DEAGLE, 0);
					set_bit(g_deagle_used, id);
					
					set_hudmessage(0, 100, 200, -1.0, 0.35, 0, 6.0, 10.0, 1.0, 1.0);
					BCM_Print(0, "^1%s ^3found the ^4DEAGLE Gun ^3with %d bullet%s!", szPlayerName, str_to_num(property), str_to_num(property) == 1 ? "" : "s" );
				}
			}
			case '3':
			{
				if(!get_bit(g_usp_used, id))
				{
					if( !user_has_weapon(id, CSW_USP) )
					{
						give_item(id, "weapon_usp");
					}
					new weapon_id = find_ent_by_owner(-1, "weapon_usp", id);
					if(weapon_id)
					{
						GetProperty(iEntity, 2, property);
						cs_set_weapon_ammo(weapon_id, str_to_num(property));
					}
					cs_set_user_bpammo(id, CSW_USP, 0);
					set_bit(g_usp_used, id);
					
					set_hudmessage(255, 51, 0, -1.0, 0.35, 0, 6.0, 10.0, 1.0, 1.0);
					BCM_Print(0, "^1%s ^3found the ^4USP Gun ^3with %d bullet%s!", szPlayerName, str_to_num(property), str_to_num(property) == 1 ? "" : "s" );
				}
			}
			case '4':
			{
				if(!get_bit(g_tmp_used, id))
				{
					if( !user_has_weapon(id, CSW_TMP) )
					{
						give_item(id, "weapon_tmp");
					}
					new weapon_id = find_ent_by_owner(-1, "weapon_tmp", id);
					if(weapon_id)
					{
						GetProperty(iEntity, 2, property);
						cs_set_weapon_ammo(weapon_id, str_to_num(property));
					}
					cs_set_user_bpammo(id, CSW_TMP, 0);
					set_bit(g_tmp_used, id);
					
					set_hudmessage(255, 51, 0, -1.0, 0.35, 0, 6.0, 10.0, 1.0, 1.0);
					BCM_Print(0, "^1%s ^3found the ^4TMP Gun ^3with %d bullets%s!", szPlayerName, str_to_num(property), str_to_num(property) == 1 ? "" : "s" );
				}
			}
			case '5':
			{
				if(!get_bit(g_aug_used, id))
				{
					if( !user_has_weapon(id, CSW_AUG) )
					{
						give_item(id, "weapon_aug");
					}
					new weapon_id = find_ent_by_owner(-1, "weapon_aug", id);
					if(weapon_id)
					{
						GetProperty(iEntity, 2, property);
						cs_set_weapon_ammo(weapon_id, str_to_num(property));
					}
					cs_set_user_bpammo(id, CSW_AUG, 0);
					set_bit(g_aug_used, id);
					
					set_hudmessage(255, 51, 0, -1.0, 0.35, 0, 6.0, 10.0, 1.0, 1.0);
					BCM_Print(0, "^1%s ^3found the ^4Aug Gun ^3with %d bullet%s!", szPlayerName, str_to_num(property), str_to_num(property) == 1 ? "" : "s" );
				}
			}
			case '6':
			{
				if(!get_bit(g_m3_used, id))
				{
					if( !user_has_weapon(id, CSW_M3) )
					{
						give_item(id, "weapon_m3");
					}
					new weapon_id = find_ent_by_owner(-1, "weapon_m3", id);
					if(weapon_id)
					{
						GetProperty(iEntity, 2, property);
						cs_set_weapon_ammo(weapon_id, str_to_num(property));
					}
					cs_set_user_bpammo(id, CSW_M3, 0);
					set_bit(g_m3_used, id);
					
					set_hudmessage(0, 255, 0, -1.0, 0.35, 0, 6.0, 10.0, 1.0, 1.0);
					BCM_Print(0, "^1%s ^3found the ^4SHOTGUN ^3with %d bullet%s!", szPlayerName, str_to_num(property), str_to_num(property) == 1 ? "" : "s" );
				}
			}
			case '7':
			{
				if(!get_bit(g_mac10_used, id))
				{
					if( !user_has_weapon(id, CSW_MAC10) )
					{
						give_item(id, "weapon_mac10");
					}
					new weapon_id = find_ent_by_owner(-1, "weapon_mac10", id);
					if(weapon_id)
					{
						GetProperty(iEntity, 2, property);
						cs_set_weapon_ammo(weapon_id, str_to_num(property));
					}
					cs_set_user_bpammo(id, CSW_MAC10, 0);
					set_bit(g_mac10_used, id);
					
					set_hudmessage(255, 51, 0, -1.0, 0.35, 0, 6.0, 10.0, 1.0, 1.0);
					BCM_Print(0, "^1%s ^3found the ^4MAC10 Gun ^3with %d bullet%s!", szPlayerName, str_to_num(property), str_to_num(property) == 1 ? "" : "s" );
				}
			}
			case '8':
			{
				if(!get_bit(g_ak47_used, id))
				{
					if( !user_has_weapon(id, CSW_AK47) )
					{
						give_item(id, "weapon_ak47");
					}
					new weapon_id = find_ent_by_owner(-1, "weapon_ak47", id);
					if(weapon_id)
					{
						GetProperty(iEntity, 2, property);
						cs_set_weapon_ammo(weapon_id, str_to_num(property));
					}
					cs_set_user_bpammo(id, CSW_AK47, 0);
					set_bit(g_ak47_used, id);
					
					set_hudmessage(255, 51, 0, -1.0, 0.35, 0, 6.0, 10.0, 1.0, 1.0);
					BCM_Print(0, "^1%s ^3found the ^4AK47 Gun ^3with %d bullet%s!", szPlayerName, str_to_num(property), str_to_num(property) == 1 ? "" : "s" );
				}
			}
			case '9':
			{
				if(!get_bit(g_c4_used, id))
				{
					if( !user_has_weapon(id, CSW_FAMAS) )
					{
						give_item(id, "weapon_famas");
					}
					new weapon_id = find_ent_by_owner(-1, "weapon_famas", id);
					if(weapon_id)
					{
						GetProperty(iEntity, 2, property);
						cs_set_weapon_ammo(weapon_id, str_to_num(property));
					}
					cs_set_user_bpammo(id, CSW_FAMAS, 0);
					set_bit(g_c4_used, id);
					
					set_hudmessage(255, 51, 0, -1.0, 0.35, 0, 6.0, 10.0, 1.0, 1.0);
					BCM_Print(0, "^1%s ^3found the ^4FAMAS Gun ^3with %d bullet%s!", szPlayerName, str_to_num(property), str_to_num(property) == 1 ? "" : "s" );
				}
			}
		}
	}
	else if ( !get_bit(g_has_hud_text, id) )
	{
		set_hudmessage(255, 51, 0, -1.0, 0.35, 0, 6.0, 2.0, 1.0, 1.0);
		show_hudmessage(id, "Gun next use: Next Round");
	}	
}

ActionDuckBlock(id)
{
	set_pev(id, pev_bInDuck, 1);
}

ActionXp(id, ent)
{
	new Float:gametime = get_gametime();
	if ( !( gametime >= g_next_xp_time[id] ) )
	{
	
	return PLUGIN_HANDLED;
	}
	
	static property[5];
	GetProperty(ent, 1, property);
	
	if (cs_get_user_team(id) == CS_TEAM_CT)
	{
	set_hudmessage(255, 51, 0, -1.0, 0.50, 1, 6.0, 12.0, 0.0, 1.0, 8);
	show_hudmessage(id, "This Block is for Terrorists Only");
	}
	
	if (cs_get_user_team(id) == CS_TEAM_T && !XpUsed[id])
	{
	new xp = str_to_num(property);
	hnsxp_add_user_xp( id, xp );
	new name[42];
        get_user_name(id, name, 32);
	message_begin(MSG_ONE, gmsgScreenFade, {0,0,0}, id);
        write_short(4096*1);    // Duration
        write_short(4096*1);    // Hold time
        write_short(4096);    // Fade type
        write_byte(148);        // Red
        write_byte(100);        // Green
        write_byte(211);        // Blue
        write_byte(100);    // Alpha
        message_end();  
        BCM_Print(id, "^3You have Gained^4 %s^3 Xp!", property);
	emit_sound(id, CHAN_STATIC, g_sound_xpblock, 1.0, ATTN_NORM, 0, PITCH_NORM);
        }
	
	
        GetProperty(ent, 2, property);
	g_next_xp_time[id] = gametime + str_to_float(property);
	
	return PLUGIN_HANDLED;
}

ActionBlindTrap(id, iEntity)
{
	static color_red[5], color_green[5], color_blue[5], color_alpha[5];
	
	new Float:gametime = get_gametime();
	if ( gametime >= g_blind_next_use[id] )
	{	
		static Float:delay;
		delay = 3.0;
		g_blind_next_use[id] = gametime + delay;
		
		GetProperty(iEntity, 1, color_red);
		GetProperty(iEntity, 2, color_green);
		GetProperty(iEntity, 3, color_blue);
		GetProperty(iEntity, 4, color_alpha);

		message_begin(MSG_ONE, gmsgScreenFade, {0,0,0}, id);
		write_short(4096*3);    // Duration
		write_short(4096*3);    // Hold time
		write_short(4096);    // Fade type
		write_byte(str_to_num(color_red));
		write_byte(str_to_num(color_green));
		write_byte(str_to_num(color_blue));
		write_byte(str_to_num(color_alpha));    // Alpha
		message_end();
	}
}

ActionSuperman(id, iEntity)
{
	new Float:gametime = get_gametime();
	if ( gametime >= g_superman_next_use[id] )
	{	
		static property[5];

		set_user_gravity(id, 0.50);
		
		set_bit(g_block_status, id);

		static Float:time_out;
		GetProperty(iEntity, 1, property);
		time_out = str_to_float(property);
		set_task(time_out, "TaskRemoveSuperman", TASK_SUPERMAN + id, g_blank, 0, "a", 1);
	
		static Float:delay;
		GetProperty(iEntity, 2, property);
		delay = str_to_float(property);
		
		g_superman_time_out[id] = gametime + time_out;
		g_superman_next_use[id] = gametime + time_out + delay;
		emit_sound(id, CHAN_STATIC, g_sound_supermario, 0.3, ATTN_NORM, 0, PITCH_NORM);
	}
	else if ( !get_bit(g_has_hud_text, id) )
	{
		set_hudmessage(255, 51, 0, -1.0, 0.80, 1, 6.0, 12.0, 0.0, 1.0, 8);
		show_hudmessage(id, "%s %s^nSuperman^nNext Use %.1f", PLUGIN_PREFIX, PLUGIN_VERSION, g_superman_next_use[id] - gametime);
                message_begin(MSG_ONE, gmsgScreenFade, {0,0,0}, id);
                write_short(4096*1);    // Duration
                write_short(4096*1);    // Hold time
                write_short(4096);    // Fade type
                write_byte(0);        // Red
                write_byte(200);        // Green
                write_byte(150);        // Blue
                write_byte(0);    // Alpha
                message_end(); 
	}
}

ActionMoney(id, iEntity)
{
	if (is_user_alive(id) && !get_bit(g_money_used, id))
	{
		static property[5];
		GetProperty(iEntity, 1, property);
		cs_set_user_money(id, cs_get_user_money (id) + str_to_num(property));
		set_bit(g_money_used, id);
		BCM_Print(id, "^1You just got ^3$^3%i ! ^4Now you can buy something from the shop.", str_to_num(property));// ^4=Green ^3=Silver ^1=Normal
		emit_sound(id, CHAN_STATIC, g_sound_money, 1.0, ATTN_NORM, 0, PITCH_NORM);
	}
	else if ( !get_bit(g_has_hud_text, id) )
	{
		set_hudmessage(255, 51, 0, -1.0, 0.05, 0, 0.0, 1.0, 0.25, 0.25, 8);
		show_hudmessage(id, "Money Usage: One per round!");
	}
}

ActionDeathBounce(id)
{
	if (!get_user_godmode(id))
	{
		new szPlayerName[32];
		get_user_name(id, szPlayerName, 31);
		BCM_Print(0, "^3%s^1 has being ^4CRUSHED from the ^3BouncingDeath^1.", szPlayerName);
		fakedamage(id, "the block of death", 10000.0, DMG_GENERIC);
		emit_sound(id, CHAN_STATIC, g_sound_death_bounce, 1.0, ATTN_NORM, 0, PITCH_NORM);
	        {
                set_hudmessage(255, 0, 0, -1.0, 0.70, 1, 6.0, 12.0, 0.0, 1.0, 8);
                show_hudmessage(id, "You Failed !!!");
                message_begin(MSG_ONE, gmsgScreenFade, {0,0,0}, id);
                write_short(4096*1);    // Duration
                write_short(4096*1);    // Hold time
                write_short(4096);    // Fade type
                write_byte(0);        // Red
                write_byte(0);        // Green
                write_byte(0);        // Blue
                write_byte(200);    // Alpha
                message_end(); 
                }
        }
}

public bounce_death(iEntity)
{
	if ( IsBlock(iEntity) )
	{
		new block_type = entity_get_int(iEntity, EV_INT_body);
		if(pev_valid(iEntity) && block_type == BOUNCE_DEATH)
		{
			
			static property[5];
			GetProperty(iEntity, 1, property);
			if(pev(iEntity, pev_flags)&FL_ONGROUND)
			{
				new Float:velocity[3];
				velocity[2] = str_to_float(property);
				set_pev(iEntity, pev_velocity, velocity);
			}
                        set_task(0.1, "bounce_death", iEntity);
		}
	}
}

ActionTeleport(id, iEntity)
{
	new tele = entity_get_int(iEntity, EV_INT_iuser1);
	if ( !tele ) return PLUGIN_HANDLED;
	
	static Float:tele_origin[3];
	entity_get_vector(tele, EV_VEC_origin, tele_origin);
	
	new player = -1;
	do
	{
		player = find_ent_in_sphere(player, tele_origin, 16.0);
		
		if ( !is_user_alive(player)
		|| player == id
		|| cs_get_user_team(id) == cs_get_user_team(player) ) continue;
		
		user_kill(player, 1);
	}
	while ( player );
	
	entity_set_vector(id, EV_VEC_origin, tele_origin);

	static Float:velocity[3];
	entity_get_vector(id, EV_VEC_velocity, velocity);
	velocity[2] = floatabs(velocity[2]);
	entity_set_vector(id, EV_VEC_velocity, velocity);
	emit_sound(id, CHAN_STATIC, g_sound_teleports, 1.0, ATTN_NORM, 0, PITCH_NORM);
	
	return PLUGIN_HANDLED;
}

ActionTeleportBlock(id, iEntity)
{	
	set_bit(g_no_fall_damage, id);	
	g_teleport_block_start[id] = iEntity;
	new tele = entity_get_int(iEntity, EV_INT_iuser4);
	if ( !tele ) return PLUGIN_HANDLED;
	
	static Float:tele_origin[3];
	entity_get_vector(tele, EV_VEC_origin, tele_origin);
	tele_origin[2] += 48.0;
	new player = -1;
	do
	{
		player = find_ent_in_sphere(player, tele_origin, 16.0);
		
		if ( !is_user_alive(player)
		|| player == id
		|| cs_get_user_team(id) == cs_get_user_team(player) ) continue;
		
		user_kill(player, 1);
	}
	while ( player );
	
	entity_set_vector(id, EV_VEC_origin, tele_origin);

	emit_sound(id, CHAN_STATIC, g_sound_teleport, 1.0, ATTN_NORM, 0, PITCH_NORM);

	return PLUGIN_HANDLED;
}

ActionMagicCarpet(id, iEntity)
{
	static property[5];
	new Float:vVelocity[3]; 
	
	GetProperty(iEntity, 1, property);
	switch ( property[0] )
	{
		case '1':
		{
			if( get_user_team(id) == 1 ) {
				pev( id, pev_velocity, vVelocity ); 
				vVelocity[2] = 0.0; 
				set_pev( iEntity, pev_velocity, vVelocity ); 
				entity_set_int(iEntity, EV_INT_movetype, MOVETYPE_FLY);
				GetProperty(iEntity, 2, property);
				new task_id = TASK_MOVEBACK + iEntity;
				if ( !task_exists(task_id) )
					set_task(str_to_float(property), "TaskMoveBack", TASK_MOVEBACK + iEntity);
			}
		}
		case '2':
		{
			if( get_user_team(id) == 2 ) {
				pev( id, pev_velocity, vVelocity ); 
				vVelocity[2] = 0.0; 
				set_pev( iEntity, pev_velocity, vVelocity ); 
				entity_set_int(iEntity, EV_INT_movetype, MOVETYPE_FLY);
				GetProperty(iEntity, 2, property);
				new task_id = TASK_MOVEBACK + iEntity;
				if ( !task_exists(task_id) )
					set_task(str_to_float(property), "TaskMoveBack", TASK_MOVEBACK + iEntity);
			}
		}
		case '3':
		{
			pev( id, pev_velocity, vVelocity ); 
			vVelocity[2] = 0.0; 
			set_pev( iEntity, pev_velocity, vVelocity ); 
			entity_set_int(iEntity, EV_INT_movetype, MOVETYPE_FLY);
			GetProperty(iEntity, 2, property);
			new task_id = TASK_MOVEBACK + iEntity;
			if ( !task_exists(task_id) )
				set_task(str_to_float(property), "TaskMoveBack", TASK_MOVEBACK + iEntity);
		}
		case '4':
		{
			// platfrom
			//entity_set_int(iEntity, EV_INT_solid, SOLID_BBOX);
		}
	}
	
}
ActionHe(id, ent)
{
        if (HeUsed[id])
        {
        set_hudmessage(255, 51, 0, -1.0, 0.35, 0, 6.0, 2.0, 1.0, 1.0);
        show_hudmessage(id, "You taked He , careful its not a toy..");
        }
        else if (user_has_weapon( id, CSW_HEGRENADE ))
        {
        set_hudmessage(255, 51, 0, -1.0, 0.35, 0, 6.0, 2.0, 1.0, 1.0);
        show_hudmessage(id, "Throw your He to take another..");
        }
        else if (get_user_team(id) == 1 && !HeUsed[id] && !user_has_weapon( id, CSW_HEGRENADE ))
        {
        static property[5];
        GetProperty(ent, 1, property);
        give_item(id, "weapon_hegrenade");
        HeUsed[id] = true;
        }
       
        if (is_user_alive(id) && get_user_team(id) == 2)
        {
        set_hudmessage(255, 51, 0, -1.0, 0.35, 0, 6.0, 2.0, 1.0, 1.0);
        show_hudmessage(id, "This block is for Terrorists Only !");
        }
        return PLUGIN_HANDLED;
}
ActionFlash(id, ent)
{
        if (FlashUsed[id])
        {
        set_hudmessage(255, 51, 0, -1.0, 0.35, 0, 6.0, 2.0, 1.0, 1.0);
        show_hudmessage(id, "You taked Flash , careful its not a toy..");
        }
        else if (user_has_weapon( id, CSW_FLASHBANG ))
        {
        set_hudmessage(255, 51, 0, -1.0, 0.35, 0, 6.0, 2.0, 1.0, 1.0);
        show_hudmessage(id, "Throw your Flash to take another..");
        }
       
        if(cs_get_user_bpammo(id, CSW_FLASHBANG) < 2 && !FlashUsed[id] && get_user_team(id) == 1)
        {
        static property[5];
        GetProperty(ent, 1, property);
        give_item(id, "weapon_flashbang");
        FlashUsed[id] = true;
        }
       
        if (is_user_alive(id) && get_user_team(id) == 2)
        {
        set_hudmessage(255, 51, 0, -1.0, 0.35, 0, 6.0, 2.0, 1.0, 1.0);
        show_hudmessage(id, "This block is for Terrorists Only !");
        }
        return PLUGIN_HANDLED;
}
ActionSmoke(id, ent)
{
        if (SmokeUsed[id])
        {
        set_hudmessage(255, 51, 0, -1.0, 0.35, 0, 6.0, 2.0, 1.0, 1.0);
        show_hudmessage(id, "You taked Frost , careful its not a toy..");
        }
        else if (user_has_weapon( id, CSW_SMOKEGRENADE ))
        {
        set_hudmessage(255, 51, 0, -1.0, 0.35, 0, 6.0, 2.0, 1.0, 1.0);
        show_hudmessage(id, "Throw your Frost to take another..");
        }
       
        else if (get_user_team(id) == 1 && !SmokeUsed[id] && !user_has_weapon( id, CSW_SMOKEGRENADE ))
        {
        static property[5];
        GetProperty(ent, 1, property);
        give_item(id, "weapon_smokegrenade");
        SmokeUsed[id] = true;
        }
       
        if (is_user_alive(id) && get_user_team(id) == 2)
        {
        set_hudmessage(255, 51, 0, -1.0, 0.35, 0, 6.0, 2.0, 1.0, 1.0);
        show_hudmessage(id, "This block is for Terrorists Only !");
        }
        return PLUGIN_HANDLED;
}
 

public TaskSolidNot(iEntity)
{
	iEntity -= TASK_SOLIDNOT;
	
	if ( !is_valid_ent(iEntity)
	|| entity_get_int(iEntity, EV_INT_iuser2) ) return PLUGIN_HANDLED;
	
	entity_set_int(iEntity, EV_INT_solid, SOLID_NOT);
	set_rendering(iEntity, kRenderFxNone, 255, 255, 255, kRenderTransAdd, 25);
	set_task(1.0, "TaskSolid", TASK_SOLID + iEntity);
	
	return PLUGIN_HANDLED;
}

public TaskMoveBack(iEntity)
{
	iEntity -= TASK_MOVEBACK;
	
	if ( !is_valid_ent(iEntity) 
	|| entity_get_int(iEntity, EV_INT_iuser2) ) return PLUGIN_HANDLED;
	
	new Float:origin[3];
	pev(iEntity, pev_v_angle, origin);
			
	set_pev(iEntity, pev_velocity, Float:{0.0, 0.0, 0.0});
	engfunc(EngFunc_SetOrigin, iEntity, origin);
	
	return PLUGIN_HANDLED;
}	

public TaskSolid(iEntity)
{
	iEntity -= TASK_SOLID;
	
	if ( !IsBlock(iEntity) ) return PLUGIN_HANDLED;
	
	entity_set_int(iEntity, EV_INT_solid, SOLID_BBOX);
	
	if ( entity_get_int(iEntity, EV_INT_iuser1) > 0 )
	{
		GroupBlock(0, iEntity);
	}
	else
	{
		static property3[5];
		GetProperty(iEntity, 3, property3);
		
		new transparency = str_to_num(property3);
		if ( !transparency
		|| transparency == 255 )
		{
			new block_type = entity_get_int(iEntity, EV_INT_body);
			SetBlockRendering(iEntity, g_render[block_type], g_red[block_type], g_green[block_type], g_blue[block_type], g_alpha[block_type]);
		}
		else
		{
			SetBlockRendering(iEntity, TRANSALPHA, 255, 255, 255, transparency);
		}
	}
	static property[5];
	GetProperty(iEntity, 4, property);
	if( property[0] == '1' )
		set_task(0.2, "checkstuck");
	
	return PLUGIN_HANDLED;
}

public TaskNotOnIce(id)
{
	id -= TASK_ICE;
	
	clear_bit(g_ice, id);
	
	if ( !get_bit(g_alive, id) ) return PLUGIN_HANDLED;
	
	if ( get_bit(g_bootsofspeed, id) )
	{
		static block, property3[5];
		block = g_boots_of_speed[id];
		GetProperty(block, 3, property3);
		
		entity_set_float(id, EV_FL_maxspeed, str_to_float(property3));
	}
	else
	{
		ResetMaxspeed(id);
	}
	entity_set_float(id, EV_FL_friction, 1.0);
	
	return PLUGIN_HANDLED;
}

public TaskNotInHoney(id)
{
	id -= TASK_HONEY;
	
	g_honey[id] = 0;
	
	if ( !get_bit(g_alive, id) ) return PLUGIN_HANDLED;
	
	if ( g_boots_of_speed[id] )
	{
		static block, property3[5];
		block = g_boots_of_speed[id];
		GetProperty(block, 3, property3);
		
		entity_set_float(id, EV_FL_maxspeed, str_to_float(property3));
	}
	else
	{
		ResetMaxspeed(id);
		//set_user_maxspeed(id, 250.0);
	}
	
	return PLUGIN_HANDLED;
}

public TaskSlowDown(id)
{
	id -= TASK_NOSLOWDOWN;
	
	clear_bit(g_no_slow_down, id);
}

public TaskRemoveInvincibility(id)
{
	id -= TASK_INVINCIBLE;
	
	if ( get_bit(g_alive, id) )
	{
		set_user_godmode(id, 0);
	
		if ( get_gametime() >= g_stealth_time_out[id] )
		{
			set_user_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderNormal, 16);
		}
	}
	
}

public TaskRemoveStealth(id)
{
	id -= TASK_STEALTH;
	
	if ( get_bit(g_connected, id) )
	{
		if ( get_gametime() <= g_invincibility_time_out[id] )
		{
			set_user_rendering(id, kRenderFxGlowShell, 0, 51, 0, kRenderTransColor, 16);
		}
		else
		{
			set_user_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderNormal, 255);
		}
	}
	
	clear_bit(g_block_status, id);
}

public TaskRemoveBootsOfSpeed(id)
{
	id -= TASK_BOOTSOFSPEED;
	clear_bit(g_bootsofspeed, id);
	if ( get_bit(g_alive, id) )
	{
		ResetMaxspeed(id);
		//set_user_maxspeed(id, 250.0);
	}
}

public TaskRemoveSuperman(id)
{
	id -= TASK_SUPERMAN;
	
	if ( !get_bit(g_alive, id) ) return PLUGIN_HANDLED;
	
	if ( get_bit(g_connected, id) )
	{
		if ( get_gametime() <= g_superman_time_out[id] )
		{
			set_user_gravity(id, 0.50);
		}
		else
		{
			set_user_gravity(id, 1.0);
		}
	}
	
	return PLUGIN_HANDLED;
}

public TaskSpriteNextFrame(params[])
{
	new iEntity = params[0];
	if ( !is_valid_ent(iEntity) )
	{
		remove_task(TASK_SPRITE + iEntity);
		return PLUGIN_HANDLED;
	}
	
	new frames = params[1];
	new Float:current_frame = entity_get_float(iEntity, EV_FL_frame);
	
	if ( current_frame < 0.0
	|| current_frame >= frames )
	{
		entity_set_float(iEntity, EV_FL_frame, 1.0);
	}
	else
	{
		entity_set_float(iEntity, EV_FL_frame, current_frame + 1.0);
	}
	
	return PLUGIN_HANDLED;
}

public MsgStatusValue()
{
	if ( get_msg_arg_int(1) == 2
	&& get_bit(g_block_status, get_msg_arg_int(2)) )
	{
		set_msg_arg_int(1, get_msg_argtype(1), 1);
		set_msg_arg_int(2, get_msg_argtype(2), 0);
	}
}

public CmdAttack(id)
{
	if(g_block_count >= MAX_BLOCKS) {
		BCM_Print(id, "^1Max block count of^4 %d has already been^3 reached.", MAX_BLOCKS);
		return PLUGIN_HANDLED;
	}
	if ( !IsBlock(g_grabbed[id]) ) return PLUGIN_HANDLED;
	
	if ( IsBlockInGroup(id, g_grabbed[id]) && g_group_count[id] > 1 )
	{
		static block;
		for ( new i = 0; i <= g_group_count[id]; ++i )
		{
			block = g_grouped_blocks[id][i];
			if ( !IsBlockInGroup(id, block) ) continue;
			
			if ( !IsBlockStuck(block) )
			{
				CopyBlock(id, block);
			}
		}
	}
	else
	{
		if ( IsBlockStuck(g_grabbed[id]) )
		{
			BCM_Print(id, "You cannot copy a block that is in a stuck position!");
			return PLUGIN_HANDLED;
		}
		
		new new_block = CopyBlock(id, g_grabbed[id]);
		if ( !new_block ) return PLUGIN_HANDLED;
		
		entity_set_int(g_grabbed[id], EV_INT_iuser2, 0);
		entity_set_int(new_block, EV_INT_iuser2, id);
		g_grabbed[id] = new_block;
	}
	
	return PLUGIN_HANDLED;
}

public CmdAttack2(id)
{
	if ( !IsBlock(g_grabbed[id]) )
	{
		DeleteTeleport(id, g_grabbed[id]);
		return PLUGIN_HANDLED;
	}
	
	if ( !IsBlockInGroup(id, g_grabbed[id])
	|| g_group_count[id] < 2 )
	{
		DeleteBlock(g_grabbed[id]);
		return PLUGIN_HANDLED;
	}
	
	static block;
	for ( new i = 0; i <= g_group_count[id]; ++i )
	{
		block = g_grouped_blocks[id][i];
		if ( !is_valid_ent(block)
		|| !IsBlockInGroup(id, block) ) continue;
		
		DeleteBlock(block);
	}
	
	return PLUGIN_HANDLED;
}

public CmdRotate(id)
{		
	if ( !IsBlock(g_grabbed[id]) ) return PLUGIN_HANDLED;
	
	if ( !IsBlockInGroup(id, g_grabbed[id])
	|| g_group_count[id] < 2 )
	{
		RotateBlock(g_grabbed[id]);
		return PLUGIN_HANDLED;
	}
	
	static block;
	for ( new i = 0; i <= g_group_count[id]; ++i )
	{
		block = g_grouped_blocks[id][i];
		if ( !is_valid_ent(block)
		|| !IsBlockInGroup(id, block) ) continue;
		
		RotateBlock(block);
	}
	
	return PLUGIN_HANDLED;
}

public EventCurWeaponModelView( id ) {
	if( g_grabbed[id] ) {
		entity_get_string( id, EV_SZ_viewmodel, g_szViewModel[id], 31 );
		entity_set_string( id, EV_SZ_viewmodel, "" );
	}
}

public CmdGrab(id)
{
	if ( !get_bit(g_admin, id) )
	{
		console_print(id, "You have no access to that command");
		return PLUGIN_HANDLED;
	}
	if (get_pcvar_num(g_pCvar_Enable) != 1)
	{
		return PLUGIN_HANDLED;
	}
	
	static iEntity, body;
	g_grab_length[id] = get_user_aiming(id, iEntity, body);
	
	new bool:is_block = IsBlock(iEntity);
	
	if ( !is_block && !IsTeleport(iEntity) ) return PLUGIN_HANDLED;
	
	new grabber = entity_get_int(iEntity, EV_INT_iuser2);
	if ( grabber && grabber != id ) return PLUGIN_HANDLED;
	
	if ( !is_block )
	{
		SetGrabbed(id, iEntity);
		return PLUGIN_HANDLED;
	}
	
	new player = entity_get_int(iEntity, EV_INT_iuser1);
	if ( player && player != id )
	{
		new player_name[32]; 
		get_user_name(player, player_name, charsmax(player_name));
		
		BCM_Print(id, "^1%s^3 currently has this block in their group!", player_name);
		return PLUGIN_HANDLED;
	}
	
	SetGrabbed(id, iEntity);
	
	if ( g_group_count[id] < 2 ) return PLUGIN_HANDLED;
	
	static Float:grabbed_origin[3];
	
	entity_get_vector(iEntity, EV_VEC_origin, grabbed_origin);
	
	static block, Float:origin[3], Float:offset[3];
	for ( new i = 0; i <= g_group_count[id]; ++i )
	{
		block = g_grouped_blocks[id][i];
		if ( !is_valid_ent(block) ) continue;
		
		entity_get_vector(block, EV_VEC_origin, origin);
		
		offset[0] = grabbed_origin[0] - origin[0];
		offset[1] = grabbed_origin[1] - origin[1];
		offset[2] = grabbed_origin[2] - origin[2];
		
		entity_set_vector(block, EV_VEC_vuser1, offset);
		entity_set_int(block, EV_INT_iuser2, id);
	}
	
	return PLUGIN_HANDLED;
}

SetGrabbed(id, iEntity)
{	
	static aiming[3], Float:origin[3], szLastMover[32];

	entity_get_string( id, EV_SZ_viewmodel, g_szViewModel[id], 31 );
	entity_set_string( id, EV_SZ_viewmodel, g_blank );

	
	get_user_origin(id, aiming, 3);
	entity_get_vector(iEntity, EV_VEC_origin, origin);
	get_user_name(id, szLastMover, 31);
	replace_all(szLastMover, 31, "_", " ");
	entity_set_string(iEntity, EV_SZ_target, szLastMover);
	
	g_grabbed[id] = iEntity;
	g_grab_offset[id][0] = origin[0] - aiming[0];
	g_grab_offset[id][1] = origin[1] - aiming[1];
	g_grab_offset[id][2] = origin[2] - aiming[2];
	
	entity_set_int(iEntity, EV_INT_iuser2, id);
}

public CmdRelease(id)
{
	if ( !get_bit(g_admin, id) )
	{
		console_print(id, "You have no access to that command");
		return PLUGIN_HANDLED;
	}
	else if ( !g_grabbed[id] )
	{
		return PLUGIN_HANDLED;
	}
	
	if ( IsBlock(g_grabbed[id]) )
	{
		if ( IsBlockInGroup(id, g_grabbed[id]) && g_group_count[id] > 1 )
		{
			static i, block;
			
			new bool:group_is_stuck = true;
			
			for ( i = 0; i <= g_group_count[id]; ++i )
			{
				block = g_grouped_blocks[id][i];
				if ( IsBlockInGroup(id, block) )
				{
					entity_set_int(block, EV_INT_iuser2, 0);
					
					if ( group_is_stuck && !IsBlockStuck(block) )
					{
						group_is_stuck = false;
						break;
					}
				}
			}
			
			if ( group_is_stuck )
			{
				for ( i = 0; i <= g_group_count[id]; ++i )
				{
					block = g_grouped_blocks[id][i];
					if ( IsBlockInGroup(id, block) ) DeleteBlock(block);
				}
				
				BCM_Print(id, "Group deleted because all the blocks were stuck!");
			}
		}
		else
		{
			if ( is_valid_ent(g_grabbed[id]) )
			{
				if ( IsBlockStuck(g_grabbed[id]) )
				{
					BCM_Print(id, "Block deleted because it was stuck!");
					new bool:deleted = DeleteBlock(g_grabbed[id]);
					if ( deleted ) BCM_Print(id, "Block deleted because it was stuck!");
				}
				else
				{
					entity_set_int(g_grabbed[id], EV_INT_iuser2, 0);
				}
			}
		}
	}
	
	else if ( IsTeleport(g_grabbed[id]) )
	{
		entity_set_int(g_grabbed[id], EV_INT_iuser2, 0);
	}
	
	entity_set_string(id, EV_SZ_viewmodel, g_szViewModel[id]);
	g_grabbed[id] = 0;
	
	return PLUGIN_HANDLED;
}

public CmdMainMenu(id)
{
	if (get_pcvar_num(g_pCvar_Enable) > 0)
	{
		ShowMainMenu(id);
		return PLUGIN_HANDLED;
	}
	return PLUGIN_HANDLED;
}

ShowMainMenu(id)
{
	new menu[256], col[3];
	
	col = get_bit(g_admin, id) ? "\w" : "\d";	
	
	format(menu, charsmax(menu),\
		g_main_menu,\
		g_config_names[g_current_config],\
		g_block_count,\
		MAX_BLOCKS,\
		col,\
		get_bit(g_noclip, id) ? "\yOn" : "\rOff",\
		col,\
		get_bit(g_godmode, id) ? "\yOn" : "\rOff"
		);
	
	show_menu(id, g_keys_main_menu, menu, -1, "BcmMainMenu");
}

ShowBlockMenu(id)
{
	new menu[256], col[3], size[8];
	
	col = get_bit(g_admin, id) ? "\w" : "\d";
	
	switch ( g_selected_block_size[id] )
	{
		case SMALL:	size = "Small";
		case NORMAL:	size = "Normal";
		case LARGE:	size = "Large";
		case POLE:	size = "Pole";
	}
	
	format(menu, charsmax(menu),\
		g_block_menu,\
		g_block_count,\
		MAX_BLOCKS,\
		g_block_names[g_selected_block_type[id]],\
		col,\
		col,\
		col,\
		col,\
		size,\
		col,\
		col
		);
	
	show_menu(id, g_keys_block_menu, menu, -1, "BcmBlockMenu");
}

ShowBlockSelectionMenu(id)
{
	new menu[256], title[32], entry[32], num;
	
	format(title, charsmax(title), "\yBlock Selection \r%d^n^n", g_block_selection_page[id]);
	add(menu, charsmax(menu), title);
	
	new start_block = ( g_block_selection_page[id] - 1 ) * 8;
	
	for ( new i = start_block; i < start_block + 8; ++i )
	{
		if ( i < TOTAL_BLOCKS )
		{
			num = ( i - start_block ) + 1;
			
			format(entry, charsmax(entry), "\r%d. \w%s^n", num, g_block_names[i]);
		}
		else
		{
			format(entry, charsmax(entry), "^n");
		}
		
		add(menu, charsmax(menu), entry);
	}
	
	if ( g_block_selection_page[id] < g_block_selection_pages_max )
	{
		add(menu, charsmax(menu), "^n\r9. \yMore");
	}
	else
	{
		add(menu, charsmax(menu), "^n");
	}
	
	add(menu, charsmax(menu), "^n\r0. \yBack");
	
	show_menu(id, g_keys_block_selection_menu, menu, -1, "BcmBlockSelectionMenu");
}

ShowPropertiesMenu(id, iEntity)
{
	new menu[256], title[64], entry[128], property[5], line1[3], line2[3], line3[3], line4[3], num, block_type;
	
	block_type = entity_get_int(iEntity, EV_INT_body);
	
	format(title, charsmax(title), "\rSet Properties \yMenu \d7.2^n^n\wBlock Type: \y%s^n^n", g_block_names[block_type]);
	add(menu, charsmax(menu), title);
	
	if ( g_property1_name[block_type][0] )
	{
		GetProperty(iEntity, 1, property);
		
		switch ( block_type )
		{
			case BHOP, NO_SLOW_DOWN_BHOP: format(entry, charsmax(entry), "\r1. \w%s: %s^n", g_property1_name[block_type], property[0] == '1' ? "\yOn" : "\rOff");
			case MAGIC_CARPET: format(entry, charsmax(entry), "\r1. \w%s: \y%s^n", g_property1_name[block_type], property[0] == '4' ? "Off" : property[0] == '3' ? "All" : property[0] == '2' ? "Counter-Terrorists" : "Terrorists");
			case SLAP: format(entry, charsmax(entry), "\r1. \w%s: \y%s^n", g_property1_name[block_type], property[0] == '3' ? "High" : property[0] == '2' ? "Medium" : "Low");
			case CT_BARRIER, T_BARRIER: format(entry, charsmax(entry), "\r1. \w%s: \y%s^n", g_property1_name[block_type], property[0] == '3' ? "All Admins Only" : property[0] == '2' ? "Team Admins Only" : "Normal");
			case WEAPON_BLOCK: format(entry, charsmax(entry), "\r1. \w%s: \y%s^n", g_property1_name[block_type], property[0] == '9' ? "Famas" : property[0] == '8' ? "AK47" : property[0] == '7' ? "Mac 10" : property[0] == '6' ? "Shotgun" : property[0] == '5' ? "Aug" : property[0] == '4' ? "Tmp" : property[0] == '3' ? "Usp" : property[0] == '2' ? "Deagle" : "Awp");
			default: format(entry, charsmax(entry), "\r1. \w%s: \y%s^n", g_property1_name[block_type], property);
		}
		
		add(menu, charsmax(menu), entry);
	}
	else
	{
		format(line1, charsmax(line1), "^n");
	}
	
	if ( g_property2_name[block_type][0] )
	{
		if ( g_property1_name[block_type][0] )
		{
			num = 2;
		}
		else
		{
			num = 1;
		}
		
		GetProperty(iEntity, 2, property);
		
		format(entry, charsmax(entry), "\r%d. \w%s: \y%s^n", num, g_property2_name[block_type], property);
		
		add(menu, charsmax(menu), entry);
	}
	else
	{
		format(line2, charsmax(line2), "^n");
	}
	
	if ( g_property3_name[block_type][0] )
	{
		if ( g_property1_name[block_type][0] && g_property2_name[block_type][0] )
		{
			num = 3;
		}
		else if ( g_property1_name[block_type][0]
		|| g_property2_name[block_type][0] )
		{
			num = 2;
		}
		else
		{
			num = 1;
		}
		
		GetProperty(iEntity, 3, property);
		
		if ( block_type == BOOTS_OF_SPEED
		|| block_type == BLIND_TRAP
		|| property[0] != '0' && !( property[0] == '2' && property[1] == '5' && property[2] == '5' ) )
		{
			format(entry, charsmax(entry), "\r%d. \w%s: \y%s^n", num, g_property3_name[block_type], property);
		}
		else
		{
			format(entry, charsmax(entry), "\r%d. \w%s: \rOff^n", num, g_property3_name[block_type]);
		}
		
		add(menu, charsmax(menu), entry);
	}
	else
	{
		format(line3, charsmax(line3), "^n");
	}
	
	if ( g_property4_name[block_type][0] )
	{
		if ( g_property1_name[block_type][0] && g_property2_name[block_type][0] && g_property3_name[block_type][0] )
		{
			num = 4;
		}
		else if ( g_property1_name[block_type][0] && g_property2_name[block_type][0]
		|| g_property1_name[block_type][0] && g_property3_name[block_type][0]
		|| g_property2_name[block_type][0] && g_property3_name[block_type][0] )
		{
			num = 3;
		}
		else if ( g_property1_name[block_type][0]
		|| g_property2_name[block_type][0]
		|| g_property3_name[block_type][0] )
		{
			num = 2;
		}
		else
		{
			num = 1;
		}
		
		GetProperty(iEntity, 4, property);
		
		if( block_type == BLIND_TRAP )
		{
			format(entry, charsmax(entry), "\r%d. \w%s: \y%s^n", num, g_property4_name[block_type], property);
		}
		if( block_type == HEALER )
		{
			format(entry, charsmax(entry), "\r%d. \w%s: \y%s^n", num, g_property4_name[block_type], property[0] == '3' ? "Health/Armor" : property[0] == '2' ? "Armor" : "Health");
		}
		else
		{
			format(entry, charsmax(entry), "\r%d. \w%s: %s^n", num, g_property4_name[block_type], property[0] == '1' ? "\yYes" : "\rNo");
		}
		add(menu, charsmax(menu), entry);
	}
	else
	{
		format(line4, charsmax(line4), "^n");
	}
	
	g_property_info[id][1] = iEntity;
	
	add(menu, charsmax(menu), line1);
	add(menu, charsmax(menu), line2);
	add(menu, charsmax(menu), line3);
	add(menu, charsmax(menu), line4);
	add(menu, charsmax(menu), "^n\r0. \wBack");
	
	show_menu(id, g_keys_properties_menu, menu, -1, "BcmPropertiesMenu");
}

ShowTeleportMenu(id)
{
	new menu[256], col[3];
	
	col = get_bit(g_admin, id) ? "\w" : "\d";
	
	format(menu, charsmax(menu),\
		g_teleport_menu,\
		col,\
		g_teleport_start[id] ? "\w" : "\d",\
		col,\
		col,\
		col,\
		get_bit(g_noclip, id) ? "\yOn" : "\rOff",\
		col,\
		get_bit(g_godmode, id) ? "\yOn" : "\rOff"
		);
	
	show_menu(id, g_keys_teleport_menu, menu, -1, "BcmTeleportMenu");
}

ShowConfigMenu(id) {
	new menu[256], col[3];
	
	col = get_bit(g_admin, id) ? "\w" : "\d";

	format(menu, charsmax(menu), g_config_menu,  col, col, col, g_new_file, col, g_config_names[g_current_config]);
	
	show_menu(id, g_keys_config_menu, menu, -1, "BcmConfigMenu");
}

ShowConfigSelectionMenu(id) {
	new menu[256], col[3];
	
	col = get_bit(g_admin, id) ? "\w" : "\d";
	
	new bool:prev = (g_config_menu_page[id] >= 1);
	new bool:next = ((g_config_menu_page[id] * 7 + 7) < g_config_count);
	new len = 0;
	new keys = 0;
	

	len += formatex(menu[len], charsmax(menu), "\yConfig Selection Menu \w(\yCurrent file\w: \r%s\w)^n^n", g_config_names[g_current_config]);
	for(new i = 0; (i < 7) && ((g_config_menu_page[id] * 7 + i) < g_config_count); i++) {
		len += formatex(menu[len], charsmax(menu), "\r%d. \w%s^n", (i + 1), g_config_names[g_config_menu_page[id] * 7 + i]);
		keys |= (1 << i);
	}
	len += formatex(menu[len], charsmax(menu), "^n\r8. %sPrevious^n", prev ? "\w" : "\d");
	keys |= (prev ? B8 : 0);
	len += formatex(menu[len], charsmax(menu), "\r9. %sNext^n^n", next ? "\w" : "\d");
	keys |= (next ? B9 : 0);
	len += formatex(menu[len], charsmax(menu), "\r0. \wBack^n");
	keys |= B0;
	
	
	show_menu(id, keys, menu, -1, "BcmConfigSelectionMenu");
}

ShowOptionsMenu(id, oldMenu)
{
	g_menu_before_options[id] = oldMenu;
	
	new menu[256], col[3], g_auto[6];
	
	col = get_bit(g_admin, id) ? "\w" : "\d";
	
	g_auto = (get_bit(g_auto_block_properties, id) ? "\yOn" : "\rOff");
	
	format(menu, charsmax(menu),\
		g_options_menu,\
		col,\
		get_bit(g_snapping, id) ? "\yOn" : "\rOff",\
		col,\
		g_snapping_gap[id],\
		col,\
		col,\
		col,\
		col,\
		g_auto,\
		col,\
		col
		);
	
	show_menu(id, g_keys_options_menu, menu, -1, "BcmOptionsMenu");
}

ShowChoiceMenu(id, choice, const title[96])
{
	new menu[256];
	
	g_choice_option[id] = choice;
	
	format(menu, charsmax(menu), g_choice_menu, title);
	
	show_menu(id, g_keys_choice_menu, menu, -1, "BcmChoiceMenu");
}

public HandleMainMenu(id, key)
{
	switch ( key )
	{
		case K1: ShowBlockMenu(id);
		case K2: ShowTeleportMenu(id);
		case K3: ShowConfigMenu(id);
		case K6: ToggleNoclip(id);
		case K7: ToggleGodmode(id);
		case K9: ShowOptionsMenu(id, 1);
		case K0: return;
	}
	
	if ( key == K6 || key == K7 ) ShowMainMenu(id);
}

public HandleBlockMenu(id, key)
{
	switch ( key )
	{
		case K1:
		{
			g_block_selection_page[id] = 1;
			ShowBlockSelectionMenu(id);
		}
		case K2: CreateBlockAiming(id, g_selected_block_type[id]);
		case K3: ConvertBlockAiming(id, g_selected_block_type[id]);
		case K4: DeleteBlockAiming(id);
		case K5: RotateBlockAiming(id);
		case K6: ChangeBlockSize(id);
		case K7: SetPropertiesBlockAiming(id);
		case K9: ShowOptionsMenu(id, 2);
		case K0: ShowMainMenu(id);
	}
	
	if ( key != K1 && key != K7 && key != K9 && key != K0 ) ShowBlockMenu(id);
}

public HandleBlockSelectionMenu(id, key)
{
	switch ( key )
	{
		case K9:
		{
			++g_block_selection_page[id];
			
			if ( g_block_selection_page[id] > g_block_selection_pages_max )
			{
				g_block_selection_page[id] = g_block_selection_pages_max;
			}
			
			ShowBlockSelectionMenu(id);
		}
		case K0:
		{
			--g_block_selection_page[id];
			
			if ( g_block_selection_page[id] < 1 )
			{
				ShowBlockMenu(id);
			}
			else
			{
				ShowBlockSelectionMenu(id);
			}
		}
		default:
		{
			key += ( g_block_selection_page[id] - 1 ) * 8;
			
			if ( key < TOTAL_BLOCKS )
			{
				g_selected_block_type[id] = key;
				ShowBlockMenu(id);
			}
			else
			{
				ShowBlockSelectionMenu(id);
			}
		}
	}
}

public HandlePropertiesMenu(id, key)
{
	new iEntity = g_property_info[id][1];
	if ( !is_valid_ent(iEntity) )
	{
		BCM_Print(id, "That block has been deleted!");
		clear_bit(g_viewing_properties_menu, id);
		//g_viewing_properties_menu[id] = false;
		ShowBlockMenu(id);
		return PLUGIN_HANDLED;
	}
	
	new block_type = entity_get_int(iEntity, EV_INT_body);
	
	switch ( key )
	{
		case K1:
		{
			if ( g_property1_name[block_type][0] )
			{
				g_property_info[id][0] = 1;
			}
			else if ( g_property2_name[block_type][0] )
			{
				g_property_info[id][0] = 2;
			}
			else if ( g_property3_name[block_type][0] )
			{
				g_property_info[id][0] = 3;
			}
			else
			{
				g_property_info[id][0] = 4;
			}
			
			if ( g_property_info[id][0] == 1
			&& ( block_type == MAGIC_CARPET
			|| block_type == BHOP
			|| block_type == SLAP
			|| block_type == CT_BARRIER
			|| block_type == T_BARRIER
			|| block_type == NO_SLOW_DOWN_BHOP
			|| block_type == WEAPON_BLOCK) )

			{
				ToggleProperty(id, 1);
			}
			else if ( g_property_info[id][0] == 4 )
			{
				ToggleProperty(id, 4);
			}
			else
			{
				BCM_Print(id, "Type the new property value for the block.%s", g_property_info[id][0] == 3 && block_type != BOOTS_OF_SPEED ? "^1 0^3 and^1 255^3 will turn transparency off." : g_blank);
				client_cmd(id, "messagemode BCM_SetProperty");
			}
		}
		case K2:
		{
			if ( g_property1_name[block_type][0] && g_property2_name[block_type][0]
			|| g_property1_name[block_type][0] && g_property3_name[block_type][0]
			|| g_property1_name[block_type][0] && g_property4_name[block_type][0]
			|| g_property2_name[block_type][0] && g_property3_name[block_type][0]
			|| g_property2_name[block_type][0] && g_property4_name[block_type][0]
			|| g_property3_name[block_type][0] && g_property4_name[block_type][0] )
			{
				if ( g_property1_name[block_type][0] && g_property2_name[block_type][0] )
				{
					g_property_info[id][0] = 2;
				}
				else if ( g_property1_name[block_type][0] && g_property3_name[block_type][0]
				|| g_property2_name[block_type][0] && g_property3_name[block_type][0] )
				{
					g_property_info[id][0] = 3;
				}
				else
				{
					g_property_info[id][0] = 4;
				}
				
				if ( g_property_info[id][0] == 4 )
				{
					ToggleProperty(id, 4);
				}
				else
				{
					BCM_Print(id, "Type the new property value for the block.%s", g_property_info[id][0] == 3 && block_type != BOOTS_OF_SPEED ? "^1 0^3 and^1 255^3 will turn transparency off." : g_blank);
					client_cmd(id, "messagemode BCM_SetProperty");
				}
			}
		}
		case K3:
		{
			if ( g_property1_name[block_type][0] && g_property2_name[block_type][0] && g_property3_name[block_type][0]
			|| g_property1_name[block_type][0] && g_property2_name[block_type][0] && g_property4_name[block_type][0]
			|| g_property1_name[block_type][0] && g_property3_name[block_type][0] && g_property4_name[block_type][0]
			|| g_property2_name[block_type][0] && g_property3_name[block_type][0] && g_property4_name[block_type][0] )
			{
				if ( g_property1_name[block_type][0] && g_property2_name[block_type][0] && g_property3_name[block_type][0] )
				{
					g_property_info[id][0] = 3;
				}
				else
				{
					g_property_info[id][0] = 4;
				}
				
				if ( g_property_info[id][0] == 4 )
				{
					ToggleProperty(id, 4);
				}
				else
				{
					BCM_Print(id, "Type the new property value for the block.%s", g_property_info[id][0] == 3 && block_type != BOOTS_OF_SPEED ? "^1 0^3 and^1 255^3 will turn transparency off." : g_blank);
					client_cmd(id, "messagemode BCM_SetProperty");
				}
			}
		}
		case K4:
		{
			if ( g_property1_name[block_type][0] && g_property2_name[block_type][0] && g_property3_name[block_type][0] && g_property4_name[block_type][0] )
			{
				if( block_type == BLIND_TRAP )
				{
					BCM_Print(id, "Type the new property value for the block");
					client_cmd(id, "messagemode BCM_SetProperty");
					g_property_info[id][0] = 4;
				}
				else
				{
					ToggleProperty(id, 4);
				}
			}
		}
		case K0:
		{
			//g_viewing_properties_menu[id] = false;
			clear_bit(g_viewing_properties_menu, id);
			ShowBlockMenu(id);
		}
	}
	
	if ( key != K0 ) ShowPropertiesMenu(id, iEntity);
	
	return PLUGIN_HANDLED;
}

public HandleTeleportMenu(id, key)
{
	switch ( key )
	{
		case K1: CreateTeleportAiming(id, TELEPORT_START);
		case K2: CreateTeleportAiming(id, TELEPORT_DESTINATION);
		case K3: SwapTeleportAiming(id);
		case K4: DeleteTeleportAiming(id);
		case K6: ToggleNoclip(id);
		case K7: ToggleGodmode(id);
		case K9: ShowOptionsMenu(id, 3);
		case K0: ShowMainMenu(id);
	}

	if (key != K9 && key != K0)
	{
		ShowTeleportMenu(id);
	}
}

public HandleConfigMenu(id, key) {
	g_config_menu_page[id] = 0;
	switch(key) {
		case K1: ShowChoiceMenu(id, CHOICE_LOAD_CONFIG, "Are you sure you want to load another config?");
		case K2: DoEnterValue(id, CONFIG_NAME);
		case K3: ShowChoiceMenu(id, CHOICE_DEL_CONFIG, "Are you sure you wish to remove this config?");
		case K4: { 
			if(g_current_config != 0) { 
				DoEnterValue(id, CONFIG_RENAME); 
			} else { 
				BCM_Print(id, "^1Cannot change the name of the^3 Default^1 config.");
				ShowConfigMenu(id);
			}
		}
		case K0: ShowMainMenu(id);
	}
}

public HandleConfigSelectionMenu(id, key) {
	switch(key) {
		case K0: ShowConfigMenu(id);
		case K9: g_config_menu_page[id]++;
		case K8: g_config_menu_page[id]--;
	}
	
	if(key == K9 || key == K8) {
		ShowConfigSelectionMenu(id);
	} else if(key != K0) {
		new index = (g_config_menu_page[id] * 7) + key;
		GetConfigFileName(g_config_index[index], g_new_file);
		g_current_config = index;
		LoadBlocks(id);
		ShowConfigMenu(id);
	}
}

public EndVote()
{
	g_iTimer--;
	if( g_iTimer >= 0 )
	{
		new iPlayers[32], iNum, ids;
		get_players( iPlayers, iNum );
		for( new i = 0; i < iNum; i++ )
		{
			ids = iPlayers[i];
			//player_menu_info(ids, ShowConfigVoteMenu, ShowConfigVoteMenu, iPage) 
			if(!get_bit(g_iHasVotedAlready, ids))
				ShowConfigVoteMenu(ids);
		}
	}
	if( g_iTimer <= 0 )
	{
		new iPlayers[32], iNum;
		get_players( iPlayers, iNum );
		for( new i = 0; i < iNum; i++ )
		{
			clear_bit(g_iHasVotedAlready, iPlayers[i]);
		}
		remove_task(TASK_TIMER);
	}
}

ShowConfigVoteMenu(id) {
	
	if( !task_exists(TASK_TIMER) )
	{
		g_iTimer = 20;
		set_task( 1.0, "EndVote", TASK_TIMER, _, _, "b" );
	}
	
	new menu[256];
	new bool:prev = (g_config_vote_menu[id] >= 1);
	new bool:next = ((g_config_vote_menu[id] * 7 + 7) < g_config_count);
	new len = 0;
	new keys = 0;

	len += formatex(menu[len], charsmax(menu), "\yVote for a config: \w[\r%i\w]^n^n\yCurrent Config: \w[\r%s\w]^n^n", g_iTimer, g_config_names[g_current_config]);
	for(new i = 0; (i < 7) && ((g_config_vote_menu[id] * 7 + i) < g_config_count); i++)
	{
		len += formatex(menu[len], charsmax(menu), "\r%d. \w%s^n", (i + 1), g_config_names[g_config_vote_menu[id] * 7 + i]);
		keys |= (1 << i);
	}
	
	len += formatex(menu[len], charsmax(menu), "^n\r8. %sPrevious^n", prev ? "\w" : "\d");
	keys |= (prev ? B8 : 0);
	len += formatex(menu[len], charsmax(menu), "\r9. %sNext^n^n", next ? "\w" : "\d");
	keys |= (next ? B9 : 0);
	len += formatex(menu[len], charsmax(menu), "\r0. \wNone^n");
	keys |= B0;

	if( g_iTimer > 1 )
	{
		show_menu(id, keys, menu, -1, "BcmConfigVoteMenu");
	}
	else
	{
		show_menu(id, keys, menu, 1, "BcmConfigVoteMenu");
	}
}

public HandleConfigVoteMenu(id, key) {
	switch(key) {
		case K9: g_config_vote_menu[id]++;
		case K8: g_config_vote_menu[id]--;
	}
	
	if(key == K9 || key == K8) {
		ShowConfigVoteMenu(id);
	} 
	else if( key != K0 && !get_bit(g_iHasVotedAlready, id) && g_iTimer > 0) 
	{
		new index = (g_config_vote_menu[id] * 7) + key;
		g_config_vote[id] = index;
		static name[32];
		get_user_name(id, name, charsmax(name));
		BCM_Print(0, "^3%s ^1voted for [^3%s^1].", name, g_config_names[index]);
		set_bit(g_iHasVotedAlready, id);
	}
	else 
	{
		static name[32];
		get_user_name(id, name, charsmax(name));
		BCM_Print(0, "^3%s ^1voted for [^3None^1].", name);
		set_bit(g_iHasVotedAlready, id);
	}
		
}

DeleteCurrentConfiguration(id) {
	if(g_current_config == 0) {
		BCM_Print(id, "^1Cannot Delete ^3Default^1 configuration.");
		return;
	}
	
	BCM_Print(id, "^1Deleting and loading ^3Default^1 configuration.");
	for(new i = g_current_config; i < g_config_count - 1; i++) {
		g_config_index[i] = g_config_index[i + 1];
		copy(g_config_names[i], 31, g_config_names[i + 1]);
	}
	g_config_count--;
	g_current_config = 0;
	GetConfigFileName(0, g_new_file);
	LoadBlocks(id);
	SaveBlockConfigurations();
}

public HandleOptionsMenu(id, key)
{
	switch ( key )
	{
		case K1: ToggleSnapping(id);
		case K2: ToggleSnappingGap(id);
		case K3: GroupBlockAiming(id);
		case K4: ClearGroup(id);
		case K5:
		{
			if ( get_bit(g_admin, id) )	ShowChoiceMenu(id, CHOICE_DELETE, "\yA Log Will Be Created.^n \wAre you sure you want to delete all blocks and teleports?");
			else			ShowOptionsMenu(id, 6);
		}
		case K6: 
		{ 
			if(!get_bit(g_auto_block_properties, id))
				set_bit(g_auto_block_properties, id);
			else
				clear_bit(g_auto_block_properties, id);
		}
		case K7: SaveBlocks(id);
		case K8:
		{
			if ( get_bit(g_admin, id) )	ShowChoiceMenu(id, CHOICE_LOAD, "\yLoading will delete all blocks and teleports.^n \wdo you want to continue?");
			else			ShowOptionsMenu(id, 7);
		}
		case K0:
		{
			switch (g_menu_before_options[id])
			{
				case 1: ShowMainMenu(id);
				case 2: ShowBlockMenu(id);
				case 3: ShowTeleportMenu(id);
				
				default: log_amx("%sPlayer ID: %d has an invalid g_menu_before_options: %d", PLUGIN_PREFIX, id, g_menu_before_options[id]);
			}
		}
	}
	
	if ( key != K5 && key != K8 && key != K0 ) 
	{
		ShowOptionsMenu(id, g_menu_before_options[id]);
	}
}

public HandleChoiceMenu(id, key)
{
	switch ( key )
	{
		case K1:
		{
			switch ( g_choice_option[id] )
			{
				case CHOICE_DELETE:	{	DeleteAll(id, true);			}
				case CHOICE_LOAD:	{	LoadBlocks(id);				}
				case CHOICE_LOAD_CONFIG:{ 	ShowConfigSelectionMenu(id);		}
				case CHOICE_DEL_CONFIG:	{ 	DeleteCurrentConfiguration(id);  	}

				default:
				{
					log_amx("%sInvalid choice in handleChoiceMenu()", PLUGIN_PREFIX);
				}
			}
		}
		case K2: ShowOptionsMenu(id, 8);
		case K3: DeleteAllBlocks(id, true);
		case K4: DeleteAllTeleports(id, true);
		case K0: ShowOptionsMenu(id, 9);
			
	}
	
	if(g_choice_option[id] == CHOICE_LOAD || g_choice_option[id] == CHOICE_DELETE) {
		ShowOptionsMenu(id, g_menu_before_options[id]);
	}
	if(g_choice_option[id] == CHOICE_DEL_CONFIG) {
		ShowConfigMenu(id);
	}
	if(g_choice_option[id] == CHOICE_LOAD_CONFIG && key == K2) {
		ShowConfigMenu(id);
	}
}

public NewConfigName(id) 
{
	if ( id != 0 && !get_bit(g_admin, id) )
	{
		console_print(id, "You have no access to that command");
		return PLUGIN_HANDLED;
	}
	if(g_config_count >= MAX_CONFIGS) 
	{
		BCM_Print(id, "^3 Max configs of %d has already been reached.", MAX_CONFIGS);
		return PLUGIN_HANDLED;
	}
	new args[32];
	read_args(args, charsmax(args)-1);
	remove_quotes(args); 
	new szConfigName[128];
	for(new i = 1; i < 32; i++) {
		GetConfigFileName(i, szConfigName);
		if(!file_exists(szConfigName)) {
			BCM_Print(id, "^x03 file: %s, index: %d", szConfigName, i);
			g_config_index[g_config_count] = i;
			copy(g_config_names[g_config_count], charsmax(args) - 1, args);
			g_current_config = g_config_count;
			g_config_count++;
			DeleteAll(id, false);
			SaveBlockConfigurations();
			GetConfigFileName(i, g_new_file);
			new tempFP = fopen(g_new_file, "wt");
			fclose(tempFP); 
			return PLUGIN_HANDLED;
		}
			
	}
	return PLUGIN_HANDLED;
	
}

public ConfigRename(id) 
{
	if ( id != 0 && !get_bit(g_admin, id) )
	{
		console_print(id, "You have no access to that command");
		return PLUGIN_HANDLED;
	}
	if(g_config_count >= MAX_CONFIGS) {
		BCM_Print(id, "Max configs of %d has already been reached.", MAX_CONFIGS);
		return PLUGIN_HANDLED;
	}
		
	if(g_current_config == 0) {
		BCM_Print(id, "Cannot change name of the default config.");
		return PLUGIN_HANDLED;
	}
	new args[32];
	read_args(args, charsmax(args)-1);
	remove_quotes(args); 
	copy(g_config_names[g_current_config], charsmax(args) - 1, args);
	SaveBlockConfigurations();
	return PLUGIN_HANDLED;
}
	
public CmdEnterValue(id) {
	switch(g_value_types[id]) {
		case CONFIG_NAME: { NewConfigName(id); ShowConfigMenu(id); }
		case CONFIG_RENAME: { ConfigRename(id); ShowConfigMenu(id); }
	}
	return PLUGIN_HANDLED;
	
}

ToggleNoclip(id)
{
	static name[32];
	get_user_name(id, name, charsmax(name));

	if(get_bit(g_admin, id) )
	{
		if (get_user_noclip(id))
		{
			set_user_noclip(id, 0);
			clear_bit(g_noclip, id);
			set_task(0.1, "checkstuck");
			if (get_user_team(id) == 3)
			{
				return;
			}
			if (g_pCvar_ShowMessage > 0 || !get_bit(g_admin, id))
			{
				BCM_Print(0, "^1%s ^3Has ^4Stopped The ^3Noclip.", name);// ^4=Green ^3=Silver ^1=Normal
			}
	
		} else {
			set_user_noclip(id, 1);
			set_bit(g_noclip, id);
			if (get_user_team(id) == 3)
			{
				return;
			}
			if (g_pCvar_ShowMessage > 0 || !get_bit(g_admin, id))
			{
				BCM_Print(0, "^1%s ^3Has ^1Started The ^3Noclip.", name);
			}
		}
	}
}

ToggleGodmode(id)
{
	static name[32];
	get_user_name(id, name, charsmax(name));
    
	if ( get_bit(g_admin, id) )
	{
		if (get_user_godmode(id))
		{
			set_user_godmode(id, 0);
			clear_bit(g_godmode, id);
			if (get_user_team(id) == 3)
			{
				return;
			}
			if (g_pCvar_ShowMessage > 0)
			{
				BCM_Print(0, "^1%s ^3Has ^4Stopped The ^3Godpower.", name);
			}
	
		} else {
			set_user_godmode(id, 1);
			set_bit(g_godmode, id);
			if (get_user_team(id) == 3)
			{
				return;
			}
			if (g_pCvar_ShowMessage > 0)
			{
				BCM_Print(0, "^1%s ^3Has ^1Started The ^3Godpower.", name);
			}
		}
	}
}

ToggleSnapping(id)
{
	if ( get_bit(g_admin, id) )
	{
		if(!get_bit(g_snapping, id))
			set_bit(g_snapping, id);
		else
			clear_bit(g_snapping, id);
	}
}

ToggleSnappingGap(id)
{
	if ( get_bit(g_admin, id) )
	{
		g_snapping_gap[id] += 4.0;
		
		if ( g_snapping_gap[id] > 40.0 )
		{
			g_snapping_gap[id] = 0.0;
		}	
	}
}

MoveGrabbedEntity(id, Float:move_to[3] = { 0.0, 0.0, 0.0 })
{
	static aiming[3];
	static look[3];
	static Float:float_aiming[3];
	static Float:float_look[3];
	static Float:direction[3];
	static Float:length;
	
	get_user_origin(id, aiming, 1);
	get_user_origin(id, look, 3);
	IVecFVec(aiming, float_aiming);
	IVecFVec(look, float_look);
	
	direction[0] = float_look[0] - float_aiming[0];
	direction[1] = float_look[1] - float_aiming[1];
	direction[2] = float_look[2] - float_aiming[2];
	length = get_distance_f(float_look, float_aiming);
	
	if ( length == 0.0 ) length = 1.0;
	
	move_to[0] = ( float_aiming[0] + direction[0] * g_grab_length[id] / length ) + g_grab_offset[id][0];
	move_to[1] = ( float_aiming[1] + direction[1] * g_grab_length[id] / length ) + g_grab_offset[id][1];
	move_to[2] = ( float_aiming[2] + direction[2] * g_grab_length[id] / length ) + g_grab_offset[id][2];
	move_to[2] = float(floatround(move_to[2], floatround_floor));
	
	MoveEntity(id, g_grabbed[id], move_to, true);

}

MoveEntity(id, iEntity, Float:move_to[3], bool:do_snapping)
{
	if ( do_snapping ) DoSnapping(id, iEntity, move_to);
	
	entity_set_origin(iEntity, move_to);
	
	static block_type;
	block_type = entity_get_int(iEntity, EV_INT_body);
	if( block_type == MAGIC_CARPET )
		set_pev(iEntity, pev_v_angle, move_to);
}
			
CreateBlockAiming(const id, const block_type)
{
	if ( id != 0 && !get_bit(g_admin, id) )
	{
		console_print(id, "You have no access to that command");
		return PLUGIN_HANDLED;
	}
	
	if(g_block_count >= MAX_BLOCKS) {
		BCM_Print(id, "^1Max block count of^4 %d has already been^3 reached.", MAX_BLOCKS);
		return PLUGIN_HANDLED;
	}
	
	static origin[3];
	static Float:float_origin[3];
	static szCreator[32], szLastMover[32];
	
	get_user_name(id, szCreator, 31);
	get_user_name(id, szLastMover, 31);
	get_user_origin(id, origin, 3);
	IVecFVec(origin, float_origin);
	float_origin[2] += 4.0;
	
	CreateBlock(id, block_type, float_origin, Z, g_selected_block_size[id], g_property1_default_value[block_type], g_property2_default_value[block_type], g_property3_default_value[block_type], g_property4_default_value[block_type], szCreator, szLastMover);
	return PLUGIN_HANDLED;
}

CreateBlock(const id, const block_type, Float:origin[3], const axis, const size, const property1[], const property2[], const property3[], const property4[], szCreator[] = "Unknown", szLastMover[] = "Unknown")
{
	new iEntity = create_entity("info_target");
	if ( !is_valid_ent(iEntity) ) return 0;
	entity_set_string(iEntity, EV_SZ_classname, g_block_classname);
	entity_set_int(iEntity, EV_INT_solid, SOLID_BBOX);
	
	switch ( block_type )
	{
		case MAGIC_CARPET:
		{
			set_pev(iEntity, pev_v_angle, origin); // Original Origin
		}
		case BOUNCE_DEATH:
		{
			set_pev(iEntity, pev_movetype, MOVETYPE_TOSS);
			set_task(0.1,"bounce_death",iEntity);
		}
		case TELEPORT:
		{
			g_teleport_block_start[id] = iEntity;
			if ( id != 0 )
			{
				CreateBlockAiming(id, DESTINATION);
			}
			entity_get_int(iEntity, EV_INT_iuser4);
			entity_set_int(iEntity, EV_INT_movetype, MOVETYPE_NONE);
		}
		case DESTINATION:
		{
			entity_set_int(iEntity, EV_INT_iuser4, g_teleport_block_start[id]);
			entity_set_int(g_teleport_block_start[id], EV_INT_iuser4, iEntity);
			entity_set_int(iEntity, EV_INT_movetype, MOVETYPE_NONE);		
			g_teleport_block_start[id] = 0;
		}
		default:
		{
			entity_set_int(iEntity, EV_INT_movetype, MOVETYPE_NONE);
		}
	}
	
	new block_model[256];
	new Float:size_min[3];
	new Float:size_max[3];
	new Float:angles[3];
	new Float:scale;

	switch ( axis )
	{
		case X:
		{
			if (size == POLE) {
				size_min[0] = -32.0;
				size_min[1] = -4.0;
				size_min[2] = -4.0;
			
				size_max[0] = 32.0;
				size_max[1] = 4.0;
				size_max[2] = 4.0;
			} else {
				size_min[0] = -4.0;
				size_min[1] = -32.0;
				size_min[2] = -32.0;
			
				size_max[0] = 4.0;
				size_max[1] = 32.0;
				size_max[2] = 32.0;	
			}
			angles[0] = 90.0;
		}
		case Y:
		{
			if (size == POLE) {
				size_min[0] = -4.0;
				size_min[1] = -32.0;
				size_min[2] = -4.0;
			
				size_max[0] = 4.0;
				size_max[1] = 32.0;
				size_max[2] = 4.0;
			} else {
				size_min[0] = -32.0;
				size_min[1] = -4.0;
				size_min[2] = -32.0;
			
				size_max[0] = 32.0;
				size_max[1] = 4.0;
				size_max[2] = 32.0;
			}
			angles[0] = 90.0;
			angles[2] = 90.0;
		}
		case Z:
		{
			if (size == POLE) {
				size_min[0] = -4.0;
				size_min[1] = -4.0;
				size_min[2] = -32.0;
			
				size_max[0] = 4.0;
				size_max[1] = 4.0;
				size_max[2] = 32.0;
			} else {
				size_min[0] = -32.0;
				size_min[1] = -32.0;
				size_min[2] = -4.0;
			
				size_max[0] = 32.0;
				size_max[1] = 32.0;
				size_max[2] = 4.0;
			}
			angles[0] = 0.0;
			angles[1] = 0.0;
			angles[2] = 0.0;
		}
	}
	
	switch ( size )
	{
		case SMALL:
		{
			SetBlockModelNameSmall(block_model, g_block_models[block_type], 256);
			scale = 0.25;
		}
		case NORMAL:
		{
			block_model = g_block_models[block_type];
			scale = 1.0;
		}
		case LARGE:
		{
			SetBlockModelNameLarge(block_model, g_block_models[block_type], 256);
			scale = 2.0;
		}
		case POLE:
		{
			SetBlockModelNamePole(block_model, g_block_models[block_type], 256);
			scale = 0.125;
		}
	}
	if (size != POLE) {
		for ( new i = 0; i < 3; ++i )
		{
			if ( size_min[i] != 4.0 && size_min[i] != -4.0 )
			{
				size_min[i] *= scale;
			}
		
			if ( size_max[i] != 4.0 && size_max[i] != -4.0 )
			{
				size_max[i] *= scale;
			}
		}
	}
	set_pev(iEntity, pev_targetname, szCreator, 31);
	set_pev(iEntity, pev_target, szLastMover, 31);
	entity_set_model(iEntity, block_model);
	
	SetBlockRendering(iEntity, g_render[block_type], g_red[block_type], g_green[block_type], g_blue[block_type], g_alpha[block_type]);

	entity_set_vector(iEntity, EV_VEC_angles, angles);
	entity_set_size(iEntity, size_min, size_max);
	entity_set_int(iEntity, EV_INT_body, block_type);
	
	if ( 1 <= id <= g_max_players )
	{
		DoSnapping(id, iEntity, origin);
	}
	
	entity_set_origin(iEntity, origin);
	
	SetProperty(iEntity, 1, property1);
	SetProperty(iEntity, 2, property2);
	SetProperty(iEntity, 3, property3);
	SetProperty(iEntity, 4, property4);
	
	g_block_count ++;
	return iEntity;
}

ConvertBlockAiming(id, const convert_to)
{
	if ( !get_bit(g_admin, id) )
	{
		console_print(id, "You have no access to that command");
		return PLUGIN_HANDLED;
	}
	
	static iEntity, body;
	get_user_aiming(id, iEntity, body);
	new szCreator[32], szLastMover[32];
	get_user_name(id, szCreator, 31);
	replace_all(szCreator, 31, " ", "_");
	get_user_name(id, szLastMover, 31);
	replace_all(szLastMover, 31, " ", "_");
	
	if ( !IsBlock(iEntity) ) return PLUGIN_HANDLED;
	
	new grabber = entity_get_int(iEntity, EV_INT_iuser2);
	if ( grabber && grabber != id ) return PLUGIN_HANDLED;
	
	new player = entity_get_int(iEntity, EV_INT_iuser1);
	if ( player && player != id )
	{
		new player_name[32]; 
		get_user_name(player, player_name, charsmax(player_name));
		
		BCM_Print(id, "^1%s^3 currently has this block in their group!", player_name);
		return PLUGIN_HANDLED;
	}
	
	static new_block;
	if ( IsBlockInGroup(id, iEntity) && g_group_count[id] > 1 )
	{
		static i, block, block_count;
		
		block_count = 0;
		for ( i = 0; i <= g_group_count[id]; ++i )
		{
			block = g_grouped_blocks[id][i];
			if ( !IsBlockInGroup(id, block) ) continue;
			
			new_block = ConvertBlock(id, block, convert_to, true);
			if ( new_block != 0 )
			{
				g_grouped_blocks[id][i] = new_block;
				
				GroupBlock(id, new_block);
			}
			else
			{
				++block_count;
			}
		}
		
		if ( block_count > 1 )
		{
			BCM_Print(id, "Couldn't convert^1 %d^3 blocks!", block_count);
		}
	}
	else
	{					
		new_block = ConvertBlock(id, iEntity, convert_to, false, szCreator, szLastMover);
		if ( IsBlockStuck(new_block) )
		{
			new bool:deleted = DeleteBlock(new_block);
			if ( deleted ) BCM_Print(id, "Block deleted because it was stuck!");
		}	
	}
	
	return PLUGIN_HANDLED;
}

ConvertBlock(id, iEntity, const convert_to, const bool:preserve_size, szCreator[] = "Unknown", szLastMover[] = "Unknown")
{
	new axis;
	new block_type;
	new property1[5], property2[5], property3[5], property4[5];
	new Float:origin[3];
	new Float:size_max[3];
	
	block_type = entity_get_int(iEntity, EV_INT_body);
	
	entity_get_vector(iEntity, EV_VEC_origin, origin);
	entity_get_vector(iEntity, EV_VEC_maxs, size_max);
	
	for ( new i = 0; i < 3; ++i )
	{
		if ( size_max[i] == 4.0 )
		{
			axis = i;
			break;
		}
	}
	
	GetProperty(iEntity, 1, property1);
	GetProperty(iEntity, 2, property2);
	GetProperty(iEntity, 3, property3);
	GetProperty(iEntity, 4, property4);
	
	if ( block_type != convert_to )
	{
		copy(property1, charsmax(property1), g_property1_default_value[convert_to]);
		copy(property2, charsmax(property1), g_property2_default_value[convert_to]);
		copy(property3, charsmax(property1), g_property3_default_value[convert_to]);
		copy(property4, charsmax(property1), g_property4_default_value[convert_to]);
	}
	
	DeleteBlock(iEntity);
	
	if ( preserve_size )
	{
		static size, Float:max_size;
		
		max_size = size_max[0] + size_max[1] + size_max[2];
		
		if ( max_size > 128.0 )		size = LARGE;
		else if ( max_size > 64.0 )	size = NORMAL;
		else if ( max_size > 36.0 ) 	size = POLE;
		else				size = SMALL;
		
		return CreateBlock(id, convert_to, origin, axis, size, property1, property2, property3, property4, szCreator, szLastMover);
	}
	else
	{
		return CreateBlock(id, convert_to, origin, axis, g_selected_block_size[id], property1, property2, property3, property4, szCreator, szLastMover);
	}

	return iEntity;
}

DeleteBlockAiming(id)
{
	if ( !get_bit(g_admin, id) )
	{
		console_print(id, "You have no access to that command");
		return PLUGIN_HANDLED;
	}
	
	static iEntity, body;
	get_user_aiming(id, iEntity, body);
	
	if ( !IsBlock(iEntity) ) return PLUGIN_HANDLED;
	
	new grabber = entity_get_int(iEntity, EV_INT_iuser2);
	if ( grabber && grabber != id ) return PLUGIN_HANDLED;
	
	new player = entity_get_int(iEntity, EV_INT_iuser1);
	if ( player && player != id )
	{
		new player_name[32]; 
		get_user_name(player, player_name, charsmax(player_name));
		
		BCM_Print(id, "^1%s^3 currently has this block in their group!", player_name);
		return PLUGIN_HANDLED;
	}
	
	if ( IsBlockInGroup(id, iEntity) && g_group_count[id] > 1 )
	{
		static i, block;
		for ( i = 0; i <= g_group_count[id]; ++i )
		{
			block = g_grouped_blocks[id][i];
			if ( !is_valid_ent(block) ) continue;
			
			DeleteBlock(block);
		}
		
		return PLUGIN_HANDLED;
	}
	
	DeleteBlock(iEntity);
	
	return PLUGIN_HANDLED;
}

bool:DeleteBlock(iEntity)
{
	if ( !IsBlock(iEntity) ) return true;
	
	remove_entity(iEntity);
	g_block_count --;
	return false;
}

RotateBlockAiming(id)
{
	if ( !get_bit(g_admin, id) )
	{
		console_print(id, "You have no access to that command");
		return PLUGIN_HANDLED;
	}
	
	static iEntity, body;
	get_user_aiming(id, iEntity, body);
	
	if ( !IsBlock(iEntity) ) return PLUGIN_HANDLED;
	
	new grabber = entity_get_int(iEntity, EV_INT_iuser2);
	if ( grabber && grabber != id ) return PLUGIN_HANDLED;
	
	new player = entity_get_int(iEntity, EV_INT_iuser1);
	if ( player && player != id )
	{
		static player_name[32]; 
		get_user_name(player, player_name, charsmax(player_name));
		
		BCM_Print(id, "^1%s^3 currently has this block in their group!", player_name);
		return PLUGIN_HANDLED;
	}
	
	if ( IsBlockInGroup(id, iEntity) && g_group_count[id] > 1 )
	{
		static block;
		for ( new i = 0; i <= g_group_count[id]; ++i )
		{
			block = g_grouped_blocks[id][i];
			if ( IsBlockInGroup(id, block) ) RotateBlock(block);
		}
	}
	else
	{
		RotateBlock(iEntity);
	}
	
	return PLUGIN_HANDLED;
}


RotateBlock(iEntity)
{
	if ( !is_valid_ent(iEntity) ) return false;
	
	static Float:angles[3];
	static Float:size_min[3];
	static Float:size_max[3];
	static Float:temp;
	
	entity_get_vector(iEntity, EV_VEC_angles, angles);
	entity_get_vector(iEntity, EV_VEC_mins, size_min);
	entity_get_vector(iEntity, EV_VEC_maxs, size_max);
	
	if ( angles[0] == 0.0 && angles[2] == 0.0 )
	{
		angles[0] = 90.0;
	}
	else if ( angles[0] == 90.0 && angles[2] == 0.0 )
	{
		angles[0] = 90.0;
		angles[2] = 90.0;
	}
	else
	{
		angles[0] = 0.0;
		angles[1] = 0.0;
		angles[2] = 0.0;
	}
	
	temp = size_min[0];
	size_min[0] = size_min[2];
	size_min[2] = size_min[1];
	size_min[1] = temp;
	
	temp = size_max[0];
	size_max[0] = size_max[2];
	size_max[2] = size_max[1];
	size_max[1] = temp;
	
	entity_set_vector(iEntity, EV_VEC_angles, angles);
	entity_set_size(iEntity, size_min, size_max);
	
	return true;
}

ChangeBlockSize(id)
{
	switch ( g_selected_block_size[id] )
	{
		case SMALL:	g_selected_block_size[id] = NORMAL;
		case NORMAL:	g_selected_block_size[id] = LARGE;
		case LARGE:	g_selected_block_size[id] = POLE;
		case POLE:	g_selected_block_size[id] = SMALL;
	}
}

SetPropertiesBlockAiming(id)
{
	if ( !get_bit(g_admin, id) )
	{
		console_print(id, "You have no access to that command");
		ShowBlockMenu(id);
		return PLUGIN_HANDLED;
	}
	
	static iEntity, body;
	get_user_aiming(id, iEntity, body);
	
	if ( !IsBlock(iEntity) )
	{
		ShowBlockMenu(id);
		return PLUGIN_HANDLED;
	}
	
	new block_type = entity_get_int(iEntity, EV_INT_body);
	
	if ( !g_property1_name[block_type][0]
	&& !g_property2_name[block_type][0]
	&& !g_property3_name[block_type][0]
	&& !g_property4_name[block_type][0] )
	{
		ShowBlockMenu(id);
		return PLUGIN_HANDLED;
	}
	
	//g_viewing_properties_menu[id] = true;
	set_bit(g_viewing_properties_menu, id);
	ShowPropertiesMenu(id, iEntity);
	
	return PLUGIN_HANDLED;
}

public SetPropertyBlock(id)
{
	static arg[5];
	read_argv(1, arg, charsmax(arg));
	
	if ( !strlen(arg) )
	{
		BCM_Print(id, "You can't set a property blank! Please type a new value.");
		client_cmd(id, "messagemode BCM_SetProperty");
		return PLUGIN_HANDLED;
	}
	else if ( !IsStrFloat(arg) )
	{
		BCM_Print(id, "You can't use letters in a property! Please type a new value.");
		client_cmd(id, "messagemode BCM_SetProperty");
		return PLUGIN_HANDLED;
	}
	
	new iEntity = g_property_info[id][1];
	if ( !is_valid_ent(iEntity) )
	{
		BCM_Print(id, "That block has been deleted!");
		clear_bit(g_viewing_properties_menu, id);
		//g_viewing_properties_menu[id] = false;
		ShowBlockMenu(id);
		return PLUGIN_HANDLED;
	}
	
	static block_type;
	static property;
	static Float:property_value;
	
	block_type = entity_get_int(iEntity, EV_INT_body);
	property = g_property_info[id][0];
	property_value = str_to_float(arg);
	
	if ( property == 3
	&& block_type != BOOTS_OF_SPEED
	&& block_type != BLIND_TRAP )
	{
		if ( !( 1 <= property_value <= 200 
		|| property_value == 255
		|| property_value == 0 ) )
		{
			BCM_Print(id, "The property has to be between^1 50^3 and^1 200^3,^1 255^3 or^1 0^3!");
			return PLUGIN_HANDLED;
		}
	}
	else
	{
		switch ( block_type )
		{
			case DAMAGE, HEALER:
			{
				if ( property == 1
				&& !( 1 <= property_value <= 150 ) )
				{
					BCM_Print(id, "The property has to be between^1 1^3 and^1 100^3!");
					return PLUGIN_HANDLED;
				}
				else if ( !( 0.1 <= property_value <= 240 ) )
				{
					BCM_Print(id, "The property has to be between^1 0.1^3 and^1 240^3!");
					return PLUGIN_HANDLED;
				}
			}
                        case XP:
			{
				if ( property == 1
				&& !( 1 <= property_value <= 200 ) )
				{
					BCM_Print(id, "The property has to be between^1 1^3 and^1 200^3!");
					return PLUGIN_HANDLED;
				}
				else if ( property == 2
				&& !( 15<= property_value <= 999 ) )
				{
					client_print(id,print_chat, "The property has to be between^1 15^3 and^1 999^3!");
					return PLUGIN_HANDLED;
				}
			}
			case ICE:
			{
				if ( !( 0.0 <= property_value <= 0.99 ) )
				{
					BCM_Print(id, "The property has to be between^1 0.0^3 and^1 0.99^3!");
					return PLUGIN_HANDLED;
				}
			}
			case TRAMPOLINE:
			{
				if ( property == 2
				&& !( 200 <= property_value <= 2000 ) )
				{
					BCM_Print(id, "The property has to be between^1 200^3 and^1 2000^3!");
					return PLUGIN_HANDLED;
				}
			}
			case SPEED_BOOST:
			{
				if ( property == 1
				&& !( 200 <= property_value <= 2000 ) )
				{
					BCM_Print(id, "The property has to be between^1 200^3 and^1 2000^3!");
					return PLUGIN_HANDLED;
				}
				else if ( !( 0 <= property_value <= 2000 ) )
				{
					BCM_Print(id, "The property has to be between^1 0^3 and^1 2000^3!");
					return PLUGIN_HANDLED;
				}
			}
			case LOW_GRAVITY:
			{
				if ( !( 50 <= property_value <= 750 ) )
				{
					BCM_Print(id, "The property has to be between^1 50^3 and^1 750^3!");
					return PLUGIN_HANDLED;
				}
			}
			case HONEY:
			{
				if ( !( 25 <= property_value <= 200
				|| property_value == 0 ) )
				{
					BCM_Print(id, "The property has to be between^1 25^3 and^1 200^3, or^1 0^3!");
					return PLUGIN_HANDLED;
				}
			}
			case DELAYED_BHOP:
			{
				if ( !( 0.5 <= property_value <= 5 ) )
				{
					BCM_Print(id, "The property has to be between^1 0.5^3 and^1 5^3!");
					return PLUGIN_HANDLED;
				}
			}
			case INVINCIBILITY, STEALTH, BOOTS_OF_SPEED, SUPERMAN:
			{
				if ( property == 1
				&& !( 0.5 <= property_value <= 240 ) )
				{
					BCM_Print(id, "The property has to be between^1 0.5^3 and^1 240^3!");
					return PLUGIN_HANDLED;
				}
				else if ( property == 2
				&& !( 0 <= property_value <= 240 ) )
				{
					BCM_Print(id, "The property has to be between^1 0^3 and^1 240^3!");
					return PLUGIN_HANDLED;
				}
				else if ( property == 3
				&& block_type == BOOTS_OF_SPEED
				&& !( 260 <= property_value <= 2000 ) )
				{
					BCM_Print(id, "The property has to be between^1 260^3 and^1 2000^3!");
					return PLUGIN_HANDLED;
				}
			}
			case BLIND_TRAP:
			{
				if( property == 4 && !( 15 <= property_value <= 255 ) )
				{
					BCM_Print(id, "The property has to be between^1 15^3 and^1 255^3!");
					return PLUGIN_HANDLED;
				}
			}
		}
	}
	
	SetProperty(iEntity, property, arg);
	
	for ( new i = 1; i <= g_max_players; i++ )
	{
		if ( !get_bit(g_connected, i)
		|| !get_bit(g_viewing_properties_menu, i) ) continue;
		
		iEntity = g_property_info[i][1];
		ShowPropertiesMenu(i, iEntity);
	}
	
	return PLUGIN_HANDLED;
}

ToggleProperty(id, property)
{
	new iEntity = g_property_info[id][1];
	if ( !is_valid_ent(iEntity) )
	{
		BCM_Print(id, "That block has been deleted!");
		clear_bit(g_viewing_properties_menu, id);
		ShowBlockMenu(id);
		return PLUGIN_HANDLED;
	}
	
	static property_value[5];
	GetProperty(iEntity, property, property_value);
	
	new block_type = entity_get_int(iEntity, EV_INT_body);
	if ( block_type == WEAPON_BLOCK && property == 1)
	{	
		switch( property_value[0] )
		{
			case '1': copy(property_value, charsmax(property_value), "2");
			case '2': copy(property_value, charsmax(property_value), "3");
			case '3': copy(property_value, charsmax(property_value), "4");
			case '4': copy(property_value, charsmax(property_value), "5");
			case '5': copy(property_value, charsmax(property_value), "6");
			case '6': copy(property_value, charsmax(property_value), "7");
			case '7': copy(property_value, charsmax(property_value), "8");
			case '8': copy(property_value, charsmax(property_value), "9");
			default: copy(property_value, charsmax(property_value), "1");
		}
	}
	else if ( block_type == MAGIC_CARPET && property == 1 )
	{
		switch( property_value[0] )
		{
			case '1': copy(property_value, charsmax(property_value), "2");
			case '2': copy(property_value, charsmax(property_value), "3");
			case '3': copy(property_value, charsmax(property_value), "4");
			default: copy(property_value, charsmax(property_value), "1");
		}
	}	
	else if ( block_type == SLAP && property == 1
	|| block_type == CT_BARRIER && property == 1
	|| block_type == T_BARRIER && property == 1
	|| block_type == HEALER && property == 4 )
	{
		switch( property_value[0] )
		{
			case '1': copy(property_value, charsmax(property_value), "2");
			case '2': copy(property_value, charsmax(property_value), "3");
			default: copy(property_value, charsmax(property_value), "1");
		}
	}
	else
	{
		if ( property_value[0] == '0' )		copy(property_value, charsmax(property_value), "1");
		else					copy(property_value, charsmax(property_value), "0");
	}
	
	SetProperty(iEntity, property, property_value);
	
	for ( new i = 1; i <= g_max_players; i++ )
	{
		if ( get_bit(g_connected, i) && get_bit(g_viewing_properties_menu, i) )
		{
			iEntity = g_property_info[i][1];
			ShowPropertiesMenu(i, iEntity);
		}
	}
	
	return PLUGIN_HANDLED;
}

GetProperty(iEntity, property, property_value[])
{
	switch ( property )
	{
		case 1: pev(iEntity, pev_message, property_value, 5);
		case 2: pev(iEntity, pev_netname, property_value, 5);
		case 3: pev(iEntity, pev_viewmodel2, property_value, 5);
		case 4: pev(iEntity, pev_weaponmodel2, property_value, 5);
	}
	
	return (strlen(property_value) ? 1 : 0);
}

SetProperty(iEntity, property, const property_value[])
{
	switch ( property )
	{
		case 1: set_pev(iEntity, pev_message, property_value, 5);
		case 2: set_pev(iEntity, pev_netname, property_value, 5);
		case 3:
		{
			set_pev(iEntity, pev_viewmodel2, property_value, 5);
			
			new block_type = entity_get_int(iEntity, EV_INT_body);
			if ( g_property3_name[block_type][0] && block_type != BOOTS_OF_SPEED && block_type != BLIND_TRAP)
			{
				new transparency = str_to_num(property_value);
				if ( !transparency
				|| transparency == 255 )
				{
					SetBlockRendering(iEntity, g_render[block_type], g_red[block_type], g_green[block_type], g_blue[block_type], g_alpha[block_type]);
				}
				else
				{
					SetBlockRendering(iEntity, TRANSALPHA, 255, 255, 255, transparency);
				}
			}
		}
		case 4: set_pev(iEntity, pev_weaponmodel2, property_value, 5);
	}

	return 1;
}

CopyBlock(id, iEntity)
{
	if ( !is_valid_ent(iEntity) ) return 0;
	
	if(g_block_count >= MAX_BLOCKS) {
		client_print(id, print_chat, "Max block count of %d has already been reached.", MAX_BLOCKS);
		return PLUGIN_HANDLED;
	}
	
	new size;
	new axis;
	new property1[5], property2[5], property3[5], property4[5];
	new Float:origin[3];
	new Float:angles[3];
	new Float:size_min[3];
	new Float:size_max[3];
	new Float:max_size;
	new szCreator[32], szLastMover[32];
		
	get_user_name(id, szCreator, 31);
	replace_all(szCreator, 31, " ", "_");
	
	get_user_name(id, szLastMover, 31);
	replace_all(szLastMover, 31, " ", "_");
	
	entity_get_vector(iEntity, EV_VEC_origin, origin);
	entity_get_vector(iEntity, EV_VEC_angles, angles);
	entity_get_vector(iEntity, EV_VEC_mins, size_min);
	entity_get_vector(iEntity, EV_VEC_maxs, size_max);
	
	max_size = size_max[0] + size_max[1] + size_max[2];
	
	if ( max_size > 128.0 )		size = LARGE;
	else if ( max_size > 64.0 )	size = NORMAL;
	else if ( max_size > 36.0 )	size = POLE;
	else				size = SMALL;
	
	for ( new i = 0; i < 3; ++i )
	{
		if ( size_max[i] == 4.0 )
		{
			axis = i;
			break;
		}
	}
	
	GetProperty(iEntity, 1, property1);
	GetProperty(iEntity, 2, property2);
	GetProperty(iEntity, 3, property3);
	GetProperty(iEntity, 4, property4);
	
	
	return CreateBlock(0, entity_get_int(iEntity, EV_INT_body), origin, axis, size, property1, property2, property3, property4, szCreator, szLastMover);
}

GroupBlockAiming(id)
{
	if ( !get_bit(g_admin, id) )
	{
		console_print(id, "You have no access to that command");
		return PLUGIN_HANDLED;
	}
	
	static iEntity, body;
	get_user_aiming(id, iEntity, body);
	
	if ( !IsBlock(iEntity) ) return PLUGIN_HANDLED;
	
	new player = entity_get_int(iEntity, EV_INT_iuser1);
	if ( player == 0 )
	{
		++g_group_count[id];
		g_grouped_blocks[id][g_group_count[id]] = iEntity;
		GroupBlock(id, iEntity);
		
	}
	else if ( player == id )
	{
		UnGroupBlock(iEntity);
	}
	else
	{
		static name[32];
		
		new player = entity_get_int(iEntity, EV_INT_iuser1);
		get_user_name(player, name, charsmax(name));
		
		BCM_Print(id, "Block is already in a group by:^1 %s", name);
	}
	
	return PLUGIN_HANDLED;
}

GroupBlock(id, iEntity)
{
	if ( !is_valid_ent(iEntity) ) return PLUGIN_HANDLED;
	
	if ( id > 0 && id <= g_max_players )
	{
		entity_set_int(iEntity, EV_INT_iuser1, id);
	}
	
	set_rendering(iEntity, kRenderFxGlowShell, 255, 0, 0, kRenderNormal, 16);
	
	return PLUGIN_HANDLED;
}

UnGroupBlock(iEntity)
{
	if ( IsBlock(iEntity) ) 
	{
		entity_set_int(iEntity, EV_INT_iuser1, 0);
		new block_type = entity_get_int(iEntity, EV_INT_body);
		SetBlockRendering(iEntity, g_render[block_type], g_red[block_type], g_green[block_type], g_blue[block_type], g_alpha[block_type]);
	}
}

ClearGroup(id)
{
	if ( !get_bit(g_admin, id) )
	{
		console_print(id, "You have no access to that command");
		return PLUGIN_HANDLED;
	}
	
	static block;
	static block_count = 0;
	static blocks_deleted = 0;
	
	for (new i = 0; i <= g_group_count[id]; ++i )
	{
		block = g_grouped_blocks[id][i];
		if ( IsBlockInGroup(id, block) )
		{
			if ( IsBlockStuck(block) )
			{
				DeleteBlock(block);
				++blocks_deleted;
			}
			else
			{
				UnGroupBlock(block);
				++block_count;
			}
		}
	}
	
	g_group_count[id] = 0;
	
	if ( get_bit(g_connected, id) )
	{
		if ( blocks_deleted > 0 )
		{
			BCM_Print(id, "Removed^1 %d^3 block%s from group. Deleted^1 %d^3 stuck block%s!", block_count, block_count == 1 ? "" : "s", blocks_deleted, blocks_deleted == 1 ? "" : "s");
			block_count = 0;
			blocks_deleted = 0;
		}
		else
		{
			if( block_count > 0 )
			{
				BCM_Print(id, "Removed^1 %d^3 block%s from group!", block_count, block_count == 1 ? "" : "s");
				block_count = 0;
			}
			else 
			{
				BCM_Print(id, "You have^1 No^3 blocks in a group!");
			}
		}
	}
	
	return PLUGIN_HANDLED;
}

SetBlockRendering(iEntity, type, red, green, blue, alpha)
{
	if ( !IsBlock(iEntity) ) return PLUGIN_HANDLED;
	
	switch ( type )
	{
		case GLOWSHELL:		set_rendering(iEntity, kRenderFxGlowShell, red, green, blue, kRenderNormal, alpha);
		case TRANSCOLOR:	set_rendering(iEntity, kRenderFxGlowShell, red, green, blue, kRenderTransColor, alpha);
		case TRANSALPHA:	set_rendering(iEntity, kRenderFxNone, red, green, blue, kRenderTransColor, alpha);
		case TRANSWHITE:	set_rendering(iEntity, kRenderFxNone, red, green, blue, kRenderTransAdd, alpha);
		default:		set_rendering(iEntity, kRenderFxNone, red, green, blue, kRenderNormal, alpha);
	}
	
	return PLUGIN_HANDLED;
}

bool:IsBlock(iEntity)
{
	if ( !is_valid_ent(iEntity) ) return false;
	
	static classname[32];
	entity_get_string(iEntity, EV_SZ_classname, classname, charsmax(classname));
	
	if ( equal(classname, g_block_classname) )
	{
		return true;
	}
	
	return false;
}

bool:IsBlockInGroup(id, iEntity)
{
	if ( !is_valid_ent(iEntity) ) return false;
	
	new player = entity_get_int(iEntity, EV_INT_iuser1);
	if ( player == id ) return true;
	
	return false;
}

bool:IsBlockStuck(iEntity)
{
	if ( !is_valid_ent(iEntity) ) return false;
	new content;
	new Float:origin[3];
	new Float:point[3];
	new Float:size_min[3];
	new Float:size_max[3];
	
	entity_get_vector(iEntity, EV_VEC_mins, size_min);
	entity_get_vector(iEntity, EV_VEC_maxs, size_max);
	
	entity_get_vector(iEntity, EV_VEC_origin, origin);
	
	size_min[0] += 1.0;
	size_min[1] += 1.0;
	size_min[2] += 1.0;
	
	size_max[0] -= 1.0;
	size_max[1] -= 1.0; 
	size_max[2] -= 1.0;
	
	for ( new i = 0; i < 14; ++i )
	{
		point = origin;
		
		switch ( i )
		{
			case 0:
			{
				point[0] += size_max[0];
				point[1] += size_max[1];
				point[2] += size_max[2];
			}
			case 1:
			{
				point[0] += size_min[0];
				point[1] += size_max[1];
				point[2] += size_max[2];
			}
			case 2:
			{
				point[0] += size_max[0];
				point[1] += size_min[1];
				point[2] += size_max[2];
			}
			case 3:
			{
				point[0] += size_min[0];
				point[1] += size_min[1];
				point[2] += size_max[2];
			}
			case 4:
			{
				point[0] += size_max[0];
				point[1] += size_max[1];
				point[2] += size_min[2];
			}
			case 5:
			{
				point[0] += size_min[0];
				point[1] += size_max[1];
				point[2] += size_min[2];
			}
			case 6:
			{
				point[0] += size_max[0];
				point[1] += size_min[1];
				point[2] += size_min[2];
			}
			case 7:
			{
				point[0] += size_min[0];
				point[1] += size_min[1];
				point[2] += size_min[2];
			}
			case 8:	point[0] += size_max[0];
			case 9:	point[0] += size_min[0];
			case 10:point[1] += size_max[1];
			case 11:point[1] += size_min[1];
			case 12:point[2] += size_max[2];
			case 13:point[2] += size_min[2];
		}
		
		content = point_contents(point);
		if ( content == CONTENTS_EMPTY
		|| !content ) return false;
	}
	
	return true;
}

CreateTeleportAiming(id, teleport_type)
{
	if ( !get_bit(g_admin, id) )
	{
		console_print(id, "You have no access to that command");
		return PLUGIN_HANDLED;
	}
	
	static origin[3];
	static Float:float_origin[3];
	
	get_user_origin(id, origin, 3);
	IVecFVec(origin, float_origin);
	float_origin[2] += 36.0;
	
	CreateTeleport(id, teleport_type, float_origin);
	
	return PLUGIN_HANDLED;
}

CreateTeleport(id, teleport_type, Float:origin[3])
{
	new iEntity = create_entity("info_target");
	if ( !is_valid_ent(iEntity) ) return PLUGIN_HANDLED;
	
	switch ( teleport_type )
	{
		case TELEPORT_START:
		{
			if ( g_teleport_start[id] ) remove_entity(g_teleport_start[id]);
			
			entity_set_string(iEntity, EV_SZ_classname, g_start_classname);
			entity_set_int(iEntity, EV_INT_solid, SOLID_BBOX);
			entity_set_int(iEntity, EV_INT_movetype, MOVETYPE_NONE);
			entity_set_model(iEntity, g_sprite_teleport_start);
			entity_set_size(iEntity, Float:{ -16.0, -16.0, -16.0 }, Float:{ 16.0, 16.0, 16.0 });
			entity_set_origin(iEntity, origin);
			
			entity_set_int(iEntity, EV_INT_rendermode, 5);
			entity_set_float(iEntity, EV_FL_renderamt, 255.0);
			
			static params[2];
			params[0] = iEntity;
			params[1] =  g_teleport_start_frames;
			
			set_task(0.1, "TaskSpriteNextFrame", TASK_SPRITE + iEntity, params, 2, "b");
			
			g_teleport_start[id] = iEntity;
		}
		case TELEPORT_DESTINATION:
		{
			if ( !g_teleport_start[id] )
			{
				remove_entity(iEntity);
				return PLUGIN_HANDLED;
			}
			
			entity_set_string(iEntity, EV_SZ_classname, g_destination_classname);
			entity_set_int(iEntity, EV_INT_solid, SOLID_BBOX);
			entity_set_int(iEntity, EV_INT_movetype, MOVETYPE_NONE);
			entity_set_model(iEntity, g_sprite_teleport_destination);
			entity_set_size(iEntity, Float:{ -16.0, -16.0, -16.0 }, Float:{ 16.0, 16.0, 16.0 });
			entity_set_origin(iEntity, origin);
			
			entity_set_int(iEntity, EV_INT_rendermode, 5);
			entity_set_float(iEntity, EV_FL_renderamt, 255.0);
			
			entity_set_int(iEntity, EV_INT_iuser1, g_teleport_start[id]);
			entity_set_int(g_teleport_start[id], EV_INT_iuser1, iEntity);
			
			static params[2];
			params[0] = iEntity;
			params[1] = g_teleport_end_frames;
			
			set_task(0.1, "TaskSpriteNextFrame", TASK_SPRITE + iEntity, params, 2, "b");
			
			g_teleport_start[id] = 0;
		}

	}
	
	return PLUGIN_HANDLED;
}

DeleteTeleportAiming(id)
{
	if ( !get_bit(g_admin, id) )
	{
		console_print(id, "You have no access to that command");
		return PLUGIN_HANDLED;
	}
	
	static iEntity, body;
	get_user_aiming(id, iEntity, body, 9999);
	
	new bool:deleted = DeleteTeleport(id, iEntity);
	if ( deleted ) BCM_Print(id, "Teleport deleted!");
	
	return PLUGIN_HANDLED;
}

bool:DeleteTeleport(id, iEntity)
{
	for ( new i = 0; i < 2; ++i )
	{
		if ( !IsTeleport(iEntity) ) return false;
		
		new tele = entity_get_int(iEntity, EV_INT_iuser1);
		
		if ( g_teleport_start[id] == iEntity
		|| g_teleport_start[id] == tele )
		{
			g_teleport_start[id] = 0;
		}
		
		if ( task_exists(TASK_SPRITE + iEntity) )
		{
			remove_task(TASK_SPRITE + iEntity);
		}
		
		if ( task_exists(TASK_SPRITE + tele) )
		{
			remove_task(TASK_SPRITE + tele);
		}
		
		if ( tele ) remove_entity(tele);
		
		remove_entity(iEntity);
		return true;
	}
	
	return false;
}

SwapTeleportAiming(id)
{
	if ( !get_bit(g_admin, id) )
	{
		console_print(id, "You have no access to that command");
		return PLUGIN_HANDLED;
	}
	
	static iEntity, body;
	get_user_aiming(id, iEntity, body, 9999);
	
	if ( !IsTeleport(iEntity) ) return PLUGIN_HANDLED;
	
	SwapTeleport(id, iEntity);
	
	return PLUGIN_HANDLED;
}

SwapTeleport(id, iEntity)
{
	static Float:origin_ent[3];
	static Float:origin_tele[3];
	
	new tele = entity_get_int(iEntity, EV_INT_iuser1);
	if ( !is_valid_ent(tele) )
	{
		BCM_Print(id, "Can't swap teleport positions!");
		return PLUGIN_HANDLED;
	}
	
	entity_get_vector(iEntity, EV_VEC_origin, origin_ent);
	entity_get_vector(tele, EV_VEC_origin, origin_tele);
	
	static classname[32];
	entity_get_string(iEntity, EV_SZ_classname, classname, charsmax(classname));
	
	DeleteTeleport(id, iEntity);
	
	if ( equal(classname, g_start_classname) )
	{
		CreateTeleport(id, TELEPORT_START, origin_tele);
		CreateTeleport(id, TELEPORT_DESTINATION, origin_ent);
	}
	else if ( equal(classname, g_destination_classname) )
	{
		CreateTeleport(id, TELEPORT_START, origin_ent);
		CreateTeleport(id, TELEPORT_DESTINATION, origin_tele);
	}
	
	BCM_Print(id, "Teleports swapped!");
	
	return PLUGIN_HANDLED;
}

bool:IsTeleport(iEntity)
{
	if ( !is_valid_ent(iEntity) ) return false;
	
	static classname[32];
	entity_get_string(iEntity, EV_SZ_classname, classname, charsmax(classname));
	
	if ( equal(classname, g_start_classname)
	|| equal(classname, g_destination_classname) )
	{
		return true;
	}
	
	return false;
}

DoSnapping(id, iEntity, Float:move_to[3])
{
	if ( !get_bit(g_snapping, id) ) return PLUGIN_HANDLED;
	
	new traceline;
	new closest_trace;
	new block_face;
	new Float:snap_size;
	new Float:v_return[3];
	new Float:dist;
	new Float:old_dist;
	new Float:trace_start[3];
	new Float:trace_end[3];
	new Float:size_min[3];
	new Float:size_max[3];
	
	entity_get_vector(iEntity, EV_VEC_mins, size_min);
	entity_get_vector(iEntity, EV_VEC_maxs, size_max);
	
	snap_size = g_snapping_gap[id] + 10.0;
	old_dist = 9999.9;
	closest_trace = 0;
	for ( new i = 0; i < 6; ++i )
	{
		trace_start = move_to;
		
		switch ( i )
		{
			case 0: trace_start[0] += size_min[0];
			case 1: trace_start[0] += size_max[0];
			case 2: trace_start[1] += size_min[1];
			case 3: trace_start[1] += size_max[1];
			case 4: trace_start[2] += size_min[2];
			case 5: trace_start[2] += size_max[2];
		}
		
		trace_end = trace_start;
		
		switch ( i )
		{
			case 0: trace_end[0] -= snap_size;
			case 1: trace_end[0] += snap_size;
			case 2: trace_end[1] -= snap_size;
			case 3: trace_end[1] += snap_size;
			case 4: trace_end[2] -= snap_size;
			case 5: trace_end[2] += snap_size;
		}
		
		traceline = trace_line(iEntity, trace_start, trace_end, v_return);
		if ( IsBlock(traceline)
		&& ( !IsBlockInGroup(id, traceline) || !IsBlockInGroup(id, iEntity) ) )
		{
			dist = get_distance_f(trace_start, v_return);
			if ( dist < old_dist )
			{
				closest_trace = traceline;
				old_dist = dist;
				
				block_face = i;
			}
		}
	}
	
	if ( !is_valid_ent(closest_trace) ) return PLUGIN_HANDLED;
	
	static Float:trace_origin[3];
	static Float:trace_size_min[3];
	static Float:trace_size_max[3];
	
	entity_get_vector(closest_trace, EV_VEC_origin, trace_origin);
	entity_get_vector(closest_trace, EV_VEC_mins, trace_size_min);
	entity_get_vector(closest_trace, EV_VEC_maxs, trace_size_max);
	
	move_to = trace_origin;
	
	if ( block_face == 0 ) move_to[0] += ( trace_size_max[0] + size_max[0] ) + g_snapping_gap[id];
	if ( block_face == 1 ) move_to[0] += ( trace_size_min[0] + size_min[0] ) - g_snapping_gap[id];
	if ( block_face == 2 ) move_to[1] += ( trace_size_max[1] + size_max[1] ) + g_snapping_gap[id];
	if ( block_face == 3 ) move_to[1] += ( trace_size_min[1] + size_min[1] ) - g_snapping_gap[id];
	if ( block_face == 4 ) move_to[2] += ( trace_size_max[2] + size_max[2] ) + g_snapping_gap[id];
	if ( block_face == 5 ) move_to[2] += ( trace_size_min[2] + size_min[2] ) - g_snapping_gap[id];
	
	return PLUGIN_HANDLED;
}

public DeleteAllTask() {
	DeleteAll(0, false);
}

DeleteAll(id, bool:notify)
{
	if ( id != 0 && !get_bit(g_admin, id) )
	{
		console_print(id, "You have no access to that command");
		return PLUGIN_HANDLED;
	}
	
	static iEntity, block_count, tele_count, bool:deleted;	
	iEntity = -1;
	block_count = 0;
	new bool:done = false;

	while ( !done && ( iEntity = find_ent_by_class(iEntity, g_block_classname) ) )
	{
		deleted = DeleteBlock(iEntity);
		if ( deleted )
		{
			++block_count;
		}
		if( block_count >= BLOCK_DELETE_CHUNK ) {
			set_task(0.1, "DeleteAllTask");
			done = true;
		}
	}
	
	iEntity = -1;
	tele_count = 0;
	while ( ( iEntity = find_ent_by_class(iEntity, g_start_classname) ) )
	{
		deleted = DeleteTeleport(id, iEntity);
		if ( deleted )
		{
			++tele_count;
		}
	}
	
	if ( ( block_count
		|| tele_count )
	&& notify )
	{
		static name[32];
		get_user_name(id, name, charsmax(name));
		
		for ( new i = 1; i <= g_max_players; ++i )
		{
			g_grabbed[i] = 0;
			g_teleport_start[i] = 0;
			
			if ( !get_bit(g_connected, i)
			|| !get_bit(g_admin, i) ) continue;
			
			BCM_Print(i, "^3%s ^1deleted^3 %d blocks^1 and^3 %d teleports^1 from the map!", name, block_count, tele_count);
		}
	}
	
	return PLUGIN_HANDLED;
}

DeleteAllBlocks(id, bool:notify)
{
	if ( !get_bit(g_admin, id) )
	{
		console_print(id, "You have no access to that command");
		return PLUGIN_HANDLED;
	}
	
	static iEntity, block_count, bool:deleted;
	
	iEntity = -1;
	block_count = 0;
	while ( ( iEntity = find_ent_by_class(iEntity, g_block_classname) ) )
	{
		deleted = DeleteBlock(iEntity);
		if ( deleted )
		{
			++block_count;
		}
	}
	
	if ( ( block_count )
	&& notify )
	{
		static name[32];
		get_user_name(id, name, charsmax(name));
		
		for ( new i = 1; i <= g_max_players; ++i )
		{
			g_grabbed[i] = 0;
			g_teleport_start[i] = 0;
			
			if ( !get_bit(g_connected, i)
			|| !get_bit(g_admin, i) ) continue;
			
			BCM_Print(i, "^1%s^3 Deleted^1 %d Blocks ^3from the map!", name, block_count);
		}
	}
	
	return PLUGIN_HANDLED;
}

DeleteAllTeleports(id, bool:notify)
{
	if ( !get_bit(g_admin, id) )
	{
		console_print(id, "You have no access to that command");
		return PLUGIN_HANDLED;
	}
	
	static iEntity, tele_count, bool:deleted;
	
	iEntity = -1;
	tele_count = 0;
	while ( ( iEntity = find_ent_by_class(iEntity, g_start_classname) ) )
	{
		deleted = DeleteTeleport(id, iEntity);
		if ( deleted )
		{
			++tele_count;
		}
	}

	if ( ( tele_count )
	&& notify )
	{
		static name[32];
		get_user_name(id, name, charsmax(name));
		
		for ( new i = 1; i <= g_max_players; ++i )
		{
			g_grabbed[i] = 0;
			g_teleport_start[i] = 0;
			
			if ( !get_bit(g_connected, i)
			|| !get_bit(g_admin, i) ) continue;
			
			BCM_Print(i, "^1%s^3 Deleted^1 %d Teleports^3 from the map!", name, tele_count);
		}
	}
	
	return PLUGIN_HANDLED;
}

SaveBlocks(id)
{
	if ( !get_bit(g_admin, id) )
	{
		console_print(id, "You have no access to that command");
		return PLUGIN_HANDLED;
	}
	
	new iEntity;
	new file = fopen(g_new_file, "wt");
	new data[256];
	new block_count = 0;
	new tele_count = 0;
	new block_type;
	new size;
	new property1[5], property2[5], property3[5], property4[5];
	new tele;
	new Float:origin[3];
	new Float:angles[3];
	new Float:tele_start[3];
	new Float:tele_end[3];
	new Float:max_size;
	new Float:size_max[3];
	new szCreator[32], szLastMover[32];
	
	iEntity = -1;
	while ( ( iEntity = find_ent_by_class(iEntity, g_block_classname) ) )
	{
		block_type = entity_get_int(iEntity, EV_INT_body);
		entity_get_vector(iEntity, EV_VEC_origin, origin);
		entity_get_vector(iEntity, EV_VEC_angles, angles);
		entity_get_vector(iEntity, EV_VEC_maxs, size_max);
		pev(iEntity, pev_targetname, szCreator, 31);
		pev(iEntity, pev_target, szLastMover, 31);
		
		GetProperty(iEntity, 1, property1);
		GetProperty(iEntity, 2, property2);
		GetProperty(iEntity, 3, property3);
		GetProperty(iEntity, 4, property4);
		
		if ( !property1[0] ) copy(property1, charsmax(property1), "/");
		if ( !property2[0] ) copy(property2, charsmax(property2), "/");
		if ( !property3[0] ) copy(property3, charsmax(property3), "/");
		if ( !property4[0] ) copy(property4, charsmax(property4), "/");
		
		max_size = size_max[0] + size_max[1] + size_max[2];
		
		if ( max_size > 128.0 )		size = LARGE;
		else if ( max_size > 64.0 )	size = NORMAL;
		else if ( max_size > 36.0 )	size = POLE;
		else				size = SMALL;
		
		formatex(data, charsmax(data), "%c %f %f %f %f %f %f %d ^"%s^" ^"%s^" ^"%s^" ^"%s^" ^"%s^" ^"%s^" ^n",\
			g_block_save_ids[block_type],\
			origin[0],\
			origin[1],\
			origin[2],\
			angles[0],\
			angles[1],\
			angles[2],\
			size,\
			property1,\
			property2,\
			property3,\
			property4,\
			szCreator,\
			szLastMover
			);
		fputs(file, data);
		
		++block_count;
	}
	
	iEntity = -1;
	while ( ( iEntity = find_ent_by_class(iEntity, g_destination_classname) ) )
	{
		tele = entity_get_int(iEntity, EV_INT_iuser1);
		if ( tele )
		{
			entity_get_vector(tele, EV_VEC_origin, tele_start);
			entity_get_vector(iEntity, EV_VEC_origin, tele_end);
			
			formatex(data, charsmax(data), "* %f %f %f %f %f %f^n",\
				tele_start[0],\
				tele_start[1],\
				tele_start[2],\
				tele_end[0],\
				tele_end[1],\
				tele_end[2]
				);
			fputs(file, data);
			
			++tele_count;
		}
	}
	
	static name[32];
	get_user_name(id, name, charsmax(name));
	
	for ( new i = 1; i <= g_max_players; ++i )
	{
		if ( get_bit(g_connected, i)
		&& ( get_bit(g_admin, i) ) )
		{
			BCM_Print(i, "^3%s^1 saved^3 %d Block%s^1 and^3 %d Teleport%s^1 Entites:^3 %d^1 Config:^3 %s", name, block_count, block_count == 1 ? g_blank : "s", tele_count, tele_count == 1 ? g_blank : "s", entity_count(), g_config_names[g_current_config]);
		}
	}
	
	fclose(file);
	return PLUGIN_HANDLED;
}

LoadBlocks(id)
{
	if ( id != 0 && !get_bit(g_admin, id) )
	{
		console_print(id, "You have no access to that command");
		return PLUGIN_HANDLED;
	}
	DeleteAll(id, false);
	g_load_start_line = 0;
	set_task(LOADING_DELAY, "TaskLoad");
				
	if ( 1 <= id <= g_max_players )
	{
		static name[32];
		get_user_name(id, name, charsmax(name));
		
		for ( new i = 1; i <= g_max_players; ++i )
		{
			if ( !get_bit(g_connected, i)
			|| !get_bit(g_admin, i) ) continue;
				
			BCM_Print(i, "%s loaded is loading config: %s (%s)", name, g_config_names[g_current_config], g_new_file);
			BCM_Print(i, "Wait 1.5 seconds for it to load.");
		}
	}
	
	return PLUGIN_HANDLED;
}

newLoad(id)
{
	if ( id != 0 && !get_bit(g_admin, id) )
	{
		console_print(id, "You have no access to that command");
		return PLUGIN_HANDLED;
	}
	else if ( !file_exists(g_file)
	&& 1 <= id <= g_max_players )
	{
		BCM_Print(id, "Couldn't find file:^3 %s", g_file);
		return PLUGIN_HANDLED;
	}
	
	if ( 1 <= id <= g_max_players )
	{
		DeleteAll(id, false);
		//g_load_start_line = 0;
	}
	
	new file;
	new data[256];
	new block_count;
	new tele_count;
	new type[2];
	new block_size[17];
	new origin_x[17];
	new origin_y[17];
	new origin_z[17];
	new angel_x[17];
	new angel_y[17];
	new angel_z[17];
	new block_type;
	new axis;
	new size;
	new property1[5], property2[5], property3[5], property4[5];
	new Float:origin[3];
	new Float:angles[3];
	new szCreator[32], szLastMover[32];
	//new count = 0;
	
	file = fopen(g_new_file, "rt");
	
	block_count = 0;
	tele_count = 0;
	
	while ( !feof(file) )
	{
		type = g_blank;
		fgets(file, data, charsmax(data));
		parse(data,\
			type, charsmax(type),\
			origin_x, charsmax(origin_x),\
			origin_y, charsmax(origin_y),\
			origin_z, charsmax(origin_z),\
			angel_x, charsmax(angel_x),\
			angel_y, charsmax(angel_y),\
			angel_z, charsmax(angel_z),\
			block_size, charsmax(block_size),\
			property1, charsmax(property1),\
			property2, charsmax(property2),\
			property3, charsmax(property3),\
			property4, charsmax(property4),\
			szCreator, charsmax(szCreator),\
			szLastMover, charsmax(szLastMover)
			);
		
		origin[0] =	str_to_float(origin_x);
		origin[1] =	str_to_float(origin_y);
		origin[2] =	str_to_float(origin_z);
		angles[0] =	str_to_float(angel_x);
		angles[1] =	str_to_float(angel_y);
		angles[2] =	str_to_float(angel_z);
		size =		str_to_num(block_size);
		
		if ( strlen(type) > 0 )
		{
			if ( type[0] != '*' )
			{
				if ( angles[0] == 90.0 && angles[1] == 0.0 && angles[2] == 0.0 )
				{
					axis = X;
				}
				else if ( angles[0] == 90.0 && angles[1] == 0.0 && angles[2] == 90.0 )
				{
					axis = Y;
				}
				else
				{
					axis = Z;
				}
			}
			
			switch ( type[0] )
			{
				case 'A': block_type = PLATFORM;
				case 'B': block_type = BHOP;
				case 'C': block_type = DAMAGE;
				case 'D': block_type = HEALER;
				case 'E': block_type = NO_FALL_DAMAGE;
				case 'F': block_type = ICE;
				case 'G': block_type = TRAMPOLINE;
				case 'H': block_type = SPEED_BOOST;
				case 'I': block_type = DEATH;
				case 'J': block_type = LOW_GRAVITY;
				case 'K': block_type = SLAP;
				case 'L': block_type = HONEY;
				case 'M': block_type = CT_BARRIER;
				case 'N': block_type = T_BARRIER;
				case 'O': block_type = GLASS;
				case 'P': block_type = NO_SLOW_DOWN_BHOP;
				case 'Q': block_type = DELAYED_BHOP;
				case 'R': block_type = INVINCIBILITY;
				case 'S': block_type = STEALTH;
				case 'T': block_type = BOOTS_OF_SPEED;
				case 'U': block_type = WEAPON_BLOCK;
				case '3': block_type = DUCK_BLOCK;
				case 'X': block_type = XP;
				case 'Y': block_type = BLIND_TRAP;
				case 'Z': block_type = SUPERMAN;
				case '8': block_type = MONEY;
				case '4': block_type = BOUNCE_DEATH;
				case '5': block_type = TELEPORT;
				case '6': block_type = DESTINATION;
				case '7': block_type = MAGIC_CARPET;
                                case 'W': block_type = HE;
                                case '9': block_type = FLASH;
                                case '1': block_type = SMOKE;
			        case '%': block_type = M4A1;
                                case '#': block_type = M3;
                                case '@': block_type = AWP;
                                case 'a': block_type = DEAGLE;
                                case 'b': block_type = USP;
                                case 'c': block_type = GLOCK;
                                case 'd': block_type = AK47;
                                case 'g': block_type = LIGHT;
                                case 'f': block_type = QUAKE;
                                case 'h': block_type = MUZA;
                                case '*':
				{
					CreateTeleport(0, TELEPORT_START, origin);
					CreateTeleport(0, TELEPORT_DESTINATION, angles);
					
					++tele_count;
				}
			}
			
			if ( type[0] != '*' && type[0] != '!' )
			{
				CreateBlock(0, block_type, origin, axis, size, property1, property2, property3, property4, szCreator, szLastMover);
				
				++block_count;
			}
		}
	}
	
	fclose(file);
	
	if ( 1 <= id <= g_max_players )
	{
		static name[32];
		get_user_name(id, name, charsmax(name));
		
		for ( new i = 1; i <= g_max_players; ++i )
		{
			if ( !get_bit(g_connected, i)
			|| !get_bit(g_admin, i) ) continue;
			
			BCM_Print(i, "^1%s^3 loaded^1 %d block%s^3,^1 %d teleport%s^3! Total entites in map:^1 %d", name, block_count, block_count == 1 ? g_blank : "s", tele_count, tele_count == 1 ? g_blank : "s", entity_count());
		}
	}
	
	return PLUGIN_HANDLED;
}

public TaskLoad()
{
	if (file_exists(g_new_file))
	{
		new file = fopen(g_new_file, "rt");
		new data[256];
		new block_count = 0;
		new tele_count = 0;
		new type[2];
		new block_size[17];
		new origin_x[17];
		new origin_y[17];
		new origin_z[17];
		new angel_x[17];
		new angel_y[17];
		new angel_z[17];
		new block_type;
		new axis;
		new size;
		new property1[5], property2[5], property3[5], property4[5];
		new Float:origin[3];
		new Float:angles[3];
		new szCreator[32], szLastMover[32];
		new count = 0;
		
		while ( !feof(file) )
		{
			type = g_blank;
			
			fgets(file, data, charsmax(data));
			if(++count < g_load_start_line) {
				continue;
			}
			if(count >= g_load_start_line + 25) {
				g_load_start_line = count;
				set_task(0.5, "TaskLoad");
				fclose(file);
				return;
				
			}
			
			parse(data,\
				type, charsmax(type),\
				origin_x, charsmax(origin_x),\
				origin_y, charsmax(origin_y),\
				origin_z, charsmax(origin_z),\
				angel_x, charsmax(angel_x),\
				angel_y, charsmax(angel_y),\
				angel_z, charsmax(angel_z),\
				block_size, charsmax(block_size),\
				property1, charsmax(property1),\
				property2, charsmax(property2),\
				property3, charsmax(property3),\
				property4, charsmax(property4),\
				szCreator, charsmax(szCreator),\
				szLastMover, charsmax(szLastMover)
				);
			
			origin[0] =	str_to_float(origin_x);
			origin[1] =	str_to_float(origin_y);
			origin[2] =	str_to_float(origin_z);
			angles[0] =	str_to_float(angel_x);
			angles[1] =	str_to_float(angel_y);
			angles[2] =	str_to_float(angel_z);
			size =		str_to_num(block_size);
			
			if ( strlen(type) > 0 )
			{
				if ( type[0] != '*' )
				{
					if ( angles[0] == 90.0 && angles[1] == 0.0 && angles[2] == 0.0 )
					{
						axis = X;
					}
					else if ( angles[0] == 90.0 && angles[1] == 0.0 && angles[2] == 90.0 )
					{
						axis = Y;
					}
					else
					{
						axis = Z;
					}
				}
				
				switch ( type[0] )
				{
					case 'A': block_type = PLATFORM;
					case 'B': block_type = BHOP;
					case 'C': block_type = DAMAGE;
					case 'D': block_type = HEALER;
					case 'E': block_type = NO_FALL_DAMAGE;
					case 'F': block_type = ICE;
					case 'G': block_type = TRAMPOLINE;
					case 'H': block_type = SPEED_BOOST;
					case 'I': block_type = DEATH;
					case 'J': block_type = LOW_GRAVITY;
					case 'K': block_type = SLAP;
					case 'L': block_type = HONEY;
					case 'M': block_type = CT_BARRIER;
					case 'N': block_type = T_BARRIER;
					case 'O': block_type = GLASS;
					case 'P': block_type = NO_SLOW_DOWN_BHOP;
					case 'Q': block_type = DELAYED_BHOP;
					case 'R': block_type = INVINCIBILITY;
					case 'S': block_type = STEALTH;
					case 'T': block_type = BOOTS_OF_SPEED;
					case 'U': block_type = WEAPON_BLOCK;
					case '3': block_type = DUCK_BLOCK;
					case 'X': block_type = XP;
					case 'Y': block_type = BLIND_TRAP;
					case 'Z': block_type = SUPERMAN;
					case '8': block_type = MONEY;
					case '4': block_type = BOUNCE_DEATH;
					case '5': block_type = TELEPORT;
					case '6': block_type = DESTINATION;
					case '7': block_type = MAGIC_CARPET;

					case '*':
					{
						CreateTeleport(0, TELEPORT_START, origin);
						CreateTeleport(0, TELEPORT_DESTINATION, angles);
						
						++tele_count;
					}
					default:
					{
						log_amx("%sInvalid block type: %c in: %s", PLUGIN_PREFIX, type[0], g_file);
						
						--block_count;
					}
					
				}
				
				if ( type[0] != '*' && type[0] != '!' )
				{
					CreateBlock(0, block_type, origin, axis, size, property1, property2, property3, property4, szCreator, szLastMover);
					
					++block_count;
				}
	
			}
		}
		fclose(file);
		BCM_Print(0, "^1The config is^4 done loading^1 Good Luck^3 &^1 Have Fun^3!");
		set_task(0.1, "checkstuck");
	}
}

bool:IsStrFloat(string[])
{
	new len = strlen(string);
	for ( new i = 0; i < len; i++ )
	{
		switch ( string[i] )
		{
			case '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '.', '-', '*':continue;
			default:																						return false;
		}
	}
	
	return true;
}

ResetPlayer(id)
{
	clear_bit(g_no_fall_damage, id);
	clear_bit(g_ice, id);
	clear_bit(g_low_gravity, id);
	clear_bit(g_no_slow_down, id);
	clear_bit(g_block_status, id);
	clear_bit(g_has_hud_text, id);
	clear_bit(g_awp_used, id);
	clear_bit(g_deagle_used, id);
	clear_bit(g_usp_used, id);
	clear_bit(g_tmp_used, id);
	clear_bit(g_aug_used, id);
	clear_bit(g_m3_used, id);
	clear_bit(g_mac10_used, id);
	clear_bit(g_ak47_used, id);
	clear_bit(g_c4_used, id);
        clear_bit(g_hegrenade_used, id);
	clear_bit(g_smokegrenade_used, id);
	clear_bit(g_flashgrenade_used, id);
	clear_bit(g_money_used, id);
	clear_bit(g_bootsofspeed, id);
	
	g_slap[id][0] =			0;
	g_honey[id] = 0;
	g_boots_of_speed[id] =		0;
	
	g_next_damage_time[id] =	0.0;
	g_next_heal_time[id] =		0.0;
	g_invincibility_time_out[id] =	0.0;
	g_invincibility_next_use[id] =	0.0;
	g_stealth_time_out[id] =	0.0;
	g_stealth_next_use[id] =	0.0;
	g_boots_of_speed_time_out[id] =	0.0;
	g_boots_of_speed_next_use[id] =	0.0;
	g_superman_time_out[id] = 	0.0;
	g_superman_next_use[id] = 	0.0;
	g_blind_next_use[id] = 		0.0;
        g_next_xp_time[id] =		0.0;
	
	new task_id = TASK_INVINCIBLE + id;
	if ( task_exists(task_id) )
		remove_task(task_id);
	
	task_id = TASK_STEALTH + id;
	if ( task_exists(task_id) )	
		remove_task(task_id);
	
	task_id = TASK_BOOTSOFSPEED + id;
	if ( task_exists(task_id) )	
		remove_task(task_id);
	
	task_id = TASK_SUPERMAN + id;
	if ( task_exists(task_id) )
		TaskRemoveSuperman(id);
	
	if ( get_bit(g_connected, id) )
		set_user_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderNormal, 255);
	
	set_bit(g_reseted, id);
}

ResetMaxspeed(id)
{
	static Float:max_speed;
	
	switch ( get_user_weapon(id) )
	{
		case CSW_SG550, CSW_AWP, CSW_G3SG1:				max_speed = 210.0;
		case CSW_M249:							max_speed = 220.0;
		case CSW_AK47:							max_speed = 221.0;
		case CSW_M3, CSW_M4A1:					        max_speed = 230.0;
		case CSW_SG552:							max_speed = 235.0;
		case CSW_XM1014, CSW_AUG, CSW_GALIL, CSW_FAMAS:			max_speed = 240.0;
		case CSW_P90:							max_speed = 245.0;
		case CSW_HEGRENADE, CSW_FLASHBANG, CSW_SMOKEGRENADE, CSW_KNIFE: 	max_speed = 250.0;
		case CSW_SCOUT:							max_speed = 260.0;
		default:							max_speed = 250.0;
	}
	entity_set_float(id, EV_FL_maxspeed, max_speed);
}

BCM_Print( const client, const szMessageFormat[ ], any:... )
{
	static szMessage[ 192 ], iLen;
	iLen = formatex( szMessage, 191, "^4[%s %s] ", PLUGIN_PREFIX, PLUGIN_VERSION );
	vformat( szMessage[ iLen ], 191 - iLen, szMessageFormat, 3 );
	
	if( client )
	{
		UTIL_SayText( client, client, szMessage );
	}
	else
	{
		static i;
		for( i = 1; i <= g_max_players; i++ )
		{
			if( is_user_connected( i ) )
			{
				UTIL_SayText( i, i, szMessage );
			}
		}
	}
}

DoEnterValue(id, type) {
	g_value_types[id] = type;
	client_cmd(id, "messagemode Enter_Value");
}

GetConfigFileName(index, filename[]) {
	if(index == 0) {
		formatex(filename, 96, "%s/%s.bm", Dir, Map);
	} else {
		formatex(filename, 96, "%s/%s.%d.bm", Dir, Map, index);
	}
}

UTIL_SayText( const iReceiver, const iSender, const szMessage[ ] )
{
	message_begin( iReceiver ? MSG_ONE_UNRELIABLE : MSG_BROADCAST, g_iMsgId_SayText, _, iReceiver );
	write_byte( iSender );
	write_string( szMessage );
	message_end( );
}

new const Float:size[][3] = {
	{0.0, 0.0, 1.0}, {0.0, 0.0, -1.0}, {0.0, 1.0, 0.0}, {0.0, -1.0, 0.0}, {1.0, 0.0, 0.0}, {-1.0, 0.0, 0.0}, {-1.0, 1.0, 1.0}, {1.0, 1.0, 1.0}, {1.0, -1.0, 1.0}, {1.0, 1.0, -1.0}, {-1.0, -1.0, 1.0}, {1.0, -1.0, -1.0}, {-1.0, 1.0, -1.0}, {-1.0, -1.0, -1.0},
	{0.0, 0.0, 2.0}, {0.0, 0.0, -2.0}, {0.0, 2.0, 0.0}, {0.0, -2.0, 0.0}, {2.0, 0.0, 0.0}, {-2.0, 0.0, 0.0}, {-2.0, 2.0, 2.0}, {2.0, 2.0, 2.0}, {2.0, -2.0, 2.0}, {2.0, 2.0, -2.0}, {-2.0, -2.0, 2.0}, {2.0, -2.0, -2.0}, {-2.0, 2.0, -2.0}, {-2.0, -2.0, -2.0},
	{0.0, 0.0, 3.0}, {0.0, 0.0, -3.0}, {0.0, 3.0, 0.0}, {0.0, -3.0, 0.0}, {3.0, 0.0, 0.0}, {-3.0, 0.0, 0.0}, {-3.0, 3.0, 3.0}, {3.0, 3.0, 3.0}, {3.0, -3.0, 3.0}, {3.0, 3.0, -3.0}, {-3.0, -3.0, 3.0}, {3.0, -3.0, -3.0}, {-3.0, 3.0, -3.0}, {-3.0, -3.0, -3.0},
	{0.0, 0.0, 4.0}, {0.0, 0.0, -4.0}, {0.0, 4.0, 0.0}, {0.0, -4.0, 0.0}, {4.0, 0.0, 0.0}, {-4.0, 0.0, 0.0}, {-4.0, 4.0, 4.0}, {4.0, 4.0, 4.0}, {4.0, -4.0, 4.0}, {4.0, 4.0, -4.0}, {-4.0, -4.0, 4.0}, {4.0, -4.0, -4.0}, {-4.0, 4.0, -4.0}, {-4.0, -4.0, -4.0},
	{0.0, 0.0, 5.0}, {0.0, 0.0, -5.0}, {0.0, 5.0, 0.0}, {0.0, -5.0, 0.0}, {5.0, 0.0, 0.0}, {-5.0, 0.0, 0.0}, {-5.0, 5.0, 5.0}, {5.0, 5.0, 5.0}, {5.0, -5.0, 5.0}, {5.0, 5.0, -5.0}, {-5.0, -5.0, 5.0}, {5.0, -5.0, -5.0}, {-5.0, 5.0, -5.0}, {-5.0, -5.0, -5.0}
};

public checkstuck() {
	static players[32], pnum, player;
	get_players(players, pnum);
	static Float:origin[3];
	static Float:mins[3], hull;
	static Float:vec[3];
	static o,i;
	for(i=0; i<pnum; i++){
		player = players[i];
		if (get_bit(g_connected, player) && get_bit(g_alive, player)) {
			pev(player, pev_origin, origin);
			hull = pev(player, pev_flags) & FL_DUCKING ? HULL_HEAD : HULL_HUMAN;
			if (!is_hull_vacant(origin, hull,player) && !get_user_noclip(player) && !(pev(player,pev_solid) & SOLID_NOT)) {
				set_bit(stuck, player);
				if(get_bit(stuck, player)) {
					pev(player, pev_mins, mins);
					vec[2] = origin[2];
					for (o=0; o < sizeof size; ++o) {
						vec[0] = origin[0] - mins[0] * size[o][0];
						vec[1] = origin[1] - mins[1] * size[o][1];
						vec[2] = origin[2] - mins[2] * size[o][2];
						if (is_hull_vacant(vec, hull,player)) {
							engfunc(EngFunc_SetOrigin, player, vec);
							set_pev(player,pev_velocity,{0.0,0.0,0.0});
							o = sizeof size;
						}
					}
				}
			}
			else
			{
				clear_bit(stuck, player);
			}
		}
	}
}

stock bool:is_hull_vacant(const Float:origin[3], hull,id) {
	static tr;
	engfunc(EngFunc_TraceHull, origin, origin, 0, hull, id, tr);
	if (!get_tr2(tr, TR_StartSolid) || !get_tr2(tr, TR_AllSolid)) //get_tr2(tr, TR_InOpen))
		return true;
	
	return false;
}
[/code]

bollnas_blockmaker
[code]native hnsxp_get_user_xp(client);

native hnsxp_set_user_xp(client, xp);

stock hnsxp_add_user_xp(client, xp)
{
	return hnsxp_set_user_xp(client, hnsxp_get_user_xp(client) + xp);
}

stock hnsxp_sub_user_xp(client, xp)
{
	return hnsxp_set_user_xp(client, hnsxp_get_user_xp(client) - xp);
}


#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <engine>
#include <fakemeta>
#include <hamsandwich>
#include <fun>

#pragma semicolon 1

#define PLUGIN_NAME				"Bollnas Course maker"
#define PLUGIN_VERSION				"5.48"
#define PLUGIN_AUTHOR				"Reverse"
#define PLUGIN_PREFIX				"BCM"

new const g_blank[] =				"";
new const g_a[] =				"a";
new const g_b[] =				"b";

new const g_block_classname[] =			"BCM_Block";
new const g_start_classname[] =			"BCM_TeleportStart";
new const g_destination_classname[] =		"BCM_TeleportDestination";
new const g_light_classname[] =			"BCM_Light";

new const g_model_platform[] =			"models/ExecuteGaming/Normal/Platform.mdl";
new const g_model_bunnyhop[] =			"models/ExecuteGaming/Normal/Bunnyhop.mdl";
new const g_model_damage[] =			"models/ExecuteGaming/Normal/Damage.mdl";
new const g_model_healer[] =			"models/ExecuteGaming/Normal/Healer.mdl";
new const g_model_no_fall_damage[] =		"models/ExecuteGaming/Normal/NoFallDamage.mdl";
new const g_model_ice[] =			"models/ExecuteGaming/Normal/Ice.mdl";
new const g_model_trampoline[] =			"models/ExecuteGaming/Normal/Trampoline.mdl";
new const g_model_speed_boost[] =		"models/ExecuteGaming/Normal/SpeedBoost.mdl";
new const g_model_death[] =			"models/ExecuteGaming/Normal/Death.mdl";
new const g_model_low_gravity[] =		"models/ExecuteGaming/Normal/LowGravity.mdl";
new const g_model_slap[] =			"models/ExecuteGaming/Normal/Slap.mdl";
new const g_model_honey[] =			"models/ExecuteGaming/Normal/Honey.mdl";
new const g_model_ct_barrier[] =			"models/ExecuteGaming/Normal/CT_Barrier.mdl";
new const g_model_t_barrier[] =			"models/ExecuteGaming/Normal/T_Barrier.mdl";
new const g_model_glass[] =			"models/ExecuteGaming/Normal/Glass.mdl";
new const g_model_no_slow_down_bunnyhop[] =	"models/ExecuteGaming/Normal/NoSlowDown_Bunnyhop.mdl";
new const g_model_delayed_bunnyhop[] =		"models/ExecuteGaming/Normal/Delayed_Bunnyhop.mdl";
new const g_model_invincibility[] =		"models/ExecuteGaming/Normal/Invincibility.mdl";
new const g_model_stealth[] =			"models/ExecuteGaming/Normal/Stealth.mdl";
new const g_model_boots_of_speed[] =		"models/ExecuteGaming/Normal/BootsOfSpeed.mdl";
new const g_model_xpblock[] =			"models/ExecuteGaming/Normal/xpblock.mdl";

new const g_sprite_light[] =			"sprites/ExecuteGaming/Light.spr";

new const g_sprite_teleport_start[] =		"sprites/ExecuteGaming/Teleport_Start.spr";
new const g_sprite_teleport_destination[] =	"sprites/ExecuteGaming/Teleport_End.spr";

new const g_sound_invincibility[] =		"warcraft3/divineshield.wav";
new const g_sound_stealth[] =			"warcraft3/ExecuteGaming_Stealth.wav";
new const g_sound_boots_of_speed[] =		"warcraft3/ExecuteGaming_BootsOfSpeed.wav";

new g_sprite_beam;
new bool:g_xpblock_used[32];

enum ( <<= 1 )
{
	B1 = 1,
	B2,
	B3,
	B4,
	B5,
	B6,
	B7,
	B8,
	B9,
	B0
};

enum
{
	K1,
	K2,
	K3,
	K4,
	K5,
	K6,
	K7,
	K8,
	K9,
	K0
};

enum
{
	CHOICE_DELETE,
	CHOICE_LOAD
};

enum
{
	X,
	Y,
	Z
};

enum ( += 1000 )
{
	TASK_SPRITE = 1000,
	TASK_SOLID,
	TASK_SOLIDNOT,
	TASK_ICE,
	TASK_HONEY,
	TASK_NOSLOWDOWN,
	TASK_INVINCIBLE,
	TASK_STEALTH,
	TASK_BOOTSOFSPEED
};

new g_file[64];

new g_keys_main_menu;
new g_keys_block_menu;
new g_keys_block_selection_menu;
new g_keys_properties_menu;
new g_keys_move_menu;
new g_keys_teleport_menu;
new g_keys_light_menu;
new g_keys_light_properties_menu;
new g_keys_options_menu;
new g_keys_choice_menu;
new g_keys_commands_menu;

new g_main_menu[256];
new g_block_menu[256];
new g_move_menu[256];
new g_teleport_menu[256];
new g_light_menu[128];
new g_light_properties_menu[256];
new g_options_menu[256];
new g_choice_menu[128];
new g_commands_menu[256];

new g_viewmodel[33][32];

new bool:g_connected[33];
new bool:g_alive[33];
new bool:g_admin[33];
new bool:g_gived_access[33];
new bool:g_snapping[33];
new bool:g_viewing_properties_menu[33];
new bool:g_viewing_light_properties_menu[33];
new bool:g_viewing_commands_menu[33];
new bool:g_no_fall_damage[33];
new bool:g_ice[33];
new bool:g_low_gravity[33];
new bool:g_no_slow_down[33];
new bool:g_has_hud_text[33];
new bool:g_block_status[33];
new bool:g_noclip[33];
new bool:g_godmode[33];
new bool:g_all_godmode;
new bool:g_has_checkpoint[33];
new bool:g_checkpoint_duck[33];
new bool:g_reseted[33];

new g_selected_block_size[33];
new g_choice_option[33];
new g_block_selection_page[33];
new g_teleport_start[33];
new g_grabbed[33];
new g_grouped_blocks[33][256];
new g_group_count[33];
new g_property_info[33][2];
new g_light_property_info[33][2];
new g_slap_times[33];
new g_honey[33];
new g_boots_of_speed[33];

new Float:g_grid_size[33];
new Float:g_snapping_gap[33];
new Float:g_grab_offset[33][3];
new Float:g_grab_length[33];
new Float:g_next_damage_time[33];
new Float:g_next_heal_time[33];
new Float:g_invincibility_time_out[33];
new Float:g_invincibility_next_use[33];
new Float:g_stealth_time_out[33];
new Float:g_stealth_next_use[33];
new Float:g_boots_of_speed_time_out[33];
new Float:g_boots_of_speed_next_use[33];
new Float:g_set_velocity[33][3];
new Float:g_checkpoint_position[33][3];

new g_cvar_textures;

new g_max_players;

enum
{
	PLATFORM,
	BUNNYHOP,
	DAMAGE,
	HEALER,
	NO_FALL_DAMAGE,
	ICE,
	TRAMPOLINE,
	SPEED_BOOST,
	DEATH,
	LOW_GRAVITY,
	SLAP,
	HONEY,
	CT_BARRIER,
	T_BARRIER,
	GLASS,
	NO_SLOW_DOWN_BUNNYHOP,
	DELAYED_BUNNYHOP,
	INVINCIBILITY,
	STEALTH,
	BOOTS_OF_SPEED,
	XPBLOCK,
	
	TOTAL_BLOCKS
};

enum
{
	TELEPORT_START,
	TELEPORT_DESTINATION
};

enum
{
	NORMAL,
	TINY,
	LARGE
};

enum
{
	NORMAL,
	GLOWSHELL,
	TRANSCOLOR,
	TRANSALPHA,
	TRANSWHITE
};

new g_selected_block_type[TOTAL_BLOCKS];
new g_render[TOTAL_BLOCKS];
new g_red[TOTAL_BLOCKS];
new g_green[TOTAL_BLOCKS];
new g_blue[TOTAL_BLOCKS];
new g_alpha[TOTAL_BLOCKS];

new const g_block_names[TOTAL_BLOCKS][] =
{
	"Platform",
	"Bunnyhop",
	"Damage",
	"Healer",
	"No Fall Damage",
	"Ice",
	"Trampoline",
	"Speed Boost",
	"Death",
	"Low Gravity",
	"Slap",
	"Honey",
	"CT Barrier",
	"T Barrier",
	"Glass",
	"No Slow Down Bunnyhop",
	"Delayed Bunnyhop",
	"Invincibility",
	"Stealth",
	"Boots Of Speed",
	"XP Block"
};

new const g_property1_name[TOTAL_BLOCKS][] =
{
	"",
	"No Fall Damage",
	"Damage Per Interval",
	"Health Per Interval",
	"",
	"",
	"Upward Speed",
	"Forward Speed",
	"",
	"Gravity",
	"Hardness",
	"Speed In Honey",
	"",
	"",
	"",
	"No Fall Damage",
	"Delay Before Dissapear",
	"Invincibility Time",
	"Stealth Time",
	"Boots Of Speed Time",
	"XP To Give"
};

new const g_property1_default_value[TOTAL_BLOCKS][] =
{
	"",
	"0",
	"5",
	"1",
	"",
	"",
	"500",
	"1000",
	"",
	"200",
	"2",
	"75",
	"",
	"",
	"",
	"0",
	"1",
	"10",
	"10",
	"10",
	"50"
};

new const g_property2_name[TOTAL_BLOCKS][] =
{
	"",
	"",
	"Interval Between Damage",
	"Interval Between Heals",
	"",
	"",
	"",
	"Upward Speed",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"Delay After Usage",
	"Delay After Usage",
	"Delay After Usage",
	""
};

new const g_property2_default_value[TOTAL_BLOCKS][] =
{
	"",
	"",
	"0.5",
	"0.5",
	"",
	"",
	"",
	"200",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"60",
	"60",
	"60",
	""
};

new const g_property3_name[TOTAL_BLOCKS][] =
{
	"",
	"Transparency",
	"Transparency",
	"Transparency",
	"Transparency",
	"Transparency",
	"Transparency",
	"Transparency",
	"Transparency",
	"Transparency",
	"Transparency",
	"Transparency",
	"Transparency",
	"Transparency",
	"",
	"Transparency",
	"Transparency",
	"",
	"",
	"Speed",
	"Transparency"
};

new const g_property3_default_value[TOTAL_BLOCKS][] =
{
	"",
	"255",
	"255",
	"255",
	"255",
	"255",
	"255",
	"255",
	"255",
	"255",
	"255",
	"255",
	"255",
	"255",
	"",
	"255",
	"255",
	"",
	"",
	"400",
	"255"
};

new const g_property4_name[TOTAL_BLOCKS][] =
{
	"",
	"On Top Only",
	"On Top Only",
	"On Top Only",
	"",
	"",
	"On Top Only",
	"On Top Only",
	"On Top Only",
	"On Top Only",
	"On Top Only",
	"On Top Only",
	"On Top Only",
	"On Top Only",
	"",
	"On Top Only",
	"On Top Only",
	"On Top Only",
	"On Top Only",
	"On Top Only",
	"On Top Only"
};

new const g_property4_default_value[TOTAL_BLOCKS][] =
{
	"",
	"0",
	"1",
	"1",
	"",
	"",
	"0",
	"0",
	"1",
	"0",
	"1",
	"0",
	"0",
	"0",
	"",
	"0",
	"0",
	"1",
	"1",
	"1",
	"1"
};

new const g_block_save_ids[TOTAL_BLOCKS] =
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
	'U'
};

new g_block_models[TOTAL_BLOCKS][256];

new g_block_selection_pages_max;

public plugin_precache()
{
	g_block_models[PLATFORM] =		g_model_platform;
	g_block_models[BUNNYHOP] =		g_model_bunnyhop;
	g_block_models[DAMAGE] =		g_model_damage;
	g_block_models[HEALER] =		g_model_healer;
	g_block_models[NO_FALL_DAMAGE] =	g_model_no_fall_damage;
	g_block_models[ICE] =			g_model_ice;
	g_block_models[TRAMPOLINE] =		g_model_trampoline;
	g_block_models[SPEED_BOOST] =		g_model_speed_boost;
	g_block_models[DEATH] =			g_model_death;
	g_block_models[LOW_GRAVITY] =		g_model_low_gravity;
	g_block_models[SLAP] =			g_model_slap;
	g_block_models[HONEY] =			g_model_honey;
	g_block_models[CT_BARRIER] =		g_model_ct_barrier;
	g_block_models[T_BARRIER] =		g_model_t_barrier;
	g_block_models[GLASS] =			g_model_glass;
	g_block_models[NO_SLOW_DOWN_BUNNYHOP] =	g_model_no_slow_down_bunnyhop;
	g_block_models[DELAYED_BUNNYHOP] =	g_model_delayed_bunnyhop;
	g_block_models[INVINCIBILITY] =		g_model_invincibility;
	g_block_models[STEALTH] =		g_model_stealth;
	g_block_models[BOOTS_OF_SPEED] =	g_model_boots_of_speed;
	g_block_models[XPBLOCK] =		g_model_xpblock;
	
	SetupBlockRendering(GLASS, TRANSWHITE, 255, 255, 255, 100);
	SetupBlockRendering(INVINCIBILITY, GLOWSHELL, 255, 255, 255, 16);
	SetupBlockRendering(STEALTH, TRANSWHITE, 255, 255, 255, 100);
	
	new block_model[256];
	for ( new i = 0; i < TOTAL_BLOCKS; ++i )
	{
		precache_model(g_block_models[i]);
		
		SetBlockModelName(block_model, g_block_models[i], "Tiny");
		precache_model(block_model);
		
		SetBlockModelName(block_model, g_block_models[i], "Large");
		precache_model(block_model);
	}
	
	precache_model(g_sprite_light);
	
	precache_model(g_sprite_teleport_start);
	precache_model(g_sprite_teleport_destination);
	g_sprite_beam = precache_model("sprites/zbeam4.spr");
	
	precache_sound(g_sound_invincibility);
	precache_sound(g_sound_stealth);
	precache_sound(g_sound_boots_of_speed);
}

public plugin_init()
{
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR);
	
	RegisterSayCmd("/rcm",			"CmdMainMenu");
	
	new command[32] =			"CmdShowInfo";
	RegisterSayCmd("BM",			command);
	RegisterSayCmd("Info",		        command);
	RegisterSayCmd("Help",		        command);
	
	command =				"CmdSaveCheckpoint";
	RegisterSayCmd("cp",			command);
	RegisterSayCmd("savecp",		command);
	RegisterSayCmd("checkpoint",		command);
	RegisterSayCmd("savecheckpoint",	command);
	
	command =				"CmdLoadCheckpoint";
	RegisterSayCmd("tp",			command);
	RegisterSayCmd("gocheck",		command);
	RegisterSayCmd("teleport",		command);
	RegisterSayCmd("loadcheck",		command);
	RegisterSayCmd("teleportcp",		command);
	RegisterSayCmd("gocheckpoint",		command);
	RegisterSayCmd("loadcheckpoint",	command);
	
	command =				"CmdReviveYourself";
	RegisterSayCmd("rs",			command);
	RegisterSayCmd("spawn",			command);
	RegisterSayCmd("revive",		command);
	RegisterSayCmd("respawn",		command);
	RegisterSayCmd("restart",		command);
	
	register_clcmd("BCM_SetProperty",	"SetPropertyBlock",	-1);
	register_clcmd("BCM_SetLightProperty",	"SetPropertyLight",	-1);
	register_clcmd("BCM_Revive",		"RevivePlayer",		-1);
	register_clcmd("BCM_GiveAccess",	"GiveAccess",		-1);
	
	command =				"CmdGrab";
	register_clcmd("+bcmGrab",		command,		-1, g_blank);
	register_clcmd("+bcmGrab",		command,		-1, g_blank);
	
	command =				"CmdRelease";
	register_clcmd("-bcmGrab",		command,		-1, g_blank);
	register_clcmd("-bcmGrab",		command,		-1, g_blank);
	
	CreateMenus();
	
	register_menucmd(register_menuid("BcmMainMenu"),		g_keys_main_menu,		"HandleMainMenu");
	register_menucmd(register_menuid("BcmBlockMenu"),		g_keys_block_menu,		"HandleBlockMenu");
	register_menucmd(register_menuid("BcmBlockSelectionMenu"),	g_keys_block_selection_menu,	"HandleBlockSelectionMenu");
	register_menucmd(register_menuid("BcmPropertiesMenu"),		g_keys_properties_menu,		"HandlePropertiesMenu");
	register_menucmd(register_menuid("BcmMoveMenu"),		g_keys_move_menu,		"HandleMoveMenu");
	register_menucmd(register_menuid("BcmTeleportMenu"),		g_keys_teleport_menu,		"HandleTeleportMenu");
	register_menucmd(register_menuid("BcmLightMenu"),		g_keys_light_menu,		"HandleLightMenu");
	register_menucmd(register_menuid("BcmLightPropertiesMenu"),	g_keys_light_properties_menu,	"HandleLightPropertiesMenu");
	register_menucmd(register_menuid("BcmOptionsMenu"),		g_keys_options_menu,		"HandleOptionsMenu");
	register_menucmd(register_menuid("BcmChoiceMenu"),		g_keys_choice_menu,		"HandleChoiceMenu");
	register_menucmd(register_menuid("BcmCommandsMenu"),		g_keys_commands_menu,		"HandleCommandsMenu");
	
	RegisterHam(Ham_Spawn,		"player",	"FwdPlayerSpawn",	1);
	RegisterHam(Ham_Killed,		"player",	"FwdPlayerKilled",	1);
	
	register_forward(FM_CmdStart,			"FwdCmdStart");
	
	register_think(g_light_classname,		"LightThink");
	
	register_event("CurWeapon",			"EventCurWeapon",	"be");
	
	register_message(get_user_msgid("StatusValue"),	"MsgStatusValue");
	
	g_cvar_textures =	register_cvar("BCM_Textures", "Reverse", 0, 0.0);
	
	g_max_players =		get_maxplayers();
	
	new dir[64];
	get_datadir(dir, charsmax(dir));
	
	new folder[64];
	formatex(folder, charsmax(folder), "/%s", PLUGIN_PREFIX);
	
	add(dir, charsmax(dir), folder);
	if ( !dir_exists(dir) ) mkdir(dir);
	
	new map[32];
	get_mapname(map, charsmax(map));
	
	formatex(g_file, charsmax(g_file), "%s/%s.%s", dir, map, PLUGIN_PREFIX);
}

public plugin_cfg()
{
	LoadBlocks(0);
}

public client_putinserver(id)
{
	g_connected[id] =			bool:!is_user_hltv(id);
	g_alive[id] =				false;
	
	g_admin[id] =				bool:access(id, ADMIN_MENU);
	g_gived_access[id] =			false;
	
	g_viewing_properties_menu[id] =		false;
	g_viewing_light_properties_menu[id] =	false;
	g_viewing_commands_menu[id] =		false;
	
	g_snapping[id] =			true;
	
	g_grid_size[id] =			1.0;
	g_snapping_gap[id] =			0.0;

	g_group_count[id] =			0;
	
	g_noclip[id] =				false;
	g_godmode[id] =				false;
	
	g_has_checkpoint[id] =			false;
	g_checkpoint_duck[id] =			false;
	
	g_reseted[id] =				false;
	
	ResetPlayer(id);
}

public client_disconnect(id)
{
	g_connected[id] =			false;
	g_alive[id] =				false;
	
	ClearGroup(id);
	
	if ( g_grabbed[id] )
	{
		if ( is_valid_ent(g_grabbed[id]) )
		{
			entity_set_int(g_grabbed[id], EV_INT_iuser2, 0);
		}
		
		g_grabbed[id] =			0;
	}
}

RegisterSayCmd(const command[], const handle[])
{
	static temp[64];
	
	register_clcmd(command, handle, -1, g_blank);
	
	formatex(temp, charsmax(temp), "say /bcm", command);
	register_clcmd(temp, handle, -1, g_blank);
	
	formatex(temp, charsmax(temp), "say_team /bcm", command);
	register_clcmd(temp, handle, -1, g_blank);
}

CreateMenus()
{
	g_block_selection_pages_max = floatround((float(TOTAL_BLOCKS) / 8.0), floatround_ceil);
	
	new size = charsmax(g_main_menu);
	add(g_main_menu, size, "\r[%s] \y%s \rv%s^n^n");
	add(g_main_menu, size, "\r1. \wBlock Menu^n");
	add(g_main_menu, size, "\r2. \wTeleport Menu^n");
	add(g_main_menu, size, "\r3. \wLight Menu^n");
	add(g_main_menu, size, "\r4. \wOptions Menu^n");
	add(g_main_menu, size, "\r5. \wCommands Menu^n^n");
	add(g_main_menu, size, "%s6. %sNoclip: %s^n");
	add(g_main_menu, size, "%s7. %sGodmode: %s^n^n");
	add(g_main_menu, size, "\r9. \wHelp^n");
	add(g_main_menu, size, "\r0. \wClose");
	g_keys_main_menu =		B1 | B2 | B3 | B4 | B5 | B6 | B7 | B9 | B0;
	
	size = charsmax(g_block_menu);
	add(g_block_menu, size, "\r[%s] \yBlock Menu^n^n");
	add(g_block_menu, size, "\r1. \wBlock Type: \y%s^n");
	add(g_block_menu, size, "\r2. \wBlock Size: \y%s^n^n");
	add(g_block_menu, size, "%s3. %sCreate^n");
	add(g_block_menu, size, "%s4. %sConvert^n");
	add(g_block_menu, size, "%s5. %sDelete^n");
	add(g_block_menu, size, "%s6. %sRotate^n");
	add(g_block_menu, size, "%s7. %sSet Properties^n");
	add(g_block_menu, size, "%s8. %sMove^n^n");
	add(g_block_menu, size, "\r0. \wBack");
	g_keys_block_menu =		B1 | B2 | B3 | B4 | B5 | B6 | B7 | B8 | B0;
	g_keys_block_selection_menu =	B1 | B2 | B3 | B4 | B5 | B6 | B7 | B8 | B9 | B0;
	g_keys_properties_menu =	B1 | B2 | B3 | B4 | B0;
	
	size = charsmax(g_move_menu);
	add(g_move_menu, size, "\r[%s] \yMove Menu^n^n");
	add(g_move_menu, size, "\r1. \wGrid Size: \y%.1f^n^n");
	add(g_move_menu, size, "\r2. \wZ\y+^n");
	add(g_move_menu, size, "\r3. \wZ\r-^n");
	add(g_move_menu, size, "\r4. \wX\y+^n");
	add(g_move_menu, size, "\r5. \wX\r-^n");
	add(g_move_menu, size, "\r6. \wY\y+^n");
	add(g_move_menu, size, "\r7. \wY\r-^n^n^n");
	add(g_move_menu, size, "\r0. \wBack");
	g_keys_move_menu =		B1 | B2 | B3 | B4 | B5 | B6 | B7 | B0;
	
	size = charsmax(g_teleport_menu);
	add(g_teleport_menu, size, "\r[%s] \yTeleport Menu^n^n");
	add(g_teleport_menu, size, "%s1. %sCreate Start^n");
	add(g_teleport_menu, size, "%s2. %sCreate Destination^n^n");
	add(g_teleport_menu, size, "%s3. %sDelete Teleport^n^n");
	add(g_teleport_menu, size, "%s4. %sSwap Start/Destination^n^n");
	add(g_teleport_menu, size, "%s5. %sShow Path^n^n^n");
	add(g_teleport_menu, size, "\r0. \wBack");
	g_keys_teleport_menu =		B1 | B2 | B3 | B4 | B5 | B0;
	
	size = charsmax(g_light_menu);
	add(g_light_menu, size, "\r[%s] \yLight Menu^n^n");
	add(g_light_menu, size, "%s1. %sCreate Light^n");
	add(g_light_menu, size, "%s2. %sDelete Light^n^n");
	add(g_light_menu, size, "%s3. %sSet Properties^n^n^n^n^n^n^n");
	add(g_light_menu, size, "\r0. \wBack");
	g_keys_light_menu =		B1 | B2 | B3 | B0;
	
	size = charsmax(g_light_properties_menu);
	add(g_light_properties_menu, size, "\r[%s] \ySet Properties^n^n");
	add(g_light_properties_menu, size, "\r1. \wRadius: \y%s^n");
	add(g_light_properties_menu, size, "\r2. \wColor Red: \y%s^n");
	add(g_light_properties_menu, size, "\r3. \wColor Green: \y%s^n");
	add(g_light_properties_menu, size, "\r4. \wColor Blue: \y%s^n^n^n^n^n^n^n");
	add(g_light_properties_menu, size, "\r0. \wBack");
	g_keys_light_properties_menu =	B1 | B2 | B3 | B4 | B0;
	
	size = charsmax(g_options_menu);
	add(g_options_menu, size, "\r[%s] \yOptions Menu^n^n");
	add(g_options_menu, size, "%s1. %sSnapping: %s^n");
	add(g_options_menu, size, "%s2. %sSnapping Gap: \y%.1f^n^n");
	add(g_options_menu, size, "%s3. %sAdd to Group^n");
	add(g_options_menu, size, "%s4. %sClear Group^n^n");
	add(g_options_menu, size, "%s5. %sDelete All^n");
	add(g_options_menu, size, "%s6. %sSave^n");
	add(g_options_menu, size, "%s7. %sLoad^n^n");
	add(g_options_menu, size, "\r0. \wBack");
	g_keys_options_menu =		B1 | B2 | B3 | B4 | B5 | B6 | B7 | B0;
	
	size = charsmax(g_choice_menu);
	add(g_choice_menu, size, "\y%s^n^n");
	add(g_choice_menu, size, "\r1. \wYes^n");
	add(g_choice_menu, size, "\r2. \wNo^n^n^n^n^n^n^n^n^n");
	g_keys_choice_menu =		B1 | B2;
	
	size = charsmax(g_commands_menu);
	add(g_commands_menu, size, "\r[%s] \yCommands Menu^n^n");
	add(g_commands_menu, size, "%s1. %sSave Checkpoint^n");
	add(g_commands_menu, size, "%s2. %sLoad Checkpoint^n^n");
	add(g_commands_menu, size, "%s3. %sRevive Yourself^n");
	add(g_commands_menu, size, "%s4. %sRevive Player^n");
	add(g_commands_menu, size, "%s5. %sRevive Everyone^n^n");
	add(g_commands_menu, size, "%s6. %s%s Godmode %s Everyone^n");
	add(g_commands_menu, size, "%s7. %sGive Access to %s^n^n");
	add(g_commands_menu, size, "\r0. \wBack");
	g_keys_commands_menu =		B1 | B2 | B3 | B4 | B5 | B6 | B7 | B0;
}

SetupBlockRendering(block_type, render_type, red, green, blue, alpha)
{
	g_render[block_type] =		render_type;
	g_red[block_type] =		red;
	g_green[block_type] =		green;
	g_blue[block_type] =		blue;
	g_alpha[block_type] =		alpha;
}

SetBlockModelName(model_target[256], model_source[256], const new_name[])
{
	model_target = model_source;
	replace(model_target, charsmax(model_target), "Normal", new_name);
}

public FwdPlayerSpawn(id)
{
	if ( !is_user_alive(id) ) return HAM_IGNORED;
	
	g_alive[id] =			true;
	
	if ( g_noclip[id] )		set_user_noclip(id, 1);
	if ( g_godmode[id] )		set_user_godmode(id, 1);
	
	if ( g_all_godmode )
	{
		for ( new i = 1; i <= g_max_players; i++ )
		{
			if ( !g_alive[i]
			|| g_admin[i]
			|| g_gived_access[i] ) continue;
			
			entity_set_float(i, EV_FL_takedamage, DAMAGE_NO);
		}
	}
	
	if ( g_viewing_commands_menu[id] ) ShowCommandsMenu(id);
	
	if ( !g_reseted[id] )
	{
		ResetPlayer(id);
	}
	
	g_reseted[id] =			false;
	
	return HAM_IGNORED;
}

public FwdPlayerKilled(id)
{
	g_alive[id] = bool:is_user_alive(id);
	
	ResetPlayer(id);
	
	if ( g_viewing_commands_menu[id] ) ShowCommandsMenu(id);
}

public FwdCmdStart(id, handle)
{
	if ( !g_connected[id] ) return FMRES_IGNORED;
	
	static buttons, oldbuttons;
	buttons =	get_uc(handle, UC_Buttons);
	oldbuttons =	entity_get_int(id, EV_INT_oldbuttons);
	
	if ( g_alive[id]
	&& ( buttons & IN_USE )
	&& !( oldbuttons & IN_USE )
	&& !g_has_hud_text[id] )
	{
		static ent, body;
		get_user_aiming(id, ent, body, 9999);
		
		if ( IsBlock(ent) )
		{
			static block_type;
			block_type = entity_get_int(ent, EV_INT_body);
			
			static property[5];
			
			static message[512], len;
			len = format(message, charsmax(message), "%s %s^nType: %s", PLUGIN_PREFIX, PLUGIN_VERSION, g_block_names[block_type]);
			
			if ( g_property1_name[block_type][0] )
			{
				GetProperty(ent, 1, property);
				
				if ( ( block_type == BUNNYHOP
					|| block_type == NO_SLOW_DOWN_BUNNYHOP )
				&& property[0] == '1' )
				{
					len += format(message[len], charsmax(message) - len, "^n%s", g_property1_name[block_type]);
				}
				else if ( block_type == SLAP )
				{
					len += format(message[len], charsmax(message) - len, "^n%s: %s", g_property1_name[block_type], property[0] == '3' ? "High" : property[0] == '2' ? "Medium" : "Low");
				}
				else if ( block_type != BUNNYHOP
				&& block_type != NO_SLOW_DOWN_BUNNYHOP )
				{
					len += format(message[len], charsmax(message) - len, "^n%s: %s", g_property1_name[block_type], property);
				}
			}
			if ( g_property2_name[block_type][0] )
			{
				GetProperty(ent, 2, property);
				
				len += format(message[len], charsmax(message) - len, "^n%s: %s", g_property2_name[block_type], property);
			}
			if ( g_property3_name[block_type][0] )
			{
				GetProperty(ent, 3, property);
				
				if ( block_type == BOOTS_OF_SPEED
				|| property[0] != '0'
				&& !( property[0] == '2' && property[1] == '5' && property[2] == '5' ) )
				{
					len += format(message[len], charsmax(message) - len, "^n%s: %s", g_property3_name[block_type], property);
				}
			}
			if ( g_property4_name[block_type][0] )
			{
				GetProperty(ent, 4, property);
				
				len += format(message[len], charsmax(message) - len, "^n%s: %s", g_property4_name[block_type], property[0] == '1' ? "Yes" : "No");
			}
			
			set_hudmessage(0, 255, 0, 0.01, 0.18, 0, 0.0, 1.0, 0.25, 0.25, 2);
			show_hudmessage(id, message);
		}
		else if ( IsLight(ent) )
		{
			static property1[5], property2[5], property3[5], property4[5];
			
			GetProperty(ent, 1, property1);
			GetProperty(ent, 2, property2);
			GetProperty(ent, 3, property3);
			GetProperty(ent, 4, property4);
			
			set_hudmessage(0, 255, 0, 0.01, 0.18, 0, 0.0, 1.0, 0.25, 0.25, 2);
			show_hudmessage(id, "%s %s^nType: Light^nRadius: %s^nColor Red: %s^nColor Green: %s^nColor Blue: %s", PLUGIN_PREFIX, PLUGIN_VERSION, property1, property2, property3, property4);
		}
	}
	
	if ( !g_grabbed[id] ) return FMRES_IGNORED;
	
	if ( ( buttons & IN_JUMP )
	&& !( oldbuttons & IN_JUMP ) ) if ( g_grab_length[id] > 72.0 ) g_grab_length[id] -= 16.0;
	
	if ( ( buttons & IN_DUCK )
	&& !( oldbuttons & IN_DUCK ) ) g_grab_length[id] += 16.0;
	
	if ( ( buttons & IN_ATTACK )
	&& !( oldbuttons & IN_ATTACK ) ) CmdAttack(id);
	
	if ( ( buttons & IN_ATTACK2 )
	&& !( oldbuttons & IN_ATTACK2 ) ) CmdAttack2(id);
	
	if ( ( buttons & IN_RELOAD )
	&& !( oldbuttons & IN_RELOAD ) )
	{
		CmdRotate(id);
		set_uc(handle, UC_Buttons, buttons & ~IN_RELOAD);
	}
	
	if ( !is_valid_ent(g_grabbed[id]) )
	{
		CmdRelease(id);
		return FMRES_IGNORED;
	}
	
	if ( !IsBlockInGroup(id, g_grabbed[id])
	|| g_group_count[id] < 1 )
	{
		MoveGrabbedEntity(id);
		return FMRES_IGNORED;
	}
	
	static block;
	static Float:move_to[3];
	static Float:offset[3];
	static Float:origin[3];
	
	MoveGrabbedEntity(id, move_to);
	
	for ( new i = 0; i <= g_group_count[id]; ++i )
	{
		block = g_grouped_blocks[id][i];
		
		if ( !IsBlockInGroup(id, block) ) continue;
		
		entity_get_vector(block, EV_VEC_vuser1, offset);
		
		origin[0] = move_to[0] - offset[0];
		origin[1] = move_to[1] - offset[1];
		origin[2] = move_to[2] - offset[2];
		
		MoveEntity(id, block, origin, false);
	}
	
	return FMRES_IGNORED;
}

public EventCurWeapon(id)
{
	static block, property[5];
	
	if ( g_boots_of_speed[id] )
	{
		block = g_boots_of_speed[id];
		GetProperty(block, 3, property);
		
		entity_set_float(id, EV_FL_maxspeed, str_to_float(property));
	}
	else if ( g_ice[id] )
	{
		entity_set_float(id, EV_FL_maxspeed, 400.0);
	}
	else if ( g_honey[id] )
	{
		block = g_honey[id];
		GetProperty(block, 1, property);
		
		entity_set_float(id, EV_FL_maxspeed, str_to_float(property));
	}
}

public pfn_touch(ent, id)
{
	if ( !( 1 <= id <= g_max_players )
	|| !g_alive[id]
	|| !IsBlock(ent) ) return PLUGIN_CONTINUE;
	
	new block_type =	entity_get_int(ent, EV_INT_body);
	if ( block_type == PLATFORM
	|| block_type == GLASS ) return PLUGIN_CONTINUE;
	
	new flags =		entity_get_int(id, EV_INT_flags);
	new groundentity =	entity_get_edict(id, EV_ENT_groundentity);
	
	static property[5];
	GetProperty(ent, 4, property);
	
	if ( property[0] == '0'
	|| ( ( !property[0]
		|| property[0] == '1'
		|| property[0] == '/' )
	&& ( flags & FL_ONGROUND )
	&& groundentity == ent ) )
	{
		switch ( block_type )
		{
			case BUNNYHOP, NO_SLOW_DOWN_BUNNYHOP:	ActionBhop(ent);
			case DAMAGE:				ActionDamage(id, ent);
			case HEALER:				ActionHeal(id, ent);
			case TRAMPOLINE:			ActionTrampoline(id, ent);
			case SPEED_BOOST:			ActionSpeedBoost(id, ent);
			case DEATH:
			{
				if ( !get_user_godmode(id) )
				{
					fakedamage(id, "The Block of Death", 10000.0, DMG_GENERIC);
				}
			}
			case SLAP:
			{
				GetProperty(ent, 1, property);
				g_slap_times[id] = str_to_num(property) * 2;
			}
			case LOW_GRAVITY:			ActionLowGravity(id, ent);
			case HONEY:				ActionHoney(id, ent);
			case CT_BARRIER:			ActionBarrier(id, ent, true);
			case T_BARRIER:				ActionBarrier(id, ent, false);
			case DELAYED_BUNNYHOP:			ActionDelayedBhop(ent);
			case STEALTH:				ActionStealth(id, ent);
			case INVINCIBILITY:			ActionInvincibility(id, ent);
			case BOOTS_OF_SPEED:			ActionBootsOfSpeed(id, ent);
			case XPBLOCK:				ActionXPBlock(id, ent);
		}
	}
	
	if ( ( flags & FL_ONGROUND )
	&& groundentity == ent )
	{
		switch ( block_type )
		{
			case BUNNYHOP:
			{
				GetProperty(ent, 1, property);
				if ( property[0] == '1' )
				{
					g_no_fall_damage[id] = true;
				}
			}
			case NO_FALL_DAMAGE:			g_no_fall_damage[id] = true;
			case ICE:				ActionIce(id);
			case NO_SLOW_DOWN_BUNNYHOP:
			{
				ActionNoSlowDown(id);
				
				GetProperty(ent, 1, property);
				if ( property[0] == '1' )
				{
					g_no_fall_damage[id] = true;
				}
			}
		}
	}
	
	return PLUGIN_CONTINUE;
}

public server_frame()
{
	for ( new id = 1; id <= g_max_players; ++id )
	{
		if ( !g_alive[id] ) continue;
		
		if ( g_ice[id] || g_no_slow_down[id] )
		{
			entity_set_float(id, EV_FL_fuser2, 0.0);
		}
		
		if ( g_set_velocity[id][0] != 0.0
		|| g_set_velocity[id][1] != 0.0
		|| g_set_velocity[id][2] != 0.0 )
		{
			entity_set_vector(id, EV_VEC_velocity, g_set_velocity[id]);
			
			g_set_velocity[id][0] = 0.0;
			g_set_velocity[id][1] = 0.0;
			g_set_velocity[id][2] = 0.0;
		}
		
		if ( g_low_gravity[id] )
		{
			if ( entity_get_int(id, EV_INT_flags) & FL_ONGROUND )
			{
				entity_set_float(id, EV_FL_gravity, 1.0);
				g_low_gravity[id] = false;
			}
		}
		
		while ( g_slap_times[id] )
		{
			user_slap(id, 0);
			g_slap_times[id]--;
		}
	}
	
	static ent;
	static entinsphere;
	static Float:origin[3];
	
	while ( ( ent = find_ent_by_class(ent, g_start_classname) ) )
	{
		entity_get_vector(ent, EV_VEC_origin, origin);
		
		entinsphere = -1;
		while ( ( entinsphere = find_ent_in_sphere(entinsphere, origin, 40.0) ) )
		{
			static classname[32];
			entity_get_string(entinsphere, EV_SZ_classname, classname, charsmax(classname));
			
			if ( 1 <= entinsphere <= g_max_players && g_alive[entinsphere] )
			{
				ActionTeleport(entinsphere, ent);
			}
			else if ( equal(classname, "grenade") )
			{
				entity_set_int(ent, EV_INT_solid, SOLID_NOT);
				entity_set_float(ent, EV_FL_ltime, get_gametime() + 2.0);
			}
			else if ( get_gametime() >= entity_get_float(ent, EV_FL_ltime) )
			{
				entity_set_int(ent, EV_INT_solid, SOLID_BBOX);
			}
		}
	}
	
	static bool:ent_near;
	
	ent_near = false;
	while ( ( ent = find_ent_by_class(ent, g_destination_classname) ) )
	{
		entity_get_vector(ent, EV_VEC_origin, origin);
		
		entinsphere = -1;
		while ( ( entinsphere = find_ent_in_sphere(entinsphere, origin, 64.0) ) )
		{
			static classname[32];
			entity_get_string(entinsphere, EV_SZ_classname, classname, charsmax(classname));
			
			if ( 1 <= entinsphere <= g_max_players && g_alive[entinsphere]
			|| equal(classname, "grenade") )
			{
				ent_near = true;
				break;
			}
		}
		
		if ( ent_near )
		{
			if ( !entity_get_int(ent, EV_INT_iuser2) )
			{
				entity_set_int(ent, EV_INT_solid, SOLID_NOT);
			}
		}
		else
		{
			entity_set_int(ent, EV_INT_solid, SOLID_BBOX);
		}
	}
}

public client_PreThink(id)
{
	if ( !g_alive[id] ) return PLUGIN_CONTINUE;
	
	new Float:gametime =			get_gametime();
	new Float:timeleft_invincibility =	g_invincibility_time_out[id] - gametime;
	new Float:timeleft_stealth =		g_stealth_time_out[id] - gametime;
	new Float:timeleft_boots_of_speed =	g_boots_of_speed_time_out[id] - gametime;
	
	if ( timeleft_invincibility >= 0.0
	|| timeleft_stealth >= 0.0
	|| timeleft_boots_of_speed >= 0.0 )
	{
		new text[48], text_to_show[256];
		
		format(text, charsmax(text), "%s %s", PLUGIN_PREFIX, PLUGIN_VERSION);
		add(text_to_show, charsmax(text_to_show), text);
	
		if ( timeleft_invincibility >= 0.0 )
		{
			format(text, charsmax(text), "^nInvincible %.1f", timeleft_invincibility);
			add(text_to_show, charsmax(text_to_show), text);
		}
		
		if ( timeleft_stealth >= 0.0 )
		{
			format(text, charsmax(text), "^nStealth %.1f", timeleft_stealth);
			add(text_to_show, charsmax(text_to_show), text);
		}
		
		if ( timeleft_boots_of_speed >= 0.0 )
		{
			format(text, charsmax(text), "^nBoots Of Speed %.1f", timeleft_boots_of_speed);
			add(text_to_show, charsmax(text_to_show), text);
		}
		
		set_hudmessage(0, 255, 0, 0.01, 0.18, 0, 0.0, 1.0, 0.25, 0.25, 2);
		show_hudmessage(id, text_to_show);
		
		g_has_hud_text[id] = true;
	}
	else
	{
		g_has_hud_text[id] = false;
	}
	
	return PLUGIN_CONTINUE;
}

public client_PostThink(id)
{
	if ( !g_alive[id] ) return PLUGIN_CONTINUE;
	
	if ( g_no_fall_damage[id] )
	{
		entity_set_int(id,  EV_INT_watertype, -3);
		g_no_fall_damage[id] = false;
	}
	
	return PLUGIN_CONTINUE;
}

ActionBhop(ent)
{
	if ( task_exists(TASK_SOLIDNOT + ent)
	|| task_exists(TASK_SOLID + ent) ) return PLUGIN_HANDLED;
	
	set_task(0.1, "TaskSolidNot", TASK_SOLIDNOT + ent);
	
	return PLUGIN_HANDLED;
}

ActionDamage(id, ent)
{
	new Float:gametime = get_gametime();
	if ( !( gametime >= g_next_damage_time[id] )
	|| get_user_health(id) <= 0
	|| get_user_godmode(id) ) return PLUGIN_HANDLED;
	
	static property[5];
	
	GetProperty(ent, 1, property);
	fakedamage(id, "Damage Block", str_to_float(property), DMG_CRUSH);
	
	GetProperty(ent, 2, property);
	g_next_damage_time[id] = gametime + str_to_float(property);
	
	return PLUGIN_HANDLED;
}

ActionHeal(id, ent)
{
	new Float:gametime = get_gametime();
	if ( !( gametime >= g_next_heal_time[id] ) ) return PLUGIN_HANDLED;
	
	new health = get_user_health(id);
	if ( health >= 100 ) return PLUGIN_HANDLED;
	
	static property[5];
	
	GetProperty(ent, 1, property);
	health += str_to_num(property);
	set_user_health(id, min(100, health));
	
	GetProperty(ent, 2, property);
	g_next_heal_time[id] = gametime + str_to_float(property);
	
	return PLUGIN_HANDLED;
}

ActionIce(id)
{
	if ( !g_ice[id] )
	{
		entity_set_float(id, EV_FL_friction, 0.15);
		entity_set_float(id, EV_FL_maxspeed, 400.0);
		
		g_ice[id] = true;
	}
	
	new task_id = TASK_ICE + id;
	if ( task_exists(task_id) ) remove_task(task_id);
	
	set_task(0.1, "TaskNotOnIce", task_id);
}

ActionTrampoline(id, ent)
{
	static property1[5];
	GetProperty(ent, 1, property1);
	
	entity_get_vector(id, EV_VEC_velocity, g_set_velocity[id]);
	
	g_set_velocity[id][2] = str_to_float(property1);
	
	entity_set_int(id, EV_INT_gaitsequence, 6);
	
	g_no_fall_damage[id] = true;
}

ActionSpeedBoost(id, ent)
{
	static property[5];
	
	GetProperty(ent, 1, property);
	velocity_by_aim(id, str_to_num(property), g_set_velocity[id]);
	
	GetProperty(ent, 2, property);
	g_set_velocity[id][2] = str_to_float(property);
	
	entity_set_int(id, EV_INT_gaitsequence, 6);
}

ActionLowGravity(id, ent)
{
	if ( g_low_gravity[id] ) return PLUGIN_HANDLED;
	
	static property1[5];
	GetProperty(ent, 1, property1);
	
	entity_set_float(id, EV_FL_gravity, str_to_float(property1) / 800);
	
	g_low_gravity[id] = true;
	
	return PLUGIN_HANDLED;
}

ActionHoney(id, ent)
{
	if ( g_honey[id] != ent )
	{
		static property1[5];
		GetProperty(ent, 1, property1);
		
		new Float:speed = str_to_float(property1);
		entity_set_float(id, EV_FL_maxspeed, speed == 0 ? -1.0 : speed);
		
		g_honey[id] = ent;
	}
	
	new task_id = TASK_HONEY + id;
	if ( task_exists(task_id) )
	{
		remove_task(task_id);
	}
	else
	{
		static Float:velocity[3];
		entity_get_vector(id, EV_VEC_velocity, velocity);
		
		velocity[0] /= 2.0;
		velocity[1] /= 2.0;
		
		entity_set_vector(id, EV_VEC_velocity, velocity);
	}
	
	set_task(0.1, "TaskNotInHoney", task_id);
}

ActionBarrier(id, ent, bool:block_terrorists)
{
	if ( task_exists(TASK_SOLIDNOT + ent)
	|| task_exists(TASK_SOLID + ent) ) return PLUGIN_HANDLED;
	
	new CsTeams:team = block_terrorists ? CS_TEAM_T : CS_TEAM_CT;
	if ( cs_get_user_team(id) == team ) TaskSolidNot(TASK_SOLIDNOT + ent);
	
	return PLUGIN_HANDLED;
}

ActionNoSlowDown(id)
{
	g_no_slow_down[id] = true;
	
	new task_id = TASK_NOSLOWDOWN + id;
	if ( task_exists(task_id) ) remove_task(task_id);
	
	set_task(0.1, "TaskSlowDown", task_id);
}

ActionDelayedBhop(ent)
{
	if ( task_exists(TASK_SOLIDNOT + ent)
	|| task_exists(TASK_SOLID + ent) ) return PLUGIN_HANDLED;
	
	static property1[5];
	GetProperty(ent, 1, property1);
	
	set_task(str_to_float(property1), "TaskSolidNot", TASK_SOLIDNOT + ent);
	
	return PLUGIN_HANDLED;
}

ActionInvincibility(id, ent)
{
	new Float:gametime = get_gametime();
	if ( !( gametime >= g_invincibility_next_use[id] ) )
	{
		if ( !g_has_hud_text[id] )
		{
			set_hudmessage(0, 255, 0, 0.01, 0.18, 0, 0.0, 1.0, 0.25, 0.25, 2);
			show_hudmessage(id, "%s %s^nInvincibility^nNext Use %.1f", PLUGIN_PREFIX, PLUGIN_VERSION, g_invincibility_next_use[id] - gametime);
		}
		
		return PLUGIN_HANDLED;
	}
	
	static property[5];
	
	entity_set_float(id, EV_FL_takedamage, DAMAGE_NO);
	
	if ( gametime >= g_stealth_time_out[id] )
	{
		set_user_rendering(id, kRenderFxGlowShell, 255, 255, 255, kRenderNormal, 16);
	}
	
	emit_sound(id, CHAN_STATIC, g_sound_invincibility, 1.0, ATTN_NORM, 0, PITCH_NORM);
	
	static Float:time_out;
	GetProperty(ent, 1, property);
	time_out = str_to_float(property);
	set_task(time_out, "TaskRemoveInvincibility", TASK_INVINCIBLE + id, g_blank, 0, g_a, 1);
	
	GetProperty(ent, 2, property);
	
	g_invincibility_time_out[id] = gametime + time_out;
	g_invincibility_next_use[id] = gametime + time_out + str_to_float(property);
	
	return PLUGIN_HANDLED;
}

ActionStealth(id, ent)
{
	new Float:gametime = get_gametime();
	if ( !( gametime >= g_stealth_next_use[id] ) )
	{
		if ( !g_has_hud_text[id] )
		{
			set_hudmessage(0, 255, 0, 0.01, 0.18, 0, 0.0, 1.0, 0.25, 0.25, 2);
			show_hudmessage(id, "%s %s^nStealth^nNext Use %.1f", PLUGIN_PREFIX, PLUGIN_VERSION, g_stealth_next_use[id] - gametime);
		}
		
		return PLUGIN_HANDLED;
	}
	
	static property[5];
	
	set_user_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderTransColor, 0);
	
	emit_sound(id, CHAN_STATIC, g_sound_stealth, 1.0, ATTN_NORM, 0, PITCH_NORM);
	
	g_block_status[id] = true;
	
	static Float:time_out;
	GetProperty(ent, 1, property);
	time_out = str_to_float(property);
	set_task(time_out, "TaskRemoveStealth", TASK_STEALTH + id, g_blank, 0, g_a, 1);
	
	GetProperty(ent, 2, property);
	
	g_stealth_time_out[id] = gametime + time_out;
	g_stealth_next_use[id] = gametime + time_out + str_to_float(property);
	
	return PLUGIN_HANDLED;
}

ActionBootsOfSpeed(id, ent)
{
	new Float:gametime = get_gametime();
	if ( !( gametime >= g_boots_of_speed_next_use[id] ) )
	{
		if ( !g_has_hud_text[id] )
		{
			set_hudmessage(0, 255, 0, 0.01, 0.18, 0, 0.0, 1.0, 0.25, 0.25, 2);
			show_hudmessage(id, "%s %s^nBoots Of Speed^nNext Use %.1f", PLUGIN_PREFIX, PLUGIN_VERSION, g_boots_of_speed_next_use[id] - gametime);
		}
		
		return PLUGIN_HANDLED;
	}
	
	static property[5];
	
	GetProperty(ent, 3, property);
	entity_set_float(id, EV_FL_maxspeed, str_to_float(property));
	
	g_boots_of_speed[id] = ent;
	
	emit_sound(id, CHAN_STATIC, g_sound_boots_of_speed, 1.0, ATTN_NORM, 0, PITCH_NORM);
	
	static Float:time_out;
	GetProperty(ent, 1, property);
	time_out = str_to_float(property);
	set_task(time_out, "TaskRemoveBootsOfSpeed", TASK_BOOTSOFSPEED + id, g_blank, 0, g_a, 1);
	
	GetProperty(ent, 2, property);
	
	g_boots_of_speed_time_out[id] = gametime + time_out;
	g_boots_of_speed_next_use[id] = gametime + time_out + str_to_float(property);
	
	return PLUGIN_HANDLED;
}

ActionXPBlock(id, ent)
{
	if ( cs_get_user_team(id) == CS_TEAM_T )
	{
		if ( !g_xpblock_used[id] )
		{
			new property[5];
			GetProperty(ent, 1, property);
			hnsxp_add_user_xp(id, str_to_num(property));
			g_xpblock_used[id] = true;
			
			set_hudmessage(0, 255, 0, 0.01, 0.18, 0, 0.0, 1.0, 0.25, 0.25, 2);
			show_hudmessage(id, "You got %i more XP!", str_to_num(property));
		}
	}
		else
		{
			set_hudmessage(0, 255, 0, 0.01, 0.18, 0, 0.0, 1.0, 0.25, 0.25, 2);
			show_hudmessage(id, "Only Terrorists can take XP Block!");
	}
}

ActionTeleport(id, ent)
{
	new tele = entity_get_int(ent, EV_INT_iuser1);
	if ( !tele ) return PLUGIN_HANDLED;
	
	static Float:tele_origin[3];
	entity_get_vector(tele, EV_VEC_origin, tele_origin);
	
	new player = -1;
	do
	{
		player = find_ent_in_sphere(player, tele_origin, 16.0);
		
		if ( !is_user_alive(player)
		|| player == id
		|| cs_get_user_team(id) == cs_get_user_team(player) ) continue;
		
		user_kill(player, 1);
	}
	while ( player );
	
	entity_set_vector(id, EV_VEC_origin, tele_origin);
	
	static Float:velocity[3];
	entity_get_vector(id, EV_VEC_velocity, velocity);
	velocity[2] = floatabs(velocity[2]);
	entity_set_vector(id, EV_VEC_velocity, velocity);
	
	return PLUGIN_HANDLED;
}

public TaskSolidNot(ent)
{
	ent -= TASK_SOLIDNOT;
	
	if ( !is_valid_ent(ent)
	|| entity_get_int(ent, EV_INT_iuser2) ) return PLUGIN_HANDLED;
	
	entity_set_int(ent, EV_INT_solid, SOLID_NOT);
	set_rendering(ent, kRenderFxNone, 255, 255, 255, kRenderTransAdd, 25);
	set_task(1.0, "TaskSolid", TASK_SOLID + ent);
	
	return PLUGIN_HANDLED;
}

public TaskSolid(ent)
{
	ent -= TASK_SOLID;
	
	if ( !IsBlock(ent) ) return PLUGIN_HANDLED;
	
	entity_set_int(ent, EV_INT_solid, SOLID_BBOX);
	
	if ( entity_get_int(ent, EV_INT_iuser1) > 0 )
	{
		GroupBlock(0, ent);
	}
	else
	{
		static property3[5];
		GetProperty(ent, 3, property3);
		
		new transparency = str_to_num(property3);
		if ( !transparency
		|| transparency == 255 )
		{
			new block_type = entity_get_int(ent, EV_INT_body);
			SetBlockRendering(ent, g_render[block_type], g_red[block_type], g_green[block_type], g_blue[block_type], g_alpha[block_type]);
		}
		else
		{
			SetBlockRendering(ent, TRANSALPHA, 255, 255, 255, transparency);
		}
	}
	
	return PLUGIN_HANDLED;
}

public TaskNotOnIce(id)
{
	id -= TASK_ICE;
	
	g_ice[id] = false;
	
	if ( !g_alive[id] ) return PLUGIN_HANDLED;
	
	if ( g_boots_of_speed[id] )
	{
		static block, property3[5];
		block = g_boots_of_speed[id];
		GetProperty(block, 3, property3);
		
		entity_set_float(id, EV_FL_maxspeed, str_to_float(property3));
	}
	else
	{
		ResetMaxspeed(id);
	}
	
	entity_set_float(id, EV_FL_friction, 1.0);
	
	return PLUGIN_HANDLED;
}

public TaskNotInHoney(id)
{
	id -= TASK_HONEY;
	
	g_honey[id] = 0;
	
	if ( !g_alive[id] ) return PLUGIN_HANDLED;
	
	if ( g_boots_of_speed[id] )
	{
		static block, property3[5];
		block = g_boots_of_speed[id];
		GetProperty(block, 3, property3);
		
		entity_set_float(id, EV_FL_maxspeed, str_to_float(property3));
	}
	else
	{
		ResetMaxspeed(id);
	}
	
	return PLUGIN_HANDLED;
}

public TaskSlowDown(id)
{
	id -= TASK_NOSLOWDOWN;
	
	g_no_slow_down[id] = false;
}

public TaskRemoveInvincibility(id)
{
	id -= TASK_INVINCIBLE;
	
	if ( !g_alive[id] ) return PLUGIN_HANDLED;
	
	if ( ( g_admin[id] || g_gived_access[id] ) && !g_godmode[id]
	|| ( !g_admin[id] && !g_gived_access[id] ) && !g_all_godmode )
	{
		set_user_godmode(id, 0);
	}
	
	if ( get_gametime() >= g_stealth_time_out[id] )
	{
		set_user_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderNormal, 16);
	}
	
	return PLUGIN_HANDLED;
}

public TaskRemoveStealth(id)
{
	id -= TASK_STEALTH;
	
	if ( g_connected[id] )
	{
		if ( get_gametime() <= g_invincibility_time_out[id] )
		{
			set_user_rendering(id, kRenderFxGlowShell, 255, 255, 255, kRenderTransColor, 16);
		}
		else
		{
			set_user_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderNormal, 255);
		}
	}
	
	g_block_status[id] = false;
}

public TaskRemoveBootsOfSpeed(id)
{
	id -= TASK_BOOTSOFSPEED;
	
	g_boots_of_speed[id] = 0;
	
	if ( !g_alive[id] ) return PLUGIN_HANDLED;
	
	if ( g_ice[id] )
	{
		entity_set_float(id, EV_FL_maxspeed, 400.0);
	}
	else if ( g_honey[id] )
	{
		static block, property1[5];
		block = g_honey[id];
		GetProperty(block, 1, property1);
		
		entity_set_float(id, EV_FL_maxspeed, str_to_float(property1));
	}
	else
	{
		ResetMaxspeed(id);
	}
	
	return PLUGIN_HANDLED;
}

public TaskSpriteNextFrame(params[])
{
	new ent = params[0];
	if ( !is_valid_ent(ent) )
	{
		remove_task(TASK_SPRITE + ent);
		return PLUGIN_HANDLED;
	}
	
	new frames = params[1];
	new Float:current_frame = entity_get_float(ent, EV_FL_frame);
	
	if ( current_frame < 0.0
	|| current_frame >= frames )
	{
		entity_set_float(ent, EV_FL_frame, 1.0);
	}
	else
	{
		entity_set_float(ent, EV_FL_frame, current_frame + 1.0);
	}
	
	return PLUGIN_HANDLED;
}

public MsgStatusValue()
{
	if ( get_msg_arg_int(1) == 2
	&& g_block_status[get_msg_arg_int(2)] )
	{
		set_msg_arg_int(1, get_msg_argtype(1), 1);
		set_msg_arg_int(2, get_msg_argtype(2), 0);
	}
}

public CmdAttack(id)
{
	if ( !IsBlock(g_grabbed[id]) ) return PLUGIN_HANDLED;
	
	if ( IsBlockInGroup(id, g_grabbed[id]) && g_group_count[id] > 1 )
	{
		static block;
		for ( new i = 0; i <= g_group_count[id]; ++i )
		{
			block = g_grouped_blocks[id][i];
			if ( !IsBlockInGroup(id, block) ) continue;
			
			if ( !IsBlockStuck(block) )
			{
				CopyBlock(block);
			}
		}
	}
	else
	{
		if ( IsBlockStuck(g_grabbed[id]) )
		{
			BCM_Print(id, "You cannot copy a block that is in a stuck position!");
			return PLUGIN_HANDLED;
		}
		
		new new_block = CopyBlock(g_grabbed[id]);
		if ( !new_block ) return PLUGIN_HANDLED;
		
		entity_set_int(g_grabbed[id], EV_INT_iuser2, 0);
		entity_set_int(new_block, EV_INT_iuser2, id);
		g_grabbed[id] = new_block;
	}
	
	return PLUGIN_HANDLED;
}

public CmdAttack2(id)
{
	if ( !IsBlock(g_grabbed[id]) )
	{
		DeleteTeleport(id, g_grabbed[id]);
		return PLUGIN_HANDLED;
	}
	
	if ( !IsBlockInGroup(id, g_grabbed[id])
	|| g_group_count[id] < 2 )
	{
		DeleteBlock(g_grabbed[id]);
		return PLUGIN_HANDLED;
	}
	
	static block;
	for ( new i = 0; i <= g_group_count[id]; ++i )
	{
		block = g_grouped_blocks[id][i];
		if ( !is_valid_ent(block)
		|| !IsBlockInGroup(id, block) ) continue;
		
		DeleteBlock(block);
	}
	
	return PLUGIN_HANDLED;
}

public CmdRotate(id)
{		
	if ( !IsBlock(g_grabbed[id]) ) return PLUGIN_HANDLED;
	
	if ( !IsBlockInGroup(id, g_grabbed[id])
	|| g_group_count[id] < 2 )
	{
		RotateBlock(g_grabbed[id]);
		return PLUGIN_HANDLED;
	}
	
	static block;
	for ( new i = 0; i <= g_group_count[id]; ++i )
	{
		block = g_grouped_blocks[id][i];
		if ( !is_valid_ent(block)
		|| !IsBlockInGroup(id, block) ) continue;
		
		RotateBlock(block);
	}
	
	return PLUGIN_HANDLED;
}

public CmdGrab(id)
{
	if ( !g_admin[id] && !g_gived_access[id] )
	{
		console_print(id, "You have no access to that command");
		return PLUGIN_HANDLED;
	}
	
	static ent, body;
	g_grab_length[id] = get_user_aiming(id, ent, body);
	
	new bool:is_block = IsBlock(ent);
	
	if ( !is_block && !IsTeleport(ent) && !IsLight(ent) ) return PLUGIN_HANDLED;
	
	new grabber = entity_get_int(ent, EV_INT_iuser2);
	if ( grabber && grabber != id ) return PLUGIN_HANDLED;
	
	if ( !is_block )
	{
		SetGrabbed(id, ent);
		return PLUGIN_HANDLED;
	}
	
	new player = entity_get_int(ent, EV_INT_iuser1);
	if ( player && player != id )
	{
		new player_name[32]; 
		get_user_name(player, player_name, charsmax(player_name));
		
		BCM_Print(id, "^1%s3 currently has this block in their group!", player_name);
		return PLUGIN_HANDLED;
	}
	
	SetGrabbed(id, ent);
	
	if ( g_group_count[id] < 2 ) return PLUGIN_HANDLED;
	
	static Float:grabbed_origin[3];
	
	entity_get_vector(ent, EV_VEC_origin, grabbed_origin);
	
	static block, Float:origin[3], Float:offset[3];
	for ( new i = 0; i <= g_group_count[id]; ++i )
	{
		block = g_grouped_blocks[id][i];
		if ( !is_valid_ent(block) ) continue;
		
		entity_get_vector(block, EV_VEC_origin, origin);
		
		offset[0] = grabbed_origin[0] - origin[0];
		offset[1] = grabbed_origin[1] - origin[1];
		offset[2] = grabbed_origin[2] - origin[2];
		
		entity_set_vector(block, EV_VEC_vuser1, offset);
		entity_set_int(block, EV_INT_iuser2, id);
	}
	
	return PLUGIN_HANDLED;
}

SetGrabbed(id, ent)
{
	entity_get_string(id, EV_SZ_viewmodel, g_viewmodel[id], charsmax(g_viewmodel));
	entity_set_string(id, EV_SZ_viewmodel, g_blank);
	
	static aiming[3], Float:origin[3];
	
	get_user_origin(id, aiming, 3);
	entity_get_vector(ent, EV_VEC_origin, origin);
	
	g_grabbed[id] = ent;
	g_grab_offset[id][0] = origin[0] - aiming[0];
	g_grab_offset[id][1] = origin[1] - aiming[1];
	g_grab_offset[id][2] = origin[2] - aiming[2];
	
	entity_set_int(ent, EV_INT_iuser2, id);
}

public CmdRelease(id)
{
	if ( !g_admin[id] && !g_gived_access[id] )
	{
		console_print(id, "You have no access to that command");
		return PLUGIN_HANDLED;
	}
	else if ( !g_grabbed[id] )
	{
		return PLUGIN_HANDLED;
	}
	
	if ( IsBlock(g_grabbed[id]) )
	{
		if ( IsBlockInGroup(id, g_grabbed[id]) && g_group_count[id] > 1 )
		{
			static i, block;
			
			new bool:group_is_stuck = true;
			
			for ( i = 0; i <= g_group_count[id]; ++i )
			{
				block = g_grouped_blocks[id][i];
				if ( IsBlockInGroup(id, block) )
				{
					entity_set_int(block, EV_INT_iuser2, 0);
					
					if ( group_is_stuck && !IsBlockStuck(block) )
					{
						group_is_stuck = false;
						break;
					}
				}
			}
			
			if ( group_is_stuck )
			{
				for ( i = 0; i <= g_group_count[id]; ++i )
				{
					block = g_grouped_blocks[id][i];
					if ( IsBlockInGroup(id, block) ) DeleteBlock(block);
				}
				
				BCM_Print(id, "Group deleted because all the blocks were stuck!");
			}
		}
		else
		{
			if ( is_valid_ent(g_grabbed[id]) )
			{
				if ( IsBlockStuck(g_grabbed[id]) )
				{
					new bool:deleted = DeleteBlock(g_grabbed[id]);
					if ( deleted ) BCM_Print(id, "Block deleted because it was stuck!");
				}
				else
				{
					entity_set_int(g_grabbed[id], EV_INT_iuser2, 0);
				}
			}
		}
	}
	else if ( IsTeleport(g_grabbed[id]) )
	{
		entity_set_int(g_grabbed[id], EV_INT_iuser2, 0);
	}
	
	entity_get_string(id, EV_SZ_viewmodel, g_viewmodel[id], charsmax(g_viewmodel));
	entity_set_string(id, EV_SZ_viewmodel, g_blank);
	
	g_grabbed[id] = 0;
	
	return PLUGIN_HANDLED;
}

public CmdMainMenu(id)
{
	ShowMainMenu(id);
	return PLUGIN_HANDLED;
}

ShowMainMenu(id)
{
	new menu[256], col1[3], col2[3];
	
	col1 = g_admin[id] || g_gived_access[id] ? "\r" : "\d";
	col2 = g_admin[id] || g_gived_access[id] ? "\w" : "\d";
	
	format(menu, charsmax(menu),\
		g_main_menu,\
		PLUGIN_PREFIX,\
		PLUGIN_NAME,\
		PLUGIN_VERSION,\
		col1,\
		col2,\
		g_noclip[id] ? "\yOn" : "\rOff",\
		col1,\
		col2,\
		g_godmode[id] ? "\yOn" : "\rOff"
		);
	
	show_menu(id, g_keys_main_menu, menu, -1, "BcmMainMenu");
}

ShowBlockMenu(id)
{
	new menu[256], col1[3], col2[3], size[8];
	
	col1 = g_admin[id] || g_gived_access[id] ? "\r" : "\d";
	col2 = g_admin[id] || g_gived_access[id] ? "\w" : "\d";
	
	switch ( g_selected_block_size[id] )
	{
		case TINY:	size = "Tiny";
		case NORMAL:	size = "Normal";
		case LARGE:	size = "Large";
	}
	
	format(menu, charsmax(menu),\
		g_block_menu,\
		PLUGIN_PREFIX,\
		g_block_names[g_selected_block_type[id]],\
		size,\
		col1,\
		col2,\
		col1,\
		col2,\
		col1,\
		col2,\
		col1,\
		col2,\
		col1,\
		col2,\
		col1,\
		col2
		);
	
	show_menu(id, g_keys_block_menu, menu, -1, "BcmBlockMenu");
}

ShowBlockSelectionMenu(id)
{
	new menu[256], title[32], entry[32], num;
	
	format(title, charsmax(title), "\r[%s] \yBlock Selection %d^n^n", PLUGIN_PREFIX, g_block_selection_page[id]);
	add(menu, charsmax(menu), title);
	
	new start_block = ( g_block_selection_page[id] - 1 ) * 8;
	
	for ( new i = start_block; i < start_block + 8; ++i )
	{
		if ( i < TOTAL_BLOCKS )
		{
			num = ( i - start_block ) + 1;
			
			format(entry, charsmax(entry), "\r%d. \w%s^n", num, g_block_names[i]);
		}
		else
		{
			format(entry, charsmax(entry), "^n");
		}
		
		add(menu, charsmax(menu), entry);
	}
	
	if ( g_block_selection_page[id] < g_block_selection_pages_max )
	{
		add(menu, charsmax(menu), "^n\r9. \wMore");
	}
	else
	{
		add(menu, charsmax(menu), "^n");
	}
	
	add(menu, charsmax(menu), "^n\r0. \wBack");
	
	show_menu(id, g_keys_block_selection_menu, menu, -1, "BcmBlockSelectionMenu");
}

ShowPropertiesMenu(id, ent)
{
	new menu[256], title[32], entry[64], property[5], line1[3], line2[3], line3[3], line4[3], num, block_type;
	
	block_type = entity_get_int(ent, EV_INT_body);
	
	format(title, charsmax(title), "\r[%s] \ySet Properties^n^n", PLUGIN_PREFIX);
	add(menu, charsmax(menu), title);
	
	if ( g_property1_name[block_type][0] )
	{
		GetProperty(ent, 1, property);
		
		if ( block_type == BUNNYHOP
		|| block_type == NO_SLOW_DOWN_BUNNYHOP )
		{
			format(entry, charsmax(entry), "\r1. \w%s: %s^n", g_property1_name[block_type], property[0] == '1' ? "\yOn" : "\rOff");
		}
		else if ( block_type == SLAP )
		{
			format(entry, charsmax(entry), "\r1. \w%s: \y%s^n", g_property1_name[block_type], property[0] == '3' ? "High" : property[0] == '2' ? "Medium" : "Low");
		}
		else
		{
			format(entry, charsmax(entry), "\r1. \w%s: \y%s^n", g_property1_name[block_type], property);
		}
		
		add(menu, charsmax(menu), entry);
	}
	else
	{
		format(line1, charsmax(line1), "^n");
	}
	
	if ( g_property2_name[block_type][0] )
	{
		if ( g_property1_name[block_type][0] )
		{
			num = 2;
		}
		else
		{
			num = 1;
		}
		
		GetProperty(ent, 2, property);
		
		format(entry, charsmax(entry), "\r%d. \w%s: \y%s^n", num, g_property2_name[block_type], property);
		
		add(menu, charsmax(menu), entry);
	}
	else
	{
		format(line2, charsmax(line2), "^n");
	}
	
	if ( g_property3_name[block_type][0] )
	{
		if ( g_property1_name[block_type][0] && g_property2_name[block_type][0] )
		{
			num = 3;
		}
		else if ( g_property1_name[block_type][0]
		|| g_property2_name[block_type][0] )
		{
			num = 2;
		}
		else
		{
			num = 1;
		}
		
		GetProperty(ent, 3, property);
		
		if ( block_type == BOOTS_OF_SPEED
		|| property[0] != '0' && !( property[0] == '2' && property[1] == '5' && property[2] == '5' ) )
		{
			format(entry, charsmax(entry), "\r%d. \w%s: \y%s^n", num, g_property3_name[block_type], property);
		}
		else
		{
			format(entry, charsmax(entry), "\r%d. \w%s: \rOff^n", num, g_property3_name[block_type]);
		}
		
		add(menu, charsmax(menu), entry);
	}
	else
	{
		format(line3, charsmax(line3), "^n");
	}
	
	if ( g_property4_name[block_type][0] )
	{
		if ( g_property1_name[block_type][0] && g_property2_name[block_type][0] && g_property3_name[block_type][0] )
		{
			num = 4;
		}
		else if ( g_property1_name[block_type][0] && g_property2_name[block_type][0]
		|| g_property1_name[block_type][0] && g_property3_name[block_type][0]
		|| g_property2_name[block_type][0] && g_property3_name[block_type][0] )
		{
			num = 3;
		}
		else if ( g_property1_name[block_type][0]
		|| g_property2_name[block_type][0]
		|| g_property3_name[block_type][0] )
		{
			num = 2;
		}
		else
		{
			num = 1;
		}
		
		GetProperty(ent, 4, property);
		
		format(entry, charsmax(entry), "\r%d. \w%s: %s^n", num, g_property4_name[block_type], property[0] == '1' ? "\yYes" : "\rNo");
		add(menu, charsmax(menu), entry);
	}
	else
	{
		format(line4, charsmax(line4), "^n");
	}
	
	g_property_info[id][1] = ent;
	
	add(menu, charsmax(menu), line1);
	add(menu, charsmax(menu), line2);
	add(menu, charsmax(menu), line3);
	add(menu, charsmax(menu), line4);
	add(menu, charsmax(menu), "^n^n^n^n^n^n\r0. \wBack");
	
	show_menu(id, g_keys_properties_menu, menu, -1, "BcmPropertiesMenu");
}

ShowMoveMenu(id)
{
	if ( !g_admin[id] && !g_gived_access[id] )
	{
		ShowBlockMenu(id);
		return PLUGIN_HANDLED;
	}
	
	new menu[256];
	
	format(menu, charsmax(menu), g_move_menu, PLUGIN_PREFIX, g_grid_size[id]);
	
	show_menu(id, g_keys_move_menu, menu, -1, "BcmMoveMenu");
	
	return PLUGIN_HANDLED;
}

ShowTeleportMenu(id)
{
	new menu[256], col1[3], col2[3];
	
	col1 = g_admin[id] || g_gived_access[id] ? "\r" : "\d";
	col2 = g_admin[id] || g_gived_access[id] ? "\w" : "\d";
	
	format(menu, charsmax(menu),\
		g_teleport_menu,\
		PLUGIN_PREFIX,\
		col1,\
		col2,\
		g_teleport_start[id] ? "\r" : "\d",\
		g_teleport_start[id] ? "\w" : "\d",\
		col1,\
		col2,\
		col1,\
		col2,\
		col1,\
		col2
		);
	
	show_menu(id, g_keys_teleport_menu, menu, -1, "BcmTeleportMenu");
}

ShowLightMenu(id)
{
	new menu[256], col1[3], col2[3];
	
	col1 = g_admin[id] || g_gived_access[id] ? "\r" : "\d";
	col2 = g_admin[id] || g_gived_access[id] ? "\w" : "\d";
	
	format(menu, charsmax(menu),\
		g_light_menu,\
		PLUGIN_PREFIX,\
		col1,\
		col2,\
		col1,\
		col2,\
		col1,\
		col2
		);
	
	show_menu(id, g_keys_light_menu, menu, -1, "BcmLightMenu");
}

ShowLightPropertiesMenu(id, ent)
{
	new menu[256], radius[5], color_red[5], color_green[5], color_blue[5];
	
	GetProperty(ent, 1, radius);
	GetProperty(ent, 2, color_red);
	GetProperty(ent, 3, color_green);
	GetProperty(ent, 4, color_blue);
	
	format(menu, charsmax(menu),\
		g_light_properties_menu,\
		PLUGIN_PREFIX,\
		radius,\
		color_red,\
		color_green,\
		color_blue
		);
	
	g_light_property_info[id][1] = ent;
	
	show_menu(id, g_keys_light_properties_menu, menu, -1, "BcmLightPropertiesMenu");
}

ShowOptionsMenu(id)
{
	new menu[256], col1[3], col2[3], col3[3], col4[3];
	
	col1 = g_admin[id] || g_gived_access[id] ? "\r" : "\d";
	col2 = g_admin[id] || g_gived_access[id] ? "\w" : "\d";
	col3 = g_admin[id] ? "\r" : "\d";
	col4 = g_admin[id] ? "\w" : "\d";
	
	format(menu, charsmax(menu),\
		g_options_menu,\
		PLUGIN_PREFIX,\
		col1,\
		col2,\
		g_snapping[id] ? "\yOn" : "\rOff",\
		col1,\
		col2,\
		g_snapping_gap[id],\
		col1,\
		col2,\
		col1,\
		col2,\
		col3,\
		col4,\
		col3,\
		col4,\
		col3,\
		col4
		);
	
	show_menu(id, g_keys_options_menu, menu, -1, "BcmOptionsMenu");
}

ShowChoiceMenu(id, choice, const title[96])
{
	new menu[128];
	
	g_choice_option[id] = choice;
	
	format(menu, charsmax(menu), g_choice_menu, title);
	
	show_menu(id, g_keys_choice_menu, menu, -1, "BcmChoiceMenu");
}

ShowCommandsMenu(id)
{
	new menu[256], col1[3], col2[3], col3[3], col4[3];
	
	col1 = g_admin[id] ? "\r" : "\d";
	col2 = g_admin[id] ? "\w" : "\d";
	col3 = ( g_admin[id] || g_gived_access[id] ) && g_alive[id] ? "\r" : "\d";
	col4 = ( g_admin[id] || g_gived_access[id] ) && g_alive[id] ? "\w" : "\d";
	
	format(menu, charsmax(menu),\
		g_commands_menu,\
		PLUGIN_PREFIX,\
		col3,\
		col4,\
		g_alive[id] && g_has_checkpoint[id] ? "\r" : "\d",\
		g_alive[id] && g_has_checkpoint[id] ? "\w" : "\d",\
		( g_admin[id] || g_gived_access[id] ) && !g_alive[id] ? "\r" : "\d",\
		( g_admin[id] || g_gived_access[id] ) && !g_alive[id] ? "\w" : "\d",\
		col1,\
		col2,\
		col1,\
		col2,\
		col1,\
		col2,\
		g_all_godmode ? "Remove" : "Set",\
		g_all_godmode ? "from" : "on",\
		col1,\
		col2,\
		PLUGIN_PREFIX
		);
	
	show_menu(id, g_keys_commands_menu, menu, -1, "BcmCommandsMenu");
}

public HandleMainMenu(id, key)
{
	switch ( key )
	{
		case K1: ShowBlockMenu(id);
		case K2: ShowTeleportMenu(id);
		case K3: ShowLightMenu(id);
		case K4: ShowOptionsMenu(id);
		case K5:
		{
			g_viewing_commands_menu[id] = true;
			ShowCommandsMenu(id);
		}
		case K6: ToggleNoclip(id);
		case K7: ToggleGodmode(id);
		case K9: CmdShowInfo(id);
		case K0: return;
	}
	
	if ( key == K6 || key == K7 || key == K9 ) ShowMainMenu(id);
}

public HandleBlockMenu(id, key)
{
	switch ( key )
	{
		case K1:
		{
			g_block_selection_page[id] = 1;
			ShowBlockSelectionMenu(id);
		}
		case K2: ChangeBlockSize(id);
		case K3: CreateBlockAiming(id, g_selected_block_type[id]);
		case K4: ConvertBlockAiming(id, g_selected_block_type[id]);
		case K5: DeleteBlockAiming(id);
		case K6: RotateBlockAiming(id);
		case K7: SetPropertiesBlockAiming(id);
		case K8: ShowMoveMenu(id);
		case K0: ShowMainMenu(id);
	}
	
	if ( key != K1 && key != K7 && key != K8 && key != K0 ) ShowBlockMenu(id);
}

public HandleBlockSelectionMenu(id, key)
{
	switch ( key )
	{
		case K9:
		{
			++g_block_selection_page[id];
			
			if ( g_block_selection_page[id] > g_block_selection_pages_max )
			{
				g_block_selection_page[id] = g_block_selection_pages_max;
			}
			
			ShowBlockSelectionMenu(id);
		}
		case K0:
		{
			--g_block_selection_page[id];
			
			if ( g_block_selection_page[id] < 1 )
			{
				ShowBlockMenu(id);
			}
			else
			{
				ShowBlockSelectionMenu(id);
			}
		}
		default:
		{
			key += ( g_block_selection_page[id] - 1 ) * 8;
			
			if ( key < TOTAL_BLOCKS )
			{
				g_selected_block_type[id] = key;
				ShowBlockMenu(id);
			}
			else
			{
				ShowBlockSelectionMenu(id);
			}
		}
	}
}

public HandlePropertiesMenu(id, key)
{
	new ent = g_property_info[id][1];
	if ( !is_valid_ent(ent) )
	{
		BCM_Print(id, "That block has been deleted!");
		g_viewing_properties_menu[id] = false;
		ShowBlockMenu(id);
		return PLUGIN_HANDLED;
	}
	
	new block_type = entity_get_int(ent, EV_INT_body);
	
	switch ( key )
	{
		case K1:
		{
			if ( g_property1_name[block_type][0] )
			{
				g_property_info[id][0] = 1;
			}
			else if ( g_property2_name[block_type][0] )
			{
				g_property_info[id][0] = 2;
			}
			else if ( g_property3_name[block_type][0] )
			{
				g_property_info[id][0] = 3;
			}
			else
			{
				g_property_info[id][0] = 4;
			}
			
			if ( g_property_info[id][0] == 1
			&& ( block_type == BUNNYHOP
			|| block_type == SLAP
			|| block_type == NO_SLOW_DOWN_BUNNYHOP ) )
			{
				ToggleProperty(id, 1);
			}
			else if ( g_property_info[id][0] == 4 )
			{
				ToggleProperty(id, 4);
			}
			else
			{
				BCM_Print(id, "Type the new property value for the block.%s", g_property_info[id][0] == 3 && block_type != BOOTS_OF_SPEED ? "^1 0^3 and^1 255^3 will turn transparency off." : g_blank);
				client_cmd(id, "messagemode BCM_SetProperty");
			}
		}
		case K2:
		{
			if ( g_property1_name[block_type][0] && g_property2_name[block_type][0]
			|| g_property1_name[block_type][0] && g_property3_name[block_type][0]
			|| g_property1_name[block_type][0] && g_property4_name[block_type][0]
			|| g_property2_name[block_type][0] && g_property3_name[block_type][0]
			|| g_property2_name[block_type][0] && g_property4_name[block_type][0]
			|| g_property3_name[block_type][0] && g_property4_name[block_type][0] )
			{
				if ( g_property1_name[block_type][0] && g_property2_name[block_type][0] )
				{
					g_property_info[id][0] = 2;
				}
				else if ( g_property1_name[block_type][0] && g_property3_name[block_type][0]
				|| g_property2_name[block_type][0] && g_property3_name[block_type][0] )
				{
					g_property_info[id][0] = 3;
				}
				else
				{
					g_property_info[id][0] = 4;
				}
				
				if ( g_property_info[id][0] == 4 )
				{
					ToggleProperty(id, 4);
				}
				else
				{
					BCM_Print(id, "Type the new property value for the block.%s", g_property_info[id][0] == 3 && block_type != BOOTS_OF_SPEED ? "^1 0^3 and^1 255^3 will turn transparency off." : g_blank);
					client_cmd(id, "messagemode BCM_SetProperty");
				}
			}
		}
		case K3:
		{
			if ( g_property1_name[block_type][0] && g_property2_name[block_type][0] && g_property3_name[block_type][0]
			|| g_property1_name[block_type][0] && g_property2_name[block_type][0] && g_property4_name[block_type][0]
			|| g_property1_name[block_type][0] && g_property3_name[block_type][0] && g_property4_name[block_type][0]
			|| g_property2_name[block_type][0] && g_property3_name[block_type][0] && g_property4_name[block_type][0] )
			{
				if ( g_property1_name[block_type][0] && g_property2_name[block_type][0] && g_property3_name[block_type][0] )
				{
					g_property_info[id][0] = 3;
				}
				else
				{
					g_property_info[id][0] = 4;
				}
				
				if ( g_property_info[id][0] == 4 )
				{
					ToggleProperty(id, 4);
				}
				else
				{
					BCM_Print(id, "Type the new property value for the block.%s", g_property_info[id][0] == 3 && block_type != BOOTS_OF_SPEED ? "^1 0^3 and^1 255^3 will turn transparency off." : g_blank);
					client_cmd(id, "messagemode BCM_SetProperty");
				}
			}
		}
		case K4:
		{
			if ( g_property1_name[block_type][0] && g_property2_name[block_type][0] && g_property3_name[block_type][0] && g_property4_name[block_type][0] )
			{
				ToggleProperty(id, 4);
			}
		}
		case K0:
		{
			g_viewing_properties_menu[id] = false;
			ShowBlockMenu(id);
		}
	}
	
	if ( key != K0 ) ShowPropertiesMenu(id, ent);
	
	return PLUGIN_HANDLED;
}

public HandleMoveMenu(id, key)
{
	switch ( key )
	{
		case K1: ToggleGridSize(id);
		case K0: ShowBlockMenu(id);
		default:
		{
			static ent, body;
			get_user_aiming(id, ent, body);
			
			if ( !IsBlock(ent) ) return PLUGIN_HANDLED;
			
			static Float:origin[3];
			
			if ( IsBlockInGroup(id, ent) && g_group_count[id] > 1 )
			{
				static i, block;
				
				new bool:group_is_stuck = true;
				
				for ( i = 0; i <= g_group_count[id]; ++i )
				{
					block = g_grouped_blocks[id][i];
					if ( IsBlockInGroup(id, block) )
					{
						entity_get_vector(block, EV_VEC_origin, origin);
						
						switch ( key )
						{
							case K2: origin[2] += g_grid_size[id];
							case K3: origin[2] -= g_grid_size[id];
							case K4: origin[0] += g_grid_size[id];
							case K5: origin[0] -= g_grid_size[id];
							case K6: origin[1] += g_grid_size[id];
							case K7: origin[1] -= g_grid_size[id];
						}
						
						MoveEntity(id, block, origin, false);
						
						if ( group_is_stuck && !IsBlockStuck(block) )
						{
							group_is_stuck = false;
							break;
						}
					}
				}
				
				if ( group_is_stuck )
				{
					for ( i = 0; i <= g_group_count[id]; ++i )
					{
						block = g_grouped_blocks[id][i];
						if ( IsBlockInGroup(id, block) )
						{
							DeleteBlock(block);
						}
					}
					
					BCM_Print(id, "Group deleted because all the blocks were stuck!");
				}
			}
			else
			{
				entity_get_vector(ent, EV_VEC_origin, origin);
				
				switch ( key )
				{
					case K2: origin[2] += g_grid_size[id];
					case K3: origin[2] -= g_grid_size[id];
					case K4: origin[0] += g_grid_size[id];
					case K5: origin[0] -= g_grid_size[id];
					case K6: origin[1] += g_grid_size[id];
					case K7: origin[1] -= g_grid_size[id];
				}
				
				MoveEntity(id, ent, origin, false);
				
				if ( IsBlockStuck(ent) )
				{
					new bool:deleted = DeleteBlock(ent);
					if ( deleted ) BCM_Print(id, "Block deleted because it was stuck!");
				}
			}
		}
	}
	
	if ( key != K0 ) ShowMoveMenu(id);
	
	return PLUGIN_HANDLED;
}

public HandleTeleportMenu(id, key)
{
	switch ( key )
	{
		case K1: CreateTeleportAiming(id, TELEPORT_START);
		case K2: CreateTeleportAiming(id, TELEPORT_DESTINATION);
		case K3: DeleteTeleportAiming(id);
		case K4: SwapTeleportAiming(id);
		case K5: ShowTeleportPath(id);
		case K0: ShowMainMenu(id);
	}
	
	if ( key != K9 && key != K0 ) ShowTeleportMenu(id);
}

public HandleLightMenu(id, key)
{
	switch ( key )
	{
		case K1: CreateLightAiming(id);
		case K2: DeleteLightAiming(id);
		case K3: SetPropertiesLightAiming(id);
		case K0: ShowMainMenu(id);
	}
	
	if ( key != K3 && key != K0 ) ShowLightMenu(id);
}

public HandleLightPropertiesMenu(id, key)
{
	new ent = g_light_property_info[id][1];
	if ( !is_valid_ent(ent) )
	{
		BCM_Print(id, "That light has been deleted!");
		g_viewing_light_properties_menu[id] = false;
		ShowLightMenu(id);
		return PLUGIN_HANDLED;
	}
	
	switch ( key )
	{
		case K1: g_light_property_info[id][0] = 1;
		case K2: g_light_property_info[id][0] = 2;
		case K3: g_light_property_info[id][0] = 3;
		case K4: g_light_property_info[id][0] = 4;
		case K0:
		{
			g_viewing_light_properties_menu[id] = false;
			ShowLightMenu(id);
		}
	}
	
	if ( key != K0 )
	{
		BCM_Print(id, "Type the new property value for the light.");
		client_cmd(id, "messagemode BCM_SetLightProperty");
		ShowLightPropertiesMenu(id, ent);
	}
	
	return PLUGIN_HANDLED;
}

public HandleOptionsMenu(id, key)
{
	switch ( key )
	{
		case K1: ToggleSnapping(id);
		case K2: ToggleSnappingGap(id);
		case K3: GroupBlockAiming(id);
		case K4: ClearGroup(id);
		case K5:
		{
			if ( g_admin[id] )	ShowChoiceMenu(id, CHOICE_DELETE, "Are you sure you want to delete all blocks and teleports?");
			else			ShowOptionsMenu(id);
		}
		case K6: SaveBlocks(id);
		case K7:
		{
			if ( g_admin[id] )	ShowChoiceMenu(id, CHOICE_LOAD, "Loading will delete all blocks and teleports, do you want to continue?");
			else			ShowOptionsMenu(id);
		}
		case K0: ShowMainMenu(id);
	}
	
	if ( key != K5 && key != K7 && key != K0 ) ShowOptionsMenu(id);
}

public HandleChoiceMenu(id, key)
{
	switch ( key )
	{
		case K1:
		{
			switch ( g_choice_option[id] )
			{
				case CHOICE_DELETE:	DeleteAll(id, true);
				case CHOICE_LOAD:	LoadBlocks(id);
			}
		}
		case K2: ShowOptionsMenu(id);
	}
	
	ShowOptionsMenu(id);
}

public HandleCommandsMenu(id, key)
{
	switch ( key )
	{
		case K1: CmdSaveCheckpoint(id);
		case K2: CmdLoadCheckpoint(id);
		case K3: CmdReviveYourself(id);
		case K4: CmdRevivePlayer(id);
		case K5: CmdReviveEveryone(id);
		case K6: ToggleAllGodmode(id);
		case K7: CmdGiveAccess(id);
		case K0:
		{
			g_viewing_commands_menu[id] = false;
			ShowMainMenu(id);
		}
	}
	
	if ( key != K0 ) ShowCommandsMenu(id);
}

ToggleNoclip(id)
{
	if ( g_admin[id] || g_gived_access[id] )
	{
		set_user_noclip(id, g_noclip[id] ? 0 : 1);
		g_noclip[id] = !g_noclip[id];
	}
}

ToggleGodmode(id)
{
	if ( g_admin[id] || g_gived_access[id] )
	{
		set_user_godmode(id, g_godmode[id] ? 0 : 1);
		g_godmode[id] = !g_godmode[id];
	}
}

ToggleGridSize(id)
{
	g_grid_size[id] *= 2;
	
	{
		g_grid_size[id] = 1.0;
	}
}

ToggleSnapping(id)
{
	if ( g_admin[id] || g_gived_access[id] )
	{
		g_snapping[id] = !g_snapping[id];
	}
}

ToggleSnappingGap(id)
{
	if ( g_admin[id] || g_gived_access[id] )
	{
		g_snapping_gap[id] += 4.0;
		
		if ( g_snapping_gap[id] > 40.0 )
		{
			g_snapping_gap[id] = 0.0;
		}
	}
}

public CmdSaveCheckpoint(id)
{
	if ( !g_admin[id] && !g_gived_access[id] )
	{
		console_print(id, "You have no access to that command");
		return PLUGIN_HANDLED;
	}
	else if ( !g_alive[id] )
	{
		BCM_Print(id, "You have to be alive to save a checkpoint!");
		return PLUGIN_HANDLED;
	}
	else if ( g_noclip[id] )
	{
		BCM_Print(id, "You can't save a checkpoint while using noclip!");
		return PLUGIN_HANDLED;
	}
	
	static Float:velocity[3];
	get_user_velocity(id, velocity);
	
	new button =	entity_get_int(id, EV_INT_button);
	new flags =	entity_get_int(id, EV_INT_flags);
	
	if ( !( ( velocity[2] >= 0.0 || ( flags & FL_INWATER ) ) && !( button & IN_JUMP ) && velocity[2] <= 0.0 ) )
	{
		BCM_Print(id, "You can't save a checkpoint while moving up or down!");
		return PLUGIN_HANDLED;
	}
	
	if ( flags & FL_DUCKING )	g_checkpoint_duck[id] = true;
	else				g_checkpoint_duck[id] = false;
	
	entity_get_vector(id, EV_VEC_origin, g_checkpoint_position[id]);
	
	BCM_Print(id, "Checkpoint saved!");
	
	if ( !g_has_checkpoint[id] )		g_has_checkpoint[id] = true;
	
	if ( g_viewing_commands_menu[id] )	ShowCommandsMenu(id);
	
	return PLUGIN_HANDLED;
}

public CmdLoadCheckpoint(id)
{
	if ( !g_admin[id] && !g_gived_access[id] )
	{
		console_print(id, "You have no access to that command");
		return PLUGIN_HANDLED;
	}
	else if ( !g_alive[id] )
	{
		BCM_Print(id, "You have to be alive to load a checkpoint!");
		return PLUGIN_HANDLED;
	}
	else if ( !g_has_checkpoint[id] )
	{
		BCM_Print(id, "You don't have a checkpoint!");
		return PLUGIN_HANDLED;
	}
	
	static Float:origin[3];
	for ( new i = 1; i <= g_max_players; i++ )
	{
		if ( i == id
		|| !g_alive[i] ) continue;
		
		entity_get_vector(id, EV_VEC_origin, origin);
		
		if ( get_distance_f(g_checkpoint_position[id], origin) <= 35.0 )
		{
			if ( cs_get_user_team(i) == cs_get_user_team(id) ) continue;
			
			BCM_Print(id, "Somebody is too close to your checkpoint!");
			return PLUGIN_HANDLED;
		}
	}
	
	entity_set_vector(id, EV_VEC_origin, g_checkpoint_position[id]);
	entity_set_vector(id, EV_VEC_velocity, Float:{ 0.0, 0.0, 0.0 });
	
	if ( g_checkpoint_duck[id] )
	{
		entity_set_int(id, EV_INT_flags, entity_get_int(id, EV_INT_flags) | FL_DUCKING);
	}
	
	return PLUGIN_HANDLED;
}

public CmdReviveYourself(id)
{
	if ( !g_admin[id] && !g_gived_access[id] )
	{
		console_print(id, "You have no access to that command");
		return PLUGIN_HANDLED;
	}
	else if ( g_alive[id] )
	{
		BCM_Print(id, "You are already alive!");
		return PLUGIN_HANDLED;
	}
	
	ExecuteHam(Ham_CS_RoundRespawn, id);
	BCM_Print(id, "You have revived yourself!");
	
	static name[32];
	get_user_name(id, name, charsmax(name));
	
	for ( new i = 1; i <= g_max_players; i++ )
	{
		if ( !g_connected[i]
		|| i == id ) continue;
		
		BCM_Print(i, "^1%s^3 revived himself!", name);
	}
	
	return PLUGIN_HANDLED;
}

CmdRevivePlayer(id)
{
	if ( !g_admin[id] && !g_gived_access[id] )
	{
		console_print(id, "You have no access to that command");
		return PLUGIN_HANDLED;
	}
	
	client_cmd(id, "messagemode BCM_Revive");
	BCM_Print(id, "Type the name of the client that you want to revive.");
	
	return PLUGIN_HANDLED;
}

public RevivePlayer(id)
{
	if ( !g_admin[id] && !g_gived_access[id] )
	{
		console_print(id, "You have no access to that command");
		return PLUGIN_HANDLED;
	}
	
	static arg[32], target;
	read_argv(1, arg, charsmax(arg));
	
	target = cmd_target(id, arg, CMDTARGET_NO_BOTS);
	if ( !target ) return PLUGIN_HANDLED;
	else if ( id == target )
	{
		CmdReviveYourself(id);
		return PLUGIN_HANDLED;
	}
	
	static target_name[32];
	get_user_name(target, target_name, charsmax(target_name));
	
	if ( g_admin[target]
	|| g_gived_access[target] )
	{
		BCM_Print(id, "^1%s^3 is admin, he can revive himself!", target_name);
		return PLUGIN_HANDLED;
	}
	else if ( g_alive[target] )
	{
		BCM_Print(id, "^1%s^3 is already alive!", target_name);
		return PLUGIN_HANDLED;
	}
	
	ExecuteHam(Ham_CS_RoundRespawn, target);
	
	static admin_name[32];
	get_user_name(id, admin_name, charsmax(admin_name));
	
	BCM_Print(id, "You revived^1 %s^3!", target_name);
	
	for ( new i = 1; i <= g_max_players; i++ )
	{
		if ( !g_connected[i]
		|| i == id
		|| i == target ) continue;
		
		BCM_Print(i, "^1%s^3 revived^1 %s^3!", admin_name, target_name);
	}
	
	BCM_Print(target, "You have been revived by^1 %s^3!", admin_name);
	
	return PLUGIN_HANDLED;
}

CmdReviveEveryone(id)
{
	if ( !g_admin[id] )
	{
		console_print(id, "You have no access to that command");
		return PLUGIN_HANDLED;
	}
	
	for ( new i = 1; i <= g_max_players; i++ )
	{
		if ( !g_connected[i]
		|| g_admin[i]
		|| g_gived_access[i]
		|| g_alive[i] ) continue;
		
		ExecuteHam(Ham_CS_RoundRespawn, i);
	}
	
	static admin_name[32];
	get_user_name(id, admin_name, charsmax(admin_name));
	
	BCM_Print(0, "^1%s^3 revived everyone!", admin_name);
	
	return PLUGIN_HANDLED;
}

ToggleAllGodmode(id)
{
	if ( !g_admin[id] )
	{
		console_print(id, "You have no access to that command");
		return PLUGIN_HANDLED;
	}
	
	for ( new i = 1; i <= g_max_players; i++ )
	{
		if ( !g_connected[i] ) continue;
		
		if ( g_alive[i]
		&& !g_admin[i]
		&& !g_gived_access[i] )
		{
			entity_set_float(i, EV_FL_takedamage, g_all_godmode ? DAMAGE_AIM : DAMAGE_NO);
		}
		
		if ( g_viewing_commands_menu[i] ) ShowCommandsMenu(i);
	}
	
	g_all_godmode = !g_all_godmode;
	
	static admin_name[32];
	get_user_name(id, admin_name, charsmax(admin_name));
	
	if ( g_all_godmode )	BCM_Print(0, "^1%s^3 set godmode on everyone!", admin_name);
	else			BCM_Print(0, "^1%s^3 removed godmode from everyone!", admin_name);
	
	return PLUGIN_HANDLED;
}

CmdGiveAccess(id)
{
	if ( !g_admin[id] )
	{
		console_print(id, "You have no access to that command");
		return PLUGIN_HANDLED;
	}
	
	client_cmd(id, "messagemode BCM_GiveAccess");
	BCM_Print(id, "Type the name of the client that you want to give access to %s.", PLUGIN_PREFIX);
	
	return PLUGIN_HANDLED;
}

public GiveAccess(id)
{
	if ( !g_admin[id] )
	{
		console_print(id, "You have no access to that command");
		return PLUGIN_HANDLED;
	}
	
	static arg[32], target;
	read_argv(1, arg, charsmax(arg));
	
	target = cmd_target(id, arg, CMDTARGET_NO_BOTS);
	if ( !target ) return PLUGIN_HANDLED;
	
	static target_name[32];
	get_user_name(target, target_name, charsmax(target_name));
	
	if ( g_admin[target] || g_gived_access[target] )
	{
		BCM_Print(id, "^1%s^3 already have access to %s!", target_name, PLUGIN_PREFIX);
		return PLUGIN_HANDLED;
	}
	
	g_gived_access[target] = true;
	
	BCM_Print(id, "You gived^1 %s^3 access to %s!", target_name, PLUGIN_PREFIX);
	
	static admin_name[32];
	get_user_name(id, admin_name, charsmax(admin_name));
	
	BCM_Print(target, "^1%s^3 has gived you access to %s! Type^1 /%s^3 to bring up the Main Menu.", admin_name, PLUGIN_PREFIX, PLUGIN_PREFIX);
	
	for ( new i = 1; i <= g_max_players; i++ )
	{
		if ( i == id
		|| i == target
		|| !g_connected[i] ) continue;
		
		BCM_Print(i, "^1%s^3 gived^1 %s^3 access to %s!", admin_name, target_name, PLUGIN_PREFIX);
	}
	
	return PLUGIN_HANDLED;
}

public CmdShowInfo(id)
{
	static text[1120], len, textures[32], title[64];
	
	get_pcvar_string(g_cvar_textures, textures, charsmax(textures));
	
	len += format(text[len], charsmax(text) - len, "<html>");
	
	len += format(text[len], charsmax(text) - len, "<style type = ^"text/css^">");
	
	len += format(text[len], charsmax(text) - len, "body");
	len += format(text[len], charsmax(text) - len, "{");
	len += format(text[len], charsmax(text) - len, 	"background-color:#000000;");
	len += format(text[len], charsmax(text) - len,	"font-family:Comic Sans MS;");
	len += format(text[len], charsmax(text) - len,	"font-weight:bold;");
	len += format(text[len], charsmax(text) - len, "}");
	
	len += format(text[len], charsmax(text) - len, "h1");
	len += format(text[len], charsmax(text) - len, "{");
	len += format(text[len], charsmax(text) - len,	"color:#00FF00;");
	len += format(text[len], charsmax(text) - len,	"font-size:large;");
	len += format(text[len], charsmax(text) - len, "}");
	
	len += format(text[len], charsmax(text) - len, "h2");
	len += format(text[len], charsmax(text) - len, "{");
	len += format(text[len], charsmax(text) - len,	"color:#00FF00;");
	len += format(text[len], charsmax(text) - len,	"font-size:medium;");
	len += format(text[len], charsmax(text) - len, "}");
	
	len += format(text[len], charsmax(text) - len, "h3");
	len += format(text[len], charsmax(text) - len, "{");
	len += format(text[len], charsmax(text) - len,	"color:#0096FF;");
	len += format(text[len], charsmax(text) - len,	"font-size:medium;");
	len += format(text[len], charsmax(text) - len, "}");
	
	len += format(text[len], charsmax(text) - len, "h4");
	len += format(text[len], charsmax(text) - len, "{");
	len += format(text[len], charsmax(text) - len,	"color:#FFFFFF;");
	len += format(text[len], charsmax(text) - len,	"font-size:medium;");
	len += format(text[len], charsmax(text) - len, "}");
	
	len += format(text[len], charsmax(text) - len, "h5");
	len += format(text[len], charsmax(text) - len, "{");
	len += format(text[len], charsmax(text) - len,	"color:#FFFFFF;");
	len += format(text[len], charsmax(text) - len,	"font-size:x-small;");
	len += format(text[len], charsmax(text) - len, "}");
	
	len += format(text[len], charsmax(text) - len, "</style>");
	
	len += format(text[len], charsmax(text) - len, "<body>");
	len += format(text[len], charsmax(text) - len, "<div align = ^"center^">");
	
	len += format(text[len], charsmax(text) - len, "<h1>");
	len += format(text[len], charsmax(text) - len, "%s v%s", PLUGIN_NAME, PLUGIN_VERSION);
	len += format(text[len], charsmax(text) - len, "</h1>");
	
	len += format(text[len], charsmax(text) - len, "<h4>");
	len += format(text[len], charsmax(text) - len, "by Someone");
	len += format(text[len], charsmax(text) - len, "</h4>");
	
	len += format(text[len], charsmax(text) - len, "<h1>");
	len += format(text[len], charsmax(text) - len, "Texture Design");
	len += format(text[len], charsmax(text) - len, "</h1>");
	
	len += format(text[len], charsmax(text) - len, "<h4>");
	len += format(text[len], charsmax(text) - len, "by Someone %s", textures);
	len += format(text[len], charsmax(text) - len, "</h4>");
	
	len += format(text[len], charsmax(text) - len, "<h2>");
	len += format(text[len], charsmax(text) - len, "Grabbing Blocks:");
	len += format(text[len], charsmax(text) - len, "</h3>");
	
	len += format(text[len], charsmax(text) - len, "<h5>");
	len += format(text[len], charsmax(text) - len, "Bind a key to +bcmgrab to move the blocks around.<br />", PLUGIN_PREFIX);
	len += format(text[len], charsmax(text) - len, "Eg: <I>Bind F +bcmgrab.</I>", PLUGIN_PREFIX);
	len += format(text[len], charsmax(text) - len, "</h5>");
	
	len += format(text[len], charsmax(text) - len, "<h2>");
	len += format(text[len], charsmax(text) - len, "Commands while grabbing a block:");
	len += format(text[len], charsmax(text) - len, "</h2>");
	
	len += format(text[len], charsmax(text) - len, "<h5>");
	len += format(text[len], charsmax(text) - len, "<I>+Attack</I>: Copies the block.<br />");
	len += format(text[len], charsmax(text) - len, "<I>+Attack2</I>: Deletes the block.<br />");
	len += format(text[len], charsmax(text) - len, "<I>+Reload</I>: Rotates the block.<br />");
	len += format(text[len], charsmax(text) - len, "<I>+Jump</I>: Moves the block closer to you.<br />");
	len += format(text[len], charsmax(text) - len, "<I>+Duck</I>: Moves the block further away from you.");
	len += format(text[len], charsmax(text) - len, "</h5>");
	
	len += format(text[len], charsmax(text) - len, "<h3>");
	len += format(text[len], charsmax(text) - len, "Press <I>+Use</I> to see what block you are aiming at.<br />");
	len += format(text[len], charsmax(text) - len, "Type /bcm to bring up the %s Main Menu.", PLUGIN_PREFIX, PLUGIN_PREFIX);
	len += format(text[len], charsmax(text) - len, "</h3>");
	
	len += format(text[len], charsmax(text) - len, "</div>");
	len += format(text[len], charsmax(text) - len, "</body>");
	
	len += format(text[len], charsmax(text) - len, "</html>");
	
	format(title, charsmax(title) - 1, "%s v%s", PLUGIN_NAME, PLUGIN_VERSION);
	show_motd(id, text, title);
	
	return PLUGIN_HANDLED;
}

MoveGrabbedEntity(id, Float:move_to[3] = { 0.0, 0.0, 0.0 })
{
	static aiming[3];
	static look[3];
	static Float:float_aiming[3];
	static Float:float_look[3];
	static Float:direction[3];
	static Float:length;
	
	get_user_origin(id, aiming, 1);
	get_user_origin(id, look, 3);
	IVecFVec(aiming, float_aiming);
	IVecFVec(look, float_look);
	
	direction[0] = float_look[0] - float_aiming[0];
	direction[1] = float_look[1] - float_aiming[1];
	direction[2] = float_look[2] - float_aiming[2];
	length = get_distance_f(float_look, float_aiming);
	
	if ( length == 0.0 ) length = 1.0;
	
	move_to[0] = ( float_aiming[0] + direction[0] * g_grab_length[id] / length ) + g_grab_offset[id][0];
	move_to[1] = ( float_aiming[1] + direction[1] * g_grab_length[id] / length ) + g_grab_offset[id][1];
	move_to[2] = ( float_aiming[2] + direction[2] * g_grab_length[id] / length ) + g_grab_offset[id][2];
	move_to[2] = float(floatround(move_to[2], floatround_floor));
	
	MoveEntity(id, g_grabbed[id], move_to, true);
}

MoveEntity(id, ent, Float:move_to[3], bool:do_snapping)
{
	if ( do_snapping ) DoSnapping(id, ent, move_to);
	
	entity_set_origin(ent, move_to);
}

CreateBlockAiming(const id, const block_type)
{
	if ( !g_admin[id] && !g_gived_access[id] )
	{
		console_print(id, "You have no access to that command");
		return PLUGIN_HANDLED;
	}
	
	static origin[3];
	static Float:float_origin[3];
	
	get_user_origin(id, origin, 3);
	IVecFVec(origin, float_origin);
	float_origin[2] += 4.0;
	
	CreateBlock(id, block_type, float_origin, Z, g_selected_block_size[id], g_property1_default_value[block_type], g_property2_default_value[block_type], g_property3_default_value[block_type], g_property4_default_value[block_type]);
	
	return PLUGIN_HANDLED;
}

CreateBlock(const id, const block_type, Float:origin[3], const axis, const size, const property1[], const property2[], const property3[], const property4[])
{
	new ent = create_entity("info_target");
	if ( !is_valid_ent(ent) ) return 0;
	
	entity_set_string(ent, EV_SZ_classname, g_block_classname);
	entity_set_int(ent, EV_INT_solid, SOLID_BBOX);
	entity_set_int(ent, EV_INT_movetype, MOVETYPE_NONE);
	
	new block_model[256];
	new Float:size_min[3];
	new Float:size_max[3];
	new Float:angles[3];
	new Float:scale;
	
	switch ( axis )
	{
		case X:
		{
			size_min[0] = -4.0;
			size_min[1] = -32.0;
			size_min[2] = -32.0;
			
			size_max[0] = 4.0;
			size_max[1] = 32.0;
			size_max[2] = 32.0;
			
			angles[0] = 90.0;
		}
		case Y:
		{
			size_min[0] = -32.0;
			size_min[1] = -4.0;
			size_min[2] = -32.0;
			
			size_max[0] = 32.0;
			size_max[1] = 4.0;
			size_max[2] = 32.0;
			
			angles[0] = 90.0;
			angles[2] = 90.0;
		}
		case Z:
		{
			size_min[0] = -32.0;
			size_min[1] = -32.0;
			size_min[2] = -4.0;
			
			size_max[0] = 32.0;
			size_max[1] = 32.0;
			size_max[2] = 4.0;
			
			angles[0] = 0.0;
			angles[1] = 0.0;
			angles[2] = 0.0;
		}
	}
	
	switch ( size )
	{
		case TINY:
		{
			SetBlockModelName(block_model, g_block_models[block_type], "Tiny");
			scale = 0.25;
		}
		case NORMAL:
		{
			block_model = g_block_models[block_type];
			scale = 1.0;
		}
		case LARGE:
		{
			SetBlockModelName(block_model, g_block_models[block_type], "Large");
			scale = 2.0;
		}
	}
	
	for ( new i = 0; i < 3; ++i )
	{
		if ( size_min[i] != 4.0 && size_min[i] != -4.0 )
		{
			size_min[i] *= scale;
		}
		
		if ( size_max[i] != 4.0 && size_max[i] != -4.0 )
		{
			size_max[i] *= scale;
		}
	}
	
	entity_set_model(ent, block_model);
	
	SetBlockRendering(ent, g_render[block_type], g_red[block_type], g_green[block_type], g_blue[block_type], g_alpha[block_type]);
	
	entity_set_vector(ent, EV_VEC_angles, angles);
	entity_set_size(ent, size_min, size_max);
	entity_set_int(ent, EV_INT_body, block_type);
	
	if ( 1 <= id <= g_max_players )
	{
		DoSnapping(id, ent, origin);
	}
	
	entity_set_origin(ent, origin);
	
	SetProperty(ent, 1, property1);
	SetProperty(ent, 2, property2);
	SetProperty(ent, 3, property3);
	SetProperty(ent, 4, property4);
	
	return ent;
}

ConvertBlockAiming(id, const convert_to)
{
	if ( !g_admin[id] && !g_gived_access[id] )
	{
		console_print(id, "You have no access to that command");
		return PLUGIN_HANDLED;
	}
	
	static ent, body;
	get_user_aiming(id, ent, body);
	
	if ( !IsBlock(ent) ) return PLUGIN_HANDLED;
	
	new grabber = entity_get_int(ent, EV_INT_iuser2);
	if ( grabber && grabber != id ) return PLUGIN_HANDLED;
	
	new player = entity_get_int(ent, EV_INT_iuser1);
	if ( player && player != id )
	{
		new player_name[32]; 
		get_user_name(player, player_name, charsmax(player_name));
		
		BCM_Print(id, "^1%s^3 currently has this block in their group!", player_name);
		return PLUGIN_HANDLED;
	}
	
	static new_block;
	if ( IsBlockInGroup(id, ent) && g_group_count[id] > 1 )
	{
		static i, block, block_count;
		
		block_count = 0;
		for ( i = 0; i <= g_group_count[id]; ++i )
		{
			block = g_grouped_blocks[id][i];
			if ( !IsBlockInGroup(id, block) ) continue;
			
			new_block = ConvertBlock(id, block, convert_to, true);
			if ( new_block != 0 )
			{
				g_grouped_blocks[id][i] = new_block;
				
				GroupBlock(id, new_block);
			}
			else
			{
				++block_count;
			}
		}
		
		if ( block_count > 1 )
		{
			BCM_Print(id, "Couldn't convert^1 %d^3 blocks!", block_count);
		}
	}
	else
	{
		new_block = ConvertBlock(id, ent, convert_to, false);
		if ( IsBlockStuck(new_block) )
		{
			new bool:deleted = DeleteBlock(new_block);
			if ( deleted ) BCM_Print(id, "Block deleted because it was stuck!");
		}
	}
	
	return PLUGIN_HANDLED;
}

ConvertBlock(id, ent, const convert_to, const bool:preserve_size)
{
	new axis;
	new block_type;
	new property1[5], property2[5], property3[5], property4[5];
	new Float:origin[3];
	new Float:size_max[3];
	
	block_type = entity_get_int(ent, EV_INT_body);
	
	entity_get_vector(ent, EV_VEC_origin, origin);
	entity_get_vector(ent, EV_VEC_maxs, size_max);
	
	for ( new i = 0; i < 3; ++i )
	{
		if ( size_max[i] == 4.0 )
		{
			axis = i;
			break;
		}
	}
	
	GetProperty(ent, 1, property1);
	GetProperty(ent, 2, property2);
	GetProperty(ent, 3, property3);
	GetProperty(ent, 4, property4);
	
	if ( block_type != convert_to )
	{
		copy(property1, charsmax(property1), g_property1_default_value[convert_to]);
		copy(property2, charsmax(property1), g_property2_default_value[convert_to]);
		copy(property3, charsmax(property1), g_property3_default_value[convert_to]);
		copy(property4, charsmax(property1), g_property4_default_value[convert_to]);
	}
	
	DeleteBlock(ent);
	
	if ( preserve_size )
	{
		static size, Float:max_size;
		
		max_size = size_max[0] + size_max[1] + size_max[2];
		
		if ( max_size > 128.0 )		size = LARGE;
		else if ( max_size > 64.0 )	size = NORMAL;
		else				size = TINY;
		
		return CreateBlock(id, convert_to, origin, axis, size, property1, property2, property3, property4);
	}
	else
	{
		return CreateBlock(id, convert_to, origin, axis, g_selected_block_size[id], property1, property2, property3, property4);
	}

	return ent;
}

DeleteBlockAiming(id)
{
	if ( !g_admin[id] && !g_gived_access[id] )
	{
		console_print(id, "You have no access to that command");
		return PLUGIN_HANDLED;
	}
	
	static ent, body;
	get_user_aiming(id, ent, body);
	
	if ( !IsBlock(ent) ) return PLUGIN_HANDLED;
	
	new grabber = entity_get_int(ent, EV_INT_iuser2);
	if ( grabber && grabber != id ) return PLUGIN_HANDLED;
	
	new player = entity_get_int(ent, EV_INT_iuser1);
	if ( player && player != id )
	{
		new player_name[32]; 
		get_user_name(player, player_name, charsmax(player_name));
		
		BCM_Print(id, "^1%s^3 currently has this block in their group!", player_name);
		return PLUGIN_HANDLED;
	}
	
	if ( IsBlockInGroup(id, ent) && g_group_count[id] > 1 )
	{
		static i, block;
		for ( i = 0; i <= g_group_count[id]; ++i )
		{
			block = g_grouped_blocks[id][i];
			if ( !is_valid_ent(block) ) continue;
			
			DeleteBlock(block);
		}
		
		return PLUGIN_HANDLED;
	}
	
	DeleteBlock(ent);
	
	return PLUGIN_HANDLED;
}

bool:DeleteBlock(ent)
{
	if ( !IsBlock(ent) ) return false;
	
	remove_entity(ent);
	return true;
}

RotateBlockAiming(id)
{
	if ( !g_admin[id] && !g_gived_access[id] )
	{
		console_print(id, "You have no access to that command");
		return PLUGIN_HANDLED;
	}
	
	static ent, body;
	get_user_aiming(id, ent, body);
	
	if ( !IsBlock(ent) ) return PLUGIN_HANDLED;
	
	new grabber = entity_get_int(ent, EV_INT_iuser2);
	if ( grabber && grabber != id ) return PLUGIN_HANDLED;
	
	new player = entity_get_int(ent, EV_INT_iuser1);
	if ( player && player != id )
	{
		static player_name[32]; 
		get_user_name(player, player_name, charsmax(player_name));
		
		BCM_Print(id, "^1%s^3 currently has this block in their group!", player_name);
		return PLUGIN_HANDLED;
	}
	
	if ( IsBlockInGroup(id, ent) && g_group_count[id] > 1 )
	{
		static block;
		for ( new i = 0; i <= g_group_count[id]; ++i )
		{
			block = g_grouped_blocks[id][i];
			if ( IsBlockInGroup(id, block) ) RotateBlock(block);
		}
	}
	else
	{
		RotateBlock(ent);
	}
	
	return PLUGIN_HANDLED;
}

RotateBlock(ent)
{
	if ( !is_valid_ent(ent) ) return false;
	
	static Float:angles[3];
	static Float:size_min[3];
	static Float:size_max[3];
	static Float:temp;
	
	entity_get_vector(ent, EV_VEC_angles, angles);
	entity_get_vector(ent, EV_VEC_mins, size_min);
	entity_get_vector(ent, EV_VEC_maxs, size_max);
	
	if ( angles[0] == 0.0 && angles[2] == 0.0 )
	{
		angles[0] = 90.0;
	}
	else if ( angles[0] == 90.0 && angles[2] == 0.0 )
	{
		angles[0] = 90.0;
		angles[2] = 90.0;
	}
	else
	{
		angles[0] = 0.0;
		angles[1] = 0.0;
		angles[2] = 0.0;
	}
	
	temp = size_min[0];
	size_min[0] = size_min[2];
	size_min[2] = size_min[1];
	size_min[1] = temp;
	
	temp = size_max[0];
	size_max[0] = size_max[2];
	size_max[2] = size_max[1];
	size_max[1] = temp;
	
	entity_set_vector(ent, EV_VEC_angles, angles);
	entity_set_size(ent, size_min, size_max);
	
	return true;
}

ChangeBlockSize(id)
{
	switch ( g_selected_block_size[id] )
	{
		case TINY:	g_selected_block_size[id] = NORMAL;
		case NORMAL:	g_selected_block_size[id] = LARGE;
		case LARGE:	g_selected_block_size[id] = TINY;
	}
}

SetPropertiesBlockAiming(id)
{
	if ( !g_admin[id] && !g_gived_access[id] )
	{
		console_print(id, "You have no access to that command");
		ShowBlockMenu(id);
		return PLUGIN_HANDLED;
	}
	
	static ent, body;
	get_user_aiming(id, ent, body);
	
	if ( !IsBlock(ent) )
	{
		ShowBlockMenu(id);
		return PLUGIN_HANDLED;
	}
	
	new block_type = entity_get_int(ent, EV_INT_body);
	
	if ( !g_property1_name[block_type][0]
	&& !g_property2_name[block_type][0]
	&& !g_property3_name[block_type][0]
	&& !g_property4_name[block_type][0] )
	{
		ShowBlockMenu(id);
		return PLUGIN_HANDLED;
	}
	
	g_viewing_properties_menu[id] = true;
	ShowPropertiesMenu(id, ent);
	
	return PLUGIN_HANDLED;
}

public SetPropertyBlock(id)
{
	static arg[5];
	read_argv(1, arg, charsmax(arg));
	
	if ( !strlen(arg) )
	{
		BCM_Print(id, "You can't set a property blank! Please type a new value.");
		client_cmd(id, "messagemode BCM_SetProperty");
		return PLUGIN_HANDLED;
	}
	else if ( !IsStrFloat(arg) )
	{
		BCM_Print(id, "You can't use letters in a property! Please type a new value.");
		client_cmd(id, "messagemode BCM_SetProperty");
		return PLUGIN_HANDLED;
	}
	
	new ent = g_property_info[id][1];
	if ( !is_valid_ent(ent) )
	{
		BCM_Print(id, "That block has been deleted!");
		g_viewing_properties_menu[id] = false;
		ShowBlockMenu(id);
		return PLUGIN_HANDLED;
	}
	
	static block_type;
	static property;
	static Float:property_value;
	
	block_type = entity_get_int(ent, EV_INT_body);
	property = g_property_info[id][0];
	property_value = str_to_float(arg);
	
	if ( property == 3
	&& block_type != BOOTS_OF_SPEED )
	{
		if ( !( 50 <= property_value <= 200 
		|| property_value == 255
		|| property_value == 0 ) )
		{
			BCM_Print(id, "The property has to be between^1 50^3 and^1 200^3,^1 255^3 or^1 0^3!");
			return PLUGIN_HANDLED;
		}
	}
	else
	{
		switch ( block_type )
		{
			case DAMAGE, HEALER:
			{
				if ( property == 1
				&& !( 1 <= property_value <= 100 ) )
				{
					BCM_Print(id, "The property has to be between^1 1^3 and^1 100^3!");
					return PLUGIN_HANDLED;
				}
				else if ( !( 0.1 <= property_value <= 240 ) )
				{
					BCM_Print(id, "The property has to be between^1 0.1^3 and^1 240^3!");
					return PLUGIN_HANDLED;
				}
			}
			case TRAMPOLINE:
			{
				if ( !( 200 <= property_value <= 2000 ) )
				{
					BCM_Print(id, "The property has to be between^1 200^3 and^1 2000^3!");
					return PLUGIN_HANDLED;
				}
			}
			case SPEED_BOOST:
			{
				if ( property == 1
				&& !( 200 <= property_value <= 2000 ) )
				{
					BCM_Print(id, "The property has to be between^1 200^3 and^1 2000^3!");
					return PLUGIN_HANDLED;
				}
				else if ( !( 0 <= property_value <= 2000 ) )
				{
					BCM_Print(id, "The property has to be between^1 0^3 and^1 2000^3!");
					return PLUGIN_HANDLED;
				}
			}
			case LOW_GRAVITY:
			{
				if ( !( 50 <= property_value <= 750 ) )
				{
					BCM_Print(id, "The property has to be between^1 50^3 and^1 750^3!");
					return PLUGIN_HANDLED;
				}
			}
			case HONEY:
			{
				if ( !( 75 <= property_value <= 200
				|| property_value == 0 ) )
				{
					BCM_Print(id, "The property has to be between^1 75^3 and^1 200^3, or^1 0^3!");
					return PLUGIN_HANDLED;
				}
			}
			case DELAYED_BUNNYHOP:
			{
				if ( !( 0.5 <= property_value <= 5 ) )
				{
					BCM_Print(id, "The property has to be between^1 0.5^3 and^1 5^3!");
					return PLUGIN_HANDLED;
				}
			}
			case INVINCIBILITY, STEALTH, BOOTS_OF_SPEED:
			{
				if ( property == 1
				&& !( 0.5 <= property_value <= 240 ) )
				{
					BCM_Print(id, "The property has to be between^1 0.5^3 and^1 240^3!");
					return PLUGIN_HANDLED;
				}
				else if ( property == 2
				&& !( 0 <= property_value <= 240 ) )
				{
					BCM_Print(id, "The property has to be between^1 0^3 and^1 240^3!");
					return PLUGIN_HANDLED;
				}
				else if ( property == 3
				&& block_type == BOOTS_OF_SPEED
				&& !( 260 <= property_value <= 400 ) )
				{
					BCM_Print(id, "The property has to be between^1 260^3 and^1 400^3!");
					return PLUGIN_HANDLED;
				}
			}
		}
	}
	
	SetProperty(ent, property, arg);
	
	for ( new i = 1; i <= g_max_players; i++ )
	{
		if ( !g_connected[i]
		|| !g_viewing_properties_menu[i] ) continue;
		
		ent = g_property_info[i][1];
		ShowPropertiesMenu(i, ent);
	}
	
	return PLUGIN_HANDLED;
}

ToggleProperty(id, property)
{
	new ent = g_property_info[id][1];
	if ( !is_valid_ent(ent) )
	{
		BCM_Print(id, "That block has been deleted!");
		g_viewing_properties_menu[id] = false;
		ShowBlockMenu(id);
		return PLUGIN_HANDLED;
	}
	
	static property_value[5];
	GetProperty(ent, property, property_value);
	
	new block_type = entity_get_int(ent, EV_INT_body);
	
	if ( block_type == SLAP && property == 1 )
	{
		if ( property_value[0] == '1' )		copy(property_value, charsmax(property_value), "2");
		else if ( property_value[0] == '2' )	copy(property_value, charsmax(property_value), "3");
		else					copy(property_value, charsmax(property_value), "1");
	}
	else
	{
		if ( property_value[0] == '0' )		copy(property_value, charsmax(property_value), "1");
		else					copy(property_value, charsmax(property_value), "0");
	}
	
	SetProperty(ent, property, property_value);
	
	for ( new i = 1; i <= g_max_players; i++ )
	{
		if ( g_connected[i] && g_viewing_properties_menu[i] )
		{
			ent = g_property_info[i][1];
			ShowPropertiesMenu(i, ent);
		}
	}
	
	return PLUGIN_HANDLED;
}

GetProperty(ent, property, property_value[])
{
	switch ( property )
	{
		case 1: pev(ent, pev_message, property_value, 5);
		case 2: pev(ent, pev_netname, property_value, 5);
		case 3: pev(ent, pev_viewmodel2, property_value, 5);
		case 4: pev(ent, pev_weaponmodel2, property_value, 5);
	}
	
	return (strlen(property_value) ? 1 : 0);
}

SetProperty(ent, property, const property_value[])
{
	switch ( property )
	{
		case 1: set_pev(ent, pev_message, property_value, 5);
		case 2: set_pev(ent, pev_netname, property_value, 5);
		case 3:
		{
			set_pev(ent, pev_viewmodel2, property_value, 5);
			
			new block_type = entity_get_int(ent, EV_INT_body);
			if ( g_property3_name[block_type][0] && block_type != BOOTS_OF_SPEED )
			{
				new transparency = str_to_num(property_value);
				if ( !transparency
				|| transparency == 255 )
				{
					SetBlockRendering(ent, g_render[block_type], g_red[block_type], g_green[block_type], g_blue[block_type], g_alpha[block_type]);
				}
				else
				{
					SetBlockRendering(ent, TRANSALPHA, 255, 255, 255, transparency);
				}
			}
		}
		case 4: set_pev(ent, pev_weaponmodel2, property_value, 5);
	}

	return 1;
}

CopyBlock(ent)
{
	if ( !is_valid_ent(ent) ) return 0;
	
	new size;
	new axis;
	new property1[5], property2[5], property3[5], property4[5];
	new Float:origin[3];
	new Float:angles[3];
	new Float:size_min[3];
	new Float:size_max[3];
	new Float:max_size;
	
	entity_get_vector(ent, EV_VEC_origin, origin);
	entity_get_vector(ent, EV_VEC_angles, angles);
	entity_get_vector(ent, EV_VEC_mins, size_min);
	entity_get_vector(ent, EV_VEC_maxs, size_max);
	
	max_size = size_max[0] + size_max[1] + size_max[2];
	
	if ( max_size > 128.0 )		size = LARGE;
	else if ( max_size > 64.0 )	size = NORMAL;
	else				size = TINY;
	
	for ( new i = 0; i < 3; ++i )
	{
		if ( size_max[i] == 4.0 )
		{
			axis = i;
			break;
		}
	}
	
	GetProperty(ent, 1, property1);
	GetProperty(ent, 2, property2);
	GetProperty(ent, 3, property3);
	GetProperty(ent, 4, property4);
	
	return CreateBlock(0, entity_get_int(ent, EV_INT_body), origin, axis, size, property1, property2, property3, property4);
}

GroupBlockAiming(id)
{
	if ( !g_admin[id] && !g_gived_access[id] )
	{
		console_print(id, "You have no access to that command");
		return PLUGIN_HANDLED;
	}
	
	static ent, body;
	get_user_aiming(id, ent, body);
	
	if ( !IsBlock(ent) ) return PLUGIN_HANDLED;
	
	new player = entity_get_int(ent, EV_INT_iuser1);
	if ( !player )
	{
		++g_group_count[id];
		g_grouped_blocks[id][g_group_count[id]] = ent;
		GroupBlock(id, ent);
		
	}
	else if ( player == id )
	{
		UnGroupBlock(ent);
	}
	else
	{
		static player, name[32];
		
		player = entity_get_int(ent, EV_INT_iuser1);
		get_user_name(player, name, charsmax(name));
		
		BCM_Print(id, "Block is already in a group by:^1 %s", name);
	}
	
	return PLUGIN_HANDLED;
}

GroupBlock(id, ent)
{
	if ( !is_valid_ent(ent) ) return PLUGIN_HANDLED;
	
	if ( 1 <= id <= g_max_players )
	{
		entity_set_int(ent, EV_INT_iuser1, id);
	}
	
	set_rendering(ent, kRenderFxGlowShell, 255, 0, 0, kRenderNormal, 16);
	
	return PLUGIN_HANDLED;
}

UnGroupBlock(ent)
{
	if ( !IsBlock(ent) ) return PLUGIN_HANDLED;
	
	entity_set_int(ent, EV_INT_iuser1, 0);
	
	new block_type = entity_get_int(ent, EV_INT_body);
	SetBlockRendering(ent, g_render[block_type], g_red[block_type], g_green[block_type], g_blue[block_type], g_alpha[block_type]);
	
	return PLUGIN_HANDLED;
}

ClearGroup(id)
{
	if ( !g_admin[id] && !g_gived_access[id] )
	{
		console_print(id, "You have no access to that command");
		return PLUGIN_HANDLED;
	}
	
	static block;
	static block_count;
	static blocks_deleted;
	
	block_count = 0;
	blocks_deleted = 0;
	for ( new i = 0; i <= g_group_count[id]; ++i )
	{
		block = g_grouped_blocks[id][i];
		if ( IsBlockInGroup(id, block) )
		{
			if ( IsBlockStuck(block) )
			{
				DeleteBlock(block);
				++blocks_deleted;
			}
			else
			{
				UnGroupBlock(block);
				++block_count;
			}
		}
	}
	
	g_group_count[id] = 0;
	
	if ( g_connected[id] )
	{
		if ( blocks_deleted > 0 )
		{
			BCM_Print(id, "Removed^1 %d^3 blocks from group. Deleted^1 %d^3 stuck blocks!", block_count, blocks_deleted);
		}
		else
		{
			BCM_Print(id, "Removed^1 %d^3 blocks from group!", block_count);
		}
	}
	
	return PLUGIN_HANDLED;
}

SetBlockRendering(ent, type, red, green, blue, alpha)
{
	if ( !IsBlock(ent) ) return PLUGIN_HANDLED;
	
	switch ( type )
	{
		case GLOWSHELL:		set_rendering(ent, kRenderFxGlowShell, red, green, blue, kRenderNormal, alpha);
		case TRANSCOLOR:	set_rendering(ent, kRenderFxGlowShell, red, green, blue, kRenderTransColor, alpha);
		case TRANSALPHA:	set_rendering(ent, kRenderFxNone, red, green, blue, kRenderTransColor, alpha);
		case TRANSWHITE:	set_rendering(ent, kRenderFxNone, red, green, blue, kRenderTransAdd, alpha);
		default:		set_rendering(ent, kRenderFxNone, red, green, blue, kRenderNormal, alpha);
	}
	
	return PLUGIN_HANDLED;
}

bool:IsBlock(ent)
{
	if ( !is_valid_ent(ent) ) return false;
	
	static classname[32];
	entity_get_string(ent, EV_SZ_classname, classname, charsmax(classname));
	
	if ( equal(classname, g_block_classname) )
	{
		return true;
	}
	
	return false;
}

bool:IsBlockInGroup(id, ent)
{
	if ( !is_valid_ent(ent) ) return false;
	
	new player = entity_get_int(ent, EV_INT_iuser1);
	if ( player == id ) return true;
	
	return false;
}

bool:IsBlockStuck(ent)
{
	if ( !is_valid_ent(ent) ) return false;
	
	new content;
	new Float:origin[3];
	new Float:point[3];
	new Float:size_min[3];
	new Float:size_max[3];
	
	entity_get_vector(ent, EV_VEC_mins, size_min);
	entity_get_vector(ent, EV_VEC_maxs, size_max);
	
	entity_get_vector(ent, EV_VEC_origin, origin);
	
	size_min[0] += 1.0;
	size_min[1] += 1.0;
	size_min[2] += 1.0;
	
	size_max[0] -= 1.0;
	size_max[1] -= 1.0; 
	size_max[2] -= 1.0;
	
	for ( new i = 0; i < 14; ++i )
	{
		point = origin;
		
		switch ( i )
		{
			case 0:
			{
					point[0] += size_max[0];
					point[1] += size_max[1];
					point[2] += size_max[2];
			}
			case 1:
			{
					point[0] += size_min[0];
					point[1] += size_max[1];
					point[2] += size_max[2];
			}
			case 2:
			{
					point[0] += size_max[0];
					point[1] += size_min[1];
					point[2] += size_max[2];
			}
			case 3:
			{
					point[0] += size_min[0];
					point[1] += size_min[1];
					point[2] += size_max[2];
			}
			case 4:
			{
					point[0] += size_max[0];
					point[1] += size_max[1];
					point[2] += size_min[2];
			}
			case 5:
			{
					point[0] += size_min[0];
					point[1] += size_max[1];
					point[2] += size_min[2];
			}
			case 6:
			{
					point[0] += size_max[0];
					point[1] += size_min[1];
					point[2] += size_min[2];
			}
			case 7:
			{
					point[0] += size_min[0];
					point[1] += size_min[1];
					point[2] += size_min[2];
			}
			case 8:		point[0] += size_max[0];
			case 9:		point[0] += size_min[0];
			case 10:	point[1] += size_max[1];
			case 11:	point[1] += size_min[1];
			case 12:	point[2] += size_max[2];
			case 13:	point[2] += size_min[2];
		}
		
		content = point_contents(point);
		if ( content == CONTENTS_EMPTY
		|| !content ) return false;
	}
	
	return true;
}

CreateTeleportAiming(id, teleport_type)
{
	if ( !g_admin[id] && !g_gived_access[id] )
	{
		console_print(id, "You have no access to that command");
		return PLUGIN_HANDLED;
	}
	
	static origin[3];
	static Float:float_origin[3];
	
	get_user_origin(id, origin, 3);
	IVecFVec(origin, float_origin);
	float_origin[2] += 36.0;
	
	CreateTeleport(id, teleport_type, float_origin);
	
	return PLUGIN_HANDLED;
}

CreateTeleport(id, teleport_type, Float:origin[3])
{
	new ent = create_entity("info_target");
	if ( !is_valid_ent(ent) ) return PLUGIN_HANDLED;
	
	switch ( teleport_type )
	{
		case TELEPORT_START:
		{
			if ( g_teleport_start[id] ) remove_entity(g_teleport_start[id]);
			
			entity_set_string(ent, EV_SZ_classname, g_start_classname);
			entity_set_int(ent, EV_INT_solid, SOLID_BBOX);
			entity_set_int(ent, EV_INT_movetype, MOVETYPE_NONE);
			entity_set_model(ent, g_sprite_teleport_start);
			entity_set_size(ent, Float:{ -16.0, -16.0, -16.0 }, Float:{ 16.0, 16.0, 16.0 });
			entity_set_origin(ent, origin);
			
			entity_set_int(ent, EV_INT_rendermode, 5);
			entity_set_float(ent, EV_FL_renderamt, 255.0);
			
			static params[2];
			params[0] = ent;
			params[1] = 6;
			
			set_task(0.1, "TaskSpriteNextFrame", TASK_SPRITE + ent, params, 2, g_b);
			
			g_teleport_start[id] = ent;
		}
		case TELEPORT_DESTINATION:
		{
			if ( !g_teleport_start[id] )
			{
				remove_entity(ent);
				return PLUGIN_HANDLED;
			}
			
			entity_set_string(ent, EV_SZ_classname, g_destination_classname);
			entity_set_int(ent, EV_INT_solid, SOLID_BBOX);
			entity_set_int(ent, EV_INT_movetype, MOVETYPE_NONE);
			entity_set_model(ent, g_sprite_teleport_destination);
			entity_set_size(ent, Float:{ -16.0, -16.0, -16.0 }, Float:{ 16.0, 16.0, 16.0 });
			entity_set_origin(ent, origin);
			
			entity_set_int(ent, EV_INT_rendermode, 5);
			entity_set_float(ent, EV_FL_renderamt, 255.0);
			
			entity_set_int(ent, EV_INT_iuser1, g_teleport_start[id]);
			entity_set_int(g_teleport_start[id], EV_INT_iuser1, ent);
			
			static params[2];
			params[0] = ent;
			params[1] = 4;
			
			set_task(0.1, "TaskSpriteNextFrame", TASK_SPRITE + ent, params, 2, g_b);
			
			g_teleport_start[id] = 0;
		}
	}
	
	return PLUGIN_HANDLED;
}

DeleteTeleportAiming(id)
{
	if ( !g_admin[id] && !g_gived_access[id] )
	{
		console_print(id, "You have no access to that command");
		return PLUGIN_HANDLED;
	}
	
	static ent, body;
	get_user_aiming(id, ent, body, 9999);
	
	new bool:deleted = DeleteTeleport(id, ent);
	if ( deleted ) BCM_Print(id, "Teleport deleted!");
	
	return PLUGIN_HANDLED;
}

bool:DeleteTeleport(id, ent)
{
	for ( new i = 0; i < 2; ++i )
	{
		if ( !IsTeleport(ent) ) return false;
		
		new tele = entity_get_int(ent, EV_INT_iuser1);
		
		if ( g_teleport_start[id] == ent
		|| g_teleport_start[id] == tele )
		{
			g_teleport_start[id] = 0;
		}
		
		if ( task_exists(TASK_SPRITE + ent) )
		{
			remove_task(TASK_SPRITE + ent);
		}
		
		if ( task_exists(TASK_SPRITE + tele) )
		{
			remove_task(TASK_SPRITE + tele);
		}
		
		if ( tele ) remove_entity(tele);
		
		remove_entity(ent);
		return true;
	}
	
	return false;
}

SwapTeleportAiming(id)
{
	if ( !g_admin[id] && !g_gived_access[id] )
	{
		console_print(id, "You have no access to that command");
		return PLUGIN_HANDLED;
	}
	
	static ent, body;
	get_user_aiming(id, ent, body, 9999);
	
	if ( !IsTeleport(ent) ) return PLUGIN_HANDLED;
	
	SwapTeleport(id, ent);
	
	return PLUGIN_HANDLED;
}

SwapTeleport(id, ent)
{
	static Float:origin_ent[3];
	static Float:origin_tele[3];
	
	new tele = entity_get_int(ent, EV_INT_iuser1);
	if ( !is_valid_ent(tele) )
	{
		BCM_Print(id, "Can't swap teleport positions!");
		return PLUGIN_HANDLED;
	}
	
	entity_get_vector(ent, EV_VEC_origin, origin_ent);
	entity_get_vector(tele, EV_VEC_origin, origin_tele);
	
	static classname[32];
	entity_get_string(ent, EV_SZ_classname, classname, charsmax(classname));
	
	DeleteTeleport(id, ent);
	
	if ( equal(classname, g_start_classname) )
	{
		CreateTeleport(id, TELEPORT_START, origin_tele);
		CreateTeleport(id, TELEPORT_DESTINATION, origin_ent);
	}
	else if ( equal(classname, g_destination_classname) )
	{
		CreateTeleport(id, TELEPORT_START, origin_ent);
		CreateTeleport(id, TELEPORT_DESTINATION, origin_tele);
	}
	
	BCM_Print(id, "Teleports swapped!");
	
	return PLUGIN_HANDLED;
}

ShowTeleportPath(id)
{
	static ent, body;
	get_user_aiming(id, ent, body);
	
	if ( !IsTeleport(ent) ) return PLUGIN_HANDLED;
	
	new tele = entity_get_int(ent, EV_INT_iuser1);
	if ( !tele ) return PLUGIN_HANDLED;
	
	static Float:origin1[3], Float:origin2[3], Float:dist;
	
	entity_get_vector(ent, EV_VEC_origin, origin1);
	entity_get_vector(tele, EV_VEC_origin, origin2);
	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(TE_BEAMPOINTS);
	write_coord(floatround(origin1[0], floatround_floor));
	write_coord(floatround(origin1[1], floatround_floor));
	write_coord(floatround(origin1[2], floatround_floor));
	write_coord(floatround(origin2[0], floatround_floor));
	write_coord(floatround(origin2[1], floatround_floor));
	write_coord(floatround(origin2[2], floatround_floor));
	write_short(g_sprite_beam);
	write_byte(0);
	write_byte(1);
	write_byte(50);
	write_byte(5);
	write_byte(0);
	write_byte(255);
	write_byte(255);
	write_byte(255);
	write_byte(255);
	write_byte(0);
	message_end();
	
	dist = get_distance_f(origin1, origin2);
	
	BCM_Print(id, "A line has been drawn to show the teleport path. Distance:^1 %f units", dist);
	
	return PLUGIN_HANDLED;
}

bool:IsTeleport(ent)
{
	if ( !is_valid_ent(ent) ) return false;
	
	static classname[32];
	entity_get_string(ent, EV_SZ_classname, classname, charsmax(classname));
	
	if ( equal(classname, g_start_classname)
	|| equal(classname, g_destination_classname) )
	{
		return true;
	}
	
	return false;
}

CreateLightAiming(const id)
{
	if ( !g_admin[id] && !g_gived_access[id] )
	{
		console_print(id, "You have no access to that command");
		return PLUGIN_HANDLED;
	}
	
	static origin[3];
	static Float:float_origin[3];
	
	get_user_origin(id, origin, 3);
	IVecFVec(origin, float_origin);
	float_origin[2] += 4.0;
	
	CreateLight(float_origin, "25", "255", "255", "255");
	
	return PLUGIN_HANDLED;
}

CreateLight(Float:origin[3], const radius[], const color_red[], const color_green[], const color_blue[])
{
	new ent = create_entity("info_target");
	if ( !is_valid_ent(ent) ) return 0;
	
	entity_set_origin(ent, origin);
	entity_set_model(ent, g_sprite_light);
	entity_set_float(ent, EV_FL_scale, 0.25);
	entity_set_string(ent, EV_SZ_classname, g_light_classname);
	entity_set_int(ent, EV_INT_solid, SOLID_BBOX);
	entity_set_int(ent, EV_INT_movetype, MOVETYPE_NONE);
	
	entity_set_size(ent, Float:{ -3.0, -3.0, -6.0 }, Float:{ 3.0, 3.0, 6.0 });
	
	static Float:color[3];
	color[0] = str_to_float(color_red);
	color[1] = str_to_float(color_green);
	color[2] = str_to_float(color_blue);
	
	entity_set_vector(ent, EV_VEC_rendercolor, color);
	
	SetProperty(ent, 1, radius);
	SetProperty(ent, 2, color_red);
	SetProperty(ent, 3, color_green);
	SetProperty(ent, 4, color_blue);
	
	entity_set_float(ent, EV_FL_nextthink, get_gametime() + 0.01);
	
	return ent;
}

DeleteLightAiming(id)
{
	if ( !g_admin[id] && !g_gived_access[id] )
	{
		console_print(id, "You have no access to that command");
		return PLUGIN_HANDLED;
	}
	
	static ent, body;
	get_user_aiming(id, ent, body);
	
	if ( !IsLight(ent) ) return PLUGIN_HANDLED;
	
	new grabber = entity_get_int(ent, EV_INT_iuser2);
	if ( grabber && grabber != id ) return PLUGIN_HANDLED;
	
	DeleteLight(ent);
	
	return PLUGIN_HANDLED;
}

bool:DeleteLight(ent)
{
	if ( !IsLight(ent) ) return false;
	
	remove_entity(ent);
	
	return true;
}

SetPropertiesLightAiming(id)
{
	if ( !g_admin[id] && !g_gived_access[id] )
	{
		console_print(id, "You have no access to that command");
		ShowLightMenu(id);
		return PLUGIN_HANDLED;
	}
	
	static ent, body;
	get_user_aiming(id, ent, body);
	
	if ( !IsLight(ent) )
	{
		ShowLightMenu(id);
		return PLUGIN_HANDLED;
	}
	
	g_viewing_light_properties_menu[id] = true;
	ShowLightPropertiesMenu(id, ent);
	
	return PLUGIN_HANDLED;
}

public SetPropertyLight(id)
{
	static arg[33];
	read_argv(1, arg, charsmax(arg));
	
	if ( !strlen(arg) )
	{
		BCM_Print(id, "You can't set a property blank! Please type a new value.");
		client_cmd(id, "messagemode BCM_SetLightProperty");
		return PLUGIN_HANDLED;
	}
	else if ( !is_str_num(arg) )
	{
		BCM_Print(id, "You can't use letters in a property! Please type a new value.");
		client_cmd(id, "messagemode BCM_SetLightProperty");
		return PLUGIN_HANDLED;
	}
	
	new ent = g_light_property_info[id][1];
	if ( !is_valid_ent(ent) )
	{
		BCM_Print(id, "That light has been deleted!");
		g_viewing_light_properties_menu[id] = false;
		ShowLightMenu(id);
		return PLUGIN_HANDLED;
	}
	
	static property;
	static property_value;
	
	property = g_light_property_info[id][0];
	property_value = str_to_num(arg);
	
	if ( property == 1 )
	{
		if ( !( 1 <= property_value <= 100 ) )
		{
			BCM_Print(id, "The property has to be between^1 1^3 and^1 100^3!");
			return PLUGIN_HANDLED;
		}
	}
	else if ( !( 0 <= property_value <= 255 ) )
	{
		BCM_Print(id, "The property has to be between^1 0^3 and^1 255^3!");
		return PLUGIN_HANDLED;
	}
	
	SetProperty(ent, property, arg);
	
	if ( property != 1 )
	{
		static color_red[5], color_green[5], color_blue[5];
		
		GetProperty(ent, 2, color_red);
		GetProperty(ent, 3, color_green);
		GetProperty(ent, 4, color_blue);
		
		static Float:color[3];
		color[0] = str_to_float(color_red);
		color[1] = str_to_float(color_green);
		color[2] = str_to_float(color_blue);
		
		entity_set_vector(ent, EV_VEC_rendercolor, color);
	}
	
	for ( new i = 1; i <= g_max_players; i++ )
	{
		if ( !g_connected[i]
		|| !g_viewing_light_properties_menu[i] ) continue;
		
		ent = g_light_property_info[i][1];
		ShowLightPropertiesMenu(i, ent);
	}
	
	return PLUGIN_HANDLED;
}

public LightThink(ent)
{
	static radius[5], color_red[5], color_green[5], color_blue[5];
	
	GetProperty(ent, 1, radius);
	GetProperty(ent, 2, color_red);
	GetProperty(ent, 3, color_green);
	GetProperty(ent, 4, color_blue);
	
	static Float:float_origin[3];
	entity_get_vector(ent, EV_VEC_origin, float_origin);
	
	static origin[3];
	FVecIVec(float_origin, origin);
	
	message_begin(MSG_PVS, SVC_TEMPENTITY, origin, 0);
	write_byte(TE_DLIGHT);
	write_coord(origin[0]);
	write_coord(origin[1]);
	write_coord(origin[2]);
	write_byte(str_to_num(radius));
	write_byte(str_to_num(color_red));
	write_byte(str_to_num(color_green));
	write_byte(str_to_num(color_blue));
	write_byte(1);
	write_byte(1);
	message_end();
	
	entity_set_float(ent, EV_FL_nextthink, get_gametime() + 0.01);
}

bool:IsLight(ent)
{
	if ( !is_valid_ent(ent) ) return false;
	
	static classname[32];
	entity_get_string(ent, EV_SZ_classname, classname, charsmax(classname));
	
	if ( equal(classname, g_light_classname) )
	{
		return true;
	}
	
	return false;
}

DoSnapping(id, ent, Float:move_to[3])
{
	if ( !g_snapping[id] ) return PLUGIN_HANDLED;
	
	new traceline;
	new closest_trace;
	new block_face;
	new Float:snap_size;
	new Float:v_return[3];
	new Float:dist;
	new Float:old_dist;
	new Float:trace_start[3];
	new Float:trace_end[3];
	new Float:size_min[3];
	new Float:size_max[3];
	
	entity_get_vector(ent, EV_VEC_mins, size_min);
	entity_get_vector(ent, EV_VEC_maxs, size_max);
	
	snap_size = g_snapping_gap[id] + 10.0;
	old_dist = 9999.9;
	closest_trace = 0;
	for ( new i = 0; i < 6; ++i )
	{
		trace_start = move_to;
		
		switch ( i )
		{
			case 0: trace_start[0] += size_min[0];
			case 1: trace_start[0] += size_max[0];
			case 2: trace_start[1] += size_min[1];
			case 3: trace_start[1] += size_max[1];
			case 4: trace_start[2] += size_min[2];
			case 5: trace_start[2] += size_max[2];
		}
		
		trace_end = trace_start;
		
		switch ( i )
		{
			case 0: trace_end[0] -= snap_size;
			case 1: trace_end[0] += snap_size;
			case 2: trace_end[1] -= snap_size;
			case 3: trace_end[1] += snap_size;
			case 4: trace_end[2] -= snap_size;
			case 5: trace_end[2] += snap_size;
		}
		
		traceline = trace_line(ent, trace_start, trace_end, v_return);
		if ( IsBlock(traceline)
		&& ( !IsBlockInGroup(id, traceline) || !IsBlockInGroup(id, ent) ) )
		{
			dist = get_distance_f(trace_start, v_return);
			if ( dist < old_dist )
			{
				closest_trace = traceline;
				old_dist = dist;
				
				block_face = i;
			}
		}
	}
	
	if ( !is_valid_ent(closest_trace) ) return PLUGIN_HANDLED;
	
	static Float:trace_origin[3];
	static Float:trace_size_min[3];
	static Float:trace_size_max[3];
	
	entity_get_vector(closest_trace, EV_VEC_origin, trace_origin);
	entity_get_vector(closest_trace, EV_VEC_mins, trace_size_min);
	entity_get_vector(closest_trace, EV_VEC_maxs, trace_size_max);
	
	move_to = trace_origin;
	
	if ( block_face == 0 ) move_to[0] += ( trace_size_max[0] + size_max[0] ) + g_snapping_gap[id];
	if ( block_face == 1 ) move_to[0] += ( trace_size_min[0] + size_min[0] ) - g_snapping_gap[id];
	if ( block_face == 2 ) move_to[1] += ( trace_size_max[1] + size_max[1] ) + g_snapping_gap[id];
	if ( block_face == 3 ) move_to[1] += ( trace_size_min[1] + size_min[1] ) - g_snapping_gap[id];
	if ( block_face == 4 ) move_to[2] += ( trace_size_max[2] + size_max[2] ) + g_snapping_gap[id];
	if ( block_face == 5 ) move_to[2] += ( trace_size_min[2] + size_min[2] ) - g_snapping_gap[id];
	
	return PLUGIN_HANDLED;
}

DeleteAll(id, bool:notify)
{
	if ( !g_admin[id] )
	{
		console_print(id, "You have no access to that command");
		return PLUGIN_HANDLED;
	}
	
	static ent, block_count, tele_count, light_count, bool:deleted;
	
	ent = -1;
	block_count = 0;
	while ( ( ent = find_ent_by_class(ent, g_block_classname) ) )
	{
		deleted = DeleteBlock(ent);
		if ( deleted )
		{
			++block_count;
		}
	}
	
	ent = -1;
	tele_count = 0;
	while ( ( ent = find_ent_by_class(ent, g_start_classname) ) )
	{
		deleted = DeleteTeleport(id, ent);
		if ( deleted )
		{
			++tele_count;
		}
	}
	
	ent = -1;
	light_count = 0;
	while ( ( ent = find_ent_by_class(ent, g_light_classname) ) )
	{
		deleted = DeleteLight(ent);
		if ( deleted )
		{
			++light_count;
		}
	}
	
	if ( ( block_count
		|| tele_count
		|| light_count )
	&& notify )
	{
		static name[32];
		get_user_name(id, name, charsmax(name));
		
		for ( new i = 1; i <= g_max_players; ++i )
		{
			g_grabbed[i] = 0;
			g_teleport_start[i] = 0;
			
			if ( !g_connected[i]
			|| !g_admin[i] && !g_gived_access[i] ) continue;
			
			BCM_Print(i, "^1%s^3 deleted^1 %d blocks^3,^1 %d teleports^3 and^1 %d lights^3 from the map!", name, block_count, tele_count, light_count);
		}
	}
	
	return PLUGIN_HANDLED;
}

SaveBlocks(id)
{
	if ( !g_admin[id] )
	{
		console_print(id, "You have no access to that command");
		return PLUGIN_HANDLED;
	}
	
	new ent;
	new file;
	new data[128];
	new block_count;
	new tele_count;
	new light_count;
	new block_type;
	new size;
	new property1[5], property2[5], property3[5], property4[5];
	new tele;
	new Float:origin[3];
	new Float:angles[3];
	new Float:tele_start[3];
	new Float:tele_end[3];
	new Float:max_size;
	new Float:size_max[3];
	
	file = fopen(g_file, "wt");
	
	block_count = 0;
	tele_count = 0;
	
	ent = -1;
	while ( ( ent = find_ent_by_class(ent, g_block_classname) ) )
	{
		block_type = entity_get_int(ent, EV_INT_body);
		entity_get_vector(ent, EV_VEC_origin, origin);
		entity_get_vector(ent, EV_VEC_angles, angles);
		entity_get_vector(ent, EV_VEC_maxs, size_max);
		
		GetProperty(ent, 1, property1);
		GetProperty(ent, 2, property2);
		GetProperty(ent, 3, property3);
		GetProperty(ent, 4, property4);
		
		if ( !property1[0] ) copy(property1, charsmax(property1), "/");
		if ( !property2[0] ) copy(property2, charsmax(property2), "/");
		if ( !property3[0] ) copy(property3, charsmax(property3), "/");
		if ( !property4[0] ) copy(property4, charsmax(property4), "/");
		
		max_size = size_max[0] + size_max[1] + size_max[2];
		
		if ( max_size > 128.0 )		size = LARGE;
		else if ( max_size > 64.0 )	size = NORMAL;
		else				size = TINY;
		
		formatex(data, charsmax(data), "%c %f %f %f %f %f %f %d %s %s %s %s^n",\
			g_block_save_ids[block_type],\
			origin[0],\
			origin[1],\
			origin[2],\
			angles[0],\
			angles[1],\
			angles[2],\
			size,\
			property1,\
			property2,\
			property3,\
			property4
			);
		fputs(file, data);
		
		++block_count;
	}
	
	ent = -1;
	while ( ( ent = find_ent_by_class(ent, g_destination_classname) ) )
	{
		tele = entity_get_int(ent, EV_INT_iuser1);
		if ( tele )
		{
			entity_get_vector(tele, EV_VEC_origin, tele_start);
			entity_get_vector(ent, EV_VEC_origin, tele_end);
			
			formatex(data, charsmax(data), "* %f %f %f %f %f %f^n",\
				tele_start[0],\
				tele_start[1],\
				tele_start[2],\
				tele_end[0],\
				tele_end[1],\
				tele_end[2]
				);
			fputs(file, data);
			
			++tele_count;
		}
	}
	
	ent = -1;
	while ( ( ent = find_ent_by_class(ent, g_light_classname) ) )
	{
		entity_get_vector(ent, EV_VEC_origin, origin);
		
		GetProperty(ent, 1, property1);
		GetProperty(ent, 2, property2);
		GetProperty(ent, 3, property3);
		GetProperty(ent, 4, property4);
		
		formatex(data, charsmax(data), "! %f %f %f / / / / %s %s %s %s^n",\
			origin[0],\
			origin[1],\
			origin[2],\
			property1,\
			property2,\
			property3,\
			property4
			);
		fputs(file, data);
		
		++light_count;
	}
	
	static name[32];
	get_user_name(id, name, charsmax(name));
	
	for ( new i = 1; i <= g_max_players; ++i )
	{
		if ( g_connected[i]
		&& ( g_admin[i] || g_gived_access[i] ) )
		{
			BCM_Print(i, "^1%s^3 saved^1 %d block%s^3,^1 %d teleport%s^3 and^1 %d light%s^3! Total entites in map:^1 %d", name, block_count, block_count == 1 ? g_blank : "s", tele_count, tele_count == 1 ? g_blank : "s", light_count, light_count == 1 ? g_blank : "s", entity_count());
		}
	}
	
	fclose(file);
	return PLUGIN_HANDLED;
}

LoadBlocks(id)
{
	if ( id != 0 && !g_admin[id] )
	{
		console_print(id, "You have no access to that command");
		return PLUGIN_HANDLED;
	}
	else if ( !file_exists(g_file)
	&& 1 <= id <= g_max_players )
	{
		BCM_Print(id, "Couldn't find file:^1 %s", g_file);
		return PLUGIN_HANDLED;
	}
	
	if ( 1 <= id <= g_max_players )
	{
		DeleteAll(id, false);
	}
	
	new file;
	new data[128];
	new block_count;
	new tele_count;
	new light_count;
	new type[2];
	new block_size[17];
	new origin_x[17];
	new origin_y[17];
	new origin_z[17];
	new angel_x[17];
	new angel_y[17];
	new angel_z[17];
	new block_type;
	new axis;
	new size;
	new property1[5], property2[5], property3[5], property4[5];
	new Float:origin[3];
	new Float:angles[3];
	
	file = fopen(g_file, "rt");
	
	block_count = 0;
	tele_count = 0;
	
	while ( !feof(file) )
	{
		type = g_blank;
		
		fgets(file, data, charsmax(data));
		parse(data,\
			type, charsmax(type),\
			origin_x, charsmax(origin_x),\
			origin_y, charsmax(origin_y),\
			origin_z, charsmax(origin_z),\
			angel_x, charsmax(angel_x),\
			angel_y, charsmax(angel_y),\
			angel_z, charsmax(angel_z),\
			block_size, charsmax(block_size),\
			property1, charsmax(property1),\
			property2, charsmax(property2),\
			property3, charsmax(property3),\
			property4, charsmax(property4)
			);
		
		origin[0] =	str_to_float(origin_x);
		origin[1] =	str_to_float(origin_y);
		origin[2] =	str_to_float(origin_z);
		angles[0] =	str_to_float(angel_x);
		angles[1] =	str_to_float(angel_y);
		angles[2] =	str_to_float(angel_z);
		size =		str_to_num(block_size);
		
		if ( strlen(type) > 0 )
		{
			if ( type[0] != '*' )
			{
				if ( angles[0] == 90.0 && angles[1] == 0.0 && angles[2] == 0.0 )
				{
					axis = X;
				}
				else if ( angles[0] == 90.0 && angles[1] == 0.0 && angles[2] == 90.0 )
				{
					axis = Y;
				}
				else
				{
					axis = Z;
				}
			}
			
			switch ( type[0] )
			{
				case 'A': block_type = PLATFORM;
				case 'B': block_type = BUNNYHOP;
				case 'C': block_type = DAMAGE;
				case 'D': block_type = HEALER;
				case 'E': block_type = NO_FALL_DAMAGE;
				case 'F': block_type = ICE;
				case 'G': block_type = TRAMPOLINE;
				case 'H': block_type = SPEED_BOOST;
				case 'I': block_type = DEATH;
				case 'J': block_type = LOW_GRAVITY;
				case 'K': block_type = SLAP;
				case 'L': block_type = HONEY;
				case 'M': block_type = CT_BARRIER;
				case 'N': block_type = T_BARRIER;
				case 'O': block_type = GLASS;
				case 'P': block_type = NO_SLOW_DOWN_BUNNYHOP;
				case 'Q': block_type = DELAYED_BUNNYHOP;
				case 'R': block_type = INVINCIBILITY;
				case 'S': block_type = STEALTH;
				case 'T': block_type = BOOTS_OF_SPEED;
				case 'U': block_type = XPBLOCK;
				case '*':
				{
					CreateTeleport(0, TELEPORT_START, origin);
					CreateTeleport(0, TELEPORT_DESTINATION, angles);
					
					++tele_count;
				}
				case '!':
				{
					CreateLight(origin, property1, property2, property3, property4);
					
					++light_count;
				}
			}
			
			if ( type[0] != '*' && type[0] != '!' )
			{
				CreateBlock(0, block_type, origin, axis, size, property1, property2, property3, property4);
				
				++block_count;
			}
		}
	}
	
	fclose(file);
	
	if ( 1 <= id <= g_max_players )
	{
		static name[32];
		get_user_name(id, name, charsmax(name));
		
		for ( new i = 1; i <= g_max_players; ++i )
		{
			if ( !g_connected[i]
			|| !g_admin[i] && !g_gived_access[i] ) continue;
			
			BCM_Print(i, "^1%s^3 loaded^1 %d block%s^3,^1 %d teleport%s^3 and^1 %d light%s^3! Total entites in map:^1 %d", name, block_count, block_count == 1 ? g_blank : "s", tele_count, tele_count == 1 ? g_blank : "s", light_count, light_count == 1 ? g_blank : "s", entity_count());
		}
	}
	
	return PLUGIN_HANDLED;
}

bool:IsStrFloat(string[])
{
	new len = strlen(string);
	for ( new i = 0; i < len; i++ )
	{
		switch ( string[i] )
		{
			case '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '.', '-':	continue;
			default:							return false;
		}
	}
	
	return true;
}

ResetPlayer(id)
{
	g_no_fall_damage[id] =		false;
	g_ice[id] =			false;
	g_low_gravity[id] =		false;
	g_no_slow_down[id] =		false;
	g_block_status[id] =		false;
	g_has_hud_text[id] =		false;
	
	g_slap_times[id] =		0;
	g_honey[id] =			0;
	g_boots_of_speed[id] =		0;
	
	g_next_damage_time[id] =	0.0;
	g_next_heal_time[id] =		0.0;
	g_invincibility_time_out[id] =	0.0;
	g_invincibility_next_use[id] =	0.0;
	g_stealth_time_out[id] =	0.0;
	g_stealth_next_use[id] =	0.0;
	g_boots_of_speed_time_out[id] =	0.0;
	g_boots_of_speed_next_use[id] =	0.0;
	
	new task_id = TASK_INVINCIBLE + id;
	if ( task_exists(task_id) )
	{
		TaskRemoveInvincibility(task_id);
		remove_task(task_id);
	}
	
	task_id = TASK_STEALTH + id;
	if ( task_exists(task_id) )
	{
		TaskRemoveStealth(task_id);
		remove_task(task_id);
	}
	
	task_id = TASK_BOOTSOFSPEED + id;
	if ( task_exists(task_id) )
	{
		TaskRemoveBootsOfSpeed(task_id);
		remove_task(task_id);
	}
	
	if ( g_connected[id] )
	{
		set_user_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderNormal, 255);
	}
	
	g_reseted[id] =			true;
}

ResetMaxspeed(id)
{
	static Float:max_speed;
	switch ( get_user_weapon(id) )
	{
		case CSW_SG550, CSW_AWP, CSW_G3SG1:		max_speed = 210.0;
		case CSW_M249:					max_speed = 220.0;
		case CSW_AK47:					max_speed = 221.0;
		case CSW_M3, CSW_M4A1:				max_speed = 230.0;
		case CSW_SG552:					max_speed = 235.0;
		case CSW_XM1014, CSW_AUG, CSW_GALIL, CSW_FAMAS:	max_speed = 240.0;
		case CSW_P90:					max_speed = 245.0;
		case CSW_SCOUT:					max_speed = 260.0;
		default:					max_speed = 250.0;
	}
	
	entity_set_float(id, EV_FL_maxspeed, max_speed);
}

BCM_Print(id, const message_fmt[], any:...)
{
	static i; i = id ? id : GetPlayer();
	if ( !i ) return;
	
	static message[256], len;
	len = formatex(message, charsmax(message), "^4[%s %s]^3 ", PLUGIN_PREFIX, PLUGIN_VERSION);
	vformat(message[len], charsmax(message) - len, message_fmt, 3);
	message[192] = 0;
	
	static msgid_SayText;
	if ( !msgid_SayText ) msgid_SayText = get_user_msgid("SayText");
	
	static const team_names[][] =
	{
		"",
		"TERRORIST",
		"CT",
		"SPECTATOR"
	};
	
	static team; team = get_user_team(i);
	
	TeamInfo(i, id, team_names[0]);
	
	message_begin(id ? MSG_ONE_UNRELIABLE : MSG_BROADCAST, msgid_SayText, _, id);
	write_byte(i);
	write_string(message);
	message_end();
	
	TeamInfo(i, id, team_names[team]);
}

TeamInfo(receiver, sender, team[])
{
	static msgid_TeamInfo;
	if ( !msgid_TeamInfo ) msgid_TeamInfo = get_user_msgid("TeamInfo");
	
	message_begin(sender ? MSG_ONE_UNRELIABLE : MSG_BROADCAST, msgid_TeamInfo, _, sender);
	write_byte(receiver);
	write_string(team);
	message_end();
}

GetPlayer()
{
	for ( new id = 1; id <= g_max_players; id++ )
	{
		if ( !g_connected[id] ) continue;
		
		return id;
	}
	
	return 0;
}
[/code]