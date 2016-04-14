local httpc = require "http.httpc"
local json = require "cjson"

local rpc = {}

function rpc.get_userinfo(userid)
	local form = {act="getinfobyid",uid=userid}
	local respheader
	local ok,status, body = pcall(httpc.post,"myapi.nbgame.cn", "/api/base.php",form,respheader)
	local username = ""
	if ok == false then return username end
	
	local ok, result  = pcall(json.decode,body)
	
	
	if ok and  result.i then username = result.i.name end
	
	return username
		
end

function rpc.verify(userid,authentic)
	
	local content = "{\"Dest_Addr\":{\"Server_ID\":0},\"Password\":\"" .. authentic .."\",\"Src_Addr\":{\"Type_ID\":3,\"User_ID\":\"" .. userid .."\"}}}"
	local respheader
	local header
	--method, host, url, recvheader, header, content
	local ok,status, body = pcall(httpc.request,post,"115.238.147.75:8080", "/dsmp/schemas/UserLoginReq",respheader,header,content)
	if ok == false then return false end
		
	local ok, result  = pcall(json.decode,body)
	
	local re = false
	if ok and result.hRet == 0 then
		re = true
	end
	
	return re
end

function rpc.addmoney(userid,money,reason)
	reason = reason or "24point add money from 24point server"
	local content = "{\"appid\":999,\"money\":" .. money .. ",\"score\":0,\"text\":\"" .. reason .. "\",\"uid\":" .. userid .. "}"
	local respheader
	local header
	--method, host, url, recvheader, header, content
	local ok,status, body = pcall(httpc.request,post,"115.238.147.75:5100", "/dsmp/schemas/SafePaidFee",respheader,header,content)
	if ok == false then return false end
		
	local ok, result  = pcall(json.decode,body)
	
	local re = false
	if ok and result.hRet == 0 then
		re = true
	end
	
	return re
end

return rpc