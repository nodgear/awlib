function net.SafeWriteTable(tab)
    for k, v in pairs(tab) do
        if not isfunction(v) then
            net.WriteType(k)
            net.WriteType(v)
        end
    end

    net.WriteType(nil)
end