f.ads = {}

function f.ads.join(id)
	f_msg2(id, "sys", "Welcome to ", "white", game("sv_name"))
end
addhook("join", "f.ads.join")

function f.ads.minute()
	f_msg("sys", "This server is powered by ", "red", "FaP")
end
addhook("minute", "f.ads.minute")
