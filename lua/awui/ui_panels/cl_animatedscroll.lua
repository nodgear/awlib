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
-- Extra credits:
--      Methamist


local PANEL = {}

AccessorFunc(PANEL, "m_bVisibleFullHeight", "VisibleFullHeight", FORCE_BOOL)

function PANEL:Init()
    self.Offset = 0
    self.Scroll = 0
    self.CanvasSize = 1
    self.BarSize = 1

    self.scrollbar = vgui.Create("DScrollBarGrip", self)
    self.scrollbar.Paint = function(pnl, w, h)
        surface.SetDrawColor(255, 255, 255, 20)
        surface.DrawRect(0, 0, w, h)
    end

    self:SetSize(4, 4)

    self.scrollDelta = delta

    self:SetVisibleFullHeight(false)
end

function PANEL:SetEnabled(b)
    if not b then
        self.Offset = 0
        self:SetScroll(0)
        self.HasChanged = true
    end

    self:SetMouseInputEnabled(b)

    if not self:GetVisibleFullHeight() then
        self:SetVisible(b)
    end

    if self.Enabled ~= b then
        self:GetParent():InvalidateLayout()

        if self:GetParent().OnScrollbarAppear then
            self:GetParent():OnScrollbarAppear()
        end
    end

    self.Enabled = b
end

function PANEL:GetEnabled()
    return self.Enabled
end

function PANEL:Value()
    return self.Pos
end

function PANEL:BarScale()
    if self.BarSize == 0 then return 1 end

    return self.BarSize / (self.CanvasSize + self.BarSize)
end

function PANEL:SetUp(_barSize_, _canvasSize_)
    self.BarSize = _barSize_
    self.CanvasSize = math.max(_canvasSize_ - _barSize_, 1)

    self:SetEnabled(_canvasSize_ > _barSize_)

    self:InvalidateLayout()
end

function PANEL:OnMouseWheeled(dlta)
    if not self:IsVisible() then return false end

    return self:AddScroll(dlta * -2)
end

function PANEL:AddScroll(dlta)
    local oldScroll = self:GetScroll()

    dlta = dlta * 25
    self:SetScroll(oldScroll + dlta)

    return oldScroll ~= self:GetScroll()
end

function PANEL:SetScroll(scrll)
    if not self.Enabled then self.Scroll = 0 return end

    self.Scroll = math.Clamp(scrll, 0, self.CanvasSize + 75)

    self:InvalidateLayout()

    local func = self:GetParent().OnVScroll
    if func then
        func(self:GetParent(), self:GetOffset())
    else
        self:GetParent():InvalidateLayout()
    end
end

function PANEL:LimitScroll()
    if self.Scroll < 0 or self.Scroll > self.CanvasSize then
        self.Scroll = math.Clamp(self.Scroll, -75, self.CanvasSize + 75)
    end
end

function PANEL:AnimateTo(scrll, length, delay, ease)
    local anim = self:NewAnimation(length, delay, ease)
    anim.StartPos = self.Scroll
    anim.TargetPos = scrll
    anim.Think = function(anim, pnl, fraction)
        pnl:SetScroll(Lerp(fraction, anim.StartPos, anim.TargetPos))
    end
end

function PANEL:GetScroll()
    if not self.Enabled then self.Scroll = 0 end
    return self.Scroll
end

function PANEL:GetOffset()
    if not self.Enabled then return 0 end
    return self.Scroll * -1
end

function PANEL:Think() end

function PANEL:OnMousePressed()
    local x, y = self:CursorPos()

    local pageSize = self.BarSize

    if y > self.scrollbar.y then
        self:SetScroll(self:GetScroll() + pageSize)
    else
        self:SetScroll(self:GetScroll() - pageSize)
    end
end

function PANEL:OnMouseReleased()
    self.Dragging = false
    self.DraggingCanvas = nil
    self:MouseCapture(false)

    self.scrollbar.Depressed = false
end

