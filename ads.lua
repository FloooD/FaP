f.ads = {}

function f.ads.join(id)
	f_msg2(id, "white", "Welcome to "..game("sv_name"))
end
addhook("join", "f.ads.join")

function f.ads.minute()
	f_msg("white", "This server is powered by FaP.")
end
addhook("minute", "f.ads.minute")
