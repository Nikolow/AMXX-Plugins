#include < amxmodx >
#include < regex >
#include < sockets >
#include < server_query >

// Max buffer size for sockets response
#define BUFFER_SIZE 1600

// Max server connections at 1 time
#define MAX_CONNECTIONS 10

// All information regarding server queries can be found here:
// http://developer.valvesoftware.com/wiki/Server_Queries

#define A2S_PING					"^xFF^xFF^xFF^xFFping"
#define A2S_PING_LEN					9

#define A2S_INFO					"^xFF^xFF^xFF^xFF^x54Source Engine Query^x00"
#define A2S_INFO_LEN					25

#define A2S_SERVERQUERY_GETCHALLENGE			"^xFF^xFF^xFF^xFF^x56^xFF^xFF^xFF^xFF"
#define A2S_SERVERQUERY_GETCHALLENGE_LEN		9

#define A2S_PLAYER					"^xFF^xFF^xFF^xFF^x55%c%c%c%c"
#define A2S_PLAYER_LEN					9

#define A2S_RULES					"^xFF^xFF^xFF^xFF^x56%c%c%c%c"
#define A2S_RULES_LEN					9

#define REGEX_PATTERN_IP "(([a-zA-Z0-9][a-zA-Z0-9\-]*)?[a-zA-Z0-9]\.)([a-zA-Z0-9][a-zA-Z0-9\-]*)?[a-zA-Z0-9]"

ResponseTypeToQueryType( iResponseType )
{
	switch( iResponseType )
	{
		// Source Protocol
		case 0x49: return SQ_Server;
		
		// GoldSource Protocol
		case 0x6D: return SQ_Server;
		
		case 0x44: return SQ_Players;
		case 0x41: return SQ_Challenge;
		case 0x6A: return SQ_Ping;
		case 0x45: return SQ_Rules;
	}
	
	return -1;
}

enum BufferData
{
	Array:BD_aPackets,
	BD_iNumPackets,
	BD_iPacketCount
};

enum QueryData
{
	QD_iSQueryID,
	QD_iPlugin,
	QD_szIP[ 64 ],
	QD_iPort,
	QD_iType,
	QD_szFunction[ 32 ],
	Float:QD_flStartTime,
	QD_hForward,
	QD_hSocket,
	QD_iTimeout,
	QD_iData[ 128 ],
	QD_iDataSize,
	QD_iResponseAttempts,
	QD_iResponseType,
	QD_eBufferData[ BufferData ]
};

new g_iQueryCount;
new g_eQueryData[ MAX_CONNECTIONS ][ QueryData ];

new Trie:g_tServerChallenge;

new g_szBuffer[ BUFFER_SIZE ];

new Regex:g_pPatternIP;

new bool:g_bDebug = false;

new g_szDebugFile[ 64 ];

public plugin_init( )
{
	register_plugin( "Server Query API", "0.0.3", "Exolent" );
	
	register_srvcmd( "server_query_debug", "CmdDebug", _, "<0|1> - Enables/Disables debug mode for queries" );
	
	for( new i = 0; i < MAX_CONNECTIONS; i++ )
	{
		g_eQueryData[ i ][ QD_eBufferData ][ BD_aPackets ] = _:ArrayCreate( 1 );
	}
	
	g_tServerChallenge = TrieCreate( );
	
	new iReturn;
	g_pPatternIP = regex_compile( REGEX_PATTERN_IP, iReturn, "", 0 );
	
	get_localinfo( "amxx_logs", g_szDebugFile, charsmax( g_szDebugFile ) );
	add( g_szDebugFile, charsmax( g_szDebugFile ), "/server_query.log" );
}

public CmdDebug( )
{
	if( read_argc( ) > 1 )
	{
		new szArg[ 3 ];
		read_argv( 1, szArg, charsmax( szArg ) );
		
		g_bDebug = ( szArg[ 0 ] == '1' );
		
		server_print( "Debug state set to: %s", g_bDebug ? "Enabled" : "Disabled" );
	}
	else
	{
		server_print( "Current debug state: %s", g_bDebug ? "Enabled" : "Disabled" );
	}
	
	return PLUGIN_HANDLED;
}

