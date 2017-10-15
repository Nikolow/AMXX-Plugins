#if AMXX_VERSION_NUM >= 175
	#pragma reqlib hns_xp
	#if !defined AMXMODX_NOAUTOLOAD
		#pragma loadlib frost
	#endif
#else
	#pragma library frost
#endif

native add_user_immune( id )
native remove_user_immune( id )