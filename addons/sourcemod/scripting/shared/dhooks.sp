#pragma semicolon 1
#pragma newdecls required

enum struct RawHooks
{
	int Ref;
	int Pre;
	int Post;
}



void DHook_Setup()
{
	GameData gamedata = LoadGameConfigFile("zombie_riot");
	
	if (!gamedata) 
	{
		SetFailState("Failed to load gamedata (zombie_riot).");
	} 
	
	DHook_CreateDetour(gamedata, "CTFPlayer::CanAirDash", DHook_CanAirDashPre);
	DHook_CreateDetour(gamedata, "CTFPlayer::CanAirDash", DHook_CanAirDashPre);

	HookItemIterateAttribute = DynamicHook.FromConf(gamedata, "CEconItemView::IterateAttributes");
	m_Item = FindSendPropInfo("CEconEntity", "m_Item");
	FindSendPropInfo("CEconEntity", "m_bOnlyIterateItemViewAttributes", _, _, m_bOnlyIterateItemViewAttributes);
}



public MRESReturn DHook_CanAirDashPre(int client, DHookReturn ret)
{
	ret.Value = false;
	return MRES_Supercede;
}





void DHook_EntityDestoryed()
{
	RequestFrame(DHook_EntityDestoryedFrame);
}

public void DHook_EntityDestoryedFrame()
{
	if(RawEntityHooks)
	{
		int length = RawEntityHooks.Length;
		if(length)
		{
			RawHooks raw;
			for(int i; i < length; i++)
			{
				RawEntityHooks.GetArray(i, raw);
				if(!IsValidEntity(raw.Ref))
				{
					if(raw.Pre != INVALID_HOOK_ID)
						DynamicHook.RemoveHook(raw.Pre);
					
					if(raw.Post != INVALID_HOOK_ID)
						DynamicHook.RemoveHook(raw.Post);
					
					RawEntityHooks.Erase(i--);
					length--;
				}
			}
		}
	}
}


stock Handle CheckedDHookCreateFromConf(Handle game_config, const char[] name) {
    Handle res = DHookCreateFromConf(game_config, name);

    if (res == INVALID_HANDLE) {
        SetFailState("Failed to create detour for %s", name);
    }

    return res;
}


stock void DHook_HookStripWeapon(int entity)
{
	if(m_Item > 0 && m_bOnlyIterateItemViewAttributes > 0)
	{
		if(!RawEntityHooks)
			RawEntityHooks = new ArrayList(sizeof(RawHooks));
		
		Address pCEconItemView = GetEntityAddress(entity) + view_as<Address>(m_Item);
		
		RawHooks raw;
		
		raw.Ref = EntIndexToEntRef(entity);
		raw.Pre = HookItemIterateAttribute.HookRaw(Hook_Pre, pCEconItemView, DHook_IterateAttributesPre);
		raw.Post = HookItemIterateAttribute.HookRaw(Hook_Post, pCEconItemView, DHook_IterateAttributesPost);
		
		RawEntityHooks.PushArray(raw);
	}
}

public MRESReturn DHook_IterateAttributesPre(Address pThis, DHookParam hParams)
{
	StoreToAddress(pThis + view_as<Address>(m_bOnlyIterateItemViewAttributes), true, NumberType_Int8);
	return MRES_Ignored;
}

public MRESReturn DHook_IterateAttributesPost(Address pThis, DHookParam hParams)
{
	StoreToAddress(pThis + view_as<Address>(m_bOnlyIterateItemViewAttributes), false, NumberType_Int8);
	return MRES_Ignored;
}
