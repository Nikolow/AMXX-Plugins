#include <amxmodx>
#include <colorchat>

#define MAX_WORDS 100
#define MAX_LEN 32

new gsWords[ MAX_WORDS ][ MAX_LEN ];

new gsGagged[ 1024 ];

new gsWordFile[] = "addons/amxmodx/configs/badwords.ini";

public plugin_init() 
{
    register_plugin( "Word Blocker", "0.1", "hornet" )
    
    register_clcmd( "say", "cmdSay" );
    register_clcmd( "say_team", "cmdSay" );
    
    new text[ MAX_LEN ], txtlen;
    for( new i ; i < file_size( gsWordFile, 1 ) ; i ++ )
    {
        read_file( gsWordFile, i , text, charsmax( text ), txtlen );
        gsWords[ i ] = text;
    }
}

public cmdSay( id )
{    
    new authid[ 32 ];
    get_user_authid( id, authid, charsmax( authid ) );
    format( authid, charsmax( authid ) + 1, "%s ", authid );
    
    if( contain( gsGagged, authid ) != -1 )
    {
        ColorChat(id, RED, "^x04* You^x03 gagged^x01 for^x03 advertising^x04 /^x03 swearing^x01 in^x04 chat^x01 !^x04 [^x03Wait End of Map^x04]" );
        return PLUGIN_HANDLED;
    }
    
    new say[ 256 ];
    read_args( say, charsmax( say ) );
    
    for( new i ; i < sizeof gsWords - 1 ; i ++ )
    {
        if( contain( say, gsWords[ i ] ) != -1 )
        {
            new name[ 32 ];
            get_user_name( id, name, charsmax( name ) );
            
            format( authid, charsmax( authid ) + 1, "%s ", authid );
            format( gsGagged, charsmax( gsGagged ) + charsmax( authid ), "%s%s", gsGagged, authid );
            
            ColorChat(0, RED, "*^x04 %s^x03 punished^x01 because of the^x03 advertising^x04 /^x03 swearing^x01 in^x04 chat", name );
            
            return PLUGIN_HANDLED;
        }
    }
    
    return PLUGIN_CONTINUE;
}  