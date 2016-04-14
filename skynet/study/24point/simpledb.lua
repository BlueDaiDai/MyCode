local skynet = require "skynet"
require "skynet.manager"	-- import skynet.register
local db = {}

local command = {}

function command.GET(key)
	return db[key]
end

function command.DEL(key)
	db[key] = nil
end

function command.SET(key, value,timeout)
	
	if db[key] == nil then
		--默认缓存24小时
		timeout = timeout or (24 * 3600 * 100)
		--缓存 (timeout/100)秒 时间精度是1/100
		skynet.timeout(timeout, function() db[key] = nil end)	
	end
	
	db[key] = value
end

skynet.start(function()
	skynet.dispatch("lua", function(session, address, cmd, ...)
		local f = command[string.upper(cmd)]
		if f then
			skynet.ret(skynet.pack(f(...)))
		else
			error(string.format("Unknown command %s", tostring(cmd)))
		end
	end)
	skynet.register "SIMPLEDB"
end)
