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

function Aw.Net:SyncTable(sIdentifier, fCallback)
    local isListening = syncTables[sIdentifier]
    if not isListening then
        syncTables[sIdentifier] = {}
    end

    syncTables[sIdentifier].callback = fCallback

    if not isListening then
        net.Start("AW.SyncTable")
            net.WriteString(sIdentifier)
        net.SendToServer()
    end
end

net.Receive("AW.SyncTable", function(len)
    local identifier = net.ReadString()
    local syncFlag = net.ReadUInt(2)
    local target = net.ReadTable()

    if syncFlag == Aw.SyncFlag.InitialValue then
        syncTables[identifier].value = target
    elseif syncFlag == Aw.SyncFlag.Merge then
        for key, value in pairs(target) do
            syncTables[identifier].value[key] = value == table.NIL and nil or value
        end
    end

    local proxiesResult = Aw.Net:CallProxies(identifier, LocalPlayer(), target, syncFlag)
    if proxiesResult ~= false then
        syncTables[identifier].callback(syncTables[identifier].value)
    end
end)