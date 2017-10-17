/*

         Разширен Blockmaker Shop, Който е опростен и лесно редактируем.
         Работи с пари.
         Има опция за купуване на XP от магазина и трябва допълнителен hns xp non steam плъгин.
         Има и опция за Anti Frost, тоест ще трябва и плъгина frostnades с натив за frost immune.
 
*/

#include < amxmodx >
#include < fun >
#include < cstrike >
#include < hamsandwich >
#include < engine >
#include <frost>
#include <hnsxp>
 
#define FALL_VELOCITY 350.0
 
new bool:szUseRespawn[ 33 ] = false, bool:szOnePower[ 33 ] = false,
 
bool:szGodmode[ 33 ] = false, bool:szCam[ 33 ] = false,bool:szGravity[ 33 ] = false, bool:szSpeed[ 33 ]  = false,
bool:szStealth[ 33 ] = false, bool:szAntiFrost[ 33 ] = false, bool:szAntiFlash[ 33 ] = false, bool:szFallDamage[ 33 ],
 szMsgScreenFade;
 
new szGrenadesNames[][] ={
        "Frostnade",
        "Flashbang",
        "Explosive"
}
new szGrenadesItems[][] ={
        "weapon_smokegrenade",
        "weapon_flashbang",
        "weapon_hegrenade"
}
new szGrenadesAmmo[] ={
        CSW_SMOKEGRENADE,
        CSW_FLASHBANG,
        CSW_HEGRENADE
}
new szGrenadesPrices[] ={
        7000,
        3500,
        6000
}
new szHealthNames[][] ={
        "+25 Health",
        "+50 Health",
        "+75 Health",
        "+100 Health"
}
new szHealthPrices[] ={
        1000,
        2000,
        3000,
        4000
}
new szHealthItems[] ={
        25,
        50,
        75,
        100
}
new szArmorNames[][] ={
        "+25 Armor",
        "+50 Armor",
        "+75 Armor",
        "+100 Armor"
}
new szArmorPrices[] ={
        1000,
        2000,
        3000,
        4000
}
new szArmorItems[] ={
        25,
        50,
        75,
        100
}
new szWeaponsNames[][] ={
        "Ak47 2 Bullets",
        "M4A1 2 Bullets",
        "Famas 2 Bullets",
        "M3 1 Bullet",
        "Deagle 1 Bullet",
        "AWP 1 Bullet"
}
new szWeaponsItems[][] ={
        "weapon_ak47",
        "weapon_m4a1",
        "weapon_famas",
        "weapon_m3",
        "weapon_deagle",
        "weapon_awp"
}
new szWeaponsAmmo[] ={
        CSW_AK47,
        CSW_M4A1,
        CSW_FAMAS,
        CSW_M3,
        CSW_DEAGLE,
        CSW_AWP
}
new szWeaponsPrices[] ={
        10000,
        10000,
        12000,
        8000,
        12000,
        16000
}
new szWeaponsBullets[] = {
        2,
        2,
        2,
        1,
        1,
        1
}
new szPowersNames[][] = {
        "Godmode 10 Seconds",
        "Camouflage 20 Seconds",
        "0.5 Gravity 20 Seconds",
        "x2 Speed 20 Seconds",
        "Stealth 20 Seconds",
        "Anti-Frost One Round",
        "Anti-Flash One Round",
        "No Fall Damage One Round"
}
new szPowersPrices[] = {
        12000,
        5000,
        8000,
        6000,
        6000,
        8000,
        8000,
        5000
}
new szXPNames[][] ={
        "+25 XP",
        "+50 XP",
        "+75 XP",
        "+100 XP"
}
new szXPPrices[] ={
        4000,
        8000,
        12000,
        16000
}
new szXPItems[] ={
        25,
        50,
        75,
        100
}
 
public plugin_init() {
        register_plugin("Blockmaker Shop", "1.0", "Molten");
       
        register_clcmd( "say /shop", "CmdMainShopMenu" );
       
       
        register_event( "CurWeapon", "CmdSpeed", "be", "1=1" );
       
        RegisterHam( Ham_Spawn, "player", "CmdPlayerSpawn", 1 );
       
        register_event("ScreenFade", "EventFlash", "be", "4=255", "5=255", "6=255", "7>199");
        szMsgScreenFade = get_user_msgid("ScreenFade");
}
 
