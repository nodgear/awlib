util.AddNetworkString("AWESOME.ClientRequest")
util.AddNetworkString("AWESOME.ServerResponse")

net.Receive("AWESOME.ClientRequest", function(len, ply)
    local identifier = net.ReadString()
    local arguments = net.ReadTable()

    hook.Run(identifier, ply, function(response)
        net.Start("AWESOME.ServerResponse")
            net.WriteString(identifier)
            net.WriteType(response)
        net.Send(ply)
    end, unpack(arguments))
end)