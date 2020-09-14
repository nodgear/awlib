
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

-- Panel: Derma Avatar
-- Author:
--      Xenin Team
-- Credits:
--      Metamist

Aw.UI = Aw.UI or {}

local PANEL = {}

AccessorFunc(PANEL, "vertices", "Vertices", FORCE_NUMBER) -- so you can call panel:SetVertices and panel:GetRotation
AccessorFunc(PANEL, "rotation", "Rotation", FORCE_NUMBER) -- so you can call panel:SetRotation and panel:GetRotation

function PANEL:Init()
  self.rotation = 0
  self.vertices = 4
  self.scaler = 1
  self.avatar = vgui.Create("AvatarImage", self)
  self.avatar:SetPaintedManually(true)
end

function PANEL:CalculatePoly(w, h)
  local poly = {}

  local x = w/2
  local y = h/2 * self.scaler
  local radius = h/2

  table.insert(poly, { x = x, y = y })

  for i = 0, self.vertices do
    local a = math.rad((i / self.vertices) * -360) + self.rotation
    table.insert(poly, { x = x + math.sin(a) * radius, y = y + math.cos(a) * (radius * self.scaler) })
  end

  local a = math.rad(0)
  table.insert(poly, { x = x + math.sin(a) * radius, y = y + math.cos(a) * (radius * self.scaler) })
  self.data = poly
end

function PANEL:PerformLayout(w, actualH)
  local h = self:GetTall()
  if (self.scaler < 1) then
    h = h * self.scaler
  end

  self.avatar:SetPos(0, h - actualH)
  self.avatar:SetSize(self:GetWide(), actualH)
  self:CalculatePoly(self:GetWide(), self:GetTall())
end

function PANEL:SetPlayer(ply, size)
  if !IsValid(ply) then return end
  self.avatar:SetPlayer(ply, size)
end

function PANEL:SetSteamID(sid64, size)
  size = size or 64
  self.avatar:SetSteamID(sid64, size)
end
function PANEL:DrawPoly( w, h )
  if (!self.data) then
    self:CalculatePoly(w, h)
  end

  surface.DrawPoly(self.data)
end

function PANEL:Paint(w, h)
  render.ClearStencil()
  render.SetStencilEnable(true)

  render.SetStencilWriteMask(1)
  render.SetStencilTestMask(1)

  render.SetStencilFailOperation(STENCILOPERATION_REPLACE)
  render.SetStencilPassOperation(STENCILOPERATION_ZERO)
  render.SetStencilZFailOperation(STENCILOPERATION_ZERO)
  render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_NEVER)
  render.SetStencilReferenceValue(1)

  draw.NoTexture()
  surface.SetDrawColor(color_white)
  self:DrawPoly(w, h)

  render.SetStencilFailOperation(STENCILOPERATION_ZERO)
  render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
  render.SetStencilZFailOperation(STENCILOPERATION_ZERO)
  render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)
  render.SetStencilReferenceValue(1)

  self.avatar:PaintManual()

  render.SetStencilEnable(false)
  render.ClearStencil()
end

vgui.Register("Aw.UI.Panel.Avatar", PANEL)