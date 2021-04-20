#pragma semicolon 1

#define DEBUG

#define PLUGIN_AUTHOR "ZombieFeyk + null138"
#define PLUGIN_VERSION "1.3"

#include <sourcemod>
#include <sdktools>
#include <cstrike>
#include <multicolors>

#pragma newdecls required


public Plugin myinfo = 
{
	name = "Force Restart Game",
	author = PLUGIN_AUTHOR,
	description = "Force Restart Game by typing in chat !rr/!rrt",
	version = PLUGIN_VERSION,
}

public void OnPluginStart()
{
	LoadTranslations("restartgame.phrases");
	
	RegAdminCmd("sm_rr", Restart, ADMFLAG_GENERIC);
	RegAdminCmd("sm_rrt", ZombiesWin, ADMFLAG_GENERIC);
}

public Action Restart(int client, int args)
{
	char name[32];
	GetClientName(client, name, sizeof(name));
	CS_TerminateRound(5.0, CSRoundEnd_Draw, false);
	CPrintToChatAll("{green}[RR] {white}ADMIN %t", "RestartGame", name, client);
	return Plugin_Handled;
}

public Action ZombiesWin(int client, int args)
{
	char name[32];
	GetClientName(client, name, sizeof(name));
	CS_TerminateRound(5.0, CSRoundEnd_TerroristWin, false);
	SetTeamScore(1, GetTeamScore(2) + 1 );
	CPrintToChatAll("{green}[RR] {white}ADMIN %t", "ForceEnd", name, client);
	return Plugin_Handled;
}