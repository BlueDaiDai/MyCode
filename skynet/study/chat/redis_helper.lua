local redis_helper = {}
local redis  = require "redis"

local json = require "cjson"
local conf = {
	host = "127.0.0.1" ,
	port = 6379 ,
	db = 0
}


local function get_rank_key()
	return "rank." .. os.date("%Y%m%d", os.time())
end

local function get_remain_key(userid)
	return "remain." .. os.date("%Y%m%d", os.time()) .. "." ..userid
end

local function get_award_rank_key()
	return "rank." .. os.date("%Y%m%d", os.time())
	--return "rank." .. os.date("%Y%m%d",os.time() - 1*24*3600)
end

local function get_award_info_key(userid)
	return "award.info."..userid 
end

local function get_award_flag_key()
	return "award.flag." .. os.date("%Y%m%d", os.time() - 1*24*3600) --减去一天，0点以后计算昨天的
end


function redis_helper.init()
	db = redis.connect(conf)
end

--ZREVRANK salary tom 排名,排名序号从0开始
function redis_helper.get_remain(userid)
	local key = get_remain_key(userid)
	local remain = db:get(key)
	if remain == nil then
		remain = 10
		db:set(key,remain)
	end
	return remain
end

function redis_helper.decr(userid)
	local key = get_remain_key(userid)
	db:decr(key)
end

function redis_helper.isaward()
	local key = get_award_flag_key()
	return db:exists(key)
end

function redis_helper.setaward()
	local key = get_award_flag_key()
	db:set(key,1)
end


function redis_helper.get_award_info(userid)
	local key = get_award_info_key(userid)
	local result =  db:get(key)
	db:del(key) --获奖信息只使用一次，去取了，就删除掉
	return json.decode(result)
end

function redis_helper.set_award_info(userid,info)
	local key = get_award_info_key(userid)
	db:set(key,info)
end



--ZREVRANK salary tom 排名,排名序号从0开始
function redis_helper.get_rank(userid)
	local key = get_rank_key()
	local rank = db:zrevrank(key,userid)
	if rank == nil then
		--如果没有名次默认给0分,再去获取名次
		db:zadd({key,0,userid})
		rank = db:zrevrank(key,userid)
	end
	return rank
end

--ZSCORE key member
--获取用户的分数
function redis_helper.get_score(userid)
	local key = get_rank_key()
	local score = db:zscore(key,userid)
	if score == nil then
		db:zadd({key,0,userid})
		score = db:zscore(key,userid)
	end
	return score
end

--ZADD page_rank 10 google.com
--在有序集合中添加一个分数
function redis_helper.add_score(userid,score)
	local key = get_rank_key()
	db:zadd({key,score,userid})
end


function redis_helper.get_top_rank_list(topn)
	local key = get_rank_key()
	topn = topn or 3
	local ranks = db:zrevrange({key,0,topn-1,"withscores"})
	return ranks,0
end

function redis_helper.get_top_award_rank_list(topn)
	local key = get_award_rank_key()
	topn = topn or 3
	local ranks = db:zrevrange({key,0,topn-1})
	return ranks,0
end

--ZREVRANGE salary 0 -1 WITHSCORES 降序号返回
function redis_helper.get_rank_list(userid,offset,topn)
	local key = get_rank_key()
	local rank = redis_helper.get_rank(userid)
	topn = topn or 3
	offset = offset or 3
	local topranks = db:zrevrange({key,0,topn-1,"withscores"})
	local rankstart = rank-offset
	local rankend = rank+offset
	
	if rankstart <= 2 then
		rankstart = 3
		rankend = 3+offset * 2
	end
	
	local ranks = db:zrevrange({key,rankstart,rankend,"withscores"})
	local rank_items
	

	
	return topranks,0,ranks,rankstart
end


--ZCOUNT salary 2000 5000 
function redis_helper.get_count(maxscore)
	--最高200分
	maxscore = maxscore or 200
	local key = get_rank_key()
	return db:zcount({key,0,maxscore})
end

return redis_helper
