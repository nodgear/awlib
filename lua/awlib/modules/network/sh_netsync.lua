Aw.SyncFlag = {}
Aw.SyncFlag.InitialValue = 0
Aw.SyncFlag.Merge = 1

local tableSyncProxies = {}
function Aw.Net:SetTableSyncProxy(sIdentifier, fCallback)
    tableSyncProxies[sIdentifier] = tableSyncProxies[sIdentifier] or {}
    table.insert(tableSyncProxies[sIdentifier], fCallback)
end

function Aw.Net:CallProxies(sIdentifier, tValue, pPlayer)
    local proxies = tableSyncProxies[sIdentifier] or {}

    for k, callback in ipairs(proxies) do
        local proxyResult = callback(pPlayer, tValue)
        if proxyResult == false then
            return false
        end
    end

    return true
end