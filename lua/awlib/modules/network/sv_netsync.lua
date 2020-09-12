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

]]
--
-- Module: Awesome Network Helper and Wrapper
-- Author: Ceifa (Gabriel Francisco)
local syncTables = {}

local function getSyncTable(identifier)
    syncTables[identifier] = syncTables[identifier] or {
        listeners = {}
    }

    return syncTables[identifier]
end

function Aw.Net:SyncTable(sIdentifier, tValue)
    local syncTable = getSyncTable(sIdentifier)

    for ply, snapshot in pairs(syncTable.listeners) do
        if IsValid(ply) then
            local type, value

            if not snapshot then
                type = Aw.SyncFlag.InitialValue
                value = tValue
            else
                type = Aw.SyncFlag.Merge
                value = table.ShallowDiff(tValue, snapshot)
            end

            local proxiesResult = Aw.Net:CallProxies(sIdentifier, ply, value, type)
            if table.Count(value) > 0 and proxiesResult then
                net.Start("AW.SyncTable")
                    net.WriteString(sIdentifier)
                    net.WriteUInt(type, 2)
                    net.SafeWriteTable(value)
                net.Send(ply)

                syncTable.listeners[ply] = table.Copy(tValue)
            end
        else
            syncTable.listeners[ply] = nil
        end
    end

    syncTable.value = table.Copy(tValue)
end

util.AddNetworkString("AW.SyncTable")

net.Receive("AW.SyncTable", function(len, ply)
    local identifier = net.ReadString()
    local syncTable = getSyncTable(identifier)

    syncTable.listeners[ply] = syncTable.listeners[ply] or false

    if syncTable.value then
        Aw.Net:SyncTable(identifier, syncTable.value)
    end
end)