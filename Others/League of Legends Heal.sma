/*

    Подобно на LOL, можете да се хилнете или да хилнете съотборник.
    С помощта на мерника си можете да хилнете съотборник.
    Команда: Е (+use)

*/

#include <amxmodx>
#include <engine>
#include <fun>
#include <cstrike>

// ======== EDITABLE ZONE ======== //

// Set the time for healing (in seconds).
#define HealthTime 10

// Set the distance between the Health Kit owner and the receiver (in HL units).
#define OriginsDistance 260

// Set the custom Health Kit model.
new const g_MedKit[ ] = { "models/umbrella/p_medkit.mdl" };

// ======== END OF EDITABLE ZONE ======== //
// Don't proceed if you have no idea what you are doing!

#define SetUserHealthKit(%1) g_bHealthKit |= (1<<(%1 & 31))
#define HasUserHealthKit(%1) g_bHealthKit & (1<<(%1 & 31))
#define ClearUserHealthKit(%1) g_bHealthKit &= ~(1<<(%1 & 31))

#define SetUserConnected(%1) g_bConnected |= (1<<(%1 & 31))
#define IsUserConnected(%1) g_bConnected & (1<<(%1 & 31))
#define ClearUserConnected(%1) g_bConnected &= ~(1<<(%1 & 31))

new g_bHealthKit;
new g_bConnected;

new g_nMsgBarTime;

public plugin_precache( )
{
    precache_model( g_MedKit );
}

public plugin_init( )
{
    register_plugin( "Health Kit", "0.1.3c", "TBagT Edit" );
    
    register_event( "HLTV", "eventRoundStart", "a", "1=0", "2=0" );
}

public plugin_cfg( )
{
    g_nMsgBarTime = get_user_msgid( "BarTime" );
}

public eventRoundStart( id, iPlayer )
{
    if (!is_user_alive(id))
        return
    
    static CsTeams: team ; team = cs_get_user_team(id)
    
    if (team == CS_TEAM_T)
    { 
        remove_entity( find_ent_by_model( iPlayer, "info_target", g_MedKit ) );
        ClearUserHealthKit( iPlayer );
    }
    else if (team == CS_TEAM_CT)
    {
        if ( HasUserHealthKit( iPlayer ) )
        {
            client_print( iPlayer, print_chat, "You already have a Health Kit" );
        }
        
        SetUserHealthKit( iPlayer );
        
        new iEnt = create_entity( "info_target" );
        entity_set_int( iEnt, EV_INT_movetype, MOVETYPE_FOLLOW );
        entity_set_edict( iEnt, EV_ENT_aiment, iPlayer );
        entity_set_edict( iEnt, EV_ENT_owner, iPlayer );
        entity_set_model( iEnt, g_MedKit );
        
        static const szMessages[ ][ ] =
    {
        "You now have a health kit!",
        "Press E (+use) aiming to a friend.",
        "If you don't aim to a friend you will heal yourself."
    }
    
        for (new i = 0; i < sizeof ( szMessages ); i++)
    {
        client_print( iPlayer, print_chat, szMessages[ i ] );
    }
}
}

public client_putinserver( iPlayer )
{
    ClearUserHealthKit( iPlayer );
    SetUserConnected( iPlayer );
}

public client_disconnect( iPlayer )
{
    ClearUserHealthKit( iPlayer );
    ClearUserConnected( iPlayer );
}

public client_PreThink( iPlayer )
{
if ( HasUserHealthKit( iPlayer ) && is_user_alive( iPlayer ) && get_user_team(iPlayer) == 2 )
{
    if ( ( entity_get_int( iPlayer, EV_INT_button ) & IN_USE ) && !( entity_get_int( iPlayer, EV_INT_oldbuttons ) & IN_USE ) )
    {
        new iTarget;
        new iDontCare;
        get_user_aiming( iPlayer, iTarget, iDontCare );
        
        if ( is_user_alive( iTarget ) )
        {
            new iOwnerOrigin[ 3 ];
            new iReceiverOrigin[ 3 ];
            
            get_user_origin( iPlayer, iOwnerOrigin, 0 );
            get_user_origin( iTarget, iReceiverOrigin, 0 );
            
            if ( get_distance( iOwnerOrigin, iReceiverOrigin ) <= OriginsDistance )
            {
                if ( get_user_health( iTarget ) < 100 )
                {
                    set_view( iPlayer, CAMERA_3RDPERSON );
                    
                    showBarTimeMessage( iPlayer, HealthTime );
                    
                    set_hudmessage( 85, 255, 255, 0.16, 0.05, 1, 6.0, 5.0 );
                    show_hudmessage( iTarget, "A friend is healing you!" );
                    
                    static szData[ 2 ];
                    szData[ 0 ] = iPlayer;
                    szData[ 1 ] = iTarget;
                    
                    set_task( float( HealthTime ), "taskHealReceiver", _, szData, sizeof ( szData ) );
                }
            }
            return;
        }
        else
        {
            if ( get_user_health( iPlayer ) < 100 )
            {
                set_view( iPlayer, CAMERA_3RDPERSON );
                
                showBarTimeMessage( iPlayer, HealthTime );
                
                set_task( float( HealthTime ), "taskHealHimself", iPlayer );
            }
            return;
        }
    }
}
}

showBarTimeMessage( iPlayer, iTime)
{
    message_begin( MSG_ONE_UNRELIABLE, g_nMsgBarTime, _, iPlayer );
    write_short( iTime );
    message_end( );
}

public taskHealReceiver( szParams[ ] )
{
    new iPlayer = szParams[ 0 ];
    new iTarget = szParams[ 1 ];

    if ( IsUserConnected( iTarget ) && is_user_alive( iTarget ) )
    {
    set_user_health( iTarget, 100 );
    }

    if ( IsUserConnected( iPlayer ) )
    {
    if ( is_user_alive( iPlayer ) )
    {
    set_view( iPlayer, CAMERA_NONE );
    }
    ClearUserHealthKit( iPlayer );
    }

    remove_entity( find_ent_by_model( iPlayer, "info_target", g_MedKit ) );
}

public taskHealHimself( iPlayer )
{
    if ( IsUserConnected( iPlayer ) )
    {
    if ( is_user_alive( iPlayer ) )
    {
    set_user_health( iPlayer, 100 );
    
    set_view( iPlayer, CAMERA_NONE );
    }
    ClearUserHealthKit( iPlayer );
    }
} 
