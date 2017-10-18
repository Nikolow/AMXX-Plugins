#include <amxmodx>
#include <amxmisc>
#include <celltrie>
#include <fakemeta>
#include <fun>
#include <cstrike>
#include <hamsandwich>

#define PLUGIN "Frost Trap"
#define VERSION "1.11"
#define AUTHOR "R3X"

#define MAX_TRAPS 70

#define OVERRIDE_NADE_CLASS "grenade"
#define OVERRIDE_NADE_MODEL "w_smokegrenade.mdl"

#define SOUND_FREEZE "squeek/sqk_blast1.wav"
#define SOUND_RESOTRE "common/bodydrop1.wav"

#define TASK_REMOVE_FROZE 1000

new const gszClasses[][]={
	"func_button",
	"func_rot_button",
	"button_target"
};

new Trie:gTraps;
new giEntsTrigger[MAX_TRAPS];
new giPointer=0;

new smokeSpr, exploSpr, trailSpr;

new gcvarDistribute, gcvarLimit, gcvarCarry, gcvarCost;
new gcvarDistance, gcvarTime;

new gmsgAmmoPickup;

new giGrenades[33];

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR);
	register_cvar("freezetrap",VERSION,FCVAR_SERVER|FCVAR_SPONLY);
	
	register_event( "TextMsg", "eventRound", "a", "2&#Game_will_restart_in" );
	register_event("TextMsg", "eventRound", "a", "2&#Game_C")
	register_logevent( "eventRound",2, "1=Round_Start");
	
	RegisterHam(Ham_Spawn, "player","fwSpawn",1);
	register_forward(FM_SetModel, "fwSetModel",1);
	register_forward(FM_Think, "fwThink",1);
	
	gcvarDistribute=register_cvar("freezetrap_distribute","0");
	gcvarLimit=register_cvar("freezetrap_limit","1");
	gcvarCarry=register_cvar("freezetrap_carry","1");
	gcvarCost=register_cvar("freezetrap_cost","5000");
	
	gcvarDistance=register_cvar("freezetrap_distance","150.0",0,150.0);
	gcvarTime=register_cvar("freezetrap_time","10.0",0,10.0);
	
	gTraps = TrieCreate();
	
	register_clcmd("amx_give_sg","cmd_amx_give_sg",ADMIN_KICK, "<nick>");
	register_clcmd("say /freeze","buyFreezeNade");
	
	gmsgAmmoPickup = get_user_msgid("AmmoPickup");
}
public eventRound(){
	new tid;
	//512? i`m not sure, so doubled
	for(new i=0;i<=1024;i++){
		tid=i+TASK_REMOVE_FROZE;
		if(task_exists(tid)){
			remove_task(tid);
			restoreTrap(tid);
		}
	}
	for(new i=1;i<33;i++)
		giGrenades[i]=0;
}
public fwSpawn(id){
	if(get_pcvar_num(gcvarDistribute)==1){
		set_task(0.2, "taskGiveNade",id);
	}
	return HAM_IGNORED;
}
public fwUse(this, idcaller, idactivator, use_type, Float:value){
	if(task_exists(this+TASK_REMOVE_FROZE)){
		return HAM_SUPERCEDE;
	}
	return HAM_IGNORED;
}

public plugin_precache(){
	precache_sound("warcraft3/frostnova.wav");
	precache_sound(SOUND_FREEZE);
	precache_sound(SOUND_RESOTRE);
	precache_sound("items/gunpickup2.wav"); 
	
	trailSpr = precache_model("sprites/laserbeam.spr");
	smokeSpr = precache_model("sprites/steam1.spr");
	exploSpr = precache_model("sprites/shockwave.spr");
}
public fwThink(ent){
	if(!pev_valid(ent))
		return FMRES_IGNORED;
	if(isWhatIWaitFor(ent) && pev(ent, pev_iuser3)){
		new Float:dmgtime;
		pev(ent,pev_dmgtime,dmgtime);
		if(dmgtime > get_gametime()) return FMRES_IGNORED;
		frostTraps(ent);
	}
	return FMRES_IGNORED;
}
public fwSetModel(ent, const model[]){
	if(!pev_valid(ent))
		return FMRES_IGNORED;
	
	if(isWhatIWaitFor(ent) && equal(model[7], OVERRIDE_NADE_MODEL)){
		set_pev(ent, pev_iuser3, 1);
		
		// glowshell
		set_pev(ent,pev_rendermode,kRenderNormal);
		set_pev(ent,pev_renderfx,kRenderFxGlowShell);
		set_pev(ent,pev_rendercolor,Float:{0.0, 200.0, 200.0});
		set_pev(ent,pev_renderamt,16.0);

		set_beamfollow(ent,10,10,170);
	}
	return FMRES_IGNORED;
}
isWhatIWaitFor(ent){
	new szClass[32];
	pev(ent, pev_classname, szClass, 31);
	return equal(szClass, OVERRIDE_NADE_CLASS);
}

