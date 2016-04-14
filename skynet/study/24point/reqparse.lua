local skynet = require "skynet"

local reqparse = {}
local headsize = 12
local message
local body_start = headsize + 1

reqparse.cmd ={
				rank = 0x00005001,
				userinfo = 0x00005002,
				awardinfo = 0x00005003,
				-- drawaward = 0x00005005,
				gamestart = 0x00008001,
				gameover = 0x00008003,
				gamestep = 0x00008004,
				heartbeat = 0x00000000,
				enterroom = 0x00004000,
				leaveroom = 0x00004001
				}
function reqparse.parse(msg,sz)  --message lightdate的c指针
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

--排名
reqparse[reqparse.cmd.rank] = function(str)
	message.userid = string.unpack(">I4",str,body_start)
end

--个人信息
reqparse[reqparse.cmd.userinfo] = function(str)
	message.userid = string.unpack(">I4",str,body_start)
end

--奖励
reqparse[reqparse.cmd.awardinfo] = function(str)
end

-- --领取奖励
-- reqparse[reqparse.cmd.drawaward] = function(str)
-- 	--message.serialid = string.unpack(">I4",str,body_start)
-- end

--游戏开始
reqparse[reqparse.cmd.gamestart] = function(str)
	message.userid = string.unpack(">I4",str,body_start)
end

--提交成绩,gameover
reqparse[reqparse.cmd.gameover] = function(str)
	message.userid = string.unpack(">I4",str,body_start)
	message.count = string.unpack(">I4",str,body_start+4)
	message.score = string.unpack(">I4",str,body_start+8)
end

--提交成绩,gamestep
reqparse[reqparse.cmd.gamestep] = function(str)
	message.userid = string.unpack(">I4",str,body_start)
	message.score = string.unpack(">I4",str,body_start+4)
end

--心跳
reqparse[reqparse.cmd.heartbeat] = function(str)
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