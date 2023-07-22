#pragma semicolon 1

#define DEBUG

#define PLUGIN_AUTHOR "ZombieFeyk"
#define PLUGIN_VERSION "2.00"

#include <sourcemod>

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

}

public void OnClientPutInServer(int client)
{
	char steam[32], nickname[32];
	GetClientName(client, nickname, sizeof(nickname));
	GetClientAuthId(client, AuthId_Steam2, steam, 32);
	if(!IsFakeClient(client) && steam[6] != '0' && steam[6] != '1')
	{
		KickClient(client, "STEAM ID NOT VALIDATED. RESTART THE GAME");
		LogMessage("Kicked a player with invalid STEAMID. Player's NickName: %s", nickname);
	}
}
