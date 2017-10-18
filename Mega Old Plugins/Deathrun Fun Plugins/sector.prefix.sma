#include <amxmodx>
#include <amxmisc>

#define VERSION    "SECTOR.EDITION"

// Admin Prefix Head
#define FLAGADMINHEAD ADMIN_BAN
#define PREFIXADMINHEAD "Head Admin"

// Member Prefix 
#define FLAGADMINMEMBER ADMIN_RESERVATION
#define PREFIXADMINMEMBER "Fnj Member"

// VIP Prefix
#define FLAGADMINVIP ADMIN_KICK
#define PREFIXADMINVIP "Fnj V.I.P."

// NEW Admin Prefix
#define FLAGADMINNEW ADMIN_IMMUNITY
#define PREFIXADMINNEW "Fnj Admin"

// Admin Prefix User [User]
#define FLAGADMINUSER ADMIN_USER
#define PREFIXADMINUSER "User"


new AdminPrefixHEAD, AdminPrefixMEMBER, NewPrefix, VipPrefix, AdminPrefixUSER;
new SzMaxPlayers, SzSayText;

new SzGTeam[3][] = {
    "Spectator",
    "Terrorist",
    "Counter-Terrorist"
}

public plugin_init()
{
    register_plugin("Admin Sector Prefix", VERSION, "kostov,Dark_Style,Advanced");
    
    // Cvars Plugins
    AdminPrefixHEAD = register_cvar("show_admin_prefix_head", "1");
    AdminPrefixMEMBER = register_cvar("show_admin_prefix_member", "1");
    NewPrefix      = register_cvar("show_new_admin_prefix", "1");
    VipPrefix      = register_cvar("show_vip_admin_prefix", "1");
    AdminPrefixUSER = register_cvar("show_admin_prefix_user", "1");
    
    register_cvar("admin_prefix_version",    VERSION, FCVAR_SERVER|FCVAR_SPONLY);
    set_cvar_string("admin_prefix_version",    VERSION);
    register_clcmd("say", "hook_say");
    register_clcmd("say_team", "hook_say_team");
    
    SzSayText = get_user_msgid ("SayText");
    SzMaxPlayers = get_maxplayers();
    
    register_message(SzSayText, "MsgDuplicate");
}

public MsgDuplicate(id){ return PLUGIN_HANDLED; }

