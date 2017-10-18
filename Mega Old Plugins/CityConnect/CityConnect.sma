#include <amxmodx>
#include <amxmisc>
#include <geoipse>
#include <geoip>
#include <colorchat>

// http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz

new Float:gflLongitude[33];
new Float:gflLatitude[33];
new bool:gIsUserConnected[33];
new gMaxplayers;

public plugin_init() {
	register_plugin( "City Connect", "1.0", "xPaw - edit by adv..." );
	
	gMaxplayers = get_maxplayers( );
}

public client_putinserver( id ) {
	gIsUserConnected[id] = true;
	
	if( is_user_bot( id ) ) {
		gIsUserConnected[id] = false;	// lets make less loops in distance counting xD
		
		return PLUGIN_CONTINUE;
	}
	
	new szIP[32], szCountry[46], szCity[46], szName[32];
	get_user_name(id, szName, 31);
	get_user_ip( id, szIP, 31, 1 );
	
	if( equal( szIP, "loopback" ) )
		format( szIP, sizeof( szIP ) - 1, "85.196.220.208" ) // o hai i am hardcoder.
	
	geoip_country( szIP, szCountry );
	geoip_city( szIP, szCity );
	
	gflLatitude[id] = geoip_latitude( szIP );
	gflLongitude[id] = geoip_longitude( szIP );
	
	if( equal(szCountry, "error") ) {
		if( !contain(szIP, "192.168.") || !contain(szIP, "10. ") || !contain(szIP, "172.") || equal(szIP, "127.0.0.1") )
			szCountry = "LAN";
		
		else if( equal(szIP, "loopback") )
			szCountry = "LAN";
		
		else
			szCountry = "Unknown Country";
	}
	
	if( get_user_flags(id) & ADMIN_KICK ) {
		if( !equal( szCity, "error" ) )
			ColorChat( 0, BLUE, "^x01 Admin^x04 %s^x01 has^x04 connected  ^x01[^x03%s, ^x03 %s^x01]", szName, szCity, szCountry );
		else
			ColorChat( 0, BLUE, "^x01 Admin^x04 %s^x01 has^x04 connected  ^x01[^x03%s, ^x03 %s^x01]", szName, szCountry );
	} else {
		if( !equal( szCity, "error" ) )
			ColorChat( 0, BLUE, "^x01^x04 %s^x01 has^x04 connected  ^x01[^x03%s, ^x03 %s^x01]", szName, szCity, szCountry );
		else
			ColorChat( 0, BLUE, "^x01^x04 %s^x01 has^x04 connected  ^x01[^x03%s, ^x03 %s^x01]", szName, szCountry );
	}
	
	if( gflLongitude[id] != 0.0 && gflLatitude[id] != 0.0 )
		set_task( 0.2, "PrintDistance", id ); // gay fix.
	
	return PLUGIN_CONTINUE;
}

public PrintDistance( id ) {
	static i, szName[ 32 ];
	get_user_name( id, szName, 31 );
	
	for( i = 1; i <= gMaxplayers; i++ )
		if( gIsUserConnected[i] && id != i )
			if( gflLongitude[i] != 0.0 && gflLatitude[i] != 0.0 )
				ColorChat( i, RED, "^x01*^x04 %s^x01 is about^x03 %d^x01 kilometers far away from you.", szName, floatround( geoip_distance( gflLatitude[id], gflLatitude[i], gflLongitude[id], gflLongitude[i] ) ) );
}

public client_disconnect( id ) {
	gIsUserConnected[id] = false;
	
	if( is_user_bot( id ) )
		return PLUGIN_CONTINUE;
	
	new szIP[32], szCountry[46], szCity[46], szName[32];
	get_user_name(id, szName, 31);
	get_user_ip( id, szIP, 31, 1 );
	geoip_country( szIP, szCountry );
	geoip_city( szIP, szCity );
	
	if( equal(szCountry, "error") ) {
		if( !contain(szIP, "192.168.") || !contain(szIP, "10. ") || !contain(szIP, "172.") || equal(szIP, "127.0.0.1") )
			szCountry = "LAN";
		
		else if( equal(szIP, "loopback") )
			szCountry = "LAN";
		
		else
			szCountry = "Unknown Country";
	}
	
	if( get_user_flags(id) & ADMIN_KICK ) {
		if( !equal( szCity, "error" ) )
			ColorChat( 0, BLUE, "^x01 Admin^x04 %s^x01 has^x03 disconnected  ^x01[^x04%s, ^x04 %s^x01]", szName, szCity, szCountry );
		else
			ColorChat( 0, BLUE, "^x01 Admin^x04 %s^x01 has^x03 disconnected  ^x01[^x04%s, ^x04 %s^x01]", szName, szCountry );
	} else {
		if( !equal( szCity, "error" ) )
			ColorChat( 0, BLUE, "^x01^x04 %s^x01 has^x03 disconnected  ^x01[^x04%s, ^x04 %s^x01]", szName, szCity, szCountry );
		else
			ColorChat( 0, BLUE, "^x01^x04 %s^x01 has^x03 disconnected  ^x01[^x04%s, ^x04 %s^x01]", szName, szCountry );
	}
	
	return PLUGIN_CONTINUE;
}

stock Float:geoip_distance( Float:flLat1, Float:flLat2, Float:flLon1, Float:flLon2 )
	return ( 6371.0 * floatacos( floatsin( flLat1 / 57.3 ) * floatsin( flLat2 / 57.3 ) + floatcos( flLat1 / 57.3 ) * floatcos( flLat2 / 57.3 ) * floatcos( flLon2 / 57.3 - flLon1 / 57.3 ), 0 ) )