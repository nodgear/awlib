local promises = {}

function AWESOME:ServerRequest(sIdentifier, fCallback, ...)
    promises[sIdentifier] = fCallback

    net.Start("AWESOME.ClientRequest")
        net.WriteString(sIdentifier)
        net.WriteTable({...})
    net.SendToServer()
end

net.Receive("AWESOME.ServerResponse", function(len)
    local identifier = net.ReadString()
    local response = net.ReadType()

    if promises[identifier] then
        promises[identifier](response)
        promises[identifier] = nil
    end
end)