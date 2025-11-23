#pragma semicolon 1
#pragma newdecls required

static char g_Boowomp[][] = {
	"player/taunt_gas_blast.wav",
};
void ReverseRocket_Precache()
{
	PrecacheSoundArray(g_Boowomp);
}

public void Weapon_ReserveRocket(int client, int weapon, bool crit)
{
	EmitSoundToAll(g_Boowomp[GetRandomInt(0, sizeof(g_Boowomp) - 1)], client, SNDCHAN_WEAPON, 80, _, 1.0, 100, .soundtime = GetGameTime() - 4.75);
}
