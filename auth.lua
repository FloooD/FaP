need("fmt")
need("admins")

f.auth = {}
f.auth.tab = {}

for i = 1, 32 do f.auth.tab[i] = {0} end

function f.auth.onjoin(id)
	f.auth.tab[id] = f.admins[player(id, "usgn")] or {0}
	if f.auth.tab[id][1] > 0 then
		f_msg2(id, "sys", "Logged in as %s.", f.auth.tab[id][2])
	end
end

function f.auth.onleave(id, r)
	f.auth.tab[id] = {0}
	if r == 1 then --not related to auth, but dunno where else to put this.
		msg(player(id, "name").." has left the game (ping timeout).")
	end
end

addhook("join", "f.auth.onjoin")
addhook("leave", "f.auth.onleave")