public CmdMainShopMenu( id ){
        new szMenu = menu_create("\r[\w BlockMaker Shop \r]\w Main Shop Menu", "subMainShop" );
        menu_additem( szMenu, "\wGrenades Shop", "0" );
        menu_additem( szMenu, "\wHealth Shop", "1" );
        menu_additem( szMenu, "\wArmor Shop", "2" );
        menu_additem( szMenu, "\wWeapons Shop", "3" );
        menu_additem( szMenu, "\wPowers Shop", "4" );
        menu_additem( szMenu, "\wXP Shop^n", "5" );
        menu_additem( szMenu, "\rRespawn \w[\d 16000$ \w]\d One Per Map^n", "6" );
       
        menu_additem( szMenu, "\wExit", "0" );
        menu_setprop( szMenu, MPROP_NUMBER_COLOR, "\r")
        menu_setprop( szMenu, MPROP_PERPAGE, 0)
        menu_display( id, szMenu )
}
 
public subMainShop(id, szMenu, szItem){
        menu_destroy( szMenu )
        if( szItem != MENU_EXIT ){
                CmdCreateShop(id, szItem);
        }
}
 
public client_PreThink( client ) {
       
}
 
public CmdCreateShop(id, szShop){
        switch( szShop ){
                case 0:{
                        new szMenu = menu_create( "\r[\w BlockMaker \r]\w^nGrenades Shop Menu", "subGrenades" );
                        menu_additem( szMenu, "\wFrostnade \y[\r 7000$ \y]", "0" );
                        menu_additem( szMenu, "\wFlashbang \y[\r 3500$ \y]", "1" );
                        menu_additem( szMenu, "\wExplosive \y[\r 6000$ \y]", "2" );
                        menu_display( id, szMenu );
                }
                case 1:{
                        new szMenu = menu_create( "\r[\w BlockMaker \r]\w^nHealth Shop Menu", "subHealth" );
                        menu_additem( szMenu, "\w+25 HP\y[\r 1000$ \y]", "0" );
                        menu_additem( szMenu, "\w+50 HP\y[\r 2000$ \y]", "1" );
                        menu_additem( szMenu, "\w+75 HP\y[\r 3000$ \y]", "2" );
                        menu_additem( szMenu, "\w+100 HP\y[\r 4000$ \y]", "3" );
                        menu_display( id, szMenu );
                }
                case 2:{
                        new szMenu = menu_create( "\r[\w BlockMaker \r]\w^nArmor Shop Menu", "subArmor" );
                        menu_additem( szMenu, "\w+25 AP\y[\r 1000$ \y]", "0" );
                        menu_additem( szMenu, "\w+50 AP\y[\r 2000$ \y]", "1" );
                        menu_additem( szMenu, "\w+75 AP\y[\r 3000$ \y]", "2" );
                        menu_additem( szMenu, "\w+100 AP\y[\r 4000$ \y]", "3" );
                        menu_display( id, szMenu );
                }
                case 3:{
                        new szMenu = menu_create( "\r[\w BlockMaker \r]\w^nWeapons Shop Menu", "subWeapons" );
                        menu_additem( szMenu, "\wAK47\r [\w 2 \r] \y[\r 10000$ \y]", "0" );
                        menu_additem( szMenu, "\wM4A1\r [\w 2 \r] \y[\r 10000$ \y]", "1" );
                        menu_additem( szMenu, "\wFamas\r [\w 2 \r] \y[\r 12000$ \y]", "2" );
                        menu_additem( szMenu, "\wM3\r [\w 1 \r] \y[\r 8000$ \y]", "3" );
                        menu_additem( szMenu, "\wDeagle\r [\w 1 \r] \y[\r 12000$ \y]", "4" );
                        menu_additem( szMenu, "\wAwp\r [\w 1 \r] \y[\r 16000$ \y]", "5" );
                        menu_display( id, szMenu );
                }
                case 4:{
                        new szMenu = menu_create( "\r[\w BlockMaker \r]\w^nPowers Shop Menu", "subPowers" );
                        menu_additem( szMenu, "\wGodmode \y[\r 12000$ \y]\d 10 Seconds", "0" );
                        menu_additem( szMenu, "\wCamouflage \y[\r 6000$ \y]\d 20 Seconds", "1" );
                        menu_additem( szMenu, "\w0.5 Gravity \y[\r 8000$ \y]\d 20 Seconds", "2" );
                        menu_additem( szMenu, "\wx2 Speed \y[\r 6000$ \y]\d 20 Seconds", "3" );
                        menu_additem( szMenu, "\wStealth \y[\r 8000$ \y]\d 20 Seconds", "4" );
                        menu_additem( szMenu, "\wAnti-Frost \y[\r 12000$ \y]\d One Round", "5" );
                        menu_additem( szMenu, "\wAnti-Flash \y[\r 8000$ \y]\d One Round", "6" );
                        menu_additem( szMenu, "\wNo Fall Damage \y[ \r 5000$ \y]\d One Round", "7" );
                        menu_display( id, szMenu );
                }
                case 5:{
                        new szMenu = menu_create( "\r[\w BlockMaker \r]\w^nXP Shop Menu", "subXP" );
                        menu_additem( szMenu, "\w+25 XP\y[\r 4000$ \y]", "0" );
                        menu_additem( szMenu, "\w+50 XP\y[\r 8000$ \y]", "1" );
                        menu_additem( szMenu, "\w+75 XP\y[\r 12000$ \y]", "2" );
                        menu_additem( szMenu, "\w+100 XP\y[\r 16000$ \y]", "3" );
                        menu_display( id, szMenu );
                }
                case 6:{
                        if ( szUseRespawn[id] ){
                                ColorChat(id, "Sorry, this item can only be used once per map.")
                        }
                        else if(cs_get_user_money(id) < 16000 ) {
                                ColorChat( id, "Your missing^4 %i$^1 to buy the item:^3 Respawn", 16000 - cs_get_user_money(id) );
                        }
                        else if(is_user_alive(id)){
                                ColorChat(id, "^4You're alive.")
                        }
                        else {
                                ExecuteHamB(Ham_CS_RoundRespawn, id)
                                new szName[ 32 ]; get_user_name( id, szName, charsmax( szName ) );
                                ColorChat(0, "^4%s^1 have bought:^3 Respawn",szName)
                                cs_set_user_money( id, cs_get_user_money(id) - 16000 );
                                szUseRespawn[ id ] = true;
                        }
                        CmdMainShopMenu(id)
                }
        }
}
 
