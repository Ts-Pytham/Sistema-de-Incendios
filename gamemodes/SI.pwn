/*==============================================================================
	Sistema de incendio para el servidor Insonmio RP
	Dias de desarrollo:
   	 - Primer  día: 31/10/2018
   	 - Segundo día: 01/11/2018
     - Tercer  día: 02/11/2018
   	 - Cuarto  día  03/11/2018
	Actualizaciones:
	 - Primera actualización: 31/10/2018
	 - Segunda actualización: 03/11/2018
	 - Ultima  actualizaciónn 03/11/2018 Por Nahuel_Martino [Remake del sistema]
==============================================================================*/
#include <a_samp>
#include <zcmd>
#include <YSI\y_iterate>
#include <YSI\y_timers>
#include <YSI\y_va>
#include <streamer>

#define KEY_AIM 		(128)
#define PRESSED(%0) 	(((newkeys & (%0)) == (%0)) && ((oldkeys & (%0)) != (%0)))
#define HOLDING(%0)		((newkeys & (%0)) == (%0))
#define RELEASED(%0)	(((newkeys & (%0)) != (%0)) && ((oldkeys & (%0)) == (%0)))
/*============================================================================*/
// News
/*============================================================================*/
new const Float:FireSpawns[][] = //Spawns para hacer pruebas y funciona :3
{
	{-435.877105,-65.066535,57.375000},
	{-441.662933,-48.567253,57.820522},
	{-526.853088,-54.844554,63.297294},
	{-523.505065,-95.833015,64.038917},
	{-487.222381,-84.077651,59.427005},
	{-477.773620,-101.502357,60.352760},
	{-486.720153,-112.526741,62.436687},
	{-527.187438,-102.897613,61.804168},
	{-537.125732,-98.337074,61.796875},
	{-537.743774,-102.765853,61.796875},
	{-542.138977,-74.430549,61.359375},
	{-538.969604,-61.055011,61.492187},
	{-559.972290,-53.728420,62.654983},
	{-592.914672,-36.442523,62.544052},
	{-587.902587,-20.327140,62.150367},
	{-565.383239,19.670621,60.374114},
	{-557.966674,35.535743,58.935722},
	{-455.845703,18.559186,48.941398},
	{-438.659484,29.182691,47.983871},
	{-443.032043,-11.831303,52.889038},
	{-389.783142,-96.763252,46.001243},
	{-376.661987,-96.624923,45.639770},
	{-397.521728,-117.658271,50.404052},
	{-405.090179,-144.923294,61.890106},
	{-381.922454,-202.175323,58.741809},
	{-394.516204,-214.852920,58.253440},
	{-446.219116,-217.831802,72.980880},
	{-463.344482,-216.681243,76.852218},
	{-453.202545,-203.928100,75.638458},
	{-473.148437,-176.724227,76.710937},
	{-488.261230,-173.931686,76.710937},
	{-491.630126,-193.816162,76.852111},
	{-500.105773,-180.402709,78.147178},
	{-522.162170,-216.857070,76.781135},
	{-558.836242,-216.745010,76.538101},
	{-576.576843,-206.805740,76.111053},
	{-607.147888,-198.596786,75.564193},
	{-627.281555,-167.350128,69.233169},
	{-535.287048,-177.721862,76.904663},
	{-555.697143,-182.206298,77.857437},
	{-548.944702,-181.382232,76.906250},
	{-547.547363,-196.969955,76.906250}
};
/*============================================================================*/
enum ServerData
{
	bool:Incendio,
	bool:Asistencia,
	Object[sizeof(FireSpawns)]
}
new ServerInfo[ServerData];

enum PlayerData
{
	Name[MAX_PLAYER_NAME],
	Asistiendo,
	Checkpoint,
	Bonus
}
new PlayerInfo[MAX_PLAYERS][PlayerData];
/*============================================================================*/
// Timers
/*============================================================================*/
timer IniciarIncendio[80000]()
{
	if(ServerInfo[Incendio]) return 0;
    ServerInfo[Incendio] = true;
	for(new i; i<sizeof(FireSpawns); i++) ServerInfo[Object][i] = CreateDynamicObject(18690,FireSpawns[i][0],FireSpawns[i][1],FireSpawns[i][2],0,0,0,0,-1,-1,300.0);
	ServerInfo[Asistencia] = true;
	SendClientMessageToAll(-1,"{37FC00}[Noticias/LS]: {D9D9D9}¡Se ha notificado un par de incendios en el bosque a las afueras de la ciudad!");
	SendClientMessageToAll(-1,"¿Te vas a reportar para ir al bosque para apagar el incendio? escribe /sivoy dentro de estos 20 segundos");
	defer Asistencias();
	return 1;
}
timer Asistencias[20000]() return ServerInfo[Asistencia] = false;
/*============================================================================*/
// Callbacks
/*============================================================================*/
public OnFilterScriptInit()
{
	UsePlayerPedAnims();
	print("\n=============================");
	print("  Sistema de incendios V2.0    ");
	print(" FS creado por Johan Sánchez   ");
	print("  Ayudantes: Nahuel_Martino    ");
	print("=============================\n");
	return 1;
}

