

-- Turns the LocalPlayer tracing a global variable, avoiding multiple tracehit calls

if CLIENT then
    function Aw.EnsureLocalPlayer(fn)
        if IsValid(LocalPlayer()) then
            fn()
        else
            local hkName = "Aw.EnsureLocalPlayer"..tostring(fn)
            hook.Add("InitPostEntity", hkName, function()
                hook.Remove("InitPostEntity", hkName)
                fn()
            end)
        end
    end
end

Aw.EnsureLocalPlayer(function()
    LP = LocalPlayer()
    hook.Add("Tick", "Aw.EyeTrace", function()
        EyeTrace = LP:GetEyeTrace()
        EyeEnt = EyeTrace.Entity
    end)
end)
