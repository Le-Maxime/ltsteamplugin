# LuaTools Steam Plugin (Fork)

This is a fork of the [LuaTools Steam Plugin](https://github.com/piqseu/ltsteamplugin) by piqseu.

**Based on upstream commit / Основан на коммите:** [`7376f285cb47a64105cf0f1b6f6653030ae1ede0`](https://github.com/piqseu/ltsteamplugin/commit/7376f285cb47a64105cf0f1b6f6653030ae1ede0)

---

## Quick Installation / Быстрая установка (Windows)

To install or update this plugin, run the following command in **PowerShell**:

Для установки или обновления плагина выполните следующую команду в **PowerShell**:

```powershell
irm https://raw.githubusercontent.com/Le-Maxime/ltsteamplugin/main/install.ps1 | iex
```

*This script automatically detects your Steam directory, creates the plugin folder if missing, downloads the latest release zip from this fork, and extracts it.*

---

## Implemented Fixes in this Fork:
1. **Unpacked Named Arguments for Millennium API Calls**:
   - Modern versions of Millennium pass JS objects as a single table (dictionary) in `callServerMethod`. 
   - Updated `StartAddViaLuaToolsFromUrl` and `ApplyGameFix` in `backend/main.lua` to check if arguments are received as a table and unpack them, ensuring compatibility with both old (positional) and new (table-based) parameter styles.
2. **Fixed Background Process Escaping on Windows**:
   - Fixed quoting issues when spawning background downloader, fixes, and auto-updater scripts via `m_utils.exec` (CMD).
   - Switched to a robust UTF-16LE and Base64-encoded command strategy (`-EncodedCommand`) in PowerShell. This bypasses all CMD quote-stripping issues and ensures paths containing spaces (like `C:\Program Files (x86)\...`) are handled correctly without crashing.
3. **Corrected Morrenus API Availability Check**:
   - The Morrenus status API returns `HTTP 200 OK` even if the app is not in their library (returning `"status": "not_found"` in the JSON body).
   - Updated the availability checks in `downloads.start_add_via_luatools` and `downloads.check_apis_for_app` to decode the JSON body and verify that status is not `"not_found"` before flagging it as available.

## Before submitting PRs, keep in mind:
The plugin will go through a full rewrite in the near future, so if you want to contribute, wait until the rewrite is open sourced.
Issues will still be open and fixed on a case by case basis.
https://discord.gg/luatools
