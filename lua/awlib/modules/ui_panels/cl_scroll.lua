
local pnl = {}

function pnl:Init()
  self.VBar:SetWide(12)
  self.VBar:SetHideButtons(true)

  self.VBar.Paint = function(pnl, w, h)
    draw.RoundedBox(6, 0, 0, w, h, ColorAlpha(Aw.UI.Theme.navbar, 150))
  end
  self.VBar.btnGrip.Paint = function(pnl, w, h)
    draw.RoundedBox(6, 0, 0, w, h, Aw.UI.Theme.accent)
  end
end

function pnl:HideScrollBar(hide)
	self.VBar:SetWide((hide and 0) or 12)
end

vgui.Register("Aw.UI.Panel.Scroll", pnl, "DScrollPanel")
