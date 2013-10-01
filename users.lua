need("colors")

--admin level ranges from 0 to 4.
--0 is the same as no admin.
--1 and above have @say
--2 and above have @whois, @lock, @unlock, @swap, @specall
--3 and above have any rcon command via @<rcon command> and @rl
--4 has @parse which isn't much more than level 3, but in the future
----level 4 will be the only level able to control admin configs in-game
f.users = {}

f.users.tab = {}

function f.users.add(line, delim)
	local t = {}
	local i = 0
	for chunk in line:gmatch("[^"..delim.."]+") do
		i = i + 1
		t[i] = chunk
	end
	if i ~= 4 then return 1 end --wrong format
	local u = tonumber(t[1])
	if not u or u < 1 then return 2 end --wrong usgn
	local priv = tonumber(t[2])
	if not priv then return 1 end
	if not t[3] then return 1 end
	local ret = 0
	if not f.colors.presets[t[4]] then
		ret = 3 --color doesnt exist, default to red
		t[4] = "red"
	end
	f.users.tab[tonumber(t[1])] = {tonumber(t[2]), t[3], t[4]}
	return ret
end

function f.users.read()
	for line in io.lines(f_admfile) do
		f.users.add(line, "\t")
	end
end
f.users.read()

function f.users.write()
	local ff = io.open(f_admfile, "w")
	for k, v in pairs(f.users.tab) do
		ff:write(k, "\t", v[1], "\t", v[2], "\t", v[3], "\n")
	end
	ff:close()
end