util.AddNetworkString("AW.ClientRequest")
util.AddNetworkString("AW.ServerResponse")

net.Receive("AW.ClientRequest", function(len, ply)
    local identifier = net.ReadString()
    local arguments = net.ReadTable()

    hook.Run(identifier, ply, function(response)
        net.Start("AW.ServerResponse")
            net.WriteString(identifier)
            net.WriteType(response)
        net.Send(ply)
    end, unpack(arguments))
end)