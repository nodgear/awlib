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

local function getPlayers(identifier, currentTable)
    local recipient = RecipientFilter()

    for k, ply in ipairs(syncTables[identifier].listeners) do
        if IsValid(ply) then
            local proxiesResult = Aw.Net:CallProxies(identifier, ply, currentTable, Aw.SyncFlag.Merge)
            if proxiesResult ~= false then
                recipient:AddPlayer(ply)
            end
        end
    end

    return recipient
end

local function getSyncTable(identifier)
    syncTables[identifier] = syncTables[identifier] or { listeners = {} }
    return syncTables[identifier]
end

function Aw.Net:SyncTable(sIdentifier, tValue)
    local syncTable = getSyncTable(sIdentifier)
    local currentTable = syncTable.value
    local type

    if not currentTable then
        type = Aw.SyncFlag.InitialValue
        currentTable = tValue
    else
        type = Aw.SyncFlag.Merge
        currentTable = table.ShallowDiff(tValue, currentTable)
    end

    syncTable.value = table.Copy(tValue)

    local recipient = getPlayers(sIdentifier, currentTable)

    net.Start("AW.SyncTable")
        net.WriteString(sIdentifier)
        net.WriteUInt(type, 2)
        net.WriteTable(currentTable)
    net.Send(recipient)
end

util.AddNetworkString("AW.SyncTable")

net.Receive("AW.SyncTable", function(len, ply)
    local identifier = net.ReadString()
    local syncTable = getSyncTable(identifier)

    table.insert(syncTable.listeners, ply)

    if syncTable.value then
        local proxiesResult = Aw.Net:CallProxies(identifier, ply, syncTable.value, Aw.SyncFlag.InitialValue)
        if proxiesResult ~= false then
            net.Start("AW.SyncTable")
                net.WriteString(identifier)
                net.WriteUInt(Aw.SyncFlag.InitialValue, 2)
                net.WriteTable(syncTable.value)
            net.Send(ply)
        end
    end
end)