public subGrenades(id, szMenu, szItem){
        if ( cs_get_user_team(id) == CS_TEAM_CT ){
                ColorChat(id, "This shop can only be used by^4 Terrorists")
                return PLUGIN_HANDLED;
        }
        else {
                if ( !is_user_alive(id) ) {
                        ColorChat(id, "This menu can only use by^4 Alive Players")
                        return PLUGIN_HANDLED;
                }
                else if ( user_has_weapon( id, szGrenadesAmmo[ szItem ] ) ){
                        ColorChat( id, "^1You already have:^3 %s", szGrenadesNames[ szItem ] );
                        return PLUGIN_HANDLED;
                }
                else if ( cs_get_user_money(id) < szGrenadesPrices[szItem ] ){
                        ColorChat( id, "Your missing^4 %i$^1 to buy the item:^3 %s", szGrenadesPrices[ szItem ] - cs_get_user_money(id), szGrenadesNames[ szItem ] );  
                        return PLUGIN_HANDLED;
                }
                else {
                        cs_set_user_money(id, cs_get_user_money(id) - szGrenadesPrices[ szItem ])
                        new szName[ 32 ]; get_user_name( id, szName, charsmax( szName ) );
                        ColorChat( 0, "^4%s^1 have bought:^3 %s", szName, szGrenadesNames[ szItem ] );
                        give_item( id, szGrenadesItems[ szItem ] );
                        return PLUGIN_HANDLED;
                }
        }
        CmdMainShopMenu(id)
        return 1;
}
public subHealth(id, szMenu, szItem){
        if ( !is_user_alive(id) ) {
                ColorChat(id, "This menu can only use by^4 Alive Players");
                return PLUGIN_HANDLED;
        }
        if ( cs_get_user_money(id) < szHealthPrices[szItem ] ){
                ColorChat( id, "Your missing^4 %i$^1 to buy the item:^3 %s", szHealthPrices[ szItem ] - cs_get_user_money(id), szHealthNames[ szItem ] );      
                return PLUGIN_HANDLED;
        }
        cs_set_user_money(id, cs_get_user_money(id) - szHealthPrices[ szItem ] );
        new szName[ 32 ]; get_user_name( id, szName, charsmax( szName ) );
        ColorChat( 0, "^4%s^1 have bought:^3 %s", szName, szHealthNames[ szItem ] );
        set_user_health(id, get_user_health(id) + szHealthItems[ szItem ] );
        CmdMainShopMenu(id);
        return 1;
}
public subArmor(id, szMenu, szItem){
        if ( !is_user_alive(id) ) {
                ColorChat(id, "This menu can only use by^4 Alive Players");
                return PLUGIN_HANDLED;
        }
        else if ( cs_get_user_money(id) < szArmorPrices[szItem ] ){
                ColorChat( id, "Your missing^4 %i$^1 to buy the item:^3 %s", szArmorPrices[ szItem ] - cs_get_user_money(id), szArmorNames[ szItem ] );
                return PLUGIN_HANDLED;
        }
        else {
                cs_set_user_money(id, cs_get_user_money(id) - szArmorPrices[ szItem ] );
                new szName[ 32 ]; get_user_name( id, szName, charsmax( szName ) );
                ColorChat( 0, "^4%s^1 have bought:^3 %s", szName, szArmorNames[ szItem ] );
                set_user_armor(id, get_user_armor(id) + szArmorItems[ szItem ] );
                return PLUGIN_HANDLED;
        }
        CmdMainShopMenu(id)
        return 1;
}
 