public hook_say(id)
{
    new SzMessages[192], SzName[32];
    new SzAlive = is_user_alive(id);
    new SzGetFlag = get_user_flags(id);
    
    read_args(SzMessages, 191);
    remove_quotes(SzMessages);
    get_user_name(id, SzName, 31);
    
    if(!is_valid_msg(SzMessages))
        return PLUGIN_CONTINUE;
    
    if(get_pcvar_num(AdminPrefixHEAD) && SzGetFlag & FLAGADMINHEAD)(SzAlive ? format(SzMessages, 191, "^4[%s] ^3%s : ^1%s", PREFIXADMINHEAD, SzName, SzMessages) : format(SzMessages, 191, "^1*DEAD* ^4[%s] ^3%s : ^1%s", PREFIXADMINHEAD, SzName, SzMessages));
    else if(get_pcvar_num(AdminPrefixMEMBER) && SzGetFlag & FLAGADMINMEMBER)(SzAlive ? format(SzMessages, 191, "^4(%s) ^3%s : ^1%s", PREFIXADMINMEMBER, SzName, SzMessages) : format(SzMessages, 191, "^1*DEAD* ^4(%s) ^3%s : ^1%s", PREFIXADMINMEMBER, SzName, SzMessages));
    else if(get_pcvar_num(NewPrefix) && SzGetFlag & FLAGADMINNEW)(SzAlive ? format(SzMessages, 191, "^4[%s] ^3%s : ^1%s", PREFIXADMINNEW, SzName, SzMessages) : format(SzMessages, 191, "^1*DEAD* ^4[%s] ^3%s : ^1%s", PREFIXADMINNEW, SzName, SzMessages));
    else if(get_pcvar_num(VipPrefix) && SzGetFlag & FLAGADMINVIP)(SzAlive ? format(SzMessages, 191, "^4[%s] ^3%s : ^1%s", PREFIXADMINVIP, SzName, SzMessages) : format(SzMessages, 191, "^1*DEAD* ^4[%s] ^3%s : ^1%s", PREFIXADMINVIP, SzName, SzMessages));
    else if(get_pcvar_num(AdminPrefixUSER) && SzGetFlag & FLAGADMINUSER)(SzAlive ? format(SzMessages, 191, "^1(%s) ^3%s : ^1%s", PREFIXADMINUSER, SzName, SzMessages) : format(SzMessages, 191, "^1*DEAD* ^1(%s) ^3%s : ^1%s", PREFIXADMINUSER, SzName, SzMessages));
    else if(get_pcvar_num(AdminPrefixHEAD) && !(SzGetFlag & FLAGADMINHEAD))(SzAlive ? format(SzMessages, 191, "^3%s : ^1%s", SzName, SzMessages) : format(SzMessages, 191, "^1*DEAD* ^3%s : ^1%s", SzName, SzMessages));
    else if(get_pcvar_num(AdminPrefixMEMBER) && !(SzGetFlag & FLAGADMINMEMBER))(SzAlive ? format(SzMessages, 191, "^3%s : ^1%s", SzName, SzMessages) : format(SzMessages, 191, "^1*DEAD* ^3%s : ^1%s", SzName, SzMessages));
    else if(get_pcvar_num(NewPrefix) && !(SzGetFlag & FLAGADMINNEW))(SzAlive ? format(SzMessages, 191, "^3%s : ^1%s", SzName, SzMessages) : format(SzMessages, 191, "^1*DEAD* ^3%s : ^1%s", SzName, SzMessages));
    else if(get_pcvar_num(VipPrefix) && !(SzGetFlag & FLAGADMINVIP))(SzAlive ? format(SzMessages, 191, "^3%s : ^1%s", SzName, SzMessages) : format(SzMessages, 191, "^1*DEAD* ^3%s : ^1%s", SzName, SzMessages));
    else if(get_pcvar_num(AdminPrefixUSER) && !(SzGetFlag & FLAGADMINUSER))(SzAlive ? format(SzMessages, 191, "^3%s : ^1%s", SzName, SzMessages) : format(SzMessages, 191, "^1*DEAD* ^3%s : ^1%s", SzName, SzMessages));

    for(new i = 1; i <= SzMaxPlayers; i++)
        {
            if(!is_user_connected(i))
                continue;
        
            if(SzAlive && is_user_alive(i) || !SzAlive && !is_user_alive(i))
                {
                    message_begin(MSG_ONE, get_user_msgid("SayText"), {0, 0, 0}, i);
                    write_byte(id);
                    write_string(SzMessages);
                    message_end();
                }
        }

    return PLUGIN_CONTINUE;
}

