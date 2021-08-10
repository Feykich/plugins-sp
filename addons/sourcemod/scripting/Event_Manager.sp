#pragma semicolon 1

#include <sourcemod>
#include <multicolors>
#include <cstrike>
#include <sdktools>
#include <zombiereloaded>

#pragma newdecls required

#define PLUGIN_VERSION "1.0"

int EventMode = -1;
int iWarmup = 0;
int g_iBeamSprite;
int g_iClientColor[MAXPLAYERS + 1][3];

Handle TimerHandle;

float g_fTrans[MAXPLAYERS + 1] =  { 1.001, ... };

ConVar cVar_WarmupTime, g_cvBeamSprite, cVar_Hostname;

bool EventStarted = false, StandartSelected = false, MiniSelected = false, StarWarsSelected = false;
bool WarmupToggle = false, CheckEvent = false, StarWarsSkin = false, CheckTracers = false;
bool g_bVisible[MAXPLAYERS + 1] =  { true, ... };

char model[256], nick[128], oldHostname[256];

public Plugin myinfo = {
	name = "[ZR] Event Manager",
	author = "ZombieFeyk",
	description = "Event Management",
	version = PLUGIN_VERSION,
	url = ""
};

public void OnPluginStart()
{
	RegAdminCmd("sm_event", EventMenu, ADMFLAG_KICK);
	//RegConsoleCmd("sm_bot", bot);

	cVar_WarmupTime = CreateConVar("sm_eventwarmup", "30", "Event Warmup Timer", 0, true, 0.0, true, 30.0);
	g_cvBeamSprite = CreateConVar("vip_tracers_beamspr_event", "materials/sprites/laserbeam.vmt", "Tracer sprite"); // Sourcecode from VIP Tracers by R1KO & Cloud Strife

	HookEvent("round_start", OnEventStart, EventHookMode_Pre);
	HookEvent("player_spawn", OnSpawned, EventHookMode_Pre);
	HookEvent("bullet_impact", Event_BulletImpact);
}

/*
public Action bot(int client, int args)
{
	ServerCommand("sv_cheats 1");
	ServerCommand("bot_stop 1");
	ServerCommand("bot_quota 10");
	ServerCommand("mp_freezetime 0");
}
*/