public subWeapons(id, szMenu, szItem){
        if ( cs_get_user_team(id) == CS_TEAM_CT ){
                ColorChat(id, "This shop can only be used by^4 Terrorists");
                return PLUGIN_HANDLED;
        }
        else {
                if ( !is_user_alive(id) ) {
                        ColorChat(id, "This menu can only use by^4 Alive Players");
                        return PLUGIN_HANDLED;
                }
                else if ( user_has_weapon( id, szWeaponsAmmo[ szItem ] ) ){
                        ColorChat( id, "^1You already have:^3 %s", szWeaponsNames[ szItem ] ); 
                        return PLUGIN_HANDLED;
                }
                else if ( cs_get_user_money(id) < szWeaponsPrices[szItem ] ){
                        ColorChat( id, "Your missing^4 %i$^1 to buy the item:^3 %s", szWeaponsPrices[ szItem ] - cs_get_user_money(id), szWeaponsNames[ szItem ] );    
                        return PLUGIN_HANDLED;
                }
                else {
                        cs_set_user_money(id, cs_get_user_money(id) - szWeaponsPrices[ szItem ] );
                        new szName[ 32 ]; get_user_name( id, szName, charsmax( szName ) );
                        ColorChat( 0, "^4%s^1 have bought:^3 %s", szName, szWeaponsNames[ szItem ] );
                        cs_set_weapon_ammo( give_item( id, szWeaponsItems[ szItem ] ), szWeaponsBullets[ szItem ] );
                        return PLUGIN_HANDLED;
                }
        }
        CmdMainShopMenu(id)
        return 1;
}
 
