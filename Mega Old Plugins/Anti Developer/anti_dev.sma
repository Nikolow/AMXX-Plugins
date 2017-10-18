#include <amxmodx> 
public plugin_init() { 
	register_plugin("Anti Developer", "1.0", "MAD.XayC")
	set_task(0.5, "block_dev", _, _, _, "b")
} 
public block_dev() {  
	static i
	for(i = 0; i < get_maxplayers(); i++) {
		client_cmd(i,"developer 0")
	}
} 