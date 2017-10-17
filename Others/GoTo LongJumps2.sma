/*

	С едно просто меню, можете да се телепортирате на всички места на въпросната карта.
	Плъгина е направен специално за kz_longjumps2 и са добавени и скритите места.

*/

#include <amxmodx>
#include <fakemeta>

#define PLUGIN "GoTo Lj2"
#define VERSION "1.3"
#define AUTHOR "ReymonARG"

new textovariable

new const Float:lj_position[46][3] =
{
	{-1055.003051, 578.635498, -835.968750},
	{-1337.197631, 577.174560, -835.968750},
	{-1651.245117, 581.575073, -835.968750},
	{-1921.205322, 587.690368, -835.968750},
	{-2213.586669, 588.194885, -835.968750},
	{-2502.909179, 597.480102, -835.968750},
	{-2784.991210, 590.543945, -835.968750},
	{-3078.690673, 617.415283, -835.968750},
	{-3368.292236, 618.033691, -835.968750},
	{-3655.670166, 618.645690, -835.968750},
	{346.657379, -65.992279, -835.968750},
	{343.470245, -370.965698, -835.968750},
	{368.199707, -644.888305, -835.968750},
	{362.770263, -948.266723, -835.968750},
	{350.296752, -1231.697998, -835.968750},
	{342.843292, -1519.162109, -835.968750},
	{337.480926, -1804.483276, -835.968750},
	{349.853942, -2086.625244, -835.968750},
	{340.216217, -2378.290283, -835.968750},
	{329.746215, -2667.063964, -835.968750},
	{992.000000, 1344.000000, -835.968750},
	{1293.783691, 1325.809326, -835.968750},
	{1558.312500, 1325.479858, -835.968750},
	{1859.839111, 1332.097900, -835.968750},
	{2151.729492, 1329.970092, -835.968750},
	{2441.665771, 1327.857421, -835.968750},
	{2720.086914, 1337.539184, -835.968750},
	{3008.200195, 1337.607666, -835.968750},
	{3298.108154, 1340.810424, -835.968750},
	{3586.843750, 1342.000732, -835.968750},
	{352.000000, -64.000000, -1315.968750},
	{360.576812, -359.372985, -1315.968750},
	{359.121459, -646.579345, -1315.968750},
	{361.546752, -937.313232, -1315.968750},
	{361.411743, -1219.124267, -1315.968750},
	{361.272125, -1509.990844, -1315.968750},
	{362.045288, -1797.906250, -1315.968750},
	{362.804931, -2080.791015, -1315.968750},
	{363.589141, -2372.813232, -1315.968750},
	{364.382202, -2668.154785, -1315.968750},
	{-1056.000000, 576.000000, -1315.968750},
	{-1361.455688, 577.189392, -1315.968750},
	{-1636.939819, 581.278381, -1315.968750},
	{-1939.184692, 557.332946, -1315.968750},
	{-2225.302734, 563.066894, -1315.968750},
	{-2507.784423, 568.727539, -1315.968750}
};

new const Float:bhop_position[31][3] = 
{
	{-1112.000000, 856.000000, -2603.968750},
	{-1384.000000, 856.000000, -2603.968750},
	{-1656.000000, 856.000000, -2603.968750},
	{-1928.000000, 856.000000, -2603.968750},
	{-2200.000000, 856.000000, -2603.968750},
	{-2472.000000, 856.000000, -2603.968750},
	{-2744.000000, 856.000000, -2603.968750},
	{-3016.000000, 856.000000, -2603.968750},
	{-3288.000000, 856.000000, -2603.968750},
	{-3560.000000, 856.000000, -2603.968750},
	{276.000000, 216.000000, -2603.968750},
	{276.000000, -56.000000, -2603.968750},
	{276.000000, -328.000000, -2603.968750},
	{276.000000, -600.000000, -2603.968750},
	{276.000000, -872.000000, -2603.968750},
	{276.000000, -1144.000000, -2603.968750},
	{276.000000, -1416.000000, -2603.968750},
	{276.000000, -1688.000000, -2603.968750},
	{276.000000, -1960.000000, -2603.968750},
	{276.000000, -2232.000000, -2603.968750},
	{920.000000, 1604.000000, -2603.968750},
	{1192.000000, 1604.000000, -2603.968750},
	{1464.000000, 1604.000000, -2603.968750},
	{1736.000000, 1604.000000, -2603.968750},
	{2008.000000, 1604.000000, -2603.968750},
	{2280.000000, 1604.000000, -2603.968750},
	{2552.000000, 1604.000000, -2603.968750},
	{2824.000000, 1604.000000, -2603.968750},
	{3096.000000, 1604.000000, -2603.968750},
	{3368.000000, 1604.000000, -2603.968750},
	{3640.000000, 1604.000000, -2603.968750}
};

