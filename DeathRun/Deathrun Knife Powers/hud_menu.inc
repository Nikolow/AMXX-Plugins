#if defined _hud_menu_included
  #endinput
#endif
#define _hud_menu_included

#define MEXIT_NEVER		-1

#define MPROP_PERPAGE	1

#define MPROP_BACKNAME	2

#define MPROP_NEXTNAME	3

#define MPROP_EXITNAME	4

native hudmenu_create(title[], handler[], r, g, b, Float:x, Float:y, autopage)
native hudmenu_additem(menu, item[], num)
native hudmenu_settext(menu, item[])
native hudmenu_display(player, menu, keysmenu, page=0)
native hudmenu_destroy(menu)
native hudmenu_setprop(menu, prop, text[]="")