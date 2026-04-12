#include <amxmodx>
#include <amxmisc>

#define PLUGIN_VERSION "1.0"

// Конфиг с файлами музыки относительно "amxmodx/configs"
new const INI_FILENAME[] = "plugins/welcome_music.ini"

// Максимальное кол-во треков. Увеличить при необходимости.
#define MAX_FILES 32

new g_szMusic[MAX_FILES][128], g_iCount

public plugin_precache() {
   register_plugin("Welcome Music", PLUGIN_VERSION, "mx?!")

   new szPath[240]
   new iLen = get_configsdir(szPath, charsmax(szPath))
   formatex(szPath[iLen], charsmax(szPath) - iLen, "/%s", INI_FILENAME)

   new hFile = fopen(szPath, "r")

   if(!hFile) {
      set_fail_state("Can't %s '%s'", file_exists(szPath) ? "read" : "find", szPath)
      return
   }

   while(fgets(hFile, szPath, charsmax(szPath))) {
      trim(szPath)

      if(!szPath[0] || szPath[0] == ';' || szPath[0] == '/') {
         continue
      }

      copy(g_szMusic[g_iCount], charsmax(g_szMusic[]), szPath)
      precache_sound(g_szMusic[g_iCount])
      g_iCount++
   }

   if(!g_iCount) {
      set_fail_state("No music defined in '%s'", INI_FILENAME)
   }
}

public client_putinserver(pPlayer) {
   set_task(1.0, "PlayMusic", pPlayer)
}

public client_disconnected(pPlayer) {
   remove_task(pPlayer)
}

public PlayMusic(pPlayer) {
   client_cmd(pPlayer, fmt("mp3 play sound/%s", g_szMusic[ random_num(0, g_iCount - 1) ]))
}