public plugin_end( )
{
	new Array:aPackets, iNumPackets, Array:aPacket;
	
	for( new i = 0; i < MAX_CONNECTIONS; i++ )
	{
		aPackets = g_eQueryData[ i ][ QD_eBufferData ][ BD_aPackets ];
		iNumPackets = g_eQueryData[ i ][ QD_eBufferData ][ BD_iNumPackets ];
		
		while( iNumPackets-- > 0 )
		{
			aPacket = ArrayGetCell( aPackets, iNumPackets );
			
			ArrayDestroy( aPacket );
		}
		
		ArrayDestroy( aPackets );
	}
	
	TrieDestroy( g_tServerChallenge );
}

public plugin_natives( )
{
	register_library( "server_query" );
	
	register_native( "sq_query", "_sq_query" );
}

public _sq_query( iPlugin, iParams )
{
	// 1 = type (SQ_* constant)
	// 2 = ip string
	// 3 = port integer
	// 4 = callback function
	// 5 = error byref
	// 6 = timeout in seconds
	// 7 = data array
	// 8 = data size
	
	if( iParams != 8 )
	{
		if( iParams >= 5 )
		{
			set_param_byref( 5, SQError_InvalidParams );
		}
		
		return 0;
	}
	
	new iIndex = -1;
	
	for( new i = 0; i < MAX_CONNECTIONS; i++ )
	{
		if( !task_exists( i ) )
		{
			iIndex = i;
			break;
		}
	}
	
	if( iIndex == -1 )
	{
		set_param_byref( 5, SQError_MaxConnections );
		return 0;
	}
	
	new iType = g_eQueryData[ iIndex ][ QD_iType ] = get_param( 3 );
	
	if( !( 0 <= iType < ServerQueryType ) )
	{
		set_param_byref( 5, SQError_InvalidQueryType );
		return 0;
	}
	
	g_eQueryData[ iIndex ][ QD_iPlugin ] = iPlugin;
	
	get_string( 1, g_eQueryData[ iIndex ][ QD_szIP ], charsmax( g_eQueryData[ ][ QD_szIP ] ) );
	
	g_eQueryData[ iIndex ][ QD_iPort ] = get_param( 2 );
	
	for( new i = 0; i < MAX_CONNECTIONS; i++ )
	{
		if( i != iIndex && task_exists( i )
		&&  g_eQueryData[ iIndex ][ QD_iPort ] == g_eQueryData[ i ][ QD_iPort ]
		&&  equal( g_eQueryData[ iIndex ][ QD_szIP ], g_eQueryData[ i ][ QD_szIP ] ) )
		{
			set_param_byref( 5, SQError_AlreadyConnected );
			return 0;
		}
	}
	
	get_string( 4, g_eQueryData[ iIndex ][ QD_szFunction ], charsmax( g_eQueryData[ ][ QD_szFunction ] ) );
	
	g_eQueryData[ iIndex ][ QD_hForward ] = -1;
	g_eQueryData[ iIndex ][ QD_hSocket ] = 0;
	
	new iError;
	if( regex_match_c( g_eQueryData[ iIndex ][ QD_szIP ], g_pPatternIP, iError ) <= 0 )
	{
		set_param_byref( 5, SQError_InvalidIP );
		return 0;
	}
	
	new hForward = g_eQueryData[ iIndex ][ QD_hForward ] = CreateOneForward( g_eQueryData[ iIndex ][ QD_iPlugin ], g_eQueryData[ iIndex ][ QD_szFunction ],
										FP_CELL, FP_CELL, FP_CELL, FP_FLOAT, FP_CELL, FP_ARRAY, FP_CELL );
		
	if( hForward < 0 )
	{
		set_param_byref( 5, SQError_InvalidFunction );
		return 0;
	}
	
	new hSocket = g_eQueryData[ iIndex ][ QD_hSocket ] = socket_open( g_eQueryData[ iIndex ][ QD_szIP ], g_eQueryData[ iIndex ][ QD_iPort ], SOCKET_UDP, iError );
	
	if( hSocket <= 0 || iError )
	{
		DestroyForward( hForward );
		
		set_param_byref( 5, SQError_CouldNotConnect );
		return 0;
	}
	
	g_eQueryData[ iIndex ][ QD_iSQueryID ] = ++g_iQueryCount;
	
	g_eQueryData[ iIndex ][ QD_flStartTime ] = _:get_gametime( );
	
	g_eQueryData[ iIndex ][ QD_iTimeout ] = max( 1, get_param( 6 ) );
	
	new iSize = g_eQueryData[ iIndex ][ QD_iDataSize ] = min( get_param( 8 ), sizeof( g_eQueryData[ ][ QD_iData ] ) );
	
	if( iSize )
	{
		get_array( 7, g_eQueryData[ iIndex ][ QD_iData ], iSize );
	}
	
	iSize = g_eQueryData[ iIndex ][ QD_eBufferData ][ BD_iPacketCount ];
	
	if( iSize )
	{
		new Array:aPacket;
		
		for( new i = 0; i < iSize; i++ )
		{
			aPacket = ArrayGetCell( g_eQueryData[ iIndex ][ QD_eBufferData ][ BD_aPackets ], i );
			
			ArrayDestroy( aPacket );
		}
		
		ArrayClear( g_eQueryData[ iIndex ][ QD_eBufferData ][ BD_aPackets ] );
		
		g_eQueryData[ iIndex ][ QD_eBufferData ][ BD_iPacketCount ] = 0;
		g_eQueryData[ iIndex ][ QD_eBufferData ][ BD_iNumPackets ] = 0;
	}
	
	switch( iType )
	{
		case SQ_Server, SQ_Challenge, SQ_Ping:
		{
			SendRequest( iIndex, iType );
		}
		case SQ_Players, SQ_Rules:
		{
			new iChallenge = Challenge( iIndex );
			
			if( iChallenge != -1 )
			{
				SendRequest( iIndex, iType, iChallenge );
			}
			else
			{
				SendRequest( iIndex, SQ_Challenge );
			}
		}
	}
	
	set_param_byref( 5, SQError_NoError );
	
	return g_iQueryCount;
}

