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

_MsgC = _MsgC or MsgC
_ErrorNoHalt = _ErrorNoHalt or ErrorNoHalt

local logTypes = {
    TRACE = {
        Level = 0,
        Color = color_white
    },
    WARN = {
        Level = 1,
        Color = color_orange
    },
    ERROR = {
        Level = 2,
        Color = color_red
    }
}

local available_colors            = {
    "\27[38;5;0m", "\27[38;5;18m", "\27[38;5;22m",
    "\27[38;5;12m", "\27[38;5;52m", "\27[38;5;53m",
    "\27[38;5;3m", "\27[38;5;240m", "\27[38;5;8m",
    "\27[38;5;4m", "\27[38;5;10m", "\27[38;5;14m",
    "\27[38;5;9m", "\27[38;5;13m", "\27[38;5;11m",
    "\27[38;5;15m", "\27[38;5;8m"
}

local color_map = {
    Color(0, 0, 0),       Color(0, 0, 127),      Color(0, 127, 0),
    Color(0, 127, 127),   Color(127, 0, 0),      Color(127, 0, 127),
    Color(127, 127, 0),   Color(200, 200, 200),  Color(127, 127, 127),
    Color(0, 0, 255),     Color(0, 255, 0),      Color(0, 255, 255),
    Color(255, 0, 0),     Color(255, 0, 255),    Color(255, 255, 0),
    Color(255, 255, 255), Color(128, 128, 128)
}

local color_map_len = #color_map
local color_clear_sequence = "\27[0m"

local function shouldColorize()
    local os, arch = jit.os, jit.arch
    return not (os == "Windows" and arch == "x64")
end

local function sequence_from_color(col)
    local dist, windist, ri

    for i = 1, color_map_len do
        dist = (col.r - color_map[i].r) ^ 2 + (col.g - color_map[i].g) ^ 2 + (col.b - color_map[i].b) ^ 2

        if i == 1 or dist < windist then
            windist = dist
            ri = i
        end
    end

    return available_colors[ri]
end


function print_colored(color, text)
    local color_sequence = color_clear_sequence

    if istable(color) then
        color_sequence = sequence_from_color(color)
    elseif isstring(color) then
        color_sequence = color
    end

    if not isstring(color_sequence) then
        color_sequence = color_clear_sequence
    end

    Msg(color_sequence .. text .. color_clear_sequence)
end

if shouldColorize() then
    function MsgC(...)
        local this_sequence = color_clear_sequence

        for k, v in ipairs({...}) do
            if istable(v) then
                this_sequence = sequence_from_color(v)
            else
                print_colored(this_sequence, tostring(v))
            end
        end
    end

    function ErrorNoHalt(msg)
        Msg("\27[41;15m")
        _ErrorNoHalt(msg)
        Msg(color_clear_sequence)
    end
end

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
        chat.AddText(filecolor, "[AW]" .. "[" .. module .. "] ", typecolor, log .. "~> @" .. file .. ":" .. line .. "\n")
    else
        MsgC(filecolor, "[AW]" .. "[" .. module .. "] ", typecolor, log, " ~> @" .. file .. ":" .. line .. "\n")
    end

end

local function getModuleName(src)
    local iModuleStart
    local sModule = string.Explode("/", src)
    for _, c in pairs(sModule) do
        if c == "modules" then
            iModuleStart = _
        end
    end

    if sModule[iModuleStart] then
        return string.upper(sModule[iModuleStart])
    end
end

Aw.MinimumLogLevel = {
    Global = 1
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