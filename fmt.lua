need("colors")

f.fmt = true

local function c(...)
	local ret =""
	for i, v in ipairs(arg) do
		ret = ret..((i % 2 == 1) and f.colors[v] or v)
	end
	return ret
end
function f_msg(...) return msg(c(...)) end
--example: f_msg("red", "red text ", "blue", "and blue text on the same line")
function f_msg2(id, ...) return msg2(id, c(...)) end