Challenge( iIndex, iChallenge = -1 )
{
	new szFullIP[ 64 ];
	formatex( szFullIP, charsmax( szFullIP ), "%s:%d", g_eQueryData[ iIndex ][ QD_szIP ], g_eQueryData[ iIndex ][ QD_iPort ] );
	
	if( iChallenge != -1 )
	{
		TrieSetCell( g_tServerChallenge, szFullIP, iChallenge );
		return 1;
	}
	else if( TrieGetCell( g_tServerChallenge, szFullIP, iChallenge ) )
	{
		return iChallenge;
	}
	
	return -1;
}

SendRequest( iIndex, iType, iChallenge = -1 )
{
	switch( iType )
	{
		case SQ_Server:
		{
			socket_send2( g_eQueryData[ iIndex ][ QD_hSocket ], A2S_INFO, A2S_INFO_LEN );
		}
		case SQ_Players:
		{
			new szRequest[ A2S_PLAYER_LEN + 1 ];
			formatex( szRequest, charsmax( szRequest ), A2S_PLAYER,
				( iChallenge >> 24 ) & 0xFF,
				( iChallenge >> 16 ) & 0xFF,
				( iChallenge >> 8  ) & 0xFF,
				( iChallenge       ) & 0xFF );
			
			socket_send2( g_eQueryData[ iIndex ][ QD_hSocket ], szRequest, A2S_PLAYER_LEN );
		}
		case SQ_Challenge:
		{
			socket_send2( g_eQueryData[ iIndex ][ QD_hSocket ], A2S_SERVERQUERY_GETCHALLENGE, A2S_SERVERQUERY_GETCHALLENGE_LEN );
		}
		case SQ_Ping:
		{
			socket_send2( g_eQueryData[ iIndex ][ QD_hSocket ], A2S_PING, A2S_PING_LEN );
		}
		case SQ_Rules:
		{
			new szRequest[ A2S_RULES_LEN + 1 ];
			formatex( szRequest, charsmax( szRequest ), A2S_RULES,
				( iChallenge >> 24 ) & 0xFF,
				( iChallenge >> 16 ) & 0xFF,
				( iChallenge >> 8  ) & 0xFF,
				( iChallenge       ) & 0xFF );
			
			socket_send2( g_eQueryData[ iIndex ][ QD_hSocket ], szRequest, A2S_RULES_LEN );
		}
		default:
		{
			return 0;
		}
	}
	
	g_eQueryData[ iIndex ][ QD_iResponseAttempts ] = g_eQueryData[ iIndex ][ QD_iTimeout ] * 10;
	
	set_task( 0.1, "TaskGetResponse", iIndex );
	
	return 1;
}

