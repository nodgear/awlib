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

local promises = {}

local function buildRequestIdentifier(identifier)
    return string.format("%s:%s", math.random(1, 1000000), identifier)
end

function Aw.Net:ServerRequest(sIdentifier, fCallback, ...)
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