public frostTraps(ent){
	if(!pev_valid(ent))
		return;
	new Float:fOrigin[3];
	pev(ent, pev_origin, fOrigin);
	fOrigin[2] += 30.0;
	makeExplosion(ent, fOrigin);
	engfunc(EngFunc_RemoveEntity, ent);
	
	new szTargetName[32];
	new ent2=-1, item;
	do{
		ent2 = engfunc(EngFunc_FindEntityInSphere, ent2, fOrigin, get_pcvar_float(gcvarDistance));
		if(pev_valid(ent2)){
			pev(ent2, pev_targetname, szTargetName, 31);
			
			if(TrieGetCell(gTraps, szTargetName,item)){
				bufferSets(ent2);
				if(!task_exists(ent2+TASK_REMOVE_FROZE))
					frostTrap(ent2, item);
			}
		}
	}while(ent2);
}
frostTrap(ent, item){
	RegisterHamFromEntity(Ham_Use, ent, "fwUse", 0)
	
	new Float:iRestore=get_pcvar_float(gcvarTime);
	bufferSets(ent);
	
	frost(ent, iRestore, 150.0);
	frost(giEntsTrigger[item],iRestore, 255.0);
	
	emit_sound(ent,CHAN_BODY,SOUND_FREEZE,VOL_NORM,ATTN_NORM,0,PITCH_NORM);
}
public restoreTrap(ent){
	ent-=TASK_REMOVE_FROZE;
	if(pev_valid(ent)){
		new Float:fVec[3];
		set_pev(ent, pev_rendermode, pev(ent, pev_iuser1));
		set_pev(ent, pev_renderfx, pev(ent, pev_iuser2));
		pev(ent, pev_vuser1, fVec)
		set_pev(ent, pev_rendercolor, fVec);
		
		pev(ent, pev_fuser1, fVec[0]);
		set_pev(ent, pev_renderamt, fVec[0]);
		
		emit_sound(ent,CHAN_BODY,SOUND_RESOTRE,VOL_NORM,ATTN_NORM,0,PITCH_NORM);
	}
}
bufferSets(ent){
	//Buffer
	new Float:fVec[3];
	set_pev(ent, pev_iuser1, pev(ent, pev_rendermode));
	set_pev(ent, pev_iuser2, pev(ent, pev_renderfx));
	
	pev(ent, pev_rendercolor, fVec);
	set_pev(ent, pev_vuser1, fVec);
	
	pev(ent, pev_renderamt, fVec[0]);
	set_pev(ent, pev_fuser1, fVec[0]);
}
frost(ent, Float:fRestore=10.0, Float:fAmount=16.0){
	set_pev(ent,pev_rendermode,kRenderTransColor);
	set_pev(ent,pev_renderfx,kRenderFxExplode);
	set_pev(ent,pev_rendercolor,Float:{0.0, 200.0, 200.0});
	set_pev(ent,pev_renderamt,fAmount);
	if(!task_exists(ent+TASK_REMOVE_FROZE)){
		set_task(fRestore, "restoreTrap",ent+TASK_REMOVE_FROZE);
	}
}
makeExplosion(ent, const Float:fOrigin[3]){
	// make the smoke
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY);
	write_byte(TE_SMOKE);
	write_coord(floatround(fOrigin[0])); // x
	write_coord(floatround(fOrigin[1])); // y
	write_coord(floatround(fOrigin[2])); // z
	write_short(smokeSpr); // sprite
	write_byte(random_num(30,40)); // scale
	write_byte(5); // framerate
	message_end();
	
	create_blast(fOrigin);
	
	emit_sound(ent,CHAN_BODY,"warcraft3/frostnova.wav",VOL_NORM,ATTN_NORM,0,PITCH_NORM);
}
//Las Machinas de la muerte