public subPowers(id, szMenu, szItem){
        if ( szOnePower[id] ){
                ColorChat(id, "You can only use ^4One Power^1 per time.")
                CmdMainShopMenu(id)
                return 1;
        }
       
        if ( cs_get_user_team( id ) == CS_TEAM_T && ( szItem == 5 || szItem == 6 ) )
        {
                ColorChat(id, "Only ^x03Counter-Terrorist ^x01can buy this item." );
                return 1;
        }
       
        if ( !is_user_alive(id) ) {
                ColorChat(id, "This menu can only use by^4 Alive Players")
        }
        else if ( cs_get_user_money(id) < szPowersPrices[szItem ] ){
                ColorChat( id, "Your missing^4 %i$^1 to buy the item:^3 %s", szPowersPrices[ szItem ] - cs_get_user_money(id), szPowersNames[ szItem ] );      
                return PLUGIN_HANDLED;
        }
        else {
                cs_set_user_money(id, cs_get_user_money(id) - szPowersPrices[ szItem ])
                new szName[ 32 ]; get_user_name( id, szName, charsmax( szName ) );
                ColorChat( 0, "^4%s^1 have bought:^3 %s", szName, szPowersNames[ szItem ] );
                szOnePower[id] = true;
                switch ( szItem ){
                        case 0:{
                                set_user_godmode(id, 1)&&set_task(10.0, "CmdRemovePowers", id);
                                szGodmode[id] = true;
                        }
                        case 1:{
                                if(cs_get_user_team(id) == CS_TEAM_CT){
                                        cs_set_user_model(id, "gurila")
                                }
                                else if(cs_get_user_team(id) == CS_TEAM_T){
                                        cs_set_user_model(id, "gsg9")
                                }
                                set_task(20.0, "CmdRemovePowers", id)
                                szCam[id] = true;
                        }
                        case 2:{
                                set_user_gravity(id, 0.5)&&set_task(20.0, "CmdRemovePowers", id)
                                szGravity[id] = true;
                        }
                        case 3:{
                                CmdSpeed(id)
                                set_task(20.0, "CmdRemovePowers", id)
                                szSpeed[id]  = true;
                        }
                        case 4:{
                                set_user_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderTransAlpha, 15)&&set_task(20.0, "CmdRemovePowers", id)
                                szStealth[id] = true;
                        }
                        case 5:{
                                add_user_immune( id );
                                szAntiFrost[id] = true;
                        }
                        case 6: szAntiFlash[id] = true;
                       
                        case 7: szFallDamage[id] = true;
                }
               
        }
        CmdMainShopMenu(id)
        return 1;
}
public subXP(id, szMenu, szItem){
        if ( cs_get_user_money(id) < szPowersPrices[szItem ] ){
                ColorChat( id, "Your missing^4 %i$^1 to buy the item:^3 %s", szXPPrices[ szItem ] - cs_get_user_money(id), szXPNames[ szItem ] );      
                return PLUGIN_HANDLED;
        }
        else {
                cs_set_user_money(id, cs_get_user_money(id) - szXPPrices[ szItem ])
                new szName[ 32 ]; get_user_name( id, szName, charsmax( szName ) );
                ColorChat( 0, "^4%s^1 have bought:^3 %s", szName, szXPNames[ szItem ] );
                hnsxp_set_user_xp(id, szXPItems[ szItem ] )
                return PLUGIN_HANDLED;
        }
        CmdMainShopMenu(id)
        return 1;
}
public CmdRemovePowers(id){
        if ( szGodmode[id] ){
                szGodmode[id] = false;
                set_user_godmode( id, 0 );
                ColorChat(id, "^3Godmode^1 is now set to:^4 Off")
        }
        else if ( szCam[id] ){
                szCam[id] = false;
                cs_reset_user_model(id);
                ColorChat(id, "^4Model^1 is now set to:^3 Normal")
        }
        else if ( szGravity[id] ){
                szGravity[id] = false;
                set_user_gravity( id, 1.0 );
                ColorChat(id, "^4Gravity^1 is now set to:^3 800")
        }
        else if ( szSpeed[id] ){
                szSpeed[id]  = false;
                set_user_maxspeed( id, get_user_maxspeed( id ) - 220 );
                ColorChat(id, "^4Speed^1 is now set to:^3 Normal")
        }
        else if ( szStealth[id] ){
                szStealth[id] = false;
                set_user_rendering( id, kRenderFxGlowShell, 0, 0, 0, kRenderTransAlpha, 255 );
                ColorChat(id, " ^4Stealth^1 is now set to:^3 Visible")
        }
        else if ( szAntiFrost[id] ){
                szAntiFrost[id] = false;
                remove_user_immune( id );
                ColorChat(id, "^4Anti-Frost^1 is now set to:^3 Off")
        }
        else if ( szAntiFlash[id] ){
                szAntiFlash[id] = false;
                ColorChat(id, "^4Anti-Flash^1 is now set to:^3 Off")
        }
       
        else if ( szFallDamage[id] ) {
                szFallDamage[id] = false;
                ColorChat(id, "^x03No Fall Damage ^x03is now set to: ^x03Off" );
        }
        szOnePower[id] = false;
}
public CmdSpeed(id){
        if ( !szSpeed[id] ) return 0;
        set_user_maxspeed( id, get_user_maxspeed( id ) + 220 );
        return 0;
}
 
public CmdPlayerSpawn(id) {
        CmdRemovePowers(id);
}
public EventFlash(id){
        if ( szAntiFlash[id] ){
                message_begin( MSG_ONE, szMsgScreenFade, {0,0,0}, id );
                write_short( 1 );
                write_short( 1 );
                write_short( 1 );
                write_byte( 0 );
                write_byte( 0 );
                write_byte( 0 );
                write_byte( 255 );
                message_end( );
        }
}
stock ColorChat( const id, const string[], any:... ){
        new msg[191], players[32], count = 1;
       
        static len; len = formatex(msg, charsmax(msg), "^3[^4 BlockMaker Shop ^3]^1 ");
        vformat(msg[len], charsmax(msg) - len, string, 3);
       
        if(id)  players[0] = id;
        else    get_players(players,count,"ch");
       
        for (new i = 0; i < count; i++){
                if(is_user_connected(players[i])){
                        message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("SayText"),_, players[i]);
                        write_byte(players[i]);
                        write_string(msg);
                        message_end();
                }
        }
}
