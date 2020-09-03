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