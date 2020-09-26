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

-- Module: UI Essentials
-- Author:
--      Xenin Team
--      Nodge
--      Bo Anderson

function Aw.UI:CreateFont(sName, iSize, sFont, iWeight, tMerge)
    local tbl = {
		font = sFont or "Montserrat Regular",
		size = (iSize + 2) or 16,
		weight = iWeight or 500,
		extended = true
	}

	if (tMerge) then
		table.Merge(tbl, tMerge)
	end

	surface.CreateFont(sName, tbl)
end


--- Draw a poly arc
-- @number x xPos
-- @number y yPos
-- @number p InitialPoint
-- @number rad Radius
-- @color color Color
-- @number seg Segments (points)
-- @realm client
function Aw.UI:DrawArc(x, y, ang, p, rad, color, seg)
	seg = seg or 80
	ang = (-ang) + 180
	local circle = {}

	table.insert(circle, {x = x, y = y})
	for i = 0, seg do
		local a = math.rad((i / seg) * -p + ang)
		table.insert(circle, {x = x + math.sin(a) * rad, y = y + math.cos(a) * rad})
	end

	surface.SetDrawColor(color)
	draw.NoTexture()
	surface.DrawPoly(circle)
end

--- Returns a table with a poly arc for later cache
-- @number x xPos
-- @number y yPos
-- @number p InitialPoint
-- @number rad Radius
-- @color color Color
-- @number seg Segments (points)
-- @realm client
-- @treturn table circle
function Aw.UI:CalculateArc(x, y, ang, p, rad, seg)
	seg = seg or 80
	ang = (-ang) + 180
	local circle = {}

	table.insert(circle, {x = x, y = y})
	for i = 0, seg do
		local a = math.rad((i / seg) * -p + ang)
		table.insert(circle, {x = x + math.sin(a) * rad, y = y + math.cos(a) * rad})
	end

	return circle
end

--- Draws a previously cached arc
-- @string Variable with the circle table
-- @color color Color
-- @realm client
function Aw.UI:DrawCachedArc(circle, color)
	surface.SetDrawColor(color)
	draw.NoTexture()
	surface.DrawPoly(circle)
end

function Aw.UI:DrawShadowText(text, font, x, y, col, xAlign, yAlign, amt, shadow)
    for i = 1, amt do
      draw.SimpleText(text, font, x + i, y + i, Color(0, 0, 0, i * (shadow or 50)), xAlign, yAlign)
    end
  
    draw.SimpleText(text, font, x, y, col, xAlign, yAlign)
end

function Aw.UI:DrawRoundedBoxEx(radius, x, y, w, h, col, tl, tr, bl, br)
	--Validate input
	x = math.floor(x)
	y = math.floor(y)
	w = math.floor(w)
	h = math.floor(h)
	radius = math.Clamp(math.floor(radius), 0, math.min(h/2, w/2))

	if (radius == 0) then
		surface.SetDrawColor(col)
		surface.DrawRect(x, y, w, h)

		return
	end

	--Draw all rects required
	surface.SetDrawColor(col)
	surface.DrawRect(x+radius, y, w-radius*2, radius)
	surface.DrawRect(x, y+radius, w, h-radius*2)
	surface.DrawRect(x+radius, y+h-radius, w-radius*2, radius)

	--Draw the four corner arcs
	if(tl) then
		Aw.UI:DrawArc(x+radius, y+radius, 270, 90, radius, col, radius)
	else
		surface.SetDrawColor(col)
		surface.DrawRect(x, y, radius, radius)
	end

	if(tr) then
		Aw.UI:DrawArc(x+w-radius, y+radius, 0, 90, radius, col, radius)
	else
		surface.SetDrawColor(col)
		surface.DrawRect(x+w-radius, y, radius, radius)
	end

	if(bl) then
		Aw.UI:DrawArc(x+radius, y+h-radius, 180, 90, radius, col, radius)
	else
		surface.SetDrawColor(col)
		surface.DrawRect(x, y+h-radius, radius, radius)
	end

	if(br) then
		Aw.UI:DrawArc(x+w-radius, y+h-radius, 90, 90, radius, col, radius)
	else
		surface.SetDrawColor(col)
		surface.DrawRect(x+w-radius, y+h-radius, radius, radius)
	end
end

function Aw.UI:DrawRoundedBox(radius, x, y, w, h, col)
	Aw.UI:DrawRoundedBoxEx(radius, x, y, w, h, col, true, true, true, true)
end

local matLoading = Material("xenin/loading.png", "smooth")

function Aw.UI:DrawLoadingCircle(x, y, size, col)
  surface.SetMaterial(matLoading)
  surface.SetDrawColor(col or ColorAlpha(color_white, 100))
  Aw.UI:DrawRotatedTexture(x, y, size, size, ((ct or CurTime()) % 360) * -100)
end

