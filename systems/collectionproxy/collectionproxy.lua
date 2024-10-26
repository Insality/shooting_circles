local ecs = require("decore.ecs")
local decore = require("decore.decore")

local logger = decore.get_logger("system.collectionproxy")

local HASH_PROXY_LOADED = hash("proxy_loaded")
local HASH_INIT = hash("init")
local HASH_ENABLE = hash("enable")
local HASH_ACQUIRE_INPUT_FOCUS = hash("acquire_input_focus")

---@class component.collectionproxy: string
decore.register_component("collectionproxy")

---@class system.collectionproxy: system
local M = {}


---@static
---@return system.collectionproxy
function M.create_system()
	local system = decore.system(M, "collectionproxy", { "collectionproxy" })
	return system
end


function M:postWrap()
	self.world.queue:process("on_message", self.on_message, self)
end


function M:onAdd(entity)
	msg.post(entity.collectionproxy, "load")
end


function M:on_message(message)
	if message.message_id == HASH_PROXY_LOADED then
		local sender = message.sender
		msg.post(sender, HASH_INIT)
		msg.post(sender, HASH_ENABLE)
		msg.post(sender, HASH_ACQUIRE_INPUT_FOCUS)
	end
end


return M
