--[[
	Taken from Improved Hair Menu by duckduckquak
]]
SpnCharCustomMath = SpnCharCustomMath or {}
SpnCharCustomMath.math = SpnCharCustomMath.math or {}

function SpnCharCustomMath.math.wrap(value, min, max)
	if value < min then
		return max
	elseif value > max then
		return min
	else
		return value
	end
end

function SpnCharCustomMath.math.sign(x)
	return x>0 and 1 or x<0 and -1 or 0
end

function SpnCharCustomMath.math.clamp(value, min, max)
	if value < min then
		return min
	elseif value > max then
		return max
	else
		return value
	end
end

return SpnCharCustomMath