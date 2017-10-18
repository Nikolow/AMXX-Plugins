#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <engine>
#include <fakemeta>
#include <hamsandwich>
#include <fun>

#pragma semicolon 1

#define PLUGIN_NAME				"BetterPlay Blockmaker"
#define PLUGIN_VERSION				"2.4"
#define PLUGIN_AUTHOR				"Smiley"
#define PLUGIN_PREFIX				"BetterPlay"

new death[ 33 ], player_has_a_stealth[ 33 ], g_stealth_duration[ 33 ];
new const iDeathBlockType[ ][ ] =
{
	"Death Block", "Bounce Death Block"
};

new const g_blank[] =				"";
new const g_a[] =				"a";
new const g_b[] =				"b";

new const g_block_classname[] =			"BCM_Block";
new const g_start_classname[] =			"BCM_TeleportStart";
new const g_destination_classname[] =		"BCM_TeleportDestination";
new const g_light_classname[] =			"BCM_Light";

new const g_model_platform[] =			"models/BetterPlay_BM/Normal/platform.mdl";
new const g_model_bunnyhop[] =			"models/BetterPlay_BM/Normal/bhop.mdl";
new const g_model_damage[] =			"models/BetterPlay_BM/Normal/damage.mdl";
new const g_model_healer[] =			"models/BetterPlay_BM/Normal/healer.mdl";
new const g_model_no_fall_damage[] =		"models/BetterPlay_BM/Normal/nofalldamage.mdl";
new const g_model_ice[] =			"models/BetterPlay_BM/Normal/ice.mdl";
new const g_model_trampoline[] =			"models/BetterPlay_BM/Normal/trampoline.mdl";
new const g_model_speed_boost[] =		"models/BetterPlay_BM/Normal/speedboost.mdl";
new const g_model_death[] =			"models/BetterPlay_BM/Normal/death.mdl";
new const g_model_low_gravity[] =		"models/BetterPlay_BM/Normal/lowgravity.mdl";
new const g_model_slap[] =			"models/BetterPlay_BM/Normal/slap.mdl";
new const g_model_honey[] =			"models/BetterPlay_BM/Normal/honey.mdl";
new const g_model_ct_barrier[] =			"models/BetterPlay_BM/Normal/barrier_ct.mdl";
new const g_model_t_barrier[] =			"models/BetterPlay_BM/Normal/barrier_t.mdl";
new const g_model_glass[] =			"models/BetterPlay_BM/Normal/glass.mdl";
new const g_model_no_slow_down_bunnyhop[] =	"models/BetterPlay_BM/Normal/bhop_nsd.mdl";
new const g_model_delayed_bunnyhop[] =		"models/BetterPlay_BM/Normal/delay_bhop.mdl";
new const g_model_invincibility[] =		"models/BetterPlay_BM/Normal/godmode.mdl";
new const g_model_stealth[] =			"models/BetterPlay_BM/Normal/stealth.mdl";
new const g_model_boots_of_speed[] =		"models/BetterPlay_BM/Normal/bootsofspeed.mdl";
new const g_model_deagle[] =			"models/BetterPlay_BM/Normal/deagle.mdl";
new const g_model_awp[] =			"models/BetterPlay_BM/Normal/awp.mdl";
new const g_model_shotgun[] =			"models/BetterPlay_BM/Normal/shotgun.mdl";
new const g_model_he[] =				"models/BetterPlay_BM/Normal/he.mdl";
new const g_model_flash[] =			"models/BetterPlay_BM/Normal/flash.mdl";
new const g_model_frost[] =			"models/BetterPlay_BM/Normal/frost.mdl";
new const g_model_xp[] =				"models/BetterPlay_BM/Normal/xp.mdl";
new const g_model_point[] =			"models/BetterPlay_BM/Normal/bmpoints.mdl";	//
new const g_model_nades[] =			"models/BetterPlay_BM/Normal/grenades.mdl";
new const g_model_pistols[] =			"models/BetterPlay_BM/Normal/pistols.mdl";
new const g_model_rifles[] =			"models/BetterPlay_BM/Normal/rifles.mdl";
new const g_model_scout[] =			"models/BetterPlay_BM/Normal/scout.mdl";
new const g_model_famas[] =			"models/BetterPlay_BM/Normal/famas.mdl";	//
new const g_model_bouncedeath[] =		"models/BetterPlay_BM/Normal/death.mdl";
new const g_model_carpet[] =			"models/BetterPlay_BM/Normal/magiccarpet.mdl";	//
new const g_model_teleport[] =			"models/BetterPlay_BM/Normal/teleport.mdl";
new const g_model_destination[] =		"models/BetterPlay_BM/Normal/teleport.mdl";

new const g_sprite_light[] =			"sprites/lightmaker/lightmaker.spr";

new const g_sprite_teleport_start[] =		"models/BetterPlay_BM/bp_start.spr";
new const g_sprite_teleport_destination[] =	"models/BetterPlay_BM/bp_end.spr";

new const g_sound_invincibility[] =		"BetterPlay/invicibility.wav";
new const g_sound_stealth[] =			"BetterPlay/stealth.wav";
new const g_sound_boots_of_speed[] =		"BetterPlay/speedboots.wav";
new const g_sound_bmpoint[] =			"BetterPlay/bmpoint.wav";
new const g_sound_xp[] =			"BetterPlay/expirience.wav";

new g_sprite_beam;

native hnsxp_get_user_xp( client );
native hnsxp_set_user_xp( client, xp );
native hnsxp_get_user_health( client );

native hnsshop_get_user_points( client );
native hnsshop_set_user_points( client, points );

public plugin_natives( )
{
	register_library( "betterplay_bm" );
	register_native( "bm_player_has_a_stealth", "_return_info" );
	register_native( "bm_player_stealth_duration", "_return_info_duration" );
}

public _return_info( plugin, params ) { return player_has_a_stealth[ get_param( 1 ) ]; }
public _return_info_duration( plugin, params ) { return g_stealth_duration[ get_param( 1 ) ]; }

const r = 50;
const g = 50;
const b = 200;

const Float:x = -1.0;
const Float:y = 0.84;

const effects = 0;
const channel = -4;

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
	TASK_BOOTSOFSPEED,
	TASK_MOVEBACK
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
new g_teleport_block_start[33];
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

new bool:iDeagle[ 33 ], bool:iAwp[ 33 ], bool:iShotgun[ 33 ], bool:iHe[ 33 ], bool:iFlash[ 33 ], bool:iFrost[ 33 ], bool:iXP[ 33 ], bool:iPoint[ 33 ], bool:iNades[ 33 ], bool:iPistols[ 33 ], bool:iRifles[ 33 ], bool:iScout[ 33 ], bool:iFamas[ 33 ];
new g_max_players;

