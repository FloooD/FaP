----------------------------
----FlooD's admin scriPt----
----------------------------
--latest version always at--
---github.com/FloooD/FaP----

f = {}
if not f_dir then f_dir = "sys/lua/" end
if not f_admfile then f_admfile = f_dir.."admins" end

function need(smth)
	if not f[smth] then dofile(f_dir..smth..".lua") end
end

need("ads")
need("users")
need("am")
need("fmt")
need("auth")
need("cmds")
need("show_rcon")

--for security:
io.popen = nil
os.execute = nil
os.remove = nil
os.rename = nil
