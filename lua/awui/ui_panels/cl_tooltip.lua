 
local pnl = {}

AccessorFunc(pnl, "m_bgWidth", "BackgroundWidth")
AccessorFunc(pnl, "m_bgHeight", "BackgroundHeight")

function pnl:Init()
  self.background = vgui.Create("DPanel", self)
  self.background.Paint = function(pnl, w, h)
    local x, y = pnl:LocalToScreen(0, 0)
    
    BSHADOWS.BeginShadow()
      draw.RoundedBox(6, x, y, w, h, XeninUI.Theme.Background)
  	BSHADOWS.EndShadow(1, 2, 2, 150, 0, 0)
  end
  self.background.closeBtn.DoClick = function(pnl)
    self:Remove()
  end
end

function pnl:Paint(w, h)
  surface.SetDrawColor(20, 20, 20, 160)
  surface.DrawRect(0, 0, w, h)
end

function pnl:PerformLayout(w, h)
  self.background:SetSize(
    self:GetBackgroundWidth(),
    self:GetBackgroundHeight()
  )
  self.background:Center()
  self:SetZPos(2000)
end

function pnl:SetText(str)
  self.label:SetTitle(str)
end

vgui.Register("Aw.UI.Panel.Tooltip", pnl, "EditablePanel")