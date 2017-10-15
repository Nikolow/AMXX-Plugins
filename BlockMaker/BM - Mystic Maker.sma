#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <engine>
#include <fakemeta>
#include <hamsandwich>
#include <fun>
#include <ColorChat>

#define PLUGIN_NAME				"MysticMaker"
#define PLUGIN_VERSION				"4.5"
#define PLUGIN_AUTHOR				"kyku&Dmk880"
#define PLUGIN_PREFIX				"MysticMaker"
#define write_coord_f(%1) 		engfunc(EngFunc_WriteCoord,%1)

new const g_blank[] =				"";
new const g_a[] =				"a";
new const g_b[] =				"b";

new const g_block_classname[] =			"BM_Block";
new const g_start_classname[] =			"BM_TeleportStart";
new const g_destination_classname[] =		"BM_TeleportDestination";
new const g_light_classname[] =			"BM_Light";
new gMsgScreenFade;

new Float:g_pole_block_size_min_x[3] = {-32.0,-4.0,-4.0};
new Float:g_pole_block_size_max_x[3] = { 32.0, 4.0, 4.0};
new Float:g_pole_block_size_min_z[3] = {-4.0,-4.0,-32.0};
new Float:g_pole_block_size_max_z[3] = { 4.0, 4.0, 32.0};
new Float:g_pole_block_size_min_y[3] = {-4.0,-32.0,-4.0};
new Float:g_pole_block_size_max_y[3] = { 4.0, 32.0, 4.0};

native hnsxp_get_user_xp(client);

native hnsxp_set_user_xp(client, xp);

stock hnsxp_add_user_xp(client, xp)
{
    return hnsxp_set_user_xp(client, hnsxp_get_user_xp(client) + xp);
}

new kurczak[32];
new const g_model_platform[] =			"models/EasyBlock/platforma.mdl";		//New model
new const g_model_bunnyhop[] =			"models/EasyBlock/bunnyhop.mdl";		//New model
new const g_model_damage[] =			"models/EasyBlock/obrazenia.mdl";		//New model
new const g_model_healer[] =			"models/EasyBlock/leczenie.mdl";		//New model
new const g_model_no_fall_damage[] =		"models/EasyBlock/nofall.mdl";		//New model
new const g_model_ice[] =			"models/EasyBlock/lod.mdl";		        //New model
new const g_model_trampoline[] =		"models/EasyBlock/trampolina.mdl";	        //New model
new const g_model_speed_boost[] =		"models/EasyBlock/strzalka.mdl";		//New model
new const g_model_death[] =			"models/EasyBlock/smierc.mdl";		//New model
new const g_model_low_gravity[] =		"models/EasyBlock/platforma.mdl";		//New model
new const g_model_slap[] =			"models/EasyBlock/platforma.mdl";		//New model
new const g_model_honey[] =			"models/EasyBlock/spowolnienie.mdl";		        //New model
new const g_model_ct_barrier[] =		"models/EasyBlock/ct.mdl";		//New model
new const g_model_t_barrier[] =			"models/EasyBlock/tt.mdl";		//New model
new const g_model_glass[] =			"models/EasyBlock/glass.mdl";		//OLDBLOCKMAKER
new const g_model_bhglass[] =			"models/EasyBlock/glass.mdl";		//OLDBLOCKMAKER
new const g_model_no_slow_down_bunnyhop[] =	"models/EasyBlock/bunnyhop.mdl";		//New model
new const g_model_delayed_bunnyhop[] =		"models/EasyBlock/opozniony.mdl";		//New model
new const g_model_invincibility[] =		"models/EasyBlock/niesmiertelnosc.mdl";		//New model
new const g_model_stealth[] =			"models/EasyBlock/niewidzialnosc.mdl";		//New model
new const g_model_boots_of_speed[] =		"models/EasyBlock/buty.mdl";		//New model
new const g_model_awp[] =			"models/EasyBlock/bron.mdl";		//New model
new const g_model_rot[] =			"models/EasyBlock/platforma.mdl";		//New model
new const g_model_he[] =			"models/EasyBlock/platforma.mdl";		//New model
new const g_model_he2[] =			"models/EasyBlock/platforma.mdl";		//New model
new const g_model_smoke[] =			"models/EasyBlock/platforma.mdl";		//New model
new const g_model_kamuflarz[] =			"models/EasyBlock/platforma.mdl";		//New model
new const g_model_muza[] =			"models/EasyBlock/platforma.mdl";		//New model
new const g_model_bhice[] =			"models/EasyBlock/platforma.mdl";		//New model
new const g_model_flash[] =			"models/EasyBlock/platforma.mdl";		//New model
new const g_model_bhflash[] =			"models/EasyBlock/platforma.mdl";		//New model
new const g_model_deathd[] =			"models/EasyBlock/smierc.mdl";		//New model
new const g_model_spam[] =			"models/EasyBlock/spamduck.mdl";		        //New model
new const g_model_bunnyhopdmg[] =		"models/EasyBlock/platforma.mdl";		//New model
new const g_model_armor[] =			"models/EasyBlock/platforma.mdl";		//New model
new const g_model_boom[] =			"models/EasyBlock/platforma.mdl";		//New model
new const g_model_rand[] =			"models/EasyBlock/platforma.mdl";		//New model
new const g_model_xp[] =			"models/EasyBlock/platforma.mdl";		        //New model
new const g_model_przekrety[] =			"models/EasyBlock/platforma.mdl";		//New model
new const g_model_vip[] = 			"models/EasyBlock/platforma.mdl";		//New model	
new const g_model_noc[] = 			"models/EasyBlock/platforma.mdl";		//New model
new const g_model_zatrucie[] =			"models/EasyBlock/platforma.mdl";		//New model
new const g_model_antidotum[] =			"models/EasyBlock/platforma.mdl";		//New model
new const g_model_light[] =			"models/EasyBlock/platforma.mdl";		//New model
new const g_model_gps[] =			"models/EasyBlock/platforma.mdl";		//New model
new const g_model_bron[]=			"models/EasyBlock/bron.mdl";		        //New model
new const g_model_rot3[]=			"models/EasyBlock/bunnyhop.mdl";		//New model
new const g_model_trawa[]=			"models/EasyBlock/trawa.mdl";		//New model
new const g_model_mikstura[] =			"models/EasyBlock/mikstura.mdl";
new const g_model_dywan[] =			"models/EasyBlock/platforma.mdl";

new const g_sprite_light[] =			"sprites/light.spr";
new const g_sprite_teleport_start[] =		"sprites/EasyBlock/teleport_start.spr";
new const g_sprite_teleport_destination[] =	"sprites/EasyBlock/teleport_end.spr";
new const szSprite[] = 				"sprites/EasyBlock/Muzyka.spr";

new const g_sound_invincibility[] =		"EasyBlock/niesmiertelnosc.wav";
new const g_sound_stealth[] =			"EasyBlock/niewidka.wav";
new const g_sound_boots_of_speed[] =		"EasyBlock/butyszybkosci.wav";
new const g_sound_noc[] =		"EasyBlock/ciemnosc.wav";
new const g_sound_death[] =		"EasyBlock/smierc.wav";
new const g_sound_mikstura[] = 		"EasyBlock/mikstura.wav";	
new const g_sound_kurczak[] =		"EasyBlock/chicken.wav";
new const g_sound_granat[] =            "EasyBlock/granat.wav";
new const gszCamouflageSound[] = 		"EasyBlock/kamuflaz.wav";	
new const gszTeleportSound[] = 			"EasyBlock/tele.wav";
new const gszWeapons[] = 			"EasyBlock/bron.wav";
new g_sprite_beam;
new const gszNukeExplosion[] = "weapons/c4_explode1.wav";

enum ( <<= 1 )
{
	B1 = 1, B2, B3, B4, B5, B6, B7, B8, B9, B0
};

enum
{
	K1, K2, K3, K4, K5, K6, K7, K8, K9, K0
};

enum
{
	CHOICE_DELETE, CHOICE_LOAD
};

enum
{
	X, Y, Z
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
	TASK_KAMUFLARZ,
	TASK_XP,
	TASK_NOC
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

new g_block_menu[256+128];
new g_move_menu[256+128];
new g_teleport_menu[256+128];
new g_light_menu[128];
new g_light_properties_menu[256+128];
new g_options_menu[256+128];
new g_choice_menu[128];
new g_commands_menu[256+128];

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
new bool:MiksturaUsed[33];

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

new g_HudSyncObj;
new gbUsed[33];
new bool:zarazenie[33];
new numer;
new pSprite;

new Float:g_grid_size[33];
new Float:g_snapping_gap[33];
new Float:g_grab_offset[33][3];
new Float:g_grab_length[33];
new Float:g_next_damage_time[33];
new Float:g_next_heal_time[33];
new Float:g_invincibility_time_out[33];
new Float:g_invincibility_next_use[33];
new Float:g_xp_time_out[33];
new Float:g_xp_next_use[33];
new Float:g_stealth_time_out[33];
new Float:g_stealth_next_use[33];
new Float:gfNocTimeOut[33];
new Float:gfNocNextUse[33];
new Float:g_boots_of_speed_time_out[33];

new g_exploSpr;

new Float:g_boots_of_speed_next_use[33];
new Float:g_awp_next_use[33];
new Float:g_rand_next_use[33];
new Float:g_deagle_next_use[33];
new Float:g_he_next_use[33];
new Float:g_he2_next_use[33];
new Float:g_smoke_next_use[33];
new Float:g_kamuflarz_time_out[33];
new Float:g_kamuflarz_next_use[33];
new Float:next_use_gps[33];
new Float:g_set_velocity[33][3];
new Float:g_checkpoint_position[33][3];

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
	KAMUFLARZ,
	BHGLASS,
	MUZA,
	AWP,
	ROT,
	HE,
	HE2,
	SMOKE,
	BHICE,
	FLASH,
	BHFLASH,
	SPAM,
	DEATHD,
	BUNNYHOPDMG,
	ARMOR,
	BOOM,
	RAND,
	XP,
	PRZEKRETY,
	VIP,
	NOC,
	ZATRUCIE,
	ANTIDOTUM,
	LIGHT,
	GPS,
	BRON,
	ROT3,
	TRAWA,
	MIKSTURA,
	DYWAN,

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
	LARGE,
	POLE
};

enum
{
	NORMAL,
	GLOWSHELL,
	TRANSCOLOR,
	TRANSALPHA,
	TRANSWHITE,
	TRANSADD
};

enum _:Weapons
{ 
	awp,	//0
	deagle,
	ak47,
	scout,
	m3,
	m4a1,
	tmp,
	usp,
	glock18,
	mp5navy,
	xm1014,	//10
	mac10,
	aug,
	elite,
	fiveseven,
	ump45,
	sg550,
	galil,
	famas,
	m249,
	g3sg1,	//20
	sg552,
	p228,
	p90,
	weapon_flashbang,
	weapon_hegrenade,
	weapon_smokegrenade,
	weapon_c4	//27
};

new const g_bronie[Weapons][] =
{
	"awp",
	"deagle",
	"ak47",
	"scout",
	"m3",
	"m4a1",
	"tmp",
	"usp",
	"glock18",
	"mp5navy",
	"xm1014",
	"mac10",
	"aug",
	"elite",
	"fiveseven",
	"ump45",
	"sg550",
	"galil",
	"famas",
	"m249",
	"g3sg1",
	"sg552",
	"p228",
	"p90",
	"flashbang",
	"hegrenade",
	"smokegrenade",
	"c4"
};

new g_selected_block_type[TOTAL_BLOCKS];
new g_render[TOTAL_BLOCKS];
new g_red[TOTAL_BLOCKS];
new g_green[TOTAL_BLOCKS];
new g_blue[TOTAL_BLOCKS];
new g_alpha[TOTAL_BLOCKS];

new bool:gbUsedWeapon[33][Weapons];

new const g_block_names[TOTAL_BLOCKS][] =
{
	"Platforma",
	"Bhop",
	"Obrazenia",
	"Zycie",
	"Bez obrazen (upadek)",
	"Lod",
	"Trampolina",
	"Strzalka",
	"Smierc",
	"Mala grawitacja",
	"Slap",
	"Miod",
	"Blokuj CT",
	"Blokuj T",
	"Szyba",
	"Bhop NoSlowDown",
	"Opozniony Bhop",
	"Niesmiertelnosc",
	"Niewidzialnosc",
	"Buty predkosci",
	"Kamuflarz",
	"Bhop szyba",
	"Muzyka",
	"Bron Awp",
	"Znikajacy",
	"Granat HE",
	"Granat Kurczak",
	"Granat Smoke",
	"Bhop Ice",
	"Oslepiajacy",
	"Bhop oslepiajacy",
	"Spam duck",
	"Odbijajacy sie death",
	"Bhop Dmg",
	"Pancerz",
	"Kamikaze",
	"Losowy",
	"XP Block",
	"BHOP Przekrety",
	"VIP",
	"Ciemnosc",
	"Zatrucie",
	"Antidotum",
	"Bhop Light",
	"Gps",
	"Bron",
	"Rotate BHOP",
	"Trawa",
	"Mikstura",
	"Dywan"
};

new const g_property1_name[TOTAL_BLOCKS][] =
{
	"",
	"Bez obrazen (upadek)",
	"Obrazenia",
	"Leczenie",
	"",
	"",
	"Predkosc w gore",
	"Predkosc",
	"Zabija z godem",
	"Grawitacja",
	"Sila wybicia",
	"Predkosc w miodzie",
	"",
	"",
	"",
	"Bez obrazen (upadek)",
	"Czas po jakim znika",
	"Czas niesmiertelnosci",
	"Czas niewidzialnosci",
	"Czas butow speeda",
	"Czas kamuflarza",
	"Bez obrazen (upadek)",
	"",
	"",
	"",
	"",
	"",
	"",
	"Bez obrazen (upadek)",
	"",
	"",
	"",
	"Zabija z godem",
	"Bez obrazen (upadek)",
	"Po ile",
	"Zasieg pierdolniecia",
	"",
	"Ilosc Expa",
	"",
	"",
	"Czas Nocy",
	"",
	"",
	"Bez obrazen (upadek)",
	"",
	"Nazwa Broni",
	"",
	"",
	"HP",
	""
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
	"0",
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
	"15",
	"0",
	"",
	"",
	"",
	"",
	"",
	"",
	"0",
	"",
	"",
	"",
	"0",
	"0",
	"5",
	"300",
	"",
	"10",
	"",
	"",
	"15",
	"",
	"",
	"0",
	"",
	"0",
	"",
	"",
	"50",
	""
};

new const g_property2_name[TOTAL_BLOCKS][] =
{
	"",
	"",
	"Czas pomiedzy obrazeniami",
	"Czas pomiedzy leczeniem",
	"",
	"",
	"",
	"Predkosc w gore",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"Odstep pomiedzy uzyciem",
	"Odstep pomiedzy uzyciem",
	"Odstep pomiedzy uzyciem",
	"Odstep pomiedzy uzyciem",
	"",
	"",
	"Odstep pomiedzy uzyciem",
	"",
	"Odstep pomiedzy uzyciem",
	"Odstep pomiedzy uzyciem",
	"Odstep pomiedzy uzyciem",
	"",
	"",
	"",
	"",
	"Wysokosc",
	"",
	"Czas pomiedzy dodawaniem",
	"",
	"",
	"Odstep pomiedzy uzyciem",
	"",
	"",
	"Odstep pomiedzy uzyciem",
	"",
	"",
	"",
	"",
	"Ilosc naboji",
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
	"60",
	"60",
	"60",
	"60",
	"",
	"",
	"60",
	"",
	"60",
	"60",
	"60",
	"",
	"",
	"",
	"",
	"500",
	"",
	"0.5",
	"",
	"",
	"60",
	"",
	"",
	"60",
	"",
	"",
	"",
	"",
	"1",
	"",
	"",
	"",
	""
};

new const g_property3_name[TOTAL_BLOCKS][] =
{
	"",
	"Przezroczystosc",
	"Przezroczystosc",
	"Przezroczystosc",
	"Przezroczystosc",
	"Przezroczystosc",
	"Przezroczystosc",
	"Przezroczystosc",
	"Przezroczystosc",
	"Przezroczystosc",
	"Przezroczystosc",
	"Przezroczystosc",
	"Przezroczystosc",
	"Przezroczystosc",
	"",
	"Przezroczystosc",
	"Przezroczystosc",
	"",
	"",
	"Speed",
	"",
	"",
	"",
	"",
	"Przezroczystosc",
	"",
	"",
	"",
	"Przezroczystosc",
	"",
	"",
	"",
	"",
	"Przezroczystosc",
	"Przezroczystosc",
	"Przezroczystosc",
	"Przezroczystosc",
	"Przezroczystosc",
	"",
	"Przezroczystosc",
	"",
	"",
	"",
	"Przezroczystosc",
	"",
	"Przezroczystosc",
	"Przezroczystosc",
	"",
	"Przezroczystosc",
	"Przezroczystosc"
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
	"",
	"",
	"",
	"",
	"255",
	"",
	"",
	"",
	"255",
	"",
	"",
	"",
	"",
	"255",
	"255",
	"255",
	"255",
	"255",
	"",
	"255",
	"",
	"",
	"",
	"255",
	"",
	"255",
	"255",
	"",
	"255",
	"255"
};

new const g_property4_name[TOTAL_BLOCKS][] =
{
	"",
	"Tylko z gory",
	"Tylko z gory",
	"Tylko z gory",
	"",
	"",
	"Tylko z gory",
	"Tylko z gory",
	"Tylko z gory",
	"Tylko z gory",
	"Tylko z gory",
	"Tylko z gory",
	"Tylko z gory",
	"Tylko z gory",
	"",
	"Tylko z gory",
	"Tylko z gory",
	"Tylko z gory",
	"Tylko z gory",
	"Tylko z gory",
	"Tylko z gory",
	"Tylko z gory",
	"",
	"",
	"Tylko z gory",
	"",
	"",
	"",
	"Tylko z gory",
	"",
	"Tylko z gory",
	"",
	"Tylko z gory",
	"Tylko z gory",
	"Tylko z gory",
	"Tylko z gory",
	"Tylko z gory",
	"Tylko z gory",
	"Tylko z gory",
	"Tylko z gory",
	"Tylko z gory",
	"Tylko z gory",
	"Tylko z gory",
	"Tylko z gory",
	"",
	"Tylko z gory",
	"Tylko z gory",
	"",
	"Tylko z gory",
	"Tylko z gory"
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
	"1",
	"1",
	"",
	"",
	"1",
	"",
	"",
	"",
	"0",
	"",
	"0",
	"",
	"0",
	"0",
	"0",
	"0",
	"0",
	"1",
	"0",
	"0",
	"1",
	"1",
	"1",
	"0",
	"",
	"1",
	"0",
	"",
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
	'U',
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
	'7',
	'8',
	'9',
	'a',
	'b',
	'c',
	'd',
	'e',
	'f',
	'g',
	'h',
	'i',
	'j',
	'k',
	'l',
	'm',
	'n',
	'@',
	'p'
};

