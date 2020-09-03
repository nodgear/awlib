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

-- Module: Animation helper
-- Author:
--      Xenin Team

local pnl = FindMetaTable("Panel")

function pnl:LerpColor(var, to, duration, callback)
	if (!duration) then duration = Aw.UI.TransitionTime end

	local color = self[var]
	local anim = self:NewAnimation(duration)
	anim.Color = to
	anim.Think = function(anim, pnl, fract)
		local newFract = Aw.UI:Ease(fract, 0, 1, 1)

		if (!anim.StartColor) then
			anim.StartColor = color
		end

		local newColor = Aw.UI:LerpColor(newFract, anim.StartColor, anim.Color)
		self[var] = newColor
	end
	anim.OnEnd = function()
		if (callback) then
			callback(self)
		end
	end
end

function pnl:LerpVector(var, to, duration, callback)
	if (!duration) then duration = Aw.UI.TransitionTime end

	local vector = self[var]
	local anim = self:NewAnimation(duration)
	anim.Vector = to
	anim.Think = function(anim, pnl, fract)
		local newFract = Aw.UI:Ease(fract, 0, 1, 1)

		if (!anim.StartVector) then
			anim.StartVector = vector
		end

		local newColor = Aw.UI:LerpVector(newFract, anim.StartVector, anim.Vector)
		self[var] = newColor
	end
	anim.OnEnd = function()
		if (callback) then
			callback(self)
		end
	end
end

function pnl:LerpAngle(var, to, duration, callback)
	if (!duration) then duration = Aw.UI.TransitionTime end

	local angle = self[var]
	local anim = self:NewAnimation(duration)
	anim.Angle = to
	anim.Think = function(anim, pnl, fract)
		local newFract = Aw.UI:Ease(fract, 0, 1, 1)

		if (!anim.StartAngle) then
			anim.StartAngle = angle
		end

		local newColor = Aw.UI:LerpAngle(newFract, anim.StartAngle, anim.Angle)
		self[var] = newColor
	end
	anim.OnEnd = function()
		if (callback) then
			callback(self)
		end
	end
end

function pnl:EndAnimations()
	for i, v in pairs(self.m_AnimList or {}) do
		if (v.OnEnd) then v:OnEnd(self) end
		self.m_AnimList[i] = nil
	end
end

function pnl:Lerp(var, to, duration, callback)
	if (!duration) then duration = Aw.UI.TransitionTime end

	local varStart = self[var]
	local anim = self:NewAnimation(duration)
	anim.Goal = to
	anim.Think = function(anim, pnl, fract)
		local newFract = Aw.UI:Ease(fract, 0, 1, 1)

		if (!anim.Start) then
			anim.Start = varStart
		end

		local new = Lerp(newFract, anim.Start, anim.Goal)
		self[var] = new
	end
	anim.OnEnd = function()
		if (callback) then
			callback(self)
		end
	end
end

function pnl:LerpMove(x, y, duration, callback)
	if (!duration) then duration = Aw.UI.TransitionTime end

	local anim = self:NewAnimation(duration)
	anim.Pos = Vector(x, y)
	anim.Think = function(anim, pnl, fract)
		local newFract = Aw.UI:Ease(fract, 0, 1, 1)

		if (!anim.StartPos) then
			anim.StartPos = Vector(pnl.x, pnl.y, 0)
		end

		local new = LerpVector(newFract, anim.StartPos, anim.Pos)
		self:SetPos(new.x, new.y)
	end
	anim.OnEnd = function()
		if (callback) then
			callback(self)
		end
	end
end

function pnl:LerpMoveY(y, duration, callback)
	if (!duration) then duration = Aw.UI.TransitionTime end

	local anim = self:NewAnimation(duration)
	anim.Pos = y
	anim.Think = function(anim, pnl, fract)
		local newFract = Aw.UI:Ease(fract, 0, 1, 1)

		if (!anim.StartPos) then
			anim.StartPos = pnl.y
		end

		local new = Lerp(newFract, anim.StartPos, anim.Pos)
		self:SetPos(pnl.x, new)
	end
	anim.OnEnd = function()
		if (callback) then
			callback(self)
		end
	end
end

