
function AwUI:MaskInverse(maskFn, drawFn, pixel)
	pixel = pixel or 1

	render.ClearStencil()
	render.SetStencilEnable(true)
	render.DepthRange(0, 1)

	render.SetStencilWriteMask(1)
	render.SetStencilTestMask(1)

	render.SetStencilFailOperation(STENCILOPERATION_REPLACE)
	render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
	render.SetStencilZFailOperation(STENCILOPERATION_KEEP)
	render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_NEVER)
	render.SetStencilReferenceValue(pixel)

	maskFn()

	render.SetStencilFailOperation(STENCILOPERATION_REPLACE)
	render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
	render.SetStencilZFailOperation(STENCILOPERATION_KEEP)
	render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)
	render.SetStencilReferenceValue(pixel - 1)

	drawFn()

	render.DepthRange(0, 1)
	render.SetStencilEnable(false)
	render.ClearStencil()
end

function AwUI:Mask(maskFn, drawFn, pixel)
	pixel = pixel or 1

	render.ClearStencil()
	render.SetStencilEnable(true)
	render.DepthRange(0, 1)

	render.SetStencilWriteMask(1)
	render.SetStencilTestMask(1)

	render.SetStencilFailOperation(STENCILOPERATION_REPLACE)
	render.SetStencilPassOperation(STENCILOPERATION_KEEP)
	render.SetStencilZFailOperation(STENCILOPERATION_KEEP)
	render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_NEVER)
	render.SetStencilReferenceValue(pixel)

	maskFn()

	render.SetStencilFailOperation(STENCILOPERATION_KEEP)
	render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
	render.SetStencilZFailOperation(STENCILOPERATION_KEEP)
	render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)
	render.SetStencilReferenceValue(pixel)

	drawFn()

	render.DepthRange(0, 1)
	render.SetStencilEnable(false)
	render.ClearStencil()
end


function AwUI:MaskEntity(BgDraw, entityDraw)
    render.SetStencilWriteMask( 0xFF )
        render.SetStencilTestMask( 0xFF )
        render.SetStencilReferenceValue( 0 )
        render.SetStencilFailOperation( STENCIL_KEEP )
        render.SetStencilZFailOperation( STENCIL_KEEP )
        render.ClearStencil()

        render.SetStencilFailOperation(STENCIL_KEEP)
        render.SetStencilZFailOperation(STENCIL_KEEP)
        
        render.SetStencilReferenceValue(1)
        render.SetStencilCompareFunction(STENCIL_NOTEQUAL)
        render.SetStencilPassOperation(STENCIL_REPLACE)
        BgDraw()
        entityDraw()
        render.SetStencilEnable( false )
end