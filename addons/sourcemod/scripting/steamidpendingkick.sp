#pragma semicolon 1

#define DEBUG

#define PLUGIN_AUTHOR "ZombieFeyk"
#define PLUGIN_VERSION "1.00"

#include <sourcemod>
#include <sdktools>

#pragma newdecls required

ConVar steamidkick;

public Plugin myinfo = 
{
	name = "Simple STEAMID_PENDING Kicker",
	author = PLUGIN_AUTHOR,
	description = "Kick a player. if SteamID is not reaching to the server",
	version = PLUGIN_VERSION,
	url = ""
};

public void OnPluginStart()
{
	steamidkick = CreateConVar("sm_steamidretry", "1", "Reconnect a Player with SteamID Pending?");
}

public void OnClientPutInServer(int client)
{
	char steam[32], nickname[32];
	GetClientName(client, nickname, sizeof(nickname));
	GetClientAuthId(client, AuthId_Steam2, steam, 32);
	if(steamidkick.IntValue)
	{
		if(!IsFakeClient(client) && steam[6] != '0' && steam[6] != '1')
		{
			FakeClientCommand(client, "retry");
		}
	}
	else if(!IsFakeClient(client) && steam[6] != '0' && steam[6] != '1')
	{
		KickClient(client, "STEAM ID NOT VALIDATED. RESTART THE GAME");
		LogMessage("Kicked a player with invalid STEAMID. Player's NickName: %s", nickname);
	}
}