#pragma semicolon 1
#pragma newdecls required

static int how_many_times_fisted[MAXPLAYERS];


void KahmlFistMapStart()
{
	PrecacheSound("items/powerup_pickup_knockout_melee_hit.wav");
}


public void Fists_of_Kahml(int client, int weapon, bool crit, int slot)
{
	int viewmodelModel;
	viewmodelModel = EntRefToEntIndex(i_Viewmodel_PlayerModel[client]);
		
	float flPos[3]; // original
	float flAng[3]; // original

	if(how_many_times_fisted[client] >= 3)
	{
		if(IsValidEntity(viewmodelModel))
		{
			GetAttachment(viewmodelModel, "effect_hand_r", flPos, flAng);
					
			int particler = ParticleEffectAt(flPos, "raygun_projectile_red_crit", 0.25);
					
			SetParent(viewmodelModel, particler, "effect_hand_r");
			
			GetAttachment(viewmodelModel, "effect_hand_l", flPos, flAng);
			
			int particlel = ParticleEffectAt(flPos, "raygun_projectile_red_crit", 0.25);
			
					
			SetParent(viewmodelModel, particlel, "effect_hand_l");			
		}
		Attributes_Set(weapon, 1, 2.75);
		
		CreateTimer(0.2, Apply_cool_effects_kahml, client, TIMER_FLAG_NO_MAPCHANGE);
		how_many_times_fisted[client] = 0;
	}
	else
	{
		if(IsValidEntity(viewmodelModel))
		{
			GetAttachment(viewmodelModel, "effect_hand_r", flPos, flAng);
					
			int particler = ParticleEffectAt(flPos, "raygun_projectile_blue_crit", 0.25);
					
			SetParent(viewmodelModel, particler, "effect_hand_r");
			
			GetAttachment(viewmodelModel, "effect_hand_l", flPos, flAng);
			
			int particlel = ParticleEffectAt(flPos, "raygun_projectile_blue_crit", 0.25);
					
			SetParent(viewmodelModel, particlel, "effect_hand_l");	
		}
				
		Attributes_Set(weapon, 1, 1.0);
		how_many_times_fisted[client] += 1;
	}
}

public Action Apply_cool_effects_kahml(Handle cut_timer, int client)
{
	if (IsValidClient(client))
	{
		EmitSoundToAll("items/powerup_pickup_knockout_melee_hit.wav", client, SNDCHAN_STATIC, 70, _, 0.35);
		Client_Shake(client, 0, 25.0, 15.0, 0.25);
	}
	return Plugin_Handled;
}