ArobCoChcesz(const szClass[]){
	new szTarget[32];
	new ent=-1;
	do{
		if(giPointer >= MAX_TRAPS)
			break;
		ent = engfunc(EngFunc_FindEntityByString, ent, "classname", szClass);
		if(pev_valid(ent)){
			pev(ent, pev_target, szTarget, 31);
			if(szTarget[0]){
				TrieSetCell(gTraps, szTarget, giPointer);
				giEntsTrigger[giPointer] =ent;
				giPointer++;
			}
		}
	}while(ent);
}
public plugin_cfg(){
	for(new i=0; i<sizeof gszClasses; i++){
		ArobCoChcesz(gszClasses[i]);
	}
}
//Effect
create_blast(const Float:originF[3])
{
	new origin[3];
	FVecIVec(originF,origin);

	// smallest ring
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY);
	write_byte(TE_BEAMCYLINDER);
	write_coord(origin[0]); // x
	write_coord(origin[1]); // y
	write_coord(origin[2]); // z
	write_coord(origin[0]); // x axis
	write_coord(origin[1]); // y axis
	write_coord(origin[2] + 385); // z axis
	write_short(exploSpr); // sprite
	write_byte(0); // start frame
	write_byte(0); // framerate
	write_byte(4); // life
	write_byte(60); // width
	write_byte(0); // noise
	write_byte(0); // red
	write_byte(200); // green
	write_byte(200); // blue
	write_byte(100); // brightness
	write_byte(0); // speed
	message_end();

	// medium ring
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY);
	write_byte(TE_BEAMCYLINDER);
	write_coord(origin[0]); // x
	write_coord(origin[1]); // y
	write_coord(origin[2]); // z
	write_coord(origin[0]); // x axis
	write_coord(origin[1]); // y axis
	write_coord(origin[2] + 470); // z axis
	write_short(exploSpr); // sprite
	write_byte(0); // start frame
	write_byte(0); // framerate
	write_byte(4); // life
	write_byte(60); // width
	write_byte(0); // noise
	write_byte(0); // red
	write_byte(200); // green
	write_byte(200); // blue
	write_byte(100); // brightness
	write_byte(0); // speed
	message_end();

	// largest ring
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY);
	write_byte(TE_BEAMCYLINDER);
	write_coord(origin[0]); // x
	write_coord(origin[1]); // y
	write_coord(origin[2]); // z
	write_coord(origin[0]); // x axis
	write_coord(origin[1]); // y axis
	write_coord(origin[2] + 555); // z axis
	write_short(exploSpr); // sprite
	write_byte(0); // start frame
	write_byte(0); // framerate
	write_byte(4); // life
	write_byte(60); // width
	write_byte(0); // noise
	write_byte(0); // red
	write_byte(200); // green
	write_byte(200); // blue
	write_byte(100); // brightness
	write_byte(0); // speed
	message_end();

	// light effect
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY);
	write_byte(TE_DLIGHT);
	write_coord(origin[0]); // x
	write_coord(origin[1]); // y
	write_coord(origin[2]); // z
	write_byte(floatround(get_pcvar_float(gcvarDistance)/5.0)); // radius
	write_byte(0); // r
	write_byte(200); // g
	write_byte(200); // b
	write_byte(8); // life
	write_byte(60); // decay rate
	message_end();
}
// give an entity a beam trail
set_beamfollow(ent,life,width,brightness)
{
	clear_beamfollow(ent);

	message_begin(MSG_BROADCAST,SVC_TEMPENTITY);
	write_byte(TE_BEAMFOLLOW);
	write_short(ent); // entity
	write_short(trailSpr); // sprite
	write_byte(life); // life
	write_byte(width); // width
	write_byte(random(255)); // red
	write_byte(random(255)); // green
	write_byte(random(255)); // blue
	write_byte(brightness); // brightness
	message_end();
}

// removes beam trails from an entity
clear_beamfollow(ent)
{
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY);
	write_byte(TE_KILLBEAM);
	write_short(ent); // entity
	message_end();
}
//CMD
public cmd_amx_give_sg(id, level, cid){
	if(!cmd_access(id, level, cid, 2))
		return PLUGIN_HANDLED;
	new szTarget[32], iTarget;
	read_argv(1, szTarget, 31);
	iTarget=cmd_target(id,szTarget,0);
	if(!is_user_alive(id))
		return PLUGIN_HANDLED;
	giveNade(iTarget, true);
	return PLUGIN_HANDLED;
}
public buyFreezeNade(id){
	if(!is_user_alive(id))
		return PLUGIN_CONTINUE;
	if(get_pcvar_num(gcvarDistribute) < 2)
		return PLUGIN_CONTINUE;
	giveNade(id);
	return PLUGIN_CONTINUE;
}
public taskGiveNade(id){
	giveNade(id);
}
giveNade(id, bool:bCmd=false){
	if(!is_user_alive(id) || get_user_team(id)!=2)
		return 0;
	if(giGrenades[id] >= get_pcvar_num(gcvarLimit) && !bCmd){
		client_print(id, print_center, "Wyczerpales limit");
		return 0;
	}
	new iMoney=cs_get_user_money(id) - get_pcvar_num(gcvarCost);
	new bool:pay=(get_pcvar_num(gcvarDistribute) > 1)
	if(pay && (iMoney < 0) && !bCmd){
		client_print(id, print_center, "#Cstrike_TitlesTXT_Not_Enough_Money");
		return 0;
	}
	if(!user_has_weapon(id, CSW_SMOKEGRENADE)){
		give_item(id, "weapon_smokegrenade");
	}
	else{
		new iAmmo = cs_get_user_bpammo(id, CSW_SMOKEGRENADE);
		if(iAmmo < get_pcvar_num(gcvarCarry) || bCmd){
			cs_set_user_bpammo(id, CSW_SMOKEGRENADE,  iAmmo+1);
			message_begin(MSG_ONE, gmsgAmmoPickup, _, id);
			write_byte(13);
			write_byte(1);
			message_end();
			engfunc(EngFunc_EmitSound,id,CHAN_ITEM,"items/gunpickup2.wav",VOL_NORM,ATTN_NORM,0,PITCH_NORM);
		}
		else{
			client_print(id, print_center, "#Cstrike_TitlesTXT_Cannot_Carry_Anymore");
			return 0;
		}
	}
	if(!bCmd && pay)
		cs_set_user_money(id, iMoney);
	giGrenades[id]++;
	return 1;
}
