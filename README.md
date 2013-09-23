### FlooD's admin scriPt
[latest version on github] (https://github.com/FloooD/FaP)

#### quick guide:
1. edit the admins file in notepad to make yourself an admin. example:

    12345	4	your_name	green

   the first entry should be your usgn id, the second is your admin level, and
   the third and fourth are your @say name and color, respectively. separate
   entries with tabs, not multiple spaces.

2. admin levels:
   1 and above have @say
   2 and above have @lock, @swap, @specall, @make<spec|t|ct>, and @whois
   3 and above have all rcon commands e.g. @kick, @banip, @equip, etc...
   4 has everything, including @userlist, @useradd, @userdel

3. user management:
   you can edit the admins file and restart the server to update the edits, or
   you can use the in-game system if you're a level 4 admin. the in-game
   system works like this:
   @userlist
       lists all the admins, online (in the server) or offline
   @useradd <usgn>,<level>,<name>,<color>
       adds a new admin. if there is already an admin with the usgn, then that admin is modified.
   @userdel <usgn>
       deletes an admin

4. make server.lua something like:

    f_dir = "sys/lua/" --the location to all the lua files
    f_admfile = "sys/lua/admins"
    dofile(f_dir.."fap.lua")

#### todo:
- [ ] server setting presets, files?

#### contact:
* email: vomitme at gggmail
* xfire: apersonn
