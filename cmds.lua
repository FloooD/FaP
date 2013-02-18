need("fmt")
need("auth")

f.cmds = {}

function f.cmds.onsay(id, txt)
	local sym = txt:sub(1, 1)
	if sym == "!" or sym == "@" then
		local space = txt:find(" ") or (#txt + 1)
		local cmd = txt:sub(1, space - 1)
		local wat = f.cmds.lut[cmd]
		if not wat then
			f_msg2(id, "sys", "Command does not exist.")
			return 1
		end
		if f.auth.tab[id][1] < f.cmds[wat].min_lvl then
			f_msg2(id, "sys", "Insufficient privilege.")
			return 1
		end
		return f.cmds[wat]:run(id, cmd, txt:sub(space + 1)) or 1
	end
end
addhook("say", "f.cmds.onsay")

f.cmds.lut = {
  ["!broadcast"]	= "_broadcast",
  ["!bc"]		= "_broadcast",
  ["!resetscore"]	= "_resetscore",
  ["!rs"]		= "_resetscore",
  ["@say"]		= "_say",
--[[  ["@lock"]		= "_lock",
  ["@lockt"]		= "_lock",
  ["@lockct"]		= "_lock",
  ["@lockspec"]		= "_lock",
  ["@unlockt"]		= "_lock",
  ["@unlockct"]		= "_lock",
  ["@unlockspec"]	= "_lock",]]--do later
  ["@p"]		= "_parse",
  ["@parse"]		= "_parse"
}

f.cmds._broadcast = {
  times = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}, --lOLoloLOLOLolOL
  onleave = function(self, id) self.times[id] = 0 end,

  min_lvl = 0,
  run =	function(self, id, cmd, txt)
		local dt = self.times[id] - os.time()
		if dt <= 0 then
			f_msg(f.color_team[player(id, "team")], player(id, "name"), "green", " (BROADCAST): ", "std", txt)
			self.times[id] = os.time() + 7 --magic number umad??
		else
			f_msg2(id, "sys", dt.." seconds until next broadcast.")
		end
	end
}
addhook("leave", "f.cmds._broadcast.onleave")

f.cmds._resetscore = {
  min_lvl = 0,
  run =	function(self, id, cmd, txt)
		if player(id, "deaths") ~= 0 or player(id, "score") ~= 0 then
			parse("setscore "..id.." 0")
			parse("setdeaths "..id.." 0")
			f_msg(f.color_team[player(id, "team")], player(id, "name"), "sys", " reset his score.")
		else
			f_msg2(id, "sys", "Score already 0/0.")
		end
	end
}

f.cmds._say = {
  min_lvl = 1,
  run =	function(self, id, cmd, txt)
		f_msg(f.auth.tab[id][3], player(id, "name")..": ", "white", txt)
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
	end
}
