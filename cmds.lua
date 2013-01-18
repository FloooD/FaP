need("fmt")
need("auth")

f.cmds = {}

function f.cmds.onsay(id, txt)
	local sym = txt:sub(1, 1)
	if sym == "!" or sym == "@" then
		local space = txt:find(" ") or (txt:len() + 1)
		local cmd = txt:sub(1, space - 1)
		if f.auth.tab[id][1] >= f.cmds.tab[cmd].min_priv then
			return f.cmds.tab[cmd]:run(id, txt:sub(space + 1)) or 1
		else
			f_msg2(id, "sys", "Insufficient privilege.")
			return 1
		end
	end
end
addhook("say", "f.cmds.onsay")

f.cmds.proto = {
  aliases = {},
  min_priv = 0,
  run = function(self, id, txt)
		f_msg2(id, "sys", "Command does not exist.")
		return 1
	end,
  on =	function(self) end,
  name = "f.cmds.tab."
}

local function hook(cmd, hook, func)
	cmd["_"..func] = function(...) return cmd[func](cmd, ...) end
	addhook(hook, cmd.name.."._"..func)
end

f.cmds.tab = {}

f.cmds.tab["!bc"] = {
  aliases = {"!broadcast"},
  times = {},
  onleave = function(self, id) self.times[id] = 0 end,
  run =	function(self, id, txt)
		local dt = self.times[id] - os.time()
		if dt <= 0 then
			f_msg("green", "%s (BROADCAST): %s", player(id, "name"), txt)
			self.times[id] = os.time() + 10
		else
			f_msg2(id, "sys", "%d seconds until next broadcast.", dt)
		end
	end,
  on =	function(self)
		for i = 1, 32 do self.times[i] = 0 end
		hook(self, "leave", "onleave")
	end
}

f.cmds.tab["!rs"] = {
  aliases = {"!resetscore"},
  run =	function(self, id, txt)
		if player(id, "deaths") ~= 0 or player(id, "score") ~= 0 then
			parse("setscore "..id.." 0")
			parse("setdeaths "..id.." 0")
			f_msg("sys", "%s reset his score.", player(id, "name"))
		else
			f_msg2(id, "sys", "Score already 0/0.")
		end
	end
}

f.cmds.tab["@say"] = {
  min_priv = 1,
  run =	function(self, id, txt)
		f_msg(f.auth.tab[id][3], "%s (%s): %s", player(id, "name"), f.auth.tab[id][2], txt)
	end
}

f.cmds.tab["@lock"] = {
  menu_title = "Team Control Menu",
  teams = {[0] = "Spectators", "Terrorists", "Counter-Terrorists"},
  locks = {[0] = false, false, false},
  onmenu = function(self, id, title, btn)
		if title ~= self.menu_title then return end
		
		if btn == 1 or btn == 2 then
			local l = (btn == 1)
			for i = 0, 2 do self.locks[i] = l end
		elseif btn == 4 or btn == 5 or btn == 6 then
			local i = btn - 4
			self.locks[i] = not self.locks[i]
		elseif btn == 8 then
			local temp = {self.locks[1], self.locks[2]}
			for i = 1, 2 do self.locks[i] = false end
			for _, id in pairs(player(0, "table")) do
				local t = player(id, "team")
				if t == 1 then
					parse("makect "..id)
				elseif t == 2 then
					parse("maket "..id)
				end
			end
			self.locks[1] = temp[2]
			self.locks[2] = temp[1]
		elseif btn == 9 then
			local temp = {[0] = self.locks[0], self.locks[1], self.locks[2]}
			for i = 0, 2 do self.locks[i] = false end
			for _, id in pairs(player(0, "table")) do
				parse("makespec "..id)
			end
			for i = 0, 2 do self.locks[i] = temp[i] end
		end
	end,
  onteam = function(self, id, team)
  		local pteam = player(id, "team")
		if pteam == team then return end
  		if self.locks[pteam] then
			f_msg2(id, "sys", "Your team is locked.")
			return 1
		elseif self.locks[team] then
			f_msg2(id, "sys", "The "..self.teams[team].." team is locked.")
			return 1
		end
	end,
  min_priv = 2,
  run = function(self, id, txt)
  		local list = self.menu_title..","
		if self.locks[0] and self.locks[1] and self.locks[2] then
			list = list.."(Lock all),Unlock all,,"
		elseif self.locks[0] or self.locks[1] or self.locks[2] then
			list = list.."Lock all,Unlock all,,"
		else
			list = list.."Lock all,(Unlock all),,"
		end
		for i = 0, 2 do
			list = list..(self.locks[i] and "Unlock" or "Lock").." "..self.teams[i]..","
		end
		list = list..",Swap teams,Makespec all"
		menu(id, list)
	end,
  on =	function(self)
		hook(self, "team", "onteam")
		hook(self, "menu", "onmenu")
	end
}

f.cmds.tab["@p"] = {
  min_priv = 4,
  aliases = {"@parse"}
}

f.cmds.aliases = {}
for k, cmd in pairs(f.cmds.tab) do
	setmetatable(cmd, {__index = f.cmds.proto})
	for _, v in pairs(cmd.aliases) do
		f.cmds.aliases[v] = cmd
	end
	cmd.name = cmd.name..k
	cmd:on()
end
setmetatable(f.cmds.tab, {__index =
			function(_, cmd)
				return f.cmds.aliases[cmd] or f.cmds.proto
			end})
