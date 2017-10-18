#include < amxmodx >
#include < amxmisc >
#include < cstrike >
#include < nvault >

new const VERSION[] = "0.0.6";
new const PREFIX[] = "[EasyBlock] ";

new Connects[ 33 ];

new g_iMsgSayText;
new g_vSaveFile;

new iPlayers[ 33 ][ 32 ];
new iNum[ 33 ];

public plugin_init()
{
    register_plugin( "Connections Counter", VERSION, "Advanced" );
    
    register_cvar( "connects_count", VERSION, FCVAR_SERVER | FCVAR_SPONLY ); 
    
    g_iMsgSayText = get_user_msgid( "SayText" );
    
    g_vSaveFile = nvault_open( "ConnectCount" );
}

public client_putinserver( id )
{
    if( !is_user_bot( id ) )
    {
        if( task_exists( id ) )
        {
            remove_task( id );
        }
        
        LoadData( id );
        ++Connects[ id ];
        
        if ( is_user_admin( id ) )
        {
        }
        set_task( 2.0, "PrintZ0r", id ); 
    }
}

public PrintZ0r( id )
{
    new szName[ 33 ];
    new szMessage[ 256 ];
    get_user_name( id, szName, 32 );
    format( szMessage, 255, "^x04%s^x03%s ^x01have joined with^x04 %i^x03 Connections.", PREFIX, szName, Connects[ id ] );
    Print( 0, 1, szMessage )
}

public client_disconnect( id ) 
{  
    if( !is_user_bot( id ) )
    {
        SaveData( id );
        if( task_exists( id ) )
        {
            remove_task( id );
        }
    }
}  

public SaveData( id ) 
{ 
    new szAuthID[ 35 ];
    new vaultkey[ 33 ], vaultdata[ 13 ]; 
    
    get_user_authid( id, szAuthID, 34 );
    
    format( vaultkey, 32, "%s", szAuthID );
    format( vaultdata, 12," %i ", Connects[ id ] ); 

    nvault_set( g_vSaveFile, vaultkey, vaultdata ); 
    
    return PLUGIN_CONTINUE; 
}  

public LoadData( id ) 
{ 
    new szAuthID[ 35 ]; 
    new vaultkey[ 33 ], vaultdata[ 13 ];
    new ConnectCount[ 33 ];
    
    get_user_authid( id, szAuthID, 34 ); 
    
    format( vaultkey, 32, "%s", szAuthID ); 
    format( vaultdata, 12," %i ", Connects[ id ] ); 
    
    nvault_get( g_vSaveFile, vaultkey, vaultdata, 255 ); 
    
    parse( vaultdata, ConnectCount, 32); 
    
    Connects[ id ] = str_to_num( ConnectCount ); 
    
    return PLUGIN_CONTINUE; 
}

public HookSay_Team( id )
{
    new szMessage[ 192 ];
    read_args( szMessage, 191 );
    remove_quotes( szMessage );
    
    new szName[ 33 ], szTeam[ 33 ];
    get_user_name( id, szName, 32 );
        
    new CsTeams:userteam = cs_get_user_team( id );
        
    if ( szMessage[0] == '@' || szMessage[0] == '/' || szMessage[0] == '!' || equal( szMessage, "" ) )
    {
        return PLUGIN_CONTINUE;
    }
    
    if ( userteam == CS_TEAM_T )
    {
        get_players( iPlayers[ id ], iNum[ id ], _, "TERRORIST" );
        szTeam = "(Terrorist)";
    }
    else if ( userteam == CS_TEAM_CT )
    {
        get_players( iPlayers[ id ], iNum[ id ], _, "CT" );
        szTeam = "(Counter-Terrorists)";
    }
    else
    {
        get_players( iPlayers[ id ], iNum[ id ], _, "SPECTATOR" );
        szTeam = "(Spectator)";
    }
    for ( new a = 0; a < iNum[ id ]; ++a )
    {
        new i = iPlayers[ id ][ a ];
        if( cs_get_user_team( i ) != userteam )
        {
            return PLUGIN_HANDLED;
        }
        
        if ( is_user_alive( id ) )
        {
        }
    }
    return PLUGIN_HANDLED;
}

Print( id, colorid, szMessage[], any:... )
{
    message_begin( id ? MSG_ONE_UNRELIABLE : MSG_BROADCAST, g_iMsgSayText, _, id );
    write_byte( colorid );
    write_string( szMessage );
    message_end( );
}  