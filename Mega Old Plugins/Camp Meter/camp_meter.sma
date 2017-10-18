#include <amxmodx>
#include <fun>

#define SND_STOP (1<<5)

new playercoord0[33][3]
new playercoord1[33][3]
new playercoord2[33][3]
new playercoord3[33][3]
new playercoord4[33][3]
new campmeter[33]
new bool:pausecounter[33]
new bool:bombplanted
new bool:de_map
new camptolerancedefending = 180
new camptoleranceattacking = 200



public sqrt(num) {
	new div = num; 
	new result = 1;
	while (div > result) {	// end when div == result, or just below
		div = (div + result) / 2	// take mean value as new divisor
		result = num / div
	}
	return div;
}

public unpausecounter(parm[]) {
	new id = parm[0]
	pausecounter[id] = false
	return PLUGIN_CONTINUE
}

public displaymeter(id) {
	if (get_cvar_num("anticamping_meter") != 0) {
		if (campmeter[id] > 100) {
			set_hudmessage(random(255), random(255), random(255), -1.0, 0.3, 2, 0.1, 1.5, 0.02, 0.02, -2)
			show_hudmessage(id,"Go away !!!^nYour CAMPMETER is %i%",campmeter[id])
		} else if (campmeter[id] > 90) {
			set_hudmessage(random(255), random(255), random(255), -1.0, 0.3, 2, 0.1, 1.5, 0.02, 0.02, -2)
			show_hudmessage(id,"Go away !!!^nYour CAMPMETER is %i%",campmeter[id])
		} else if (campmeter[id] > 80){
			set_hudmessage(random(255), random(255), random(255), -1.0, 0.3, 2, 0.1, 2.1, 0.02, 0.02, -2)
			show_hudmessage(id,"CAMPmeter: %i%",campmeter[id])
		} else if (campmeter[id] > 50 ) {
			set_hudmessage(random(255), random(255), random(255), -0.9, 0.3, 2, 0.1, 2.1, 0.02, 0.02, -2)
			show_hudmessage(id,"CampMeter: %i%",campmeter[id])
		} else if (campmeter[id] > 20 ) {
			set_hudmessage(random(255), random(255), random(255), -0.9, 0.3, 2, 0.1, 2.1, 0.02, 0.02, -2)
			show_hudmessage(id,"Campmeter: %i%",campmeter[id])
			
		}
	}
	return PLUGIN_HANDLED
}