new const Float:cj_position[36][3] =
{
	{510.419097, -570.309509, -1987.968750},
	{895.791259, -568.062133, -1987.968750},
	{1278.016967, -562.385681, -1987.968750},
	{1666.351440, -555.636962, -1987.968750},
	{2065.401367, -546.061279, -1987.968750},
	{2040.247924, -937.604553, -1987.968750},
	{1665.417480, -928.629760, -1987.968750},
	{1275.896606, -928.826965, -1987.968750},
	{892.463623, -917.491577, -1987.968750},
	{502.266082, -920.462524, -1987.968750},
	{-508.481475, -913.018859, -1987.968750},
	{-886.500610, -895.082397, -1987.968750},
	{-1288.920410, -892.894775, -1987.968750},
	{-1657.170654, -899.145629, -1987.968750},
	{-2049.642333, -921.599304, -1987.968750},
	{-2060.020996, -567.047363, -1987.968750},
	{-1666.292602, -567.379882, -1987.968750},
	{-1277.856201, -580.906982, -1987.968750},
	{-897.188049, -579.648559, -1987.968750},
	{-499.895538, -590.854248, -1987.968750},
	{-146.453659, 539.329589, -1987.968750},
	{-153.383697, 920.178405, -1987.968750},
	{-144.053710, 1307.472045, -1987.968750},
	{-147.273071, 1687.733276, -1987.968750},
	{-164.247619, 2066.548095, -1987.968750},
	{148.882644, 2073.309326, -1987.968750},
	{154.298782, 1683.728881, -1987.968750},
	{159.601821, 1302.276245, -1987.968750},
	{164.697799, 935.719665, -1987.968750},
	{170.312454, 536.241882, -1987.968750},
	{779.433044, -2107.653808, -1987.968750},
	{382.840240, -2114.206054, -1987.968750},
	{3.906657, -2098.052978, -1987.968750},
	{-372.657531, -2098.760986, -1987.968750},
	{-772.508483, -2103.706787, -1987.968750},
	{-1153.285888, -2091.457519, -1987.968750}
};

new const Float:hj_position[31][3] =
{
	{-1106.355468, 878.013427, -3163.968750},
	{-1367.504028, 913.048767, -3163.968750},
	{-1647.023071, 908.966552, -3163.968750},
	{-1917.632080, 910.012084, -3163.968750},
	{-2182.140380, 911.779602, -3163.968750},
	{-2470.787353, 910.848754, -3163.968750},
	{-2722.177978, 914.569641, -3163.968750},
	{-3000.114501, 910.841430, -3163.981689},
	{-3281.111572, 912.804687, -3163.981689},
	{-3556.852294, 913.801147, -3163.968750},
	{240.000000, 216.000000, -3163.968750},
	{241.124816, -56.954338, -3163.968750},
	{239.805801, -340.236358, -3163.968750},
	{240.463912, -606.579223, -3163.968750},
	{238.570556, -880.856750, -3163.968750},
	{241.137466, -1151.218872, -3163.968750},
	{241.707733, -1414.711181, -3163.968750},
	{240.443603, -1703.864868, -3163.968750},
	{240.031265, -1949.415161, -3163.968750},
	{239.354141, -2221.444580, -3163.968750},
	{936.000000, 1616.000000, -3163.968750},
	{1228.001831, 1617.031494, -3163.968750},
	{1498.516601, 1616.019775, -3163.968750},
	{1767.118408, 1615.015380, -3163.968750},
	{2020.724975, 1614.067138, -3163.968750},
	{2308.373291, 1613.513305, -3163.968750},
	{2571.921875, 1614.751342, -3163.968750},
	{2856.849365, 1615.914428, -3163.968750},
	{3121.180664, 1613.757812, -3163.968750},
	{3393.780029, 1613.029541, -3163.968750},
	{3661.197998, 1615.132324, -3163.968750}
};

