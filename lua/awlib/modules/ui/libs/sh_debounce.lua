
function Aw:RemoveDebounce(name)
	timer.Remove("_debounce." .. name)
end

function Aw:Debounce(name, wait, func)
  if (timer.Exists("_debounce." .. name)) then
    timer.Remove("_debounce." .. name)
  end

  timer.Create("_debounce." .. name, wait, 1, function()
    func()

    timer.Remove("_debounce." .. name)
  end)
end
