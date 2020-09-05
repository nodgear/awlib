function table.Invert(src, key, idnum)
    local ret = {}
    if not istable(src) then return end

    for k, v in pairs(src) do
        if key and istable(v) then
            if v[key] then
                ret[v[key]] = v

                if idnum then
                    v.IDNUM = k
                end
            end
        else
            ret[v] = k
        end
    end

    return ret
end

function table.StoreKeys(src, key)
    key = key or "IDNUM"

    for k, v in pairs(src) do
        if istable(v) then
            v[key] = k
        end
    end

    return src
end

-- The following allows you to safely pack varargs while retaining nil values
table.NIL = table.NIL or setmetatable({}, {
    __tostring = function() return "nil" end
})

function table.PackNil(...)
    local t = {}

    for i = 1, select("#", ...) do
        local v = select(i, ...)

        if v == nil then
            v = table.NIL
        end

        table.insert(t, v)
    end

    return t
end

function table.UnpackNil(t, nocopy)
    if #t == 0 then return end

    if not nocopy then
        t = table.Copy(t)
    end

    local v = table.remove(t, 1)

    if v == table.NIL then
        v = nil
    end

    return v, table.UnpackNil(t, true)
end

-- Only works on sequential tables. The other implementation of table randomness is complete jank.
function table.TrueRandom(tbl)
    local n = random.RandomInt(1, #tbl)

    return tbl[n]
end

function table.Equals(source, target)
    local sourceType, targetType = type(source), type(target)

    if sourceType ~= targetType then
        return false
    end

    -- non-table types can be directly compared
    if not istable(source) or not istable(target) then
        return source == target
    end

    for k1, v1 in pairs(source) do
        local v2 = target[k1]
        if v2 == nil or not table.Equals(v1, v2) then
            return false
        end
    end

    for k2, v2 in pairs(target) do
        local v1 = source[k2]
        if v1 == nil or not table.Equals(v1, v2) then
            return false
        end
    end

    return true
end

function table.ShallowDiff(source, target)
    local diff = {}

    for key, value in pairs(source) do
        if target[key] == nil or not table.Equals(value, target[key]) then
            diff[key] = value
        end
    end

    for key, value in pairs(target) do
        if source[key] == nil then
            diff[key] = table.NIL
        end
    end

    return diff
end

function table.CreateProxied(reference, changeCallback)
    local proxy = {}

    local proxiedTableBase = {
        __index = function(t, k)
            if istable(reference[k]) then
                return table.CreateProxied(reference[k], changeCallback)
            else
                return reference[k]
            end
        end,
        __newindex = function(t, k, v)
            reference[k] = v
            changeCallback(k, v)
        end,
        IsProxied = function() return true end
    }

    return setmetatable(proxy, proxiedTableBase)
end