stock PrintBuffer( const Array:aBuffer, const iBufferLen, const iPerLine = 4 )
{
	new szMessage[ 64 ], iMessageLen;
	
	for( new i = 0; i < iBufferLen; i++ )
	{
		if( i && !( i % iPerLine ) )
		{
			Log( "%s", szMessage );
			
			iMessageLen = 0;
		}
		
		iMessageLen += formatex( szMessage[ iMessageLen ], charsmax( szMessage ) - iMessageLen, "%08X ", ArrayGetCell( aBuffer, i ) );
	}
	
	if( iMessageLen )
	{
		/*for( new i = iBufferLen; i % iPerLine; i++ )
		{
			iMessageLen += formatex( szMessage[ iMessageLen ], charsmax( szMessage ) - iMessageLen, "%08X ", 0 );
		}*/
		
		Log( "%s", szMessage );
	}
}

public TaskGetResponse( iIndex )
{
	new hSocket = g_eQueryData[ iIndex ][ QD_hSocket ];
	
	if( socket_change( hSocket, 100 ) )
	{
		new iLen = socket_recv( hSocket, g_szBuffer, charsmax( g_szBuffer ) );
		
		Log( "Found response (length=%d) for type %d", iLen, g_eQueryData[ iIndex ][ QD_iType ] );
		
		if( iLen <= 0 )
		{
			FailedResponse( iIndex );
		}
		else
		{
			new Array:aReadBuffer = ArrayCreate( 1 );
			
			for( new i = 0; i < iLen; i++ )
			{
				ArrayPushCell( aReadBuffer, g_szBuffer[ i ] );
			}
			
			PrintBuffer( aReadBuffer, iLen );
			
			new iType = g_eQueryData[ iIndex ][ QD_iType ];
			
			new iBufferType;
			new iPos = sq_readlong( aReadBuffer, iLen, 0, iBufferType );
			
			new iPacketCount, iPacketNumber;
			
			if( iBufferType == -2 )
			{
				new iRequestID;
				iPos = sq_readlong( aReadBuffer, iLen, iPos, iRequestID );
				
				new iPacketData;
				iPos = sq_readbyte( aReadBuffer, iLen, iPos, iPacketData );
				
				iPacketCount = iPacketData & 0xF;
				iPacketNumber = iPacketData >> 4;
				
				Log( "Packet: %d / %d", iPacketNumber, iPacketCount );
				
				// Check if the first packet
				if( iPacketNumber == 0 )
				{
					// Skip the next 4 bytes (should be FF FF FF FF)
					iPos += 4;
				}
			}
			else
			{
				iPacketCount = 1;
				iPacketNumber = 0;
			}
			
			new iResponseType;
			
			if( iPacketNumber == 0 )
			{
				iPos = sq_readbyte( aReadBuffer, iLen, iPos, iResponseType );
				
				g_eQueryData[ iIndex ][ QD_iResponseType ] = iResponseType;
			}
			else
			{
				iResponseType = g_eQueryData[ iIndex ][ QD_iResponseType ];
			}
			
			Log( "Response Type: %X", iResponseType );
			
			if( iType != SQ_Challenge && ResponseTypeToQueryType( iResponseType ) == SQ_Challenge )
			{
				Log( "Response is a challenge" );
				
				new iChallenge, iByte;
				
				for( new i = 0; i < 4; i++ )
				{
					iPos = sq_readbyte( aReadBuffer, iLen, iPos, iByte );
					
					iChallenge = ( iChallenge << 8 ) | iByte;
				}
				
				Challenge( iIndex, iChallenge );
				
				SendRequest( iIndex, iType, iChallenge );
			}
			else if( ResponseTypeToQueryType( iResponseType ) == iType )
			{
				new Array:aPackets = g_eQueryData[ iIndex ][ QD_eBufferData ][ BD_aPackets ];
				
				if( !g_eQueryData[ iIndex ][ QD_eBufferData ][ BD_iPacketCount ] )
				{
					g_eQueryData[ iIndex ][ QD_eBufferData ][ BD_iPacketCount ] = iPacketCount;
					
					for( new i = 0; i < iPacketCount; i++ )
					{
						ArrayPushCell( aPackets, ArrayCreate( 1 ) );
					}
				}
				else
				{
					// Needed?
					iPacketCount = g_eQueryData[ iIndex ][ QD_eBufferData ][ BD_iPacketCount ];
				}
				
				new Array:aPacket = ArrayGetCell( aPackets, iPacketNumber );
				
				for( new i = iPos; i < iLen; i++ )
				{
					ArrayPushCell( aPacket, g_szBuffer[ i ] );
				}
				
				if( ++g_eQueryData[ iIndex ][ QD_eBufferData ][ BD_iNumPackets ] < iPacketCount )
				{
					set_task( 0.1, "TaskGetResponse", iIndex );
				}
				else
				{
					new Array:aBuffer = ArrayCreate( 1 );
					new iBufferSize;
					
					for( new i = 0, iPacketSize; i < iPacketCount; i++ )
					{
						aPacket = ArrayGetCell( aPackets, i );
						iPacketSize = ArraySize( aPacket );
						
						for( iPos = 0; iPos < iPacketSize; iPos++ )
						{
							ArrayPushCell( aBuffer, ArrayGetCell( aPacket, iPos ) );
						}
						
						ArrayDestroy( aPacket );
						
						iBufferSize += iPacketSize;
					}
					
					ArrayClear( aPackets );
					
					g_eQueryData[ iIndex ][ QD_eBufferData ][ BD_iPacketCount ] = 0;
					g_eQueryData[ iIndex ][ QD_eBufferData ][ BD_iNumPackets ] = 0;
					
					new Float:flQueueTime = get_gametime( ) - g_eQueryData[ iIndex ][ QD_flStartTime ];
					
					socket_close( hSocket );
					
					iPos = 0;
					
					new Trie:tResponseData = TrieCreate( );
					
					switch( iType )
					{
						case SQ_Server:
						{	
							// Check which type of server we are reading
							switch( iResponseType )
							{
								// Source servers
								case 0x49:
								{
									static
										iVersion,
										szServerName[ 128 ],
										szMap[ 64 ],
										szGameDir[ 32 ],
										szGameDesc[ 128 ],
										iAppID,
										iNumPlayers,
										iMaxPlayers,
										iNumBots,
										iServerType,
										iOS,
										bPassword,
										bSecure,
										szGameVersion[ 32 ];
									
									iPos = sq_readbyte( aBuffer, iBufferSize, iPos, iVersion );
									iPos = sq_readstring( aBuffer, iBufferSize, iPos, szServerName, charsmax( szServerName ) );
									iPos = sq_readstring( aBuffer, iBufferSize, iPos, szMap, charsmax( szMap ) );
									iPos = sq_readstring( aBuffer, iBufferSize, iPos, szGameDir, charsmax( szGameDir ) );
									iPos = sq_readstring( aBuffer, iBufferSize, iPos, szGameDesc, charsmax( szGameDesc ) );
									iPos = sq_readshort( aBuffer, iBufferSize, iPos, iAppID );
									iPos = sq_readbyte( aBuffer, iBufferSize, iPos, iNumPlayers );
									iPos = sq_readbyte( aBuffer, iBufferSize, iPos, iMaxPlayers );
									iPos = sq_readbyte( aBuffer, iBufferSize, iPos, iNumBots );
									iPos = sq_readbyte( aBuffer, iBufferSize, iPos, iServerType );
									iPos = sq_readbyte( aBuffer, iBufferSize, iPos, iOS );
									iPos = sq_readbyte( aBuffer, iBufferSize, iPos, bPassword );
									iPos = sq_readbyte( aBuffer, iBufferSize, iPos, bSecure );
									
									// The Ship response
									if( iAppID == 2400 )
									{
										new iGameMode;
										new iWitnessCount;
										new iWitnessTime;
										
										iPos = sq_readbyte( aBuffer, iBufferSize, iPos, iGameMode );
										iPos = sq_readbyte( aBuffer, iBufferSize, iPos, iWitnessCount );
										iPos = sq_readbyte( aBuffer, iBufferSize, iPos, iWitnessTime );
										
										TrieSetCell( tResponseData, "game_mode", iGameMode );
										TrieSetCell( tResponseData, "witness_count", iWitnessCount );
										TrieSetCell( tResponseData, "witness_time", iWitnessTime );
									}
									
									iPos = sq_readstring( aBuffer, iBufferSize, iPos, szGameVersion, charsmax( szGameVersion ) );
									
									// Check for extra data
									if( iPos < iBufferSize )
									{
										new iExtraDataFlag;
										iPos = sq_readbyte( aBuffer, iBufferSize, iPos, iExtraDataFlag );
										
										if( iExtraDataFlag & 0x80 )
										{
											new iGamePort;
											iPos = sq_readshort( aBuffer, iBufferSize, iPos, iGamePort );
											
											TrieSetCell( tResponseData, "game_port", iGamePort );
										}
										if( iExtraDataFlag & 0x10 )
										{
											// Server's 64-bit SteamID
										}
										if( iExtraDataFlag & 0x40 )
										{
											new iSpectatorPort;
											new szSpectatorName[ 128 ];
											
											iPos = sq_readshort( aBuffer, iBufferSize, iPos, iSpectatorPort );
											iPos = sq_readstring( aBuffer, iBufferSize, iPos, szSpectatorName, charsmax( szSpectatorName ) );
											
											TrieSetCell( tResponseData, "spectator_port", iSpectatorPort );
											TrieSetString( tResponseData, "spectator_name", szSpectatorName );
										}
										if( iExtraDataFlag & 0x20 )
										{
											// Unsure of proper string size for this
											static szGameTags[ 1024 ];
											iPos = sq_readstring( aBuffer, iBufferSize, iPos, szGameTags, charsmax( szGameTags ) );
											
											TrieSetString( tResponseData, "game_tags", szGameTags );
										}
										if( iExtraDataFlag & 0x01 )
										{
											// Server's 64-bit GameID
										}
									}
									
									TrieSetString( tResponseData, "response_type", "source" );
									TrieSetCell( tResponseData, "protocol", iVersion );
									TrieSetString( tResponseData, "server_name", szServerName );
									TrieSetString( tResponseData, "map", szMap );
									TrieSetString( tResponseData, "game_dir", szGameDir );
									TrieSetString( tResponseData, "game_desc", szGameDesc );
									TrieSetCell( tResponseData, "appid", iAppID );
									TrieSetCell( tResponseData, "num_players", iNumPlayers );
									TrieSetCell( tResponseData, "max_players", iMaxPlayers );
									TrieSetCell( tResponseData, "num_bots", iNumBots );
									TrieSetCell( tResponseData, "server_type", iServerType );
									TrieSetCell( tResponseData, ( iOS == 'w' ) ? "windows" : "linux", 1 );
									
									if( bPassword )
									{
										TrieSetCell( tResponseData, "password", 1 );
									}
									if( bSecure )
									{
										TrieSetCell( tResponseData, "secure", 1 );
									}
									
									TrieSetString( tResponseData, "game_version", szGameVersion );
								}
								
								// GoldSource servers
								case 0x6D:
								{
									static
										szIP[ 32 ],
										szServerName[ 128 ],
										szMap[ 64 ],
										szGameDir[ 32 ],
										szGameDesc[ 128 ],
										iNumPlayers,
										iMaxPlayers,
										iVersion,
										iServerType,
										iOS,
										bPassword,
										bIsMod,
										bSecure,
										iNumBots;
									
									iPos = sq_readstring( aBuffer, iBufferSize, iPos, szIP, charsmax( szIP ) );
									iPos = sq_readstring( aBuffer, iBufferSize, iPos, szServerName, charsmax( szServerName ) );
									iPos = sq_readstring( aBuffer, iBufferSize, iPos, szMap, charsmax( szMap ) );
									iPos = sq_readstring( aBuffer, iBufferSize, iPos, szGameDir, charsmax( szGameDir ) );
									iPos = sq_readstring( aBuffer, iBufferSize, iPos, szGameDesc, charsmax( szGameDesc ) );
									iPos = sq_readbyte( aBuffer, iBufferSize, iPos, iNumPlayers );
									iPos = sq_readbyte( aBuffer, iBufferSize, iPos, iMaxPlayers );
									iPos = sq_readbyte( aBuffer, iBufferSize, iPos, iVersion );
									iPos = sq_readbyte( aBuffer, iBufferSize, iPos, iServerType );
									iPos = sq_readbyte( aBuffer, iBufferSize, iPos, iOS );
									iPos = sq_readbyte( aBuffer, iBufferSize, iPos, bPassword );
									iPos = sq_readbyte( aBuffer, iBufferSize, iPos, bIsMod );
									
									if( bIsMod )
									{
										TrieSetCell( tResponseData, "is_mod", 1 );
										
										static
											szURLInfo[ 256 ],
											szURLDownload[ 1024 ],
											iModVersion,
											iModSize,
											bServerOnly,
											bCustomClientDLL;
										
										iPos = sq_readstring( aBuffer, iBufferSize, iPos, szURLInfo, charsmax( szURLInfo ) );
										iPos = sq_readstring( aBuffer, iBufferSize, iPos, szURLDownload, charsmax( szURLDownload ) );
										iPos++; // NULL byte
										iPos = sq_readlong( aBuffer, iBufferSize, iPos, iModVersion );
										iPos = sq_readlong( aBuffer, iBufferSize, iPos, iModSize );
										iPos = sq_readbyte( aBuffer, iBufferSize, iPos, bServerOnly );
										iPos = sq_readbyte( aBuffer, iBufferSize, iPos, bCustomClientDLL );
										
										TrieSetString( tResponseData, "mod_url_info", szURLInfo );
										TrieSetString( tResponseData, "mod_url_download", szURLDownload );
										TrieSetCell( tResponseData, "mod_version", iModVersion );
										TrieSetCell( tResponseData, "mod_size", iModSize );
										if( bServerOnly )
										{
											TrieSetCell( tResponseData, "mod_server_only", 1 );
										}
										if( bCustomClientDLL )
										{
											TrieSetCell( tResponseData, "mod_custom_cldll", 1 );
										}
									}
									
									iPos = sq_readbyte( aBuffer, iBufferSize, iPos, bSecure );
									iPos = sq_readbyte( aBuffer, iBufferSize, iPos, iNumBots );
									
									TrieSetString( tResponseData, "response_type", "goldsource" );
									TrieSetString( tResponseData, "ip", szIP );
									TrieSetString( tResponseData, "server_name", szServerName );
									TrieSetString( tResponseData, "map", szMap );
									TrieSetString( tResponseData, "game_dir", szGameDir );
									TrieSetString( tResponseData, "game_desc", szGameDesc );
									TrieSetCell( tResponseData, "num_players", iNumPlayers );
									TrieSetCell( tResponseData, "max_players", iMaxPlayers );
									TrieSetCell( tResponseData, "protocol", iVersion );
									TrieSetCell( tResponseData, "server_type", iServerType );
									TrieSetCell( tResponseData, ( iOS == 'w' ) ? "windows" : "linux", 1 );
									
									if( bPassword )
									{
										TrieSetCell( tResponseData, "password", 1 );
									}
									if( bSecure )
									{
										TrieSetCell( tResponseData, "secure", 1 );
									}
									
									TrieSetCell( tResponseData, "num_bots", iNumBots );
								}
							}
						}
						case SQ_Players:
						{
							new iNumPlayers;
							iPos = sq_readbyte( aBuffer, iBufferSize, iPos, iNumPlayers );
							
							new Array:aPlayers = ArrayCreate( );
							new Trie:tPlayer;
							
							new iID, szName[ 32 ], iKills, Float:flPlayedTime;
							
							for( new i = 0; i < iNumPlayers; i++ )
							{
								tPlayer = TrieCreate( );
								
								iPos = sq_readbyte( aBuffer, iBufferSize, iPos, iID );
								iPos = sq_readstring( aBuffer, iBufferSize, iPos, szName, charsmax( szName ) );
								iPos = sq_readlong( aBuffer, iBufferSize, iPos, iKills );
								iPos = sq_readfloat( aBuffer, iBufferSize, iPos, flPlayedTime );
								
								TrieSetCell( tPlayer, "id", iID );
								TrieSetString( tPlayer, "name", szName );
								TrieSetCell( tPlayer, "kills", iKills );
								TrieSetCell( tPlayer, "time", flPlayedTime );
								
								ArrayPushCell( aPlayers, tPlayer );
							}
							
							TrieSetCell( tResponseData, "count", iNumPlayers );
							TrieSetCell( tResponseData, "players", aPlayers );
						}
						case SQ_Challenge:
						{
							new iChallenge, iByte;
							
							for( new i = 0; i < 4; i++ )
							{
								iPos = sq_readbyte( aBuffer, iBufferSize, iPos, iByte );
								
								iChallenge = ( iChallenge << 8 ) | iByte;
							}
							
							TrieSetCell( tResponseData, "challenge", iChallenge );
						}
						case SQ_Ping:
						{
							TrieSetCell( tResponseData, "ping", floatround( flQueueTime * 100.0 ) );
						}
						case SQ_Rules:
						{
							static szRule[ SQ_RULE_NAME_SIZE ], szValue[ SQ_RULE_VALUE_SIZE ];
							
							new Array:aRules = ArrayCreate( sizeof( szRule ) );
							new Array:aValues = ArrayCreate( sizeof( szValue ) );
							
							new iNumRules;
							iPos = sq_readshort( aBuffer, iBufferSize, iPos, iNumRules );
							
							while( iPos < iBufferSize )
							{
								iPos = sq_readstring( aBuffer, iBufferSize, iPos, szRule, charsmax( szRule ) );
								iPos = sq_readstring( aBuffer, iBufferSize, iPos, szValue, charsmax( szValue ) );
								
								ArrayPushString( aRules, szRule );
								ArrayPushString( aValues, szValue );
							}
							
							TrieSetCell( tResponseData, "count", iNumRules );
							TrieSetCell( tResponseData, "rules", aRules );
							TrieSetCell( tResponseData, "values", aValues );
						}
					}
					
					new hForward = g_eQueryData[ iIndex ][ QD_hForward ];
					
					new iDataSize = g_eQueryData[ iIndex ][ QD_iDataSize ];
					
					new iReturn;
					ExecuteForward( hForward, iReturn,
						g_eQueryData[ iIndex ][ QD_iSQueryID ],
						iType,
						tResponseData,
						flQueueTime,
						false,
						PrepareArray( g_eQueryData[ iIndex ][ QD_iData ], iDataSize ),
						iDataSize );
					
					DestroyForward( hForward );
					
					ArrayDestroy( aBuffer );
					
					switch( iType )
					{
						case SQ_Server:
						{
						}
						case SQ_Players:
						{
							new iCount, Array:aPlayers;
							TrieGetCell( tResponseData, "count", iCount );
							TrieGetCell( tResponseData, "players", aPlayers );
							
							new Trie:tPlayer;
							
							for( new i = 0; i < iCount; i++ )
							{
								tPlayer = ArrayGetCell( aPlayers, i );
								TrieDestroy( tPlayer );
							}
							
							ArrayDestroy( aPlayers );
						}
						case SQ_Challenge:
						{
						}
						case SQ_Ping:
						{
						}
						case SQ_Rules:
						{
							new Array:aData;
							
							TrieGetCell( tResponseData, "rules", aData );
							ArrayDestroy( aData );
							
							TrieGetCell( tResponseData, "values", aData );
							ArrayDestroy( aData );
						}
					}
					
					TrieDestroy( tResponseData );
				}
			}
			else
			{
				FailedResponse( iIndex );
			}
			
			ArrayDestroy( aReadBuffer );
		}
	}
	else if( --g_eQueryData[ iIndex ][ QD_iResponseAttempts ] > 0 )
	{
		set_task( 0.1, "TaskGetResponse", iIndex );
	}
	else
	{
		FailedResponse( iIndex );
	}
}

FailedResponse( iIndex )
{
	new hForward = g_eQueryData[ iIndex ][ QD_hForward ];
	
	new iSize = g_eQueryData[ iIndex ][ QD_iDataSize ];
	
	new iReturn;
	ExecuteForward( hForward, iReturn,
		g_eQueryData[ iIndex ][ QD_iSQueryID ],
		g_eQueryData[ iIndex ][ QD_iType ],
		Invalid_Trie,
		( get_gametime( ) - Float:g_eQueryData[ iIndex ][ QD_flStartTime ] ),
		true,
		PrepareArray( g_eQueryData[ iIndex ][ QD_iData ], iSize ),
		iSize );
	
	DestroyForward( hForward );
	
	socket_close( g_eQueryData[ iIndex ][ QD_hSocket ] );
}

Log( const szFormat[ ], any:... )
{
	if( g_bDebug )
	{
		static szLogMessage[ 1024 ];
		vformat( szLogMessage, charsmax( szLogMessage ), szFormat, 2 );
		
		log_to_file( g_szDebugFile, "%s", szLogMessage );
	}
}