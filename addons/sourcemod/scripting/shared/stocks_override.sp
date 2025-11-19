#pragma semicolon 1
#pragma newdecls required

//#define GetPlayerWeaponSlot GetPlayerWeaponSlot__DontUse

void Stock_TakeDamage(int entity = 0, int inflictor = 0, int attacker = 0, float damage = 0.0, int damageType=DMG_GENERIC, int weapon=-1,const float damageForce[3]=NULL_VECTOR, const float damagePosition[3]=NULL_VECTOR, bool bypassHooks = false, int Zr_damage_custom = 0)
{
	bypassHooks = false;
	//NEVER bypass hooks. EVER. EVER EVER EVER.
	SDKHooks_TakeDamage(entity, inflictor, attacker, damage, damageType, IsValidEntity(weapon) ? weapon : -1, damageForce, damagePosition, bypassHooks);

}

//We need custom Defaults for this, mainly bypass hooks to FALSE. i dont want to spend 5 years on replacing everything.
//im sorry.
#define SDKHooks_TakeDamage Stock_TakeDamage

bool Stock_IsValidEntity(int entity)
{
	if(entity == 0 || entity == -1)
	{
		return false;
	}
	else
	{
		return IsValidEntity(entity);
	}

}

#define IsValidEntity Stock_IsValidEntity

stock void Stock_SetEntityMoveType(int entity, MoveType mt)
{
	SetEntityMoveType(entity, mt);
}

#define SetEntityMoveType Stock_SetEntityMoveType


#define KillTimer KILLTIMER_DONOTUSE_USE_DELETE

//In this case i never need the world ever.
void Stock_SetHudTextParams(float x, float y, float holdTime, int r, int g, int b, int a, int effect = 1, float fxTime=0.1, float fadeIn=0.1, float fadeOut=0.1)
{
	SetHudTextParams(x, y, holdTime, r, g, b, a, effect, fxTime, fadeIn, fadeOut);
}

#define SetHudTextParams Stock_SetHudTextParams

int Stock_ShowSyncHudText(int client, Handle sync, const char[] message, any ...)
{
	int ReturnFlags = GetEntProp(client, Prop_Send, "m_iHideHUD");
	if(ReturnFlags & HIDEHUD_ALL) //hide.
		return 0;

	char buffer[512];
	VFormat(buffer, sizeof(buffer), message, 4);
	return ShowSyncHudText(client, sync, buffer);
}
#define ShowSyncHudText Stock_ShowSyncHudText

void Stock_PrintHintText(int client, const char[] format, any ...)
{
	int ReturnFlags = GetEntProp(client, Prop_Send, "m_iHideHUD");
	if(ReturnFlags & HIDEHUD_ALL) //hide.
		return;

	char buffer[512];
	VFormat(buffer, sizeof(buffer), format, 3);
	PrintHintText(client, buffer);
}
#define PrintHintText Stock_PrintHintText

stock void ResetToZero(any[] array, int length)
{
    for(int i; i<length; i++)
    {
        array[i] = 0;
    }
}

stock void ResetToZero2(any[][] array, int length1, int length2)
{
    for(int a; a<length1; a++)
    {
        for(int b; b<length2; b++)
        {
            array[a][b] = 0;
        }
    }
}

stock void ResetFloatToZero(any[] array, int length)
{
    for(int i; i<length; i++)
    {
        array[i] = 0.0;
    }
}

#define Zero(%1)        ResetToZero(%1, sizeof(%1))
#define Zero2(%1)    ResetToZero2(%1, sizeof(%1), sizeof(%1[]))
#define ZeroFloat(%1)        ResetFloatToZero(%1, sizeof(%1))

#define TF2_RemoveWeaponSlot RemoveSlotWeapons
#define TF2_RemoveAllWeapons RemoveAllWeapons

stock void RemoveSlotWeapons(int client, int slot)
{
	char buffer[36];
	int entity;
	bool found;
	do
	{
		found = false;
		
		int i;
		while(TF2_GetItem(client, entity, i))
		{
			GetEntityClassname(entity, buffer, sizeof(buffer));
			if(TF2_GetClassnameSlot(buffer, entity) == slot)
			{
				TF2_RemoveItem(client, entity);
				found = true;
				break;
			}
		}
	}
	while(found);
}

stock void RemoveAllWeapons(int client)
{
	int entity;
	bool found;
	do
	{
		found = false;

		int i;
		while(TF2_GetItem(client, entity, i))
		{
			TF2_RemoveItem(client, entity);
			found = true;
			break;
		}
	}
	while(found);
}


