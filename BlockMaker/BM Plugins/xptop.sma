/*

	/xptop - Това е топ, който изкарва статистика от nvault файл на дадени играчи и ги подрежда.
	Можете да смените файла с какъвто искате, може да не е за HNS XP, а за друг.
	За смяна на файла - ред 34

*/

#include <amxmodx>
#include <nvault_util>
#define PLUGIN "xptop"
#define VERSION "1.0" 
#define AUTHOR "dedi"
 
new   gNameVault;

new const g_szCups[ ][ ] = {
    "https://cdn1.iconfinder.com/data/icons/fatcow/16x16/cup_gold.png",
    "https://cdn1.iconfinder.com/data/icons/fatcow/16x16/cup_bronze.png",
    "https://cdn1.iconfinder.com/data/icons/fatcow/16x16/cup_silver.png"
}; 


public plugin_init() { 
register_plugin(PLUGIN, VERSION, AUTHOR) 
register_clcmd("say /xptop", "CmdTop")
}
 

SortTopPlayers( &Array:aNames,  &Array:aXPs )
{
    aNames = ArrayCreate( 32 );
    aXPs = ArrayCreate( 1 );
    new hVault = nvault_util_open( "hnsxp" );
    new iCount = nvault_util_count( hVault );
    new iPos;

    new szXP[ 11 ], iTimeStamp, szName[ 32 ];


    for( new i = 0; i < iCount; i++ )
    {

        iPos = nvault_util_read( hVault, iPos, szName, charsmax( szName ), szXP, charsmax( szXP ), iTimeStamp );

        nvault_get( gNameVault, szName, charsmax( szName ) );
        
        ArrayPushString( aNames, szName );
        ArrayPushCell( aXPs, str_to_num( szXP ) );
    }
    
    nvault_util_close( hVault );
    
    new iXP;
    for( new i = 0, j; i < ( iCount - 1 ); i++ )
    {
 
        iXP = ArrayGetCell( aXPs, i );
     
   
        for( j = i + 1; j < iCount; j++ )
        {
if(i > 16){
break;
}
if( iXP < ArrayGetCell( aXPs, j ) )
        {
                ArraySwap( aNames, i, j );
                ArraySwap( aXPs, i, j );
                
                i--;
                
                break;
            }
        }
    }
    
    return iCount;
}


public CmdTop(id)
{
    new Array:aNames, Array:aXPs;
    new iTotal = SortTopPlayers(aNames, aXPs);
    new szHTML[2500], iLen;
    iLen = copy(szHTML, charsmax(szHTML), "<html><body><h2>XP TOP 15</h2><br><table><tr><th>#.</th><th>Name</th><th>XP</th></tr>");
    new iMaxColors = sizeof( g_szCups );
    new szName[156];
    for( new i = 0; i < 15; i++ )
    {
        if( i < iTotal )
        {
            ArrayGetString(aNames, i, szName, charsmax(szName));
            replace_all(szName, charsmax(szName), "&", "&amp;");
            replace_all(szName, charsmax(szName), "<", "&lt;");
            replace_all(szName, charsmax(szName), ">", "&gt;");
            
            if( i < iMaxColors ) {
            iLen += formatex(szHTML[iLen], charsmax(szHTML)-iLen, "<tr><td><img src=^"%s^"/></td><td>%s</td><td>%i</td></tr>",g_szCups[ i ], szName, ArrayGetCell(aXPs, i));
            } else {
            iLen += formatex(szHTML[iLen], charsmax(szHTML)-iLen, "<tr><td>%i.</td><td>%s</td><td>%i</td></tr>", (i + 1), szName, ArrayGetCell(aXPs, i));
}
        }
        else
        {
            iLen += copy(szHTML[iLen], charsmax(szHTML)-iLen, "<tr><td></td><td></td><td></td></tr>");
        }
    }
    
    iLen += copy(szHTML[iLen], charsmax(szHTML)-iLen, "</table></body></html>");
    
    ArrayDestroy(aNames);
    ArrayDestroy(aXPs);
    
    show_motd(id, szHTML, "XP TOP 15");
    
    return PLUGIN_HANDLED;
}

/*Function()
{
	
}*/
