package.path = "./study/search/?.lua;" .. package.path
require "skynet.manager"
local skynet = require "skynet"
local netpack = require "netpack"
local socket = require "socket"
local sproto = require "sproto"
local sprotoloader = require "sprotoloader"
local reqparse = require "reqparse"

local WATCHDOG
local host
local send_request

local CMD = {}
local REQUEST = {}
local client_fd

local actorNum = 0

--给出切分的段落数量，并返回文本table
local function getText(num)
	local function readFile(fileName)
	    local f = assert(io.open(fileName,'r'))
	    local content = f:read('*all')
	    f:close()
	    return content
	end
	local file = "/Users/baison-linc/Documents/Blue/skynet/study/search/shediao.txt"
	local text = readFile(file)
	local length = string.len(text)

	local p = {}
	p[1] = 0
	for i = 1,num do
		table.insert(p,math.floor(length/num*i))
	end

	local textString = {}
	for i = 1,num do
		textString[i] = string.sub(text,p[i],p[i + 1])
	end 
	return textString
end

local function search(num)
	actorNum = num
	local name = "欧阳锋"
	skynet.send("PRINTSERVER", "lua", "set_actor_num", actorNum,name)
	--print("启动"..actorNum.."个actor来搜寻郭靖、黄蓉、欧阳锋！")
	local textString = getText(actorNum)
	
	for i = 1,actorNum do
		skynet.send("LOGICSERVER", "lua", "search", textString[i],name)
		
	end
end



function REQUEST:get()
	--print("get", self.what)
	skynet.send("PRINTSERVER", "lua", "reset")
	search(self.what)
	local r = skynet.call("SIMPLEDB", "lua", "get", self.what)
	return { result = r }
end

function REQUEST:set()
	print("set", self.what, self.value)
	local r = skynet.call("SIMPLEDB", "lua", "set", self.what, self.value)
end

function REQUEST:handshake()
	return { msg = "Welcome to skynet, I will send heartbeat every 5 sec." }
end

function REQUEST:quit()
	skynet.call(WATCHDOG, "lua", "close", client_fd)
end

local function request(name, args, response)
	local f = assert(REQUEST[name])
	local r = f(args)
	if response then
		return response(r)
	end
end

local function send_package(pack)
	local package = string.pack(">s2", pack)
	socket.write(client_fd, package)
end





skynet.register_protocol {
	name = "client",
	id = skynet.PTYPE_CLIENT,
	unpack = function (msg, sz)
		return host:dispatch(msg, sz)
	end,
	dispatch = function (_, _, type, ...)
		if type == "REQUEST" then
			local ok, result  = pcall(request, ...)
			if ok then
				if result then
					send_package(result)
				end
			else
				skynet.error(result)
			end
		else
			assert(type == "RESPONSE")
			error "This example doesn't support request client"
		end
	end
}

function CMD.start(conf)
	local fd = conf.client
	local gate = conf.gate
	WATCHDOG = conf.watchdog
	-- slot 1,2 set at main.lua
	host = sprotoloader.load(1):host "package"
	send_request = host:attach(sprotoloader.load(2))
	skynet.fork(function()
		while true do
			send_package(send_request "heartbeat")
			skynet.sleep(500)
		end
	end)

	client_fd = fd
	skynet.call(gate, "lua", "forward", fd)
end

function CMD.disconnect()
	-- todo: do something before exit
	skynet.exit()
end

function CMD.tellTime(pCount,pTime)
	-- print("tellTime")
	-- print("pTime:",pTime,"pCount:",pCount)
	host = sprotoloader.load(1):host "package"
	send_request = host:attach(sprotoloader.load(2))
	send_package(send_request ("time",{ time = pTime,count = pCount }))
end

skynet.start(function()
	skynet.dispatch("lua", function(_,_, command, ...)
		local f = CMD[command]
		f(...)
		--skynet.ret(skynet.pack(f(...)))
	end)

	skynet.register "AGENT"
end)