new g_keys_nades = ( 1 << 0 ) | ( 1 << 1 ) | ( 1 << 2 ) | ( 1 << 9 );
new g_keys_pistols = ( 1 << 0 ) | ( 1 << 1 ) | ( 1 << 2 ) | ( 1 << 9 );
new g_keys_rifles = ( 1 << 0 ) | ( 1 << 1 ) | ( 1 << 9 );

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
	DEAGLE,
	AWP,
	SHOTGUN,
	HE,
	FLASH,
	FROST,
	XP,
	POINT,
	NADES,
	PISTOLS,
	RIFLES,
	SCOUT,
	FAMAS,
	BOUNCE_DEATH,
	MAGIC_CARPET,
	TELEPORT,
	DESTINATION,
	
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
	"Deagle",
	"AWP",
	"Shotgun",
	"HE Grenade",
	"Flashbang",
	"Frostnade",
	"XP Block",
	"Point Block",
	"Nades Block",
	"Pistols Block",
	"Rifles Block",
	"Scout",
	"Famas",
	"Bounce Death",
	"Magic Carpet",
	"Teleport Block",
	"Destination Block"
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
	"Ammo", // Deagle
	"Ammo", // AWP
	"Ammo",  // Shotgun
	"", 	// he
	"", 	// flash
	"", 	// frost
	"XP",	// xp
	"Point", // point
	"", 	// nades
	"", 	// pistols
	"", 	// rifles
	"Ammo", // scout
	"Ammo",  // famas
	"Bouncing Height",
	"", 	// carpet
	"Teleport Name",
	"Destinatoin Name"
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
	"1", // Deagle
	"1", // AWP
	"1",  // Shotgun
	"", 	// he
	"", 	// flash
	"", 	// frost
	"50",	// xp
	"1",	// point
	"", 	// nades
	"", 	// pistols
	"", 	// rifles
	"1", 	// scout
	"1", 	// famas
	"400",	// bounce death
	"", 	// carpet
	"Name", // teleport
	"Name"	// destination
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
	"", // Deagle
	"", // AWP
	"",  // Shotgun
	"", 	// he
	"", 	// flash
	"", 	// frost
	"", 	// xp
	"", 	// point
	"", 	// nades
	"", 	// pistols
	"", 	// rifles
	"", 	// scout
	"", 	// famas
	"", 	// bounce death
	"Delay Before Respawn", // carpet
	"", 	// teleport
	""	// destination
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
	"", // Deagle
	"", // AWP
	"",  // Shotgun
	"", 	// he
	"", 	// flash
	"", 	// frost
	"", 	// xp
	"", 	// point
	"", 	// nades
	"", 	// pistols
	"", 	// rifles
	"", 	// scout
	"", 	// famas
	"", 	// bounce death
	"5",	// carpet
	"", 	// teleport
	""	// destination
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
	"Transparency", // deagle
	"Transparency", // awp
	"Transparency", // shotgun
	"Transparency", // he
	"Transparency", // flash
	"Transparency", // frost
	"Transparency", // xp
	"Transparency", // point
	"Transparency", // nades
	"Transparency", // pistols
	"Transparency", // rifles
	"Transparency", // scout
	"Transparency", // famas
	"Transparency", // bounce death
	"Transparency",	// carpet
	"Transparency",	// teleport
	"Transparency"	// destination
};

new const g_property3_default_value[TOTAL_BLOCKS][] =
{
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
	"",
	"255",
	"255",
	"",
	"",
	"400",
	"255", // deagle
	"255", // awp
	"255",  // shotgun
	"255", // he
	"255", // flash
	"255",  // frost
	"255", // xp
	"255", // point
	"255", // nades
	"255", // pistols
	"255", 	// rifles
	"255", // scout
	"255", // famas
	"255",  // bounce death
	"255",	// carpet
	"255",  // teleport
	"255"	// destination
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
	"On Top Only", // deagle
	"On Top Only", // awp
	"On Top Only",  // shotgun
	"On Top Only", // he
	"On Top Only", // flash
	"On Top Only",  // frost
	"On Top Only", // xp
	"On Top Only",  // point
	"On Top Only", // nades
	"On Top Only", // pistols
	"On Top Only", 	// rifles
	"On Top Only", // scout
	"On Top Only", // famas
	"On Top Only", 	// bounce death
	"On Top Only",	// carpet
	"On Top Only", 	// teleport
	"On Top Only"	// destination
};

new const g_property4_default_value[TOTAL_BLOCKS][] =
{
	"",
	"1",
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
	"1",
	"0",
	"1",
	"1",
	"1",
	"1", // deagle
	"1", // awp
	"1",  // shotgun
	"1", // he
	"1", // flash
	"1",  // frost
	"1", // xp
	"1",  // point
	"1", // nades
	"1", // pistols
	"1", // rifles
	"1", // scout
	"1", // famas
	"1", 	// bounce death
	"1",	// carpet
	"1", 	// teleport
	"1"	// destination
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
	'U', // deagle
	'Y', // AWP
	'Z',  // shotgun
	'X', // he
	'W', // flash
	'V', // frost
	'a', // xp
	'b',  // point
	'c', // nades
	'd', // pistols
	'e',  // rifles
	'f', // scout
	'g', // famas
	'h', // bounce death
	'i',  // carpet
	'j',  // teleport
	'k'   // destination
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
	g_block_models[DEAGLE] =		g_model_deagle;
	g_block_models[AWP] =			g_model_awp;
	g_block_models[SHOTGUN] =		g_model_shotgun;
	g_block_models[HE] =			g_model_he;
	g_block_models[FLASH] =			g_model_flash;
	g_block_models[FROST] =			g_model_frost;
	g_block_models[XP] =			g_model_xp;
	g_block_models[POINT] =			g_model_point;
	g_block_models[NADES] =			g_model_nades;
	g_block_models[PISTOLS] =		g_model_pistols;
	g_block_models[RIFLES] =		g_model_rifles;
	g_block_models[SCOUT] =			g_model_scout;
	g_block_models[FAMAS] =			g_model_famas;
	g_block_models[BOUNCE_DEATH] =		g_model_bouncedeath;
	g_block_models[MAGIC_CARPET] =		g_model_carpet;
	g_block_models[TELEPORT] =		g_model_teleport;
	g_block_models[DESTINATION] =		g_model_destination;
	
	SetupBlockRendering(GLASS, TRANSWHITE, 255, 255, 255, 100);
	SetupBlockRendering(INVINCIBILITY, GLOWSHELL, 255, 255, 255, 16);
	SetupBlockRendering(STEALTH, TRANSWHITE, 255, 255, 255, 100);
	
	SetupBlockRendering( DEAGLE, TRANSCOLOR, 0, 255, 0, 150 );
	SetupBlockRendering( AWP, TRANSCOLOR, 255, 0, 0, 150 );
	SetupBlockRendering( SHOTGUN, TRANSCOLOR, 0, 127, 255, 150 );
		
	SetupBlockRendering( HE, TRANSCOLOR, 0, 150, 200, 150 );
	SetupBlockRendering( FLASH, TRANSCOLOR, 0, 200, 150, 150 );
	SetupBlockRendering( FROST, TRANSCOLOR, 200, 150, 150, 150 );
		
	SetupBlockRendering( XP, TRANSCOLOR, 45, 54, 76, 150 );
	SetupBlockRendering( POINT, TRANSCOLOR, 54, 67, 45, 150 );
		
	SetupBlockRendering( NADES, TRANSCOLOR, 160, 109, 132, 150 );
	SetupBlockRendering( PISTOLS, TRANSCOLOR, 129, 198, 93, 150 );
	SetupBlockRendering( RIFLES, TRANSCOLOR, 16, 115, 164, 150 );
		
	SetupBlockRendering( SCOUT, TRANSCOLOR, 255, 255, 0, 150 );
	SetupBlockRendering( FAMAS, TRANSCOLOR, 143, 0, 55, 150 );

	new block_model[256];
	for ( new i = 0; i < TOTAL_BLOCKS; ++i )
	{
		precache_model(g_block_models[i]);
		
		SetBlockModelName(block_model, g_block_models[i], "Small");
		precache_model(block_model);
		
		SetBlockModelName(block_model, g_block_models[i], "Large");
		precache_model(block_model);
		
		SetBlockModelName(block_model, g_block_models[i], "Pole");
		precache_model(block_model);
	}
	
	precache_model(g_sprite_light);
	
	precache_model(g_sprite_teleport_start);
	precache_model(g_sprite_teleport_destination);
	g_sprite_beam = precache_model("sprites/zbeam4.spr");
	
	precache_sound(g_sound_invincibility);
	precache_sound(g_sound_stealth);
	precache_sound(g_sound_boots_of_speed);
	precache_sound(g_sound_bmpoint);
	precache_sound(g_sound_xp);
	precache_sound( "BetterPlay/lightningbolt.wav" );
	precache_sound( "BetterPlay/bp_teleport.wav" );
}

