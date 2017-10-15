#if defined _hns_xp_included
	#endinput
#endif
#define _hns_xp_included

#if AMXX_VERSION_NUM >= 175
	#pragma reqlib hns_xp
	#if !defined AMXMODX_NOAUTOLOAD
		#pragma loadlib hns_xp
	#endif
#else
	#pragma library hns_xp
#endif



native hnsxp_get_user_xp(const client);

/* ///
 * Sets <xp> points to client
 * 
 * @param		client - The player index to set points to
 * @param		xp - The amount of XP points to set to client
 * 
 * @return		The XP points of client
 * 
 */
native hnsxp_set_user_xp(const client, const xp);

/*
 * Returns a players XP points from a given authid
 * 
 * @param		authid - The authid of the player to get points from
 * 
 * @return		The XP points of the player
 * 
 */
