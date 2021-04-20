#include <sourcemod>
#include <sdktools_functions>

#define DEBUG

#define PLUGIN_AUTHOR "ZombieFeyk + null138"
#define PLUGIN_VERSION "1.1"

#pragma newdecls required

public Plugin myinfo = 
{
	name = "Give Weapon Knife",
	author = PLUGIN_AUTHOR,
	description = "Typing in chat !knife give's you a knife.",
	version = PLUGIN_VERSION,
}

public void OnPluginStart()
{
	RegConsoleCmd("sm_knife", giveknifeplayer);
}

public Action giveknifeplayer(int Igrok, int Arguments)
{
	if(Arguments == 0 && Igrok > 0 && !IsFakeClient(Igrok) && IsPlayerAlive(Igrok))
	{
		if(GetPlayerWeaponSlot(Igrok, 2) == -1)
		{
			GivePlayerItem(Igrok, "weapon_knife");
		}
		else PrintToChat(Igrok, "[SM] You already have knife");
	}

	return Plugin_Handled;
}