public plugin_init()
{
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR);
	
	RegisterSayCmd("/rcm",			"CmdMainMenu");
	
	new command[ 32 ] =			"CmdSaveCheckpoint";
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
	register_clcmd("+bmGrab",		command,		-1, g_blank);
	register_clcmd("+bmGrab",		command,		-1, g_blank);
	
	command =				"CmdRelease";
	register_clcmd("-bmGrab",		command,		-1, g_blank);
	register_clcmd("-bmGrab",		command,		-1, g_blank);
	
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
	
	register_menu( "NadesMenu", 		g_keys_nades,	 	"NadesMenuHandler" );
	register_menu( "PistolsMenu", 		g_keys_pistols, 	"PistolsMenuHandler" );
	register_menu( "RiflesMenu", 		g_keys_rifles, 		"RiflesMenuHandler" );
	
	RegisterHam(Ham_Spawn,		"player",	"FwdPlayerSpawn",	1);
	RegisterHam(Ham_Killed,		"player",	"FwdPlayerKilled",	1);
	
	register_forward(FM_CmdStart,			"FwdCmdStart");

	register_think(g_light_classname,		"LightThink");
	
	register_event("CurWeapon",			"EventCurWeapon",	"be");
	
	register_message(get_user_msgid("StatusValue"),	"MsgStatusValue");

	g_max_players =		get_maxplayers();
	set_task( 600.0, "task_task", _, _, _, "b" );

	new dir[64];
	get_datadir(dir, charsmax(dir));
	
	new folder[64];
	formatex(folder, charsmax(folder), "/BetterPlaySaveBlocks", PLUGIN_PREFIX);
	
	add(dir, charsmax(dir), folder);
	if ( !dir_exists(dir) ) mkdir(dir);
	
	new map[32];
	get_mapname(map, charsmax(map));
	
	formatex(g_file, charsmax(g_file), "%s/%s.sm", dir, map);
}

public plugin_cfg()
{
	LoadBlocks(0);
}

public client_putinserver(id)
{
	g_connected[id] =			bool:!is_user_hltv(id);
	g_alive[id] =				false;
	
	g_admin[id] =				bool:access(id, ADMIN_RCON);
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
	
	formatex(temp, charsmax(temp), "say /bm", command);
	register_clcmd(temp, handle, -1, g_blank);
	
	formatex(temp, charsmax(temp), "say_team /bm", command);
	register_clcmd(temp, handle, -1, g_blank);
}

