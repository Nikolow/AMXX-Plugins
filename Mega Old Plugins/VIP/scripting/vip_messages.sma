#include <amxmodx>
#include <colorchat>

public client_putinserver(id)
set_task(18.0,"hudmsg",id)

public hudmsg(id)
{
    new name[32]
    get_user_name(id,name,31)
    if(!is_user_connected(id)) return 
    if(get_user_flags(id) & ADMIN_LEVEL_A)
    {
        set_hudmessage(0, 255, 0, -1.0, 0.18, 2, 0.1, 0.0, 0.1, 0.1, -1)
        show_hudmessage(id,"%s, ti si VIP !^n^n^n Kakvo poluchavash:^n^n 1. Reservation Slot and Immunity^n 2. Bezplatna HE Granata vseki rund^n 3. Tag pred imeto ti > [VIP]^n 4. Specialen VIP Model [T - CT]^n 5. Dostup do VIP Menuto^n^nZa da otvorite VIP Menuto napishete v chata /vmenu, /vipmenu ili /vshop^n^nKakvo vkluchva tova VIP Menu:^n Bezplatna Kruv i Bronq^n Bezplatni urajiq [1 patron]^n Granati [Spored Otbora]^n Sportni obuvki [Samo za TT]^nVAJNO: Mojete da izpolzvate samo 1 item na ROUND", name)
        ColorChat(id, GREY, "^x03.:VIP:.^x01 You are^x03 VIP^x01. You can get^x04 something^x01 form^x03 VIP Menu^x01 [^x03 FREE^x01 >^x04 No money^x01]");
        ColorChat(id, RED, "^x03.:VIP Shop:.^x01 You can^x03 GET^x01 something from^x04 VIP^x03 Menu^x01 ! Commands:^x04 /vshop^x01,^x03 /vmenu^x01 or^x04 /vipmenu");
        ColorChat(id, GREY, "^x03.:VIP Use:.^x01 You^x03 CAN^x01 use this menu^x04 EVERY^x01 Round >  > [^x03 One^x04 Choose^x01]");
    } else { 
        set_hudmessage(0, 255, 0, -1.0, 0.18, 2, 0.1, 4.0, 0.1, 0.1, -1)
        show_hudmessage(id,"%s, ti NE si VIP !^n Ako iskash da stanesh i da imash PRIVILEGII napishi v chata^n/vip^n I si izberi kakva informaciq iskash da razberesh !", name)
        ColorChat(id, GREY, "^x03.:VIP:.^x01 You are not^x03 VIP^x01.");
        ColorChat(id, GREY, "^x03.:VIP Shop:.^x01 You can't^x03 GET^x01 something from^x04 VIP^x03 Menu^x01 !");

    
    }
}



    	
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1026\\ f0\\ fs16 \n\\ par }
*/
