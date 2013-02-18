f.am = {} --automoney

--modes: 0 - off
--       1 - 16k each round if mp_startmoney is 16k. otherwise off. 
--       2 - all rounds starts with mp_startmoney.
--mode 1 is enough for almost everything. use mode 0 instead if you have
--some other script that sets money or if you want 16k but not every round.
--use mode 2 if you want to practice pistol rounds or something.
f.am.mode = 1

function f.am.onspawn(id)
	if f.am.mode == 0 then return end
	local m = game("mp_startmoney")
	if f.am.mode == 1 and m ~= "16000" then return end
	parse("setmoney "..id.." "..m)
end
addhook("spawn", "f.am.onspawn")
