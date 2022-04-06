#include <sourcemod>
#include <shop>
#include <sdktools>
#include <sdktools_hooks>

public Plugin myinfo =
{
    name =  "[Shop]Tagrenade" ,
    author =  "ZIFON & FIVE" ,
    description =  "https://github.com/ZIFON" ,
    version =  "1.0" ,
    url =  "https://github.com/ZIFON"
};

CategoryId gcategory_id;
ItemId g_iID;
ConVar CVARB, CVARS;

public void OnPluginStart()
{
    AutoExecConfig(true, "shop_Tagrenade");
    (CVARB = CreateConVar("sm_shop_Tagrenade", "450", "Цена покупки.", _, true, 0.0)).AddChangeHook(ChangeCvar_Buy);
    (CVARS = CreateConVar("sm_shop_Tagrenade_sell_price", "200", "Цена продажи.", _, true, 0.0)).AddChangeHook(ChangeCvar_Sell);
    if(Shop_IsStarted()) Shop_Started();
    
}

public void Shop_Started()
{
    gcategory_id = Shop_RegisterCategory("ability", "Способности", "");
    if (Shop_StartItem(gcategory_id, "shop_Tagrenade"))
    {
            Shop_SetInfo("Tagrenade", "Tagrenade", CVARB.IntValue, CVARS.IntValue, Item_BuyOnly, 0);
            Shop_SetCallbacks(OnItemRegistered, _,_,_,_,_,OnBuy);
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

public bool OnBuy(int client, CategoryId category_id, const char[] category, ItemId item_id, const char[] item, ItemType type, int price, int sell_price, int value){

    GivePlayerItem(client, "weapon_tagrenade");
    return true;
    
}