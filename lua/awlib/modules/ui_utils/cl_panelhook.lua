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

	function PNL:DrawGrid( material, pixelGridUnits, textureGridDivisions )
		self.BG = Material(material .. "_fixed")
		local strImage = self.BG:GetName()
	
		if self.BG:IsError() then
			self.BG = CreateMaterial(material .. "_fixed", "VertexLitGeneric", "")
			self.BG:SetTexture("$basetexture", Material(material):GetTexture("$basetexture"))
		end
	
		local Mat = self.BG
	
		if ( string.find( Mat:GetShader(), "VertexLitGeneric" ) || string.find( Mat:GetShader(), "Cable" ) ) then
	
			local t = Mat:GetString( "$basetexture" )
	
			if ( t ) then
	
				local params = {}
				params[ "$basetexture" ] = t
				params[ "$vertexcolor" ] = 1
				params[ "$vertexalpha" ] = 1
	
				Mat = CreateMaterial( strImage .. "_DImage", "UnlitGeneric", params )
	
			end
	
		end
	
		self.BG = Mat


		local size = self:GetSize()
		local texture = self.BG:GetTexture("$basetexture")
		local tw = texture:GetMappingWidth()
		local th = texture:GetMappingHeight()
			
		local scale = (tw/pixelGridUnits) / textureGridDivisions
	
		local u0, v0 = 0,0
		local u1, v1 = (size*2 / tw) * scale, (size*2 / th) * scale
	
		u0 = u0 - (u1 % 1)
		v0 = v0 - (v1 % 1)
	
		local du = 0.5 / tw
		local dv = 0.5 / th
		u0, v0 = ( u0 - du ) / ( 1 - 2 * du ), ( v0 - dv ) / ( 1 - 2 * dv )
		u1, v1 = ( u1 - du ) / ( 1 - 2 * du ), ( v1 - dv ) / ( 1 - 2 * dv )
	
		surface.SetMaterial(self.BG)
		surface.DrawTexturedRectUV( -size, -size, size*2, size*2, u0, v0, u1, v1 )
	
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