function Aw.UI:DrawRotatedTexture( x, y, w, h, angle, cx, cy )
	cx,cy = cx or w/2,cy or w/2
	if( cx == w/2 and cy == w/2 ) then
		surface.DrawTexturedRectRotated( x, y, w, h, angle )
	else	
		local vec = Vector( w/2-cx, cy-h/2, 0 )
		vec:Rotate( Angle(180, angle, -180) )
		surface.DrawTexturedRectRotated( x-vec.x, y+vec.y, w, h, angle )
	end
end



local mat_white = Material("vgui/white")

function draw.SimpleLinearGradient(x, y, w, h, startColor, endColor, horizontal)
	draw.LinearGradient(x, y, w, h, { {offset = 0, color = startColor}, {offset = 1, color = endColor} }, horizontal)
end

function draw.LinearGradient(x, y, w, h, stops, horizontal)
	if #stops == 0 then
		return
	elseif #stops == 1 then
		surface.SetDrawColor(stops[1].color)
		surface.DrawRect(x, y, w, h)
		return
	end

	table.SortByMember(stops, "offset", true)

	render.SetMaterial(mat_white)
	mesh.Begin(MATERIAL_QUADS, #stops - 1)
	for i = 1, #stops - 1 do
		local offset1 = math.Clamp(stops[i].offset, 0, 1)
		local offset2 = math.Clamp(stops[i + 1].offset, 0, 1)
		if offset1 == offset2 then continue end

		local deltaX1, deltaY1, deltaX2, deltaY2

		local color1 = stops[i].color
		local color2 = stops[i + 1].color

		local r1, g1, b1, a1 = color1.r, color1.g, color1.b, color1.a
		local r2, g2, b2, a2
		local r3, g3, b3, a3 = color2.r, color2.g, color2.b, color2.a
		local r4, g4, b4, a4

		if horizontal then
			r2, g2, b2, a2 = r3, g3, b3, a3
			r4, g4, b4, a4 = r1, g1, b1, a1
			deltaX1 = offset1 * w
			deltaY1 = 0
			deltaX2 = offset2 * w
			deltaY2 = h
		else
			r2, g2, b2, a2 = r1, g1, b1, a1
			r4, g4, b4, a4 = r3, g3, b3, a3
			deltaX1 = 0
			deltaY1 = offset1 * h
			deltaX2 = w
			deltaY2 = offset2 * h
		end

		mesh.Color(r1, g1, b1, a1)
		mesh.Position(Vector(x + deltaX1, y + deltaY1))
		mesh.AdvanceVertex()

		mesh.Color(r2, g2, b2, a2)
		mesh.Position(Vector(x + deltaX2, y + deltaY1))
		mesh.AdvanceVertex()

		mesh.Color(r3, g3, b3, a3)
		mesh.Position(Vector(x + deltaX2, y + deltaY2))
		mesh.AdvanceVertex()

		mesh.Color(r4, g4, b4, a4)
		mesh.Position(Vector(x + deltaX1, y + deltaY2))
		mesh.AdvanceVertex()
	end
	mesh.End()
end


function Aw.UI:BuildButtonSizes(pnl)
    local TotalButtons = #pnl.Buttons
    for _, button in pairs(pnl.Buttons) do
        if !button:GetDisableAutoSize() then
            button:Dock(LEFT)
        end
        button.PerformLayout = function(s,w,h)
            local totalmargin = (s:GetMargin() * (TotalButtons-1) )

            if !s:GetDisableAutoSize() then
                if pnl.Buttons[TotalButtons] == s then
                    s:DockMargin( s.Margin / 2, 0, 0, 0 )
                    s:SetWide(s.Body:GetWide() / TotalButtons - s.Margin/2)
                elseif pnl.Buttons[1] == s then
                    s:DockMargin( 0, 0, s.Margin / 2, 0 )
                    s:SetWide(s.Body:GetWide() / TotalButtons - s.Margin/2)
                else
                    s:DockMargin( s.Margin / 2, 0, s.Margin / 2, 0 )
                    s:SetWide(s.Body:GetWide() / TotalButtons - s.Margin)
                end
            end
        end
    end
end

function Aw.UI:Ease(t, b, c, d)
	t = t / d
	local ts = t * t
	local tc = ts * t

	--return b + c * ts
	return b + c * (-2 * tc + 3 * ts)
end

function Aw.UI:EaseInOutQuintic(t, b, c, d)
	t = t / d
	local ts = t * t
	local tc = ts * t

	--return b + c * ts
	return b + c * (6 * tc * ts + -15 * ts * ts + 10 * tc)
end

function Aw.UI:LerpColor(fract, from, to)
	return Color(
		Lerp(fract, from.r, to.r),
		Lerp(fract, from.g, to.g),
		Lerp(fract, from.b, to.b),
		Lerp(fract, from.a or 255, to.a or 255)
	)
end