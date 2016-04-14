package.path = "./study/search/?.lua;" .. package.path
local skynet = require "skynet"
require "skynet.manager"	-- import skynet.register

local command = {}

local count = {}
local time = {}
local actorNum = 0
local name 

-- local function send_package(pack)
-- 	local package = string.pack(">s2", pack)
-- 	socket.write(client_fd, package)
-- end





local function isSearchOver()
	-- print("isSearchOver:",#count,#time,actorNum)
	-- print("type:",type(#count),type(#time),type(actorNum))
	-- print("#count == actorNum :",(#count) == actorNum ,(#time) == actorNum)
	if #count == actorNum and #time == actorNum then
		--print("进入函数内部！")
		local maxTime = 0
		for i = 1,#time do
			if time[i] > maxTime then
				maxTime = time[i]
			end
		end

		local totalCount = 0
		for i = 1,#count do
			totalCount = totalCount + count[i]
		end

		-- print("文中"..name.."出现的次数为：",totalCount)
		-- print("查找所用总时间为：",maxTime)

		--发包告诉客户端用了多少时间、一共有词语多少个！
		skynet.send("AGENT", "lua", "tellTime", totalCount,maxTime)
	end
end

function command.setcount(value)
	--print("agent->setCount is gotten!")
	table.insert(count,value)
	isSearchOver()
end

function command.settime(value)
	--print("agent->setTime is gotten!")
	table.insert(time,value)
	isSearchOver()
end

function command.set_actor_num(value1,value2)
	--print("printServer->set_actor_num is gotten!")
	actorNum = tonumber(value1)
	name = value2
end


function command.reset()
	actorNum = 0
	time = {}
	count = {}
end

skynet.start(function()
	skynet.dispatch("lua", function(session, address, cmd, ...)
		-- print("com:",cmd)
		local f = command[string.lower(cmd)]
		if f then
			--skynet.ret(skynet.pack(f(...)))
			f(...)
		else
			error(string.format("Unknown command %s", tostring(cmd)))
		end
	end)
	skynet.register "PRINTSERVER"
end)
