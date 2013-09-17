need("fmt")
need("users")
need("auth")
need("usdeids")

f.cmds = {}

function f.cmds.onsay(id, txt)
	local sym = txt:sub(1, 1)
	if sym == "!" or sym == "@" then
		local space = txt:find(" ") or (#txt + 1)
		local cmd = txt:sub(1, space - 1)
		local wat = f.cmds.lut[cmd:lower()]
		if not wat then
			f_msg2(id, "sys", "Command does not exist.")
			return 1
		end
		if f.auth.tab[id][1] < f.cmds[wat].min_lvl then
			f_msg2(id, "sys", "Insufficient privilege.")
			return 1
		end
		local ret = f.cmds[wat]:run(id, cmd, txt:sub(space + 1))
		if ret == 0 then --silent
		elseif ret == 1 then --player used @cmd. rest is hidden
			f_msg("sys", player(id, "name").." used ", "red", cmd)
		elseif ret == 2 then --player used @cmd params.
			f_msg("sys", player(id, "name").." used ", "red", txt)
		end
		return 1
	end
end
addhook("say", "f.cmds.onsay")

local function hook(hook, base, func, ...) --watisthisidonteven
	f.cmds[base]["_"..func] = function(...) return f.cmds[base][func](f.cmds[base], ...) end
	addhook(hook, "f.cmds."..base.."._"..func, ...)
end

f.cmds.lut = {
  ["!broadcast"]	= "_broadcast",
  ["!bc"]		= "_broadcast",
  ["!resetscore"]	= "_resetscore",
  ["!rs"]		= "_resetscore",
  ["@say"]		= "_say",
  ["@lock"]		= "_team",
  ["@swap"]		= "_team",
  ["@specall"]		= "_team",
  ["@makespec"]		= "_team",
  ["@maket"]		= "_team",
  ["@makect"]		= "_team",
  ["@p"]		= "_parse",
  ["@parse"]		= "_parse",
  ["@whois"]		= "_whois",
  ["@rl"]		= "_rl",
  ["@useradd"]		= "_users",
  ["@userdel"]		= "_users",
  ["@userlist"]		= "_users"
}

for line in io.lines(f_dir.."default_cmds") do
	if not f.cmds.lut["@"..line] then
		f.cmds.lut["@"..line] = "_generic"
	end
end

f.cmds._generic = {
  min_lvl = 3,
  run = function(self, id, cmd, txt)
		print("@COMMAND: NAME="..player(id, "name")..
			" IP="..player(id, "ip")..":"..player(id, "port")..
			" USGN="..player(id, "usgn")..
			" CMD="..cmd..(txt and " "..txt or ""))
		parse(cmd:sub(2).." "..txt)
		return 1
	end
}

f.cmds._broadcast = {
  times = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
  onleave = function(self, id) self.times[id] = 0 end,

  min_lvl = 0,
  run =	function(self, id, cmd, txt)
		local dt = self.times[id] - os.time()
		if dt <= 0 then
			f_msg(f.colors.team[player(id, "team")], player(id, "name"), "green", " (BROADCAST): ", "std", txt)
			self.times[id] = os.time() + 7
		else
			f_msg2(id, "sys", dt.." seconds until next broadcast.")
		end
		return 0
	end
}
hook("leave", "_broadcast", "onleave")

f.cmds._resetscore = {
  min_lvl = 0,
  run =	function(self, id, cmd, txt)
		if player(id, "deaths") ~= 0 or player(id, "score") ~= 0 then
			parse("setscore "..id.." 0")
			parse("setdeaths "..id.." 0")
			return 1
		else
			f_msg2(id, "sys", "Score already 0/0.")
			return 0
		end
	end
}

f.cmds._say = {
  min_lvl = 1,
  run =	function(self, id, cmd, txt)
		f_msg(f.auth.tab[id][3], player(id, "name")..": ", "white", txt)
		return 0
	end
}

f.cmds._parse = {
  min_lvl = 4,
  run = function(self, id, cmd, txt)
		print("@PARSE: NAME="..player(id, "name")..
			" IP="..player(id, "ip")..":"..player(id, "port")..
			" USGN="..player(id, "usgn")..
			" CMD="..cmd..(txt and " "..txt or ""))
		for c in string.gmatch(txt, "[^;]+") do
			f_msg("sys", player(id, "name").." used ", "red", cmd.." "..c:gsub("%s.*", ""))
			parse(c)
		end
		return 2
	end
}

f.cmds._team = {
  team_names = {[0] = "Spectators", "Terrorists", "Counter-Terrorists"},
  invert_name_tab = {["none"] = -1, ["spec"] = 0, ["t"] = 1, ["ct"] = 2, ["all"] = 3},
  lock_state = -1,
  swap = function(self)
		local temp = self.lock_state
		if temp == 1 or temp == 2 then
			temp = 3 - temp
		end
		self.lock_state = -1
		for _, id in pairs(player(0, "table")) do
			local t = player(id, "team")
			if t == 1 then
				parse("makect "..id)
			elseif t >= 2 then
				parse("maket "..id)
			end
		end
		self.lock_state = temp
	end,
  specall = function(self)
		local temp = self.lock_state
		self.lock_state = -1
		for _, id in pairs(player(0, "table")) do
			parse("makespec "..id)
		end
		self.lock_state = temp
	end,
  onmenu = function(self, id, title, btn)
		if title ~= "Team Control Menu" then return end
		
		if btn == 1 then
			self.lock_state = -1
			f_msg("sys", player(id, "name").." unlocked all teams")
		elseif btn == 2 then
			self.lock_state = 3
			f_msg("sys", player(id, "name").." locked all teams")
		elseif btn == 4 or btn == 5 or btn == 6 then
			local l = btn - 4
			self.lock_state = l
			f_msg("sys", player(id, "name").." locked "..self.team_names[l].. " team")
		elseif btn == 8 then
			self:swap()
			f_msg("sys", player(id, "name").." swapped teams")
		elseif btn == 9 then
			self:specall()
			f_msg("sys", player(id, "name").." used makespec all")
		else
			return
		end
	end,
  onteam = function(self, id, team)
  		if self.lock_state == -1 then
			return
		end
  		local pteam = player(id, "team")
		if pteam == 3 then pteam = 2 end
		if pteam == team then return end
		if self.lock_state == 3 then
			f_msg2(id, "sys", "All teams are locked.")
			return 1
		elseif self.lock_state == pteam then
			f_msg2(id, "sys", "Your team is locked.")
			return 1
		elseif self.lock_state == team then
			f_msg2(id, "sys", "The "..self.team_names[team].." team is locked.")
			return 1
		end
	end,
  min_lvl = 2,
  run = function(self, id, cmd, txt)
  		cmd = cmd:lower()
		if cmd == "@swap" then
			self:swap()
			return 1
		elseif cmd == "@specall" then 
			self:specall()
			return 1
		elseif cmd:sub(1,5) == "@make" then
			local temp = self.lock_state
			self.lock_state = -1
			parse(cmd:sub(2).." "..txt)
			self.lock_state = temp
			return 1
		end
		txt=txt:lower()
		if txt == "" then
			menu(id, "Team Control Menu,Lock none,Lock all,,Lock Spectators,Lock Terrorists,Lock Counter-Terrorists,,Swap teams,Makespec all")
		else
			local s = self.invert_name_tab[txt]
			if not s then
				f_msg2(id, "sys", "Usage: ", "white", "@lock **", "sys",
					" where ** is all, none, spec, t, or ct or just use",
					"white", "@lock", "sys", " to open a menu.")
				return 0
			end
			self.lock_state = s
		end
		return 2
	end
}
hook("team", "_team", "onteam")
hook("menu", "_team", "onmenu")

f.cmds._whois = {
  min_lvl = 2,
  run = function(self, id, cmd, txt)
		local pid = tonumber(txt)
		if not player(pid, "exists") then
			f_msg2(id, "sys", "Player with id "..pid.." does not exist.")
			return 0
		end
		f_msg2(id, "sys", "name: "..player(pid, "name"))
		f_msg2(id, "sys", "ip: "..player(pid, "ip"))
		local u = player(pid, "usgn")
		if u then
			f_msg2(id, "sys", "usgn id: "..u)
			f_msg2(id, "sys", "usgn name: "..(f.usdeids[u] or "not in list"))
		else
			f_msg2(id, "sys", "no usgn id")
		end
		return 1
	end
}

f.cmds._rl = {
--reloads server by changing to current map
  min_lvl = 3,
  run = function(self, id, cmd, txt)
		f_msg(id, "sys", "Reloading server...")
  		parse("map "..game("sv_map"))
  		return 1
	end
}

f.cmds._users = {
  min_lvl = 4,
  run = function(self, id, cmd, txt)
		if cmd == "@userlist" then
			f_msg2(id, "sys", "format:")
			f_msg2(id, "red", "usgn, level, name, color")
			f_msg2(id, "sys", "all users:")
			for k, v in pairs(f.users.tab) do
				f_msg2(id, "red", k..", "..v[1]..", "..v[2]..", "..v[3])
			end
			f_msg2(id, "sys", "currently logged in:")
			for i = 1,32 do
				if #f.auth.tab[i] > 1 then
					f_msg2(id, "red", player(i, "usgn")..", "..f.auth.tab[i][1]..", "..f.auth.tab[i][2]..", "..f.auth.tab[i][3])
				end
			end
			return 0
		end

		local u = tonumber(txt:find(",") and txt:sub(1, txt:find(",") - 1) or txt)
		if not u or u == 0 then
			f_msg2(id, "sys", "Usage:")
			f_msg2(id, "sys", "@userlist")
			f_msg2(id, "sys", "@useradd <usgn>,<level>,<name>,<color>")
			f_msg2(id, "sys", "@userdel <usgn>")
			f_msg2(id, "sys", "note: @useradd can also modify an existing user")
			return 0
		end

		local exists = false
		if f.users.tab[u] then exists = true end
			
		if cmd == "@useradd" then
			if exists then
				f_msg2(id, "sys", "user with usgn "..u.." already exists and will be modified.")
			end
			local ret = f.users.add(txt, ",")
			if ret == 0 then
				f_msg2(id, "sys", "user with usgn "..u.." added successfully")
			elseif ret == 1 then
				f_msg2(id, "sys", "wrong format. Usage: @useradd <usgn>,<level>,<name>,<color>")
				return 0
			elseif ret == 2 then
				f_msg2(id, "sys", "invalid usgn")
				return 0
			elseif ret == 3 then
				f_msg2(id, "sys", "color not found. user with usgn "..u.." added successfully with default color of red")
			end
			for i = 1, 32 do
				if player(i, "usgn") == u then f.auth.onjoin(i) end
			end
			f.users.write()
			return 1
		elseif cmd == "@userdel" then
			if not exists then
				f_msg2(id, "sys", "user with usgn "..u.." does not exist.")
				f_msg2(id, "sys", "use @userlist if you want to modify the user.")
				return 0
			end
			f.users.tab[u] = nil
			for i = 1, 32 do
				if player(i, "usgn") == u then f.auth.onjoin(u) end
			end
			f.users.write()
			return 1
		end
	end
}