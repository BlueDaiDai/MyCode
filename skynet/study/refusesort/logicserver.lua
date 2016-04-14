package.path = "./study/refusesort/?.lua;" .. package.path
local skynet = require "skynet"
require "skynet.manager"	-- import skynet.register

local rpc = require "rpc_baison"
local redis_helper = require "redis_helper"

local command = {}

local cache_name={}

local function add_name_to_cache(userid,username)
	cache_name[userid] = username
	--默认缓存24小时
	timeout = timeout or (24 * 3600 * 100)
	--缓存 (timeout/100)秒 时间精度是1/100
	skynet.timeout(timeout, function() cache_name[userid] = nil end)	
end

local function get_username(userid)
	local username = cache_name[userid]
	if username == nil then
		username = rpc.get_userinfo(userid)
		add_name_to_cache(userid,username)
	end
	
	return username
end

local function convert_array_to_rank(rank_items,startindex,array)
	local j = 1
	local tempranks = {}
	for i=1,#array do
		if i % 2 == 1 then
			local v = {}
			v.rank = startindex + j
			v.userid = array[i]
			v.username = get_username(v.userid)
			tempranks[j] = v
		else
			tempranks[j].maxscore	= array[i]
			table.insert(rank_items,tempranks[j])
			j = j + 1
		end
	end
	return rank_items
end

function command.get_rank_items(userid)
	local topn = tonumber(skynet.getenv "topn")
	local topranks,topstart,ranks,rankstart = redis_helper.get_rank_list(userid,3,topn)
	local rank_items = {}
	convert_array_to_rank(rank_items,topstart,topranks)
	convert_array_to_rank(rank_items,rankstart,ranks)
	-- for i=1,#rank_items do
	-- 	for k,v in pairs(rank_items[i]) do
	-- 		print(k,v)
	-- 	end
	-- end
	return rank_items
end

function command.add_score(userid,score)
	redis_helper.add_score(userid,score)
end

function command.get_award_info(userid)
	return redis_helper.get_award_info(userid)
end

function command.get_user(userid)
	local user = {}
	--redis获取的名次从零开始
	user.rank = redis_helper.get_rank(userid) + 1
	user.score = redis_helper.get_score(userid)
	user.name = get_username(userid)
	user.total = redis_helper.get_count()
	user.remain = redis_helper.get_remain(userid)
	return user
end

function command.sub_remain(userid)
	redis_helper.decr(userid)
end

function command.verify(userid,authentic)
	return rpc.verify(userid,authentic)
end

-- function command.set(key, value)
-- 	local r = skynet.call("SIMPLEDB", "lua", "set", self.what, self.value)
-- end


skynet.start(function()
	
	skynet.dispatch("lua", function(session, address, cmd, ...)
		local f = command[string.lower(cmd)]
		if f then
			skynet.ret(skynet.pack(f(...)))
		else
			error(string.format("Unknown command %s", tostring(cmd)))
		end
	end)
	-- print("get_userinfo:" .. rpc.get_userinfo(833424))
	-- print("verify:" .. tostring(rpc.verify(1895853,"9bedb8f92df3cf89")))
	-- print("verify:" .. tostring(rpc.verify(1895853,"9bedb8f92df3cf88")))
	-- print("addmoney:" .. tostring(rpc.addmoney(833424,1)))
	redis_helper.init()
	-- print("get_rank:" .. redis_helper.get_rank(823424))
	-- print("get_score:" .. redis_helper.get_score(823424))
	-- redis_helper.add_score(823424,5)
	-- print("get_rank:" .. redis_helper.get_rank(823424))
	-- print("get_score:" .. redis_helper.get_score(823424))
	--command["get_rank_items"](833424)
	
	--command["get_rank_items"](833425)
	-- local crypt = require "crypt"
	-- local secret = "BS789net"
	
	-- local encodestr = crypt.desencode(secret,"abcdefgh")
	
	-- --print(encodestr,#encodestr)
	
	-- local decodestr = crypt.desdecode(secret,encodestr)
	
	-- print(decodestr,#decodestr)
	
	skynet.register "LOGICSERVER"
end)