new g_block_models[TOTAL_BLOCKS][256];

new g_block_selection_pages_max;

new const gszS1[] = "EB-Sound/EasyBlock/Kwiecien/1.wav";
new const gszS2[] = "EB-Sound/EasyBlock/Kwiecien/2.wav";
new const gszS3[] = "EB-Sound/EasyBlock/Kwiecien/3.wav";
new const gszS4[] = "EB-Sound/EasyBlock/Kwiecien/4.wav";
new const gszS5[] = "EB-Sound/EasyBlock/Kwiecien/5.wav";
new const gszS6[] = "EB-Sound/EasyBlock/Kwiecien/6.wav";
new const gszS7[] = "EB-Sound/EasyBlock/Kwiecien/7.wav";
new const gszS8[] = "EB-Sound/EasyBlock/Kwiecien/8.wav";
new const gszS9[] = "EB-Sound/EasyBlock/Kwiecien/9.wav";
new const gszS10[] = "EB-Sound/EasyBlock/Kwiecien/10.wav";
new const gszS11[] = "EB-Sound/EasyBlock/Kwiecien/11.wav";
new const gszS12[] = "EB-Sound/EasyBlock/Kwiecien/12.wav";
new const gszS13[] = "EB-Sound/EasyBlock/Kwiecien/13.wav";
new const gszXpSound[] = "EasyBlock/xp.wav";

new const sprite_grenade_ring[] = "sprites/shockwave.spr"		


public plugin_precache()
{
	g_block_models[PLATFORM] =		g_model_platform;
	g_block_models[BUNNYHOPDMG] =		g_model_bunnyhopdmg;
	g_block_models[BUNNYHOP] =		g_model_bunnyhop;
	g_block_models[FLASH_] =			g_model_flash;
	g_block_models[BHFLASH] =		g_model_bhflash;
	g_block_models[DAMAGE] =		g_model_damage;
	g_block_models[HEALER] =		g_model_healer;
	g_block_models[NO_FALL_DAMAGE] =	g_model_no_fall_damage;
	g_block_models[ICE] =			g_model_ice;
	g_block_models[TRAMPOLINE] =		g_model_trampoline;
	g_block_models[SPEED_BOOST] =		g_model_speed_boost;
	g_block_models[DEATH] =			g_model_death;
	g_block_models[LOW_GRAVITY] =		g_model_low_gravity;
	g_block_models[MUZA] =			g_model_muza;
	g_block_models[SLAP] =			g_model_slap;
	g_block_models[HONEY] =			g_model_honey;
	g_block_models[CT_BARRIER] =		g_model_ct_barrier;
	g_block_models[T_BARRIER] =		g_model_t_barrier;
	g_block_models[GLASS] =			g_model_glass;
	g_block_models[BHGLASS] =		g_model_bhglass;
	g_block_models[NO_SLOW_DOWN_BUNNYHOP] =	g_model_no_slow_down_bunnyhop;
	g_block_models[DELAYED_BUNNYHOP] =	g_model_delayed_bunnyhop;
	g_block_models[INVINCIBILITY] =		g_model_invincibility;
	g_block_models[STEALTH] =		g_model_stealth;
	g_block_models[BOOM] =			g_model_boom;
	g_block_models[BOOTS_OF_SPEED] =	g_model_boots_of_speed;
	g_block_models[AWP] =			g_model_awp;
	g_block_models[HE] =			g_model_he;
	g_block_models[HE2] =			g_model_he2;
	g_block_models[SMOKE] =			g_model_smoke;
	g_block_models[ROT] =			g_model_rot;
	g_block_models[KAMUFLARZ] =		g_model_kamuflarz;
	g_block_models[BHICE] =			g_model_bhice;
	g_block_models[SPAM] =			g_model_spam;
	g_block_models[DEATHD] =		g_model_deathd;
	g_block_models[ARMOR] =			g_model_armor;
	g_block_models[RAND] =			g_model_rand;
	g_block_models[XP] =			g_model_xp;
	g_block_models[PRZEKRETY] =		g_model_przekrety;
	g_block_models[VIP] = 			g_model_vip;
	g_block_models[NOC] = 			g_model_noc;
	g_block_models[ZATRUCIE] =		g_model_zatrucie;
	g_block_models[ANTIDOTUM] =		g_model_antidotum;
	g_block_models[LIGHT] =			g_model_light;
	g_block_models[GPS] =			g_model_gps;
	g_block_models[BRON] =			g_model_bron;
	g_block_models[ROT3] =			g_model_rot3;
	g_block_models[TRAWA] =			g_model_trawa;
	g_block_models[MIKSTURA] =		g_model_mikstura;
	g_block_models[DYWAN] =			g_model_dywan;

	SetupBlockRendering(GLASS, TRANSWHITE, 255, 255, 255, 100);
	SetupBlockRendering(BHGLASS, TRANSWHITE, 255, 255, 255, 100);
	SetupBlockRendering(INVINCIBILITY, GLOWSHELL, 255, 255, 255, 16);
	SetupBlockRendering(STEALTH, TRANSWHITE, 255, 255, 255, 100);
	SetupBlockRendering(PRZEKRETY, TRANSADD, 255, 255, 255, 255);
	SetupBlockRendering(NOC, TRANSADD, 255, 255, 255, 255);
	SetupBlockRendering(ZATRUCIE, GLOWSHELL, 255, 0, 0, 16);
	SetupBlockRendering(ANTIDOTUM, GLOWSHELL, 0, 255, 0, 16);
	
	new block_model[256];
	for ( new i = 0; i < TOTAL_BLOCKS; ++i )
	{
		precache_model(g_block_models[i]);
		
		SetBlockModelName(block_model, g_block_models[i], "_small.mdl");
		precache_model(block_model);
		
		SetBlockModelName(block_model, g_block_models[i], "_large.mdl");
		precache_model(block_model);
		
		SetBlockModelName(block_model, g_block_models[i], "_pole.mdl");
		precache_model(block_model);
	}
	g_exploSpr = engfunc(EngFunc_PrecacheModel, sprite_grenade_ring)
	precache_model(g_sprite_light);
	precache_model("models/chick.mdl");
	
	precache_model(g_sprite_teleport_start);
	precache_model(g_sprite_teleport_destination);
	g_sprite_beam = precache_model("sprites/zbeam4.spr");
	pSprite = precache_model(szSprite);
	
	precache_sound("weapons/flashbang-2.wav");
	precache_sound(g_sound_invincibility);
	precache_sound(g_sound_stealth);
	precache_sound(g_sound_boots_of_speed);
        precache_sound(g_sound_death);
        precache_sound(g_sound_noc);
	precache_sound(g_sound_mikstura);
        precache_sound(g_sound_kurczak);
        precache_sound(g_sound_granat);
        precache_sound(gszCamouflageSound);
	precache_sound(gszTeleportSound);
	precache_sound(gszWeapons);
	
	precache_sound(gszS1);
	precache_sound(gszS2);
	precache_sound(gszS3);
	precache_sound(gszS4);
	precache_sound(gszS5);
	precache_sound(gszS6);
	precache_sound(gszS7);
	precache_sound(gszS8);
	precache_sound(gszS9);
	precache_sound(gszS10);
	precache_sound(gszS11);
	precache_sound(gszS12);
	precache_sound(gszS13);
	precache_sound(gszNukeExplosion);
	precache_sound(gszXpSound);
}

public plugin_init()
{
	register_plugin(PLUGIN_NAME, "4.5", PLUGIN_AUTHOR);
	RegisterHam(Ham_TakeDamage,"player", "hook_TakeDamage");
	set_task(25.0, "info",_,_,_,"b");
        RegisterSayCmd("/bm",			"CmdMainMenu");
	gMsgScreenFade = get_user_msgid("ScreenFade");
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
	
	register_clcmd("bm_ustawienia",	"SetPropertyBlock",	-1);
	register_clcmd("bm_swiatla",	"SetPropertyLight",	-1);
	register_clcmd("bm_ozyw",	"RevivePlayer",		-1);
	register_clcmd("bm_dajbm",	"GiveAccess",		-1);
	
	command =				"CmdGrab";
	register_clcmd("+bmgrab",		command,		-1, g_blank);
	register_clcmd("+bmgrab",		command,		-1, g_blank);
	
	command =				"CmdRelease";
	register_clcmd("-bmgrab",		command,		-1, g_blank);
	register_clcmd("-bmgrab",		command,		-1, g_blank);
	
	CreateMenus();
	
	register_menucmd(register_menuid("SCMMainMenu"),		g_keys_main_menu,		"HandleMainMenu");
	register_menucmd(register_menuid("SCMBlockMenu"),		g_keys_block_menu,		"HandleBlockMenu");
	register_menucmd(register_menuid("SCMBlockSelectionMenu"),	g_keys_block_selection_menu,	"HandleBlockSelectionMenu");
	register_menucmd(register_menuid("SCMPropertiesMenu"),		g_keys_properties_menu,		"HandlePropertiesMenu");
	register_menucmd(register_menuid("SCMMoveMenu"),		g_keys_move_menu,		"HandleMoveMenu");
	register_menucmd(register_menuid("SCMTeleportMenu"),		g_keys_teleport_menu,		"HandleTeleportMenu");
	register_menucmd(register_menuid("SCMLightMenu"),		g_keys_light_menu,		"HandleLightMenu");
	register_menucmd(register_menuid("SCMLightPropertiesMenu"),	g_keys_light_properties_menu,	"HandleLightPropertiesMenu");
	register_menucmd(register_menuid("SCMOptionsMenu"),		g_keys_options_menu,		"HandleOptionsMenu");
	register_menucmd(register_menuid("SCMChoiceMenu"),		g_keys_choice_menu,		"HandleChoiceMenu");
	register_menucmd(register_menuid("SCMCommandsMenu"),		g_keys_commands_menu,		"HandleCommandsMenu");
	
	register_cvar("bm_budowanie", "0");
	
	RegisterHam(Ham_Spawn,		"player",	"FwdPlayerSpawn",	1);
	RegisterHam(Ham_Killed,		"player",	"FwdPlayerKilled",	1);
	
	register_forward(FM_CmdStart,			"FwdCmdStart");
	
	register_think(g_light_classname,		"LightThink");
	
	register_event("CurWeapon",			"EventCurWeapon",	"be");
	
	register_message(get_user_msgid("StatusValue"),	"MsgStatusValue");
	
	g_max_players =		get_maxplayers();
	set_task(2.0, "przekrec", 0, "", _, "b");
	
	new dir[64];
	get_datadir(dir, charsmax(dir));
	
	new folder[64];
	formatex(folder, charsmax(folder), "/%s", PLUGIN_PREFIX);
	
	add(dir, charsmax(dir), folder);
	if ( !dir_exists(dir) ) mkdir(dir);
	set_task(3.0, "odswiez");
	new map[32];
	get_mapname(map, charsmax(map));
	g_HudSyncObj = CreateHudSyncObj();
	formatex(g_file, charsmax(g_file), "%s/%s.%s", dir, map, PLUGIN_PREFIX);

}
public odswiez(){
	new ent = -1;
	while ((ent = find_ent_by_class(ent, g_block_classname))){
		if (IsBlock(ent)){
			new blockType = entity_get_int(ent, EV_INT_body);
			if (blockType == DEATHD){	
				new Float:floatt[3];
				new property2[5];
				GetProperty(ent, 2, property2);
				floatt[2] = str_to_float(property2);
				entity_set_int(ent, EV_INT_movetype, MOVETYPE_BOUNCE);
				drop_to_floor(ent);
				entity_set_vector(ent, EV_VEC_velocity, floatt);
			}
		}
	}
}

public info(id) {
	ColorChat(id, GREEN, "[EasyBlock]^x01 Na serwerze jest^x04 BM^x01 by^x03 kyku&DMK880^x01 edytowany przez:^x04 Na 5tyk'a.");
}

public przekrec()
{
	new ent = -1;
	while ((ent = find_ent_by_class(ent, g_block_classname)))
	{
		if (IsBlock(ent))
		{
			new blockType = entity_get_int(ent, EV_INT_body);
			if(blockType == ROT3) RotateBlock(ent);
			if(blockType == ROT) TaskSolidNot(TASK_SOLIDNOT + ent);
		}
	}
	return PLUGIN_CONTINUE;
}
public plugin_cfg(){
	LoadBlocks(0);
}

public client_putinserver(id)
{
	g_connected[id] =			bool:!is_user_hltv(id);
	g_alive[id] =				false;
	
	g_admin[id] =				bool:access(id, ADMIN_LEVEL_H);
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
	zarazenie[id] =				false;
	
	g_has_checkpoint[id] =			false;
	g_checkpoint_duck[id] =			false;
	
	g_reseted[id] =				false;
	MiksturaUsed[id] =		false;
	
	ResetPlayer(id);
}

