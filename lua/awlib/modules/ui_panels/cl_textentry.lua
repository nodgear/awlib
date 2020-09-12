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

-- Panel: Derma Text Entry
-- Author:
--      Xenin Team
--      Nodge
local pnl = {}

AccessorFunc(pnl, "m_backgroundColor",  "BackgroundColor" )
AccessorFunc(pnl, "m_rounded",          "Rounded"         )
AccessorFunc(pnl, "m_placeholder",      "Placeholder"     )
AccessorFunc(pnl, "m_textColor",        "TextColor"       )
AccessorFunc(pnl, "m_placeholderColor", "PlaceholderColor")
AccessorFunc(pnl, "m_iconColor",        "IconColor"       )

function pnl:Init()
    Aw.UI:CreateFont("Aw.UI.TextEntry", 18, "Montserrat SemiBold")
	self:SetBackgroundColor(AwAdmin.Config.ColorNavbar)
	self:SetRounded(6)
	self:SetPlaceholder("")
	self:SetTextColor(Color(205, 205, 205))
	self:SetPlaceholderColor(Color(120, 120, 120))
	self:SetIconColor(self:GetTextColor())

	self.textentry = vgui.Create("DTextEntry", self)
	self.textentry:Dock(FILL)
	self.textentry:DockMargin(8, 8, 8, 8)
	self.textentry:SetFont("Aw.UI.TextEntry")
	self.textentry:SetDrawLanguageID(false)
	self.textentry.Paint = function(pnl, w, h)
		local col = self:GetTextColor()
		
		pnl:DrawTextEntryText(col, col, col)

		if (#pnl:GetText() == 0) then
			draw.SimpleText(self:GetPlaceholder() or "", pnl:GetFont(), 0, pnl:IsMultiline() and 8 or h / 2, self:GetPlaceholderColor(), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		end
	end
end

function pnl:SetFont(str)
	self.textentry:SetFont(str)
end

function pnl:GetText()
	return self.textentry:GetText()
end

function pnl:SetText(str)
	self.textentry:SetText(str)
end

function pnl:SetMultiLine(state)
	self:SetMultiline(state)
	self.textentry:SetMultiline(state)
end

function pnl:SetIcon(icon, left)
    -- Todo: Change SetIcon to use WebMaterials :)
	if (!IsValid(self.icon)) then
		self.icon = vgui.Create("DButton", self)
		self.icon:SetText("")
		self.icon:Dock(left and LEFT or RIGHT)
		self.icon:DockMargin(left and 10 or -5, 10, left and 0 or 10, 10)
		self.icon.Paint = function(pnl, w, h)
			surface.SetDrawColor(self:GetIconColor())
			surface.SetMaterial(pnl.mat)
			surface.DrawTexturedRect(0, 0, w, h)
		end
		self.icon.DoClick = function(pnl)
			self.textentry:RequestFocus()
		end
	end

	self.icon.mat = icon
end

function pnl:PerformLayout(w, h)
	if (IsValid(self.icon)) then
		self.icon:SetWide(self.icon:GetTall())
	end
end

function pnl:OnMousePressed()
	self.textentry:RequestFocus()
end

function pnl:Paint(w, h)
	draw.RoundedBox(self:GetRounded(), 0, 0, w, h, self:GetBackgroundColor())
end

vgui.Register("Aw.UI.TextEntry", pnl)