public Action EventMenu(int client, int args)
{
	Handle menu = CreateMenu(EventMenu_Handler);

	char cEventMode[64];
	
	switch(EventMode)
	{
		case 0: cEventMode = "Standart Event";
		case 1: cEventMode = "Mini Event";
		case 2: cEventMode = "Star Wars Event";
		default: cEventMode = "No Event Selected";
	}
	if(StandartSelected)
	{
		cEventMode = "Standart Event";
		CheckEvent = true;
	}
	if(MiniSelected)
	{
		cEventMode = "Mini Event";
		CheckEvent = true;
	}
	if(StarWarsSelected)
	{
		cEventMode = "Star Wars Event";
		CheckEvent = true;
	}
	
	SetMenuTitle(menu, "Event Manager\nMode: %s \n", cEventMode);
    
	AddMenuItem(menu, "start", "Start An Event");
	AddMenuItem(menu, "cEventMode", "Event Selection");
	AddMenuItem(menu, "restart", "Restart Round");
	AddMenuItem(menu, "precache", "Precache Models [NECESSARILY]");

	SetMenuExitBackButton(menu, true);
	SetMenuExitButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int EventMenu_Handler(Handle EventMenu, MenuAction action, int client, int position)
{
	if(IsValidClient(client))
	{
		char list[256];
		GetMenuItem(EventMenu, position, list, sizeof(list));
		if(action == MenuAction_Select)
		{
			if(StrEqual(list, "start"))
			{
				EventStartedToggle(client);
			}
			if(StrEqual(list, "cEventMode"))
			{
				EventMenuSelect(client);
			}
			if(StrEqual(list, "restart"))
			{
				FakeClientCommand(client, "say /rr");
			}
			if(StrEqual(list, "precache"))
			{
				cPrecacheModel(client);
			}
		}
		else if(action == MenuAction_End)
		{
			CloseHandle(EventMenu);
		}
	}
}

public void EventMenuSelect(int client)
{
	Handle menu = CreateMenu(EventMenuSelect_Handler);

	char cEventMode[64];

	switch(EventMode)
	{
		case 0:
		cEventMode = "Standart Event";
		case 1:
		cEventMode = "Mini Event";
		case 2:
		cEventMode = "Star Wars Event";
		default:
		cEventMode = "No Event Selected";
	}
	if(StandartSelected)
		cEventMode = "Standart Event";

	if(MiniSelected)
		cEventMode = "Mini Event";

	if(StarWarsSelected)
		cEventMode = "Star Wars Event";

	SetMenuTitle(menu, "Event Selection\nMode: %s", cEventMode);

	AddMenuItem(menu, "standart", "Standart Event");
	AddMenuItem(menu, "minievent", "Mini Event");
	AddMenuItem(menu, "starwars", "Star Wars Event");

	SetMenuExitBackButton(menu, true);
	SetMenuExitButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int EventMenuSelect_Handler(Handle EventMenuSelect, MenuAction action, int client, int position)
{
	if(IsValidClient(client))
	{
		char list[256];
		GetClientName(client, nick, sizeof(nick));
		GetMenuItem(EventMenuSelect, position, list, sizeof(list));
		if(action == MenuAction_Select)
		{
			if(StrEqual(list, "standart"))
			{
				StandartSelected = true;
				MiniSelected = false;
				StarWarsSelected = false;
				for(int i = 1; i < MaxClients; i++)
				{
					if(IsValidClient(i) && GetAdminFlag(GetUserAdmin(i), Admin_Kick))
					{
						CPrintToChat(i, "{white}[ADM-WARNING] {green}Admin {white}%s {green}has choosed {white}EVENT{green} mode!", nick);
					}
				}
				CPrintToChat(client, "{white}[EVENT]{green} You've choosed {white}EVENT {green}mode!");
			}
			if(StrEqual(list, "minievent"))
			{
				StandartSelected = false;
				MiniSelected = true;
				StarWarsSelected = false;
				for(int i = 1; i < MaxClients; i++)
				{
					if(IsValidClient(i) && GetAdminFlag(GetUserAdmin(i), Admin_Kick))
					{
						CPrintToChat(i, "{white}[ADM-WARNING]{green} Admin {white}%s {green}has choosed {white}MINI-EVENT{green} mode!", nick);
					}
				}
				CPrintToChat(client, "{white}[EVENT]{green} You've choosed {white}MINI-EVENT {green}mode!");
			}
			if(StrEqual(list, "starwars"))
			{
				StandartSelected = false;
				MiniSelected = false;
				StarWarsSelected = true;
				for(int i = 1; i < MaxClients; i++)
				{
					if(IsValidClient(i) && GetAdminFlag(GetUserAdmin(i), Admin_Kick))
					{
						CPrintToChat(i, "{white}[ADM-WARNING]{green} Admin {white}%s {green}has choosed {white}STAR-WARS{green} mode!", nick);
					}
				}
				CPrintToChat(client, "{white}[EVENT]{green} You've choosed {white}STAR-WARS {green}mode!");
			}
		}
		else if(action == MenuAction_End)
		{
			CloseHandle(EventMenuSelect);
		}
	}
}

void EventStartedToggle(int client)
{
	if(EventStarted == false)
	{
		if(CheckEvent == false)
		{
			CPrintToChat(client, "{white}[EVENT]{green} Can't start an event. Firstly choose {white}event mode{green}!");
		}
		else if(StandartSelected)
		{
			EventStarted = true;
			Warmup(client);
		}
		else if(MiniSelected)
		{
			EventStarted = true;
			Warmup(client);
		}
		else if(StarWarsSelected)
		{
			EventStarted = true;
			CreateTimer(0.2, StarWarsMode);
			Warmup(client);
		}
		return;
	}
	if(EventStarted == true)
	{
		EventStarted = false;
		CPrintToChat(client, "{white}[EVENT] {green}You turned off an event!");
		EventOff(client);
	}
}


public void EventOff(int client)
{
	ServerCommand("hostname LEGION | Zombie Escape Project | NoSteam");
	CheckTracers = false;
}

void GetHostname()
{
	cVar_Hostname = FindConVar("hostname");
	cVar_Hostname.GetString(oldHostname, 256);

	if(cVar_Hostname && StandartSelected)
	{
		GetConVarString(cVar_Hostname, oldHostname, sizeof(oldHostname));
		Format(oldHostname, sizeof(oldHostname), "[EVENT] %s", oldHostname);
		cVar_Hostname.SetString(oldHostname);
	}
	else if(cVar_Hostname && MiniSelected)
	{
		GetConVarString(cVar_Hostname, oldHostname, sizeof(oldHostname));
		Format(oldHostname, sizeof(oldHostname), "[MINI-EVENT] %s", oldHostname);
		cVar_Hostname.SetString(oldHostname);
	}
	else if(cVar_Hostname && StarWarsSelected)
	{
		GetConVarString(cVar_Hostname, oldHostname, sizeof(oldHostname));
		Format(oldHostname, sizeof(oldHostname), "[STAR-WARS EVENT] %s", oldHostname);
		cVar_Hostname.SetString(oldHostname);
	}
}

public void Warmup(int client)
{
	GetClientName(client, nick, sizeof(nick));
	CPrintToChatAll("{white}[EVENT] {green}ADMIN {white}%s {green}HAS STARTED WARMUP EVENT", nick);
	CPrintToChatAll("{white}[EVENT] {green}ADMIN {white}%s {green}HAS STARTED WARMUP EVENT", nick);
	CPrintToChatAll("{white}[EVENT] {green}ADMIN {white}%s {green}HAS STARTED WARMUP EVENT", nick);
	LogMessage("[LOG-EVENT] ADMIN %s STARTED AN EVENT", nick);
	ServerCommand("mp_timeleft 180");
	GetHostname();
	iWarmup = 0;
	CS_TerminateRound(1.0, CSRoundEnd_Draw, false);
	if(cVar_WarmupTime.IntValue > 0)
	{
		WarmupToggle = true;
		TimerHandle = CreateTimer(1.0, WarmupI, 0, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	}
}

public Action WarmupI(Handle timer, any client)
{
	if(iWarmup >= cVar_WarmupTime.IntValue && WarmupToggle == true)
	{
		WarmupToggle = false;
		iWarmup = 0;
		float fDelay = 3.0;
		CS_TerminateRound(fDelay, CSRoundEnd_GameStart, false);
		CS_SetTeamScore(CS_TEAM_CT, 0);
		CS_SetTeamScore(CS_TEAM_T, 0);
		DeleteTimer();
	}
	for(int i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i) && !IsFakeClient(i))
		{
			SetHudTextParams(0.0, -1.0, -1.0, 255, 255, 255, 255, 0, 0.0, 1.0, 1.0);
			ShowHudText(i, -1, "EVENT WILL BE STARTED IN %d", cVar_WarmupTime.IntValue - iWarmup);
			iWarmup++;
		}
	}
	return Plugin_Handled;
}

public void DeleteTimer()
{
	if(TimerHandle != INVALID_HANDLE)
	{
		KillTimer(TimerHandle);
		TimerHandle = INVALID_HANDLE;
	}
}

void cPrecacheModel(int client)
{
	GetClientName(client, nick, sizeof(nick));
	PrecacheModel("models/player/sourcegear.ru/human/stormtrooper/stormtrooper.mdl", true);
	PrecacheModel("models/player/legion/zombi/stormtrooper.mdl", true);
	for(int i = 1; i < MaxClients; i++)
	{
		if(IsValidClient(i) && GetAdminFlag(GetUserAdmin(i), Admin_Kick))
		{
			CPrintToChat(i, "{white}[ADM-WARNING]{green} Admin {white}%s {green}has Precached {white}EVENT{green} models!", nick);
		}
	}
	CPrintToChat(client, "{white}[EVENT] {green}Models successfully precached!");
}

public void ZR_OnClientInfected(int client, int attacker, bool motherInfect, bool respawnOverride, bool respawn)
{
	if(StarWarsSkin)
	{
		FormatEx(model, sizeof(model), "models/player/legion/zombi/stormtrooper.mdl"); // Put here new model Stormtrooper as Zombie
		SetEntityModel(client, model);
	}
}

public Action ZR_OnClientHuman(int &client, bool &respawn, bool &protect)
{
	if(StarWarsSkin)
	{
		FormatEx(model, sizeof(model), "models/player/sourcegear.ru/human/stormtrooper/stormtrooper.mdl"); // Put here new model Stormtrooper as Zombie
		SetEntityModel(client, model);
	}
}

public void ZR_OnClientHumanPost(int client, bool respawn, bool protect)
{
	if(StarWarsSkin)
	{
		FormatEx(model, sizeof(model), "models/player/sourcegear.ru/human/stormtrooper/stormtrooper.mdl"); // Put here new model Stormtrooper as Human
		SetEntityModel(client, model);
	}
}

public Action StarWarsMode(Handle timer)
{
	StarWarsSkin = true;
	for(int i = 1; i < MaxClients; i++)
	{
		if(IsClientInGame(i) && IsPlayerAlive(i) && ZR_IsClientZombie(i))
		{
			FormatEx(model, sizeof(model), "models/player/legion/zombi/stormtrooper.mdl"); // Put here new model Stormtrooper as Zombie
			SetEntityModel(i, model);
		}
		if(IsClientInGame(i) && IsPlayerAlive(i) && ZR_IsClientHuman(i))
		{
			FormatEx(model, sizeof(model), "models/player/sourcegear.ru/human/stormtrooper/stormtrooper.mdl"); // Put here new model Stormtrooper as Human
			SetEntityModel(i, model);
		}
	}
}

public Action OnEventStart(Handle event, char[] name, bool dontBroadcast)
{
	if(EventStarted && StandartSelected)
	{
		CPrintToChatAll("{white} [EVENT] {green}HAS BEGUN!");
		CPrintToChatAll("{white} [EVENT] {green}HAS BEGUN!");
		CPrintToChatAll("{white} [EVENT] {green}HAS BEGUN!");
	}
	else if(EventStarted && MiniSelected)
	{
		CPrintToChatAll("{white} [MINI-EVENT] {green}HAS BEGUN!");
		CPrintToChatAll("{white} [MINI-EVENT] {green}HAS BEGUN!");
		CPrintToChatAll("{white} [MINI-EVENT] {green}HAS BEGUN!");
	}
	else if(EventStarted && StarWarsSelected)
	{
		CheckTracers = true;
		CreateTimer(0.2, StarWarsMode);
		char sBuffer[128];
		GetConVarString(g_cvBeamSprite, sBuffer, sizeof(sBuffer));
		if((g_iBeamSprite = PrecacheModel(sBuffer)) == 0)
		{
			SetFailState("Invalid path to beam sprite \"%s\"", sBuffer);
		}
		CPrintToChatAll("{white} [STAR-WARS EVENT] {green}HAS BEGUN!");
		CPrintToChatAll("{white} [STAR-WARS EVENT] {green}HAS BEGUN!");
		CPrintToChatAll("{white} [STAR-WARS EVENT] {green}HAS BEGUN!");
	}
}

public Action OnSpawned(Handle event, char[] name, bool dontBroadcast)
{
	if(EventStarted && StarWarsSelected)
	{
		CreateTimer(0.2, StarWarsMode);
	}
}

public void OnMapStart()
{
	PrecacheModel("models/player/sourcegear.ru/human/stormtrooper/stormtrooper.mdl", true); // Put here new model Stormtrooper as Human
	PrecacheModel("models/player/legion/zombi/stormtrooper.mdl", true); // Put here new model Stormtrooper as Zombie

	CreateTimer(0.2, StarWarsMode);
}

bool IsValidClient(int client, bool nobots = true)
{
	if (client <= 0 || client > MaxClients || !IsClientConnected(client) || (nobots && IsFakeClient(client)))
	{
		return false;
	}
	return IsClientInGame(client);
}

// Sourcecode of VIP Tracers by R1KO & Cloud Strife

public void Event_BulletImpact(Handle hEvent, const char[] sEvName, bool dontBroadcast)
{
	int iClient = GetClientOfUserId(GetEventInt(hEvent, "userid"));

	if(iClient && IsValidClient(iClient) && CheckTracers)
	{
		float fClientOrigin[3], fEndPos[3], fStartPos[3], fPercentage;
		int iColor[4];
		iColor[0] = g_iClientColor[iClient][0];
		iColor[1] = g_iClientColor[iClient][1];
		iColor[2] = g_iClientColor[iClient][2];
		iColor[3] = RoundFloat(g_fTrans[iClient]);
		GetClientEyePosition(iClient, fClientOrigin);
		
		fEndPos[0] = GetEventFloat(hEvent, "x");
		fEndPos[1] = GetEventFloat(hEvent, "y");
		fEndPos[2] = GetEventFloat(hEvent, "z");
		
		fPercentage = 0.4/(GetVectorDistance(fClientOrigin, fEndPos)/100.0);

		fStartPos[0] = fClientOrigin[0] + ((fEndPos[0]-fClientOrigin[0]) * fPercentage); 
		fStartPos[1] = fClientOrigin[1] + ((fEndPos[1]-fClientOrigin[1]) * fPercentage)-0.08; 
		fStartPos[2] = fClientOrigin[2] + ((fEndPos[2]-fClientOrigin[2]) * fPercentage);
		TE_SetupBeamPoints(fStartPos, fEndPos, g_iBeamSprite, 0, 0, 0, 0.1, 1.0, 1.0, 1, 0.5 * 0.0, {0, 0, 255, 255}, 0);
		int count = 0, iClients[MAXPLAYERS + 1];
		for (int i = 1; i <= MaxClients; i++)
		{
			if(IsClientInGame(i) && !IsFakeClient(i))
			{
				if(g_bVisible[i] || i == iClient)
				{
					iClients[count++] = i;
				}
			}
		}
		TE_Send(iClients, count);
	}
}