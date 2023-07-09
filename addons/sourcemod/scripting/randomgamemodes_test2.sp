#pragma semicolon 1

#define PLUGIN_AUTHOR "Feykich, null138"
#define PLUGIN_VERSION "1.0"

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <multicolors>
#include <zombiereloaded>

#pragma newdecls required

bool bEnabledGame = false;
Handle hTimerRepeat, hFindConVar;
int iCaseSelection;
ConVar cvGravityValue, cvSpeedValue;
//char NemesisModelPath[PLATFORM_MAX_PATH];

static const char StringWeapons[][] = {
	"weapon_glock", "weapon_usp", "weapon_p228",
	"weapon_deagle", "weapon_elite", "weapon_fiveseven", 
	"weapon_m3", "weapon_xm1014", "weapon_galil",
	"weapon_ak47", "weapon_scout", "weapon_sg552", 
	"weapon_awp", "weapon_g3sg1", "weapon_famas", 
	"weapon_m4a1", "weapon_aug", "weapon_sg550", 
	"weapon_mac10", "weapon_tmp", "weapon_mp5navy",
	"weapon_ump45", "weapon_p90", "weapon_m249" };


public Plugin myinfo = 
{
	name = "[ZR] Random Game Modes",
	author = PLUGIN_AUTHOR,
	description = "The name of this plugin is the answer",
	version = PLUGIN_VERSION,
	url = "https://steamcommunity.com/id/zombiefeyk159753/"
};

public void OnPluginStart()
{
	RegConsoleCmd("sm_g", CheckMenu);
	RegConsoleCmd("sm_nemesis", NemesisModeTest);
	RegAdminCmd("sm_random", CheckMenu, ADMFLAG_KICK);
	
	cvGravityValue = CreateConVar("sm_gravityvalue", "300", "Sets value of gravity for random mode", FCVAR_NONE, true, 0.0, true, 9999.0);
	cvSpeedValue = CreateConVar("sm_speedvalue", "2", "Sets value of speed for random mode", FCVAR_NONE, true, 1.0, true, 10.0);
	
	//BuildPath(Path_SM, NemesisModelPath, sizeof(NemesisModelPath), "configs/randomgames.cfg");
	
	HookEvent("round_start", RoundStart, EventHookMode_Pre);
	HookEvent("round_end", RoundEnd, EventHookMode_Pre);
}

public Action CheckMenu(int client, int args)
{
	if(!IsFakeClient(client) && IsClientInGame(client))
	{
		MenuRandomGames(client);
	}
	return Plugin_Handled;
}

public void MenuRandomGames(int client)
{
	Menu menu = new Menu(RandomMenu_Handler);
	
	char buffer[32];
	
	menu.SetTitle("Settings Random Modes\n");
	
	bEnabledGame ? Format(buffer, 32, "Enable Random [X]") : Format(buffer, 32, "Enable Random [-]");
	menu.AddItem("1", buffer);
	
	menu.Display(client, 30);
}

public Action RoundStart(Event event, const char[] name, bool dontBroadcast)
{
	if(bEnabledGame == true)
	{
		CreateTimer(5.0, TimerDelay);
		CPrintToChatAll("{white}[Randomizer] {green}In 5 Seconds will be selected game mode this round!");
	}
	return Plugin_Handled;
}

public Action RoundEnd(Event event, const char[] name, bool dontBroadcast)
{
	if(bEnabledGame == true)
	{
		if(iCaseSelection == 2)
		{
			for (int i = 1; i <= MaxClients; i++)
			{
				if(IsClientInGame(i))
				{
					SetEntPropFloat(i, Prop_Send, "m_flModelScale", 1.0);
				}
			}
		}
		else if(iCaseSelection == 3)
		{
			int iFogIndex = FindEntityByClassname(-1, "env_fog_controller");
			DispatchKeyValue(iFogIndex, "fogenable", "0");
			
		}
		else if(iCaseSelection == 5)
		{
			hFindConVar = FindConVar("sv_gravity");
			SetConVarString(hFindConVar, "800", false, false);
		}
		DisableFunctions();
	}
	return Plugin_Continue;
}

public Action PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(iCaseSelection == 2)
	{
		SetEntPropFloat(client, Prop_Send, "m_flModelScale", 0.5);
	}
	else if(iCaseSelection == 4 && ZR_IsClientZombie(client))
	{
		float fSpeedValue = GetConVarFloat(cvSpeedValue);
		SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", fSpeedValue);
		SetEntityGravity(client, 0.5);
	}
	return Plugin_Continue;
}

public Action TimerDelay(Handle timer)
{
	if(bEnabledGame == true)
	{
		int LastRandom;
		iCaseSelection = GetRandomInt(1, 6);
		if(LastRandom != iCaseSelection)
		{
			int iFogIndex = FindEntityByClassname(-1, "env_fog_controller");
			switch(iCaseSelection)
			{
				case 1:
				{
					PrintToChatAll("debug 1(random guns)");
					randomGuns();
				}
				case 2:
				{
					PrintToChatAll("debug 2 (modelscale)");
					SetNewModelScale();
				}
				case 3:
				{
					if(iFogIndex != -1)
					{
						createFog();
						PrintToChatAll("debug (fog)");
					}
					else
					{
						PrintToChatAll("debug New Random");
						CreateTimer(1.0, TimerDelay);
					}
				}
				case 4:
				{
					PrintToChatAll("debug (Speed + Gravity)");
					FastPlayMode();
				}
				case 5:
				{
					PrintToChatAll("debug (Gravity)");
					GravityMode();
				}
				case 6:
				{
					PrintToChatAll("debug (Nemesis)");
					//NemesisMode();
				}
			}
		}
		else if(LastRandom == iCaseSelection)
		{
			CreateTimer(1.0, TimerDelay);
		}
	}
	return Plugin_Handled;
}

