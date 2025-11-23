#pragma semicolon 1
#pragma newdecls required


static Handle Local_Timer[MAXPLAYERS] = {null, ...};
public void PosionSandvichMapStart()
{
	PrecacheSound("mvm/mvm_tank_explode.wav");
	PrecacheSound("mvm/sentrybuster/mvm_sentrybuster_intro.wav");
}

public void PosionSandvichCreate(int client, int weapon)
{
	if (Local_Timer[client] != null)
	{
		delete Local_Timer[client];
		Local_Timer[client] = null;
	}
	DataPack pack;
	Local_Timer[client] = CreateDataTimer(0.1, Timer_Local, pack, TIMER_REPEAT);
	pack.WriteCell(client);
	pack.WriteCell(EntIndexToEntRef(client));
	pack.WriteCell(EntIndexToEntRef(weapon));
}

static Action Timer_Local(Handle timer, DataPack pack)
{
	pack.Reset();
	int clientidx = pack.ReadCell();
	int client = EntRefToEntIndex(pack.ReadCell());
	int weapon = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidClient(client) || !IsClientInGame(client) || !IsPlayerAlive(client) || !IsValidEntity(weapon))
	{
		Local_Timer[clientidx] = null;

		return Plugin_Stop;
	}	
	if (TF2_IsPlayerInCondition(client, TFCond_Taunting))
	{
		Local_Timer[clientidx] = null;
		DataPack pack1 = new DataPack();
		pack1.WriteCell(EntIndexToEntRef(client));
		pack1.WriteCell(EntIndexToEntRef(weapon));
		RequestFrames(PosionSandvich_ExplodeMeNow, RoundToNearest(50.0 * 1.0), pack1);
		return Plugin_Stop;
	}
	return Plugin_Continue;
}


void PosionSandvich_ExplodeMeNow(DataPack pack)
{
	pack.Reset();
	int client = EntRefToEntIndex(pack.ReadCell());
	int weapon = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidClient(client) || !IsClientInGame(client) || !IsPlayerAlive(client) || !IsValidEntity(weapon))
	{
		return;
	}
	if (!TF2_IsPlayerInCondition(client, TFCond_Taunting))
	{
		PosionSandvichCreate(client, weapon);
		return;
	}

	SDKHooks_TakeDamage(client, client, client, 9999.0, DMG_PREVENT_PHYSICS_FORCE, _, {0.0, 0.0, 0.0});
}