/*

	Прилага random модели на играчите.
	Моделите се редактират по-долу. 
	При наличие на "T" модел, трябва да се precache-не отделно. По-долу има пример за това !

*/
#include < amxmodx >
#include < cstrike >
#include < hamsandwich >

#define PLUGIN		"Players Models"
#define VERSION		"1.1"
#define AUTHOR		"Smiley"

new bool:g_iAdmin[ 33 ];

new const models_name[ ][ ] =
{
	"bpbm_player_t", 
	"bpbm_player_ct",
	"bpbm_vip_t_assassin",
	"bpbm_vip_t_clown",
	"bpbm_vip_t_naruto",
	"bpbm_vip_t_xmen",
	"bpbm_vip_ct_deadpool",
	"bpbm_vip_ct_ironman",
	"bpbm_vip_ct_smith",
	"bpbm_vip_ct_spiderman"
}

public plugin_precache( )
{
	for( new i = 0; i < sizeof( models_name ); i++ )
	{
		new folders[ 64 ];
		formatex( folders, charsmax( folders ), "models/player/%s/%s.mdl", models_name[ i ], models_name[ i ] );
		precache_model( folders );
		precache_model("models/player/bpbm_vip_ct_deadpool/bpbm_vip_ct_deadpoolT.mdl")
	}
}

public plugin_init( )
{
	register_plugin( PLUGIN, VERSION, AUTHOR );
	RegisterHam( Ham_Spawn, "player", "fwdPlayerSpawn", 1 );
}

public client_authorized( id ) g_iAdmin[ id ] = ( get_user_flags( id ) & ADMIN_KICK ) ? true : false;

public client_disconnect( id ) g_iAdmin[ id ] = false;

public fwdPlayerSpawn( id )
{
	if( !is_user_alive( id ) ) return;
	
	if( cs_get_user_team( id ) == CS_TEAM_T ) cs_set_user_model( id, g_iAdmin[ id ] ? models_name[ random_num( 2, 5 ) ] : models_name[ 0 ] );
	else if( cs_get_user_team( id ) == CS_TEAM_CT ) cs_set_user_model( id, g_iAdmin[ id ] ? models_name[ random_num( 6, 9 ) ] : models_name[ 1 ] );	
}
	
		
			


	