new const Float:ladder_position[21][3] =
{
	{-857.883483, -416.029144, 612.031250},
	{-856.920715, -272.506286, 612.031250},
	{-855.968750, -130.703628, 612.031250},
	{-853.100952, 13.096566, 612.031250},
	{-850.177490, 159.679611, 612.031250},
	{-867.020446, 299.906280, 612.031250},
	{-864.290527, 446.658813, 612.031250},
	{-861.931030, 589.741088, 612.031250},
	{-859.532470, 735.175231, 612.031250},
	{-857.180053, 877.828247, 612.031250},
	{-682.690917, 1048.701904, 612.031250},
	{-533.808044, 1040.901000, 612.031250},
	{-389.494995, 1036.525024, 612.031250},
	{-247.663177, 1032.294921, 612.031250},
	{-104.602775, 1027.355712, 612.031250},
	{37.518779, 1013.453491, 612.031250},
	{183.952041, 1008.388732, 612.031250},
	{324.939300, 1008.444580, 612.031250},
	{471.211456, 1008.567443, 612.031250},
	{617.199951, 1008.176391, 612.031250},
	{761.598754, 1008.002502, 612.031250}
}

new const Float:place_position[5][3] = 
{
	{-32.000000, 1312.000000, -835.968750},
	{-96.000000, 1584.000000, -2603.968750},
	{0.000000, -40.000000, -1987.968750},
	{-80.000000, 1584.000000, -3163.968750},
	{-1168.000000, -656.000000, 740.031250}
}

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR);
	register_cvar("goto", VERSION, FCVAR_SERVER | FCVAR_SPONLY );
	
	textovariable = get_user_msgid("SayText");
	
	new mapita[32];
	get_mapname(mapita, 31);
	
	if(equali(mapita, "kz_longjumps2"))
	{
		register_clcmd("say", "hooksay");
		register_clcmd("say_team", "hooksay");
	}
}

public gotomenu(id)
{
	
	new menu1 = menu_create("\r[ 4V ] \yGo To Menu", "menugoto");
	menu_additem(menu1, "Start", "1", 0);
	menu_additem(menu1, "Long Jumps", "2", 0);
	menu_additem(menu1, "Bhop Jumps", "3", 0);
	menu_additem(menu1, "Count Jumps", "4", 0);
	menu_additem(menu1, "High Jumps", "5", 0);
	menu_additem(menu1, "Ladder Jumps", "6", 0);
	menu_additem(menu1, "Secret Room", "7", 0);
	
	menu_display(id, menu1, 0);
}

public menugoto(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		client_cmd(id, "say /menu");
		return PLUGIN_HANDLED;
	}
	
	new data[6], iName[64];
	new access, callback;
	
	menu_item_getinfo(menu, item, access, data,5, iName, 63, callback);
	
	new key = str_to_num(data);
	
	switch(key)
	{
		case 1:
		{
			set_pev(id, pev_origin, {-4.830482, 2.784362, -27.968750});
			gotomenu(id);
		}
		case 2:
		{
			ljmenu(id, 0);
		}
		case 3:
		{
			bhopmenu(id, 0);
		}
		case 4:
		{
			cjmenu(id, 0);
		}
		case 5:
		{
			hjmenu(id, 0);
		}
		case 6:
		{
			laddermenu(id, 0);
		}
		case 7:
		{
			set_pev(id, pev_origin, {-778.922546, -1908.944580, 720.031250});
			gotomenu(id);
		}
	}
	
	return PLUGIN_HANDLED;
}

public ljmenu(id, page)
{
	new menu2 = menu_create("\r[ 4V ] \yGo To Menu \d[Long Jumps]", "menulj");
	
	new lala = 1, popo = 219;
	menu_additem(menu2, "\wLj Place ^n^n\yBlocks", "1", 0);
	
	for(new i = 0; i <= charsmax(lj_position); i++)
	{
		popo++;
		lala++;
		new lugar[5], ljblock[8];
		num_to_str(lala, lugar, 4);
		num_to_str(popo, ljblock, 7);
		menu_additem(menu2, ljblock, lugar, 0);
	}
	menu_setprop(menu2, MPROP_EXITNAME, "\wMain Menu");
	
	menu_display(id, menu2, page);
}

public menulj(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		gotomenu(id);
		return PLUGIN_HANDLED;
	}
	
	new data[6], iName[64];
	new access, callback;
	
	menu_item_getinfo(menu, item, access, data,5, iName, 63, callback);
	
	new key = str_to_num(data);
	new Float:floatkey = str_to_float(data);
	
	switch( key )
	{
		case 1:
		{
			set_pev(id, pev_origin, place_position[0]);
			ljmenu(id, 0);
		}
		default:
		{
			set_pev(id, pev_origin, lj_position[key-2]);
			ljmenu(id, floatround( floatkey/7.001, floatround_floor));
		}
	}
	
	return PLUGIN_HANDLED;
}

