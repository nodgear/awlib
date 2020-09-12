--[[
Awesome Lib - Over engineered button
Usage:
    button = self.container:Add("Aw.UI.Panel.Button")
    button:SetText(string) -- Guess what
    button:SetBody(self.container) -- Only needed when using auto size.
    button:SetDisabled(boolean) -- Blocked buttons can't be clicked, and will display a blocked cursor. (optional).
    button:SetBordered(boolean) -- If the buttons should be an outlined button (optional).
    button:SetBorderThickness(number) -- Set the thickness of the border (optional).
    button:SetBackgroundColor(color) -- Set's the background color (optional).
    button:SetBorderColor(color) -- Set's the border color (optional).
    button:SetHoverColor(color) -- Set's color when hovering (optional).
    button:SetShadow(boolean) -- Should draw shadow behind the button? (option).
    button:SetMargin(number) -- Horizontal margin between buttons (optional).
    button:SetRadius(number) -- Corner border radius (optional).
    button:SetMaterialClick(boolean) -- Makes a material like click effect when the button is clicked (optional).
    button:SetMaterialClickColor(color) -- Color of the material click effect (optional).
    button:SetMaterialClickSpeed(number) -- Speed for the material click effect (default 5) (optional).
    button:SetIconURL(string) -- ImgurID: Downloads and draws icon based on this imgur url.
    button:AutoSize(boolean) -- If true, the button will resize itself to fit the container within the other buttons.
    button:Deploy() -- Inject all options to the panel variables (optional).
           ^^^ -- if you're overriding panel Paint(), OnCursorEntered() + OnCursorExited() you don't need to call this.

    -- After creating all buttons from the container, we call BuildButtonSizes (if autosize is enabled)
    Aw.UI:BuildButtonSizes(self.ActionsContainer)
]]--

local pnl = {}

AccessorFunc(pnl, "m_bordered",   "Bordered"          , FORCE_BOOL)
AccessorFunc(pnl, "m_shadow"  ,   "Shadow"            , FORCE_BOOL)
AccessorFunc(pnl, "m_autosize",   "DisableAutoSize"   , FORCE_BOOL)
AccessorFunc(pnl, "m_disabled",   "Disabled"          , FORCE_BOOL)
AccessorFunc(pnl, "m_radius"    , "Radius"            , FORCE_NUMBER)
AccessorFunc(pnl, "m_borderw"   , "BorderThickness"   , FORCE_NUMBER)
AccessorFunc(pnl, "m_reactspeed", "MaterialClickSpeed", FORCE_NUMBER)
AccessorFunc(pnl, "m_margin"    , "Margin"            , FORCE_NUMBER)
AccessorFunc(pnl, "m_iconmargin", "IconMargin"        , FORCE_NUMBER)
AccessorFunc(pnl, "m_background", "BackgroundColor"   )
AccessorFunc(pnl, "m_border"    , "BorderColor"       )
AccessorFunc(pnl, "m_icon"      , "IconURL"           )
AccessorFunc(pnl, "m_hover"     , "HoverColor"        )
AccessorFunc(pnl, "m_body"      , "Body"              )
AccessorFunc(pnl, "m_react"     , "MaterialClick"     )
AccessorFunc(pnl, "m_reactcolor", "MaterialClickColor")

function pnl:Init()
    self.Alpha = 0
    self.TextAlpha = 255
    self.Text = ""
    self.Color = color_black

    Aw.UI:CreateFont("Aw.UI.Font.Button", 18, "Montserrat SemiBold")
end

