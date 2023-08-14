/* Modified from the original: https://amx-x.ru/viewtopic.php?f=8&t=34883 */

#include <amxmodx>

#define PLUGIN  "Anti-Reconnect"
#define VERSION "1.3"
#define AUTHOR  "RevCrew & prnl0"

#define DICTIONARY "anti-rc.txt"

#define SET_BIT(%1,%2)    (%1 |= (1 << (%2 & 31)))
#define CLEAR_BIT(%1,%2)  (%1 &= ~(1 << (%2 & 31)))
#define CHECK_BIT(%1,%2)  (%1 & (1 << (%2 & 31)))

#define MIN_RC_TIME 10.0
#define MAX_RC_TIME 300.0

enum DetectType
{
  dt_authid = 0,
  dt_ip
}

enum _:PlayerData
{
  pd_rc_count,
  pd_entry_permit_time
}

new Trie:g_user_map;
new g_in_rc = 0;

new g_pcvar_admin_immunity = 0;
new g_pcvar_admin_flag = 0;
new g_pcvar_rc_time = 0;
new g_pcvar_detect_type = 0;
new g_pcvar_chat_show_n_rc_attemps = 0;
new g_pcvar_chat_show = 0;
new g_pcvar_prefix = 0;

public plugin_init()
{
  register_plugin(PLUGIN, VERSION, AUTHOR);
  register_dictionary(DICTIONARY);

  g_pcvar_admin_immunity          = register_cvar("ar_admin_immunity", "0");
  g_pcvar_admin_flag              = register_cvar("ar_admin_flag", "g");
  g_pcvar_rc_time                 = register_cvar("ar_reconnect_time", "120");
  g_pcvar_detect_type             = register_cvar("ar_detect_type", "ip");
  g_pcvar_chat_show               = register_cvar("ar_show_in_chat", "1");
  g_pcvar_chat_show_n_rc_attemps  = register_cvar("ar_rc_attempts_to_show_in_chat", "3");
  g_pcvar_prefix                  = register_cvar("ar_prefix", "^3[AR]^1");

  g_user_map = TrieCreate();
}

public plugin_end()
{
  TrieDestroy(g_user_map)
}

public client_connect(pid)
{
  CLEAR_BIT(g_in_rc, pid);

  if (should_bypass_ar(pid)) {
    return PLUGIN_CONTINUE;
  }

  static id[MAX_AUTHID_LENGTH + 1];
  get_detect_id(pid, id, charsmax(id));
  
  new player[PlayerData];
  /* TODO: checking if `TrieGetArray` succeeded is really not necessary if you
   *       trust the logic in `client_disconnected`. */
  if (TrieGetArray(g_user_map, id, player, 2)) {
    new time_left = player[pd_entry_permit_time] - get_systime(0);
    if (time_left > 0) {
      SET_BIT(g_in_rc, pid);

      ++player[pd_rc_count];
      TrieSetArray(g_user_map, id, player, 2);

      server_cmd("kick #%d ^"%L^"", get_user_userid(pid), pid, "CONSOLE_KICK", time_left);

      if (
        get_pcvar_bool(g_pcvar_chat_show)
        && player[pd_rc_count] <= get_pcvar_num(g_pcvar_chat_show_n_rc_attemps)
      ) {
        /* TODO: eventually replace with a global stock that formats messages. */
        static name[MAX_NAME_LENGTH + 1];
        static msg[MAX_FMT_LENGTH + 1];
        get_user_name(pid, name, charsmax(name));
        get_pcvar_string(g_pcvar_prefix, msg, charsmax(msg));
        formatex(
          msg, charsmax(msg),
          "%L", LANG_PLAYER, "CHAT_PLAYER_KICKED", msg, name, get_pcvar_num(g_pcvar_rc_time)
        );
        client_print_color(0, print_team_default, msg);
      }

      return PLUGIN_CONTINUE;
    }
    TrieDeleteKey(g_user_map, id);
  }

  return PLUGIN_CONTINUE;
}

public client_disconnected(pid)
{
  if (should_bypass_ar(pid) || CHECK_BIT(g_in_rc, pid)) {
    return PLUGIN_CONTINUE;
  }

  static id[MAX_AUTHID_LENGTH + 1];
  get_detect_id(pid, id, charsmax(id));

  new player[PlayerData];
  TrieGetArray(g_user_map, id, player, 2);
  player[pd_rc_count] = 0;
  player[pd_entry_permit_time] = get_systime(0) + get_pcvar_num(g_pcvar_rc_time);
  TrieSetArray(g_user_map, id, player, 2);

  return PLUGIN_CONTINUE;
}

/* Utilities */

bool:should_bypass_ar(pid)
{
  if (get_pcvar_bool(g_pcvar_admin_immunity)) {
    static flag[16];
    get_pcvar_string(g_pcvar_admin_flag, flag, charsmax(flag));
    if (get_user_flags(pid) & read_flags(flag)) {
      return true;
    }
  }
  return false;
}

get_detect_id(pid, id[], maxlen)
{
  if (get_detect_type() == DetectType:dt_ip) {
    get_user_ip(pid, id, maxlen, 1);
  } else {
    get_user_authid(pid, id, maxlen);
  }
}

DetectType:get_detect_type()
{
  static detect_type[7];
  get_pcvar_string(g_pcvar_detect_type, detect_type, charsmax(detect_type));
  if (!strncmp(detect_type, "authid", 6, true)) {
    return DetectType:dt_authid;
  } else {
    return DetectType:dt_ip;
  }
}