package.path = "./study/search/?.lua;" .. package.path
local skynet = require "skynet"
require "skynet.manager"	-- import skynet.register

local command = {}


function command.search(text,name)
	--print("开始查找")
	local time1 = skynet.time()
	local count = 0
	for w in string.gmatch(text,name) do
		count = count + 1
	end
	local time2 = skynet.time()
	--print("结束查找")


	-- print("射雕英雄传中"..name.."出现的次数为:",count)
	-- print("查找时间为:",time2 - time1)

	-- skynet.send("SIMPLEDB", "lua", "setcount",count)
	-- skynet.send("SIMPLEDB", "lua", "settime",time2 - time1)

	skynet.send("PRINTSERVER", "lua", "setcount", count)
	skynet.send("PRINTSERVER", "lua", "settime", time2 - time1)
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
	skynet.register "LOGICSERVER"
end)
