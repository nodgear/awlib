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

    local proxiesResult = Aw.Net:CallProxies(identifier, syncTables[identifier].value, LocalPlayer())
    if proxiesResult ~= false then
        syncTables[identifier].callback(proxiesResult)
    end
end)