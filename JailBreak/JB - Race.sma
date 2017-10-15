#include <amxmodx>
#include <jbextreme>
#include <engine>
#include <fakemeta> 

#define PLUGIN "[jb] race" //
#define VERSION "1.0"
#define AUTHOR "dedihost"

public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR)
        
    register_clcmd("say /race", "race")
    register_think("npc_onna","npc_think");
    register_logevent("logevent_round_end", 2, "1=Round_End")  
    register_event("TextMsg", "Event_GameWillRestartIn", "a", "2=#Game_will_restart_in")
}

public plugin_precache()
{
    precache_model("models/csflags.mdl")
}

public race(id)
{
if(is_user_simon(id)) {
    new Float:origin[3]

    entity_get_vector(id,EV_VEC_origin,origin)

    new ent = create_entity("info_target")

    entity_set_origin(ent,origin);
    origin[2] += 80.0
    entity_set_origin(id,origin)

    entity_set_string(ent,EV_SZ_classname,"npc_onna");
    entity_set_model(ent,"models/csflags.mdl");
    entity_set_int(ent,EV_INT_solid, 2)

    new Float:maxs[3] = {16.0,16.0,36.0}
    new Float:mins[3] = {-16.0,-16.0,-36.0}
    entity_set_size(ent,mins,maxs)

    entity_set_float(ent,EV_FL_animtime,2.0)
    entity_set_float(ent,EV_FL_framerate,1.0)
    entity_set_int(ent,EV_INT_sequence,0);

    entity_set_float(ent,EV_FL_nextthink,halflife_time() + 0.01)

    drop_to_floor(ent)
} else {
client_print(id,print_chat,"Only simon can spawn flags!")
}
}

public npc_think(id)
{
    // Put your think stuff here.
    entity_set_float(id,EV_FL_nextthink,halflife_time() + 0.01)
}


public logevent_round_end() {
    new armoury = FM_NULLENT
    while( ( armoury = find_ent_by_class(armoury, "npc_onna") ) > 0 )
    {
            remove_entity(armoury)
    }
}

public Event_GameWillRestartIn() {
    new armoury = FM_NULLENT
    while( ( armoury = find_ent_by_class(armoury, "npc_onna") ) > 0 )
    {
            remove_entity(armoury)
    }
}
