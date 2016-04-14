local skynet = require "skynet"
local snax = require "snax"

local max_client = 4096

skynet.start(function()
	print("Server start")
	local console = skynet.newservice("console")
	skynet.newservice("debug_console",8000)
	skynet.newservice("simpledb")
	skynet.newservice("logicserver")
	skynet.newservice("awardservice")
	local watchdog = skynet.newservice("watchdog")
	skynet.call(watchdog, "lua", "start", {
		port = 8888,
		maxclient = max_client,
		nodelay = true,
	})
	print("Watchdog listen on ", 8888)

	skynet.exit()
end)
