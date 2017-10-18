/*

	При влизане в сървъра, след 6 секунди, ще бъде изкарано HUD съобщение с правилата на сървъра.

*/

#include <amxmodx>
#include <amxmisc>

#define PLUGIN    "Welcome Hud Message"
#define AUTHOR    "Advanced"
#define VERSION    "1.0"

new name[32]

new const ConnectMessage[] = "Welcome %s^nxD GaminG 2 Rules:^n^n1. No SpawnKill^n2. No UnderStab^n3. No UnderBlock^n4. No team block^n5. No use of buggs^n6. No FunJumping (FJ)^n7. No Winning Team Join (WTJ)^n8. No Publiccity for other servers^n9. No script e.x. bhop, rysshop script^n10. No Screaming in your microphone, talk normally^n^n -- Type /rules if you want to see rules again -- ^n^n------- To SEE Admin Rules type /adminrules -------"

public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR)
}

public client_putinserver(id)
{
    get_user_name(id, name, 31)
    set_task(6.0, "ShowTheHud", id)
}

public ShowTheHud(id)
{
    set_hudmessage(191, 191, 191, -1.0, 0.17, 1, 13.0, 13.0, 2.0, 1.0, -1)
    show_hudmessage(id, ConnectMessage, name)
}  