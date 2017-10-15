#include <amxmodx>
#include <amxmisc>
#include <colorchat>
#include <sqlx>


new bool:iUserCalled[33]; 
new iCacheUserName[34]
new iCacheReporter[34], iCacheUserIp[18]; 

#define CREATE_DB	"CREATE TABLE IF NOT EXISTS `call_admin` (`id` INT(12) NOT NULL AUTO_INCREMENT PRIMARY KEY ,`nick` VARCHAR(30) NOT NULL ,`report` VARCHAR(255) NOT NULL ,`date` VARCHAR(10) NOT NULL ,`time` VARCHAR(10) NOT NULL ,`ip` VARCHAR(22) NOT NULL ,`server` VARCHAR(30) NOT NULL ,`ip2` VARCHAR(16) NOT NULL ,`reporter_name` VARCHAR(30) NOT NULL)"
#define IMPORRT_DB	"INSERT INTO `call_admin` (nick,ip,report,date,time,server,ip2,reporter_name) VALUES ('%s','%s','%s','%s','%s','%s','%s','%s')"



#define szHost  "192.168.1.101"
#define szUser  "root" 
#define szPass  "test1337"
#define szDb    "test"

new Handle:SqlConnection

public plugin_init() 
{
	register_plugin("CallAdmin Mysql","0.1","Nikolow")
	
	register_clcmd("say /call", "cmdCallMenu", ADMIN_ALL); 
	register_clcmd("say /calladmin", "cmdCallMenu", ADMIN_ALL); 
	register_concmd("amx_callreason", "cmdCallReason", ADMIN_ALL); 
}

public plugin_cfg() 
{ 
	SqlConnection = SQL_MakeDbTuple(szHost,szUser,szPass,szDb)
	new QueryCache[1024]
	formatex(QueryCache,1023,CREATE_DB) 
	SQL_ThreadQuery(SqlConnection,"QueryCreateTable",QueryCache)
}

public plugin_end() { SQL_FreeHandle(SqlConnection); } 

public QueryCreateTable(iFailState,Handle:hQuery,szError[],iError,iData[],iDataSize,Float:flQueueTime) 
{
	switch(iFailState) 
	{
		case TQUERY_CONNECT_FAILED: log_amx("Failed to connect to database (%i): %s", iError, szError); 
		case TQUERY_QUERY_FAILED: log_amx("Error on query for QueryCreateTable() (%i): %s", iError, szError);
		default: { /*successfully created tables*/ }
	}
}

public cmdCallMenu(id, level, cid) 
{ 
   if(!cmd_access(id, level, cid, 1)) 
      return PLUGIN_HANDLED; 
    
   new iMenu = menu_create("\rCall Admin Menu:", "cmdCallMenuFunc"); 
   new iPlayers[32], iNum, iTarget; 
   new UserName[34], szTempID[10]; 
   get_players(iPlayers, iNum); 
   for(new i; i < iNum; i++) 
   { 
      iTarget = iPlayers[i]; 
      get_user_name(iTarget, UserName, sizeof UserName - 1); 
      num_to_str(iTarget, szTempID, charsmax(szTempID)); 
      menu_additem(iMenu, UserName, szTempID, _, menu_makecallback("CallMenuPlayers")); 
   } 

   menu_display(id, iMenu, 0); 
   return PLUGIN_HANDLED; 
} 

public CallMenuPlayers(iClient, iMenu, Item) 
{ 
   new iAccess, Info[3], iCallback; 
   menu_item_getinfo(iMenu, Item, iAccess, Info, sizeof Info - 1, _, _, iCallback); 
     
   new iGetID = str_to_num(Info); 
    
   if(access(iGetID, ADMIN_IMMUNITY)) // админи с имунитед не се показват
   { 
      return ITEM_DISABLED; 
   }  
    
   if(iUserCalled[iGetID]) // вече репортнати хора не се показват
   { 
      return ITEM_DISABLED; 
   } 
    
   return ITEM_ENABLED; 
} 

public cmdCallMenuFunc(id, iMenu, Item) 
{ 
   if(Item == MENU_EXIT) 
   { 
      menu_destroy(iMenu); 
      return PLUGIN_HANDLED; 
   } 

   new iData[6], iName[64]; 
   new access, callback; 
   menu_item_getinfo(iMenu, Item, access, iData, charsmax(iData), iName, charsmax(iName), callback); 

   new iTarget = str_to_num(iData); 
   get_user_name(iTarget, iCacheUserName, sizeof iCacheUserName - 1); 
   get_user_name(id, iCacheReporter, sizeof iCacheReporter - 1); 
   get_user_ip(iTarget, iCacheUserIp, sizeof iCacheUserIp - 1, 1); 

   ColorChat(id, TEAM_COLOR, "[ AMXX ]^1 Please type^4 Reason^1 for this^3 Call^1 !"); 
   client_cmd(id, "messagemode amx_callreason"); 
   
   menu_destroy(iMenu); 
   return PLUGIN_HANDLED; 
} 

public cmdCallReason(id, level, cid) 
{ 
   if(!cmd_access(id, level, cid, 1)) 
      return PLUGIN_HANDLED; 
    
   new iReason[64]; 
   read_argv(1, iReason, sizeof iReason - 1); 
   
   
   CallFunction(id, iCacheUserName, iCacheUserIp, iReason, iCacheReporter); 
   
   
   return PLUGIN_HANDLED; 
} 

stock CallFunction(id, const iPlayer[], const PlayerIp[], const iReason[], const iReporter[]) 
{
	new plID = find_player("bl", iPlayer)

	// server ip address
	new ip[22], szPort[6];
	//get_user_ip(id,ip,15,1) 
	get_user_ip(0,ip,15,1) 
	get_cvar_string("port", szPort, 5);
	format(ip, 21, "%s:%s", ip, szPort);
   
	// server host name
	new srvname[32];
	get_cvar_string("hostname",srvname,31)
   
	// date ?
	new datestr[11];
	get_time("%d.%m.%Y",datestr,10) 
	//get_time("%Y.%m.%d",datestr,10) 
   
	// current time ?
	new timestr[9];
	get_time("%H:%M:%S",timestr,8)
	
	
   
	new query[1001] 
	format(query,1000,IMPORRT_DB,iPlayer,ip,iReason,datestr,timestr,srvname,PlayerIp, iReporter)  
	SQL_ThreadQuery(SqlConnection,"QueryCreateTable",query) 
	
	//ColorChat(id, TEAM_COLOR, "^4[ AMXX ]^3 %s^4[^3 %s^4 ]^1 has been^4 Reported^1 for^3 %s^1 by^4 %s", iPlayer, PlayerIp, iReason, iReporter)
	ColorChat(id, TEAM_COLOR, "^4[ AMXX ]^3 %s^1 has been^4 Reported^1 for^3 %s^1 by^4 %s", iPlayer, iReason, iReporter)
	iUserCalled[plID] = true;
} 

public client_connect(id) 
{ 
   iUserCalled[id] = false; 
}

public client_disconnect(id) 
{ 
   iUserCalled[id] = false; 
}  
