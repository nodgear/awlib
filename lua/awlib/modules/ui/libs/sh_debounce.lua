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

function Aw:RemoveDebounce(name)
	timer.Remove("_debounce." .. name)
end

function Aw:Debounce(name, wait, func)
  if (timer.Exists("_debounce." .. name)) then
    timer.Remove("_debounce." .. name)
  end

  timer.Create("_debounce." .. name, wait, 1, function()
    func()

    timer.Remove("_debounce." .. name)
  end)
end
