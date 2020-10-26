--- @module Utils.Cam
-- Provides interface for camera lerp and animation.

AW = AW or {}
AW.Cam = AW.Cam or {}
AW.Cam.tCamVars = {}

function AW.Cam:Running()
	return (self.tCamVars.Done or self.tCamVars.StartTime) and true or false
end

--- Clear Camera
-- stops any camera animation, without advice.
-- @bool bSamePath Wether should the camera return the same path before beeing removed.
-- @number iTime Total time to return
-- @realm client
function AW.Cam:ClearCamera( bSamePath, iTime)

	if bSamePath and iTime then
		AW.Cam:JumpFromTo( self.tCamVars.To.pos, self.tCamVars.To.ang, self.tCamVars.Current.fov, LocalPlayer():EyePos(), LocalPlayer():EyeAngles(), LocalPlayer():GetFOV(), iTime, function()
			timer.Simple(.1, function()
				AW.Cam:ClearCamera()
			end)
		end)
	else
		self.tCamVars = {}
	end

end

--- Changes the lib CalcView table
-- @internal
-- @player pPlayer LocalPlayer
-- @vector vecOrigin Origin Vectors
-- @angle angAngs Origin angles
-- @number intFOV FOV
-- @realm client
function AW.Cam:CalcView( pPlayer, vecOrigin, angAngs, intFOV )
	if not self.tCamVars.StartTime then return end

	return {
		origin = self.tCamVars.Current.pos,
		angles = self.tCamVars.Current.ang,
		fov = self.tCamVars.Current.fov,
		drawviewer = self.tCamVars.DrawModel
	}
end

--- Jiggles the given vectors with the specified value threshould.
-- @internal
-- @vector v
-- @number max
local function jiggle(v, max)
	local v = Angle( (math.sin(RealTime() / 2))*max, (math.sin(RealTime() /2 ))*max*10, (math.sin(RealTime() /2))*max*10 )
	return v
end

local rx = Angle(0,0,0)

function AW.Cam:Think()
	if not self.tCamVars.StartTime then return end

	if RealTime() >= self.tCamVars.StartTime +self.tCamVars.Length then
		self.tCamVars.Done = true

		if self.tCamVars.Callback and not self.tCamVars.DoneCallback then
			self.tCamVars.DoneCallback = true
			self.tCamVars.Callback()
		end
	end

	local frac = (RealTime() - self.tCamVars.StartTime) /self.tCamVars.Length

	local vecTo = self.tCamVars.To.pos
	local angTo = self.tCamVars.To.ang
	if IsValid( self.tCamVars.Follow ) then
		-- vecTo = self.tCamVars.Follow:LocalToWorld( vecTo )
		-- angTo = self.tCamVars.Follow:LocalToWorldAngles( angTo )
	end
	frac = math.Clamp( frac, 0, 1 )

	if self.tCamVars.Jiggle then
		rx = jiggle( rx, self.tCamVars.JiggleMax )
		self.tCamVars.Current.ang = LerpAngle( frac, self.tCamVars.From.ang, angTo ) + rx
	else
		self.tCamVars.Current.ang = LerpAngle( frac, self.tCamVars.From.ang, angTo )
	end
	self.tCamVars.Current.pos = LerpVector( frac, self.tCamVars.From.pos, vecTo )
	self.tCamVars.Current.fov = Lerp( frac, self.tCamVars.From.fov, self.tCamVars.To.fov )
end



--- Make the camera animate from one position to another in the time given.
-- @vector vFrom Initial position (localplayer position mostly)
-- @angle aFrom Angle from (same thing)
-- @number intFovFrom FOV, usually needed when dealing with panels + camera
-- @vector  vTo Final position
-- @angle aTo Final angle
-- @number intFOVTo Final fov
-- @number intLen Duration of the camera travel
-- @func funcCallback Function callback after the camera is done travelling.
-- @bool bViewModel If true, the player will be able to see himself
-- @bool bJiggle if true, the camera will have a jiggle effect.
-- @number xJiggleMax Max ammount of jiggleness.
-- @realm client


function AW.Cam:JumpFromTo( vFrom, aFrom, intFovFrom, vTo, aTo, intFOVTo, intLen, funcCallback, bViewModel, bJiggle, xJiggleMax )
	self:ClearCamera()

	self.tCamVars = {
		From = { pos = vFrom, ang = aFrom, fov = intFovFrom },
		To = { pos = vTo, ang = aTo, fov = intFOVTo },
		Current = { pos = vFrom, ang = aFrom, fov = intFovFrom },

		Callback = funcCallback,
		Length = intLen,
		StartTime = RealTime(),
		DrawModel = bViewModel and true or false,
		Jiggle = bJiggle or false,
		JiggleMax = bJiggle and xJiggleMax or 0

	}
end

--- Make the camera animate from one position to another in the time given.<br>
-- After that, follows the specified entity.
-- @entity entFollow Entity to be followed
-- @vector vFrom Initial position (localplayer position mostly)
-- @angle aFrom Angle from (same thing)
-- @number intFovFrom FOV, usually needed when dealing with panels + camera
-- @vector vTo Final position
-- @angle aTo Final angle
-- @number intFOVTo Final fov
-- @number intLen Duration of the camera travel
-- @func funcCallback Function callback after the camera is done travelling.
-- @bool bViewModel If true, the player will be able to see himself
-- @bool bJiggle If true, the camera will jiggle, simulating a handheld camera.
-- @realm client
function AW.Cam:JumpFromToFollow( entFollow, vFrom, aFrom, intFovFrom, vTo, aTo, intFOVTo, intLen, funcCallback, bViewModel, bJiggle)
	self:ClearCamera()

	self.tCamVars = {
		From = { pos = vFrom, ang = aFrom, fov = intFovFrom },
		To = { pos = vTo, ang = aTo, fov = intFOVTo },
		Current = { pos = vFrom, ang = aFrom, fov = intFovFrom },

		Callback = funcCallback,
		Length = intLen,
		StartTime = RealTime(),
		Follow = entFollow,
		DrawModel = bViewModel and true or false,
		Jiggle = bJiggle or false,
		JiggleMax = bJiggle and xJiggleMax or 0
	}
end

hook.Add("Think", "AW.Think", function()
	AW.Cam:Think()
end)

hook.Add("CalcView", "SERERNITY.Cam.CalcView", function()
	if AW.Cam:Running() then
		return AW.Cam:CalcView( pPlayer, vecOrigin, angAngs, intFOV )
	end
end)
