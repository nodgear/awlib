-- TODO: Move AwAdmin namespaces to Aw / Aw.UI
Aw.UI = Aw.UI or {}

local pnl = {}
AccessorFunc(pnl, "m_body", "Body")

function pnl:Init()

    Aw.UI:CreateFont("AdminUI.Sidebar.Name", 18, "Montserrat SemiBold")

  self.Scroll = self:Add("Aw.UI.Panel.Scroll")
  self.Scroll:Dock(FILL)
  self.Scroll:DockMargin(16, 16, 16, 16)
  self.Scroll.VBar:SetWide(0)
  self.Text = "Awesome"

  self.Header = self:Add("DPanel")
  self.Header:DockMargin(0, 8, 0, 16)
  self.Header.img = "D3ctB8W"
  self.Header.Alpha = 0
  self.Header.LX = 0
  self.Header.TX = 0
  Aw.UI:DownloadIcon(self.Header, self.Header.img)

  self.Header.Paint = function(s,w,h)
    surface.SetFont("AdminUI.Sidebar.Name")

    local iconsize = s.img and h or 0

    local tw, th = surface.GetTextSize(self.Text)
    local lx = Lerp(s.LX, (self.Wide /2 - iconsize/2), w/2 - iconsize/2 - tw/2 - 2)
    local tx = Lerp(s.LX,  w/2 - tw/2,  w/2 - tw/2 + iconsize/2 + 2)

    Aw.UI:DrawIcon( lx, 0, h, h, self.Header )

    draw.SimpleText(self.Text, "AdminUI.Sidebar.Name", tx, h / 2 + (pnl.SmallFont and 1 or 0), ColorAlpha(color_white, s.Alpha), TEXT_ALIGN_LEFT, desc and TEXT_ALIGN_BOTTOM or TEXT_ALIGN_CENTER, 1, 125)
    -- draw.SimpleText(name, "AdminUI.Sidebar.Name", x, h / 2 + (pnl.SmallFont and 1 or 0), color_white, TEXT_ALIGN_LEFT, desc and TEXT_ALIGN_BOTTOM or TEXT_ALIGN_CENTER, 1, 125)
  end

  self.Sidebar = {}
  self.Panels = {}
  self.LastPos = {}

  self.MouseInbound = false

  self.Wide = 72
  self.MinWide = 72
  self.MaxWide = 0
  self.Expanded = false
end

function pnl:CreateDivider(startCol, endCol)
  startCol = startCol or Color(164, 43, 115)
  endCol = endCol or Color(198, 66, 110)

  local divider = self.Scroll:Add("DPanel")
  divider:Dock(TOP)
  divider:SetTall(10)
  divider.Paint = function(pnl, w, h)
    local aX, aY = pnl:LocalToScreen()
    draw.SimpleLinearGradient(aX + 4, aY + 4, w - 8, h - 8, startCol, endCol, true)
  end
end

function pnl:CreatePanel(name, panelClass, icon, tbl)
  tbl = tbl or {}
  tbl.colors = tbl.colors or {}
  local startCol = tbl.colors[1] or Color(158, 53, 210)
  local endCol = tbl.colors[2] or Color(109, 77, 213)

  local btn = self.Scroll:Add("DButton")
  btn:Dock(TOP)
  btn:DockMargin(0, 8, 0, 8)
  btn.Name = name
  btn.Icon = icon
  btn.Tbl = tbl
  btn.PanelClass = panelClass
  btn:SetTall(tbl.Height or 40)
  btn:SetText("")
  btn.GradientAlpha = 0
  Aw.UI:DownloadIcon(btn, icon)
  btn.Paint = function(pnl, w, h)
    Aw.UI:DrawRoundedBox(AwAdmin.Sizes.br, 0, 0, w, h, ColorAlpha(AwAdmin.Config.ColorAccent, pnl.GradientAlpha) )

    local x = icon and h or 40
    Aw.UI:DrawIcon(8, 8, h - 16, h - 16, pnl)

    draw.SimpleText(name, "AdminUI.Sidebar.Name", x, h / 2 + (pnl.SmallFont and 1 or 0), color_white, TEXT_ALIGN_LEFT, desc and TEXT_ALIGN_BOTTOM or TEXT_ALIGN_CENTER, 1, 125)
  end
  btn.OnCursorEntered = function(pnl)
    if (self.Active == btn.Id) then return end

    pnl:Lerp("GradientAlpha", 127.5)
  end
  btn.OnCursorExited = function(pnl)
    if (self.Active == btn.Id) then return end

    pnl:Lerp("GradientAlpha", 0)
  end
  btn.DoClick = function(pnl)
    self:SetActive(pnl.Id)
  end

  if (!IsValid(self:GetBody())) then
    Error("Failed to find body for panel " .. tostring(panelClass))
  end
  local body = self:GetBody():Add(panelClass or "DPanel")
  if (!IsValid(body)) then
    Error("Failed to create panel for " .. tostring(panelClass))
  end
  body:Dock(FILL)
  body.Data = tbl
  body:SetVisible(false)
  if (body.SetData) then
    body:SetData(tbl)
  end

  local bodyId = table.insert(self.Panels, body)
  self.Panels[bodyId].Id = bodyId

  local id = table.insert(self.Sidebar, btn)
  self.Sidebar[id].Id = id
