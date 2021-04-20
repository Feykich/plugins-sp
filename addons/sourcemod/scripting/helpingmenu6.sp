#pragma semicolon 1

#include <sourcemod>
#include <sdktools>

#pragma newdecls required

char command1[MAXPLAYERS + 1][32];

public void OnPluginStart() 
{
	LoadTranslations("usefulcommands.phrases");
	
	RegConsoleCmd("sm_cmd", cmdHelp);
}

public Action cmdHelp(int client, int args)
{
	ShowMainMenu(client);

	return Plugin_Handled;
}

public int MenuHandlerMenu(Menu menu, MenuAction action, int client, int choice)
{
	if (action == MenuAction_Select)
	{
		char menuItem[10], buffer[258];
		menu.GetItem(choice, menuItem, sizeof(menuItem));
		switch(StringToInt(menuItem))
		{
			case 1:
			{
				FormatEx(buffer, 258, "%T", "Hud", client);
				Format(command1[client], 32, "sm_hud");
			}
			case 2:
			{
				FormatEx(buffer, 258, "%T", "BHud", client);
				Format(command1[client], 32, "sm_bhud");
			}
			case 3:
			{
				FormatEx(buffer, 258, "%T", "Music", client);
				Format(command1[client], 32, "sm_music");
			}
			case 4:
			{
				FormatEx(buffer, 258, "%T", "StopSound", client);
				Format(command1[client], 32, "sm_stopsound");
			}
			case 5:
			{
				FormatEx(buffer, 258, "%T", "ZTele", client);
				Format(command1[client], 32, "ztele");
			}
			case 6:
			{
				FormatEx(buffer, 258, "%T", "Knife", client);
				Format(command1[client], 32, "sm_knife");
			}
			case 7:
			{
				FormatEx(buffer, 258, "%T", "settings", client);
				Format(command1[client], 32, "sm_settings");
			}
		}
		FakeClientCommand(client, "menuselect 10");
		ShowDescriptionsMenu(client, buffer);
	}
	if (action == MenuAction_End)
    {
		menu.Close();
	}
}

int MenuHandlerMenu2(Menu menu, MenuAction action, int client, int choice)
{
	if(action == MenuAction_Select)
	{
		char menuItem[10];
		menu.GetItem(choice, menuItem, sizeof(menuItem));
		
		if(StringToInt(menuItem) == 2)
		{
			FakeClientCommand(client, command1[client]);
			command1[client] = NULL_STRING;
			ShowMainMenu(client);
		}
	}
	if(action == MenuAction_End)
	{
		menu.Close();
	}
}

void ShowMainMenu(int client)
{
	Menu menu = new Menu(MenuHandlerMenu);

	menu.SetTitle("Useful Commands");

	menu.AddItem("1", "[E/D] !hud");
	menu.AddItem("2", "[E/D] !bhud");
	menu.AddItem("3", "[E/D] !music");
	menu.AddItem("4", "[E/D] !stopsound");
	menu.AddItem("5", "!ztele");
	menu.AddItem("6", "!knife");
	menu.AddItem("7", "!settings");

	menu.Display(client, MENU_TIME_FOREVER);
}

void ShowDescriptionsMenu(int client, const char[] description)
{
	Menu hMenu = new Menu(MenuHandlerMenu2);
	
	
	hMenu.SetTitle("Help");
	
	hMenu.AddItem("1", description, ITEMDRAW_DISABLED);
	hMenu.AddItem("2", "Run Command");
	hMenu.Display(client, MENU_TIME_FOREVER);
}