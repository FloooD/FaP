need("colors")

f.fmt = true

function f_print(s, ...) return print(s:format(...)) end
function f_msg(c, s, ...) return msg(f.colors[c]..s:format(...)) end
function f_msg2(id, c, s, ...) return msg2(id, f.colors[c]..s:format(...)) end