stock void TF2_RemoveItem(int client, int weapon)
{
	/*if(TF2_IsWearable(weapon))
	{
		TF2_RemoveWearable(client, weapon);
		return;
	}*/

	int entity = GetEntPropEnt(weapon, Prop_Send, "m_hExtraWearable");
	if(entity != -1)
		TF2_RemoveWearable(client, entity);

	entity = GetEntPropEnt(weapon, Prop_Send, "m_hExtraWearableViewModel");
	if(entity != -1)
		TF2_RemoveWearable(client, entity);

	RemovePlayerItem(client, weapon);
	RemoveEntity(weapon);
}



//This is here for rpg, because it relies on triggers, teleportentity disables triggers for an entity for a frame for some reason.
stock void Custom_TeleportEntity(int entity, const float origin[3] = NULL_VECTOR, const float angles[3] = NULL_VECTOR, const float velocity[3] = NULL_VECTOR, bool do_original = false)
{
	if(!do_original && entity <= MaxClients)
	{
		if(origin[1] != NULL_VECTOR[1] || origin[0] != NULL_VECTOR[0] || origin[2] != NULL_VECTOR[2])
		{
			if(origin[0] == 0.0 && origin[1] == 0.0 && origin[2] == 0.0)
				LogStackTrace("Possible unintended 0 0 0 teleport");
			
			Custom_SDKCall_SetLocalOrigin(entity, origin);
		}

		if(angles[1] != NULL_VECTOR[1] || angles[0] != NULL_VECTOR[0] || angles[2] != NULL_VECTOR[2])
		{
			if(entity <= MaxClients)
			{
				float angles2[3];
				angles2 = angles;
				SnapEyeAngles(entity, angles2);
			}
			else
			{
				SetEntPropVector(entity, Prop_Data, "m_angRotation", angles); 
			}
		}

		if(velocity[0] != NULL_VECTOR[0] || velocity[1] != NULL_VECTOR[1] || velocity[2] != NULL_VECTOR[2])
		{
			Custom_SetAbsVelocity(entity, velocity);
		}
	}
	else
	{
		TeleportEntity(entity,origin,angles,velocity);
	}
}

stock void Custom_SDKCall_SetLocalOrigin(int index, const float localOrigin[3])
{
	if(g_hSetLocalOrigin)
	{
		SDKCall(g_hSetLocalOrigin, index, localOrigin);
	}
}
stock void Custom_SnapEyeAngles(int client, const float viewAngles[3])
{
	SDKCall(g_hSnapEyeAngles, client, viewAngles);
}

stock void Custom_SetAbsVelocity(int client, const float viewAngles[3])
{
	SDKCall(g_hSetAbsVelocity, client, viewAngles);
}

#define TeleportEntity Custom_TeleportEntity


void Edited_TF2_RegeneratePlayer(int client)
{
#if defined ZR
	TF2_SetPlayerClass_ZR(client, CurrentClass[client], false, false);
#endif
	//delete at all times, they have no purpose here, you respawn.
	TF2_RegeneratePlayer(client);
}

#define TF2_RegeneratePlayer Edited_TF2_RegeneratePlayer


stock void Edited_TF2_RespawnPlayer(int client)
{
	TF2_SetPlayerClass_ZR(client, CurrentClass[client], false, false);
	
	//delete at all times, they have no purpose here, you respawn.
	TF2_RespawnPlayer(client);
}

#define TF2_RespawnPlayer Edited_TF2_RespawnPlayer

stock void PrecacheSoundList(const char[][] array, int length)
{
    for(int i; i < length; i++)
    {
		PrecacheSound(array[i]);
    }
}

#define PrecacheSoundArray(%1)        PrecacheSoundList(%1, sizeof(%1))

#define TF2Attrib_GetByDefIndex OLD_CODE_FIX_IT
#define TF2Items_SetAttribute OLD_CODE_FIX_IT

stock void Stock_RemoveEntity(int entity)
{
	if(entity >= 0 && entity <= MaxClients)
	{
		ThrowError("Unintended RemoveEntity on entity %d.", entity);
		return;
	}

	if(entity > MaxClients && entity < MAXENTITIES && ViewChange_IsViewmodelRef(EntIndexToEntRef(entity)))
	{
		LogStackTrace("Possible unintended RemoveEntity entity index leaking.");
	}

	RemoveEntity(entity);
}

#define RemoveEntity Stock_RemoveEntity

stock int EntRefToEntIndexFast(int &ref)
{
	if(ref == -1)
		return ref;
	
	int entity = EntRefToEntIndex(ref);
	if(entity == -1)
		ref = -1;
	
	return entity;
}
