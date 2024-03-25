--[[
                           _   _     __    ___    _____                             __  
                          (_) | |   /_ |  / _ \  | ____|                           / /
   ___   ___   _ __ ___    _  | |_   | | | (_) | | |__         _ __ ___   ___     / / 
  / __| / __| | '_ ` _ \  | | | __|  | |  \__, | |___ \       | '_ ` _ \ / _ \   / /  
 | (__  \__ \ | | | | | | | | | |_   | |    / /   ___) |  _   | | | | | |  __/  / /   
  \___| |___/ |_| |_| |_| |_|  \__|  |_|   /_/   |____/  (_)  |_| |_| |_|\___| /_/    
   
   
    Script Name: Emulate Chat while Muted
    Script Author: csmit195
    Script Version: 1.0
    Script Description: Yep, stop getting muted trolls.
]]

local ffi = require("ffi")
local js = panorama.open()
local GameStateAPI = js.GameStateAPI

local sendChatSuccess, SendChat = pcall(function()
   ffi.cdef[[
      typedef void***(__thiscall* FindHudElement_t)(void*, const char*);
      typedef void(__cdecl* ChatPrintf_t)(void*, int, int, const char*, ...);
   ]]

   local signature_gHud = '\xB9\xCC\xCC\xCC\xCC\x88\x46\x09'
   local signature_FindElement = '\x55\x8B\xEC\x53\x8B\x5D\x08\x56\x57\x8B\xF9\x33\xF6\x39\x77\x28'

   local match = client.find_signature('client_panorama.dll', signature_gHud) or error('sig1 not found') -- returns void***
   local char_match = ffi.cast('char*', match) + 1
   local hud = ffi.cast('void**', char_match)[0] or error('hud is nil') -- returns void**

   match = client.find_signature('client_panorama.dll', signature_FindElement) or error('FindHudElement not found')
   local find_hud_element = ffi.cast('FindHudElement_t', match)
   local hudchat = find_hud_element(hud, 'CHudChat') or error('CHudChat not found')
   local chudchat_vtbl = hudchat[0] or error('CHudChat instance vtable is nil')
   local raw_print_to_chat = chudchat_vtbl[27] -- void*
   local print_to_chat = ffi.cast('ChatPrintf_t', raw_print_to_chat)

   return function (text)
      print_to_chat(hudchat, 0, 0, text)
   end
end)

if ( sendChatSuccess ) then
   local colors = {'\x01', '\x10', '\x0B'}
   client.set_event_callback('player_chat', function (e)
      local ent, name, text = e.entity, e.name, e.text
      if ( ent == entity.get_local_player() ) then
         local Team = entity.get_prop(ent,  'm_iTeamNum')
         local TeamFullName = (Team == 3 and 'Counter-Terrorist') or (Team == 2 and 'Terrorist') or (Team == 1 and 'Spectators') or ''
         local LocalPlayer = GameStateAPI.GetLocalPlayerXuid()
         if ( LocalPlayer and GameStateAPI.IsSelectedPlayerMuted(LocalPlayer) ) then
            SendChat(' ' .. colors[Team] .. '[*] ' .. (e.teamonly and '(' .. TeamFullName .. ') ' or '') .. name .. ': ' .. '\x01' .. text)
         end
      end
   end)
else
   error('Failed to initiate FFI Print to Chat, try reloading')
end