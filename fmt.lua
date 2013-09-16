need("colors")

f.fmt = true

local function c(...)
	local ret =""
	for i, v in ipairs(arg) do
		ret = ret..((i % 2 == 1) and f.colors.presets[v] or f.color.char..v)
	end
	return ret
end
function f_msg(...) return msg(c(...)) end
--example: f_msg("red", "red text, ", "blue", "blue text, ", "123123123", "and custom colored text on the same line")
function f_msg2(id, ...) return msg2(id, c(...)) end
