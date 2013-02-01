/*
* If the server is empty AND remains empty for 10 minutes, change to default map
* 
* Based on "Auto change map v1.3 by "Mleczam"
* 
* Changelog (date/version/description):
* 2013-01-14	-	0.1.1	-	initial internal dev version
* 2013-01-14	-	0.1.2	-	initial testing complete, enabled map chg
* 2013-01-14	-	0.1.3	-	ADD TIME TO LOG, CHG MAP TO NUCLEUS, del commented out code
*
*/


#pragma semicolon 1
#include <sourcemod>


#define PLUGIN_VERSION		"0.1.3"
#define DEFAULT_NEXT_MAP	"koth_nucleus"	// Map to change to after time limit reached
#define MAP_IDLE_TIME		10				// Time (minutes) between empty server and map change


new Handle:timer = INVALID_HANDLE; 


//native FormatTime(String:buffer[], maxlength, const String:format[], stamp=-1);
//native GetTime(bigStamp[2]={0,0})


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
}

public OnMapStart()
{
      timer = CreateTimer(60.0, IsServerEmpty ,0, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
}

public Action:IsServerEmpty(Handle:Timer)
{
	new ccount=0;
	new String:sFormattedTime[22];
	
	FormatTime(sFormattedTime, sizeof(sFormattedTime), "%m/%d/%Y - %H:%M:%S", GetTime());

	for (new i = 1; i <= MaxClients; i++)
		if (IsClientInGame(i) && !IsFakeClient(i))
		{
            ccount++;
		}
		 
	if (ccount > 0)
	{
		PrintToServer("L %s: [AutoMapChanger] Detected %d clients, continuing.", sFormattedTime, ccount);
		return Plugin_Handled;
	}
	else
	{
		PrintToServer("L %s: [AutoMapChanger] Detected %d clients, starting empty server countdown.", sFormattedTime, ccount);
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
	new String:currentmapname[128];	  
	new ccount=0;
	  
	KillTimer(timer);
	
	// Check # of players
	for (new i = 1; i <= MaxClients; i++)
		if (IsClientInGame(i) && !IsFakeClient(i))
		{
            ccount++;
		}
      
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
		GetCurrentMap(currentmapname, sizeof(currentmapname));
		
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
	}
	return Plugin_Handled;
}
