#pragma semicolon 1
#pragma newdecls required


void SDKHooks_ClearAll()
{

}


void SDKHook_PluginStart()
{

}


void SDKHook_MapStart()
{

}


stock void SDKHook_HookClient(int client)
{
	SDKUnhook(client, SDKHook_WeaponSwitchPost, OnWeaponSwitchPost);
	SDKHook(client, SDKHook_WeaponSwitchPost, OnWeaponSwitchPost);
	SDKUnhook(client, SDKHook_TraceAttack, Player_TraceAttack);
	SDKHook(client, SDKHook_TraceAttack, Player_TraceAttack);

}



public void OnWeaponSwitchPost(int client, int weapon)
{
	RequestFrame(OnWeaponSwitchFrame, GetClientUserId(client));
}

public void OnWeaponSwitchFrame(int userid)
{
	int client = GetClientOfUserId(userid);
	if(client)
	{
		ViewChange_Update(client, false);
		// We delay ViewChange_Switch by a frame so it doesn't mess with the regenerate process
	}
}


float f_TraceAttackWasTriggeredSameFrame[MAXENTITIES];

public Action Player_TraceAttack(int victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& ammotype, int hitbox, int hitgroup)
{
//	PrintToChatAll("ow NPC_TraceAttack");
	if(attacker < 1 || attacker > MaxClients || victim == attacker)
		return Plugin_Continue;
		
	if(inflictor < 1 || inflictor > MaxClients)
		return Plugin_Continue;

	i_HasBeenHeadShotted[victim] = false;
	
	int weapon = GetEntPropEnt(attacker, Prop_Send, "m_hActiveWeapon");
	if(!IsValidEntity(weapon))
		return Plugin_Continue;
	bool WasAlreadyPlayed = false;
	if(f_TraceAttackWasTriggeredSameFrame[victim] == GetGameTime())
	{
		WasAlreadyPlayed = true;
	}
	f_TraceAttackWasTriggeredSameFrame[victim] = GetGameTime();



	if(hitgroup == HITGROUP_HEAD)
	{
		i_HasBeenHeadShotted[victim] = true;
		//incase it has headshot multi
		damage *= Attributes_Get(weapon, Attrib_HeadshotBonus, 1.0);

		damage *= 1.5;
		
		int pitch = GetRandomInt(90, 110);
		int random_case = GetRandomInt(1, 2);
		float volume = 0.7;
	
		if(!WasAlreadyPlayed)
		{
			DisplayCritAboveNpc(victim, attacker, false);
		}
		switch(random_case)
		{
			case 1:
			{
				for(int client=1; client<=MaxClients; client++)
				{
					if(IsClientInGame(client) && client != attacker)
					{
						EmitSoundToClient(client, "zombiesurvival/headshot1.wav", victim, _, 80, _, volume, pitch);
					}
				}
				EmitSoundToClient(attacker, "zombiesurvival/headshot1.wav", _, _, 90, _, volume, pitch);
			}
			case 2:
			{
				for(int client=1; client<=MaxClients; client++)
				{
					if(IsClientInGame(client) && client != attacker)
					{
						EmitSoundToClient(client, "zombiesurvival/headshot2.wav", victim, _, 80, _, volume, pitch);
					}
				}
				EmitSoundToClient(attacker, "zombiesurvival/headshot2.wav", _, _, 90, _, volume, pitch);
			}
		}
	}
	return Plugin_Changed;
}