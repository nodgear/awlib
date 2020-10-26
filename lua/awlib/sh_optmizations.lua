-- inserts distance verification from the squared value to the entity metatable.

local entMeta = FindMetaTable("Entity")
function Aw.IsCloseTo(eEnt, eOtherEnt, nDistance)
    return eEnt:GetPos():DistToSqr( eOtherEnt:GetPos() ) < (distance * distance)
end

entMeta.IsCloseTo = Aw.IsCloseTo