public checkcamping(){
	if (get_cvar_num("anticamping") == 0){
		set_task(1.0,"checkcamping",1)
		return PLUGIN_CONTINUE
	}
	new players[32]
	new numberofplayers
	new variance[3]
	new average[3]
	new variancetotal
	new standarddeviation
	new id
	new team
	new i
	new j
	get_players(players, numberofplayers, "a")
	for (i = 0; i < numberofplayers; ++i) {
		while (i < numberofplayers && pausecounter[players[i]]) {
			++i
		}
		if (i >= numberofplayers){
			set_task(1.0,"checkcamping",1)
			return PLUGIN_CONTINUE
		}
		id = players[i]
		for (j = 0; j < 3; ++j) {
			playercoord4[id][j] = playercoord3[id][j]
			playercoord3[id][j] = playercoord2[id][j]
			playercoord2[id][j] = playercoord1[id][j]
			playercoord1[id][j] = playercoord0[id][j]
		}
		get_user_origin(id, playercoord0[id], 0)
		for (j = 0; j < 3; ++j) {
			average[j] = (playercoord0[id][j] +
							playercoord1[id][j] +
							playercoord2[id][j] +
							playercoord3[id][j] +
							playercoord4[id][j]) / 5
			variance[j] = (((playercoord0[id][j] - average[j]) * (playercoord0[id][j] - average[j]) +
							  (playercoord1[id][j] - average[j]) * (playercoord1[id][j] - average[j]) +
							  (playercoord2[id][j] - average[j]) * (playercoord2[id][j] - average[j]) +
							  (playercoord3[id][j] - average[j]) * (playercoord3[id][j] - average[j]) +
							  (playercoord4[id][j] - average[j]) * (playercoord4[id][j] - average[j])) / 4)
		}
		variancetotal=variance[0]+variance[1]+variance[2]
		standarddeviation=sqrt(variancetotal)
		team = get_user_team(id)
		if (!de_map){
			if (team==2)	// Team 1 = Terro, Team 2 = CT
				campmeter[id] += (camptoleranceattacking - standarddeviation) / get_cvar_num("anticamping_camptime")
			else
				campmeter[id] += (camptoleranceattacking - standarddeviation) / get_cvar_num("anticamping_camptime")
		}
		else if (bombplanted){
			if (team == 1)	// Team 1 = Terro, Team 2 = CT
				campmeter[id] = 0
			else
				campmeter[id] += (camptoleranceattacking-standarddeviation)/get_cvar_num("anticamping_camptime")
		}
		else{
			if (team==2)	// Team 1 = Terro, Team 2 = CT
				campmeter[id] += (camptolerancedefending-standarddeviation)/get_cvar_num("anticamping_camptime")
			else
				campmeter[id] += (camptoleranceattacking-standarddeviation)/get_cvar_num("anticamping_camptime")
		}
		if (campmeter[id] < 80 ) {
			emit_sound(id,CHAN_VOICE,"player/heartbeat1.wav", 0.0, ATTN_NORM, SND_STOP, PITCH_NORM)
		}
		if (campmeter[id] < 0) {
			campmeter[id] = 0
		} else if (campmeter[id]>100) {
			switch(get_cvar_num("anticamping")) {
				case 1: {
					user_slap(id,get_cvar_num("anticamping_healthpunish"))
				}
				case 2: {
					set_user_health(id, get_user_health(id) - get_cvar_num("anticamping_healthpunish"))
				}
				case 3: {
					emit_sound(id,CHAN_VOICE,"player/heartbeat1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
				}
			}
			campmeter[id] = 100
		} else if (campmeter[id] > 90) {
			switch(get_cvar_num("anticamping")) {
				case 1: {
					user_slap(id,get_cvar_num("anticamping_healthpunish") / 5)
				}
				case 2: {
					set_user_health(id, get_user_health(id) - get_cvar_num("anticamping_healthpunish") / 5)
				}
				case 3: {
					emit_sound(id,CHAN_VOICE,"player/heartbeat1.wav", 0.5, ATTN_NORM, 0, PITCH_NORM)
				}
			}
		} else if (campmeter[id]>80){
			switch(get_cvar_num("anticamping")) {
				case 1: {
					user_slap(id,get_cvar_num("anticamping_healthpunish") / 10)
				}
				case 2: {
					set_user_health(id, get_user_health(id) - get_cvar_num("anticamping_healthpunish") / 10)
				}
				case 3: {
					emit_sound(id,CHAN_VOICE,"player/heartbeat1.wav", 0.1, ATTN_NORM, 0, PITCH_NORM)
				}
			}
		}
		displaymeter(id)
	}
	set_task(2.0,"checkcamping",1)
	return PLUGIN_CONTINUE
}

public damage_event(id) {
	if (get_cvar_num("anticamping") != 0) {
		new enemy = get_user_attacker(id)
		if (is_user_connected(enemy) && get_user_team(id)!=get_user_team(enemy)) {
			campmeter[id]=0
			campmeter[enemy]=0
		}
		return PLUGIN_CONTINUE
	}
	return PLUGIN_CONTINUE
}

public new_round(id) {
	if (get_cvar_num("anticamping") != 0) {
		bombplanted=false
		pausecounter[id]=true
		campmeter[id]=0
		new Float:freezetime = get_cvar_float("mp_freezetime")+1.0
		new parm[1]
		parm[0]=id
		set_task(freezetime,"unpausecounter",0,parm,1)
		return PLUGIN_CONTINUE
	}
	return PLUGIN_CONTINUE
}

public bartime_event(id) {
	if (get_cvar_num("anticamping") != 0) {
		pausecounter[id]=true
		campmeter[id]=0
		new Float:bar_time=float(read_data(1)+1)
		new parm[1]
		parm[0]=id
		set_task(bar_time,"unpausecounter",0,parm,1)
		return PLUGIN_CONTINUE
	}
	return PLUGIN_CONTINUE
}

public bomb_planted() {
	if (get_cvar_num("anticamping") != 0) {
		bombplanted=true
		return PLUGIN_CONTINUE
	}
	return PLUGIN_CONTINUE
}

public got_bomb(id) {
	if (get_cvar_num("anticamping") != 0) {
		de_map=true
		return PLUGIN_CONTINUE
	}
	return PLUGIN_CONTINUE
}

public round_end() {
	if (get_cvar_num("anticamping") != 0) {
		new players[32]
		new numberofplayers
		new id
		new i
		get_players(players, numberofplayers, "a")
		for (i = 0; i < numberofplayers; ++i) {
			id=players[i]
			pausecounter[id]=true
			return PLUGIN_CONTINUE
		}
	}
	return PLUGIN_CONTINUE
}

public plugin_precache() {
	precache_sound("player/heartbeat1.wav")
	return PLUGIN_CONTINUE
}
public plugin_init() {
	register_plugin("AntiCamping Advanced","1.01","SpaceDude - ADVanced edit...")
	register_event("Damage", "damage_event", "b", "2!0")
	register_event("BarTime","bartime_event","b")
	register_event("ResetHUD", "new_round", "b")
	register_event("SendAudio", "bomb_planted", "a", "2&%!MRAD_BOMBPL")
	register_event("SendAudio", "round_end", "a", "2&%!MRAD_terwin","2&%!MRAD_ctwin","2&%!MRAD_rounddraw")
	register_event("StatusIcon", "got_bomb", "be", "1=1", "1=2", "2=c4")
	register_cvar("anticamping","1",0)  //0=Disabled, 1=Slap, 2=Health Reduction, 3=Heartbeat
	register_cvar("anticamping_camptime","20",0)  //Amount of time allowed to camp
	register_cvar("anticamping_healthpunish","5",0)  //Amount of health taken due to punishment
	register_cvar("anticamping_meter","1",0) //Display 'campmeter' to each cilent
	set_task(1.0,"checkcamping",1)
	return PLUGIN_CONTINUE
}