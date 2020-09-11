
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

local scrW, scrH = ScrW(), ScrH()

local function Load()
	BSHADOWS = {}

	local resStr = scrW .. "" .. scrH
	--The original drawing layer
	BSHADOWS.RenderTarget = GetRenderTarget("bshadows_original_" .. resStr, scrW, scrH)

	--The shadow layer
	BSHADOWS.RenderTarget2 = GetRenderTarget("bshadows_shadow_" .. resStr,  scrW, scrH)

	--The matarial to draw the render targets on
	BSHADOWS.ShadowMaterial = CreateMaterial("bshadows","UnlitGeneric",{
		["$translucent"] = 1,
		["$vertexalpha"] = 1,
		["alpha"] = 1
	})

	--When we copy the rendertarget it retains color, using this allows up to force any drawing to be black
	--Then we can blur it to create the shadow effect
	BSHADOWS.ShadowMaterialGrayscale = CreateMaterial("bshadows_grayscale","UnlitGeneric",{
		["$translucent"] = 1,
		["$vertexalpha"] = 1,
		["$alpha"] = 1,
		["$color"] = "0 0 0",
		["$color2"] = "0 0 0"
	})

	--Call this to begin drawing a shadow
	BSHADOWS.BeginShadow = function()

		--Set the render target so all draw calls draw onto the render target instead of the screen
		render.PushRenderTarget(BSHADOWS.RenderTarget)

		--Clear is so that theres no color or alpha
		render.OverrideAlphaWriteEnable(true, true)
		render.Clear(0,0,0,0)
		render.OverrideAlphaWriteEnable(false, false)

		--Start Cam2D as where drawing on a flat surface 
		cam.Start2D()

		--Now leave the rest to the user to draw onto the surface
	end

	--This will draw the shadow, and mirror any other draw calls the happened during drawing the shadow
	BSHADOWS.EndShadow = function(intensity, spread, blur, opacity, direction, distance, _shadowOnly)

		--Set default opcaity
		opacity = opacity or 255
		direction = direction or 0
		distance = distance or 0
		_shadowOnly = _shadowOnly or false

		--Copy this render target to the other
		render.CopyRenderTargetToTexture(BSHADOWS.RenderTarget2)

		--Blur the second render target
		if blur > 0 then
			render.OverrideAlphaWriteEnable(true, true)
			render.BlurRenderTarget(BSHADOWS.RenderTarget2, spread, spread, blur)
			render.OverrideAlphaWriteEnable(false, false) 
		end

		--First remove the render target that the user drew
		render.PopRenderTarget()

		--Now update the material to what was drawn
		BSHADOWS.ShadowMaterial:SetTexture('$basetexture', BSHADOWS.RenderTarget)

		--Now update the material to the shadow render target
		BSHADOWS.ShadowMaterialGrayscale:SetTexture('$basetexture', BSHADOWS.RenderTarget2)

		--Work out shadow offsets
		local xOffset = math.sin(math.rad(direction)) * distance
		local yOffset = math.cos(math.rad(direction)) * distance

		--Now draw the shadow
		BSHADOWS.ShadowMaterialGrayscale:SetFloat("$alpha", opacity/255) --set the alpha of the shadow
		render.SetMaterial(BSHADOWS.ShadowMaterialGrayscale)
		for i = 1 , math.ceil(intensity) do
			render.DrawScreenQuadEx(xOffset, yOffset, scrW, scrH)
		end

		if not _shadowOnly then
			--Now draw the original
			BSHADOWS.ShadowMaterial:SetTexture('$basetexture', BSHADOWS.RenderTarget)
			render.SetMaterial(BSHADOWS.ShadowMaterial)
			render.DrawScreenQuad()
		end

		cam.End2D()
	end

	--This will draw a shadow based on the texture you passed it.
	BSHADOWS.DrawShadowTexture = function(texture, intensity, spread, blur, opacity, direction, distance, shadowOnly)

		--Set default opcaity
		opacity = opacity or 255
		direction = direction or 0
		distance = distance or 0
		shadowOnly = shadowOnly or false

		--Copy the texture we wish to create a shadow for to the shadow render target
		render.CopyTexture(texture, BSHADOWS.RenderTarget2)

		--Blur the second render target
		if blur > 0 then
			render.PushRenderTarget(BSHADOWS.RenderTarget2)
			render.OverrideAlphaWriteEnable(true, true)
			render.BlurRenderTarget(BSHADOWS.RenderTarget2, spread, spread, blur)
			render.OverrideAlphaWriteEnable(false, false) 
			render.PopRenderTarget()
		end

		--Now update the material to the shadow render target
		BSHADOWS.ShadowMaterialGrayscale:SetTexture('$basetexture', BSHADOWS.RenderTarget2)

		--Work out shadow offsets
		local xOffset = math.sin(math.rad(direction)) * distance
		local yOffset = math.cos(math.rad(direction)) * distance

		--Now draw the shadow
		BSHADOWS.ShadowMaterialGrayscale:SetFloat("$alpha", opacity/255) --Set the alpha
		render.SetMaterial(BSHADOWS.ShadowMaterialGrayscale)
		for i = 1 , math.ceil(intensity) do
			render.DrawScreenQuadEx(xOffset, yOffset, scrW, scrH)
		end
		if not shadowOnly then
			--Now draw the original
			BSHADOWS.ShadowMaterial:SetTexture('$basetexture', texture)
			render.SetMaterial(BSHADOWS.ShadowMaterial)
			render.DrawScreenQuad()
		end
	end
end

Load()

timer.Create("XeninUI.BShadows.ResolutionCheck", 1, 0, function()
	if (ScrW() != scrW or ScrH() != scrH) then
		scrW = ScrW()
		scrH = ScrH()

		Load()
	end
end)
