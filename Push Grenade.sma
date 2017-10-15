/*
ZOMBIE DARKNESS FLASHBANG
*/
#include <amxmodx>
#include <fakemeta>
#include <engine>
#include <xs>
//Vars
new g_msgScreenFade, g_msgScreenShake, flash_sprite_index
//Knockback strengh and radius
new Float:KRADIUS=200.0, Float:KPOWER=600.0
//Shockwave sprite
new flashwave[] = "sprites/shockwave.spr"
public plugin_init(){
register_plugin("ZB4Flashbang","1.0","Inovella")
register_forward(FM_Think, "fwd_think")

//Flash blocking
register_event("ScreenFade","FlashEvent","b","4=255","5=255","6=255","7>199")

g_msgScreenFade = get_user_msgid("ScreenFade")
g_msgScreenShake = get_user_msgid("ScreenShake")
}
public plugin_precache(){
flash_sprite_index = precache_model(flashwave)
}
//This is an idiocy code, but fm set model not working
public fwd_think(iEntity){
if (!pev_valid(iEntity)){
         return FMRES_IGNORED
}
new szModel[25]
pev(iEntity, pev_model, szModel, 24)
if (equali(szModel, "models/w_flashbang.mdl")){
         new Float:fDmgTime
         pev(iEntity, pev_dmgtime, fDmgTime)
         if (fDmgTime <= get_gametime() && fDmgTime != 0.0){
                 func_nade_explode(iEntity)
                 return FMRES_SUPERCEDE
         }
}

return FMRES_IGNORED
}
public func_nade_explode(iEntity){
if (!pev_valid(iEntity)){
         return
}

/*Blocked explode, your code goes here*/

//Making Shockwave
flashbang_explode(iEntity);

//Making Flashbang model invisible
set_pev(iEntity, pev_effects, EF_NODRAW);

//Knockback effect, calculation from hlsdk
static Float:originF[3]
pev(iEntity, pev_origin, originF)
static victim
victim = -1
new Float:fOrigin[3],Float:fDistance,Float:fDamage
while ((victim = engfunc(EngFunc_FindEntityInSphere, victim, originF, KRADIUS)) != 0){
if (!is_user_alive(victim)) continue
ScreenShake(victim)
pev(victim, pev_origin, fOrigin)
fDistance = get_distance_f(fOrigin, originF)
fDamage = KPOWER - floatmul(KPOWER, floatdiv(fDistance, KRADIUS))//get the damage value
fDamage *= EstimateDamage(originF, victim, 0)
if ( fDamage < 0 ) continue
CreateBombKnockBack(victim,originF,fDamage,KPOWER)
}
}
public FlashEvent(id){
message_begin(MSG_ONE, g_msgScreenFade, {0,0,0}, id)
write_short(1)
write_short(1)
write_short(1)
write_byte(0)
write_byte(0)
write_byte(0)
write_byte(255)
message_end()
}
public flashbang_explode(greindex){
if(!pev_valid(greindex)) return;
static Float:Orig[3];
pev(greindex,pev_origin,Orig);
ShockWave(Orig, 5, 35, 1000.0, {135, 206, 250})
}
//Nice Shockwave (from Alexander 3 public NPC)
stock ShockWave(Float:Orig[3], Life, Width, Float:Radius, Color[3]){
engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, Orig, 0)
write_byte(TE_BEAMCYLINDER) // TE id
engfunc(EngFunc_WriteCoord, Orig[0]) // x
engfunc(EngFunc_WriteCoord, Orig[1]) // y
engfunc(EngFunc_WriteCoord, Orig[2]) // z
engfunc(EngFunc_WriteCoord, Orig[0]) // x axis
engfunc(EngFunc_WriteCoord, Orig[1]) // y axis
engfunc(EngFunc_WriteCoord, Orig[2]+Radius) // z axis
write_short(flash_sprite_index) // sprite
write_byte(0) // startframe
write_byte(0) // framerate
write_byte(Life) // life (4)
write_byte(Width) // width (20)
write_byte(0) // noise
write_byte(Color[0]) // red
write_byte(Color[1]) // green
write_byte(Color[2]) // blue
write_byte(255) // brightness
write_byte(0) // speed
message_end()
}
//Knockback power and radius
stock CreateBombKnockBack(iVictim,Float:vAttacker[3],Float:fMulti,Float:fRadius){
new Float:vVictim[3];
pev(iVictim, pev_origin, vVictim);
xs_vec_sub(vVictim, vAttacker, vVictim);
xs_vec_mul_scalar(vVictim, fMulti * 0.7, vVictim);
xs_vec_mul_scalar(vVictim, fRadius / xs_vec_len(vVictim), vVictim);
set_pev(iVictim, pev_velocity, vVictim);
}
stock ScreenShake(id, amplitude = 8, duration = 6, frequency = 18){
message_begin(MSG_ONE_UNRELIABLE, g_msgScreenShake, _, id)
write_short((1<<12)*amplitude)
write_short((1<<12)*duration)
write_short((1<<12)*frequency)
message_end()
}
//Damaging only enemy team
stock Float:EstimateDamage(Float:fPoint[3], ent, ignored) {
new Float:fOrigin[3]
new tr
new Float:fFraction
pev(ent, pev_origin, fOrigin)
engfunc(EngFunc_TraceLine, fPoint, fOrigin, DONT_IGNORE_MONSTERS, ignored, tr)
get_tr2(tr, TR_flFraction, fFraction)
if ( fFraction == 1.0 || get_tr2( tr, TR_pHit ) == ent )//no valid enity between the explode point & player
return 1.0
return 0.6//if has fraise, lessen blast hurt
}
