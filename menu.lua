-- source/libraries/roxy-menu/menu.lua
-- Initialize RoxyMenu plugin

local logWarn  = Log and Log.warn  or warn
local logDebug = Log and Log.debug or print

local ok, result = pcall(import, "libraries/roxy-menu/core/RoxyMenu")

if not ok then
  logWarn("Failed to load RoxyMenu plugin: " .. tostring(result))
else --#DEBUG
  logDebug("RoxyMenu plugin loaded successfully") --#DEBUG
end
