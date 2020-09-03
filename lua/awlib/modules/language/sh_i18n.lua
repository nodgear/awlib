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

-- Module: Awesome i18n for Garry'sMOD
-- Author:
--      Nodge (Matheus A.)

Aw.L = Aw.L or {
    api_url    = "https://api.github.com/repos/",
    repo       = "AwData",
    repo_owner = "nodgear",
}

function Aw.L:Set( sAddon, sLangcode )
    Aw.L[sAddon] =  {}
    Aw.L[sAddon].lang = string.lower(sLangcode)
end

function Aw.L:Download(sAddon)
    local LanguageCode = self[sAddon].lang or "en_us"
    local URL = self[sAddon].remote_file
    local Path = string.lower(sAddon) .. "/languages/" .. LanguageCode .. ".json"
    local File = util.JSONToTable(file.Read(Path, "LUA") or "{\"version\":0}")
    http.Fetch( URL , function(sBody)
        local Remote = util.JSONToTable(sBody)
        Remote.version = Remote.version or 0
        self[sAddon].phrases = tonumber(File.version) >= tonumber(Remote.version) and File.phrases or Remote.phrases
    end, function(err)
        self[sAddon].phrases = File or {}
    end)
end

function Aw.L:Build(sAddon)
    local URL = self.api_url..self.repo_owner.."/"..self.repo.."/contents/"..sAddon.."/languages"

    http.Fetch(URL, function(sBody)
       local tResponse = util.JSONToTable(sBody)
       for _, object in pairs(tResponse) do
        if !istable(object) then continue end
        self[sAddon].remote_file = object.download_url
       end
       self:Download(sAddon)
    end, function()
        self[sAddon].remote_file = "None"
        self[sAddon].phrases   = {}
    end)
end

function Aw.L:Translate(sAddon, sPhrase, ...)
    local result = sPhrase
    local base    = string.Explode(".", sPhrase)
    local context    = base[1]
    local str = base[2]

    if !self[sAddon] then return end

    if self[sAddon]["phrases"] then
        local i18n   = self[sAddon]["phrases"][context][str] or sPhrase
        result = i18n and (select("#", ...) > 0 and string.format(i18n, ...) or i18n) or sPhrase
    end

    -- print(  base, context, str, sPhrase, result )
    -- PrintTable(self)

    return result or "nil"
end
