#pragma semicolon 1

#define DEBUG

#define PLUGIN_AUTHOR ""
#define PLUGIN_VERSION "0.00"

#include <sourcemod>

#pragma newdecls required

char map[256];

public Plugin myinfo = 
{
	name = "",
	author = PLUGIN_AUTHOR,
	description = "",
	version = PLUGIN_VERSION,
	url = ""
};

public void OnPluginStart()
{
	LoadTranslations("rmap.phrases");
	
	RegAdminCmd("sm_rmap", RestartMap, ADMFLAG_BAN);
}

public Action RestartMap(int client, int args)
{
	PrintToServer("[RMAP] %N Restarted the Map!..", client);
	LogMessage("[RMAP] %N Restarted the Map!..", client);
	GetCurrentMap(map, sizeof(map));
	for (int i = 1; i <= MaxClients; i++)
	{
		if(!IsClientInGame(i))
		{
			continue;
		}
		if(GetAdminFlag(GetUserAdmin(i), Admin_Kick))
		{
			PrintToChat(i, "[RMAP] %N Restarted the Map!", client);
			PrintToChat(i, "[RMAP] %N Restarted the Map!", client);
		}
		PrintToChat(i, "[RMAP] %T", "Restarting Map", i);
	}
	CreateTimer(3.0, MapChangeTime, _, TIMER_FLAG_NO_MAPCHANGE);
}

public Action MapChangeTime(Handle timer)
{
	ForceChangeLevel(map, "sm_rmap Command");
	return Plugin_Stop;
}
