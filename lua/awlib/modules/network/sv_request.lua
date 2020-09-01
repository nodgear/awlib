local function getRequestIdentifier(builtIdentifier)
    local separatorIdx = string.find(builtIdentifier, ":")
    return string.sub(builtIdentifier, separatorIdx + 1)
end

util.AddNetworkString("AW.ClientRequest")
util.AddNetworkString("AW.ServerResponse")

net.Receive("AW.ClientRequest", function(len, ply)
    local requestIdentifier = net.ReadString()
    local arguments = net.ReadTable()

    local identifier = getRequestIdentifier(requestIdentifier)

    hook.Run(identifier, ply, function(response)
        net.Start("AW.ServerResponse")
            net.WriteString(requestIdentifier)
            net.WriteType(response)
        net.Send(ply)
    end, unpack(arguments))
end)