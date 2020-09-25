-- if !Aw.UI.__AddedPanelFunctions then
	local PNL = FindMetaTable("Panel")
	local Old_Remove = Old_Remove or PNL.Remove

	function PNL:Stack(identifier)
		Aw.UI.PanelStack = Aw.UI.PanelStack or {}
		Aw.UI.PanelStack[identifier] = self

		self.StackID = identifier
		self.StackNumber = table.Count(Aw.UI.PanelStack)
	end

	function PNL:GetStack(w,h,m)
		if !self.StackID then return end
		return self.StackNumber, self.StackNumber * w + m * self.StackNumber, self.StackNumber * h + m * self.StackNumber -- this will return the stack number,
	end

	function PNL:RemoveStack()
		if !self.StackID then return end
		Aw.UI.PanelStack[self.StackID] = nil
		hook.Run("StackValueChange", self.StackNumber)
	end

	function PNL:InBound()
		local w, h = self:GetWide(), self:GetTall()
		local px, py = self:LocalToScreen()
		local mx, my = gui.MousePos()
		local tx, ty = math.Clamp(mx - px, -1, w + 1), math.Clamp(my - py, -1, h + 1)
		return  (tx < w and tx >= 0) and (ty < h + 1 and ty >= 0)
	end

	function PNL:Remove()
		for k, v in pairs( self.hooks or {} ) do
			hook.Remove( v.name, k )
		end

		for k, v in pairs( self.timers or {} ) do
			timer.Remove( k )
		end

		if self.StackID then
			self:RemoveStack()
		end

		Old_Remove( self )
	end

	function PNL:AddHook( name, identifier, func )
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

	function PNL:GetHooks()
		return self.hooks or {}
	end

	function PNL:AddTimer( identifier, delay, rep, func )
		self.timers = self.timers or {}
		self.timers[identifier] = true

		timer.Create( identifier, delay, rep, function( ... )
			if IsValid( self ) then
				func( self, ... )
			end
		end )
	end

	function PNL:GetTimers()
		return self.timers or {}
	end

	function PNL:LerpAlpha(alpha, time, callback)
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

-- 	Aw.UI.__AddedPanelFunctions = true
-- end