CreateMenus()
{
	g_block_selection_pages_max = floatround((float(TOTAL_BLOCKS) / 8.0), floatround_ceil);
	
	new size = charsmax(g_main_menu);
	add(g_main_menu, size, "\y%s \rv%s^n^n");
	add(g_main_menu, size, "\r1. \wBlock Menu^n");
	add(g_main_menu, size, "\r2. \wTeleport Menu^n");
	add(g_main_menu, size, "\r3. \wLight Menu^n");
	add(g_main_menu, size, "\r4. \wOptions Menu^n");
	add(g_main_menu, size, "\r5. \wCommands Menu^n^n");
	add(g_main_menu, size, "%s6. %sNoclip: %s^n");
	add(g_main_menu, size, "%s7. %sGodmode: %s^n^n");
	add(g_main_menu, size, "\r0. \wClose");
	g_keys_main_menu =		B1 | B2 | B3 | B4 | B5 | B6 | B7 | B0;
	
	size = charsmax(g_block_menu);
	add(g_block_menu, size, "\r[%s] \yBlock Menu^n^n\wLoaded Blocks\d: \y%i^n^n");
	add(g_block_menu, size, "\r1. \wBlock Type: \y[%s]^n");
	add(g_block_menu, size, "\r2. \wBlock Size: \y[%s]^n^n");
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
	add(g_move_menu, size, "\r1. \wGrid Size: \y[%.1f]^n^n");
	add(g_move_menu, size, "\r2. \wZ\y+^n");
	add(g_move_menu, size, "\r3. \wZ\r-^n");
	add(g_move_menu, size, "\r4. \wX\y+^n");
	add(g_move_menu, size, "\r5. \wX\r-^n");
	add(g_move_menu, size, "\r6. \wY\y+^n");
	add(g_move_menu, size, "\r7. \wY\r-^n^n^n");
	add(g_move_menu, size, "\r0. \wBack");
	g_keys_move_menu =		B1 | B2 | B3 | B4 | B5 | B6 | B7 | B0;
	
	size = charsmax(g_teleport_menu);
	add(g_teleport_menu, size, "\r[%s] \yTeleport Menu^n^n\wLoaded Teleports\d: \y%i^n^n");
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
	add(g_options_menu, size, "%s1. %sSnapping: [%s]^n");
	add(g_options_menu, size, "%s2. %sSnapping Gap: \y[%.1f]^n^n");
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
	
	iDeagle[ id ] = iAwp[ id ] = iShotgun[ id ] = iHe[ id ] = iFlash[ id ] = iFrost[ id ] = iXP[ id ] = iPoint[ id ] = iNades[ id ] = iPistols[ id ] = iRifles[ id ] = iScout[ id ] = iFamas[ id ] = false;
	
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
			static block_type, property[ 5 ], iCreator[ 33 ], message[ 512 ], len;
			block_type = entity_get_int(ent, EV_INT_body);
			pev( ent, pev_targetname, iCreator, charsmax( iCreator ) );

			len = format(message, charsmax(message), "Block Type: %s^nCreated by: %s", g_block_names[block_type], iCreator );

			if( get_user_flags( id ) & ADMIN_KICK )
			{
				if ( g_property1_name[block_type][0] )
				{
					GetProperty(ent, 1, property);
					
					if( ( block_type == BUNNYHOP || block_type == NO_SLOW_DOWN_BUNNYHOP ) && property[0] == '1' )
					{
						len += format(message[len], charsmax(message) - len, "^n%s", g_property1_name[block_type]);
					}
					else if ( block_type == SLAP )
					{
						len += format(message[len], charsmax(message) - len, "^n%s: %s", g_property1_name[block_type], property[0] == '3' ? "High" : property[0] == '2' ? "Medium" : "Low");
					}
					else if ( block_type != BUNNYHOP && block_type != NO_SLOW_DOWN_BUNNYHOP )
					{
						len += format(message[len], charsmax(message) - len, "^n%s: %s", g_property1_name[block_type], property);
					}
					else if ( block_type == TELEPORT || block_type == DESTINATION ) 
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
			}
			
			set_hudmessage( r, g, b, x, y, effects, 0.0, 1.0, 0.2, 0.2, channel );
			show_hudmessage(id, message);
		}
		else if ( IsLight(ent) )
		{
			static property1[5], property2[5], property3[5], property4[5];
			
			GetProperty(ent, 1, property1);
			GetProperty(ent, 2, property2);
			GetProperty(ent, 3, property3);
			GetProperty(ent, 4, property4);
			
			set_hudmessage( r, g, b, x, y, effects, 0.0, 1.0, 0.2, 0.2, channel );
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
	
	new UserName[ 33 ];
	get_user_name( id, UserName, charsmax( UserName ) );
	
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
				death[ id ] = 0;
				ActionDeath( id, UserName );
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
			case DEAGLE:				ActionDeagle( id, ent, UserName );
			case AWP:				ActionAwp( id, ent, UserName );
			case SHOTGUN:				ActionShotgun( id, ent, UserName );
			case HE:				ActionHE( id, UserName );
			case FLASH:				ActionFlash( id, UserName );
			case FROST:				ActionFrost( id, UserName );
			case XP:				ActionXP( id, ent );
			case POINT:				ActionPoint( id, ent );
			case NADES:				ActionNades( id );
			case PISTOLS:				ActionPistols( id );
			case RIFLES:				ActionRifles( id );
			case SCOUT:				ActionScout( id, ent, UserName );
			case FAMAS:				ActionFamas( id, ent, UserName );
			case BOUNCE_DEATH:
			{
				death[ id ]++;
				ActionDeath( id, UserName );
			}
			case MAGIC_CARPET:			ActionMagicCarpet( id, ent );
			case TELEPORT:				ActionTeleportBlock( id, ent );
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
		
		set_hudmessage( r, g, b, x, y, effects, 0.0, 0.01, 0.01, 0.01, channel );
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

ActionDeagle( id, ent, const UserName[ ] )
{
	if( is_user_alive( id ) )
	{
		if( iDeagle[ id ] )
		{
			set_hudmessage( r, g, b, x, y, effects, 0.0, 0.3, 0.1, 0.1, channel );
			show_hudmessage(id, "Deagle Next Use : Next Spawn");
		}
		else
		{
			if( cs_get_user_team( id ) == CS_TEAM_CT )
			{
				set_hudmessage( r, g, b, x, y, effects, 0.0, 0.3, 0.1, 0.1, channel );
				show_hudmessage(id, "This block is only for Terrorists!");
			}
			else if( cs_get_user_team( id ) == CS_TEAM_T )
			{
				if( !user_has_weapon( id, CSW_DEAGLE ) )
				{
					static property[ 5 ];
					GetProperty( ent, 1, property );
					
					give_item( id, "weapon_deagle" );
					cs_set_weapon_ammo( find_ent_by_owner( 1, "weapon_deagle", id ), str_to_num( property ) );
					
					iDeagle[ id ] = true;
					client_cmd( id, "spk BetterPlay/lightningbolt.wav");
	
					BlindPlayer( id, 1.0, 1.0, random( 255 ), random( 255 ), random( 255 ), 130 );
					BCM_Print( 0, "^1Beware!^3 %s^1 has a^4 Deagle^1 with^3 %d^4 bullet%s.", UserName, str_to_num( property ), str_to_num( property ) == 1 ? "" : "s" );
				}
			}
		}
	}
}

ActionAwp( id, ent, const UserName[ ] )
{
	if( is_user_alive( id ) )
	{
		if( iAwp[ id ] )
		{
			set_hudmessage( r, g, b, x, y, effects, 0.0, 0.3, 0.1, 0.1, channel );
			show_hudmessage(id, "AWP Next Use : Next Spawn");
		}
		else
		{
			if( cs_get_user_team( id ) == CS_TEAM_CT )
			{
				set_hudmessage( r, g, b, x, y, effects, 0.0, 0.3, 0.1, 0.1, channel );
				show_hudmessage(id, "This block is only for Terrorists!");
			}
			else if( cs_get_user_team( id ) == CS_TEAM_T )
			{
				if( !user_has_weapon( id, CSW_AWP ) )
				{
					static property[ 5 ];
					GetProperty( ent, 1, property );
					
					give_item( id, "weapon_awp" );
					cs_set_weapon_ammo( find_ent_by_owner( 1, "weapon_awp", id ), str_to_num( property ) );
					
					iAwp[ id ] = true;
					client_cmd( id, "spk BetterPlay/lightningbolt.wav");
					
					BlindPlayer( id, 1.0, 1.0, random( 255 ), random( 255 ), random( 255 ), 130 );
					BCM_Print( 0, "^1Beware!^3 %s^1 has a^4 Awp^1 with^3 %d^4 bullet%s.", UserName, str_to_num( property ), str_to_num( property ) == 1 ? "" : "s" );
				}
			}
		}
	}
}

ActionShotgun( id, ent, const UserName[ ] )
{
	if( is_user_alive( id ) )
	{
		if( iShotgun[ id ] )
		{
			set_hudmessage( r, g, b, x, y, effects, 0.0, 0.3, 0.1, 0.1, channel );
			show_hudmessage(id, "Shotgun Next Use : Next Spawn");
		}
		else
		{
			if( cs_get_user_team( id ) == CS_TEAM_CT )
			{
				set_hudmessage( r, g, b, x, y, effects, 0.0, 0.3, 0.1, 0.1, channel );
				show_hudmessage(id, "This block is only for Terrorists!");
			}
			else if( cs_get_user_team( id ) == CS_TEAM_T )
			{
				if( !user_has_weapon( id, CSW_M3 ) )
				{
					static property[ 5 ];
					GetProperty( ent, 1, property );
					
					give_item( id, "weapon_m3" );
					cs_set_weapon_ammo( find_ent_by_owner( 1, "weapon_m3", id ), str_to_num( property ) );
					
					BlindPlayer( id, 1.0, 1.0, random( 255 ), random( 255 ), random( 255 ), 130 );
					
					iShotgun[ id ] = true;
					BCM_Print( 0, "^1Beware!^3 %s^1 has a^4 Shotgun^1 with^3 %d^4 bullet%s.", UserName, str_to_num( property ), str_to_num( property ) == 1 ? "" : "s" );
				}
			}
		}
	}
}

ActionHE( id, const UserName[ ] )
{
	if( is_user_alive( id ) )
	{
		if( iHe[ id ] )
		{
			set_hudmessage( r, g, b, x, y, effects, 0.0, 0.3, 0.1, 0.1, channel );
			show_hudmessage(id, "HE Grenade Next Use : Next Spawn");
		}
		else
		{
			if( cs_get_user_team( id ) == CS_TEAM_CT )
			{
				set_hudmessage( r, g, b, x, y, effects, 0.0, 0.3, 0.1, 0.1, channel );
				show_hudmessage(id, "This block is only for Terrorists!");
			}
			else if( cs_get_user_team( id ) == CS_TEAM_T )
			{
				if( !user_has_weapon( id, CSW_HEGRENADE ) )
				{
					give_item( id, "weapon_hegrenade" );
					iHe[ id ] = true;

					BlindPlayer( id, 1.0, 1.0, random( 255 ), random( 255 ), random( 255 ), 130 );
					
					BCM_Print( 0, "%s^1 has picked up a^4 HE Grenade!", UserName );
				}
			}
		}
	}
}

ActionFlash( id, const UserName[ ] )
{
	if( is_user_alive( id ) )
	{
		if( iFlash[ id ] )
		{
			set_hudmessage( r, g, b, x, y, effects, 0.0, 0.3, 0.1, 0.1, channel );
			show_hudmessage(id, "Flashbang Next Use : Next Spawn");
		}
		else
		{
			if( cs_get_user_team( id ) == CS_TEAM_CT )
			{
				set_hudmessage( r, g, b, x, y, effects, 0.0, 0.3, 0.1, 0.1, channel );
				show_hudmessage(id, "This block is only for Terrorists!");
			}
			else if( cs_get_user_team( id ) == CS_TEAM_T )
			{
				if( cs_get_user_bpammo( id, CSW_FLASHBANG ) < 2 )
				{
					give_item( id, "weapon_flashbang" );
					iFlash[ id ] = true;
					
					BlindPlayer( id, 1.0, 1.0, random( 255 ), random( 255 ), random( 255 ), 130 );					
					BCM_Print( 0, "%s^1 has picked up a^4 Flashbang!", UserName );
				}
			}
		}
	}
}

ActionFrost( id, const UserName[ ] )
{
	if( is_user_alive( id ) )
	{
		if( iFrost[ id ] )
		{
			set_hudmessage( r, g, b, x, y, effects, 0.0, 0.3, 0.1, 0.1, channel );
			show_hudmessage(id, "Frostnade Next Use : Next Spawn");
		}
		else
		{
			if( cs_get_user_team( id ) == CS_TEAM_CT )
			{
				set_hudmessage( r, g, b, x, y, effects, 0.0, 0.3, 0.1, 0.1, channel );
				show_hudmessage(id, "This block is only for Terrorists!");
			}
			else if( cs_get_user_team( id ) == CS_TEAM_T )
			{
				if( !user_has_weapon( id, CSW_SMOKEGRENADE ) )
				{
					give_item( id, "weapon_smokegrenade" );
					iFrost[ id ] = true;

					BlindPlayer( id, 1.0, 1.0, random( 255 ), random( 255 ), random( 255 ), 130 );
					BCM_Print( 0, "%s^1 has picked up a^4 Frostnade!", UserName );
				}
			}
		}
	}
}

ActionXP( id, ent )
{
	if( is_user_alive( id ) )
	{
		if( iXP[ id ] )
		{
			set_hudmessage( r, g, b, x, y, effects, 0.0, 0.3, 0.1, 0.1, channel );
			show_hudmessage(id, "XP Next Use : Next Spawn");
		}
		else
		{
			if( cs_get_user_team( id ) == CS_TEAM_CT )
			{
				set_hudmessage( r, g, b, x, y, effects, 0.0, 0.3, 0.1, 0.1, channel );
				show_hudmessage(id, "This block is only for Terrorists!");
			}
			else if( cs_get_user_team( id ) == CS_TEAM_T )
			{
				static property[ 5 ];
				GetProperty( ent, 1, property );
				
				hnsxp_set_user_xp( id, hnsxp_get_user_xp( id ) + str_to_num( property ) );
				iXP[ id ] = true;
				
				BlindPlayer( id, 1.0, 1.0, random( 255 ), random( 255 ), random( 255 ), 130 );	
				
				client_cmd( id, "spk %s", g_sound_xp );				

				BCM_Print( id, "^1You^3 just picked^4 up^1 %i^3 XP^4!", str_to_num( property ) );
			}
		}
	}
}

ActionPoint( id, ent )
{
	if( is_user_alive( id ) )
	{
		if( iPoint[ id ] )
		{
			set_hudmessage( r, g, b, x, y, effects, 0.0, 0.3, 0.1, 0.1, channel );
			show_hudmessage(id, "Point Next Use : Next Spawn");
		}
		else
		{
			if( cs_get_user_team( id ) == CS_TEAM_CT )
			{
				set_hudmessage( r, g, b, x, y, effects, 0.0, 0.3, 0.1, 0.1, channel );
				show_hudmessage(id, "This block is only for Terrorists!");
			}
			else if( cs_get_user_team( id ) == CS_TEAM_T )
			{
				static property[ 5 ];
				GetProperty( ent, 1, property );
				
				hnsshop_set_user_points( id, hnsshop_get_user_points( id ) + str_to_num( property ) );
				iPoint[ id ] = true;
				
				BlindPlayer( id, 1.0, 1.0, random( 255 ), random( 255 ), random( 255 ), 130 );
				
				client_cmd( id, "spk %s", g_sound_bmpoint );		
	
				BCM_Print( id, "^1You^3 just picked^4 up^1 %i^3 Point%s^4!", str_to_num( property ), str_to_num( property ) == 1 ? "" : "s" );
			}
		}
	}
}

ActionNades( id )
{
	if( is_user_alive( id ) )
	{
		if( iNades[ id ] )
		{
			set_hudmessage( r, g, b, x, y, effects, 0.0, 0.3, 0.1, 0.1, channel );
			show_hudmessage(id, "Nades Block Next Use : Next Spawn");
			return PLUGIN_HANDLED;
		}
		else
		{
			if( cs_get_user_team( id ) == CS_TEAM_CT )
			{
				set_hudmessage( r, g, b, x, y, effects, 0.0, 0.3, 0.1, 0.1, channel );
				show_hudmessage(id, "This block is only for Terrorists!");
				return PLUGIN_HANDLED;
			}
			else if( cs_get_user_team( id ) == CS_TEAM_T )
			{
				NadesMenu( id );
				iNades[ id ] = true;
			}
		}
	}
	
	return PLUGIN_HANDLED;
}

public NadesMenu( id )
{
	static iMenu[ 500 ], iLen;
	iLen = 0;
	
	iLen += formatex( iMenu[ iLen ], charsmax( iMenu ) - iLen, "\d[\y%s \rv\y%s\d]^n^n\wSelect \da \ynade^n^n", PLUGIN_NAME, PLUGIN_VERSION );

	if( user_has_weapon( id, CSW_HEGRENADE ) )
	{
		iLen += formatex( iMenu[ iLen ], charsmax( iMenu ) - iLen, "\r1. \dHE Grenade^n" ); 
	}
	else
	{
		iLen += formatex( iMenu[ iLen ], charsmax( iMenu ) - iLen, "\r1. \wHE \yGrenade^n" );
	}
	
	if( cs_get_user_bpammo( id, CSW_FLASHBANG ) >= 2 )
	{
		iLen += formatex( iMenu[ iLen ], charsmax( iMenu ) - iLen, "\r2. \dFlashbang^n" ); 
	}
	else
	{
		iLen += formatex( iMenu[ iLen ], charsmax( iMenu ) - iLen, "\r2. \wFlash\ybang^n" );
	}
	
	if( user_has_weapon( id, CSW_SMOKEGRENADE ) )
	{
		iLen += formatex( iMenu[ iLen ], charsmax( iMenu ) - iLen, "\r3. \dFrost Nade^n^n" ); 
	}
	else
	{
		iLen += formatex( iMenu[ iLen ], charsmax( iMenu ) - iLen, "\r3. \wFrost \yNade^n^n" );
	}

	show_menu( id, g_keys_nades, iMenu, -1, "NadesMenu" );
}

public NadesMenuHandler( id, key )
{
	if( !is_user_alive( id ) ) return PLUGIN_HANDLED;
	
	switch( key )
	{
		case 0:
		{
			if( user_has_weapon( id, CSW_HEGRENADE ) )
			{
				BCM_Print( id, "^1Used your^3 HE Grenade^1 before you take^4 another one^1." );
				NadesMenu( id );
				client_cmd( id, "spk buttons/button10.wav" );
				return PLUGIN_HANDLED;
			}
			
			give_item( id, "weapon_hegrenade" );			
			BlindPlayer( id, 1.0, 1.0, random( 255 ), random( 255 ), random( 255 ), 150 );
		}
		case 1:
		{
			if( cs_get_user_bpammo( id, CSW_FLASHBANG ) >= 2 )
			{
				BCM_Print( id, "^1Used your^3 Flashbang^1 before you take^4 another one^1." );
				NadesMenu( id );
				client_cmd( id, "spk buttons/button10.wav" );
				return PLUGIN_HANDLED;
			}
			
			give_item( id, "weapon_flashbang" );		
			BlindPlayer( id, 1.0, 1.0, random( 255 ), random( 255 ), random( 255 ), 150 );
		}
		case 2:
		{
			if( user_has_weapon( id, CSW_SMOKEGRENADE ) )
			{
				BCM_Print( id, "^1Used your^3 Frost Nade^1 before you take^4 another one^1." );
				NadesMenu( id );
				client_cmd( id, "spk buttons/button10.wav" );
				return PLUGIN_HANDLED;
			}
			
			give_item( id, "weapon_smokegrenade" );
			BlindPlayer( id, 1.0, 1.0, random( 255 ), random( 255 ), random( 255 ), 150 );
		}
	}
	
	return PLUGIN_HANDLED;
}

ActionPistols( id )
{
	if( is_user_alive( id ) )
	{
		if( iPistols[ id ] )
		{
			set_hudmessage( r, g, b, x, y, effects, 0.0, 0.3, 0.1, 0.1, channel );
			show_hudmessage(id, "Pistols Block Next Use : Next Spawn");
			return PLUGIN_HANDLED;
		}
		else
		{
			if( cs_get_user_team( id ) == CS_TEAM_CT )
			{
				set_hudmessage( r, g, b, x, y, effects, 0.0, 0.3, 0.1, 0.1, channel );
				show_hudmessage(id, "This block is only for Terrorists!");
				return PLUGIN_HANDLED;
			}
			else if( cs_get_user_team( id ) == CS_TEAM_T )
			{
				PistolsMenu( id );
				iPistols[ id ] = true;
			}
		}
	}
	
	return PLUGIN_HANDLED;
}

public PistolsMenu( id )
{
	static iMenu[ 500 ], iLen;
	iLen = 0;
	
	iLen += formatex( iMenu[ iLen ], charsmax( iMenu ) - iLen, "\d[\y%s \rv\y%s\d]^n^n\wSelect \da \ypistol^n^n", PLUGIN_NAME, PLUGIN_VERSION );

	iLen += formatex( iMenu[ iLen ], charsmax( iMenu ) - iLen, "\r1. \wGlock \d- \r2 \ybullets^n" ); 
	iLen += formatex( iMenu[ iLen ], charsmax( iMenu ) - iLen, "\r2. \wUsp \d- \r1 \ybullet^n" ); 
	iLen += formatex( iMenu[ iLen ], charsmax( iMenu ) - iLen, "\r3. \wFiveseven \d- \r1 \ybullet^n^n" ); 

	show_menu( id, g_keys_pistols, iMenu, -1, "PistolsMenu" );
}

public PistolsMenuHandler( id, key )
{
	if( !is_user_alive( id ) ) return PLUGIN_HANDLED;
	
	switch( key )
	{
		case 0:
		{
			give_item( id, "weapon_glock18" );
			cs_set_weapon_ammo( find_ent_by_owner( 1, "weapon_glock18", id ), 2 );	
			
			BlindPlayer( id, 1.0, 1.0, random( 255 ), random( 255 ), random( 255 ), 150 );
		}
		case 1:
		{
			give_item( id, "weapon_usp" );
			cs_set_weapon_ammo( find_ent_by_owner( 1, "weapon_usp", id ), 1 );	
			
			BlindPlayer( id, 1.0, 1.0, random( 255 ), random( 255 ), random( 255 ), 150 );
		}
		case 2:
		{
			give_item( id, "weapon_fiveseven" );
			cs_set_weapon_ammo( find_ent_by_owner( 1, "weapon_fiveseven", id ), 1 );	
			
			BlindPlayer( id, 1.0, 1.0, random( 255 ), random( 255 ), random( 255 ), 150 );
		}
	}
	
	return PLUGIN_HANDLED;
}

ActionRifles( id )
{
	if( is_user_alive( id ) )
	{
		if( iRifles[ id ] )
		{
			set_hudmessage( r, g, b, x, y, effects, 0.0, 0.3, 0.1, 0.1, channel );
			show_hudmessage(id, "Rifles Block Next Use : Next Spawn");
			return PLUGIN_HANDLED;
		}
		else
		{
			if( cs_get_user_team( id ) == CS_TEAM_CT )
			{
				set_hudmessage( r, g, b, x, y, effects, 0.0, 0.3, 0.1, 0.1, channel );
				show_hudmessage(id, "This block is only for Terrorists!");
				return PLUGIN_HANDLED;
			}
			else if( cs_get_user_team( id ) == CS_TEAM_T )
			{
				RiflesMenu( id );
				iRifles[ id ] = true;
			}
		}
	}
	
	return PLUGIN_HANDLED;
}

public RiflesMenu( id )
{
	static iMenu[ 500 ], iLen;
	iLen = 0;
	
	iLen += formatex( iMenu[ iLen ], charsmax( iMenu ) - iLen, "\d[\y%s \rv\y%s\d]^n^n\wSelect \da \yrifle^n^n", PLUGIN_NAME, PLUGIN_VERSION );

	iLen += formatex( iMenu[ iLen ], charsmax( iMenu ) - iLen, "\r1. \wAK-47 \d- \r1 \ybullet^n" ); 
	iLen += formatex( iMenu[ iLen ], charsmax( iMenu ) - iLen, "\r2. \wM4A1 \d- \r1 \ybullet^n^n" ); 

	show_menu( id, g_keys_rifles, iMenu, -1, "RiflesMenu" );
}

public RiflesMenuHandler( id, key )
{
	if( !is_user_alive( id ) ) return PLUGIN_HANDLED;
	
	switch( key )
	{
		case 0:
		{
			give_item( id, "weapon_ak47" );
			cs_set_weapon_ammo( find_ent_by_owner( 1, "weapon_ak47", id ), 1 );	
			
			BlindPlayer( id, 1.0, 1.0, random( 255 ), random( 255 ), random( 255 ), 150 );
		}
		case 1:
		{
			give_item( id, "weapon_m4a1" );
			cs_set_weapon_ammo( find_ent_by_owner( 1, "weapon_m4a1", id ), 1 );	
			
			BlindPlayer( id, 1.0, 1.0, random( 255 ), random( 255 ), random( 255 ), 150 );
		}
	}
	
	return PLUGIN_HANDLED;
}

ActionScout( id, ent, const UserName[ ] )
{
	if( is_user_alive( id ) )
	{
		if( iScout[ id ] )
		{
			set_hudmessage( r, g, b, x, y, effects, 0.0, 0.3, 0.1, 0.1, channel );
			show_hudmessage(id, "Scout Next Use : Next Spawn");
		}
		else
		{
			if( cs_get_user_team( id ) == CS_TEAM_CT )
			{
				set_hudmessage( r, g, b, x, y, effects, 0.0, 0.3, 0.1, 0.1, channel );
				show_hudmessage(id, "This block is only for Terrorists!");
			}
			else if( cs_get_user_team( id ) == CS_TEAM_T )
			{
				if( !user_has_weapon( id, CSW_SCOUT ) )
				{
					static property[ 5 ];
					GetProperty( ent, 1, property );
					
					give_item( id, "weapon_scout" );
					cs_set_weapon_ammo( find_ent_by_owner( 1, "weapon_scout", id ), str_to_num( property ) );
					
					BlindPlayer( id, 1.0, 1.0, random( 255 ), random( 255 ), random( 255 ), 130 );
			
					iScout[ id ] = true;
					BCM_Print( 0, "^1Beware!^3 %s^1 has a^4 Scout^1 with^3 %d^4 bullet%s.", UserName, str_to_num( property ), str_to_num( property ) == 1 ? "" : "s" );
				}
			}
		}
	}
}

ActionFamas( id, ent, const UserName[ ] )
{
	if( is_user_alive( id ) )
	{
		if( iFamas[ id ] )
		{
			set_hudmessage( r, g, b, x, y, effects, 0.0, 0.3, 0.1, 0.1, channel );
			show_hudmessage(id, "Famas Next Use : Next Spawn");
		}
		else
		{
			if( cs_get_user_team( id ) == CS_TEAM_CT )
			{
				set_hudmessage( r, g, b, x, y, effects, 0.0, 0.3, 0.1, 0.1, channel );
				show_hudmessage(id, "This block is only for Terrorists!");
			}
			else if( cs_get_user_team( id ) == CS_TEAM_T )
			{
				if( !user_has_weapon( id, CSW_FAMAS ) )
				{
					static property[ 5 ];
					GetProperty( ent, 1, property );
					
					give_item( id, "weapon_famas" );
					cs_set_weapon_ammo( find_ent_by_owner( 1, "weapon_famas", id ), str_to_num( property ) );
					
					BlindPlayer( id, 1.0, 1.0, random( 255 ), random( 255 ), random( 255 ), 130 );
					
					iFamas[ id ] = true;
					BCM_Print( 0, "^1Beware!^3 %s^1 has a^4 Famas^1 with^3 %d^4 bullet%s.", UserName, str_to_num( property ), str_to_num( property ) == 1 ? "" : "s" );
				}
			}
		}
	}
}

public TaskBounceDeath( ent )
{
	if( IsBlock( ent ) )
	{
		new block_type = entity_get_int( ent, EV_INT_body );
		if( pev_valid( ent ) && block_type == BOUNCE_DEATH )
		{
			static property[ 5 ];
			GetProperty( ent, 1, property );
			
			if( pev( ent, pev_flags ) & FL_ONGROUND )
			{
				new Float:velocity[ 3 ];
				velocity[ 2 ] = str_to_float( property );
				
				set_pev( ent, pev_velocity, velocity );
			}
			set_task( 0.1, "TaskBounceDeath", ent );
		}
	}
}

ActionMagicCarpet( id, ent )
{
	static property[ 5 ];
	GetProperty( ent, 2, property );
	
	new Float:iVelocity[ 3 ];
	pev( id, pev_velocity, iVelocity );
	
	iVelocity[ 2 ] = 0.0;
	
	set_pev( ent, pev_velocity, iVelocity );
	entity_set_int( ent, EV_INT_movetype, MOVETYPE_FLY );
	
	if( !task_exists( TASK_MOVEBACK + ent ) ) set_task( str_to_float( property), "TaskMoveBack", TASK_MOVEBACK + ent );
}

public TaskMoveBack( ent )
{
	ent -= TASK_MOVEBACK;
	
	if( !is_valid_ent( ent ) || entity_get_int( ent, EV_INT_iuser2 ) ) return PLUGIN_HANDLED;
	
	new Float:iOrigin[ 3 ];
	pev( ent, pev_v_angle, iOrigin );
	
	set_pev( ent, pev_velocity, Float:{ 0.0, 0.0, 0.0} );
	engfunc( EngFunc_SetOrigin, ent, iOrigin );
	
	return PLUGIN_HANDLED;
}

ActionTeleportBlock(id, iEntity)
{	
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
	}
	while ( player );
	
	entity_set_vector(id, EV_VEC_origin, tele_origin);

	client_cmd( id, "spk BetterPlay/bp_teleport.wav" );
	
	return PLUGIN_HANDLED;
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
	
	new iXPHealth = hnsxp_get_user_health( id );
	new hp = iXPHealth == 0 ? 100 : iXPHealth + 100;
	new health = get_user_health( id );
	
	if( health >= hp ) return PLUGIN_HANDLED;

	static property[5];
	
	GetProperty(ent, 1, property);
	health += str_to_num(property);

	set_user_health( id, min( hp, health ) );
	
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

ActionDeath( id, const UserName[ ] )
{
	if( !get_user_godmode( id ) )
	{
		fakedamage( id, "The Block of Death", 10000.0, DMG_GENERIC );
		BCM_Print( 0, "%s^1 has died on^4 %s", UserName, iDeathBlockType[ death[id] ] );
		
		BlindPlayer( id, 1.0, 1.0, 255, 0, 0, 150 );
		death[ id ] = 0;
	}
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
			set_hudmessage( r, g, b, x, y, effects, 0.0, 0.1, 0.1, 0.1, channel );
			show_hudmessage(id, "Invincibility^nNext Use %.1f", g_invincibility_next_use[id] - gametime);
		}
		
		return PLUGIN_HANDLED;
	}
	
	static property[5];
	
	entity_set_float(id, EV_FL_takedamage, DAMAGE_NO);
	BlindPlayer( id, 1.0, 1.0, random( 255 ), random( 255 ), random( 255 ), 150 );
	
	if ( gametime >= g_stealth_time_out[id] )
	{
		set_user_rendering(id, kRenderFxGlowShell, 255, 255, 255, kRenderNormal, 16);
	}
	
	client_cmd( id, "spk %s", g_sound_invincibility );
	
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
			set_hudmessage( r, g, b, x, y, effects, 0.0, 0.1, 0.1, 0.1, channel );
			show_hudmessage(id, "Stealth^nNext Use %.1f", g_stealth_next_use[id] - gametime);
		}
		
		return PLUGIN_HANDLED;
	}
	
	static property[5];
	player_has_a_stealth[ id ]++;

	BlindPlayer( id, 1.0, 1.0, random( 255 ), random( 255 ), random( 255 ), 150 );		
	client_cmd( id, "spk %s", g_sound_stealth );
	
	g_block_status[id] = true;
	
	static Float:time_out;
	GetProperty(ent, 1, property);
	time_out = str_to_float(property);
	set_task(time_out, "TaskRemoveStealth", TASK_STEALTH + id, g_blank, 0, g_a, 1);
	
	g_stealth_duration[ id ] = str_to_num( property );
	if( callfunc_begin( "RemoveXPInvisibility", "hns_xp_nosteam.amxx" ) == 1 )
	{
		callfunc_push_int( id );
		callfunc_end( );
	}
	
	set_user_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderTransColor, 0);

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
			set_hudmessage( r, g, b, x, y, effects, 0.0, 0.1, 0.1, 0.1, channel );
			show_hudmessage(id, "Boots Of Speed^nNext Use %.1f", g_boots_of_speed_next_use[id] - gametime);
		}
		
		return PLUGIN_HANDLED;
	}
	
	static property[5];
	
	GetProperty(ent, 3, property);
	entity_set_float(id, EV_FL_maxspeed, str_to_float(property));
	
	BlindPlayer( id, 1.0, 1.0, random( 255 ), random( 255 ), random( 255 ), 150 );
	g_boots_of_speed[id] = ent;
	
	client_cmd( id, "spk %s", g_sound_boots_of_speed );
	
	static Float:time_out;
	GetProperty(ent, 1, property);
	time_out = str_to_float(property);
	set_task(time_out, "TaskRemoveBootsOfSpeed", TASK_BOOTSOFSPEED + id, g_blank, 0, g_a, 1);
	
	GetProperty(ent, 2, property);
	
	g_boots_of_speed_time_out[id] = gametime + time_out;
	g_boots_of_speed_next_use[id] = gametime + time_out + str_to_float(property);
	
	return PLUGIN_HANDLED;
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
		
		//user_kill(player, 1);
	}
	while ( player );
	
	entity_set_vector(id, EV_VEC_origin, tele_origin);
	
	static Float:velocity[3];
	entity_get_vector(id, EV_VEC_velocity, velocity);
	velocity[2] = floatabs(velocity[2]);
	entity_set_vector(id, EV_VEC_velocity, velocity);
	
	client_cmd( id, "spk BetterPlay/bp_teleport.wav" );
	
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
		
		player_has_a_stealth[ id ] = 0;
		g_stealth_duration[ id ] = 0;
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
				CopyBlock( id, block );
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

