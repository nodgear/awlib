local promises = {}

function Aw:ServerRequest(sIdentifier, fCallback, ...)
    promises[sIdentifier] = fCallback

    net.Start("AW.ClientRequest")
        net.WriteString(sIdentifier)
        net.WriteTable({...})
    net.SendToServer()
end

net.Receive("AW.ServerResponse", function(len)
    local identifier = net.ReadString()
    local response = net.ReadType()

    if promises[identifier] then
        promises[identifier](response)
        promises[identifier] = nil
    end
end)