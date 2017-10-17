/*

	Плъгин за слушане на музика в сървъра от избраната и качена на платформата в определената директория.
	Директорията се намира в SONG_PATH и взима всички песни (.mp3 файлове) в нея.
	Плъгина е направен за 1.8.3, при по-старите версии има проблем с компилацията.
	По-стара версия: http://amxx-bg.info/viewtopic.php?f=96&t=2351#p12718
	Командата може да се промени от if ( equali(Said[1], "music") ) и могат да се добавят още команди.
	Командата е: /music, като отваря меню-то с всички песни.

*/


#include <amxmisc>

#define SONG_PATH "sound/my_music"

new Array:Music;

enum _:Mp3Data
{
	Name[54],
	Path[128]
}

public plugin_precache()
{
	Music = ArrayCreate(Mp3Data);
	Read_Songs_From_Dir();
}

public plugin_init( )
{
	register_plugin("Music", "0.1", "Nikolow");
	register_clcmd("say", "Chat");
}

public plugin_end( )
{
    ArrayDestroy(Music);
}

Read_Songs_From_Dir()
{
	new Dir[128];
	formatex(Dir, charsmax(Dir), SONG_PATH);
	
	new const Mp3Ext[] = ".mp3"; 
	new Mp3File[64], Len;
	new DirPointer = open_dir(Dir, Mp3File, charsmax(Mp3File)); 
	
	if ( !DirPointer )
	{
		return; 
	}
	
	new Data[Mp3Data], Precache[128];
	
	formatex(Data[Path], charsmax(Data[Path]), "%s/%s", Dir, "/stop.mp3");
	if ( file_exists(Data[Path]) )
	{
		formatex(Precache, charsmax(Precache), "%s/stop.mp3", Dir);
		precache_sound(Precache);
		formatex(Data[Name], charsmax(Data[Name]), "Stop Music");
		ArrayPushArray(Music, Data, charsmax(Data));
	}
	
	do 
	{ 
		Len = strlen(Mp3File);
		if ( equali(Mp3File, "stop.mp3") )
		{
			continue;
		}
		
		if ( Len > 4 && equali(Mp3File[Len-4], Mp3Ext) ) 
		{
			formatex(Data[Path], charsmax(Data[Path]), "%s/%s", Dir, Mp3File);
			copy(Data[Name], charsmax(Data[Name]), Mp3File);
			Data[Name][strlen(Data[Name])-4] = '^0';
			formatex(Precache, charsmax(Precache), "%s/%s", Dir, Mp3File);
			server_print(Precache);
			precache_sound(Precache);
			
			ArrayPushArray(Music, Data, charsmax(Data));
		} 
	} 
	while ( next_file(DirPointer, Mp3File, charsmax(Mp3File)) );
	
	close_dir(DirPointer);
}

public Chat(id)
{
	new Said[10];
	read_argv(1, Said, charsmax(Said));
	
	if ( Said[0] != '/' )
	{
		return PLUGIN_CONTINUE;
	}
	
	if ( equali(Said[1], "music") )
	{
		new Data[Mp3Data], Menu = menu_create( "\rMusic Menu:", "menu_handler" );
		
		for(new i = 0; i < ArraySize(Music); ++i) 
		{
			ArrayGetArray(Music, i, Data, charsmax(Data));
			replace_string(Data[Name], charsmax(Data[Name]), "_", " ");
			menu_additem(Menu, Data[Name]);
		}
		
		menu_display(id, Menu);
		return PLUGIN_CONTINUE;
	}

	return PLUGIN_CONTINUE;
}

public menu_handler( id, Menu, Item )
{
	if( Item != MENU_EXIT )
	{
		new Data[Mp3Data];
		ArrayGetArray(Music, Item, Data, charsmax(Data));
		//server_print(Data[Path]);
		client_cmd(id, "mp3 play ^"%s^"", Data[Path]);
	}
	
	menu_destroy( Menu )
	return PLUGIN_HANDLED;
}