public client_disconnect(id)
{
	g_connected[id] =			false;
	g_alive[id] =				false;
	
	ClearGroup(id);
	if ( g_grabbed[id] ){
		if ( is_valid_ent(g_grabbed[id]) ){
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
	new size;
	g_keys_main_menu = B1 | B2 | B3 | B4 | B5 | B6 | B7| B9 | B0;

	size = charsmax(g_block_menu);
	add(g_block_menu, size, "\r[%s] \yMenu Blockow^n^n");
	add(g_block_menu, size, "\r1. \wBlock Type: \y%s^n");
	add(g_block_menu, size, "%s2. %sUtworz Block^n");
	add(g_block_menu, size, "%s3. %sZamien Block^n");
	add(g_block_menu, size, "%s4. %sUsun Block^n");
	add(g_block_menu, size, "%s5. %sObroc Block^n^n");
	add(g_block_menu, size, "%s6. %sNoclip: %s^n");
	add(g_block_menu, size, "%s7. %sGodmode: %s^n^n");
	add(g_block_menu, size, "\r8. \wRozmiar Blocka: \y%s^n");
	add(g_block_menu, size, "%s9. %sOpcje Blockow^n^n");
	add(g_block_menu, size, "\r0. \wWroc");
	g_keys_block_menu =		B1 | B2 | B3 | B4 | B5 | B6 | B7 | B8 | B9 | B0;
	g_keys_block_selection_menu =	B1 | B2 | B3 | B4 | B5 | B6 | B7 | B8 | B9 | B0;
	g_keys_properties_menu =	B1 | B2 | B3 | B4 | B0;
	
	size = charsmax(g_move_menu);
	add(g_move_menu, size, "\r[%s] \yMenu przesuwania^n^n");
	add(g_move_menu, size, "\r1. \wRozmiar siatki: \y%.1f^n^n");
	add(g_move_menu, size, "\r2. \wZ\y+^n");
	add(g_move_menu, size, "\r3. \wZ\r-^n");
	add(g_move_menu, size, "\r4. \wX\y+^n");
	add(g_move_menu, size, "\r5. \wX\r-^n");
	add(g_move_menu, size, "\r6. \wY\y+^n");
	add(g_move_menu, size, "\r7. \wY\r-^n^n^n");
	add(g_move_menu, size, "\r0. \wWroc");
	g_keys_move_menu =		B1 | B2 | B3 | B4 | B5 | B6 | B7 | B0;
	
	size = charsmax(g_teleport_menu);
	add(g_teleport_menu, size, "\r[%s] \yMenu teleportow^n^n");
	add(g_teleport_menu, size, "%s1. %sPostaw Teleport^n");
	add(g_teleport_menu, size, "%s2. %sKoniec Teleportu^n^n");
	add(g_teleport_menu, size, "%s3. %sUsun Teleport^n^n");
	add(g_teleport_menu, size, "%s4. %sZmien start z koncem^n^n");
	add(g_teleport_menu, size, "%s5. %sPokaz linie teleportu^n^n^n");
	add(g_teleport_menu, size, "\r0. \wWroc");
	g_keys_teleport_menu =		B1 | B2 | B3 | B4 | B5 | B0;
	
	size = charsmax(g_light_menu);
	add(g_light_menu, size, "\r[%s] \yMenu swiatel^n^n");
	add(g_light_menu, size, "%s1. %sStworz swiatlo^n");
	add(g_light_menu, size, "%s2. %sUsun swiatlo^n^n");
	add(g_light_menu, size, "%s3. %sZmien kolor^n^n^n^n^n^n^n");
	add(g_light_menu, size, "\r0. \wWroc");
	g_keys_light_menu =		B1 | B2 | B3 | B0;
	
	size = charsmax(g_light_properties_menu);
	add(g_light_properties_menu, size, "\r[%s] \yUstawienia swiatla^n^n");
	add(g_light_properties_menu, size, "\r1. \wOdleglosc: \y%s^n");
	add(g_light_properties_menu, size, "\r2. \wCzerwony  (R): \y%s^n");
	add(g_light_properties_menu, size, "\r3. \wZielony   (G): \y%s^n");
	add(g_light_properties_menu, size, "\r4. \wNiebieski (B): \y%s^n^n^n^n^n^n^n");
	add(g_light_properties_menu, size, "\r0. \wWroc");
	g_keys_light_properties_menu =	B1 | B2 | B3 | B4 | B0;
	
	size = charsmax(g_options_menu);	
	add(g_options_menu, size, "\r[%s] \yMenu opcji^n^n");
	add(g_options_menu, size, "%s1. %sLaczenie: %s^n");
	add(g_options_menu, size, "%s2. %sOdstep: \y%.1f^n^n");
	add(g_options_menu, size, "%s3. %sDodaj do grupy^n");
	add(g_options_menu, size, "%s4. %sWyczysc grupe^n^n");
	add(g_options_menu, size, "%s5. %sUstawienia blocka^n");
	add(g_options_menu, size, "%s6. %sPrzesun block^n^n");
	add(g_options_menu, size, "%s7. %sUsun wszystkie blocki^n");
	add(g_options_menu, size, "%s8. %sZapisz wszystkie blocki^n");
	add(g_options_menu, size, "%s9. %sZaladuj wszystkie blocki^n^n");
	add(g_options_menu, size, "\r0. \wWroc");
	g_keys_options_menu =		B1 | B2 | B3 | B4 | B5 | B6 | B7 | B8 | B9| B0;
	
	size = charsmax(g_choice_menu);
	add(g_choice_menu, size, "\y%s^n^n");
	add(g_choice_menu, size, "\r1. \wTak^n");
	add(g_choice_menu, size, "\r2. \wNie^n^n^n^n^n^n^n^n^n");
	g_keys_choice_menu =		B1 | B2;
	
	size = charsmax(g_commands_menu);
	add(g_commands_menu, size, "\r[%s] \yMenu Admina^n^n");
	add(g_commands_menu, size, "%s1. %sZapisz Checkpoint^n");
	add(g_commands_menu, size, "%s2. %sZaladuj Checkpoint^n^n");
	add(g_commands_menu, size, "%s3. %sOzyw sie^n");
	add(g_commands_menu, size, "%s4. %sOzyw gracza^n");
	add(g_commands_menu, size, "%s5. %sOzyw wszystkich^n^n");
	add(g_commands_menu, size, "%s6. %sGod dla wszystkich%s%s^n");
	add(g_commands_menu, size, "%s7. %sDaj graczowi %s^n^n");
	add(g_commands_menu, size, "\r0. \wWroc");
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
	replace(model_target, charsmax(model_target), ".mdl", new_name);
	if(!file_exists(model_target)) format(model_target, 255, "models/EasyBlock/platforma_pole.mdl");
	if(equal(model_target, "models/EasyBlock/platforma_large.mdl")) format(model_target, 255, "models/csEntasiaEB/platforma_large.mdl");
}
public FwdPlayerSpawn(id)
{
	if ( !is_user_alive(id) ) return HAM_IGNORED;
	
	g_alive[id] =			true;
	kurczak[id]=0;
	if ( g_noclip[id] )		set_user_noclip(id, 1);
	if ( g_godmode[id] )		set_user_godmode(id, 1);
	if ( zarazenie[id] )		zarazenie[id]=false;
	if ( g_all_godmode ){
		for ( new i = 1; i <= g_max_players; i++ ){
			if ( !g_alive[i] || g_admin[i] || g_gived_access[i] ) continue;
			entity_set_float(i, EV_FL_takedamage, DAMAGE_NO);
		}
	}
	if ( g_viewing_commands_menu[id] ) ShowCommandsMenu(id);
	if ( !g_reseted[id] ) ResetPlayer(id);
	
	g_reseted[id] =			false;
	
	return HAM_IGNORED;
}

public FwdPlayerKilled(id)
{
	g_alive[id] = bool:is_user_alive(id);
	if ( zarazenie[id] )		zarazenie[id]=false;
	ResetPlayer(id);
	if ( g_viewing_commands_menu[id] ) ShowCommandsMenu(id);
}
public hook_TakeDamage(id, Useless, Attacker, Float:damage, damagebits)
{
	new classname[32];
	pev(Useless,pev_classname,classname,31);
	
	if(equal(classname,"kurczak")){
	
		if(get_user_team(Attacker) == get_user_team(id) && Attacker != id)
		SetHamParamFloat(4, 0.0);
		else if(is_user_connected(id) && is_user_alive(id)){
			new Float:pAim[3];
			new str[11];
			float_to_str(damage, str, 10);
			if(id != Attacker || get_cvar_num("bm_kurczak")){
				if(str_to_num(str) > 5){
					velocity_by_aim(id, str_to_num(str)+20*15, pAim);
					pAim[2] =  random_float(300.0, 900.0);	
					pAim[1] =  random_float(-800.0, 800.0);	
					pAim[0] =  random_float(-800.0, 800.0);	
					entity_set_vector(id, EV_VEC_velocity, pAim);
					entity_set_int(id, EV_INT_gaitsequence, 6);   
						
					client_print(id, print_chat, "Oberwales od kurczaka!");
					emit_sound(id, CHAN_STATIC, "misc/killChicken.wav", 1.0, ATTN_NORM, 0, PITCH_NORM);

				}
			}
		}
	}
	return HAM_IGNORED;
} 

public grenade_throw(id, gid, wid)
{
	if(kurczak[id]>0 && wid == CSW_HEGRENADE){
		kurczak[id] --;
		set_pev(gid, pev_classname,"kurczak");
		entity_set_model(gid, "models/chick.mdl");
	}
}
public FwdCmdStart(id, handle)
{
	if ( !g_connected[id] ) return FMRES_IGNORED;
	
	static buttons, oldbuttons;
	buttons =	get_uc(handle, UC_Buttons);
	oldbuttons =	entity_get_int(id, EV_INT_oldbuttons);
	
	if ( /*g_alive[id] && */( buttons & IN_USE ) && !( oldbuttons & IN_USE ) && !g_has_hud_text[id] ){
		static ent, body;
		get_user_aiming(id, ent, body, 9999);
	
		if ( IsBlock(ent) ){
			static block_type;
			block_type = entity_get_int(ent, EV_INT_body);
			
			static property[5];
			static message[512], len;
			len = format(message, charsmax(message), "EasyBlock^nRodzaj blocka: %s", g_block_names[block_type]);
	
			if ( g_property1_name[block_type][0] ){
				GetProperty(ent, 1, property);
		
				if ( ( block_type == BUNNYHOP || block_type == NO_SLOW_DOWN_BUNNYHOP|| block_type ==BUNNYHOPDMG || block_type==BHGLASS ||block_type==BHICE||block_type == BHFLASH) && property[0] == '1' ){
					len += format(message[len], charsmax(message) - len, "^n%s", g_property1_name[block_type]);
				}
				
				else if ( block_type == DEATH || block_type==DEATHD){
					GetProperty(ent, 1, property);
					len += format(message[len], charsmax(message) - len, "^n%s: %s", g_property1_name[block_type], property[0] == '1' ? "Tak" : "Nie");
				}
				
				else if ( block_type == SLAP ){
					len += format(message[len], charsmax(message) - len, "^n%s: %s", g_property1_name[block_type], property[0] == '3' ? "Duza" : property[0] == '2' ? "Srednia" : "Mala");
				}
				
				else if ( block_type == BRON ){
					new i = str_to_num(property);
					len += format(message[len], charsmax(message) - len, "^n%s: %s", g_property1_name[block_type], g_bronie[i]);
				}
				else if ( block_type == XP ){
					GetProperty(ent, 1, property);
					new k = str_to_num(property);
					len += format(message[len], charsmax(message) - len, "^nIlosc XP: %d | VIP: %d",k, k+15);
				}
				else if ( block_type != BUNNYHOP && block_type != NO_SLOW_DOWN_BUNNYHOP &&block_type != BUNNYHOPDMG&&block_type != BHGLASS&&block_type!=BHICE&&block_type!=BHFLASH){
					len += format(message[len], charsmax(message) - len, "^n%s: %s", g_property1_name[block_type], property);
				}
			
			}
			if ( g_property2_name[block_type][0] ){
				GetProperty(ent, 2, property);
				len += format(message[len], charsmax(message) - len, "^n%s: %s", g_property2_name[block_type], property);
			}
			/*if ( g_property3_name[block_type][0] ){
				GetProperty(ent, 3, property);
			
				if ( block_type == BOOTS_OF_SPEED || property[0] != '0' && !( property[0] == '2' && property[1] == '5' && property[2] == '5' ) ){
					len += format(message[len], charsmax(message) - len, "^n%s: %s", g_property3_name[block_type], property);
				}
			}*/
			if ( g_property4_name[block_type][0] ){
				GetProperty(ent, 4, property);
				len += format(message[len], charsmax(message) - len, "^n%s: %s", g_property4_name[block_type], property[0] == '1' ? "Tak" : "Nie");
			}
			set_hudmessage(255, 150, 0, 0.01, 0.18, 0, 0.0, 1.0, 0.25, 0.25, 2);
			ShowSyncHudMsg(id, g_HudSyncObj, message);
		}
		else if ( IsLight(ent) ){
			static property1[5], property2[5], property3[5], property4[5];
			
			GetProperty(ent, 1, property1);
			GetProperty(ent, 2, property2);
			GetProperty(ent, 3, property3);
			GetProperty(ent, 4, property4);
			
			set_hudmessage(255, 150, 0, 0.01, 0.18, 0, 0.0, 1.0, 0.25, 0.25, 2);
			ShowSyncHudMsg(id, g_HudSyncObj,  "EasyBlock^nSwiatlo^nSila: %s^nKolor Czerwony: %s^nKolor Zielony: %s^nKolor Niebieski: %s",  property1, property2, property3, property4);
		}
	}
	
	if ( !g_grabbed[id] ) return FMRES_IGNORED;
	if ( ( buttons & IN_JUMP ) && !( oldbuttons & IN_JUMP ) ) if ( g_grab_length[id] > 72.0 ) g_grab_length[id] -= 16.0;
	if ( ( buttons & IN_DUCK ) && !( oldbuttons & IN_DUCK ) ) g_grab_length[id] += 16.0;
	if ( ( buttons & IN_ATTACK ) && !( oldbuttons & IN_ATTACK ) ) CmdAttack(id);
	if ( ( buttons & IN_ATTACK2 ) && !( oldbuttons & IN_ATTACK2 ) ) CmdAttack2(id);
	if ( ( buttons & IN_RELOAD ) && !( oldbuttons & IN_RELOAD ) ){
		CmdRotate(id);
		set_uc(handle, UC_Buttons, buttons & ~IN_RELOAD);
	}
	if ( !is_valid_ent(g_grabbed[id]) ){
		CmdRelease(id);
		return FMRES_IGNORED;
	}
	if ( !IsBlockInGroup(id, g_grabbed[id]) || g_group_count[id] < 1 ){
		MoveGrabbedEntity(id);
		return FMRES_IGNORED;
	}
	static block;
	static Float:move_to[3];
	static Float:offset[3];
	static Float:origin[3];
	
	MoveGrabbedEntity(id, move_to);
	
	for ( new i = 0; i <= g_group_count[id]; ++i ){
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
	
	if ( g_boots_of_speed[id] ){
		block = g_boots_of_speed[id];
		GetProperty(block, 3, property);
		
		entity_set_float(id, EV_FL_maxspeed, str_to_float(property));
	}
	else if ( g_ice[id] ){
		entity_set_float(id, EV_FL_maxspeed, 400.0);
	}
	else if ( g_honey[id] ){
		block = g_honey[id];
		GetProperty(block, 1, property);
		entity_set_float(id, EV_FL_maxspeed, str_to_float(property));
	}
}

public pfn_touch(ent, id)
{
	if ( !( 1 <= id <= g_max_players ) || !g_alive[id] || !IsBlock(ent) ) return PLUGIN_CONTINUE;
	
	new block_type =	entity_get_int(ent, EV_INT_body);
	if ( block_type == PLATFORM || block_type == GLASS || block_type == ROT || block_type == TRAWA) return PLUGIN_CONTINUE;
	
	new flags =		entity_get_int(id, EV_INT_flags);
	new groundentity =	entity_get_edict(id, EV_ENT_groundentity);
	
	static property[5];
	GetProperty(ent, 4, property);
	
	if ( property[0] == '0' || ( ( !property[0] || property[0] == '1' || property[0] == '/' ) && ( flags & FL_ONGROUND ) && groundentity == ent ) )
	{
		if(block_type == FLASH || block_type == BHFLASH)
		{
			message_begin(MSG_ONE, gMsgScreenFade, {0, 0, 0}, id);
			write_short(7000);
			write_short(7000);
			write_short(4096);	
			write_byte(255);	
			write_byte(255);	
			write_byte(255);	
			write_byte(255);
			message_end();
			//emit_sound(id, CHAN_STATIC, gszFLASH, 1.0, ATTN_NORM, 0, PITCH_NORM);
		}
		if(block_type == PRZEKRETY){
			ActionPrzekrety(id)	
		}
		if(block_type == LIGHT){
			ActionLight(id);
		}
		switch ( block_type )
		{
			case BUNNYHOP, NO_SLOW_DOWN_BUNNYHOP,BHGLASS,BUNNYHOPDMG,BHICE,BHFLASH, PRZEKRETY, LIGHT,ROT3:{
				if(block_type==BUNNYHOPDMG) ActionDamage(id, ent);
				ActionBhop(ent);
			}	
			case DAMAGE:				ActionDamage(id, ent);
			case HEALER:				ActionHeal(id, ent);
			case ARMOR:				ActionArmor(id, ent);
			case TRAMPOLINE:			ActionTrampoline(id, ent);
			case SPEED_BOOST:			ActionSpeedBoost(id, ent);
			case DEATH, DEATHD:
			{
				if ( !get_user_godmode(id) )
				{	
                                        emit_sound(id, CHAN_STATIC, g_sound_death, 1.0, ATTN_NORM, 0, PITCH_NORM);
                                        fakedamage(id, "Block smierci!", 10000.0, DMG_GENERIC);
				} 
				else if(is_user_alive(id))
				{
					static property1[5];
					GetProperty(ent, 1, property1);
					if(str_to_num(property1)){
						set_user_frags(id, get_user_frags(id)+1);
						user_kill(id);
						emit_sound(id, CHAN_STATIC, g_sound_death, 1.0, ATTN_NORM, 0, PITCH_NORM);
                                                client_print(id, print_chat, "Na ten block godmode nic nie da!");
					}
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
			case VIP:				ActionVip(id, ent);
			case DELAYED_BUNNYHOP:			ActionDelayedBhop(ent);
			case STEALTH:				ActionStealth(id, ent);
			case BOOM:				ActionBoom(id, ent);
			case INVINCIBILITY:			ActionInvincibility(id, ent);
			case KAMUFLARZ:				ActionKamuflarz(id, ent);
			case BOOTS_OF_SPEED:			ActionBootsOfSpeed(id, ent);
			case MUZA:				ActionMuza(id, ent);
			case AWP:				ActionAwp(id, ent);
			case RAND:				ActionRand(id, ent);
			case HE:				ActionGranat(id, ent, 0);
			case HE2:				ActionGranat(id, ent, 1);
			case SMOKE:				ActionGranat(id, ent, 2);
			case SPAM:				ActionDUCK(id);
			case XP:				ActionXP(id, ent);
			case NOC:				ActionNoc(id,ent);
			case ZATRUCIE:				ActionZarazenie(id);
			case ANTIDOTUM:				ActionAntidotum(id);
			case GPS:				ActionGps(id);
			case BRON:				ActionWeapon(id,ent);
			case MIKSTURA:				ActionMikstura(id,ent);
			case DYWAN: 
			{
				new origin[2][3];
				pev(id, pev_origin, origin[0]);
				pev(ent, pev_origin, origin[1]);
				
				origin[1][0] = origin[0][0];
				origin[1][1] = origin[0][1];
				
				set_pev(ent, pev_origin, origin[1]);
				set_pev(ent, pev_movetype, MOVETYPE_FLY);
			}
	
		}
	}

	if ( ( flags & FL_ONGROUND ) && groundentity == ent )
	{
		switch ( block_type )
		{
			case BUNNYHOP,BUNNYHOPDMG,BHGLASS,BHICE,BHFLASH:
			{
				if(block_type == BHICE) ActionIce(id);
				GetProperty(ent, 1, property);
				if ( property[0] == '1' ){
					g_no_fall_damage[id] = true;
				}
			}
			case NO_FALL_DAMAGE:		g_no_fall_damage[id] = true;
			case ICE:			ActionIce(id);
			case PRZEKRETY:			ActionPrzekrety(id);
			case LIGHT:			ActionLight(id);
			case NO_SLOW_DOWN_BUNNYHOP:
			{
				ActionNoSlowDown(id);
				GetProperty(ent, 1, property);
				if ( property[0] == '1' ){
					g_no_fall_damage[id] = true;
				}
			}
		}
	}
	return PLUGIN_CONTINUE;
}
ActionDUCK(id){
	entity_set_int(id, EV_INT_bInDuck, 10);
}

public server_frame(){
	for ( new id = 1; id <= g_max_players; ++id ){
		if ( !g_alive[id] ) continue;
		
		if ( g_ice[id] || g_no_slow_down[id] ){
			entity_set_float(id, EV_FL_fuser2, 0.0);
		}
		if ( g_set_velocity[id][0] != 0.0|| g_set_velocity[id][1] != 0.0|| g_set_velocity[id][2] != 0.0 ){
			entity_set_vector(id, EV_VEC_velocity, g_set_velocity[id]);
			g_set_velocity[id][0] = 0.0;
			g_set_velocity[id][1] = 0.0;
			g_set_velocity[id][2] = 0.0;
		}
		if ( g_low_gravity[id] ){
			if ( entity_get_int(id, EV_INT_flags) & FL_ONGROUND ){
				entity_set_float(id, EV_FL_gravity, 1.0);
				g_low_gravity[id] = false;
			}
		}
		while ( g_slap_times[id] ){
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

			if ( 1 <= entinsphere <= g_max_players && g_alive[entinsphere] ){
				ActionTeleport(entinsphere, ent);
			}
			else if ( equal(classname, "grenade") ){
				entity_set_int(ent, EV_INT_solid, SOLID_NOT);
				entity_set_float(ent, EV_FL_ltime, get_gametime() + 2.0);
			}
			else if ( get_gametime() >= entity_get_float(ent, EV_FL_ltime) ){
				entity_set_int(ent, EV_INT_solid, SOLID_BBOX);
			}
		}
	}

	static bool:ent_near;

	ent_near = false;
	while ( ( ent = find_ent_by_class(ent, g_destination_classname) ) ){
		entity_get_vector(ent, EV_VEC_origin, origin);
		entinsphere = -1;
		while ( ( entinsphere = find_ent_in_sphere(entinsphere, origin, 64.0) ) ){
			static classname[32];
			entity_get_string(entinsphere, EV_SZ_classname, classname, charsmax(classname));
	
			if ( 1 <= entinsphere <= g_max_players && g_alive[entinsphere] || equal(classname, "grenade") ){
				ent_near = true;
				break;
			}
		}
	
		if ( ent_near ){
			if ( !entity_get_int(ent, EV_INT_iuser2) ){
				entity_set_int(ent, EV_INT_solid, SOLID_NOT);
			}
		}
		else entity_set_int(ent, EV_INT_solid, SOLID_BBOX);
	}
}

public client_PreThink(id)
{
	if ( !g_alive[id] ) return PLUGIN_CONTINUE;
	
	new Float:gametime =			get_gametime();
	new Float:timeleft_kamuflarz =		g_kamuflarz_time_out[id] - gametime;
	new Float:timeleft_invincibility =	g_invincibility_time_out[id] - gametime;
	new Float:timeleft_stealth =		g_stealth_time_out[id] - gametime;
	new Float:timeleft_boots_of_speed =	g_boots_of_speed_time_out[id] - gametime;
	
	
	
	if ( timeleft_invincibility >= 0.0|| timeleft_stealth >= 0.0|| timeleft_kamuflarz >= 0.0|| timeleft_boots_of_speed >= 0.0 )
	{
		new text[48], text_to_show[256];
		
		format(text, charsmax(text), "%s", PLUGIN_PREFIX);
		add(text_to_show, charsmax(text_to_show), text);
		
		if ( timeleft_invincibility >= 0.0 ){
			format(text, charsmax(text), "^nNiesmiertelnosc %.1f", timeleft_invincibility);
			add(text_to_show, charsmax(text_to_show), text);
		}
		if ( timeleft_kamuflarz >= 0.0 ){
			format(text, charsmax(text), "^nKamuflarz %.1f", timeleft_kamuflarz);
			add(text_to_show, charsmax(text_to_show), text);
		}
		
		if ( timeleft_stealth >= 0.0 ){
			format(text, charsmax(text), "^nNiewidzialnosc %.1f", timeleft_stealth);
			add(text_to_show, charsmax(text_to_show), text);
		}
		
		if ( timeleft_boots_of_speed >= 0.0 ){
			format(text, charsmax(text), "^nButy predkosci %.1f", timeleft_boots_of_speed);
			add(text_to_show, charsmax(text_to_show), text);
		}
	
		set_hudmessage(255, 150, 0, 0.01, 0.18, 0, 0.0, 1.0, 0.25, 0.25, 2);
		ShowSyncHudMsg(id, g_HudSyncObj,  text_to_show);
	
		g_has_hud_text[id] = true;
	}
	else g_has_hud_text[id] = false;
	
	return PLUGIN_CONTINUE;
}

public client_PostThink(id)
{
	if ( !g_alive[id] ) return PLUGIN_CONTINUE;
	
	if ( g_no_fall_damage[id] ){
		entity_set_int(id,  EV_INT_watertype, -3);
		g_no_fall_damage[id] = false;
	}
	
	return PLUGIN_CONTINUE;
}

ActionBhop(ent)
{
	if ( task_exists(TASK_SOLIDNOT + ent) || task_exists(TASK_SOLID + ent) ) return PLUGIN_HANDLED;
	set_task(0.1, "TaskSolidNot", TASK_SOLIDNOT + ent);

	return PLUGIN_HANDLED;
}

ActionDamage(id, ent)
{
	new Float:gametime = get_gametime();
	if ( !( gametime >= g_next_damage_time[id] ) || get_user_health(id) <= 0 || get_user_godmode(id) ) return PLUGIN_HANDLED;
	
	static property[5];
	static block_type;
	block_type = entity_get_int(ent, EV_INT_body);
	if(block_type == BUNNYHOPDMG) property = "5";
	else GetProperty(ent, 1, property);
	
	fakedamage(id, "Damage Block", str_to_float(property), DMG_CRUSH);
	if(block_type == BUNNYHOPDMG) property = "0.5";
	else GetProperty(ent, 2, property);
	g_next_damage_time[id] = gametime + str_to_float(property);
	
	return PLUGIN_HANDLED;
}
ActionArmor(id, ent)
{
	new Float:gametime = get_gametime();
	if ( !( gametime >= g_next_heal_time[id] ) ) return PLUGIN_HANDLED;
	
	new health = get_user_armor(id);
	if ( health >= 255 ) return PLUGIN_HANDLED;
	
	static property[5];
	
	GetProperty(ent, 1, property);
	health += str_to_num(property);
	set_user_armor(id, min(255, health));
	
	GetProperty(ent, 2, property);
	g_next_heal_time[id] = gametime + str_to_float(property);
	
	return PLUGIN_HANDLED;
}
ActionLight(id)
{
	new origin[3];
	get_user_origin(id, origin);
				    
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY,origin);
	write_byte(TE_DLIGHT);
	write_coord(origin[0]);
	write_coord(origin[1]); 
	write_coord(origin[2]);
	if ( get_user_team ( id ) == 1 ) {              
		write_byte(20);
		write_byte(255);
		write_byte(0);
		write_byte(0);
		write_byte(255);
		write_byte(50); 
		message_end();
	}
	if ( get_user_team ( id ) == 2 ) { 
		write_byte(20);
		write_byte(0);
		write_byte(0);
		write_byte(255);
		write_byte(255);
		write_byte(50); 
		message_end();
	}
	if ( get_user_team ( id ) == 3 ) {
		write_byte(30);
		write_byte(69);
		write_byte(69);
		write_byte(69);
		write_byte(255);
		write_byte(50); 
		message_end();
	}
	return PLUGIN_HANDLED;
}

ActionMikstura(id, ent)
{
	if(!MiksturaUsed[id])
	{
		new health = get_user_health(id);

		static property[5];
	        emit_sound(id, CHAN_STATIC, g_sound_mikstura, 1.0, ATTN_NORM, 0, PITCH_NORM);

		GetProperty(ent, 1, property);
		MiksturaUsed[id] = true;
		health += str_to_num(property);
		set_user_health(id, health);
	}
	else
	{
		set_hudmessage(0, 255, 0, 0.01, 0.18, 0, 0.0, 1.0, 0.25, 0.25, 2);
		show_hudmessage(id, "Mikstura: Raz na runde");
	}
	return PLUGIN_HANDLED;
}

ActionGps(id)
{
	new Float:gametime = get_gametime();
	if ( !( gametime >= next_use_gps[id] ) ) return PLUGIN_HANDLED;
	{
		set_task(0.1, "draw", id);
		
	}
	
	next_use_gps[id]=gametime + 2.0;

	return PLUGIN_HANDLED;
}
public draw(idd)
{
	new vec_shower[3], vec_victim[3];
	for(new id=0; id<=32; id++)
	{
		if(is_user_connected(id) && is_user_alive(id) && idd!=id)
		{
			//if(get_user_team(id)!=get_user_team(idd))
			get_user_origin(id, vec_shower, 0);
			get_user_origin(idd, vec_victim, 0);
			
			message_begin(MSG_ALL, SVC_TEMPENTITY, {0, 0, 0}, id);
			write_byte(0);
			write_coord(vec_shower[0]);
			write_coord(vec_shower[1]);
			write_coord(vec_shower[2]);
			write_coord(vec_victim[0]);
			write_coord(vec_victim[1]);
			write_coord(vec_victim[2]);
			write_short(g_sprite_beam);
			write_byte(0);
			write_byte(0);
			write_byte(20);			// x 0.1
			write_byte(3);			// x 0.1
			write_byte(0);
			if (get_user_team(id) == 1)
			{
				write_byte(255);
				write_byte(50);
				write_byte(50);
			}
			else
			{
				write_byte(100);
				write_byte(100);
				write_byte(255);
			}
			write_byte(200);
			write_byte(2);
			message_end();
			
		}
	}
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
ActionZarazenie(id)
{
	if(!gbUsed[id])
	{
		if(is_user_alive(id))
		{
			zarazenie[id]=true;
			if(zarazenie[id]==true)
			{
				client_print(id, print_chat, "[EasyBlock] Zostales zarazony.");
				set_task(1.0,"zabijmnie",id);
			}
		}
	}
	else
	{
		client_print(id , print_center , "Szybko! Szukaj Antidotum!");
	}
	gbUsed[id]=true;
}
ActionAntidotum(id)
{
	if(zarazenie[id]==true)
	{
		zarazenie[id]=false;
		gbUsed[id]=false;
		Display_Fade(id, 50, 200, 50);
		client_print(id, print_chat, "[EasyBlock] Znalazles antidotum.");
	}
}
public zabijmnie(id,ent)
{
	if(zarazenie[id]==true)
	{
		if(is_user_alive(id))
		{
			new hp = get_user_health(id);
			set_user_health(id, hp - 5);
			Display_Fade(id, 200,50,50);
			set_task(1.0,"zabijmnie",id);
		}
	}
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
	if ( task_exists(task_id) ) remove_task(task_id);
	else{
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
	if ( task_exists(TASK_SOLIDNOT + ent) || task_exists(TASK_SOLID + ent) ) return PLUGIN_HANDLED;
	new CsTeams:team = block_terrorists ? CS_TEAM_T : CS_TEAM_CT;
	if ( cs_get_user_team(id) == team ) TaskSolidNot(TASK_SOLIDNOT + ent);

	return PLUGIN_HANDLED;
}
ActionVip(id, ent)
{
	if ( get_user_flags(id) & ADMIN_LEVEL_F ) TaskSolidNot(TASK_SOLIDNOT + ent);	
}

ActionNoSlowDown(id)
{
	g_no_slow_down[id] = true;
	
	new task_id = TASK_NOSLOWDOWN + id;
	if ( task_exists(task_id) ) remove_task(task_id);
	
	set_task(0.1, "TaskSlowDown", task_id);
}

ActionPrzekrety(id)
{
	new Float:Random_Float[3]
	for(new i = 0; i < 3; i++) Random_Float[i] = random_float(-50.0, 50.0)
	Punch_View(id, Random_Float)
}
stock Punch_View(id, Float:ViewAngle[3])
{
	entity_set_vector(id, EV_VEC_punchangle, ViewAngle)
}
ActionDelayedBhop(ent)
{
	if ( task_exists(TASK_SOLIDNOT + ent) || task_exists(TASK_SOLID + ent) ) return PLUGIN_HANDLED;
	
	static property1[5];
	GetProperty(ent, 1, property1);
	set_task(str_to_float(property1), "TaskSolidNot", TASK_SOLIDNOT + ent);
	
	return PLUGIN_HANDLED;
}

ActionInvincibility(id, ent)
{
	new Float:gametime = get_gametime();
	if ( !( gametime >= g_invincibility_next_use[id] ) ){
		if ( !g_has_hud_text[id] )
		{
			set_hudmessage(255, 150, 0, 0.01, 0.18, 0, 0.0, 1.0, 0.25, 0.25, 2);
			ShowSyncHudMsg(id, g_HudSyncObj,  "^nNiesmiertelnosc^nNastepne uzycie za %.1f", g_invincibility_next_use[id] - gametime);
		}
	
		return PLUGIN_HANDLED;
	}
	static property[5];
	entity_set_float(id, EV_FL_takedamage, DAMAGE_NO);
	
	if ( gametime >= g_stealth_time_out[id] ){
		set_user_rendering(id, kRenderFxGlowShell, 0, 127, 255, kRenderNormal, 16);
	}
	emit_sound(id, CHAN_STATIC, g_sound_invincibility, 1.0, ATTN_NORM, 0, PITCH_NORM);
	
	static Float:time_out;
	GetProperty(ent, 1, property);
	if(entity_get_int(ent, EV_INT_body) == RAND) property = "10";
	time_out = str_to_float(property);
	
	set_task(time_out, "TaskRemoveInvincibility", TASK_INVINCIBLE + id, g_blank, 0, g_a, 1);
	
	GetProperty(ent, 2, property);
	if(entity_get_int(ent, EV_INT_body) == RAND) property = "50";
	g_invincibility_time_out[id] = gametime + time_out;
	g_invincibility_next_use[id] = gametime + time_out + str_to_float(property);
	
	return PLUGIN_HANDLED;
}
ActionKamuflarz(id, ent)
{
	new Float:gametime = get_gametime();
	if ( !( gametime >= g_kamuflarz_next_use[id] ) ){
		if ( !g_has_hud_text[id] ){
			set_hudmessage(255, 150, 0, 0.01, 0.18, 0, 0.0, 1.0, 0.25, 0.25, 2);
			ShowSyncHudMsg(id, g_HudSyncObj,  "^nKamuflarz^nNastepne uzycie za %.1f", g_kamuflarz_next_use[id] - gametime);
		}
		return PLUGIN_HANDLED;
	}

	static property[5];
	
	if(cs_get_user_team(id) == CS_TEAM_T){
		cs_set_user_model(id,  "gign");
	}
	else if(cs_get_user_team(id) == CS_TEAM_CT){
		cs_set_user_model(id,  "leet");
	}
	client_cmd(0, "cl_minmodels 0");
	emit_sound(id, CHAN_STATIC, gszCamouflageSound, 1.0, ATTN_NORM, 0, PITCH_NORM);
	
	static Float:time_out;
	GetProperty(ent, 1, property);
	time_out = str_to_float(property);
	if(entity_get_int(ent, EV_INT_body) == RAND) property = "10";
	set_task(time_out, "TaskRemoveKamuflarz", TASK_KAMUFLARZ+ id, g_blank, 0, g_a, 1);
	
	GetProperty(ent, 2, property);
	if(entity_get_int(ent, EV_INT_body) == RAND) property = "50";
	g_kamuflarz_time_out[id] = gametime + time_out;
	g_kamuflarz_next_use[id] = gametime + time_out + str_to_float(property);
	
	return PLUGIN_HANDLED;
}

ActionStealth(id, ent)
{
	new Float:gametime = get_gametime();
	if ( !( gametime >= g_stealth_next_use[id] ) ){
		if ( !g_has_hud_text[id] ){
			set_hudmessage(255, 150, 0, 0.01, 0.18, 0, 0.0, 1.0, 0.25, 0.25, 2);
			ShowSyncHudMsg(id, g_HudSyncObj,  "^nNiewidzialnosc^nNastepne uzycie za %.1f", g_stealth_next_use[id] - gametime);
		}
		
		return PLUGIN_HANDLED;
	}
	static property[5];
	set_user_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderTransColor, 0);
	
	emit_sound(id, CHAN_STATIC, g_sound_stealth, 1.0, ATTN_NORM, 0, PITCH_NORM);
	
	g_block_status[id] = true;
	
	static Float:time_out;
	GetProperty(ent, 1, property);
	if(entity_get_int(ent, EV_INT_body) == RAND) property = "10";
	time_out = str_to_float(property);
	
	set_task(time_out, "TaskRemoveStealth", TASK_STEALTH + id, g_blank, 0, g_a, 1);
	
	GetProperty(ent, 2, property);
	if(entity_get_int(ent, EV_INT_body) == RAND) property = "50";
	g_stealth_time_out[id] = gametime + time_out;
	g_stealth_next_use[id] = gametime + time_out + str_to_float(property);
	
	return PLUGIN_HANDLED;
}
ActionWeapon(id, ent) 
{
	static property[5];
	GetProperty(ent, 1, property);
    
	numer = str_to_num(property);
	new szWeapon[32]; 
	format(szWeapon, 31, "weapon_%s", g_bronie[numer]); 
	
	
	new iWeapons[32], iNum;
	if(cs_get_user_team(id)==CS_TEAM_T){
		if(!gbUsedWeapon[id][str_to_num(property)]){		
			if(!(get_user_weapons(id, iWeapons, iNum) & (1<<get_weaponid(szWeapon)))){
				GetProperty(ent, 2, property);
				give_item(id, szWeapon);
				new ammo = str_to_num(property);
				cs_set_weapon_ammo(find_ent_by_owner(-1, szWeapon, id), ammo);
				if( ammo==1) client_print(id, print_chat, "[EasyBlock] Dostales: %s z %d nabojem", g_bronie[numer], ammo); 
				else client_print(id, print_chat, "[EasyBlock] Dostales: %s z %d nabojami", g_bronie[numer], ammo); 
				GetProperty(ent, 1, property);
				gbUsedWeapon[id][str_to_num(property)] = true;
				new name[33];
				get_user_name(id, name, 32);
				set_hudmessage(255, 212, 0, -1.0, 0.4, 0, 6.0, 4.0);
				show_hudmessage(0, "%s dorwal %s z %d ammo!",name,g_bronie[numer],ammo);
				emit_sound(id, CHAN_STATIC, gszWeapons, 1.0, ATTN_NORM, 0, PITCH_NORM);
			}
		}
		else {
			set_hudmessage(255, 150, 0, 0.01, 0.18, 0, 0.0, 1.0, 0.25, 0.25, 2);
			show_hudmessage(id, "Juz raz wziales %s!", g_bronie[numer]); 
		}
	}
	else{
		set_hudmessage(255, 150, 0, 0.01, 0.18, 0, 0.0, 1.0, 0.25, 0.25, 2);
		show_hudmessage(id, "Dostaniesz jak na nia zasluzysz Psie!"); 
	}

	return PLUGIN_HANDLED; 
}  
ActionBoom(id, ent)
{
	new ile=0;
	new ppos[3],ppos2[3], Float:ppos3[3];
	
	get_user_origin(id, ppos);
	ppos3[0] = float(ppos[0]);
	ppos3[1] = float(ppos[1]);
	ppos3[2] = float(ppos[2]);
	create_blast(ppos3);
	static property[5];
	GetProperty(ent, 1, property);
	if(entity_get_int(ent, EV_INT_body) == RAND) property = "500";
	for (new i = 1; i <= 32; ++i){
		if (is_user_alive(i))
		{
			if(get_user_team(i) != get_user_team(id)){
				get_user_origin(i, ppos2);
				new dmg = str_to_num(property)-(get_distance(ppos, ppos2)/2);
				if(dmg>0){
					new Float:pAim[3];
					velocity_by_aim(id, dmg*15, pAim);
					pAim[2] =  random_float(300.0, 900.0);	
					pAim[1] =  random_float(-800.0, 800.0);	
					pAim[0] =  random_float(-800.0, 800.0);	
					entity_set_vector(id, EV_VEC_velocity, pAim);
					entity_set_int(id, EV_INT_gaitsequence, 6);   
					if(get_user_health(i)>dmg) fakedamage(i, "wybuch kamikadze!", dmg+0.0, DMG_BLAST);
					else user_kill(i);
				}
				if(!is_user_alive(i)) ile++;
			}


		}

	}
	emit_sound(0, CHAN_STATIC, gszNukeExplosion, 1.0, ATTN_NORM, 0, PITCH_NORM);
	new szPlayerName[32];
	get_user_name(id, szPlayerName, 32);
	set_hudmessage(255, 255, 0, -1.0, 0.35, 0, 6.0, 10.0, 1.0, 1.0);
	show_hudmessage(0, "%s popelnil samobojstwo zabijajac przy tym %d osob%s%s!", szPlayerName, ile, ile==1?"e":"", ile>1?"y":"");
	set_user_frags(id, get_user_frags(id)+ile);
	user_kill(id,1);
}
ActionMuza(id, ent)
{
	new iii = entity_get_int(ent, EV_INT_iuser4);
	if(floatround(halflife_time(), floatround_floor) >= iii)
	{
		new i = random_num(1, 13);
		new Float:czas = 10.0;
		new nazwa[67];
		switch(i){
			case 1: czas = 15.0;
			case 2: czas = 26.0;
			case 3: czas = 19.0;
			case 4: czas = 23.0;
			case 5: czas = 16.0;
			case 6: czas = 17.0;
			case 7: czas = 25.0;
			case 8: czas = 17.0;
			case 9: czas = 25.0;
			case 10: czas = 16.0;	
			case 11: czas = 15.0;
			case 12: czas = 14.0;
			case 13: czas = 15.0;
		}
		switch(i){
			case 1: format(nazwa, 66, "Flux Pavilion - Louder", i);
			case 2: format(nazwa, 66, "SKRILLEX - Make it Bun Dem (Culprate Remix)", i);
			case 3: format(nazwa, 66, "SKRILLEX - Firs of The Year (Equinox)", i);
			case 4: format(nazwa, 66, "Chwytak ft. DJ Wiktor - Napijmy Sie Gorzoly", i);
			case 5: format(nazwa, 66, "Avicii - Levels (SKRILLEX Remix)", i);
			case 6: format(nazwa, 66, "Flo Rida - Whistle", i);
			case 7: format(nazwa, 66, "Power Play - Skok w Bok", i);
			case 8: format(nazwa, 66, "Unknown,sorry :(", i);
			case 9: format(nazwa, 66, "Drossel - To Ten Klub (Max Peace Club Mix) ", i);
			case 10: format(nazwa, 66, "Power Play - Zawsze Cos", i);	
			case 11: format(nazwa, 66, "DJ Kuba & NE!TAN feat. Heidi Anne - Another Day (Video Edit)", i);
			case 12: format(nazwa, 66, "Lara Fabian - I Will Love Again (Baart'B 'Love' Bootleg)", i);
			case 13: format(nazwa, 66, "Ewelina Lisowska - W Strone Slonca (Max Peace Remix Edit)", i);
		}
		new nazwa2[36];
		format(nazwa2, 35, "EB-Sound/Entasia/Kwiecien/%d.wav", i);
		ColorChat(id, GREEN, "Teraz leci:^x03 %s", nazwa);
		entity_set_int(ent, EV_INT_iuser4, floatround(halflife_time()+czas, floatround_floor)+2);
		emit_sound ( id, 0,nazwa2, 0.6, 0.8,0, 100 );
		new Float:origin[3];
		pev(id, pev_origin, origin);
		origin[2]+=35.0;
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
		write_byte(TE_SPRITE);
		write_coord_f(origin[0]);
		write_coord_f(origin[1]);
		write_coord_f(origin[2]);
		write_short(pSprite);
		write_byte(10);
		write_byte(255);
		message_end();
	}
}
ActionBootsOfSpeed(id, ent)
{
	new Float:gametime = get_gametime();
	if ( !( gametime >= g_boots_of_speed_next_use[id] ) ){
		if ( !g_has_hud_text[id] ){
			set_hudmessage(255, 150, 0, 0.01, 0.18, 0, 0.0, 1.0, 0.25, 0.25, 2);
			ShowSyncHudMsg(id, g_HudSyncObj,  "^nButy predkosci^nNastepne uzycie za %.1f", g_boots_of_speed_next_use[id] - gametime);
		}
		return PLUGIN_HANDLED;
	}
	static property[5];
	
	GetProperty(ent, 3, property);
	if(entity_get_int(ent, EV_INT_body) == RAND) property = "320";
	entity_set_float(id, EV_FL_maxspeed, str_to_float(property));
	
	g_boots_of_speed[id] = ent;
	
	emit_sound(id, CHAN_STATIC, g_sound_boots_of_speed, 1.0, ATTN_NORM, 0, PITCH_NORM);
	
	static Float:time_out;
	GetProperty(ent, 1, property);
	if(entity_get_int(ent, EV_INT_body) == RAND) property = "10";
	time_out = str_to_float(property);
	set_task(time_out, "TaskRemoveBootsOfSpeed", TASK_BOOTSOFSPEED + id, g_blank, 0, g_a, 1);
	
	GetProperty(ent, 2, property);
	if(entity_get_int(ent, EV_INT_body) == RAND) property = "50";
	g_boots_of_speed_time_out[id] = gametime + time_out;
	g_boots_of_speed_next_use[id] = gametime + time_out + str_to_float(property);
	
	return PLUGIN_HANDLED;
}
ActionAwp(id, ent)
{
	new Float:gametime = get_gametime();
	if ( !( gametime >= g_awp_next_use[id] ) ){
		if ( !g_has_hud_text[id] ){
			set_hudmessage(255, 150, 0, 0.01, 0.18, 0, 0.0, 1.0, 0.25, 0.25, 2);
			ShowSyncHudMsg(id, g_HudSyncObj,  "^nBron Awp^nNastepne uzycie za %.1f", g_awp_next_use[id] - gametime);
		}
	
		return PLUGIN_HANDLED;
	}
	new name[33];
	get_user_name(id, name, 32);
	set_hudmessage(255, 212, 0, -1.0, 0.4, 0, 6.0, 4.0);
	show_hudmessage(0, "%s dorwal AWP z 1 ammo! Spierdalac!!",name);
	
	give_item(id, "weapon_awp");
	cs_set_weapon_ammo(get_weapon_id(id, "weapon_awp"),  1);
	cs_set_user_bpammo(id, CSW_AWP, 0);
	
	emit_sound(id, CHAN_STATIC, gszWeapons, 1.0, ATTN_NORM, 0, PITCH_NORM);
	
	static property[5];
	GetProperty(ent, 2, property);
	if(entity_get_int(ent, EV_INT_body) == RAND) property = "50";
	g_awp_next_use[id] = gametime + str_to_float(property);
	return PLUGIN_HANDLED;
}
ActionGranat(id, ent, jaki)
{
	new Float:nextuse;
	new nazwa[20];
	new Float:gametime = get_gametime();
	static property[5];
	GetProperty(ent, 2, property);
	if(entity_get_int(ent, EV_INT_body) == RAND) property = "50";
	
	if(jaki == 0){
		nextuse =g_he_next_use[id]; 
		nazwa = "HE";
	}
	else if(jaki==1){
		nextuse =g_he2_next_use[id]; 
		nazwa = "Kurczak";
	}
	else {
		nextuse =g_smoke_next_use[id]; 
		nazwa = "Smoke";
	}
	if ( !( gametime >= nextuse ) ){
		if ( !g_has_hud_text[id] ){
			set_hudmessage(255, 150, 0, 0.01, 0.18, 0, 0.0, 1.0, 0.25, 0.25, 2);
			ShowSyncHudMsg(id, g_HudSyncObj,  "^nGranat %s^nNastepne uzycie za %.1f", nazwa,nextuse - gametime);
		}
		return PLUGIN_HANDLED;
	}
	if(jaki==0){
		g_he_next_use[id]= gametime + str_to_float(property);
		ColorChat(id, GREEN, "[IS.eu]^3 Dostales:^4 Hejdza.");
                emit_sound(id, CHAN_STATIC, g_sound_granat, 1.0, ATTN_NORM, 0, PITCH_NORM);
                if(cs_get_user_bpammo(id, CSW_HEGRENADE) > 0){
			cs_set_user_bpammo(id, CSW_HEGRENADE, cs_get_user_bpammo(id, CSW_HEGRENADE)+1);
		} 
		else {
			give_item(id, "weapon_hegrenade");			
		}
	}
	else if(jaki==1){
		kurczak[id]++;
		g_he2_next_use[id]= gametime + str_to_float(property);
		emit_sound(id, CHAN_STATIC, g_sound_kurczak, 1.0, ATTN_NORM, 0, PITCH_NORM);
                if(cs_get_user_bpammo(id, CSW_HEGRENADE) > 0){
			cs_set_user_bpammo(id, CSW_HEGRENADE, cs_get_user_bpammo(id, CSW_HEGRENADE)+1);
		} 
		else {
			give_item(id, "weapon_hegrenade");			
		}
	}
	else if(jaki==2){
		if(cs_get_user_bpammo(id, CSW_SMOKEGRENADE) > 0){
			cs_set_user_bpammo(id, CSW_SMOKEGRENADE, cs_get_user_bpammo(id, CSW_SMOKEGRENADE)+1);
		}
		else {
			give_item(id, "weapon_smokegrenade");
		}
		g_smoke_next_use[id]= gametime + str_to_float(property);
	}
	return PLUGIN_HANDLED;
}
ActionNoc(id,ent)
{
	new Float:gametime = get_gametime();
	if ( !( gametime >= gfNocNextUse[id] ) ){
		if ( !g_has_hud_text[id] ){
			set_hudmessage(255, 150, 0, 0.01, 0.18, 0, 0.0, 1.0, 0.25, 0.25, 2);
			ShowSyncHudMsg(id, g_HudSyncObj,  "^nCiemnosc^nNastepne uzycie za %.1f", gfNocNextUse[id] - gametime);
		}
		return PLUGIN_HANDLED;
	}
	static property[5];
	static Float:time_out;
	GetProperty(ent, 1, property);
	if(entity_get_int(ent, EV_INT_body) == RAND) property = "15";
	time_out = str_to_float(property);
	set_task(time_out, "taskNocRemove", TASK_NOC + id, g_blank, 0, g_a, 1);
	set_lights("b");
	emit_sound(id, CHAN_STATIC, g_sound_noc, 1.0, ATTN_NORM, 0, PITCH_NORM);
        new name[32];
	get_user_name(id, name, 31);
        set_hudmessage(200,15,200, -1.0, 0.30, 2, 32.0, 13.0, 0.01, 0.1, 1);
        show_hudmessage(0, "%s Imprezuje!!", name);

	GetProperty(ent, 2, property);
	if(entity_get_int(ent, EV_INT_body) == RAND) property = "60";
	gfNocTimeOut[id] = gametime + time_out;
	gfNocNextUse[id] = gametime + time_out + str_to_float(property);
	
	return PLUGIN_HANDLED;
}

public taskNocRemove(id)
{
	id -= TASK_NOC;
	
	set_lights("m");
	set_user_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderNormal, 16);
}

ActionRand(id, ent)
{
	new Float:gametime = get_gametime();
	if ( !( gametime >= g_rand_next_use[id] ) ){
		if ( !g_has_hud_text[id] ){
			set_hudmessage(255, 150, 0, 0.01, 0.18, 0, 0.0, 1.0, 0.25, 0.25, 2);
			ShowSyncHudMsg(id, g_HudSyncObj,  "^nLosowy block^nNastepne uzycie za %.1f", g_rand_next_use[id] - gametime);
		}
		return PLUGIN_HANDLED;
	}

	new los = random_num(1, 10);
	
	if(los==1) g_slap_times[id] = 10;
	else if(los==2) ActionStealth(id, ent);
	else if(los==3) ActionBoom(id, ent);
	else if(los==4) ActionInvincibility(id, ent);
	else if(los==5) ActionKamuflarz(id, ent);
	else if(los==6) ActionBootsOfSpeed(id, ent);
	else if(los==7) ActionGranat(id, ent, 0);
	else if(los==8) ActionGranat(id, ent, 1);
	else if(los==9) ActionGranat(id, ent, 2);
	else if(los==10) ActionXP(id,ent);
	
	g_rand_next_use[id] = gametime + 40.0;
	return PLUGIN_HANDLED;
}
ActionXP(id, ent)
{
	new Float:gametime = get_gametime();
	if ( !( gametime >= g_xp_next_use[id] ) ){
		if ( !g_has_hud_text[id] ){
			set_hudmessage(255, 150, 0, 0.01, 0.18, 0, 0.0, 1.0, 0.25, 0.25, 2);
			ShowSyncHudMsg(id, g_HudSyncObj,  "^nExperience^nNastepne uzycie za %.1f", g_xp_next_use[id] - gametime);
		}
		return PLUGIN_HANDLED;
	}
	static property[5];
	new name[33];
	get_user_name(id, name, 32); 
	
	static Float:time_out;
	if(entity_get_int(ent, EV_INT_body) == RAND) property = "1";
	if(get_cvar_num("bm_budowanie") == 0)
	{
		new players[32], num;
		get_players(players, num, "ch");
		if(num<1) client_print(0, print_chat, "[EasyBlock] Musi byc co najmniej 2 graczy aby mozna bylo brac EXP.");
		else
		{
			if(get_user_flags(id) & ADMIN_LEVEL_F)
			{
				GetProperty(ent, 1, property);
				new vipexp=str_to_num(property)+15;
				server_cmd("przekaz_xp ^"%s^" ^"%d^"", name, vipexp);
				client_print(0, print_chat, "[EasyBlock] Gracz %s, zdobyl %d EXP'a za bycie VIP`em.", name, vipexp);         set_hudmessage(0, 255, 0, -1.0, 0.20, 0, 6.0, 12.0, 0.0, 1.0, 3);
                                show_hudmessage(0, "Gracz %s Zdobyl %d EXP'a na bloku!", name, vipexp);
				emit_sound(id, CHAN_STATIC, gszXpSound, 1.0, ATTN_NORM, 0, PITCH_NORM);
			}
			else
			{
				GetProperty(ent, 1, property);
				server_cmd("przekaz_xp ^"%s^" ^"%s^"", name, property);
				client_print(0, print_chat, "[EasyBlock] Gracz %s, zdobyl %s EXP'a na bloku.", name, property);
                                show_hudmessage(0, "Gracz %s Zdobyl %s EXP'a na bloku!", name, property);
				emit_sound(id, CHAN_STATIC, gszXpSound, 1.0, ATTN_NORM, 0, PITCH_NORM);
			}
		}
	}
	else client_print(0, print_chat, "[EasyBlock] Graczu %s, na pewno nie dostaniesz XP gdy sa budowane mapy!", name);
	time_out = str_to_float(property);
	
	GetProperty(ent, 2, property);
	if(entity_get_int(ent, EV_INT_body) == RAND) property = "60";
	g_xp_time_out[id] = gametime + time_out;
	g_xp_next_use[id] = gametime + time_out + str_to_float(property);
	
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
		if ( !is_user_alive(player) || player == id || cs_get_user_team(id) == cs_get_user_team(player) ) continue;
		user_kill(player, 1);
	}
	while ( player );
	
	entity_set_vector(id, EV_VEC_origin, tele_origin);
	
	static Float:velocity[3];
	entity_get_vector(id, EV_VEC_velocity, velocity);
	velocity[2] = floatabs(velocity[2]);
	entity_set_vector(id, EV_VEC_velocity, velocity);
	emit_sound(id, CHAN_STATIC, gszTeleportSound, 1.0, ATTN_NORM, 0, PITCH_NORM);
	return PLUGIN_HANDLED;
}

public TaskSolidNot(ent)
{
	ent -= TASK_SOLIDNOT;
	
	if ( !is_valid_ent(ent) || entity_get_int(ent, EV_INT_iuser2) ) return PLUGIN_HANDLED;
	
	entity_set_int(ent, EV_INT_solid, SOLID_NOT);
	set_rendering(ent, kRenderFxNone, 255, 255, 255, kRenderTransAdd, 25);
	set_task(1.0, "TaskSolid", TASK_SOLID + ent);
	
	return PLUGIN_HANDLED;
}
stock get_weapon_id(id, const weapon[])
{
	new ent = -1;
	
	while((ent = find_ent_by_class(ent, weapon)) != 0)
	{
		if(id == entity_get_edict(ent, EV_ENT_owner))
		return ent;
	}
	
	return 0;
}
public TaskSolid(ent)
{
	ent -= TASK_SOLID;
	
	if ( !IsBlock(ent) ) return PLUGIN_HANDLED;
	
	entity_set_int(ent, EV_INT_solid, SOLID_BBOX);
	
	if ( entity_get_int(ent, EV_INT_iuser1) > 0 ){
		GroupBlock(0, ent);
	}
	else{
		static property3[5];
		GetProperty(ent, 3, property3);
		new block_type = entity_get_int(ent, EV_INT_body);
		new transparency = str_to_num(property3);
		if ( !transparency || transparency == 255 ){

			SetBlockRendering(ent, g_render[block_type], g_red[block_type], g_green[block_type], g_blue[block_type], g_alpha[block_type]);
		}
		else{
			SetBlockRendering(ent, TRANSALPHA, 255, 255, 255, transparency);
			if(transparency==1) set_rendering(ent, kRenderFxPulseSlow, g_red[block_type], g_green[block_type], g_blue[block_type],kRenderTransAlpha, 150);
			if(transparency==2) set_rendering(ent, kRenderFxPulseFastWide, g_red[block_type], g_green[block_type], g_blue[block_type],kRenderTransAlpha, 150);
			if(transparency==3) set_rendering(ent, kRenderFxStrobeFast, g_red[block_type], g_green[block_type], g_blue[block_type],kRenderTransAlpha, 150);
			if(transparency==4) set_rendering(ent, kRenderFxHologram, g_red[block_type], g_green[block_type], g_blue[block_type],kRenderNormal, g_alpha[block_type]);
			if(transparency==5) set_rendering(ent, kRenderFxHologram, g_red[block_type], g_green[block_type], g_blue[block_type],kRenderTransAdd, g_alpha[block_type]);
			if(transparency==6) set_rendering(ent, kRenderFxHologram, g_red[block_type], g_green[block_type], g_blue[block_type], kRenderTransAlpha, 200);
			if(transparency==7) set_rendering(ent, kRenderFxGlowShell, 255, 0, 0, kRenderNormal, 20);
			if(transparency==8) set_rendering(ent, kRenderFxGlowShell, 0, 255, 0, kRenderNormal, 20);
			if(transparency==9) set_rendering(ent, kRenderFxGlowShell, 255, 0, 0, kRenderTransAlpha, 200);/////////////////////////
			if(transparency==10) set_rendering(ent, kRenderFxGlowShell, 0, 255, 0, kRenderTransAlpha, 200);
			if(transparency==11) set_rendering(ent, kRenderFxGlowShell, 0, 0, 255, kRenderTransAlpha, 200);
			if(transparency==12) set_rendering(ent, kRenderFxGlowShell, 255, 0, 0, kRenderTransAlpha, 150);
			if(transparency==13) set_rendering(ent, kRenderFxGlowShell, 0, 255, 0, kRenderTransAlpha, 150);
			if(transparency==14) set_rendering(ent, kRenderFxGlowShell, 0, 0, 255, kRenderTransAlpha, 150);
			if(transparency==15) set_rendering(ent, kRenderFxGlowShell, 255, 0, 255, kRenderNormal, 20);///////////////////////
			if(transparency==16) set_rendering(ent, kRenderFxGlowShell, 150, 150, 0, kRenderNormal, 20);
			if(transparency==17) set_rendering(ent, kRenderFxGlowShell, 0, 0, 255, kRenderNormal, 20);
			if(transparency==18) set_rendering(ent, kRenderFxGlowShell, 255, 150, 0, kRenderNormal, 20);
			if(transparency==19) set_rendering(ent, kRenderFxGlowShell, 255, 255, 255, kRenderNormal, 20);
			if(transparency==20) set_rendering(ent, kRenderFxGlowShell, 0, 150, 150, kRenderNormal, 20);
		}
	}
	
	return PLUGIN_HANDLED;
}

public TaskNotOnIce(id)
{
	id -= TASK_ICE;
	g_ice[id] = false;
	
	if ( !g_alive[id] ) return PLUGIN_HANDLED;
	if ( g_boots_of_speed[id] ){
		static block, property3[5];
		block = g_boots_of_speed[id];
		GetProperty(block, 3, property3);
		
		entity_set_float(id, EV_FL_maxspeed, str_to_float(property3));
	}
	else ResetMaxspeed(id);
	
	entity_set_float(id, EV_FL_friction, 1.0);
	
	return PLUGIN_HANDLED;
}

public TaskNotInHoney(id)
{
	id -= TASK_HONEY;
	
	g_honey[id] = 0;
	
	if ( !g_alive[id] ) return PLUGIN_HANDLED;
	
	if ( g_boots_of_speed[id] ){
		static block, property3[5];
		block = g_boots_of_speed[id];
		GetProperty(block, 3, property3);
		
		entity_set_float(id, EV_FL_maxspeed, str_to_float(property3));
	}
	else ResetMaxspeed(id);
	
	return PLUGIN_HANDLED;
}

public TaskSlowDown(id)
{
	id -= TASK_NOSLOWDOWN;
	g_no_slow_down[id] = false;
}
public TaskRemoveKamuflarz(id)
{
	id -= TASK_KAMUFLARZ;
	
	if ( !g_alive[id] ) return PLUGIN_HANDLED;
	
	if(cs_get_user_team(id) == CS_TEAM_CT){
		cs_set_user_model(id,  "gign");
	} 
	else if(cs_get_user_team(id) == CS_TEAM_T){
		cs_set_user_model(id,  "leet");
	}
	client_cmd(0, "cl_minmodels 0");
	
	return PLUGIN_HANDLED;
}

public TaskRemoveInvincibility(id)
{
	id -= TASK_INVINCIBLE;
	
	if ( !g_alive[id] ) return PLUGIN_HANDLED;
	
	if ( ( g_admin[id] || g_gived_access[id] ) && !g_godmode[id] || ( !g_admin[id] && !g_gived_access[id] ) && !g_all_godmode ){
		set_user_godmode(id, 0);
	}
	
	if ( get_gametime() >= g_stealth_time_out[id] ){
		set_user_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderNormal, 16);
	}
	
	return PLUGIN_HANDLED;
}

public TaskRemoveStealth(id)
{
	id -= TASK_STEALTH;
	if ( g_connected[id] ){
		if ( get_gametime() <= g_invincibility_time_out[id] ){
			set_user_rendering(id, kRenderFxGlowShell, 255, 255, 255, kRenderTransColor, 16);
		}
		else set_user_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderNormal, 255);
	
	}
	g_block_status[id] = false;
}

public TaskRemoveBootsOfSpeed(id)
{
	id -= TASK_BOOTSOFSPEED;
	
	g_boots_of_speed[id] = 0;
	
	if ( !g_alive[id] ) return PLUGIN_HANDLED;
	
	if ( g_ice[id] ){
		entity_set_float(id, EV_FL_maxspeed, 400.0);
	}
	else if ( g_honey[id] ){
		static block, property1[5];
		block = g_honey[id];
		GetProperty(block, 1, property1);
		entity_set_float(id, EV_FL_maxspeed, str_to_float(property1));
	}
	else ResetMaxspeed(id);
	
	return PLUGIN_HANDLED;
}

public TaskSpriteNextFrame(params[])
{
	new ent = params[0];
	if ( !is_valid_ent(ent) ){
		remove_task(TASK_SPRITE + ent);
		return PLUGIN_HANDLED;
	}
	
	new frames = params[1];
	new Float:current_frame = entity_get_float(ent, EV_FL_frame);
	
	if ( current_frame < 0.0 || current_frame >= frames ){
		entity_set_float(ent, EV_FL_frame, 1.0);
	}
	else entity_set_float(ent, EV_FL_frame, current_frame + 1.0);
	
	return PLUGIN_HANDLED;
}

public MsgStatusValue()
{
	if ( get_msg_arg_int(1) == 2 && g_block_status[get_msg_arg_int(2)] ){
		set_msg_arg_int(1, get_msg_argtype(1), 1);
		set_msg_arg_int(2, get_msg_argtype(2), 0);
	}
}

public CmdAttack(id)
{
	if ( !IsBlock(g_grabbed[id]) ) return PLUGIN_HANDLED;
	
	if ( IsBlockInGroup(id, g_grabbed[id]) && g_group_count[id] > 1 ){
		static block;
		for ( new i = 0; i <= g_group_count[id]; ++i ){
			block = g_grouped_blocks[id][i];
			if ( !IsBlockInGroup(id, block) ) continue;
			if ( !IsBlockStuck(block) ) CopyBlock(block);
		}
	}
	else{
		if ( IsBlockStuck(g_grabbed[id]) )
		{
			BM_Print(id, "Nie mozesz ruszyc tego blocka!");
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
	if ( !IsBlock(g_grabbed[id]) ){
		DeleteTeleport(id, g_grabbed[id]);
		return PLUGIN_HANDLED;
	}
	
	if ( !IsBlockInGroup(id, g_grabbed[id]) || g_group_count[id] < 2 ){
		DeleteBlock(g_grabbed[id]);
		return PLUGIN_HANDLED;
	}
	static block;
	for ( new i = 0; i <= g_group_count[id]; ++i ){
		block = g_grouped_blocks[id][i];
		if ( !is_valid_ent(block) || !IsBlockInGroup(id, block) ) continue;
		DeleteBlock(block);
	}
	
	return PLUGIN_HANDLED;
}

public CmdRotate(id)
{		
	if ( !IsBlock(g_grabbed[id]) ) return PLUGIN_HANDLED;
	
	if ( !IsBlockInGroup(id, g_grabbed[id])|| g_group_count[id] < 2 ){
		RotateBlock(g_grabbed[id]);
		return PLUGIN_HANDLED;
	}
	static block;
	for ( new i = 0; i <= g_group_count[id]; ++i ){
		block = g_grouped_blocks[id][i];
		if ( !is_valid_ent(block) || !IsBlockInGroup(id, block) ) continue;
		
		RotateBlock(block);
	}
	return PLUGIN_HANDLED;
}

public CmdGrab(id)
{
	if ( !g_admin[id] && !g_gived_access[id] ){
		console_print(id, "Nie masz wymaganych uprawnien");
		return PLUGIN_HANDLED;
	}
	static ent, body;
	g_grab_length[id] = get_user_aiming(id, ent, body);
	
	new bool:is_block = IsBlock(ent);
	
	if ( !is_block && !IsTeleport(ent) && !IsLight(ent) ) return PLUGIN_HANDLED;
	
	new grabber = entity_get_int(ent, EV_INT_iuser2);
	if ( grabber && grabber != id ) return PLUGIN_HANDLED;
	
	if ( !is_block ){
		SetGrabbed(id, ent);
		return PLUGIN_HANDLED;
	}
	
	new player = entity_get_int(ent, EV_INT_iuser1);
	if ( player && player != id ){
		new player_name[32]; 
		get_user_name(player, player_name, charsmax(player_name));
		
		BM_Print(id, "^1%s3 aktualnie ma tego blocka (grupe)!", player_name);
		return PLUGIN_HANDLED;
	}
	
	SetGrabbed(id, ent);
	
	if ( g_group_count[id] < 2 ) return PLUGIN_HANDLED;
	
	static Float:grabbed_origin[3];
	
	entity_get_vector(ent, EV_VEC_origin, grabbed_origin);
	
	static block, Float:origin[3], Float:offset[3];
	for ( new i = 0; i <= g_group_count[id]; ++i ){
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
	static block_type;
	block_type = entity_get_int(ent, EV_INT_body);
	if(block_type == DEATHD){
		entity_set_int(ent, EV_INT_movetype, MOVETYPE_NONE);
	}
}

public CmdRelease(id)
{
	if ( !g_admin[id] && !g_gived_access[id] ){
		console_print(id, "Nie masz wymaganych uprawnien");
		return PLUGIN_HANDLED;
	}
	else if ( !g_grabbed[id] ){
		return PLUGIN_HANDLED;
	}
	if ( IsBlock(g_grabbed[id]) ){
		static block_type;
		block_type = entity_get_int(g_grabbed[id], EV_INT_body);
		if(block_type == DEATHD){
			new Float:floatt[3];
			new property2[5];
			GetProperty(g_grabbed[id], 2, property2);
			floatt[2] = str_to_float(property2);
			entity_set_int(g_grabbed[id], EV_INT_movetype, MOVETYPE_BOUNCE);
			drop_to_floor(g_grabbed[id]);
			entity_set_vector(g_grabbed[id], EV_VEC_velocity, floatt);
		}
		if ( IsBlockInGroup(id, g_grabbed[id]) && g_group_count[id] > 1 ){
			static i, block;
			
			new bool:group_is_stuck = true;
			
			for ( i = 0; i <= g_group_count[id]; ++i ){
				block = g_grouped_blocks[id][i];
				if ( IsBlockInGroup(id, block) ){
					entity_set_int(block, EV_INT_iuser2, 0);
					if ( group_is_stuck && !IsBlockStuck(block) ){
						group_is_stuck = false;
						break;
					}
				}
			}
			if ( group_is_stuck )
			{
				for ( i = 0; i <= g_group_count[id]; ++i ){
					block = g_grouped_blocks[id][i];
					if ( IsBlockInGroup(id, block) ) DeleteBlock(block);
				}
				
				BM_Print(id, "Grupa usunieta poniewaz blocki sa w ziemi!");
			}
		}
		else{
			if ( is_valid_ent(g_grabbed[id]) ){
				if ( IsBlockStuck(g_grabbed[id]) ){
					new bool:deleted = DeleteBlock(g_grabbed[id]);
					if ( deleted ) BM_Print(id, "Block skasowany poniewaz byl w ziemi!");
				}
				else entity_set_int(g_grabbed[id], EV_INT_iuser2, 0);
			}
		}
	}
	else if ( IsTeleport(g_grabbed[id]) ){
		entity_set_int(g_grabbed[id], EV_INT_iuser2, 0);
	}
	entity_set_string(id, EV_SZ_viewmodel, g_viewmodel[id]);
	
	g_grabbed[id] = 0;
	
	return PLUGIN_HANDLED;
}

public CmdMainMenu(id)
{
	if(get_cvar_num("bm_budowanie") > 0)
	{
		ShowMainMenu(id);
	}
	return PLUGIN_HANDLED;
}

ShowMainMenu(id)
{
	new menu[256+128], col1[3], col2[3];
	
	col1 = g_admin[id] || g_gived_access[id] ? "\r" : "\d";
	col2 = g_admin[id] || g_gived_access[id] ? "\w" : "\d";
	
	format(menu, charsmax(menu), "\r[%s] \yMenu Glowne^n^n", PLUGIN_PREFIX);
	format(menu, charsmax(menu), "%s\r1. \wMenu blockow^n", menu);
	format(menu, charsmax(menu), "%s\r2. \wMenu teleportow^n", menu);
	format(menu, charsmax(menu), "%s\r3. \wMenu swiatel^n", menu);
	format(menu, charsmax(menu), "%s\r4. \wMenu opcji^n", menu);
	format(menu, charsmax(menu), "%s\r5. \wMenu admina^n^n", menu);
	format(menu, charsmax(menu), "%s%s6. %sNoclip: %s^n", menu,col1,col2,g_noclip[id]?"\yOn":"\rOff");
	format(menu, charsmax(menu), "%s%s7. %sGodmode: %s^n^n", menu,col1,col2,g_godmode[id]?"\yOn":"\rOff");
	format(menu, charsmax(menu), "%s\r0. \wZamknij", menu);
	
	show_menu(id, g_keys_main_menu, menu, -1, "SCMMainMenu");
}

ShowBlockMenu(id)
{
	new menu[256+128], col1[3], col2[3], size[8];
	
	col1 = g_admin[id] || g_gived_access[id] ? "\r" : "\d";
	col2 = g_admin[id] || g_gived_access[id] ? "\w" : "\d";
	
	switch ( g_selected_block_size[id] ){
		case TINY:	size = "Small";
		case NORMAL:	size = "Normal";
		case LARGE:	size = "Large";
		case POLE:	size = "Pole";
	}
	
	
	format(menu, charsmax(menu),\
	g_block_menu,\
	PLUGIN_PREFIX,\
	g_block_names[g_selected_block_type[id]],\
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
	g_noclip[id] ? "\yOn" : "\rOff",\
	col1,\
	col2,\
	g_godmode[id] ? "\yOn" : "\rOff",\
	size,\
	col1,\
	col2);
	
	show_menu(id, g_keys_block_menu, menu, -1, "SCMBlockMenu");
}

ShowBlockSelectionMenu(id)
{
	new menu[256+128], title[42], entry[32], num;
	
	format(title, charsmax(title), "\r[%s] \yWybierz block: ^n^n", PLUGIN_PREFIX);
	add(menu, charsmax(menu), title);
	
	new start_block = ( g_block_selection_page[id] - 1 ) * 8;
	
	for ( new i = start_block; i < start_block + 8; ++i ){
		if ( i < TOTAL_BLOCKS ){
			num = ( i - start_block ) + 1;
			format(entry, charsmax(entry), "\r%d. \w%s^n", num, g_block_names[i]);
		}
		else format(entry, charsmax(entry), "^n");
		
		add(menu, charsmax(menu), entry);
	}
	
	if ( g_block_selection_page[id] < g_block_selection_pages_max ){
		add(menu, charsmax(menu), "^n\r9. \wWiecej");
	}
	else{
		add(menu, charsmax(menu), "^n");
	}
	add(menu, charsmax(menu), "^n\r0. \wWroc");
	
	show_menu(id, g_keys_block_selection_menu, menu, -1, "SCMBlockSelectionMenu");
}

ShowPropertiesMenu(id, ent)
{
	new menu[256+128], title[32], entry[64], property[5], line1[3], line2[3], line3[3], line4[3], num, block_type;
	
	block_type = entity_get_int(ent, EV_INT_body);
	
	format(title, charsmax(title), "\r[%s] \yUstawienia^n^n", PLUGIN_PREFIX);
	add(menu, charsmax(menu), title);
	
	if ( g_property1_name[block_type][0] )
	{
		GetProperty(ent, 1, property);
	
		if ( block_type == BUNNYHOP || block_type == NO_SLOW_DOWN_BUNNYHOP || block_type == BHICE	|| block_type == BUNNYHOPDMG || block_type == BHFLASH || block_type == BHGLASS )
		{
			format(entry, charsmax(entry), "\r1. \w%s: %s^n", g_property1_name[block_type], property[0] == '1' ? "\yOn" : "\rOff");
		}
		else if ( block_type == SLAP ){
		format(entry, charsmax(entry), "\r1. \w%s: \y%s^n", g_property1_name[block_type], property[0] == '3' ? "High" : property[0] == '2' ? "Medium" : "Low");
		}
		else format(entry, charsmax(entry), "\r1. \w%s: \y%s^n", g_property1_name[block_type], property);
	
		add(menu, charsmax(menu), entry);
	}
	else format(line1, charsmax(line1), "^n");
	
	if ( g_property2_name[block_type][0] )
	{
		if ( g_property1_name[block_type][0] ) num = 2;
		else num = 1;
		
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
	
	format(entry, charsmax(entry), "\r%d. \w%s: %s^n", num, g_property4_name[block_type], property[0] == '1' ? "\yTak" : "\rNie");
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
	add(menu, charsmax(menu), "^n^n^n^n^n^n\r0. \wWroc");
	
	show_menu(id, g_keys_properties_menu, menu, -1, "SCMPropertiesMenu");
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

show_menu(id, g_keys_move_menu, menu, -1, "SCMMoveMenu");

return PLUGIN_HANDLED;
}

ShowTeleportMenu(id)
{
new menu[256+128], col1[3], col2[3];

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

show_menu(id, g_keys_teleport_menu, menu, -1, "SCMTeleportMenu");
}

ShowLightMenu(id)
{
new menu[256+128], col1[3], col2[3];

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

show_menu(id, g_keys_light_menu, menu, -1, "SCMLightMenu");
}

ShowLightPropertiesMenu(id, ent)
{
new menu[256+128], radius[5], color_red[5], color_green[5], color_blue[5];

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

show_menu(id, g_keys_light_properties_menu, menu, -1, "SCMLightPropertiesMenu");
}

ShowOptionsMenu(id)
{
new menu[256+128], col1[3], col2[3], col3[3], col4[3];

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
col1,\
col2,\
col1,\
col2,\
col3,\
col4,\
col3,\
col4,\
col3,\
col4);

show_menu(id, g_keys_options_menu, menu, -1, "SCMOptionsMenu");
}

ShowChoiceMenu(id, choice, const title[96])
{
new menu[128];

g_choice_option[id] = choice;

format(menu, charsmax(menu), g_choice_menu, title);

show_menu(id, g_keys_choice_menu, menu, -1, "SCMChoiceMenu");
}

ShowCommandsMenu(id)
{
new menu[256+128], col1[3], col2[3], col3[3], col4[3];

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
g_all_godmode ? "" : "",\
g_all_godmode ? "" : "",\
col1,\
col2,\
PLUGIN_PREFIX
);

show_menu(id, g_keys_commands_menu, menu, -1, "SCMCommandsMenu");
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
new authid[32];
get_user_authid(id,authid,31);
if(get_user_flags(id) & ADMIN_IMMUNITY ){
g_viewing_commands_menu[id] = true;
ShowCommandsMenu(id);
} else 
{
ShowMainMenu(id);
client_print(id, print_center, "Nie masz dostepu!");
}	
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
case K2: CreateBlockAiming(id, g_selected_block_type[id]);
case K3: ConvertBlockAiming(id, g_selected_block_type[id]);
case K4: DeleteBlockAiming(id);
case K5: RotateBlockAiming(id);
case K6: ToggleNoclip(id);
case K7: ToggleGodmode(id);

case K8: ChangeBlockSize(id);
case K9: ShowOptionsMenu(id);
case K0: ShowMainMenu(id);
}

if ( key == 1|| key == 2||key == 3||key == 4||key == 5||key == 6|| key == 7) ShowBlockMenu(id);
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
BM_Print(id, "Block skasowany!");
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
||block_type == BUNNYHOPDMG
|| block_type == SLAP
|| block_type == DEATH
|| block_type == DEATHD
|| block_type == BHGLASS
|| block_type == BHICE
|| block_type == BHFLASH
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
BM_Print(id, "Wpisz nowa wartosc dla blocka.%s", g_property_info[id][0] == 3 && block_type != BOOTS_OF_SPEED ? "^1 0^3 and^1 255^3 will turn transparency off." : g_blank);
client_cmd(id, "messagemode bm_ustawienia");
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
BM_Print(id, "Wpisz nowa wartosc dla blocka.%s", g_property_info[id][0] == 3 && block_type != BOOTS_OF_SPEED ? "^1 0^3 and^1 255^3 will turn transparency off." : g_blank);
client_cmd(id, "messagemode bm_ustawienia");
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
BM_Print(id, "Wpisz nowa wartosc dla blocka.%s", g_property_info[id][0] == 3 && block_type != BOOTS_OF_SPEED ? "^1 0^3 and^1 255^3 will turn transparency off." : g_blank);
client_cmd(id, "messagemode bm_ustawienia");
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

BM_Print(id, "Grupa usunieta poniewaz blocki byly w ziemi!");
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
if ( deleted ) BM_Print(id, "Block usuniety poniewaz byl w ziemi!");
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
BM_Print(id, "Swiatlo zostalo skasowane!");
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
BM_Print(id, "Wpisz nowa wartosc dla swiatla.");
client_cmd(id, "messagemode bm_swiatla");
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
case K5: SetPropertiesBlockAiming(id);
case K6: ShowMoveMenu(id);
case K7:
{
if ( g_admin[id] )	ShowChoiceMenu(id, CHOICE_DELETE, "Jestes pewien, ze chcesz skasowac wszystkie blocki i teleporty?");
else			ShowOptionsMenu(id);
}
case K8: SaveBlocks(id);
case K9:
{
if ( g_admin[id] )	ShowChoiceMenu(id, CHOICE_LOAD, "Jestes pewny ze chcesz usunac wszystkie blocki a nastepnie zaladowac?");
else			ShowOptionsMenu(id);
}
case K0: ShowBlockMenu(id);
}



if ( key == K1||key == K2||key == K3 ||key == K4||key == K8) ShowOptionsMenu(id);
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
new name[32];
get_user_name(id, name, 31);
BM_Print(0, "Admin %s %s noclipa!", name, g_noclip[id] ? "wylaczyl":"wlaczyl");
set_user_noclip(id, g_noclip[id] ? 0 : 1);
g_noclip[id] = !g_noclip[id];
}
}

