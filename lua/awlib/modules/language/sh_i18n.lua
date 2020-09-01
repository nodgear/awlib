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

    if self[sAddon]["phrases"] then
        print("tem phrase")
        local i18n   = self[sAddon]["phrases"][context][str] or sPhrase
        result = i18n and (select("#", ...) > 0 and string.format(i18n, ...) or i18n) or sPhrase
    end

    -- print(  base, context, str, sPhrase, result )
    -- PrintTable(self)

    return result or "nil"
end
