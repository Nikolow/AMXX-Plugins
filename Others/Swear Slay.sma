/*

	При намиране на дума от swer.ini, плъгина кара играчът да се САМОУБИЕ с clien_cmd.
	Също така му изкарва и худ съобщение.
	Плъгина иска пренаписване !

*/

#include <amxmodx> 
#include <fun>
#define MAX_WORDS 4096 
new g_swearsFile[] = "addons/amxmodx/configs/swear.ini" 
#define PUNISH_PLAYER   1 
#define alive   1 
new g_swearsNames[MAX_WORDS][32] 
new g_swearsNum 
public plugin_init() 
{ 
 register_plugin("Swear Slay","1.0","Advanced") 
 register_clcmd("say","swearPunish") 
 register_clcmd("say_team","swearPunish")
 register_cvar("sw_mode","1")
 register_cvar("sw_slap","50.0")
 register_cvar("sw_admin","25.0")
 readList( g_swearsFile )
 return PLUGIN_CONTINUE 
} 
readList(filename[]) 
{ 
 if(!file_exists(filename) ){
  log_message("Swear Filter: file %s not found", filename) 
  return 
 } 
 new iLen 
 while( g_swearsNum < MAX_WORDS && read_file(filename, g_swearsNum ,g_swearsNames[g_swearsNum][1],30,iLen) ) 
 { 
 g_swearsNames[g_swearsNum][0] = iLen 
 ++g_swearsNum 
 }
 log_message("Swear Filter: loaded %d words",g_swearsNum ) 
} 
#if PUNISH_PLAYER == 1 
public plugin_precache() 
{
 precache_sound( "ambience/thunder_clap.wav")
 return PLUGIN_CONTINUE 
}
#endif 
public swearPunish(id) 
{
 new szSaid[192]
 read_args(szSaid,191)
 new bool:found = false
 new pos, i = 0
 while ( i < g_swearsNum )
 {
 if ( (pos = containi(szSaid,g_swearsNames[i][1])) != -1 ){ 
  new len = g_swearsNames[i][0] 
  while(len--)
  szSaid[pos++] = ' '
  found = true 
  continue
 }
 ++i
 }
 if ( found ){ 
  new cmd[32]
  read_argv(0,cmd,31)
  if(get_cvar_num("sw_admin") == 1){
   if (get_user_flags(id)&ADMIN_IMMUNITY){
    return PLUGIN_HANDLED
    }
 }              
  engclient_cmd(id,cmd,szSaid)    
  #if PUNISH_PLAYER == 1 
  if(is_user_alive(id) == 1){
   if(get_cvar_num("sw_mode") == 0){
         new pfrags = get_user_frags(id)
         set_user_frags(id,pfrags -1)
         set_hudmessage(random(255),random(255),random(255), 0.05, 0.50, 2, 0.1, 10.0, 0.02, 0.02, 11)         
         show_hudmessage(id,"xaxaxaxaxaxaxaxaxaxaxaxa")
         return PLUGIN_HANDLED
 }
  set_hudmessage(random(255),random(255),random(255), 0.05, 0.50, 2, 0.5, 10.0, 0.05, 0.05, 11)        
  show_hudmessage(id,"[xD-GaminG 2 Swear Rules]^n1. Don't Swear players / admins^n2. Don't spores with players / admins^n^nIf you do NOT follow the Rules will be punished with SLAY^n^n^nIf you want READ server Rules type /rules")
  client_cmd(id, "kill")
  } 
} 
#endif       
 return PLUGIN_CONTINUE 
}  