public bhopmenu(id, page)
{
	new menu3 = menu_create("\r[ 4V ] \yGo To Menu \dBhop Jumps", "menubhop");
	
	new lala = 1, popo = 219;
	menu_additem(menu3, "\wBhop Place ^n^n\yBlocks", "1", 0);
	
	for(new i = 0; i <= charsmax(bhop_position); i++)
	{
		popo++;
		lala++;
		new lugar[5], ljblock[8];
		num_to_str(lala, lugar, 4);
		num_to_str(popo, ljblock, 7);
		menu_additem(menu3, ljblock, lugar, 0);
	}
	menu_setprop(menu3, MPROP_EXITNAME, "\wMain Menu");
	
	menu_display(id, menu3, page);
}

public menubhop(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		gotomenu(id);
		return PLUGIN_HANDLED;
	}
	
	new data[6], iName[64];
	new access, callback;
	
	menu_item_getinfo(menu, item, access, data,5, iName, 63, callback);
	
	new key = str_to_num(data);
	new Float:floatkey = str_to_float(data);
	
	switch( key )
	{
		case 1:
		{
			set_pev(id, pev_origin, place_position[1]);
			bhopmenu(id, 0);
		}
		default:
		{
			set_pev(id, pev_origin, bhop_position[key-2]);
			bhopmenu(id, floatround( floatkey/7.001, floatround_floor));
		}
	}
	
	return PLUGIN_HANDLED;
}

public cjmenu(id, page)
{
	new menu4 = menu_create("\r[ 4V ] \yGo To Menu \dCJ Jumps", "menucj");
	
	new lala = 1, popo = 239;
	menu_additem(menu4, "\wCj Place ^n^n\yBlocks", "1", 0);
	
	for(new i = 0; i <= charsmax(cj_position); i++)
	{
		popo++;
		lala++;
		new lugar[5], ljblock[8];
		num_to_str(lala, lugar, 4);
		num_to_str(popo, ljblock, 7);
		menu_additem(menu4, ljblock, lugar, 0);
	}
	menu_setprop(menu4, MPROP_EXITNAME, "\wMain Menu");
	
	menu_display(id, menu4, page);
}

public menucj(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		gotomenu(id);
		return PLUGIN_HANDLED;
	}
	
	new data[6], iName[64];
	new access, callback;
	
	menu_item_getinfo(menu, item, access, data,5, iName, 63, callback);
	
	new key = str_to_num(data);
	new Float:floatkey = str_to_float(data);
	
	switch( key )
	{
		case 1:
		{
			set_pev(id, pev_origin, place_position[2]);
			cjmenu(id, 0);
		}
		default:
		{
			set_pev(id, pev_origin, cj_position[key-2]);
			cjmenu(id, floatround( floatkey/7.001, floatround_floor));
		}
	}
	
	return PLUGIN_HANDLED;
}

public hjmenu(id, page)
{
	new menu5 = menu_create("\r[ 4V ] \yGo To Menu \dHigh Jumps", "menuhj");
	
	new lala = 1, popo = 219;
	menu_additem(menu5, "\wHj Place ^n^n\yBlocks", "1", 0);
	
	for(new i = 0; i <= charsmax(hj_position); i++)
	{
		popo++;
		lala++;
		new lugar[5], ljblock[8];
		num_to_str(lala, lugar, 4);
		num_to_str(popo, ljblock, 7);
		menu_additem(menu5, ljblock, lugar, 0);
	}
	menu_setprop(menu5, MPROP_EXITNAME, "\wMain Menu");
	
	menu_display(id, menu5, page);
}

public menuhj(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		gotomenu(id);
		return PLUGIN_HANDLED;
	}
	
	new data[6], iName[64];
	new access, callback;
	
	menu_item_getinfo(menu, item, access, data,5, iName, 63, callback);
	
	new key = str_to_num(data);
	new Float:floatkey = str_to_float(data);
	
	switch( key )
	{
		case 1:
		{
			set_pev(id, pev_origin, place_position[3]);
			hjmenu(id, 0);
		}
		default:
		{
			set_pev(id, pev_origin, hj_position[key-2]);
			hjmenu(id, floatround( floatkey/7.001, floatround_floor));
		}
	}
	
	return PLUGIN_HANDLED;
}

public laddermenu(id, page)
{
	new menu6 = menu_create("\r[ 4V ] \yGo To Menu \dLadder Jumps", "menuladder");
	
	new lala = 1, popo = 149;
	menu_additem(menu6, "\wLadder Place ^n^n\yBlocks", "1", 0);
	
	for(new i = 0; i <= charsmax(ladder_position); i++)
	{
		popo++;
		lala++;
		new lugar[5], ljblock[8];
		num_to_str(lala, lugar, 4);
		num_to_str(popo, ljblock, 7);
		menu_additem(menu6, ljblock, lugar, 0);
	}
	menu_setprop(menu6, MPROP_EXITNAME, "\wMain Menu");
	
	menu_display(id, menu6, page);
}

