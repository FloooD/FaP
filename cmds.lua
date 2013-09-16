need("fmt")
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
  ["@unlock"]		= "_team",
  ["@swap"]		= "_team",
  ["@specall"]		= "_team",
  ["@p"]		= "_parse",
  ["@parse"]		= "_parse",
  ["@whois"]		= "_whois",
  ["@rl"]		= "_rl"
}

for line in io.lines(f_dir.."default_cmds") do
	f.cmds.lut["@"..line] = "_generic"
end

f.cmds._generic = {
  min_lvl = 3,
  run = function(self, id, cmd, txt)
		parse(cmd:sub(2).." "..txt)
		return 1
	end
}

f.cmds._broadcast = {
  times = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}, --lOLoloLOLOLolOL
  onleave = function(self, id) self.times[id] = 0 end,

  min_lvl = 0,
  run =	function(self, id, cmd, txt)
		local dt = self.times[id] - os.time()
		if dt <= 0 then
			f_msg(f.colors.team[player(id, "team")], player(id, "name"), "green", " (BROADCAST): ", "std", txt)
			self.times[id] = os.time() + 7 --magic number umad??
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
		print("PARSE: NAME="..player(id, "name")..
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
  menu_title = "Team Control Menu",
  team_names = {[0] = "Spectators", "Terrorists", "Counter-Terrorists"},
  locks = {[0] = false, false, false},
  genmenu = function (self)
		local list = self.menu_title..","
		if self.locks[0] and self.locks[1] and self.locks[2] then
			list = list.."(Lock all),Unlock all,,"
		elseif self.locks[0] or self.locks[1] or self.locks[2] then
			list = list.."Lock all,Unlock all,,"
		else
			list = list.."Lock all,(Unlock all),,"
		end
		for i = 0, 2 do
			list = list..(self.locks[i] and "Unlock" or "Lock").." "..self.team_names[i]..","
		end
		return list..",Swap teams,Makespec all"
	end,
  lockall = function(self, lol)
		for i = 0, 2 do self.locks[i] = lol end
		f_msg("sys", "All teams "..(lol and "locked." or "unlocked."))
	end,
  lock = function(self, tm, lol)
		self.locks[tm] = lol
		f_msg(f.colors.team[tm], self.team_names[tm], "sys", " team "..(lol and "locked." or "unlocked."))
	end,
  swap = function(self)
		local temp = {self.locks[1], self.locks[2]}
		for i = 1, 2 do self.locks[i] = false end
		for _, id in pairs(player(0, "table")) do
			local t = player(id, "team")
			if t == 1 then
				parse("makect "..id)
			elseif t >= 2 then
				parse("maket "..id)
			end
		end
		self.locks[1] = temp[2]
		self.locks[2] = temp[1]
		f_msg("sys", "Teams swapped.")
	end,
  specall = function(self)
		local temp = {[0] = self.locks[0], self.locks[1], self.locks[2]}
		for i = 0, 2 do self.locks[i] = false end
		for _, id in pairs(player(0, "table")) do
			parse("makespec "..id)
		end
		for i = 0, 2 do self.locks[i] = temp[i] end
	end,
  onmenu = function(self, id, title, btn)
		if title ~= self.menu_title then return end
		
		if btn == 1 then
			self:lockall(true)
		elseif btn == 2 then
			self:lockall(false)
		elseif btn == 4 or btn == 5 or btn == 6 then
			local tm = btn - 4
			self:lock(tm, not self.locks[tm])
		elseif btn == 8 then
			self:swap()
		elseif btn == 9 then
			self:specall()
		else
			return
		end
		menu(id, self:genmenu())
	end,
  onteam = function(self, id, team)
  		local pteam = player(id, "team")
		if pteam == 3 then pteam = 2 end
		if pteam == team then return end
  		if self.locks[pteam] then
			f_msg2(id, "sys", "Your team is locked.")
			return 1
		elseif self.locks[team] then
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
		end
		local lol = (cmd == "@lock")
		txt=txt:lower()
		if txt == "" then
			menu(id, self:genmenu())
		elseif txt == "all" then
			self:lockall(lol)
		elseif txt == "spec" then
			self:lock(0, lol)
		elseif txt == "t" then
			self:lock(1, lol)
		elseif txt == "ct" then
			self:lock(2, lol)
		else
			f_msg2(id, "sys", "Usage "..cmd.." ** where ** is spec, t, or ct or just use "..cmd.." to open a menu.")
			return 0
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
		if f_ip then
			local port = game("sv_hostport")
			for _, i in player(0, "table") do
				parse("reroute "..i.." "f_ip"..":"..port)
			end
		end
  		parse("map "..game("sv_map"))
  		return 1
	end
}
