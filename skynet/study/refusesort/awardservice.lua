package.path = "./study/refusesort/?.lua;" .. package.path
local skynet = require "skynet"
local award_items

local rpc = require "rpc_baison"
local redis_helper = require "redis_helper"
local json = require "cjson"

local command = {}

local function get_award_item(rank)
    for i=1,#award_items do
        local item = award_items[i]
        if item.start_rank <= rank and rank<=item.end_rank then
            return item
        end
    end
end

--发奖
local function doaward()
    local isaward = redis_helper.isaward()
    --print(isaward,type(isaward))
    if isaward == true then
        skynet.error("昨日的奖已经发过了")
        return
    end
    
    --发奖
    local topn = award_items[#award_items].end_rank
    local userids = redis_helper.get_top_award_rank_list(topn)
    for i=1,#userids do
        local item = get_award_item(i)
        local userid = tonumber(userids[i])
        if item.money > 0 then
            local re = rpc.addmoney(userid,item.money)
            local result = {}
            result.userid = userid
            result.date = os.date("%Y-%m-%d", os.time() - 1*24*3600)
            result.rank = i
            result.info = "奖励" .. item.money .. "银子"
            result.time = os.time() 
            print(result.time)
            local info = json.encode(result)
            
            redis_helper.set_award_info(userid,info) --记录到redis
            skynet.error(info) --记录log
        end
        
        if item.hammer > 0 then
        end
    end
    redis_helper.setaward()--设置发过奖的标记，按天
end

local function startrun()
    while true do
        doaward()
        --skynet.sleep(  1*60*100) --1分钟执行一次
        skynet.sleep(24*3600*100) --1天执行一次
    end
end


function command.drawaward()
    return true
end

function command.hello()

end

skynet.start(function()
	local award_index = tonumber(skynet.getenv "award_index")
    award_items = require("awarditems")[award_index]
    print(award_items[1].info)
    
	skynet.dispatch("lua", function(session, address, cmd, ...)
		local f = command[string.lower(cmd)]
		if f then
			skynet.ret(skynet.pack(f(...)))
		else
			error(string.format("Unknown command %s", tostring(cmd)))
		end
	end)

	redis_helper.init()
    
    --首先完成昨天的发奖
    skynet.fork(doaward)
    --计算出下一次运行的时间,第二天凌晨00:01秒开始运行
    local curtime = os.time()
    local nexttime = curtime + 24*3600
    local tab = os.date("*t",nexttime)
    tab.hour=00
    tab.min=00
    tab.sec=01
    nexttime = os.time(tab)
    local difftime = nexttime - curtime
    
    skynet.error("awardservice 再过" .. difftime .. "秒执行计划任务")
    skynet.timeout(difftime*100,startrun)
	--skynet.register "LOGICSERVER"
end)