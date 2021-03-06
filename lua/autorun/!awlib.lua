AddCSLuaFile()
_MODULES.awlib = true

require "xloader"

Aw = Aw or {}

xloader("awui/ui_utils", function(f) include(f) end)

xloader("awlib", function(f)
    if (timer.Exists("_load.awLib")) then
        timer.Remove("_load.awLib")
    end

    timer.Create("_load.awLib", .4, 1, function()
        hook.Run("AWESOME.LIB.Hook.Loaded")
        timer.Remove("_load.awLib")
    end)

    include(f)
end)

xloader("awui/ui_panels", function(f) include(f) end)