/*
* If the server is empty AND remains empty for 10 minutes, change to default map
* 
* Based on "Auto change map v1.3 by "Mleczam"
* 
* Changelog (date/version/description):
* 2013-01-14	-	0.1.1	-	initial internal dev version
* 2013-01-14	-	0.1.2	-	initial testing complete, enabled map chg
*
*/


#pragma semicolon 1
#include <sourcemod>


#define PLUGIN_VERSION		"0.1.2"
#define DEFAULT_NEXT_MAP	"pl_goldrush"	// Map to change to after time limit reached
#define MAP_IDLE_TIME		10			// Time (minutes) between empty server and map change


new Handle:timer = INVALID_HANDLE; 
//new Handle:new_map;
//new Handle:map_idle_time;
//new Handle:Timelimit_H;
//new Handle:Command_S;
//new Handle:PlayersC;
//new status;

//PrintToServer(const String:format[], any:...);

public Plugin:myinfo =
{
	name = "Auto Map Changer",
	author = "Malachi",
	description = "Change the map if the server is empty for over 10 minutes.",
	version = PLUGIN_VERSION,
	url = "http://www.necrophix.com/"
}

public OnPluginStart()
{
//      Command_S = CreateConVar("sm_cm_command","sm_setnextmap","When mp_timelimit is not 0 uses this command - use ma_setnextmap for MAP or sm_setnextmap for sourcemod", FCVAR_PLUGIN);
//      map_idle_time = CreateConVar("sm_cm_idlechange","5","When no players after this time server changes the map", FCVAR_PLUGIN);
//      new_map = CreateConVar("sm_cm_nextmap","de_dust2","Name of the map for change without .bsp", FCVAR_PLUGIN);
//      PlayersC = CreateConVar("sm_cm_players","0","How many players should by to change the map", FCVAR_PLUGIN);
//      Timelimit_H = FindConVar("mp_timelimit");
//      AutoExecConfig(true, "automapchanger");
//      status = 0;
}

public OnMapStart()
{
      timer = CreateTimer(60.0, IsServerEmpty ,0, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
//      status = 0;
}

public Action:IsServerEmpty(Handle:Timer)
{
	new ccount=0;
	
//	new NOfClients = GetClientCount(true);

	for (new i = 1; i <= MaxClients; i++)
		if (IsClientInGame(i) && !IsFakeClient(i))
		{
            ccount++;
		}
		 
//	if( ccount > GetConVarFloat(PlayersC) || status) 

	if (ccount > 0)
	{
		PrintToServer("AutoMapChanger: detected %d clients, continuing.", ccount);
		return Plugin_Handled;
	}
	else
	{
		PrintToServer("AutoMapChanger: detected %d clients, starting empty server countdown.", ccount);
		KillTimer(timer); 
		timer = INVALID_HANDLE;
		timer = CreateTimer( MAP_IDLE_TIME * 60.0, IsTimeLimitReached);
		return Plugin_Handled;
	}
}

public OnClientPostAdminCheck(iClient)
{
	PrintToServer("AutoMapChanger: detected client connect (index=%d), resetting.", iClient);
	KillTimer(timer);
	timer = CreateTimer(60.0, IsServerEmpty ,0, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
}


public Action:IsTimeLimitReached(Handle:Timer)
{
//	new String:str[128];
//	new String:command_s[64];
//	new String:mapname[128];	  

	new String:currentmapname[128];	  

	new ccount=0;
	  
//	new NOfClients = GetClientCount(true);

	KillTimer(timer);
	
	// Check # of players
	for (new i = 1; i <= MaxClients; i++)
		if (IsClientInGame(i) && !IsFakeClient(i))
		{
            ccount++;
		}
      
//	if( ccount > GetConVarFloat(PlayersC) )

	// If we have players again, reset everything and start over
	if (ccount > 0)
	{
		PrintToServer("AutoMapChanger: detected %d clients, aborting empty server countdown.", ccount);
		timer = INVALID_HANDLE;
		timer = CreateTimer(60.0, IsServerEmpty, 0, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		return Plugin_Handled;
	}
	else
	{
		GetCurrentMap(currentmapname,sizeof(currentmapname));
		
//		GetConVarString(new_map, str, sizeof(str));

		// If we are already on the default map, no map change
		if( strcmp(currentmapname, DEFAULT_NEXT_MAP, false) )
		{ 
			PrintToServer("AutoMapChanger: time limit reached, commencing map change to %s now!", DEFAULT_NEXT_MAP);
			if( IsMapValid(DEFAULT_NEXT_MAP) ) 
				ServerCommand("changelevel %s", DEFAULT_NEXT_MAP);
			return Plugin_Handled;
		}
		else
		{
			PrintToServer("AutoMapChanger: time limit reached, map change aborted - already on default map (%s)", DEFAULT_NEXT_MAP);
		}
		
//
//			Don't care about map time limit
//
//          else if(GetConVarFloat(Timelimit_H))
//          {
//            GetConVarString(Command_S,command_s,sizeof(command_s));
//            ServerCommand("%s %s",command_s,str);
//            status = 1;
//          }

	}
	return Plugin_Handled;
}