function PANEL:OnCursorMoved(x, y)
    if not self.Enabled or not self.Dragging then return end

    local x = 0
    local y = gui.MouseY()
    local x, y = self:ScreenToLocal(x, y)

    y = y - self.HoldPos

    local trackSize = self:GetTall() - self.scrollbar:GetTall()
    y = y / trackSize

    self:SetScroll(math.Clamp(y * self.CanvasSize, 0, self.CanvasSize))
end

function PANEL:Grip()
    if not self.Enabled or self.BarSize == 0 then return end

    self:MouseCapture(true)
    self.Dragging = true

    local x, y = 0, gui.MouseY()
    local x, y = self.scrollbar:ScreenToLocal(x, y)
    self.HoldPos = y

    self.scrollbar.Depressed = true
end

function PANEL:PerformLayout(w, h)
    self:LimitScroll()

    local scroll = self:GetScroll() / self.CanvasSize
    local barSize = math.max(self:BarScale() * self:GetTall(), 10)
    local track = self:GetTall() - barSize
    track = track + 1

    scroll = scroll * track

    local barStart = math.max(scroll, 0)
    local barEnd = math.min(scroll + barSize, self:GetTall())

    self.scrollbar:SetPos(0, barStart)
    self.scrollbar:SetSize(w, barEnd - barStart)
end


function PANEL:Paint(w, h)
end

vgui.Register("Aw.UI.Panel.ScrollbarAnimated", PANEL, "Panel")

--[[
	Created by Patrick Ratzow (sleeppyy).

	Credits goes to Metamist for his previously closed source library Wyvern,
		CupCakeR for various improvements, the animated texture VGUI panel, and misc.
]]
 
local PANEL = {}

AccessorFunc(PANEL, "Padding",   "Padding")
AccessorFunc(PANEL, "pnlCanvas", "Canvas")
AccessorFunc(PANEL, "m_scrollbarLeftSide", "ScrollbarLeftSide")
AccessorFunc(PANEL, "m_bBarDockOffset", "BarDockShouldOffset", FORCE_BOOL)

function PANEL:Init()
    self.pnlCanvas = vgui.Create("Panel", self)
    self.pnlCanvas.OnMousePressed = function(self, code) self:GetParent():OnMousePressed(code) end
    self.pnlCanvas:SetMouseInputEnabled(true)
    self.pnlCanvas.PerformLayout = function(pnl)
        self:PerformLayout()
        self:InvalidateParent()
    end

    self.VBar = vgui.Create("Aw.UI.Panel.ScrollbarAnimated", self)
    self.VBar:Dock(RIGHT)

    self:SetPadding(0)
    self:SetMouseInputEnabled(true)

    -- This turns off the engine drawing
    self:SetPaintBackgroundEnabled(false)
    self:SetPaintBorderEnabled(false)

    self.scrollDelta = 0
    self.scrollReturnWait = 0

    self:SetBarDockShouldOffset(true)

    -- Edited in idc
    self:SetBarDockShouldOffset(false)
    self.VBar:SetWide(8)
    self.VBar.Paint = function(pnl, w, h)
      draw.RoundedBox(w / 2, 0, 0, w, h, AwAdmin.Config.ColorNavbar)
    end
    self.VBar.scrollbar.barAlpha = 0
    self.VBar.scrollbar.Paint = function(pnl, w, h)
      if self.VBar:GetEnabled() then
        pnl.barAlpha = pnl.barAlpha + (1 - pnl.barAlpha) * 10 * FrameTime()
      else
        pnl.barAlpha = pnl.barAlpha + (0 - pnl.barAlpha) * 10 * FrameTime()
      end

      draw.RoundedBox(w / 2, 0, 0, w, h, ColorAlpha(AwAdmin.Config.ColorAccent, 255 * pnl.barAlpha))
    end
    self.VBar:SetVisibleFullHeight(true) 
end

function PANEL:AddItem(pnl)
    pnl:SetParent(self:GetCanvas())
end

function PANEL:OnChildAdded(child)
    self:AddItem(child)
end

function PANEL:SizeToContents()
    self:SetSize(self.pnlCanvas:GetSize())
end

function PANEL:GetVBar()
    return self.VBar
end

function PANEL:GetCanvas()
    return self.pnlCanvas
end

function PANEL:InnerWidth()
    return self:GetCanvas():GetWide()
