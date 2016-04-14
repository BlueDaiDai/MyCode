local skynet = require "skynet"
local snax = require "snax"
local sprotoloader = require "sprotoloader"

local max_client = 4096

skynet.start(function()
	print("Server start")
	skynet.uniqueservice("protoloader")
	local console = skynet.newservice("console")
	skynet.newservice("logicserver")
	skynet.newservice("printserver")
	skynet.newservice("debug_console",8000)
	local watchdog = skynet.newservice("watchdog")
	skynet.call(watchdog, "lua", "start", {
		port = 8888,
		maxclient = max_client,
		nodelay = true,
	})
	print("Watchdog listen on ", 8888)
	skynet.exit()
end)
