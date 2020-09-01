local promises = {}

local function buildRequestIdentifier(identifier)
    return string.format("%s:%s", math.random(1, 1000000), identifier)
end

function Aw:ServerRequest(sIdentifier, fCallback, ...)
    local requestIdentifier = buildRequestIdentifier(sIdentifier)
    promises[requestIdentifier] = fCallback

    net.Start("AW.ClientRequest")
        net.WriteString(requestIdentifier)
        net.WriteTable({...})
    net.SendToServer()
end

net.Receive("AW.ServerResponse", function(len)
    local requestIdentifier = net.ReadString()
    local response = net.ReadType()

    if promises[requestIdentifier] then
        promises[requestIdentifier](response)
        promises[requestIdentifier] = nil
    end
end)