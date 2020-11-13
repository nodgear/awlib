
local pnl = {}

AccessorFunc( pnl, "m_paused", "Paused" )
AccessorFunc( pnl, "m_extension", "Extension" )

function pnl:Init()
    self.images = {}
    self.slots = {}
    self:SetPaused( false )
end

function pnl:SetDirectory( dir )
    local files = file.Find( "materials/" .. dir .. "/*", "GAME" ) or {}
    for k, v in pairs( files ) do
        files[k] = tonumber( string.StripExtension( v ) )
    end

    table.sort( files, function( a, b ) return a < b end)

    local new = {}
    local extension = self:GetExtension() or ".png"
    for k, v in pairs( files ) do
        new[k] = Material( dir .. "/" .. v ..  extension, "smooth" )
    end
    	PrintTable(new)
    self.dir = dir
    self.images = new
end

function pnl:SetImages( tbl )
    self.images = tbl
end

function pnl:SetTimes( normal, idle )
    self.times = {
        normal = normal or .02,
        idle = idle or 1
    }
end

function pnl:PostInit()
    self.start_slot = 1
    self.end_slot = #self.images
    
    self.slots = {
        min = 1,
        max = #self.images
    }

    self.cur_image = self.slots.min
    self.next_change = UnPredictedCurTime() + self.times.normal

    self.can_draw = true
end

function pnl:Paint(w, h)
    if !self.can_draw then return end

	if !self.images[self.cur_image] then return end

    surface.SetMaterial( self.images[self.cur_image] )
    surface.SetDrawColor( 255, 255, 255 )
    surface.DrawTexturedRect( 0, 0, w, h )

    if self.next_change < UnPredictedCurTime() and !self:GetPaused() then
        self.cur_image = self.cur_image < self.slots.max and self.cur_image + 1 or self.slots.min
        self.next_change = UnPredictedCurTime() + (self.cur_image < self.slots.max and self.times.normal or self.times.idle)
    end
end

vgui.Register("Aw.UI.Panel.GIF", pnl, "Panel")