ToggleGodmode(id)
{
if ( g_admin[id] || g_gived_access[id] )
{
new name[32];
get_user_name(id, name, 31);
BM_Print(0, "Admin %s %s godmoda!", name, g_noclip[id] ? "wylaczyl":"wlaczyl");
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
console_print(id, "Nie masz wymaganych uprawnien");
return PLUGIN_HANDLED;
}
else if ( !g_alive[id] )
{
BM_Print(id, "You have to be alive to save a checkpoint!");
return PLUGIN_HANDLED;
}
else if ( g_noclip[id] )
{
BM_Print(id, "You can't save a checkpoint while using noclip!");
return PLUGIN_HANDLED;
}

static Float:velocity[3];
get_user_velocity(id, velocity);

new button =	entity_get_int(id, EV_INT_button);
new flags =	entity_get_int(id, EV_INT_flags);

if ( !( ( velocity[2] >= 0.0 || ( flags & FL_INWATER ) ) && !( button & IN_JUMP ) && velocity[2] <= 0.0 ) )
{
BM_Print(id, "You can't save a checkpoint while moving up or down!");
return PLUGIN_HANDLED;
}

if ( flags & FL_DUCKING )	g_checkpoint_duck[id] = true;
else				g_checkpoint_duck[id] = false;

entity_get_vector(id, EV_VEC_origin, g_checkpoint_position[id]);

BM_Print(id, "Checkpoint saved!");

if ( !g_has_checkpoint[id] )		g_has_checkpoint[id] = true;

if ( g_viewing_commands_menu[id] )	ShowCommandsMenu(id);

return PLUGIN_HANDLED;
}