public hook_say_team(id){
    new SzMessages[192], SzName[32];
    new SzAlive = is_user_alive(id);
    new SzGetFlag = get_user_flags(id);
    new SzGetTeam = get_user_team(id);

    read_args(SzMessages, 191);
    remove_quotes(SzMessages);
    get_user_name(id, SzName, 31);
    
    if(!is_valid_msg(SzMessages))
        return PLUGIN_CONTINUE;
    
    if(get_pcvar_num(AdminPrefixHEAD) && SzGetFlag & FLAGADMINHEAD)(SzAlive ? format(SzMessages, 191, "^4[%s] ^3%s : ^1%s", PREFIXADMINHEAD, SzName, SzMessages) : format(SzMessages, 191, "^1*DEAD* ^4[%s] ^3%s : ^1%s", PREFIXADMINHEAD, SzName, SzMessages));
    else if(get_pcvar_num(AdminPrefixMEMBER) && SzGetFlag & FLAGADMINMEMBER)(SzAlive ? format(SzMessages, 191, "^1(%s) ^3%s : ^1%s", PREFIXADMINMEMBER, SzName, SzMessages) : format(SzMessages, 191, "^1*DEAD* ^4(%s) ^3%s : ^1%s", PREFIXADMINMEMBER, SzName, SzMessages));
    else if(get_pcvar_num(NewPrefix) && SzGetFlag & FLAGADMINNEW)(SzAlive ? format(SzMessages, 191, "^4[%s] ^3%s : ^1%s", PREFIXADMINNEW, SzName, SzMessages) : format(SzMessages, 191, "^1*DEAD* ^4[%s] ^3%s : ^1%s", PREFIXADMINNEW, SzName, SzMessages));
    else if(get_pcvar_num(VipPrefix) && SzGetFlag & FLAGADMINVIP)(SzAlive ? format(SzMessages, 191, "^4[%s] ^3%s : ^1%s", PREFIXADMINVIP, SzName, SzMessages) : format(SzMessages, 191, "^1*DEAD* ^4[%s] ^3%s : ^1%s", PREFIXADMINVIP, SzName, SzMessages));
    else if(get_pcvar_num(AdminPrefixUSER) && SzGetFlag & FLAGADMINUSER)(SzAlive ? format(SzMessages, 191, "^1(%s) ^3%s : ^1%s", PREFIXADMINUSER, SzName, SzMessages) : format(SzMessages, 191, "^1*DEAD* ^1(%s) ^3%s : ^1%s", PREFIXADMINUSER, SzName, SzMessages));
    else if(get_pcvar_num(AdminPrefixHEAD) && !(SzGetFlag & FLAGADMINHEAD))(SzAlive ? format(SzMessages, 191, "^3%s : ^1%s", SzName, SzMessages) : format(SzMessages, 191, "^1*DEAD* ^3%s : ^1%s", SzName, SzMessages));
    else if(get_pcvar_num(AdminPrefixMEMBER) && !(SzGetFlag & FLAGADMINMEMBER))(SzAlive ? format(SzMessages, 191, "^3%s : ^1%s", SzName, SzMessages) : format(SzMessages, 191, "^1*DEAD* ^3%s : ^1%s", SzName, SzMessages));
    else if(get_pcvar_num(NewPrefix) && !(SzGetFlag & FLAGADMINNEW))(SzAlive ? format(SzMessages, 191, "^3%s : ^1%s", SzName, SzMessages) : format(SzMessages, 191, "^1*DEAD* ^3%s : ^1%s", SzName, SzMessages));
    else if(get_pcvar_num(VipPrefix) && !(SzGetFlag & FLAGADMINVIP))(SzAlive ? format(SzMessages, 191, "^3%s : ^1%s", SzName, SzMessages) : format(SzMessages, 191, "^1*DEAD* ^3%s : ^1%s", SzName, SzMessages));
    else if(get_pcvar_num(AdminPrefixUSER) && !(SzGetFlag & FLAGADMINUSER))(SzAlive ? format(SzMessages, 191, "^3%s : ^1%s", SzName, SzMessages) : format(SzMessages, 191, "^1*DEAD* ^3%s : ^1%s", SzName, SzMessages));
    
    for(new i = 1; i <= SzMaxPlayers; i++)
        {
            if(!is_user_connected(i))
                continue;
            
            if(get_user_team(i) != SzGetTeam)
                continue;
            
            if(SzAlive && is_user_alive(i) || !SzAlive && !is_user_alive(i))
                {
                    message_begin(MSG_ONE, get_user_msgid("SayText"), {0, 0, 0}, i);
                    write_byte(id);
                    write_string(SzMessages);
                    message_end();
                }
        }

    return PLUGIN_CONTINUE;
}


bool:is_valid_msg(const SzMessages[]){
    if( SzMessages[0] == '@'
    || !strlen(SzMessages)){ return false; }
    return true;
}  
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1026\\ f0\\ fs16 \n\\ par }
*/
