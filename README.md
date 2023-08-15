
# Anti-Reconnect

An [AMX Mod X](https://www.amxmodx.org/) plugin for [Counter-Strike 1.6](https://store.steampowered.com/app/10/CounterStrike/) that prevents players from reconnecting to the server within some time frame.

## Requirements

- HLDS
- Metamod
- AMX Mod X (>= 1.9.0)

## Installation

1. Download the [latest release](https://github.com/prnl0/amxx-anti-rc/releases/latest).
2. Extract the 7z archive into your HLDS folder.
3. Append `anti-rc.amxx` to `configs/plugins.ini`.

## Configuration (CVars)

<details>
<summary>CVars (click to expand) </summary>

_Note: the min. and max. values are not currently enforced, and are only provided as sensible bounds._

<table>
  <tr>
    <td>CVar</td>
    <td align="center">Type</td>
    <td align="center">Def. value</td>
    <td align="center">Min. value</td>
    <td align="center">Max. value</td>
    <td>Description</td>
  </tr>
  <tr><td colspan="6" align="center">Core</td></tr>
  <tr>
    <td><code>ar_admin_immunity</code></td>
    <td align="center">boolean</td>
    <td align="center">0</td>
    <td align="center">0</td>
    <td align="center">1</td>
    <td>
      Admins are allowed to reconnect indefinitely.<br>
      <code>0</code> - disabled;<br>
      <code>1</code> - enabled.
    </td>
  </tr>
  <tr>
    <td><code>ar_admin_flag</code></td>
    <td align="center">string</td>
    <td align="center"><code>"g"</code></td>
    <td align="center">-</td>
    <td align="center">-</td>
    <td>Flag identifying admins to which <code>ar_admin_immunity</code> applies. Irrelevant if <code>ar_admin_immunity</code> is <code>0</code>.</td>
  </tr>
  <tr>
    <td><code>ar_reconnect_time</code></td>
    <td align="center">integer</td>
    <td align="center">120</td>
    <td align="center">0</td>
    <td align="center">-</td>
    <td>Amount of time (in seconds) in-between reconnects.</td>
  </tr>
  <tr>
    <td><code>ar_detect_type</code></td>
    <td align="center">string</td>
    <td align="center"><code>"ip"</code></td>
    <td align="center">-</td>
    <td align="center">-</td>
    <td>
      Method by which to identify players.<br>
      <code>"authid"</code> - by AuthID (SteamID);<br>
      <code>"ip"</code> - by IP address.
    </td>
  </tr>
  <tr>
    <td><code>ar_show_in_chat</code></td>
    <td align="center">boolean</td>
    <td align="center">1</td>
    <td align="center">0</td>
    <td align="center">1</td>
    <td>
      Notify other players of reconnect attempts.<br>
      <code>0</code> - disabled;<br>
      <code>1</code> - enabled.
    </td>
  </tr>
  <tr>
    <td><code>ar_rc_attempts_to_show_in_chat</code></td>
    <td align="center">integer</td>
    <td align="center">3</td>
    <td align="center">0</td>
    <td align="center">-</td>
    <td>Number of reconnect attempts to notify other players of. (Requires <code>ar_show_in_chat 1</code>.)</td>
  </tr>
  <tr>
    <td><code>ar_prefix</code></td>
    <td align="center">string</td>
    <td align="center"><code>"^3[AR]^1"</code></td>
    <td align="center">-</td>
    <td align="center">-</td>
    <td>Prefix printed before every chat message issued by the plugin.</td>
  </tr>
</table>
</details>
