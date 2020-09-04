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

-- Module: Async Image download
-- Author:
--      Xenin Team
--		Nodge
-- 		Sneaky Squid


Aw.UI.CachedIcons = Aw.UI.CachedIcons or {}

if (!file.IsDir("awesome/icons", "DATA")) then
  file.CreateDir("awesome/icons")
end


local function DownloadImage(tbl)
	local p = Aw.Promises.new()

	if (!isstring(tbl.id)) then
		return p:reject("ID invalid")
	end

	local id = tbl.id
	local idLower = id:lower()
	local url = tbl.url or "https://i.imgur.com"
	local type = tbl.type or "png"

	if (Aw.UI.CachedIcons[id] and Aw.UI.CachedIcons[id] != "Loading") then
		return p:resolve(Aw.UI.CachedIcons[id])
	end

	local read = file.Read("awesome/icons/" .. idLower .. "." .. type)
	if (read) then
		Aw.UI.CachedIcons[id] = Material("../data/awesome/icons/" .. idLower .. ".png", "smooth")

		return p:resolve(Aw.UI.CachedIcons[id])
	end

	http.Fetch(url .. "/" .. id .. "." .. type, function(body)
		local str = "awesome/icons/" .. idLower .. "." .. type
		file.Write(str, body)

		Aw.UI.CachedIcons[id] = Material("../data/" .. str, "smooth")

		p:resolve(Aw.UI.CachedIcons[id])
	end, function(err)
		p:reject(err)
	end)

	return p
end

function Aw.UI:DownloadIcon(pnl, tbl, pnlVar)
	if (!tbl) then return end

	local p = Aw.Promises.new()

	if (isstring(tbl)) then
		tbl = { { id = tbl } }
	end

	local i = 1
	local function AsyncDownload()
		if (!tbl[i]) then p:reject() end

		pnl[pnlVar or "Icon"] = "Loading"
		DownloadImage(tbl[i]):next(function(result)
			p:resolve(result):next(function()
				pnl[pnlVar or "Icon"] = result
			end, function(err)
				ErrorNoHalt(err)
			end)
		end, function(err)
			i = i + 1

			ErrorNoHalt(err)

			AsyncDownload()
		end)
	end

	AsyncDownload()

	return p
end

function Aw.UI:DrawIcon(x, y, w, h, pnl, col, loadCol, var)
	col = col or color_white
	loadCol = loadCol or color_red
	var = var or "Icon"

	if (pnl[var] and type(pnl[var]) == "IMaterial") then
		surface.SetMaterial(pnl[var])
		surface.SetDrawColor(col)
		surface.DrawTexturedRect(x, y, w, h)
	elseif (pnl[var] != nil) then
		Aw.UI:DrawLoadingCircle(h, h, h, loadCol)
  end
end

-- Can be used, but I recommend using :DownloadIcon one as it's more customisable
-- This is preserved for old use
function Aw.UI:GetIcon(id)
	local _type = type(id)
	if (_type == "IMaterial") then
		return id
	end

	if (self.CachedIcons[id]) then
		return self.CachedIcons[id]
	end

	local read = file.Read("awesome/icons/" .. id:lower() .. ".png")
	if (read) then
		self.CachedIcons[id] = Material("../data/awesome/icons/" .. id:lower() .. ".png", "smooth")
	else
		self.CachedIcons[id] = "Loading"
	end

	http.Fetch("https://i.imgur.com/" .. id .. ".png", function(body, len)
		local str = "awesome/icons/" .. id:lower() .. ".png"
		file.Write(str, body)

		self.CachedIcons[id] = Material("../data/" .. str, "smooth")
	end)
end