function pnl:LerpMoveX(x, duration, callback)
	if (!duration) then duration = Aw.UI.TransitionTime end

	local anim = self:NewAnimation(duration)
	anim.Pos = x
	anim.Think = function(anim, pnl, fract)
		local newFract = Aw.UI:Ease(fract, 0, 1, 1)

		if (!anim.StartPos) then
			anim.StartPos = pnl.x
		end

		local new = Lerp(newFract, anim.StartPos, anim.Pos)
		self:SetPos(new, pnl.y)
	end
	anim.OnEnd = function()
		if (callback) then
			callback(self)
		end
	end
end

function pnl:LerpHeight(height, duration, callback, easeFunc)
	if (!duration) then duration = Aw.UI.TransitionTime end
	if (!easeFunc) then easeFunc = function(a, b, c, d) return Aw.UI:Ease(a, b, c, d) end end

	local anim = self:NewAnimation(duration)
	anim.Height = height
	anim.Think = function(anim, pnl, fract)
		local newFract = easeFunc(fract, 0, 1, 1)

		if (!anim.StartHeight) then
			anim.StartHeight = pnl:GetTall()
		end

		local new = Lerp(newFract, anim.StartHeight, anim.Height)
		self:SetTall(new)
	end
	anim.OnEnd = function()
		if (callback) then
			callback(self)
		end
	end
end

function pnl:LerpWidth(width, duration, callback, easeFunc)
	if (!duration) then duration = Aw.UI.TransitionTime end
	if (!easeFunc) then easeFunc = function(a, b, c, d) return Aw.UI:Ease(a, b, c, d) end end

	local anim = self:NewAnimation(duration)
	anim.Width = width
	anim.Think = function(anim, pnl, fract)
		local newFract = easeFunc(fract, 0, 1, 1)

		if (!anim.StartWidth) then
			anim.StartWidth = pnl:GetWide()
		end

		local new = Lerp(newFract, anim.StartWidth, anim.Width)
		self:SetWide(new)
	end
	anim.OnEnd = function()
		if (callback) then
			callback(self)
		end
	end
end

function pnl:LerpSize(w, h, duration, callback)
	if (!duration) then duration = Aw.UI.TransitionTime end

	local anim = self:NewAnimation(duration)
	anim.Size = Vector(w, h)
	anim.Think = function(anim, pnl, fract)
		local newFract = Aw.UI:Ease(fract, 0, 1, 1)

		if (!anim.StartSize) then
			anim.StartSize = Vector(pnl:GetWide(), pnl:GetWide(), 0)
		end

		local new = LerpVector(newFract, anim.StartSize, anim.Size)
		self:SetSize(new.x, new.y)
	end
	anim.OnEnd = function()
		if (callback) then
			callback()
		end
	end
end

if !Aw.UI.__AddedPanelFunctions then
	local pnl = FindMetaTable("Panel")
	local Old_Remove = Old_Remove or pnl.Remove

	function pnl:Remove()
		for k, v in pairs( self.hooks or {} ) do
			hook.Remove( v.name, k )
		end

		for k, v in pairs( self.timers or {} ) do
			timer.Remove( k )
		end

		Old_Remove( self )
	end

	function pnl:AddHook( name, identifier, func )
		identifier = identifier .. " - " .. CurTime()

		self.hooks = self.hooks or {}
		self.hooks[identifier] = {
			name = name,
			func = function( ... )
				if IsValid( self ) then
					return func( self, ... )
				end
			end
		}

		hook.Add( name, identifier, self.hooks[identifier].func)
	end

	function pnl:GetHooks()
		return self.hooks or {}
	end

	function pnl:AddTimer( identifier, delay, rep, func )
		self.timers = self.timers or {}
		self.timers[identifier] = true

		timer.Create( identifier, delay, rep, function( ... )
			if IsValid( self ) then
				func( self, ... )
			end
		end )
	end

	function pnl:GetTimers()
		return self.timers or {}
	end

	function pnl:LerpAlpha(alpha, time, callback)
		callback = callback or function() end

		self.Alpha = self.Alpha or 0

		local oldThink = self.Think
		self.Think = function(pnl)
			if (oldThink) then oldThink(pnl) end

			-- Shitty workaround
			self:SetAlpha(pnl.Alpha >= 250 and 255 or pnl.Alpha)
		end
		self:Lerp("Alpha", alpha, time, function()
			self.Think = oldThink
			callback(self)
		end)
	end

	Aw.UI.__AddedPanelFunctions = true
end

