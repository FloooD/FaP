need("colors")

--admin level ranges from 0 to 4.
--0 is the same as no admin.
--1 and above have @say
--2 and above have @whois, @lock, @unlock, @swap, @specall
--3 and above have any rcon command via @<rcon command> and @rl
--4 has @parse which isn't much more than level 3, but in the future
----level 4 will be the only level able to control admin configs in-game

f.admins = {
 --us id#-adm lvl-name---@say color
  [1127] = {4, "FlooD", "ltblue"}
}
