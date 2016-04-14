local resppack = {}

local tag = 0x5342
local checkcoe = 0
local reserved = 0
local headsize = 12
local body_start = headsize + 1

local bodystr

resppack.cmd = {
				enterroom = 0x80004000,
				leaveroom = 0x80004001
				}

local function fillStr(str,needlen)
	return str .. string.rep("\0",needlen-#str)
end

function resppack.pack(cmdtype,version,...)
	bodystr = ""
	local f = resppack[cmdtype]
	if f then
		f(...)
	end
	local str =  string.pack("<I2I2bbI4I2",tag,#bodystr,checkcoe,version,cmdtype,reserved) .. bodystr
	return str
end


--进入房间回包
resppack[resppack.cmd.enterroom] = function(state,player_count)
	bodystr = string.pack("i4I4",state,player_count)
end

--离开房间回包
resppack[resppack.cmd.leaveroom] = function(userid,reasonid)
	bodystr = string.pack("<I4i4",userid,reasonid)
end


return resppack;