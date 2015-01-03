#include <sourcemod>
#include <sdktools>
#include <multicolors>
#include <freeday>
#include <hosties>
#include <lastrequest>

#undef REQUIRE_PLUGIN
#include <updater>

#define UPDATE_URL    "http://bitbucket.toastdev.de/sourcemod-plugins/raw/master/LRFreeday.txt"
public Plugin:myinfo = 
{
	name = "Last Request: Freeday",
	author = "Toast",
	description = "Last Request Feature Freeday",
	version = "1.0.0",
	url = "bitbucket.toastdev.de"
}
new g_LREntryNum;
new String:g_sLR_Name[64];
new g_Explosion;
new String:GameName[64];

public OnMapStart()
{
	
	g_Explosion = PrecacheModel("sprites/sprite_fire01.vmt");
	
	PrecacheSound("ambient/explosions/exp2.wav", true);
}

public OnPluginStart()
{
	GetGameFolderName(GameName, sizeof(GameName));
	LoadTranslations("freedaylr.phrases");
	Format(g_sLR_Name, sizeof(g_sLR_Name), "%T", "LR Title", LANG_SERVER);

	if (LibraryExists("updater"))
    {
        Updater_AddPlugin(UPDATE_URL);
    }	
}
public OnLibraryAdded(const String:name[])
{
    if (StrEqual(name, "updater"))
    {
        Updater_AddPlugin(UPDATE_URL)
    }
}
public OnPluginEnd()
{
	RemoveLastRequestFromList(Freeday_Start, Freeday_Stop, g_sLR_Name);
}
public APLRes:AskPluginLoad2(Handle:myself, bool:late, String:error[], err_max)
{
	MarkNativeAsOptional("Updater_AddPlugin");
	return APLRes_Success;
}

public Freeday_Start(Handle:LR_Array, iIndexInArray)
{
	new This_LR_Type = GetArrayCell(LR_Array, iIndexInArray, _:Block_LRType);
	if (This_LR_Type == g_LREntryNum)
	{		
		new LR_Player_Prisoner = GetArrayCell(LR_Array, iIndexInArray, _:Block_Prisoner);

		StripAllWeapons(LR_Player_Prisoner);
		decl String:TargetName[MAX_NAME_LENGTH];
		GetClientName(LR_Player_Prisoner, TargetName, sizeof(TargetName))
		CPrintToChatAll(CHAT_BANNER, "LRStart", TargetName);
		EmitSoundToAll("ambient/explosions/exp2.wav", LR_Player_Prisoner, _, _, _, 1.0);
		SetFreeday(LR_Player_Prisoner, false);
		CreateTimer(2.0, KillExplosion, LR_Player_Prisoner);	
	}
}
public Action:KillExplosion(Handle:timer, any:client){
	if(IsClientInGame(client) && IsPlayerAlive(client)){
		new Float:vPlayer[3];
		GetClientAbsOrigin(client, vPlayer);
		TE_SetupExplosion(vPlayer, g_Explosion, 10.0, 1, 0, 600, 5000);
		TE_SendToAll();
		ForcePlayerSuicide(client);
	}
}

public Freeday_Stop(This_LR_Type, LR_Player_Prisoner, LR_Player_Guard)
{
	// Nothing
}

public OnConfigsExecuted()
{
	// Add Freeday to the Last Request API
	static bool:bAddedFreeday = false;
	if (!bAddedFreeday)
	{
		g_LREntryNum = AddLastRequestToList(Freeday_Start, Freeday_Stop, g_sLR_Name);
		bAddedFreeday = true;
	}
}