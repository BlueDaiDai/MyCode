package.path = "./study/search/?.lua;" .. package.path
local skynet = require "skynet"
require "skynet.manager"	-- import skynet.register

local command = {}
local host
local socket = require "socket"
local sprotoloader = require "sprotoloader"
local client_fd = {}
--local private = { obj = nil, chat = nil}
local obj = nil
local myId = nil

local function send_package(pack)
	local package = string.pack(">s2", pack)
	for i = 1,#client_fd do
		socket.write(client_fd[i], package)
	end
end

local function send_privatePackage(pack)
	local package = string.pack(">s2", pack)
	socket.write(obj, package)
end

local function send_promptPackage(pack)
	local package = string.pack(">s2", pack)
	socket.write(myId, package)
end

function command.client_id(id)
	table.insert(client_fd,id)
end



function command.ask_member()
	host = sprotoloader.load(1):host "package"
	send_request = host:attach(sprotoloader.load(2))

	for i = 1,#client_fd do
		send_package(send_request ("member",{ person = client_fd[i] }))
	end
end

function command.group_chat(chatContent,id)
	--print("group_chat:",chatContent)
	host = sprotoloader.load(1):host "package"
	send_request = host:attach(sprotoloader.load(2))
	send_package(send_request ("gchat",{ groupChat = id..":"..chatContent }))
end

function command.private_chat(chatContent,id)
	--print("group_chat:",chatContent)
	local function getObj(str, delimiter)
		if str==nil or str=='' or delimiter==nil then
			return nil
		end
		
	    local result = {}
	    for match in (str..delimiter):gmatch("(.-)"..delimiter) do
	        table.insert(result, match)
	    end
	    return result[1]
	end

	obj = getObj(chatContent,"#")
	print("obj:",obj)
	local l1 = string.len(obj)
	local l2 = string.len(chatContent)
	local chat = string.sub(chatContent,l1 + 2,l2)

	host = sprotoloader.load(1):host "package"
	send_request = host:attach(sprotoloader.load(2))
	if string.len(chat) == 0 then
		myId = id
		send_promptPackage(send_request ("prompt",{ alert = "请检查您的私聊命令格式！" }))
	else
		send_privatePackage(send_request ("pchat",{ privateChat = id..":"..chat }))
	end
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
