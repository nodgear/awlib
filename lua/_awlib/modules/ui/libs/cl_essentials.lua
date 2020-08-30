function AwUI:CreateFont(sName, iSize, sFont, iWeight, tMerge)
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
function AwUI:DrawArc(x, y, ang, p, rad, color, seg)
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
function AwUI:CalculateArc(x, y, ang, p, rad, seg)
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
function AwUI:DrawCachedArc(circle, color)
	surface.SetDrawColor(color)
	draw.NoTexture()
	surface.DrawPoly(circle)
end

function AwUI:DrawShadowText(text, font, x, y, col, xAlign, yAlign, amt, shadow)
    for i = 1, amt do
      draw.SimpleText(text, font, x + i, y + i, Color(0, 0, 0, i * (shadow or 50)), xAlign, yAlign)
    end
  
    draw.SimpleText(text, font, x, y, col, xAlign, yAlign)
end

function AwUI:DrawRoundedBoxEx(radius, x, y, w, h, col, tl, tr, bl, br)
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
		AwUI:DrawArc(x+radius, y+radius, 270, 90, radius, col, radius)
	else
		surface.SetDrawColor(col)
		surface.DrawRect(x, y, radius, radius)
	end

	if(tr) then
		AwUI:DrawArc(x+w-radius, y+radius, 0, 90, radius, col, radius)
	else
		surface.SetDrawColor(col)
		surface.DrawRect(x+w-radius, y, radius, radius)
	end

	if(bl) then
		AwUI:DrawArc(x+radius, y+h-radius, 180, 90, radius, col, radius)
	else
		surface.SetDrawColor(col)
		surface.DrawRect(x, y+h-radius, radius, radius)
	end

	if(br) then
		AwUI:DrawArc(x+w-radius, y+h-radius, 90, 90, radius, col, radius)
	else
		surface.SetDrawColor(col)
		surface.DrawRect(x+w-radius, y+h-radius, radius, radius)
	end
end

function AwUI:DrawRoundedBox(radius, x, y, w, h, col)
	AwUI:DrawRoundedBoxEx(radius, x, y, w, h, col, true, true, true, true)
end

local matLoading = Material("xenin/loading.png", "smooth")

function AwUI:DrawLoadingCircle(x, y, size, col)
  surface.SetMaterial(matLoading)
  surface.SetDrawColor(col or ColorAlpha(XeninUI.Theme.Accent, 100))
  AwUI:DrawRotatedTexture(x, y, size, size, ((ct or CurTime()) % 360) * -100)
end

function AwUI:DrawRotatedTexture( x, y, w, h, angle, cx, cy )
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