end

AccessorFunc(PANEL, "m_scrollbarLeftSide", "ScrollbarLeftSide")

function PANEL:Rebuild()
    self:GetCanvas():SizeToChildren(false, true)

    if self.m_bNoSizing and self:GetCanvas():GetTall() < self:GetTall() then
        self:GetCanvas():SetPos(0, (self:GetTall()-self:GetCanvas():GetTall()) * 0.5)
    end
end

function PANEL:Think()
    if not self.lastThink then self.lastThink = CurTime() end
    local elapsed = CurTime() - self.lastThink
    self.lastThink = CurTime()

    if self.scrollDelta > 0 then
        self.VBar:OnMouseWheeled(self.scrollDelta / 1)

        if self.VBar.Scroll >= 0 then
            self.scrollDelta = self.scrollDelta - 10 * elapsed
        end
        if self.scrollDelta < 0 then self.scrollDelta = 0 end
    elseif self.scrollDelta < 0 then
        self.VBar:OnMouseWheeled(self.scrollDelta / 1)

        if self.VBar.Scroll <= self.VBar.CanvasSize then
            self.scrollDelta = self.scrollDelta + 10 * elapsed
        end
        if self.scrollDelta > 0 then self.scrollDelta = 0 end
    end

    if self.scrollReturnWait >= 1 then
        if self.VBar.Scroll < 0 then
            if self.VBar.Scroll <= -75 and self.scrollDelta > 0 then self.scrollDelta = self.scrollDelta / 2 end

            self.scrollDelta = self.scrollDelta + ((self.VBar.Scroll) / 1500 - 0.01) * 100 * elapsed

        elseif self.VBar.Scroll > self.VBar.CanvasSize then
            if self.VBar.Scroll >= self.VBar.CanvasSize + 75 and self.scrollDelta < 0 then self.scrollDelta = self.scrollDelta / 2 end

            self.scrollDelta = self.scrollDelta + ((self.VBar.Scroll - self.VBar.CanvasSize) / 1500 + 0.01) * 100 * elapsed
        end
    else
        self.scrollReturnWait = self.scrollReturnWait + 10 * elapsed
    end
end

function PANEL:OnMouseWheeled(delta)
    if (delta > 0 and self.VBar.Scroll <= self.VBar.CanvasSize * 0.005) or
            (delta < 0 and self.VBar.Scroll >= self.VBar.CanvasSize * 0.995) then
        self.scrollDelta = self.scrollDelta + delta / 10
        return
    end

    self.scrollDelta = delta / 2
    self.scrollReturnWait = 0
    --return self.VBar:OnMouseWheeled(delta)
end

function PANEL:OnVScroll(iOffset)
    self.pnlCanvas:SetPos(0, iOffset)
end

function PANEL:ScrollToChild(panel)
    self:PerformLayout()

    local x, y = self.pnlCanvas:GetChildPosition(panel)
    local w, h = panel:GetSize()

    y = y + h * 0.5;
    y = y - self:GetTall() * 0.5;

    self.VBar:AnimateTo(y, 0.5, 0, 0.5);
end


function PANEL:PerformLayout()
    if self:GetScrollbarLeftSide() then
        self.VBar:Dock(LEFT)
    else
        self.VBar:Dock(RIGHT)
    end

    local wide = self:GetWide()
    local xPos = 0
    local yPos = 0

    self:Rebuild()

    self.VBar:SetUp(self:GetTall(), self.pnlCanvas:GetTall())
    yPos = self.VBar:GetOffset()

    if self.VBar.Enabled or not self:GetBarDockShouldOffset() then
        wide = wide - self.VBar:GetWide()

        if self:GetScrollbarLeftSide() then
            xPos = self.VBar:GetWide()
        end
    end

    self.pnlCanvas:SetPos(xPos, yPos)
    self.pnlCanvas:SetWide(wide)

    self:Rebuild()
end

function PANEL:Clear()
    return self.pnlCanvas:Clear()
end

function PANEL:Paint(w, h)
end

vgui.Register("Aw.UI.Panel.ScrollAnimated", PANEL, "DPanel")
