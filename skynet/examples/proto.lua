local sprotoparser = require "sprotoparser"

local proto = {}

proto.c2s = sprotoparser.parse [[
.package {
	type 0 : integer
	session 1 : integer
}

handshake 1 {
	response {
		msg 0  : string
	}
}

get 2 {
	request {
		what 0 : string
	}
	response {
		result 0 : string
	}
}

set 3 {
	request {
		what 0 : string
		value 1 : string
	}
}

quit 4 {}

getGroupChat 5 {
	request {
		what 0 : string
	}
	response {
		result 0 : string
	}
}

getPrivateChat 6 {
	request {
		what 0 : string
	}
	response {
		result 0 : string
	}
}

getMember 7 {
	request {
		what 0 : string
	}
	response {
		result 0 : string
	}
}
]]

proto.s2c = sprotoparser.parse [[
.package {
	type 0 : integer
	session 1 : integer
}

heartbeat 1 {}

time 2 {
	request {
		time 0 : string
		count 1 : string
	}

	response {
		time 0 : string
		count 1 : string
	}

}


gchat 3 {
	request {
		groupChat 0 : string
	}

	response {
		groupChat 0 : string
	}

}



member 4 {
	request {
		person 0 : string
	}

	response {
		person 0 : string
	}

}

pchat 5 {
	request {
		privateChat 0 : string
	}

	response {
		privateChat 0 : string
	}

}

prompt 6 {
	request {
		alert 0 : string
	}

	response {
		alert 0 : string
	}

}
]]

return proto
