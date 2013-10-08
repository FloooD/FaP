## FlooD's admin scriPt
[latest version on github](https://github.com/FloooD/FaP)

#### quick guide:
1. edit the admins file in notepad to make yourself a superadmin. example:

        12345	4	your_name	green

   the first entry is your usgn id, the second is your admin level, and the
   third and fourth are your @say name and color, respectively. separate the
   entries with tabs, not multiple spaces.

2. admin levels description:
   * 1 and above have @say
   * 2 and above have @lock, @swap, @specall, @make<spec|t|ct>, and @whois
   * 3 and above have all rcon commands e.g. @kick, @banip, @equip, etc...
   * 4 has everything, including @userlist, @useradd, @userdel

3. you can edit the admins file and restart the server to update the edits, or
   you can use the in-game system if you're a level 4 admin. the in-game
   system works like this:
   * @userlist
     - lists all the admins, online (in the server) and offline
   * @useradd [usgn],[level],[name],[color]
     - adds a new admin. if there is already an admin with the usgn, then that
       admin is modified.
   * @userdel [usgn]
     - deletes an admin

   all changes are immediately written to the admins file

4. make server.lua something like:

        f_dir = "sys/lua/" --the location to all the lua files
        f_admfile = "sys/lua/admins"
        dofile(f_dir.."fap.lua")

5. to see usgn names in @whois, run update.sh from the `usdelist/` directory.
   you can run it periodically to keep the list updated.

        cd usdelist/
        ./update.sh

   note: the script is for use on linux servers. for windows users, right click
   [this] (http://unrealsoftware.de/users.php?raw&s=0&c=10000000) and save it
   as the usdelist.raw file in the usdelist/ directory. (make sure to select
   Save as type: `All files (*.*)`)

#### todo:
- [ ] server setting presets, files?

#### contact:
* email: vomitme at gggmail
* xfire: apersonn
