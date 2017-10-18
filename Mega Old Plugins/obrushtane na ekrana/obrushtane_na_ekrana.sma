#include <amxmodx>
#include fakemeta

#define MAX_PLAYERS 32

#define SetUserReversed(%1)		g_bMigraineux |= 1<<(%1 & 31)
#define ClearUserReversed(%1)		g_bMigraineux &= ~( 1<<(%1 & 31) )
#define HasUserMigraine(%1)		g_bMigraineux &  1<<(%1 & 31)

enum _:GlobalState {None, Terrorists, Cts, All}

new g_bMigraineux

new Float:g_vecPunchAngles[MAX_PLAYERS+1][3]
new g_iFfPlayerPreThink
//new g_iGlobalState
new g_Max



#define SHAKE_AMPLITUDE    15.0    // max = 16.0
#define SHAKE_DURATION    4.0        // max = 16.0
#define SHAKE_FREQUENCY    256.0    // max = 256.0

#define PLUGIN "Tras ?"
#define VERSION "0.0.1"

new gmsgShake

public plugin_init()
{
    register_plugin( PLUGIN, VERSION, "ConnorMcLeod" )

    gmsgShake = get_user_msgid("ScreenShake")

    //register_clcmd("say /tras", "ClCmd_Tras")
    register_clcmd("say /tras2", "ClCmd_Tras2")
    g_Max = get_maxplayers()
    //register_clcmd("say_team /tras", "ClCmd_Tras")
}
/*
public ClCmd_Tras( id )
{
	new shakeAmplitude = __FixedUnsigned16(SHAKE_AMPLITUDE, 1<<12)
	new shakeDuration  = __FixedUnsigned16(SHAKE_DURATION, 1<<12)
	new shakeFrequency = __FixedUnsigned16(SHAKE_FREQUENCY, 1<<8)

	for( new i = 1 ; i <= g_Max ; i++ )
	{
		if( !is_user_connected(i) )
			continue;
			
		if( !is_user_alive(i) )
			continue;
			
		//message_begin(MSG_ONE_UNRELIABLE, gmsgShake, .player = players[g_Max])
		message_begin(MSG_ONE, gmsgShake, {0,0,0}, g_Max[i])
		{
			write_short( shakeAmplitude )  // shake amount.
			write_short( shakeDuration )   // shake lasts this long.
			write_short( shakeFrequency )  // shake noise frequency.
		}
		
		message_end()
		SetUserReversed(id)
		CheckForward()
		set_task(1.0, "ClCmd_Tras2",id)
	}
	return PLUGIN_HANDLED
}*/


public ClCmd_Tras2( id )
{
    new players[32], num
    get_players(players, num, "a")

    new shakeAmplitude = __FixedUnsigned16(SHAKE_AMPLITUDE, 1<<12)
    new shakeDuration  = __FixedUnsigned16(SHAKE_DURATION, 1<<12)
    new shakeFrequency = __FixedUnsigned16(SHAKE_FREQUENCY, 1<<8)

    for(--num; num>=0; num--)
    {
        message_begin(MSG_ONE_UNRELIABLE, gmsgShake, .player = players[num])
        {
		write_short( shakeAmplitude )  // shake amount.
		write_short( shakeDuration )   // shake lasts this long.
		write_short( shakeFrequency )  // shake noise frequency.
		//SetUserReversed(id)
        }
        message_end()
        //SetUserReversed(id)
        //CheckForward()
        ClearUserReversed(id)
        CheckForward()
    }
    return PLUGIN_HANDLED
}

__FixedUnsigned16(Float:flValue, iScale)
{
    new iOutput;

    iOutput = floatround(flValue * iScale)

    if ( iOutput < 0 )
        iOutput = 0

    if ( iOutput > 0xFFFF )
        iOutput = 0xFFFF

    return iOutput
}  


public client_putinserver( id )
{
	ClearUserReversed(id)
	CheckForward()
}

public client_disconnect( id )
{
	ClearUserReversed(id)
	CheckForward()
}

public PlayerPreThink( id )
{
	if(HasUserMigraine(id) && is_user_alive(id))
	{
		if( g_vecPunchAngles[id][1] < 180.0 )
		{
			g_vecPunchAngles[id][1] += 2.0
			g_vecPunchAngles[id][0] = g_vecPunchAngles[id][1] * 2.0
		}
		else
		{
			g_vecPunchAngles[id][0] = 0.0
		}

		static Float:vecPunchAngle[3]
		vecPunchAngle[0] = g_vecPunchAngles[id][0]
		vecPunchAngle[1] = g_vecPunchAngles[id][0]
		vecPunchAngle[2] = g_vecPunchAngles[id][1]

		set_pev(id, pev_punchangle, vecPunchAngle)
	}
}

CheckForward()
{
	if( !g_bMigraineux != !g_iFfPlayerPreThink )
	{
		if( g_bMigraineux )
		{
			g_iFfPlayerPreThink = register_forward(FM_PlayerPreThink, "PlayerPreThink")
		}
		else
		{
			unregister_forward(FM_PlayerPreThink, g_iFfPlayerPreThink)
			g_iFfPlayerPreThink = 0
		}
	}
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1026\\ f0\\ fs16 \n\\ par }
*/