public task_task( ) { for( new i = 1; i <= 32; i++ ) { if( is_user_connected( i ) ) { BCM_Print( i, "This server using^4 %s^3 v^4%s^3 by^4 %s", PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR ); } } }

public CmdMainMenu(id)
{
	if( !g_admin[ id ] && !g_gived_access[ id ] ) BCM_Print( id, "^1You have not^4 access^1 to that^3 command^4!" );
	else ShowMainMenu( id );
	
	return PLUGIN_HANDLED;
}

ShowMainMenu(id)
{
	new menu[256], col1[3], col2[3];
	
	col1 = g_admin[id] || g_gived_access[id] ? "\r" : "\d";
	col2 = g_admin[id] || g_gived_access[id] ? "\w" : "\d";
	
	format(menu, charsmax(menu),\
		g_main_menu,\
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
	
	new iCount = 0;
	new ent = -1;
	
	while( ( ent = find_ent_by_class( ent, g_block_classname ) ) ) iCount++;

	col1 = g_admin[id] || g_gived_access[id] ? "\r" : "\d";
	col2 = g_admin[id] || g_gived_access[id] ? "\w" : "\d";
	
	switch ( g_selected_block_size[id] )
	{
		case SMALL:	size = "Small";
		case NORMAL:	size = "Normal";
		case LARGE:	size = "Large";
		case POLE:	size = "Pole";
	}
	
	format(menu, charsmax(menu),\
		g_block_menu,\
		PLUGIN_PREFIX,\
		iCount,\
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
	
	format(title, charsmax(title), "\r[BM] \yBlock Selection %d^n^n", g_block_selection_page[id]);
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
	
	format(title, charsmax(title), "\r[BM] \ySet Properties^n^n" );
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
	
	new iCount = 0;
	new ent = -1;
	
	while( ( ent = find_ent_by_class( ent, g_destination_classname ) ) ) iCount++;
	
	col1 = g_admin[id] || g_gived_access[id] ? "\r" : "\d";
	col2 = g_admin[id] || g_gived_access[id] ? "\w" : "\d";
	
	format(menu, charsmax(menu),\
		g_teleport_menu,\
		PLUGIN_PREFIX,\
		iCount,\
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
	
	if( entity_get_int( ent, EV_INT_body ) == MAGIC_CARPET ) set_pev( ent, pev_v_angle, move_to );
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
	
	static iCreator[ 33 ];
	get_user_name( id, iCreator, charsmax( iCreator ) );

	CreateBlock(id, block_type, float_origin, Z, g_selected_block_size[id], g_property1_default_value[block_type], g_property2_default_value[block_type], g_property3_default_value[block_type], g_property4_default_value[block_type], iCreator );
	
	return PLUGIN_HANDLED;
}

CreateBlock(const id, const block_type, Float:origin[3], const axis, const size, const property1[], const property2[], const property3[], const property4[], iCreator[ ] = "Unknow" )
{
	new ent = create_entity("info_target");
	if ( !is_valid_ent(ent) ) return 0;
	
	entity_set_string(ent, EV_SZ_classname, g_block_classname);
	entity_set_int(ent, EV_INT_solid, SOLID_BBOX);
	entity_set_int(ent, EV_INT_movetype, MOVETYPE_NONE);
	
	switch( block_type )
	{
		case BOUNCE_DEATH:
		{
			set_pev( ent, pev_movetype, MOVETYPE_TOSS );
			set_task( 0.1, "TaskBounceDeath", ent );
		}
		case MAGIC_CARPET:
		{
			set_pev( ent, pev_v_angle, origin );
		}
		case TELEPORT:
		{
			g_teleport_block_start[ id ] = ent;
			
			if( id != 0 ) { CreateBlockAiming( id, DESTINATION ); }
			
			entity_get_int( ent, EV_INT_iuser4 );
			entity_set_int( ent, EV_INT_movetype, MOVETYPE_NONE );
		}
		case DESTINATION:
		{
			entity_set_int( ent, EV_INT_iuser4, g_teleport_block_start[ id ] );
			entity_set_int( g_teleport_block_start[ id ], EV_INT_iuser4, ent );
			entity_set_int( ent, EV_INT_movetype, MOVETYPE_NONE);		
			
			g_teleport_block_start[id] = 0;
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
			size_min[0] = -4.0;
			size_min[1] = -32.0;
			size_min[2] = -32.0;
			
			size_max[0] = 4.0;
			size_max[1] = 32.0;
			size_max[2] = 32.0;
			
			if(size == POLE)
			{
				size_min[0] = -32.0;
				size_min[1] = -4.0;
				size_min[2] = -4.0;
			
				size_max[0] = 32.0;
				size_max[1] = 4.0;
				size_max[2] = 4.0;
			}
				
			
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
			
			if(size == POLE)
			{
				size_min[0] = -4.0;
				size_min[1] = -32.0;
				size_min[2] = -4.0;
			
				size_max[0] = 4.0;
				size_max[1] = 32.0;
				size_max[2] = 4.0;
			}
			
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
			
			if(size == POLE)
			{
				size_min[0] = -4.0;
				size_min[1] = -4.0;
				size_min[2] = -32.0;
			
				size_max[0] = 4.0;
				size_max[1] = 4.0;
				size_max[2] = 32.0;
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
			SetBlockModelName(block_model, g_block_models[block_type], "Small");
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
		case POLE:
		{
			SetBlockModelName(block_model, g_block_models[block_type], "Pole");
			scale = 1.0;
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
	
	set_pev( ent, pev_targetname, iCreator, 32 );
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
	
	static ent, body, iCreator[ 33 ];
	get_user_aiming(id, ent, body);
	
	get_user_name( id, iCreator, charsmax( iCreator ) );
	replace_all( iCreator, charsmax( iCreator ), " ", "_" );

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
		new_block = ConvertBlock( id, ent, convert_to, false, iCreator );
		if ( IsBlockStuck(new_block) )
		{
			new bool:deleted = DeleteBlock(new_block);
			if ( deleted ) BCM_Print(id, "Block deleted because it was stuck!");
		}
	}
	
	return PLUGIN_HANDLED;
}

ConvertBlock(id, ent, const convert_to, const bool:preserve_size, iCreator[ ] = "Unknow")
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
		else if ( max_size > 32.0 )	size = POLE;
		else				size = SMALL;
		
		return CreateBlock(id, convert_to, origin, axis, size, property1, property2, property3, property4, iCreator);
	}
	else
	{
		return CreateBlock(id, convert_to, origin, axis, g_selected_block_size[id], property1, property2, property3, property4, iCreator);
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
		case SMALL:	g_selected_block_size[id] = NORMAL;
		case NORMAL:	g_selected_block_size[id] = LARGE;
		case LARGE:	g_selected_block_size[id] = POLE;
		case POLE:	g_selected_block_size[id] = SMALL;
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
			case DEAGLE:
			{
				if ( !( 1 <= property_value <= 7 ) )
				{
					BCM_Print(id, "The property has to be between^1 1^3 and^1 7^3!");
					return PLUGIN_HANDLED;
				}
			}
			case AWP:
			{
				if ( !( 1 <= property_value <= 10 ) )
				{
					BCM_Print(id, "The property has to be between^1 1^3 and^1 10^3!");
					return PLUGIN_HANDLED;
				}
			}
			case SHOTGUN:
			{
				if ( !( 1 <= property_value <= 8 ) )
				{
					BCM_Print(id, "The property has to be between^1 1^3 and^1 8^3!");
					return PLUGIN_HANDLED;
				}
			}
			case XP:
			{
				if ( !( 1 <= property_value <= 300 ) )
				{
					BCM_Print(id, "The property has to be between^1 1^3 and^1 300^3!");
					return PLUGIN_HANDLED;
				}
			}
			case POINT:
			{
				if ( !( 1 <= property_value <= 10 ) )
				{
					BCM_Print(id, "The property has to be between^1 1^3 and^1 10^3!");
					return PLUGIN_HANDLED;
				}
			}
			case SCOUT:
			{
				if ( !( 1 <= property_value <= 10 ) )
				{
					BCM_Print(id, "The property has to be between^1 1^3 and^1 10^3!");
					return PLUGIN_HANDLED;
				}
			}
			case FAMAS:
			{
				if ( !( 1 <= property_value <= 30 ) )
				{
					BCM_Print(id, "The property has to be between^1 1^3 and^1 30^3!");
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

CopyBlock(id, ent)
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
	new iCreator[ 33 ];
	
	get_user_name( id, iCreator, charsmax( iCreator ) );
	replace_all( iCreator, charsmax( iCreator ), " ", "_" );
	
	entity_get_vector(ent, EV_VEC_origin, origin);
	entity_get_vector(ent, EV_VEC_angles, angles);
	entity_get_vector(ent, EV_VEC_mins, size_min);
	entity_get_vector(ent, EV_VEC_maxs, size_max);
	
	max_size = size_max[0] + size_max[1] + size_max[2];
	
	if ( max_size > 128.0 )		size = LARGE;
	else if ( max_size > 64.0 )	size = NORMAL;
	else if ( max_size > 32.0 )	size = POLE;
	else				size = SMALL;
	
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
	
	return CreateBlock(0, entity_get_int(ent, EV_INT_body), origin, axis, size, property1, property2, property3, property4, iCreator );
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
	new iCreator[ 33 ];
	
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
		
		pev( ent, pev_targetname, iCreator, charsmax( iCreator ) );
		
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
		else if ( max_size > 32.0 )	size = POLE;
		else				size = SMALL;
		
		formatex(data, charsmax(data), "%c %f %f %f %f %f %f %d %s %s %s %s ^"%s^" ^n",\
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
			iCreator
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
	new iCreator[ 33 ];
	
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
			property4, charsmax(property4),\
			iCreator, charsmax( iCreator )
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
				case 'U': block_type = DEAGLE;
				case 'Y': block_type = AWP;
				case 'Z': block_type = SHOTGUN;			
				case 'X': block_type = HE;
				case 'W': block_type = FLASH;
				case 'V': block_type = FROST;
				case 'a': block_type = XP;
				case 'b': block_type = POINT;
				case 'c': block_type = NADES;
				case 'd': block_type = PISTOLS;
				case 'e': block_type = RIFLES;
				case 'f': block_type = SCOUT;
				case 'g': block_type = FAMAS;
				case 'h': block_type = BOUNCE_DEATH;
				case 'i': block_type = MAGIC_CARPET;
				case 'j': block_type = TELEPORT;
				case 'k': block_type = DESTINATION;
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
				CreateBlock(0, block_type, origin, axis, size, property1, property2, property3, property4, iCreator);
				
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
	
	player_has_a_stealth[ id ] = 0;
	
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

BlindPlayer( index, Float:fDuration, Float:fHoldTime, cRed, cGreen, cBlue, cAlpha )
{
	message_begin( MSG_ONE_UNRELIABLE, get_user_msgid( "ScreenFade" ), { 0, 0, 0 }, index );
	
	write_short( floatround( 4096.0 * fDuration, floatround_round ) );
	write_short( floatround( 4096.0 * fHoldTime, floatround_round ) );
	write_short( 4096 );

	write_byte( cRed );
	write_byte( cGreen );
	write_byte( cBlue );
	write_byte( cAlpha );
	
	message_end( );
}

BCM_Print(id, const message_fmt[], any:...)
{
	static i; i = id ? id : GetPlayer();
	if ( !i ) return;
	
	static message[256], len;
	len = formatex(message, charsmax(message), "^4[%s BM]^3 ", PLUGIN_PREFIX );
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