public OnFilterScriptExit()
{
	return 1;
}

public OnPlayerConnect(playerid)
{
    GetPlayerName(playerid,PlayerInfo[playerid][Name],MAX_PLAYER_NAME);
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
    PlayerInfo[playerid][Name] = '\0';
	return 1;
}

public OnPlayerSpawn(playerid)
{
	return 1;
}

public OnPlayerEnterDynamicCP(playerid, checkpointid)
{
	if((PlayerInfo[playerid][Checkpoint] == checkpointid) && ServerInfo[Incendio] && PlayerInfo[playerid][Asistiendo] == 1)
	{
	    PlayerInfo[playerid][Asistiendo] = 2;
	    DestroyDynamicCP(PlayerInfo[playerid][Checkpoint]);
		for(new i; i<sizeof(FireSpawns); i++) SetPlayerMapIcon(playerid,i,FireSpawns[i][0],FireSpawns[i][1],FireSpawns[i][2],0,0xFF0000FF,MAPICON_LOCAL);
		SendClientMessageToAllEx(-1,"El bombero %s acaba de llegar al bosque",PlayerInfo[playerid][Name]);
		SendClientMessage(playerid,-1,"** Debes apagar el fuego y rescatar a los guardabosques!");
		GivePlayerWeapon(playerid,42,10000);
	}
	return 1;
}
public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(ServerInfo[Incendio] && PlayerInfo[playerid][Asistiendo] == 2 && HOLDING(KEY_AIM | KEY_FIRE) && (GetPlayerWeapon(playerid) == 42))
	{
        for(new i; i<sizeof(FireSpawns); i++)
		{
			if(IsPlayerInRangeOfPoint(playerid,5.0,FireSpawns[i][0],FireSpawns[i][1],FireSpawns[i][2]) && IsValidDynamicObject(ServerInfo[Object][i]))
			{
			    DestroyDynamicObject(ServerInfo[Object][i]);
				foreach(new i2 : Player) RemovePlayerMapIcon(i2,i);
				PlayerPlaySound(playerid,1058,0,0,0);
				PlayerInfo[playerid][Bonus]++;
				SendClientMessageEx(playerid,-1,"Fuego Apagado: %d/%d",PlayerInfo[playerid][Bonus],sizeof(FireSpawns));
				break;
			}
		}
	}
	return 1;
}

/*============================================================================*/
stock SendClientMessageToAllEx(colour, const fmat[], va_args<>)
{
	new str[144];
	va_format(str, sizeof (str), fmat, va_start<2>);
	return SendClientMessageToAll(colour, str);
}

stock SendClientMessageEx(playerid, colour, const fmat[], va_args<>)
{
	new str[144];
	va_format(str, sizeof (str), fmat, va_start<3>);
	return SendClientMessage(playerid, colour, str);
}

/*============================================================================*/
CMD:bosque(playerid, params[]) return SetPlayerPos(playerid,-592.783874,-28.224105,63.871223);
CMD:newfire(playerid, params[])
{
	new Float:PlayerPos[3];
	GetPlayerPos(playerid,PlayerPos[0],PlayerPos[1],PlayerPos[2]);
	SendClientMessageEx(playerid,-1,"{FF0000}{%f,%f,%f},",PlayerPos[0],PlayerPos[1],(PlayerPos[2] - 2));
	printf("{%f,%f,%f},",PlayerPos[0],PlayerPos[1],(PlayerPos[2] - 2));
	//Luego de obtener las posiciones para tu fuego, lo copias desde la consola y lo pegas en FireSpawns
	return 1;
}
CMD:incendiar(playerid, params[])
{
	IniciarIncendio();
	return 1;
}
CMD:sivoy(playerid, params[])
{
	if(ServerInfo[Incendio] && ServerInfo[Asistencia] && PlayerInfo[playerid][Asistiendo] == 0)
	{
	    PlayerInfo[playerid][Asistiendo] = 1;
		SendClientMessageToAllEx(-1,"{0015FA}El bombero %s se ha reportado para ir al bosque",PlayerInfo[playerid][Name]);
		PlayerInfo[playerid][Checkpoint] = CreateDynamicCP(-510.531250,-83.661071,62.151420,3.0,0,-1,playerid,300.0);
	}
	else SendClientMessage(playerid,-1,"No puedes usar este comando ahora");
	return 1;
}