end

function pnl:SetActive(id)
  local active = self.Active
  self.Active = id

  if (IsValid(self.Sidebar[active])) then
    self.Sidebar[active]:OnCursorExited()

    if (IsValid(self.Panels[active])) then
      self.Panels[active]:SetVisible(false)
    end
  end
  
  if (IsValid(self.Sidebar[id])) then
    self.Sidebar[id]:Lerp("GradientAlpha", 255)

    if (IsValid(self.Panels[id])) then
      if (self.Panels[id].Data.recreateOnSwitch and id != active) then
        local tempData = self.Panels[id].Data
        local tempId = self.Panels[id].Id
        self.Panels[id]:Remove()

        self.Panels[id] = self:GetBody():Add(self.Sidebar[id].PanelClass or "DPanel")
        self.Panels[id]:Dock(FILL)
        self.Panels[id].Data = tempData
        self.Panels[id].Id = tempId
      else
        self.Panels[id]:SetVisible(true)
      end

      if (self.Panels[id].OnSwitchedTo) then
        self.Panels[id]:OnSwitchedTo(self.Panels[id].Data)
      end
    end
  end
end

function pnl:SetActiveByName(name)
  for i, v in ipairs(self.Sidebar) do
    if (v.Name == name) then
      self:SetActive(i)

      break
    end
  end
end

function pnl:PerformLayout(w,h)
  self.MaxWide = self:GetParent():GetWide() * .19

  self.Header:Dock(TOP)
  self.Header:SetTall(38)
end

function pnl:InBound()
    local w, h = self:GetWide(), self:GetTall()
    local px, py = self:LocalToScreen()
    local mx, my = gui.MousePos()
    local tx, ty = math.Clamp(mx - px, -1, w + 1), math.Clamp(my - py, -1, h + 1)
    return  (tx < w and tx >= 0) and (ty < h + 1 and ty >= 0)
end

function pnl:Think()
  local CurrentState = self:InBound()
  self:SetWide(self.Wide)

  if Animating then
    self:GetParent():InvalidateLayout(false)
  end

  if CurrentState ~= self.MouseInbound then
    Animating = true
    self.MouseInbound = CurrentState
    self:Lerp("Wide", CurrentState and self.MaxWide or self.MinWide, .3, function()
      Animating = false
      self.Expanded = self.MaxWide == self.Wide
      self.Header:Lerp("Alpha", self.Expanded and 255 or 0, .2)
      self.Header:Lerp("LX", self.Expanded and 1 or 0, .3)
      self.Header:Lerp("TX", self.Expanded and 1 or 0, .3)
    end)
  end
end

function pnl:Paint(w,h)
  Aw.UI:DrawRoundedBoxEx(6, 0, 0, w, h, AwAdmin.Config.ColorNavbar, true, false, true, false)
end
vgui.Register("Aw.UI.Panel.AnimatedSidebar", pnl)


-- TODO: Move to scrollpanel

local pnl = {}

function pnl:Init()
  self.VBar:SetWide(12)
  self.VBar:SetHideButtons(true)

  self.VBar.Paint = function(pnl, w, h)
    draw.RoundedBox(6, 0, 0, w, h, ColorAlpha(AwAdmin.Config.ColorNavbar, 150))
  end
  self.VBar.btnGrip.Paint = function(pnl, w, h)
    draw.RoundedBox(6, 0, 0, w, h, AwAdmin.Config.ColorAccent)
  end
end

function pnl:HideScrollBar(hide)
	self.VBar:SetWide((hide and 0) or 12)
end

vgui.Register("Aw.UI.Panel.Scroll", pnl, "DScrollPanel")