function pnl:Paint(w,h)
    if self.Bordered then
        Aw.UI:MaskInverse(function()
            Aw.UI:DrawRoundedBox(self.Radius, self.Border, self.Border, w - ( self.Border * 2 ), h - ( self.Border * 2 ), color_white, true, true, true, true)
        end,function()
            draw.RoundedBox(self.Radius, 0, 0, w, h, self.Color)
        end)
    else
        draw.RoundedBox(self.Radius, 0, 0, w, h, self.Color)
    end

    draw.RoundedBox(self.Radius, 0, 0, w, h, ColorAlpha(self.Color, self.Alpha) )

    if self.mAlpha >=1 and self:GetMaterialClick() then
        Aw.UI:Mask(function()
            Aw.UI:DrawRoundedBox(self.Radius, 0, 0, w, h, color_white, true, true, true, true)
        end,function()
            surface.SetDrawColor( ColorAlpha( self.ReactColor, self.mAlpha ) )
            draw.NoTexture()
            Aw.UI:SimpleCircle(self.mX, self.mY, self.mRad)
            self.mRad = Lerp( RealFrameTime() * self.mSpeed, self.mRad,  w)
            self.mAlpha = Lerp( RealFrameTime() * self.mSpeed, self.mAlpha, 0)
        end)
    end
    if self.Icon then
        surface.SetFont("Aw.UI.Font.Button")
        local tw, th = surface.GetTextSize(self.Text)
        local iw, ih = 0, 0
        local iconsize = 16

        Aw.UI:DrawIcon(w/2 - iconsize/2 - tw/2 - self.IconMargin, h/2 - iconsize/2, iconsize, iconsize, self, ColorAlpha(color_white, self.TextAlpha))

        draw.SimpleText(self.Text, "Aw.UI.Font.Button", w/2 - tw/2 + iconsize/2 + self.IconMargin, h/2, ColorAlpha(color_white, self.TextAlpha), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    else
        draw.SimpleText(self.Text, "Aw.UI.Font.Button", w/2, h/2, ColorAlpha(color_white, self.TextAlpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end

function pnl:SetText(sText)
    self.Text = sText

end

function pnl:Deploy()
    self.Bordered                            = self:GetBordered() or false
    self.Background                          = self:GetBackgroundColor() or AwAdmin.Config.ColorNavbar
    self.Hover                               = self:GetHoverColor() or AwAdmin.Config.ColorAccent
    self.Disabled                            = self:GetDisabled() or false
    self.Shadow                              = self:GetShadow() or false
    self.Icon                                = self:GetIconURL() or false
    self.Border                              = self:GetBorderThickness() or 1
    self.Radius                              = self:GetRadius() or 6
    self.AutoSize                            = self:GetDisableAutoSize() or false
    self.ReactColor                          = self:GetMaterialClickColor() or color_white
    self.Body                                = self:GetBody() or self:GetParent()
    self.Margin                              = self:GetMargin() or 0
    self.IconMargin                          = self:GetIconMargin() or 8
    self.Body.Buttons                        = self.Body.Buttons or {}
    self.Body.Buttons[#self.Body.Buttons +1] = self
    self.mRad, self.mAlpha, self.mX, self.mY = 0, 0, 0, 0
    self.mSpeed                              = self:GetMaterialClickSpeed() or 5
    self:SetZPos(#self.Body.Buttons)

    if self.Icon then Aw.UI:DownloadIcon(self, self.Icon) end
    self.Color = self.Background -- yes, that's exactly what you're reading
end

function pnl:OnCursorEntered()
    self:SetCursor(self:GetDisabled() and "no" or "hand")
    if self:GetDisabled() then return end
    self:LerpColor("Color", self.Hover, .4)
    self:Lerp("Alpha", 255)
    self:Lerp("TextAlpha", 255)

end

function pnl:OnCursorExited()
    self:LerpColor("Color", self.Background, .4)
    self:Lerp("Alpha", 0)
    self:Lerp("TextAlpha", 255)
end

function pnl:DoClick()
    -- for override!
end

function pnl:DoRightClick()
    -- for override!
end

function pnl:DoMiddleClick()
    -- for override!
end

function pnl:DoStartDrag()
    -- for override!
end

function pnl:DoStopDrag()
    -- for override!
end

function pnl:DoScrollUp()
    -- for override!
end

function pnl:DoScrollDown()
    -- for override!
end

function pnl:OnMousePressed(sKey)
    if self:GetDisabled() then
        return
    end

    if sKey == MOUSE_LEFT then
        if self:GetMaterialClick() then
            self.mX, self.mY = self:CursorPos()
            self.mRad = 0
            self.mAlpha = 255
        end
        self.DoClick()
    elseif sKey == MOUSE_RIGHT then
        self.DoRightClick()
    elseif sKey == MOUSE_MIDDLE then
        self.DoMiddleClick()
    elseif sKey == MOUSE_WHEEL_UP then
        self.DoScrollUp()
    elseif sKey == MOUSE_WHEEL_DOWN then
        self.DoScrollDown()
    end
end

vgui.Register("Aw.UI.Panel.Button", pnl, "EditablePanel")
