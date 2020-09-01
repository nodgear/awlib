AddCSLuaFile()
_MODULES.awlib = true

require "xloader"

Aw = Aw or {}
xloader("awlib", function(f) include(f) end)