
static GlobalForward OnWin;
void Natives_PluginLoad()
{
	OnWin = new GlobalForward("TGG_OnWin", ET_Ignore, Param_Cell);
}

void Native_OnWin(int client)
{
	Call_StartForward(OnWin);
	Call_PushCell(client);
	Call_Finish();
}