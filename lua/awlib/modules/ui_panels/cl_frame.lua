
local pnl = {}

AccessorFunc(pnl, "m_canminimize",   "CanMinimize"          , FORCE_BOOL  )

function pnl:Init()
  Aw.UI:CreateFont("Aw.UI.Font.FrameTitle", 21, "Montserrat Semibold")

  self.closeButton = self:Add("Aw.UI.Panel.Button")
  self.closeButton:SetText("x")
  self.closeButton:Dock(RIGHT)
  self.closeButton:SetBackgroundColor( AwAdmin.Config.ColorNavbar )
  self.closeButton.DoClick = function(s,w,h)
    self:GetParent():Remove()
  end
  self.closeButton:Deploy()

  self.title = self:Add("DLabel")
  self.title:SetFont("Aw.UI.Font.FrameTitle")
  self.title:SetTextColor(AwAdmin.Config.ColorText)
  self.title:SetText("Awesome")


  self.resizeButton = self:Add("Aw.UI.Panel.Button")
  self.resizeButton:SetText("-")
  self.resizeButton:Dock(RIGHT)
  self.resizeButton:SetBackgroundColor( AwAdmin.Config.ColorNavbar )
  self.resizeButton.DoClick = function(s,w,h)
    if not self.pw or not self.ph then
      self.px, self.py, self.pw, self.ph = self:GetParent():GetBounds()
    end
    if not self:GetParent().Minimized then
      self:GetParent():SizeTo(300, self:GetTall(), .1, 0)
      for _, panel in pairs(self:GetParent():GetChildren()) do
        if panel ~= self then
          panel:SetVisible(false)
        end
      end
      self:GetParent():Stack(self.title:GetText())
      local sn, sw, sh = self:GetParent():GetStack(300,40,16)
      self:GetParent():MoveTo(ScrW() - 316, ScrH() - sh, .3, 0, -1, function()
      end)
      self:GetParent().Minimized = true
      self:GetParent():SetKeyboardInputEnabled( false )
    else
      self:GetParent():SizeTo(self.pw, self.ph, .1, 0, -1, function()
        for _, panel in pairs(self:GetParent():GetChildren()) do
          if panel ~= self then
            panel:SetVisible(true)
          end
        end
        self:GetParent():MoveTo(ScrW()/2 - self:GetParent():GetWide() / 2, ScrH()/2 - self:GetParent():GetTall()/2, .2, 0, -1, function()
        end)
        self:GetParent():SetKeyboardInputEnabled( true )
        self:GetParent().Minimized = false
        self:GetParent():RemoveStack()
      end)
    end
  end
  self.resizeButton:Deploy()

  self:Dock(TOP)
end

function pnl:PerformLayout(w,h)
  self:SetTall(40)
  self.closeButton:SetWide(h)
  self.resizeButton:SetVisible(self:GetCanMinimize())
  self.resizeButton:SetWide(h)

  self.title:Dock(LEFT)
  self.title:SizeToContents()
  self.title:SetTextInset(8, 0)
end

function pnl:Paint(w,h)
  draw.RoundedBoxEx(AwAdmin.Sizes.br, 0, 0, w, h, AwAdmin.Config.ColorNavbar, true, true, self:GetParent().Minimized, self:GetParent().Minimized)
end

function pnl:OnMousePressed(sKeyCode)
  if sKeyCode ~= MOUSE_LEFT then return end
  self.mpx, self.mpy = self:CursorPos()
  self.sw, self.sh = ScrW(), ScrH()

  self.mpx = math.Clamp(self.mpx, 0, self:GetWide())
  self.mpy = math.Clamp(self.mpy, 0, self:GetWide())
  self.Dragging = true
end

function pnl:OnMouseReleased(sKeyCode)
  if sKeyCode ~= MOUSE_LEFT then return end
  self.mpx, self.mpy = 0, 0
  self.Dragging = false
end

function pnl:Think()
  if self:GetParent().Minimized then
    self:GetParent():SetMouseInputEnabled( self:GetParent():InBound() )
    self:GetParent():SetKeyboardInputEnabled( self:GetParent():InBound() )
  end

  if not self.Dragging then return end
  local mx, my = gui.MousePos()
  local px, py, w, h = self:GetParent():GetBounds()

  local x, y = math.Clamp(mx - self.mpx, 0, self.sw - w), math.Clamp(my - self.mpy, 0, self.sh - h)

  self:GetParent():SetPos( x, y )
end

function pnl:DragMousePress(sKeyCode)

end

function pnl:SetTitle(str)
    self.title:SetText(str)
end

-- function pnl:Think()

    -- self:SetMouseInputEnabled(self:InBound())
    -- gui.EnableScreenClicker( self:InBound() )
-- end

function pnl:OnCursorEntered()
  self:SetCursor("sizeall")
end

vgui.Register("Aw.UI.Panel.FrameHeader", pnl, "EditablePanel")