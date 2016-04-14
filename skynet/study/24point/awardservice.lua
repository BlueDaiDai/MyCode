package.path = "./study/24point/?.lua;" .. package.path
local skynet = require "skynet"
local award_items = require("awarditems")

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
    
    print(aa)
    local isaward = redis_helper.isaward()
    print(isaward,type(isaward))
    if tonumber(isaward) == 1 then
        print("已经发过奖了")
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
            result.date = os.date("%Y%m%d", os.time() - 1*24*3600)
            result.rank = i
            result.info = "你获得了第".. i .. "名 奖励" .. item.money .. "银子"
            result.time = os.time() 
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
        skynet.sleep(  1*60*100) --1分钟执行一次
        --skynet.sleep(24*3600*100) --1天执行一次
    end
end


function command.drawaward()
    return true
end

function command.hello()

end

skynet.start(function()
	
	skynet.dispatch("lua", function(session, address, cmd, ...)
		local f = command[string.lower(cmd)]
		if f then
			skynet.ret(skynet.pack(f(...)))
		else
			error(string.format("Unknown command %s", tostring(cmd)))
		end
	end)

	--redis_helper.init()
    
    doaward()

	
	--skynet.register "LOGICSERVER"
end)