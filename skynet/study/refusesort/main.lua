local skynet = require "skynet"
local snax = require "snax"

local max_client = 4096

skynet.start(function()
	print("Server start")
	local console = skynet.newservice("console")
	local debug_port = tonumber(skynet.getenv "debug_port")
	skynet.newservice("debug_console",debug_port)
	skynet.newservice("simpledb")
	skynet.newservice("logicserver")
	skynet.newservice("awardservice")
	local watchdog = skynet.newservice("watchdog")
	local socket_port = tonumber(skynet.getenv "socket_port")
	skynet.call(watchdog, "lua", "start", {
		port = socket_port,
		maxclient = max_client,
		nodelay = true,
	})
	print("Watchdog listen on ", socket_port)

	skynet.exit()
end)
