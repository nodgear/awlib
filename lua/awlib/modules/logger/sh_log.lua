--[[
	LICENSE:
	Definitions:
		the Xenin/XeninUI Copyright Owner (hereby Patrick Ratzow) under Custom Software License
		the Awesome Copyright Owner (hereby Matheus A.) under Custom Software License
		the XLib Copyright Owner (hereby Xavier B.) under MIT License
		the Software (hereby the Library and it's contents)
		Garry's Mod Marketplace is any online and offline marketplace that sells Garry's Mod game modifications in any way, including, but not limited to Gmodstore.com

	Ownership:
		the use of this library is intended, but not limited to the use by Awesome Copyright owner on Garry's Mod Marketplace
		modifying, selling or sharing this piece of software is not allowed unless respecting all above licenses

]]--

-- Module: Awesome Logger
-- Author:
--            Nodge (Matheus A.)
--            Meow
--            Ceifa (Gabriel Francisco)

-- TODO: Refact all this macaroni

local tFiles = {}
local tFileColors = {}

local incr = SERVER and 20 or 75

local function LogPrint(log, module, file, line, filecolor, typecolor)
    hook.Run("AW.LogPrint", log, module, file, line, filecolor, typecolor)

    if not module or not file then
        if CLIENT then
            chat.AddText("[AW] " .. log)
        else
            MsgC("\n[AW] " .. log .. "\n")
        end

        return
    end

    if not shouldColorize() then
        filecolor = ""
        typecolor = ""
    end

    if CLIENT then
        chat.AddText(filecolor, "[AW]" .. "[" .. module .. "] ", typecolor, log .. "~> @" .. file .. ":" .. line )
    else
        MsgC(filecolor, "[AW]" .. "[" .. module .. "] ", typecolor, log, " ~> @" .. file .. ":" .. line .. "\n")
    end

end

local function getModuleName(src)
    local iModuleStart
    local sModule = string.Explode("/", src)
    for _, c in pairs(sModule) do
        if c == "modules" then
            iModuleStart = _ + 1
        end
    end

    if sModule[iModuleStart] then
        return string.upper(sModule[iModuleStart])
    end
end

Aw.MinimumLogLevel = {
    Global = 0
}

function Aw:SetLogLevel(level)
    local info = debug.getinfo(2)
    local sModule = getModuleName(info.short_src)

    if sModule then
        Aw.MinimumLogLevel[sModule] = level
    else
        Aw.MinimumLogLevel.Global = level
    end
end

function Aw:Log(sType, sLog, ...)
    local info

    if not sLog then
        sLog = sType
        sType = "TRACE"
    elseif istable(sType) then
        info = sType.Info
        sType = sType.Level
    else
        info = debug.getinfo(2, "S")
    end

    local sModule = getModuleName(info.short_src)

    local type = logTypes[string.upper(sType)]
    local minimumLevel = Aw.MinimumLogLevel[sModule] or Aw.MinimumLogLevel.Global

    if type.Level < minimumLevel then
        return
    end

    local sFile = info.short_src
    if tFiles[sFile] then
        sFile = tFiles[sFile]
    else
        local oldsFile = sFile
        sFile = string.Explode('/', sFile)
        sFile = sFile[#sFile]
        tFiles[oldsFile] = sFile
    end

    if istable(sLog) then
        sLog = table.ToString(sLog, "[TABLE] [" .. SPrint(...) .. "]\n Output:", true) .. "\n"
    end

    if tFileColors[sFile] then
        tFileColors[sFile] = HSVToColor(incr * 60 % 360, SERVER and (game.IsDedicated() and 1 or 0.5) or 1, 0.8)
        incr = incr + 1
    else
        tFileColors[sFile] = HSVToColor(180 % 360, 1, 0.8)
    end

    local iLine = info.lastlinedefined

    LogPrint(string.format(sLog, ...), sModule, sFile, iLine, tFileColors[sFile], type.Color)
end

function Aw:LogTrace(sLog, ...)
    Aw:Log({
        Info = debug.getinfo(2, "S"),
        Level = "TRACE"
    }, sLog, ...)
end

function Aw:LogWarn(sLog, ...)
    Aw:Log({
        Info = debug.getinfo(2, "S"),
        Level = "WARN"
    }, sLog, ...)
end

function Aw:LogError(sLog, ...)
    Aw:Log({
        Info = debug.getinfo(2, "S"),
        Level = "ERROR"
    }, sLog, ...)
end