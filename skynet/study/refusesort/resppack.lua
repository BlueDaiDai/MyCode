local resppack = {}

local crypt = require "crypt"
local secret = "BS789net"

local tag = 0x5342
local checkcoe = 0
local reserved = 0
local headsize = 12
local body_start = headsize + 1

local bodystr

resppack.cmd = {
				rank = 0x80005001,
				userinfo = 0x80005002,
				awardinfo = 0x80005003,
				awardresult = 0x80005004,
				-- drawaward = 0x80005005,
				gamestart = 0x80008001,
				timeout = 0x80008002,
				gameover = 0x80008003,
				gamestep = 0x80008004,
				gamescene = 0x80008005,
				heartbeat = 0x80000000,
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
	local str
	if version == 0x40 then
		--des加密
		local tempstr = string.pack("<I4I2",cmdtype,reserved) .. bodystr
		local encodestr = crypt.desencode(secret,tempstr)
		--print("加密后长度:",#encodestr)
		str =  string.pack("<I2I2bb",tag,#encodestr-6,checkcoe,version) .. encodestr
	else
		str =  string.pack("<I2I2bbI4I2",tag,#bodystr,checkcoe,version,cmdtype,reserved) .. bodystr
	end
	
	return str
end

--排名列表
resppack[resppack.cmd.rank] = function(rank_items)
	local str_array = {}
	for i =1,#rank_items do
		local v = rank_items[i]
		str_array[i] = string.pack("<I4I4c32I4",v.rank,v.userid,fillStr(v.username,32),v.maxscore)
	end
	bodystr = table.concat(str_array)
end

--个人信息
resppack[resppack.cmd.userinfo] = function(person)
	--print(person.remain)
	bodystr = string.pack("<I4I4I4I4i2",person.userid,person.total,person.best_rank,person.best_score,person.remain)
end

--奖励说明
resppack[resppack.cmd.awardinfo] = function(award_items)
	local str_array = {}
	for i =1,#award_items do
		local v = award_items[i]
		str_array[i] = string.pack("<I4I4I2c"..#v.info,v.start_rank,v.end_rank,#v.info,v.info)
	end
	bodystr = table.concat(str_array)
end

-- --比赛获奖结果
resppack[resppack.cmd.awardresult] = function(result)
	bodystr = string.pack("<I4c32I4I2c"..#result.info,result.userid,fillStr(result.date,32),result.rank,#result.info,result.info)
end

--领取奖励结果
-- resppack[resppack.cmd.drawaward] = function(result)
-- 	bodystr = string.pack("<I4I2c"..#result.info,result.re,#result.info,result.info)
-- end

--开始回包
resppack[resppack.cmd.gamestart] = function(result)
	bodystr = string.pack("<bI2c"..#result.info .. "I2I2",result.re,#result.info,result.info,result.rand,result.step)
end

--结束回包
resppack[resppack.cmd.timeout] = function()

end

--gameover回包
resppack[resppack.cmd.gameover] = function(result)
	bodystr = string.pack("<bI4I4",result.iswin,result.best_rank,result.best_score)
end

--gamestep回包
resppack[resppack.cmd.gamestep] = function(isok)
	bodystr = string.pack("<b",isok)
end

--gamescene回包
resppack[resppack.cmd.gamescene] = function(score,seconds,rand,step)
	bodystr = string.pack("<I4I4I2I2",score,seconds,rand,step)
end


--心跳包
resppack[resppack.cmd.heartbeat] = function()
end

--进入房间回包
resppack[resppack.cmd.enterroom] = function(state,player_count,reason)
	bodystr = string.pack("<i4I4",state,player_count)
	if reason then
		bodystr = bodystr .. string.pack("<I2c"..#reason,#reason,reason)
	end
end

--离开房间回包
resppack[resppack.cmd.leaveroom] = function(userid,reasonid)
	bodystr = string.pack("<I4i4",userid,reasonid)
end


return resppack;