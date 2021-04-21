#pragma semicolon 1

#define DEBUG

#define PLUGIN_AUTHOR ""
#define PLUGIN_VERSION "0.00"

#include <sourcemod>
#include <sdktools>

#pragma newdecls required

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
	
}

public void OnClientPutInServer(int client)
{
	char steam[32];
	char nickname[128];
	GetClientName(client, nickname, sizeof(nickname));
	GetClientAuthId(client, AuthId_Steam2, steam, 32);
	if(!IsFakeClient(client) && steam[6] != '0' && steam[6] != '1')
	{
		KickClient(client, "STEAM ID NOT VALIDATED. RESTART THE GAME");
		LogMessage("Kicked a player with invalid STEAMID. Player's NickName: %d", nickname)
	}
}
