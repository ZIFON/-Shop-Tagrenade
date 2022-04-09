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
    version =  "2.0" ,
    url =  "https://github.com/ZIFON"
};

CategoryId gcategory_id;
ItemId g_iID;
bool g_bSpecialGrenade[MAXPLAYERS+1];
ConVar CVARB, CVARS;

public void OnPluginStart()
{
    HookEvent("tagrenade_detonate",tagrenade);
    HookEvent("player_death", Event_OnPlayerDeath, EventHookMode_PostNoCopy);

    AutoExecConfig(true, "shop_Tagrenade");

    (CVARB = CreateConVar("sm_shop_Tagrenade", "450", "Цена покупки.", _, true, 0.0)).AddChangeHook(ChangeCvar_Buy);
    (CVARS = CreateConVar("sm_shop_Tagrenade_sell_price", "200", "Цена продажи.", _, true, 0.0)).AddChangeHook(ChangeCvar_Sell);

    if(Shop_IsStarted()) Shop_Started();
}

public void Shop_Started()
{
    gcategory_id = Shop_RegisterCategory(CATEGORY, "Спец.Гранаты", "");

    if (Shop_StartItem(gcategory_id, "shop_Tagrenade"))
    {
            Shop_SetInfo("Tagrenade", "Tagrenade", CVARB.IntValue, CVARS.IntValue, Item_BuyOnly, 0);
            Shop_SetCallbacks(_, _, _, _, _, _, ItemBuyCallback);
            Shop_EndItem();
    }
}


public void ChangeCvar_Buy(ConVar convar, const char[] oldValue, const char[] newValue)
{
  Shop_SetItemPrice(g_iID, convar.IntValue);
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

public bool ItemBuyCallback(int client, CategoryId category_id, const char[] category, ItemId item_id, const char[] item, ItemType type, int price, int sell_price, int value, int gold_price, int gold_sell_price){

    if (!IsPlayerAlive(client))
    {
      PrintToChat(client, " \x04[\x05Shop\x04] \x02Вы должны быть живы.");
    }
    else if (g_bSpecialGrenade[client])
    {
      PrintToChat(client, " \x04[\x05Shop\x04] \x02Вы еще не использовали предыдущую гранату.");
    }
    else
  {
      PrintToChat(client, " \x04[\x05Shop\x04] \x06Вы успешно приобрели вх-гранату.");
      g_bSpecialGrenade[client] = true;
      GivePlayerItem(client, "weapon_tagrenade");
      return true;
  }
  
    return false;
}