public menuladder(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		gotomenu(id);
		return PLUGIN_HANDLED;
	}
	
	new data[6], iName[64];
	new access, callback;
	
	menu_item_getinfo(menu, item, access, data,5, iName, 63, callback);
	
	new key = str_to_num(data);
	new Float:floatkey = str_to_float(data);
	
	switch( key )
	{
		case 1:
		{
			set_pev(id, pev_origin, place_position[4]);
			laddermenu(id, 0);
		}
		default:
		{
			set_pev(id, pev_origin, ladder_position[key-2]);
			laddermenu(id, floatround( floatkey/7.001, floatround_floor));
		}
	}
	
	return PLUGIN_HANDLED;
}

public hooksay(id)
{		
	new args[64], commando[12], tipo[12], bloke[4];
	read_args(args, 63);
	remove_quotes(args);
	
	if( containi(args, "goto") == -1 && args[0] != '/' )
		return PLUGIN_CONTINUE;
	
	parse(args, commando, 11, tipo, 11, bloke, 3);
	
	if( equali(commando, "/goto", 4) && equali(tipo, "") )
	{
		gotomenu(id);
		return PLUGIN_CONTINUE;
	}
	else if( equali(commando, "/goto", 4) )
	{
		new lalin = str_to_num(bloke);
		
		if( equali(tipo, "lj") )
		{
			if( is_block_valid(lalin, 220, 265) )
			{
				set_pev(id, pev_origin, lj_position[lalin-220]);
				print(id, "Moved to Lj Block: %i", lalin);
			}
			else
			{
				set_pev(id, pev_origin, place_position[0]);
				print(id, "Moved to Long Jumps Place");
			}
		}
		else if( equali(tipo, "bhop") )
		{
			if( is_block_valid(lalin, 220, 250) )
			{
				set_pev(id, pev_origin, bhop_position[lalin-220]);
				print(id, "Moved to Bhop Block: %i", lalin);
			}
			else
			{
				set_pev(id, pev_origin, place_position[1]);
				print(id, "Moved to Bhop Place");
			}
		}
		else if( equali(tipo, "cj") )
		{
			if( is_block_valid(lalin, 240, 275) )
			{
				set_pev(id, pev_origin, cj_position[lalin-240]);
				print(id, "Moved to Cj Block: %i", lalin);
			}
			else
			{
				set_pev(id, pev_origin, place_position[2]);
				print(id, "Moved to Count Jumps Place");
			}
		}
		else if( equali(tipo, "hj") )
		{
			if( is_block_valid(lalin, 220, 250) )
			{
				set_pev(id, pev_origin, hj_position[lalin-220]);
				print(id, "Moved to Hj Block: %i", lalin);
			}
			else
			{
				set_pev(id, pev_origin, place_position[3]);
				print(id, "Moved to High Jumps Place");
			}
		}
		else if( equali(tipo, "ladder") )
		{
			if( is_block_valid(lalin, 150, 170) )
			{
				set_pev(id, pev_origin, ladder_position[lalin-150]);
				print(id, "Moved to Ladder Block: %i", lalin);
			}
			else
			{
				set_pev(id, pev_origin, place_position[4]);
				print(id, "Moved to Ladders Place");
			}
		}
		else if( equali(tipo, "start") )
		{
			set_pev(id, pev_origin, {-4.830482, 2.784362, -27.968750});
			print(id, "Moved to Start Position");
		}
		else if( containi(tipo, "room") != -1 )
		{
			set_pev(id, pev_origin, {-778.922546, -1908.944580, 720.031250});
			print(id, "Moved to Secret Room");
		}
		
		return PLUGIN_HANDLED;
	}
	
	return PLUGIN_CONTINUE;
}

print(id, const msg[], {Float,Sql,Result,_}:...)
{
	new message[160], final[192];
	final[0] = 0x04;
	vformat(message, 159, msg, 3);
	formatex(final[1], 188, "[ 4V ] %s", message);
	
	message_begin(MSG_ONE_UNRELIABLE, textovariable, _, id);
	write_byte(id);
	write_string(final);
	message_end();
} 

stock is_block_valid(value, num1, num2)
{
	if( value >= num1 && value <= num2 )
		return true;
		
	return false;
}
