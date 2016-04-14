local resppack = {}

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
	local str =  string.pack("<I2I2bbI4I2",tag,#bodystr,checkcoe,version,cmdtype,reserved) .. bodystr
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
	bodystr = string.pack("<I4I4I4I4I2",person.userid,person.total,person.best_rank,person.best_score,person.remain)
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
	bodystr = string.pack("<bI2c"..#result.info,result.re,#result.info,result.info)
end

--结束回包
resppack[resppack.cmd.timeout] = function()

end

--gameover回包
resppack[resppack.cmd.gameover] = function(result)
	bodystr = string.pack("<bI4I4",result.iswin,result.best_rank,result.best_score)
end

--gamestep回包
resppack[resppack.cmd.gamestep] = function()
end

--gamescene回包
resppack[resppack.cmd.gamescene] = function(score,seconds)
	bodystr = string.pack("<I4I4",score,seconds)
end


--心跳包
resppack[resppack.cmd.heartbeat] = function()
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