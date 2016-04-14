local skynet = require "skynet"

local reqparse = {}
local headsize = 12
local message
local body_start = headsize + 1

reqparse.cmd ={
				enterroom = 0x00004000,
				leaveroom = 0x00004001
				}
function reqparse.parse(msg,sz)
	--parse header
	local str = skynet.tostring(msg,sz);
	local tag,bodylen,checkcoe,version,cmdtype,reserved =  string.unpack(">I2I2bbI4I2",str)
	message = {}
	message.cmdtype = cmdtype
	message.version = version
	local f = reqparse[cmdtype]
	if f then
		f(str)
	end
	return message
end




--进入房间
reqparse[reqparse.cmd.enterroom] = function(str)
	message.userid = string.unpack(">I4",str,body_start)
	message.serverid = string.unpack(">I4",str,body_start+4)
	message.authentic = string.unpack(">c16",str,body_start+8)
end

--离开房间
reqparse[reqparse.cmd.leaveroom] = function(str)
end

return reqparse