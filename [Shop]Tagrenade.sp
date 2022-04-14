#include <sourcemod>
#include <shop>
#include <sdktools>
#include <sdktools_hooks>

#define CATEGORY "granades"

public Plugin myinfo =
{
	name =  "[Shop]Tagrenade" ,
	author =  "ZIFON & FIVE" ,
	description =  "https://github.com/ZIFON" ,
	version =  "3.0" ,
	url =  "https://github.com/ZIFON"
};

int g_iRoundUsed[MAXPLAYERS+1];
CategoryId gcategory_id;
ItemId g_iID;
bool g_bSpecialGrenade[MAXPLAYERS+1];

ConVar CVARB, CVARS, CVARL;

public void OnPluginStart()
{
	LoadTranslations("shop_tagrenade.phrases");

	HookEvent("tagrenade_detonate",tagrenade);
	HookEvent("player_death", Event_OnPlayerDeath, EventHookMode_PostNoCopy);
	HookEvent("round_start", Event_OnRoundStart, EventHookMode_PostNoCopy);

	AutoExecConfig(true, "shop_Tagrenade");

	(CVARB = CreateConVar("sm_shop_Tagrenade", "450", "Цена покупки.", _, true, 0.0)).AddChangeHook(ChangeCvar_Buy);
	(CVARS = CreateConVar("sm_shop_Tagrenade_sell_price", "200", "Цена продажи.", _, true, 0.0)).AddChangeHook(ChangeCvar_Sell);
	(CVARL = CreateConVar("sm_shop_Tagrenade_limit", "3", "Сколько можно будет использовать за раунд", _, true, 0.0)).AddChangeHook(ChangeCvar_Limit);

	if(Shop_IsStarted()) Shop_Started();
}

public void Shop_Started()
{
	gcategory_id = Shop_RegisterCategory(CATEGORY, "Спец.Гранаты", "");

	if (Shop_StartItem(gcategory_id, "shop_Tagrenade"))
	{
		Shop_SetInfo("Tagrenade", "Tagrenade", CVARB.IntValue, _, Item_BuyOnly, _, CVARS.IntValue, _);
		Shop_SetCallbacks(_, _, _, _, _, _, ItemBuyCallback);
		Shop_EndItem();
	}
}

public void ChangeCvar_Buy(ConVar convar, const char[] oldValue, const char[] newValue)
{
	Shop_SetItemPrice(g_iID, convar.IntValue);
}

public void Event_OnRoundStart(Event event, const char[] name, bool dontBroadcast)
{
	for (int i = 1; i <= MaxClients; ++i)
	{
		g_iRoundUsed[i] = 0;
	} 
}

public void ChangeCvar_Limit(ConVar convar, const char[] oldValue, const char[] newValue)
{
	CVARL.SetInt(StringToInt(newValue));
}

public void ChangeCvar_Sell(ConVar convar, const char[] oldValue, const char[] newValue)
{
	Shop_SetItemSellPrice(g_iID, convar.IntValue);
}
public void OnItemRegistered(CategoryId category_id, const char[] sCategory, const char[] sItem, ItemId item_id)
{
	g_iID = item_id;
}
public void Event_OnPlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	if (IsClientInGame(client) && g_bSpecialGrenade[client])
		g_bSpecialGrenade[client] = false;
}

public Action tagrenade(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	if (IsClientInGame(client) && IsPlayerAlive(client) && g_bSpecialGrenade[client])
	{
		g_bSpecialGrenade[client] = false;
	}
	return Plugin_Continue;
}

public bool ItemBuyCallback(int client, CategoryId category_id, const char[] category, ItemId item_id, const char[] item, ItemType type, int price, int sell_price, int value, int gold_price, int gold_sell_price)
{
	SetGlobalTransTarget(client);
	
	if (!IsPlayerAlive(client))
	{
		PrintToChat(client, "%t%t", "Prefix", "OnlyAlive");
	}
	else if (CVARL.IntValue && g_iRoundUsed[client] >= CVARL.IntValue)
	{
		PrintToChat(client, "%t%t", "Prefix", "LimitOnRound", g_iRoundUsed[client], CVARL.IntValue);
	}
	else if (g_bSpecialGrenade[client])
	{
		PrintToChat(client, "%t%t", "Prefix", "Unused");
	}

	else
	{
		PrintToChat(client, "%t%t", "Prefix", "SuccessfulPay");
		g_bSpecialGrenade[client] = true;
		GivePlayerItem(client, "weapon_tagrenade");
		g_iRoundUsed[client]++;
		return true;
	}

	return false;
}