public CmdLoadCheckpoint(id)
{
if ( !g_admin[id] && !g_gived_access[id] )
{
console_print(id, "Nie masz wymaganych uprawnien");
return PLUGIN_HANDLED;
}
else if ( !g_alive[id] )
{
BM_Print(id, "You have to be alive to load a checkpoint!");
return PLUGIN_HANDLED;
}
else if ( !g_has_checkpoint[id] )
{
BM_Print(id, "You don't have a checkpoint!");
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

BM_Print(id, "Somebody is too close to your checkpoint!");
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
console_print(id, "Nie masz wymaganych uprawnien");
return PLUGIN_HANDLED;
}
else if ( g_alive[id] )
{
BM_Print(id, "Przeciez zyjesz.. Idiota!");
return PLUGIN_HANDLED;
}

ExecuteHam(Ham_CS_RoundRespawn, id);
BM_Print(id, "Ozywiles sie!");

static name[32];
get_user_name(id, name, charsmax(name));

for ( new i = 1; i <= g_max_players; i++ )
{
if ( !g_connected[i]
|| i == id ) continue;

BM_Print(i, "^1%s^3 ozywil sie!", name);
}

return PLUGIN_HANDLED;
}

CmdRevivePlayer(id)
{
if ( !g_admin[id] && !g_gived_access[id] )
{
console_print(id, "Nie masz wymaganych uprawnien");
return PLUGIN_HANDLED;
}

client_cmd(id, "messagemode bm_ozyw");
BM_Print(id, "Wpisz nick osoby ktora chcesz ozywic.");

return PLUGIN_HANDLED;
}

