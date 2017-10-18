#include <amxmodx>
#include <amxmisc>
#include <cstrike>

public plugin_init()
{
    register_plugin("Fade-Teamcolor", "1.0", "Mottzi")
    
    register_logevent("logeventRoundEnd", 2, "1=Round_End");
}

public logeventRoundEnd()
{
    new players[32], pnum, tempid;
    get_players(players, pnum);
    
    
    for( new i; i<pnum; i++ )
    {
        tempid = players[i];
        
        switch(cs_get_user_team(tempid))
        {
            case CS_TEAM_CT:
            {
                message_begin(MSG_ONE, get_user_msgid("ScreenFade"), {0,0,0}, tempid);
                write_short(4096*10);    // Duration
                write_short(4096*2);    // Hold time
                write_short(4096);    // Fade type
                write_byte(0);        // Red
                write_byte(0);        // Green
                write_byte(255);        // Blue
                write_byte(180);    // Alpha
                message_end();
            }
            
            case CS_TEAM_T:
            {
                message_begin(MSG_ONE, get_user_msgid("ScreenFade"), {0,0,0}, tempid);
                write_short(4096*10);    // Duration
                write_short(4096*2);    // Hold time
                write_short(4096);    // Fade type
                write_byte(255);        // Red
                write_byte(0);        // Green
                write_byte(0);        // Blue
                write_byte(180);    // Alpha
                message_end();
            }
        }
    }
}  