function AwUI:Ease(t, b, c, d)
	t = t / d
	local ts = t * t
	local tc = ts * t

	--return b + c * ts
	return b + c * (-2 * tc + 3 * ts)
end

function AwUI:EaseInOutQuintic(t, b, c, d)
	t = t / d
	local ts = t * t
	local tc = ts * t

	--return b + c * ts
	return b + c * (6 * tc * ts + -15 * ts * ts + 10 * tc)
end