public RevivePlayer(id)
{
if ( !g_admin[id] && !g_gived_access[id] )
{
console_print(id, "Nie masz wymaganych uprawnien");
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
BM_Print(id, "^1%s^3 is admin, he can revive himself!", target_name);
return PLUGIN_HANDLED;
}
else if ( g_alive[target] )
{
BM_Print(id, "^1%s^3 jest zywy!", target_name);
return PLUGIN_HANDLED;
}

ExecuteHam(Ham_CS_RoundRespawn, target);

static admin_name[32];
get_user_name(id, admin_name, charsmax(admin_name));

BM_Print(id, "Ozywiles^1 %s^3!", target_name);

for ( new i = 1; i <= g_max_players; i++ )
{
if ( !g_connected[i]
|| i == id
|| i == target ) continue;

BM_Print(i, "^1%s^3 ozywil^1 %s^3!", admin_name, target_name);
}

BM_Print(target, "Zostales ozywiony przez^1 %s^3!", admin_name);

return PLUGIN_HANDLED;
}

CmdReviveEveryone(id)
{
if ( !g_admin[id] )
{
console_print(id, "Nie masz wymaganych uprawnien");
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

BM_Print(0, "^1%s^3 ozywil wszystkich!", admin_name);

return PLUGIN_HANDLED;
}

ToggleAllGodmode(id)
{
if ( !g_admin[id] )
{
console_print(id, "Nie masz wymaganych uprawnien");
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

if ( g_all_godmode )	BM_Print(0, "^1%s^3 dal goda kazdemu!", admin_name);
else			BM_Print(0, "^1%s^3 odebral wszystkim goda!", admin_name);

return PLUGIN_HANDLED;
}

CmdGiveAccess(id)
{
if ( !g_admin[id] )
{
console_print(id, "Nie masz wymaganych uprawnien");
return PLUGIN_HANDLED;
}

client_cmd(id, "messagemode bm_dajbm");
BM_Print(id, "Wpisz nick osoby ktorej chcesz dac dostep do BM");

return PLUGIN_HANDLED;
}

public GiveAccess(id)
{
if ( !g_admin[id] )
{
console_print(id, "Nie masz wymaganych uprawnien");
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
BM_Print(id, "^1%s^3 already have access to %s!", target_name, PLUGIN_PREFIX);
return PLUGIN_HANDLED;
}

g_gived_access[target] = true;

BM_Print(id, "You gived^1 %s^3 access to %s!", target_name, PLUGIN_PREFIX);

static admin_name[32];
get_user_name(id, admin_name, charsmax(admin_name));

BM_Print(target, "^1%s^3 dal Ci dostep do BM! Wpisz /bm by wlaczyc menu!", admin_name);

for ( new i = 1; i <= g_max_players; i++ )
{
if ( i == id
|| i == target
|| !g_connected[i] ) continue;

BM_Print(i, "^1%s^3 dal^1 %s^3 dostep do BM!", admin_name, target_name);
}

return PLUGIN_HANDLED;
}

public CmdShowInfo(id)
{

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
console_print(id, "Nie masz wymaganych uprawnien");
return PLUGIN_HANDLED;
}

static origin[3];
static Float:float_origin[3];

get_user_origin(id, origin, 3);
IVecFVec(origin, float_origin);
float_origin[2] += 4.0;


if(g_selected_block_size[id] == POLE) CreateBlock(id, block_type, float_origin, X, g_selected_block_size[id], g_property1_default_value[block_type], g_property2_default_value[block_type], g_property3_default_value[block_type], g_property4_default_value[block_type]);
else CreateBlock(id, block_type, float_origin, Z, g_selected_block_size[id], g_property1_default_value[block_type], g_property2_default_value[block_type], g_property3_default_value[block_type], g_property4_default_value[block_type]);
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
		case X:{
			if (size == POLE) {
				size_min = g_pole_block_size_min_x;
				size_max = g_pole_block_size_max_x;
			}
			else 
			{
				size_min[0] = -4.0;
				size_min[1] = -32.0;
				size_min[2] = -32.0;
				
				size_max[0] = 4.0;
				size_max[1] = 32.0;
				size_max[2] = 32.0;
			}
			angles[0] = 90.0;
		}
		case Y:{
			if (size == POLE) {
				size_min = g_pole_block_size_min_y;
				size_max = g_pole_block_size_max_y;
			}
			else
			{
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
		case Z:{
			if (size == POLE) {
				size_min = g_pole_block_size_min_z;
				size_max = g_pole_block_size_max_z;
			}
			else
			{
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
		case TINY:
		{
			SetBlockModelName(block_model, g_block_models[block_type], "_small.mdl");
			scale = 0.25;
		}
		case NORMAL:
		{
			block_model = g_block_models[block_type];
			scale = 1.0;
		}
		case LARGE:
		{
			SetBlockModelName(block_model, g_block_models[block_type], "_large.mdl");
			scale = 2.0;
		}
		case POLE:
		{
			SetBlockModelName(block_model, g_block_models[block_type], "_pole.mdl");
			scale = 0.125;
		}
	}
	if(size != POLE){
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
	if(block_type == DEATHD){
		new Float:floatt[3];
		floatt[2] = str_to_float(property2);
		entity_set_int(ent, EV_INT_movetype, MOVETYPE_BOUNCE);
		drop_to_floor(ent);
		entity_set_vector(ent, EV_VEC_velocity, floatt);
	}
	return ent;
}

ConvertBlockAiming(id, const convert_to)
{
if ( !g_admin[id] && !g_gived_access[id] )
{
console_print(id, "Nie masz wymaganych uprawnien");
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

BM_Print(id, "^1%s^3 ma ta grupe!", player_name);
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
BM_Print(id, "Nie mozna zmienic ^1 %d^3 blockow!", block_count);
}
}
else
{
new_block = ConvertBlock(id, ent, convert_to, false);
if ( IsBlockStuck(new_block) )
{
new bool:deleted = DeleteBlock(new_block);
if ( deleted ) BM_Print(id, "Block skasowany poniewaz byl w ziemi!");
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
		else if ( max_size > 32.0 )	size = POLE;
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
		console_print(id, "Nie masz wymaganych uprawnien");
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
	
		BM_Print(id, "^1%s^3 currently has this block in their group!", player_name);
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
		console_print(id, "Nie masz wymaganych uprawnien");
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
	
		BM_Print(id, "^1%s^3 currently has this block in their group!", player_name);
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
		case LARGE:	g_selected_block_size[id] = POLE;
		case POLE:	g_selected_block_size[id] = TINY;
	}
}

SetPropertiesBlockAiming(id)
{
	if ( !g_admin[id] && !g_gived_access[id] ){
		console_print(id, "Nie masz wymaganych uprawnien");
		ShowBlockMenu(id);
		return PLUGIN_HANDLED;
	}
	
	static ent, body;
	get_user_aiming(id, ent, body);
	
	if ( !IsBlock(ent) ){
		ShowBlockMenu(id);
		return PLUGIN_HANDLED;
	}
	
	new block_type = entity_get_int(ent, EV_INT_body);
	
	if ( !g_property1_name[block_type][0]&& !g_property2_name[block_type][0]&& !g_property3_name[block_type][0]&& !g_property4_name[block_type][0] )
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
	
	if ( !strlen(arg) ){
		BM_Print(id, "Nie mozesz zostawic pola pustego!");
		client_cmd(id, "messagemode bm_ustawienia");
		return PLUGIN_HANDLED;
	}
	else if ( !IsStrFloat(arg) ){
		BM_Print(id, "Nieprawidlowa wartosc");
		client_cmd(id, "messagemode bm_ustawienia");
		return PLUGIN_HANDLED;
	}
	new ent = g_property_info[id][1];
	if ( !is_valid_ent(ent) ){
		BM_Print(id, "Block skasowany");
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
	
	if ( property == 3&& block_type != BOOTS_OF_SPEED )
	{
		if ( !( 1 <= property_value <= 200 || property_value == 255|| property_value == 0 ) )
		{
			BM_Print(id, "Dozwolona wartosc: od^1 1^3 do^1 200^3,^1 255^3 lub^1 0^3!");
			return PLUGIN_HANDLED;
		}
	}
	else
	{
		switch ( block_type )
		{
			case DAMAGE, HEALER,ARMOR:
			{
				if ( property == 1&& !( 1 <= property_value <= 100 ) )
				{
					BM_Print(id, "Dozwolona wartosc: od ^1 1^3 do^1 100^3!");
					return PLUGIN_HANDLED;
				}
				else if ( !( 0.1 <= property_value <= 240 ) )
				{
					BM_Print(id, "Dozwolona wartosc: od ^1 0.1^3 od ^1 240^3!");
					return PLUGIN_HANDLED;
				}
			}
			case TRAMPOLINE:
			{
				if ( !( 200 <= property_value <= 2000 ) )
				{
					BM_Print(id, "Dozwolona wartosc: ^1 200^3 do^1 2000^3!");
					return PLUGIN_HANDLED;
				}
			}
			case SPEED_BOOST:
			{
				if ( property == 1&& !( 200 <= property_value <= 2000 ) )
				{
					BM_Print(id, "Dozwolona wartosc: od^1 200^3 do^1 2000^3!");
					return PLUGIN_HANDLED;
				}
				else if ( !( 0 <= property_value <= 2000 ) )
				{
					BM_Print(id, "Dozwolona wartosc: od^1 0^3 do^1 2000^3!");
					return PLUGIN_HANDLED;
				}
			}
			case LOW_GRAVITY:
			{
				if ( !( 50 <= property_value <= 750 ) )
				{
					BM_Print(id, "Dozwolona wartosc: ^1 50^3 do^1 750^3!");
					return PLUGIN_HANDLED;
				}
			}
			case HONEY:
			{
				if ( !( 75 <= property_value <= 200|| property_value == 0 ) )
				{
					BM_Print(id, "Dozwolona wartosc: ^1 75^3 do^1 200^3, lub^1 0^3!");
					return PLUGIN_HANDLED;
				}
			}
			case DELAYED_BUNNYHOP:
			{
				if ( !( 0.5 <= property_value <= 5 ) )
				{
					BM_Print(id, "Dozwolona wartosc: od^1 0.5^3 od^1 5^3!");
					return PLUGIN_HANDLED;
				}
			}
			case INVINCIBILITY, STEALTH, BOOTS_OF_SPEED,KAMUFLARZ,AWP:
			{
				if ( property == 1&& !( 0.5 <= property_value <= 600) )
				{
					BM_Print(id, "Dozwolona wartosc: od^1 0.5^3 do^1 600^3!");
					return PLUGIN_HANDLED;
				}
				else if ( property == 2&& !( 0 <= property_value <= 600 ) )
				{
					BM_Print(id, "Dozwolona wartosc: od^1 0^3 do^1 600^3!");
					return PLUGIN_HANDLED;
				}
				else if ( property == 3&& block_type == BOOTS_OF_SPEED&& !( 260 <= property_value <= 400 ) )
				{
					BM_Print(id, "Dozwolona wartosc: od^1 260^3 do^1 400^3!");
					return PLUGIN_HANDLED;
				}
			}
			case XP:
			{
				if ( property == 1&& !( 1 <= property_value <= 100) )
				{
					BM_Print(id, "Dozwolona wartosc: od^1 1^3 do^1 100^3!");
					return PLUGIN_HANDLED;
				}
			}
			case DEATHD: 
			{
				if(property==2){
					if ( !( 10.0 <= property_value <= 2000.0 ) ){	
                                                BM_Print(id, "Dozwolona wartosc: od^1 10^3 do^1 2000^3!");
						emit_sound(id, CHAN_STATIC, g_sound_death, 1.0, ATTN_NORM, 0, PITCH_NORM);
                                                return PLUGIN_HANDLED;
					}
					else{
						new Float:floatt[3];
						floatt[2] =property_value;
						drop_to_floor(ent);
						entity_set_vector(ent, EV_VEC_velocity, floatt);
					}
				}
			
			}
		}
	}
	
	SetProperty(ent, property, arg);
	
	for ( new i = 1; i <= g_max_players; i++ )
	{
		if ( !g_connected[i]|| !g_viewing_properties_menu[i] ) continue;
		ent = g_property_info[i][1];
		ShowPropertiesMenu(i, ent);
	}
	
	return PLUGIN_HANDLED;
}

ToggleProperty(id, property)
{
	new ent = g_property_info[id][1];
	if ( !is_valid_ent(ent) ){
		BM_Print(id, "That block has been deleted!");
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
				if ( !transparency|| transparency == 255 )
				{
					SetBlockRendering(ent, g_render[block_type], g_red[block_type], g_green[block_type], g_blue[block_type], g_alpha[block_type]);
				}
				else
				{
					SetBlockRendering(ent, TRANSALPHA, 255, 255, 255, transparency);
					if(transparency==1) set_rendering(ent, kRenderFxPulseSlow, g_red[block_type], g_green[block_type], g_blue[block_type],kRenderTransAlpha, 150);
					if(transparency==2) set_rendering(ent, kRenderFxPulseFastWide, g_red[block_type], g_green[block_type], g_blue[block_type],kRenderTransAlpha, 150);
					if(transparency==3) set_rendering(ent, kRenderFxStrobeFast, g_red[block_type], g_green[block_type], g_blue[block_type],kRenderTransAlpha, 150);
					if(transparency==4) set_rendering(ent, kRenderFxHologram, g_red[block_type], g_green[block_type], g_blue[block_type],kRenderNormal, g_alpha[block_type]);
					if(transparency==5) set_rendering(ent, kRenderFxHologram, g_red[block_type], g_green[block_type], g_blue[block_type],kRenderTransAdd, g_alpha[block_type]);
					if(transparency==6) set_rendering(ent, kRenderFxHologram, g_red[block_type], g_green[block_type], g_blue[block_type], kRenderTransAlpha, 200);
					if(transparency==7) set_rendering(ent, kRenderFxGlowShell, 255, 0, 0, kRenderNormal, 20);
					if(transparency==8) set_rendering(ent, kRenderFxGlowShell, 0, 255, 0, kRenderNormal, 20);
					if(transparency==9) set_rendering(ent, kRenderFxGlowShell, 255, 0, 0, kRenderTransAlpha, 200);/////////////////////////
					if(transparency==10) set_rendering(ent, kRenderFxGlowShell, 0, 255, 0, kRenderTransAlpha, 200);
					if(transparency==11) set_rendering(ent, kRenderFxGlowShell, 0, 0, 255, kRenderTransAlpha, 200);
					if(transparency==12) set_rendering(ent, kRenderFxGlowShell, 255, 0, 0, kRenderTransAlpha, 150);
					if(transparency==13) set_rendering(ent, kRenderFxGlowShell, 0, 255, 0, kRenderTransAlpha, 150);
					if(transparency==14) set_rendering(ent, kRenderFxGlowShell, 0, 0, 255, kRenderTransAlpha, 150);
					if(transparency==15) set_rendering(ent, kRenderFxGlowShell, 255, 0, 255, kRenderNormal, 20);///////////////////////
					if(transparency==16) set_rendering(ent, kRenderFxGlowShell, 150, 150, 0, kRenderNormal, 20);
					if(transparency==17) set_rendering(ent, kRenderFxGlowShell, 0, 0, 255, kRenderNormal, 20);
					if(transparency==18) set_rendering(ent, kRenderFxGlowShell, 255, 150, 0, kRenderNormal, 20);
					if(transparency==19) set_rendering(ent, kRenderFxGlowShell, 255, 255, 255, kRenderNormal, 20);
					if(transparency==20) set_rendering(ent, kRenderFxGlowShell, 0, 150, 150, kRenderNormal, 20);
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
static block_type;
block_type = entity_get_int(ent, EV_INT_body);
if(block_type == DEATHD){
new Float:floatt[3];
new property2[5];
GetProperty(ent, 2, property2);
floatt[2] = str_to_float(property2);
entity_set_int(ent, EV_INT_movetype, MOVETYPE_BOUNCE);
drop_to_floor(ent);
entity_set_vector(ent, EV_VEC_velocity, floatt);
}
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
else if ( max_size > 32.0 )	size = POLE;
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
console_print(id, "Nie masz wymaganych uprawnien");
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

BM_Print(id, "Block is already in a group by:^1 %s", name);
}

return PLUGIN_HANDLED;
}

GroupBlock(id, ent)
{
	if ( !is_valid_ent(ent) ) return PLUGIN_HANDLED;
	if ( 1 <= id <= g_max_players ){
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
	if ( !g_admin[id] && !g_gived_access[id] ){
		console_print(id, "Nie masz wymaganych uprawnien");
		return PLUGIN_HANDLED;
	}
	
	static block;
	static block_count;
	static blocks_deleted;
	
	block_count = 0;
	blocks_deleted = 0;
	for ( new i = 0; i <= g_group_count[id]; ++i ){
		block = g_grouped_blocks[id][i];
		if ( IsBlockInGroup(id, block) ){
			if ( IsBlockStuck(block) ){
				DeleteBlock(block);
				++blocks_deleted;
			}
			else{
				UnGroupBlock(block);
				++block_count;
			}
		}
	}
	
	g_group_count[id] = 0;
	
	if ( g_connected[id] )
	{
		if ( blocks_deleted > 0 ){
			BM_Print(id, "Removed^1 %d^3 blocks from group. Deleted^1 %d^3 stuck blocks!", block_count, blocks_deleted);
		}
		else{
			BM_Print(id, "Removed^1 %d^3 blocks from group!", block_count);
		}
	}
	
	return PLUGIN_HANDLED;
}

SetBlockRendering(ent, type, red, green, blue, alpha)
{
	if ( !IsBlock(ent) ) return PLUGIN_HANDLED;
	
	switch ( type ){
		case GLOWSHELL:		set_rendering(ent, kRenderFxGlowShell, red, green, blue, kRenderNormal, alpha);
		case TRANSCOLOR:	set_rendering(ent, kRenderFxGlowShell, red, green, blue, kRenderTransColor, alpha);
		case TRANSALPHA:	set_rendering(ent, kRenderFxNone, red, green, blue, kRenderTransColor, alpha);
		case TRANSWHITE:	set_rendering(ent, kRenderFxNone, red, green, blue, kRenderTransAdd, alpha);
		case TRANSADD:		set_rendering(ent, kRenderFxNone, red, green, blue, kRenderTransAdd, alpha);
		default:		set_rendering(ent, kRenderFxNone, red, green, blue, kRenderNormal, alpha);
	}
	
	return PLUGIN_HANDLED;
}

bool:IsBlock(ent)
{
	if ( !is_valid_ent(ent) ) return false;
	
	static classname[32];
	entity_get_string(ent, EV_SZ_classname, classname, charsmax(classname));
	
	if ( equal(classname, g_block_classname) ){
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
		if ( content == CONTENTS_EMPTY|| !content ) return false;
	}
	
	return true;
}

CreateTeleportAiming(id, teleport_type)
{
	if ( !g_admin[id] && !g_gived_access[id] ){
		console_print(id, "Nie masz wymaganych uprawnien");
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
	if ( !g_admin[id] && !g_gived_access[id] ){
		console_print(id, "Nie masz wymaganych uprawnien");
		return PLUGIN_HANDLED;
	}
	
	static ent, body;
	get_user_aiming(id, ent, body, 9999);
	
	new bool:deleted = DeleteTeleport(id, ent);
	if ( deleted ) BM_Print(id, "Teleport skasowany!");
	
	return PLUGIN_HANDLED;
}

bool:DeleteTeleport(id, ent)
{
	for ( new i = 0; i < 2; ++i ){
		if ( !IsTeleport(ent) ) return false;
		
		new tele = entity_get_int(ent, EV_INT_iuser1);
		
		if ( g_teleport_start[id] == ent|| g_teleport_start[id] == tele ){
			g_teleport_start[id] = 0;
		}
		
		if ( task_exists(TASK_SPRITE + ent) ){
			remove_task(TASK_SPRITE + ent);
		}
		
		if ( task_exists(TASK_SPRITE + tele) ){
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
	if ( !g_admin[id] && !g_gived_access[id] ){
		console_print(id, "Nie masz wymaganych uprawnien");
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
	if ( !is_valid_ent(tele) ){
		BM_Print(id, "Can't swap teleport positions!");
		return PLUGIN_HANDLED;
	}
	
	entity_get_vector(ent, EV_VEC_origin, origin_ent);
	entity_get_vector(tele, EV_VEC_origin, origin_tele);
	
	static classname[32];
	entity_get_string(ent, EV_SZ_classname, classname, charsmax(classname));
	
	DeleteTeleport(id, ent);
	
	if ( equal(classname, g_start_classname) ){
		CreateTeleport(id, TELEPORT_START, origin_tele);
		CreateTeleport(id, TELEPORT_DESTINATION, origin_ent);
	}
	else if ( equal(classname, g_destination_classname) ){
		CreateTeleport(id, TELEPORT_START, origin_ent);
		CreateTeleport(id, TELEPORT_DESTINATION, origin_tele);
	}
	
	BM_Print(id, "Teleport zamieniony!");
	
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
	
	BM_Print(id, "Linia zostala narysowana. Odleglosc:^1 %f units", dist);

	return PLUGIN_HANDLED;
}

bool:IsTeleport(ent){
	if ( !is_valid_ent(ent) ) return false;
	
	static classname[32];
	entity_get_string(ent, EV_SZ_classname, classname, charsmax(classname));
	
	if ( equal(classname, g_start_classname)|| equal(classname, g_destination_classname) ){
		return true;
	}
	
	return false;
}

CreateLightAiming(const id)
{
if ( !g_admin[id] && !g_gived_access[id] )
{
console_print(id, "Nie masz wymaganych uprawnien");
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
console_print(id, "Nie masz wymaganych uprawnien");
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
console_print(id, "Nie masz wymaganych uprawnien");
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
BM_Print(id, "You can't set a property blank! Please type a new value.");
client_cmd(id, "messagemode bm_swiatla");
return PLUGIN_HANDLED;
}
else if ( !is_str_num(arg) )
{
BM_Print(id, "You can't use letters in a property! Please type a new value.");
client_cmd(id, "messagemode bm_swiatla");
return PLUGIN_HANDLED;
}

new ent = g_light_property_info[id][1];
if ( !is_valid_ent(ent) )
{
BM_Print(id, "That light has been deleted!");
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
BM_Print(id, "Dozwolona wartosc: od^1 1^3 do^1 100^3!");
return PLUGIN_HANDLED;
}
}
else if ( !( 0 <= property_value <= 255 ) )
{
BM_Print(id, "Dozwolona wartosc: od^1 0^3 do^1 255^3!");
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
	
	if ( equal(classname, g_light_classname) ) return true;
	
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
	for ( new i = 0; i < 6; ++i ){
		trace_start = move_to;
		switch ( i ){
			case 0: trace_start[0] += size_min[0];
			case 1: trace_start[0] += size_max[0];
			case 2: trace_start[1] += size_min[1];
			case 3: trace_start[1] += size_max[1];
			case 4: trace_start[2] += size_min[2];
			case 5: trace_start[2] += size_max[2];
		}
		trace_end = trace_start;
		switch ( i ){
			case 0: trace_end[0] -= snap_size;
			case 1: trace_end[0] += snap_size;
			case 2: trace_end[1] -= snap_size;
			case 3: trace_end[1] += snap_size;
			case 4: trace_end[2] -= snap_size;
			case 5: trace_end[2] += snap_size;
		}
		
		traceline = trace_line(ent, trace_start, trace_end, v_return);
		if ( IsBlock(traceline) && ( !IsBlockInGroup(id, traceline) || !IsBlockInGroup(id, ent) ) ){
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
	if(!(get_user_flags(id) & ADMIN_IMMUNITY)){
		console_print(id, "Nie masz wymaganych uprawnien");
		return PLUGIN_HANDLED;
	}
	static ent, block_count, tele_count, light_count, bool:deleted;
	
	ent = -1;
	block_count = 0;
	while ( ( ent = find_ent_by_class(ent, g_block_classname) ) ){
		deleted = DeleteBlock(ent);
		if ( deleted ) ++block_count;
	}
	ent = -1;
	tele_count = 0;
	while ( ( ent = find_ent_by_class(ent, g_start_classname) ) ){
		deleted = DeleteTeleport(id, ent);
		if ( deleted ) ++tele_count;
	}
	ent = -1;
	light_count = 0;
	while ( ( ent = find_ent_by_class(ent, g_light_classname) ) ){
		deleted = DeleteLight(ent);
		if ( deleted ) ++light_count;
	}
	
	if ( ( block_count || tele_count || light_count ) && notify ){
		static name[32];
		get_user_name(id, name, charsmax(name));
		
		for ( new i = 1; i <= g_max_players; ++i ){
			g_grabbed[i] = 0;
			g_teleport_start[i] = 0;
			if ( !g_connected[i] || !g_admin[i] && !g_gived_access[i] ) continue;
			BM_Print(i, "^1%s^3 deleted^1 %d blocks^3,^1 %d teleports^3 and^1 %d lights^3 from the map!", name, block_count, tele_count, light_count);
		}
	}
	return PLUGIN_HANDLED;
}

SaveBlocks(id)
{
	if ( !g_admin[id] ){
		console_print(id, "Nie masz wymaganych uprawnien");
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
		else if ( max_size > 32.0 )	size = POLE;
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
	
	for ( new i = 1; i <= g_max_players; ++i ){
		if ( g_connected[i] && ( g_admin[i] || g_gived_access[i] ) ){
			BM_Print(i, "^1%s^3 zapisal^1 %d blockow^3,^1 %d, teleportow^3 oraz^1 %d swiatel^3! Wszystkich bytow na mapie:^1 %d", name, block_count, tele_count, light_count, entity_count());
		}
	}
	
	fclose(file);
	return PLUGIN_HANDLED;
}

LoadBlocks(id)
{
	if ( id != 0 && !g_admin[id] ){
		console_print(id, "Nie masz wymaganych uprawnien");
		return PLUGIN_HANDLED;
	}
	else if ( !file_exists(g_file) && 1 <= id <= g_max_players ){
		BM_Print(id, "Couldn't find file:^1 %s", g_file);
		return PLUGIN_HANDLED;
	}
	if ( 1 <= id <= g_max_players ){
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
	
	while ( !feof(file) ){
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
				if ( angles[0] == 90.0 && angles[1] == 0.0 && angles[2] == 0.0 ){
					axis = X;
				}
				else if ( angles[0] == 90.0 && angles[1] == 0.0 && angles[2] == 90.0 ){
					axis = Y;
				}
				else axis = Z;
			}
	
			switch ( type[0] ){
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
				case 'U': block_type = KAMUFLARZ;
				case 'W': block_type = BHGLASS;
				case 'X': block_type = MUZA;
				case 'Y': block_type = AWP;
				case 'Z': block_type = ROT;
				case '1': block_type = HE;
				case '2': block_type = HE2;
				case '3': block_type = SMOKE;
				case '4': block_type = BHICE;
				case '5': block_type = FLASH;
				case '6': block_type = BHFLASH;
				case '7': block_type = SPAM;
				case '8': block_type = DEATHD;
				case '9': block_type = BUNNYHOPDMG;
				case 'a': block_type = ARMOR;
				case 'b': block_type = BOOM;
				case 'c': block_type = RAND;
				case 'd': block_type = XP;
				case 'e': block_type = PRZEKRETY;
				case 'f': block_type = VIP;
				case 'g': block_type = NOC;
				case 'h': block_type = ZATRUCIE;
				case 'i': block_type = ANTIDOTUM;
				case 'j': block_type = LIGHT;
				case 'k': block_type = GPS;
				case 'l': block_type = BRON;
				case 'm': block_type = ROT3;
				case 'n': block_type = TRAWA;
	                        case '@': block_type = MIKSTURA;

				case '*':{
					CreateTeleport(0, TELEPORT_START, origin);
					CreateTeleport(0, TELEPORT_DESTINATION, angles);
					++tele_count;
				}
				case '!':{
					CreateLight(origin, property1, property2, property3, property4);
					++light_count;
				}
			}
			if ( type[0] != '*' && type[0] != '!' ){
				CreateBlock(0, block_type, origin, axis, size, property1, property2, property3, property4);
				++block_count;
			}
		}
	}
	fclose(file);

	if ( 1 <= id <= g_max_players ){
		static name[32];
		get_user_name(id, name, charsmax(name));
		for ( new i = 1; i <= g_max_players; ++i ){
			if ( !g_connected[i] || !g_admin[i] && !g_gived_access[i] ) continue;
			BM_Print(i, "^1%s^3 loaded^1 %d block%s^3,^1 %d teleport%s^3 and^1 %d light%s^3! Total entites in map:^1 %d", name, block_count, block_count == 1 ? g_blank : "s", tele_count, tele_count == 1 ? g_blank : "s", light_count, light_count == 1 ? g_blank : "s", entity_count());
			}
	}
	return PLUGIN_HANDLED;
}
bool:IsStrFloat(string[])
{
	new len = strlen(string);
	for ( new i = 0; i < len; i++ ){
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
	for(new i = 0; i < Weapons; i++){
		gbUsedWeapon[id][i] =		false;
	}
	gbUsed[id]		=	false;
	zarazenie[id]		=	false;
	g_next_damage_time[id] =	0.0;
	g_next_heal_time[id] =		0.0;
	g_invincibility_time_out[id] =	0.0;
	g_xp_time_out[id] =		0.0;
	gfNocTimeOut[id] =		0.0;
	gfNocNextUse[id] =		0.0;
	g_kamuflarz_time_out[id] =	0.0;
	g_invincibility_next_use[id] =	0.0;
	g_xp_next_use[id] =		0.0;
	g_kamuflarz_next_use[id] =	0.0;
	g_awp_next_use[id] =	0.0;
	g_deagle_next_use[id] =	0.0;
	g_stealth_time_out[id] =	0.0;
	g_stealth_next_use[id] =	0.0;
	g_boots_of_speed_time_out[id] =	0.0;
	g_boots_of_speed_next_use[id] =	0.0;
	MiksturaUsed[id] =		false;
	
	new task_id = TASK_INVINCIBLE + id;
	if ( task_exists(task_id) ){
		TaskRemoveInvincibility(task_id);
		remove_task(task_id);
	}
	task_id = TASK_KAMUFLARZ + id;
	if ( task_exists(task_id) ){
		TaskRemoveKamuflarz(task_id);
		remove_task(task_id);
	}
	task_id = TASK_STEALTH + id;
	if ( task_exists(task_id) ){
		TaskRemoveStealth(task_id);
		remove_task(task_id);
	}
	task_id = TASK_BOOTSOFSPEED + id;
	if ( task_exists(task_id) ){
		TaskRemoveBootsOfSpeed(task_id);
		remove_task(task_id);
	}
	if ( g_connected[id] ){
		set_user_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderNormal, 255);
	}
	
	g_reseted[id] =			true;
}
create_blast(const Float:originF[3])
{
	// Smallest ring
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0)
	write_byte(TE_BEAMCYLINDER) // TE id
	engfunc(EngFunc_WriteCoord, originF[0]) // x
	engfunc(EngFunc_WriteCoord, originF[1]) // y
	engfunc(EngFunc_WriteCoord, originF[2]) // z
	engfunc(EngFunc_WriteCoord, originF[0]) // x axis
	engfunc(EngFunc_WriteCoord, originF[1]) // y axis
	engfunc(EngFunc_WriteCoord, originF[2]+385.0) // z axis
	write_short(g_exploSpr) // sprite
	write_byte(0) // startframe
	write_byte(0) // framerate
	write_byte(4) // life
	write_byte(60) // width
	write_byte(0) // noise
	write_byte(142) // red    142 229 238
	write_byte(229) // green
	write_byte(238) // blue
	write_byte(200) // brightness
	write_byte(0) // speed
	message_end()
	
	// Medium ring
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0)
	write_byte(TE_BEAMCYLINDER) // TE id
	engfunc(EngFunc_WriteCoord, originF[0]) // x
	engfunc(EngFunc_WriteCoord, originF[1]) // y
	engfunc(EngFunc_WriteCoord, originF[2]) // z
	engfunc(EngFunc_WriteCoord, originF[0]) // x axis
	engfunc(EngFunc_WriteCoord, originF[1]) // y axis
	engfunc(EngFunc_WriteCoord, originF[2]+470.0) // z axis
	write_short(g_exploSpr) // sprite
	write_byte(0) // startframe
	write_byte(0) // framerate
	write_byte(4) // life
	write_byte(60) // width
	write_byte(0) // noise
	write_byte(127) // red    142 229 238  127 255 212
	write_byte(255) // green
	write_byte(212) // blue
	write_byte(200) // brightness
	write_byte(0) // speed
	message_end()
	
	// Largest ring
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0)
	write_byte(TE_BEAMCYLINDER) // TE id
	engfunc(EngFunc_WriteCoord, originF[0]) // x
	engfunc(EngFunc_WriteCoord, originF[1]) // y
	engfunc(EngFunc_WriteCoord, originF[2]) // z
	engfunc(EngFunc_WriteCoord, originF[0]) // x axis
	engfunc(EngFunc_WriteCoord, originF[1]) // y axis
	engfunc(EngFunc_WriteCoord, originF[2]+555.0) // z axis
	write_short(g_exploSpr) // sprite
	write_byte(0) // startframe
	write_byte(0) // framerate
	write_byte(4) // life
	write_byte(60) // width
	write_byte(0) // noise
	write_byte(142) // red    142 229 238 
	write_byte(229) // green
	write_byte(238) // blue
	write_byte(200) // brightness
	write_byte(0) // speed
	message_end()
}
ResetMaxspeed(id)
{
	static Float:max_speed;
	switch ( get_user_weapon(id) ){
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

BM_Print(id, const message_fmt[], any:...)
{
	static i; i = id ? id : GetPlayer();
	if ( !i ) return;
	
	static message[256], len;
	len = formatex(message, charsmax(message), "^4[EasyBlock]^3 ");
	vformat(message[len], charsmax(message) - len, message_fmt, 3);
	message[192] = 0;
	
	static msgid_SayText;
	if ( !msgid_SayText ) msgid_SayText = get_user_msgid("SayText");
	
	static const team_names[][] ={
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
	for ( new id = 1; id <= g_max_players; id++ ){
		if ( !g_connected[id] ) continue;
		return id;
		}
	return 0;
}
stock Display_Fade(client, red,gren,blu)
{
	message_begin(MSG_ONE, gMsgScreenFade, {0,0,0}, client);
	write_short(1 << 12);   	// Duration
	write_short(1<<8);   	// Hold time
	write_short(4096);    	// Fade type
	write_byte(red);       	// Red
	write_byte(gren);        // Green
	write_byte(blu);        	// Blue
	write_byte(100);   	// Alpha
	message_end();
}