local skynet = require "skynet"
local snax = require "snax"


local max_client = 4096

skynet.start(function()
	print("Server start")
	local console = skynet.newservice("console")  --启动控制台模块
	local debug_console = tonumber(skynet.getenv "debug_port")
	skynet.newservice("debug_console",debug_port)
	skynet.newservice("simpledb")   --简单数据库
	skynet.newservice("logicserver")
	skynet.newservice("awardservice")
	local watchdog = skynet.newservice("watchdog")
	skynet.call(watchdog, "lua", "start", {
		port = socket_port,
		maxclient = max_client,
		nodelay = true,
	})

	print("Watchdog listen on ", socket_port)

	skynet.exit()
end)

