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

-- Module: Awesome Network Helper and Wrapper
-- Author: Ceifa (Gabriel Francisco)

Aw.SyncFlag = {}
Aw.SyncFlag.InitialValue = 0
Aw.SyncFlag.Merge = 1

Aw.TableSyncProxies = Aw.TableSyncProxies or {}
function Aw.Net:SetTableSyncProxy(sIdentifier, fCallback)
    Aw.TableSyncProxies[sIdentifier] = Aw.TableSyncProxies[sIdentifier] or {}
    table.insert(Aw.TableSyncProxies[sIdentifier], fCallback)
end

function Aw.Net:CallProxies(sIdentifier, pPlayer, tValue, nType)
    local proxies = Aw.TableSyncProxies[sIdentifier] or {}

    for k, callback in ipairs(proxies) do
        local proxyResult = callback(pPlayer, tValue, nType)
        if proxyResult == false then
            return false
        elseif istable(proxyResult) then
            tValue = proxyResult
        end
    end

    return tValue
end