int RandomMenu_Handler(Menu menu, MenuAction action, int client, int choice)
{
	if(action == MenuAction_Select)
	{
		choice++;
		switch(choice)
		{
			case 1:
			{
				bEnabledGame = !bEnabledGame;
				PrintToChat(client, "[ZR] Random Games %sabled", bEnabledGame ? "en" : "dis");
				LogMessage("[Randomizer] ADMIN %N Toggled random games", client);
			}
		}
	}
	else if(action == MenuAction_End)
	{
		menu.Close();
	}
}

public Action TimerHandle(Handle timer)
{
	randomGuns();
}

void GravityMode()
{
	hFindConVar = FindConVar("sv_gravity");
	char GravityValue[128];
	GetConVarString(cvGravityValue, GravityValue, sizeof(GravityValue));
	SetConVarString(hFindConVar, GravityValue, false, false);
}

void FastPlayMode()
{
	HookEvent("player_spawn", PlayerSpawn);
	HookEvent("weapon_fire", WeaponFire);
	float fSpeedValue = GetConVarFloat(cvSpeedValue);
	for(int i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i))
		{
			if(IsPlayerAlive(i) && ZR_IsClientZombie(i))
			{
				SetEntPropFloat(i, Prop_Send, "m_flLaggedMovementValue", fSpeedValue);
				SetEntityGravity(i, 0.5);
			}
		}
	}
}

void randomGuns()
{
	int iLastWeapon;
	int iRandom = GetRandomInt(1, 24);
	if(iLastWeapon != iRandom)
    {
		for (int i = 1; i <= MaxClients; i++)
		{
			if(IsClientInGame(i) && IsPlayerAlive(i))
			{
				int iWeaponSlot0 = GetPlayerWeaponSlot(i, 0);
				int iWeaponSlot1 = GetPlayerWeaponSlot(i, 1);
				int iGrenadeHE = GetPlayerWeaponSlot(i, 2);
				if(iWeaponSlot0 > 0) 
				{
					RemovePlayerItem(i, iWeaponSlot0);
					RemoveEdict(iWeaponSlot0);
				}
				if(iWeaponSlot1 > 0) 
				{
					RemovePlayerItem(i, iWeaponSlot1);
					RemoveEdict(iWeaponSlot1);
				}
				if(iGrenadeHE < 0) 
				{
					GivePlayerItem(i, "weapon_hegrenade");
				}
				int iGiveWeapon = GivePlayerItem(i, StringWeapons[iRandom]);
				EquipPlayerWeapon(i, iGiveWeapon);
			}
			else if(iLastWeapon == iRandom)
			{
				if(GetAdminFlag(GetUserAdmin(i), Admin_Kick))
				{
					PrintToChat(i, "[Weapon Randomizer] Previous weapon repeat detected. Repeat randomizing..");
				}
				randomGuns();
			}
		}
		hTimerRepeat = CreateTimer(60.0, TimerHandle);
	}
}

void SetNewModelScale()
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i))
		{
			SetEntPropFloat(i, Prop_Send, "m_flModelScale", 0.5);
		}
	}
}

public Action NemesisModeTest(int client, int args) // not ready function
{
	//PrecacheModel(NemesisModelPath, false);
	if(IsClientInGame(client) && IsPlayerAlive(client))
	{
		PrintToChatAll("Success!");
		//SetEntityModel(client, NemesisModelPath);
		SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 3.0);
	}
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}

public Action OnTakeDamage(int client, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if(iCaseSelection != 6)
	{
		return Plugin_Handled;
	}
	if(IsPlayerAlive(client) && GetClientTeam(client) == 2)
	{
		return Plugin_Continue;
	}
	char sWeapon[32];
	GetClientWeapon(client, sWeapon, sizeof(sWeapon));
	inflictor = attacker;
	if(StrContains(sWeapon, "knife", false))
	{
		CPrintToChatAll("true");
		ForcePlayerSuicide(inflictor);
	}
	return Plugin_Continue;
}

void createFog()
{
	int iFogIndex = FindEntityByClassname(-1, "env_fog_controller");
	DispatchKeyValue(iFogIndex, "fogblend", "0");
	DispatchKeyValue(iFogIndex, "fogcolor", "192 192 192");
	DispatchKeyValue(iFogIndex, "fogcolor2", "192 192 192");
	DispatchKeyValueFloat(iFogIndex, "fogstart", 300.0);
	DispatchKeyValueFloat(iFogIndex, "fogend", 500.0);
	DispatchKeyValueFloat(iFogIndex, "fogmaxdensity", 100.0);
	DispatchSpawn(iFogIndex);
	ActivateEntity(iFogIndex);
}

//void ConfigModel()
//{
//	KeyValues kv = new KeyValues;
//	
//	kv.GetSectionName(kv);
//}

public Action WeaponFire(Handle event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	int iWeaponSlot0 = GetPlayerWeaponSlot(client, 0);
	if(IsValidEntity(iWeaponSlot0))
	{
		if(GetEntProp(iWeaponSlot0, Prop_Data, "m_iState"))
		{
			SetEntProp(iWeaponSlot0, Prop_Data, "m_iClip1", GetEntProp(iWeaponSlot0, Prop_Data, "m_iClip1"));
		}
	}
	return Plugin_Continue;
}

void DisableFunctions()
{
	UnhookEvent("player_spawn", PlayerSpawn);
	UnhookEvent("weapon_fire", WeaponFire);
	KillTimer(hTimerRepeat);
	hTimerRepeat = INVALID_HANDLE;
}