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