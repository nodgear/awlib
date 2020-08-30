AddCSLuaFile()
_MODULES.awlib = true

require "xloader"

AWESOME = AWESOME or {}
xloader("awlib", function(f) include(f) end)