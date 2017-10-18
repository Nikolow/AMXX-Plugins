#include <amxmodx>
#include <cstrike>
#include <hamsandwich>
#include <fun>
#include <colorchat>

#define MAX_PLAYERS    32

#define EXTRA_HEALTH 50

new const VERSION[] = "1.2"

new bool:b_BetHappening
new bool:b_CtWon
new bool:b_TerrWon

new bool:b_Bet[MAX_PLAYERS+1]
new bool:b_ChoseTerr[MAX_PLAYERS+1]
new bool:b_ChoseCt[MAX_PLAYERS+1]
new bool:b_ChoseNothing[MAX_PLAYERS+1]

new bool:b_Respawn[MAX_PLAYERS+1]

new trName[32]

new pcTimeAfter

public plugin_init()
{
    register_plugin( "HnS Betting", VERSION, "Wrecked" ) // :avast:
    
    register_event( "DeathMsg", "EV_DeathMsg", "a" )
    
    register_logevent( "LEV_RoundStart", 2, "1=Round_Start" )
    
    pcTimeAfter = register_cvar( "hb_time", "10.0" )
}

public LEV_RoundStart()
{
    set_task( get_pcvar_float( pcTimeAfter ), "task_GiveRewards" )
}

public task_GiveRewards()
{
    new iPlayers[32]
    new iNum
    new id
    
    get_players( iPlayers, iNum )
    
    for( new i = 0; i < iNum; i++ )
    {
        id = iPlayers[i]
        
        if( b_Bet[id] )
        {
            if( b_CtWon && b_ChoseCt[id] )
            {
                GIVE_Rewards( id )
            }
            else if( b_TerrWon && b_ChoseTerr[id] )
            {
                GIVE_Rewards( id )
            }
            else
            {
                new num = random_num( 1, 100 )
                
                if( num == 96 )
                {
                    new iWep = give_item( id, "weapon_awp" )
                    
                    cs_set_weapon_ammo( iWep, 1 )
                    cs_set_user_bpammo( id, CSW_AWP, 0 )
                    
                    ColorChat(id, GREY, "^x04WOW^x01! ^x03You ^x01won the^x04 1% chance^x01 to ^x04win^x01 an ^x03awp^x01!" )
                }
            }
        }
    }
}

public EV_DeathMsg()
{
    new victim = read_data( 2 )
    
    if( b_Respawn[victim] )
        set_task( 2.0, "TASK_Respawn", victim )
    
    if( b_BetHappening && cs_get_user_team( victim ) == CS_TEAM_T )
    {
        b_TerrWon = false
        b_CtWon = true
        
        return PLUGIN_HANDLED;
    }
    else if( b_BetHappening && cs_get_user_team( victim ) == CS_TEAM_CT )
    {
        new ctAmt = GetTeams( CS_TEAM_CT )
        
        if( ctAmt == 0 )
        {
            b_CtWon = false
            b_TerrWon = true
        }
        
        return PLUGIN_HANDLED;
    }
    
    new trAmt = GetTeams( CS_TEAM_T )
    
    if( trAmt != 1 )
    {
        return PLUGIN_HANDLED;
    }
    else if( trAmt == 1 )
    {
        new iPlayers[32]
        new iNum
        new tempid
        
        get_players( iPlayers, iNum )
        
        for( new i = 0; i < iNum; i++ )
        {
            tempid = iPlayers[i]
            
            if( !is_user_alive( tempid ) && is_user_connected( tempid ) )
            {
                menu_Bet( tempid )
            }
            
            else if( is_user_alive( tempid ) && cs_get_user_team( tempid ) == CS_TEAM_T )
            {
                get_user_name( tempid, trName, 31 )
            }
        }
        b_BetHappening = true
    }
    return PLUGIN_CONTINUE;
}

public menu_Bet( id )
{
    new menu = menu_create( "Who Will Win?", "menu_BetHandler" )
    
    menu_additem( menu, trName, "1", 0 )
    menu_additem( menu, "The CT's", "2", 0 )
    menu_additem( menu, "I Don't Know", "3", 0 )
    
    menu_setprop( menu, MPROP_EXIT, MEXIT_ALL )
    
    menu_display( id, menu, 0 )
    
    return PLUGIN_CONTINUE;
}

public menu_BetHandler( id, menu, item )
{
    if( item == MENU_EXIT )
    {
        menu_destroy( menu )
        
        return PLUGIN_HANDLED;
    }
    
    new name[64]
    new data[6]
    new access
    new callback
    
    menu_item_getinfo( menu, item, access, data, 5, name, 63, callback )
    
    new choice = str_to_num( data )
    
    switch( choice )
    {
        case 1: // Single Terr
        {
            b_Bet[id] = true
            b_ChoseTerr[id] = true
            b_ChoseCt[id] = false
            b_ChoseNothing[id] = false
        }
        
        case 2: // CT Team
        {
            b_Bet[id] = true
            b_ChoseTerr[id] = false
            b_ChoseCt[id] = true
            b_ChoseNothing[id] = false
        }
        
        case 3: // 1% AWP
        {
            b_Bet[id] = true
            b_ChoseTerr[id] = false
            b_ChoseCt[id] = false
            b_ChoseNothing[id] = true
        }
    }
    
    return PLUGIN_HANDLED;
}

stock GIVE_Rewards( id )
{
    if( !is_user_alive( id ) )
        return PLUGIN_HANDLED;
    
    new rnum = random_num( 1, 4 )
    
    switch( rnum )
    {
        case 1: // scout
        {
            new iWep = give_item( id, "weapon_scout" )
            
            if( iWep > 0 )
            {
                cs_set_weapon_ammo( iWep, 0 )
                cs_set_user_bpammo( id, CSW_SCOUT, 0 )
            }
            
            ColorChat(id, GREY, "^x04You ^x03won ^x01a ^x03scout ^x01with ^x04no ^x03bullets ^x01for placing the ^x04correct ^x03bet^x01!" )
        }
        
        case 2: // nade
        {
            give_item( id, "weapon_hegrenade" )
            
            client_print( id, print_chat, "^x04You ^x03won ^x01a ^x03grenade ^x01for placing the ^x04correct ^x03bet^x01!" )
        }
        
        case 3: // health
        {
            set_user_health( id, get_user_health( id ) + EXTRA_HEALTH )
            
            client_print( id, print_chat, "^x04You ^x03won^x03 +%i ^x04HP ^x01for placing the ^x04correct ^x03bet^x01!", EXTRA_HEALTH )
        }
        
        case 4: // respawn
        {
            b_Respawn[id] = true
            
            client_print( id, print_chat, "^x04You ^x03won ^x01an ^x03extra ^x04respawn ^x01for the ^x03round^x01!" )
        }
    }
    
    return PLUGIN_HANDLED;
}
        
public TASK_Revive( id )
{
    if( !is_user_alive( id ) )
        ExecuteHamB( Ham_CS_RoundRespawn, id )
        
    b_Respawn[id] = false
}

GetTeams( CsTeams:iTeam )
{
    new iPlayers[32]
    new iNum
    
    get_players( iPlayers, iNum )
    
    new goodteam
    
    for( new i = 0; i < iNum; i++ )
    {
        if( cs_get_user_team( iPlayers[i] ) == iTeam )
        {
            goodteam++
        }
    }
    
    return goodteam;
}  