/*
	1.0 (01.05.2026 by mx?!):
		* Первый релиз
*/

#include amxmodx
#include amxmisc
//#include gamecms5
native Array:cmsapi_get_user_services(const index, const szAuth[] = "", const szService[] = "", serviceID = 0, bool:part = false);

new const PLUGIN_VERSION[] = "1.0"

new const CFG_FILENAME[] = "plugins/server_access_control.cfg"

new g_szAmxxFlags[32], g_iAmxxMode, g_szGameCmsPriv[32]

public plugin_init() {
	register_plugin("Server Access Control", PLUGIN_VERSION, "mx?!")
	register_dictionary("server_access_control.txt")
	
	bind_pcvar_string(create_cvar("sac_amxx_access_flags", ""), g_szAmxxFlags, charsmax(g_szAmxxFlags))
	bind_pcvar_num(create_cvar("sac_amxx_access_mode", "0"), g_iAmxxMode)
	bind_pcvar_string(create_cvar("sac_gamecms_priv", ""), g_szGameCmsPriv, charsmax(g_szGameCmsPriv))
	
	new szPath[240]
	get_configsdir(szPath, charsmax(szPath))
	server_cmd("exec %s/%s", szPath, CFG_FILENAME)
}

public client_putinserver(pPlayer) {
	if(is_user_bot(pPlayer) || is_user_hltv(pPlayer) || g_szAmxxFlags[0] == '~') {
		return
	}
	
	new bitAccess = read_flags(g_szAmxxFlags)
	
	if(bitAccess) {
		if(g_iAmxxMode) {
			if((get_user_flags(pPlayer) & bitAccess) == bitAccess) {
				return
			}
		}
		else if(get_user_flags(pPlayer) & bitAccess) {
			return
		}
	}
	
	if(g_szGameCmsPriv[0] && cmsapi_get_user_services(pPlayer, "", g_szGameCmsPriv, 0) != Invalid_Array) {
		return
	}
	
	engclient_print(pPlayer, engprint_console, "^n%L", pPlayer, "SAC__INFO_1")
	engclient_print(pPlayer, engprint_console, "%L^n", pPlayer, "SAC__INFO_2")
	
	set_task(1.0, "task_DelayedKick", get_user_userid(pPlayer))
}

public task_DelayedKick(iUserID) {
	new pPlayer = find_player("k", iUserID)

	if(is_user_connected(pPlayer)) {
		server_cmd( "kick #%i ^"%L^"", iUserID, pPlayer, "SAC__NO_ACCESS")
	}	
}

public plugin_natives() {
	set_native_filter("native_filter")
}

// *   trap        - 0 if native couldn't be found, 1 if native use was attempted
public native_filter(const szNativeName[], iNativeID, iTrapMode) {
	return !iTrapMode
}
