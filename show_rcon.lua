need("fmt")

function f.show_rcon(t, p, ip)
	local name = (p == 0) and "EXTERNAL RCON: "..ip or player(p, "name")
	f_msg("sys", name.." used ", "red", "rcon "..t:gsub("%s.*", ""))
end
addhook("rcon", "f.show_rcon")
