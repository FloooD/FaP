f.usdeids = {}

local list_file = f_dir.."usdelist/usdelist.raw" --change if in different location

local function load_list()
	local ff = assert(io.open(list_file, "r"),
			"raw list file could not be opened. check if list_file in usdeids.lua is correct.")
	local buf = ff:read("*all")
	ff:close()
	local t = {}
	for id, name in buf:gmatch("(%d+),([^\n]+)") do
		t[tonumber(id)] = name
	end
	return t
end
f.usdeids = load_list()
