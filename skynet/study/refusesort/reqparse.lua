local skynet = require "skynet"

local reqparse = {}
local headsize = 12
local message
local body_start = headsize + 1
local bodystr

local crypt = require "crypt"
local secret = "BS789net"


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
function reqparse.parse(msg,sz)
	--parse header
	local str = skynet.tostring(msg,sz);
	local tag,bodylen,checkcoe,version,cmdtype,reserved =  string.unpack(">I2I2bbI4I2",str)
	message = {}
	
	-- for i=1,#str do
	-- 	print(string.format("%x",str[i]))
	-- end
	
	--desdecode
	if version == 0x40 then
		--print("desdecode")
		local tempStr = string.sub(str,7)
		--print(#tempStr)
		--print(tempStr)
		
		local decodestr = crypt.desdecode(secret, tempStr)
		--print(#decodestr)
		--print(decodestr)
		str = string.sub(str,1,6) .. decodestr
		cmdtype = string.unpack(">I4",str,7)
		--local userid = string.unpack(">I4",str,13)
		--print(string.format("desdecode cmdtype:%x ,%d" ,cmdtype,userid))
		
	end
	
	message.version = version
	message.cmdtype = cmdtype
	
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
	message.rand = string.unpack(">I2",str,body_start+12)
end

--提交成绩,gamestep
reqparse[reqparse.cmd.gamestep] = function(str)
	message.userid = string.unpack(">I4",str,body_start)
	message.score = string.unpack(">I4",str,body_start+4)
	message.rand = string.unpack(">I2",str,body_start+8)
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