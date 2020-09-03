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

local syncTables = {}

local function getPlayers(identifier)
    local recipient = RecipientFilter()

    for k, ply in ipairs(syncTables[identifier].listeners) do
        if IsValid(ply) then
            recipient:AddPlayer(ply)
        end
    end

    return recipient
end

local function getSyncTable(identifier)
    syncTables[identifier] = syncTables[identifier] or { listeners = {} }
    return syncTables[identifier]
end

local function getTableDiff(source, target)
    local diff = {}

    for key, value in pairs(source) do
        if target[key] == nil then
            diff[key] = value
        end
    end

    for key, value in pairs(target) do
        if source[key] == nil then
            diff[key] = table.NIL
        end
    end

    return diff
end

function Aw.Net:SyncTable(sIdentifier, tValue)
    local syncTable = getSyncTable(sIdentifier)
    local currentTable = syncTable.value

    if not currentTable then
        tableToSend = tValue
    else
        tableToSend = getTableDiff(tValue, currentTable)
    end

    syncTable.value = tValue

    local recipient = getPlayers(sIdentifier)

    net.Start("AW.SyncTable")
        net.WriteString(sIdentifier)
        net.WriteUInt(Aw.SyncFlag.Merge, 2)
        net.WriteTable(tableToSend)
    net.Send(recipient)
end

util.AddNetworkString("AW.SyncTable")

net.Receive("AW.SyncTable", function(len, ply)
    local identifier = net.ReadString()
    local syncTable = getSyncTable(identifier)

    table.insert(syncTable.listeners, ply)

    net.Start("AW.SyncTable")
        net.WriteString(identifier)
        net.WriteUInt(Aw.SyncFlag.InitialValue, 2)
        net.WriteTable(syncTable.value or {})
    net.Send(ply)
end)